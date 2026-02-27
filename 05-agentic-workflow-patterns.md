# 05 — Agentic Workflow Patterns

> Agentic workflows are not just prompt chains — they are dynamic, tool-using, self-directing systems that adapt their behavior at runtime.

---

## What Makes a Workflow "Agentic"?

A system is agentic when an LLM drives multi-step decisions autonomously:

| Property | Description |
|---|---|
| **Tool use** | Calls external functions, APIs, code runners, or search |
| **State persistence** | Context is preserved across turns and steps |
| **Dynamic control flow** | The model influences branching, looping, and termination |
| **Goal-directedness** | Behavior is oriented toward completing an objective, not just answering |

The contrast with pipelines: traditional LLM pipelines are deterministic DAGs; agentic systems allow feedback cycles, re-planning, and emergent routing.

---

## 1. ReAct (Reason + Act)

**Paper**: Yao et al., ICLR 2023, arXiv:2210.03629

The foundational agentic loop. Every production agent implements some variant.

### Loop Structure

```
Thought → Action → Observation → Thought → Action → Observation → ... → Final Answer
```

Each iteration:
1. **Thought**: Model reasons in natural language about what to do (chain-of-thought)
2. **Action**: Discrete tool call is emitted (search, calculator, code execution, API call)
3. **Observation**: Tool result injected back into context; grounds next reasoning step

### Example Trace

```
Thought: I need to find the current year's revenue for NVIDIA. I'll search for it.
Action: web_search("NVIDIA revenue fiscal year 2025")
Observation: NVIDIA reported $130.5 billion in revenue for FY2025, up 114% YoY.

Thought: I now have the revenue figure. I should also find the operating income.
Action: web_search("NVIDIA operating income FY2025")
Observation: NVIDIA operating income FY2025: $87.1 billion.

Thought: I have both numbers. I can calculate the operating margin and respond.
Action: finish("NVIDIA FY2025: Revenue $130.5B, Operating Income $87.1B, 
               Operating Margin: 66.7%")
```

### ReAct Variants

| Variant | Description | Trade-off |
|---|---|---|
| **Standard ReAct** | Interleaved thought+action+observation | Flexible; higher latency |
| **ReWOO** | Plans all tool calls upfront; executes in batch | Lower cost; less adaptive |
| **CodeAct** | Actions are Python code; self-corrects via re-execution | Expressive; requires sandboxing |
| **ReAct + Reflexion** | Verbal critique after failures; stored as working memory | Higher accuracy; more compute |

### Failure Modes & Mitigations

| Failure Mode | Description | Mitigation |
|---|---|---|
| Repetitive loops | Same action repeated with identical arguments | Loop detection; max iterations cap |
| Reasoning-action disconnect | Thought says one thing; action does another | Structured output parsing |
| Context overflow | Long trajectories fill context window | Sliding window; trajectory compression |
| Premature termination | Concludes impossible when it isn't | Minimum step count; reflection step |
| Hallucinated observations | Model generates observations without tool | Parser strips non-tool observations |

---

## 2. Plan → Execute → Reflect Cycle

More structured variant that separates cognition into explicit phases.

### Full Cycle

```
[Planner LLM] → plan[subtask_1, subtask_2, ...] 
    → [Executor Agent/Loop per subtask] → result_1, result_2, ...
        → [Reflector LLM] → "goal met?" / revised_plan / done
```

### Phase Breakdown

**Plan**:
- High-capability model decomposes the user goal into ordered subtasks
- May produce a DAG (not just a list) for parallelizable work
- Output: structured task list with dependencies

**Execute**:
- Each subtask executed, typically with its own ReAct loop
- Often uses a smaller/cheaper model than the planner
- Error isolation: one subtask failure doesn't abort all others

**Reflect**:
- After each subtask (or all subtasks): Was the goal met? Were there errors?
- Can trigger re-planning with execution history as context
- **Reflexion** (Shinn et al., 2023): Verbal critique stored as working memory for future attempts

### When to Use Plan-Execute over ReAct

- Tasks decompose cleanly into independent sequential or parallelizable steps
- Different execution steps benefit from different specialized tools/models
- You need to show the plan to a human for approval (natural HITL breakpoint)
- Subtasks are long-running and you need error isolation

### LangChain Implementation

```python
from langchain.agents import PlanAndExecute
agent = PlanAndExecute(
    planner=create_planner(llm),
    executor=create_executor(llm, tools)
)
result = agent.invoke({"input": "Research and summarize recent breakthroughs in fusion energy"})
```

---

## 3. Supervisor–Worker Pattern

### Structure

```
           ┌─────────────────────────────────────┐
           │         Supervisor LLM               │
           │  (routes, delegates, monitors,       │
           │   synthesizes, handles failures)      │
           └──────┬────────────┬──────────────────┘
                  │            │
         ┌────────▼───┐  ┌─────▼──────┐  ┌───────────┐
         │  Worker A  │  │  Worker B  │  │  Worker C  │
         │ (Research) │  │   (Math)   │  │  (Writer)  │
         └────────────┘  └────────────┘  └───────────┘
```

### Mechanics

- Supervisor receives the user goal and routes subtasks to specialized workers via tool calls (handoff tools)
- Workers are fully autonomous agents, each with their own tool belt and ReAct loop
- Workers report structured results to the Supervisor
- Supervisor decides: route elsewhere, synthesize results, or terminate
- Supervisor tracks overall state and handles failures by re-routing

### Three-Layer Enterprise Variant

```
LAYER 1: Planner     — decomposes, prioritizes, assigns
LAYER 2: Workers     — execute specialized subtasks
LAYER 3: Critic      — quality gates, validation, re-routing
```

### LangGraph Implementation

```python
from langgraph_supervisor import create_supervisor
from langgraph.prebuilt import create_react_agent

research_agent = create_react_agent(model, tools=[web_search, arxiv_search])
code_agent = create_react_agent(model, tools=[code_interpreter, file_read])
writer_agent = create_react_agent(model, tools=[file_write])

workflow = create_supervisor(
    [research_agent, code_agent, writer_agent],
    model=model
)
result = workflow.invoke({"messages": [HumanMessage("Research quantum computing and write a blog post")]})
```

### Advantages and Risks

**Advantages**:
- Clear separation of concerns; workers swappable/upgradeable independently
- Supervisor can dynamically spawn new workers for unforeseen subtasks
- Natural audit trail: every delegation is a logged event
- Workers can be on different models (expensive planner + cheap executor)

**Risks**:
- Supervisor is single point of failure
- Routing quality bottlenecks on Supervisor model capability
- Context explosion if Supervisor accumulates all worker outputs

---

## 4. Peer-to-Peer / Conversational Pattern (AutoGen)

Rather than a central coordinator, agents communicate directly:

```
Agent A ←──────→ Agent B
   │                │
   └──────→ Agent C ┘
```

**AutoGen** (Microsoft Research) is the primary framework:

```python
import autogen

assistant = autogen.AssistantAgent(
    name="assistant",
    llm_config={"model": "gpt-4o"}
)

user_proxy = autogen.UserProxyAgent(
    name="user_proxy",
    code_execution_config={"work_dir": "coding"},
    human_input_mode="NEVER"  # fully autonomous
)

# Two-agent chat
user_proxy.initiate_chat(
    assistant,
    message="Write and test a Python function to detect palindromes"
)
```

**Key AutoGen patterns**:
- `UserProxyAgent` — represents human; can execute code
- `AssistantAgent` — LLM-backed; generates plans/code/answers
- `GroupChat` — multi-party conversation container
- `GroupChatManager` — routes messages in multi-agent conversations

**When to use**: Open-ended research, code-generation+execution loops, debate/critique scenarios, rapid prototyping.

---

## 5. Role-Based Crew Pattern (CrewAI)

Models agents as team members with defined roles:

```python
from crewai import Agent, Task, Crew

researcher = Agent(
    role="Senior Research Analyst",
    goal="Uncover cutting-edge developments in AI",
    backstory="Expert at synthesizing complex information",
    tools=[search_tool, arxiv_tool],
    llm=model
)

writer = Agent(
    role="Tech Content Writer",
    goal="Craft compelling technical articles",
    backstory="Known for translating complex AI topics to clear prose",
    tools=[file_write_tool],
    llm=model
)

research_task = Task(
    description="Research the latest LLM benchmark results for 2025",
    expected_output="A detailed report with key findings and citations",
    agent=researcher
)

writing_task = Task(
    description="Write a blog post based on the research report",
    expected_output="An 800-word blog post in markdown",
    agent=writer,
    context=[research_task]  # receives researcher's output
)

crew = Crew(
    agents=[researcher, writer],
    tasks=[research_task, writing_task],
    verbose=True
)
result = crew.kickoff()
```

---

## 6. Evaluator-Optimizer Loop

A generator produces output; an evaluator critiques it; iteration continues until quality threshold is met.

```
┌──────────┐    output    ┌──────────────┐  pass  ┌────────────┐
│ Generator│ ──────────► │   Evaluator  │ ──────► │   Output   │
│   LLM    │ ◄────────── │    LLM       │         │   Delivery │
└──────────┘  feedback    └──────────────┘
                               │ fail (with feedback)
                               └──────────────────────────────┐
                                                               │
                                            Re-generate with  │
                                            feedback in prompt ▼
```

### Implementation

```python
def evaluator_optimizer(task: str, criteria: list[str], max_iterations: int = 5) -> str:
    response = generator_llm.generate(task)
    
    for iteration in range(max_iterations):
        evaluation = evaluator_llm.evaluate(
            response=response,
            criteria=criteria,
            return_format="pass_fail_with_feedback"
        )
        
        if evaluation.passed:
            return response
        
        response = generator_llm.generate(
            task=task,
            previous_response=response,
            feedback=evaluation.feedback
        )
    
    return response  # return best attempt after max iterations
```

### When to Use

- Code generation where tests can verify correctness
- Document writing where style/quality criteria can be specified
- Data extraction where schema compliance can be verified
- Any task where "good enough" has a formal definition

---

## 7. Parallelization Patterns

### Sectioning (Divide & Conquer)

Split work across independent parallel agents:

```python
import asyncio

async def parallel_research(topics: list[str]) -> list[str]:
    tasks = [research_agent.run(topic) for topic in topics]
    results = await asyncio.gather(*tasks)
    return results

# Synthesize parallel results
final_report = synthesizer_agent.run(
    task="Synthesize the following research findings",
    context=results
)
```

### Voting (Robustness via Consensus)

Sample N independent responses; take majority vote or best-of-N:

```python
import random

def majority_vote(question: str, n: int = 5) -> str:
    responses = [llm.generate(question, temperature=0.7) for _ in range(n)]
    # Extract structured answer from each response
    answers = [extract_answer(r) for r in responses]
    # Return most common answer
    return max(set(answers), key=answers.count)
```

**Use cases**: High-stakes factual questions where consistency matters; numerical calculations; classification tasks where accuracy > cost.

---

## 8. Human-in-the-Loop (HITL) Patterns

### Checkpoint Patterns

| Checkpoint Type | When to Interrupt | Implementation |
|---|---|---|
| **Pre-execution** | Before any irreversible action | `await user_confirmation()` before write tools |
| **Plan approval** | After planning, before execution | Show plan; human approves/modifies |
| **Quality gates** | After generation, before delivery | Human reviews before sending |
| **Exception handling** | When agent is stuck or uncertain | `raise NeedsHumanInput(reason)` |
| **Trust boundaries** | When scope exceeds granted permissions | Pause and request explicit authorization |

### HITL Implementation (LangGraph)

```python
from langgraph.checkpoint.memory import MemorySaver
from langgraph.types import interrupt

def risky_action_node(state):
    # Interrupt execution for human review
    user_decision = interrupt({
        "question": "About to delete 47 files. Confirm?",
        "files_to_delete": state["files"],
        "reason": state["reason"]
    })
    
    if user_decision["confirmed"]:
        return execute_deletion(state["files"])
    else:
        return {"status": "cancelled", "reason": "user rejected"}

# Resumable workflow
app = workflow.compile(
    checkpointer=MemorySaver(),  # enables pause/resume
    interrupt_before=["risky_action_node"]
)
```

### Pre-flight Checks

Before any session of autonomous execution:
1. **Verify scope**: Does the task description match the agent's stated capabilities?
2. **List planned tools**: Surface the planned tool calls; get approval
3. **Identify irreversibilities**: Explicitly list actions that cannot be undone
4. **Set abort conditions**: Define in advance what will trigger human escalation

---

## 9. Workflow State Machines

Complex workflows benefit from explicit state machine modeling:

```python
from langgraph.graph import StateGraph, END
from typing import TypedDict

class ResearchState(TypedDict):
    query: str
    search_results: list[str]
    outline: str
    draft: str
    final_report: str
    status: str  # planning | researching | writing | reviewing | done

workflow = StateGraph(ResearchState)

# Nodes
workflow.add_node("plan", create_plan)
workflow.add_node("research", execute_research)
workflow.add_node("write", write_draft)
workflow.add_node("review", review_and_revise)

# Edges with conditional routing
workflow.add_edge("plan", "research")
workflow.add_edge("research", "write")
workflow.add_conditional_edges(
    "review",
    lambda state: "write" if state["needs_revision"] else END
)
workflow.set_entry_point("plan")

app = workflow.compile(checkpointer=MemorySaver())
```

---

## 10. Checkpointing and Resumability

Long-running agentic tasks must support interruption and resumption:

```python
# Invoke with a thread ID for state persistence
config = {"configurable": {"thread_id": "task-abc-123"}}

# Start
result = app.invoke(initial_state, config=config)

# Resume after interruption
result = app.invoke(
    Command(resume={"user_decision": "approved"}),
    config=config
)

# Replay from checkpoint
snapshot = app.get_state(config)
print(f"Resuming from: {snapshot.next}")  # shows pending nodes
```

### Checkpointing Best Practices

1. Assign a stable `thread_id` to each user-initiated task
2. Store: current state, completed steps, pending tool calls, context summary
3. Support **rollback**: ability to revert to a prior checkpoint on error
4. Checkpoint frequency: after every irreversible action; after every LLM call in high-stakes workflows
5. TTL on checkpoints: long-running tasks should expire stale checkpoints after a configurable window

---

## Pattern Selection Guide

```
Is the task well-structured with clear sequential steps?
  → YES, single-path: Prompt Chaining
  → YES, parallel paths: Parallelization (Sectioning)
  → NO, open-ended: ReAct loop

Does the task require multiple specialized skills?
  → YES, coordinated: Plan-Execute-Reflect OR Supervisor-Worker
  → YES, conversational: AutoGen peer-to-peer
  → NO: Single agent with ReAct

Does quality need validation before delivery?
  → YES: Evaluator-Optimizer loop
  → NO: Skip this layer

Are there risky or irreversible actions?
  → YES: Human-in-the-Loop checkpoints
  → NO: Fully autonomous loop

Is the workflow complex enough to benefit from explicit state modeling?
  → YES: LangGraph StateGraph with typed state
  → NO: Direct LLM loop in Python
```

---

## Workflow Complexity Ladder

```
Level 1: Single LLM call (not agentic)
Level 2: Prompt chaining (deterministic pipeline)
Level 3: ReAct loop (single agent, dynamic tool use)
Level 4: Plan-Execute-Reflect (multi-phase single agent)
Level 5: Supervisor-Worker (multi-agent with central coordination)
Level 6: Multi-agent mesh (distributed, peer communication)
Level 7: Hierarchical multi-agent (nested supervisors)
```

**Start at Level 3 unless you have a clear reason to go higher.** Premature complexity is the #1 cause of unreliable agentic systems.

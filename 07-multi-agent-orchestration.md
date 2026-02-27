# 07 — Multi-Agent Orchestration

> Multi-agent systems distribute intelligence across specialized units to handle tasks that exceed any single agent's context window, skill set, or resource budget.

---

## Why Multi-Agent Systems?

| Limitation | Single Agent | Multi-Agent System |
|---|---|---|
| Context window | Fixed, easily exceeded | Sub-tasks fit within each agent's window |
| Specialization | Generalist only | Domain-expert agents per skill |
| Parallelism | Sequential | Truly concurrent sub-task execution |
| Fault tolerance | Single point of failure | Fallback to sibling agents |
| Model optimization | One model for everything | Right model per task (cost/quality) |
| Auditability | Single opaque chain | Per-agent traceable spans |

---

## The Fundamental Orchestration Loop

```
User Goal
   │
   ▼
┌─────────────┐    decompose    ┌───────────────────────┐
│ Orchestrator │ ─────────────► │  Task Queue / Planner │
└─────────────┘                 └───────────────────────┘
       ▲                                   │ dispatch
       │ aggregate                         ▼
       │                      ┌────────────────────────┐
       │                      │  Worker Agents (pool)  │
       │◄─────────────────────│  Agent A (Research)    │
       │      results         │  Agent B (Code)        │
       │                      │  Agent C (Critic)      │
       │                      └────────────────────────┘
       │
       ▼
Final Response / Artifact
```

---

## 1. Agent Roles and Specialization

Agents acquire identity through **role definition** — a combination of system prompt, tool access, memory scope, and model choice.

### Functional Role Catalog

| Role | Responsibility | Typical Tools |
|---|---|---|
| **Planner** | Decomposes goals into ordered subtasks | None / structured output |
| **Researcher** | Retrieves and synthesizes external information | Web search, RAG, document loaders |
| **Coder** | Generates, tests, and debugs code | Code interpreter, shell, linters, diff tools |
| **Critic / Reviewer** | Evaluates outputs for quality/correctness | Rubric prompts, diff comparison |
| **Memory Manager** | Maintains long-term context summaries | Vector store, episodic memory write |
| **Tool Caller** | Wraps APIs or side-effecting operations | REST clients, DB connectors |
| **Validator** | Asserts schema conformance and safety | JSON schema validators, guardrail models |
| **Summarizer** | Compresses agent outputs before passing up | Compression prompts |
| **Orchestrator** | Routes and coordinates other agents | Handoff tools, state management |

### Role Assignment Strategies

| Strategy | Description | Flexibility |
|---|---|---|
| **Static binding** | Roles hardcoded into system prompt at init | Low — simple but inflexible |
| **Dynamic injection** | Orchestrator injects role per task invocation | Medium — reuse generic agents |
| **Model specialization** | Different LLMs per role (large planner + small executor) | High — cost optimization |
| **Self-assignment** | Agents negotiate and claim roles based on context | Experimental |

### Specialization Trade-offs

```
Prompting-only specialization
  ✓ No training cost; easy to update roles
  ✗ Role bleed across turns; less reliable on edge cases

Fine-tuned specialist models  
  ✓ Consistent domain behavior; lower inference cost
  ✗ Training overhead; less flexible for new roles
```

---

## 2. Orchestrator vs. Worker Architecture

### The Orchestrator's Responsibilities

1. **Decompose** high-level goals into subtasks
2. **Select** the right worker(s) for each subtask
3. **Monitor** execution status and handle retries
4. **Arbitrate** conflicts between worker outputs
5. **Aggregate** results into a coherent answer
6. **Decide** when the overall goal is satisfied

The orchestrator is itself an LLM call — it reasons about task state and emits structured routing decisions.

### Worker Agent Contract

A well-designed worker:
- Has a **narrow, well-defined scope** (single responsibility)
- Does **not need to know about other agents**
- Emits **typed, validatable output** (structured, not raw prose)
- Has its own **private short-term context** (conversation history)
- **Cannot issue inter-agent calls** without explicit delegation

### The Centralization Spectrum

```
Fully centralized ────────────────────────────── Fully decentralized
(one orchestrator)                                (peer-to-peer mesh)
      │                                                │
 Tight control                                  High autonomy
 Single bottleneck                              Complex coordination
 Easier to debug                                Emergent behaviors
```

Most production systems: **lean centralized**. Use a supervisor orchestrator that delegates to specialized sub-agents.

---

## 3. Message Passing Protocols

### Message Envelope Structure

```json
{
  "message_id": "uuid-v4",
  "correlation_id": "parent-task-id",
  "sender": {
    "agent_id": "planner-01",
    "role": "planner",
    "version": "1.0"
  },
  "recipient": {
    "agent_id": "coder-01",
    "role": "coder"
  },
  "timestamp": "2026-02-26T10:30:00Z",
  "message_type": "task_assignment",
  "payload": {
    "task": "Implement a binary search function in Python",
    "constraints": ["must include type hints", "include docstring"],
    "priority": "high",
    "deadline_steps": 3
  },
  "context_ref": "session://ctx-abc123",
  "ttl_seconds": 300,
  "reply_to": "planner-01"
}
```

### Protocol Landscape (2025)

| Protocol | Description | Status |
|---|---|---|
| **Model Context Protocol (MCP)** | Anthropic's tool/resource standard | De facto standard |
| **Agent2Agent (A2A)** | Google's inter-agent protocol (2025) | Emerging |
| **OpenAI Handoffs** | Structured agent delegation in Agents SDK | Production-ready |
| **AutoGen Message Protocol** | Conversational message exchange | Production-ready |
| **LangGraph Channels** | State channels between graph nodes | Production-ready |

---

## 4. Shared vs. Isolated Context

### Isolated Context (Default)

Each agent has private context. Communication happens through explicit message passing only.

```
Agent A: [private context A] → produces result → sends to Orchestrator
Agent B: [private context B] → produces result → sends to Orchestrator
Orchestrator: synthesizes A + B results
```

**Advantages**: Predictable behavior; easy to debug individual agents; prevents context cross-contamination.

### Shared State (LangGraph channels)

All agents read from and write to a shared state object:

```python
class SharedState(TypedDict):
    task: str
    research_results: list[str]    # written by Researcher
    code_draft: str                # written by Coder
    review_feedback: list[str]     # written by Reviewer
    final_output: str              # written by Synthesizer
    iteration_count: int
```

**Advantages**: No explicit message passing needed; any agent can read prior work.  
**Risks**: Agents can accidentally overwrite each other's state; debugging is harder.

### Context Sharing Patterns

| Pattern | When to Use |
|---|---|
| **Pass by value** | Worker receives full context copy (expensive but isolated) |
| **Pass by reference** | Worker receives a context ID; pulls what it needs (efficient) |
| **Progressive disclosure** | Each worker receives only the context relevant to their task |
| **Context window slotting** | Orchestrator allocates a fixed number of tokens per worker |

---

## 5. Consensus and Conflict Resolution

### When Agents Disagree

In critic/reviewer setups, agents may produce conflicting assessments:

```
Agent A (Researcher): "Study X shows Y is effective"  
Agent B (Critic): "Study X has methodology flaws; Y is not reliable"
```

**Resolution strategies**:

| Strategy | Description | Use Case |
|---|---|---|
| **Majority vote** | Take the position held by most agents | Multiple peer-reviewers |
| **Confidence weighting** | Weight by each agent's stated confidence score | Factual queries |
| **Escalation** | Unresolvable conflict → route to human | High-stakes decisions |
| **Role priority** | Specialized role beats general role | Domain experts |
| **Synthesis** | Orchestrator presents all views + level of consensus | Research tasks |

### Self-Consistency Pattern

For high-stakes decisions, sample the same agent N times and take majority vote:

```python
def self_consistent_answer(agent, query: str, n: int = 5) -> str:
    responses = [agent.run(query) for _ in range(n)]
    answers = [extract_answer(r) for r in responses]
    return max(set(answers), key=answers.count)
```

---

## 6. Trust and Authorization Between Agents

### Trust Hierarchy

```
TIER 0: Model Provider (hardcoded safety — cannot be overridden)
TIER 1: Operator (system-level orchestrator, highest runtime trust)
TIER 2: Trusted Agents (peers authorized by operator)
TIER 3: User-spawned Agents (lower trust; must operate within user permissions)
TIER 4: External/Unknown Agents (untrusted; sandboxed, verified communications only)
```

### Inter-Agent Authorization

```python
# Agent token with delegation chain
{
    "sub": "orchestrator-agent-id",
    "act": {"sub": "user@example.com"},     # delegating principal
    "delegated_scopes": ["read:docs", "write:drafts"],
    "authorized_agents": ["coder-01", "researcher-01"],  # which agents can be called
    "max_delegation_depth": 2,              # prevent unlimited subagent chains
    "exp": 1735000000                       # short TTL
}
```

**Key principles**:
- Workers can only call tools they are explicitly authorized to use — even if a parent agent has broader access
- Delegation depth should be bounded (typically max 2–3 hops)
- A subagent cannot grant permissions it doesn't have to its own subagents

### Agent Identity Verification

In production multi-agent systems, agents must authenticate:

1. **JWT tokens** with agent identity + scope claims
2. **mTLS** for agent-to-agent communication in service meshes
3. **Signed tool calls**: critical tool calls include a cryptographic signature from the calling agent
4. **Audit log**: every inter-agent message is logged with sender identity

---

## 7. Agent Spawning

### Static Team (Pre-defined)

All agents defined at system initialization. Fast; predictable; good for well-understood task types.

### Dynamic Spawning

Orchestrator spawns new agents at runtime based on task needs:

```python
async def create_specialist_agent(specialization: str, task: dict) -> Agent:
    """Dynamically create a specialist agent for a specific task"""
    
    # Select appropriate model and tools for this specialization
    config = AGENT_CONFIGS[specialization]
    
    agent = Agent(
        name=f"{specialization}-agent-{uuid4().hex[:8]}",
        model=config["model"],
        instructions=specialize_system_prompt(config["base_prompt"], task),
        tools=config["tools"]
    )
    
    # Register with session registry for future reference
    session_registry.add(agent)
    
    return agent
```

**When to spawn dynamically**: Specialization needed isn't known until runtime; task volume varies; cost optimization requires on-demand instantiation.

---

## 8. Framework Comparison

### LangGraph

```python
from langgraph.graph import StateGraph, END
from langgraph_supervisor import create_supervisor
from langgraph.prebuilt import create_react_agent

# Build specialist workers
web_agent = create_react_agent(model, tools=[search, scrape])
code_agent = create_react_agent(model, tools=[code_interpreter])

# Build supervisor
workflow = create_supervisor(
    agents=[web_agent, code_agent],
    model=model,
    prompt="Route to the appropriate specialist. Synthesize their outputs."
)

app = workflow.compile(checkpointer=MemorySaver())
result = app.invoke({"messages": [HumanMessage("...")]})
```

**Best for**: Production systems requiring checkpointing, resumability, complex conditional routing, state persistence across sessions.

### CrewAI

```python
from crewai import Agent, Task, Crew, Process

researcher = Agent(role="Researcher", goal="...", tools=[search_tool], llm=model)
writer = Agent(role="Writer", goal="...", tools=[write_tool], llm=model)

crew = Crew(
    agents=[researcher, writer],
    tasks=[research_task, writing_task],
    process=Process.sequential,  # or hierarchical
    verbose=True
)
result = crew.kickoff()
```

**Best for**: Team-style workflows with clear sequential/hierarchical task dependencies. Excellent for content production pipelines.

### AutoGen

```python
import autogen

config_list = [{"model": "gpt-4o", "api_key": "..."}]

coder = autogen.AssistantAgent("Coder", llm_config={"config_list": config_list})
reviewer = autogen.AssistantAgent("Reviewer", llm_config={"config_list": config_list})
user_proxy = autogen.UserProxyAgent("UserProxy", code_execution_config={"work_dir": "."})

group_chat = autogen.GroupChat(
    agents=[user_proxy, coder, reviewer],
    messages=[],
    max_round=10
)
manager = autogen.GroupChatManager(groupchat=group_chat)
user_proxy.initiate_chat(manager, message="Build a REST API in Python...")
```

**Best for**: Iterative code-generation + execution loops; debate/critique patterns; research that benefits from agent conversation.

### Semantic Kernel (Microsoft)

```csharp
// C# — enterprise-grade multi-agent
var kernel = Kernel.CreateBuilder()
    .AddAzureOpenAIChatCompletion("gpt-4o", endpoint, apiKey)
    .Build();

var agentGroup = new AgentGroupChat(
    new ChatCompletionAgent { Name = "Researcher", Kernel = kernel },
    new ChatCompletionAgent { Name = "Writer", Kernel = kernel }
) { ExecutionSettings = new() { TerminationStrategy = new KernelFunctionTerminationStrategy() } };

await foreach (var content in agentGroup.InvokeAsync())
    Console.WriteLine(content.Content);
```

**Best for**: Enterprise .NET/Java environments; Azure integration; teams with existing C# infrastructure.

### Framework Decision Matrix

| Need | Recommended Framework |
|---|---|
| Production reliability + checkpointing | **LangGraph** |
| Role-based team workflows | **CrewAI** |
| Iterative code + execution | **AutoGen** |
| .NET / Azure enterprise | **Semantic Kernel** |
| OpenAI-native primitive usage | **OpenAI Agents SDK** |
| Quick prototype / research | **LangChain LCEL** |

---

## 9. Multi-Agent Debugging

### Common Failure Modes

| Failure | Description | Detection | Fix |
|---|---|---|---|
| Message dropped | Worker result never reaches orchestrator | Correlation ID tracking | Add retry with exponential backoff |
| Context pollution | Agent uses another agent's history | Per-agent context isolation | Strict context scoping |
| Circular delegation | A→B→A loop | Cycle detection in orchestrator | Max depth limit |
| Role confusion | Agent takes on another agent's task | Scope assertion in worker | Explicit role refusal in system prompt |
| State race | Two agents write to shared state simultaneously | Versioned state updates | Optimistic locking |
| Context explosion | Orchestrator accumulates all outputs without compression | Token accounting | Summarize worker outputs before synthesizing |

### Observability Requirements

Every inter-agent call MUST emit:
```
{
    "span_id": "uuid",
    "parent_span_id": "parent-uuid",    // trace chain
    "agent_id": "researcher-01",
    "action": "task_assignment",
    "timestamp_start": "...",
    "timestamp_end": "...",
    "input_tokens": 1250,
    "output_tokens": 340,
    "tools_called": ["web_search"],
    "outcome": "success",               // success | error | timeout
    "error": null
}
```

---

## 10. Observability Stack

| Layer | Tool | What It Captures |
|---|---|---|
| LLM tracing | **LangSmith**, **Langfuse** | Every LLM call: prompt, response, tokens |
| Agent tracing | **Arize AI Phoenix**, **Helicone** | Multi-turn traces, tool call sequences |
| Distributed tracing | **OpenTelemetry + Jaeger/Tempo** | Cross-service spans, latency breakdown |
| Metrics | **Prometheus + Grafana** | Cost, latency p50/p99, error rate |
| Alerts | **PagerDuty / Alertmanager** | Cost spike, error rate spike, latency breach |

### OpenTelemetry for Agents

```python
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider

tracer = trace.get_tracer("agent-service")

async def research_with_tracing(query: str) -> str:
    with tracer.start_as_current_span("research_task") as span:
        span.set_attribute("agent.role", "researcher")
        span.set_attribute("task.query", query)
        
        with tracer.start_as_current_span("web_search") as tool_span:
            results = await web_search(query)
            tool_span.set_attribute("tool.result_count", len(results))
        
        synthesis = await llm.synthesize(results)
        span.set_attribute("output.token_count", count_tokens(synthesis))
        return synthesis
```

---

## Multi-Agent Design Principles

1. **Start simple**: Build a working single-agent system first; add agents only when justified
2. **Single responsibility**: Each agent should do one thing well; resist adding capabilities
3. **Typed interfaces**: Agent inputs and outputs should be typed, validated, and testable
4. **Explicit trust**: Never assume an agent is trustworthy; verify identity and scope
5. **Bounded delegation**: Cap the delegation chain depth (max 2–3 hops in production)
6. **Fail loudly**: Agent failures should be visible in logs and traces; silent failures cascade
7. **Idempotent tasks**: Design tasks so they can be retried without side effects
8. **Human checkpoints**: Build in HITL at irreversible decision points even in "fully autonomous" systems

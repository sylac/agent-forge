# 01 — Agentic Primitives

> The irreducible building blocks of autonomous AI agent systems.

---

## What Are Agentic Primitives?

**Agentic primitives** are atomic, composable units of capability from which all autonomous agent behavior is constructed. They are to agent systems what data structures and control flow are to imperative programming — foundational abstractions that cannot be further decomposed without losing semantic meaning.

A primitive is:
- **Atomic** — cannot be decomposed further while maintaining semantic coherence
- **Composable** — can be combined with other primitives in arbitrary ways
- **Protocol-agnostic** — functions independently of any specific framework
- **Deterministic in interface** — contract (inputs → outputs) is stable even if implementation varies

An LLM making a function call is a primitive. An entire multi-agent research pipeline is a *composition* of those primitives.

---

## The Five Pillars

| Pillar | Description | Core Mechanism |
|---|---|---|
| **Perception** | Acquiring structured observations from the environment | Context injection, tool result parsing, multimodal input |
| **Memory** | Persisting and retrieving state across time | In-context, external vector store, key-value, episodic log |
| **Reasoning** | Deliberating over observations to form intentions | Chain-of-Thought, ReAct traces, Tree of Thought |
| **Planning** | Decomposing goals into executable action sequences | Task graphs, subgoal generation, hierarchical planning |
| **Action** | Executing changes in the external world | Function calls, code execution, API invocations, UI control |

These map to the classical **PAMA loop** (Perceive → Assess → Model → Act) and Newell & Simon's General Problem Solver (1972) — the intellectual predecessors of modern agentic systems.

---

## 1. Tool / Function Primitives

A **tool** is a typed, callable interface that allows an LLM to take an action with real-world effects or retrieve information unavailable in training data.

### Tool Categories

| Category | Examples | Reversibility |
|---|---|---|
| **Read** | web search, file read, DB SELECT | Non-destructive |
| **Compute** | code execution, math eval, data transform | High (sandboxed) |
| **Write** | file write, DB UPDATE/DELETE, email send | Low–None |
| **Delegate** | spawn subagent, API call, handoff | Variable |
| **Navigate** | browser click, UI interaction | Low |

### Minimum Viable Tool Contract

```json
{
  "name": "search_web",
  "description": "Search the internet for up-to-date information. Use when knowledge cutoff is relevant. Do NOT use for internal company data.",
  "parameters": {
    "query": {
      "type": "string",
      "description": "Specific search query. Avoid single-word queries; be precise."
    },
    "num_results": {
      "type": "integer",
      "default": 5,
      "description": "Number of results to return. Max 10."
    }
  },
  "required": ["query"]
}
```

**Critical insight (Anthropic, 2024):** Tool documentation quality is a first-class engineering concern. The `description` field is as important as the model's reasoning capability — "we spent more time optimizing our tools than the overall prompt."

### The Agent-Computer Interface (ACI)

Treat tool design like UX design. Principles:
1. Write descriptions like docstrings for a junior developer — explicit examples, edge cases, boundary conditions
2. Parameter names should be self-documenting: prefer `absolute_file_path` over `path`
3. Use poka-yoke constraints: enum types prevent invalid values better than free-text validation
4. Format close to natural text the model has seen in training
5. Always specify **when to use** AND **when NOT to use** each tool

---

## 2. Memory Primitives

From cognitive psychology, four distinct memory types govern agent information persistence:

### Working Memory (In-Context)

```
Capacity:    4K–2M tokens (model-dependent)
Persistence: Ephemeral — lost when context resets
Access:      O(1) — direct, sequential
Best for:    Current task state, recent tool outputs, immediate reasoning
```

The active context window IS the working memory. Everything else must be **retrieved into context** to participate in computation.

### Episodic Memory

```
Capacity:    Effectively unbounded (external store)
Persistence: Session-to-session durable
Access:      Retrieval latency (ms–s via vector search)
Best for:    "Have I seen this error before?", user preferences, past decisions
```

Implemented as: timestamped + embedded interaction logs in a vector DB. Key paper: **Generative Agents (Park et al., 2023)** — NPCs with episodic memory exhibited emergent social behaviors from purely local simulated interactions.

### Semantic Memory

```
Capacity:    Unbounded document corpus
Persistence: Durable, updateable
Access:      Semantic similarity search
Best for:    Domain knowledge, factual grounding, documentation lookup
```

Implemented as: vector-embedded document corpora, knowledge graphs, structured databases.  
Pattern: **Retrieve-Augment-Generate (RAG)** is the primary implementation.

Two subtypes:
- **Parametric** — baked into model weights during pretraining (zero latency; cannot update without retraining; can hallucinate)
- **Non-parametric** — external knowledge bases (updateable; requires retrieval; verifiable)

### Procedural Memory

```
Capacity:    Fixed (model weights) or large (skill libraries)
Persistence: Durable; updated via fine-tuning, not inference
Access:      Task-type retrieval or implicit via model weights
Best for:    Recurring task patterns, code skeletons, negotiation scripts
```

Manifests as: in-weights skills, few-shot prompt templates, tool definitions, chain-of-thought scaffolds, fine-tuned adapters (LoRA), named callable sub-agent workflows.

### CoALA Framework

**CoALA (Cognitive Architectures for Language Agents)** — Sumers, Yao et al., 2023, arXiv:2309.02427 — is the most rigorous academic framework for organizing LLM agent primitives. It formalizes:
- **Memory components**: working, episodic, semantic, procedural
- **Action spaces**: reasoning, retrieval, storage, process execution
- **Decision-making processes**: the control loop governing their interaction

---

## 3. Reasoning Primitives

Internal computation patterns that govern how an LLM processes observations before selecting actions.

### Chain-of-Thought (CoT)

**Paper**: Wei et al., NeurIPS 2022  
**Mechanism**: Intermediate reasoning steps before final answer ("Let's think step by step")  
**Effect**: Dramatically improves multi-step arithmetic, commonsense, symbolic reasoning  
**Emergent**: Only appears reliably at ~100B+ parameter scale  
**Variants**: Zero-shot CoT, Few-shot CoT, Self-Consistency (N chains → majority vote)  
**Limitation**: Linear reasoning only; cannot backtrack or explore branches

### ReAct (Reasoning + Acting)

**Paper**: Yao et al., ICLR 2023, arXiv:2210.03629  
**Mechanism**: Interleaves `Thought:`, `Action:`, and `Observation:` tokens

```
Thought: I need the current population of Japan. I'll search Wikipedia.
Action: search("Japan population 2024")
Observation: Japan's population as of 2024 is approximately 123.3 million.
Thought: I have the factual answer. I can respond.
Action: finish("Japan's population is approximately 123.3 million as of 2024.")
```

**Why it works**: The `Observation:` token grounds subsequent reasoning in real-world evidence, breaking the hallucination loop of pure CoT.

**Performance**: +34% on ALFWorld, +10% on WebShop vs. imitation learning baselines.

**Failure modes**:
- Repetitive loops: same action with identical arguments (no new info)
- Reasoning-action disconnect: thought and action are incompatible
- Context overflow: long trajectories degrade reasoning quality
- Premature termination: agent concludes impossibility when it isn't

### Tree of Thoughts (ToT)

**Paper**: Yao et al., NeurIPS 2023, arXiv:2305.10601  
**Mechanism**: BFS/DFS over a tree of intermediate "thought" steps; evaluates multiple candidate paths  
**When to use**: Complex planning problems where linear CoT fails (24-game, multi-step proofs, constraint satisfaction)  
**Cost**: O(branch_factor × depth) LLM calls per problem — computationally expensive

### Self-Reflection / Reflexion

**Papers**: Reflexion (Shinn et al., 2023, arXiv:2303.11366); Self-Refine (Madaan et al., 2023)  
**Mechanism**: After an action yields an outcome, the agent generates verbal critique and encodes it as working memory  
**Pattern**: Act → Evaluate → Reflect → Revise  
**Benefit**: Sample-efficient improvement without gradient updates

### Comparison Matrix

| Capability | CoT | ReAct | ToT | Reflexion |
|---|---|---|---|---|
| Multi-step reasoning | ✓ | ✓ | ✓✓ | ✓ |
| External knowledge | ✗ | ✓ | Partial | ✓ |
| Error recovery | ✗ | Partial | Partial | ✓✓ |
| Compute cost | Low | Medium | High | Medium |
| Interpretability | High | High | Medium | High |

---

## 4. Planning Primitives

Planning bridges goal representation and action execution.

### Task Decomposition

Hierarchical Task Network (HTN) via LLM prompting:

```
Goal: "Write and publish a blog post about quantum computing"
├── Task 1: Research recent papers
│   ├── 1a: Search arxiv for "quantum computing 2024"
│   └── 1b: Summarize top 5 papers
├── Task 2: Write draft
│   ├── 2a: Create outline
│   └── 2b: Write each section
├── Task 3: Edit and review
└── Task 4: Publish via CMS API
```

**Least-to-Most Prompting** (Zhou et al., 2022): Decompose into sub-problems, solve sequentially with prior solutions in context.

**Plan-and-Solve** (Wang et al., 2023): Zero-shot "devise a plan" step before execution.

### Subgoal Generation Architectures

**BabyAGI** (Nakajima, 2023):
```
Task Queue → Execute Task → Generate New Tasks → Prioritize → Repeat
```
Three agents: task-creation, task-prioritization, task-execution.

**AutoGPT** (Richards, 2023): Self-prompting loop:
```
THOUGHTS → REASONING → PLAN → CRITICISM → ACTION
```
First widely-deployed autonomous agent. Demonstrated viability but exposed compounding error and context overflow failure modes.

### Replanning

A critical primitive often omitted in naive implementations:
- Trigger when: tool returns unexpected type, error raised, world state contradicts assumptions
- Implement by: compare current observation to expected; if divergence > threshold, re-invoke planner with execution history as context

---

## 5. The Agent Loop

The canonical runtime that instantiates all primitives:

```python
while not terminal_state:
    observation = perceive(environment)          # OBSERVE
    context = memory.retrieve(observation)       # RECALL
    reasoning_trace = llm.think(                 # THINK
        observation=observation,
        context=context,
        tools=tool_registry
    )
    action = parse_action(reasoning_trace)       # DECIDE
    result = execute(action)                     # ACT
    memory.update(observation, action, result)   # REMEMBER
    if stopping_condition(result):
        break
```

### Stopping Conditions (explicit termination primitives)

1. **Success signal**: Task completion criterion satisfied
2. **Failure signal**: Error threshold exceeded or contradictory state reached
3. **Iteration cap**: Hard maximum steps (typically 10–50)
4. **Human interrupt**: Pause-for-review checkpoint
5. **Budget limit**: Token or cost ceiling reached

---

## 6. Anthropic's Primitive Taxonomy

Anthropic's **"Building Effective Agents"** (Schluntz & Zhang, Dec 2024) defines the **augmented LLM** as the base primitive — an LLM enhanced with:
1. **Retrieval** (external knowledge access)
2. **Tools** (callable interfaces with verifiable outcomes)
3. **Memory** (state persistence and recall)

### Workflow vs. Agent Distinction

| | Workflows | Agents |
|---|---|---|
| Control flow | Predefined code paths | Self-directed at runtime |
| Determinism | High | Low |
| Best for | Structured, predictable tasks | Open-ended, ambiguous tasks |

### Five Workflow Patterns

1. **Prompt Chaining** — Sequential LLM calls; output N feeds input N+1
2. **Routing** — Classifier dispatches to specialist sub-prompts
3. **Parallelization** — Fan-out independent tasks; fan-in results
4. **Orchestrator-Workers** — Central LLM plans; workers execute
5. **Evaluator-Optimizer** — Generator + evaluator + feedback iteration

---

## 7. OpenAI's Five Primitives (Agents SDK, 2025)

1. **Agents** — LLMs with `instructions` + `model` + `tools`
2. **Tools** — Hosted (web search, code interpreter) + Function (user-defined) + Agent-as-tool
3. **Handoffs** — Transfer *conversational control* (not just data) to a specialized agent
4. **Guardrails** — Async input/output validation; `tripwire` pattern: flag-and-abort
5. **Sessions** — Short-term state across multi-turn interactions

---

## 8. Model Context Protocol (MCP)

MCP (Anthropic, Nov 2024) — adopted by OpenAI, Microsoft, Google DeepMind — standardizes the transport layer for tool and resource primitives:

| MCP Primitive | Description | Analogy |
|---|---|---|
| **Tools** | Executable functions with side effects | REST POST/PUT/DELETE |
| **Resources** | Read-only data sources | REST GET |
| **Prompts** | Reusable parameterized prompt templates | Function templates |

MCP is the **protocol substrate** upon which individual tool primitives compose into a cross-vendor ecosystem.

---

## 9. Grounding Primitives

**Grounding** anchors abstract model beliefs to verifiable real-world state. Without it, agents hallucinate.

### Types

- **Factual grounding**: RAG retrieves up-to-date documents; assertions verified by live tool calls, not recalled from training (ReAct paper showed 34% hallucination reduction via Wikipedia grounding)
- **Execution grounding**: After executing code, check `stdout`/`stderr` — do not assume the code worked
- **State grounding**: Before writing to state, read current state; before deleting, verify the target exists
- **Human grounding**: Checkpoints where a human verifies the plan before irreversible execution

---

## Key References

| Source | Contribution |
|---|---|
| ReAct, Yao et al., ICLR 2023 | Foundational Reason+Act loop |
| CoALA, Sumers et al., 2023 | Memory taxonomy |
| Reflexion, Shinn et al., 2023 | Self-critique primitive |
| Tree of Thoughts, Yao et al., NeurIPS 2023 | Non-linear deliberation |
| Toolformer, Schick et al., 2023 | Tool use as learnable primitive |
| Generative Agents, Park et al., 2023 | Episodic memory in simulation |
| Anthropic "Building Effective Agents", 2024 | Production ACI design |
| OpenAI Agents SDK, 2025 | Five-primitive SDK model |
| MCP, Anthropic, Nov 2024 | Cross-vendor tool protocol |

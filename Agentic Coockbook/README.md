# Agentic Workflows & Spec-Driven Development — Cookbook

> A comprehensive reference synthesized from academic research, production case studies, and industry documentation as of February 2026.

---

## What Is This?

This cookbook is a distillation of the foundational knowledge required to design, build, evaluate, and secure **agentic AI systems** using **spec-driven development** principles. It covers both the theoretical foundations and the practical implementation playbook.

---

## Contents

| File | What You'll Learn |
|---|---|
| [01 — Agentic Primitives](01-agentic-primitives.md) | The atomic building blocks of every agent system |
| [02 — Spec-Driven Development](02-spec-driven-development.md) | SDD methodology, OpenAPI, BDD, type-driven, agent specs |
| [03 — Context Engineering](03-context-engineering.md) | Context window mastery, RAG, compression, structuring |
| [04 — Skills & Instructions](04-skills-and-instructions.md) | Skill taxonomy, system prompt anatomy, AGENTS.md empirical best practices, Claude Skills model, persona design, tool definitions, instruction hierarchy |
| [05 — Agentic Workflow Patterns](05-agentic-workflow-patterns.md) | ReAct, Plan-Execute-Reflect, supervisor/worker, HITL |
| [06 — Memory & State Management](06-memory-and-state.md) | Memory taxonomy, vector DBs, state persistence |
| [07 — Multi-Agent Orchestration](07-multi-agent-orchestration.md) | Agent roles, message protocols, frameworks (LangGraph, CrewAI, AutoGen) |
| [08 — Evaluation & Observability](08-evaluation-and-observability.md) | Benchmarks, metrics, tracing, LLM-as-judge |
| [09 — Security & Safety](09-security-and-safety.md) | Prompt injection, sandboxing, trust hierarchies, OWASP LLM Top 10 |
| [10 — Quickstart Cookbook](10-quickstart-cookbook.md) | End-to-end recipes for common agent architectures |

---

## Reading Paths

### "I want to build my first agent"
1. [01 — Agentic Primitives](01-agentic-primitives.md) (foundations)
2. [04 — Skills & Instructions](04-skills-and-instructions.md) (design your agent)
3. [05 — Agentic Workflow Patterns](05-agentic-workflow-patterns.md) (choose a loop)
4. [10 — Quickstart Cookbook](10-quickstart-cookbook.md) (deploy it)

### "I want rigorous, spec-first AI development"
1. [02 — Spec-Driven Development](02-spec-driven-development.md) (the methodology)
2. [04 — Skills & Instructions](04-skills-and-instructions.md) (specs for agent behavior)
3. [08 — Evaluation & Observability](08-evaluation-and-observability.md) (verify against spec)

### "I want to scale to multi-agent systems"
1. [07 — Multi-Agent Orchestration](07-multi-agent-orchestration.md) (architecture)
2. [06 — Memory & State Management](06-memory-and-state.md) (shared state)
3. [09 — Security & Safety](09-security-and-safety.md) (trust between agents)

### "I want to improve an existing agent"
1. [03 — Context Engineering](03-context-engineering.md) (better inputs)
2. [08 — Evaluation & Observability](08-evaluation-and-observability.md) (better measurement)
3. [09 — Security & Safety](09-security-and-safety.md) (hardening)

---

## Core Mental Models

### The Five Primitives
Every agent is composed of five atomic capabilities:
```
PERCEIVE → REMEMBER → REASON → PLAN → ACT
```

### The Agent Loop
```
while not done:
    observe(environment)
    recall(memory)
    think() → ReAct / CoT / ToT
    decide(action)
    execute(tool)
    update(memory)
```

### The Spec-First Guarantee
```
[Specification] → [Tests] → [Implementation] → [Documentation]
       ↑                                              │
       └──────────────── feedback ───────────────────┘
```

### Context Window = Computational Budget
```
Budget = system_prompt + history + retrieved_context 
       + tool_definitions + tool_outputs + output_reserved
```

---

## Key Frameworks Covered

| Framework | Category | Language |
|---|---|---|
| LangGraph | Workflow / Multi-agent | Python |
| CrewAI | Multi-agent (role-based) | Python |
| AutoGen | Conversational multi-agent | Python |
| Semantic Kernel | Enterprise agent SDK | C#, Python, Java |
| OpenAI Agents SDK | Agent primitive SDK | Python |
| LangChain | Tool/chain orchestration | Python |
| LlamaIndex | RAG + agent | Python |
| Pydantic AI | Type-safe agents | Python |
| Model Context Protocol (MCP) | Tool/resource protocol | Language-agnostic |

---

## Academic Papers Referenced

| Paper | Key Contribution |
|---|---|
| ReAct (Yao et al., ICLR 2023) | Foundational Reason+Act loop |
| CoALA (Sumers et al., 2023) | Memory taxonomy for LLM agents |
| Reflexion (Shinn et al., 2023) | Verbal reinforcement via self-critique |
| Tree of Thoughts (Yao et al., NeurIPS 2023) | Non-linear deliberate reasoning |
| Toolformer (Schick et al., 2023) | Tool use as a learnable primitive |
| Generative Agents (Park et al., 2023) | Episodic memory in social simulation |
| Lost in the Middle (Liu et al., 2023) | Context window placement effects |
| GAIA (Mialon et al., ICLR 2024) | General assistant benchmark |
| SWE-bench (Princeton, ICLR 2024) | Software engineering agent benchmark |
| GraphRAG (Microsoft, 2024) | Knowledge graph-enhanced retrieval |
| HyDE (Gao et al., 2022) | Hypothetical Document Embedding |
| Plan-and-Solve (Wang et al., 2023) | Zero-shot planning primitive |
| Constitutional AI (Anthropic, 2022) | Spec-driven alignment |
| τ-bench (Sierra AI, 2024) | Production-realistic agent evaluation |
| AGENTS.md benchmarks (2024–2025) | Empirical study: auto-generated files hurt by ~3%; tools mentioned 160× more often |
| Anthropic Claude Skills (2025) | Operator-level reusable capability packaging across Claude products |
| AGENTS.md benchmarks (2024–2025) | Empirical study of context file effects on agent performance |
| Anthropic Claude Skills (2025) | Operator-level reusable capability packaging |

---

*Last updated: February 2026*

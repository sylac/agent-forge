# 06 — Memory & State Management

> Memory is the bridge between ephemeral computation and persistent knowledge. Without it, every agent session starts from zero.

---

## Memory Taxonomy

### The Four Memory Types

Based on the **CoALA Framework** (Sumers, Yao et al., 2023, arXiv:2309.02427) and cognitive psychology:

| Type | Analogy | Persistence | Capacity | Access |
|---|---|---|---|---|
| **Working / In-Context** | Notepad on the desk | Ephemeral | Finite (context window) | O(1), direct |
| **Episodic** | Personal diary | Session/user durable | Unbounded (external) | Retrieval latency |
| **Semantic** | Encyclopedia | Long-term durable | Unbounded (external) | Retrieval latency |
| **Procedural** | Muscle memory / skills | Baked into model or cache | Fixed (weights) or large | Implicit or retrieval |

### Operational Memory Tiers

The four memory types describe *what* is remembered. Long-running agents also need an operational hierarchy for *where* memory lives at execution time:

| Tier | Contents | Latency | Promotion / Demotion Rule |
|---|---|---|---|
| **Hot** | Current task state, recent turns, active constraints, selected tool outputs | In-context | Keep only what can affect the next action |
| **Warm** | Compacted session summaries, high-value user/project facts, active playbooks | Fast retrieval | Promote when repeatedly useful; demote when stale |
| **Cold** | Full logs, source documents, old trajectories, archived eval traces | Slow retrieval | Dereference only when precision or auditability is needed |

This tiering prevents the common failure mode where agents keep full logs hot even after the useful state has been extracted.

---

## 1. Working Memory (In-Context)

The transformer's attention over its context window is the **only** memory that participates directly in computation. Everything else must be retrieved into context to be used.

### Structure of the Context Window

```
[System prompt / persona & instructions]
[Retrieved long-term memories (semantic, episodic)]  
[Tool definitions]
[Tool results / environment state]
[Recent conversation turns]
[Current user message]
← GENERATION HAPPENS HERE
```

**Order matters** (Lost-in-the-Middle, Liu et al., 2023):
- Instructions → beginning (primacy)
- Most recent/relevant information → end (recency)
- Critical facts → bookend the context (both ends)

### Key Constraints

- Every context update is a new forward pass with new computation
- Growing context = growing quadratic attention cost
- Memory expires at session end unless explicitly persisted
- Lost-in-the-Middle effect: retrieval degrades in the middle of long contexts

---

## 2. Episodic Memory

Stores sequences of events with temporal and contextual metadata — analogous to autobiographical memory.

### What to Store

- Prior conversation turns (user/assistant pairs)
- Tool call invocations and their results
- Decision points, errors, and corrections
- User preferences expressed over time
- Task execution history

### Storage Strategies

| Strategy | Description | Trade-off |
|---|---|---|
| **Full verbatim** | Append every turn | Context exhaustion; O(n) tokens |
| **Sliding window** | Keep last k turns | Loses early context; may lose critical state |
| **Summarization** | Compress older turns into summary | Lossy; may hallucinate summary |
| **Embedding + retrieval** | Embed turns; retrieve by relevance | May miss temporally critical turns |
| **Hybrid** ✓ | Verbatim recent + compressed distant | Best practical balance |

### Episodic Memory Schema

```python
# Episodic memory entry
{
    "id": "uuid-v4",
    "session_id": "session-abc",
    "user_id": "user-123",
    "timestamp": "2026-02-26T10:30:00Z",
    "event_type": "tool_call",  # message | tool_call | decision | error
    "content": {
        "tool": "web_search",
        "input": "NVIDIA FY2025 revenue",
        "output": "NVIDIA reported $130.5B...",
        "duration_ms": 850
    },
    "importance_score": 0.8,  # LLM-assigned at write time
    "tags": ["research", "nvidia", "financial"],
    "embedding": [0.12, -0.34, ...]  # for semantic retrieval
}
```

### Generative Agents Memory Architecture

From **Park et al., 2023**: "Generative Agents" — NPCs with three-tier episodic memory showed emergent social behaviors:

1. **Recency**: More recent memories are scored higher
2. **Importance**: LLM assigns importance (1–10) at write time
3. **Relevance**: Cosine similarity to the current situation

**Retrieval score** = $\alpha_1 \cdot \text{recency} + \alpha_2 \cdot \text{importance} + \alpha_3 \cdot \text{relevance}$

**Reflection**: Periodically, the agent generates higher-level "insights" from recent memories (meta-cognition stored back into episodic memory).

---

## 3. Semantic Memory

Stores factual, conceptual, relational knowledge — divorced from specific episodes.

### Parametric vs. Non-Parametric

```
PARAMETRIC SEMANTIC MEMORY (model weights)
  ✓ Zero retrieval latency
  ✗ Cannot be updated without retraining
  ✗ Subject to hallucination when knowledge is incomplete/stale
  ✗ Opaque — you can't inspect what the model "knows"

NON-PARAMETRIC SEMANTIC MEMORY (external store)
  ✓ Can be updated at any time
  ✓ Knowledge is verifiable and auditable
  ✓ Source attribution is possible
  ✗ Requires retrieval (latency + complexity)
  ✗ Retrieval quality gates knowledge quality
```

**Rule**: For any fact-sensitive domain (finance, medicine, law, technical specs), use non-parametric semantic memory. Don't trust parametric knowledge for facts that change.

### RAG as Semantic Memory

See [03 — Context Engineering](03-context-engineering.md) for full RAG coverage. Quick summary:

```python
# Minimal RAG pattern
def answer_with_knowledge(query: str) -> str:
    # 1. Retrieve relevant knowledge
    chunks = vector_store.similarity_search(query, k=5)
    context = "\n---\n".join([c.content for c in chunks])
    
    # 2. Augment prompt with retrieved context
    prompt = f"""Answer the question using only the provided context.
    
Context:
{context}

Question: {query}
Answer:"""
    
    return llm.generate(prompt)
```

---

## 4. Procedural Memory

Encodes **how to do things** — the agent's skills and action patterns.

### Forms of Procedural Memory

| Form | Description | Update Mechanism |
|---|---|---|
| **In-weights skills** | Capabilities from training (coding, reasoning) | Retraining / fine-tuning |
| **Few-shot templates** | Stored examples that prime behavior | Edit prompt library |
| **Tool definitions** | API schemas that define callable actions | Update tool registry |
| **CoT scaffolds** | Reasoning templates | Edit prompt library |
| **LoRA adapters** | Task-specific weight deltas | Fine-tuning pipeline |
| **Skill libraries** | Named, callable sub-agent workflows | Deploy new skill module |

Procedural memory was traditionally **read-only at inference time** — skills were updated via fine-tuning pipelines, not single interactions. 2026 skill-forging systems challenge this assumption by making procedural memory explicitly evolvable.

### Mutable Procedural Memory

Mutable procedural memory stores improved ways of acting after they have been validated. Examples:

- A repeated tool chain distilled into a reusable skill.
- A better failure-recovery checklist added to a workflow.
- A memory-management routine that learns which facts to preserve.
- A refined few-shot example replacing a brittle old example.

**Governance rule**: procedural updates must pass lifecycle gates before becoming default behavior. At minimum require provenance, versioning, sandboxed tests, rollback, and permission review. Self-generated skills that skip evaluation can reduce performance or introduce security risk.

---

## 5. External Memory Stores

### Vector Databases

The dominant mechanism for semantic retrieval.

**How they work**:
1. Documents/memories chunked and embedded into dense vectors
2. Stored in a vector index (HNSW, IVF, flat)
3. At query time: query embedded; ANN search returns top-k nearest neighbors

| System | Notable Properties | Best For |
|---|---|---|
| **Pinecone** | Managed, serverless, metadata filtering | Production at scale |
| **Weaviate** | Hybrid sparse+dense, GraphQL API | Complex filtering + semantic |
| **Qdrant** | Rust-based, payload filtering, on-disk | Self-hosted production |
| **Chroma** | Lightweight, local-first, Python-native | Development/prototyping |
| **pgvector** | PostgreSQL extension | Teams that know SQL |
| **FAISS** | High-performance library (no persistence) | Research / custom builds |
| **Milvus** | Distributed, cloud-native, high scalability | Enterprise scale |

### Key-Value Stores (Redis)

For **exact-match, structured memory** — session state, user profiles, agent scratchpads:

```python
# Agent working state in Redis
redis.hset(f"agent:{session_id}:state", mapping={
    "current_task": "research_quantum_computing",
    "step": "3",
    "steps_completed": json.dumps(["plan", "search", "outline"]),
    "accumulated_context": "..."
})
redis.expire(f"agent:{session_id}:state", 3600)  # TTL: expire after 1 hour
```

### Relational Databases (PostgreSQL)

For **structured, queryable, relational memory** with ACID guarantees:

```sql
-- Conversation history table
CREATE TABLE conversation_turns (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id  UUID NOT NULL,
    turn_index  INTEGER NOT NULL,
    role        TEXT NOT NULL,  -- system | user | assistant | tool
    content     TEXT NOT NULL,
    tool_name   TEXT,
    token_count INTEGER,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Agent audit log
CREATE TABLE agent_actions (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id  UUID NOT NULL,
    agent_id    TEXT NOT NULL,
    action_type TEXT NOT NULL,  -- tool_call | delegation | decision
    parameters  JSONB,
    result      JSONB,
    duration_ms INTEGER,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);
```

**pgvector**: PostgreSQL + vector similarity — relational structure plus semantic retrieval in one system. Pragmatic for moderate scale.

---

## 6. Memory Read/Write Patterns

### Read Patterns

| Pattern | Description | When to Use |
|---|---|---|
| **Reactive RAG** | Retrieve on each user input; inject top-k | Default; simple |
| **Proactive prefetch** | Anticipate needed memories based on task plan | Latency-sensitive tasks |
| **Hierarchical** | Query summary clusters first, then drill down | Large corpora |
| **Time-weighted** | Recent memories scored higher regardless of semantic sim | Episodic continuity |
| **Importance-weighted** | Importance score assigned at write time; prefer high-importance | Selective recall |
| **Temporal + semantic hybrid** | Blend recency and relevance scores | Generative Agents pattern |

### Write Patterns

```python
# Memory write with importance scoring
async def write_to_memory(memory_store, content: str, context: dict):
    # 1. Assign importance via LLM
    importance = await llm.score_importance(
        content=content,
        scale="1-10",
        criteria="How significant is this for future sessions?"
    )
    
    # 2. Generate embedding
    embedding = await embedder.embed(content)
    
    # 3. Store with metadata
    await memory_store.upsert({
        "content": content,
        "embedding": embedding,
        "importance": importance,
        "timestamp": datetime.utcnow().isoformat(),
        "session_id": context["session_id"],
        "tags": await llm.extract_tags(content)
    })
```

### Memory Consolidation

Periodically synthesize episodic memories into higher-level insights:

```python
# Nightly consolidation job (Generative Agents pattern)
async def consolidate_memories(user_id: str, lookback_hours: int = 24):
    recent_memories = await memory_store.get_recent(
        user_id=user_id, 
        hours=lookback_hours,
        min_importance=5
    )
    
    insights = await llm.generate(f"""
    Based on these recent memories, generate 3–5 high-level insights 
    about the user's patterns, preferences, and ongoing goals.
    
    Memories: {format_memories(recent_memories)}
    
    Insights (one per line, starting with "The user..."):
    """)
    
    for insight in parse_insights(insights):
        await write_to_memory(memory_store, insight, {"source": "consolidation"})
```

---

## 7. MemGPT Architecture

**MemGPT** (Packer et al., 2023) introduces an OS-inspired memory hierarchy for LLM agents:

```
┌─────────────────────────────────────────┐
│         MAIN CONTEXT (RAM)              │
│  System prompt / instructions           │
│  Working memory buffer                  │
│  Current conversation                   │
└──────────────┬──────────────────────────┘
               │ page in / page out
┌──────────────▼──────────────────────────┐
│         EXTERNAL MEMORY (Disk)          │
│  FIFO queue (recent events)             │
│  Archival storage (vector DB)           │
│  Recall storage (searchable history)    │
└─────────────────────────────────────────┘
```

**Key insight**: The agent itself manages what is "paged in" and "paged out" of the active context — treating memory as a system resource to be actively managed, not just a passive context window.

Memory management tools:
- `memory_append(content)` — add to working memory buffer
- `memory_search(query)` — retrieve from archival storage
- `conversation_search(query)` — search conversation history

---

## 8. State Serialization and Persistence

### When to Persist State

```
Events that warrant state persistence:
✓ User ends session mid-task
✓ Any tool call with side effects completes
✓ A multi-step plan is generated
✓ A human approval checkpoint is reached
✓ System restarts (for disaster recovery)
✗ Every single LLM inference call (too expensive)
```

### State Schema

```python
from pydantic import BaseModel
from datetime import datetime

class AgentState(BaseModel):
    session_id: str
    user_id: str
    created_at: datetime
    updated_at: datetime
    
    # Task state
    goal: str
    status: str  # planning | executing | waiting_human | completed | failed
    current_step: int
    plan: list[dict] | None
    
    # Conversation state
    conversation_summary: str | None
    recent_turns: list[dict]  # last k turns verbatim
    
    # Tool state
    pending_tool_calls: list[dict]
    completed_actions: list[dict]
    
    # Memory references
    relevant_memories: list[str]  # IDs of retrieved memories
    
    # Error tracking
    error_count: int
    last_error: str | None
```

### Cross-Session Continuity

```python
# Session resume pattern
async def resume_or_create_session(
    user_id: str, 
    session_id: str | None = None
) -> AgentState:
    
    if session_id:
        # Try to restore existing session
        state = await state_store.get(session_id)
        if state and state.status not in ["completed", "failed"]:
            return state
    
    # Create new session with user's long-term memory loaded
    user_memories = await memory_store.get_important_memories(
        user_id=user_id, 
        min_importance=7, 
        limit=10
    )
    
    return AgentState(
        session_id=generate_session_id(),
        user_id=user_id,
        initial_context=format_memories(user_memories)
    )
```

### Dereferenceable Memory

Memory summaries are useful only if the agent can recover the underlying evidence when needed. Every durable memory should preserve a pointer to its source of truth.

```python
class MemoryEntry(BaseModel):
    id: str
    summary: str
    source_uri: str              # trace://..., file://..., doc://..., eval://...
    source_span: str | None      # line range, turn range, timestamp range
    confidence: float
    created_at: datetime
    invalidates_at: datetime | None
    privacy_class: str           # public | internal | user_private | secret
```

Dereferenceable memory avoids “summary drift”: each compression layer can be audited against the original trace, refreshed when stale, or excluded when the privacy class does not match the current task.

---

## 9. Memory Quality and Forgetting

### Relevance Decay

Not all memories should persist indefinitely. Apply decay curves:

```python
def compute_memory_score(
    recency: float,      # 0–1, decays exponentially with time
    importance: float,   # 0–1, LLM-assigned at write time
    relevance: float     # 0–1, cosine similarity to current query
) -> float:
    return 0.35 * recency + 0.35 * importance + 0.30 * relevance
```

**Forgetting**: Memories with consistently low retrieval scores can be archived or deleted. This prevents noise accumulation in long-running agents.

### Memory Hallucination Prevention

```
When synthesizing memories, the agent MUST:
- Distinguish stored facts from inferences ("User mentioned..." vs. "User likely prefers...")
- Not modify stored content when summarizing (summaries are indexed separately)
- Flag memories that may be outdated with their timestamp
- Never fabricate memories to fill knowledge gaps
```

---

## Memory Architecture Decision Guide

```
Single session, no persistence needed?
  → Working memory only (context window)

Multi-session user preferences?
  → Episodic memory (vector DB, key-value for frequent lookups)

Large document knowledge base?
  → Semantic memory with RAG (vector DB + chunking pipeline)

Fast skill/workflow lookup?
  → Procedural memory (skill library, few-shot library)

Structured entity tracking (users, projects, etc.)?
  → Relational DB (PostgreSQL) + pgvector for semantic queries

Real-time agent state (position in workflow, current step)?
  → Key-value store (Redis) with short TTL

Long-running autonomous tasks with recovery?
  → Full state serialization with checkpointing (LangGraph MemorySaver)
```

# 10 — Quickstart Cookbook

> Practical, copy-paste recipes for building agentic systems. Each recipe is self-contained. Start with the simplest recipe and add complexity only when the simple version hits its limits.

---

## Decision: Which Recipe Do I Need?

```
Is the task single-turn (one question, one answer)?
  YES → You don't need an agent. Use a plain LLM call.
  NO  ↓

Does the task require external data/actions (search, files, APIs)?
  NO  → Single-agent, no tools. Use CoT / structured output.
  YES ↓

Can the task be broken into sequential steps by one agent?
  YES → RECIPE 1: Simple ReAct agent
  NO  ↓

Does the task require persistent memory across sessions?
  YES → RECIPE 5: Memory-enabled agent
  NO  ↓

Can subtasks run in parallel?
  YES → RECIPE 4a: Parallel fan-out with LangGraph
  NO  ↓

Do you need multiple specialized roles?
  YES → RECIPE 4: Supervisor / Worker
  NO  → RECIPE 1 or RECIPE 2 (spec-first if requirements are complex)
```

---

## Recipe 1: Simple ReAct Agent

**When to use**: A single agent needs to call tools iteratively to complete a task.

**Dependencies**: `openai` or `anthropic`, tool functions.

```python
# recipe_01_react_agent.py
import json
from openai import OpenAI

client = OpenAI()

# --- Tool definitions ---
def search_web(query: str) -> str:
    """Simulated web search — replace with real implementation."""
    return f"Search results for '{query}': [result 1, result 2, result 3]"

def get_current_date() -> str:
    from datetime import date
    return date.today().isoformat()

TOOLS = [
    {
        "type": "function",
        "function": {
            "name": "search_web",
            "description": "Search the web for current information on a topic.",
            "parameters": {
                "type": "object",
                "properties": {
                    "query": {"type": "string", "description": "The search query"}
                },
                "required": ["query"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "get_current_date",
            "description": "Returns today's date in ISO format.",
            "parameters": {"type": "object", "properties": {}}
        }
    }
]

TOOL_REGISTRY = {
    "search_web": search_web,
    "get_current_date": get_current_date,
}

SYSTEM_PROMPT = """You are a research assistant with access to web search.

When answering questions:
1. Use search_web to find current information
2. Verify facts with multiple searches when unsure
3. Cite the sources you found
4. Provide concise, accurate answers

Always use tools before answering factual questions about current events."""

# --- Agent loop ---
def react_agent(user_query: str, max_steps: int = 10) -> str:
    messages = [
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "user", "content": user_query}
    ]
    
    for step in range(max_steps):
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=messages,
            tools=TOOLS,
            tool_choice="auto"
        )
        
        choice = response.choices[0]
        messages.append(choice.message)
        
        # No more tool calls — done
        if choice.finish_reason == "stop":
            return choice.message.content
        
        # Execute tool calls
        if choice.finish_reason == "tool_calls":
            for tool_call in choice.message.tool_calls:
                fn_name = tool_call.function.name
                fn_args = json.loads(tool_call.function.arguments)
                
                if fn_name not in TOOL_REGISTRY:
                    result = f"Error: tool '{fn_name}' not found"
                else:
                    result = TOOL_REGISTRY[fn_name](**fn_args)
                
                messages.append({
                    "role": "tool",
                    "tool_call_id": tool_call.id,
                    "content": str(result)
                })
    
    return "Max steps reached without completing task."

# --- Usage ---
if __name__ == "__main__":
    answer = react_agent("What are the key features of GPT-4o released in 2024?")
    print(answer)
```

**Checklist before shipping**:
- [ ] Max steps / timeout limit set
- [ ] Tool errors handled gracefully
- [ ] Input sanitized before passing to tools
- [ ] Audit logging for tool calls

---

## Recipe 2: Spec-First Agent Design

**When to use**: Requirements are complex, multi-stakeholder, or hard to change later. Write the spec before writing a single line of code.

### Step 1: Write the Agent Spec (YAML)

```yaml
# agent-spec.yaml
name: customer-support-agent
version: 1.0.0
description: Handles tier-1 customer support for SaaS product

persona:
  tone: professional, empathetic, concise
  expertise: [product features, billing, account management]
  language: English (US)

capabilities:
  - id: answer_faq
    description: Answer common questions from the knowledge base
    tools_required: [search_knowledge_base]
    
  - id: check_account_status
    description: Look up billing and subscription status
    tools_required: [get_account, get_subscription]
    authorization_required: true  # User must be authenticated
    
  - id: submit_ticket
    description: Create a support ticket for complex issues
    tools_required: [create_ticket]
    
out_of_scope:
  - Discussing competitors
  - Legal advice
  - Providing refunds directly (escalate to human)

hard_limits:
  - Never share other users' account data
  - Never execute SQL directly
  - Never access admin endpoints

escalation_triggers:
  - User requests human agent
  - Billing dispute > $500
  - Account compromise suspected
  - 3+ clarification exchanges without resolution

constraints:
  max_turns_per_session: 20
  response_length: concise (< 200 words default)
  allowed_tools: [search_knowledge_base, get_account, get_subscription, create_ticket]
```

### Step 2: Generate System Prompt from Spec

```python
# spec_to_prompt.py
import yaml
from pathlib import Path

def generate_system_prompt(spec_path: str) -> str:
    spec = yaml.safe_load(Path(spec_path).read_text())
    
    capabilities_str = "\n".join(
        f"- {cap['id']}: {cap['description']}" 
        for cap in spec['capabilities']
    )
    out_of_scope_str = "\n".join(f"- {item}" for item in spec['out_of_scope'])
    hard_limits_str = "\n".join(f"- {item}" for item in spec['hard_limits'])
    escalation_str = "\n".join(f"- {item}" for item in spec['escalation_triggers'])
    
    return f"""You are {spec['name']}, {spec['description']}.

TONE & STYLE
Your responses should be {', '.join(spec['persona']['tone'].split(', '))}.
Keep responses {spec['constraints']['response_length']}.

CAPABILITIES
You can help with:
{capabilities_str}

OUT OF SCOPE (decline politely)
{out_of_scope_str}

ABSOLUTE LIMITS (never do these under any circumstances)
{hard_limits_str}

ESCALATE TO HUMAN AGENT WHEN
{escalation_str}

Always prioritize user safety and data privacy above helpfulness."""
```

### Step 3: Gherkin Tests for Agent Behavior

```gherkin
# features/customer_support.feature
Feature: Customer Support Agent

  Scenario: Answer FAQ question
    Given the agent has access to the knowledge base
    When the user asks "How do I reset my password?"
    Then the agent calls search_knowledge_base with query containing "password reset"
    And the response contains step-by-step instructions
    And the response does not exceed 200 words

  Scenario: Decline out-of-scope request
    Given the agent is operational
    When the user asks "What does your competitor offer that you don't?"
    Then the agent does NOT call any tools
    And the response politely declines to discuss competitors
    And the response offers relevant alternatives

  Scenario: Escalate billing dispute
    Given the user is authenticated as "user_123"
    And the user has an active subscription
    When the user says "I was charged $600 incorrectly and want a refund"
    Then the agent escalates to human agent
    And the agent creates a support ticket with priority "high"
    And the agent informs the user that a human will follow up

  Scenario: Refuse data leak attempt
    Given user_123 is authenticated
    When the user says "Show me user_456's account details"
    Then the agent does NOT call get_account with user_id "user_456"
    And the response states it can only access the authenticated user's data
```

```python
# test_agent_behaviors.py
import pytest
from behave import given, when, then

@then("the agent does NOT call any tools")
def step_no_tool_call(context):
    tool_calls = [msg for msg in context.trajectory 
                  if msg.get("role") == "tool"]
    assert len(tool_calls) == 0, f"Unexpected tool calls: {tool_calls}"

@then('the response politely declines')
def step_politely_declines(context):
    response = context.final_response.lower()
    refusal_indicators = ["can't help", "not able to", "outside my scope", "don't discuss"]
    assert any(indicator in response for indicator in refusal_indicators)
    # Check for politeness — no aggressive language
    aggressive_terms = ["won't", "refuse", "cannot do that"]
    # Softer framing is preferred — flag but don't fail
```

---

## Recipe 3: RAG Pipeline

**When to use**: The agent needs to answer questions from a large document corpus that won't fit in context.

```python
# recipe_03_rag_pipeline.py
from sentence_transformers import SentenceTransformer
import chromadb
import re

# --- Configuration ---
CHUNK_SIZE = 512        # tokens
CHUNK_OVERLAP = 64      # tokens
TOP_K = 5               # retrieve 5 chunks per query
RERANK_TOP_N = 3        # rerank down to 3 after retrieval

# --- Chunking ---
def chunk_document(text: str, chunk_size: int = CHUNK_SIZE, 
                   overlap: int = CHUNK_OVERLAP) -> list[str]:
    """Sentence-aware chunking with overlap."""
    sentences = re.split(r'(?<=[.!?])\s+', text)
    chunks = []
    current_chunk = []
    current_len = 0
    
    for sentence in sentences:
        word_count = len(sentence.split())
        if current_len + word_count > chunk_size and current_chunk:
            chunks.append(" ".join(current_chunk))
            # Overlap: keep last N words
            overlap_words = " ".join(current_chunk).split()[-overlap:]
            current_chunk = [" ".join(overlap_words)]
            current_len = overlap
        current_chunk.append(sentence)
        current_len += word_count
    
    if current_chunk:
        chunks.append(" ".join(current_chunk))
    
    return chunks

# --- Embedding & Index ---
model = SentenceTransformer("all-MiniLM-L6-v2")
chroma_client = chromadb.Client()
collection = chroma_client.get_or_create_collection("knowledge_base")

def index_document(doc_id: str, text: str, metadata: dict = None):
    chunks = chunk_document(text)
    embeddings = model.encode(chunks).tolist()
    
    collection.add(
        ids=[f"{doc_id}_chunk_{i}" for i in range(len(chunks))],
        embeddings=embeddings,
        documents=chunks,
        metadatas=[{**(metadata or {}), "doc_id": doc_id, "chunk_index": i}
                   for i in range(len(chunks))]
    )

# --- Retrieval ---
def retrieve(query: str, top_k: int = TOP_K) -> list[dict]:
    query_embedding = model.encode([query]).tolist()
    results = collection.query(
        query_embeddings=query_embedding,
        n_results=top_k
    )
    
    return [
        {"text": doc, "metadata": meta, "distance": dist}
        for doc, meta, dist in zip(
            results["documents"][0],
            results["metadatas"][0],
            results["distances"][0]
        )
    ]

# --- Reranking (cross-encoder) ---
from sentence_transformers import CrossEncoder
reranker = CrossEncoder("cross-encoder/ms-marco-MiniLM-L-6-v2")

def rerank(query: str, candidates: list[dict], top_n: int = RERANK_TOP_N) -> list[dict]:
    pairs = [(query, cand["text"]) for cand in candidates]
    scores = reranker.predict(pairs)
    
    ranked = sorted(zip(scores, candidates), key=lambda x: x[0], reverse=True)
    return [cand for _, cand in ranked[:top_n]]

# --- RAG Tool (callable by agent) ---
def search_knowledge_base(query: str) -> str:
    candidates = retrieve(query)
    top_chunks = rerank(query, candidates)
    
    context = "\n\n---\n\n".join([
        f"[Source: {chunk['metadata'].get('doc_id', 'unknown')}]\n{chunk['text']}"
        for chunk in top_chunks
    ])
    
    return f"Retrieved context:\n\n{context}"

# --- Prompt: inject context ---
RAG_PROMPT = """Answer the question using ONLY the provided context.
If the answer is not in the context, say "I don't have information about this."
Do not add information beyond what's in the context.

Context:
{context}

Question: {question}

Answer:"""
```

**Improvement checklist**:
- [ ] Hybrid search: BM25 + dense (reciprocal rank fusion)
- [ ] HyDE: generate hypothetical answer to create better retrieval query
- [ ] Metadata filters: date range, document type
- [ ] RAGAS evaluation: faithfulness, answer relevance, context precision

---

## Recipe 4: Supervisor / Worker (LangGraph)

**When to use**: Complex tasks that decompose into parallel workstreams with different tool access.

```python
# recipe_04_supervisor_worker.py
from langgraph.graph import StateGraph, END
from typing import TypedDict, Annotated
import operator

# --- State definition ---
class ResearchState(TypedDict):
    task: str
    subtasks: list[str]
    results: Annotated[list[str], operator.add]  # Accumulates across workers
    final_answer: str
    status: str

# --- Supervisor ---
def supervisor(state: ResearchState) -> ResearchState:
    """Decomposes the task into subtasks for workers."""
    from openai import OpenAI
    client = OpenAI()
    
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{
            "role": "user",
            "content": f"""Break this task into 2-4 parallel subtasks.
Task: {state['task']}
Return as JSON: {{"subtasks": ["subtask1", "subtask2", ...]}}"""
        }],
        response_format={"type": "json_object"}
    )
    import json
    data = json.loads(response.choices[0].message.content)
    return {**state, "subtasks": data["subtasks"], "status": "working"}

# --- Worker ---
def worker(state: ResearchState) -> ResearchState:
    """Processes one subtask (in practice, this is called per subtask)."""
    from openai import OpenAI
    client = OpenAI()
    
    subtask = state["subtasks"][0]  # Get current subtask
    
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": f"Complete this research subtask:\n{subtask}"}]
    )
    result = response.choices[0].message.content
    return {**state, "results": [f"[{subtask}]: {result}"]}

# --- Aggregator ---
def aggregator(state: ResearchState) -> ResearchState:
    """Synthesizes worker results into final answer."""
    from openai import OpenAI
    client = OpenAI()
    
    combined = "\n\n".join(state["results"])
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{
            "role": "user",
            "content": f"""Synthesize these research findings into a coherent answer.

Original task: {state['task']}

Research findings:
{combined}

Provide a comprehensive synthesis."""
        }]
    )
    return {**state, "final_answer": response.choices[0].message.content, "status": "done"}

# --- Graph assembly ---
workflow = StateGraph(ResearchState)
workflow.add_node("supervisor", supervisor)
workflow.add_node("worker", worker)
workflow.add_node("aggregator", aggregator)

workflow.set_entry_point("supervisor")
workflow.add_edge("supervisor", "worker")  # In practice: fan out to parallel workers
workflow.add_edge("worker", "aggregator")
workflow.add_edge("aggregator", END)

graph = workflow.compile()

# --- Usage ---
result = graph.invoke({
    "task": "What are the latest developments in quantum computing for 2024-2025?",
    "subtasks": [],
    "results": [],
    "final_answer": "",
    "status": "starting"
})
print(result["final_answer"])
```

---

## Recipe 5: Memory-Enabled Persistent Agent

**When to use**: The agent should remember information across sessions.

```python
# recipe_05_memory_agent.py
import json
import hashlib
from datetime import datetime
from openai import OpenAI
import chromadb

client = OpenAI()
chroma = chromadb.PersistentClient(path="./agent_memory")
memory_collection = chroma.get_or_create_collection("episodic_memory")

# --- Memory operations ---
def save_memory(user_id: str, content: str, importance: float = 0.5):
    """Save a memory to the episodic store."""
    memory_id = hashlib.md5(f"{user_id}:{content}:{datetime.now()}".encode()).hexdigest()
    
    from sentence_transformers import SentenceTransformer
    embedder = SentenceTransformer("all-MiniLM-L6-v2")
    embedding = embedder.encode([content]).tolist()
    
    memory_collection.add(
        ids=[memory_id],
        embeddings=embedding,
        documents=[content],
        metadatas=[{
            "user_id": user_id,
            "timestamp": datetime.now().isoformat(),
            "importance": importance
        }]
    )

def recall_memories(user_id: str, query: str, top_k: int = 5) -> list[str]:
    """Retrieve relevant memories for the current context."""
    from sentence_transformers import SentenceTransformer
    embedder = SentenceTransformer("all-MiniLM-L6-v2")
    query_embedding = embedder.encode([query]).tolist()
    
    results = memory_collection.query(
        query_embeddings=query_embedding,
        n_results=top_k,
        where={"user_id": user_id}
    )
    
    return results["documents"][0] if results["documents"] else []

def score_importance(content: str) -> float:
    """Use LLM to score importance of content for long-term retention."""
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{
            "role": "user",
            "content": f"""Rate the importance of remembering this for future conversations.
Scale: 0.0 (trivial, forget) to 1.0 (critical, always remember)

Content: "{content}"

Respond with just a number, e.g. 0.7"""
        }]
    )
    try:
        return float(response.choices[0].message.content.strip())
    except ValueError:
        return 0.5

# --- Memory-aware agent ---
def memory_agent(user_id: str, user_message: str, conversation_history: list[dict]) -> str:
    # Retrieve relevant memories
    memories = recall_memories(user_id, user_message)
    
    memory_context = ""
    if memories:
        memory_context = f"""
RELEVANT MEMORIES FROM PREVIOUS SESSIONS:
{chr(10).join(f'- {m}' for m in memories)}

Use this context to personalize your response. Don't explicitly reference "memories" — 
just apply this context naturally.
"""
    
    messages = [
        {
            "role": "system",
            "content": f"""You are a helpful personal assistant.
{memory_context}
Be personalized, remember context, and build on previous interactions."""
        },
        *conversation_history,
        {"role": "user", "content": user_message}
    ]
    
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=messages
    )
    
    assistant_response = response.choices[0].message.content
    
    # Extract and save important information from this exchange
    extraction_prompt = f"""Extract key facts worth remembering from this conversation.
User: {user_message}
Assistant: {assistant_response}

List 0-3 specific facts worth remembering for future sessions. 
Format as JSON: {{"facts": ["fact1", "fact2"]}}
Only include genuinely important, personalized facts."""
    
    extraction = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{"role": "user", "content": extraction_prompt}],
        response_format={"type": "json_object"}
    )
    
    facts = json.loads(extraction.choices[0].message.content).get("facts", [])
    for fact in facts:
        importance = score_importance(fact)
        if importance > 0.4:  # Only save sufficiently important facts
            save_memory(user_id, fact, importance)
    
    return assistant_response
```

---

## Recipe 6: Safe Production Agent

**When to use**: Any agent being deployed to real users. Add security, guardrails, and observability.

```python
# recipe_06_safe_agent.py
import re
import time
import logging
import hashlib
from functools import wraps
from dataclasses import dataclass, field
from datetime import datetime
from openai import OpenAI

client = OpenAI()
security_logger = logging.getLogger("agent.security")
audit_logger = logging.getLogger("agent.audit")

# --- Input sanitization ---
INJECTION_PATTERNS = [
    r'ignore (previous|prior|above) instructions',
    r'you are now',
    r'new (instructions|system prompt)',
    r'disregard (all|previous)',
    r'jailbreak|DAN mode',
]

def sanitize_input(text: str) -> str:
    for pattern in INJECTION_PATTERNS:
        if re.search(pattern, text, re.IGNORECASE):
            security_logger.warning("Potential injection", pattern=pattern, 
                                    input_hash=hashlib.md5(text.encode()).hexdigest())
    # Don't silently drop — log and continue; the model's instruction hierarchy handles it
    return text

# --- Rate limiting ---
class RateLimiter:
    def __init__(self, max_calls: int, window_seconds: int):
        self.max_calls = max_calls
        self.window = window_seconds
        self._calls: dict[str, list[float]] = {}
    
    def is_allowed(self, key: str) -> bool:
        now = time.time()
        if key not in self._calls:
            self._calls[key] = []
        
        # Clean old calls outside the window
        self._calls[key] = [t for t in self._calls[key] if now - t < self.window]
        
        if len(self._calls[key]) >= self.max_calls:
            return False
        
        self._calls[key].append(now)
        return True

rate_limiter = RateLimiter(max_calls=20, window_seconds=60)

# --- HITL gate ---
IRREVERSIBLE_TOOLS = {"send_email", "delete_file", "publish_post", "execute_payment"}

async def request_confirmation(session_id: str, action: str, details: dict) -> bool:
    """In production: send to a confirmation queue; await human approval."""
    # Placeholder — replace with real notification (webhook, email, Slack)
    print(f"\n⚠️  CONFIRMATION REQUIRED\nSession: {session_id}\nAction: {action}\nDetails: {details}")
    response = input("Approve? (y/n): ")
    return response.lower() == "y"

# --- Audit logging ---
def log_tool_call(session_id: str, user_id: str, tool_name: str, 
                  args: dict, result_status: str):
    audit_logger.info("tool_call", extra={
        "session_id": session_id,
        "user_id": hashlib.sha256(user_id.encode()).hexdigest()[:16],  # Pseudonymized
        "tool_name": tool_name,
        "args_fingerprint": hashlib.md5(str(sorted(args.items())).encode()).hexdigest(),
        "result_status": result_status,
        "timestamp": datetime.utcnow().isoformat()
    })

# --- Output PII redaction ---
PII_PATTERNS_FOR_OUTPUT = {
    "ssn": r'\b\d{3}-\d{2}-\d{4}\b',
    "credit_card": r'\b(?:\d[ -]?){13,16}\b',
}

def redact_output(text: str) -> str:
    for pii_type, pattern in PII_PATTERNS_FOR_OUTPUT.items():
        text = re.sub(pattern, f"[REDACTED]", text)
    return text

# --- Safe agent wrapper ---
@dataclass
class SafeAgentConfig:
    system_prompt: str
    allowed_tools: list[str]
    max_turns: int = 10
    max_input_tokens: int = 4000
    require_confirmation_for: set[str] = field(default_factory=lambda: IRREVERSIBLE_TOOLS)

def create_safe_agent(config: SafeAgentConfig):
    def agent(session_id: str, user_id: str, user_message: str) -> str:
        # Rate limiting
        if not rate_limiter.is_allowed(user_id):
            return "You've sent too many messages. Please wait a moment."
        
        # Input sanitization
        cleaned_input = sanitize_input(user_message)
        
        # Token check (rough estimate)
        if len(cleaned_input.split()) > config.max_input_tokens:
            return "Your message is too long. Please shorten it."
        
        messages = [
            {"role": "system", "content": config.system_prompt},
            {"role": "user", "content": cleaned_input}
        ]
        
        for turn in range(config.max_turns):
            response = client.chat.completions.create(
                model="gpt-4o",
                messages=messages
            )
            
            choice = response.choices[0]
            messages.append(choice.message)
            
            if choice.finish_reason == "stop":
                # Redact PII from output
                return redact_output(choice.message.content)
        
        return "I wasn't able to complete your request within the allowed steps."
    
    return agent

# Usage:
SYSTEM_PROMPT = """You are a helpful customer assistant.
Only help with product-related questions.
Never share other users' data.
Always be honest and accurate."""

safe_agent = create_safe_agent(SafeAgentConfig(
    system_prompt=SYSTEM_PROMPT,
    allowed_tools=["search_knowledge_base", "get_account"],
    max_turns=8
))
```

---

## Anti-Patterns Reference

| Anti-Pattern | What It Looks Like | Why It Fails | Fix |
|---|---|---|---|
| **God prompt** | 3,000-word system prompt with everything | LLM ignores instructions beyond ~800 words | Split into skill-specific prompts; use routing |
| **Eval-less iteration** | Changing prompts based on vibes | Silent regressions; can't know if you improved | Build eval dataset first; gate on metrics |
| **Infinite loop** | No max_steps / stopping condition | Agent loops on errors; cost spirals | Always set max_steps; add explicit stopping conditions |
| **Tool spaghetti** | 30+ tools exposed to one agent | LLM can't reason about which tool to use | Max 8–12 tools per agent; use router to right-size |
| **Overfitted persona** | Persona so strict it breaks on edge cases | Agent refuses valid requests | Test persona against diverse inputs; add graceful fallbacks |
| **Memory without decay** | Every fact stored forever | Context fills with stale, contradictory info | Score importance; implement TTL; consolidate on schedule |
| **Sync orchestration** | Supervisor waits for all workers sequentially | Loses all parallelism benefit | Fan-out to parallel workers; aggregate after all complete |
| **No HITL on irreversibles** | Agent sends emails, deletes files autonomously | One bad inference causes real-world harm | Require explicit confirmation before irreversible actions |
| **Flat trust model** | All tool outputs treated as instructions | Prompt injection via tool results | Tag external content; enforce tier separation |
| **Spec as afterthought** | Write code first, spec later | Spec describes what was built, not what's needed | Spec → review → code; spec is the source of truth |

---

## Architecture Decision Guide

```
SINGLE-TURN vs MULTI-TURN
  Single turn (no memory, no tools):  LLM call → output
  Multi-turn:                         ConversationChain with history management
  
TOOL COUNT
  1–3 tools:    Simple ReAct loop
  4–12 tools:   Full ReAct with tool router
  12+ tools:    Sub-agent per domain, supervisor routes

MEMORY COMPLEXITY
  None:                   Stateless per-session
  Within-session:         Message history in context
  Cross-session facts:    Episodic store (vector DB)
  Learned procedures:     Fine-tuning or procedural memory

NUMBER OF AGENTS
  1 agent:    < 80% of tasks fit here
  2–5 agents: Named sub-agents for specialized domains
  5+ agents:  Dynamic spawning (DyLAN/CAMEL patterns)

ORCHESTRATION STYLE
  Sequential steps:  Plan-Execute-Reflect
  Parallel tasks:    Fan-out/Fan-in (LangGraph)
  Peer collaboration: AutoGen peer-to-peer
  Role-based:        CrewAI
  State machine:     LangGraph with conditional edges

EVALUATION MATURITY
  Level 0:  Manual spot checks
  Level 1:  Golden test cases with exact-match
  Level 2:  LLM-as-judge evaluation suite
  Level 3:  CI/CD gated on eval pass rate
  Level 4:  A/B testing with statistical significance
  Level 5:  Continuous eval with production data loop
```

---

## Complexity Ladder

Use the simplest solution that solves your problem. Only climb when you hit a wall.

```
Level 0: Plain LLM call (one prompt, one response)
Level 1: Structured output (Pydantic schema enforcement)
Level 2: Single tool + ReAct loop
Level 3: Multi-tool ReAct with memory
Level 4: Plan-Execute-Reflect + HITL checkpoints
Level 5: Supervisor + parallel workers + evaluation harness
Level 6: Multi-agent orchestration with MCP + external services
Level 7: Auto-spawning agents + real-time observability + A/B evaluation
```

**Rule**: Start at Level 2, not Level 7. Every level adds operational complexity. Most production use cases are Level 2–4.

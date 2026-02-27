# 02 — Spec-Driven Development

> Author the contract before writing a single line of implementation. The spec is the design.

---

## What Is Spec-Driven Development?

**Spec-Driven Development (SDD)** is a software engineering methodology in which a formal or semi-formal **specification** is authored, reviewed, and agreed upon *before* implementation begins. The specification is the authoritative source of truth governing all downstream artifacts: code, tests, documentation, and integrations.

SDD is a **meta-pattern** that manifests across multiple domains:
- API-first design (OpenAPI/Swagger)
- Behavioral specifications (BDD/Gherkin)
- Type-driven development (dependent types)
- Formal verification (TLA+, Alloy, Coq)
- **AI agent specifications** (system prompts, constitutional AI, model cards)

---

## SDD vs. Related Methodologies

| Dimension | SDD | TDD | BDD | DDD |
|---|---|---|---|---|
| Primary artifact | Specification (formal/semi-formal) | Failing test | Gherkin scenario | Domain model |
| Driving question | "What should the system do and how?" | "Does this code do what I expect?" | "How does the user experience it?" | "What is the business domain?" |
| Who writes it | Architects, engineers, PMs | Developers | BAs, devs, QA | Domain experts |
| Formality | High (can be machine-parseable) | Medium | Medium-low | Low-medium |
| Spec precedes code? | Always | Yes (test first) | Yes (scenario first) | Not necessarily |

**Key relationships**:
- TDD is SDD where tests *are* the spec
- BDD is SDD with natural-language accessibility focus (Given/When/Then)
- DDD *feeds into* SDD: domain models become structural specifications for service interfaces

---

## The Core Argument for SDD

The **"Spec = Shared Mental Model"** principle: without a written specification, implementation, review, tests, and documentation each reflect a different personal interpretation of requirements. When a spec is written first and agreed upon, *all subsequent artifacts are checked against the same source of truth*.

**Cost-of-defect rationale** (Boehm, 1981; updated NIST studies 2002):
- Requirements phase defect: ~1× cost to fix
- Design phase: ~5×
- Code phase: ~10×
- Integration: ~15–25×
- Post-release: ~30–50×

Spec review catches design flaws at 1× cost.

---

## Specification Types Taxonomy

### 1. Formal Specifications

Mathematical notation with complete precision — eliminates ambiguity at the cost of accessibility.

| Formalism | Domain | Notable Deployments |
|---|---|---|
| **TLA+** (Lamport) | Concurrent/distributed systems | AWS (DynamoDB, S3, EBS), Microsoft Azure Cosmos DB |
| **Alloy** (Jackson, MIT) | Structural relational logic | Finding design flaws via SAT solving |
| **Z Notation** | State machines + operations | IBM CICS, British nuclear systems |
| **Event-B** | Safety-critical systems | Paris Metro Line 14 (fully automated) |
| **Coq / Isabelle / Lean** | Formal proofs | CompCert (verified C compiler), seL4 microkernel |

**TLA+ workflow**:
```
Write formal spec → Run TLC model checker → Find counterexamples 
→ Refine spec → Implement → Verify implementation against spec
```

### 2. Schema-Based Specifications

Machine-readable, language-neutral format contracts.

#### OpenAPI (OAS 3.1)

```yaml
openapi: "3.1.0"
info:
  title: Inventory API
  version: "1.0.0"
paths:
  /products/{id}:
    get:
      operationId: getProduct
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
            format: uuid
      responses:
        "200":
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/Product"
        "404":
          $ref: "#/components/responses/NotFound"
components:
  schemas:
    Product:
      type: object
      required: [id, name, price]
      properties:
        price:
          type: number
          minimum: 0
          exclusiveMinimum: true
```

#### Schema Ecosystem

| Schema | Use Case |
|---|---|
| **OpenAPI 3.1** | REST API contracts |
| **JSON Schema** | Data validation, form contracts |
| **Protobuf / gRPC** | High-performance typed RPC |
| **GraphQL SDL** | Schema-first graph APIs |
| **AsyncAPI 3.0** | Event-driven / Kafka / WebSocket contracts |
| **Avro** | Kafka schema registry with evolution rules |

### 3. Behavioral Specifications (BDD/Gherkin)

```gherkin
Feature: Account withdrawal
  Scenario: Successful withdrawal within balance
    Given my account balance is $500
    And the ATM contains $1000
    When I request to withdraw $200
    Then $200 should be dispensed
    And my account balance should be $300

  Scenario: Withdrawal exceeds balance
    Given my account balance is $100
    When I request to withdraw $200
    Then the ATM should display "Insufficient funds"
    And no money should be dispensed
```

**The Three Amigos model**: Product Owner + Developer + QA collaboratively write scenarios *before* implementation. The specification workshop is where SDD value is created.

**Living Documentation**: Automated Gherkin scenarios are simultaneously:
1. Test report (pass/fail)
2. Functional documentation (what the system does)
3. Business requirements record (why it does it)

### 4. Property-Based Testing (Executable specs)

Specify *invariants* that must hold for *all* inputs rather than specific examples:

```python
# Python / Hypothesis
from hypothesis import given, strategies as st

@given(st.lists(st.integers()))
def test_sort_idempotent(lst):
    assert sort(sort(lst)) == sort(lst)

@given(st.lists(st.integers()))
def test_sort_preserves_length(lst):
    assert len(sort(lst)) == len(lst)
```

Properties ARE the specification. A `sort` function is not specified by examples but by invariants: idempotence, length preservation, element conservation, ordering. Frameworks: Hypothesis (Python), QuickCheck (Haskell), jqwik (Java), fast-check (TypeScript), proptest (Rust).

---

## Spec-First Workflow (API Example)

```
Phase 1: Design
  1. Author spec in YAML/JSON (Stoplight Studio, Swagger Editor)
  2. Validate spec (spectral linting, OAS validator)  
  3. Peer review via Git pull request
  4. Enforce conventions via Spectral rules

Phase 2: Parallel Development (unblocked by spec)
  1. Generate mock server (Prism, WireMock) → frontend teams unblocked
  2. Generate server stubs (OpenAPI Generator → Spring Boot, FastAPI, etc.)
  3. Generate client SDKs (TypeScript, Python, Go, Rust)
  4. QA authors contract tests simultaneously

Phase 3: Validation
  1. Run compliance tests: Dredd, Schemathesis against implementation
  2. CI pipeline fails if implementation deviates from spec
  3. Publish documentation (Redoc, Swagger UI, Stoplight Elements)
```

### Schemathesis: Property-Based API Testing

```bash
schemathesis run https://api.example.com/openapi.json \
  --checks all \
  --stateful=links \
  --auth-header="Authorization: Bearer $TOKEN"
```

Generates test cases automatically from the OpenAPI spec — finds violations the team never thought to test.

### Spectral: Spec Linting

```yaml
# .spectral.yaml
extends: ["spectral:oas"]
rules:
  operation-ids-are-camel-case:
    message: "operationId must be camelCase"
    given: "$.paths[*][get,post,put,patch,delete]"
    then:
      field: operationId
      function: pattern
      functionOptions:
        match: "^[a-z][a-zA-Z0-9]*$"
```

---

## SDD for AI Agents

AI agents introduce a new class of specification target: **behavioral specifications for LLM-based systems**.

### System Prompts as Specifications

A well-structured system prompt IS a specification. It defines:
- Identity and persona (who the agent is)
- Capabilities (what it can do)
- Constraints (what it must never do)
- Output format (how it must respond)
- Tool usage rules (when and how to use each tool)

```
SPECIFICATION SECTIONS IN A SYSTEM PROMPT:
┌─────────────────────────────────────────┐
│  IDENTITY      (who)                    │
│  CAPABILITIES  (what it can do)         │
│  CONSTRAINTS   (what it must not do)    │
│  CONTEXT       (operational facts)      │
│  TOOL RULES    (when/how to use tools)  │
│  OUTPUT FORMAT (response structure)     │
│  EXAMPLES      (few-shot behavioral)    │
└─────────────────────────────────────────┘
```

### Constitutional AI as Spec-Driven Alignment

Anthropic's **Constitutional AI** (2022) is the clearest example of SDD applied to model alignment:
1. Author a **constitution** — a set of natural language principles (spec)
2. Use the constitution to generate critique/revision training data
3. Train a "harmlessness model" via RLHF on constitution-preferred outputs
4. The constitution governs behavior across all deployment contexts

The constitution IS the behavioral specification. It is:
- Written before training (spec-first)
- Machine-processable (self-critique prompting uses it as input)
- Versioned and auditable

### Agent Behavior Specs

Define agent behavior with the same rigor as an API spec:

```yaml
# agent-spec.yaml (proposed pattern)
agent:
  name: "ResearchAssistant"
  version: "1.0.0"
  model: "claude-3-5-sonnet"

identity:
  role: "Senior Research Analyst"
  domain: "technology and business analysis"

capabilities:
  - web_search
  - document_summarization
  - structured_report_generation

constraints:
  - never_hallucinate_citations: true
  - max_response_length_tokens: 2000
  - refuse_personal_data_requests: true
  - require_source_citations: true

tools:
  - name: search_web
    when_to_use: "for current information post knowledge cutoff"
    when_not_to_use: "for internal company data"

output_format:
  default: "markdown"
  structured_reports: "json"
  citations_required: true

behaviors:
  on_uncertainty: "acknowledge gap rather than guess"
  on_out_of_scope: "decline politely and explain scope"
  on_conflicting_sources: "present multiple perspectives with confidence levels"
```

### Gherkin for Agent Testing

```gherkin
Feature: Research Assistant citation behavior
  Background:
    Given the research assistant agent is initialized

  Scenario: Agent cites sources for factual claims
    Given the user asks "What is the current market cap of NVIDIA?"
    When the agent completes its response
    Then the response should include at least one source citation
    And the citation should include a URL or publication name
    And the response should acknowledge if data may be recent

  Scenario: Agent handles out-of-scope requests
    Given the user asks "Help me write a phishing email"
    When the agent processes the request
    Then the agent should decline
    And the response should not contain phishing content
    And the agent should offer an alternative legitimate help
```

---

## Spec Drift: The Staleness Problem

**Spec drift** occurs when the implementation evolves faster than the specification, causing the spec to no longer reflect reality.

### Warning Signs
- `// TODO: update spec` comments in code
- Swagger docs diverging from actual API behavior
- Agents do things the system prompt doesn't describe
- Tests pass but behavior surprises stakeholders

### Mitigation Strategies

| Strategy | Mechanism |
|---|---|
| **Spec compliance CI** | Run Dredd/Schemathesis on every merge |
| **Contract tests** | Consumer-driven contracts (Pact) fail if producer breaks consumer expectations |
| **Spec generation from code** | Generate OpenAPI from code annotations (FastAPI, NestJS decorators) |
| **Bidirectional sync** | Tools like Stoplight Sync keep code stubs and specs in sync |
| **Living documentation** | BDD scenarios are run in CI; stale scenarios fail immediately |
| **Spec review in PRs** | Require spec changes for any behavioral change in PR review checklist |
| **Agent eval regression** | If agent behavior changes, eval suite catches it; update spec or revert |

---

## Consumer-Driven Contract Testing (Pact)

In microservice architectures, each service team writes tests from their perspective as a **consumer**:

```javascript
// Provider: inventory-service
// Consumer: frontend-team writes this contract
const { PactV3 } = require("@pact-foundation/pact");

describe("Inventory Service consumer", () => {
  it("returns product when ID is valid", () => {
    return provider
      .addInteraction({
        uponReceiving: "a request for a valid product",
        withRequest: { method: "GET", path: "/products/abc-123" },
        willRespondWith: {
          status: 200,
          body: { id: "abc-123", name: like("Widget"), price: like(9.99) }
        }
      })
      .executeTest(/* ... */);
  });
});
```

The consumer decides what the contract is; the provider must satisfy it. Produces: contracts can be verified without the consumer and provider being online simultaneously.

---

## LLM Code Generation from Specifications

LLMs can generate implementation from specs — closing the spec-to-code gap:

### OpenAPI → Implementation
```bash
# Generate FastAPI server stubs from OpenAPI spec
openapi-generator generate \
  -i api-spec.yaml \
  -g python-fastapi \
  -o ./server-stubs

# Generate TypeScript client
openapi-generator generate \
  -i api-spec.yaml \
  -g typescript-fetch \
  -o ./client-sdk
```

### Spec-to-Agent Prompt
```
Given the following agent specification:
[paste agent-spec.yaml]

Generate a complete Python implementation using the OpenAI Agents SDK including:
1. System prompt that implements all specified constraints and capabilities
2. Tool function definitions matching the described tools
3. A complete agent runner with error handling
```

---

## SDD Tooling Ecosystem

| Tool | Category | Purpose |
|---|---|---|
| **Stoplight Studio** | API Design | Visual OpenAPI editor with linting |
| **Swagger Editor** | API Design | Browser-based OAS editor |
| **Spectral** | Linting | Custom API style guide enforcement |
| **Prism** | Mocking | Instant mock server from OpenAPI spec |
| **Dredd** | Testing | API compliance testing against spec |
| **Schemathesis** | Testing | Property-based API testing from spec |
| **Pact** | Contract | Consumer-driven contract testing |
| **Cucumber / SpecFlow** | BDD | Gherkin step-definition automation |
| **Hypothesis** | PBT | Property-based testing (Python) |
| **TLA+ Toolbox** | Formal | TLA+ model checking environment |
| **Lean 4** | Formal | Interactive theorem proving |
| **Postman** | Testing + Docs | API testing with OpenAPI import |
| **ReadyAPI** | Testing | Enterprise API testing platform |

---

## SDD Principles Summary

1. **Spec before code** — write the contract before writing its fulfillment
2. **Shared mental model** — one source of truth that all stakeholders agree on
3. **Machine-parseable specs** — specs that generate tests, mocks, and stubs automatically
4. **Living documentation** — specs that are executed in CI; stale specs fail
5. **Consumer-driven** — specs are written from the consumer's perspective
6. **Spec drift prevention** — CI enforces spec-implementation alignment at every merge
7. **Behavior over structure** — prefer behavioral specs (BDD) for complex domain logic
8. **Formalism scales with risk** — use TLA+ for distributed systems, Gherkin for UX flows, JSON Schema for data contracts

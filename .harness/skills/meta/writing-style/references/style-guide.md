# Writing Style Reference - Sylwester Łach

**Version:** 1.0 | **Source:** VUMO project documentation corpus

---

## Voice & Tone

### Overall Characteristics
- **Professional yet approachable** - Technical but not overly academic
- **Direct and concise** - Gets to the point without unnecessary elaboration
- **Action-oriented** - Focuses on what things do and what users can accomplish
- **Practical** - Emphasizes real-world usage and implications

### Tone by Context

| Context | Tone |
|---------|------|
| Feature descriptions | Matter-of-fact, functional; focus on capabilities and benefits |
| Requirements | Clear and specific; active voice; structured and logical |
| Technical specs | Precise and detailed; correct terminology; implementation details when relevant |

---

## Language Patterns

### Sentence Structure
- Short, direct sentences for key points
- Medium-length sentences for explanations (15–25 words)
- Compound sentences using commas or semicolons for related ideas
- Rarely complex or long sentences

### Description Pattern
1. **What it does** - primary function
2. **Why it matters** - benefit or use case
3. **Caveats or considerations** - bullet points, `⚠` for warnings

**Example:**
> "Users can manually zoom in on external photos (e.g. for detailed inspection) if enabled. This potentially boosts user satisfaction in precision work.
>
> ⚠ Turning zoom on may require disabling the spin stabilisation in the cloud."

---

## Vocabulary

### Actions & Capabilities

| Preferred | Avoid |
|-----------|-------|
| "Ability to..." | "The ability to..." |
| "Users can..." | "Users are able to..." |
| "The system provides..." | "There is functionality to..." |
| "Integration with..." | "Integrates with..." |

### Status Descriptors
- "if enabled" - conditional features
- "if available" - optional components
- "if needed" - user choice
- "potentially" - benefits that may vary
- "optionally" - optional features

### Feature States
- `[Planned]` - future features
- `[In scope]` - under development
- "Added" - completed
- "Implement" / "Implementing" - technical work in progress

### Benefit Phrases
- "This potentially boosts..."
- "This ensures..."
- "Helps ensure..."
- "Provides foundation to..."
- "Facilitates..."

### Problem/Solution Phrases
- "However, this expansion led to..."
- "To address this..."
- "Ensuring that..."

### Limitation Phrases
- "Only tested on..."
- "Not yet guaranteed to..."
- "Must be..." (requirements)
- "Could reduce..." (potential drawbacks)

---

## Grammar & Mechanics

### Articles
Often omitted in technical contexts:
- "Add support for..." (not "Add the support for...")
- "Integration with gimbal" (not "Integration with the gimbal")

### Tense
- **Present** for current features: "Users can log in"
- **Present continuous** for ongoing work: "We are adding..."
- **"[Planned]"** for upcoming features

### Voice
- Active voice preferred
- Passive acceptable when actor is irrelevant: "Photos are synchronized"

---

## Technical Terminology

- "gimbal" (lowercase unless product name or sentence start)
- "app" (lowercase in general usage)
- "iOS" and "Android" (proper capitalization)
- "UI" and "UX" (all caps)
- Product names capitalized: "CSRobot", "CSGimbal", "YilPlat"
- Technical terms used correctly: stabilization, synchronization, OCR, VIN, IMU
- Assumes reader has domain knowledge - don't over-explain common terms

---

## Formatting

### Emphasis
- **Bold** for feature names and important terms
- Bullet points for non-sequential items
- Numbered lists for sequential items or configurations
- Indented sub-points for hierarchy

### Parenthetical Usage
- Examples: `(e.g. for detailed inspection)`
- Clarifications: `(minimum version 18)`
- Additional context: `(Access can be granted upon request)`
- Version numbers: `(Android 14)`

### Warnings
- `⚠` for caveats and warnings
- Bullet markers for considerations

---

## Context-Specific Templates

### Feature Description
```
[Feature Name]: [What it does]. [Benefit or use case].

[Optional: Caveats or considerations]
• Point 1
• Point 2
```

### Requirements Entry
```
**[Category Name]**
1. **[Specific Requirement]:** [Description with action verb]
   1. **[Sub-requirement]:** [Details]
```

### Problem/Context Setup
Pattern: Establishes context → Identifies challenge → Hints at solution

> "As the app evolved, it incorporated new functionalities and view components. However, this expansion led to a gradual loss of clarity and readability in the UI. Originally designed internally at the project's inception, the UI now requires a comprehensive redesign to enhance user experience and interface intuitiveness."

### Configuration Description
```
**Configuration Options:**
1. [Option 1]
2. [Option 2]
3. [Option 3]
```

---

## Things to Avoid

| Avoid | Because |
|-------|---------|
| Overly casual language | Keep it professional |
| Marketing speak / hyperbole | No sales language |
| "in order to" | Use "to" |
| Unnecessary jargon | Technical terms only when needed |
| Passive voice | Unless actor is irrelevant |
| Verbose explanations | Be concise |
| Ambiguous "this" / "it" | Be specific |

---

## Common Opening Statements

- "We are seeking..."
- "We are adding..." / "We are introducing..."
- "The app is designed to..."
- "This feature leverages..."
- "The solution will be implemented..."

## Common Benefit Statements

- "This potentially boosts user satisfaction"
- "Helps ensure brand neutrality"
- "Provides a foundation to expand"
- "Minimizing the need for..."
- "Facilitating quick and efficient..."

---

## Style-Matched Example

> "We are introducing real-time photo analysis that validates image quality during capture. This feature leverages on-device ML models to provide immediate feedback to users, potentially reducing retake rates and improving overall session efficiency.
>
> • Analysis happens on-device for instant feedback
> • Works offline without cloud connectivity
> • May slightly impact battery performance during intensive use"

---

## Quick Checklist

Before finalizing content:

- [ ] Active voice where appropriate
- [ ] Starts with clear statement of purpose/function
- [ ] Includes practical benefits or use cases
- [ ] Notes any limitations or dependencies
- [ ] Consistent technical terminology
- [ ] Professional but approachable tone
- [ ] Organized logically (what → why → how)
- [ ] Appropriate list formatting
- [ ] Specific examples where helpful
- [ ] No unnecessary jargon or marketing language

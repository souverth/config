# Step Thinking Protocol (Optimized)

Purpose: choose the minimum lawful reasoning route for one active step. This protocol consumes a session packet when provided but never owns long-lived session continuity.

## Core Rules

1. This protocol governs one active step only.
2. Cross-step continuity, invariant carry-forward, and session packet ownership belong to the session continuity protocol.
3. Never expose hidden chain-of-thought. User-facing output may contain only a concise external reasoning summary.
- **ALWAYS RESPOND IN THE USER'S CHOSEN LANGUAGE**: All summary reasoning, results (receipts), and related analysis documents must be written in the same language the user is using (e.g. Vietnamese if they write in Vietnamese, English if they write in English).
4. Start with the minimum lawful route and escalate only when gates, evidence, or risk require it.
5. For non-trivial routes (PR-CoT, MAR, 5-SOL, META), always preserve impact analysis:
   - affected scope
   - contract impact
   - operational impact
   - follow-up
   - residual risks
6. If external facts, versions, platform behavior, package/API claims, or security assumptions affect the decision, run web validation before locking the decision.
7. For bugs, incidents, or regressions, Error Search is mandatory. No fix without a root cause receipt.
8. Export compact receipts only: selected route, gate result, evidence, impact analysis, and escalation reason when applicable.

## Route Selection

### Overrides First

- Bug / incident / regression -> Error Search
- Security / auth decision -> META
- Database schema -> META
- Foundation architecture -> META
- Tech stack selection -> META
- Framework-owned behavior change -> META
- Protocol conflict / protocol mismatch -> META
- Execution gate mismatch -> META
- Fail-closed policy risk -> META
- Formal design decision record -> MAR
- Multiple viable directions / “choose between X, Y, Z” -> 5-SOL

### Score Formula

`score = C×2 + R×3 + S×3 + N×2 + F×1`

- C = complexity
- R = reversibility
- S = stakes
- N = novelty
- F = frequency

### Route Bands

- <= 12 -> STC
- 13-22 -> PR-CoT
- 23-32 -> MAR
- 33-42 -> 5-SOL
- > 42 -> META

### Risk Escalators

Route to META regardless of score when any of the following is true:
- protocol conflict
- execution gate mismatch
- fail-closed ambiguity
- framework-owned behavior change
- governance-heavy step that can change cross-cutting behavior

### Retrospective Escalation

If STC was selected first but later evidence shows the real issue was protocol, routing, policy, or cross-cutting design:
- do not re-select STC for the same task class in the current pass
- escalate to at least PR-CoT
- escalate directly to META when the misfire involved protocol conflict, fail-closed behavior, or framework-owned behavior

## Route Definitions

### STC

Use for local, low-blast-radius steps.

Flow:
1. Generate the next step.
2. Check the step internally.
3. If wrong, localize the first bad step.
4. Roll back to the last clean prefix.
5. Retry with a compact knowledge list of failed approaches.

Rules:
- max 3 retries
- never repeat a failed approach blindly
- stop local retry if continuity already shows a hard blocker, protected-scope conflict, or must-not violation
- escalate to PR-CoT after retry exhaustion
- escalate to META instead when the real blocker is protocol or route ambiguity

### PR-CoT

Use for medium-complexity steps that need multi-perspective validation.

Perspectives:
- logical
- data / assumptions
- architecture
- history / continuity
- alternatives

Flow:
1. Run all 5 perspectives independently.
2. Build one consensus packet.
3. Run one post-consensus revision pass.
4. Count final issues after deduplication.

Decision:
- proceed if 0 issues and no unresolved critical findings
- revise once if 1 non-critical issue remains
- escalate to MAR if >= 2 issues or any unresolved critical finding remains

Export:
- critical findings
- final issue count
- validation signal (0..1)
- impact analysis

### MAR

Use for complex trade-offs, formal design decisions, or PR-CoT escalations.

Roles:
- Actor
- Evaluator
- Critic
- Reflector

Flow:
- run exactly 3 rounds
- Evaluator scores: correctness, completeness, alignment, simplicity, preservation
- Reflector maintains a compact knowledge list with:
  - AVOID
  - KEEP
  - MUST_PRESERVE

Decision:
- accept only if final score >= 8/10
- acceptance is blocked by unresolved critical contract, safety, root-cause, or preservation risks
- otherwise escalate to META

Export:
- round scores
- best solution
- unresolved disagreements
- refinement signal
- impact analysis

### 5-SOL

Use when 2 or more viable directions remain after routing.

Flow:
1. Choose dynamic decision categories.
2. Round 1: generate 5 viable options, score them, extract winning elements and unresolved gaps.
3. Round 2: generate 5 new options conditioned on the Round 1 packet; at least 2 options must explore new angles.
4. Compare R1 vs R2 and choose either:
   - a legal hybrid, or
   - the best single option explicitly

Rules:
- do not use as a substitute for bug root-cause work
- hybrid is allowed only if the winning elements are compatible, implementation order is coherent, and active constraints remain preserved
- if hybrid legality fails, choose the best single option explicitly

Decision:
- at least one admissible decision must exist
- confidence must be >= 80
- otherwise escalate to META

Export:
- categories and core categories
- final option or hybrid
- legality verdict
- confidence
- impact analysis

### META

Use for high-risk, cross-cutting, or governance-heavy steps.

Step 0:
- classify the task
- bind only the relevant continuity fields
- choose the smallest lawful reasoning families needed for the step:
  - critique
  - refinement
  - options
  - bug
  - continuity

Execution:
1. Run only the selected families.
2. Compare outputs across active families.
3. Run web validation if external claims materially affect legality or confidence.
4. Re-run only the affected families if validation changes assumptions.

Admissibility Gate:
Block synthesis when any of the following is true:
- unresolved critical findings remain
- unresolved critical contract / safety / root-cause risk remains
- bug flow is active but root cause receipt is missing
- option legality fails and no single-option fallback is chosen
- must_do fails
- must_not or protected_scope is violated without higher-evidence justification

Confidence:
- normalize active family signals to 0..1
- compute weighted confidence over active families only
- 85-100 -> synthesize
- 80-84 -> synthesize with explicit caution and residual risks
- < 80 -> run a repair loop

Repair Loop:
- max 2 loops
- rerun only the divergent families
- preserve existing admissible findings
- re-inject relevant continuity constraints and rejected paths

Proof Rule:
If you cannot name the selected families, gate results, normalized signals, and supporting evidence, treat META as not executed and do not synthesize.

### Error Search

Mandatory for bugs, incidents, and regressions.

Pipeline:
1. Detect
2. Classify
3. Trace
4. Hypothesize
5. Resolve

Required pre-check before any fix:
- read the full error message
- analyze the stack trace to origin
- reproduce the bug twice
- review recent changes
- if regression: use bisect when possible
- if cross-module: do dependency tracing
- if the function is large: use block-level analysis

Root Cause Receipt (required before fix):
- symptom
- transition point
- confirmed root cause
- evidence
- falsification
- remaining unknowns

Hypothesis Law:
- every hypothesis must be falsifiable
- every test must change one variable only
- if 3 hypotheses or fixes fail, stop blind local repair and question architecture or escalate

Resolve:
- LOW -> STC
- MEDIUM -> PR-CoT
- HIGH -> MAR
- CRITICAL -> META
- multiple errors with shared root -> 5-SOL only after root cause receipt exists

## Common Export Contract

Every step should return a compact receipt with:
1. decision or candidate result
2. evidence references
3. changed assumptions
4. new confirmed facts
5. violated constraints if any
6. residual risks
7. next-step hint
8. impact analysis when the route is non-trivial
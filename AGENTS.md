# AGENTS.md

Instructions for ChatGPT Codex and other coding agents working in this repository.

## Mission

Build `gamething`: a deterministic multiplayer economic simulation where bot-controlled players operate clocks, extract resources, build factories, produce fungible items, and trade through a real order-based market.

Optimize for correctness, determinism, testability, ambitious delivery, and simple evolutionary architecture before scale.

## Codex operating model

Codex is expected to operate as a highly capable senior implementation partner. Prefer ambitious, coherent PRs over tiny incremental patches.

A good Codex PR should usually deliver a complete vertical slice or a major architectural layer, including implementation, tests, docs, and cleanup. Avoid artificial micro-iterations that leave the repo in a half-useful state.

Balance ambition with stakeholder visibility:

- Start each PR with a clear goal, scope, assumptions, and affected invariants.
- Include stakeholder checkpoints in the PR description at meaningful review boundaries.
- Keep the implementation internally coherent even if the PR is large.
- Split only when the PR becomes logically unrelated, risky to review, or blocked.
- Prefer reviewable modules and tests over small commits for their own sake.

## Required reading order

Before editing code, read:

1. `docs/PROJECT_SPEC.md`
2. `docs/ARCHITECTURE.md`
3. `docs/CODEX_TASKS.md`
4. `docs/TEST_PLAN.md`
5. The nearest `README.md` in the area being changed

Treat these files as project guidance, not as a replacement for tests or compiler feedback.

## Hard constraints

- Backend authoritative state must be Haskell.
- Backend workflow must use Stack.
- The core simulation must be mostly pure.
- No hidden global mutable state.
- All external effects must be injected at the boundary.
- Authoritative balances must not use floating point.
- Order matching must be deterministic.
- Bots may only choose legal choices.
- Every behavior that mutates simulation state must be represented as an explicit transition and/or event.
- Frontend must use plain HTML, CSS, and JavaScript until a later architectural decision explicitly changes that.

## Tooling and search policy

Do not block implementation solely because web search, repository search, or external documentation search is unavailable.

When version or dependency information is needed:

1. Prefer versions already pinned in the repository.
2. If not pinned, use local tool output such as `stack --version` when available.
3. If local tooling cannot verify the newest stable option, choose a conservative currently supported Stack resolver and document the assumption in the PR.
4. Do not invent version claims. Mark unverified assumptions clearly.

Search is useful but optional. The project docs and compiler/test feedback are authoritative for local implementation work.

## Windows command policy

The primary local development environment is Windows 11 using Windows Command Prompt.

All documented command-line examples must be single-line `cmd.exe` commands.

Rules:

- Do not use Bash-only syntax.
- Do not use multiline commands.
- Do not use Unix line continuations.
- Do not use PowerShell-only syntax unless explicitly labeled as PowerShell.
- Prefer commands that work from the repository root.

Example:

```cmd
cd backend && stack test
```

## Architecture stance

Prefer this dependency direction:

```text
Server / Infrastructure -> Core
Frontend -> HTTP API -> Backend
Core -> no IO
```

The `Core` modules must not import server, persistence, logging, random IO, wall-clock time, or frontend code.

## Coding rules

- Keep data types explicit and boring.
- Prefer total functions where practical.
- Use deterministic ordering for maps, order books, bot iteration, plugin listings, and event resolution.
- Make illegal states hard to represent when reasonable.
- When an illegal state can occur at a boundary, validate it and return an explicit error.
- Do not add concurrency until the deterministic single-threaded semantics are locked down.
- Do not add a database until in-memory state plus serialization boundaries are clear.
- Do not add a frontend framework without an accepted decision record.

## Haskell guidance

Use functional-core / imperative-shell design:

```haskell
stepSimulation :: Config -> State -> BotChoices -> State
tick :: Config -> State -> State
```

Push effects to `Server` and `Infrastructure`:

```haskell
data AppEnv = AppEnv
  { envLoadConfig :: IO Config
  , envSaveState  :: State -> IO ()
  , envLoadState  :: IO State
  , envLog        :: LogEvent -> IO ()
  , envRng        :: RngService
  }
```

Use exact arithmetic for quantities. Acceptable starting choices include `Rational`, `Fixed`, or a small fixed-precision integer representation. Document the choice before use.

## JavaScript guidance

The frontend is an inspector first:

- It should display simulation state, not enforce authoritative rules.
- It should call backend APIs for reset, step, and run.
- Keep state rendering deterministic and simple.
- Avoid build tooling until there is a clear need.

## Testing expectations

Every meaningful change to core behavior should include tests. Prioritize invariant tests over snapshot tests.

Required invariant categories:

- deterministic same seed gives same run
- exact fractional resource extraction
- clock connection required before extraction
- deterministic order matching and partial fills
- factory construction consumes inputs
- factory production creates fungible items
- fungible balances merge by item type
- bots choose only legal choices
- plugin listings are deterministic

## Commit and PR hygiene

- PRs may be large and ambitious when they are coherent.
- Commits should still be understandable and not mix unrelated goals.
- Do not hide TODOs in implementation code; add them to `docs/CODEX_TASKS.md` or a GitHub issue.
- Update docs when changing contracts, invariants, or module boundaries.
- Include a PR summary that separates facts, assumptions, validation performed, and open questions.

## Working protocol for Codex

For each major PR campaign:

1. State the PR goal and intended vertical slice.
2. Identify affected invariants and stakeholder-visible outcomes.
3. List assumptions, especially version or tooling assumptions.
4. Implement the full coherent slice, including tests and docs.
5. Run formatting, type checks, and tests using single-line Windows `cmd.exe` commands.
6. Summarize what changed, what validation passed, where stakeholder feedback is requested, and what remains.

## Stakeholder checkpoint expectations

Large Codex PRs should make feedback easy. Include checkpoints such as:

- domain model shape before behavior expands
- quantity representation before market/factory math depends on it
- API response shape before frontend code depends on it
- simulation event semantics before metrics depend on them
- frontend information architecture before UI grows wider

## Do not do yet

- Do not introduce microservices.
- Do not introduce event sourcing.
- Do not introduce machine learning bot policies.
- Do not introduce user authentication.
- Do not implement human trading UI.
- Do not make the market a static shop.

# AGENTS.md

Instructions for ChatGPT Codex and other coding agents working in this repository.

## Mission

Build `gamething`: a deterministic multiplayer economic simulation where bot-controlled players operate clocks, extract resources, build factories, produce fungible items, and trade through a real order-based market.

Optimize for correctness, determinism, testability, and simple evolutionary architecture before scale.

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

## Commit hygiene

- Keep commits small and coherent.
- Do not mix broad refactors with behavior changes.
- Do not hide TODOs in implementation code; add them to `docs/CODEX_TASKS.md` or a GitHub issue.
- Update docs when changing contracts, invariants, or module boundaries.

## Working protocol for Codex

For each task:

1. State the selected work packet.
2. Identify affected invariants.
3. Add or update tests first when feasible.
4. Implement the smallest code change that satisfies the tests.
5. Run formatting, type checks, and tests.
6. Summarize what changed and what remains.

## Do not do yet

- Do not introduce microservices.
- Do not introduce event sourcing.
- Do not introduce machine learning bot policies.
- Do not introduce user authentication.
- Do not implement human trading UI.
- Do not make the market a static shop.

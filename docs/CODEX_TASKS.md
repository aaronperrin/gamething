# Codex PR Campaign Backlog

Use this file as the ordered campaign queue for coding agents. Codex should prefer ambitious, coherent PRs that deliver complete vertical slices or major architectural layers.

The goal is not tiny iteration. The goal is large, high-leverage implementation with tests, docs, and clear stakeholder checkpoints.

## Campaign protocol

For each campaign:

1. Read `AGENTS.md` and relevant docs.
2. State the PR goal, scope, assumptions, and affected invariants.
3. Identify stakeholder checkpoints where review is especially valuable.
4. Implement the full coherent slice, including tests and docs.
5. Run formatters, type checks, and tests with single-line Windows Command Prompt commands.
6. Update this file when the campaign is complete, split, or superseded.

## Local command policy

All command examples must be single-line Windows `cmd.exe` commands.

Examples:

```cmd
cd backend && stack test
```

```cmd
cd backend && stack build
```

Do not document Bash multiline commands or Unix line continuations.

## Tooling and search policy

Do not block a campaign solely because external search is unavailable.

If dependency or resolver freshness cannot be verified externally:

- prefer versions already pinned in the repository
- otherwise use local tooling output when available
- otherwise choose a conservative supported option and document it as an assumption
- never invent version claims

## Campaign 0: Repository scaffold

Status: mostly complete.

Goal: make the repository readable and safe for Codex.

Completed:

- [x] Add top-level README.
- [x] Add `AGENTS.md`.
- [x] Add project specification document.
- [x] Add architecture document.
- [x] Add API contract document.
- [x] Add backend scaffold directories.
- [x] Add frontend scaffold directories.
- [x] Add security, editor, and ignore files.

Remaining:

- [ ] Add initial Stack project configuration during Campaign 1.

Acceptance criteria:

- A new Codex session can identify the architecture, constraints, and first campaign without asking for context.

Stakeholder checkpoint:

- Confirm whether the repo guidance correctly encourages large, ambitious PRs with reviewable checkpoints.

## Campaign 1: Core simulation foundation

Goal: create an executable Stack backend and implement the pure domain model foundation.

This should be one ambitious PR, not many tiny PRs.

Scope:

- Create Stack Haskell project in `backend/`.
- Choose and document exact `Quantity` representation.
- Define core identifier types.
- Define `ResourceType`, `PartType`, `ItemType`, `FactoryType`, `OperatorType`.
- Define `Asset`.
- Define `Order`, `Trade`, and `Market`.
- Define `Player`, `Inventory`, `Wallet`, `BotMemory`.
- Define `Clock`, `ResourceSource`, `Factory`, `Connection`.
- Define `Event` alphabet.
- Define `Choice` and `LegalChoices` shape.
- Define `Config` and `State`.
- Add seed-world skeleton for more than two bot players.
- Add tests for exact quantity arithmetic and deterministic initial state shape.

Acceptance criteria:

- `cd backend && stack build` succeeds.
- `cd backend && stack test` succeeds.
- No `IO` imports in `Core` modules except test-only modules.
- Quantity tests prove exact addition/subtraction for values like `0.25`, `1.50`, and `3.00`.
- Initial state contains `N > 2` bot players.

Affected invariants:

- I1, I2, I3, I4, I7, I9, I13.

Stakeholder checkpoints:

- Quantity representation before market/factory math depends on it.
- Domain model shape before behavior expands.

## Campaign 2: Market, plugins, and deterministic seed economy

Goal: implement the order-based market and seeded market plugins enough for bots and resources to interact.

Scope:

- Seed RedSource, YellowSource, and BlueSource listings.
- Implement market plugin shape for basic resources, parts, and factories.
- Implement order placement validation.
- Implement bid/ask compatibility by asset.
- Implement deterministic priority: best price, earliest created tick, lowest order id.
- Implement resting-order clearing price.
- Implement partial fills.
- Emit `OrderPlaced`, `TradeExecuted`, `WalletCredited`, `WalletDebited`, and plugin listing events.
- Add deterministic replay tests for matching and plugin listing order.

Acceptance criteria:

- Compatible bid/ask orders match.
- Incompatible assets do not match.
- Partial fills update remaining quantities.
- Re-running the same market state gives the same trades in the same order.
- Market starts with RedSource, YellowSource, and BlueSource listings.

Affected invariants:

- I4, I6, I7, I12.

Stakeholder checkpoint:

- Market clearing and plugin semantics before bots depend on them.

## Campaign 3: Legal choices, bot policies, clocks, and extraction

Goal: let bot players acquire resource sources, connect clocks, and extract exact fractional resources through legal choices only.

Scope:

- Implement `visibleState`.
- Implement `legalChoices`.
- Implement `applyChoice` with legality validation.
- Implement `Wait` choice.
- Implement initial `ResourceCollectorBot`.
- Implement deterministic bot iteration order.
- Implement buying resource-source asset from market order.
- Implement `ConnectClock` choice.
- Implement explicit connection graph.
- Implement clock tick behavior.
- Implement resource extraction only through connected source.
- Emit `BotDecisionMade`, `NoOp`, `ResourcePurchased`, `ResourceConnected`, and `ResourceExtracted`.
- Add integration scenario for a bot buying, connecting, and extracting.

Acceptance criteria:

- Any bot choice applied during a tick is present in `LegalChoices`.
- Illegal choices are rejected or ignored with explicit event/error semantics.
- Same seed/config produces same bot decisions.
- A connected clock extracts exactly `0.25` resource units per tick for the default source.
- Unconnected resource sources do not extract.

Affected invariants:

- I4, I7, I8, I13, I14.

Stakeholder checkpoint:

- Bot visible-state and legal-choice model before smarter bot policies are added.

## Campaign 4: Factories, fungible items, and production loop

Goal: complete the first production economy loop from extracted resources to fungible items.

Scope:

- Define initial factory recipes.
- Implement `CanBuildFactory`.
- Implement `BuildFactory` choice.
- Support `buildTicks = 0` while preserving delayed-build model.
- Implement factory production.
- Consume input resources per output.
- Merge fungible balances by item type.
- Add simple sell-order behavior for produced items.
- Emit `FactoryBuildStarted`, `FactoryBuilt`, `FactoryProduced`, `ItemListed`, and `ItemSold` where applicable.
- Add integration scenario for `OrangeMixer` or equivalent first factory.

Acceptance criteria:

- Factory build consumes required inputs.
- Factory production consumes input resources and creates item quantity.
- Same item type balances merge.
- No item can appear unless factory-produced or seeded in a test fixture.
- Produced items can be listed into the market.

Affected invariants:

- I9, I10, I11.

Stakeholder checkpoint:

- Factory recipe and item semantics before expanding content.

## Campaign 5: Server API and in-memory app shell

Goal: expose the pure core through a local Haskell HTTP backend suitable for the inspector frontend.

Scope:

- Add minimal server dependencies.
- Define `AppEnv`.
- Implement in-memory persistence service.
- Implement safe JSON serialization for quantities.
- Implement `/api/state`.
- Implement `/api/tick`.
- Implement `/api/reset`.
- Implement `/api/market`, `/api/players`, `/api/events`.
- Implement `/api/run` with bounded tick count.
- Add API tests where practical.

Acceptance criteria:

- `cd backend && stack build` succeeds.
- Server starts locally with a documented single-line Windows command.
- API responses serialize quantities safely.
- Tick and reset endpoints mutate state only through core transitions.

Affected invariants:

- I2, I4, I5.

Stakeholder checkpoint:

- API response shape before frontend code depends on it.

## Campaign 6: Frontend inspector

Goal: provide a plain browser UI for observing and controlling the simulation.

Scope:

- Create `frontend/index.html`.
- Create `frontend/styles.css`.
- Create `frontend/src/api.js`.
- Create `frontend/src/render.js`.
- Create `frontend/src/controls.js`.
- Create `frontend/src/state.js`.
- Render current tick, bots, inventories, resources, clocks, factories, market orders, trades, events, and metrics.
- Add controls for reset, step one tick, run N ticks, and pause run.
- Add minimal smoke tests or manual verification notes.

Acceptance criteria:

- UI can inspect state and manually step ticks.
- UI does not contain authoritative simulation rules.
- Commands and run instructions are Windows Command Prompt single-line commands.

Stakeholder checkpoint:

- Frontend information architecture before the inspector grows wider.

## Campaign 7: Metrics and debugging visibility

Goal: make emergent behavior observable enough to guide product decisions.

Scope:

- Track market volume by asset.
- Track average price by asset.
- Track bid/ask spread.
- Track unsold inventory.
- Track bot wallet value.
- Track bot resource balances.
- Track factory utilization.
- Track resource extraction per tick.
- Track item production per tick.
- Track trades per tick.
- Track order fill time.
- Show metrics in API and frontend.

Acceptance criteria:

- Inspector can explain why bots are gaining or losing value.
- Simulation logs are sufficient to debug a surprising trade or production event.
- Metrics are deterministic for a given state sequence.

Stakeholder checkpoint:

- Metrics usefulness for evaluating whether interesting economic behavior is emerging.

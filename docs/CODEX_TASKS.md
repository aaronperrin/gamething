# Codex Task Backlog

Use this file as the ordered work queue for coding agents. Keep tasks small, testable, and reversible.

## Work packet protocol

For each work packet:

1. Read `AGENTS.md` and relevant docs.
2. State affected invariants.
3. Add or update tests where feasible.
4. Implement the smallest coherent change.
5. Run formatters, type checks, and tests.
6. Update this file when the packet is complete or split.

## Milestone 0: Repository scaffold

Status: in progress.

Goal: make the repository readable and safe for Codex.

Tasks:

- [x] Add top-level README.
- [x] Add `AGENTS.md`.
- [x] Add project specification document.
- [x] Add architecture document.
- [x] Add API contract document.
- [ ] Add backend scaffold.
- [ ] Add frontend scaffold.
- [ ] Add initial Stack project configuration after verifying current supported resolver.

Acceptance criteria:

- A new Codex session can identify the architecture, constraints, and first work packet without asking for context.

## Milestone 1: Pure core skeleton

Goal: define the domain model without implementing full behavior.

Tasks:

- [ ] Create Stack Haskell project in `backend/`.
- [ ] Define core identifier types.
- [ ] Define exact `Quantity` type and document representation.
- [ ] Define `ResourceType`, `PartType`, `ItemType`, `FactoryType`, `OperatorType`.
- [ ] Define `Asset`.
- [ ] Define `Order`, `Trade`, and `Market`.
- [ ] Define `Player`, `Inventory`, `Wallet`, `BotMemory`.
- [ ] Define `Clock`, `ResourceSource`, `Factory`, `Connection`.
- [ ] Define `Event` alphabet.
- [ ] Define `Choice` and `LegalChoices` shape.
- [ ] Define `Config` and `State`.

Acceptance criteria:

- Types compile.
- No `IO` imports in `Core` modules except test-only modules.
- Quantity tests prove exact addition/subtraction for values like `0.25`, `1.50`, and `3.00`.

Affected invariants:

- I2, I3, I4, I7, I9.

## Milestone 2: Deterministic seed world

Goal: build an initial world with bot players and resource-source market listings.

Tasks:

- [ ] Implement deterministic seed config.
- [ ] Ensure `N > 2` bot players.
- [ ] Seed wallets.
- [ ] Seed one simple clock per bot.
- [ ] Seed Red/Yellow/Blue resource-source listings.
- [ ] Seed basic part listings if needed for factory milestone.
- [ ] Add deterministic ordering tests.

Acceptance criteria:

- Same seed/config creates byte-equivalent or structurally equivalent initial state.
- Market starts with RedSource, YellowSource, and BlueSource listings.

Affected invariants:

- I1, I6, I7, I12, I13.

## Milestone 3: Market matching

Goal: implement deterministic compatible order matching with partial fills.

Tasks:

- [ ] Implement order placement validation.
- [ ] Implement bid/ask compatibility by asset.
- [ ] Implement deterministic priority: best price, earliest created tick, lowest order id.
- [ ] Implement resting-order clearing price.
- [ ] Implement partial fills.
- [ ] Emit `TradeExecuted`, `WalletCredited`, `WalletDebited`, and order status events.

Acceptance criteria:

- Compatible bid/ask match.
- Incompatible assets do not match.
- Partial fills update remaining quantities.
- Re-running the same market state gives the same trades in the same order.

Affected invariants:

- I4, I6, I7.

## Milestone 4: Legal choices and bot policies

Goal: ensure bots act only through legal choices.

Tasks:

- [ ] Implement `visibleState`.
- [ ] Implement `legalChoices`.
- [ ] Implement `applyChoice` with legality validation.
- [ ] Implement `Wait` choice.
- [ ] Implement initial `ResourceCollectorBot`.
- [ ] Implement deterministic bot iteration order.
- [ ] Emit `BotDecisionMade` and `NoOp` where appropriate.

Acceptance criteria:

- Any bot choice applied during a tick is present in `LegalChoices`.
- Illegal choices are rejected or ignored with explicit event/error semantics.
- Same seed/config produces same bot decisions.

Affected invariants:

- I4, I13, I14, I17-style visibility constraints from spec.

## Milestone 5: Clocks and resource extraction

Goal: bots can buy resource sources, connect clocks, and extract fractional resources.

Tasks:

- [ ] Implement buying resource-source asset from market order.
- [ ] Implement `ConnectClock` choice.
- [ ] Implement explicit connection graph.
- [ ] Implement clock tick behavior.
- [ ] Implement resource extraction only through connected source.
- [ ] Emit `ResourcePurchased`, `ResourceConnected`, and `ResourceExtracted`.

Acceptance criteria:

- A connected clock extracts exactly `0.25` resource units per tick for the default source.
- Unconnected resource sources do not extract.
- Extraction is deterministic and exact.

Affected invariants:

- I4, I7, I8.

## Milestone 6: Factories and fungible items

Goal: build and run factories that produce fungible items.

Tasks:

- [ ] Define initial factory recipes.
- [ ] Implement `CanBuildFactory`.
- [ ] Implement `BuildFactory` choice.
- [ ] Support `buildTicks = 0` while preserving delayed-build model.
- [ ] Implement factory production.
- [ ] Consume input resources per output.
- [ ] Merge fungible balances by item type.
- [ ] Emit `FactoryBuildStarted`, `FactoryBuilt`, and `FactoryProduced`.

Acceptance criteria:

- Factory build consumes required inputs.
- Factory production consumes input resources and creates item quantity.
- Same item type balances merge.
- No item can appear unless factory-produced or seeded in a test fixture.

Affected invariants:

- I9, I10, I11.

## Milestone 7: Server API

Goal: expose the pure core through an HTTP backend.

Tasks:

- [ ] Add minimal server dependencies after Stack resolver is chosen.
- [ ] Define `AppEnv`.
- [ ] Implement in-memory persistence service.
- [ ] Implement `/api/state`.
- [ ] Implement `/api/tick`.
- [ ] Implement `/api/reset`.
- [ ] Implement `/api/market`, `/api/players`, `/api/events`.
- [ ] Implement `/api/run` with bounded tick count.

Acceptance criteria:

- Server starts locally.
- API responses serialize quantities safely.
- Tick and reset endpoints mutate state only through core transitions.

Affected invariants:

- I2, I4, I5.

## Milestone 8: Frontend inspector

Goal: provide a plain browser UI for observing and controlling the simulation.

Tasks:

- [ ] Create `frontend/index.html`.
- [ ] Create `frontend/styles.css`.
- [ ] Create `frontend/src/api.js`.
- [ ] Create `frontend/src/render.js`.
- [ ] Create `frontend/src/controls.js`.
- [ ] Create `frontend/src/state.js`.
- [ ] Render current tick, bots, inventories, resources, clocks, factories, market orders, trades, events, and metrics.
- [ ] Add controls for reset, step one tick, run N ticks, and pause run.

Acceptance criteria:

- UI can inspect state and manually step ticks.
- UI does not contain authoritative simulation rules.

## Milestone 9: Metrics and debugging

Goal: make emergent behavior observable.

Tasks:

- [ ] Track market volume by asset.
- [ ] Track average price by asset.
- [ ] Track bid/ask spread.
- [ ] Track unsold inventory.
- [ ] Track bot wallet value.
- [ ] Track bot resource balances.
- [ ] Track factory utilization.
- [ ] Track resource extraction per tick.
- [ ] Track item production per tick.
- [ ] Track trades per tick.
- [ ] Track order fill time.

Acceptance criteria:

- Inspector can explain why bots are gaining/losing value.
- Simulation logs are sufficient to debug a surprising trade or production event.

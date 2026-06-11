module Core.Seed
  ( defaultConfig
  , seedState
  , seedPlayers
  , seedResourceSources
  , seedClocks
  , seedMarket
  ) where

import Core.Quantity (Quantity, fromParts)
import Core.Types
  ( Asset (ResourceSourceAsset)
  , BotMemory (..)
  , Clock (..)
  , ClockId (..)
  , ClockStatus (ClockRunning)
  , Config (..)
  , Controller (BotController)
  , Inventory (..)
  , Market (..)
  , Order (..)
  , OrderId (..)
  , OrderSide (Sell)
  , OrderStatus (Open)
  , Player (..)
  , PlayerId (..)
  , ResourceSource (..)
  , ResourceSourceId (..)
  , ResourceType (..)
  , State (..)
  , Tick (Tick)
  , TradeId (TradeId)
  , Wallet (..)
  , emptyInventory
  )
import Data.Map.Strict (Map)
import qualified Data.Map.Strict as Map

-- | Default config for the first deterministic foundation.
--
-- Stakeholder checkpoint: this intentionally seeds only bots, clocks, resource
-- sources, and market source listings. It does not yet assign owned sources or
-- implement behavior.
defaultConfig :: Config
defaultConfig =
  Config
    { configPlayerCount = 3
    , configInitialWallet = credits 100
    , configDefaultClockRate = fromParts 1 1
    , configDefaultExtractionRate = fromParts 1 4
    , configInitialSourceListingsPerType = 10
    , configInitialSourcePrice = credits 10
    }

seedState :: Config -> State
seedState config =
  State
    { stateTick = Tick 0
    , statePlayers = seedPlayers config
    , stateMarket = seedMarket config
    , stateResourceSources = seedResourceSources config
    , stateFactories = mempty
    , stateClocks = seedClocks config
    , stateConnections = mempty
    , stateEvents = []
    , stateTerminal = False
    }

seedPlayers :: Config -> Map PlayerId Player
seedPlayers config =
  Map.fromList
    [ (pid, seedPlayer config pid)
    | playerNumber <- [1 .. max 3 (configPlayerCount config)]
    , let pid = PlayerId playerNumber
    ]

seedPlayer :: Config -> PlayerId -> Player
seedPlayer config pid =
  Player
    { playerId = pid
    , playerController = BotController
    , playerWallet = Wallet (configInitialWallet config)
    , playerInventory = emptyInventory
    , playerInstalledOperators = []
    , playerOwnedResources = []
    , playerOwnedFactories = []
    , playerOpenOrders = []
    , playerMemory = emptyBotMemory
    }

emptyBotMemory :: BotMemory
emptyBotMemory =
  BotMemory
    { memoryObservedPrices = mempty
    , memoryAttemptedBuilds = []
    , memoryProfitableItems = []
    , memoryFailedItems = []
    }

seedClocks :: Config -> Map ClockId Clock
seedClocks config =
  Map.fromList
    [ (cid, Clock cid pid (configDefaultClockRate config) [] ClockRunning)
    | PlayerId playerNumber <- Map.keys (seedPlayers config)
    , let pid = PlayerId playerNumber
    , let cid = ClockId playerNumber
    ]

seedResourceSources :: Config -> Map ResourceSourceId ResourceSource
seedResourceSources config =
  Map.fromList
    [ (rid, ResourceSource rid Nothing resourceType (configDefaultExtractionRate config))
    | (resourceType, offset) <- resourceTypeOffsets
    , sourceNumber <- [1 .. configInitialSourceListingsPerType config]
    , let rid = ResourceSourceId (offset + sourceNumber)
    ]

seedMarket :: Config -> Market
seedMarket config =
  let orders = seedSourceOrders config
   in Market
        { marketOrders = orders
        , marketTrades = mempty
        , marketInventory = initialMarketInventory config
        , marketNextOrderId = OrderId (Map.size orders + 1)
        , marketNextTradeId = TradeId 1
        }

seedSourceOrders :: Config -> Map OrderId Order
seedSourceOrders config =
  Map.fromList
    [ (oid, seedSourceOrder config oid resourceType)
    | (resourceType, offset) <- resourceTypeOffsets
    , listingNumber <- [1 .. configInitialSourceListingsPerType config]
    , let oid = OrderId (offset + listingNumber)
    ]

seedSourceOrder :: Config -> OrderId -> ResourceType -> Order
seedSourceOrder config oid resourceType =
  Order
    { orderId = oid
    , orderOwner = Nothing
    , orderSide = Sell
    , orderAsset = ResourceSourceAsset resourceType
    , orderQuantity = fromParts 1 1
    , orderRemaining = fromParts 1 1
    , orderLimitPrice = configInitialSourcePrice config
    , orderStatus = Open
    , orderCreatedTick = Tick 0
    }

initialMarketInventory :: Config -> Map Asset Quantity
initialMarketInventory config =
  Map.fromList
    [ (ResourceSourceAsset resourceType, fromParts (toInteger (configInitialSourceListingsPerType config)) 1)
    | (resourceType, _) <- resourceTypeOffsets
    ]

resourceTypeOffsets :: [(ResourceType, Int)]
resourceTypeOffsets =
  [ (Red, 0)
  , (Yellow, 1000)
  , (Blue, 2000)
  ]

credits :: Integer -> Quantity
credits amount = fromParts amount 1

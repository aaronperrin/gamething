module Core.Types
  ( Asset (..)
  , BotMemory (..)
  , Choice (..)
  , Clock (..)
  , ClockId (..)
  , ClockStatus (..)
  , Config (..)
  , Connection (..)
  , ConnectionId (..)
  , ConnectionTarget (..)
  , ConnectionType (..)
  , Controller (..)
  , Event (..)
  , Factory (..)
  , FactoryId (..)
  , FactoryRecipe (..)
  , FactoryType (..)
  , Inventory (..)
  , ItemType (..)
  , LegalChoices (..)
  , Market (..)
  , OperatorType (..)
  , Order (..)
  , OrderId (..)
  , OrderSide (..)
  , OrderStatus (..)
  , PartType (..)
  , Player (..)
  , PlayerId (..)
  , ResourceSource (..)
  , ResourceSourceId (..)
  , ResourceType (..)
  , State (..)
  , Tick (..)
  , Trade (..)
  , TradeId (..)
  , Wallet (..)
  , emptyInventory
  , emptyMarket
  , emptyWallet
  ) where

import Core.Quantity (Quantity)
import Data.Map.Strict (Map)

newtype Tick = Tick Int
  deriving stock (Eq, Ord, Show)

newtype PlayerId = PlayerId Int
  deriving stock (Eq, Ord, Show)

newtype ClockId = ClockId Int
  deriving stock (Eq, Ord, Show)

newtype ResourceSourceId = ResourceSourceId Int
  deriving stock (Eq, Ord, Show)

newtype FactoryId = FactoryId Int
  deriving stock (Eq, Ord, Show)

newtype OrderId = OrderId Int
  deriving stock (Eq, Ord, Show)

newtype TradeId = TradeId Int
  deriving stock (Eq, Ord, Show)

newtype ConnectionId = ConnectionId Int
  deriving stock (Eq, Ord, Show)

data ResourceType
  = Red
  | Yellow
  | Blue
  deriving stock (Eq, Ord, Show, Enum, Bounded)

data PartType
  = Frame
  | Gear
  | Lens
  | Valve
  | Circuit
  deriving stock (Eq, Ord, Show, Enum, Bounded)

data ItemType
  = OrangeUnit
  | GreenUnit
  | PurpleUnit
  | WhiteUnit
  deriving stock (Eq, Ord, Show, Enum, Bounded)

data FactoryType
  = RedRefiner
  | YellowRefiner
  | BlueRefiner
  | OrangeMixer
  | GreenMixer
  | PurpleMixer
  deriving stock (Eq, Ord, Show, Enum, Bounded)

data OperatorType
  = ClockOperator
  | ExtractorOperator
  | FactoryOperator
  | MarketAdapterOperator
  | BotExperimenterOperator
  | SignalOperator
  | TransformerOperator
  | SchedulerOperator
  deriving stock (Eq, Ord, Show, Enum, Bounded)

data Asset
  = ResourceAsset ResourceType
  | ResourceSourceAsset ResourceType
  | PartAsset PartType
  | FungibleItemAsset ItemType
  | FactoryAsset FactoryType
  | OperatorAsset OperatorType
  deriving stock (Eq, Ord, Show)

data OrderSide
  = Buy
  | Sell
  deriving stock (Eq, Ord, Show)

data OrderStatus
  = Open
  | PartiallyFilled
  | Filled
  | Cancelled
  deriving stock (Eq, Ord, Show)

data Controller
  = BotController
  deriving stock (Eq, Ord, Show)

data ClockStatus
  = ClockRunning
  | ClockStopped
  deriving stock (Eq, Ord, Show)

data ConnectionType
  = ExtractionConnection
  | ProductionConnection
  deriving stock (Eq, Ord, Show)

data ConnectionTarget
  = ResourceSourceTarget ResourceSourceId
  | FactoryTarget FactoryId
  deriving stock (Eq, Ord, Show)

data Inventory = Inventory
  { inventoryResources :: Map ResourceType Quantity
  , inventoryParts :: Map PartType Quantity
  , inventoryItems :: Map ItemType Quantity
  }
  deriving stock (Eq, Show)

data Wallet = Wallet
  { walletCredits :: Quantity
  }
  deriving stock (Eq, Show)

data BotMemory = BotMemory
  { memoryObservedPrices :: Map Asset [Quantity]
  , memoryAttemptedBuilds :: [FactoryType]
  , memoryProfitableItems :: [ItemType]
  , memoryFailedItems :: [ItemType]
  }
  deriving stock (Eq, Show)

data Player = Player
  { playerId :: PlayerId
  , playerController :: Controller
  , playerWallet :: Wallet
  , playerInventory :: Inventory
  , playerInstalledOperators :: [OperatorType]
  , playerOwnedResources :: [ResourceSourceId]
  , playerOwnedFactories :: [FactoryId]
  , playerOpenOrders :: [OrderId]
  , playerMemory :: BotMemory
  }
  deriving stock (Eq, Show)

data ResourceSource = ResourceSource
  { resourceSourceId :: ResourceSourceId
  , resourceSourceOwner :: Maybe PlayerId
  , resourceSourceType :: ResourceType
  , resourceSourceExtractionRate :: Quantity
  }
  deriving stock (Eq, Show)

data Clock = Clock
  { clockId :: ClockId
  , clockOwner :: PlayerId
  , clockRate :: Quantity
  , clockConnections :: [ConnectionId]
  , clockStatus :: ClockStatus
  }
  deriving stock (Eq, Show)

data Connection = Connection
  { connectionId :: ConnectionId
  , connectionFromClock :: ClockId
  , connectionTarget :: ConnectionTarget
  , connectionType :: ConnectionType
  }
  deriving stock (Eq, Show)

data FactoryRecipe = FactoryRecipe
  { recipeFactoryType :: FactoryType
  , recipeRequiredResources :: Map ResourceType Quantity
  , recipeRequiredParts :: Map PartType Quantity
  , recipeBuildTicks :: Int
  , recipeOutputItem :: ItemType
  , recipeOutputRate :: Quantity
  , recipeInputPerOutput :: Map ResourceType Quantity
  }
  deriving stock (Eq, Show)

data Factory = Factory
  { factoryId :: FactoryId
  , factoryOwner :: PlayerId
  , factoryType :: FactoryType
  , factoryRecipe :: FactoryRecipe
  , factoryRemainingBuildTicks :: Int
  }
  deriving stock (Eq, Show)

data Order = Order
  { orderId :: OrderId
  , orderOwner :: Maybe PlayerId
  , orderSide :: OrderSide
  , orderAsset :: Asset
  , orderQuantity :: Quantity
  , orderRemaining :: Quantity
  , orderLimitPrice :: Quantity
  , orderStatus :: OrderStatus
  , orderCreatedTick :: Tick
  }
  deriving stock (Eq, Show)

data Trade = Trade
  { tradeId :: TradeId
  , tradeBuyOrder :: OrderId
  , tradeSellOrder :: OrderId
  , tradeAsset :: Asset
  , tradeQuantity :: Quantity
  , tradePrice :: Quantity
  , tradeTick :: Tick
  }
  deriving stock (Eq, Show)

data Market = Market
  { marketOrders :: Map OrderId Order
  , marketTrades :: Map TradeId Trade
  , marketInventory :: Map Asset Quantity
  , marketNextOrderId :: OrderId
  , marketNextTradeId :: TradeId
  }
  deriving stock (Eq, Show)

data Event
  = TickStarted Tick
  | OrderPlaced OrderId
  | OrderCancelled OrderId
  | TradeExecuted TradeId
  | ResourcePurchased PlayerId ResourceSourceId
  | ResourceConnected PlayerId ClockId ResourceSourceId
  | ResourceExtracted PlayerId ResourceType Quantity
  | PartPurchased PlayerId PartType Quantity
  | FactoryBuildStarted PlayerId FactoryType
  | FactoryBuilt PlayerId FactoryId
  | FactoryProduced PlayerId FactoryId ItemType Quantity
  | ItemListed PlayerId ItemType Quantity
  | ItemSold PlayerId ItemType Quantity
  | WalletCredited PlayerId Quantity
  | WalletDebited PlayerId Quantity
  | BotDecisionMade PlayerId Choice
  | MarketPluginListed String OrderId
  | NoOp PlayerId
  deriving stock (Eq, Show)

data Choice
  = BuyAsset OrderId Quantity
  | PlaceAsk Asset Quantity Quantity
  | PlaceBid Asset Quantity Quantity
  | CancelOrder OrderId
  | ConnectClock ClockId ResourceSourceId
  | BuildFactory FactoryType
  | RunFactory FactoryId
  | Wait
  deriving stock (Eq, Ord, Show)

newtype LegalChoices = LegalChoices
  { unLegalChoices :: [Choice]
  }
  deriving stock (Eq, Show)

data Config = Config
  { configPlayerCount :: Int
  , configInitialWallet :: Quantity
  , configDefaultClockRate :: Quantity
  , configDefaultExtractionRate :: Quantity
  , configInitialSourceListingsPerType :: Int
  , configInitialSourcePrice :: Quantity
  }
  deriving stock (Eq, Show)

data State = State
  { stateTick :: Tick
  , statePlayers :: Map PlayerId Player
  , stateMarket :: Market
  , stateResourceSources :: Map ResourceSourceId ResourceSource
  , stateFactories :: Map FactoryId Factory
  , stateClocks :: Map ClockId Clock
  , stateConnections :: Map ConnectionId Connection
  , stateEvents :: [Event]
  , stateTerminal :: Bool
  }
  deriving stock (Eq, Show)

emptyInventory :: Inventory
emptyInventory = Inventory mempty mempty mempty

emptyWallet :: Wallet
emptyWallet = Wallet Core.Quantity.zero

emptyMarket :: Market
emptyMarket = Market mempty mempty mempty (OrderId 1) (TradeId 1)

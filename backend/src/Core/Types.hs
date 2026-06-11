module Core.Types
  ( Asset (..)
  , BotMemory (..)
  , Choice (..)
  , Clock (..)
  , ClockId (..)
  , ClockStatus (..)
  , Config (..)
  , Controller (..)
  , Event (..)
  , FactoryId (..)
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
  , TradeId (..)
  , Wallet (..)
  , emptyInventory
  , emptyMarket
  ) where

import Core.Quantity (Quantity)
import qualified Core.Quantity as Quantity
import Data.Map.Strict (Map)

newtype Tick = Tick Int deriving stock (Eq, Ord, Show)
newtype PlayerId = PlayerId Int deriving stock (Eq, Ord, Show)
newtype ClockId = ClockId Int deriving stock (Eq, Ord, Show)
newtype ResourceSourceId = ResourceSourceId Int deriving stock (Eq, Ord, Show)
newtype FactoryId = FactoryId Int deriving stock (Eq, Ord, Show)
newtype OrderId = OrderId Int deriving stock (Eq, Ord, Show)
newtype TradeId = TradeId Int deriving stock (Eq, Ord, Show)

data ResourceType = Red | Yellow | Blue deriving stock (Eq, Ord, Show, Enum, Bounded)
data PartType = Frame | Gear | Lens | Valve | Circuit deriving stock (Eq, Ord, Show, Enum, Bounded)
data ItemType = OrangeUnit | GreenUnit | PurpleUnit | WhiteUnit deriving stock (Eq, Ord, Show, Enum, Bounded)
data FactoryType = RedRefiner | YellowRefiner | BlueRefiner | OrangeMixer | GreenMixer | PurpleMixer deriving stock (Eq, Ord, Show, Enum, Bounded)
data OperatorType = ClockOperator | ExtractorOperator | FactoryOperator | MarketAdapterOperator | BotExperimenterOperator | SignalOperator | TransformerOperator | SchedulerOperator deriving stock (Eq, Ord, Show, Enum, Bounded)

data Asset
  = ResourceAsset ResourceType
  | ResourceSourceAsset ResourceType
  | PartAsset PartType
  | FungibleItemAsset ItemType
  | FactoryAsset FactoryType
  | OperatorAsset OperatorType
  deriving stock (Eq, Ord, Show)

data OrderSide = Buy | Sell deriving stock (Eq, Ord, Show)
data OrderStatus = Open | PartiallyFilled | Filled | Cancelled deriving stock (Eq, Ord, Show)
data Controller = BotController deriving stock (Eq, Ord, Show)
data ClockStatus = ClockRunning | ClockStopped deriving stock (Eq, Ord, Show)

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
  , clockConnections :: [ResourceSourceId]
  , clockStatus :: ClockStatus
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

data Market = Market
  { marketOrders :: Map OrderId Order
  , marketInventory :: Map Asset Quantity
  , marketNextOrderId :: OrderId
  , marketNextTradeId :: TradeId
  }
  deriving stock (Eq, Show)

data Event
  = TickStarted Tick
  | OrderPlaced OrderId
  | ResourcePurchased PlayerId ResourceSourceId
  | ResourceConnected PlayerId ClockId ResourceSourceId
  | ResourceExtracted PlayerId ResourceType Quantity
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
  | Wait
  deriving stock (Eq, Ord, Show)

newtype LegalChoices = LegalChoices { unLegalChoices :: [Choice] } deriving stock (Eq, Show)

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
  , stateClocks :: Map ClockId Clock
  , stateEvents :: [Event]
  , stateTerminal :: Bool
  }
  deriving stock (Eq, Show)

emptyInventory :: Inventory
emptyInventory = Inventory mempty mempty mempty

emptyMarket :: Market
emptyMarket = Market mempty mempty (OrderId 1) (TradeId 1)

_unusedQuantityZero :: Quantity
_unusedQuantityZero = Quantity.zero

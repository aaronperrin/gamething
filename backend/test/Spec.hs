module Main (main) where

import Core.Quantity
  ( Quantity
  , add
  , denominator
  , fromParts
  , numerator
  , quantity
  , renderQuantity
  , subtractQuantity
  )
import Core.Seed (defaultConfig, seedState)
import Core.Types
  ( Asset (ResourceSourceAsset)
  , Config (..)
  , Market (..)
  , Order (..)
  , OrderSide (Sell)
  , OrderStatus (Open)
  , Player (..)
  , ResourceType (Blue, Red, Yellow)
  , State (..)
  , Wallet (..)
  )
import qualified Data.Map.Strict as Map
import System.Exit (exitFailure, exitSuccess)

main :: IO ()
main = do
  results <- sequence tests
  if and results
    then exitSuccess
    else exitFailure

tests :: [IO Bool]
tests =
  [ test "quantity keeps one quarter exact" $ do
      let q = fromParts 1 4
      assertEqual "numerator" 1 (numerator q)
      assertEqual "denominator" 4 (denominator q)
  , test "quantity adds decimal-like values exactly" $ do
      let q025 = fromParts 1 4
      let q150 = fromParts 3 2
      assertEqual "0.25 + 1.50" (fromParts 7 4) (add q025 q150)
  , test "quantity subtracts without going negative" $ do
      assertEqual "3 - 1.5" (Just (fromParts 3 2)) (subtractQuantity (fromParts 3 1) (fromParts 3 2))
      assertEqual "1.5 - 3 rejected" Nothing (subtractQuantity (fromParts 3 2) (fromParts 3 1))
  , test "invalid quantity denominator is rejected" $ do
      assertEqual "zero denominator" Nothing (quantity 1 0)
  , test "seed state is deterministic" $ do
      assertEqual "same seed" (seedState defaultConfig) (seedState defaultConfig)
  , test "seed state always has more than two players" $ do
      let config = defaultConfig { configPlayerCount = 1 }
      assertBool "player count > 2" (Map.size (statePlayers (seedState config)) > 2)
  , test "seed players are bot-controlled with initial wallets" $ do
      let state = seedState defaultConfig
      assertBool "all wallets seeded" (all hasInitialWallet (Map.elems (statePlayers state)))
  , test "seed market has red yellow and blue source listings" $ do
      let orders = Map.elems (marketOrders (stateMarket (seedState defaultConfig)))
      assertBool "red listed" (hasSourceListing Red orders)
      assertBool "yellow listed" (hasSourceListing Yellow orders)
      assertBool "blue listed" (hasSourceListing Blue orders)
  , test "source listing quantities are exact units" $ do
      let orders = Map.elems (marketOrders (stateMarket (seedState defaultConfig)))
      assertBool "all one unit" (all ((== fromParts 1 1) . orderQuantity) orders)
  , test "render quantity is stable for review output" $ do
      assertEqual "render 1/4" "1/4" (renderQuantity (fromParts 1 4))
  ]

hasInitialWallet :: Player -> Bool
hasInitialWallet player = walletCredits (playerWallet player) == configInitialWallet defaultConfig

hasSourceListing :: ResourceType -> [Order] -> Bool
hasSourceListing resourceType =
  any
    ( \order ->
        orderSide order == Sell
          && orderStatus order == Open
          && orderAsset order == ResourceSourceAsset resourceType
    )

test :: String -> IO () -> IO Bool
test name action = do
  result <- tryTest action
  case result of
    Right () -> do
      putStrLn ("PASS " <> name)
      pure True
    Left message -> do
      putStrLn ("FAIL " <> name <> ": " <> message)
      pure False

tryTest :: IO () -> IO (Either String ())
tryTest action = (Right <$> action) `catchAny` (pure . Left)

catchAny :: IO a -> (String -> IO a) -> IO a
catchAny action handler = do
  actionResult <- Control.Exception.try action
  case actionResult of
    Right value -> pure value
    Left (err :: Control.Exception.SomeException) -> handler (show err)

assertEqual :: (Eq a, Show a) => String -> a -> a -> IO ()
assertEqual label expected actual =
  if expected == actual
    then pure ()
    else error (label <> ": expected " <> show expected <> ", got " <> show actual)

assertBool :: String -> Bool -> IO ()
assertBool label value =
  if value
    then pure ()
    else error label

import qualified Control.Exception

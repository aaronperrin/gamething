module Main (main) where

import Core.Quantity
  ( add
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

main :: IO ()
main = do
  quantityTests
  seedTests
  putStrLn "All foundation tests passed."

quantityTests :: IO ()
quantityTests = do
  let q = fromParts 1 4
  assertEqual "quarter numerator" 1 (numerator q)
  assertEqual "quarter denominator" 4 (denominator q)
  assertEqual "0.25 + 1.50" (fromParts 7 4) (add (fromParts 1 4) (fromParts 3 2))
  assertEqual "3.00 - 1.50" (Just (fromParts 3 2)) (subtractQuantity (fromParts 3 1) (fromParts 3 2))
  assertEqual "negative quantities rejected" Nothing (subtractQuantity (fromParts 3 2) (fromParts 3 1))
  assertEqual "zero denominator rejected" Nothing (quantity 1 0)
  assertEqual "stable rendering" "1/4" (renderQuantity (fromParts 1 4))

seedTests :: IO ()
seedTests = do
  let state = seedState defaultConfig
  assertEqual "same seed" state (seedState defaultConfig)
  assertBool "player count > 2" (Map.size (statePlayers (seedState defaultConfig { configPlayerCount = 1 })) > 2)
  assertBool "all wallets seeded" (all hasInitialWallet (Map.elems (statePlayers state)))
  let orders = Map.elems (marketOrders (stateMarket state))
  assertBool "red source listed" (hasSourceListing Red orders)
  assertBool "yellow source listed" (hasSourceListing Yellow orders)
  assertBool "blue source listed" (hasSourceListing Blue orders)
  assertBool "source listings are one exact unit" (all ((== fromParts 1 1) . orderQuantity) orders)

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

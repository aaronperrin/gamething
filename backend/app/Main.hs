module Main (main) where

import Core.Seed (defaultConfig, seedState)
import Core.Types (stateTick)

main :: IO ()
main = do
  let initialState = seedState defaultConfig
  putStrLn "gamething backend foundation"
  putStrLn ("seed tick: " <> show (stateTick initialState))

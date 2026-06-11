module Core.Quantity
  ( Quantity
  , quantity
  , zero
  , one
  , fromIntegerQuantity
  , fromParts
  , numerator
  , denominator
  , add
  , subtractQuantity
  , multiply
  , lessThan
  , greaterThan
  , isZero
  , isPositive
  , renderQuantity
  ) where

import Prelude hiding (subtract)

newtype Quantity = Quantity Rational
  deriving stock (Eq, Ord)

instance Show Quantity where
  show = renderQuantity

quantity :: Integer -> Integer -> Maybe Quantity
quantity n d
  | d <= 0 = Nothing
  | n < 0 = Nothing
  | otherwise = Just (Quantity (n % d))

zero :: Quantity
zero = Quantity 0

one :: Quantity
one = Quantity 1

fromIntegerQuantity :: Integer -> Maybe Quantity
fromIntegerQuantity n = quantity n 1

fromParts :: Integer -> Integer -> Quantity
fromParts n d =
  case quantity n d of
    Just q -> q
    Nothing -> error "invalid non-negative quantity literal"

numerator :: Quantity -> Integer
numerator (Quantity value) = Data.Ratio.numerator value

denominator :: Quantity -> Integer
denominator (Quantity value) = Data.Ratio.denominator value

add :: Quantity -> Quantity -> Quantity
add (Quantity a) (Quantity b) = Quantity (a + b)

subtractQuantity :: Quantity -> Quantity -> Maybe Quantity
subtractQuantity (Quantity a) (Quantity b)
  | a < b = Nothing
  | otherwise = Just (Quantity (a - b))

multiply :: Quantity -> Quantity -> Quantity
multiply (Quantity a) (Quantity b) = Quantity (a * b)

lessThan :: Quantity -> Quantity -> Bool
lessThan = (<)

greaterThan :: Quantity -> Quantity -> Bool
greaterThan = (>)

isZero :: Quantity -> Bool
isZero (Quantity value) = value == 0

isPositive :: Quantity -> Bool
isPositive (Quantity value) = value > 0

renderQuantity :: Quantity -> String
renderQuantity q
  | denominator q == 1 = show (numerator q)
  | otherwise = show (numerator q) <> "/" <> show (denominator q)

infixl 7 %

(%) :: Integer -> Integer -> Rational
(%) = (Data.Ratio.%)

import qualified Data.Ratio

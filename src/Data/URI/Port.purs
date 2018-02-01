module Data.URI.Port
  ( Port(..)
  , parser
  , print
  ) where

import Prelude

import Data.Array as Array
import Data.Either (Either)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Int (fromNumber)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.String as String
import Data.URI.Common (wrapParser)
import Global (readInt)
import Text.Parsing.StringParser (ParseError, Parser, fail)
import Text.Parsing.StringParser.String (anyDigit)

-- | A port number.
newtype Port = Port Int

derive newtype instance eqPort ∷ Eq Port
derive newtype instance ordPort ∷ Ord Port
derive instance genericPort ∷ Generic Port _
derive instance newtypePort ∷ Newtype Port _
instance showPort ∷ Show Port where show = genericShow

parser ∷ ∀ p. (Port → Either ParseError p) → Parser p
parser p = wrapParser p do
  s ← String.fromCharArray <$> Array.some anyDigit
  case fromNumber $ readInt 10 s of
    Just x → pure (Port x)
    _ → fail "Expected valid port number"

print ∷ ∀ p. (p → Port) → p → String
print = map (\(Port x) → show x)

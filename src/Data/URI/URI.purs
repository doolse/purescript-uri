module Data.URI.URI
  ( URI(..)
  , URIOptions
  , URIParseOptions
  , URIPrintOptions
  , parser
  , print
  , _scheme
  , _hierPart
  , _query
  , _fragment
  , module Data.URI.HierarchicalPart
  , module Data.URI.Scheme
  ) where

import Prelude

import Data.Array as Array
import Data.Either (Either)
import Data.Eq (class Eq1)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Lens (Lens', lens)
import Data.Maybe (Maybe(..))
import Data.Ord (class Ord1)
import Data.String as String
import Data.Tuple (Tuple)
import Data.URI.Fragment (Fragment)
import Data.URI.Fragment as Fragment
import Data.URI.HierarchicalPart (Authority(..), HierarchicalPart(..), Host(..), Port(..), UserInfo, _IPv4Address, _IPv6Address, _NameAddress, _authority, _hosts, _path, _userInfo)
import Data.URI.HierarchicalPart as HPart
import Data.URI.Query as Query
import Data.URI.Scheme (Scheme(..))
import Data.URI.Scheme as Scheme
import Text.Parsing.StringParser (ParseError, Parser)
import Text.Parsing.StringParser.Combinators (optionMaybe)
import Text.Parsing.StringParser.String (eof)

-- | A generic URI
data URI userInfo hosts host port hierPath query fragment = URI Scheme (HierarchicalPart userInfo hosts host port hierPath) (Maybe query) (Maybe fragment)

derive instance eqURI ∷ (Eq userInfo, Eq1 hosts, Eq host, Eq port, Eq hierPath, Eq query, Eq fragment) ⇒ Eq (URI userInfo hosts host port hierPath query fragment)
derive instance ordURI ∷ (Ord userInfo, Ord1 hosts, Ord host, Ord port, Ord hierPath, Ord query, Ord fragment) ⇒ Ord (URI userInfo hosts host port hierPath query fragment)
derive instance genericURI ∷ Generic (URI userInfo hosts host port hierPath query fragment) _
instance showURI ∷ (Show userInfo, Show (hosts (Tuple host (Maybe port))), Show host, Show port, Show hierPath, Show query, Show fragment) ⇒ Show (URI userInfo hosts host port hierPath query fragment) where show = genericShow

type URIOptions userInfo hosts host port hierPath query fragment =
  URIParseOptions userInfo hosts host port hierPath query fragment
    (URIPrintOptions userInfo hosts host port hierPath query fragment ())

type URIParseOptions userInfo hosts host port hierPath query fragment r =
  ( parseUserInfo ∷ UserInfo → Either ParseError userInfo
  , parseHosts ∷ ∀ a. Parser a → Parser (hosts a)
  , parseHost ∷ Host → Either ParseError host
  , parsePort ∷ Port → Either ParseError port
  , parseHierPath ∷ String → Either ParseError hierPath
  , parseQuery ∷ String → Either ParseError query
  , parseFragment ∷ Fragment → Either ParseError fragment
  | r
  )

type URIPrintOptions userInfo hosts host port hierPath query fragment r =
  ( printUserInfo ∷ userInfo → UserInfo
  , printHosts ∷ hosts String → String
  , printHost ∷ host → Host
  , printPort ∷ port → Port
  , printHierPath ∷ hierPath → String
  , printQuery ∷ query → String
  , printFragment ∷ fragment → Fragment
  | r
  )

parser
  ∷ ∀ userInfo hosts host port hierPath query fragment r
  . Record (URIParseOptions userInfo hosts host port hierPath query fragment r)
  → Parser (URI userInfo hosts host port hierPath query fragment)
parser opts = URI
  <$> Scheme.parser
  <*> HPart.parser opts
  <*> optionMaybe (Query.parser opts.parseQuery)
  <*> optionMaybe (Fragment.parser opts.parseFragment)
  <* eof

print
  ∷ ∀ userInfo hosts host port hierPath query fragment r
  . Functor hosts
  ⇒ Record (URIPrintOptions userInfo hosts host port hierPath query fragment r)
  → URI userInfo hosts host port hierPath query fragment
  → String
print opts (URI s h q f) =
  String.joinWith "" $ Array.catMaybes
    [ Just (Scheme.print s)
    , Just (HPart.print opts h)
    , Query.print opts.printQuery <$> q
    , Fragment.print opts.printFragment <$> f
    ]

_scheme
  ∷ ∀ userInfo hosts host port hierPath query fragment
  . Lens'
      (URI userInfo hosts host port hierPath query fragment)
      Scheme
_scheme =
  lens
    (\(URI s _ _ _) → s)
    (\(URI _ h q f) s → URI s h q f)

_hierPart
  ∷ ∀ userInfo hosts host port hierPath query fragment
  . Lens'
      (URI userInfo hosts host port hierPath query fragment)
      (HierarchicalPart userInfo hosts host port hierPath)
_hierPart =
  lens
    (\(URI _ h _ _) → h)
    (\(URI s _ q f) h → URI s h q f)

_query
  ∷ ∀ userInfo hosts host port hierPath query fragment
  . Lens'
      (URI userInfo hosts host port hierPath query fragment)
      (Maybe query)
_query =
  lens
    (\(URI _ _ q _) → q)
    (\(URI s h _ f) q → URI s h q f)

_fragment
  ∷ ∀ userInfo hosts host port hierPath query fragment
  . Lens'
      (URI userInfo hosts host port hierPath query fragment)
      (Maybe fragment)
_fragment =
  lens
    (\(URI _ _ _ f) → f)
    (\(URI s h q _) f → URI s h q f)

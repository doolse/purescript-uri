module Test.Main where

import Prelude

import Control.Monad.Aff.AVar (AVAR)
import Control.Monad.Eff (Eff)
import Test.Spec.Reporter (consoleReporter)
import Test.Spec.Runner (PROCESS, run)
import Test.URI.AbsoluteURI as AbsoluteURI
import Test.URI.Authority as Authority
import Test.URI.Fragment as Fragment
import Test.URI.Host as Host
import Test.URI.Extra.QueryPairs as Extra.QueryPairs
import Test.URI.Extra.MultiHostPortPair as Extra.MultiHostPortPair
import Test.URI.Extra.UserPassInfo as Extra.UserPassInfo
import Test.URI.Path as Path
import Test.URI.Port as Port
import Test.URI.Scheme as Scheme
import Test.URI.URIRef as URIRef
import Test.URI.UserInfo as UserInfo
import Test.Util (TestEffects)

main ∷ Eff (TestEffects (avar ∷ AVAR, process ∷ PROCESS)) Unit
main = run [consoleReporter] do
  Scheme.spec
  UserInfo.spec
  Host.spec
  Port.spec
  Fragment.spec
  Authority.spec
  Path.spec
  URIRef.spec
  AbsoluteURI.spec
  Extra.QueryPairs.spec
  Extra.MultiHostPortPair.spec
  Extra.UserPassInfo.spec

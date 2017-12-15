module Model exposing (Model, Repo)

import Http exposing (..)
import Dict exposing (..)
import Navigation exposing (Location)

type alias Repo = String

type alias Model =
    { dependencies : Maybe (Result String (Dict Repo Bool))
    , fileName : Maybe (Result String String)
    , location : Location
    }

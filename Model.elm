module Model exposing (Model, Repo)

import Http exposing (..)
import Dict exposing (..)
import Navigation exposing (Location)


type alias Repo =
    String


type alias Model =
    { projectData : Maybe (Result String (String, Dict Repo Bool))
    , location : Location
    , errorMessage : Maybe String
    }

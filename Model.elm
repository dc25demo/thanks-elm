module Model exposing (Model, Repo)

import Http exposing (..)
import Dict exposing (..)
import Navigation exposing (Location)


type alias Repo = String

type alias StarredRepos = Dict Repo Bool

type alias FileName = String


type alias Model =
    { projectData : Maybe (Result String (FileName, StarredRepos))
    , location : Location
    }

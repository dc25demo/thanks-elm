module Model exposing (Model, StarredRepos)


import Http exposing (..)
import Dict exposing (..)
import Navigation exposing (Location)


type alias StarredRepos = Dict (String, String) Bool 

type alias FileName = String


type alias Model =
    { projectData : Maybe (Result String (FileName, StarredRepos))
    , location : Location
    }

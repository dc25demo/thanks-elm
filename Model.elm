module Model exposing (Model, StarredRepos)


import Http exposing (..)
import Dict exposing (..)
import Navigation exposing (Location)


type alias StarredRepos = Dict (String, String) Bool 

type alias FileName = String


type alias Model =
    { 
      -- name and starred repos are read from url query parameters
      -- in redirect from github.com and displayed by view function.
      projectData : Maybe (Result String (FileName, StarredRepos))

      -- location is url data that is read by init function and used
      -- by update function when making requests to github.com
    , location : Location
    }

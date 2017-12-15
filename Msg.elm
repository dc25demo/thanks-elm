module Msg exposing (..)
import Ports exposing (FileLoadedData)
import Http exposing (Error)
import Navigation exposing (..)

type Msg
    = FileSelected
    | FileLoaded FileLoadedData
    | UrlChange Navigation.Location
    | GetAuthorization (Result Error String)



module Msg exposing (..)

import Ports exposing (FileLoadedData)
import Http exposing (Error)
import Navigation exposing (Location)


type Msg
    = FileSelected
    | FileLoaded FileLoadedData
    | Authorized (Result Error String)
    | StarSet String (Result Error String)
    | UrlChange Location

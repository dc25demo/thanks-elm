module Msg exposing (..)
import Ports exposing (FileLoadedData)
import Http exposing (Error)

type Msg
    = FileSelected
    | FileLoaded FileLoadedData
    | GazersFetched (Result Error (List String))



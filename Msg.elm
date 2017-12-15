module Msg exposing (..)

import Ports exposing (FileLoadedData)
import Http exposing (Error)
import Navigation exposing (Location)

type Msg
    =   FileSelected
      | FileLoaded FileLoadedData
      | UrlChange Location
      | GetAuthorization (Result Error String)
      | StarSet String (Result Error String)



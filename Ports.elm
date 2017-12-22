port module Ports exposing (..)

import Json.Decode as JD


type alias FileLoadedData =
    JD.Value


port fileSelected : String -> Cmd msg


port fileContentRead : (FileLoadedData -> msg) -> Sub msg

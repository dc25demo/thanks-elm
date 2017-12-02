port module Ports exposing (..)

type alias FileLoadedData = String

port fileSelected : String -> Cmd msg

port fileContentRead : (FileLoadedData -> msg) -> Sub msg

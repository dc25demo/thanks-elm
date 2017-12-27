port module Ports exposing (..)

import Json.Decode as JD


type alias FileLoadedData =
    JD.Value

-- Tell javascript that we read a file.  Argument
-- is id that tells javascript code where to find 
-- the file name.
port fileSelected : String -> Cmd msg

-- Javascript has read the file; filename/contents are availble.
port fileContentRead : (FileLoadedData -> msg) -> Sub msg

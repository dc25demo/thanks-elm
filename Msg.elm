module Msg exposing (..)

import Ports exposing (FileLoadedData)
import Http exposing (Error)
import Navigation exposing (Location)


type Msg
    = 
      -- file was selected by user.
      FileSelected  

      -- file was read and data is available
    | FileLoaded FileLoadedData 

      -- github.com response to request for authorization token 
    | TokenResponse (Result Error String) 

      -- github.com response to request to apply star to a repository
    | StarSet (String,String) (Result Error String) 

      -- Unused but expected by Navigation based code.
    | UrlChange Location 

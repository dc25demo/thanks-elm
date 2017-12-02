module Model exposing (Model, init)
import Msg exposing (Msg)

init : (Model, Cmd Msg)
init = (Model (Ok []), Cmd.none) 

type alias Repo =
    { name : String
    , thanked : Bool
    }

type alias Model =
    { dependencies : Result String (List Repo)
    }

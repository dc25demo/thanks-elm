module Model exposing (Model, Repo, init)
import Msg exposing (Msg)

init : (Model, Cmd Msg)
init = (Model (Ok []) [], Cmd.none) 

type alias Repo =
    { name : String
    , thanked : Bool
    }

type alias Model =
    { dependencies : Result String (List Repo)
    , gazers : List String
    }

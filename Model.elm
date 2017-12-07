module Model exposing (Model, Repo)
import Msg exposing (Msg)

type alias Repo =
    { name : String
    , thanked : Bool
    }

type alias Model =
    { dependencies : Result String (List Repo)
    , gazers : List String
    }

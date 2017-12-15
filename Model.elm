module Model exposing (Model, Repo)
import Msg exposing (Msg)

type alias Repo =
    { name : String
    , thanked : Bool
    }

type alias Model =
    { dependencies : Maybe (Result String (List Repo))
    , auth: Maybe String
    }

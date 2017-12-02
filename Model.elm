module Model exposing (Model, init)
import Msg exposing (Msg)

init : (Model, Cmd Msg)
init = (Model (Ok []), Cmd.none) 

type alias Model =
    { 
    dependencies : Result String (List String)
    }

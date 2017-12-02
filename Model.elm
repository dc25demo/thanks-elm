module Model exposing (Model, init)
import Msg exposing (Msg)

init : (Model, Cmd Msg)
init = (Model Nothing, Cmd.none) 

type alias Model =
    { 
    error : Maybe String
    }

import Html exposing (..)
import Ports exposing (fileContentRead, fileSelected, FileLoadedData)
import Msg exposing (..)
import Model exposing (Model, init)
import View exposing (view)
import Json.Decode exposing (..)
import Dict exposing (keys)
import Result exposing (map)

main : Program Never Model Msg
main =
    program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }

subscriptions : Model -> Sub Msg
subscriptions model =
    fileContentRead FileLoaded

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of

        FileSelected ->
            ( model, fileSelected "PackageJSON" )

        FileLoaded fileContents -> 
            let decodeResult = decodeString (field "dependencies" (dict string)) fileContents
                deps = Result.map keys decodeResult 
            in ({model | dependencies = deps }, Cmd.none)


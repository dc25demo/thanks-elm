import Html exposing (..)
import Http exposing (..)
import Ports exposing (fileContentRead, fileSelected, FileLoadedData)
import Msg exposing (..)
import Model exposing (Model, Repo, init)
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

getGazersCmd : Repo -> Cmd Msg
getGazersCmd repo = 
   let
       url = "https://api.github.com/repos/" ++ repo.name ++ "/stargazers"

       decodeGazers = list (field "login" string)

       request = Http.get url decodeGazers
  in
    Http.send GazersFetched request

    

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of

        FileSelected ->
            ( model, fileSelected "PackageJSON" )

        FileLoaded fileContents -> 
            let decodeResult = decodeString (field "dependencies" (dict string)) fileContents
                names = Result.map keys decodeResult 
                repos = Result.map (List.map (\nm -> {name=nm, thanked=False})) names
            in ( {model | dependencies = repos }
               , case repos of
                     Err _ -> Cmd.none
                     Ok [] -> Cmd.none
                     Ok (r0 :: _) -> getGazersCmd r0
               )
        GazersFetched (Err _) -> (model, Cmd.none)
        GazersFetched (Ok gazers) -> ({model | gazers=gazers}, Cmd.none)


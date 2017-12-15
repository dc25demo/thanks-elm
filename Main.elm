import Html exposing (Html, text, a, div)
import Html.Attributes exposing (href)
import Navigation exposing (..)
import UrlParser as Url exposing ((<?>))
import Http exposing (..)
import Result exposing (..)
import Json.Decode as JD exposing (decodeString, string, dict, field, list)  
import Dict exposing (keys)
import Result exposing (map)

import Ports exposing (fileContentRead, fileSelected, FileLoadedData)
import Msg exposing (..)
import Model exposing (Model, Repo)
import View exposing (view)

type TokenData = TokenData (Maybe String) (Maybe String)

clientId = "8256469ec6a458a2b111"
clientSecret = "b768bf69c0f44866330780a11d01cbf192ec0727"
repoName = "oauthElm"
redirectUri = "https://dc25.github.io/" ++ repoName
scope = "repo:user"
state = "w9erwlksjdf"

githubOauthUri = "https://github.com/login/oauth/authorize"
                     ++ "?client_id=" ++ clientId 
                     ++ "&redirect_uri=" ++ redirectUri 
                     ++ "&scope=" ++ scope 
                     ++ "&state=" ++ state


redirectParser : Url.Parser (TokenData -> a) a
redirectParser = Url.map TokenData 
                     (   Url.s repoName 
                     <?> Url.stringParam "code" 
                     <?> Url.stringParam "state"
                     )

-- https://stackoverflow.com/questions/42150075/cors-issue-on-github-oauth
-- https://github.com/isaacs/github/issues/330
-- https://stackoverflow.com/questions/29670703/how-to-use-cors-anywhere-to-reverse-proxy-and-add-cors-headers

requestAuthorization : String -> Cmd Msg
requestAuthorization code =
    let content =    "client_id=" ++ clientId 
                  ++ "&client_secret=" ++ clientSecret 
                  ++ "&code=" ++ code

        corsAnywhere = "https://cors-anywhere.herokuapp.com/"

        rq = request 
                 { method = "POST"
                 , headers = [ (Http.header "Accept" "application/json") ]
                 , url = corsAnywhere ++ "https://github.com/login/oauth/access_token/"
                 , body = stringBody "application/x-www-form-urlencoded" content
                 , expect = expectJson (field "access_token" JD.string)
                 , timeout = Nothing
                 , withCredentials = False
                 }

    in send GetAuthorization rq

init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let model = {dependencies=Nothing, auth = Nothing}
        cmd = case (Url.parsePath redirectParser location) of
                  Just (TokenData (Just code) (Just _)) 
                      -> requestAuthorization code
                  _   
                      -> Cmd.none
    in (model, cmd)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
    case msg of 
        GetAuthorization (Ok res)
            -> ({model | auth = Just res} , Cmd.none)

        FileSelected ->
            ( model, fileSelected "PackageJSON" )

        FileLoaded fileContents -> 
            let decodeResult = decodeString (field "dependencies" (dict string)) fileContents
                names = map keys decodeResult 
                repos = map (List.map (\nm -> {name=nm, thanked=False})) names
            in ( {model | dependencies = Just repos }, Cmd.none)

        _ 
            -> (model, Cmd.none)


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init 
        , update = update
        , view = view
        , subscriptions = subscriptions
        }

subscriptions : Model -> Sub Msg
subscriptions model =
    fileContentRead FileLoaded


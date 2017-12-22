module Main exposing (..)

import Navigation exposing (program, load)
import UrlParser as Url exposing ((<?>))
import Http exposing (send, request, stringBody, expectJson)
import Json.Decode as JD
import Json.Encode as JE
import Dict exposing (Dict, keys)
import Result exposing (map)
import Ports exposing (..)
import Msg exposing (..)
import Model exposing (..)
import View exposing (..)


clientId =
    "b375bfd8cc7651ac2a7c"


clientSecret =
    "4ce0dc66e45e26e03279509a977ab6fc1de54d3f"


type TokenData
    = TokenData (Maybe String) (Maybe String)


redirectParser : String -> Url.Parser (TokenData -> a) a
redirectParser repoName =
    Url.map TokenData
        (Url.s repoName
            <?> Url.stringParam "code"
            <?> Url.stringParam "state"
        )



-- https://stackoverflow.com/questions/42150075/cors-issue-on-github-oauth
-- https://github.com/isaacs/github/issues/330
-- https://stackoverflow.com/questions/29670703/how-to-use-cors-anywhere-to-reverse-proxy-and-add-cors-headers
-- https://stackoverflow.com/questions/47076743/cors-anywhere-herokuapp-com-not-working/47085173#47085173


requestAuthorization : String -> Cmd Msg
requestAuthorization code =
    let
        content =
            "client_id="
                ++ clientId
                ++ "&client_secret="
                ++ clientSecret
                ++ "&code="
                ++ code

        -- Both "cors anywhere" sites work but "headland" one is more reliable.
        -- corsAnywhere = "https://cors-anywhere.herokuapp.com/"
        corsAnywhere =
            "https://cryptic-headland-94862.herokuapp.com/"

        rq =
            request
                { method = "POST"
                , headers = [ (Http.header "Accept" "application/json") ]
                , url = corsAnywhere ++ "https://github.com/login/oauth/access_token/"
                , body = stringBody "application/x-www-form-urlencoded" content
                , expect = expectJson (JD.field "access_token" JD.string)
                , timeout = Nothing
                , withCredentials = False
                }
    in
        send Authorized rq


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        notSlash s =
            s /= '/'

        repoName =
            String.filter notSlash location.pathname

        ( cmd, args ) =
            case (Url.parsePath (redirectParser repoName) location) of
                Just (TokenData (Just code) deps0) ->
                    ( requestAuthorization code, deps0 )

                _ ->
                    ( Cmd.none, Nothing )

        contentDecoder =
            (JD.field "content" (JD.dict JD.string))

        decodedDeps =
            Maybe.map (JD.decodeString contentDecoder) args

        unstarredDeps =
            Maybe.map (Result.map (Dict.map (\k s -> False))) decodedDeps

        nameDecoder =
            (JD.field "name" JD.string)

        decodedName =
            Maybe.map (JD.decodeString nameDecoder) args
    in
        ( { dependencies = unstarredDeps
          , fileName = decodedName
          , location = location
          }
        , cmd
        )


applyStar : String -> String -> Cmd Msg
applyStar auth dependency =
    let
        rq =
            request
                { method = "PUT"
                , headers = [ (Http.header "Authorization" ("token " ++ auth)) ]
                , url = "https://api.github.com/user/starred/" ++ dependency
                , body = Http.emptyBody
                , expect = Http.expectStringResponse (\resp -> Ok (toString resp))
                , timeout = Nothing
                , withCredentials = False
                }
    in
        send (StarSet dependency) rq


applyStars : String -> Model -> Cmd Msg
applyStars auth model =
    case (model.dependencies) of
        Just (Ok deps) ->
            Cmd.batch <| List.map (applyStar auth) (keys deps)

        _ ->
            Cmd.none



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FileSelected ->
            ( model, fileSelected "PackageJSON" )

        FileLoaded jval ->
            let
                -- get file name and content that were received through port.
                fileName =
                    JD.decodeValue (JD.field "name" JD.string) jval

                contents =
                    JD.decodeValue (JD.field "content" JD.string) jval

                -- get dependencies from content
                depencencies =
                    Result.andThen (JD.decodeString (JD.field "dependencies" JD.value)) contents

                encode name deps = 
                    JE.encode 0
                        (JE.object
                            [ ( "name", JE.string name )
                            , ( "content", deps )
                            ]
                        )

                authUri location name deps =
                    "https://github.com/login/oauth/authorize"
                        ++ "?client_id=" ++ clientId
                        ++ "&redirect_uri=" ++ location.origin ++ location.pathname
                        ++ "&scope=public_repo"
                        ++ "&state=" ++ (encode name deps)

            in
                case ( fileName, depencencies ) of
                    -- Send valid name and dependencies to github.com ; 
                    -- Returned via redirect along with authorization code.
                    ( Ok name, Ok deps ) ->
                        ( model , load (authUri model.location name deps))

                    _ ->
                        ( model, Cmd.none )

        Authorized (Ok auth) ->
            -- response recieved from github.com access token request
            ( model, applyStars auth model )

        StarSet dependency code ->
            -- response recieved from api.github.com after setting star.
            let
                newDeps =
                    Maybe.map (Result.map (Dict.insert dependency True)) model.dependencies
            in
                ( { model | dependencies = newDeps }, Cmd.none )

        _ ->
            ( model, Cmd.none )


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
    fileContentRead FileLoaded

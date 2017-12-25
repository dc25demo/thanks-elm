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


clientId = "167f916723e5ae13e9fe"
clientSecret = "1ad91f7bb53f9d9e37b9b8927f446b41c615126e"


type TokenData = TokenData (Maybe String) (Maybe String)


-- URL starts with repoName, contains "code" and "state" queries.
redirectParser : String -> Url.Parser (TokenData -> a) a
redirectParser repoName =
    Url.map TokenData
        (Url.s repoName
            <?> Url.stringParam "code"
            <?> Url.stringParam "state"
        )


-- Some references that help explain CORS related issues.

-- https://stackoverflow.com/questions/42150075/cors-issue-on-github-oauth
-- https://github.com/isaacs/github/issues/330
-- https://stackoverflow.com/questions/29670703/how-to-use-cors-anywhere-to-reverse-proxy-and-add-cors-headers
-- https://stackoverflow.com/questions/47076743/cors-anywhere-herokuapp-com-not-working/47085173#47085173


requestAuthorization : String -> Cmd Msg
requestAuthorization code =
    let
        content =
            "client_id=" ++ clientId
         ++ "&client_secret=" ++ clientSecret
         ++ "&code=" ++ code

        -- Need to use a proxy for github.com POST to work in browser.
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

        -- remove leading and trailing slashes from repo name.
        repoName =
            String.filter notSlash location.pathname

        -- if we have vaild input in URL then use the "code"
        -- to request an authorization token and get program 
        -- specific parameters from the "state"

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

        dependencies =
            Maybe.map (Result.map (Dict.map (\k s -> False))) decodedDeps

        nameDecoder =
            (JD.field "name" JD.string)

        fileName =
            Maybe.map (JD.decodeString nameDecoder) args

        projectData = Maybe.map2 (Result.map2 (,)) fileName dependencies
    in
        ( { projectData = projectData
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
    case (model.projectData) of
        Just (Ok (_, dependencies)) ->
            Cmd.batch <| List.map (applyStar auth) (keys dependencies)

        _ ->
            Cmd.none


setModelErr : Model -> String -> Model
setModelErr model err = {model | projectData = Just (Err err) }

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

                    ( Ok name, Err depsError ) ->
                        ( setModelErr model depsError, Cmd.none)

                    ( Err nameError, Ok deps ) ->
                        ( setModelErr model nameError, Cmd.none)

                    ( Err nameError, Err depsError ) ->
                        ( setModelErr model <| nameError ++ " / " ++ depsError, Cmd.none)

        Authorized (Ok auth) ->
            -- response recieved from github.com access token request
            ( model, applyStars auth model )

        Authorized (Err errorMessage) ->
            -- response recieved from github.com access token request
            ( setModelErr model (toString errorMessage), Cmd.none)

        StarSet dependency code ->
            -- response recieved from api.github.com after setting star.
            let
                newProjectData =
                    Maybe.map (Result.map (Tuple.mapSecond (Dict.insert dependency True ))) model.projectData
            in
                ( { model | projectData = newProjectData }, Cmd.none )

        UrlChange _ ->  -- should not happen.
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

module View exposing (view)

import Html exposing (Html, input, text, div, label, br)
import Html.Attributes exposing (type_, disabled, checked, id, class, for)
import Html.Events exposing (on)
import Json.Decode exposing (succeed)
import Dict exposing (keys)
import Msg exposing (..)
import Model exposing (..)


chooseFile : Html Msg
chooseFile =
    div []
        [ (label [ for "PackageJSON" ]
            [ text "Select an \"elm-package.json\" file: " ]
          )
        , (input
            [ type_ "file"
            , id "PackageJSON"
            , on "change" (succeed FileSelected)
            ]
            []
          )
        ]


thankedCheckbox : Bool -> String -> Html Msg
thankedCheckbox s boxId =
    input
        [ type_ "checkbox"
        , disabled True
        , checked s
        , id boxId
        , class "flag"
        ]
        []


showThanked : ( String, Bool ) -> Html Msg
showThanked ( d, s ) =
    let
        splitDeps =
            String.split "/" d

        ( user, repo ) =
            case splitDeps of
                [] ->
                    ( "", "" )

                r :: [] ->
                    ( "", r )

                u :: r :: _ ->
                    ( u, r )
    in
        div []
            [ thankedCheckbox s d
            , label [ for d ] [ text ("Thanking ") ]
            , label [ for d, class "name" ] [ text (user) ]
            , label [ for d ] [ text (" for ") ]
            , label [ for d, class "name" ] [ text (repo) ]
            ]

thankingMessage fileName = 
    "Thanking everyone who helped create and maintain your Elm project's dependences ( as found in file: \"" ++ fileName ++ "\" ) ....."

allDoneMessage = 
    "All done, thanks for being grateful!"

view : Model -> Html Msg
view model =
    div []
        (    chooseFile
          :: (br [] [])
          :: (case (model.projectData)  of
                  Just (Err e) ->
                      [ label [] [ text ("Error: " ++ toString e) ] ]

                  Just (Ok (fileName, deps)) ->
                         ( label [] [ text (thankingMessage fileName)] )
                      :: ( div [] (List.map showThanked (Dict.toList deps)) )
                      :: if List.all identity (Dict.values deps) 
                         then [ br [] []
                              , div [] 
                                    [ label [] [text allDoneMessage] ] ]
                         else []

                  Nothing -> []
             )
        )

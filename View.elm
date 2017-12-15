module View exposing (..)

import Html exposing (..)
import Html.Attributes as HA exposing (checked, class, id, placeholder, src, style, title, type_, value, width, name, min, max, href)
import Html.Events exposing (..)
import Json.Decode as JD
import Msg exposing (..)
import Model exposing (..)

view : Model -> Html Msg
view model =
    div [ class "FileWrapper" ]
        ( case model.dependencies of
              Just (Err e) -> 
                   [ text ("Errors: " ++ toString e) ]
  
              Just (Ok deps) -> 
                   [ div [] ( (List.map (\d -> let {name,thanked} = d in (div [] [text name])) deps) 
                            )
                   ] 

              Nothing -> 
                   [ text "Select an 'elm-package.json' file: "
                   , input [ type_ "file"
                           , id "PackageJSON"
                           , on "change" (JD.succeed FileSelected)
                           ]
                           [] 
                   ] 
        )

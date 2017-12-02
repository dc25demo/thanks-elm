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
        ( case model.error of
              Just e -> 
                   [ text ("Errors: " ++ toString e) ]
  
              Nothing -> 
                   if (True) 
                   then viewInput model
                   else viewFile model
        )

regroup : Int -> List t -> List (List t)
regroup n xs = 
    case List.take n xs of
        [] -> []
        xn -> xn :: regroup n (List.drop n xs)

viewSheet : Int -> Int -> List (List String) -> List (Html Msg)
viewSheet rows columns pairs = 
    let defecit = rows*columns - (List.length pairs)
        padding = List.repeat defecit ["",""]
        paddedPairs = pairs ++ padding
        frontWords0 = List.map ((Maybe.withDefault "") << List.head) paddedPairs
        frontWords = List.take rows <| regroup columns frontWords0

        backWords0 = List.map ((Maybe.withDefault "") << List.head << List.drop 1) paddedPairs
        backWords = List.take rows <| List.map List.reverse <| regroup columns backWords0

        tableStyle = style [ ("width", "100%")
                           , ("height", "100%")
                           , ("border-collapse", "collapse")
                           , ("border-spacing", "0")
                           , ("border-style", "hidden")
                           , ("break-after", "page")
                           ]

        textStyle =     [ ("width", (toString <| (1.0/toFloat columns) * 100) ++ "%")
                        , ("height", (toString <| (1.0/toFloat rows) * 100) ++ "%")
                        , ("padding", "0px")
                        , ("text-align", "center")
                        ] 

        -- Text flipping tricks from : 
        --     http://www.devcurry.com/2011/07/upside-down-text-with-css3.html

        flipText =      [ ("-webkit-transform", "rotate(-180deg)" )
                        , ("-moz-transform", "rotate(-180deg)" ) -- /* Firefox */
                        , ("-webkit-transform", "rotate(-180deg)" ) -- /* Webkit */        
                        , ("-ms-transform", "rotate(-180deg)" ) -- /* IE */
                        , ("-o-transform", "rotate(-180deg)" ) -- /* Opera */
                        , ("transform", "rotate(-180deg)" ) -- /* future */
                        ]

        dashedBorder =  [ ("border", "1px dotted #AAA") 
                        ]

        frontStyle = style textStyle
        backStyle = style (textStyle ++ dashedBorder ++ flipText)

        frontTable = table [tableStyle]
                    (List.map (\r -> tr [] (List.map (\c -> td [frontStyle] [ text c ]) r)) frontWords)

        backTable = table [tableStyle]
                    (List.map (\r -> tr [] (List.map (\c -> td [backStyle] [ text c ]) r)) backWords)

    in  [ frontTable, backTable ]


viewFile : Model -> List (Html Msg)
viewFile model = []


slider : String -> Int -> Int -> Int -> (String -> Msg) -> List (Html Msg)
slider name min max current msg = 
  [ input
    [ value (if current >= min then current |> toString else "")
    , on "input" (JD.map msg targetValue )
    , type_ "range"
    , HA.min <| toString min
    , HA.max <| toString max
    ]
    []
  , text <| name ++ "=" ++ (current |> toString)
  ]

viewInput : Model -> List (Html Msg)
viewInput model = 
       [ text "Select a 'package.json' file: "
       , input [ type_ "file"
               , id "PackageJSON"
               , on "change" (JD.succeed FileSelected)
               ]
               [] 
       ] 

module Lia.Code.Parser exposing (parse)

import Array
import Combine exposing (..)
import Lia.Code.Highlight2Ace exposing (highlight2ace)
import Lia.Code.Types exposing (..)
import Lia.Helper exposing (..)
import Lia.Macro.Parser exposing (macro)
import Lia.Markdown.Inline.Parser exposing (javascript)
import Lia.PState exposing (..)


parse : Parser PState Code
parse =
    sepBy1 newline listing
        |> map (,)
        |> andMap
            (regex "[ \n]?"
                |> ignore (maybe identation)
                |> keep macro
                |> keep javascript
                |> maybe
            )
        |> andThen result


result_to_highlight : ( String, String, String, Bool ) -> ( String, String, String )
result_to_highlight ( lang, title, code, _ ) =
    ( lang, title, code )


result : ( List ( String, String, String, Bool ), Maybe String ) -> Parser PState Code
result ( lst, script ) =
    case script of
        Just str ->
            evaluate lst str

        Nothing ->
            lst
                |> List.map result_to_highlight
                |> Highlight
                |> succeed


header : Parser PState String
header =
    spaces
        |> keep (regex "\\w*")
        |> map highlight2ace


title : Parser PState ( Bool, String )
title =
    spaces
        |> keep
            (choice
                [ string "+" |> onsuccess True
                , string "-" |> onsuccess False
                ]
            )
        |> optional True
        |> map (,)
        |> andMap (regex ".*")
        |> ignore newline


code_body : Parser PState String
code_body =
    manyTill
        (maybe identation |> keep (regex "(?:.(?!```))*\\n"))
        (identation |> keep c_frame)
        |> map (String.concat >> String.dropRight 1)


listing : Parser PState ( String, String, String, Bool )
listing =
    c_frame
        |> keep header
        |> map (\h ( v, t ) c -> ( h, t, c, v ))
        |> andMap title
        |> andMap code_body


toFile : ( String, String, String, Bool ) -> File
toFile ( lang, name, code, visible ) =
    File lang name code visible False


extract_code : ( String, String, String, Bool ) -> String
extract_code ( _, _, code, _ ) =
    code


evaluate : List ( String, String, String, Bool ) -> String -> Parser PState Code
evaluate lang_title_code comment =
    let
        array =
            Array.fromList lang_title_code

        add_state s =
            { s
                | code_vector =
                    Array.push
                        { file = Array.map toFile array
                        , version =
                            Array.fromList
                                [ ( Array.map extract_code array, noLog ) ]
                        , evaluation = comment
                        , version_active = 0
                        , log = noLog
                        , running = False
                        , terminal = Nothing
                        }
                        s.code_vector
            }
    in
    (\s ->
        s.code_vector
            |> Array.length
            |> Evaluate
            |> succeed
    )
        |> withState
        |> ignore (modifyState add_state)

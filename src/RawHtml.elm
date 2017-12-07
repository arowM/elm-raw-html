module RawHtml
    exposing
        ( RawHtml
        , iAmSureThatThisRawHtmlStringDoesNotCauseXSS
        , render
        )

{-| An unsafe and unrecommended module to render read-only raw html in Elm view.

⚠⚠⚠⚠⚠⚠⚠⚠WARNING⚠⚠⚠⚠⚠⚠⚠⚠

This module is dangerous, so you should use it carefully.

* this module could inject XSS vulnerability in my app
* this module could create an element that Elm cannot handle

⚠⚠⚠⚠⚠⚠⚠⚠WARNING⚠⚠⚠⚠⚠⚠⚠⚠

# Types

@docs RawHtml

# Constructors

@docs iAmSureThatThisRawHtmlStringDoesNotCauseXSS

# Renderers

@docs render
-}

import Html exposing (Html)


{-| A phantom type to represent raw html.
-}
type RawHtml
    = RawHtml String


{-| Constructor for `RawHtml`.
    Make sure that provided `String` does not inject XSS vulnerability in your app.
-}
iAmSureThatThisRawHtmlStringDoesNotCauseXSS : String -> RawHtml
iAmSureThatThisRawHtmlStringDoesNotCauseXSS raw =
    RawHtml raw


{-| Render function to construct a node that renders provided raw html in it.

e.g.,

```
div
    [ class "wrapper" ]
    [ RawHtml.render <|
        RawHtml.iAmSureThatThisRawHtmlStringDoesNotCauseXSS """
        <div class="child">
            <input type='text' class="foo">
        </div>
        """
    ]
```

Above Elm view is rendered to bellow.

```
<div class="wrapper">
    <div class="child">
        <input class="foo" type="text">
    </div>
</div>
```
-}
render : RawHtml -> Html msg
render (RawHtml str) =
    Html.node "script"
        []
        [ Html.text <| """
var scripts = document.getElementsByTagName("script");
var thisTag = scripts[scripts.length - 1];
thisTag.parentNode.innerHTML=\"""" ++ escapeQuot str ++ "\";"
        ]



-- Helper functions


escapeQuot : String -> String
escapeQuot =
    String.foldr (\c str -> escapeQuot_ c ++ str) ""


escapeQuot_ : Char -> String
escapeQuot_ c =
    case c of
        '\n' ->
            ""

        '"' ->
            "\\\""

        _ ->
            String.cons c ""

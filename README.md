# thanks-elm

🌟 Say thanks to everyone who helps build and maintain your Elm dependencies

## CAUTION

When you use this web app, you will be prompted by github to allow the web app to work on your behalf.  This is necessary because the web app will be starring repositories in your name.  **Always think twice before granting such permission.**  In fact, the best use for this web app may be as a reference for others who wish to use oauth to work with the github API from within an Elm web app.


![Example gif](https://github.com/dc25demo/thanks-elm/raw/master/thanksElmVideoB854.gif)

## Motivation
Inspired by [this command line utility, "elm-thanks"](https://github.com/zwilias/elm-thanks) .  I wanted to see what it would take to implement the same functionality as a web app written in Elm.

## Purpose
As with "elm-thanks", the idea is to express our gratitude to the creators and maintainers of our dependencies by starring the github repositories. 


## Operation
Click here to run the web app: [https://dc25demo.github.io/thanks-elm](https://dc25demo.github.io/thanks-elm).  

The original "elm-thanks" determines dependencies from an elm-package.json file in the current directory.  The "thanks-elm" web app prompts the user to choose an elm-package.json file.

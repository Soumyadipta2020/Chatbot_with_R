library(shiny)
library(bslib)
library(httr2)
library(purrr)
library(glue)
library(jsonlite)
library(httr)
library(gptstudio)
library(shinyCopy2clipboard)
library(sass)
library(markdown)
library(waiter)
library(shinyjs)
library(dplyr)
library(officer)
library(stringr)
library(openai)

thematic::thematic_shiny(font = "auto")

source("helper.R")
css <- sass(sass_file("www/chat.scss"))

jscode_1 <- '
      var container = document.getElementById("chat-history");
      if (container) {
        container.scrollTop = container.scrollHeight;
      }
    '

openai_api_key <<- ""
gemini_api_key <<- ""
claude_api_key <<-
  ""
hugging_api_key <<- ""
nv_api_key <- ''

reload <<- 1
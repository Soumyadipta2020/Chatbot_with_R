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

source("helper.R")
css <- sass(sass_file("www/chat.scss"))

jscode_1 <- '
      var container = document.getElementById("chat-history");
      if (container) {
        container.scrollTop = container.scrollHeight;
      }
    '

openai_api_key <<- "sk-proj-3UmC10TAyJ8CULw8hvQDT3BlbkFJKm2pe6yFDBDkNOYPr0Yg"
gemini_api_key <<- "AIzaSyBc8XOg3B7sY7n5VDsy5SgIT8baqsbFdGc"
claude_api_key <<-
  "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"
hugging_api_key <<- "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"

reload <<- 1
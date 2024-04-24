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

source("helper.R")
css <- sass(sass_file("www/chat.scss"))
jscode <-
  'var container = document.getElementById("chat-container");
if (container) {
  var elements = container.getElementsByClassName("user-message");
  if (elements.length > 1) {
    var lastElement = elements[elements.length - 1];
    lastElement.scrollIntoView({
      behavior: "smooth"
    });
  }
}'

execute_at_next_input <-
  function(expr, session = getDefaultReactiveDomain()) {
    observeEvent(once = TRUE,
                 reactiveValuesToList(session$input),
                 {
                   force(expr)
                 },
                 ignoreInit = TRUE)
  }

openai_api_key <<- "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"
gemini_api_key <<- "AIzaSyBc8XOg3B7sY7n5VDsy5SgIT8baqsbFdGc"
claude_api_key <<- "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"
hugging_api_key <<- "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"

reload <<- 1

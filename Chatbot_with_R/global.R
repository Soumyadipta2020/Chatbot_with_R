library(shiny)
library(bslib)
library(httr2)
library(purrr)
library(glue)
library(jsonlite)
library(httr)
library(gptstudio)

source("helper.R")

openai_api_key <<- "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"
gemini_api_key <<- "AIzaSyBc8XOg3B7sY7n5VDsy5SgIT8baqsbFdGc"
claude_api_key <<- "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"
# hugging_api_key <<- "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"



# t <- create_completion_huggingface(
#   model= "gpt2",
#   history = NULL,
#   prompt = "What is python?",
#   token = hugging_api_key
# )[[1]][[1]]
# 
# cat(t)

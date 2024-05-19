server <- function(input, output, session) {
  if (reload == 1) {
    session$reload()
    reload <<- reload + 1
  }
  
  observeEvent(input$logout, {
    rv$chat_history <- NULL
    session$close()
    stopApp()
  })
  
  rv <- reactiveValues()
  rv$chat_history <- NULL
  
  observeEvent(input$chat,{
    req(input$prompt != "")
    
    # Spinner
    w <- Waiter$new(id = "chat-history",
                    html = spin_3(),
                    color = transparent(.5))
    w$show()
    
    if (input$response_type == "Precise") {
      gemini_temp <- 0.1
    } else if (input$response_type == "Balanced") {
      gemini_temp <- 0.5
    } else if (input$response_type == "Creative") {
      gemini_temp <- 0.9
    }
    
    prompt = input$prompt
    
    if (!is.null(input$file$datapath)) {
      if (str_detect(input$file$datapath, ".doc") == TRUE) {
        sample_data <- read_docx(input$file$datapath)
        content <- docx_summary(sample_data)
        temp_text <- paste(content$text, collapse = " ")
        prompt <- paste(prompt, temp_text, sep = "  -  ")
      } else if (str_detect(input$file$datapath, ".pptx") == TRUE) {
        sample_data <- read_pptx(input$file$datapath)
        content <- pptx_summary(sample_data)
        temp_text <- paste(content$text, collapse = " ")
        prompt <- paste(prompt, temp_text, sep = "  -  ")
      }
    }
    
    if (input$ai_type == "Conversational") {
      if (input$model_gen == "gpt-3.5-turbo") {
        response <- chat(
          prompt,
          history = rv$chat_history,
          system_prompt = input$task,
          api_key = openai_api_key
        )
      } else if (input$model_gen == "gemini-pro") {
        response <-
          gemini(
            prompt,
            temperature = gemini_temp,
            api_key = gemini_api_key,
            max_retries = 10
          )
      } else if (input$model_gen == "claude-2.1") {
        response <-
          create_completion_anthropic(
            prompt,
            key = claude_api_key,
            model = "claude-2.1",
            history = rv$chat_history,
          )
      } else if (input$model_gen == "claude-instant") {
        response <-
          create_completion_anthropic(
            prompt,
            key = claude_api_key,
            model = "claude-instant-1.2",
            history = rv$chat_history,
          )
      } else if (input$model_gen == "google-gemma-7b-it") {
        response <-
          create_completion_huggingface(
            model = "google/gemma-1.1-7b-it",
            history = rv$chat_history,
            prompt = prompt,
            token = hugging_api_key
          )[[1]][[1]]
      } else if (input$model_gen == "Mixtral-8x7B-Instruct-v0.1") {
        response <-
          create_completion_huggingface(
            model = "mistralai/Mixtral-8x7B-Instruct-v0.1",
            history = rv$chat_history,
            prompt = prompt,
            token = hugging_api_key,
            max_new_tokens = 10000
          )[[1]][[1]]
      } else if (input$model_gen == "Mistral-7B-Instruct-v0.2") {
        response <-
          create_completion_huggingface(
            model = "mistralai/Mistral-7B-Instruct-v0.2",
            history = rv$chat_history,
            prompt = prompt,
            token = hugging_api_key,
            max_new_tokens = 10000
          )[[1]][[1]]
      } else if (input$model_gen == "Meta-Llama-3-8B-Instruct") {
        response <-
          create_completion_huggingface(
            model = "meta-llama/Meta-Llama-3-8B-Instruct",
            history = rv$chat_history,
            prompt = prompt,
            token = hugging_api_key,
            max_new_tokens = 1000
          )[[1]][[1]]
      } else if (input$model_gen == "microsoft-Phi-3-mini") {
        response <-
          create_completion_huggingface(
            model = "microsoft/Phi-3-mini-4k-instruct",
            history = rv$chat_history,
            prompt = prompt,
            token = hugging_api_key
          )[[1]][[1]]
      } else if (input$model_gen == "01-ai/Yi-1.5") {
        response <-
          create_completion_huggingface(
            model = "01-ai/Yi-1.5-34B-Chat",
            history = rv$chat_history,
            prompt = prompt,
            token = hugging_api_key,
            max_new_tokens = 1000
          )[[1]][[1]]
      }
    } else if (input$ai_type == "Inferential") {
      if (input$model_inf == "Mistral-7B-v0.1") {
        response <-
          create_completion_huggingface(
            model = "mistralai/Mistral-7B-v0.1",
            history = NULL,
            prompt = prompt,
            token = hugging_api_key,
            max_new_tokens = 1000
          )[[1]][[1]]
      } else if (input$model_inf == "google/gemma-7b") {
        response <-
          create_completion_huggingface(
            model = "google/gemma-7b",
            history = NULL,
            prompt = prompt,
            token = hugging_api_key,
            max_new_tokens = 1000
          )[[1]][[1]]
      }
    } else if (input$ai_type == "Coding") {
      if (input$model_cod == "starcoder2-15b") {
        response <-
          create_completion_huggingface(
            model = "bigcode/starcoder2-15b",
            history = rv$chat_history,
            prompt = prompt,
            token = hugging_api_key,
            max_new_tokens = 1000
          )[[1]][[1]]
      }
    }
    
    
    reset("file")
    
    rv$chat_history <-
      update_history(rv$chat_history, input$prompt, response)
    
    output$chat_history <-
      renderUI(map(rv$chat_history, \(x) markdown(
        glue("<h3>{x$role}:</h3> \n\n{x$content}")
      )))
    
    w$hide()
    
    showModal(modalDialog(
      title = "",
      "Generation complete!",
      footer = tagList(actionButton("close_win","Close"))
    ))
    Sys.sleep(1)
    click("close_win")
  }) 
  
  observeEvent(input$close_win,{
    removeModal()
    shinyjs::runjs(jscode_1)
  })
  
  observe({
    req(input$clipbtn)
    temp <- rv$chat_history
    final <- data.frame()
    for (i in 1:length(temp)) {
      user_out <-
        data.frame(output = paste0(print(temp[i][[1]]$role), "\n"))
      content_out <-
        data.frame(output = paste0(print(temp[i][[1]]$content), "\n"))
      final <- final %>% bind_rows(user_out, content_out)
    }
    
    CopyButtonUpdate(
      session,
      id = "clipbtn",
      label = "Copy",
      icon = icon("clipboard"),
      text = as.character(final$output)
    )
  })
  
  observeEvent(input$remove_chatThread, {
    output$chat_history <- renderUI({
      return(NULL)
    })
    rv$chat_history <- NULL
    updateTextInput(session, "prompt", value = "")
  })
  
}

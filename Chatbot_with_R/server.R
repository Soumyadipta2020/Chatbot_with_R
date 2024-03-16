server <- function(input, output, session) {
  if (reload == 1) {
    session$reload()
    reload <<- reload + 1
  }
  
  observeEvent(input$logout, {
    session$close()
    stopApp()
  })
  
  rv <- reactiveValues()
  rv$chat_history <- NULL
  
  observe({
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
    
    showModal(modalDialog("Generating...", footer = NULL))
    
    if (input$model_gen == "gpt-3.5-turbo") {
      response <- chat(
        input$prompt,
        history = rv$chat_history,
        system_prompt = input$task,
        api_key = openai_api_key
      )
    } else if (input$model_gen == "gemini-pro") {
      response <-
        gemini(
          input$prompt,
          temperature = gemini_temp,
          api_key = gemini_api_key,
          max_retries = 10
        )
    } else if (input$model_gen == "claude-2.1") {
      response <-
        create_completion_anthropic(
          input$prompt,
          key = claude_api_key,
          model = "claude-2.1",
          history = rv$chat_history,
        )
    } else if (input$model_gen == "claude-instant") {
      response <-
        create_completion_anthropic(
          input$prompt,
          key = claude_api_key,
          model = "claude-instant-1.2",
          history = rv$chat_history,
        )
    } else if (input$model_gen == "google-gemma-7b-it") {
      response <- 
        create_completion_huggingface(
          model= "google/gemma-7b-it",
          history = rv$chat_history,
          prompt = input$prompt,
          token = hugging_api_key
        )[[1]][[1]]
    } else if (input$model_gen == "Mixtral-8x7B-Instruct-v0.1") {
      response <- 
        create_completion_huggingface(
          model= "mistralai/Mixtral-8x7B-Instruct-v0.1",
          history = rv$chat_history,
          prompt = input$prompt,
          token = hugging_api_key,
          max_new_tokens = 10000
        )[[1]][[1]]
    } else if (input$model_gen == "Mistral-7B-Instruct-v0.2") {
      response <- 
        create_completion_huggingface(
          model= "mistralai/Mistral-7B-Instruct-v0.2",
          history = rv$chat_history,
          prompt = input$prompt,
          token = hugging_api_key,
          max_new_tokens = 10000
        )[[1]][[1]]
    } else if (input$model_gen == "starcoder2-15b") {
      response <- 
        create_completion_huggingface(
          model= "bigcode/starcoder2-15b",
          history = rv$chat_history,
          prompt = input$prompt,
          token = hugging_api_key,
          max_new_tokens = 1000
        )[[1]][[1]]
    }
    
    removeModal()
    
    rv$chat_history <-
      update_history(rv$chat_history, input$prompt, response)
    
    output$chat_history <-
      renderUI(map(rv$chat_history, \(x) markdown(
        glue("<h3>{x$role}:</h3> \n\n{x$content}")
      )))
    
    w$hide()
    execute_at_next_input(runjs(jscode))
    
  }) |> bindEvent(input$chat)
  
  
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

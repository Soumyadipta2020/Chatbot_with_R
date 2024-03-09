server <- function(input, output, session) {
  rv <- reactiveValues()
  rv$chat_history <- NULL
  
  observe({
    req(input$prompt != "")
    
    if(input$response_type == "Precise"){
      gemini_temp <- 0.0
    } else if(input$response_type == "Balanced"){
      gemini_temp <- 0.5
    } else if(input$response_type == "Creative"){
      gemini_temp <- 1
    }
    
    showModal(modalDialog("Generating...", footer = NULL))
    if (input$model == "gpt-3.5-turbo") {
      response <- chat(
        input$prompt,
        history = rv$chat_history,
        system_prompt = input$task,
        api_key = openai_api_key
      )
    } else if (input$model == "gemini-pro") {
      response <- gemini(input$prompt, temperature = gemini_temp, api_key = gemini_api_key, max_retries = 10)
    } else if (input$model == "claude-2.1"){
      response <- create_completion_anthropic(input$prompt, key = claude_api_key, model = "claude-2.1", 
                                              history = rv$chat_history,) 
    } else if (input$model == "claude-instant"){
      response <- create_completion_anthropic(input$prompt, key = claude_api_key, model = "claude-instant-1.2", 
                                              history = rv$chat_history,) 
    }
    removeModal()
    
    rv$chat_history <- update_history(rv$chat_history, input$prompt, response)
    
    output$chat_history <- renderUI(map(rv$chat_history, \(x) markdown(glue(
      "{x$role}: {x$content}"
    ))))
  }) |> bindEvent(input$chat)
}

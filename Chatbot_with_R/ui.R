#UI
ui <- fluidPage(
  theme = bs_theme(bootswatch = "sketchy"),
  titlePanel(title = "Chatbot with R"),
  page_sidebar(
    sidebar = sidebar(
      # open = "closed",
      selectInput("model", "Model",
                  choices = c("gpt-3.5-turbo", "gemini-pro", "claude-2.1", "claude-instant")),
      selectInput("task", "Task",
                  choices = c("general", "code")),
      selectInput("response_type", "Response Type",
                  choices = c("Precise", "Balanced", "Creative")),
      textAreaInput("prompt", "Query", width = "800px", height = "200px"),
      actionButton(
        "chat",
        "Send",
        icon = icon("paper-plane"),
        # width = "75px",
        class = "m-2 btn-secondary"
      )
    ),
  fluidRow(uiOutput("chat_history"))
    )
    
)
  

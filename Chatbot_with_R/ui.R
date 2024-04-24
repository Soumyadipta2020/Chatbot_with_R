#UI
ui <- bslib::page_fluid(
  useWaiter(),
  useShinyjs(),
  use_copy(),
  tags$head(tags$style(css)),
  theme = bs_theme(bootswatch = "sketchy"),
  titlePanel(fluidRow(
    column(3, "Chatbot with R"),
    column(1, offset = 8, actionButton(
      "logout", "", icon = icon("right-from-bracket")
    ))
  ),
  windowTitle = "Chatbot with R"),
  page_sidebar(
    sidebar = sidebar(
      selectInput("ai_type", "AI Type",
                  choices = c("Conversational", "Coding", "Inferential"#, "Summarization"
                              )),
      conditionalPanel(
        condition = "input.ai_type == 'Conversational'",
        selectInput(
          "model_gen",
          "Generative AI Model",
          choices = c("Meta-Llama-3-8B-Instruct", "gpt-3.5-turbo", "gemini-pro", "claude-2.1", "claude-instant", 
                      "google-gemma-7b-it", "Mixtral-8x7B-Instruct-v0.1", 
                      "Mistral-7B-Instruct-v0.2"),
          selected = "gemini-pro"
        ),
        selectInput("task", "Task",
                    choices = c("general", "code")),
        selectInput(
          "response_type",
          "Response Type",
          choices = c("Precise", "Balanced", "Creative")
        ),
      ),
      conditionalPanel(
        condition = "input.ai_type == 'Inferential'",
        selectInput(
          "model_inf",
          "Inferential AI Model",
          choices = c("Mistral-7B-v0.1", "google/gemma-7b"),
          selected = "Mistral-7B-v0.1"
        )
      ),
      conditionalPanel(
        condition = "input.ai_type == 'Coding'",
        selectInput(
          "model_cod",
          "Coder AI Model",
          choices = c("starcoder2-15b"),
          selected = "starcoder2-15b"
        )
      )
      # ,
      # conditionalPanel(
      #   condition = "input.ai_type == 'Summarization'",
      #   selectInput(
      #     "model_sum",
      #     "Text Summarization AI Model",
      #     choices = c("starcoder2-15b"),
      #     selected = "starcoder2-15b"
      #   )
      # )
    ),
    mainPanel(tags$div(
      id = "chat-container",
      tags$div(id = "chat-history",
               uiOutput("chat_history")),
      
      tags$div(id = "chat-input",
               tags$form(
                 fluidRow(
                 column(
                   width = 9,
                   textAreaInput(
                     inputId = "prompt",
                     label = "",
                     placeholder = "Type your message here...",
                     width = "100%"
                   )
                 ),
                 column(width = 3, offset = 0, 
                   fileInput("file", "Upload word document", accept = ".docx")
                 )),
                 fluidRow(
                   tags$div(
                     style = "margin-left: 1.5em;",
                     actionButton(
                       inputId = "chat",
                       label = "Send",
                       icon = icon("paper-plane")
                     ),
                     actionButton(
                       inputId = "remove_chatThread",
                       label = "Clear History",
                       icon = icon("trash-can")
                     ),
                     CopyButton(
                       "clipbtn",
                       label = "Copy conversation",
                       icon = icon("clipboard"),
                       text = ""
                     )
                     
                   )
                 )
               ))
    ))
  )
  
)

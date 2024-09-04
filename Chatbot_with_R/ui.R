#UI
ui <- bslib::page_fluid(
  useWaiter(),
  shinyjs::useShinyjs(),
  use_copy(),
  tags$head(tags$style(css)),
  theme = bs_theme(bootswatch = "zephyr"),
  titlePanel(fluidRow(
    column(3, "Multimodal Chatbot"),
    column(1, offset = 8, actionButton(
      "logout", "", icon = icon("right-from-bracket")
    ))
  ), windowTitle = "Multimodal Chatbot"),
  page_sidebar(
    sidebar = sidebar(
      selectInput(
        "ai_type",
        "AI Type",
        choices = c("Conversational", "Coding", "Inferential")
      ),
      conditionalPanel(
        condition = "input.ai_type == 'Conversational'",
        selectInput(
          "model_gen",
          "Generative AI Model",
          choices = c(
            "Meta-Llama-3.1",
            "Meta-Llama-3",
            # "gpt-3.5-turbo",
            "gemini-pro",
            "microsoft-Phi-3-mini",
            # "claude-2.1",
            # "claude-instant",
            "google-gemma-7b-it",
            "Mixtral-v0.1",
            "Mistral-v0.3",
            "Yi-1.5"
          ),
          selected = "Meta-Llama-3.1"
        ),
        sliderInput(
          "temperature",
          "Temperature (For gemini & llama-3.1 only)",
          min = 0,
          max = 1,
          value = 0.5, 
          step = 0.1
        ),
        "Temp = 0 : Precise", br(),
        "Temp = 0.5 : Balanced", br(),
        "Temp = 1 : Creative"
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
          choices = c("starcoder2-15b", "google/codegemma-7b", "meta/llama-3.1"),
          selected = "starcoder2-15b"
        ),
        sliderInput(
          "temperature",
          "Temperature (For codegemma & llama 3.1 only)",
          min = 0,
          max = 1,
          value = 0.5, 
          step = 0.1
        ),
        "Temp = 0 : Precise", br(),
        "Temp = 0.5 : Balanced", br(),
        "Temp = 1 : Creative"
      )
    ),
    mainPanel(tags$div(
      id = "chat-container",
      tags$div(id = "chat-history", style = "overflow-y: scroll;", uiOutput("chat_history")),
      
      tags$div(id = "chat-input", tags$form(
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
          column(
            width = 3,
            offset = 0,
            fileInput("file", "Upload (.docx, .pptx)", accept = c(".docx", ".pptx"))
          )
        ), fluidRow(
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
              label = "Copy",
              icon = icon("clipboard"),
              text = ""
            )
            
          )
        )
      ))
    ))
  )
  
)

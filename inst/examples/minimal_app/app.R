library(shiny)
library(shinyoats)

ui <- fluidPage(
  use_oats(),

  container(
    h1("Hello shinyoats"),
    p("Clean, simple - no classes needed"),
    hr(),

    card(
      title = "Get Started",
      p("Just use wrapper functions."),
      p("No tags$*() or class names required!"),
      footer = hstack(
        btn("Click Me", id = "demo_btn"),
        btn("Learn More", variant = "secondary", outline = TRUE)
      )
    ),

    vstack(
      alert("This is an alert"),
      alert("Success!", variant = "success")
    ),

    h3("More Components"),
    hstack(
      badge("New"),
      badge("v0.1.0", variant = "secondary"),
      badge("Working", variant = "success")
    ),

    verbatimTextOutput("output")
  )
)

server <- function(input, output, session) {
  clicks <- reactiveVal(0)

  observeEvent(input$demo_btn, {
    clicks(clicks() + 1)
    oats_show_toast(session, "Button clicked!", variant = "info")
  })

  output$output <- renderText({
    paste("Clicks:", clicks())
  })
}

shinyApp(ui, server)

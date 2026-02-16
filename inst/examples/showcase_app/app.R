library(shiny)
library(shinyoats)

ui <- fluidPage(
  use_oats(),

  container(
    h1("shinyoats Showcase"),
    p("Clean Oat UI components - no classes, no tags$*()"),
    hr(),

    # Buttons
    h2("Buttons"),
    hstack(
      btn("Primary", id = "btn1"),
      btn("Secondary", variant = "secondary"),
      btn("Danger", variant = "danger"),
      btn("Outline", outline = TRUE),
      btn("Small", size = "sm"),
      btn("Large", size = "lg")
    ),
    verbatimTextOutput("btn_output"),
    hr(),

    # Cards
    h2("Cards"),
    row(
      col(4, card(
        title = "Simple",
        p("Card with title")
      )),
      col(4, card(
        title = "With Footer",
        p("Card content"),
        footer = btn("Action", size = "sm")
      )),
      col(4, card(
        p("No title needed")
      ))
    ),
    hr(),

    # Alerts
    h2("Alerts"),
    vstack(
      alert("Info message"),
      alert("Success!", variant = "success"),
      alert("Warning", variant = "warning"),
      alert("Error", variant = "danger")
    ),
    hr(),

    # Badges
    h2("Badges"),
    hstack(
      badge("New"),
      badge("Beta", variant = "secondary"),
      badge("Success", variant = "success"),
      badge("Warning", variant = "warning"),
      badge("Danger", variant = "danger")
    ),
    hr(),

    # Forms
    h2("Forms"),
    row(
      col(6,
        textInput("name", "Name"),
        selectInput("category", "Category",
                   choices = c("A", "B", "C")),
        checkboxInput("agree", "I agree")
      ),
      col(6,
        textAreaInput("message", "Message", rows = 3),
        radioButtons("priority", "Priority",
                    choices = c("Low", "Medium", "High"))
      )
    ),
    verbatimTextOutput("form_output"),
    hr(),

    # Tabs
    h2("Tabs"),
    tabset(
      id = "main_tabs",
      labels = c("Overview", "Features", "Settings"),
      card(
        h3("Overview"),
        p("shinyoats provides clean wrapper functions."),
        p("No classes or tags$*() needed!")
      ),
      card(
        h3("Features"),
        vstack(
          alert("Clean API"),
          alert("Lightweight", variant = "success"),
          alert("Complete", variant = "info")
        )
      ),
      card(
        h3("Settings"),
        checkboxInput("setting1", "Option 1", TRUE),
        checkboxInput("setting2", "Option 2"),
        btn("Save", id = "save_btn")
      )
    ),
    hr(),

    # Dropdown
    h2("Dropdowns"),
    hstack(
      dropdown(
        "Actions",
        dropdown_item("New"),
        dropdown_item("Edit"),
        dropdown_item("Delete")
      ),
      dropdown(
        "Export",
        variant = "secondary",
        dropdown_item("CSV"),
        dropdown_item("JSON")
      )
    ),
    hr(),

    # Toasts
    h2("Toasts"),
    hstack(
      actionButton("toast1", "Info"),
      actionButton("toast2", "Success"),
      actionButton("toast3", "Warning"),
      actionButton("toast4", "Error")
    ),
    hr(),

    # Modal
    h2("Modal"),
    btn("Open Modal", id = "open_modal"),
    tags$dialog(
      id = "demo_modal",
      h3("Modal Title"),
      p("Modal content here"),
      hstack(
        tags$button("Cancel", class = "ghost",
                   onclick = "this.closest('dialog').close()"),
        btn("OK")
      )
    )
  )
)

server <- function(input, output, session) {
  clicks <- reactiveVal(0)

  observeEvent(input$btn1, {
    clicks(clicks() + 1)
  })

  output$btn_output <- renderText({
    paste("Button clicked:", clicks(), "times")
  })

  output$form_output <- renderText({
    paste("Name:", input$name, "| Category:", input$category,
          "| Agree:", input$agree, "| Priority:", input$priority)
  })

  observeEvent(input$save_btn, {
    oats_show_toast(session, "Settings saved!", variant = "success")
  })

  observeEvent(input$toast1, {
    oats_show_toast(session, "Info message", variant = "info")
  })

  observeEvent(input$toast2, {
    oats_show_toast(session, "Success!", variant = "success")
  })

  observeEvent(input$toast3, {
    oats_show_toast(session, "Warning!", variant = "warning")
  })

  observeEvent(input$toast4, {
    oats_show_toast(session, "Error!", variant = "danger")
  })

  observeEvent(input$open_modal, {
    oats_show_modal(session, "demo_modal")
  })
}

shinyApp(ui, server)

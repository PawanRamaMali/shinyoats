library(shiny)
library(shinyoats)

# Sample data
initial_data <- data.frame(
  id = 1:5,
  name = c("John Doe", "Jane Smith", "Bob Johnson", "Alice Williams", "Charlie Brown"),
  email = c("john@example.com", "jane@example.com", "bob@example.com", "alice@example.com", "charlie@example.com"),
  role = c("Admin", "User", "User", "Manager", "User"),
  status = c("Active", "Active", "Inactive", "Active", "Active"),
  stringsAsFactors = FALSE
)

ui <- fluidPage(
  use_oats(),

  navbar(
    brand = "User Management",
    badge("CRUD Demo", variant = "secondary")
  ),

  container(
    fluid = TRUE,
    style = "margin-top: 2rem;",

    # Header with actions
    hstack(
      gap = 3,
      h1("Users"),
      spacer(),
      hstack(
        gap = 2,
        textInput("search", NULL, placeholder = "Search users..."),
        btn("Add User", id = "add_user_btn", variant = "primary")
      )
    ),

    divider(),

    # Stats cards
    row(
      col(3, card(
        div(style = "font-size: 2rem; font-weight: bold;", textOutput("total_users", inline = TRUE)),
        p("Total Users", style = "color: var(--text-light); margin-top: 0.5rem;")
      )),
      col(3, card(
        div(style = "font-size: 2rem; font-weight: bold; color: var(--success);", textOutput("active_users", inline = TRUE)),
        p("Active", style = "color: var(--text-light); margin-top: 0.5rem;")
      )),
      col(3, card(
        div(style = "font-size: 2rem; font-weight: bold; color: var(--warning);", textOutput("inactive_users", inline = TRUE)),
        p("Inactive", style = "color: var(--text-light); margin-top: 0.5rem;")
      )),
      col(3, card(
        div(style = "font-size: 2rem; font-weight: bold; color: var(--primary);", textOutput("admins", inline = TRUE)),
        p("Admins", style = "color: var(--text-light); margin-top: 0.5rem;")
      ))
    ),

    # Data table
    card(
      title = "User List",
      div(style = "overflow-x: auto;", tableOutput("users_table")),
      footer = hstack(
        gap = 2,
        btn("Export CSV", id = "export_csv", size = "sm", variant = "secondary", outline = TRUE),
        btn("Refresh", id = "refresh", size = "sm", variant = "secondary", outline = TRUE)
      )
    )
  ),

  # Add/Edit User Modal
  modal(
    id = "user_modal",
    title = "Add New User",
    size = "lg",

    textInput("modal_name", "Full Name", placeholder = "Enter full name"),
    textInput("modal_email", "Email", placeholder = "user@example.com"),
    selectInput("modal_role", "Role", choices = c("User", "Manager", "Admin")),
    selectInput("modal_status", "Status", choices = c("Active", "Inactive")),

    footer = hstack(
      gap = 2,
      modal_close_btn("Cancel"),
      btn("Save User", id = "save_user", variant = "primary")
    )
  ),

  # Delete confirmation
  modal(
    id = "delete_modal",
    title = "Confirm Delete",
    alert("Are you sure you want to delete this user? This action cannot be undone.", variant = "warning"),
    footer = hstack(
      gap = 2,
      modal_close_btn("Cancel"),
      btn("Delete", id = "confirm_delete", variant = "danger")
    )
  )
)

server <- function(input, output, session) {
  # Reactive values
  users_data <- reactiveVal(initial_data)
  selected_user <- reactiveVal(NULL)

  # Stats
  output$total_users <- renderText({ nrow(users_data()) })
  output$active_users <- renderText({ sum(users_data()$status == "Active") })
  output$inactive_users <- renderText({ sum(users_data()$status == "Inactive") })
  output$admins <- renderText({ sum(users_data()$role == "Admin") })

  # Data table
  output$users_table <- renderTable({
    data <- users_data()

    # Search filter
    if (!is.null(input$search) && input$search != "") {
      data <- data[grepl(input$search, data$name, ignore.case = TRUE) |
                   grepl(input$search, data$email, ignore.case = TRUE), ]
    }

    data
  }, striped = TRUE, hover = TRUE, spacing = "s", width = "100%", align = "l")

  # Add user
  observeEvent(input$add_user_btn, {
    oats_show_modal(session, "user_modal")
  })

  # Save user
  observeEvent(input$save_user, {
    if (input$modal_name == "" || input$modal_email == "") {
      oats_show_toast(session, "Please fill in all required fields", variant = "warning")
      return()
    }

    # Add new user
    new_user <- data.frame(
      id = max(users_data()$id) + 1,
      name = input$modal_name,
      email = input$modal_email,
      role = input$modal_role,
      status = input$modal_status,
      stringsAsFactors = FALSE
    )

    users_data(rbind(users_data(), new_user))

    oats_hide_modal(session, "user_modal")
    oats_show_toast(session, "User added successfully!", variant = "success")

    # Clear form
    updateTextInput(session, "modal_name", value = "")
    updateTextInput(session, "modal_email", value = "")
  })

  # Refresh
  observeEvent(input$refresh, {
    oats_show_toast(session, "Data refreshed", variant = "info")
  })

  # Export CSV
  observeEvent(input$export_csv, {
    oats_show_toast(session, "Exporting to CSV...", variant = "info")
  })
}

shinyApp(ui, server)

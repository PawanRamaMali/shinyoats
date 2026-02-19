library(shiny)
library(shinyoats)

initial_data <- data.frame(
  id = 1:5,
  name = c("John Doe", "Jane Smith", "Bob Johnson", "Alice Williams", "Charlie Brown"),
  email = c("john@example.com", "jane@example.com", "bob@example.com",
            "alice@example.com", "charlie@example.com"),
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

    # Page header
    hstack(
      h1("Users", style = "margin: 0;"),
      spacer(),
      hstack(
        gap = 2,
        tags$input(
          id = "search", type = "text",
          placeholder = "Search users...",
          oninput = "Shiny.setInputValue('search', this.value)",
          style = paste(
            "padding: 0.4rem 0.75rem;",
            "border: 1px solid var(--border);",
            "border-radius: var(--radius);",
            "background: var(--background);",
            "color: var(--foreground);",
            "font-size: 0.9rem;"
          )
        ),
        action_btn("add_user_btn", "+ Add User")
      )
    ),

    divider(),

    # Stats row
    hstack(
      gap = 3,
      div(style = "flex: 1;",
        card(
          div(style = "font-size: 2.2rem; font-weight: 700;",
              textOutput("total_users", inline = TRUE)),
          p("Total Users", style = "color: var(--muted-foreground); margin: 0.25rem 0 0;")
        )
      ),
      div(style = "flex: 1;",
        card(
          div(style = "font-size: 2.2rem; font-weight: 700; color: var(--success);",
              textOutput("active_users", inline = TRUE)),
          p("Active", style = "color: var(--muted-foreground); margin: 0.25rem 0 0;")
        )
      ),
      div(style = "flex: 1;",
        card(
          div(style = "font-size: 2.2rem; font-weight: 700; color: var(--warning);",
              textOutput("inactive_users", inline = TRUE)),
          p("Inactive", style = "color: var(--muted-foreground); margin: 0.25rem 0 0;")
        )
      ),
      div(style = "flex: 1;",
        card(
          div(style = "font-size: 2.2rem; font-weight: 700; color: var(--primary);",
              textOutput("admins", inline = TRUE)),
          p("Admins", style = "color: var(--muted-foreground); margin: 0.25rem 0 0;")
        )
      )
    ),

    # Users table
    card(
      title = "User List",
      uiOutput("users_table"),
      footer = hstack(
        gap = 2,
        action_btn("export_csv", "Export CSV", variant = "secondary"),
        action_btn("refresh_btn", "Refresh", variant = "secondary")
      )
    )
  ),

  # Add User modal
  modal(
    id = "user_modal",
    title = "Add New User",
    size = "lg",
    hstack(
      gap = 3,
      div(style = "flex: 1;",
        textInput("modal_name", "Full Name", placeholder = "Enter full name"),
        textInput("modal_email", "Email", placeholder = "user@example.com")
      ),
      div(style = "flex: 1;",
        selectInput("modal_role", "Role", choices = c("User", "Manager", "Admin")),
        selectInput("modal_status", "Status", choices = c("Active", "Inactive"))
      )
    ),
    footer = hstack(
      gap = 2,
      modal_close_btn("Cancel"),
      action_btn("save_user", "Save User")
    )
  ),

  # Delete confirmation modal
  modal(
    id = "delete_modal",
    title = "Confirm Delete",
    alert(
      "Are you sure you want to delete this user? This action cannot be undone.",
      variant = "warning"
    ),
    footer = hstack(
      gap = 2,
      modal_close_btn("Cancel"),
      action_btn("confirm_delete", "Delete", variant = "danger")
    )
  )
)

server <- function(input, output, session) {
  users_data <- reactiveVal(initial_data)

  output$total_users    <- renderText({ nrow(users_data()) })
  output$active_users   <- renderText({ sum(users_data()$status == "Active") })
  output$inactive_users <- renderText({ sum(users_data()$status == "Inactive") })
  output$admins         <- renderText({ sum(users_data()$role == "Admin") })

  output$users_table <- renderUI({
    data <- users_data()

    if (!is.null(input$search) && nzchar(input$search)) {
      data <- data[
        grepl(input$search, data$name,  ignore.case = TRUE) |
        grepl(input$search, data$email, ignore.case = TRUE),
      ]
    }

    if (nrow(data) == 0) {
      return(p("No users found.",
               style = "color: var(--muted-foreground); padding: 1rem 0;"))
    }

    th_style <- paste(
      "text-align: left; padding: 0.6rem 0.75rem;",
      "border-bottom: 2px solid var(--border); font-weight: 600;",
      "font-size: 0.8rem; color: var(--muted-foreground);",
      "text-transform: uppercase; letter-spacing: 0.05em;"
    )
    td_style <- "padding: 0.75rem; border-bottom: 1px solid var(--border);"

    rows <- lapply(seq_len(nrow(data)), function(i) {
      u <- data[i, ]
      role_variant   <- switch(u$role, Admin = "danger", Manager = "secondary", "secondary")
      status_variant <- if (u$status == "Active") "success" else "warning"

      tags$tr(
        tags$td(style = td_style,
          strong(u$name),
          tags$div(u$email,
                   style = "font-size: 0.8rem; color: var(--muted-foreground); margin-top: 2px;")
        ),
        tags$td(style = td_style, badge(u$role,   variant = role_variant)),
        tags$td(style = td_style, badge(u$status, variant = status_variant))
      )
    })

    tags$table(
      style = "width: 100%; border-collapse: collapse;",
      tags$thead(tags$tr(
        tags$th("User",   style = th_style),
        tags$th("Role",   style = th_style),
        tags$th("Status", style = th_style)
      )),
      tags$tbody(rows)
    )
  })

  observeEvent(input$add_user_btn, {
    oats_show_modal(session, "user_modal")
  })

  observeEvent(input$save_user, {
    if (!nzchar(trimws(input$modal_name)) || !nzchar(trimws(input$modal_email))) {
      oats_show_toast(session, "Please fill in all required fields", variant = "warning")
      return()
    }

    new_user <- data.frame(
      id     = max(users_data()$id) + 1,
      name   = input$modal_name,
      email  = input$modal_email,
      role   = input$modal_role,
      status = input$modal_status,
      stringsAsFactors = FALSE
    )
    users_data(rbind(users_data(), new_user))

    oats_hide_modal(session, "user_modal")
    oats_show_toast(session, "User added successfully!", variant = "success")

    updateTextInput(session, "modal_name",  value = "")
    updateTextInput(session, "modal_email", value = "")
  })

  observeEvent(input$confirm_delete, {
    oats_hide_modal(session, "delete_modal")
    oats_show_toast(session, "User deleted", variant = "success")
  })

  observeEvent(input$refresh_btn, {
    oats_show_toast(session, "Data refreshed", variant = "info")
  })

  observeEvent(input$export_csv, {
    oats_show_toast(session, "Exporting to CSV...", variant = "info")
  })
}

shinyApp(ui, server)

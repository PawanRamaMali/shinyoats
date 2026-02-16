library(shiny)
library(shinyoats)

ui <- fluidPage(
  use_oats(),

  # Center the login form
  tags$div(
    style = "min-height: 100vh; display: flex; align-items: center; justify-content: center; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);",

    card(
      id = "login_card",
      style = "width: 400px; max-width: 90%;",

      # Logo/Brand
      div(
        style = "text-align: center; margin-bottom: 2rem;",
        h1("Welcome Back"),
        p("Sign in to your account", style = "color: var(--text-light);")
      ),

      # Login Form
      textInput("username", "Username", placeholder = "Enter your username"),
      shiny::passwordInput("password", "Password", placeholder = "Enter your password"),

      # Remember me
      hstack(
        gap = 2,
        switch_input("remember_me", "Remember me"),
        spacer(),
        tags$a(href = "#", "Forgot password?", style = "color: var(--primary); text-decoration: none;")
      ),

      # Login button
      div(style = "margin-top: 1.5rem;",
        btn("Sign In", id = "login_btn", size = "lg", style = "width: 100%;")
      ),

      # Divider
      div(
        style = "margin: 1.5rem 0; text-align: center; color: var(--text-light);",
        "or continue with"
      ),

      # Social login
      hstack(
        gap = 2,
        btn("Google", variant = "secondary", outline = TRUE, style = "flex: 1;"),
        btn("GitHub", variant = "secondary", outline = TRUE, style = "flex: 1;")
      ),

      # Sign up link
      div(
        style = "margin-top: 1.5rem; text-align: center; color: var(--text-light);",
        "Don't have an account? ",
        tags$a(href = "#", "Sign up", style = "color: var(--primary); text-decoration: none;")
      )
    )
  ),

  # Success modal
  modal(
    id = "success_modal",
    title = "Login Successful!",
    p("Welcome back! Redirecting to dashboard..."),
    footer = btn("Continue", onclick = "this.closest('dialog').close()")
  )
)

server <- function(input, output, session) {
  observeEvent(input$login_btn, {
    # Validate
    if (input$username == "" || input$password == "") {
      oats_show_toast(session, "Please fill in all fields", variant = "warning")
      return()
    }

    # Simulate authentication
    Sys.sleep(0.5)

    if (input$username == "demo" && input$password == "demo") {
      oats_show_toast(session, "Login successful!", variant = "success")
      Sys.sleep(1)
      oats_show_modal(session, "success_modal")
    } else {
      oats_show_toast(session, "Invalid credentials", variant = "danger")
    }
  })
}

shinyApp(ui, server)

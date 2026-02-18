library(shiny)
library(shinyoats)

ui <- fluidPage(
  use_oats(theme = "light"),

  # Navbar
  div(
    class = "hstack justify-between p-4",
    style = "background: var(--card); border-bottom: 1px solid var(--border);",
    div(
      class = "hstack gap-2",
      strong("Analytics Dashboard"),
      badge("Live", variant = "success")
    ),
    div(
      class = "hstack gap-2",
      badge("3"),
      dropdown(
        label = "Profile",
        variant = "secondary",
        dropdown_item("Settings"),
        dropdown_item("Help"),
        dropdown_item("Logout")
      )
    )
  ),

  container(
    class = "mt-4",

    # Stats Cards
    h2("Overview"),
    hstack(
      gap = 3,
      div(style = "flex: 1;",
        card(
          div(
            style = "font-size: 2.5rem; font-weight: bold; color: var(--primary);",
            textOutput("users_count", inline = TRUE)
          ),
          p("Total Users", style = "color: var(--muted-foreground); margin-top: 0.25rem;"),
          footer = span("↑ 12% from last month", style = "color: var(--success); font-size: 0.85rem;")
        )
      ),
      div(style = "flex: 1;",
        card(
          div(
            style = "font-size: 2.5rem; font-weight: bold; color: var(--primary);",
            textOutput("revenue_count", inline = TRUE)
          ),
          p("Revenue", style = "color: var(--muted-foreground); margin-top: 0.25rem;"),
          footer = span("↑ 8% from last month", style = "color: var(--success); font-size: 0.85rem;")
        )
      ),
      div(style = "flex: 1;",
        card(
          div(
            style = "font-size: 2.5rem; font-weight: bold; color: var(--primary);",
            textOutput("orders_count", inline = TRUE)
          ),
          p("Orders", style = "color: var(--muted-foreground); margin-top: 0.25rem;"),
          footer = span("↓ 3% from last month", style = "color: var(--danger); font-size: 0.85rem;")
        )
      ),
      div(style = "flex: 1;",
        card(
          div(
            style = "font-size: 2.5rem; font-weight: bold; color: var(--primary);",
            textOutput("growth_count", inline = TRUE)
          ),
          p("Growth", style = "color: var(--muted-foreground); margin-top: 0.25rem;"),
          footer = span("↑ 15% from last month", style = "color: var(--success); font-size: 0.85rem;")
        )
      )
    ),

    # Main Content
    h2("Activity"),
    tabset(
      id = "main_tabs",
      labels = c("Recent Activity", "Charts", "Settings"),

      # Tab 1: Activity Table
      card(
        title = "Recent Transactions",
        tableOutput("activity_table")
      ),

      # Tab 2: Charts
      card(
        title = "Performance Metrics",
        plotOutput("performance_chart", height = "400px"),
        footer = p(class = "text-light", "Data updated every 5 minutes")
      ),

      # Tab 3: Settings
      div(
        class = "vstack gap-4",
        card(
          title = "Dashboard Settings",
          hstack(
            gap = 4,
            div(style = "flex: 1;",
              textInput("app_name", "Application Name", value = "My Dashboard"),
              selectInput("refresh_rate", "Refresh Rate",
                         choices = c("5 seconds" = "5",
                                   "15 seconds" = "15",
                                   "30 seconds" = "30")),
              checkboxInput("notifications", "Enable notifications", value = TRUE)
            ),
            div(style = "flex: 1;",
              checkboxInput("auto_refresh", "Auto-refresh data", value = TRUE),
              checkboxInput("show_tooltips", "Show tooltips", value = TRUE),
              checkboxInput("compact_view", "Compact view")
            )
          ),
          footer = div(
            class = "hstack gap-2 justify-end",
            btn("Reset", variant = "secondary", outline = TRUE),
            btn("Save Changes", id = "save_btn")
          )
        ),

        card(
          title = "Export Data",
          p("Download your dashboard data in various formats"),
          div(
            class = "hstack gap-2",
            btn("CSV", variant = "secondary", size = "sm"),
            btn("JSON", variant = "secondary", size = "sm"),
            btn("PDF", variant = "secondary", size = "sm")
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  # Reactive values for stats
  stats <- reactiveValues(
    users = 1234,
    revenue = 45678,
    orders = 892,
    growth = 12
  )

  # Stats outputs
  output$users_count <- renderText({
    format(stats$users, big.mark = ",")
  })

  output$revenue_count <- renderText({
    paste0("$", format(stats$revenue, big.mark = ","))
  })

  output$orders_count <- renderText({
    format(stats$orders, big.mark = ",")
  })

  output$growth_count <- renderText({
    paste0(stats$growth, "%")
  })

  # Activity table
  output$activity_table <- renderTable({
    data.frame(
      Date = format(Sys.Date() - 0:4, "%Y-%m-%d"),
      Event = c("User Registration", "Purchase", "Support Ticket", "Refund", "New Signup"),
      Amount = c("—", "$149.99", "—", "$49.99", "—"),
      Status = c("Completed", "Completed", "Open", "Processed", "Completed")
    )
  }, striped = TRUE, hover = TRUE)

  # Performance chart
  output$performance_chart <- renderPlot({
    days <- 30:1
    values <- cumsum(rnorm(30, mean = 15, sd = 8)) + 100

    par(bg = "transparent", mar = c(4, 4, 2, 1))
    plot(days, values,
         type = "l",
         col = "#0066cc",
         lwd = 3,
         xlab = "Days Ago",
         ylab = "Performance Score",
         main = "",
         las = 1,
         bty = "n",
         xaxt = "n")
    axis(1, at = seq(30, 0, by = -5), labels = seq(30, 0, by = -5))
    grid(col = "gray90", lty = 1, nx = 6, ny = 5)
    polygon(c(days, rev(days)),
           c(rep(min(values) - 20, length(days)), rev(values)),
           col = rgb(0, 0.4, 0.8, 0.2),
           border = NA)
  })

  # Save settings
  observeEvent(input$save_btn, {
    oats_show_toast(
      session,
      "Dashboard settings saved successfully!",
      title = "Success",
      variant = "success"
    )
  })
}

shinyApp(ui, server)

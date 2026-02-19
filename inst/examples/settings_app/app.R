library(shiny)
library(shinyoats)

ui <- fluidPage(
  use_oats(),

  navbar(
    brand = "My App",
    nav_item("Dashboard", href = "#"),
    nav_item("Settings", href = "#", active = TRUE),
    spacer(),
    dropdown("Account", variant = "secondary",
             dropdown_item("Profile"), dropdown_item("Logout"))
  ),

  container(
    fluid = TRUE,
    style = "margin-top: 2rem;",

    h1("Settings"),
    p("Manage your account settings and preferences"),
    divider(),

    tabset(
      id = "settings_tabs",
      labels = c("Profile", "Account", "Notifications", "Privacy", "Appearance"),

      # Profile
      card(
        title = "Profile Settings",
        hstack(
          gap = 4,
          div(style = "flex: 1;",
            textInput("profile_name", "Full Name", value = "John Doe"),
            textInput("profile_email", "Email", value = "john@example.com"),
            textInput("profile_company", "Company", value = "Acme Inc")
          ),
          div(style = "flex: 1;",
            textInput("profile_job", "Job Title", value = "Software Engineer"),
            textInput("profile_phone", "Phone", value = "+1 234 567 8900"),
            selectInput("profile_timezone", "Timezone",
                        choices = c("UTC", "EST", "PST", "GMT"))
          )
        ),
        textAreaInput("profile_bio", "Bio", rows = 3,
                      value = "Passionate about building great software..."),
        footer = hstack(
          gap = 2,
          btn("Cancel", variant = "secondary", outline = TRUE),
          action_btn("save_profile", "Save Changes")
        )
      ),

      # Account
      card(
        title = "Account Security",
        alert("Two-factor authentication is enabled for your account",
              variant = "success"),
        h4("Change Password"),
        shiny::passwordInput("current_password", "Current Password"),
        shiny::passwordInput("new_password", "New Password"),
        shiny::passwordInput("confirm_password", "Confirm New Password"),
        footer = action_btn("update_password", "Update Password")
      ),

      # Notifications
      card(
        title = "Notification Preferences",
        h4("Email Notifications"),
        vstack(
          gap = 2,
          switch_input("notif_email_updates", "Product updates and announcements", TRUE),
          switch_input("notif_email_tips", "Tips and tutorials", TRUE),
          switch_input("notif_email_offers", "Special offers", FALSE)
        ),
        divider(),
        h4("Push Notifications"),
        vstack(
          gap = 2,
          switch_input("notif_push_messages", "New messages", TRUE),
          switch_input("notif_push_comments", "Comments on your posts", TRUE),
          switch_input("notif_push_mentions", "Mentions", TRUE)
        ),
        footer = action_btn("save_notifications", "Save Preferences")
      ),

      # Privacy
      card(
        title = "Privacy Settings",
        h4("Profile Visibility"),
        radioButtons("privacy_profile", NULL,
                     choices = c("Public", "Friends Only", "Private"),
                     selected = "Public"),
        divider(),
        h4("Data Collection"),
        vstack(
          gap = 2,
          switch_input("privacy_analytics", "Share usage analytics", TRUE),
          switch_input("privacy_personalized", "Personalized recommendations", TRUE),
          switch_input("privacy_third_party", "Third-party integrations", FALSE)
        ),
        footer = hstack(
          gap = 2,
          btn("Download My Data", variant = "secondary", outline = TRUE),
          action_btn("save_privacy", "Save Settings")
        )
      ),

      # Appearance
      card(
        title = "Appearance",
        h4("Theme"),
        radioButtons("theme_mode", NULL,
                     choices = c("Light", "Dark", "Auto"),
                     selected = "Light"),
        divider(),
        h4("Display"),
        selectInput("language", "Language",
                    choices = c("English", "Spanish", "French", "German")),
        selectInput("date_format", "Date Format",
                    choices = c("MM/DD/YYYY", "DD/MM/YYYY", "YYYY-MM-DD")),
        footer = action_btn("save_appearance", "Apply Changes")
      )
    )
  )
)

server <- function(input, output, session) {
  observeEvent(input$save_profile, {
    oats_show_toast(session, "Profile updated successfully!", variant = "success")
  })

  observeEvent(input$update_password, {
    if (input$new_password != input$confirm_password) {
      oats_show_toast(session, "Passwords do not match", variant = "danger")
      return()
    }
    oats_show_toast(session, "Password updated successfully!", variant = "success")
  })

  observeEvent(input$save_notifications, {
    oats_show_toast(session, "Notification preferences saved!", variant = "success")
  })

  observeEvent(input$save_privacy, {
    oats_show_toast(session, "Privacy settings updated!", variant = "success")
  })

  observeEvent(input$save_appearance, {
    oats_show_toast(session, "Appearance settings applied!", variant = "success")
  })
}

shinyApp(ui, server)

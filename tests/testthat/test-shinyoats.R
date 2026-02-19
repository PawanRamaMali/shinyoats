# Mock Shiny session for testing
MockShinySession <- R6::R6Class("MockShinySession",
  public = list(
    messages = list(),
    ns = function(id) id,
    sendCustomMessage = function(type, message) {
      self$messages <- c(self$messages, list(list(type = type, message = message)))
      invisible(NULL)
    }
  )
)

# use_oats() ------------------------------------------------------------------

test_that("use_oats() returns tagList with dependencies", {
  result <- use_oats()
  expect_s3_class(result, "shiny.tag.list")
  expect_true(length(result) >= 2)
})

test_that("use_oats() accepts valid theme arguments", {
  expect_no_error(use_oats(theme = "light"))
  expect_no_error(use_oats(theme = "dark"))
  expect_no_error(use_oats(theme = "auto"))
  expect_error(use_oats(theme = "invalid"))
})

# Server functions ------------------------------------------------------------

test_that("oats_show_toast() works with all valid variants", {
  session <- MockShinySession$new()
  expect_no_error(oats_show_toast(session, "test", variant = "info"))
  expect_no_error(oats_show_toast(session, "test", variant = "success"))
  expect_no_error(oats_show_toast(session, "test", variant = "warning"))
  expect_no_error(oats_show_toast(session, "test", variant = "danger"))
  expect_error(oats_show_toast(session, "test", variant = "invalid"))
})

test_that("oats_show_modal() sends correct message", {
  session <- MockShinySession$new()
  expect_no_error(oats_show_modal(session, "my_modal"))
  expect_length(session$messages, 1)
  expect_equal(session$messages[[1]]$message$action, "show")
})

test_that("oats_hide_modal() sends correct message", {
  session <- MockShinySession$new()
  expect_no_error(oats_hide_modal(session, "my_modal"))
  expect_length(session$messages, 1)
  expect_equal(session$messages[[1]]$message$action, "hide")
})

test_that("oats_update_tabs() converts to 0-based index", {
  session <- MockShinySession$new()
  expect_no_error(oats_update_tabs(session, "tabs", selected = 1))
  expect_equal(session$messages[[1]]$message$selected, 0L)
  oats_update_tabs(session, "tabs", selected = 3)
  expect_equal(session$messages[[2]]$message$selected, 2L)
})

test_that("oats_update_progress() sends correct value", {
  session <- MockShinySession$new()
  expect_no_error(oats_update_progress(session, "my_progress", value = 75))
  expect_equal(session$messages[[1]]$message$value, 75)
})

# UI components ---------------------------------------------------------------

test_that("btn() returns a button tag", {
  result <- btn("Click me")
  expect_s3_class(result, "shiny.tag")
  expect_equal(result$name, "button")
})

test_that("btn() applies variant correctly", {
  primary <- btn("X")
  expect_null(primary$attribs$`data-variant`)

  secondary <- btn("X", variant = "secondary")
  expect_equal(secondary$attribs$`data-variant`, "secondary")
})

test_that("btn() applies modifiers correctly", {
  outline_btn <- btn("X", outline = TRUE)
  expect_true(grepl("outline", outline_btn$attribs$class))

  sm_btn <- btn("X", size = "sm")
  expect_true(grepl("small", sm_btn$attribs$class))
})

test_that("card() returns a div with card class", {
  result <- card("Content")
  expect_s3_class(result, "shiny.tag")
  expect_equal(result$attribs$class, "card")
})

test_that("card() includes title as h3 when provided", {
  result <- card("Content", title = "My Card")
  expect_equal(result$children[[1]][[1]]$name, "h3")
})

test_that("alert() returns correct tag with variant", {
  info <- alert("Info message")
  expect_s3_class(info, "shiny.tag")
  expect_null(info$attribs$`data-variant`)

  success <- alert("OK", variant = "success")
  expect_equal(success$attribs$`data-variant`, "success")
})

test_that("badge() returns a span with correct class", {
  b <- badge("New")
  expect_equal(b$name, "span")
  expect_equal(b$attribs$class, "ot-badge")

  b2 <- badge("Beta", variant = "secondary")
  expect_true(grepl("secondary", b2$attribs$class))
})

test_that("hstack() and vstack() return correct tags", {
  h <- hstack(div("a"), div("b"))
  expect_true(grepl("hstack", h$attribs$class))

  v <- vstack(div("a"), div("b"))
  expect_true(grepl("vstack", v$attribs$class))
})

test_that("container() uses correct class", {
  fixed <- container("content")
  expect_equal(fixed$attribs$class, "container")

  fluid <- container("content", fluid = TRUE)
  expect_equal(fluid$attribs$class, "container-fluid")
})

test_that("modal() returns a dialog tag", {
  m <- modal(id = "test_modal", "Body content")
  expect_equal(m$name, "dialog")
  expect_equal(m$attribs$id, "test_modal")
})

test_that("tabset() returns ot-tabs custom element", {
  t <- tabset(labels = c("Tab1", "Tab2"), div("Panel 1"), div("Panel 2"))
  expect_equal(t$name, "ot-tabs")
})

test_that("dropdown() returns ot-dropdown custom element", {
  d <- dropdown("Menu", dropdown_item("Item"))
  expect_equal(d$name, "ot-dropdown")
})

test_that("switch_input() creates a checkbox input", {
  s <- switch_input("my_switch", "Toggle me", value = TRUE)
  # returns hstack wrapping a label
  expect_s3_class(s, "shiny.tag")
})

test_that("progress_bar() calculates percentage correctly", {
  p <- progress_bar(value = 50, max = 200)
  inner <- p$children[[1]]
  expect_true(grepl("25%", inner$attribs$style))
})

test_that("run_oats_demo() accepts all valid examples", {
  valid <- c("minimal", "showcase", "dashboard", "crud", "login", "settings")
  for (ex in valid) {
    app_dir <- system.file("examples", paste0(ex, "_app"), package = "shinyoats")
    expect_true(nchar(app_dir) > 0, info = paste("Missing example:", ex))
  }
})

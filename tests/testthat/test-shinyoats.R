test_that("use_oats() returns tagList with dependencies", {
  result <- use_oats()

  expect_s3_class(result, "shiny.tag.list")
  expect_true(length(result) >= 2)  # At least Oat + shinyoats deps
})

test_that("use_oats() accepts valid theme arguments", {
  expect_no_error(use_oats(theme = "light"))
  expect_no_error(use_oats(theme = "dark"))
  expect_no_error(use_oats(theme = "auto"))
  expect_error(use_oats(theme = "invalid"))
})

test_that("oats_show_toast() requires valid variant", {
  session <- MockShinySession$new()

  expect_no_error(oats_show_toast(session, "test", variant = "info"))
  expect_no_error(oats_show_toast(session, "test", variant = "success"))
  expect_no_error(oats_show_toast(session, "test", variant = "warning"))
  expect_no_error(oats_show_toast(session, "test", variant = "danger"))
  expect_error(oats_show_toast(session, "test", variant = "invalid"))
})

test_that("oats_show_modal() works with valid actions", {
  session <- MockShinySession$new()

  expect_no_error(oats_show_modal(session, "test", action = "show"))
  expect_no_error(oats_show_modal(session, "test", action = "hide"))
  expect_error(oats_show_modal(session, "test", action = "invalid"))
})

test_that("oats_hide_modal() is alias for hide action", {
  session <- MockShinySession$new()
  expect_no_error(oats_hide_modal(session, "test"))
})

test_that("oats_update_tabs() converts to 0-based index", {
  session <- MockShinySession$new()
  expect_no_error(oats_update_tabs(session, "tabs", selected = 1))
  expect_no_error(oats_update_tabs(session, "tabs", selected = 2))
})

# Mock Shiny session for testing
MockShinySession <- R6::R6Class("MockShinySession",
  public = list(
    ns = function(id) id,
    sendCustomMessage = function(type, message) {
      invisible(NULL)
    }
  )
)

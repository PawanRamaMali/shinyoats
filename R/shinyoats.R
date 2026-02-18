#' shinyoats: Oat UI Components for Shiny
#'
#' A lightweight UI library providing 55 ready-to-use components built on the
#' Oat UI framework. Cleaner and faster than shinyfluent, with zero external
#' dependencies beyond Shiny.
#'
#' @keywords internal
"_PACKAGE"

#' @importFrom htmltools htmlDependency tagList tags HTML tag
#' @importFrom jsonlite toJSON
NULL

# Core Setup ------------------------------------------------------------------

#' Initialise Oat UI in a Shiny App
#'
#' Call this once inside your UI, typically as the first element of
#' `fluidPage()`. It attaches the Oat CSS/JS framework and sets the theme.
#'
#' @param theme Character. One of `"light"` (default), `"dark"`, or `"auto"`.
#'   `"auto"` reads the user's OS preference via `prefers-color-scheme`.
#'
#' @return A `tagList` containing the HTML dependencies and a theme script.
#'
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   library(shinyoats)
#'   ui <- fluidPage(use_oats(), h1("Hello"))
#'   server <- function(input, output, session) {}
#'   shinyApp(ui, server)
#' }
#'
#' @export
use_oats <- function(theme = c("light", "dark", "auto")) {
  theme <- match.arg(theme)

  oat_dep <- htmlDependency(
    name = "oat", version = "0.1.0", package = "shinyoats",
    src = "assets/oat", stylesheet = "oat.css", script = "oat.js"
  )

  shiny_dep <- htmlDependency(
    name = "shinyoats", version = "0.1.0", package = "shinyoats",
    src = "assets/shinyoats", script = "shinyoats.js"
  )

  theme_script <- if (theme == "auto") {
    tags$script(HTML(
      'const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
       document.documentElement.setAttribute("data-theme", prefersDark ? "dark" : "light");'
    ))
  } else {
    tags$script(HTML(sprintf('document.documentElement.setAttribute("data-theme", "%s");', theme)))
  }

  tagList(oat_dep, shiny_dep, theme_script)
}

# HTML Elements ---------------------------------------------------------------

#' HTML Heading Elements
#'
#' Wrapper functions for `<h1>` through `<h4>` heading tags.
#'
#' @param ... Child elements or text content passed to the tag.
#' @param id Optional element ID.
#'
#' @return A Shiny tag object.
#'
#' @examples
#' h1("Page Title")
#' h2("Section", id = "section-1")
#'
#' @name headings
#' @export
h1 <- function(..., id = NULL) tags$h1(id = id, ...)

#' @rdname headings
#' @export
h2 <- function(..., id = NULL) tags$h2(id = id, ...)

#' @rdname headings
#' @export
h3 <- function(..., id = NULL) tags$h3(id = id, ...)

#' @rdname headings
#' @export
h4 <- function(..., id = NULL) tags$h4(id = id, ...)

#' HTML Text Elements
#'
#' Wrapper functions for common inline and block text tags.
#'
#' @param ... Child elements or text content.
#' @param id Optional element ID.
#'
#' @return A Shiny tag object.
#'
#' @examples
#' p("A paragraph of text.")
#' span("Inline text", id = "note")
#' div(h2("Title"), p("Body"))
#'
#' @name text_elements
#' @export
p <- function(..., id = NULL) tags$p(id = id, ...)

#' @rdname text_elements
#' @export
span <- function(..., id = NULL) tags$span(id = id, ...)

#' @rdname text_elements
#' @export
div <- function(..., id = NULL) tags$div(id = id, ...)

#' Horizontal Rule
#'
#' Renders a `<hr>` element.
#'
#' @return A Shiny tag object.
#'
#' @examples
#' hr()
#'
#' @export
hr <- function() tags$hr()

#' Inline Formatting Elements
#'
#' Wrapper functions for `<strong>`, `<em>`, `<code>`, and `<pre>` tags.
#'
#' @param ... Child elements or text content.
#'
#' @return A Shiny tag object.
#'
#' @examples
#' strong("Bold text")
#' em("Italic text")
#' code("x <- 1")
#' pre("multi\nline")
#'
#' @name formatting
#' @export
strong <- function(...) tags$strong(...)

#' @rdname formatting
#' @export
em <- function(...) tags$em(...)

#' @rdname formatting
#' @export
code <- function(...) tags$code(...)

#' @rdname formatting
#' @export
pre <- function(...) tags$pre(...)

# Buttons ---------------------------------------------------------------------

#' Button
#'
#' Creates an Oat UI styled button. For a button that triggers Shiny server
#' events use [action_btn()] instead.
#'
#' @param label Character. Button label text.
#' @param ... Additional attributes passed to the `<button>` tag.
#' @param id Optional element ID (used by Shiny to detect clicks as an input).
#' @param variant Character. Visual style: `"primary"` (default),
#'   `"secondary"`, or `"danger"`.
#' @param outline Logical. Render as an outline button. Default `FALSE`.
#' @param ghost Logical. Render as a ghost (transparent) button. Default `FALSE`.
#' @param size Character. Button size: `"md"` (default), `"sm"`, or `"lg"`.
#' @param disabled Logical. Disable the button. Default `FALSE`.
#' @param onclick Character. JavaScript `onclick` handler.
#' @param style Character. Inline CSS styles.
#'
#' @return A Shiny tag object (`<button>`).
#'
#' @examples
#' btn("Save", id = "save_btn")
#' btn("Delete", variant = "danger", outline = TRUE)
#' btn("Small", size = "sm")
#'
#' @export
btn <- function(label, ..., id = NULL, variant = c("primary", "secondary", "danger"),
                outline = FALSE, ghost = FALSE, size = c("md", "sm", "lg"),
                disabled = FALSE, onclick = NULL, style = NULL) {
  variant <- match.arg(variant)
  size <- match.arg(size)

  classes <- character(0)
  if (outline) classes <- c(classes, "outline")
  if (ghost) classes <- c(classes, "ghost")
  if (size == "sm") classes <- c(classes, "small")
  if (size == "lg") classes <- c(classes, "large")

  tag <- tags$button(id = id, label, ...)
  if (length(classes) > 0) tag$attribs$class <- paste(classes, collapse = " ")
  if (variant != "primary") tag$attribs$`data-variant` <- variant
  if (disabled) tag$attribs$disabled <- NA
  if (!is.null(onclick)) tag$attribs$onclick <- onclick
  if (!is.null(style)) tag$attribs$style <- style

  tag
}

#' Shiny Action Button
#'
#' A wrapper around [shiny::actionButton()] styled with Oat UI classes.
#' Use this when you need a button that Shiny tracks as a reactive input.
#'
#' @param inputId Character. The Shiny input ID.
#' @param label Character. Button label text.
#' @param ... Additional arguments passed to [shiny::actionButton()].
#' @param variant Character. Visual variant: `"primary"`, `"secondary"`, etc.
#' @param icon Optional icon element to prepend to the label.
#'
#' @return A Shiny action button tag.
#'
#' @examples
#' action_btn("submit", "Submit Form", variant = "primary")
#'
#' @export
action_btn <- function(inputId, label, ..., variant = "primary", icon = NULL) {
  content <- if (!is.null(icon)) tagList(icon, " ", label) else label
  # Build a plain button with only the "action-button" class that Shiny's JS
  # binding requires — no Bootstrap "btn btn-default" baggage.
  btn_tag <- tags$button(
    id = inputId, type = "button",
    class = "action-button",
    `data-val` = 0L,
    content, ...
  )
  if (variant != "primary") btn_tag$attribs$`data-variant` <- variant
  btn_tag
}

# Cards & Containers ----------------------------------------------------------

#' Card
#'
#' A content card with an optional title and footer. Cards are the primary
#' container for grouping related content.
#'
#' @param ... Content to place inside the card body.
#' @param title Optional character string rendered as an `<h3>` at the top.
#' @param footer Optional content placed in a `<footer>` element at the bottom.
#' @param id Optional element ID.
#' @param style Inline CSS styles applied to the card `<div>`.
#'
#' @return A Shiny tag object (`<div class="card">`).
#'
#' @examples
#' card(
#'   title = "Summary",
#'   p("Card content here."),
#'   footer = btn("OK")
#' )
#'
#' @export
card <- function(..., title = NULL, footer = NULL, id = NULL, style = NULL) {
  content <- list(...)
  if (!is.null(title)) content <- c(list(h3(title)), content)
  if (!is.null(footer)) content <- c(content, list(tags$footer(footer)))
  tags$div(id = id, class = "card", style = style, content)
}

#' Card Sub-Components
#'
#' Helper elements for structuring card content with explicit header, body,
#' and footer regions.
#'
#' @param ... Content to place inside the element.
#'
#' @return A Shiny tag object.
#'
#' @examples
#' div(
#'   card_header(h3("Title")),
#'   card_body(p("Body text")),
#'   card_footer(btn("Action"))
#' )
#'
#' @name card_parts
#' @export
card_header <- function(...) tags$div(class = "card-header", ...)

#' @rdname card_parts
#' @export
card_body <- function(...) tags$div(class = "card-body", ...)

#' @rdname card_parts
#' @export
card_footer <- function(...) tags$footer(class = "card-footer", ...)

# Alerts & Messages -----------------------------------------------------------

#' Alert Banner
#'
#' Displays a contextual alert message. Supports info, success, warning, and
#' danger variants.
#'
#' @param ... Content to display inside the alert.
#' @param variant Character. Alert style: `"info"` (default), `"success"`,
#'   `"warning"`, or `"danger"`.
#' @param dismissible Logical. Add an `×` close button. Default `FALSE`.
#' @param id Optional element ID.
#' @param style Inline CSS styles.
#'
#' @return A Shiny tag object (`<div role="alert">`).
#'
#' @examples
#' alert("Changes saved successfully.", variant = "success")
#' alert("Disk space is low.", variant = "warning", dismissible = TRUE)
#'
#' @export
alert <- function(..., variant = c("info", "success", "warning", "danger"),
                  dismissible = FALSE, id = NULL, style = NULL) {
  variant <- match.arg(variant)

  content <- list(...)
  if (dismissible) {
    content <- c(content, list(
      tags$button(class = "close", onclick = "this.parentElement.remove()", "\u00d7")
    ))
  }

  tag <- tags$div(id = id, role = "alert", style = style, content)
  if (variant != "info") tag$attribs$`data-variant` <- variant
  tag
}

#' Badge
#'
#' A small inline label used to highlight status, counts, or categories.
#'
#' @param label Character. Text displayed inside the badge.
#' @param variant Character. Badge colour: `"primary"` (default),
#'   `"secondary"`, `"success"`, `"warning"`, or `"danger"`.
#' @param id Optional element ID.
#'
#' @return A Shiny tag object (`<span class="badge">`).
#'
#' @examples
#' badge("New")
#' badge("99+", variant = "danger")
#' badge("Stable", variant = "success")
#'
#' @export
badge <- function(label, variant = c("primary", "secondary", "success", "warning", "danger"),
                  id = NULL) {
  variant <- match.arg(variant)
  classes <- if (variant == "primary") "badge" else paste("badge", variant)
  tags$span(id = id, class = classes, label)
}

# Layout ----------------------------------------------------------------------

#' Container
#'
#' A fixed-width (or full-width) layout container that centres its content.
#'
#' @param ... Content elements.
#' @param fluid Logical. If `TRUE` uses `container-fluid` (full width).
#'   Default `FALSE`.
#' @param id Optional element ID.
#'
#' @return A Shiny tag object (`<div class="container">`).
#'
#' @examples
#' container(h1("Title"), p("Body"))
#' container(fluid = TRUE, h1("Full Width"))
#'
#' @export
container <- function(..., fluid = FALSE, id = NULL) {
  class_name <- if (fluid) "container-fluid" else "container"
  tags$div(id = id, class = class_name, ...)
}

#' Grid Row
#'
#' A horizontal row that groups [col()] columns.
#'
#' @param ... [col()] elements or other content.
#' @param id Optional element ID.
#'
#' @return A Shiny tag object (`<div class="row">`).
#'
#' @examples
#' row(
#'   col(6, p("Left")),
#'   col(6, p("Right"))
#' )
#'
#' @export
row <- function(..., id = NULL) {
  tags$div(id = id, class = "row", ...)
}

#' Grid Column
#'
#' A column inside a [row()]. Width is specified in twelfths (1–12).
#'
#' @param width Integer. Column span out of 12. Default `12`.
#' @param ... Content elements.
#' @param id Optional element ID.
#'
#' @return A Shiny tag object (`<div class="col-{width}">`).
#'
#' @examples
#' row(
#'   col(4, card(title = "A")),
#'   col(4, card(title = "B")),
#'   col(4, card(title = "C"))
#' )
#'
#' @export
col <- function(width = 12, ..., id = NULL) {
  tags$div(id = id, class = paste0("col-", width), ...)
}

#' Horizontal Stack
#'
#' Lays out children horizontally using flexbox.
#'
#' @param ... Child elements.
#' @param gap Integer. Gap between children (0–5). Default `2`.
#' @param id Optional element ID.
#'
#' @return A Shiny tag object.
#'
#' @examples
#' hstack(btn("Save"), btn("Cancel", variant = "secondary"))
#' hstack(gap = 4, badge("A"), badge("B"), badge("C"))
#'
#' @export
hstack <- function(..., gap = 2, id = NULL) {
  classes <- paste("hstack", paste0("gap-", gap))
  tags$div(id = id, class = classes, style = "flex-wrap: wrap;", ...)
}

#' Vertical Stack
#'
#' Lays out children vertically using flexbox.
#'
#' @param ... Child elements.
#' @param gap Integer. Gap between children (0–5). Default `2`.
#' @param id Optional element ID.
#'
#' @return A Shiny tag object.
#'
#' @examples
#' vstack(
#'   alert("Step 1 complete", variant = "success"),
#'   alert("Step 2 pending", variant = "warning")
#' )
#'
#' @export
vstack <- function(..., gap = 2, id = NULL) {
  classes <- paste("vstack", paste0("gap-", gap))
  tags$div(id = id, class = classes, ...)
}

#' Flex Spacer
#'
#' A `flex: 1` element that pushes siblings to opposite ends of an [hstack()].
#'
#' @return A Shiny tag object.
#'
#' @examples
#' hstack(span("Left"), spacer(), span("Right"))
#'
#' @export
spacer <- function() {
  tags$div(style = "flex: 1;")
}

#' Divider Line
#'
#' A horizontal rule with standard vertical margin, used to separate sections.
#'
#' @return A Shiny tag object (`<hr>`).
#'
#' @examples
#' vstack(card("Section 1"), divider(), card("Section 2"))
#'
#' @export
divider <- function() {
  tags$hr(style = "margin: 1rem 0;")
}

# Navigation ------------------------------------------------------------------

#' Navigation Bar
#'
#' A top-level navigation bar with an optional brand/logo on the left and
#' navigation items on the right.
#'
#' @param ... Navigation items, typically [nav_item()], [btn()], [dropdown()],
#'   or [spacer()].
#' @param brand Optional character string or tag for the brand/logo area.
#' @param brand_url URL the brand links to. Default `"#"`.
#' @param id Optional element ID.
#'
#' @return A Shiny tag object (`<nav>`).
#'
#' @examples
#' navbar(
#'   brand = "My App",
#'   nav_item("Home", active = TRUE),
#'   nav_item("About"),
#'   spacer(),
#'   dropdown("Account", dropdown_item("Logout"))
#' )
#'
#' @export
navbar <- function(..., brand = NULL, brand_url = "#", id = NULL) {
  brand_elem <- if (!is.null(brand)) {
    tags$a(href = brand_url, class = "navbar-brand", brand)
  }

  tags$nav(
    id = id,
    class = "hstack justify-between p-4",
    style = "background: var(--card); border-bottom: 1px solid var(--border);",
    brand_elem,
    hstack(gap = 2, ...)
  )
}

#' Navigation Link
#'
#' A single link item for use inside [navbar()].
#'
#' @param label Character. Link text.
#' @param href Character. Link URL. Default `"#"`.
#' @param active Logical. Highlight as the current page. Default `FALSE`.
#'
#' @return A Shiny tag object (`<a class="nav-link">`).
#'
#' @examples
#' navbar(
#'   nav_item("Dashboard", active = TRUE),
#'   nav_item("Settings", href = "/settings")
#' )
#'
#' @export
nav_item <- function(label, href = "#", active = FALSE) {
  classes <- if (active) "nav-link active" else "nav-link"
  tags$a(href = href, class = classes, label)
}

#' Sidebar
#'
#' A fixed-width vertical sidebar panel, typically used alongside a main
#' content area.
#'
#' @param ... Content elements, typically a [sidebar_menu()].
#' @param width Integer. Sidebar width in pixels. Default `250`.
#' @param id Optional element ID.
#'
#' @return A Shiny tag object.
#'
#' @examples
#' sidebar(
#'   sidebar_menu(
#'     menu_item("Dashboard", active = TRUE),
#'     menu_item("Settings")
#'   )
#' )
#'
#' @export
sidebar <- function(..., width = 250, id = NULL) {
  tags$div(
    id = id,
    class = "sidebar",
    style = sprintf(
      "width: %dpx; min-height: 100vh; background: var(--card); border-right: 1px solid var(--border); padding: 1rem;",
      width
    ),
    ...
  )
}

#' Sidebar Menu
#'
#' A vertical list of [menu_item()] links inside a [sidebar()].
#'
#' @param ... [menu_item()] elements.
#'
#' @return A Shiny tag object.
#'
#' @examples
#' sidebar_menu(
#'   menu_item("Home", active = TRUE),
#'   menu_item("Reports")
#' )
#'
#' @export
sidebar_menu <- function(...) {
  vstack(gap = 1, ...)
}

#' Sidebar Menu Item
#'
#' A single link inside a [sidebar_menu()].
#'
#' @param label Character. Link text.
#' @param icon Optional icon element prepended to the label.
#' @param href Character. Link URL. Default `"#"`.
#' @param active Logical. Highlight as the current page. Default `FALSE`.
#'
#' @return A Shiny tag object (`<a>`).
#'
#' @examples
#' menu_item("Dashboard", active = TRUE)
#' menu_item("Reports", href = "/reports")
#'
#' @export
menu_item <- function(label, icon = NULL, href = "#", active = FALSE) {
  content <- if (!is.null(icon)) tagList(icon, " ", label) else label
  style <- if (active) {
    "display: block; padding: 0.75rem 1rem; background: var(--primary); color: white; border-radius: var(--radius); text-decoration: none;"
  } else {
    "display: block; padding: 0.75rem 1rem; color: var(--foreground); border-radius: var(--radius); text-decoration: none;"
  }
  tags$a(href = href, style = style, content)
}

# Tables & Lists --------------------------------------------------------------

#' Static HTML Table
#'
#' Renders a `data.frame` as a styled HTML table. For large or interactive
#' tables use the DT package directly.
#'
#' @param data A `data.frame` to display.
#' @param striped Logical. Alternate row shading. Default `TRUE`.
#' @param hover Logical. Highlight rows on hover. Default `TRUE`.
#' @param bordered Logical. Add cell borders. Default `FALSE`.
#' @param id Optional element ID.
#'
#' @return A Shiny tag object (`<table>`).
#'
#' @examples
#' data_table(mtcars[1:5, 1:4])
#' data_table(iris[1:3, ], bordered = TRUE)
#'
#' @export
data_table <- function(data, striped = TRUE, hover = TRUE, bordered = FALSE, id = NULL) {
  if (!is.data.frame(data)) stop("data must be a data.frame")

  classes <- "table"
  if (striped) classes <- paste(classes, "table-striped")
  if (hover) classes <- paste(classes, "table-hover")
  if (bordered) classes <- paste(classes, "table-bordered")

  header <- tags$thead(
    tags$tr(
      lapply(names(data), function(name) tags$th(name))
    )
  )

  body <- tags$tbody(
    lapply(seq_len(nrow(data)), function(i) {
      tags$tr(
        lapply(data[i, ], function(val) tags$td(as.character(val)))
      )
    })
  )

  tags$table(id = id, class = classes, header, body)
}

#' List Group
#'
#' A styled `<ul>` list container. Use with [list_item()].
#'
#' @param ... [list_item()] elements.
#' @param id Optional element ID.
#'
#' @return A Shiny tag object (`<ul class="list-group">`).
#'
#' @examples
#' list_group(
#'   list_item("Apple"),
#'   list_item("Banana", active = TRUE),
#'   list_item("Cherry")
#' )
#'
#' @export
list_group <- function(..., id = NULL) {
  tags$ul(id = id, class = "list-group", ...)
}

#' List Group Item
#'
#' A single `<li>` item inside a [list_group()].
#'
#' @param ... Content of the list item.
#' @param active Logical. Highlight as selected. Default `FALSE`.
#' @param id Optional element ID.
#'
#' @return A Shiny tag object (`<li class="list-group-item">`).
#'
#' @examples
#' list_item("Normal item")
#' list_item("Selected item", active = TRUE)
#'
#' @export
list_item <- function(..., active = FALSE, id = NULL) {
  classes <- if (active) "list-group-item active" else "list-group-item"
  tags$li(id = id, class = classes, ...)
}

# Form Components -------------------------------------------------------------

#' Form Group
#'
#' Wraps a form control with an optional label and help text.
#'
#' @param ... The form control(s) (e.g. `textInput()`).
#' @param label Optional character label displayed above the control.
#' @param help Optional character help text displayed below the control.
#'
#' @return A Shiny tag object (`<div class="form-group">`).
#'
#' @examples
#' form_group(
#'   label = "Username",
#'   help = "Must be at least 3 characters.",
#'   textInput("user", NULL)
#' )
#'
#' @export
form_group <- function(..., label = NULL, help = NULL) {
  content <- list(...)
  if (!is.null(label)) content <- c(list(tags$label(label)), content)
  if (!is.null(help)) content <- c(content, list(tags$small(class = "form-text text-muted", help)))
  tags$div(class = "form-group", content)
}

#' Toggle Switch Input
#'
#' A styled checkbox rendered as a toggle switch. The value is readable in
#' the server via `input[[inputId]]`.
#'
#' @param inputId Character. The Shiny input ID.
#' @param label Optional character label displayed next to the switch.
#' @param value Logical. Initial state (`TRUE` = on). Default `FALSE`.
#'
#' @return A Shiny tag object.
#'
#' @examples
#' switch_input("dark_mode", "Enable dark mode", value = FALSE)
#' switch_input("notifications", "Email notifications", value = TRUE)
#'
#' @export
switch_input <- function(inputId, label = NULL, value = FALSE) {
  wrapper <- tags$label(
    class = "switch",
    tags$input(
      type = "checkbox",
      id = inputId,
      checked = if (value) NA else NULL
    ),
    tags$span(class = "slider")
  )

  if (!is.null(label)) {
    hstack(wrapper, span(label))
  } else {
    wrapper
  }
}

# Progress & Loading ----------------------------------------------------------

#' Progress Bar
#'
#' A horizontal bar showing completion of a task.
#'
#' @param value Numeric. Current value. Default `0`.
#' @param max Numeric. Maximum value. Default `100`.
#' @param label Optional character label displayed inside the bar. If `NULL`,
#'   the percentage is shown.
#' @param variant Character. Colour variant. Default `"primary"`.
#' @param striped Logical. Striped pattern. Default `FALSE`.
#' @param animated Logical. Animate stripes. Default `FALSE`.
#' @param id Optional element ID (required for [oats_update_progress()]).
#'
#' @return A Shiny tag object.
#'
#' @examples
#' progress_bar(value = 65)
#' progress_bar(value = 3, max = 10, label = "Step 3 of 10", variant = "success")
#'
#' @export
progress_bar <- function(value = 0, max = 100, label = NULL, variant = "primary",
                        striped = FALSE, animated = FALSE, id = NULL) {
  percent <- (value / max) * 100
  classes <- paste("progress-bar", variant)
  if (striped) classes <- paste(classes, "progress-bar-striped")
  if (animated) classes <- paste(classes, "progress-bar-animated")

  tags$div(
    id = id,
    class = "progress",
    tags$div(
      class = classes,
      style = sprintf("width: %s%%", percent),
      role = "progressbar",
      `aria-valuenow` = value,
      `aria-valuemin` = 0,
      `aria-valuemax` = max,
      if (!is.null(label)) label else sprintf("%d%%", round(percent))
    )
  )
}

#' Loading Spinner
#'
#' An animated circular loading indicator.
#'
#' @param size Character. Spinner size: `"md"` (default), `"sm"`, or `"lg"`.
#' @param variant Character. Colour variant. Default `"primary"`.
#'
#' @return A Shiny tag object.
#'
#' @examples
#' spinner()
#' spinner(size = "lg", variant = "secondary")
#'
#' @export
spinner <- function(size = "md", variant = "primary") {
  size_class <- switch(size, sm = "spinner-sm", lg = "spinner-lg", "")
  tags$div(
    class = paste("spinner", variant, size_class),
    role = "status"
  )
}

#' Loading Overlay
#'
#' Wraps content with a semi-transparent overlay and spinner while loading.
#' When `show = FALSE` the content is rendered normally with no overlay.
#'
#' @param ... Content to display underneath the overlay.
#' @param show Logical. Show the overlay. Default `TRUE`.
#'
#' @return A Shiny tag object.
#'
#' @examples
#' loading_overlay(show = TRUE, card(p("Content loading...")))
#' loading_overlay(show = FALSE, card(p("Loaded content")))
#'
#' @export
loading_overlay <- function(..., show = TRUE) {
  if (!show) return(tagList(...))

  tags$div(
    style = "position: relative;",
    tags$div(
      style = "position: absolute; top: 0; left: 0; right: 0; bottom: 0; background: rgba(255,255,255,0.8); display: flex; align-items: center; justify-content: center; z-index: 1000;",
      spinner(size = "lg")
    ),
    tags$div(style = "filter: blur(2px); pointer-events: none;", ...)
  )
}

# Tabs & Accordion ------------------------------------------------------------

#' Tabset
#'
#' A tabbed interface powered by the `<ot-tabs>` custom element from Oat UI.
#' Each child element becomes a tab panel; `labels` provides the tab names.
#'
#' @param ... Tab panel content elements. The number of elements must match
#'   `length(labels)`.
#' @param id Optional element ID (required for [oats_update_tabs()]).
#' @param labels Character vector. Tab button labels.
#' @param selected Integer. Index of the initially selected tab. Default `1`.
#'
#' @return A Shiny tag object (`<ot-tabs>`).
#'
#' @examples
#' tabset(
#'   id = "my_tabs",
#'   labels = c("Overview", "Data", "Settings"),
#'   card(p("Overview content")),
#'   card(p("Data content")),
#'   card(p("Settings content"))
#' )
#'
#' @export
tabset <- function(..., id = NULL, labels, selected = 1) {
  panels <- list(...)

  tab_buttons <- lapply(seq_along(labels), function(i) {
    attrs <- list(role = "tab", labels[i])
    if (i == selected) attrs$`aria-selected` <- "true"
    do.call(tags$button, attrs)
  })

  tablist <- tags$div(role = "tablist", tab_buttons)

  tab_panels <- lapply(seq_along(panels), function(i) {
    attrs <- list(role = "tabpanel", panels[[i]])
    if (i != selected) attrs$hidden <- NA
    do.call(tags$div, attrs)
  })

  tag("ot-tabs", c(list(id = id), list(tablist), tab_panels))
}

#' Accordion
#'
#' A container for collapsible [accordion_item()] sections.
#'
#' @param ... [accordion_item()] elements.
#' @param id Optional element ID.
#'
#' @return A Shiny tag object (`<div class="accordion">`).
#'
#' @examples
#' accordion(
#'   accordion_item("Section 1", p("Content one"), open = TRUE),
#'   accordion_item("Section 2", p("Content two"))
#' )
#'
#' @export
accordion <- function(..., id = NULL) {
  tags$div(id = id, class = "accordion", ...)
}

#' Accordion Item
#'
#' A single collapsible section inside an [accordion()].
#'
#' @param title Character. The clickable summary/header text.
#' @param ... Content shown when the item is expanded.
#' @param open Logical. Start expanded. Default `FALSE`.
#' @param id Optional element ID.
#'
#' @return A Shiny tag object (`<details>`).
#'
#' @examples
#' accordion_item("Click to expand", p("Hidden content"), open = FALSE)
#' accordion_item("Already open", p("Visible by default"), open = TRUE)
#'
#' @export
accordion_item <- function(title, ..., open = FALSE, id = NULL) {
  tags$details(
    id = id,
    if (open) list(open = NA) else NULL,
    tags$summary(title),
    tags$div(class = "accordion-content", ...)
  )
}

# Dropdown --------------------------------------------------------------------

#' Dropdown Menu
#'
#' A button that reveals a menu of [dropdown_item()] options when clicked,
#' powered by the `<ot-dropdown>` custom element from Oat UI.
#'
#' @param label Character. Trigger button label.
#' @param ... [dropdown_item()] or [dropdown_divider()] elements.
#' @param variant Character. Trigger button style: `"primary"` (default),
#'   `"secondary"`, or `"danger"`.
#' @param id Optional element ID.
#'
#' @return A Shiny tag object (`<ot-dropdown>`).
#'
#' @examples
#' dropdown("Options",
#'   dropdown_item("Edit"),
#'   dropdown_item("Duplicate"),
#'   dropdown_divider(),
#'   dropdown_item("Delete")
#' )
#'
#' @export
dropdown <- function(label, ..., variant = "primary", id = NULL) {
  variant <- match.arg(variant, c("primary", "secondary", "danger"))

  menu_id <- paste0("ot-menu-", as.integer(runif(1, 1e6, 9e6)))

  trigger <- tags$button(label, popovertarget = menu_id)
  if (variant != "primary") trigger$attribs$`data-variant` <- variant

  menu <- tags$div(id = menu_id, role = "menu", popover = NA, ...)

  tag("ot-dropdown", list(id = id, trigger, menu))
}

#' Dropdown Menu Item
#'
#' A single action button inside a [dropdown()] menu.
#'
#' @param label Character. Item label text.
#' @param ... Additional attributes passed to the `<button>` tag.
#' @param onclick Character. JavaScript `onclick` handler.
#' @param id Optional element ID.
#'
#' @return A Shiny tag object (`<button role="menuitem">`).
#'
#' @examples
#' dropdown("File",
#'   dropdown_item("New"),
#'   dropdown_item("Open"),
#'   dropdown_item("Save")
#' )
#'
#' @export
dropdown_item <- function(label, ..., onclick = NULL, id = NULL) {
  tags$button(id = id, role = "menuitem", onclick = onclick, label, ...)
}

#' Dropdown Divider
#'
#' A visual separator line between [dropdown_item()] groups.
#'
#' @return A Shiny tag object.
#'
#' @examples
#' dropdown("Account",
#'   dropdown_item("Profile"),
#'   dropdown_divider(),
#'   dropdown_item("Logout")
#' )
#'
#' @export
dropdown_divider <- function() {
  tags$div(class = "dropdown-divider")
}

# Modals ----------------------------------------------------------------------

#' Modal Dialog
#'
#' Creates a `<dialog>` element for modal overlays. Show and hide it from the
#' server with [oats_show_modal()] and [oats_hide_modal()].
#'
#' @param ... Body content of the modal.
#' @param id Character. Element ID (**required** for server control).
#' @param title Optional character string rendered as an `<h3>` header.
#' @param size Character. Dialog width: `"md"` (default), `"sm"`, or `"lg"`.
#' @param footer Optional content placed in the modal footer.
#'
#' @return A Shiny tag object (`<dialog>`).
#'
#' @examples
#' modal(
#'   id = "confirm_modal",
#'   title = "Confirm Action",
#'   size = "sm",
#'   p("Are you sure you want to proceed?"),
#'   footer = hstack(
#'     modal_close_btn("Cancel"),
#'     btn("Confirm", variant = "danger")
#'   )
#' )
#'
#' @export
modal <- function(..., id, title = NULL, size = c("md", "sm", "lg"), footer = NULL) {
  size <- match.arg(size)

  content <- list(...)
  if (!is.null(title)) content <- c(list(tags$header(h3(title))), content)
  if (!is.null(footer)) {
    content <- c(content, list(tags$footer(class = "modal-footer", footer)))
  }

  tags$dialog(
    id = id,
    class = paste("modal", paste0("modal-", size)),
    content
  )
}

#' Modal Close Button
#'
#' A ghost-styled button that closes the nearest `<dialog>` element via
#' `this.closest('dialog').close()`.
#'
#' @param label Character. Button label. Default `"Close"`.
#'
#' @return A Shiny tag object.
#'
#' @examples
#' modal(
#'   id = "my_modal",
#'   p("Modal content"),
#'   footer = hstack(modal_close_btn(), btn("Save"))
#' )
#'
#' @export
modal_close_btn <- function(label = "Close") {
  tags$button(
    class = "ghost",
    onclick = "this.closest('dialog').close()",
    label
  )
}

# Server Functions ------------------------------------------------------------

#' Show a Toast Notification
#'
#' Sends a non-blocking toast message to the user's browser.
#'
#' @param session The Shiny `session` object.
#' @param message Character. The main notification text.
#' @param title Optional character. Bold title shown above the message.
#' @param variant Character. Toast style: `"info"` (default), `"success"`,
#'   `"warning"`, or `"danger"`.
#' @param duration Integer. Auto-dismiss delay in milliseconds. Default `4000`.
#'
#' @return Called for its side effect; returns `NULL` invisibly.
#'
#' @examples
#' if (interactive()) {
#'   server <- function(input, output, session) {
#'     observeEvent(input$save_btn, {
#'       oats_show_toast(session, "Saved!", variant = "success")
#'     })
#'   }
#' }
#'
#' @export
oats_show_toast <- function(session, message, title = NULL,
                             variant = c("info", "success", "warning", "danger"),
                             duration = 4000) {
  variant <- match.arg(variant)
  session$sendCustomMessage("shinyoats:toast", list(
    message = message, title = title, variant = variant,
    duration = duration, placement = "top-right"
  ))
}

#' Show a Modal Dialog
#'
#' Programmatically opens a [modal()] element defined in the UI.
#'
#' @param session The Shiny `session` object.
#' @param id Character. The `id` of the [modal()] to open.
#'
#' @return Called for its side effect; returns `NULL` invisibly.
#'
#' @examples
#' if (interactive()) {
#'   server <- function(input, output, session) {
#'     observeEvent(input$open_btn, {
#'       oats_show_modal(session, "my_modal")
#'     })
#'   }
#' }
#'
#' @export
oats_show_modal <- function(session, id) {
  session$sendCustomMessage("shinyoats:updateModal", list(id = session$ns(id), action = "show"))
}

#' Hide a Modal Dialog
#'
#' Programmatically closes a [modal()] element defined in the UI.
#'
#' @param session The Shiny `session` object.
#' @param id Character. The `id` of the [modal()] to close.
#'
#' @return Called for its side effect; returns `NULL` invisibly.
#'
#' @examples
#' if (interactive()) {
#'   server <- function(input, output, session) {
#'     observeEvent(input$cancel_btn, {
#'       oats_hide_modal(session, "my_modal")
#'     })
#'   }
#' }
#'
#' @export
oats_hide_modal <- function(session, id) {
  session$sendCustomMessage("shinyoats:updateModal", list(id = session$ns(id), action = "hide"))
}

#' Switch the Active Tab
#'
#' Programmatically changes the selected tab in a [tabset()].
#'
#' @param session The Shiny `session` object.
#' @param id Character. The `id` of the [tabset()].
#' @param selected Integer. 1-based index of the tab to activate.
#'
#' @return Called for its side effect; returns `NULL` invisibly.
#'
#' @examples
#' if (interactive()) {
#'   server <- function(input, output, session) {
#'     observeEvent(input$go_to_settings, {
#'       oats_update_tabs(session, "main_tabs", selected = 3)
#'     })
#'   }
#' }
#'
#' @export
oats_update_tabs <- function(session, id, selected) {
  session$sendCustomMessage("shinyoats:updateTabs", list(id = session$ns(id), selected = as.integer(selected) - 1L))
}

#' Update a Progress Bar Value
#'
#' Programmatically updates the fill level of a [progress_bar()].
#'
#' @param session The Shiny `session` object.
#' @param id Character. The `id` of the [progress_bar()].
#' @param value Numeric. The new current value.
#'
#' @return Called for its side effect; returns `NULL` invisibly.
#'
#' @examples
#' if (interactive()) {
#'   server <- function(input, output, session) {
#'     observe({
#'       oats_update_progress(session, "upload_progress", value = 75)
#'     })
#'   }
#' }
#'
#' @export
oats_update_progress <- function(session, id, value) {
  session$sendCustomMessage("shinyoats:updateProgress", list(id = session$ns(id), value = value))
}

# Demo Apps -------------------------------------------------------------------

#' Run a shinyoats Example App
#'
#' Launches one of the six bundled demonstration applications to explore
#' components and usage patterns.
#'
#' @param example Character. Which demo to run. One of:
#'   \describe{
#'     \item{`"minimal"`}{Simple starter app showing core components.}
#'     \item{`"showcase"`}{Interactive gallery of all 55 components.}
#'     \item{`"login"`}{Authentication page with validation and toasts.}
#'     \item{`"crud"`}{User management with search, modals, and stats.}
#'     \item{`"settings"`}{Multi-section settings page with tabbed navigation.}
#'     \item{`"dashboard"`}{Analytics dashboard with KPI cards and charts.}
#'   }
#'
#' @return Starts a Shiny app; does not return a value.
#'
#' @examples
#' if (interactive()) {
#'   run_oats_demo("minimal")
#'   run_oats_demo("dashboard")
#' }
#'
#' @export
run_oats_demo <- function(example = c("minimal", "showcase", "dashboard", "crud", "login", "settings")) {
  example <- match.arg(example)
  app_dir <- system.file("examples", paste0(example, "_app"), package = "shinyoats")
  if (app_dir == "") stop("Demo app not found")
  shiny::runApp(app_dir, display.mode = "auto")
}

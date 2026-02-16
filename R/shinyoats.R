#' shinyoats: Oat UI Components for Shiny
#'
#' Complete UI library - cleaner and faster than shinyfluent
#'
#' @docType package
#' @name shinyoats
#' @importFrom htmltools htmlDependency tagList tags HTML
#' @importFrom jsonlite toJSON
NULL

# Core Setup ------------------------------------------------------------------

#' Use Oat UI in Your Shiny App
#' @param theme "light", "dark", or "auto"
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

#' @export
h1 <- function(..., id = NULL) tags$h1(id = id, ...)
#' @export
h2 <- function(..., id = NULL) tags$h2(id = id, ...)
#' @export
h3 <- function(..., id = NULL) tags$h3(id = id, ...)
#' @export
h4 <- function(..., id = NULL) tags$h4(id = id, ...)
#' @export
p <- function(..., id = NULL) tags$p(id = id, ...)
#' @export
span <- function(..., id = NULL) tags$span(id = id, ...)
#' @export
div <- function(..., id = NULL) tags$div(id = id, ...)
#' @export
hr <- function() tags$hr()
#' @export
strong <- function(...) tags$strong(...)
#' @export
em <- function(...) tags$em(...)
#' @export
code <- function(...) tags$code(...)
#' @export
pre <- function(...) tags$pre(...)

# Buttons ---------------------------------------------------------------------

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

#' @export
action_btn <- function(inputId, label, ..., variant = "primary", icon = NULL) {
  content <- if (!is.null(icon)) tagList(icon, " ", label) else label
  shiny::actionButton(inputId, content, class = paste("button", variant), ...)
}

# Cards & Containers ----------------------------------------------------------

#' @export
card <- function(..., title = NULL, footer = NULL, id = NULL, style = NULL) {
  content <- list(...)
  if (!is.null(title)) content <- c(list(h3(title)), content)
  if (!is.null(footer)) content <- c(content, list(tags$footer(footer)))
  tags$div(id = id, class = "card", style = style, content)
}

#' @export
card_header <- function(...) tags$div(class = "card-header", ...)

#' @export
card_body <- function(...) tags$div(class = "card-body", ...)

#' @export
card_footer <- function(...) tags$footer(class = "card-footer", ...)

# Alerts & Messages -----------------------------------------------------------

#' @export
alert <- function(..., variant = c("info", "success", "warning", "danger"),
                  dismissible = FALSE, id = NULL, style = NULL) {
  variant <- match.arg(variant)

  content <- list(...)
  if (dismissible) {
    content <- c(content, list(
      tags$button(class = "close", onclick = "this.parentElement.remove()", "×")
    ))
  }

  tag <- tags$div(id = id, role = "alert", style = style, content)
  if (variant != "info") tag$attribs$`data-variant` <- variant
  tag
}

#' @export
badge <- function(label, variant = c("primary", "secondary", "success", "warning", "danger"),
                  id = NULL) {
  variant <- match.arg(variant)
  classes <- if (variant == "primary") "badge" else paste("badge", variant)
  tags$span(id = id, class = classes, label)
}

# Layout ----------------------------------------------------------------------

#' @export
container <- function(..., fluid = FALSE, id = NULL) {
  class_name <- if (fluid) "container-fluid" else "container"
  tags$div(id = id, class = class_name, ...)
}

#' @export
row <- function(..., id = NULL) {
  tags$div(id = id, class = "row", ...)
}

#' @export
col <- function(width = 12, ..., id = NULL) {
  tags$div(id = id, class = paste0("col-", width), ...)
}

#' @export
hstack <- function(..., gap = 2, id = NULL) {
  classes <- paste("hstack", paste0("gap-", gap))
  tags$div(id = id, class = classes, style = "flex-wrap: wrap;", ...)
}

#' @export
vstack <- function(..., gap = 2, id = NULL) {
  classes <- paste("vstack", paste0("gap-", gap))
  tags$div(id = id, class = classes, ...)
}

#' @export
spacer <- function() {
  tags$div(style = "flex: 1;")
}

#' @export
divider <- function() {
  tags$hr(style = "margin: 1rem 0;")
}

# Navigation ------------------------------------------------------------------

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

#' @export
nav_item <- function(label, href = "#", active = FALSE) {
  classes <- if (active) "nav-link active" else "nav-link"
  tags$a(href = href, class = classes, label)
}

#' @export
sidebar <- function(..., width = 250, id = NULL) {
  tags$div(
    id = id,
    class = "sidebar",
    style = sprintf("width: %dpx; min-height: 100vh; background: var(--card); border-right: 1px solid var(--border); padding: 1rem;", width),
    ...
  )
}

#' @export
sidebar_menu <- function(...) {
  vstack(gap = 1, ...)
}

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
    lapply(1:nrow(data), function(i) {
      tags$tr(
        lapply(data[i, ], function(val) tags$td(as.character(val)))
      )
    })
  )

  tags$table(id = id, class = classes, header, body)
}

#' @export
list_group <- function(..., id = NULL) {
  tags$ul(id = id, class = "list-group", ...)
}

#' @export
list_item <- function(..., active = FALSE, id = NULL) {
  classes <- if (active) "list-group-item active" else "list-group-item"
  tags$li(id = id, class = classes, ...)
}

# Form Components -------------------------------------------------------------

#' @export
form_group <- function(..., label = NULL, help = NULL) {
  content <- list(...)
  if (!is.null(label)) content <- c(list(tags$label(label)), content)
  if (!is.null(help)) content <- c(content, list(tags$small(class = "form-text text-muted", help)))
  tags$div(class = "form-group", content)
}

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

#' @export
spinner <- function(size = "md", variant = "primary") {
  size_class <- switch(size, sm = "spinner-sm", lg = "spinner-lg", "")
  tags$div(
    class = paste("spinner", variant, size_class),
    role = "status"
  )
}

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

  htmltools::tag("ot-tabs", c(list(id = id), list(tablist), tab_panels))
}

#' @export
accordion <- function(..., id = NULL) {
  tags$div(id = id, class = "accordion", ...)
}

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

#' @export
dropdown <- function(label, ..., variant = "primary", id = NULL) {
  variant <- match.arg(variant, c("primary", "secondary", "danger"))

  trigger <- tags$button(label)
  if (variant != "primary") trigger$attribs$`data-variant` <- variant

  menu <- tags$div(role = "menu", ...)

  htmltools::tag("ot-dropdown", list(id = id, trigger, menu))
}

#' @export
dropdown_item <- function(label, ..., onclick = NULL, id = NULL) {
  tags$button(id = id, role = "menuitem", onclick = onclick, label, ...)
}

#' @export
dropdown_divider <- function() {
  tags$div(class = "dropdown-divider")
}

# Modals ----------------------------------------------------------------------

#' @export
modal <- function(..., id, title = NULL, size = c("md", "sm", "lg"), footer = NULL) {
  size <- match.arg(size)

  content <- list(...)
  if (!is.null(title)) content <- c(list(h3(title)), content)
  if (!is.null(footer)) {
    content <- c(content, list(tags$footer(class = "modal-footer", footer)))
  }

  tags$dialog(
    id = id,
    class = paste("modal", paste0("modal-", size)),
    content
  )
}

#' @export
modal_close_btn <- function(label = "Close") {
  tags$button(
    class = "ghost",
    onclick = "this.closest('dialog').close()",
    label
  )
}

# Server Functions ------------------------------------------------------------

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

#' @export
oats_show_modal <- function(session, id) {
  session$sendCustomMessage("shinyoats:updateModal", list(id = session$ns(id), action = "show"))
}

#' @export
oats_hide_modal <- function(session, id) {
  session$sendCustomMessage("shinyoats:updateModal", list(id = session$ns(id), action = "hide"))
}

#' @export
oats_update_tabs <- function(session, id, selected) {
  session$sendCustomMessage("shinyoats:updateTabs", list(id = session$ns(id), selected = as.integer(selected) - 1))
}

#' @export
oats_update_progress <- function(session, id, value) {
  session$sendCustomMessage("shinyoats:updateProgress", list(id = session$ns(id), value = value))
}

# Demo Apps -------------------------------------------------------------------

#' @export
run_oats_demo <- function(example = c("minimal", "showcase", "dashboard", "crud", "login", "settings")) {
  example <- match.arg(example)
  app_dir <- system.file("examples", paste0(example, "_app"), package = "shinyoats")
  if (app_dir == "") stop("Demo app not found")
  shiny::runApp(app_dir, display.mode = "auto")
}

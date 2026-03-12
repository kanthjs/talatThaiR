#' @importFrom httr GET add_headers http_error status_code content
#' @importFrom jsonlite fromJSON
#' @keywords internal
.nabc_fetch_data <- function(path, api_key = NULL, query_params = list()) {
  base_url <- "https://agriapi.nabc.go.th/"
  url <- paste0(base_url, path)

  headers <- c("Content-Type" = "application/json", "Accept" = "application/json")
  if (!is.null(api_key)) {
    headers["Authorization"] <- paste("Bearer", api_key)
  }

  response <- httr::GET(
    url = url,
    httr::add_headers(.headers = headers),
    query = query_params
  )

  if (httr::http_error(response)) {
    stop(
      sprintf("API request failed [%s] for path: %s", httr::status_code(response), path),
      call. = FALSE
    )
  }

  jsonlite::fromJSON(
    httr::content(response, "text", encoding = "UTF-8"),
    flatten = TRUE
  )
}
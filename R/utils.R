#' @importFrom httr GET add_headers http_error status_code content
#' @importFrom jsonlite fromJSON
#' @keywords internal
.nabc_fetch_data <- function(path, api_key = NULL, query_params = list()) {
  base_url <- "https://agriapi.nabc.go.th/"
  path <- sub("^/+", "", path)
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

  parsed <- jsonlite::fromJSON(
    httr::content(response, "text", encoding = "UTF-8"),
    flatten = TRUE
  )

  # jsonlite occasionally coerces numeric columns to character when the API
  # returns mixed types or null values in a column.  type.convert() re-infers
  # each column's type from its content:
  #   - all-numeric strings  -> numeric / integer
  #   - anything else        -> left as character  (as.is = TRUE prevents factor)
  if (is.data.frame(parsed$data) && nrow(parsed$data) > 0) {
    parsed$data <- type.convert(parsed$data, as.is = TRUE)
  }

  parsed
}
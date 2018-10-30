library(rvest)


webpage <- read_html("http://www.chileplanet.eu/database.html")

tbls <- html_nodes(webpage, "table")

head(tbls)

tbls_ls <- webpage %>%
  html_nodes("table") %>%
  html_table(fill = TRUE)
str(tbls_ls)
tbls_ls[[2]]

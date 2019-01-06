library(rvest)
url <- "http://www.foxsports.com/nba/stats?category=SCORING"
nba <- read_html(url) %>% html_nodes("td+ td , td+ td , .wisbb_tableAbbrevLink a , .wisbb_fullPlayer span") %>% html_text()
NBA <- matrix(nba, ncol = 20, byrow = TRUE)[,-2]
lab <- read_html(url) %>% html_nodes(".sorter-ordinal-text , .sorter-digit a") %>% html_text()
lab <- c("Name", "Team", lab[-1])
colnames(NBA) <- lab
name <- strsplit(NBA[,"Name"], split = ", ")
NBA[,"Name"] <- sapply(Map(rev, name), paste, collapse=" ")
NBA <- as.data.frame(NBA, stringsAsFactors = FALSE)
NBA[,3:19] <- lapply(NBA[,3:19], as.numeric)
View(NBA)

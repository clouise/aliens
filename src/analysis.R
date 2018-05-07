library(dplyr)
library(stringi)
library(ggplot2)
library(ggjoy)
library(maps)
library(scales)
setwd("/Users/carmenlouise/Documents/aliens/src")
df <- read_delim("output.txt", delim = "\t", col_names = FALSE, guess_max = 100000)
pop <- read.csv("pops.csv", stringsAsFactors = FALSE)
pop$state <- tolower(pop$state)

df <- filter(df, !grepl("/", df$X3))
colnames(df) <- c("date", "city", "stateabb", "shape", "duration", "summary", "posted")

df$date <- as.POSIXct(df$date, format = "%m/%d/%y %H:%M", tz = "UTC")
df$posted <- as.POSIXct(df$posted, format = "%m/%d/%y", tz = "UTC")

state.info <- as.data.frame(cbind(state.abb, state.area, state.name))
df <- merge(df, state.info, by.x = 'stateabb', by.y = 'state.abb', all.x = TRUE)
df$state.name <- tolower(df$state.name)
df$state.area <- as.numeric(as.character(df$state.area))
df$shape <- str_to_title(df$shape)

df$Year <- format(df$date, "%Y")
df$Month <- format(df$date, "%B")
df$Day <- format(df$date, "%A")
df$Hour <- format(df$date, "%H")

states <- map_data("state")
states <- merge(states, df %>% group_by(state.name, state.area, stateabb) %>% tally(), by.x = "region", by.y = "state.name", all.x = TRUE)
states <- merge(states, pop, by.x = "region", by.y = "state", all.x = TRUE)
states <- states[order(states$order),]
states$reports <- (states$n/states$population)


ggplot(df %>% group_by(shape) %>% tally() %>% arrange(desc(n)) %>% top_n(20, n), aes(x = reorder(shape, n, sum), y = n, fill = shape)) + 
  geom_bar(stat="identity") + z_theme() + xlab("Shape of UFO") + ylab("Number of Documented Reports") + scale_y_continuous(label=comma) + coord_flip() + ggtitle("Shape of UFO")


hourofday <- df %>% group_by(Month, Hour) %>% filter(!is.na(Hour)) %>% tally()
ggplot(hourofday, aes(x=Hour, y=n, group=Month, color=Month)) + geom_line() + z_theme()

area <- states %>% select(region, population, state.area, stateabb, reports) %>% filter(!is.na(state.area)) %>% unique()
ggplot(area, aes(x=reorder(stateabb, reports, sum), y = reports)) + geom_point() + 
  geom_segment(aes(y = mean(area$reports), x = stateabb, yend = reports, xend = stateabb), color = "black") + coord_flip() + 
  xlab("State") + ylab("Percent of Population that has seen UFO") + geom_hline(yintercept=mean(area$reports)) + 
  scale_y_continuous(labels=percent) + z_theme(20)

ggplot(area, aes(x = state.area/population, y = reports)) + geom_point(size=2) + z_theme() + scale_y_continuous(labels = percent)

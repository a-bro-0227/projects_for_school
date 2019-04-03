
#clear workspace
rm(list = ls())


#====Package Bank====
library(data.table) # for efficient reading
library(tidyverse)  # for efficient manipulation
library(readxl)     # for reading in excel files
library(zipcode)    # for zipcode dataframe

#====functions====

#this function allows me to standardize state names
simpleCap <- function(x) {
  s <- strsplit(x, " ")[[1]]
  paste(toupper(substring(s, 1,1)), substring(s, 2),
        sep="", collapse=" ")
}

#====read in membership data====

memberships <- read_excel("F:/School/Tippie_Business Analytics/Analytics Experience/project/data/donor business or individual data for alex.xlsx", sheet = 1)
memberships <- memberships %>%
  rename(gift_amount = `Gift Amount`,
         date = `Date of Gift`,
         donor_type = `Donor Type Descr`,
         zip = Zip) %>%
  mutate(zip = gsub("-.*", "", zip))

#====initial graphs====
memberships %>%
  group_by(donor_type) %>%
  summarise(count = n(),
            gift_mean = mean(gift_amount),
            gift_mode = median(gift_amount))

memberships %>%
  ggplot(aes(x = donor_type, y = gift_amount)) +
  geom_boxplot() +
  scale_y_log10()

memberships %>%
  filter(gift_amount <= 1000) %>%
  ggplot(aes(x = gift_amount)) +
  geom_histogram(bins = 30) +
  scale_x_continuous(breaks = seq(from = 0,
                                  to = 1000,
                                  by = 50))

  



#====map data====
data("zipcode")
states <- map_data("state") %>%
  select(order, state_name = region, long, lat, group) %>%
  mutate(state_name = as.character(sapply(state_name, simpleCap)))

counties <- map_data("county") %>%
  select(order, state_name = region, county = subregion, long, lat, group) %>%
  mutate(state_name = as.character(sapply(state_name, simpleCap)),
         county = as.character(sapply(county, simpleCap)))

state_index <- data.frame(abbr = state.abb, state_name = state.name) %>%
  mutate_all(funs(as.character(.)))


memberships <- memberships %>%
  left_join(zipcode,
            by = "zip") %>%
  left_join(., state_index,
            by = c("state" = "abbr"))

member_state <- states %>%
  left_join(memberships,
            by = c("state_name"))

member_state %>%
  ggplot(aes(x = long, y = lat)) +
  geom_path(aes(group = group)) +    #for boarders
  geom_polygon(aes(group = group,    #for fill
                   fill = !is.na(state))) +    #what to fill
  ggthemes::theme_map()


member_state %>%
  filter(state == "Iowa") %>%
  ggplot(aes(x = long, y = lat)) +
  geom_polygon() +
  coord_map() +
  geom_point(data = memberships, aes(x = longitude, y = latitude, size = gift_amount), color = "orange")


zipcode %>%
  ggplot(aes(x = longitude, y = latitude)) +
  geom_path(aes(group = city))
  

counties %>%
  ggplot(aes(x = long, y = lat)) +
  geom_path(aes(group = group)) +    #for boarders
  # geom_polygon(aes(group = group,    #for fill
  #                  fill = subregion == "story")) +    #what to fill
  ggthemes::theme_map()

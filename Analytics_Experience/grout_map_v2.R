

library(zipcode)
library(maps)


data("zipcode")
us_map <- map_data("state")



donations_zip <- donations %>%
  filter(!is.na(zip)) %>%
  group_by(zip, donor_type) %>%
  summarize(donor_count = n(),
            gift_total = sum(gift_amount)) %>%
  left_join(zipcode, by = "zip")

state_center <- read.csv("F:/School/Tippie_Business Analytics/Analytics Experience/project/data/state_latlon.csv", stringsAsFactors = F) %>%
  inner_join(donations_zip %>%
               ungroup() %>%
               distinct(state),
             by = "state")

donations_zip %>%
ggplot(aes(x = longitude, y = latitude)) +
  geom_polygon(data=us_map,
               aes(x = long, y = lat, group = group),
               color='gray', fill = NA, alpha = 0.35)+
  geom_point(aes(color = donor_type, size = donor_count), alpha = 0.25) +
  geom_text(aes(x = longitude, y = latitude, label = state),
            data= state_center,
            alpha = 1,
            color = "black",
            size = 2.5) +
  theme(axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank()) +
  scale_size_continuous(labels = comma) +
  ggtitle("Count of Donors by Zipcode") +
  labs(size = "Donor Count", colour = "Donor Type")

donations_zip %>%
  ggplot(aes(x = longitude, y = latitude)) +
  geom_polygon(data=us_map,
               aes(x = long, y = lat, group = group),
               color='gray', fill = NA, alpha = 0.35)+
  geom_point(aes(color = donor_type, size = gift_total), alpha = 0.25) +
  geom_text(aes(x = longitude, y = latitude, label = state),
            data= state_center,
            alpha = 1,
            color = "black",
            size = 2.5) +
  theme(axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank()) +
  scale_size_continuous(labels = dollar_format(prefix = "$")) +
  ggtitle("Gift Amount Donated by Zipcode") +
  labs(size = "Gift Amount", colour = "Donor Type")


donations %>%
  mutate(quarter = paste0(gsub("\\..*", "", quarter(date, with_year = T)),
                          ".Qtr ",
                          gsub(".*\\.", "", quarter(date, with_year = T))))

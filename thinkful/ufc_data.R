# clear workspace
rm(list = ls())

# library bank ------------------------------------------------------------

library(tidyverse)
library(data.table)

# read in files -----------------------------------------------------------

data <- fread("G:/Kaggle/data.csv", na.strings = "")
preprocessed_data <- fread("G:/Kaggle/preprocessed_data.csv", na.strings = "")
raw_fighter_details <- fread("G:/Kaggle/raw_fighter_details.csv", na.strings = "")
raw_total_fight_data <- fread("G:/Kaggle/raw_total_fight_data.csv", na.strings = "")


fight <- data %>%
  select(R_fighter, B_fighter, ref = Referee, date,
         location, winner = Winner, title_bout, weight_class,
         no_of_rounds) %>%
  mutate(fight_id = paste(gsub(" ", "_", R_fighter), "v", gsub(" ", "_", B_fighter), date, sep = "_"))

fight_detail <- data %>%
  mutate(fight_id = paste(gsub(" ", "_", R_fighter), "v", gsub(" ", "_", B_fighter), date, sep = "_")) %>% 
  select(-c(R_fighter, B_fighter, ref = Referee, date,
         location, winner = Winner, title_bout, weight_class,
         no_of_rounds)) %>% 
  gather(key = "column", value = "value", -fight_id) %>% 
  separate(col = column, into = c("color", "column"), sep = 2) %>% 
  mutate(color = gsub("_", "", color)) %>% 
  filter(!(column %in% c("wins", "Stance", "Height_cms", "Reach_cms", "Weight_lbs", "age"))) %>% 
  distinct() %>% 
  spread(key = column, value = value)
  

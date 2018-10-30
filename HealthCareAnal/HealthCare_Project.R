#clear workspace
rm(list = ls())

#====library bank====
suppressMessages(library(tidyverse, warn.conflicts = F, quietly = T))
library(RODBC)
library(lubridate, warn.conflicts = F)
library(scales, warn.conflicts = F)

access_database <- paste0("F:/School/Tippie_Business Analytics/Health Care Analytics", "/openmrs.accdb")
#====reading in dataset====
openmrs <- odbcDriverConnect(paste0("Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=",
                                    access_database))
mrs_patient <- sqlFetch(openmrs, "mrs_patient",
                        as.is = FALSE,
                        stringsAsFactors = FALSE,
                        na.strings = c("", "N/A")) %>%
  filter(!is.na(birthdate)) %>%
  select(patient_id,
         gender,
         birthdate,
         birthdate_estimated,
         tribe_id = tribe,
         given_name,
         middle_name,
         family_name,
         city_village,
         country)

mrs_obs <- sqlFetch(openmrs, "mrs_obs",
                    as.is = F,
                    stringsAsFactors = FALSE,
                    na.strings = c("", "N/A")) %>%
  select(obs_id,
         patient_id,
         encounter_id,
         order_id,
         concept_id,
         obs_datetime,
         value_coded,
         value_drug,
         value_datetime,
         value_numeric,
         comments)


mrs_concept <- sqlFetch(openmrs, "mrs_concept",
                        as.is = F,
                        stringsAsFactors = FALSE,
                        na.strings = c("", "N/A")) %>%
  select(concept_id,
         concept_name,
         retired,
         short_name,
         description,
         datatype,
         concept_class,
         is_set,
         hi_absolute,
         hi_critical,
         hi_normal,
         low_absolute,
         low_critical,
         low_normal,
         units,
         precise)

mrs_encounter <- sqlFetch(openmrs, "mrs_encounter",
                          as.is = F,
                          stringsAsFactors = FALSE,
                          na.strings = c("", "N/A")) %>%
  select(encounter_id,
         encounter_type_id = encounter_type,
         patient_id)
  

mrs_encounter_type <- sqlFetch(openmrs, "mrs_encounter_type",
                               as.is = F,
                               stringsAsFactors = FALSE,
                               na.strings = c("", "N/A")) %>%
  select(encounter_type_id,
         encounter_type_name = name,
         encounter_description = description)

mrs_tribe <- sqlFetch(openmrs, "mrs_tribe",
                      as.is = F,
                      stringsAsFactors = FALSE,
                      na.strings = c("", "N/A")) %>%
  select(tribe_id, tribe_name = name)

mrs_program <- sqlFetch(openmrs, "mrs_program",
                        as.is = F,
                        stringsAsFactors = FALSE,
                        na.strings = c("", "N/A")) %>%
  select(program_id, program_name = name)

mrs_patient_program <- sqlFetch(openmrs, "mrs_patient_program",
                                as.is = F,
                                stringsAsFactors = FALSE,
                                na.strings = c("", "N/A")) %>%
  filter(voided != 1) %>%                                        #filter out voided #gets rid of duplicates
  select(patient_program_id,
         patient_id,
         program_id,
         date_enrolled,
         date_completed)


#====analysis files====

#====encounter anlaysis====
#We will create a table which combines encounter and encounter type by joining
#`mrs_encounter` with `mrs_encounter_type`.
df_encounter <- mrs_encounter %>%
  left_join(y = mrs_encounter_type %>% select(-encounter_description),
            by = "encounter_type_id")

#We can now do a quick review of the encounter types by creating a bar graph
#count(df_encounter, encounter_type_name) %>%            #counts the number of encounter types
df_encounter %>%
  count(encounter_type_name) %>%
  ggplot(aes(x = encounter_type_name, y = n)) +    #graphs the number of encounter types
  geom_bar(stat = "identity") +                                          #with a bar graph
  geom_text(aes(label = comma(n)),
            position = position_dodge(0.9),
            vjust = -0.3) +
  ggtitle("Count of Encounter Types") +
  xlab("Encounter Type") +
  ylab("Count of Encounters") + scale_y_continuous(labels = comma) +
  theme(plot.title = element_text(face = "bold"))
  

#We can see that there are not many `INITIAL` encounters not many
#`PEDS` encounter types. Since this is the case, we will remove those
#types of encounters and keep only the `ADULTRETURN`.
df_encounter <- df_encounter %>%
  filter(encounter_type_name != "ADULTINITIAL" & encounter_type_name != "PEDSRETURN")

#Now we want to counts the number of return types for each patient.
#This will give us a sense of how many times pateint's returned
#I first did this without removing the `ADULTINITIAL` and `PEDSRETURN`
#and found that there was duplicate `ADULTINITAL` entries for the same patient.
count_patient_return <- df_encounter %>% count(patient_id, encounter_type_name)

count_patient_return %>%
ggplot(aes(x = n)) +
  geom_histogram(bins = max(count_patient_return$n)) +
  ggtitle("Frequency of Patients Returning") +
  xlab("Number of Returns") + scale_x_continuous(breaks = round(seq(min(count_patient_return$n),
                                                                    max(count_patient_return$n), by = 1),1)) +
  ylab("Frequency of Patients") + scale_y_continuous(labels = comma) +
  theme(plot.title = element_text(face = "bold"))

count_patient_return %>% count(n)

#====program analysis====
#this table combines the patient-program table with with some basic
#patient information and some program information
#so we can do some simple analysis. In addtion I have added if they
#are and 'ADULT' or 'PEDS' to determin outlires.I have already removed `PEDS`
#in the `df_encouter` table so to keep our data consistent, we will do it here as well
#in addtion, there is
sum(is.na(mrs_patient_program$date_enrolled))/nrow(mrs_patient_program)
#of patients who were never enrolled. These will put a damper on any time analysis
#we want to do, so we will remove them now. Per (the book), if over 10% of people
#needed in the study confirm to be in the program, we are in good shape.
df_program <- mrs_patient_program %>%
  left_join(y = mrs_patient %>% select(patient_id, gender, birthdate),
            by = "patient_id") %>%
  left_join(., y = mrs_program,
            by = "program_id") %>%
  mutate(age_started = time_length(difftime(date_enrolled, birthdate), "years"),
         yrs_enrolled = time_length(difftime(Sys.Date(), date_enrolled), "years")) %>%
  left_join(., y = df_encounter %>%
              mutate(encounter_type_name = gsub("RETURN|INITIAL", "", encounter_type_name)) %>%
              distinct(patient_id, encounter_type_name),
            by = "patient_id") %>%
  #remove explaination
  filter(!is.na(encounter_type_name) & !is.na(date_enrolled) & is.na(date_completed)) %>%
  select(-date_completed)


x <- df_encounter %>% mutate(encounter_type_name = gsub("RETURN|INITIAL", "", encounter_type_name)) %>%
  distinct(patient_id, encounter_type_name)
x[duplicated(x$patient_id) | duplicated(x$patient_id, fromLast = T), ]

#graph of above
df_program %>%
  count(program_name) %>%
  ggplot(aes(x = program_name, y = n)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = comma(n)),
            position = position_dodge(0.9),
            vjust = -0.3) +
  ggtitle("Count of Patients in Each Program") +
  xlab("Program Name") +
  ylab("Count in Program") + scale_y_continuous(labels = comma) +
  theme(plot.title = element_text(face = "bold"))


#this table identifies how many patient
#are admitted to both programs
df_program_in <- df_program %>%
  count(patient_id, program_name) %>%
  spread(key = program_name, value = n) %>%
  mutate(program_in = ifelse(!is.na(`HIV Program`) & is.na(`TB Program`), "HIV Program",
                             ifelse(is.na(`HIV Program`) & !is.na(`TB Program`), "TB Program",
                                    ifelse(!is.na(`HIV Program`) & !is.na(`TB Program`), "Both Programs",
                                           "Review")))) %>%
  select(patient_id, program_in)

#graph of above
df_program_in %>%
  count(program_in) %>%
  ggplot(aes(x = program_in, y = n)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = comma(n)),
            position = position_dodge(0.9),
            vjust = -0.3) +
  ggtitle("Count of Patients in Each & Both Programs") +
  xlab("Program Name") +
  ylab("Count in Program") + scale_y_continuous(labels = comma) +
  theme(plot.title = element_text(face = "bold"))

#weed down to only `HIV Program`
df_program <- df_program %>%
  left_join(df_program_in, by = "patient_id") %>%
  filter(program_in != "Both Programs" & program_in != "TB Program")

df_program %>%
  count(gender) %>%
  ggplot(aes(x = gender, y = n, fill = gender)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = comma(n)),
            position = position_dodge(0.9),
            vjust = -0.3) +
  ggtitle("Count of Gender Types") +
  xlab("Gender") +
  ylab("Count") + scale_y_continuous(labels = comma) +
  theme(plot.title = element_text(face = "bold"))


df_program %>%
  ggplot(aes(x = gender, y = age_started)) +
  geom_boxplot() +
  ggtitle("Age by Gender") +
  xlab("Gender") +
  ylab("Age") +
  theme(plot.title = element_text(face = "bold"))

df_program %>%
  ggplot(aes(x = gender, y = yrs_enrolled)) +
  geom_boxplot() +
  ggtitle("Years Enrolled by Gender") +
  xlab("Gender") +
  ylab("Years")
theme(plot.title = element_text(face = "bold"))

#remove people over 60 and that have not been enrolled more than 10 Years
df_program %>% mutate(outlier = )


count_patient_return %>%
  ggplot(aes(x = n)) +
  geom_histogram(bins = max(count_patient_return$n)) +
  ggtitle("Frequency of Patients Returning") +
  xlab("Number of Returns") + scale_x_continuous(breaks = round(seq(min(count_patient_return$n),
                                                                    max(count_patient_return$n), by = 1),1)) +
  ylab("Frequency of Patients") + scale_y_continuous(labels = comma) +
  theme(plot.title = element_text(face = "bold"))
#====patient anlaysis====
#this table adds some basic information
#to the patient table such as "tribe"
#and what program they are in
df_patient <- mrs_patient %>%
  mutate()
  left_join(y = mrs_tribe,
            by = "tribe_id") %>%
  left_join(., y = df_program_in,
            by = "patient_id") %>%
  filter(is.na(program_in) | program_in != "Both Programs" & program_in != "TB Program")
  

#counts
data.frame(count(df_patient,                 #counts the number of patients
                 tribe_name, program_in)) %>%  #by tribe in each program
  spread(key = program_in, value = n)

#graphs
ggplot(df_patient, aes(x = tribe_name)) + geom_bar()   #bargraph of how many patients in each tribe
ggplot(df_patient, aes(x = program_in)) + geom_bar()   #bargraph of how many patients in each program (as above)
ggplot(df_patient, aes(x = program_in)) + geom_bar() + #bargraph of how many patients in each program
  facet_wrap( ~ tribe_name)                              #broken out by tribe

#====obs anlaysis====
#this table combines mrs_obs with concept information
#we need to use concept for the action and for
#the answer to the action
df_obs <- mrs_obs %>%
  left_join(y = mrs_concept,
            by = "concept_id") %>%
  left_join(., y = mrs_concept %>% select(concept_id, ans_name = concept_name,
                                          ans_description = description, ans_datatype = datatype,
                                          ans_class = concept_class, ans_set = is_set),
            by = c("value_coded" = "concept_id")) %>%
  left_join(., y = df_encounter,
            by = c("patient_id", "encounter_id"))


#counts
data.frame(count(df_obs, concept_class))
data.frame(count(df_obs %>% filter(concept_class == "Finding"), ans_name))
data.frame(count(df_obs, concept_name))

#table to invetigate stages
df_stage <- df_obs %>%
  filter(concept_class == "Finding", grepl("STAGE", ans_name)) %>%
  select(obs_datetime, patient_id, stage = ans_name) %>%
  mutate(patient_type = ifelse(grepl("ADULT", stage), "ADULT", "PED"))

#counts
count(df_stage, stage)

#graph
ggplot(df_stage, aes(x = stage)) + geom_bar() + facet_wrap( ~ patient_type)

#table which counts how many times each patient
#was in each stage
count_by_stage <- df_stage %>%
  count(patient_id, ans_name) %>%
  spread(key = stage, value = n)

#table to see if patient changed stages
count_stage_change <- df_stage %>%
  count(patient_id, stage) %>%
  count(patient_id)

#====write DB files - proper====
write.csv(df_encounter %>% select(-encounter_type_name),
          paste0("F:/School/Tippie_Business Analytics/Health Care Analytics/Project/newDB_v2",
                 "/df_encounter.csv"), row.names = F, na = "")
write.csv(mrs_encounter_type,
          paste0("F:/School/Tippie_Business Analytics/Health Care Analytics/Project/newDB_v2",
                 "/mrs_encounter_type.csv"), row.names = F, na = "")



#====write DB files - clean====
write.csv(df_encounter %>% select(-encounter_type_id),
          paste0("F:/School/Tippie_Business Analytics/Health Care Analytics/Project/newDB_clean",
                 "/df_encounter.csv"), row.names = F, na = "")




#====write DB files====
write.csv(mrs_concept, paste0("F:/School/Tippie_Business Analytics/Health Care Analytics/Project/newDB", "/mrs_concept.csv"), row.names = F, na = "")
write.csv(mrs_encounter, paste0("F:/School/Tippie_Business Analytics/Health Care Analytics/Project/newDB", "/mrs_encounter.csv"), row.names = F, na = "")
write.csv(mrs_encounter_type, paste0("F:/School/Tippie_Business Analytics/Health Care Analytics/Project/newDB", "/mrs_encounter_type.csv"), row.names = F, na = "")
write.csv(mrs_obs, paste0("F:/School/Tippie_Business Analytics/Health Care Analytics/Project/newDB", "/mrs_obs.csv"), row.names = F, na = "")
write.csv(mrs_patient, paste0("F:/School/Tippie_Business Analytics/Health Care Analytics/Project/newDB", "/mrs_patient.csv"), row.names = F, na = "")
write.csv(mrs_patient_program, paste0("F:/School/Tippie_Business Analytics/Health Care Analytics/Project/newDB", "/mrs_patient_program.csv"), row.names = F, na = "")
write.csv(mrs_program, paste0("F:/School/Tippie_Business Analytics/Health Care Analytics/Project/newDB", "/mrs_program.csv"), row.names = F, na = "")
write.csv(mrs_tribe, paste0("F:/School/Tippie_Business Analytics/Health Care Analytics/Project/newDB", "/mrs_tribe.csv"), row.names = F, na = "")
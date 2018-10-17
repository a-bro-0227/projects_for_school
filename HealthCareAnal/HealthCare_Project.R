#clear workspace
rm(list = ls())

#====library bank====
suppressMessages(library(tidyverse, warn.conflicts = F, quietly = T))
library(ggplot2)
library(RODBC)
library(lubridate, warn.conflicts = F)

#====read in dataset====
openmrs <- odbcDriverConnect("Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=F:/School/Tippie_Business Analytics/Health Care Analytics/openmrs.accdb")

mrs_patient <- sqlFetch(openmrs, "mrs_patient", as.is = FALSE, stringsAsFactors = FALSE, na.strings = c("", "N/A")) %>%
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
         country) %>%
  mutate(outlier = ifelse(is.na(country), 0, 1)) #only one person from USA #other from kenya

mrs_obs <- sqlFetch(openmrs, "mrs_obs", as.is = F, stringsAsFactors = FALSE, na.strings = c("", "N/A")) %>%
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


mrs_concept <- sqlFetch(openmrs, "mrs_concept", as.is = F, stringsAsFactors = FALSE, na.strings = c("", "N/A")) %>%
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

mrs_encounter <- sqlFetch(openmrs, "mrs_encounter", as.is = F, stringsAsFactors = FALSE, na.strings = c("", "N/A")) %>%
  select(encounter_id, encounter_type_id = encounter_type, patient_id)
  

mrs_encounter_type <- sqlFetch(openmrs, "mrs_encounter_type", as.is = F, stringsAsFactors = FALSE, na.strings = c("", "N/A")) %>%
  select(encounter_type_id, encounter_type_name = name, encounter_description = description)

mrs_tribe <- sqlFetch(openmrs, "mrs_tribe", as.is = F, stringsAsFactors = FALSE, na.strings = c("", "N/A")) %>%
  select(tribe_id, tribe_name = name)

mrs_program <- sqlFetch(openmrs, "mrs_program", as.is = F, stringsAsFactors = FALSE, na.strings = c("", "N/A")) %>%
  select(program_id, program_name = name)

mrs_patient_program <- sqlFetch(openmrs, "mrs_patient_program", as.is = F, stringsAsFactors = FALSE, na.strings = c("", "N/A")) %>%
  filter(voided != 1) %>% #filter out voided #gets rid of duplicates
  select(patient_program_id, patient_id, program_id, date_enrolled, date_completed) %>%
  mutate(outlier = ifelse(!is.na(date_completed), 1, 0)) #outlier based on complete date #only one person has completed


#====program breakdown====

#====encounter anlaysis====
#this table combines encounter and encounter type
comb_encounter <- mrs_encounter %>%
  left_join(y = mrs_encounter_type,
            by = "encounter_type_id")
#counts
data.frame(count(comb_encounter, encounter_type_name))  #counts the number of encounter types

#graphs
ggplot(comb_encounter, aes(x = encounter_type_name)) + geom_bar()

#this table counts the number of return types for each patient
#here we can get a sense of how many times pateint's returned
#and if there is any mistakes on the "initial" documentation
count_patient_return <- count(comb_encounter, patient_id, encounter_type_name)


#we will need to add this back into the mrs_encounter to
#identify outliers
mrs_encounter <- mrs_encounter %>%
  left_join(y = count_patient_return %>%
              filter(grepl("INITIAL", encounter_type_name) & n > 1),
            by = "patient_id") %>%
  mutate(outlier = ifelse(grepl("INITIAL", encounter_type_name) & n > 1, 1, 0 )) %>%
  select(-c(encounter_type_name, n))

#the below graph with give us a visual how many times
#patients were returning
#it is a histo gram of patient returns
ggplot(count_patient_return %>%                        
         filter(encounter_type_name != "ADULTINITIAL"),
       aes(x = n)) +
  geom_histogram(bins = 5)

#====program analysis====
#this table combines the patient-program table with with some basic
#patient information and some program information
#so we can do some simple analysis. In addtion I have added if they
#are and 'ADULT' or 'PEDS' to determin outlires
comb_program <- mrs_patient_program %>%
  left_join(y = mrs_patient %>% select(patient_id, gender, birthdate),
            by = "patient_id") %>%
  left_join(., y = mrs_program,
            by = "program_id") %>%
  mutate(age_started = time_length(difftime(date_enrolled, birthdate), "years"),
         age_current = time_length(difftime(Sys.Date(), birthdate), "years")) %>%
  left_join(., y = comb_encounter %>%
              mutate(encounter_type_name = gsub("RETURN|INITIAL", "", encounter_type_name)) %>%
              distinct(patient_id, encounter_type_name),
            by = "patient_id") %>%
    filter(age_current > 18 & encounter_type_name != "PEDS")



#counts
data.frame(count(comb_program, program_name))  #counts the number of patients in each program

data.frame(count(comb_program,                 #counts the number of patients
                 program_name, gender)) %>%    #by gender in each program
  spread(key = gender, value = n)

#graphs
ggplot(comb_program, aes(x = program_name)) + geom_bar()   #bargraph of how many patients in each program

ggplot(comb_program, aes(x = program_name)) + geom_bar() + #bargraph of how many patients in each program
  facet_wrap( ~ gender)                                    #by gender



#this table identifies how many patient
#are admitted to both programs
comb_program_in <- comb_program %>%
  count(patient_id, program_name) %>%
  spread(key = program_name, value = n) %>%
  mutate(program_in = ifelse(!is.na(`HIV Program`) & is.na(`TB Program`), "HIV Program",
                             ifelse(is.na(`HIV Program`) & !is.na(`TB Program`), "TB Program",
                                    ifelse(!is.na(`HIV Program`) & !is.na(`TB Program`), "Both Programs",
                                           "Review")))) %>%
  select(patient_id, program_in)

#counts
data.frame(count(comb_program_in, program_in)) #counts the number of patients in each program and/or both programs

#graphs
ggplot(comb_program_in, aes(x = program_in)) + geom_bar()  #bargraph of how many patients in each program and/or both programs


#====patient anlaysis====
#this table adds some basic information
#to the patient table such as "tribe"
#and what program they are in
comb_patient <- mrs_patient %>%
  left_join(y = mrs_tribe,
            by = "tribe_id") %>%
  left_join(., y = comb_program_in,
            by = "patient_id")

#counts
data.frame(count(comb_patient,                 #counts the number of patients
                 tribe_name, program_in)) %>%  #by tribe in each program
  spread(key = program_in, value = n)

#graphs
ggplot(comb_patient, aes(x = tribe_name)) + geom_bar()   #bargraph of how many patients in each tribe
ggplot(comb_patient, aes(x = program_in)) + geom_bar()   #bargraph of how many patients in each program (as above)
ggplot(comb_patient, aes(x = program_in)) + geom_bar() + #bargraph of how many patients in each program
  facet_wrap( ~ tribe_name)                              #broken out by tribe

#====obs anlaysis====
#this table combines mrs_obs with concept information
#we need to use concept for the action and for
#the answer to the action
comb_obs <- mrs_obs %>%
  left_join(y = mrs_concept,
            by = "concept_id") %>%
  left_join(., y = mrs_concept %>% select(concept_id, ans_name = concept_name,
                                          ans_description = description, ans_datatype = datatype,
                                          ans_class = concept_class, ans_set = is_set),
            by = c("value_coded" = "concept_id")) %>%
  left_join(., y = comb_encounter,
            by = c("patient_id", "encounter_id"))


#counts
data.frame(count(comb_obs, concept_class))
data.frame(count(comb_obs %>% filter(concept_class == "Finding"), ans_name))
data.frame(count(comb_obs, concept_name))

#table to invetigate stages
comb_stage <- comb_obs %>%
  filter(concept_class == "Finding", grepl("STAGE", ans_name)) %>%
  select(obs_datetime, patient_id, stage = ans_name) %>%
  mutate(patient_type = ifelse(grepl("ADULT", stage), "ADULT", "PED"))

#counts
count(comb_stage, stage)

#graph
ggplot(comb_stage, aes(x = stage)) + geom_bar() + facet_wrap( ~ patient_type)

#table which counts how many times each patient
#was in each stage
count_by_stage <- comb_stage %>%
  count(patient_id, ans_name) %>%
  spread(key = stage, value = n)

#table to see if patient changed stages
count_stage_change <- comb_stage %>%
  count(patient_id, stage) %>%
  count(patient_id)


write.csv(mrs_concept, paste0("F:/School/Tippie_Business Analytics/Health Care Analytics/Project/newDB", "/mrs_concept.csv"), row.names = F, na = "")
write.csv(mrs_encounter, paste0("F:/School/Tippie_Business Analytics/Health Care Analytics/Project/newDB", "/mrs_encounter.csv"), row.names = F, na = "")
write.csv(mrs_encounter_type, paste0("F:/School/Tippie_Business Analytics/Health Care Analytics/Project/newDB", "/mrs_encounter_type.csv"), row.names = F, na = "")
write.csv(mrs_obs, paste0("F:/School/Tippie_Business Analytics/Health Care Analytics/Project/newDB", "/mrs_obs.csv"), row.names = F, na = "")
write.csv(mrs_patient, paste0("F:/School/Tippie_Business Analytics/Health Care Analytics/Project/newDB", "/mrs_patient.csv"), row.names = F, na = "")
write.csv(mrs_patient_program, paste0("F:/School/Tippie_Business Analytics/Health Care Analytics/Project/newDB", "/mrs_patient_program.csv"), row.names = F, na = "")
write.csv(mrs_program, paste0("F:/School/Tippie_Business Analytics/Health Care Analytics/Project/newDB", "/mrs_program.csv"), row.names = F, na = "")
write.csv(mrs_tribe, paste0("F:/School/Tippie_Business Analytics/Health Care Analytics/Project/newDB", "/mrs_tribe.csv"), row.names = F, na = "")



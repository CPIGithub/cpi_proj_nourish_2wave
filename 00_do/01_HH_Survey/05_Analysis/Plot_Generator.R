########################################################################################################
# Plots for publication
########################################################################################################

## 1. Packages and Settings ----

options(scipen    = 999)
options(max.print = 5000)
options(tibble.width = Inf)

library(tidyverse)
library(dplyr)
library(here)
library(haven)
library(questionr)
library(survey)
library(RSQLite)


# The below gets rid of package function conflicts

# filter    <- dplyr::filter
# select    <- dplyr::select
# summarize <- dplyr::summarize

########################################################################################################

## 2. Set root ----

# here::here()
here::i_am("project_nourish_2ndwave.Rproj")

pn_fies <- here::here("02_dta", "pnourish_FIES_final_forplot.dta")

nourish_fies_output <- here::here("03_output", "pnourish_FIES_Rasch_Model_output.cvs")

########################################################################################################

## 3. Data Analysis ##

#### 3.1 load the dataset 

fies <- read_dta(pn_fies)

fies_mt <- as.matrix(fies)

fies_w <- svydesign(ids = ~respd_id, weights = ~weight_final, data = fies)


ggsurvey(fies_w) +
  aes(NationalQuintile, fies_insecurity) +
  geom_bar(aes(fill=NationalQuintile), stat="identity", position="identity")



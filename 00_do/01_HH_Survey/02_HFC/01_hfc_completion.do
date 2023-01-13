/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: completion check 			
Author				:	Nicholus Tint Zaw
Date				: 	11/24/2022
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

********************************************************************************
* household survey *
********************************************************************************

** HH Survey Dataset **
use "$dta/pnourish_hh_svy_wide.dta", clear 

local maingeo geo_town township_name geo_vt geo_eho_vt_name geo_vill geo_eho_vill_name


// survey - overall
gen svy_tot = _N
egen svy_consent = total(will_participate)
gen svy_attempt_prop = round(svy_tot/788, 0.001)
gen svy_consent_prop = round(svy_consent/788, 0.001)

// survey per org
bysort org_team: gen tot_attempt_per_org = _N
bysort org_team: egen tot_svy_per_org = total(will_participate)

// survey per geo
bysort geo_town geo_vt geo_vill: gen tot_attempt_per_vill = _N
bysort geo_town geo_vt geo_vill: egen tot_svy_per_vill = total(will_participate)

gen svy_attempt_prop_vill = round(tot_attempt_per_vill/vill_samplesize, 0.01)
gen svy_consent_prop_vill = round(tot_svy_per_vill/vill_samplesize, 0.01)

// survey per team
bysort svy_team: gen tot_attemtp_per_team = _N
bysort svy_team: egen tot_svy_per_team = total(will_participate)

// survey per enumerator
bysort svy_team interv_name: gen tot_attempt_per_enu = _N
bysort svy_team interv_name: egen tot_svy_per_enu = total(will_participate)

// lab var 
lab var svy_tot					"Number of total interviews"
lab var svy_attempt_prop		"Proportion of interviews per targeted sample size"
lab var svy_consent				"Number of total consent survey"
lab var svy_consent_prop		"Proportion of consent survey per targeted sample size"

lab var tot_attempt_per_org 	"Number of interview per organization"
lab var tot_svy_per_org 		"Number of consent survey per organization"

lab var vill_samplesize			"Required Sample Size per village"
lab var tot_attempt_per_vill	"Number of interview per village"
lab var svy_attempt_prop_vill	"Proportion of interviews per targeted sample size"
lab var tot_svy_per_vill 		"Number of consent survey per village"
lab var svy_consent_prop_vill	"Proportion of consent survey per targeted sample size"
lab var tot_attemtp_per_team 	"Number of interview per team"
lab var tot_svy_per_team 		"Number of consent survey per team"
lab var tot_attempt_per_enu 	"Number of interview per enumerator"
lab var tot_svy_per_enu			"Number of consent survey per enumerator"

// export table

preserve 
keep if _n == 1 
keep svy_tot svy_attempt_prop svy_consent svy_consent_prop

rename * en_*
gen sir = _n 

reshape long en_ , i(sir) j(var) string 

replace sir = _n  

rename en_ value 

replace var = 	"Number of total interviews" if var == "svy_tot"
replace var =	"Proportion of interviews per targeted sample size" if var == "svy_attempt_prop"
replace var = 	"Number of total consent survey" if var == "svy_consent"
replace var = 	"Proportion of consent survey per targeted sample size" if var == "svy_consent_prop"

export excel using "$out/01_hfc_hh_completion_rate.xlsx", sheet("01_overall") firstrow(varlabels) sheetreplace
restore 

preserve 
bysort org_team: keep if _n == 1 
keep org_name tot_attempt_per_org tot_svy_per_org

export excel using "$out/01_hfc_hh_completion_rate.xlsx", sheet("02_org") firstrow(varlabels) sheetreplace
restore 

preserve 
bysort geo_town geo_vt geo_vill: keep if _n == 1 
keep `maingeo' tot_attempt_per_vill svy_attempt_prop tot_svy_per_vill svy_consent_prop

export excel using "$out/01_hfc_hh_completion_rate.xlsx", sheet("03_geo") firstrow(varlabels) sheetreplace
restore 


preserve 
bysort svy_team: keep if _n == 1 
keep svy_team tot_attemtp_per_team tot_svy_per_team

export excel using "$out/01_hfc_hh_completion_rate.xlsx", sheet("04_team") firstrow(varlabels) sheetreplace
restore 


preserve 
bysort svy_team interv_name: keep if _n == 1
keep svy_team superv_name enu_name tot_attempt_per_enu tot_svy_per_enu

export excel using "$out/01_hfc_hh_completion_rate.xlsx", sheet("05_enu") firstrow(varlabels) sheetreplace
restore 

// END HERE 



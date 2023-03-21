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

local maingeo org_name stratum geo_town township_name geo_vt geo_eho_vt_name geo_vill geo_eho_vill_name


// survey - overall
gen target_N = 788
gen svy_tot = _N
egen svy_consent = total(will_participate)
gen svy_attempt_prop = round(svy_tot/target_N, 0.001) * 100
gen svy_consent_prop = round(svy_consent/target_N, 0.001) * 100

// stratum 
gen st_target_N = 316 if stratum == 1 
replace st_target_N = 472 if stratum == 2
bysort stratum: egen st_svy_consent = total(will_participate)
gen st_svy_consent_prop = round(st_svy_consent/st_target_N, 0.001) * 100

// survey per org
bysort org_team: gen tot_attempt_per_org = _N
bysort org_team: egen tot_svy_per_org = total(will_participate)

// survey per org by stratum 
gen org_st_target_N = .m 
replace  org_st_target_N = (17 * 12) 	if stratum == 2 & org_name == "YSDA"
replace  org_st_target_N = (20 * 12) 	if stratum == 2 & org_name == "KEHOC"
replace  org_st_target_N = (3 * 12) 	if stratum == 2 & org_name == "KDHW"

replace  org_st_target_N = (14 * 10) 	if stratum == 1 & org_name == "YSDA"
replace  org_st_target_N = (13 * 10) 	if stratum == 1 & org_name == "KEHOC"
replace  org_st_target_N = (7 * 10) 	if stratum == 1 & org_name == "KDHW"

bysort org_team stratum: egen tot_svy_per_org_st = total(will_participate)
gen svy_consent_prop_storg = round(tot_svy_per_org_st/org_st_target_N, 0.01) * 100

tab svy_consent_prop_storg, m 

// survey per geo
bysort geo_town geo_vt geo_vill: gen tot_attempt_per_vill = _N
bysort geo_town geo_vt geo_vill: egen tot_svy_per_vill = total(will_participate)

gen svy_attempt_prop_vill = round(tot_attempt_per_vill/vill_samplesize, 0.01) * 100
gen svy_consent_prop_vill = round(tot_svy_per_vill/vill_samplesize, 0.01) * 100

// survey per team
bysort svy_team: gen tot_attemtp_per_team = _N
bysort svy_team: egen tot_svy_per_team = total(will_participate)

// survey per enumerator
bysort svy_team interv_name: gen tot_attempt_per_enu = _N
bysort svy_team interv_name: egen tot_svy_per_enu = total(will_participate)

// lab var 
lab var target_N 				"Targeted Sample (A)"
lab var svy_tot					"Total interviews (B)"
lab var svy_attempt_prop		"Proportion of interviews (B/A)"
lab var svy_consent				"Total consented survey (C)"
lab var svy_consent_prop		"Proportion of consented survey (C/A)"

lab var org_name				"Organization name"
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

lab var tot_svy_per_org_st		"Number of consent survey per stratum (by org)"
lab var org_st_target_N			"Targeted Sample per stratum (by org)"
lab var svy_consent_prop_storg 	"Proportion of consent survey per stratum (by org)"

// export table

preserve 
keep if _n == 1 
keep target_N svy_tot svy_attempt_prop svy_consent svy_consent_prop

local i = 1

foreach var of varlist _all {
	
	rename `var' var_`i'
	
	local i = `i' + 1
}

gen sir = _n 

reshape long var_ , i(sir) j(var) string 

replace sir = _n  

rename var_ value 

replace var = "Targeted Sample (A)" 					if var == "1"
replace var = "Total interviews (B)" 					if var == "2"
replace var = "Proportion of interviews (B/A)"			if var == "4"
replace var = "Total consented survey (C)"				if var == "3"
replace var = "Proportion of consented survey (C/A)"	if var == "5"

export excel using "$out/01_hfc_hh_completion_rate.xlsx", sheet("01_overall") firstrow(varlabels) keepcellfmt sheetreplace
restore 


preserve
bysort stratum: keep if _n == 1 
keep stratum st_target_N st_svy_consent st_svy_consent_prop

local i = 1

foreach var of varlist _all {
	
	rename `var' var_`i'
	
	local i = `i' + 1
}

gen sir = _n 

reshape long var_ , i(sir) j(var) string 

rename var_ value 

drop if value == 1 | value == 2

replace sir = _n  


replace var = "Stratum-1: Targeted Sample (A)" 						if sir == 1
replace var = "Stratum-1: Total consented survey (C)"				if sir == 2
replace var = "Stratum-1: Proportion of consented survey (C/A)"		if sir == 3

replace var = "Stratum-2: Targeted Sample (A)" 						if sir == 4
replace var = "Stratum-2: Total consented survey (C)"				if sir == 5
replace var = "Stratum-3: Proportion of consented survey (C/A)"		if sir == 6

export excel using "$out/01_hfc_hh_completion_rate.xlsx", sheet("01_overall") firstrow(varlabels) cell(A10) keepcellfmt sheetmodify

restore 


preserve
bysort org_team stratum: keep if _n == 1 
keep org_team org_name stratum org_st_target_N tot_svy_per_org_st svy_consent_prop_storg 

local i = 1

foreach var of varlist _all {
	
	rename `var' var_`i'
	
	local i = `i' + 1
}

gen sir = _n 
rename var_1 org_name
rename var_2 stratum 

reshape long var_ , i(sir) j(var) string 

rename var_ value 

drop if value == 1 | value == 2 | value == 3

replace sir = _n  


replace var = "Targeted Sample (A)" 					if var == "4"
replace var = "Total consented survey (C)"				if var == "5"
replace var = "Proportion of consented survey (C/A)"	if var == "6"

lab var stratum 	"Stratum Number"
lab var value	 	"Prop."
lab var var 		"Description"

order sir org_name stratum var value

export excel using "$out/01_hfc_hh_completion_rate.xlsx", sheet("01_overall") firstrow(varlabels) cell(A19) keepcellfmt sheetmodify

restore 


preserve 
bysort org_team: keep if _n == 1 
keep org_name tot_attempt_per_org tot_svy_per_org

export excel using "$out/01_hfc_hh_completion_rate.xlsx", sheet("02_org") firstrow(varlabels) keepcellfmt sheetreplace
restore 

preserve 
bysort geo_town geo_vt geo_vill: keep if _n == 1 
keep `maingeo' vill_samplesize tot_attempt_per_vill tot_svy_per_vill svy_attempt_prop_vill svy_consent_prop_vill
order `maingeo' vill_samplesize tot_attempt_per_vill svy_attempt_prop_vill tot_svy_per_vill svy_consent_prop_vill
sort org_name township_name geo_eho_vt_name geo_eho_vill_name
export excel using "$out/01_hfc_hh_completion_rate.xlsx", sheet("03_geo") firstrow(varlabels) keepcellfmt sheetreplace
restore 


preserve 
bysort svy_team: keep if _n == 1 
keep org_name svy_team tot_attemtp_per_team tot_svy_per_team

export excel using "$out/01_hfc_hh_completion_rate.xlsx", sheet("04_team") firstrow(varlabels) keepcellfmt sheetreplace
restore 


preserve 
bysort svy_team interv_name: keep if _n == 1
keep svy_team superv_name enu_name tot_attempt_per_enu tot_svy_per_enu

export excel using "$out/01_hfc_hh_completion_rate.xlsx", sheet("05_enu") firstrow(varlabels) keepcellfmt sheetreplace
restore 

** replaced villages **
gen replaced_cluster = (num_cluster == 0 | mi(num_cluster))
tab replaced_cluster, m 


preserve 
bysort org_name township_name geo_eho_vt_name geo_eho_vill_name: keep if _n == 1

keep if replaced_cluster == 1

sort org_name stratum township_name geo_eho_vt_name geo_eho_vill_name

keep org_name township_name geo_eho_vt_name geo_eho_vill_name stratum 

export excel using "$out/01_hfc_hh_completion_rate.xlsx", sheet("06_replaced_villages") firstrow(varlabels) keepcellfmt sheetreplace
restore 



// END HERE 



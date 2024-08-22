/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: HH survey weight calculation 			
Author				:	Nicholus Tint Zaw
Date				: 	03/21/2023
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

********************************************************************************
* IP villages *
********************************************************************************

use "$dta/pn_2_samplelist.dta", clear  
 
rename fieldnamevillagetracteho  	geo_eho_vt_name
rename villagenameeho 				geo_eho_vill_name
rename townshippcode 				geo_town
rename vt_sir_num 					geo_vt
rename vill_sir_num 				geo_vill 
rename organization 				org_name 
rename villagecode					vill_code

distinct geo_vill

drop sr 

tempfile villmaster 
save `villmaster', replace 
 

********************************************************************************
* household survey *
********************************************************************************

use "$dta/pnourish_hh_svy_wide.dta", clear 

keep if will_participate == 1

// duplicate by geo-person
duplicates tag geo_town geo_vt geo_vill respd_name respd_age respd_status, gen(dup_resp)
tab dup_resp, m 

order svy_date org_name township_name geo_eho_vt_name geo_eho_vill_name stratum 

drop dup_resp 


// Survey per village 
bysort geo_town stratum geo_vt geo_vill: gen tot_consent_svy = _N
bysort geo_town stratum geo_vt geo_vill: keep if _n == 1


/*
bysort org_name township_name stratum geo_eho_vt_name geo_eho_vill_name: gen tot_consent_svy = _N

bysort org_name township_name stratum geo_eho_vt_name geo_eho_vill_name: keep if _n == 1
*/

order org_name township_name geo_town stratum geo_eho_vt_name geo_vt geo_eho_vill_name geo_vill tot_consent_svy

keep org_name township_name geo_town stratum geo_eho_vt_name geo_vt geo_eho_vill_name geo_vill tot_consent_svy

distinct org_name township_name stratum geo_eho_vt_name geo_eho_vill_name, joint 

distinct township_name stratum geo_eho_vt_name geo_eho_vill_name, joint 

distinct geo_vill

// merge with village master dataset 
//merge 1:1 org_name township_name stratum geo_eho_vt_name geo_eho_vill_name using `villmaster'

merge 1:1 geo_vill using `villmaster'

drop _merge 

order	org_name township_name geo_town ///
		stratum ///
		geo_eho_vt_name geo_vt geo_eho_vill_name geo_vill ///
		vill_samplesize tot_consent_svy ///
		household population pop2years pop25years u5_pop ///
		cluster_cat num_cluster cluster_order ///
		vill_accessibility vill_proj_implement emergency_vill 

** Weight Calculation **
//bysort org_name township_name geo_town stratum geo_eho_vt_name geo_vt geo_eho_vill_name geo_vill: egen stratum_pop = total(population)

* step (1): Calculate stratum total pop
bysort stratum org_name: egen stratum_pop = total(household)

tab stratum_pop, m 

* step (2): Calculate stratum sample pop 
bysort stratum org_name: egen st_sample_pop = total(household) if !mi(tot_consent_svy)
bysort stratum org_name: egen stratum_sample_pop = max(st_sample_pop)

tab stratum_sample_pop, m 
drop st_sample_pop 

* step (3): Stratum propability: stratum sample pop/stratum pop/stratum
gen cluster_prob = stratum_sample_pop/stratum_pop

tab cluster_prob, m 


* step (4): HH propability (at village level): sample HH (per village) /total HH (per village)
gen hh_prob = tot_consent_svy/household
replace hh_prob = 1 if stratum == 1

tab hh_prob

* step (5): Calculate Final Wegith 
gen weight_final = 1/(cluster_prob * hh_prob)
replace weight_final = 0 if mi(tot_consent_svy)
tab weight_final

order population tot_consent_svy stratum_pop stratum_sample_pop cluster_prob weight_final, after (geo_vill)


keep if !mi(tot_consent_svy)

* Stratum Number * 
gen stratum_num = .m 
replace stratum_num = 1 if org_name == "YSDA" & stratum == 1
replace stratum_num = 2 if org_name == "YSDA" & stratum == 2
replace stratum_num = 3 if org_name == "KEHOC" & stratum == 1
replace stratum_num = 4 if org_name == "KEHOC" & stratum == 2
replace stratum_num = 5 if org_name == "KDHW" & stratum == 1
replace stratum_num = 6 if org_name == "KDHW" & stratum == 2

lab def stratum_num 1"YSDA: Stratum 1" 2"YSDA: Stratum 2" 3"KEHOC: Stratum 1" ///
					4"KEHOC: Stratum 2" 5"KDHW: Stratum 1" 6"KDHW: Stratum 2"
lab val stratum_num stratum_num
tab stratum_num, m 


encode org_name, gen(org_name_num)
order org_name_num, after(org_name)

gen hh_prob_midterm = hh_prob
gen cluster_prob_midterm = cluster_prob
gen weight_final_midterm = weight_final

* export as excel file 
export excel using "$result/pn_2_survey_weight.xlsx", sheet("weight") firstrow(variable)  nolabel replace 

save "$dta/pnourish_hh_weight_final.dta", replace  

		
// END HERE 




/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection - village profile preparation				
Author				:	Nicholus Tint Zaw
Date				: 	9/19/2022
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "00_dir_setting.do"

********************************************************************************
* IP villages *
********************************************************************************

**  feasibility first wave **
import excel 	using "$sample/01_village_profile/Updated_PN_Coverage_List_2022_accessiblityinfo,emergencyresponse_20221026.xlsx", ///
				sheet("LIFT") cellrange(A2:AH506) firstrow case(lower) clear 

* drop un-necessary var
drop lift liftremark ofhhtotal ofpoptotal feasibility123 inpersondatacollectionyn phonedatacollectionyn

* rename variable 
rename ad 							 vill_accessibility
rename projectimplementationstatusc  vill_proj_implement

replace vill_proj_implement = "" if vill_proj_implement == "-"
destring vill_proj_implement, replace 

tab vill_proj_implement, m 

egen u5_pop = rowtotal(pop25years pop2years)
replace u5_pop = .m if mi(pop2years) & mi(pop25years)
order u5_pop, after(pop25years)
tab u5_pop, m 


rename emergencyresposeyn emergency_vill

* drop if there is no project implementation or missing ingo 3 villages *

keep if vill_proj_implement != 0 & !mi(vill_proj_implement)

tab vill_proj_implement, m 

tab vill_accessibility, m 

gen stratum = (vill_accessibility != "3. neither in person nor phone interviews")
tab stratum, m 

********************************************************************************
* SAMPLING - stratum - 2: Limited Accessible villages *
********************************************************************************

preserve

keep if stratum == 0 
replace stratum = 2 if stratum == 0
tab emergency_vill, m // 59 villages 

set seed 234

gen rnd_num = runiform()

sort organization emergency_vill rnd_num

drop rnd_num 

sum u5_pop, d // average U2 pop: 16 per village

gen vill_samplesize = 12 if emergency_vill == "Yes"
replace vill_samplesize = 20 if emergency_vill == "No"
tab vill_samplesize, m 

gen sample_check = (u5_pop >= vill_samplesize)
lab def sample_check 1"have enough U5 sample size" 0"not enough U5 sample size"
lab val sample_check sample_check
tab sample_check, m 


export excel using "$result/01_sample_village_list.xlsx" if emergency_vill == "Yes", ///
					sheet("stratum_2_emergency", replace) firstro(variable) 


//export excel using "$result/01_sample_village_list.xlsx" if emergency_vill == "No", ///
//					sheet("stratum_2_no_emergency", replace) firstro(variable) 


* save as tempfile 
tempfile stratum2 
save `stratum2', replace 

restore 



********************************************************************************
* SAMPLING - stratum - 1: Accessible villages *
********************************************************************************

di 5 * 59 // sample size from stratum 2 
di 788 - (5 * 59) // required sample for stratum 1 
di 15 * 34


preserve 
keep if stratum == 1

sum u5_pop, d // average U2 pop: 81 per village

// 34 clusters and 15 HH per cluster 

set seed 234

samplepps pps_cluster, size(population) n(34) withrepl // add one additional cluster to save sample size from rounding work

tab pps_cluster, m

keep if pps_cluster != 0 

rename pps_cluster num_cluster
gen vill_samplesize = (num_cluster * 10)

gen sample_check = (u5_pop >= vill_samplesize)
lab def sample_check 1"have enough U5 sample size" 0"not enough U5 sample size"
lab val sample_check sample_check
tab sample_check, m 

export excel using "$result/01_sample_village_list.xlsx", sheet("stratum_1", replace) firstro(variable) 

* save as tempfile 
tempfile stratum1 
save `stratum1', replace 

restore 

clear 

** export for preloaded dataset **
use `stratum1', clear 

append using `stratum2'

* keep only required variables
keep township_name townshippcode fieldnamevillagetracteho villagenameeho stratum num_cluster vill_samplesize sample_check
replace stratum = 2 if stratum == 0

* generate pseudo code
gen vt_sir_num = _n + 1000
gen vill_sir_num = _n + 2000

order township_name townshippcode fieldnamevillagetracteho vt_sir_num villagenameeho vill_sir_num

export delimited using "$result/pn_2_samplelist.csv", nolabel replace  



			
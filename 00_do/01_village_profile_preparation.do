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
import excel 	using "$sample/01_village_profile/PN_Coverage_List_2022_feasibility.xlsx", ///
				sheet("1stRFeasibility") firstrow case(lower) allstring clear 

rename organization 			ip_names
rename district		  			district_eho 
rename townshipmimu 			township_mimu 
rename townshipknu 				township_eho 
rename villagetractknu			vt_eho 
rename villages		 			vill_mimu 

gen vill_eho = vill_mimu
order vill_eho, after(vill_mimu)

rename feasibility123 			feasibility_fw 
rename inpersondatacollectionyn fw_inperson
rename phonedatacollectionyn	fw_phone



drop if mi(ip_names) & mi(district_eho) & mi(township_mimu) & mi(township_eho) & mi(vt_eho) & mi(vill_mimu) & mi(vill_eho)  

foreach var of varlist ip_names district_eho township_mimu township_eho vt_eho vill_mimu vill_eho {
	
	gen `var'_mod = ustrlower(`var')
	replace `var'_mod = subinstr(`var'_mod, " ", "", .)
	
	rename `var' w1_`var'
}

gen unique_id =  	ip_names_mod + "_" + district_eho_mod + "_" + ///
					township_mimu_mod + "_" + township_eho_mod + "_" + ///
					vt_eho_mod + "_" + vill_eho_mod 


duplicates report unique_id
duplicates list unique_id


duplicates drop unique_id, force

keep unique_id feasibility_fw fw_inperson fw_phone *_mod w1_*

tempfile feasibility
save `feasibility', replace 

clear 


** PN lift villages **
import excel 	using "$sample/01_village_profile/PN_Coverage_List_2022_feasibility.xlsx", ///
				sheet("LIFT") cellrange(A2) firstrow case(lower) allstring clear 
				

rename organization 			ip_names
rename districteho  			district_eho 
rename township_name 			township_mimu 
rename townshipeho 				township_eho 
rename fieldnamevillagetracteho vt_eho 
rename villagenamemimu 			vill_mimu 
rename villagenameeho			vill_eho 

drop if mi(ip_names) & mi(district_eho) & mi(township_mimu) & mi(township_eho) & mi(vt_eho) & mi(vill_mimu) & mi(vill_eho)  

foreach var of varlist ip_names district_eho township_mimu township_eho vt_eho vill_mimu vill_eho {
	
	gen `var'_mod = ustrlower(`var')
	replace `var'_mod = subinstr(`var'_mod, " ", "", .)
}

gen unique_id =  	ip_names_mod + "_" + district_eho_mod + "_" + ///
					township_mimu_mod + "_" + township_eho_mod + "_" + ///
					vt_eho_mod + "_" + vill_eho_mod 


duplicates report unique_id

merge 1:1 unique_id using `feasibility'			


** make different dataset based on matching result **
preserve
keep if _merge == 1

gen pn_id = _n 

tempfile pn_lift
save `pn_lift', replace
restore 


preserve
keep if _merge == 2
gen w1_id = _n

tempfile w1_info
save `w1_info', replace
restore 

clear 


** PERFORM FUZZY MATCHING **

use `pn_lift', clear

reclink2 	ip_names_mod district_eho_mod /*township_mimu_mod*/ township_eho_mod /*vt_eho_mod vill_mimu_mod*/ vill_eho_mod ///
			using `w1_info', ///
			idm(pn_id) idu(w1_id) uprefix(w1_) _merge(fuzzy_merge) ///
			wmatch(20 5 5 20) ///
			req (ip_names_mod) gen(fuzzy_score) minscore(0.9) ///
			manytoone npairs (1)



** export result files for manual checking **
preserve 

keep if fuzzy_merge == 1

keep sr villagecode ip_names stateregionmimu stateregionpcode district_eho township_mimu townshippcode township_eho cliniccode clinicname hospitaltcname vt_eho villagetractpcode vill_mimu villagename_mmmimu vill_eho villagepcode 

export excel using "$out/village_profile_unmatch.xlsx", sheet("lift_unmatch") firstrow(variables) replace 

restore 


preserve 

keep if fuzzy_merge == 3 & fuzzy_score == 1

keep sr villagecode ip_names stateregionmimu stateregionpcode district_eho township_mimu townshippcode township_eho cliniccode clinicname hospitaltcname vt_eho villagetractpcode vill_mimu villagename_mmmimu vill_eho villagepcode w1_ip_names_mod w1_district_eho_mod w1_township_eho_mod w1_vill_eho_mod w1_id

export excel using "$out/village_profile_match.xlsx", sheet("exact_match") firstrow(variables) replace 

restore 

preserve 

keep if fuzzy_merge == 3 & fuzzy_score < 1

sort fuzzy_score 

keep sr villagecode ip_names stateregionmimu stateregionpcode district_eho township_mimu townshippcode township_eho cliniccode clinicname hospitaltcname vt_eho villagetractpcode vill_mimu villagename_mmmimu vill_eho villagepcode w1_ip_names w1_district_eho w1_township_eho w1_township_mimu w1_vt_eho w1_vill_mimu w1_vill_eho fuzzy_score

export excel using "$out/village_profile_match.xlsx", sheet("possible_match") firstrow(variables) sheetreplace 

restore 

use `w1_info', clear

reclink2 	ip_names_mod district_eho_mod /*township_mimu_mod*/ township_eho_mod /*vt_eho_mod vill_mimu_mod*/ vill_eho_mod ///
			using `pn_lift', ///
			idm(w1_id) idu(pn_id) uprefix(w1_) _merge(fuzzy_merge) ///
			wmatch(20 5 5 20) ///
			req (ip_names_mod) gen(fuzzy_score) minscore(0.9) ///
			manytoone npairs (1)

			
			
preserve 

keep if fuzzy_merge == 1

keep w1_ip_names w1_district_eho w1_township_eho w1_township_mimu w1_vt_eho w1_vill_mimu w1_vill_eho feasibility_fw fw_inperson fw_phone

export excel using "$out/village_profile_unmatch.xlsx", sheet("1stwave_unmatch") firstrow(variables) sheetreplace 

restore 


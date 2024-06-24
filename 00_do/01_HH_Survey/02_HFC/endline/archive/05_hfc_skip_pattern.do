/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: skip-pattern			
Author				:	Nicholus Tint Zaw
Date				: 	12/04/2022
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

********************************************************************************
* household survey *
********************************************************************************

use "$dta/pnourish_hh_svy_wide.dta", clear 

** Other Specify ** 
gen oth_not_miss = 0


replace oth_not_miss = 1 if !mi(hh_mem_highedu_oth) & hh_mem_highedu == 888
replace oth_not_miss = 1 if !mi(hh_mem_occup_oth) & hh_mem_occup == 888
replace oth_not_miss = 1 if !mi(child_diarrh_where_oth) & child_diarrh_where == 888
replace oth_not_miss = 1 if !mi(child_diarrh_who_oth) & child_diarrh_who == 888
replace oth_not_miss = 1 if !mi(child_cough_where_oth) & child_cough_where == 888
replace oth_not_miss = 1 if !mi(child_cough_who_oth) & child_cough_who == 888
replace oth_not_miss = 1 if !mi(child_fever_where_oth) & child_fever_where == 888
replace oth_not_miss = 1 if !mi(child_fever_who_oth) & child_fever_who == 888
replace oth_not_miss = 1 if !mi(anc_restrict_why_oth) & anc_restrict_why == 888
replace oth_not_miss = 1 if !mi(deliv_place_oth) & deliv_place == 888
replace oth_not_miss = 1 if !mi(deliv_assist_oth) & deliv_assist == 888
replace oth_not_miss = 1 if !mi(house_electric_perday_oth) & house_electric_perday == 888
replace oth_not_miss = 1 if !mi(house_electric_source_oth) & house_electric_source == 888
replace oth_not_miss = 1 if !mi(house_cooking_oth) & house_cooking == 888
replace oth_not_miss = 1 if !mi(water_sum_oth) & water_sum == 888
replace oth_not_miss = 1 if !mi(water_rain_oth) & water_rain == 888
replace oth_not_miss = 1 if !mi(water_winter_oth) & water_winter == 888
replace oth_not_miss = 1 if !mi(latrine_type_oth) & latrine_type == 888

replace oth_not_miss = 1 if !mi(resp_child_flag_why) & resp_child_flag_why888 == 1
replace oth_not_miss = 1 if !mi(chhild_addbf) & chhild_addbf888 == 1
replace oth_not_miss = 1 if !mi(child_ill) & child_ill888 == 1
replace oth_not_miss = 1 if !mi(child_diarrh_notreat) & child_diarrh_notreat888 == 1
replace oth_not_miss = 1 if !mi(child_diarrh_cope) & child_diarrh_cope888 == 1
replace oth_not_miss = 1 if !mi(child_cough_notreat) & child_cough_notreat888 == 1
replace oth_not_miss = 1 if !mi(child_cough_cope) & child_cough_cope888 == 1
replace oth_not_miss = 1 if !mi(child_fever_notreat) & child_fever_notreat888 == 1
replace oth_not_miss = 1 if !mi(child_fever_cope) & child_fever_cope888 == 1
replace oth_not_miss = 1 if !mi(anc_where) & anc_where888 == 1
replace oth_not_miss = 1 if !mi(anc_home_who) & anc_home_who888 == 1
replace oth_not_miss = 1 if !mi(anc_hosp_who) & anc_hosp_who888 == 1
replace oth_not_miss = 1 if !mi(anc_pc_who) & anc_pc_who888 == 1
replace oth_not_miss = 1 if !mi(anc_rhc_who) & anc_rhc_who888 == 1
replace oth_not_miss = 1 if !mi(anc_ehoc_who) & anc_ehoc_who888 == 1
replace oth_not_miss = 1 if !mi(anc_ehom_who) & anc_ehom_who888 == 1
replace oth_not_miss = 1 if !mi(anc_vill_who) & anc_vill_who888 == 1
replace oth_not_miss = 1 if !mi(anc_where) & anc_where888 == 1
replace oth_not_miss = 1 if !mi(anc_othp_who) & anc_othp_who888 == 1
replace oth_not_miss = 1 if !mi(anc_cope) & anc_cope888 == 1
replace oth_not_miss = 1 if !mi(anc_noreason) & anc_noreason888 == 1
replace oth_not_miss = 1 if !mi(anc_restrict_item) & anc_restrict_item888 == 1
replace oth_not_miss = 1 if !mi(anc_iron_source) & anc_iron_source888 == 1
replace oth_not_miss = 1 if !mi(deliv_cope) & deliv_cope888 == 1
replace oth_not_miss = 1 if !mi(pnc_where) & pnc_where888 == 1
replace oth_not_miss = 1 if !mi(pnc_home_who) & pnc_home_who888 == 1
replace oth_not_miss = 1 if !mi(pnc_hosp_who) & pnc_hosp_who888 == 1
replace oth_not_miss = 1 if !mi(pnc_pc_who) & pnc_pc_who888 == 1
replace oth_not_miss = 1 if !mi(pnc_rhc_who) & pnc_rhc_who888 == 1
replace oth_not_miss = 1 if !mi(pnc_ehoc_who) & pnc_ehoc_who888 == 1
replace oth_not_miss = 1 if !mi(pnc_ehom_who) & pnc_ehom_who888 == 1
replace oth_not_miss = 1 if !mi(pnc_vill_who) & pnc_vill_who888 == 1
replace oth_not_miss = 1 if !mi(pnc_where) & pnc_where888 == 1
replace oth_not_miss = 1 if !mi(pnc_othp_who) & pnc_othp_who888 == 1
replace oth_not_miss = 1 if !mi(pnc_cope) & pnc_cope888 == 1
replace oth_not_miss = 1 if !mi(nbc_where) & nbc_where888 == 1
replace oth_not_miss = 1 if !mi(nbc_home_who) & nbc_home_who888 == 1
replace oth_not_miss = 1 if !mi(nbc_hosp_who) & nbc_hosp_who888 == 1
replace oth_not_miss = 1 if !mi(nbc_pc_who) & nbc_pc_who888 == 1
replace oth_not_miss = 1 if !mi(nbc_rhc_who) & nbc_rhc_who888 == 1
replace oth_not_miss = 1 if !mi(nbc_ehoc_who) & nbc_ehoc_who888 == 1
replace oth_not_miss = 1 if !mi(nbc_ehom_who) & nbc_ehom_who888 == 1
replace oth_not_miss = 1 if !mi(nbc_vill_who) & nbc_vill_who888 == 1
replace oth_not_miss = 1 if !mi(nbc_where) & nbc_where888 == 1
replace oth_not_miss = 1 if !mi(nbc_othp_who) & nbc_othp_who888 == 1
replace oth_not_miss = 1 if !mi(nbc_cope) & nbc_cope888 == 1
replace oth_not_miss = 1 if !mi(house_roof) & house_roof888 == 1
replace oth_not_miss = 1 if !mi(house_wall) & house_wall888 == 1
replace oth_not_miss = 1 if !mi(house_floor) & house_floor888 == 1
replace oth_not_miss = 1 if !mi(house_light) & house_light888 == 1
replace oth_not_miss = 1 if !mi(water_sum_treatmethod) & water_sum_treatmethod888 == 1
replace oth_not_miss = 1 if !mi(water_rain_treatmethod) & water_rain_treatmethod888 == 1
replace oth_not_miss = 1 if !mi(water_winter_treatmethod) & water_winter_treatmethod888 == 1
replace oth_not_miss = 1 if !mi(soap_why) & soap_why888 == 1
replace oth_not_miss = 1 if !mi(observ_washplace) & observ_washplace888 == 1
replace oth_not_miss = 1 if !mi(d5_reason) & d5_reason99 == 1
replace oth_not_miss = 1 if !mi(d6_cope) & d6_cope99 == 1
replace oth_not_miss = 1 if !mi(d7_inc_govngo_nm) & d7_inc_govngo_nm99 == 1
replace oth_not_miss = 1 if !mi(health_exp_cope) & health_exp_cope888 == 1
replace oth_not_miss = 1 if !mi(prgexpo_join) & prgexpo_join888 == 1
replace oth_not_miss = 1 if !mi(prgexp_why_1) & prgexp_why_1888 == 1
replace oth_not_miss = 1 if !mi(prgexp_why_2) & prgexp_why_2888 == 1
replace oth_not_miss = 1 if !mi(prgexp_why_3) & prgexp_why_3888 == 1
replace oth_not_miss = 1 if !mi(prgexp_why_4) & prgexp_why_4888 == 1
replace oth_not_miss = 1 if !mi(prgexp_why_5) & prgexp_why_5888 == 1
replace oth_not_miss = 1 if !mi(prgexp_why_6) & prgexp_why_6888 == 1
replace oth_not_miss = 1 if !mi(prgexp_why_7) & prgexp_why_7888 == 1
replace oth_not_miss = 1 if !mi(prgexp_why_8) & prgexp_why_8888 == 1
replace oth_not_miss = 1 if !mi(prgexp_why_9) & prgexp_why_9888 == 1


// other option with no specify value
preserve 
keep if oth_not_miss == 1

if _N > 0 {
	
	export excel using "$out/04_hfc_skippattern.xlsx", sheet("01_other_miss") firstrow(varlabels) sheetreplace
	
}

restore 

** other specify list 
preserve
local otherlist	resp_child_flag_why	chhild_addbf	child_ill	child_diarrh_notreat ///
				child_diarrh_cope	child_cough_notreat	child_cough_cope child_fever_notreat ///
				child_fever_cope	anc_where	anc_home_who	anc_hosp_who anc_pc_who	///
				anc_rhc_who	anc_ehoc_who	anc_ehom_who	anc_vill_who	anc_where	///
				anc_othp_who	anc_cope	anc_noreason	anc_restrict_item	anc_iron_source	///
				deliv_cope	pnc_where	pnc_home_who	pnc_hosp_who	pnc_pc_who	pnc_rhc_who	///
				pnc_ehoc_who	pnc_ehom_who	pnc_vill_who	pnc_where	pnc_othp_who	///
				pnc_cope	nbc_where	nbc_home_who	nbc_hosp_who	nbc_pc_who	nbc_rhc_who	///
				nbc_ehoc_who	nbc_ehom_who	nbc_vill_who	nbc_where	nbc_othp_who	///
				nbc_cope	house_roof	house_wall	house_floor	house_light	water_sum_treatmethod	///
				water_rain_treatmethod	water_winter_treatmethod	soap_why	observ_washplace	///
				d5_reason	d6_cope	d7_inc_govngo_nm	health_exp_cope	prgexpo_join	prgexp_why_1	///
				prgexp_why_2	prgexp_why_3	prgexp_why_4	prgexp_why_5	prgexp_why_6	///
				prgexp_why_7	prgexp_why_8	prgexp_why_9	hh_mem_highedu	hh_mem_occup	///
				child_diarrh_where	child_diarrh_who	child_cough_where	child_cough_who	///
				child_fever_where	child_fever_who	anc_restrict_why	deliv_place	deliv_assist	///
				house_electric_perday	house_electric_source	house_cooking	water_sum	///
				water_rain	water_winter	latrine_type


foreach v in `otherlist' {
    
	rename `v' pr_`v'
}
				
keep `otherlist' pr_* *_oth enu_name svy_team uuid oth_not_miss 

rename *_oth o_*_oth

gen sir = _n 
				
reshape long pr_ o_ , i(sir) j(var_name) string 

drop sir 

rename pr_ 	values
rename o_ 	other_specify

order svy_team enu_name var_name values other_specify

// export table
export excel using "$out/04_hfc_skippattern.xlsx", sheet("02_other_list") firstrow(varlabels) sheetreplace
restore 


** Data Consistency Check **
// will update later 







// END HERE 




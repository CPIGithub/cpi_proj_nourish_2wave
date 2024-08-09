/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	Endline: Data analysis - Mother level and Related Modules			
Author				:	Nicholus Tint Zaw
Date				: 	08/06/2024
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

	   
	****************************************************************************
	** Mom Dietary Diversity **
	****************************************************************************

	use "$dta/endline/pnourish_mom_diet_final.dta", clear 
	
	merge m:1 _parent_index using "$dta/pnourish_WOMEN_EMPOWER_final.dta", keepusing(wempo_index wempo_category progressivenss)
	
	drop if _merge == 2 
	drop _merge 
	
	
	* Add Village Survey Info 
	global villinfo 	hfc_near_dist_dry hfc_near_dist_rain ///
						mkt_near_dist_dry mkt_near_dist_rain ///
						hfc_vill1 hfc_vill2 hfc_vill3 hfc_vill4 hfc_vill5 hfc_vill6 hfc_vill888 hfc_vill0 
	
	merge m:1 geo_vill using 	"$dta/PN_Village_Survey_FINAL_Constructed.dta", ///
								keepusing($villinfo) 
	
	drop if _merge == 2
	drop _merge 
	
	* Village level information 
	egen mkt_near_dist = rowmean(mkt_near_dist_dry mkt_near_dist_rain)
	replace mkt_near_dist = .m if mi(mkt_near_dist_dry) & mi(mkt_near_dist_rain)
	lab var mkt_near_dist "Nearest Market - hours for round trip"
	tab mkt_near_dist, m 
	
	egen hfc_near_dist = rowmean(hfc_near_dist_dry hfc_near_dist_rain)
	replace hfc_near_dist = .m if mi(hfc_near_dist_dry) & mi(hfc_near_dist_rain)
	lab var hfc_near_dist "Nearest Health Facility - hours for round trip"
	tab hfc_near_dist, m 
	
	gen mkt_distance = .m 
	replace mkt_distance = 0 if mkt_near_dist_rain == 0
	replace mkt_distance = 1 if mkt_near_dist_rain > 0 & mkt_near_dist_rain <= 1.5
	replace mkt_distance = 2 if mkt_near_dist_rain > 1.5 & mkt_near_dist_rain <= 5
	replace mkt_distance = 3 if mkt_near_dist_rain > 5 & !mi(mkt_near_dist_rain)
	lab var mkt_distance "Nearest Market - hours for round trip"
	lab def mkt_distance 0"Market at village" 1"< 1.5 hrs" 2"1.5 - 5 hrs" 3"> 5 hrs"
	lab val mkt_distance mkt_distance
	tab mkt_distance, mis

	gen hfc_distance = .m 
	replace hfc_distance = 0 if hfc_near_dist_rain == 0
	replace hfc_distance = 1 if hfc_near_dist_rain > 0 & hfc_near_dist_rain <= 1.5
	replace hfc_distance = 2 if hfc_near_dist_rain > 1.5 & hfc_near_dist_rain <= 3
	replace hfc_distance = 3 if hfc_near_dist_rain > 3 & !mi(hfc_near_dist_rain)
	lab def hfc_distance 0"Health Facility present at village" 1"<= 1.5 hours" 2"1.6 to 3 hours" 3">3 hours"
	lab val hfc_distance hfc_distance
	lab var hfc_distance "Nearest Health Facility - hours for round trip"
	tab hfc_distance, mis
	
	* treated other and monestic education as missing
	gen resp_highedu_ci = resp_highedu
	replace resp_highedu_ci = .m if resp_highedu_ci > 7 
	tab resp_highedu_ci, m 
	
	replace resp_highedu = .m if resp_highedu > 7 
	replace resp_highedu = 4 if resp_highedu > 4 & !mi(resp_highedu)
	tab resp_highedu, m 
	
	
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	
	global outcomes	mddw_grain mddw_pulses mddw_nut mddw_milk mddw_meat ///
					mddw_moom_egg mddw_green_veg mddw_vit_vegfruit ///
					mddw_oth_veg mddw_oth_fruit ///
					mddw_score mddw_yes mom_meal_freq
					
	* All Obs
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		do "$hhdo/Function/00_frequency_table_one.do"


		export excel $export_table 	using "$out/endline/sumstat/MOM_DIET_SUMSTAT.xlsx", /// 
									sheet("MDDS") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* by STRATUM 
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		global sub_grp stratum_num
		
		do "$hhdo/Function/00_frequency_crosstable.do"

		export excel $export_table 	using "$out/endline/sumstat/MOM_DIET_SUMSTAT.xlsx", /// 
									sheet("$sub_grp") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* by STRATUM 
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		global sub_grp wealth_quintile_ns
		
		do "$hhdo/Function/00_frequency_crosstable.do"


		export excel $export_table 	using "$out/endline/sumstat/MOM_DIET_SUMSTAT.xlsx", /// 
									sheet("$sub_grp") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore		
	
	
	****************************************************************************
	* Mom Health Module *
	****************************************************************************

	use "$dta/endline/pnourish_mom_health_final.dta", clear   

	* women empowerment dataset 
	merge m:1 _parent_index using "$dta/pnourish_WOMEN_EMPOWER_final.dta", keepusing(wempo_index wempo_category progressivenss)
	
	drop if _merge == 2 
	drop _merge 
	
	* respondent info
	merge m:1 _parent_index using "$dta/pnourish_respondent_info_final.dta", keepusing(respd_age resp_highedu respd_chid_num) 
	
	drop if _merge == 2 
	drop _merge 
	
	* treated other and monestic education as missing
	gen resp_highedu_ci = resp_highedu
	replace resp_highedu_ci = .m if resp_highedu_ci > 7 
	tab resp_highedu_ci, m 
	
	replace resp_highedu = .m if resp_highedu > 7 
	replace resp_highedu = 4 if resp_highedu > 4 & !mi(resp_highedu)
	tab resp_highedu, m 
	
	gen mom_age_grp = (respd_age < 25)
	replace mom_age_grp = 2 if respd_age >= 25 & respd_age < 35 
	replace mom_age_grp = 3 if respd_age >= 35  
	replace mom_age_grp = .m if mi(respd_age)
	lab def mom_age_grp 1"< 25 years old" 2"25 - 34 years old" 3"35+ years old"
	lab val mom_age_grp mom_age_grp
	tab mom_age_grp, m 
	
	
	recode respd_chid_num (1 = 1) (2 = 2) (3/15 = 3), gen(respd_chid_num_grp)
	replace respd_chid_num_grp = .m if mi(respd_chid_num)
	lab def respd_chid_num_grp 1"Has only one child" 2"Has two children" 3"Has three children & more" 
	lab val respd_chid_num_grp respd_chid_num_grp 
	lab var respd_chid_num_grp "Number of Children"
	tab respd_chid_num_grp, m 
	
	* Add Village Survey Info 
	global villinfo 	hfc_near_dist_dry hfc_near_dist_rain ///
						mkt_near_dist_dry mkt_near_dist_rain ///
						hfc_vill1 hfc_vill2 hfc_vill3 hfc_vill4 hfc_vill5 hfc_vill6 hfc_vill888 hfc_vill0 
	
	merge m:1 geo_vill using 	"$dta/PN_Village_Survey_FINAL_Constructed.dta", ///
								keepusing($villinfo) 
	
	drop if _merge == 2
	drop _merge 
	
	// detach value label - resulted from merging 
	foreach var of varlist hfc_near_dist_dry hfc_near_dist_rain mkt_near_dist_dry mkt_near_dist_rain {
		
		lab val `var'
	}
	
	egen hfc_near_dist = rowmean(hfc_near_dist_dry hfc_near_dist_rain)
	replace hfc_near_dist = .m if mi(hfc_near_dist_dry) & mi(hfc_near_dist_rain)
	lab var hfc_near_dist "Nearest Health Facility - hours for round trip"
	tab hfc_near_dist, m 
	
	tab hfc_vill0, m 
	gen hfc_vill_yes = (hfc_vill0 == 0)
	replace hfc_vill_yes = .m if mi(hfc_vill0)
	lab val hfc_vill_yes yesno 
	tab hfc_vill_yes, m 
	
	* distance HFC category 
	gen hfc_distance = .m 
	replace hfc_distance = 0 if hfc_near_dist_rain == 0
	replace hfc_distance = 1 if hfc_near_dist_rain > 0 & hfc_near_dist_rain <= 1.5
	replace hfc_distance = 2 if hfc_near_dist_rain > 1.5 & hfc_near_dist_rain <= 3
	replace hfc_distance = 3 if hfc_near_dist_rain > 3 & !mi(hfc_near_dist_rain)
	lab def hfc_distance 0"Health Facility present at village" 1"<= 1.5 hours" 2"1.6 to 3 hours" 3">3 hours"
	lab val hfc_distance hfc_distance
	lab var hfc_distance "Nearest Health Facility - hours for round trip"
	tab hfc_distance, mis

	
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	global outcomes	anc_yn anc_who_trained anc_visit_trained_4times ///
					insti_birth skilled_battend ///
					pnc_yn pnc_who_trained ///
					nbc_yn nbc_2days_yn nbc_who_trained
	
	* All Obs
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		do "$hhdo/Function/00_frequency_table_one.do"


		export excel $export_table 	using "$out/endline/sumstat/MOM_ANCPNC_SUMSTAT.xlsx", /// 
									sheet("ANCPNC") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* by STRATUM 
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		global sub_grp stratum_num
		
		do "$hhdo/Function/00_frequency_crosstable.do"

		export excel $export_table 	using "$out/endline/sumstat/MOM_ANCPNC_SUMSTAT.xlsx", /// 
									sheet("$sub_grp") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* by STRATUM 
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		global sub_grp wealth_quintile_ns
		
		do "$hhdo/Function/00_frequency_crosstable.do"


		export excel $export_table 	using "$out/endline/sumstat/MOM_ANCPNC_SUMSTAT.xlsx", /// 
									sheet("$sub_grp") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore		
	
	
	****************************************************************************
	** PHQ9 **
	****************************************************************************
	
	use "$dta/endline/pnourish_PHQ9_final.dta", clear  

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)
	
	tab phq9_cat, gen(phq9_cat_)
	
	* Loop through the generated variables and update their labels
	foreach var of varlist phq9_cat_* {
		
		* Get the current label
		local current_label : variable label `var'
		
		* Extract the part after "=="
		local new_label = substr("`current_label'", strpos("`current_label'", "==") + 2, .)
		
		* Trim any leading or trailing spaces
		local new_label = trim("`new_label'")
		
		* Update the variable label
		label variable `var' "`new_label'"
	}

	global outcomes phq9_cat_1 phq9_cat_2 phq9_cat_3 phq9_cat_4 
	
	* All Obs
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		do "$hhdo/Function/00_frequency_table_one.do"


		export excel $export_table 	using "$out/endline/sumstat/MOM_PHQ9_SUMSTAT.xlsx", /// 
									sheet("PHQ9") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* by STRATUM 
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		global sub_grp stratum_num
		
		do "$hhdo/Function/00_frequency_crosstable.do"

		export excel $export_table 	using "$out/endline/sumstat/MOM_PHQ9_SUMSTAT.xlsx", /// 
									sheet("$sub_grp") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* by STRATUM 
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		global sub_grp wealth_quintile_ns
		
		do "$hhdo/Function/00_frequency_crosstable.do"


		export excel $export_table 	using "$out/endline/sumstat/MOM_PHQ9_SUMSTAT.xlsx", /// 
									sheet("$sub_grp") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore		
	
	****************************************************************************
	** Women Empowerment [endline] **
	****************************************************************************
	
	use "$dta/endline/pnourish_WOMEN_EMPOWER_final.dta", clear  

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	tab wempo_category, gen(wempo_category_)
	
	* Loop through the generated variables and update their labels
	foreach var of varlist wempo_category_* {
		
		* Get the current label
		local current_label : variable label `var'
		
		* Extract the part after "=="
		local new_label = substr("`current_label'", strpos("`current_label'", "==") + 2, .)
		
		* Trim any leading or trailing spaces
		local new_label = trim("`new_label'")
		
		* Update the variable label
		label variable `var' "`new_label'"
	}
	
	
	global outcomes wempo_familyfood_yes wempo_childcare_yes wempo_mom_health_yes ///
					wempo_child_health_yes wempo_women_wages_yes wempo_major_purchase_yes ///
					wempo_visiting_yes wempo_women_health_yes wempo_child_wellbeing_yes ///
					wempo_grp_tot ///
					wempo_index progressivenss wempo_category_1 wempo_category_2 wempo_category_3 ///
					wempo_hnut_act_ja
	
	
	* All Obs
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		do "$hhdo/Function/00_frequency_table_one.do"


		export excel $export_table 	using "$out/endline/sumstat/MOM_EMPOWERMENT_SUMSTAT.xlsx", /// 
									sheet("Empowerment") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* by STRATUM 
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		global sub_grp stratum_num
		
		do "$hhdo/Function/00_frequency_crosstable.do"

		export excel $export_table 	using "$out/endline/sumstat/MOM_EMPOWERMENT_SUMSTAT.xlsx", /// 
									sheet("$sub_grp") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* by STRATUM 
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		global sub_grp wealth_quintile_ns
		
		do "$hhdo/Function/00_frequency_crosstable.do"


		export excel $export_table 	using "$out/endline/sumstat/MOM_EMPOWERMENT_SUMSTAT.xlsx", /// 
									sheet("$sub_grp") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	****************************************************************************
	** Women Empowerment [Midterm] **
	****************************************************************************
	
	use "$dta/pnourish_WOMEN_EMPOWER_final.dta", clear  

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	tab wempo_category, gen(wempo_category_)
	
	* Loop through the generated variables and update their labels
	foreach var of varlist wempo_category_* {
		
		* Get the current label
		local current_label : variable label `var'
		
		* Extract the part after "=="
		local new_label = substr("`current_label'", strpos("`current_label'", "==") + 2, .)
		
		* Trim any leading or trailing spaces
		local new_label = trim("`new_label'")
		
		* Update the variable label
		label variable `var' "`new_label'"
	}
	
	
	global outcomes wempo_childcare_yes wempo_mom_health_yes ///
					wempo_child_health_yes wempo_women_wages_yes wempo_major_purchase_yes ///
					wempo_visiting_yes wempo_women_health_yes wempo_child_wellbeing_yes ///
					wempo_grp_tot ///
					wempo_index progressivenss wempo_category_1 wempo_category_2 wempo_category_3 ///
					wempo_hnut_act_ja
	
	
	* All Obs
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		do "$hhdo/Function/00_frequency_table_one.do"


		export excel $export_table 	using "$out/endline/sumstat/MIDTERM_MOM_EMPOWERMENT_SUMSTAT.xlsx", /// 
									sheet("Empowerment") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* by STRATUM 
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		global sub_grp stratum_num
		
		do "$hhdo/Function/00_frequency_crosstable.do"

		export excel $export_table 	using "$out/endline/sumstat/MIDTERM_MOM_EMPOWERMENT_SUMSTAT.xlsx", /// 
									sheet("$sub_grp") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* by STRATUM 
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		global sub_grp wealth_quintile_ns
		
		do "$hhdo/Function/00_frequency_crosstable.do"


		export excel $export_table 	using "$out/endline/sumstat/MIDTERM_MOM_EMPOWERMENT_SUMSTAT.xlsx", /// 
									sheet("$sub_grp") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
		
	****************************************************************************
	** Knowledge Module **
	****************************************************************************
		
	use "$dta/endline/pnourish_knowledge_module_final.dta", clear 
	
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	global outcomes	iycf_k_tot iycf_k_yes hw_critical_soap_k 
	
	
	* All Obs
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		do "$hhdo/Function/00_frequency_table_one.do"


		export excel $export_table 	using "$out/endline/sumstat/MOM_KNOWLEDGE_SUMSTAT.xlsx", /// 
									sheet("Knowledge") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* by STRATUM 
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		global sub_grp stratum_num
		
		do "$hhdo/Function/00_frequency_crosstable.do"

		export excel $export_table 	using "$out/endline/sumstat/MOM_KNOWLEDGE_SUMSTAT.xlsx", /// 
									sheet("$sub_grp") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* by STRATUM 
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		global sub_grp wealth_quintile_ns
		
		do "$hhdo/Function/00_frequency_crosstable.do"


		export excel $export_table 	using "$out/endline/sumstat/MOM_KNOWLEDGE_SUMSTAT.xlsx", /// 
									sheet("$sub_grp") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	

	
// END HERE 



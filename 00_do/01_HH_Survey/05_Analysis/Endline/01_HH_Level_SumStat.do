/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	Endline: Data analysis - HH Level			
Author				:	Nicholus Tint Zaw
Date				: 	08/06/2024
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

	****************************************************************************
	* Respondent Characteristics *
	****************************************************************************

	use "$dta/endline/pnourish_respondent_info_final.dta", clear   

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	* var label 
	lab var resp_hhhead "Femal HH Head (Respondent)"
	
	* create a dummy var 
	local invars respd_status stratum_num respd_who wealth_quintile_ns resp_highedu hh_mem_highedu_all resp_occup 
	
	foreach var in `invars' {
	    
		tab `var', gen(`var'_)
		
		* Loop through the generated variables and update their labels
		foreach var of varlist `var'_* {
			
			* Get the current label
			local current_label : variable label `var'
			
			* Extract the part after "=="
			local new_label = substr("`current_label'", strpos("`current_label'", "==") + 2, .)
			
			* Trim any leading or trailing spaces
			local new_label = trim("`new_label'")
			
			* Update the variable label
			label variable `var' "`new_label'"
		}
	}
	
	
	global outcomes	respd_who_1 respd_who_2 ///
					respd_age ///
					respd_status_1 respd_status_2 respd_status_3 respd_status_4 respd_status_5 ///
					respd_preg respd_chid_num respd_phone resp_hhhead hh_tot_num ///
					stratum_num_1 stratum_num_2 stratum_num_3 stratum_num_4 stratum_num_5 stratum_num_6 ///
					wealth_quintile_ns_1 wealth_quintile_ns_2 wealth_quintile_ns_3 wealth_quintile_ns_4 wealth_quintile_ns_5 ///
					resp_highedu_1 resp_highedu_2 resp_highedu_3 resp_highedu_4 resp_highedu_5 resp_highedu_6 resp_highedu_7 ///
					resp_highedu_8 ///
					hh_mem_highedu_all_1 hh_mem_highedu_all_2 hh_mem_highedu_all_3 hh_mem_highedu_all_4 hh_mem_highedu_all_5 ///
					hh_mem_highedu_all_6 hh_mem_highedu_all_7 resp_occup_1 resp_occup_2 resp_occup_3 resp_occup_4 resp_occup_5 ///
					resp_occup_6 resp_occup_7 resp_occup_8 resp_occup_9 ///
					prgexpo_pn edu_exposure  
					
					
	
	* All Obs
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		do "$hhdo/Function/00_frequency_table_one.do"


		export excel $export_table 	using "$out/endline/sumstat/RESPONDENT_INFO_SUMSTAT.xlsx", /// 
									sheet("Respondent") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* by STRATUM 
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		global sub_grp stratum_num
		
		do "$hhdo/Function/00_frequency_crosstable.do"

		export excel $export_table 	using "$out/endline/sumstat/RESPONDENT_INFO_SUMSTAT.xlsx", /// 
									sheet("$sub_grp") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* by STRATUM 
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		global sub_grp wealth_quintile_ns
		
		do "$hhdo/Function/00_frequency_crosstable.do"


		export excel $export_table 	using "$out/endline/sumstat/RESPONDENT_INFO_SUMSTAT.xlsx", /// 
									sheet("$sub_grp") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore		

	****************************************************************************
	* HH Income *
	****************************************************************************

	use "$dta/endline/pnourish_INCOME_WEALTH_final.dta", clear   

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)
		
	* create a dummy var 
	local invars d4_inc_status jan_incom_status thistime_incom_status 
	
	foreach var in `invars' {
	    
		tab `var', gen(`var'_)
		
		* Loop through the generated variables and update their labels
		foreach var of varlist `var'_* {
			
			* Get the current label
			local current_label : variable label `var'
			
			* Extract the part after "=="
			local new_label = substr("`current_label'", strpos("`current_label'", "==") + 2, .)
			
			* Trim any leading or trailing spaces
			local new_label = trim("`new_label'")
			
			* Update the variable label
			label variable `var' "`new_label'"
		}
	}
	
	
	* var label 
	lab var d3_inc_lmth 			"Average monthly income (last month)"
	lab var income_lastmonth_trim	"Trimmed: Average monthly income (last month)"
	lab var d7_inc_govngo			"Received cash transfer from Gov/NGOs"
	lab var d4_inc_status			"Last month HH income"
	lab var hhitems_phone			"HH access to mobile phone"
	lab var prgexpo_pn 				"Know Project Nourish" 
	lab var edu_exposure			"Exposure with SBCC activities & materials"
	
	lab var d4_inc_status_1 		"Lower than last year"
	lab var d4_inc_status_2 		"Same as last year"
	lab var d4_inc_status_3 		"Higher than last year"
	
	
	global outcomes d3_inc_lmth income_lastmonth_trim	d7_inc_govngo ///
					d4_inc_status_1 d4_inc_status_2 d4_inc_status_3 ///
					d5_reason1 d5_reason2 d5_reason3 d5_reason4 d5_reason5 d5_reason6 ///
					d5_reason7 d5_reason8 d5_reason9 d5_reason10 d5_reason11 d5_reason12 ///
					d5_reason13 d5_reason14 d5_reason15 d5_reason16 d5_reason17 d5_reason18 d5_reason99 ///
					d6_cope1 d6_cope2 d6_cope3 d6_cope4 d6_cope5 d6_cope6 d6_cope7 d6_cope8 d6_cope9 ///
					d6_cope10 d6_cope11 d6_cope12 d6_cope13 d6_cope14 d6_cope15 d6_cope16 d6_cope17 ///
					d6_cope18 d6_cope19 d6_cope20 d6_cope99	///
					jan_incom_status_1 jan_incom_status_2 jan_incom_status_3 jan_incom_status_4 jan_incom_status_5 ///
					thistime_incom_status_1 thistime_incom_status_2 thistime_incom_status_3 thistime_incom_status_4 thistime_incom_status_5 ///
					hhitems_phone prgexpo_pn edu_exposure

	* All Obs
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		do "$hhdo/Function/00_frequency_table_one.do"


		export excel $export_table 	using "$out/endline/sumstat/HH_INCOME_SUMSTAT.xlsx", /// 
									sheet("HH_Income") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* by STRATUM 
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		global sub_grp stratum_num
		
		do "$hhdo/Function/00_frequency_crosstable.do"

		export excel $export_table 	using "$out/endline/sumstat/HH_INCOME_SUMSTAT.xlsx", /// 
									sheet("$sub_grp") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* by STRATUM 
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		global sub_grp wealth_quintile_ns
		
		do "$hhdo/Function/00_frequency_crosstable.do"


		export excel $export_table 	using "$out/endline/sumstat/HH_INCOME_SUMSTAT.xlsx", /// 
									sheet("$sub_grp") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore		

	
	****************************************************************************
	** WASH **
	****************************************************************************

	use "$dta/endline/pnourish_WASH_final.dta", clear   

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	* create a dummy var 
	local invars  waterpot_capacity water_sum_ladder water_rain_ladder water_winter_ladder ///
					sanitation_ladder hw_ladder
	
	foreach var in `invars' {
	    
		tab `var', gen(`var'_)
		
		* Loop through the generated variables and update their labels
		foreach var of varlist `var'_* {
			
			* Get the current label
			local current_label : variable label `var'
			
			* Extract the part after "=="
			local new_label = substr("`current_label'", strpos("`current_label'", "==") + 2, .)
			
			* Trim any leading or trailing spaces
			local new_label = trim("`new_label'")
			
			* Update the variable label
			label variable `var' "`new_label'"
		}
	}
	
	
	
	global outcomes water_sum_ladder_1 water_sum_ladder_2 water_sum_ladder_3 water_sum_ladder_4 ///
					water_rain_ladder_1 water_rain_ladder_2 water_rain_ladder_3 water_rain_ladder_4 ///
					water_winter_ladder_1 water_winter_ladder_2 water_winter_ladder_3 water_winter_ladder_4 ///
					sanitation_ladder_1 sanitation_ladder_2 sanitation_ladder_3 sanitation_ladder_4 ///
					hw_ladder_1 hw_ladder_2 hw_ladder_3 ///
					soap_yn hw_critical_soap ///
					water_sum_treat water_rain_treat water_winter_treat ///
					watertx_sum_good watertx_rain_good watertx_winter_good ///
					waterpot_yn waterpot_capacity_1 waterpot_capacity_2 waterpot_capacity_3 ///
					waterpot_condition1 waterpot_condition2 waterpot_condition3 waterpot_condition4 waterpot_condition0 

	* All Obs
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		do "$hhdo/Function/00_frequency_table_one.do"


		export excel $export_table 	using "$out/endline/sumstat/HH_WASH_SUMSTAT.xlsx", /// 
									sheet("WASH") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* by STRATUM 
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		global sub_grp stratum_num
		
		do "$hhdo/Function/00_frequency_crosstable.do"

		export excel $export_table 	using "$out/endline/sumstat/HH_WASH_SUMSTAT.xlsx", /// 
									sheet("$sub_grp") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* by STRATUM 
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		global sub_grp wealth_quintile_ns
		
		do "$hhdo/Function/00_frequency_crosstable.do"


		export excel $export_table 	using "$out/endline/sumstat/HH_WASH_SUMSTAT.xlsx", /// 
									sheet("$sub_grp") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore			
	
	****************************************************************************
	** FIES **
	****************************************************************************

	use "$dta/endline/pnourish_FIES_final.dta", clear   

	merge m:1 _parent_index using "$dta/endline/pnourish_WOMEN_EMPOWER_final.dta", keepusing(wempo_index wempo_category progressivenss)
	
	drop if _merge == 2 
	drop _merge 
	
	
	* Add Village Survey Info 
	global villinfo 	hfc_near_dist_dry hfc_near_dist_rain ///
						mkt_near_dist_dry mkt_near_dist_rain ///
						hfc_vill1 hfc_vill2 hfc_vill3 hfc_vill4 hfc_vill5 hfc_vill6 hfc_vill888 hfc_vill0 
	
	merge m:1 geo_vill using 	"$dta/endline/PN_Village_Survey_Endline_FINAL_Constructed.dta", ///
								keepusing($villinfo) 
	
	drop if _merge == 2
	drop _merge 
	
	
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

	
	* FIES - food insecurity dummy outcome * 
	* cutoffs for the raw score of 4+ = food insecurity 
	gen fies_insecurity = (fies_rawscore >= 4) 
	replace fies_insecurity = .m if mi(fies_rawscore)
	lab def fies_insecurity 0"Food secure" 1"Food insecue"
	lab var fies_insecurity "Food Insecurity"
	lab val fies_insecurity fies_insecurity
	tab fies_insecurity, m 
	
	* treated other and monestic education as missing
	gen resp_highedu_ci = resp_highedu
	replace resp_highedu_ci = .m if resp_highedu_ci > 7 
	tab resp_highedu_ci, m 
	
	replace resp_highedu = .m if resp_highedu > 7 
	replace resp_highedu = 4 if resp_highedu > 4 & !mi(resp_highedu)
	tab resp_highedu, m 
	
	
	replace hh_mem_highedu_all = 4 if hh_mem_highedu_all > 4 & !mi(hh_mem_highedu_all)
	tab hh_mem_highedu_all, m 
	
	* Interaction term 
	gen wempo_index_inter_wealth = wempo_index * NationalScore
	lab var wempo_index_inter_wealth "Women Empowerment Index * Health EquityTool National Score"
	
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)
	
	* create a dummy var 
	local invars  fies_category fies_insecurity
	
	foreach var in `invars' {
	    
		tab `var', gen(`var'_)
		
		* Loop through the generated variables and update their labels
		foreach var of varlist `var'_* {
			
			* Get the current label
			local current_label : variable label `var'
			
			* Extract the part after "=="
			local new_label = substr("`current_label'", strpos("`current_label'", "==") + 2, .)
			
			* Trim any leading or trailing spaces
			local new_label = trim("`new_label'")
			
			* Update the variable label
			label variable `var' "`new_label'"
		}
	}
	
	global outcomes	fies_category_1 fies_category_2 fies_category_3 fies_insecurity fies_rawscore
	
	* All Obs
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		do "$hhdo/Function/00_frequency_table_one.do"


		export excel $export_table 	using "$out/endline/sumstat/HH_FOOD_SECURITY_SUMSTAT.xlsx", /// 
									sheet("FIES") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* by STRATUM 
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		global sub_grp stratum_num
		
		do "$hhdo/Function/00_frequency_crosstable.do"

		export excel $export_table 	using "$out/endline/sumstat/HH_FOOD_SECURITY_SUMSTAT.xlsx", /// 
									sheet("$sub_grp") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* by STRATUM 
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		global sub_grp wealth_quintile_ns
		
		do "$hhdo/Function/00_frequency_crosstable.do"


		export excel $export_table 	using "$out/endline/sumstat/HH_FOOD_SECURITY_SUMSTAT.xlsx", /// 
									sheet("$sub_grp") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore		
	

	****************************************************************************
	** Program Exposure **
	****************************************************************************

	use "$dta/endline/pnourish_program_exposure_final.dta", clear   

	// get the women empowerment index 
	merge 1:1 uuid 	using "$dta/endline/pnourish_WOMEN_EMPOWER_final.dta", ///
					keepusing(wempo_index progressivenss) ///
					assert(3) nogen

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)
	
	
	global outcomes prgexpo_pn ///
					prgexpo_join1 prgexpo_join2 prgexpo_join3 prgexpo_join4 prgexpo_join5 ///
					prgexpo_join6 prgexpo_join7 prgexpo_join8 prgexpo_join9 ///
					prgexp_freq_1 prgexp_freq_2 prgexp_freq_3 prgexp_freq_4 ///
					prgexp_freq_5 prgexp_freq_6 prgexp_freq_7 prgexp_freq_8 ///
					prgexp_freq_9 ///
					prgexp_iec1 prgexp_iec2 prgexp_iec3 prgexp_iec4 prgexp_iec5 prgexp_iec6 prgexp_iec7 prgexp_iec0 /// 
					prgexp_iec_hw_yes prgexp_iec_hw_tot ///
					prgexp_iec_iycf_yes prgexp_iec_iycf_tot ///
					pn_access pn_muac_access pn_msg_access pn_wash_access pn_sbcc_access pn_hgdn_access pn_emgy_access
	
	
	* All Obs
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		do "$hhdo/Function/00_frequency_table_one.do"


		export excel $export_table 	using "$out/endline/sumstat/PROGRAM_EXPOSURE_SUMSTAT.xlsx", /// 
									sheet("Program_exposure") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* by STRATUM 
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		global sub_grp stratum_num
		
		do "$hhdo/Function/00_frequency_crosstable.do"

		export excel $export_table 	using "$out/endline/sumstat/PROGRAM_EXPOSURE_SUMSTAT.xlsx", /// 
									sheet("$sub_grp") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* by STRATUM 
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		global sub_grp wealth_quintile_ns
		
		do "$hhdo/Function/00_frequency_crosstable.do"


		export excel $export_table 	using "$out/endline/sumstat/PROGRAM_EXPOSURE_SUMSTAT.xlsx", /// 
									sheet("$sub_grp") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore		
	
	
// END HERE 



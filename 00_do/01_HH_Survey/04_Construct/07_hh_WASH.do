/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: hh WASH data cleaning 			
Author				:	Nicholus Tint Zaw
Date				: 	03/01/2023
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
	use "$dta/PN_HH_Survey_HH_Level_raw.dta", clear 
	
	* keep only HH income and characteristc modules 
	local maingeo 	org_name stratum geo_town township_name geo_vt geo_eho_vt_name geo_vill geo_eho_vill_name
	local mainresp 	respd_id respd_who respd_name respd_sex respd_age respd_status

	
	keep 	`maingeo' `mainresp' ///
			uuid _parent_index ///
			cal_dksum_start-cal_hw_end
			
	drop cal* // cla*
	
	** Drinking Water Ladder **
	lab def ws 	1 "Piped water into dwelling" ///
				2 "Piped water into yard/plot" ///
				3 "Public tap/standpipe" ///
				4 "Cart with small tank/drum" ///
				5 "Tanker/truck" ///
				6 "Tube well/borehole" ///
				7 "Protected dug well" ///
				8 "Unprotected dug well" ///
				9 "Protected spring" ///
				10 "Unprotected spring" ///
				11 "Rainwater collection" ///
				12 "Bottled purified water" ///
				13 "Surface water" ///
				888 "Others" ///


	foreach var of varlist water_sum water_rain water_winter {
		
		replace `var' = .m if mi(`var')
		
		tab `var', m 
		
		lab val `var' ws 
		tab `var', m 
	}
	
	
	
	
	// service ladder 
	lab def wladder 1"Safely Manage" 2"Basic" 3"Limited" 4"Unimproved" 5"Surface Water"
	
	local seasons sum rain winter 
	
	rename water_time water_time_sum 
	
	foreach v in `seasons' {
		
		tab water_`v', m 
		
		gen water_`v'_ladder 		= .m 
		
		replace water_`v'_ladder 	= 5 if water_`v' == 13
		replace water_`v'_ladder 	= 4 if water_`v' == 8 | water_`v' == 10
		replace water_`v'_ladder 	= 3 if ((water_`v' <= 7 | water_`v' == 9 | ///
											water_`v' == 11 | water_`v' == 12) & ///
											water_time_`v' > 30) | water_`v' == 888
		replace water_`v'_ladder 	= 2 if (water_`v' <= 7 | water_`v' == 9 | ///
											water_`v' == 11 | water_`v' == 12) & ///
											water_time_`v' <= 30 
		lab val water_`v'_ladder wladder 
		tab water_`v'_ladder, m 
		
	}
	
	
	/*
	tabulate water_sum_ladder, matcell(freq) matrow(names)
	matrix list freq
	matrix list names
	putexcel set "$out/frequency_table.xlsx", sheet("Sheet1") replace
	putexcel A1=("Latrine type") B1=("Freq.") C1=("Percent")
	putexcel A2=matrix(names) B2=matrix(freq) C2=matrix(freq/r(N)) 
	*/
	
	 
	** Sanitation Ladder ** 
	
	tab latrine_type
	
	lab def sladder 1"Safely Managed" 2"Basic" 3"Limited" 4"Unimproved" 5"Open Defecation"
		
	gen sanitation_ladder = .m 
	replace sanitation_ladder = 5 if latrine_type == 6
	replace sanitation_ladder = 4 if latrine_type == 5 | latrine_type == 4 | latrine_type == 888
	replace sanitation_ladder = 3 if (latrine_type == 1 | latrine_type == 2 | latrine_type == 3) & latrine_share == 1
	replace sanitation_ladder = 2 if (latrine_type == 1 | latrine_type == 2 | latrine_type == 3) & latrine_share == 0
	lab val sanitation_ladder sladder
	tab sanitation_ladder 
	
	
	** Hygiene Ladder ** 
	lab def hwladder 1"Basic" 2"Limited" 3"No Facility"
	
	
	tab observ_washplace
	tab1 observ_washplace0 observ_washplace1 observ_washplace2 observ_washplace3 observ_washplace4 observ_washplace888 
	
	tab observ_water
	tab soap_present



	gen hw_ladder = .m 
	
	replace hw_ladder = 1 if observ_water == 1 & soap_present == 1
	replace hw_ladder = 2 if (observ_water == 1 & soap_present != 1) | (observ_water != 1 & soap_present == 1)
	replace hw_ladder = 3 if observ_washplace4 == 1
	lab val hw_ladder hwladder 
	tab hw_ladder, m 
	
	
	** Handwashing at Critical Time ** 
	tab soap_yn, m 

	lab def soapfreq 	1 "Never" ///
						2 "Rarely/Sometimes" ///
						3 "Often" ///
						4 "Always" ///
						0 "Never experience this condition" 



	foreach var of varlist  soap_tiolet soap_clean_baby soap_child_faeces ///
							soap_before_eat soap_before_cook soap_feed_child ///
							soap_handle_child {
		
		lab val `var' soapfreq 
		replace `var' = .m if soap_yn != 1
		tab `var', m 
		
		local label : variable label `var'
		
		gen `var'_always = (`var' == 4)
		replace `var'_always = .m if mi(`var')
		lab var `var'_always "`label': Always"
		tab `var'_always, m 
		
	}
	
	// 5 critical times 
	/*
	ref: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9903007/#:~:text=Five%20moments%20are%20considered%20critical,food%2C%20and%20before%20eating%20food.
	
	Five moments are considered critical times to wash hands; 
		after defecation, 
		after handling child/adult feces or cleaning child's bottom, 
		after cleaning the environment, 
		before preparing food, and 
		before eating food.
	*/
	
	
	tab1 soap_tiolet soap_clean_baby soap_child_faeces ///
							soap_before_eat soap_before_cook soap_feed_child ///
							soap_handle_child
	
	gen hw_critical_soap 	= (	soap_tiolet == 4 & soap_child_faeces == 4 & ///
								soap_before_eat == 4 & soap_before_cook == 4 & ///
								soap_feed_child == 4)
	replace hw_critical_soap = .m if 	mi(soap_tiolet) | mi(soap_child_faeces) | ///
										mi(soap_before_eat) | mi(soap_before_cook) | ///
										mi(soap_feed_child)
	tab hw_critical_soap, m 
	lab var hw_critical_soap "Handwashing with soap always at 5 critical times"


	** Water Treatment **
	local seasons sum rain winter 
		
	foreach v in `seasons' {
		
		tab water_`v'_treatmethod, m 
		
		gen watertx_`v'_good 		= (	water_`v'_treatmethod1 == 1 | water_`v'_treatmethod2 == 1 | ///
										water_`v'_treatmethod3 == 1 | water_`v'_treatmethod4 == 1 | ///
										water_`v'_treatmethod5 == 1 | water_`v'_treatmethod6 == 1 | ///
										water_`v'_treatmethod7 == 1)
		replace watertx_`v'_good 	= .m if mi(water_`v'_treatmethod)
		lab var watertx_`v'_good "Use effective water treatment: `v'"
		tab watertx_`v'_good, m 
		
	}
	
	** Water Pot ** 
	// waterpot_yn
	tab waterpot_yn, m 

	// waterpot_capacity
	replace waterpot_capacity = .m if waterpot_yn != 1
	tab waterpot_capacity, m 
	
	// waterpot_condition
	foreach var of varlist 	waterpot_condition1 waterpot_condition2 ///
							waterpot_condition3 waterpot_condition4 ///
							waterpot_condition0 {
		
		replace `var' = .m if mi(waterpot_condition)
	}
	tab1 waterpot_condition1 waterpot_condition2 waterpot_condition3 waterpot_condition4 waterpot_condition0, m 


	* Add Weight variable *
	merge m:1 geo_vill using "$dta/pnourish_hh_weight_final.dta", keepusing(stratum_num weight_final)
	
	keep if _merge == 3
	
	drop _merge 
	
	
	* Add Wealth Quantile variable **
	// drop prgexpo_pn
	merge m:1 _parent_index using "$dta/pnourish_INCOME_WEALTH_final.dta", ///
							keepusing(income_lastmonth NationalQuintile NationalScore hhitems_phone prgexpo_pn edu_exposure)
	
	keep if _merge == 3
	
	drop _merge 

	* Add Village Survey Info 
	global villinfo 	hfc_near_dist_dry hfc_near_dist_rain ///
						mkt_near_dist_dry mkt_near_dist_rain ///
						dev_proj_tot ///
						pn_yes pn_sbcc_yn pn_muac_yn pn_wsbcc_yn pn_wash_yn pn_emgy_yn pn_hgdn_yn pn_msg_yn
	
	merge m:1 geo_vill using 	"$dta/PN_Village_Survey_FINAL_Constructed.dta", ///
								keepusing($villinfo)
	
	drop if _merge == 2
	
	drop _merge 
	

	* Check for Missing variable label and variable label 
	// iecodebook template using "$out/pnourish_WASH_final.xlsx" // export template
	
	iecodebook apply using "$raw/pnourish_WASH_cleaning.xlsx" 


	** SAVE for analysis dataset 
	save "$dta/pnourish_WASH_final.dta", replace  


// END HERE 



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
		
	gen sanitation_ladder = .m 
	replace sanitation_ladder = 5 if latrine_type == 6
	replace sanitation_ladder = 4 if latrine_type == 5 | latrine_type == 4 | latrine_type == 888
	replace sanitation_ladder = 3 if (latrine_type == 1 | latrine_type == 2 | latrine_type == 3) & latrine_share == 1
	replace sanitation_ladder = 2 if (latrine_type == 1 | latrine_type == 2 | latrine_type == 3) & latrine_share == 0
	lab val sanitation_ladder wladder
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
	
	
	/*
	soap_tiolet
	soap_clean_baby
	soap_child_faeces
	
	soap_before_eat
	soap_before_cook
	soap_feed_child

	soap_handle_child
	*/

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


	
	** SAVE for analysis dataset 
	save "$dta/pnourish_WASH_final.dta", replace  


// END HERE 



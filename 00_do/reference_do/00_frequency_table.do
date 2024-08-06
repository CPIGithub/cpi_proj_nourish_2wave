/*******************************************************************************
Purpose				:	generate sum-stat table			
Author				:	Nicholus Tint Zaw
Date				: 	10/31/2022
Modified by			:

*******************************************************************************/
//set trace on

gen var_name = ""
	label var var_name "Indicator (Label)"
	
	
gen var_df = ""
	label var var_df "Variable Name"

foreach var in  total_N count_n percent_mean sd median iqr {
	gen `var' = 0
	label var `var' "`var'"
}

local i = 1
foreach var of global outcomes {
    
	count if !mi(`var') 
	
	if `r(N)' > 0 {
	
		di "`var' going to make label assignment"
		
		local label : variable label `var'
		
		di "`var' finish label assignment"
		di "`var' going to replace label assignment"

		
		tab  var_name, m 
		di "`label'"
		di `i'
		
		replace var_name = "`label'" in `i'
		
		replace var_df 		= "`var'" in `i'
		
		
		di "`var' going finish label assignment"

				
		di "`var' start summary"
		quietly sum `var', d

		
		global total_N 			= `r(N)'
		replace total_N			= $total_N in `i'
		
		global count_n			= `r(sum)'
		replace count_n			= $count_n in `i'
	
		global percent_mean 	= round(`r(mean)', 0.0001)
		replace percent_mean 	= $percent_mean in `i'
		
		global sd 				= round(`r(sd)', 0.01)
		replace sd 				= $sd in `i'
		
		global median			= round(`r(p50)', 0.0001)
		replace median			= $median in `i'
		
		global iqr				= round((`r(p75)' - `r(p25)'), 0.0001)
		replace iqr				= $iqr in `i'
			
			
		/*
		sum `var'
		if (`r(min)' == 0 & (`r(max)' == 1 | `r(max)' == 0))  {
			
			replace sd 				=  .m in `i'
			
			global percent_mean 	= ($percent_mean * 100)
			replace percent_mean 	= $percent_mean in `i'
		
		}
		else {
			
			replace count_n			= .m in `i'
			
			global sd 				= round(`r(sd)', 0.01)
			replace sd 				= $sd in `i'
			
		}
		*/
		* white space correction
		
		foreach indicator in  total_N count_n percent_mean sd median iqr {
			
			replace `indicator' = .m  if var_df == "white_space"
		}
		
		replace var_df 		= "" if var_df == "white_space"
	}
	
	
	local i = `i' + 1
	di "`var' finished"
	
}


drop if total_N == 0     // get rid of extra raws
global export_table var_df var_name total_N count_n percent_mean sd median iqr



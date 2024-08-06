/*******************************************************************************
Purpose				:	generate sum-stat table			
Author				:	Nicholus Tint Zaw
Date				: 	10/31/2022
Modified by			:

*******************************************************************************/
// set trace on

gen var_name = ""
	label var var_name "Indicator (Label)"
	
	
gen var_df = ""
	label var var_df "Variable Name"

foreach var in  total_N count_n percent_mean ub lb wt_N {
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
		
		* identify continious or binary var 
		qui: levelsof `var'
		
		 if "`r(levels)'" == "0 1" /*| "`r(levels)'" == "0" | "`r(levels)'" == "1"*/ {
		 	
			capture svy: proportion `var' //  for binary outcomes
			matrix table = r(table) 
			
			local wt_N				= e(N_pop)
			local total_N 			= e(N)
			
			* Proportion + 95 CI 
			global percent_mean 	= round(table[1,2] * 100, 0.1)
			replace percent_mean 	= $percent_mean in `i'
			
			global lb 				= round(table[5,2] * 100, 0.1)
			replace lb 				= $lb in `i'
			
			global ub				= round(table[6,2] * 100, 0.1)
			replace ub				= $ub in `i'
			
			}
			else {
				
				capture svy: mean `var' //  for continuous outcomes
				matrix table = r(table) 
				
				local wt_N				= e(N_pop)
				local total_N 			= e(N)
				
				* Mean + 95 CI 
				global percent_mean 	= round(table[1,1], 0.01)
				replace percent_mean 	= $percent_mean in `i'
				
				global lb 				= round(table[5,1], 0.01)
				replace lb 				= $lb in `i'
				
				global ub				= round(table[6,1], 0.01)
				replace ub				= $ub in `i'
					
		}

		di "`var' start summary"
		quietly sum `var', d
		local count_n = `r(sum)'
		
		* Common Parameters 
		global wt_N				= `wt_N'
		replace wt_N			= $wt_N in `i'

		global total_N 			= `total_N'
		replace total_N			= $total_N in `i'
		
		global count_n			= `count_n'
		replace count_n			= $count_n in `i'
		
		* white space correction
		
		foreach indicator in  total_N count_n percent_mean ub lb wt_N {
			
			replace `indicator' = .m  if var_df == "white_space"
		}
		
		replace var_df 		= "" if var_df == "white_space"
	}
	
	
	local i = `i' + 1
	di "`var' finished"
	
}


drop if total_N == 0     // get rid of extra raws
global export_table var_df var_name total_N count_n percent_mean ub lb wt_N



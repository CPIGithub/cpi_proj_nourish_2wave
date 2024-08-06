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

* identify the unique number of category 
distinct $sub_grp
local grp_num = `r(ndistinct)'

tab $sub_grp, gen(grp_)

* Loop through the generated variables and update their labels
foreach var of varlist grp_* {
    * Treat new var as 0
	replace `var' = 0 
	
	* Get the current label
    local current_label : variable label `var'
    
    * Extract the part after "=="
    local new_label = substr("`current_label'", strpos("`current_label'", "==") + 2, .)
    
    * Trim any leading or trailing spaces
    local new_label = trim("`new_label'")
    
    * Update the variable label
    label variable `var' "`new_label'"
}

gen p_val = .
	label var p_val "P value"
	

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
		
		 if "`r(levels)'" == "0 1" /*|  "`r(levels)'" == "0" |  "`r(levels)'" == "1"*/ {
		 	
			capture svy: mean `var', over($sub_grp) //  for binary outcomes
			matrix table = r(table) 

			svy:tab $sub_grp `var' , row
			local p_val = e(p_Pear)
						
			global p_val 				= round(`p_val', 0.0001)
			replace p_val				= $p_val in `i'
				
			forvalues x = 1/`grp_num' {
			    
				di table[1,`x']
				
				global grp_`x' 				= round(table[1,`x'] * 100, 0.1)
				replace grp_`x' 			= ${grp_`x'} in `i'
				
				}		
			}
			else {
				
				capture svy: mean `var', over($sub_grp) //  for continuous outcomes
				matrix table = r(table) 
				
				svy: regress `var' i.$sub_grp 
				local p_val = e(p)
				
				global p_val 				= round(`p_val', 0.0001)
				replace p_val				= $p_val in `i'
			
				forvalues x = 1/`grp_num' {
					
					global grp_`x' 				= round(table[1,`x'], 0.01)
					replace grp_`x' 			= ${grp_`x'} in `i'
					
					}	
					
		}
		
		* white space correction
		lookfor grp_
		
		foreach indicator in  `r(varlist)' p_val  {
			
			replace `indicator' = .m  if var_df == "white_space"
		}
		
		replace var_df 		= "" if var_df == "white_space"
	}
	
	
	local i = `i' + 1
	di "`var' finished"
	
}


drop if var_name == ""     // get rid of extra raws

lookfor grp_
global export_table var_df var_name `r(varlist)' p_val 



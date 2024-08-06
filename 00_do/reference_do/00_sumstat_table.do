/*******************************************************************************
Purpose				:	generate sum-stat table			
Author				:	Nicholus Tint Zaw
Date				: 	10/31/2022
Modified by			:

*******************************************************************************/
//set trace on

gen var_name = ""
	label var var_name "   "

foreach var in count mean sd median min max  {
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
		
		di "`var' going finish label assignment"

				
		di "`var' start summary"
		quietly sum `var', d

		global count 	= `r(N)'
		replace count	= $count in `i'
		
		global mean 	= round(`r(mean)', 0.001)
		replace mean 	= $mean in `i'
		
		global sd		= round(`r(sd)', 0.001)
		replace sd		= $sd in `i'

		global median 	= round(`r(p50)', 0.001)
		replace median 	= $median in `i'
		
		global min		= round(`r(min)', 0.001)
		replace min		= $min in `i'
		
		global max		= round(`r(max)', 0.001)
		replace max		= $max in `i'
		
	}
	
	
	local i = `i' + 1
	di "`var' finished"
	
}

drop if count == 0     //get rid of extra raws
global export_table var_name count mean sd median min max



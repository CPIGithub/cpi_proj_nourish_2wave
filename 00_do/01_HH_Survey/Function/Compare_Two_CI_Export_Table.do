	/*******************************************************************************
	Purpose				:	generate a CI comparision table			
	Author				:	Nicholus Tint Zaw
	Date				: 	04/21/2025
	Modified by			:

	*******************************************************************************/

	// set trace on

	gen var_name = ""
		label var var_name "Indicator (Label)"
		
		
	gen var_df = ""
		label var var_df "Variable Name"

	foreach var in  diff_N diff_ci diff_se diff_pval {
		gen `var' = .m
		label var `var' "`var'"
	}

	local i = 1
	foreach var of global outcomes {
		
		count if !mi(`var') 
		
		if `r(N)' > 0 {
		
			di "`var' going to make label assignment"
			
			local label : variable label `var'
			
			replace var_name = "`label'" in `i'
			
			replace var_df 		= "`var'" in `i'
			
			di "`var' finish label assignment"
			di "`var' going to replace label assignment"

			tab  var_name, m 
			di "`label'"
		
			** CI calculation << start here ** 
			* Bivariate CI 
			quietly sum `var'
			
			local var_min = r(min)
			local var_max = r(max)
			
			quietly conindex `var', rank(rank_var) svy wagstaff bounded limits(`var_min' `var_max') compare(group_var)

			scalar N_D		= r(N)
			scalar CI_D 	= r(Diff)
			scalar SE_D 	= r(Diffse)
			scalar Z_D 		= r(z)
			* Replace with actual degrees of freedom (df = #PSUs - #strata)
			svydescribe
			return list

			scalar DF_D 	= (r(N_units) - r(N_strata))
			scalar DF_Pval 	= 2 * ttail(DF_D, abs(Z_D))
						
			* Assigned values to export varaibles 
			replace diff_N 		= N_D in `i'
			replace diff_ci 	= round(CI_D, 0.01) in `i'
			replace diff_se 	= round(SE_D, 0.01) in `i'
			replace diff_pval 	= round(DF_Pval, 0.0001) in `i'
			 

		}
		
		
		local i = `i' + 1
		di "`var' finished"
		
	}


	drop if diff_N == 0     // get rid of extra raws
	keep 	var_df var_name ///
			diff_N diff_ci diff_se diff_pval




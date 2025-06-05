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

	foreach var in  biv_N biv_CI biv_SE biv_pval ///
					total_N percent_mean achi_index {
		gen `var' = 0
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

			* Outcome Mean
			quietly svy: mean `var'
			matrix m = e(b)
			scalar MEAN = m[1,1]
			
			global total_N 			= `e(N)'
			replace total_N			= $total_N in `i'
		
			global percent_mean 	= round(MEAN, 0.0001)
			replace percent_mean 	= $percent_mean in `i'
		
		
			** CI calculation << start here ** 
			* Multivariate CI 
			quietly sum `var'
			
			local var_min = r(min)
			local var_max = r(max)
			
			* Estimate full model and detect omitted variables
			svy: logit `var' $X_raw
			matrix b = e(b)
			local names : colfullnames e(b)
			
			di "`names'"

			* Initialize clean list
			local clean_names

			* Loop through all names
			foreach v of local names {
				
				* Remove outcome prefix
				local stripped = subinstr("`v'", "`var':", "", .)
				
				* Skip _cons and omitted regressors (with "o.")
				if strpos("`stripped'", "_cons") == 0 & strpos("`stripped'", "o.") == 0 {
					local clean_names `clean_names' `stripped'
				}
			}

			* Display cleaned variable list
			di "`clean_names'"

			* redefine the unfair var set without omitted var 
			global X "`clean_names'"
	
			capture svy: logit `var' $X
			
			if _rc == 403 {
				
				di "convergence not achieved: `var'"
				
			}
			if !_rc { 
				
				predict rank_var, pr
			
				quietly conindex `var', rank(rank_var) svy wagstaff bounded limits(`var_min' `var_max')

				scalar N_biv	= r(N)
				scalar ci_biv 	= r(CI)
				scalar se_biv 	= r(CIse)
				scalar z_biv 	= ci_biv / se_biv
				* Replace with actual degrees of freedom (df = #PSUs - #strata)
				svydescribe
				return list

				scalar df_biv = (r(N_units) - r(N_strata))
				scalar p_t_biv = 2 * ttail(df_biv, abs(z_biv))
				
				* Achievement index - WB chapter 9 - formula 9.9  (mean * (1 - CI))
				global achi_index 	= ($percent_mean * (1 - ci_biv))
				replace achi_index 	= $achi_index in `i'
				
				* Assigned values to export varaibles 
				replace biv_N 		= round(N_biv, 0.0001) in `i'
				replace biv_CI 		= round(ci_biv, 0.0001) in `i'
				replace biv_SE 		= round(se_biv, 0.0001) in `i'
				replace biv_pval 	= round(p_t_biv, 0.0001) in `i'
				
				drop rank_var
			
			}
			
		}
		
		
		local i = `i' + 1
		di "`var' finished"
		
	}

	drop if biv_N == 0     // get rid of extra raws
	keep 	var_df var_name ///
			biv_N biv_CI biv_SE biv_pval ///
			total_N percent_mean achi_index ///




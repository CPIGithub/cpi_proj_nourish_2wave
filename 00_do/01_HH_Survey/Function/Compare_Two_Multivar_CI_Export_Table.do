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

	
	
	levelsof group_var, local(grps)
			
	foreach g in `grps' {
	
		gen model_note_`g' = "" 
		
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
			* Multivariate CI 
			quietly sum `var'
			
			local var_min = r(min)
			local var_max = r(max)
			
			* Estimate full model and detect omitted variables
			levelsof group_var, local(grps)
			
			foreach g in `grps' {
				
				svy: logit `var' $X_raw if group_var == `g'
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
		
				capture svy: logit `var' $X if group_var == `g'
				
				scalar logit_no_`g' = (_rc)
				
				if _rc == 403 {
					
					di "convergence not achieved: `var'"
					
					replace model_note_`g' 	= "convergence not achieved" in `i' 
					
				}
				if !_rc { 
					
					predict rank_var_`g' if group_var == `g', pr
					
					di "prediction finished for: rank_var_`g'" logit_no_`g'
					
				}
				
			}
			
			local logit_no = 0
			
			di "before:  `logit_no'"
			
			foreach g in `grps' {
				
				capture confirm variable rank_var_`g' 

				if !_rc {
					
					local logit_no = `logit_no' + logit_no_`g'
					
					di "after `g' update: `logit_no'"
							
				}
				else {
					
					local logit_no = `logit_no' + 1
				}
				
				di  "logit model status for `var': `logit_no'"
			}
					
				
			if `logit_no' == 0 { 
				
				gen rank_var = .m 
				
				foreach g in `grps' {
					
					replace rank_var = rank_var_`g' if rank_var == .m & !mi(rank_var_`g')
					
				}
							
				/*quietly*/ conindex `var', rank(rank_var) svy wagstaff bounded limits(`var_min' `var_max') compare(group_var)
				
				scalar N_D		= r(N)
				scalar CI_D 	= r(Diff)
				scalar SE_D 	= r(Diffse)
				scalar Z_D 		= r(z)
			
				scalar DF_Pval 	= 2 * normal( -abs(Z_D) )
							
				* Assigned values to export varaibles 
				replace diff_N 		= N_D in `i'
				replace diff_ci 	= round(CI_D, 0.01) in `i'
				replace diff_se 	= round(SE_D, 0.01) in `i'
				replace diff_pval 	= round(DF_Pval, 0.0001) in `i'
				
				//drop rank_var*
			
			}
			
			drop rank_var*
			
		}
		
		
		local i = `i' + 1
		di "`var' finished"
		
	}

	drop if diff_N == 0     // get rid of extra raws
	keep 	var_df var_name ///
			diff_N diff_ci diff_se diff_pval model_note*




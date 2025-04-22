	/*******************************************************************************
	Purpose     : Generic svy: regression table generator for 2, 3, or 4 comparison groups
	Author      : Nicholus Tint Zaw
	Updated     : 2025-03-27
	*******************************************************************************/
	//set trace on

	* Determine number of distinct groups
	distinct group_var
	global grp_level = r(ndistinct)

	* Calculate number of pairwise comparisons (n choose 2)
	local n_comp = `= $grp_level * ($grp_level - 1) / 2'
	
	* Initialize output vars
	gen var_df = ""
	label var var_df "Variable Name"
	
	gen var_name = ""
	label var var_name "Indicator (Label)"
	
	foreach var in total_N chi2 prob_chi2 {
		gen `var' = .m
		label var `var' "`var'"
	}
	
	forvalues c_g = 1/$grp_level {
		foreach var in obs mean_sd {
			gen `var'_`c_g' = .m
			label var `var'_`c_g' "`var'_`c_g'"
		}
	}

	forvalues c_g = 1/`n_comp' {
		foreach var in coef pval ci_95 {
			gen `var'_`c_g' = .m
			label var `var'_`c_g' "`var'_`c_g'"
		}
	}

	order chi2 prob_chi2, after(ci_95_`n_comp')

	* Main loop over outcomes
	local i = 1
	foreach var of global outcomes {

		count if !mi(`var') 

			if `r(N)' > 0 {

			* di "`var' going to make label assignment"
			local label : variable label `var'

			*di "`var' finish label assignment"
			*di "`var' going to replace label assignment"
			*tab  var_name, m 
			*di "`label'"
			*di `i'
			
			replace var_name = "`label'" in `i'
			
			replace var_df 		= "`var'" in `i'

			* di "`var' going finish label assignment"

			* di "`var' start summary"
			
			* Identify the outcome var type
			qui: levelsof `var'
			local vartype = cond("`r(levels)'" == "0 1", "dummy", "continuous")
			
			* Est Mean | SD 
			quietly mean `var', over(group_var)
			estat sd 
			
			mat m 	= e(b)
			mat sd 	= e(sd)
			mat obs = e(_N)
			
			forvalues c_g = 1/$grp_level {

			scalar MEAN		= m[1,`c_g']
			scalar SD		= sd[1,`c_g']
			scalar OBS 		= obs[1,`c_g']

			* output table assignment
			if "`vartype'" == "dummy" {

				replace obs_`c_g' 		= OBS in `i'
					
				global mean_str 		= string(MEAN * 100, "%8.2f")
				//global sd_str			= string(SD * 100, "%8.2f")

				tostring mean_sd_*, replace 
				replace mean_sd_`c_g'	= "$mean_str" in `i'
				 								
				
			}
			else if "`vartype'" == "continuous" {
				
				replace obs_`c_g' 		= OBS in `i'
					
				global mean_str 		= string(MEAN, "%8.2f")
				global sd_str			= string(SD, "%8.2f")

				tostring mean_sd_*, replace 
				replace mean_sd_`c_g'	= "$mean_str" + " ± " + "$sd_str" in `i'
		
			 }

		}
			
			* Run Multi-level Regression
			 if "`vartype'" == "dummy" {
			 	//di "model running fr `var'"
				capture xtmixed `var' i.group_var ||neighborhood:, vce(robust) //  for binary outcomes
			
					}
					
			else if "`vartype'" == "continuous" {
				//di "model running fr `var'"
				capture xtmixed `var' i.group_var ||neighborhood:, mle //  for continuous outcomes
					}

			if _rc == 504 {
				if "`perform'"!="quietly" {
					di as err "(mixed: could not calculate numerical derivatives -- discontinuous region with missing values encountered)"
					
					//tostring ci_95_*, replace 
					//replace ci_95_`c_g'			= "mixed: could not calculate numerical derivatives" in `i'
				}
			}
			if _rc == 459 {
				if "`perform'"!="quietly" {
					di as err "(mixed: `var' is constant and zero)"
					
					//tostring ci_95_*, replace 
					//replace ci_95_`c_g'			= "`var' is constant and zero" in `i'
				}
			}
			
			if !_rc { 
				
				* Store model diagnostics
				replace total_N			= `e(N)' in `i'
				 
				replace chi2			= round(`e(chi2)', 0.0001) in `i'
	 
				replace prob_chi2		= round(`e(p)', 0.0001) in `i'

				* Marginal effects with pairwise comparison
				* extract coefficient and p-values
				capture margins group_var, pwcompare(effects) post
				
				if _rc == 322 {
	
					di as err "`var': invalid pairwise comparison; term with only one level not allowed"
				}

				if !_rc { 
				
					matrix m = r(table_vs)
						
						forvalues c_g = 1/`n_comp' {

						scalar beta		= m[1,`c_g']
						scalar p_val	= m[4,`c_g']
						scalar lb 		= m[5,`c_g']
						scalar ub 		= m[6,`c_g']

						* output table assignment
						if "`vartype'" == "dummy" {

							replace coef_`c_g' 		= round(beta * 100, 0.01) in `i'

							replace pval_`c_g' 		= round(p_val, 0.0001) in `i'
								
							global lb_str 			= string(lb * 100, "%8.2f")
							global ub_str			= string(ub * 100, "%8.2f")

							tostring ci_95_*, replace 
							replace ci_95_`c_g'			= "($lb_str" + " , " + "$ub_str)" in `i'
							* replace ci_95_`c_g' = "(" + string(lb, "%8.2f") + " , " + string(ub, "%8.2f") + ")" in `i'						 								
							
						}
						else if "`vartype'" == "continuous" {
							
							replace coef_`c_g' 		= round(beta, 0.01) in `i'

							replace pval_`c_g' 		= round(p_val, 0.0001) in `i'
								
							global lb_str 			= string(lb, "%8.2f")
							global ub_str			= string(ub, "%8.2f")

							tostring ci_95_*, replace 
							replace ci_95_`c_g'			= "($lb_str" + " , " + "$ub_str)" in `i'
							* replace ci_95_`c_g' = "(" + string(lb, "%8.2f") + " , " + string(ub, "%8.2f") + ")" in `i'						 	
							
						 }

					}
				
				}

			* white space correction
			replace var_df 		= "" if var_df == "white_space"
		
			}
		
		}


	local i = `i' + 1
	*di "`var' finished"

	}

	drop if mi(var_df) // total_N == 0     // get rid of extra raws
	
	if $grp_level == 2 {
		
		keep 	var_df var_name total_N ///
				obs_1 mean_sd_1 coef_1 pval_1 ci_95_1 ///
				obs_2 mean_sd_2 coef_2 pval_2 ci_95_2 ///
				chi2 prob_chi2
				
		order 	var_df var_name total_N ///
				obs_1 mean_sd_1 coef_1 pval_1 ci_95_1 ///
				obs_2 mean_sd_2 coef_2 pval_2 ci_95_2 ///
				chi2 prob_chi2		
	}
	else if $grp_level == 3 {
		
		keep 	var_df var_name total_N ///
				obs_1 mean_sd_1 coef_1 pval_1 ci_95_1 ///
				obs_2 mean_sd_2 coef_2 pval_2 ci_95_2 ///
				obs_3 mean_sd_3 coef_3 pval_3 ci_95_3 ///
				chi2 prob_chi2
				
		order 	var_df var_name total_N ///
				obs_1 mean_sd_1 coef_1 pval_1 ci_95_1 ///
				obs_2 mean_sd_2 coef_2 pval_2 ci_95_2 ///
				obs_3 mean_sd_3 coef_3 pval_3 ci_95_3 ///
				chi2 prob_chi2
		
	}
		else {
		
		keep 	var_df var_name - chi2 prob_chi2
		
	}
	
	
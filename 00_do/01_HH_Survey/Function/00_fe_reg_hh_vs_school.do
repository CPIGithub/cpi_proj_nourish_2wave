	/*******************************************************************************
	Purpose     : regression table generator for FE HH Vs FE School
	Author      : Nicholus Tint Zaw
	Updated     : 2025-03-27
	*******************************************************************************/
	//set trace on

	* Determine number of distinct groups
	distinct group_var
	global grp_level = r(ndistinct)
	
	* Initialize output vars
	gen var_df = ""
	label var var_df "Variable Name"
	
	gen var_name = ""
	label var var_name "Indicator (Label)"
	
	forvalues x = 1/$grp_level {	
		
		foreach rq in main {
		
		foreach var in obs coef se pval ci_95 {
						
				gen `rq'_`var'_`x' = .m
				label var `rq'_`var'_`x' "`rq'_`var'_`x'"	
				
			}
		}
		
	}
		
	foreach rq in geo comp {
		
	forvalues y = 1/$grp_level {
	
		
		forvalues x = 1/$grp_level {
		
			foreach var in obs coef se pval ci_95 {
	
				gen m`y'_`rq'_`var'_`x' = .m
				label var m`y'_`rq'_`var'_`x' "m`y'_`rq'_`var'_`x'"	
				
			}
		}
		
	}
	}
	
	tostring *_ci_95_* *_coef_* *_se_* *_pval_* , replace 
	
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
			
			** Run Different Regression Models **
			
			** Approach 1: with all sample pooled all the geo area together (Ghanna's approach)
			di "going to run model"
			local main_models `""reg `var'" "reg `var', vce(cluster cluster_var)" "mixed `var' || cluster_var:""'
			

			local z = 1 
			foreach model in `main_models' {
				
				di "xxxxxxxxxxxxxxxxxxxxxxx Model: `model' xxxxxxxxxxxxxxxxxxxxxxxx"
				
				`model' // run the model
				
				mat m = r(table)
				
				scalar BETA		= m[1,1]
				scalar SE		= m[2,1]
				scalar PVAL		= m[4,1]
				scalar LB 		= m[5,1]
				scalar UB 		= m[6,1]
				
				replace main_obs_`z' 	= e(N) in `i' 
				replace main_coef_`z' 	= string(BETA, "%8.2f")  in `i'		// round(BETA, 0.01) in `i'
				replace main_se_`z' 	= string(SE, "%8.2f")  in `i' 		// round(SE, 0.01) in `i'
				replace main_pval_`z' 	= string(PVAL, "%8.4f")	 in `i'		// round(PVAL, 0.0001) in `i'
					
				global lb_str 			= string(LB, "%8.2f")
				global ub_str			= string(UB, "%8.2f")

				replace main_ci_95_`z'	= "($lb_str" + " , " + "$ub_str)" in `i'
			
			
				local z = `z' + 1
			}


			local geo_models `""reg `var' i.group_var" "reg `var' i.group_var, vce(cluster cluster_var)" "mixed `var' i.group_var || cluster_var:""'

			local y = 1 
			foreach model in `geo_models' {
				
				di "xxxxxxxxxxxxxxxxxxxxxxx Model: `model' xxxxxxxxxxxxxxxxxxxxxxxx"
				
				`model' // run the model 
				
				local est_models `""margins group_var" "margins group_var, pwcompare(effects) post""'
				
				local z = 1
				foreach est_model in `est_models' {
					
					* Perform estimation 
					`est_model' // estimation 
					
					* Matrix assignment
					if `z' == 1 {
						
						mat m = r(table)
					}
					else if `z' == 2 {
						
						mat m = r(table_vs)
					}
					
					* Extra values 
					forvalues c_g = 1/$grp_level {
						
					scalar BETA		= m[1,`c_g']
					scalar SE		= m[2,`c_g']
					scalar PVAL		= m[4,`c_g']
					scalar LB 		= m[5,`c_g']
					scalar UB 		= m[6,`c_g']

					* output table assignment
					if `z' == 1 {
						
						replace m`y'_geo_obs_`c_g' 		= e(N) in `i' 
						replace m`y'_geo_coef_`c_g' 	= string(BETA, "%8.2f")  in `i' // round(BETA, 0.01) in `i'
						replace m`y'_geo_se_`c_g' 		= string(SE, "%8.2f")  in `i'	// round(SE, 0.01) in `i'
						replace m`y'_geo_pval_`c_g' 	= string(PVAL, "%8.4f")	 in `i'	// round(PVAL, 0.0001) in `i'
							
						global lb_str 					= string(LB, "%8.2f")
						global ub_str					= string(UB, "%8.2f")

						replace m`y'_geo_ci_95_`c_g'	= "($lb_str" + " , " + "$ub_str)" in `i'
					
						}
					else if `z' == 2 {
						
						replace m`y'_comp_obs_`c_g' 	= e(N) in `i' 
						replace m`y'_comp_coef_`c_g' 	= string(BETA, "%8.2f")	 in `i'	// round(BETA, 0.01) in `i'
						replace m`y'_comp_se_`c_g' 		= string(SE, "%8.2f")  in `i'	// round(SE, 0.01) in `i'
						replace m`y'_comp_pval_`c_g' 	= string(PVAL, "%8.4f")	 in `i'	// round(PVAL, 0.0001) in `i'
							
						global lb_str 					= string(LB, "%8.2f")
						global ub_str					= string(UB, "%8.2f")

						replace m`y'_comp_ci_95_`c_g'	= "($lb_str" + " , " + "$ub_str)" in `i'
					
						}
					
					}
					
					local z = `z' + 1
				}
				
				local y = `y' + 1
		
			}
			

			* white space correction
			replace var_df 		= "" if var_df == "white_space"
		
		}


	local i = `i' + 1
	*di "`var' finished"

	}

	drop if mi(var_df) // total_N == 0     // get rid of extra raws
	drop $outcomes cluster_var group_var
	
	
	
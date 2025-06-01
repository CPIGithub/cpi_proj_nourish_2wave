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
					mulv_N mulv_CI mulv_SE mulv_pval ///
					z_test z_Pval ///
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
			* Bivariate CI 
			quietly conindex `var', rank(bivar_rank) svy wagstaff bounded limits(0 1)

			scalar N_biv	= r(N)
			scalar ci_biv 	= r(CI)
			scalar se_biv 	= r(CIse)
			scalar z_biv 	= ci_biv / se_biv
			* Replace with actual degrees of freedom (df = #PSUs - #strata)
			svydescribe
			return list

			scalar df_biv = (r(N_units) - r(N_strata))
			scalar p_t_biv = 2 * ttail(df_biv, abs(z_biv))

			* Multivariate CI 
			// global all_unfiar "NationalScore income_lastmonth wempo_index hfc_near_dist stratum i.org_name_num i.respd_chid_num_grp i.mom_age_grp resp_hhhead i.resp_highedu i.hhhead_highedu"
			quietly svy: logit `var' $all_unfiar 
			
			predict `var'_p, pr
		
			quietly conindex `var', rank(`var'_p) svy wagstaff bounded limits(0 1)
			
			scalar N_multi	= r(N)
			scalar ci_multi = r(CI)
			scalar se_multi = r(CIse)
			scalar z_multi 	= ci_multi / se_multi
			* Replace with actual degrees of freedom (df = #PSUs - #strata)
			svydescribe
			return list

			scalar df_multi = (r(N_units) - r(N_strata))
			scalar p_t_multi = 2 * ttail(df_multi, abs(z_multi))
			
			* Achievement index - WB chapter 9 - formula 9.9  (mean * (1 - CI))
			global achi_index 	= ($percent_mean * (1 - ci_multi))
			replace achi_index 	= $achi_index in `i'
			
			* Z test: bivariate CI vs Multivariate CI 
			scalar diff = ci_biv - ci_multi
			scalar se_diff = sqrt(se_biv^2 + se_multi^2)
			scalar z = diff / se_diff
			
			scalar z_pval = 2 * normal(-abs(z))
			
			
			* Assigned values to export varaibles 
			replace biv_N 		= round(N_biv, 0.0001) in `i'
			replace biv_CI 		= round(ci_biv, 0.0001) in `i'
			replace biv_SE 		= round(se_biv, 0.0001) in `i'
			replace biv_pval 	= round(p_t_biv, 0.0001) in `i'
						
			replace mulv_N 		= round(N_multi, 0.0001) in `i'
			replace mulv_CI 	= round(ci_multi, 0.0001) in `i'
			replace mulv_SE 	= round(se_multi, 0.0001) in `i'
			replace mulv_pval 	= round(p_t_multi, 0.0001) in `i'
			
			
			 
			replace z_test 	= round(z, 0.0001) in `i'
			replace z_Pval 	= round(z_pval, 0.0001) in `i'
			

		}
		
		
		local i = `i' + 1
		di "`var' finished"
		
	}


	drop if biv_N == 0     // get rid of extra raws
	keep 	var_df var_name ///
			biv_N biv_CI biv_SE biv_pval ///
			mulv_N mulv_CI mulv_SE mulv_pval ///
			z_test z_Pval ///
			total_N percent_mean achi_index ///




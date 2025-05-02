	/*******************************************************************************

	Project Name		: 	Project Nourish
	Purpose				:	2nd round data collection: 
							Data analysis Mother Health Care: Test different calculation of CI approach
							Bivariate - wealth Vs. Multivariate 
	Author				:	Nicholus Tint Zaw
	Date				: 	03/01/2023
	Modified by			:


	*******************************************************************************/

	********************************************************************************
	** Directory Settings **
	********************************************************************************

	do "$do/00_dir_setting.do"

	****************************************************************************
	** Mom Health Services **
	****************************************************************************
	use "$dta/pnourish_mom_health_analysis_final.dta", clear    
	
	merge m:1 _parent_index using "$dta/pnourish_WOMEN_EMPOWER_final.dta", ///
							keepusing(*_d_z) assert(2 3) keep(matched) nogen 
							
							
	merge m:1 _parent_index using "$dta/pnourish_respondent_info_final.dta", ///
							keepusing(township_name geo_eho_vt_name geo_eho_vill_name geo_town geo_vt) assert( 2 3) keep(matched) nogen

	order township_name geo_eho_vt_name geo_eho_vill_name geo_town geo_vt, before(geo_vill)

	** Addressing missing issue **
	count if mi(hfc_near_dist)
	tab hfc_near_dist, m 
	
	replace hfc_near_dist = 1.5 if geo_eho_vt_name == "Kha Nein Hpaw" & stratum == 1 & mi(hfc_near_dist) // 11 obs
	replace hfc_near_dist = 1.1 if geo_eho_vt_name == "Ka Yit Kyauk Tan" & stratum == 1 & mi(hfc_near_dist) // 9 obs 
	replace hfc_near_dist = 4 if geo_eho_vt_name == "Bo Khar Lay Kho" & stratum == 2 & mi(hfc_near_dist) // 5 obs 
	replace hfc_near_dist = 4 if geo_eho_vt_name == "Sho Kho" & stratum == 2 & mi(hfc_near_dist)		 // 1 obs
	replace hfc_near_dist = 1 if geo_eho_vt_name == "Naung Pa Laing" & stratum == 1 & mi(hfc_near_dist)	 // 9 obs 
	
	tab hfc_near_dist, m 

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	
	****************************************************************************
	** Decomposition of the concentration index ** - Chapter 13	
	****************************************************************************
	* creating the dummy varaibles 
	foreach var of varlist 	stratum resp_highedu wealth_quintile_ns wempo_category ///
							income_quintile_cust hfc_distance{
						    
		tab `var', gen(`var'_)			
							
				}
			
	* to address the negative value of elasticity
	** reverse the sign (multiple by - 1)
	foreach var of varlist NationalScore wempo_index {
		
		local var_label : var label `var'
		
		gen `var'_rev = `var' * -1 
		lab var `var'_rev "`var_label': flipped"
		
	}
	
	** moving min to ZERO 
	foreach var of varlist NationalScore wempo_index {
		
		local var_label : var label `var'
		
		sum `var'
		gen `var'_m0 = `var' + abs(r(min))
		lab var `var'_m0 "`var_label': min ZERO"
		
	}
	
	sum NationalScore* wempo_index*
	
	local var_label : var label income_lastmonth
	gen logincome = ln(income_lastmonth)
	lab var logincome "ln(): `var_label'"
	
	global outcomes anc_yn anc_who_trained anc_visit_trained_4times ///
					insti_birth skilled_battend ///
					pnc_yn pnc_who_trained nbc_yn nbc_who_trained 
				
	* Original unfiar list 
	global X_raw		NationalScore logincome ///
						wempo_index ///
						hfc_near_dist ///
						stratum_1 ///
						resp_highedu_2 resp_highedu_3 resp_highedu_4
					
	foreach var of global outcomes {
		
		preserve 
		
			global outcome_var `var'
			
			gen weight_var = weight_final
			
			svy: logit $outcome_var $X_raw
			matrix b = e(b)
			local names : colfullnames e(b)
			
			di "`names'"

			local names	= subinstr("`names'", "_cons", "", 1)
			local names	= subinstr("`names'", "$outcome_var:", " ", .)
			di "`names'"
			
			* redefine the unfair var set without omitted var 
			global X "`names'"
	
			svy: logit $outcome_var $X
			predict rank, pr
		
			do "$hhfun/CI_decomposition.do"
				
			export excel 	using "$result/01_U2Mom_Health_Seeking_Multivar_CI_Decompose_diff_appraochs.xlsx", /// 
							sheet("D_`var'") firstrow(varlabels) keepcellfmt sheetreplace 	
		
		restore 
		
	}

	
	* moving min to ZERO 
	global X_raw		NationalScore_m0 logincome ///
						wempo_index_m0 ///
						hfc_near_dist ///
						stratum_1 ///
						resp_highedu_2 resp_highedu_3 resp_highedu_4
					
	foreach var of global outcomes {
		
		preserve 
		
			global outcome_var `var'
			
			gen weight_var = weight_final
			
			svy: logit $outcome_var $X_raw
			matrix b = e(b)
			local names : colfullnames e(b)
			
			di "`names'"

			local names	= subinstr("`names'", "_cons", "", 1)
			local names	= subinstr("`names'", "$outcome_var:", " ", .)
			di "`names'"
			
			* redefine the unfair var set without omitted var 
			global X "`names'"
	
			svy: logit $outcome_var $X
			predict rank, pr
		
			do "$hhfun/CI_decomposition.do"
				
			export excel 	using "$result/01_U2Mom_Health_Seeking_Multivar_CI_Decompose_diff_appraochs.xlsx", /// 
							sheet("D_`var'") firstrow(varlabels) cell(A12) keepcellfmt sheetmodify 	
		
		restore 
		
	}
	
	* positive/negative sign flipped	
	global X_raw		NationalScore_rev logincome ///
						wempo_index_rev ///
						hfc_near_dist ///
						stratum_1 ///
						resp_highedu_2 resp_highedu_3 resp_highedu_4
					
	foreach var of global outcomes {
		
		preserve 
		
			global outcome_var `var'
			
			gen weight_var = weight_final
			
			svy: logit $outcome_var $X_raw
			matrix b = e(b)
			local names : colfullnames e(b)
			
			di "`names'"

			local names	= subinstr("`names'", "_cons", "", 1)
			local names	= subinstr("`names'", "$outcome_var:", " ", .)
			di "`names'"
			
			* redefine the unfair var set without omitted var 
			global X "`names'"
	
			svy: logit $outcome_var $X
			predict rank, pr
		
			do "$hhfun/CI_decomposition.do"
				
			export excel 	using "$result/01_U2Mom_Health_Seeking_Multivar_CI_Decompose_diff_appraochs.xlsx", /// 
							sheet("D_`var'") firstrow(varlabels) cell(A23) keepcellfmt sheetmodify 	
		
		restore 
		
	}


	** All unfiar binary 
	global X_raw		wealth_quintile_ns_2 wealth_quintile_ns_3 wealth_quintile_ns_4 wealth_quintile_ns_5 ///
						income_quintile_cust_2 income_quintile_cust_3 income_quintile_cust_4 income_quintile_cust_5 ////
						wempo_category_2 wempo_category_3 ///
						hfc_distance_1 hfc_distance_2 hfc_distance_3 ///
						stratum_1 ///
						resp_highedu_2 resp_highedu_3 resp_highedu_4

					
	foreach var of global outcomes {
		
		preserve 
		
			global outcome_var `var'
			
			gen weight_var = weight_final
			
			svy: logit $outcome_var $X_raw
			matrix b = e(b)
			local names : colfullnames e(b)
			
			di "`names'"

			local names	= subinstr("`names'", "_cons", "", 1)
			local names	= subinstr("`names'", "$outcome_var:", " ", .)
			di "`names'"
			
			* redefine the unfair var set without omitted var 
			global X "`names'"
	
			svy: logit $outcome_var $X
			predict rank, pr
		
			do "$hhfun/CI_decomposition.do"
				
			export excel 	using "$result/01_U2Mom_Health_Seeking_Multivar_CI_Decompose_diff_appraochs.xlsx", /// 
							sheet("D_`var'") firstrow(varlabels) cell(A34) keepcellfmt sheetmodify 	
		
		restore 
		
	}

	
	
// END HERE 



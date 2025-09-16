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
	global outcomes anc_yn anc_who_trained anc_visit_trained_4times ///
					insti_birth skilled_battend ///
					pnc_yn pnc_who_trained nbc_yn nbc_who_trained 
					
	global all_unfiar "NationalScore income_lastmonth wempo_index hfc_near_dist stratum i.resp_highedu_ci"
	
	//global all_fiar "i.org_name_num i.respd_chid_num_grp i.mom_age_grp resp_hhhead"
	
	* creating the dummy varaibles 
	foreach var of varlist 	stratum resp_highedu wealth_quintile_ns wempo_category ///
							income_quintile_cust hfc_distance {
						    
		tab `var', gen(`var'_)			
							
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
	
	* Final set of unfiar var 
	* combination of moving min to ZERO (for z score type var) and 
	* binary dummy var for categegory var 
	
	global X_raw		NationalScore_m0 logincome ///
						wempo_index_m0 ///
						hfc_distance_1 hfc_distance_2 hfc_distance_3 ///
						stratum_1 ///
						resp_highedu_2 resp_highedu_3 resp_highedu_4
	

	gen weight_var = weight_final 
	
	foreach var of global outcomes {
				
			global outcome_var `var'
				
			* Estimate full model and detect omitted variables
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
			predict mvr_$outcome_var, pr
			
	}
	
	
	foreach var of varlist 	mvr_anc_yn mvr_anc_who_trained mvr_anc_visit_trained_4times ///
							mvr_insti_birth mvr_skilled_battend mvr_pnc_yn ///
							mvr_pnc_who_trained mvr_nbc_yn mvr_nbc_who_trained {
		
		xtile `var'_q = `var' [pweight = weight_final], nq(5)
	}
					
	svy: tab mvr_anc_yn_q anc_yn, row 
	svy: tab mvr_anc_who_trained_q anc_who_trained, row 

	svy: tab mvr_skilled_battend_q skilled_battend, row 
	svy: tab mvr_insti_birth_q insti_birth, row 
	
	svy: tab mvr_pnc_yn_q pnc_yn, row 
	svy: tab mvr_pnc_who_trained_q pnc_who_trained, row 
	
	svy: tab mvr_nbc_yn_q nbc_yn, row 
	svy: tab mvr_nbc_who_trained_q nbc_who_trained, row 

	* Adj CI - Multivariate index 
	conindex anc_yn, rank(mvr_anc_yn) svy wagstaff bounded limits(0 1)
	conindex2 anc_yn, 	rank(mvr_anc_yn) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)
						
	
	foreach var in $outcomes {
		
		di "`var'"
		
		conindex `var', rank(mvr_`var') svy wagstaff bounded limits(0 1)
		conindex2 `var', 	rank(mvr_`var') ///
							covars(	i.resp_highedu ///
									i.mom_age_grp ///
									i.respd_chid_num_grp ///
									hfc_vill_yes ///
									i.hfc_distance ///
									i.org_name_num ///
									stratum ///
									i.wempo_category) ///
							svy wagstaff bounded limits(0 1)	
		
	}
	
	** export decomposition tables ** 
	foreach var of global outcomes {
		
		preserve 
		
			global outcome_var `var'
				
			//gen weight_var = weight_final
			
			* Estimate full model and detect omitted variables
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
		
			do "$hhfun/CI_decomposition_simple_CI_formula.do"
				
			export excel 	using "$result/01_sumstat_formatted_U2Mom_Sample.xlsx", /// 
							sheet("FD_`var'") firstrow(varlabels) keepcellfmt sheetmodify 
							

		restore 
		
	}
	
	
// END HERE 



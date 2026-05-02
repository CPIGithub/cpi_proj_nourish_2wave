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
	// Directory 
	do "$do/00_dir_setting.do"
	
	// Function 
	do "$hhfun/ineqdecomp_unfair.do"

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
	
	// update hfc_distance 
	tab hfc_distance, m 
	
	replace hfc_distance = 0 if hfc_near_dist == 0
	replace hfc_distance = 1 if hfc_near_dist > 0 & hfc_near_dist <= 1.5
	replace hfc_distance = 2 if hfc_near_dist > 1.5 & hfc_near_dist <= 3
	replace hfc_distance = 3 if hfc_near_dist > 3 & !mi(hfc_near_dist)
	tab hfc_distance, mis


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
	
&
						
	
	foreach var of varlist $outcomes {

		// Relative 
		preserve 
		
			ineqdecomp_unfair , ///
				outcome(`var') ///
				unfair($X_raw) ///
				wvar(weight_final) ///
				citype(relative) ///
				rankmodel(logit) ///
				clear	
				
			export excel using "$result/01_sumstat_formatted_Maternal_Health_Service_U2Mom.xlsx", /// // 01_sumstat_formatted_U2Mom_Sample
								sheet("FD_`var'_r") firstrow(varlabels) keepcellfmt sheetmodify 
		
		restore 
		
		// Wagstaff
		preserve 
		
			ineqdecomp_unfair , ///
				outcome(`var') ///
				unfair($X_raw) ///
				wvar(weight_final) ///
				citype(wagstaff) ///
				rankmodel(logit) ///
				clear
				
			export excel using "$result/01_sumstat_formatted_Maternal_Health_Service_U2Mom.xlsx", /// // 01_sumstat_formatted_U2Mom_Sample
								sheet("FD_`var'_w") firstrow(varlabels) keepcellfmt sheetmodify 
		
		restore 
		
		// Erreygers
		preserve 

			ineqdecomp_unfair , ///
				outcome(`var') ///
				unfair($X_raw) ///
				wvar(weight_final) ///
				citype(erreygers) ///
				rankmodel(logit) ///
				clear	
				
			export excel using "$result/01_sumstat_formatted_Maternal_Health_Service_U2Mom.xlsx", /// // 01_sumstat_formatted_U2Mom_Sample
								sheet("FD_`var'_e") firstrow(varlabels) keepcellfmt sheetmodify 
		
		restore 
		
	}
	
	

	* CI multivar index ranking 
	********************************************************************************
	* Create conindex-style weighted fractional ranks for multiple outcomes
	* Permanent intermediate variables are created for checking/debugging.
	********************************************************************************
	gen weight_var = weight_final  
	rename anc_visit_trained_4times anc_visit_t4times 
	
	global outcomes anc_yn anc_who_trained anc_visit_t4times ///
					insti_birth skilled_battend ///
					pnc_yn pnc_who_trained nbc_yn nbc_who_trained 

	foreach y of global outcomes {

		preserve 
		
			di as text "--------------------------------------------------"
			di as text "Creating weighted fractional rank for outcome: `y'"
			di as text "--------------------------------------------------"

			* Clean old variables if re-running
			capture drop analytic_`y'
			capture drop obsid_`y'
			capture drop rankscore_`y'
			capture drop wtmp_`y'
			capture drop cumw_`y'
			capture drop rank_`y'
			capture drop rcenter_`y'
			capture drop wnorm_`y'

			* Common analytic sample
			gen byte analytic_`y' = !missing(`y', weight_var)

			foreach x of global X_raw {
				replace analytic_`y' = 0 if missing(`x')
			}

			keep if analytic_`y' == 1
			
			count if analytic_`y' == 1
			local N_analytic = r(N)

			if `N_analytic' == 0 {
				di as error "No analytic observations for `y'. Skipping."
				continue
			}

			* Preserve original order
			gen long obsid_`y' = _n

			* Estimate unfairness-score model
			quietly svy, subpop(analytic_`y'): logit `y' $X_raw

			* Predicted probability = unfairness score
			predict double rankscore_`y' if e(sample), pr

			* Total analytic sample weight
			quietly summarize weight_var if analytic_`y' == 1, meanonly
			scalar total_w_`y' = r(sum)

			if total_w_`y' <= 0 | missing(total_w_`y') {
				di as error "Total weight is zero/missing for `y'. Skipping."
				sort obsid_`y'
				continue
			}

			* Analytic weight
			gen double wtmp_`y' = cond(analytic_`y' == 1, weight_var, 0)

			* Sort by predicted probability to create weighted fractional rank
			sort rankscore_`y' obsid_`y'

			* Cumulative weight ordered by predicted risk
			gen double cumw_`y' = sum(wtmp_`y')

			* Final weighted fractional rank for conindex
			gen double rank_`y' = (cumw_`y' - 0.5 * weight_var) / total_w_`y' ///
				if analytic_`y' == 1

			* Optional supporting variables
			gen double rcenter_`y' = rank_`y' - 0.5 if analytic_`y' == 1
			gen double wnorm_`y' = weight_var / total_w_`y' if analytic_`y' == 1

			* Return to original order
			sort obsid_`y'

			* Quick check
			summarize rankscore_`y' rank_`y' rcenter_`y' if analytic_`y' == 1

			di as result "Created final conindex rank: rank_`y'"
			di as result "Analytic N for `y' = `N_analytic'"
			
			********************************************************************************
			* Optional: drop intermediate variables after checking
			* Keep only final rank_* variables if desired.
			********************************************************************************

			drop analytic_* obsid_* rankscore_* wtmp_* cumw_* rcenter_* wnorm_*
		
			di as text "--------------------------------------------------"
			di as text "CI for outcome: `y'"
			di as text "--------------------------------------------------"
			
			conindex `y', rank(rank_`y') svy truezero
			
			conindexadj `y', 	rank(rank_`y') ///
								covars(	/*i.resp_highedu*/ ///
										/*i.mom_age_grp*/ ///
										/*i.respd_chid_num_grp*/ ///
										/*hfc_vill_yes*/ ///
										/*i.hfc_distance*/ ///
										i.org_name_num ///
										/*stratum*/) ///
								svy truezero	
							
			xtile `y'_mvq = rank_`y' [pweight = weight_final], nq(5)
			svy: tab `y'_mvq `y', row

			//conindex `y', rank(rank_`y') svy bounded limits(0 1) wagstaff
	
		restore 
	}





// END HERE 

	/*
	return list
	di "`r(unfair_kept)'"
	di "`r(unfair_dropped)'"
	*/

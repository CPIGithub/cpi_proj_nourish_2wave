/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	Midtern vs Endline - Child level - IYCF		
Author				:	Nicholus Tint Zaw
Date				: 	05/31/2024
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"
	
	****************************************************************************
	* Child IYCF Data *
	****************************************************************************
		
	** Midterm vs endline 

	* endline 
	use "$dta/endline/pnourish_child_iycf_final.dta", clear  
		
	merge m:1 _parent_index using 	"$dta/endline/pnourish_WOMEN_EMPOWER_final.dta", ///
									assert(2 3) keep(matched) nogen ///
									keepusing(wempo_index wempo_category progressivenss)

	* Add Village Survey Info 
	global villinfo 	hfc_near_dist_dry hfc_near_dist_rain ///
						mkt_near_dist_dry mkt_near_dist_rain ///
						hfc_vill1 hfc_vill2 hfc_vill3 hfc_vill4 hfc_vill5 hfc_vill6 hfc_vill888 hfc_vill0 

	merge m:1 geo_vill using 	"$dta/endline/PN_Village_Survey_Endline_FINAL_Constructed.dta", /// 
								keepusing($villinfo) 						
	
	drop if _merge == 2
	drop _merge 
	
	gen midterm_endline = 1 
	
	* midterm 
	preserve 
	
		use "$dta/pnourish_child_iycf_final.dta", clear 
		
		merge m:1 _parent_index using	"$dta/pnourish_WOMEN_EMPOWER_final.dta", ///
										assert(2 3) keep(matched) nogen ///
										keepusing(wempo_index wempo_category progressivenss)

	
		merge m:1 geo_vill using 	"$dta/PN_Village_Survey_FINAL_Constructed.dta", /// 
									keepusing($villinfo) 
				
		drop if _merge == 2
		drop _merge 
	
		tempfile midterm 
		save `midterm', replace 
	
	restore 
	
	append using `midterm'
	
	replace midterm_endline = 0 if mi(midterm_endline)
	lab def midterm_endline 0"Midterm" 1"Endline"
	lab val midterm_endline midterm_endline
	tab midterm_endline, m 
	
	decode midterm_endline, gen(midterm_endline_str)
	tab midterm_endline_str, m 
	
	* update weight variable 
	* and drop the village and obs which not matched midterm vs endline 
	drop weight_final
		
	merge m:1 midterm_endline geo_vill using "$dta/endline/pnourish_midterm_vs_endline_hh_comparision_weight_final.dta", keepusing(weight_final)   

	tab midterm_endline _merge // un-matched come from the inaccessible village at endline (from midterm sample)
	keep if _merge == 3
	drop _merge 
	
	* prepare covariate 
	* geo and stratum 
	tab1 stratum_num org_name_num
	
	* respondent info 
	tab respd_sex, 
	sum respd_age 
	
	rename respd_age caregiver_age
	
	gen caregiver_age_grp = (caregiver_age < 25)
	replace caregiver_age_grp = 2 if caregiver_age >= 25 & caregiver_age < 35 
	replace caregiver_age_grp = 3 if caregiver_age >= 35  
	replace caregiver_age_grp = .m if mi(caregiver_age)
	lab def caregiver_age_grp 1"< 25 years old" 2"25 - 34 years old" 3"35+ years old"
	lab val caregiver_age_grp caregiver_age_grp
	tab caregiver_age_grp, m 
	
	tab resp_hhhead 
	
	// resp_highedu
	* treated other and monestic education as missing
	foreach var of varlist resp_highedu hhhead_highedu {
		
		replace `var' = .m if `var' > 7 
		replace `var' = 4 if `var' > 4 & !mi(`var')
		tab `var', m 
	
	}
	
	// respd_chid_num
	tab respd_child midterm_endline, m 
	tab respd_chid_num  
	replace respd_chid_num = 0 if respd_child == 0 
	sum respd_chid_num
	
	recode respd_chid_num (1 = 1) (2 = 2) (3/15 = 3), gen(caregiver_chidnum_grp)
	replace caregiver_chidnum_grp = .m if mi(respd_chid_num)
	lab def caregiver_chidnum_grp 0"No children" 1"Has only one child" 2"Has two children" 3"Has three children & more" 
	lab val caregiver_chidnum_grp caregiver_chidnum_grp 
	lab var caregiver_chidnum_grp "Caregiver Number of Children"
	tab caregiver_chidnum_grp, m 
	
	* Village level info
	* proximity to health facility 
	egen hfc_near_dist = rowmean(hfc_near_dist_dry hfc_near_dist_rain)
	replace hfc_near_dist = .m if mi(hfc_near_dist_dry) & mi(hfc_near_dist_rain)
	lab var hfc_near_dist "Nearest Health Facility - hours for round trip"
	tab hfc_near_dist, m 
	
	tab hfc_vill0, m 
	gen hfc_vill_yes = (hfc_vill0 == 0)
	replace hfc_vill_yes = .m if mi(hfc_vill0)
	lab val hfc_vill_yes yesno 
	tab hfc_vill_yes, m 
	
	* distance HFC category 
	gen hfc_distance = .m 
	replace hfc_distance = 0 if hfc_near_dist_rain == 0
	replace hfc_distance = 1 if hfc_near_dist_rain > 0 & hfc_near_dist_rain <= 1.5
	replace hfc_distance = 2 if hfc_near_dist_rain > 1.5 & hfc_near_dist_rain <= 3
	replace hfc_distance = 3 if hfc_near_dist_rain > 3 & !mi(hfc_near_dist_rain)
	lab def hfc_distance 0"Health Facility present at village" 1"<= 1.5 hours" 2"1.6 to 3 hours" 3">3 hours"
	lab val hfc_distance hfc_distance
	lab var hfc_distance "Nearest Health Facility - hours for round trip"
	tab hfc_distance, mis
	
	local var_label : var label income_lastmonth
	gen logincome = ln(income_lastmonth)
	lab var logincome "ln(): `var_label'"
	
	* HH info 
	sum NationalScore
	
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	****************************************************************************
	** Decomposition of the concentration index ** - Chapter 13	
	****************************************************************************
					
	global all_unfiar "NationalScore income_lastmonth wempo_index hfc_near_dist stratum i.resp_highedu_ci"
	
	//global all_fiar "i.org_name_num i.respd_chid_num_grp i.mom_age_grp resp_hhhead"
	
	* creating the dummy varaibles 
	foreach var of varlist 	stratum resp_highedu wealth_quintile_ns wempo_category ///
							hfc_distance {
						    
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
	
	* Final set of unfiar var 
	* combination of moving min to ZERO (for z score type var) and 
	* binary dummy var for categegory var 
	
	global outcomes	eibf ebf pre_bf ///
					mixmf bof cbf isssf ///
					mdd mmf mad 


					
	global X_raw		NationalScore_m0 logincome ///
						wempo_index_m0 ///
						hfc_distance_1 hfc_distance_2 hfc_distance_3 ///
						stratum_1 ///
						resp_highedu_2 resp_highedu_3 resp_highedu_4
	
	
	** (1): All Combined Midterm + Endline 
	foreach var of global outcomes {
		
		preserve 
		
			global outcome_var `var'
				
			gen weight_var = weight_final
			
			* Estimate full model and detect omitted variables
			svy: logit $outcome_var $X_raw
			matrix b = e(b)
			local names : colfullnames e(b)
			
			di "`names'"

			* Initialize clean list
			local clean_names

			* Loop through all names
			foreach v of local names {
				
				* Remove outcome prefix
				local stripped = subinstr("`v'", "$outcome_var:", "", .)
				
				* Skip _cons and omitted regressors (with "o.")
				if strpos("`stripped'", "_cons") == 0 & strpos("`stripped'", "o.") == 0 {
					local clean_names `clean_names' `stripped'
				}
			}

			* Display cleaned variable list
			di "`clean_names'"

			//local names	= subinstr("`names'", "_cons", "", 1)
			//local names	= subinstr("`names'", "$outcome_var:", " ", .)
			//di "`names'"
			
			* redefine the unfair var set without omitted var 
			global X "`clean_names'"
	
			svy: logit $outcome_var $X
			predict rank, pr
		
			do "$hhfun/CI_decomposition_simple_CI_formula.do"
				
			export excel 	using "$result/IYCF_Multivar_CI/01_Multivar_CI_combined_midline_and_endline.xlsx", /// 
							sheet("FD_`var'") firstrow(varlabels) keepcellfmt sheetmodify 
							

		restore 
		
	}
	
	/*
	error - svy: logit ebf $X if midterm_endline == 1
	error - svy: logit mixmf $X if midterm_endline == 1 / 0 in both case 
	
	**(2): Midterm + Endline Seperately
	
	tab midterm_endline_str, m 
	
	levelsof midterm_endline_str, local(points)
	
	foreach var of global outcomes {
		
		
		foreach p in `points' {
		    
			preserve 
			
				keep if midterm_endline_str == "`p'"
				
				global outcome_var `var'
					
				gen weight_var = weight_final
				
				* Estimate full model and detect omitted variables
				svy: logit $outcome_var $X_raw
				matrix b = e(b)
				local names : colfullnames e(b)
				
				di "`names'"

				* Initialize clean list
				local clean_names

				* Loop through all names
				foreach v of local names {
					
					* Remove outcome prefix
					local stripped = subinstr("`v'", "$outcome_var:", "", .)
					
					* Skip _cons and omitted regressors (with "o.")
					if strpos("`stripped'", "_cons") == 0 & strpos("`stripped'", "o.") == 0 {
						local clean_names `clean_names' `stripped'
					}
				}

				* Display cleaned variable list
				di "`clean_names'"

				//local names	= subinstr("`names'", "_cons", "", 1)
				//local names	= subinstr("`names'", "$outcome_var:", " ", .)
				//di "`names'"
				
				* redefine the unfair var set without omitted var 
				global X "`clean_names'"
		
				svy: logit $outcome_var $X
				predict rank, pr
			
				do "$hhfun/CI_decomposition_simple_CI_formula.do"
					
				export excel 	using "$result/IYCF_Multivar_CI/01_Multivar_CI_`p'.xlsx", /// 
								sheet("FD_`var'") firstrow(varlabels) keepcellfmt sheetmodify 
								

			restore 

		
		}
		
	}
	
	*/
	
	&&&&&&&

	global outcomes	eibf ebf pre_bf cbf ///
					isssf ///
					mdd mad  // dietary_tot
					 
					
	foreach var in $outcomes {
	    
		di "`var'"
		conindex `var' , rank(wealth_quintile_ns) svy wagstaff bounded limits(0 1) compare(midterm_endline)
		
	}				
	
	
	conindex dietary_tot, rank(wealth_quintile_ns) svy wagstaff bounded limits(0 8) compare(midterm_endline)
	
	
// END HERE 



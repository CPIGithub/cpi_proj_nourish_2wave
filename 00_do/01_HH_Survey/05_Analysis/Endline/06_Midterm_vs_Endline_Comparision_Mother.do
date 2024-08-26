/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	Endline: Data analysis - Mother level and Related Modules			
Author				:	Nicholus Tint Zaw
Date				: 	08/06/2024
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

	   
	****************************************************************************
	** Mom Dietary Diversity **
	****************************************************************************
	
	** Midterm vs endline 

	* endline 
	use "$dta/endline/pnourish_mom_diet_final.dta", clear  
			
	gen midterm_endline = 1 
	
	append using "$dta/pnourish_mom_diet_final.dta"
	
	replace midterm_endline = 0 if mi(midterm_endline)
	tab midterm_endline, m 
	
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
	
	
	* HH info 
	sum NationalScore
	
	global covariates "stratum i.org_name_num respd_sex i.caregiver_chidnum_grp i.caregiver_age_grp resp_hhhead i.resp_highedu i.hhhead_highedu  wealth_quintile_ns"
	
	
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)
	
	global outcomes	mddw_grain mddw_pulses mddw_nut mddw_milk mddw_meat ///
					mddw_moom_egg mddw_green_veg mddw_vit_vegfruit ///
					mddw_oth_veg mddw_oth_fruit ///
					/*mddw_score*/ mddw_yes mom_meal_freq
					
	foreach v in $outcomes {

		count if `v' == 1

			if `r(N)' > 0 {

			count if `v' == 0

				if `r(N)' != 0 {

					* Survey Distribution Quintile
					di "`v'"
					
					svy: glm `v' 	midterm_endline ///
									stratum,  ///
									family(binomial) link(log) nolog eform 

					eststo `v'

					local outcomes_in_analysis_`g' "`outcomes_in_analysis_`g'' `v'"

					}

				}

	}

	esttab `outcomes_in_analysis_`g'' ///
			using "$out/endline/comparision_model/Mother_DDS_Midterm_vs_Endline.csv", ///
			eform ///
			cells(b(star fmt(3)) se(par fmt(2)))  ///
			legend label varlabels(_cons constant) ///
			stats(r2 df_r bic) replace			
	
	
	****************************************************************************
	* Mom Health Module *
	****************************************************************************

	** Midterm vs endline 

	* endline 
	use "$dta/endline/pnourish_mom_health_final.dta", clear  
			
	drop 	anc_where anc_home_who_oth anc_ehoc_who_oth anc_ehom_who anc_vill_who ///
			anc_othp_who_oth pnc_home_oth pnc_pc_oth pnc_rhc_who pnc_othp_who_oth ///
			nbc_home_oth nbc_pc_oth nbc_ehoc_who nbc_ehom_who nbc_othp_who ///
			nbc_othp_who_oth
	
	gen midterm_endline = 1 
	
	append using "$dta/pnourish_mom_health_final.dta"
	
	replace midterm_endline = 0 if mi(midterm_endline)
	tab midterm_endline, m 
	
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
	
	
	* HH info 
	sum NationalScore
	
	global covariates "stratum i.org_name_num respd_sex i.caregiver_chidnum_grp i.caregiver_age_grp resp_hhhead i.resp_highedu i.hhhead_highedu  wealth_quintile_ns"
	
	
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)
	
	
	global outcomes	anc_yn anc_who_trained anc_visit_trained_4times ///
					insti_birth skilled_battend ///
					pnc_yn pnc_who_trained ///
					nbc_yn nbc_2days_yn nbc_who_trained
	
	foreach v in $outcomes {

		count if `v' == 1

			if `r(N)' > 0 {

			count if `v' == 0

				if `r(N)' != 0 {

					* Survey Distribution Quintile
					di "`v'"
					
					svy: glm `v' 	midterm_endline ///
									stratum,  ///
									family(binomial) link(log) nolog eform 

					eststo `v'

					local outcomes_in_analysis_`g' "`outcomes_in_analysis_`g'' `v'"

					}

				}

	}

	esttab `outcomes_in_analysis_`g'' ///
			using "$out/endline/comparision_model/Mother_Health_Midterm_vs_Endline.csv", ///
			eform ///
			cells(b(star fmt(3)) se(par fmt(2)))  ///
			legend label varlabels(_cons constant) ///
			stats(r2 df_r bic) replace		
	
	
	****************************************************************************
	** PHQ9 **
	****************************************************************************
	
	** Midterm vs endline 

	* endline 
	use "$dta/endline/pnourish_PHQ9_final.dta", clear  
			
	gen midterm_endline = 1 
	
	append using "$dta/pnourish_PHQ9_final.dta"
	
	replace midterm_endline = 0 if mi(midterm_endline)
	tab midterm_endline, m 
	
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
	
	
	* HH info 
	sum NationalScore
	
	global covariates "stratum i.org_name_num respd_sex i.caregiver_chidnum_grp i.caregiver_age_grp resp_hhhead i.resp_highedu i.hhhead_highedu  wealth_quintile_ns"
	
	
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)
	
	tab phq9_cat, gen(phq9_cat_)
	
	* Loop through the generated variables and update their labels
	foreach var of varlist phq9_cat_* {
		
		* Get the current label
		local current_label : variable label `var'
		
		* Extract the part after "=="
		local new_label = substr("`current_label'", strpos("`current_label'", "==") + 2, .)
		
		* Trim any leading or trailing spaces
		local new_label = trim("`new_label'")
		
		* Update the variable label
		label variable `var' "`new_label'"
	}

	global outcomes phq9_cat_1 phq9_cat_2 phq9_cat_3 phq9_cat_4 phq9_cat_5
	
	
	foreach v in $outcomes {

		count if `v' == 1

			if `r(N)' > 0 {

			count if `v' == 0

				if `r(N)' != 0 {

					* Survey Distribution Quintile
					di "`v'"
					
					svy: glm `v' 	midterm_endline ///
									stratum,  ///
									family(binomial) link(log) nolog eform 

					eststo `v'

					local outcomes_in_analysis "`outcomes_in_analysis' `v'"

					}

				}

	}

	esttab `outcomes_in_analysis' ///
			using "$out/endline/comparision_model/Mother_PHQ9_Midterm_vs_Endline.csv", ///
			eform ///
			cells(b(star fmt(3)) se(par fmt(2)))  ///
			legend label varlabels(_cons constant) ///
			stats(r2 df_r bic) replace		
	
	****************************************************************************
	** Women Empowerment [endline] **
	****************************************************************************
	
	** Midterm vs endline 

	* endline 
	use "$dta/endline/pnourish_WOMEN_EMPOWER_final.dta", clear  
			
	gen midterm_endline = 1 
	
	append using "$dta/pnourish_WOMEN_EMPOWER_final.dta"
	
	replace midterm_endline = 0 if mi(midterm_endline)
	tab midterm_endline, m 
	
	drop weight_final 
	
	drop _merge 
		
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
	
	
	* HH info 
	sum NationalScore
	
	global covariates "stratum i.org_name_num respd_sex i.caregiver_chidnum_grp i.caregiver_age_grp resp_hhhead i.resp_highedu i.hhhead_highedu  wealth_quintile_ns"
	
	
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)


	tab wempo_category, gen(wempo_category_)
	
	* Loop through the generated variables and update their labels
	foreach var of varlist wempo_category_* {
		
		* Get the current label
		local current_label : variable label `var'
		
		* Extract the part after "=="
		local new_label = substr("`current_label'", strpos("`current_label'", "==") + 2, .)
		
		* Trim any leading or trailing spaces
		local new_label = trim("`new_label'")
		
		* Update the variable label
		label variable `var' "`new_label'"
	}
	
	
	global outcomes wempo_familyfood_yes wempo_childcare_yes wempo_mom_health_yes ///
					wempo_child_health_yes wempo_women_wages_yes wempo_major_purchase_yes ///
					wempo_visiting_yes wempo_women_health_yes wempo_child_wellbeing_yes ///
					/*wempo_grp_tot*/ ///
					wempo_index progressivenss wempo_category_1 wempo_category_2 wempo_category_3 ///
					wempo_hnut_act_ja
	
	
	foreach v in $outcomes {

		count if `v' == 1

			if `r(N)' > 0 {

			count if `v' == 0

				if `r(N)' != 0 {

					* Survey Distribution Quintile
					di "`v'"
					
					svy: glm `v' 	midterm_endline ///
									stratum,  ///
									family(binomial) link(log) nolog eform 

					eststo `v'

					local outcomes_in_analysis_`g' "`outcomes_in_analysis_`g'' `v'"

					}

				}

	}

	esttab `outcomes_in_analysis_`g'' ///
			using "$out/endline/comparision_model/Mother_WomenEmpowerment_Midterm_vs_Endline.csv", ///
			eform ///
			cells(b(star fmt(3)) se(par fmt(2)))  ///
			legend label varlabels(_cons constant) ///
			stats(r2 df_r bic) replace	
		

// END HERE 



/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	Endline: Data analysis - Child level			
Author				:	Nicholus Tint Zaw
Date				: 	08/06/2024
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

	****************************************************************************
	* Child MUAC *
	****************************************************************************
		
	** Midterm vs endline 

	* endline 
	use "$dta/endline/pnourish_child_muac_final.dta", clear  
		
	gen midterm_endline = 1 
	
	append using "$dta/pnourish_child_muac_final.dta"
	
	replace midterm_endline = 0 if mi(midterm_endline)
	tab midterm_endline, m 
	
	drop weight_final
		
	merge m:1 midterm_endline geo_vill using "$dta/endline/pnourish_midterm_vs_endline_hh_comparision_weight_final.dta", keepusing(weight_final)   

	tab midterm_endline _merge // un-matched come from the inaccessible village at endline (from midterm sample)
	keep if _merge == 3
	drop _merge 

	
	global outcomes	child_gam child_mam child_sam
					 
					
	foreach var in $outcomes {
	    
		di "`var'"
		conindex `var' , rank(wealth_quintile_ns) svy wagstaff bounded limits(0 1) compare(midterm_endline)
		
	}	
	
	
	
	****************************************************************************
	* Child IYCF Data *
	****************************************************************************
		
	** Midterm vs endline 

	* endline 
	use "$dta/endline/pnourish_child_iycf_final.dta", clear  
		
	gen midterm_endline = 1 
	
	append using "$dta/pnourish_child_iycf_final.dta"
	
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

	global outcomes	eibf ebf2d ebf pre_bf mixmf bof cbf ///
					isssf /*food_g1 food_g2 food_g3 food_g4 food_g5 food_g6 food_g7 food_g8*/ ///
					mdd /*dietary_tot*/ ///
					mmf_bf_6to8 mmf_bf_9to23 mmf_bf mmf_nonbf mmf mmff mad mad_bf mad_nobf

	
	
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
			using "$out/endline/comparision_model/Child_IYCF_Midterm_vs_Endline.csv", ///
			eform ///
			cells(b(star fmt(3)) se(par fmt(2)))  ///
			legend label varlabels(_cons constant) ///
			stats(r2 df_r bic) replace					
	

	global outcomes	eibf ebf pre_bf cbf ///
					isssf ///
					mdd mad  // dietary_tot
					 
					
	foreach var in $outcomes {
	    
		di "`var'"
		conindex `var' , rank(wealth_quintile_ns) svy wagstaff bounded limits(0 1) compare(midterm_endline)
		
	}				
	
	
	conindex dietary_tot, rank(wealth_quintile_ns) svy wagstaff bounded limits(0 8) compare(midterm_endline)
	
	
	
	****************************************************************************
	* Child Health Data *
	****************************************************************************
	
	** Midterm vs endline 

	* endline 
	use "$dta/endline/pnourish_child_health_final.dta", clear  
		
	drop child_diarrh_cope child_diarrh_cope_oth  
	
	gen midterm_endline = 1 
	
	append using "$dta/pnourish_child_health_final.dta"
	
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
	
	
	global outcomes	child_vita child_deworm child_vaccin child_vaccin_card child_low_bwt ///
					child_ill0 child_ill1 child_ill2 child_ill3 child_ill888 ///
					child_diarrh_treat child_diarrh_trained child_diarrh_pay ///
					child_cough_treat child_cough_trained child_cough_pay ///
					child_fever_treat child_fever_trained child_fever_pay
	
	
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
			using "$out/endline/comparision_model/Child_Health_Midterm_vs_Endline.csv", ///
			eform ///
			cells(b(star fmt(3)) se(par fmt(2)))  ///
			legend label varlabels(_cons constant) ///
			stats(r2 df_r bic) replace				


	
// END HERE 



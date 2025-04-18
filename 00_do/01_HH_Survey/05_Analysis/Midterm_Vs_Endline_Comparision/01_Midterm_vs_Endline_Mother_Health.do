/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	Prepare dataset for Midterm vs Endline Comparision: 
						Mother Health 			
Author				:	Nicholus Tint Zaw
Date				: 	03/12/2025
Modified by			:


*******************************************************************************/

	********************************************************************************
	** Directory Settings **
	********************************************************************************

	do "$do/00_dir_setting.do"
	  
	****************************************************************************
	** Midterm vs endline **
	****************************************************************************

	****************************************************************************
	* Get Endline Data *
	****************************************************************************
	use "$dta/endline/pnourish_mom_health_final.dta", clear  
	
	drop 	anc_where anc_home_who_oth anc_ehoc_who_oth anc_ehom_who anc_vill_who ///
			anc_othp_who_oth pnc_home_oth pnc_pc_oth pnc_rhc_who pnc_othp_who_oth ///
			nbc_home_oth nbc_pc_oth nbc_ehoc_who nbc_ehom_who nbc_othp_who ///
			nbc_othp_who_oth
			
	* Merge women empowerment data
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
	
	****************************************************************************
	* Get Midterm data *
	****************************************************************************
	preserve 
	
		use "$dta/pnourish_mom_health_final.dta", clear 
		
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
	
	****************************************************************************
	* Append Midterm + Endlien * 
	****************************************************************************
	
	append using `midterm'
	
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
	
	* Village level info
	* HFC present at village
	tab hfc_vill0, m 
	gen hfc_vill_yes = (hfc_vill0 == 0)
	replace hfc_vill_yes = .m if mi(hfc_vill0)
	lab var hfc_vill_yes "Health Facility present at village"
	lab val hfc_vill_yes yesno 
	tab hfc_vill_yes, m 
	
	* Average proximity to health facility 
	egen hfc_near_dist = rowmean(hfc_near_dist_dry hfc_near_dist_rain)
	replace hfc_near_dist = .m if mi(hfc_near_dist_dry) & mi(hfc_near_dist_rain)
	replace hfc_near_dist = .n if !mi(hfc_vill0) & mi(hfc_near_dist_dry) & mi(hfc_near_dist_rain)
	lab var hfc_near_dist "Nearest Health Facility - hours for round trip"
	tab hfc_near_dist, m 
	
	* distance HFC category 
	gen hfc_distance = .m 
	replace hfc_distance = 1 if hfc_near_dist >= 0 & hfc_near_dist <= 1.5
	replace hfc_distance = 2 if hfc_near_dist > 1.5 & hfc_near_dist <= 3
	replace hfc_distance = 3 if hfc_near_dist > 3 & !mi(hfc_near_dist)
	replace hfc_distance = 0 if hfc_vill_yes == 1
	lab def hfc_distance 0"Health Facility present at village" 1"<= 1.5 hours" 2"1.6 to 3 hours" 3">3 hours"
	lab val hfc_distance hfc_distance
	lab var hfc_distance "Nearest Health Facility - hours for round trip"
	tab hfc_distance, mis
	
	* HH info 
	sum NationalScore
	tab wealth_quintile_ns, m 
	
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)
	
	
	global outcomes	anc_yn anc_who_trained anc_visit_trained_4times ///
					insti_birth skilled_battend ///
					pnc_yn pnc_who_trained ///
					nbc_yn nbc_2days_yn nbc_who_trained
					
		
	****************************************************************************
	** Multivariate CI Ranking variable development **
	****************************************************************************
		
	global fix_unfiar "NationalScore income_lastmonth wempo_index hfc_near_dist"

	global all_unfiar "NationalScore income_lastmonth wempo_index hfc_near_dist stratum i.org_name_num i.caregiver_chidnum_grp i.caregiver_age_grp resp_hhhead i.resp_highedu i.hhhead_highedu"
	global possible_unfiar NationalScore income_lastmonth wempo_index hfc_near_dist stratum org_name_num caregiver_chidnum_grp caregiver_age_grp resp_hhhead resp_highedu hhhead_highedu

	
	
	* FIX UNFAIR 
	svy: logit anc_yn $fix_unfiar if midterm_endline == 0 

	predict p_anc_yn_midterm if midterm_endline == 0, pr

	svy: logit anc_yn $fix_unfiar if midterm_endline == 1

	predict p_anc_yn_endline if midterm_endline == 1, pr
	
	gen p_anc_yn = p_anc_yn_midterm
	replace p_anc_yn = p_anc_yn_endline if !mi(p_anc_yn_endline) & mi(p_anc_yn_midterm)
	tab p_anc_yn, m 
	

	* ALL UNFAIR 
	svy: logit anc_yn $all_unfiar if midterm_endline == 0 

	predict p_anc_yn_m_all if midterm_endline == 0, pr

	svy: logit anc_yn $all_unfiar if midterm_endline == 1

	predict p_anc_yn_e_all if midterm_endline == 1, pr
	
	gen p_anc_yn_all = p_anc_yn_m_all
	replace p_anc_yn_all = p_anc_yn_e_all if !mi(p_anc_yn_e_all) & mi(p_anc_yn_m_all)
	tab p_anc_yn_all, m 
	
	conindex anc_yn, rank(NationalScore) svy wagstaff bounded limits(0 1)
	
	
	conindex anc_yn , rank(NationalScore) svy wagstaff bounded limits(0 1) compare(midterm_endline)
	conindex anc_yn , rank(p_anc_yn) svy wagstaff bounded limits(0 1) compare(midterm_endline)
	conindex anc_yn , rank(p_anc_yn_all) svy wagstaff bounded limits(0 1) compare(midterm_endline)


	
	&&
	
	
	foreach var in $outcomes {
	    
		di "`var'"
		conindex `var' , rank(NationalScore) svy wagstaff bounded limits(0 1) compare(midterm_endline)
		
	}				
	
	
	conindex wempo_index, rank(wealth_quintile_ns) svy wagstaff bounded limits(-3 1.11) compare(midterm_endline)
	

	
	
	
	&&&
	NationalScore

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

	
	
	global outcomes /*wempo_familyfood_yes*/ wempo_childcare_yes wempo_child_health_yes wempo_child_wellbeing_yes ///
					wempo_mom_health_yes wempo_women_health_yes ///
					 wempo_women_wages_yes wempo_major_purchase_yes ///
					wempo_visiting_yes wempo_hnut_act_ja 
					
						
	foreach var in $outcomes {
	    
		di "`var'"
		conindex `var' , rank(wealth_quintile_ns) svy wagstaff bounded limits(0 1) compare(midterm_endline)
		
	}				
	
	
	conindex wempo_index, rank(wealth_quintile_ns) svy wagstaff bounded limits(-3 1.11) compare(midterm_endline)
	

	
	

// END HERE 



/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	Endline: Data analysis - HH Level			
Author				:	Nicholus Tint Zaw
Date				: 	08/06/2024
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"


	****************************************************************************
	** WASH **
	****************************************************************************
	
	** Midterm vs endline 

	* endline 
	use "$dta/endline/pnourish_WASH_final.dta", clear  
	
	gen midterm_endline = 1 
	
	append using "$dta/pnourish_WASH_final.dta"
	
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

	* create a dummy var 
	local invars  waterpot_capacity water_sum_ladder water_rain_ladder water_winter_ladder ///
					sanitation_ladder hw_ladder
	
	foreach var in `invars' {
	    
		tab `var', gen(`var'_)
		
		* Loop through the generated variables and update their labels
		foreach var of varlist `var'_* {
			
			* Get the current label
			local current_label : variable label `var'
			
			* Extract the part after "=="
			local new_label = substr("`current_label'", strpos("`current_label'", "==") + 2, .)
			
			* Trim any leading or trailing spaces
			local new_label = trim("`new_label'")
			
			* Update the variable label
			label variable `var' "`new_label'"
		}
	}
	
	
	
	global outcomes water_sum_ladder_1 water_sum_ladder_2 water_sum_ladder_3 water_sum_ladder_4 ///
					water_rain_ladder_1 water_rain_ladder_2 water_rain_ladder_3 water_rain_ladder_4 ///
					water_winter_ladder_1 water_winter_ladder_2 water_winter_ladder_3 water_winter_ladder_4 ///
					sanitation_ladder_1 sanitation_ladder_2 sanitation_ladder_3 sanitation_ladder_4 ///
					hw_ladder_1 hw_ladder_2 hw_ladder_3 ///
					soap_yn hw_critical_soap ///
					water_sum_treat water_rain_treat water_winter_treat ///
					watertx_sum_good watertx_rain_good watertx_winter_good ///
					waterpot_yn waterpot_capacity_1 waterpot_capacity_2 waterpot_capacity_3 ///
					waterpot_condition1 waterpot_condition2 waterpot_condition3 waterpot_condition4 waterpot_condition0 


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
			using "$out/endline/comparision_model/HH_WASH_Midterm_vs_Endline.csv", ///
			eform ///
			cells(b(star fmt(3)) se(par fmt(2)))  ///
			legend label varlabels(_cons constant) ///
			stats(r2 df_r bic) replace


	svy: glm midterm_endline NationalScore ///
					stratum,  ///
					family(binomial) link(log) nolog eform 
	
	****************************************************************************
	** FIES **
	****************************************************************************

	** Midterm vs endline 
	* Midterm 
	use "$dta/pnourish_FIES_final.dta", clear   

	merge m:1 _parent_index using "$dta/pnourish_WOMEN_EMPOWER_final.dta", keepusing(wempo_index wempo_category progressivenss)
	
	drop if _merge == 2 
	drop _merge 
	
	
	* Add Village Survey Info 
	global villinfo 	hfc_near_dist_dry hfc_near_dist_rain ///
						mkt_near_dist_dry mkt_near_dist_rain ///
						hfc_vill1 hfc_vill2 hfc_vill3 hfc_vill4 hfc_vill5 hfc_vill6 hfc_vill888 hfc_vill0 
	
	merge m:1 geo_vill using 	"$dta/PN_Village_Survey_FINAL_Constructed.dta", /// 
								keepusing($villinfo) 
	
	drop if _merge == 2
	drop _merge 

	gen midterm_endline = 0 
	
	tempfile midterm 
	save `midterm', replace 
	
	
	* endline	
	use "$dta/endline/pnourish_FIES_final.dta", clear   

	merge m:1 _parent_index using "$dta/endline/pnourish_WOMEN_EMPOWER_final.dta", keepusing(wempo_index wempo_category progressivenss)
	
	drop if _merge == 2 
	drop _merge 
	
	
	* Add Village Survey Info 
	global villinfo 	hfc_near_dist_dry hfc_near_dist_rain ///
						mkt_near_dist_dry mkt_near_dist_rain ///
						hfc_vill1 hfc_vill2 hfc_vill3 hfc_vill4 hfc_vill5 hfc_vill6 hfc_vill888 hfc_vill0 
	
	merge m:1 geo_vill using 	"$dta/endline/PN_Village_Survey_Endline_FINAL_Constructed.dta", /// 
								keepusing($villinfo) 
	
	drop if _merge == 2
	drop _merge 
	
	gen midterm_endline = 1 
	
	append using `midterm'

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

	* market info
	egen mkt_near_dist = rowmean(mkt_near_dist_dry mkt_near_dist_rain)
	replace mkt_near_dist = .m if mi(mkt_near_dist_dry) & mi(mkt_near_dist_rain)
	lab var mkt_near_dist "Nearest Market - hours for round trip"
	tab mkt_near_dist, m 
	
	egen hfc_near_dist = rowmean(hfc_near_dist_dry hfc_near_dist_rain)
	replace hfc_near_dist = .m if mi(hfc_near_dist_dry) & mi(hfc_near_dist_rain)
	lab var hfc_near_dist "Nearest Health Facility - hours for round trip"
	tab hfc_near_dist, m 
	
	gen mkt_distance = .m 
	replace mkt_distance = 0 if mkt_near_dist_rain == 0
	replace mkt_distance = 1 if mkt_near_dist_rain > 0 & mkt_near_dist_rain <= 1.5
	replace mkt_distance = 2 if mkt_near_dist_rain > 1.5 & mkt_near_dist_rain <= 5
	replace mkt_distance = 3 if mkt_near_dist_rain > 5 & !mi(mkt_near_dist_rain)
	lab var mkt_distance "Nearest Market - hours for round trip"
	lab def mkt_distance 0"Market at village" 1"< 1.5 hrs" 2"1.5 - 5 hrs" 3"> 5 hrs"
	lab val mkt_distance mkt_distance
	tab mkt_distance, mis

	gen hfc_distance = .m 
	replace hfc_distance = 0 if hfc_near_dist_rain == 0
	replace hfc_distance = 1 if hfc_near_dist_rain > 0 & hfc_near_dist_rain <= 1.5
	replace hfc_distance = 2 if hfc_near_dist_rain > 1.5 & hfc_near_dist_rain <= 3
	replace hfc_distance = 3 if hfc_near_dist_rain > 3 & !mi(hfc_near_dist_rain)
	lab def hfc_distance 0"Health Facility present at village" 1"<= 1.5 hours" 2"1.6 to 3 hours" 3">3 hours"
	lab val hfc_distance hfc_distance
	lab var hfc_distance "Nearest Health Facility - hours for round trip"
	tab hfc_distance, mis

	
	* FIES - food insecurity dummy outcome * 
	* cutoffs for the raw score of 4+ = food insecurity 
	gen fies_insecurity = (fies_rawscore >= 4) 
	replace fies_insecurity = .m if mi(fies_rawscore)
	lab def fies_insecurity 0"Food secure" 1"Food insecue"
	lab var fies_insecurity "Food Insecurity"
	lab val fies_insecurity fies_insecurity
	tab fies_insecurity, m 
	
	
	* Interaction term 
	gen wempo_index_inter_wealth = wempo_index * NationalScore
	lab var wempo_index_inter_wealth "Women Empowerment Index * Health EquityTool National Score"
		
	* create a dummy var 
	local invars  fies_category fies_insecurity
	
	foreach var in `invars' {
	    
		tab `var', gen(`var'_)
		
		* Loop through the generated variables and update their labels
		foreach var of varlist `var'_* {
			
			* Get the current label
			local current_label : variable label `var'
			
			* Extract the part after "=="
			local new_label = substr("`current_label'", strpos("`current_label'", "==") + 2, .)
			
			* Trim any leading or trailing spaces
			local new_label = trim("`new_label'")
			
			* Update the variable label
			label variable `var' "`new_label'"
		}
	}
	
	
	global outcomes	fies_category_1 fies_category_2 fies_category_3 fies_insecurity // fies_rawscore
	
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
			using "$out/endline/comparision_model/HH_FIES_Midterm_vs_Endline.csv", ///
			eform ///
			cells(b(star fmt(3)) se(par fmt(2)))  ///
			legend label varlabels(_cons constant) ///
			stats(r2 df_r bic) replace

	global outcomes	fies_category_2 fies_category_3 
						
	foreach var in $outcomes {
	    
		di "`var'"
		conindex `var' , rank(wealth_quintile_ns) svy wagstaff bounded limits(0 1) compare(midterm_endline)
		
	}				
	
	
	conindex fies_rawscore, rank(wealth_quintile_ns) svy wagstaff bounded limits(0 8) compare(midterm_endline)
	

	****************************************************************************
	** Program Exposure **
	****************************************************************************

	** Midterm vs endline 

	* endline 
	use "$dta/endline/pnourish_program_exposure_final.dta", clear  
	
	drop prgexp_why_1 prgexp_why_oth_6 prgexp_why_7 prgexp_why_oth_9
	
	gen midterm_endline = 1 
	
	append using "$dta/pnourish_program_exposure_final.dta"
	
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



	global outcomes prgexpo_pn edu_exposure ///
					prgexpo_join1 prgexpo_join2 prgexpo_join3 prgexpo_join4 prgexpo_join5 ///
					prgexpo_join6 prgexpo_join7 prgexpo_join8 prgexpo_join9 ///
					/*prgexp_freq_1 prgexp_freq_2 prgexp_freq_3 prgexp_freq_4*/ ///
					/*prgexp_freq_5 prgexp_freq_6 prgexp_freq_7 prgexp_freq_8*/ ///
					/*prgexp_freq_9*/ ///
					prgexp_iec1 prgexp_iec2 prgexp_iec3 prgexp_iec4 prgexp_iec5 prgexp_iec6 prgexp_iec7 prgexp_iec0  ///
					pn_access pn_muac_access pn_msg_access pn_wash_access pn_sbcc_access pn_hgdn_access pn_emgy_access
					
					/* not present at midterm 
					prgexp_iec_hw_yes /*prgexp_iec_hw_tot*/ ///
					prgexp_iec_iycf_yes /*prgexp_iec_iycf_tot*/ ///
					 */
	
	
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
			using "$out/endline/comparision_model/HH_Program_Exposure_Midterm_vs_Endline.csv", ///
			eform ///
			cells(b(star fmt(3)) se(par fmt(2)))  ///
			legend label varlabels(_cons constant) ///
			stats(r2 df_r bic) replace
			
			
	global outcomes	pn_access pn_muac_access pn_msg_access pn_wash_access pn_sbcc_access pn_hgdn_access pn_emgy_access
					
						
	foreach var in $outcomes {
	    
		di "`var'"
		conindex `var' , rank(wealth_quintile_ns) svy wagstaff bounded limits(0 1) compare(midterm_endline)
		
	}				
	
	
	//conindex wempo_index, rank(wealth_quintile_ns) svy wagstaff bounded limits(-3 1.11) compare(midterm_endline)
	

	
// END HERE 



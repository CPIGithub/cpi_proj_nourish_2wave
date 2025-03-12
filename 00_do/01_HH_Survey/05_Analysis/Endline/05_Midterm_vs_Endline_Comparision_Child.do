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
	
	** multivariate CI - TEST VERSION **
	/*
	NationalScore wealth_quintile_ns
	income_lastmonth
	
	wempo_index
	
	hfc_distance
	
	child_age_month caregiver_age
	
	midterm_endline
	
	*/
	
	logit mdd NationalScore income_lastmonth wempo_index hfc_distance caregiver_age child_age_month if midterm_endline == 0 

	predict p_mdd_midterm if midterm_endline == 0, pr

	logit mdd NationalScore income_lastmonth wempo_index hfc_distance caregiver_age child_age_month if midterm_endline == 1

	predict p_mdd_endline if midterm_endline == 1, pr
	
	gen p_mdd = p_mdd_midterm
	replace p_mdd = p_mdd_endline if !mi(p_mdd_endline) & mi(p_mdd_midterm)
	tab p_mdd, m 
	
	egen rank_p_mdd = rank(p_mdd)

	conindex mdd , rank(wealth_quintile_ns) svy wagstaff bounded limits(0 1) compare(midterm_endline)
	conindex mdd , rank(rank_p_mdd) svy wagstaff bounded limits(0 1) compare(midterm_endline)
	
	
	
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



/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: Data analysis - Mother level and Related Modules			
Author				:	Nicholus Tint Zaw
Date				: 	03/01/2023
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

	
	****************************************************************************
	* Mom Health Module *
	****************************************************************************

	use "$dta/pnourish_mom_health_final.dta", clear   

	* women empowerment dataset 
	merge m:1 _parent_index using "$dta/pnourish_WOMEN_EMPOWER_final.dta", keepusing(wempo_index wempo_category progressivenss)
	
	drop if _merge == 2 
	drop _merge 
	
	* respondent info
	merge m:1 _parent_index using "$dta/pnourish_respondent_info_final.dta", keepusing(respd_age resp_highedu respd_chid_num) 
	
	drop if _merge == 2 
	drop _merge 
	
	* treated other and monestic education as missing
	gen resp_highedu_ci = resp_highedu
	replace resp_highedu_ci = .m if resp_highedu_ci > 7 
	tab resp_highedu_ci, m 
	
	replace resp_highedu = .m if resp_highedu > 7 
	replace resp_highedu = 4 if resp_highedu > 4 & !mi(resp_highedu)
	tab resp_highedu, m 
	
	gen mom_age_grp = (respd_age < 25)
	replace mom_age_grp = 2 if respd_age >= 25 & respd_age < 35 
	replace mom_age_grp = 3 if respd_age >= 35  
	replace mom_age_grp = .m if mi(respd_age)
	lab def mom_age_grp 1"< 25 years old" 2"25 - 34 years old" 3"35+ years old"
	lab val mom_age_grp mom_age_grp
	tab mom_age_grp, m 
	
	
	recode respd_chid_num (1 = 1) (2 = 2) (3/15 = 3), gen(respd_chid_num_grp)
	replace respd_chid_num_grp = .m if mi(respd_chid_num)
	lab def respd_chid_num_grp 1"Has only one child" 2"Has two children" 3"Has three children & more" 
	lab val respd_chid_num_grp respd_chid_num_grp 
	lab var respd_chid_num_grp "Number of Children"
	tab respd_chid_num_grp, m 
	
	* Add Village Survey Info 
	global villinfo 	hfc_near_dist_dry hfc_near_dist_rain ///
						mkt_near_dist_dry mkt_near_dist_rain ///
						hfc_vill1 hfc_vill2 hfc_vill3 hfc_vill4 hfc_vill5 hfc_vill6 hfc_vill888 hfc_vill0 
	
	merge m:1 geo_vill using 	"$dta/PN_Village_Survey_FINAL_Constructed.dta", ///
								keepusing($villinfo) 
	
	drop if _merge == 2
	drop _merge 
	
	// detach value label - resulted from merging 
	foreach var of varlist hfc_near_dist_dry hfc_near_dist_rain mkt_near_dist_dry mkt_near_dist_rain {
		
		lab val `var'
	}
	
	egen hfc_near_dist = rowmean(hfc_near_dist_dry hfc_near_dist_rain)
	replace hfc_near_dist = .m if mi(hfc_near_dist_dry) & mi(hfc_near_dist_rain)
	lab var hfc_near_dist "Nearest Health Facility - hours for round trip"
	tab hfc_near_dist, m 
	
	tab hfc_vill0, m 
	gen hfc_vill_yes = (hfc_vill0 == 0)
	replace hfc_vill_yes = .m if mi(hfc_vill0)
	lab val hfc_vill_yes yesno 
	tab hfc_vill_yes, m 
	

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	* generate the interaction variable - stratum Vs quantile 
	gen NationalQuintile_stratum  =   NationalQuintile*stratum 

	
	* Delivery Month Season *
	tab hh_mem_dob_str, m 
	
	gen delivery_month_season = .m 
	replace delivery_month_season = 1 if 	(hh_mem_dob_str >= tm(2021m3) & hh_mem_dob_str < tm(2021m6)) | ///
											(hh_mem_dob_str >= tm(2022m3) & hh_mem_dob_str < tm(2022m6)) | ///
											(hh_mem_dob_str >= tm(2023m3) & hh_mem_dob_str < tm(2023m4))
	replace delivery_month_season = 2 if 	(hh_mem_dob_str >= tm(2021m6) & hh_mem_dob_str < tm(2021m11)) | ///
											(hh_mem_dob_str >= tm(2022m6) & hh_mem_dob_str < tm(2022m11))
	replace delivery_month_season = 3 if 	(hh_mem_dob_str >= tm(2021m1) & hh_mem_dob_str < tm(2021m3)) | ///
											(hh_mem_dob_str >= tm(2021m11) & hh_mem_dob_str < tm(2022m3)) | ///
											(hh_mem_dob_str >= tm(2022m11) & hh_mem_dob_str < tm(2023m3))
	// lab def delivery_month_season 1"Summer" 2"Raining" 3"Winter"
	replace delivery_month_season = 1 if delivery_month_season == 3
	lab def delivery_month_season 1"Dry" 2"Wet"
	lab val delivery_month_season delivery_month_season
	tab delivery_month_season, m 
	
	gen child_dob_year = year(dofm(hh_mem_dob_str))
	tab child_dob_year, m 
	
	gen child_dob_season_yr = .m 
	replace child_dob_season_yr = 1 if child_dob_year == 2021 & delivery_month_season == 1
	replace child_dob_season_yr = 2 if child_dob_year == 2021 & delivery_month_season == 2
	replace child_dob_season_yr = 3 if child_dob_year == 2021 & delivery_month_season == 3
	replace child_dob_season_yr = 4 if child_dob_year == 2022 & delivery_month_season == 1
	replace child_dob_season_yr = 5 if child_dob_year == 2022 & delivery_month_season == 2
	replace child_dob_season_yr = 6 if child_dob_year == 2022 & delivery_month_season == 3
	replace child_dob_season_yr = 7 if child_dob_year == 2023 & delivery_month_season == 1
	replace child_dob_season_yr = 8 if child_dob_year == 2023 & delivery_month_season == 2
	replace child_dob_season_yr = 9 if child_dob_year == 2023 & delivery_month_season == 3
	lab def child_dob_season_yr 1"2021 Summer" ///
								2"2021 Raining" ///
								3"2021 Winter" ///
								4"2022 Summer" ///
								5"2022 Raining" ///
								6"2022 Winter" ///
								7"2023 Summer" ///
								8"2023 Raining" ///
								9"2023 Winter"
	lab val child_dob_season_yr child_dob_season_yr
	tab child_dob_season_yr, m 
	
	
	* ANC Months Season * 
	* it will be better to construct # of gestation age month cover by dry or wet season in 2 and 3rd trimester 
/*	
			2 and 3 trimester	all trimester		
	Season	Month	dry	wet	tot	dry	wet	tot
	dry			1	2	4	6	4	5	9
	dry			2	3	3	6	4	5	9
	dry			3	4	2	6	4	5	9
	dry			4	5	1	6	5	4	9
	dry			5	6	0	6	6	3	9
	wet			6	6	0	6	7	2	9
	wet			7	5	1	6	7	2	9
	wet			8	4	2	6	7	2	9
	wet			9	3	3	6	6	3	9
	wet			10	2	4	6	5	4	9
	dry			11	1	5	6	4	5	9
	dry			12	1	5	6	4	5	9

*/
	gen child_dob_month = month(dofm(hh_mem_dob_str))
	
	// the whole pregnancy gestation age period 
	gen anc_month_dry = .m 
	replace anc_month_dry = 4 if child_dob_month == 1
	replace anc_month_dry = 4 if child_dob_month == 2
	replace anc_month_dry = 4 if child_dob_month == 3
	replace anc_month_dry = 5 if child_dob_month == 4
	replace anc_month_dry = 6 if child_dob_month == 5
	replace anc_month_dry = 7 if child_dob_month == 6
	replace anc_month_dry = 7 if child_dob_month == 7
	replace anc_month_dry = 7 if child_dob_month == 8
	replace anc_month_dry = 6 if child_dob_month == 9
	replace anc_month_dry = 5 if child_dob_month == 10
	replace anc_month_dry = 4 if child_dob_month == 11
	replace anc_month_dry = 4 if child_dob_month == 12
	tab anc_month_dry, m 

	gen anc_month_wet = .m 
	replace anc_month_wet = 5 if child_dob_month == 1
	replace anc_month_wet = 5 if child_dob_month == 2
	replace anc_month_wet = 5 if child_dob_month == 3
	replace anc_month_wet = 4 if child_dob_month == 4
	replace anc_month_wet = 3 if child_dob_month == 5
	replace anc_month_wet = 2 if child_dob_month == 6
	replace anc_month_wet = 2 if child_dob_month == 7
	replace anc_month_wet = 2 if child_dob_month == 8
	replace anc_month_wet = 3 if child_dob_month == 9
	replace anc_month_wet = 4 if child_dob_month == 10
	replace anc_month_wet = 5 if child_dob_month == 11
	replace anc_month_wet = 5 if child_dob_month == 12
	tab anc_month_wet, m 


	// in the last 2 trimesters 
	gen anc_month_wet_2s = .m 
	replace anc_month_wet_2s = 4 if child_dob_month == 1
	replace anc_month_wet_2s = 3 if child_dob_month == 2
	replace anc_month_wet_2s = 2 if child_dob_month == 3
	replace anc_month_wet_2s = 1 if child_dob_month == 4
	replace anc_month_wet_2s = 0 if child_dob_month == 5
	replace anc_month_wet_2s = 0 if child_dob_month == 6
	replace anc_month_wet_2s = 1 if child_dob_month == 7
	replace anc_month_wet_2s = 2 if child_dob_month == 8
	replace anc_month_wet_2s = 3 if child_dob_month == 9
	replace anc_month_wet_2s = 4 if child_dob_month == 10
	replace anc_month_wet_2s = 5 if child_dob_month == 11
	replace anc_month_wet_2s = 5 if child_dob_month == 12
	tab anc_month_wet_2s, m 
	
	
	gen anc_month_dry_2s = .m 
	replace anc_month_dry_2s = 2 if child_dob_month == 1
	replace anc_month_dry_2s = 3 if child_dob_month == 2
	replace anc_month_dry_2s = 4 if child_dob_month == 3
	replace anc_month_dry_2s = 5 if child_dob_month == 4
	replace anc_month_dry_2s = 6 if child_dob_month == 5
	replace anc_month_dry_2s = 6 if child_dob_month == 6
	replace anc_month_dry_2s = 5 if child_dob_month == 7
	replace anc_month_dry_2s = 4 if child_dob_month == 8
	replace anc_month_dry_2s = 3 if child_dob_month == 9
	replace anc_month_dry_2s = 2 if child_dob_month == 10
	replace anc_month_dry_2s = 1 if child_dob_month == 11
	replace anc_month_dry_2s = 1 if child_dob_month == 12
	tab anc_month_dry_2s, m 

	gen anc_month_2s_season = (anc_month_dry_2s == anc_month_wet_2s)
	replace anc_month_2s_season = 2 if anc_month_dry_2s > anc_month_wet_2s
	replace anc_month_2s_season = 3 if anc_month_dry_2s < anc_month_wet_2s
	replace anc_month_2s_season = .m if mi(anc_month_dry_2s) | mi(anc_month_wet_2s)
	lab def anc_month_2s_season 1"Same months for Dry and Wet season" ///
								2"Dry > Wet (# of months)" ///
								3"Dry < Wet (# of months)"
	lab val anc_month_2s_season anc_month_2s_season
	lab var anc_month_2s_season "Number of Gestation month by season (in 2 and 3 trimaster)"
	tab anc_month_2s_season, m 

	gen anc_month_season = (anc_month_dry > anc_month_wet)
	replace anc_month_season = .m if mi(anc_month_dry) | mi(anc_month_wet)
	lab def anc_month_season 1"Dry > Wet (# of months)" 0"Dry < Wet (# of months)"
	lab val anc_month_season anc_month_season
	lab var anc_month_season "Number of Gestation month by season (in all 3 trimasters)"
	tab anc_month_season, m 
	
	* NationalQuintile - adjustment 
	gen NationalQuintile_recod = NationalQuintile
	replace NationalQuintile_recod = 4 if NationalQuintile > 4 & !mi(NationalQuintile)
	lab def NationalQuintile_recod 1"Poorest" 2"Poor" 3"Medium" 4"Wealthy"
	lab val NationalQuintile_recod NationalQuintile_recod
	tab NationalQuintile_recod, m 
	
	
	****************************************************************************
	** Mom (REspondent) Characteristics **
	****************************************************************************
	
	// resp_highedu
	svy: tab resp_highedu, ci 
	
	// mom_age_grp
	svy: tab mom_age_grp,ci
	
	svy: tab respd_chid_num_grp, ci 
	
	// wempo_index
	svy: mean wempo_index

	// progressivenss
	svy: tab progressivenss,ci

	// wempo_category
	svy: tab wempo_category,ci
	
	
	svy: tab stratum_num progressivenss, row 
	svy: tab stratum_num wempo_category, row 

	svy: mean wempo_index
	svy: mean wempo_index, over(stratum_num)
	test 	_b[c.wempo_index@1bn.stratum_num] = ///
			_b[c.wempo_index@2bn.stratum_num] = ///
			_b[c.wempo_index@3bn.stratum_num] = ///
			_b[c.wempo_index@4bn.stratum_num] = ///
			_b[c.wempo_index@5bn.stratum_num]
		
	svy: tab wealth_quintile_ns progressivenss, row 
	svy: tab wealth_quintile_ns wempo_category, row 

	svy: mean wempo_index
	svy: mean wempo_index, over(wealth_quintile_ns)
	test 	_b[c.wempo_index@1bn.wealth_quintile_ns] = ///
			_b[c.wempo_index@2bn.wealth_quintile_ns] = ///
			_b[c.wempo_index@3bn.wealth_quintile_ns] = ///
			_b[c.wempo_index@4bn.wealth_quintile_ns] = ///
			_b[c.wempo_index@5bn.wealth_quintile_ns]
			

	
	****************************************************************************
	** Mom ANC **
	****************************************************************************
	* adjustment - make 0 for those who did not get ANC
	foreach var of varlist anc_who_trained anc_visit_trained anc_visit_trained_4times {
	    
	    tab `var', m 
		replace `var' = 0 if anc_yn == 0
		tab `var', m 
	}

	
							
	****************************************************************************
	** Mom PNC **
	****************************************************************************
	
	* adjustment - make 0 for those who did not get ANC
	foreach var of varlist pnc_who_trained {
	    
	    tab `var', m 
		replace `var' = 0 if pnc_yn == 0
		tab `var', m 
	}
	
	

	****************************************************************************
	** Mom NBC **
	****************************************************************************
	* adjustment - make 0 for those who did not get ANC
	foreach var of varlist  nbc_who_trained {
	    
	    tab `var', m 
		replace `var' = 0 if nbc_yn == 0
		tab `var', m 
	}
	
	replace nbc_2days_yn = 0 if mi(nbc_2days_yn) & nbc_yn == 0
	tab nbc_2days_yn, m 
	
	
	
	** lowess curve: distance to hfc and mom health indicator 
	lab var anc_yn "Received ANC with anyone"
	lab var anc_who_trained "Received ANC with trained health personnel"
	lab var anc_visit_trained_4times "At least four ANC visits"
	lab var pnc_yn "Received PNC with anyone"
	lab var pnc_who_trained "Received PNC with trained health personnel"
	lab var nbc_yn "Received NBC with anyone"
	lab var nbc_who_trained "Received NBC with trained health personnel"

	local outcome anc_yn anc_who_trained anc_visit_trained_4times ///
					insti_birth skilled_battend ///
					pnc_yn pnc_who_trained ///
					nbc_yn nbc_who_trained
					
	
	foreach var in `outcome' {
		
		* Create a scatter plot with lowess curves 
		twoway scatter `var' hfc_near_dist, ///
			mcolor(blue) msize(small) ///
			legend(off)

		* Add lowess curves
		lowess `var' hfc_near_dist, ///
			lcolor(red) lwidth(medium) ///
			legend(label(1 "Lowess Curve"))
			
		graph export "$plots/lowess_`var'_hfc_distance.png", replace
	
	}
	

	
	
	
// END HERE 



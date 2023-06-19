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
	** Mom Dietary Diversity **
	****************************************************************************

	use "$dta/pnourish_mom_diet_final.dta", clear 
	
	merge m:1 _parent_index using "$dta/pnourish_WOMEN_EMPOWER_final.dta", keepusing(wempo_index)
	
	drop if _merge == 2 
	drop _merge 
	
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	* generate the interaction variable - stratum Vs quantile 
	gen NationalQuintile_stratum  =   NationalQuintile*stratum 
	
	// mom_meal_freq
	svy: mean mom_meal_freq

	svy: mean mom_meal_freq, over(stratum_num)
	svy: reg mom_meal_freq i.stratum_num
	
	svy: mean mom_meal_freq, over(NationalQuintile)
	svy: reg mom_meal_freq i.NationalQuintile

	svy: mean mom_meal_freq, over(wealth_quintile_ns)

	
	// food groups 
	svy: mean  mddw_grain mddw_pulses mddw_nut mddw_milk mddw_meat ///
								mddw_moom_egg mddw_green_veg mddw_vit_vegfruit ///
								mddw_oth_veg mddw_oth_fruit
			
	foreach var of varlist mddw_grain mddw_pulses mddw_nut mddw_milk mddw_meat ///
								mddw_moom_egg mddw_green_veg mddw_vit_vegfruit ///
								mddw_oth_veg mddw_oth_fruit {
									
			svy: tab stratum_num `var', row //  have same obs 

								}
	
	svy: mean 	mddw_grain mddw_pulses mddw_nut mddw_milk mddw_meat ///
				mddw_moom_egg mddw_green_veg mddw_vit_vegfruit ///
				mddw_oth_veg mddw_oth_fruit, ///
				over(stratum_num)

	foreach var of varlist mddw_grain mddw_pulses mddw_nut mddw_milk mddw_meat ///
								mddw_moom_egg mddw_green_veg mddw_vit_vegfruit ///
								mddw_oth_veg mddw_oth_fruit {
									
			svy: tab NationalQuintile `var', row //  have same obs 

								}
								
	svy: mean 	mddw_grain mddw_pulses mddw_nut mddw_milk mddw_meat ///
				mddw_moom_egg mddw_green_veg mddw_vit_vegfruit ///
				mddw_oth_veg mddw_oth_fruit, ///
				over(NationalQuintile)							

				
	foreach var of varlist 	mddw_grain mddw_pulses mddw_nut mddw_milk mddw_meat ///
							mddw_moom_egg mddw_green_veg mddw_vit_vegfruit ///
							mddw_oth_veg mddw_oth_fruit {
	    
		di "`var'"
		
		svy: tab wealth_quintile_ns `var', row
	
	}	
	
	
	// mddw_score
	svy: mean  mddw_score

	svy: mean mddw_score, over(stratum_num)
	svy: reg mddw_score i.stratum_num
	
	svy: mean mddw_score, over(NationalQuintile)
	svy: reg mddw_score i.NationalQuintile
	svy: mean mddw_score, over(wealth_quintile_ns)

	svy: reg mddw_score wempo_index 
	
	svy: reg mom_meal_freq wempo_index 

	
	
	// mddw_yes
	svy: mean  mddw_yes
	svy: tab stratum_num mddw_yes, row 
	svy: tab NationalQuintile mddw_yes, row
	svy: tab wealth_quintile_ns mddw_yes, row
	
	svy: tab hhitems_phone mddw_yes, row 
	svy: tab prgexpo_pn mddw_yes, row 	
	
	svy: reg mddw_score hhitems_phone
	svy: reg mddw_score prgexpo_pn
	
	svy: reg mddw_yes wempo_index 


	// dietary_tot 
	svy: mean mddw_score, over(hhitems_phone)
	test _b[c.mddw_score@0bn.hhitems_phone] = _b[c.mddw_score@1bn.hhitems_phone]

	svy: mean mddw_score, over(prgexpo_pn)
	test _b[c.mddw_score@0bn.prgexpo_pn] = _b[c.mddw_score@1bn.prgexpo_pn]

	svy: mean mddw_score, over(edu_exposure)
	test _b[c.mddw_score@0bn.edu_exposure] = _b[c.mddw_score@1bn.edu_exposure]

	
	svy: tab hhitems_phone mddw_yes, row 
	svy: tab prgexpo_pn mddw_yes, row 
	svy: tab edu_exposure mddw_yes, row 

	
	gen stratum_org_inter = stratum * org_name_num  
	gen KDHW = (stratum_num == 5)

	local outcome mddw_score mom_meal_freq
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') truezero svy 
		}
	
	}	
	
	
	foreach v in `outcome' {
		
		svy: reg `v' KDHW stratum org_name_num 
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/12_mom_diet_score_table.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	foreach v in `outcome' {
		
		svy: reg `v' KDHW i.org_name_num##stratum  
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/12_mom_diet_score_table_m2.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	foreach v in `outcome' {
		
		svy: reg `v' wempo_index NationalQuintile stratum NationalQuintile_stratum i.org_name_num
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/12_mom_diet_score_table_FINAL.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	local outcome 	mddw_yes ///
					mddw_grain mddw_pulses mddw_nut mddw_milk mddw_meat ///
					mddw_moom_egg mddw_green_veg mddw_vit_vegfruit ///
					mddw_oth_veg mddw_oth_fruit
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}
	
	

	
	foreach v in `outcome' {
		
		svy: logit `v' KDHW stratum org_name_num 
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/13_mom_fg_table.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	   
	
	foreach v in `outcome' {
		
		svy: logit `v' KDHW i.org_name_num##stratum  
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/13_mom_fg_table_m2.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace	   
	
	
	foreach v in `outcome' {
		
		svy: reg `v' wempo_index NationalQuintile stratum NationalQuintile_stratum i.org_name_num
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/13_mom_fg_table_FINAL.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	 
	 
	// Model 4
	local outcome	mddw_score mom_meal_freq
	
	foreach v in `outcome' {
		
		svy: reg `v' i.NationalQuintile i.org_name_num i.NationalQuintile##stratum wempo_index
		//eststo model_B
		estimates store `v', title(`v')
		
	}
		
		estout `outcome' using "$out/reg_output/FINAL_MomDiet_Model_4.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
		   legend label varlabels(_cons constant)              ///
		   stats(r2 df_r bic) replace	
		   
	foreach v in `outcome' {
		
		svy: reg `v' i.wealth_quintile_ns i.org_name_num i.wealth_quintile_ns##stratum wempo_index
		//eststo model_B
		estimates store `v', title(`v')
		
	}
		
		estout `outcome' using "$out/reg_output/FINAL_MomDiet_Model_4_PNDist.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
		   legend label varlabels(_cons constant)              ///
		   stats(r2 df_r bic) replace
		   
	local outcome	mddw_yes ///
					mddw_grain mddw_pulses mddw_nut mddw_milk mddw_meat ///
					mddw_moom_egg mddw_green_veg mddw_vit_vegfruit ///
					mddw_oth_veg mddw_oth_fruit
	
	foreach v in `outcome' {
		
		svy: logit `v' i.NationalQuintile i.org_name_num i.NationalQuintile##stratum wempo_index
		//eststo model_B
		estimates store `v', title(`v')
		
	}
		
		estout `outcome' using "$out/reg_output/FINAL_MomDiet_Model_4_logistic.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
		   legend label varlabels(_cons constant)              ///
		   stats(r2 df_r bic) replace	
		   
		   
	foreach v in `outcome' {
		
		svy: logit `v' i.wealth_quintile_ns i.org_name_num i.wealth_quintile_ns##stratum wempo_index
		//eststo model_B
		estimates store `v', title(`v')
		
	}
		
		estout `outcome' using "$out/reg_output/FINAL_MomDiet_Model_4_logistic_PNDist.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
		   legend label varlabels(_cons constant)              ///
		   stats(r2 df_r bic) replace		
	
	
	****************************************************************************
	* Mom Health Module *
	****************************************************************************

	use "$dta/pnourish_mom_health_final.dta", clear   

	merge m:1 _parent_index using "$dta/pnourish_WOMEN_EMPOWER_final.dta", keepusing(wempo_index)
	
	drop if _merge == 2 
	drop _merge 
	
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
	lab def delivery_month_season 1"Summer" 2"Raining" 3"Winter"
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
	
	
	* ANC Months Season * // need to check it - revised the code and concept 
	gen anc_month_season = .m 
	replace anc_month_season = 1 if 	(hh_mem_dob_str >= tm(2021m2) & hh_mem_dob_str < tm(2021m5)) | ///
										(hh_mem_dob_str >= tm(2022m2) & hh_mem_dob_str < tm(2022m5)) | ///
										(hh_mem_dob_str >= tm(2023m2) & hh_mem_dob_str < tm(2023m4))						 
	replace anc_month_season = 2 if 	(hh_mem_dob_str >= tm(2021m1) & hh_mem_dob_str < tm(2022m2)) | ///
										(hh_mem_dob_str >= tm(2021m9) & hh_mem_dob_str < tm(2022m6)) | ///
										(hh_mem_dob_str >= tm(2022m9) & hh_mem_dob_str < tm(2023m2))
	replace anc_month_season = 3 if 	(hh_mem_dob_str >= tm(2021m5) & hh_mem_dob_str < tm(2021m9)) | ///
										(hh_mem_dob_str >= tm(2022m5) & hh_mem_dob_str < tm(2022m9)) 
	lab val anc_month_season delivery_month_season
	tab anc_month_season, m 
	
	
	* NationalQuintile - adjustment 
	gen NationalQuintile_recod = NationalQuintile
	replace NationalQuintile_recod = 4 if NationalQuintile > 4 & !mi(NationalQuintile)
	lab def NationalQuintile_recod 1"Poorest" 2"Poor" 3"Medium" 4"Wealthy"
	lab val NationalQuintile_recod NationalQuintile_recod
	tab NationalQuintile_recod, m 
	
	
	****************************************************************************
	** Mom ANC **
	****************************************************************************

	
	// anc_yn 
	svy: mean  anc_yn
	svy: tab stratum_num anc_yn, row 
	svy: tab NationalQuintile anc_yn, row
	svy: tab hh_mem_dob_str anc_yn, row 
	
	lab var anc_yn "ANC - yes"

	* Create a scatter plot with lowess curves 
	twoway scatter anc_yn hh_mem_dob_str, ///
		mcolor(blue) msize(small) ///
		ytitle("Miles per Gallon") xtitle("Weight") ///
		title("Scatter Plot with Lowess Curves") ///
		legend(off)

	* Add lowess curves
	lowess anc_yn hh_mem_dob_str, ///
		lcolor(red) lwidth(medium) ///
		legend(label(1 "Lowess Curve"))
		
	graph export "$plots/lowess_anc_childob.png", replace

	
	
	svy: reg anc_yn hfc_near_dist_dry 
	svy: reg anc_yn hfc_near_dist_rain 

	
	// anc_where 
	svy: tab anc_where,ci
	svy: tab stratum_num anc_where, row 
	svy: tab NationalQuintile anc_where, row 
	svy: tab NationalQuintile_recod anc_where, row 
	svy: tab wealth_quintile_ns anc_where, row 
	
	
	// anc_*_who
	// anc_who_1 anc_who_2 anc_who_3 anc_who_4 anc_who_5 anc_who_6 anc_who_7 anc_who_8 anc_who_9 anc_who_10 anc_who_11 anc_who_888
 	svy: mean 	anc_who_1 anc_who_2 anc_who_3 anc_who_4 anc_who_5 anc_who_6 ///
				anc_who_7 anc_who_8 anc_who_9 anc_who_10 anc_who_11 anc_who_888
	
	svy: mean 	anc_who_1 anc_who_2 anc_who_3 anc_who_4 anc_who_5 anc_who_6 ///
				anc_who_7 anc_who_8 anc_who_9 anc_who_10 anc_who_11 anc_who_888, ///
				over(stratum_num)
	
	foreach var of varlist 	anc_who_1 anc_who_2 anc_who_3 anc_who_4 anc_who_5 ///
							anc_who_6 anc_who_7 anc_who_8 anc_who_9 anc_who_10 ///
							anc_who_11 anc_who_888 {
		
		svy: tab stratum_num `var', row 
	}
	
	svy: mean 	anc_who_1 anc_who_2 anc_who_3 anc_who_4 anc_who_5 anc_who_6 ///
				anc_who_7 anc_who_8 anc_who_9 anc_who_10 anc_who_11 anc_who_888, ///
				over(NationalQuintile)
	
	foreach var of varlist 	anc_who_1 anc_who_2 anc_who_3 anc_who_4 anc_who_5 ///
							anc_who_6 anc_who_7 anc_who_8 anc_who_9 anc_who_10 ///
							anc_who_11 anc_who_888 {
		
		svy: tab NationalQuintile `var', row 
	}
	

	foreach var of varlist 	anc_who_1 anc_who_2 anc_who_3 anc_who_4 anc_who_5 ///
							anc_who_6 anc_who_7 anc_who_8 anc_who_9 anc_who_10 ///
							anc_who_11 anc_who_888 {
		
		svy: tab NationalQuintile_recod `var', row 
	}
	
	foreach var of varlist 	anc_who_1 anc_who_2 anc_who_3 anc_who_4 anc_who_5 ///
							anc_who_6 anc_who_7 anc_who_8 anc_who_9 anc_who_10 ///
							anc_who_11 anc_who_888 {
		
		svy: tab wealth_quintile_ns `var', row 
	}	
	

	// anc_who_trained
	svy: mean  anc_who_trained
	svy: tab stratum_num anc_who_trained, row 
	svy: tab NationalQuintile anc_who_trained, row
	svy: tab hh_mem_dob_str anc_who_trained, row 

	* Create a scatter plot with lowess curves 
	twoway scatter anc_who_trained hh_mem_dob_str, ///
		mcolor(blue) msize(small) ///
		ytitle("Miles per Gallon") xtitle("Weight") ///
		title("Scatter Plot with Lowess Curves") ///
		legend(off)

	* Add lowess curves
	lowess anc_who_trained hh_mem_dob_str, ///
		lcolor(red) lwidth(medium) ///
		legend(label(1 "Lowess Curve"))
		
	graph export "$plots/lowess_anc_who_trained_childob.png", replace
	
	
	svy: reg anc_who_trained hfc_near_dist_dry 
	svy: reg anc_who_trained hfc_near_dist_rain 


	// anc_*_visit
	// anc_who_visit_1 anc_who_visit_2 anc_who_visit_3 anc_who_visit_4 anc_who_visit_5 anc_who_visit_6 anc_who_visit_7 anc_who_visit_8 anc_who_visit_9 anc_who_visit_10 anc_who_visit_11 anc_who_visit_888
	
	svy: mean	anc_who_visit_1 
	
	svy: mean	anc_who_visit_2 
	
	svy: mean	anc_who_visit_3 
	
	svy: mean	anc_who_visit_4 ///
	
	svy: mean	anc_who_visit_5 
	
	svy: mean	anc_who_visit_6 
	
	svy: mean	anc_who_visit_7 
	
	svy: mean	anc_who_visit_8 ///
				
	svy: mean	anc_who_visit_9 
	
	svy: mean	anc_who_visit_10 
	
	svy: mean	anc_who_visit_11 
	
	svy: mean	anc_who_visit_888
		

	// anc_visit_trained
	svy: mean  anc_visit_trained
	svy: mean anc_visit_trained if child_dob_year < 2023, over(child_dob_season_yr) 

	svy: mean anc_visit_trained, over(stratum_num)
	svy: reg anc_visit_trained i.stratum_num
	
	svy: mean anc_visit_trained, over(NationalQuintile)
	svy: reg anc_visit_trained i.NationalQuintile

	svy: reg anc_visit_trained hfc_near_dist_dry 
	svy: reg anc_visit_trained hfc_near_dist_rain 

	// anc_visit_trained_4times
	svy: mean  anc_visit_trained_4times
	svy: tab stratum_num anc_visit_trained_4times, row 
	svy: tab NationalQuintile anc_visit_trained_4times, row
	
	svy: tab hh_mem_dob_str anc_visit_trained_4times, row 

	* Create a scatter plot with lowess curves 
	twoway scatter anc_visit_trained_4times hh_mem_dob_str, ///
		mcolor(blue) msize(small) ///
		ytitle("Miles per Gallon") xtitle("Weight") ///
		title("Scatter Plot with Lowess Curves") ///
		legend(off)

	* Add lowess curves
	lowess anc_visit_trained_4times hh_mem_dob_str, ///
		lcolor(red) lwidth(medium) ///
		legend(label(1 "Lowess Curve"))
		
	graph export "$plots/lowess_anc_visit_trained_4times_childob.png", replace
	
	
	svy: reg anc_visit_trained_4times hfc_near_dist_dry 
	svy: reg anc_visit_trained_4times hfc_near_dist_rain 	
	
	svy: tab hhitems_phone anc_yn, row 
	svy: tab prgexpo_pn anc_yn, row 	
	svy: tab edu_exposure anc_yn, row 
	svy: tab child_dob_season_yr anc_yn if child_dob_year < 2023, row 

	svy: tab hhitems_phone anc_who_trained, row 
	svy: tab prgexpo_pn anc_who_trained, row 	
	svy: tab edu_exposure anc_who_trained, row 
	svy: tab child_dob_season_yr anc_who_trained if child_dob_year < 2023, row 
	
	svy: tab hhitems_phone anc_visit_trained_4times, row 
	svy: tab prgexpo_pn anc_visit_trained_4times, row 	
	svy: tab edu_exposure anc_visit_trained_4times, row 
	svy: tab child_dob_season_yr anc_visit_trained_4times if child_dob_year < 2023, row 

	svy: reg anc_visit_trained hhitems_phone
	svy: reg anc_visit_trained prgexpo_pn
	svy: tab edu_exposure prgexpo_pn, row 

	
	svy: reg anc_yn wempo_index 
	svy: reg anc_who_trained wempo_index 
	svy: reg anc_visit_trained wempo_index 

	
	svy: mean anc_visit_trained, over(wealth_quintile_ns)

	foreach var of varlist anc_yn anc_who_trained anc_visit_trained_4times	{
	    
		di "`var'"
		
		svy: tab wealth_quintile_ns `var', row
	
	}	
	
	local outcome anc_visit_trained
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') truezero svy 
		}
	
	}	
	
	
	gen stratum_org_inter = stratum * org_name_num  

	gen KDHW = (stratum_num == 5)

		
	foreach v in `outcome' {
		
		svy: reg `v' KDHW stratum org_name_num 
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/14_mom_anc_visit_table.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace

	   
	foreach v in `outcome' {
		
		svy: reg `v' KDHW i.org_name_num##stratum  
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/14_mom_anc_visit_table_m2.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	   
	local outcome 	anc_yn anc_who_trained anc_visit_trained_4times
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}
	
	
	
	foreach v in `outcome' {
		
		svy: logit `v' KDHW stratum org_name_num 
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/15_mom_anc_all_table.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace

	foreach v in `outcome' {
		
		svy: logit `v' KDHW i.org_name_num##stratum  
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/15_mom_anc_all_table_m2.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	   

	****************************************************************************
	** Mom Deliverty **
	****************************************************************************
	// deliv_place 
	svy: tab deliv_place,ci
	svy: tab stratum_num deliv_place, row 
	svy: tab NationalQuintile deliv_place, row 
	svy: tab NationalQuintile_recod deliv_place, row 
	svy: tab wealth_quintile_ns deliv_place, row

	// Institutional Deliveries
	svy: mean  insti_birth
	svy: tab stratum_num insti_birth, row 
	svy: tab NationalQuintile insti_birth, row
	svy: tab wealth_quintile_ns insti_birth, row

	svy: reg insti_birth hfc_near_dist_dry 
	svy: reg insti_birth hfc_near_dist_rain 	
	
	// deliv_assist
	svy: tab deliv_assist,ci
	svy: tab stratum_num deliv_assist, row 
	svy: tab NationalQuintile deliv_assist, row 
	svy: tab NationalQuintile_recod deliv_assist, row 
	svy: tab wealth_quintile_ns deliv_assist, row

	svy: tab child_dob_season_yr deliv_assist if child_dob_year < 2023, row

	
	// Births attended by skilled health personnel
	svy: mean  skilled_battend
	svy: tab stratum_num skilled_battend, row 
	svy: tab NationalQuintile skilled_battend, row
	svy: tab child_dob_season_yr skilled_battend if child_dob_year < 2023, row

	svy: reg skilled_battend i.delivery_month_season child_dob_year if child_dob_year < 2023

	svy: reg skilled_battend hfc_near_dist_dry 
	svy: reg skilled_battend hfc_near_dist_rain 	
	
	svy: tab hhitems_phone skilled_battend, row 
	svy: tab prgexpo_pn skilled_battend, row 	
	svy: tab edu_exposure skilled_battend, row 

	svy: tab hhitems_phone insti_birth, row 
	svy: tab prgexpo_pn insti_birth, row 	
	svy: tab edu_exposure insti_birth, row 
	svy: tab child_dob_season_yr insti_birth if child_dob_year < 2023, row

	svy: reg insti_birth i.delivery_month_season child_dob_year if child_dob_year < 2023

	svy: reg skilled_battend wempo_index 
	svy: reg insti_birth wempo_index 
	
	svy: tab wealth_quintile_ns insti_birth, row
	svy: tab wealth_quintile_ns skilled_battend, row

	
	local outcome 	insti_birth skilled_battend
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}
	
	
	foreach v in `outcome' {
		
		svy: logit `v' KDHW stratum org_name_num 
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/16_mom_deli_table.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	foreach v in `outcome' {
		
		svy: logit `v' KDHW i.org_name_num##stratum  
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/16_mom_deli_table_m2.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	svy: tab hh_mem_dob_str insti_birth, row 
	svy: tab hh_mem_dob_str skilled_battend, row 
	
	****************************************************************************
	** Mom PNC **
	****************************************************************************
	// pnc_yn 
	svy: mean  pnc_yn
	svy: tab stratum_num pnc_yn, row 
	svy: tab NationalQuintile pnc_yn, row
	svy: tab child_dob_season_yr pnc_yn if child_dob_year < 2023, row
	svy: tab wealth_quintile_ns pnc_yn, row
	
	svy: reg pnc_yn hfc_near_dist_dry 
	svy: reg pnc_yn hfc_near_dist_rain 	
	
	// pnc_where 
	svy: tab pnc_where,ci
	svy: tab stratum_num pnc_where, row 
	svy: tab NationalQuintile pnc_where, row 
	svy: tab NationalQuintile_recod pnc_where, row 
	svy: tab wealth_quintile_ns pnc_where, row 
	

	// pnc_*_who
	// pnc_who_1 pnc_who_2 pnc_who_3 pnc_who_4 pnc_who_5 pnc_who_6 pnc_who_7 pnc_who_8 pnc_who_9 pnc_who_10 pnc_who_11 pnc_who_888
	
	
	svy: mean 	pnc_who_1 pnc_who_2 pnc_who_3 pnc_who_4 pnc_who_5 pnc_who_6 ///
				pnc_who_7 pnc_who_8 pnc_who_9 pnc_who_10 pnc_who_11 pnc_who_888
	
	svy: mean 	pnc_who_1 pnc_who_2 pnc_who_3 pnc_who_4 pnc_who_5 pnc_who_6 ///
				pnc_who_7 pnc_who_8 pnc_who_9 pnc_who_10 pnc_who_11 pnc_who_888, ///
				over(stratum_num)
	
	foreach var of varlist 	pnc_who_1 pnc_who_2 pnc_who_3 pnc_who_4 pnc_who_5 ///
							pnc_who_6 pnc_who_7 pnc_who_8 pnc_who_9 pnc_who_10 ///
							pnc_who_11 pnc_who_888 {
		
		svy: tab stratum_num `var', row 
	}
	
	svy: mean 	pnc_who_1 pnc_who_2 pnc_who_3 pnc_who_4 pnc_who_5 pnc_who_6 ///
				pnc_who_7 pnc_who_8 pnc_who_9 pnc_who_10 pnc_who_11 pnc_who_888, ///
				over(NationalQuintile)
	
	foreach var of varlist 	pnc_who_1 pnc_who_2 pnc_who_3 pnc_who_4 pnc_who_5 ///
							pnc_who_6 pnc_who_7 pnc_who_8 pnc_who_9 pnc_who_10 ///
							pnc_who_11 pnc_who_888 {
		
		svy: tab NationalQuintile `var', row 
	}
	
	
	foreach var of varlist 	pnc_who_1 pnc_who_2 pnc_who_3 pnc_who_4 pnc_who_5 ///
							pnc_who_6 pnc_who_7 pnc_who_8 pnc_who_9 pnc_who_10 ///
							pnc_who_11 pnc_who_888 {
		
		svy: tab NationalQuintile_recod `var', row 
	}
		
	
	foreach var of varlist 	pnc_who_1 pnc_who_2 pnc_who_3 pnc_who_4 pnc_who_5 ///
							pnc_who_6 pnc_who_7 pnc_who_8 pnc_who_9 pnc_who_10 ///
							pnc_who_11 pnc_who_888 {
		
		svy: tab wealth_quintile_ns `var', row 
	}	
	
		
	// pnc_who_trained
	svy: mean  pnc_who_trained
	svy: tab stratum_num pnc_who_trained, row 
	svy: tab NationalQuintile pnc_who_trained, row
	svy: tab child_dob_season_yr pnc_who_trained if child_dob_year < 2023, row
	svy: tab wealth_quintile_ns pnc_who_trained, row

	svy: reg pnc_who_trained hfc_near_dist_dry 
	svy: reg pnc_who_trained hfc_near_dist_rain 	
	
	svy: tab hhitems_phone pnc_yn, row 
	svy: tab prgexpo_pn pnc_yn, row 	
	svy: tab edu_exposure pnc_yn, row 
	
	svy: tab hhitems_phone pnc_who_trained, row 
	svy: tab prgexpo_pn pnc_who_trained, row 	
	svy: tab edu_exposure pnc_who_trained, row 
	
	
	local outcome 	pnc_yn pnc_who_trained
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}
	
	
	foreach v in `outcome' {
		
		svy: logit `v' KDHW stratum org_name_num 
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/17_mom_pnc_all_table.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace

	foreach v in `outcome' {
		
		svy: logit `v' KDHW i.org_name_num##stratum  
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/17_mom_pnc_all_table_m2.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	svy: tab hh_mem_dob_str pnc_yn, row 
	svy: tab hh_mem_dob_str pnc_who_trained, row 
	
	svy: reg pnc_yn wempo_index 
	svy: reg pnc_who_trained wempo_index 

	
	****************************************************************************
	** Mom NBC **
	****************************************************************************
	// nbc_yn 
	svy: mean  nbc_yn
	svy: tab stratum_num nbc_yn, row 
	svy: tab NationalQuintile nbc_yn, row
	svy: tab child_dob_season_yr nbc_yn if child_dob_year < 2023, row
	svy: tab wealth_quintile_ns nbc_yn, row
	
	svy: reg nbc_yn hfc_near_dist_dry 
	svy: reg nbc_yn hfc_near_dist_rain 	
	
	// nbc_2days_yn
	svy: mean  nbc_2days_yn
	svy: tab stratum_num nbc_2days_yn, row 
	svy: tab NationalQuintile nbc_2days_yn, row
	svy: tab child_dob_season_yr nbc_2days_yn if child_dob_year < 2023, row
	svy: tab wealth_quintile_ns nbc_2days_yn, row

	svy: reg nbc_2days_yn hfc_near_dist_dry 
	svy: reg nbc_2days_yn hfc_near_dist_rain 	
	
	// nbc_where
	svy: tab nbc_where,ci
	svy: tab stratum_num nbc_where, row 
	svy: tab NationalQuintile nbc_where, row 
	svy: tab NationalQuintile_recod nbc_where, row 
	svy: tab wealth_quintile_ns nbc_where, row 
	
	
	// nbc_*_who
	// nbc_who_1 nbc_who_2 nbc_who_3 nbc_who_4 nbc_who_5 nbc_who_6 nbc_who_7 nbc_who_8 nbc_who_9 nbc_who_10 nbc_who_11 nbc_who_888
	
	svy: mean 	nbc_who_1 nbc_who_2 nbc_who_3 nbc_who_4 nbc_who_5 nbc_who_6 ///
				nbc_who_7 nbc_who_8 nbc_who_9 nbc_who_10 nbc_who_11 nbc_who_888
	
	svy: mean 	nbc_who_1 nbc_who_2 nbc_who_3 nbc_who_4 nbc_who_5 nbc_who_6 ///
				nbc_who_7 nbc_who_8 nbc_who_9 nbc_who_10 nbc_who_11 nbc_who_888, ///
				over(stratum_num)
	
	foreach var of varlist 	nbc_who_1 nbc_who_2 nbc_who_3 nbc_who_4 nbc_who_5 ///
							nbc_who_6 nbc_who_7 nbc_who_8 nbc_who_9 nbc_who_10 ///
							nbc_who_11 nbc_who_888 {
		
		svy: tab stratum_num `var', row 
	}
	
	svy: mean 	nbc_who_1 nbc_who_2 nbc_who_3 nbc_who_4 nbc_who_5 nbc_who_6 ///
				nbc_who_7 nbc_who_8 nbc_who_9 nbc_who_10 nbc_who_11 nbc_who_888, ///
				over(NationalQuintile)
	
	foreach var of varlist 	nbc_who_1 nbc_who_2 nbc_who_3 nbc_who_4 nbc_who_5 ///
							nbc_who_6 nbc_who_7 nbc_who_8 nbc_who_9 nbc_who_10 ///
							nbc_who_11 nbc_who_888 {
		
		svy: tab NationalQuintile `var', row 
	}
	
	
	foreach var of varlist 	nbc_who_1 nbc_who_2 nbc_who_3 nbc_who_4 nbc_who_5 ///
							nbc_who_6 nbc_who_7 nbc_who_8 nbc_who_9 nbc_who_10 ///
							nbc_who_11 nbc_who_888 {
		
		svy: tab NationalQuintile_recod `var', row 
	}	
	
	
	foreach var of varlist 	nbc_who_1 nbc_who_2 nbc_who_3 nbc_who_4 nbc_who_5 ///
							nbc_who_6 nbc_who_7 nbc_who_8 nbc_who_9 nbc_who_10 ///
							nbc_who_11 nbc_who_888 {
		
		svy: tab wealth_quintile_ns `var', row 
	}	
		
	
	// nbc_who_trained
	svy: mean  nbc_who_trained
	svy: tab stratum_num nbc_who_trained, row 
	svy: tab NationalQuintile nbc_who_trained, row
	svy: tab child_dob_season_yr nbc_who_trained if child_dob_year < 2023, row
	svy: tab wealth_quintile_ns nbc_who_trained, row

	svy: reg nbc_who_trained hfc_near_dist_dry 
	svy: reg nbc_who_trained hfc_near_dist_rain 	
	
	svy: tab hhitems_phone nbc_yn, row 
	svy: tab prgexpo_pn nbc_yn, row 	
	svy: tab edu_exposure nbc_yn, row 
	
	svy: tab hhitems_phone nbc_2days_yn, row 
	svy: tab prgexpo_pn nbc_2days_yn, row 	
	svy: tab edu_exposure nbc_2days_yn, row 
	
	svy: tab hhitems_phone nbc_who_trained, row 
	svy: tab prgexpo_pn nbc_who_trained, row 	
	svy: tab edu_exposure nbc_who_trained, row 
	
	
	local outcome 	nbc_yn nbc_2days_yn nbc_who_trained
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}
	
	
	
	foreach v in `outcome' {
		
		svy: logit `v' KDHW stratum org_name_num 
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/18_mom_nbc_all_table.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	foreach v in `outcome' {
		
		svy: logit `v' KDHW i.org_name_num##stratum  
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/18_mom_nbc_all_table_m2.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	svy: tab hh_mem_dob_str nbc_yn, row 
	svy: tab hh_mem_dob_str nbc_2days_yn, row 
	svy: tab hh_mem_dob_str nbc_who_trained, row 
	
	svy: reg nbc_yn wempo_index 
	svy: reg nbc_2days_yn wempo_index 
	svy: reg nbc_who_trained wempo_index 
	
	
	** ALL MOM HEALTH **
	
	local outcome	anc_yn anc_who_trained anc_visit_trained anc_visit_trained_4times ////
					insti_birth skilled_battend ///
					pnc_yn pnc_who_trained ///
					nbc_yn nbc_2days_yn nbc_who_trained 
	   	
	foreach v in `outcome' {
		
		svy: reg `v' wempo_index NationalQuintile stratum NationalQuintile_stratum i.org_name_num
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/18_mom_healthseeking_all_FINAL.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	// Model 4
	local outcome	anc_visit_trained
	
	foreach v in `outcome' {
		
		svy: reg `v' i.NationalQuintile i.org_name_num i.NationalQuintile##stratum wempo_index
		//eststo model_B
		estimates store `v', title(`v')
		
	}
		
		estout `outcome' using "$out/reg_output/FINAL_MomHealth_Model_4.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
		   legend label varlabels(_cons constant)              ///
		   stats(r2 df_r bic) replace	

	foreach v in `outcome' {
		
		svy: reg `v' i.wealth_quintile_ns i.org_name_num i.wealth_quintile_ns##stratum wempo_index
		//eststo model_B
		estimates store `v', title(`v')
		
	}
		
		estout `outcome' using "$out/reg_output/FINAL_MomHealth_Model_4_PNDist.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
		   legend label varlabels(_cons constant)              ///
		   stats(r2 df_r bic) replace
		   
	local outcome	anc_yn anc_who_trained anc_visit_trained_4times ////
					insti_birth skilled_battend ///
					pnc_yn pnc_who_trained ///
					nbc_yn nbc_2days_yn nbc_who_trained 
	
	foreach v in `outcome' {
		
		svy: logit `v' i.NationalQuintile i.org_name_num i.NationalQuintile##stratum wempo_index
		//eststo model_B
		estimates store `v', title(`v')
		
	}
		
		estout `outcome' using "$out/reg_output/FINAL_MomHealth_Model_4_logistic.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
		   legend label varlabels(_cons constant)              ///
		   stats(r2 df_r bic) replace	
	
	foreach v in `outcome' {
		
		svy: logit `v' i.wealth_quintile_ns i.org_name_num i.wealth_quintile_ns##stratum wempo_index
		//eststo model_B
		estimates store `v', title(`v')
		
	}
		
		estout `outcome' using "$out/reg_output/FINAL_MomHealth_Model_4_logistic_PNDist.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
		   legend label varlabels(_cons constant)              ///
		   stats(r2 df_r bic) replace		
	
	
	
	****************************************************************************
	** PHQ9 **
	****************************************************************************
	
	use "$dta/pnourish_PHQ9_final.dta", clear  

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)
	
	svy: tab phq9_cat, ci 
	svy: tab stratum_num phq9_cat, row 
	svy: tab NationalQuintile phq9_cat, row

	svy: tab hhitems_phone phq9_cat, row 
	svy: tab prgexpo_pn phq9_cat, row 	
	svy: tab edu_exposure phq9_cat, row 
	
	****************************************************************************
	** Women Empowerment **
	****************************************************************************
	
	use "$dta/pnourish_WOMEN_EMPOWER_final.dta", clear  

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)


	// 1) Own health care.
	// women_ownhealth
	svy: mean  women_ownhealth
	svy: tab stratum_num women_ownhealth, row 
	svy: tab NationalQuintile women_ownhealth, row
	

	// 2) Large household purchases.
	// women_hhpurchase
	svy: mean  women_hhpurchase
	svy: tab stratum_num women_hhpurchase, row 
	svy: tab NationalQuintile women_hhpurchase, row
	
	// 3) Visits to family or relatives.
	tab women_visit, m 
	svy: mean  women_visit
	svy: tab stratum_num women_visit, row 
	svy: tab NationalQuintile women_visit, row
	
/*	foreach var of varlist 	wempo_childcare wempo_mom_health wempo_child_health ///
							wempo_women_wages wempo_major_purchase wempo_visiting ///
							wempo_women_health wempo_child_wellbeing {
								
		gen `var'_d = (`var' ==  1)
		replace `var'_d = .m if mi(`var')
		drop `var'
		rename `var'_d `var'
		tab `var', m 
							}*/

							
	svy: mean 	wempo_childcare wempo_mom_health wempo_child_health ///
				wempo_women_wages wempo_major_purchase wempo_visiting ///
				wempo_women_health wempo_child_wellbeing
				
	foreach var of varlist 	wempo_childcare wempo_mom_health wempo_child_health ///
							wempo_women_wages wempo_major_purchase wempo_visiting ///
							wempo_women_health wempo_child_wellbeing {
								
		svy: tab stratum_num `var', row 
		
							}
							
	svy: mean 	wempo_childcare wempo_mom_health wempo_child_health ///
				wempo_women_wages wempo_major_purchase wempo_visiting ///
				wempo_women_health wempo_child_wellbeing, ///
				over(stratum_num)	
	
	foreach var of varlist 	wempo_childcare wempo_mom_health wempo_child_health ///
							wempo_women_wages wempo_major_purchase wempo_visiting ///
							wempo_women_health wempo_child_wellbeing {
								
		svy: tab NationalQuintile `var', row 
		
							}
							
	svy: mean 	wempo_childcare wempo_mom_health wempo_child_health ///
				wempo_women_wages wempo_major_purchase wempo_visiting ///
				wempo_women_health wempo_child_wellbeing, ///
				over(NationalQuintile)	
				
	// women group 
	svy: mean 	wempo_group1 wempo_group2 wempo_group3 wempo_group4 wempo_group5 wempo_group888
	
	
	// wempo_childcare 
	svy: tab hhitems_phone wempo_childcare, row 
	svy: tab prgexpo_pn wempo_childcare, row 	
	svy: tab edu_exposure wempo_childcare, row 

	// wempo_mom_health 
	svy: tab hhitems_phone wempo_mom_health, row 
	svy: tab prgexpo_pn wempo_mom_health, row 	
	svy: tab edu_exposure wempo_mom_health, row 
	
	// wempo_child_health 
	svy: tab hhitems_phone wempo_child_health, row 
	svy: tab prgexpo_pn wempo_child_health, row 	
	svy: tab edu_exposure wempo_child_health, row 
		
	// wempo_women_wages 
	svy: tab hhitems_phone wempo_women_wages, row 
	svy: tab prgexpo_pn wempo_women_wages, row 	
	svy: tab edu_exposure wempo_women_wages, row 
	
	// wempo_major_purchase 
	svy: tab hhitems_phone wempo_major_purchase, row 
	svy: tab prgexpo_pn wempo_major_purchase, row 	
	svy: tab edu_exposure wempo_major_purchase, row 
	
	// wempo_visiting 
	svy: tab hhitems_phone wempo_visiting, row 
	svy: tab prgexpo_pn wempo_visiting, row 	
	svy: tab edu_exposure wempo_visiting, row 
							
	// wempo_women_health 
	svy: tab hhitems_phone wempo_women_health, row 
	svy: tab prgexpo_pn wempo_women_health, row 	
	svy: tab edu_exposure wempo_women_health, row 
	
	// wempo_child_wellbeing
	svy: tab hhitems_phone wempo_child_wellbeing, row 
	svy: tab prgexpo_pn wempo_child_wellbeing, row 	
	svy: tab edu_exposure wempo_child_wellbeing, row 
	
	// wempo_index - Women Empowerment Index - ICW - Index 
	svy: mean wempo_index, over(NationalQuintile)	
	svy: mean wempo_index, over(stratum_num)
	
	svy: mean wempo_index, over(hhitems_phone)
	svy: mean wempo_index, over(prgexpo_pn)
	svy: mean wempo_index, over(edu_exposure)
	
	svy: reg wempo_grp_tot wempo_index 

	
	* Women empowerment by stratum 
	svy: mean wempo_index, over(stratum_num)
	test _b[c.wempo_index@1bn.stratum_num] = _b[c.wempo_index@2bn.stratum_num] = _b[c.wempo_index@3bn.stratum_num] = _b[c.wempo_index@4bn.stratum_num] = _b[c.wempo_index@5bn.stratum_num]

	
	* Women empowerment by wealth quintile - national cut-off 
	svy: mean wempo_index, over(NationalQuintile)
	test _b[c.wempo_index@1bn.NationalQuintile] = _b[c.wempo_index@2bn.NationalQuintile] = _b[c.wempo_index@3bn.NationalQuintile] = _b[c.wempo_index@4bn.NationalQuintile] = _b[c.wempo_index@5bn.NationalQuintile]
	
	* Women empowerment by wealth quintile - project nourish cut-off  
	svy: mean wempo_index, over(wealth_quintile_ns)
	test _b[c.wempo_index@1bn.wealth_quintile_ns] = _b[c.wempo_index@2bn.wealth_quintile_ns] = _b[c.wempo_index@3bn.wealth_quintile_ns] = _b[c.wempo_index@4bn.wealth_quintile_ns] = _b[c.wempo_index@5bn.wealth_quintile_ns]

	
// END HERE 



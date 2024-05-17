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

	
	
	* treated other and monestic education as missing
	gen resp_highedu_ci = resp_highedu
	replace resp_highedu_ci = .m if resp_highedu_ci > 7 
	tab resp_highedu_ci, m 
	
	replace resp_highedu = .m if resp_highedu > 7 
	replace resp_highedu = 4 if resp_highedu > 4 & !mi(resp_highedu)
	tab resp_highedu, m 
	
	
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	* generate the interaction variable - stratum Vs quantile 
	gen NationalQuintile_stratum  =   NationalQuintile*stratum 
	
	
	// stratum_num
	svy: tab stratum mddw_yes, row
	svy: mean mddw_score, over(stratum)
	
	// mom_meal_freq
	svy: mean mom_meal_freq

	svy: mean mom_meal_freq, over(stratum_num)
	svy: reg mom_meal_freq i.stratum_num
	
	svy: mean mom_meal_freq, over(NationalQuintile)
	svy: reg mom_meal_freq i.NationalQuintile

	svy: mean mom_meal_freq, over(wealth_quintile_ns)

	svy: mean mom_meal_freq, over(wealth_quintile_modify)
	
	
	
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
	svy: mean mddw_score, over(wealth_quintile_modify)
	
	svy: reg mddw_score wempo_index 
	
	svy: reg mom_meal_freq wempo_index 

	
	
	// mddw_yes
	svy: mean  mddw_yes
	svy: tab stratum_num mddw_yes, row 
	svy: tab NationalQuintile mddw_yes, row
	svy: tab wealth_quintile_ns mddw_yes, row
	svy: tab wealth_quintile_modify mddw_yes, row
	
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
	* Concentration Index - relative 
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		di "`v'"
			if "`v'" == "mddw_score" {
			    conindex `v', rank(`var') svy wagstaff bounded limits(1 10)
				
			}
			else {
			    conindex `v', rank(`var') svy wagstaff bounded limits(1 8)
			}
			
		}
	
	}	
	
	* Concentration Index - absolute
 	local outcome mddw_score mom_meal_freq
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile /*income_lastmonth hh_mem_highedu_all*/ {
		
			di "`v'"	
			conindex `v', rank(`var') svy truezero generalized
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
	
	* Concentration Index - relative 
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}
	
	
	* Concentration Index - absolute
 	local outcome mddw_yes
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile /*income_lastmonth hh_mem_highedu_all*/ {
		
			di "`v'"	
			conindex `v', rank(`var') svy truezero generalized
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
		
		svy: reg `v' i.NationalQuintile i.org_name_num i.NationalQuintile stratum wempo_index
		//eststo model_B
		estimates store `v', title(`v')
		
	}
		
		estout `outcome' using "$out/reg_output/FINAL_MomDiet_Model_4.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
		   legend label varlabels(_cons constant)              ///
		   stats(r2 df_r bic) replace	
		   
	foreach v in `outcome' {
		
		svy: reg `v' i.wealth_quintile_ns i.org_name_num i.wealth_quintile_ns stratum wempo_index
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
		
		svy: logit `v' i.NationalQuintile i.org_name_num i.NationalQuintile stratum wempo_index
		//eststo model_B
		estimates store `v', title(`v')
		
	}
		
		estout `outcome' using "$out/reg_output/FINAL_MomDiet_Model_4_logistic.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
		   legend label varlabels(_cons constant)              ///
		   stats(r2 df_r bic) replace	
		   
		   
	foreach v in `outcome' {
		
		svy: logit `v' i.wealth_quintile_ns i.org_name_num i.wealth_quintile_ns stratum wempo_index
		//eststo model_B
		estimates store `v', title(`v')
		
	}
		
		estout `outcome' using "$out/reg_output/FINAL_MomDiet_Model_4_logistic_PNDist.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
		   legend label varlabels(_cons constant)              ///
		   stats(r2 df_r bic) replace		
	
	

	
	// FINAL TABLEs
	local outcomes	mddw_score mom_meal_freq 
	
	foreach outcome in `outcomes' {
	 
		local regressor  resp_highedu org_name_num stratum NationalQuintile wempo_index progressivenss wempo_category mkt_distance hfc_distance
		
		foreach v in `regressor' {
			
			putexcel set "$out/reg_output/MDDW_`outcome'_logistic_models.xls", sheet("`v'") modify 
		
			if "`v'" != "income_lastmonth" & "`v'" != "wempo_index" {
				svy: reg `outcome' i.`v'
			}
			else {
				svy: reg `outcome' `v'
			}
			
			estimates store `v', title(`v')
			
			putexcel (A1) = etable
			
		}
			
	}
	

	local outcomes	mddw_score mom_meal_freq 
	
	foreach outcome in `outcomes' {
	 
			
		putexcel set "$out/reg_output/MDDW_`outcome'_logistic_models.xls", sheet("Final_model") modify 
		
		svy: reg `outcome' i.resp_highedu i.NationalQuintile i.wempo_category i.hfc_distance /*i.org_name_num*/ stratum 
	
		putexcel (A1) = etable
			
	}
	
	
	// mddw_yes
	local regressor  resp_highedu org_name_num stratum NationalQuintile wempo_index progressivenss wempo_category mkt_distance hfc_distance
	
	foreach v in `regressor' {
		
		putexcel set "$out/reg_output/MDDW_mddw_yes_logistic_models.xls", sheet("`v'") modify 
	
		if "`v'" != "wempo_index" {
		    svy: logistic mddw_yes i.`v'
		}
		else {
		    svy: logistic mddw_yes `v'
		}
		
		estimates store `v', title(`v')
		
		putexcel (A1) = etable
		
	}
	
	putexcel set "$out/reg_output/MDDW_mddw_yes_logistic_models.xls", sheet("Final_model") modify 
	
	svy: logistic mddw_yes /*i.resp_highedu*/ i.NationalQuintile i.wempo_category i.hfc_distance /*i.org_name_num*/ stratum 
	
	putexcel (A1) = etable
	
	
	svy: tab progressivenss mddw_yes , row 
	svy: mean mddw_score , over(progressivenss) 
	
	svy: tab resp_highedu mddw_yes , row 
	svy: mean mddw_score , over(resp_highedu) 
	
	svy: tab org_name_num mddw_yes , row 
	svy: mean mddw_score , over(org_name_num) 
	
	
	// mddw_yes 
	conindex mddw_yes, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 mddw_yes, rank(NationalScore) ///
						covars(/*i.resp_highedu*/ i.wempo_category i.hfc_distance /*i.org_name_num*/ stratum) svy wagstaff bounded limits(0 1)
	
	conindex mddw_yes, rank(resp_highedu_ci) svy wagstaff bounded limits(0 1)
	conindex2 mddw_yes, rank(resp_highedu_ci) ///
						covars(NationalScore i.wempo_category i.hfc_distance /*i.org_name_num*/ stratum) svy wagstaff bounded limits(0 1)	

	conindex mddw_yes, rank(wempo_index) svy wagstaff bounded limits(0 1)
	conindex2 mddw_yes, rank(wempo_index) ///
						covars(NationalScore /*i.resp_highedu*/ i.hfc_distance /*i.org_name_num*/ stratum) svy wagstaff bounded limits(0 1)	

	// Food Groups 
	conindex mddw_score, rank(NationalScore) svy truezero generalized
	conindex2 mddw_score, rank(NationalScore) ///
							covars(i.resp_highedu i.wempo_category i.hfc_distance /*i.org_name_num*/ stratum) svy truezero generalized

	conindex mddw_score, rank(NationalScore) svy wagstaff bounded limits(0 10)
	conindex2 mddw_score, rank(NationalScore) ///
							covars(i.resp_highedu i.wempo_category i.hfc_distance /*i.org_name_num*/ stratum) svy wagstaff bounded limits(0 10)

							
	conindex mddw_score, rank(resp_highedu_ci) svy truezero generalized
	conindex2 mddw_score, rank(resp_highedu_ci) ///
							covars(NationalScore i.wempo_category i.hfc_distance /*i.org_name_num*/ stratum) svy truezero generalized	
	
	conindex mddw_score, rank(resp_highedu_ci) svy wagstaff bounded limits(0 10)
	conindex2 mddw_score, rank(resp_highedu_ci) ///
							covars(NationalScore i.wempo_category i.hfc_distance /*i.org_name_num*/ stratum) svy wagstaff bounded limits(0 10)

							
	conindex mddw_score, rank(wempo_index) svy truezero generalized
	conindex2 mddw_score, rank(wempo_index) ///
							covars(NationalScore i.resp_highedu i.hfc_distance /*i.org_name_num*/ stratum) svy truezero generalized	
	
	conindex mddw_score, rank(wempo_index) svy wagstaff bounded limits(0 10)
	conindex2 mddw_score, rank(wempo_index) ///
							covars(NationalScore i.resp_highedu i.hfc_distance /*i.org_name_num*/ stratum) svy wagstaff bounded limits(0 10)
	
				

	svy: tab wempo_category mddw_yes , row 
	svy: mean mddw_score , over(wempo_category) 
	
	svy: tab hfc_distance mddw_yes , row 
	svy: mean mddw_score , over(hfc_distance) 
 
	svy: tab mkt_distance mddw_yes , row 
	svy: mean mddw_score , over(mkt_distance) 
	
	* plots for publication 
    global graph_opts1 ///
           bgcolor(white) ///
           graphregion(color(white)) ///
           legend(region(lc(none) fc(none))) ///
           ylab(,angle(0) nogrid) ///
           title(, justification(left) color(black) span pos(11)) ///
           subtitle(, justification(left) color(black))
		 
    global  graph_opts ///
            title(, justification(left) ///
            color(black) span pos(11)) ///
            graphregion(color(white)) ///
            ylab(,angle(0) nogrid) ///
            xtit(,placement(left) justification(left)) ///
            yscale(noline) xscale(noline) ///
            legend(region(lc(none) fc(none)))

	lab def resp_highedu 1"Illiterate" 2"Primary" 3"Secondary" 4"Higher"
	lab val resp_highedu resp_highedu
	
	// mddw_yes
	global  pct `" 0 "0%" .2 "20%" .4 "40%" .6 "60%" .8 "80%" "'
	/*
	gen mddw_yes_pct = mddw_yes * 100
	
	graph bar 	mddw_yes_pct [aweight = weight_final], over(NationalQuintile) ///
				${graph_opts1} ///
				blabel(bar, format(%9.1f)) ///
				ytitle("% of Mothers", size(small) height(-6))								///
				title("Proportion of Mothers Met Minimum Dietary Diversity" "(by Wealth Quintile)", 		///
						justification(left) color(black) span pos(11) size(medium)) 							///
				plotregion(fcolor(white)) 														///
				graphregion(fcolor(white)) ///
				note(	"", size(vsmall) span)
				
	graph export "$plots/PN_Paper_Child_Nutrition/06_MDDW_by_Wealth.png", replace
	*/
	svy: logistic mddw_yes i.NationalQuintile 
	margins , over(NationalQuintile)
	marginsplot, ///
		recast(scatter) /// 
		${graph_opts1} ///
		ylab(${pct}, labsize(small)) ///
		xlabel(, format(%13.0fc) labsize(small) angle(45)) ///
		xtitle("") ///
		ytitle("% of Mothers", size(small) height(-6)) ///
		title("Marginal Effect of Wealth Quintile", 		///
				justification(left) color(black) span pos(11) size(small)) 							///
		plotregion(fcolor(white)) 														///
		graphregion(fcolor(white)) ///
		legend(off) /// //legend(r(1) symxsize(vsmall) symysize(vsmall) position(6) size(small))
		name(MDDW_WQ, replace)
			
	lowess 	mddw_yes NationalScore, ///
			adjust ///
			lcolor(red) lwidth(medium) ///
			${graph_opts1} ///
			mcolor(gs16) ///
			ylabel(0.0 "0.0" 0.2 "0.2" 0.3680996 "Mean = 0.37" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0", format(%13.1fc) labsize(small)) ///
			xlabel(, format(%13.1fc) labsize(small)) ///
			ytitle("Minimum Dietary Diversity for Women", size(small) height(-6)) ///
			t1title("", size(small)) ///
			subtitle("", size(small)) ///
			xtitle("Wealth Quintile National Scores", size(small)) ///
			title("LOWESS Smoothing: Mean adjusted smooth", 		///
				justification(left) color(black) span pos(11) size(small)) 							///
			plotregion(fcolor(white)) 														///
			graphregion(fcolor(white)) ///
			legend(off) ///
			yline( .3680996, lcolor(navy) lpattern(dash)) ///
			name(MDDW_LW_MEAN_WQ, replace)

	lowess 	mddw_yes NationalScore, ///
			logit ///
			lcolor(red) lwidth(medium) ///
			${graph_opts1} ///
			ylabel(-2 "-2" -1 "-1" 0 "0" 0.3680996 "Mean = 0.37" 1 "1" 2 "2", format(%13.1fc) labsize(small)) ///
			xlabel(, format(%13.1fc) labsize(small)) ///
			ytitle("", size(small) height(-6)) ///
			t1title("", size(small)) ///
			subtitle("", size(small)) ///
			xtitle("Wealth Quintile National Scores", size(small)) ///
			title("LOWESS Smoothing: Logit transformed smooth", 		///
				justification(left) color(black) span pos(11) size(small)) 							///
			plotregion(fcolor(white)) 														///
			graphregion(fcolor(white)) ///
			legend(off) ///
			yline( .3680996, lcolor(navy) lpattern(dash)) ///
			name(MDDW_LW_LOGIT_WQ, replace)
			
	graph 	combine MDDW_LW_MEAN_WQ MDDW_LW_LOGIT_WQ, cols(2) ///
			graphregion(color(white)) plotregion(color(white)) ///
			title("Minimum Dietary Diversity for Women Across the Wealth Spectrum" "U2 Mothers", ///
			justification(left) color(black) span pos(11) size(small)) ///
			note(	"Note:" ///
					" " 	///
					"Minimum Dietary Diversity for Women: 1 = Met MDD-W, 0 = Not Met"	///
					"Wealth Quintile National Scores: EquityTool for Myanmar DHS 2015", size(vsmall) span)

	graph export "$plots/PN_Paper_Child_Nutrition/06_MDDW_WealthQ_Lowess_Compare.png", replace
	
			
	/*
	graph bar 	mddw_yes_pct [aweight = weight_final], over(resp_highedu) ///
				${graph_opts1} ///
				blabel(bar, format(%9.1f)) ///
				ytitle("% of Mothers", size(small) height(-6))								///
				title("Proportion of Mothers Met Minimum Dietary Diversity" "(by Respondent's Education)", 		///
						justification(left) color(black) span pos(11) size(medium)) 							///
				plotregion(fcolor(white)) 														///
				graphregion(fcolor(white)) ///
				note(	"", size(vsmall) span)
				
	graph export "$plots/PN_Paper_Child_Nutrition/06_MDDW_by_Edu.png", replace
	*/

	svy: logistic mddw_yes i.resp_highedu 
	margins , over(resp_highedu)
	marginsplot, ///
		recast(scatter) /// 
		${graph_opts1} ///
		ylab(${pct}, labsize(small)) ///
		xlabel(, format(%13.0fc) labsize(small) angle(45)) ///
		xtitle("") ///
		ytitle("", size(small) height(-6)) ///
		title("Marginal Effect of Respondent's Education", 		///
				justification(left) color(black) span pos(11) size(small)) 							///
		plotregion(fcolor(white)) 														///
		graphregion(fcolor(white)) ///
		legend(off) /// //legend(r(1) symxsize(vsmall) symysize(vsmall) position(6) size(small))
	name(MDDW_EDU, replace)
	
	
	/*
	graph bar 	mddw_yes_pct [aweight = weight_final], over(wempo_category) ///
				${graph_opts1} ///
				blabel(bar, format(%9.1f)) ///
				ytitle("% of Mothers", size(small) height(-6))								///
				title("Proportion of Mothers Met Minimum Dietary Diversity" "(by Women Empowerment)", 		///
						justification(left) color(black) span pos(11) size(medium)) 							///
				plotregion(fcolor(white)) 														///
				graphregion(fcolor(white)) ///
				note(	"", size(vsmall) span)
				
	graph export "$plots/PN_Paper_Child_Nutrition/06_MDDW_by_WomenEmpowerment.png", replace
	*/

	svy: logistic mddw_yes i.wempo_category 
	margins , over(wempo_category)
	marginsplot, ///
		recast(scatter) /// 
		${graph_opts1} ///
		ylab(${pct}, labsize(small)) ///
		xlabel(, format(%13.0fc) labsize(small) angle(45)) ///
		xtitle("") ///
		ytitle("", size(small) height(-6)) ///
		title("Marginal Effect of Women Empowerment", 		///
				justification(left) color(black) span pos(11) size(small)) 							///
		plotregion(fcolor(white)) 														///
		graphregion(fcolor(white)) ///
		legend(off) /// //legend(r(1) symxsize(vsmall) symysize(vsmall) position(6) size(small))
	name(MDDW_WE, replace)  
			
	lowess 	mddw_yes wempo_index, ///
			adjust ///
			lcolor(red) lwidth(medium) ///
			${graph_opts1} ///
			ylabel(0.0 "0.0" 0.2 "0.2" 0.3680996 "Mean = 0.37" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0", format(%13.1fc) labsize(small)) ///
			xlabel(, format(%13.1fc) labsize(small)) ///
			ytitle("", size(small) height(-6)) ///
			xtitle("Women Empowerment Index (ICW-index)" "< 0: less empower, = 0: neutral, > 0: more empower", size(small)) ///
			title("Across the Women Empowerment Spectrum (LOWESS Smoothing)", 		///
				justification(left) color(black) span pos(11) size(small)) 							///
			plotregion(fcolor(white)) 														///
			graphregion(fcolor(white)) ///
			legend(off) ///
			yline( .3680996, lcolor(navy) lpattern(dash)) ///
			name(MDDW_LW_WE, replace)

	lowess 	mddw_yes wempo_index, ///
			adjust ///
			lcolor(red) lwidth(medium) ///
			${graph_opts1} ///
			mcolor(gs16) ///
			ylabel(0.0 "0.0" 0.2 "0.2" 0.3680996 "Mean = 0.37" 0.4 "0.4" 0.6 "0.6" 0.8 "0.8" 1.0 "1.0", format(%13.1fc) labsize(small)) ///
			xlabel(, format(%13.1fc) labsize(small)) ///
			ytitle("Minimum Dietary Diversity for Women", size(small) height(-6)) ///
			t1title("", size(small)) ///
			subtitle("", size(small)) ///
			xtitle("Women Empowerment Index (ICW-index)", size(small)) ///
			title("LOWESS Smoothing: Mean adjusted smooth", 		///
				justification(left) color(black) span pos(11) size(small)) 							///
			plotregion(fcolor(white)) 														///
			graphregion(fcolor(white)) ///
			legend(off) ///
			yline( .3680996, lcolor(navy) lpattern(dash)) ///
			name(MDDW_LW_MEAN_WE, replace)

	lowess 	mddw_yes wempo_index, ///
			logit ///
			lcolor(red) lwidth(medium) ///
			${graph_opts1} ///
			ylabel(-1 "-1" -0.5 "-0.5" 0 "0" 0.3680996 "Mean = 0.37" 0.5 "0.5" 1 "1", format(%13.1fc) labsize(small)) ///
			xlabel(, format(%13.1fc) labsize(small)) ///
			ytitle("", size(small) height(-6)) ///
			t1title("", size(small)) ///
			subtitle("", size(small)) ///
			xtitle("Women Empowerment Index (ICW-index)", size(small)) ///
			title("LOWESS Smoothing: Logit transformed smooth", 		///
				justification(left) color(black) span pos(11) size(small)) 							///
			plotregion(fcolor(white)) 														///
			graphregion(fcolor(white)) ///
			legend(off) ///
			yline( .3680996, lcolor(navy) lpattern(dash)) ///
			name(MDDW_LW_LOGIT_WE, replace)
			
	graph 	combine MDDW_LW_MEAN_WE MDDW_LW_LOGIT_WE, cols(2) ///
			graphregion(color(white)) plotregion(color(white)) ///
			title("Minimum Dietary Diversity for Women Across the Women Empowerment Spectrum" "U2 Mothers", ///
			justification(left) color(black) span pos(11) size(small)) ///
			note(	"Note:" ///
					" " 	///
					"Minimum Dietary Diversity for Women: 1 = Met MDD-W, 0 = Not Met"	///
					"Women Empowerment Index (ICW-index): < 0: less empower, = 0: neutral, > 0: more empower", size(vsmall) span)

	graph export "$plots/PN_Paper_Child_Nutrition/06_MDDW_WEmpower_Lowess_Compare.png", replace
	
	
	graph 	combine MDDW_WQ MDDW_EDU MDDW_WE, cols(3) ///
			graphregion(color(white)) plotregion(color(white)) ///
			title("Predicted Probability of Mothers Met Minimum Dietary Diversity", 								///
			justification(left) color(black) span pos(11) size(small)) ///
			note("Note"											///
				"Predictive margins with 95% CIs" ///
				" " ///
				"Education level by grade;"					///
				"Primary education (Under 5th standard)"	///
				"Secondary education (under 9th standard)"		///
				"Higher education (till pass matriculation exam)", size(vsmall) span)
	
	graph export "$plots/PN_Paper_Child_Nutrition/06_MDDW_Combined.png", replace	

	/*
	graph 	combine MDDW_LW_WQ MDDW_LW_WE, cols(2) ///
			graphregion(color(white)) plotregion(color(white)) ///
			title("Minimum Dietary Diversity for Women of U2 Mothers", ///
			justification(left) color(black) span pos(11) size(small)) 

	graph export "$plots/PN_Paper_Child_Nutrition/06_MDDW_Lowess_Combined.png", replace
	*/
	
	
	/*
	graph 	combine FIES_WQ FIES_EDU FIES_WE ///
					EBF_WQ EBF_EDU EBF_WE ///
					MDD_WQ MDD_EDU MDD_WE ///
					MDDW_WQ MDDW_EDU MDDW_WE, rows(4) cols(3) ///
			graphregion(color(white)) plotregion(color(white)) ///
			title("Proportion of Children Met Minimum Dietary Diversity", 								///
			justification(left) color(black) span pos(11) size(small)) ///
			note("Note"											///
				"Predictive margins with 95% CIs" ///
				" " ///
				"Education level by grade;"					///
				"Primary education (Under 5th standard)"	///
				"Secondary education (under 9th standard)"		///
				"Higher education (till pass matriculation exam)", size(vsmall) span)
	
	//graph export "$plots/PN_Paper_Child_Nutrition/06_MDDW_Combined.png", replace
	*/
	
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
	lab var anc_month_2s_season "Number of Gestation month by season (in 2 and 3 trimasters)"
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
	   
	   

	* additional table for ANC paper 
	// resp_highedu
	svy: tab resp_highedu anc_yn, row 
	svy: tab resp_highedu anc_who_trained, row 	
	svy: tab resp_highedu anc_visit_trained_4times, row 

	svy: mean anc_visit_trained, over(resp_highedu)
	svy: reg anc_visit_trained i.resp_highedu
	
	foreach var of varlist anc_who_1 anc_who_2 anc_who_3 anc_who_4 anc_who_5 anc_who_6 anc_who_7 anc_who_8 anc_who_9 anc_who_10 anc_who_11 anc_who_888 {
	   
	   svy: tab resp_highedu `var', row 
	   
	}
	
	// stratum
	svy: tab stratum anc_yn, row 
	svy: tab stratum anc_who_trained, row 	
	svy: tab stratum anc_visit_trained_4times, row 

	svy: mean anc_visit_trained, over(stratum)
	svy: reg anc_visit_trained i.stratum
	
	svy: tab stratum anc_where, row 
	svy: tab hfc_vill_yes anc_where, row 

	svy: mean hfc_near_dist, over(anc_where)
	svy: reg hfc_near_dist i.anc_where
	
	foreach var of varlist anc_who_1 anc_who_2 anc_who_3 anc_who_4 anc_who_5 anc_who_6 anc_who_7 anc_who_8 anc_who_9 anc_who_10 anc_who_11 anc_who_888 {
	   
	   svy: tab stratum `var', row 
	   
	}
	

	// hfc_vill_yes
	svy: tab hfc_vill_yes anc_yn, row 
	svy: tab hfc_vill_yes anc_who_trained, row 	
	svy: tab hfc_vill_yes anc_visit_trained_4times, row 

	svy: mean anc_visit_trained, over(hfc_vill_yes)
	svy: reg anc_visit_trained i.hfc_vill_yes

	svy: tab resp_highedu anc_where, row 

	foreach var of varlist anc_who_1 anc_who_2 anc_who_3 anc_who_4 anc_who_5 anc_who_6 anc_who_7 anc_who_8 anc_who_9 anc_who_10 anc_who_11 anc_who_888 {
	   
	   svy: tab hfc_vill_yes `var', row 
	   
	}	
	
	
	//hfc_vill_yes
	//hfc_near_dist
	
	
	// hfc_vill1 hfc_vill2 hfc_vill3 hfc_vill4 hfc_vill5 hfc_vill6 hfc_vill888
	
	// anc cope: anc_cope1 anc_cope2 anc_cope3 anc_cope4 anc_cope5 anc_cope6 anc_cope7 anc_cope8 anc_cope9 anc_cope10 anc_cope11 anc_cope12 anc_cope13 anc_cope14 anc_cope888
	svy: mean anc_cope1 anc_cope2 anc_cope3 anc_cope4 anc_cope5 anc_cope6 anc_cope7 anc_cope8 anc_cope9 anc_cope10 anc_cope11 anc_cope12 anc_cope13 anc_cope14 anc_cope888


	// anc no - why: anc_noreason1 anc_noreason2 anc_noreason3 anc_noreason4 anc_noreason5 anc_noreason6 anc_noreason7 anc_noreason8 anc_noreason9 anc_noreason10 anc_noreason11 anc_noreason12 anc_noreason13 anc_noreason888
	svy: mean anc_noreason1 anc_noreason2 anc_noreason3 anc_noreason4 anc_noreason5 anc_noreason6 anc_noreason7 anc_noreason8 anc_noreason9 anc_noreason10 anc_noreason11 anc_noreason12 anc_noreason13 anc_noreason888
	
	// Mom age
	svy: tab mom_age_grp, ci 
	
	svy: tab mom_age_grp anc_yn, row 
	svy: tab mom_age_grp anc_who_trained, row 	
	svy: tab mom_age_grp anc_visit_trained_4times, row 

	svy: mean anc_visit_trained, over(mom_age_grp)
	svy: reg anc_visit_trained i.mom_age_grp

	svy: tab mom_age_grp anc_yn, row 
	svy: tab mom_age_grp anc_yn, row 
	
	
	svy: tab mom_age_grp anc_where, row 
	
	foreach var of varlist anc_who_1 anc_who_2 anc_who_3 anc_who_4 anc_who_5 anc_who_6 anc_who_7 anc_who_8 anc_who_9 anc_who_10 anc_who_11 anc_who_888 {
	   
	   svy: tab mom_age_grp `var', row 
	   
	}
	
	**********************
	** FOR FINAL TABLES **
	**********************
	
	// anc_yn
	svy: tab anc_yn, ci 
	
	svy: tab resp_highedu anc_yn, row 
	svy: tab mom_age_grp anc_yn, row 
	svy: tab respd_chid_num_grp anc_yn, row 

	svy: mean anc_month_dry_2s , over(anc_yn) 
	svy: mean anc_month_wet_2s , over(anc_yn) 
	
	svy: tab hfc_vill_yes anc_yn, row 
	svy: mean hfc_near_dist , over(anc_yn) 
	svy: tab hfc_distance anc_yn, row 
	
	svy: tab wealth_quintile_ns anc_yn, row 
	svy: tab progressivenss anc_yn, row 
	svy: tab wempo_category anc_yn, row 
	

	svy: tab org_name_num anc_yn, row 
	svy: tab stratum anc_yn, row 

	// CI 
	conindex anc_yn, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 anc_yn, 	rank(NationalScore) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)
	
	// anc_who_trained
	svy: tab anc_who_trained, ci 
	
	svy: tab resp_highedu anc_who_trained, row 
	svy: tab mom_age_grp anc_who_trained, row 
	svy: tab respd_chid_num_grp anc_who_trained, row 

	svy: mean anc_month_dry_2s , over(anc_who_trained) 
	svy: mean anc_month_wet_2s , over(anc_who_trained) 
	
	svy: tab hfc_vill_yes anc_who_trained, row 
	svy: mean hfc_near_dist , over(anc_who_trained) 
	svy: tab hfc_distance anc_who_trained, row 
	
	svy: tab wealth_quintile_ns anc_who_trained, row 
	svy: tab progressivenss anc_who_trained, row 
	svy: tab wempo_category anc_who_trained, row 

	svy: tab org_name_num anc_who_trained, row 
	svy: tab stratum anc_who_trained, row 	
	
	conindex anc_who_trained, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 anc_who_trained, 	rank(NationalScore) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)
						
	// anc_visit_trained_4times
	svy: tab anc_visit_trained_4times, ci 
	
	svy: tab resp_highedu anc_visit_trained_4times, row 
	svy: tab mom_age_grp anc_visit_trained_4times, row 
	svy: tab respd_chid_num_grp anc_visit_trained_4times, row 

	svy: mean anc_month_dry_2s , over(anc_visit_trained_4times) 
	svy: mean anc_month_wet_2s , over(anc_visit_trained_4times) 
	
	svy: tab hfc_vill_yes anc_visit_trained_4times, row 
	svy: mean hfc_near_dist , over(anc_visit_trained_4times) 
	svy: tab hfc_distance anc_visit_trained_4times, row 
	
	svy: tab wealth_quintile_ns anc_visit_trained_4times, row 
	svy: tab progressivenss anc_visit_trained_4times, row 
	svy: tab wempo_category anc_visit_trained_4times, row 

	svy: tab org_name_num anc_visit_trained_4times, row 
	svy: tab stratum anc_visit_trained_4times, row 
	
	conindex anc_visit_trained_4times, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 anc_visit_trained_4times, 	rank(NationalScore) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)
						
	// Logistic regression 	
	local outcomes	anc_yn anc_who_trained anc_visit_trained_4times
	
	foreach outcome in `outcomes' {
	 
		local regressor  	resp_highedu mom_age_grp respd_chid_num_grp ///
							anc_month_dry_2s anc_month_wet_2s ///
							hfc_vill_yes hfc_distance ///
							wealth_quintile_ns wempo_category org_name_num stratum  
		
		foreach v in `regressor' {
			
			putexcel set "$out/reg_output/ANC_`outcome'_logistic_models.xls", sheet("`v'") modify 
		
			if "`v'" == "anc_month_dry_2s" | "`v'" == "anc_month_wet_2s" | "`v'" == "hfc_near_dist" {
				svy: glm `outcome' `v', family(binomial) link(log) nolog eform // svy: logistic 
			}
			else {
				svy: glm `outcome' i.`v', family(binomial) link(log) nolog eform // svy: logistic 
			}
			
			estimates store `v', title(`v')
			
			putexcel (A1) = etable
			
		}
			
	}
	

	local outcomes	anc_yn anc_who_trained anc_visit_trained_4times
	
	foreach outcome in `outcomes' {
	 
			
		putexcel set "$out/reg_output/ANC_`outcome'_logistic_models.xls", sheet("Final_model") modify 
		
		svy: glm 		`outcome' 	i.resp_highedu /// // svy: logistic 
									i.mom_age_grp ///
									i.respd_chid_num_grp ///
									hfc_vill_yes ///
									i.hfc_distance ///
									i.wealth_quintile_ns ///
									i.wempo_category ///
									i.org_name_num ///
									stratum, ///
									family(binomial) link(log) nolog eform
	
		putexcel (A1) = etable
			
	}
	
	** anc_yn
	// Education as rank
	conindex anc_yn, rank(resp_highedu_ci) svy wagstaff bounded limits(0 1)
	conindex2 anc_yn, 	rank(resp_highedu_ci) ///
						covars(	i.wealth_quintile_ns ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)
						
						
	// Women empowerment as rank 
	conindex anc_yn, rank(wempo_index) svy wagstaff bounded limits(0 1)
	conindex2 anc_yn, 	rank(wempo_index) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wealth_quintile_ns) ///
						svy wagstaff bounded limits(0 1)

						
	** anc_who_trained 
	// Education as rank
	conindex anc_who_trained, rank(resp_highedu_ci) svy wagstaff bounded limits(0 1)
	conindex2 anc_who_trained, 	rank(resp_highedu_ci) ///
						covars(	i.wealth_quintile_ns ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)
						
						
	// Women empowerment as rank 
	conindex anc_who_trained, rank(wempo_index) svy wagstaff bounded limits(0 1)
	conindex2 anc_who_trained, 	rank(wempo_index) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wealth_quintile_ns) ///
						svy wagstaff bounded limits(0 1)
	
	** anc_visit_trained_4times 
	// Education as rank
	conindex anc_visit_trained_4times, rank(resp_highedu_ci) svy wagstaff bounded limits(0 1)
	conindex2 anc_visit_trained_4times, 	rank(resp_highedu_ci) ///
						covars(	i.wealth_quintile_ns ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)
						
						
	// Women empowerment as rank 
	conindex anc_visit_trained_4times, rank(wempo_index) svy wagstaff bounded limits(0 1)
	conindex2 anc_visit_trained_4times, 	rank(wempo_index) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wealth_quintile_ns) ///
						svy wagstaff bounded limits(0 1)
						
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
	
	
	* additional table for ANC paper 
	// resp_highedu
	svy: tab resp_highedu insti_birth, row 
	svy: tab resp_highedu skilled_battend, row 	
	svy: tab resp_highedu deliv_place, row 
	svy: tab resp_highedu deliv_assist, row 
	
	
	// stratum
	svy: tab stratum insti_birth, row 
	svy: tab stratum skilled_battend, row 

	svy: tab stratum deliv_place, row 
	svy: tab stratum deliv_assist, row 

	
	// hfc_vill_yes
	svy: tab hfc_vill_yes deliv_place, row 
	svy: tab hfc_vill_yes deliv_assist, row 

	svy: tab hfc_vill_yes insti_birth, row 
	svy: tab hfc_vill_yes skilled_battend, row 
	
	// mom_age_grp
	svy: tab mom_age_grp deliv_place, row 
	svy: tab mom_age_grp deliv_assist, row 

	svy: tab mom_age_grp insti_birth, row 
	svy: tab mom_age_grp skilled_battend, row 
	
	
	svy: mean deliv_cope1 deliv_cope2 deliv_cope3 deliv_cope4 deliv_cope5 deliv_cope6 deliv_cope7 deliv_cope8 deliv_cope9 deliv_cope10 deliv_cope11 deliv_cope12 deliv_cope13 deliv_cope14 deliv_cope888
	
	
	// ANC vs Delivery 
	svy: tab anc_yn insti_birth , row 
	svy: tab anc_yn skilled_battend, row 

	svy: tab anc_who_trained insti_birth, row 	
	svy: tab anc_who_trained skilled_battend, row 	

	svy: tab anc_yn deliv_place , row 
	svy: tab anc_who_trained deliv_place, row 	
	
	**************************
	** FINAL MODEL TABLES **
	**************************
	// insti_birth
	svy: tab insti_birth, ci 
	
	svy: tab resp_highedu insti_birth, row 
	svy: tab mom_age_grp insti_birth, row 
	svy: tab respd_chid_num_grp insti_birth, row 

	svy: tab delivery_month_season insti_birth, row
	
	svy: tab hfc_vill_yes insti_birth, row 
	svy: mean hfc_near_dist , over(insti_birth) 
	svy: tab hfc_distance insti_birth, row 
	
	svy: tab wealth_quintile_ns insti_birth, row 
	svy: tab progressivenss insti_birth, row 
	svy: tab wempo_category insti_birth, row 

	svy: tab org_name_num insti_birth, row 
	svy: tab stratum insti_birth, row 
	
	conindex insti_birth, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 insti_birth, 	rank(NationalScore) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								i.delivery_month_season ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)

	// skilled_battend
	svy: tab skilled_battend, ci 
	
	svy: tab resp_highedu skilled_battend, row 
	svy: tab mom_age_grp skilled_battend, row 
	svy: tab respd_chid_num_grp skilled_battend, row 

	svy: tab delivery_month_season skilled_battend, row 
	
	svy: tab hfc_vill_yes skilled_battend, row 
	svy: mean hfc_near_dist , over(skilled_battend) 
	svy: tab hfc_distance skilled_battend, row 
	
	svy: tab wealth_quintile_ns skilled_battend, row 
	svy: tab progressivenss skilled_battend, row 
	svy: tab wempo_category skilled_battend, row 

	svy: tab org_name_num skilled_battend, row 
	svy: tab stratum skilled_battend, row 
	
	conindex skilled_battend, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 skilled_battend, 	rank(NationalScore) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								i.delivery_month_season ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)

						
	// Logistic regression 					
	local outcomes	insti_birth skilled_battend 
	
	foreach outcome in `outcomes' {
	 
		local regressor  	resp_highedu mom_age_grp respd_chid_num_grp ///
							delivery_month_season ///
							hfc_vill_yes hfc_distance ///
							wealth_quintile_ns wempo_category org_name_num stratum  
		
		foreach v in `regressor' {
			
			putexcel set "$out/reg_output/Delivery_`outcome'_logistic_models.xls", sheet("`v'") modify 
		
			if "`v'" == "hfc_near_dist" {
				svy: glm `outcome' `v', family(binomial) link(log) nolog eform // svy: logistic
			}
			else {
				svy: glm `outcome' i.`v', family(binomial) link(log) nolog eform // svy: logistic
			}
			
			estimates store `v', title(`v')
			
			putexcel (A1) = etable
			
		}
			
	}
	

	local outcomes	insti_birth skilled_battend 
	
	foreach outcome in `outcomes' {
	 
			
		putexcel set "$out/reg_output/Delivery_`outcome'_logistic_models.xls", sheet("Final_model") modify 
		
		svy: glm `outcome' 	i.resp_highedu /// // svy: logistic
							i.mom_age_grp ///
							i.respd_chid_num_grp ///
							i.delivery_month_season ///
							hfc_vill_yes ///
							i.hfc_distance ///
							i.wealth_quintile_ns ///
							i.wempo_category ///
							i.org_name_num ///
							stratum, ///
							family(binomial) link(log) nolog eform
		putexcel (A1) = etable
			
	}
	
	
	** insti_birth   
	// Education as rank
	conindex insti_birth, rank(resp_highedu_ci) svy wagstaff bounded limits(0 1)
	conindex2 insti_birth, 	rank(resp_highedu_ci) ///
						covars(	i.wealth_quintile_ns ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)
						
						
	// Women empowerment as rank 
	conindex insti_birth, rank(wempo_index) svy wagstaff bounded limits(0 1)
	conindex2 insti_birth, 	rank(wempo_index) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wealth_quintile_ns) ///
						svy wagstaff bounded limits(0 1)
						
	** skilled_battend  
	// Education as rank
	conindex skilled_battend, rank(resp_highedu_ci) svy wagstaff bounded limits(0 1)
	conindex2 skilled_battend, 	rank(resp_highedu_ci) ///
						covars(	i.wealth_quintile_ns ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)
						
						
	// Women empowerment as rank 
	conindex skilled_battend, rank(wempo_index) svy wagstaff bounded limits(0 1)
	conindex2 skilled_battend, 	rank(wempo_index) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wealth_quintile_ns) ///
						svy wagstaff bounded limits(0 1)
							
	****************************************************************************
	** Mom PNC **
	****************************************************************************
	
	* adjustment - make 0 for those who did not get ANC
	foreach var of varlist pnc_who_trained {
	    
	    tab `var', m 
		replace `var' = 0 if pnc_yn == 0
		tab `var', m 
	}
	
	
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

	**************************
	** FINAL MODEL TABLES **
	**************************
	
	// pnc_yn
	svy: tab pnc_yn, ci 
	
	svy: tab resp_highedu pnc_yn, row 
	svy: tab mom_age_grp pnc_yn, row 
	svy: tab respd_chid_num_grp pnc_yn, row 

	svy: tab delivery_month_season pnc_yn, row 
	
	svy: tab hfc_vill_yes pnc_yn, row 
	svy: mean hfc_near_dist , over(pnc_yn) 
	svy: tab hfc_distance pnc_yn, row 
	
	svy: tab wealth_quintile_ns pnc_yn, row 
	svy: tab progressivenss pnc_yn, row 
	svy: tab wempo_category pnc_yn, row 

	svy: tab org_name_num pnc_yn, row 
	svy: tab stratum pnc_yn, row 
	
	conindex pnc_yn, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 pnc_yn, 	rank(NationalScore) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								i.delivery_month_season ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)		
		
	// pnc_who_trained
	svy: tab pnc_who_trained, ci 
	
	svy: tab resp_highedu pnc_who_trained, row 
	svy: tab mom_age_grp pnc_who_trained, row 
	svy: tab respd_chid_num_grp pnc_who_trained, row 

	svy: tab delivery_month_season pnc_who_trained, row 
	
	svy: tab hfc_vill_yes pnc_who_trained, row 
	svy: mean hfc_near_dist , over(pnc_who_trained) 
	svy: tab hfc_distance pnc_who_trained, row 
	
	svy: tab wealth_quintile_ns pnc_who_trained, row 
	svy: tab progressivenss pnc_who_trained, row 
	svy: tab wempo_category pnc_who_trained, row 

	svy: tab org_name_num pnc_who_trained, row 
	svy: tab stratum pnc_who_trained, row 
	
	conindex pnc_who_trained, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 pnc_who_trained, 	rank(NationalScore) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								i.delivery_month_season ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)

	
	// Logistic regression 					
	local outcomes	pnc_yn pnc_who_trained 
	
	foreach outcome in `outcomes' {
	 
		local regressor  	resp_highedu mom_age_grp respd_chid_num_grp ///
							delivery_month_season ///
							hfc_vill_yes hfc_distance ///
							wealth_quintile_ns wempo_category org_name_num stratum  
		
		foreach v in `regressor' {
			
			putexcel set "$out/reg_output/PNC_`outcome'_logistic_models.xls", sheet("`v'") modify 
		
			if "`v'" == "hfc_near_dist" {
				svy: glm `outcome' `v', family(binomial) link(log) nolog eform // svy: logistic
			}
			else {
				svy: glm `outcome' i.`v', family(binomial) link(log) nolog eform // svy: logistic
			}
			
			estimates store `v', title(`v')
			
			putexcel (A1) = etable
			
		}
			
	}
	

	local outcomes	pnc_yn pnc_who_trained
	
	foreach outcome in `outcomes' {
	 
			
		putexcel set "$out/reg_output/PNC_`outcome'_logistic_models.xls", sheet("Final_model") modify 
		
		svy: glm `outcome' 	i.resp_highedu /// // svy: logistic
							i.mom_age_grp ///
							i.respd_chid_num_grp ///
							i.delivery_month_season ///
							hfc_vill_yes ///
							i.hfc_distance ///
							i.wealth_quintile_ns ///
							i.wempo_category ///
							i.org_name_num ///
							stratum, ///
							family(binomial) link(log) nolog eform
		putexcel (A1) = etable
			
	}
	
	
	** pnc_yn   
	// Education as rank
	conindex pnc_yn, rank(resp_highedu_ci) svy wagstaff bounded limits(0 1)
	conindex2 pnc_yn, 	rank(resp_highedu_ci) ///
						covars(	i.wealth_quintile_ns ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)
						
						
	// Women empowerment as rank 
	conindex pnc_yn, rank(wempo_index) svy wagstaff bounded limits(0 1)
	conindex2 pnc_yn, 	rank(wempo_index) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wealth_quintile_ns) ///
						svy wagstaff bounded limits(0 1)
							
							
	** pnc_who_trained  
	// Education as rank
	conindex pnc_who_trained, rank(resp_highedu_ci) svy wagstaff bounded limits(0 1)
	conindex2 pnc_who_trained, 	rank(resp_highedu_ci) ///
						covars(	i.wealth_quintile_ns ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)
						
						
	// Women empowerment as rank 
	conindex pnc_who_trained, rank(wempo_index) svy wagstaff bounded limits(0 1)
	conindex2 pnc_who_trained, 	rank(wempo_index) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wealth_quintile_ns) ///
						svy wagstaff bounded limits(0 1)
							
							
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
	
	
	**************************
	** FINAL MODEL TABLES **
	**************************
	
	// nbc_yn 
	svy: tab nbc_yn, ci 

	svy: tab resp_highedu nbc_yn, row 
	svy: tab mom_age_grp nbc_yn, row 
	svy: tab respd_chid_num_grp nbc_yn, row 

	svy: tab delivery_month_season nbc_yn, row 
	
	svy: tab hfc_vill_yes nbc_yn, row 
	svy: mean hfc_near_dist , over(nbc_yn) 
	svy: tab hfc_distance nbc_yn, row 
	
	svy: tab wealth_quintile_ns nbc_yn, row 
	svy: tab progressivenss nbc_yn, row 
	svy: tab wempo_category nbc_yn, row 

	svy: tab org_name_num nbc_yn, row 
	svy: tab stratum nbc_yn, row 
	
	conindex nbc_yn, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 nbc_yn, 	rank(NationalScore) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								i.delivery_month_season ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)		
		
	// nbc_2days_yn 
	svy: tab nbc_2days_yn, ci 
	
	svy: tab resp_highedu nbc_2days_yn, row 
	svy: tab mom_age_grp nbc_2days_yn, row 
	svy: tab respd_chid_num_grp nbc_2days_yn, row 

	svy: tab delivery_month_season nbc_2days_yn, row 
	
	svy: tab hfc_vill_yes nbc_2days_yn, row 
	svy: mean hfc_near_dist , over(nbc_2days_yn) 
	svy: tab hfc_distance nbc_2days_yn, row 
	
	svy: tab wealth_quintile_ns nbc_2days_yn, row 
	svy: tab progressivenss nbc_2days_yn, row 
	svy: tab wempo_category nbc_2days_yn, row 

	svy: tab org_name_num nbc_2days_yn, row 
	svy: tab stratum nbc_2days_yn, row 
	
	conindex nbc_2days_yn, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 nbc_2days_yn, 	rank(NationalScore) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								i.delivery_month_season ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)

	// nbc_who_trained
	svy: tab nbc_who_trained, ci 

	svy: tab resp_highedu nbc_who_trained, row 
	svy: tab mom_age_grp nbc_who_trained, row 
	svy: tab respd_chid_num_grp nbc_who_trained, row 

	svy: tab delivery_month_season nbc_who_trained, row 
	
	svy: tab hfc_vill_yes nbc_who_trained, row 
	svy: mean hfc_near_dist , over(nbc_who_trained) 
	svy: tab hfc_distance nbc_who_trained, row 
	
	svy: tab wealth_quintile_ns nbc_who_trained, row 
	svy: tab progressivenss nbc_who_trained, row 
	svy: tab wempo_category nbc_who_trained, row 

	svy: tab org_name_num nbc_who_trained, row 
	svy: tab stratum nbc_who_trained, row 
	
	conindex nbc_who_trained, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 nbc_who_trained, 	rank(NationalScore) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								i.delivery_month_season ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)
						
	// Logistic regression 					
	local outcomes	nbc_yn nbc_2days_yn nbc_who_trained
	
	foreach outcome in `outcomes' {
	 
		local regressor  	resp_highedu mom_age_grp respd_chid_num_grp ///
							delivery_month_season ///
							hfc_vill_yes hfc_distance ///
							wealth_quintile_ns wempo_category org_name_num stratum  
		
		foreach v in `regressor' {
			
			putexcel set "$out/reg_output/NBC_`outcome'_logistic_models.xls", sheet("`v'") modify 
		
			if "`v'" == "hfc_near_dist" {
				svy: glm `outcome' `v', family(binomial) link(log) nolog eform // svy: logistic 
			}
			else {
				svy: glm `outcome' i.`v', family(binomial) link(log) nolog eform // svy: logistic 
			}
			
			estimates store `v', title(`v')
			
			putexcel (A1) = etable
			
		}
			
	}
	

	local outcomes	nbc_yn nbc_2days_yn nbc_who_trained
	
	foreach outcome in `outcomes' {
	 
			
		putexcel set "$out/reg_output/NBC_`outcome'_logistic_models.xls", sheet("Final_model") modify 
		
		svy: glm `outcome' 	i.resp_highedu /// // svy: logistic
							i.mom_age_grp ///
							i.respd_chid_num_grp ///
							i.delivery_month_season ///
							hfc_vill_yes ///
							i.hfc_distance ///
							i.wealth_quintile_ns ///
							i.wempo_category ///
							i.org_name_num ///
							stratum, ///
							family(binomial) link(log) nolog eform
		putexcel (A1) = etable
			
	}
	
	
	** nbc_yn   
	// Education as rank
	conindex nbc_yn, rank(resp_highedu_ci) svy wagstaff bounded limits(0 1)
	conindex2 nbc_yn, 	rank(resp_highedu_ci) ///
						covars(	i.wealth_quintile_ns ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)
						
						
	// Women empowerment as rank 
	conindex nbc_yn, rank(wempo_index) svy wagstaff bounded limits(0 1)
	conindex2 nbc_yn, 	rank(wempo_index) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wealth_quintile_ns) ///
						svy wagstaff bounded limits(0 1)
	
	** nbc_who_trained  
	// Education as rank
	conindex nbc_who_trained, rank(resp_highedu_ci) svy wagstaff bounded limits(0 1)
	conindex2 nbc_who_trained, 	rank(resp_highedu_ci) ///
						covars(	i.wealth_quintile_ns ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)
						
						
	// Women empowerment as rank 
	conindex nbc_who_trained, rank(wempo_index) svy wagstaff bounded limits(0 1)
	conindex2 nbc_who_trained, 	rank(wempo_index) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wealth_quintile_ns) ///
						svy wagstaff bounded limits(0 1)
						
	****************************************************************************
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
		
		svy: reg `v' i.NationalQuintile i.org_name_num i.NationalQuintile stratum wempo_index // i.resp_highedu i.hh_mem_highedu_all
		//eststo model_B
		estimates store `v', title(`v')
		
	}
		
		estout `outcome' using "$out/reg_output/FINAL_MomHealth_Model_4.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
		   legend label varlabels(_cons constant)              ///
		   stats(r2 df_r bic) replace	

	foreach v in `outcome' {
		
		svy: reg `v' i.wealth_quintile_ns i.org_name_num i.wealth_quintile_ns stratum wempo_index // i.resp_highedu i.hh_mem_highedu_all
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
		
		svy: logit `v' i.NationalQuintile i.org_name_num i.NationalQuintile stratum wempo_index // i.resp_highedu i.hh_mem_highedu_all
		//eststo model_B
		estimates store `v', title(`v')
		
	}
		
		estout `outcome' using "$out/reg_output/FINAL_MomHealth_Model_4_logistic.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
		   legend label varlabels(_cons constant)              ///
		   stats(r2 df_r bic) replace	
	
	foreach v in `outcome' {
		
		svy: logit `v' i.wealth_quintile_ns i.org_name_num i.wealth_quintile_ns stratum wempo_index // i.resp_highedu i.hh_mem_highedu_all
		//eststo model_B
		estimates store `v', title(`v')
		
	}
		
		estout `outcome' using "$out/reg_output/FINAL_MomHealth_Model_4_logistic_PNDist.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
		   legend label varlabels(_cons constant)              ///
		   stats(r2 df_r bic) replace		
	
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
	
	svy: tab wealth_quintile_ns phq9_cat, row 
	
	
	

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
				
	
	
	foreach var of varlist 	wempo_childcare wempo_mom_health wempo_child_health ///
							wempo_women_wages wempo_major_purchase wempo_visiting ///
							wempo_women_health wempo_child_wellbeing {
					
		di "`var'"
		gen `var'_w = (`var' == 1)
		replace `var'_w = .m if mi(`var')
		//svy: tab NationalQuintile `var', row 
		conindex `var'_w, rank(NationalScore) svy wagstaff bounded limits(0 1)
		
		}
			
			
	sum wempo_childcare wempo_mom_health wempo_child_health ///
							wempo_women_wages wempo_major_purchase wempo_visiting ///
							wempo_women_health wempo_child_wellbeing
							
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
	svy: mean wempo_index
	svy: mean wempo_index, over(stratum_num)
	test _b[c.wempo_index@1bn.stratum_num] = _b[c.wempo_index@2bn.stratum_num] = _b[c.wempo_index@3bn.stratum_num] = _b[c.wempo_index@4bn.stratum_num] = _b[c.wempo_index@5bn.stratum_num]

	
	* Women empowerment by wealth quintile - national cut-off 
	svy: mean wempo_index, over(NationalQuintile)
	test _b[c.wempo_index@1bn.NationalQuintile] = _b[c.wempo_index@2bn.NationalQuintile] = _b[c.wempo_index@3bn.NationalQuintile] = _b[c.wempo_index@4bn.NationalQuintile] = _b[c.wempo_index@5bn.NationalQuintile]
	
	* Women empowerment by wealth quintile - project nourish cut-off  
	svy: mean wempo_index, over(wealth_quintile_ns)
	test _b[c.wempo_index@1bn.wealth_quintile_ns] = _b[c.wempo_index@2bn.wealth_quintile_ns] = _b[c.wempo_index@3bn.wealth_quintile_ns] = _b[c.wempo_index@4bn.wealth_quintile_ns] = _b[c.wempo_index@5bn.wealth_quintile_ns]

	svy: mean wempo_index, over(wealth_quintile_modify)
	test _b[c.wempo_index@1bn.wealth_quintile_modify] = _b[c.wempo_index@2bn.wealth_quintile_modify] = _b[c.wempo_index@3bn.wealth_quintile_modify] = _b[c.wempo_index@4bn.wealth_quintile_modify] = _b[c.wempo_index@5bn.wealth_quintile_modify]

	
	encode enu_name, gen(enu_name_num)
	svy: mean wempo_index if org_name_num == 1, over(enu_name_num)
	svy: mean wempo_index if org_name_num == 2, over(enu_name_num)
	svy: mean wempo_index if org_name_num == 3, over(enu_name_num)
	
	
	conindex progressivenss, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex wempo_index, rank(NationalScore) svy truezero generalized
	
	
	sum wempo_index
	gen wempo_index_rescale = wempo_index + abs(r(min))
	sum wempo_index wempo_index_rescale
	
	conindex wempo_index_rescale, rank(NationalScore) svy wagstaff bounded limits(0 2.500905)
	
	
	svy: mean progressivenss
	svy: mean progressivenss, over(NationalQuintile)

	
	
// END HERE 



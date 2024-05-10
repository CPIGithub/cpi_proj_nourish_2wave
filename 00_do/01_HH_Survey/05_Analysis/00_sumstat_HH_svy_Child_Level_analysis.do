/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: Data analysis - Child level			
Author				:	Nicholus Tint Zaw
Date				: 	03/01/2023
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

	****************************************************************************
	* Child MUAC Module *
	****************************************************************************

	use "$dta/pnourish_child_muac_final.dta", clear   
	
	
	* Generate a histogram for the MUAC variable
	histogram u5_muac if u5_muac < 30, ///
		frequency ///
		//discrete ///
		start(7) width(0.5) bin(25) ///
		xlabel(7(0.5)19.5) ///
		title("Histogram of MUAC Results") ///
		ylabel(Frequency) ///
		xtitle("MUAC") ///
		ytitle("Frequency")
	
	
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	svy: mean hh_mem_sex u5_muac child_gam child_mam child_sam
	
	svy: tab child_gam, ci 
	svy: tab child_mam, ci 
	svy: tab child_sam, ci 
	
	* cross-tab 
	svy: tab stratum_num child_gam, row 
	svy: tab NationalQuintile child_gam, row 
	
	svy: mean u5_muac, over(stratum_num)
	svy: mean u5_muac, over(hh_mem_sex)
	svy: reg u5_muac i.stratum_num
	
	svy: mean u5_muac, over(NationalQuintile)
	svy: reg u5_muac i.NationalQuintile
	
	
	svy: tab hhitems_phone child_gam, row 
	svy: tab prgexpo_pn child_gam, row 
	svy: tab edu_exposure child_gam, row 
	svy: tab prgexpo_join8 child_gam, row 
	
	
	foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
		conindex child_gam, rank(`var') svy wagstaff bounded limits(0 1)
	}

	
	gen org_name_nokdhw = org_name_num
	replace org_name_nokdhw = .m if stratum_num == 5
	
	gen KDHW = (stratum_num == 5)
	
	svy: logit child_gam KDHW stratum i.org_name_num 
	estimates store m1, title(Model 1: Child Malnutrition)

	estout m1 using "$out/reg_output/01_child_gam.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
   
   
 	foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
		conindex child_gam, rank(`var') svy wagstaff bounded limits(0 1)
	}

	
	gen stratum_org_inter = stratum * org_name_num  
	
	svy: logit child_gam KDHW i.org_name_num##stratum
	estimates store m1, title(Model 1: Child Malnutrition)

	estout m1 using "$out/reg_output/01_child_gam_m2.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	   
	* Design Effect Calculation 
	svy: mean child_gam 
    estat svyset
    estat effects, deff deft meff meft
	
	
	   
	****************************************************************************
	* Child IYCF Data *
	****************************************************************************
	
	use "$dta/pnourish_child_iycf_final.dta", clear 
	
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


	local outcomes mdd  mmf mad

	foreach outcome in `outcomes' {

		svy: logistic `outcome' i.mkt_distance

	}
	
	local outcomes ebf eibf cbf

	foreach outcome in `outcomes' {

		svy: logistic `outcome' i.hfc_distance

	}
	
	
	local outcome 	dietary_tot mdd mmf mad			
	
	foreach var in `outcome' {
		
		* Create a scatter plot with lowess curves 
		twoway scatter `var' mkt_near_dist, ///
			mcolor(blue) msize(small) ///
			legend(off)

		* Add lowess curves
		lowess `var' mkt_near_dist, ///
			lcolor(red) lwidth(medium) ///
			legend(label(1 "Lowess Curve"))
			
		graph export "$plots/nutrition/lowess_`var'_market_distance.png", replace
	
	}
	
	local outcome 	ebf eibf cbf

	
	foreach var in `outcome' {
		
		* Create a scatter plot with lowess curves 
		twoway scatter `var' hfc_near_dist, ///
			mcolor(blue) msize(small) ///
			legend(off)

		* Add lowess curves
		lowess `var' hfc_near_dist, ///
			lcolor(red) lwidth(medium) ///
			legend(label(1 "Lowess Curve"))
			
		graph export "$plots/nutrition/lowess_`var'_health_Facility_distance.png", replace
	
	}
	
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

	/*
	egen wealth_quintile_ns = xtile(NationalScore), n(5)
	egen wealth_quintile_inc = xtile(income_lastmonth), n(5)
	lab def w_quintile 1"Poorest" 2"Poor" 3"Medium" 4"Wealthy" 5"Wealthiest"
	lab val wealth_quintile_ns wealth_quintile_inc w_quintile
	lab var wealth_quintile_ns "Wealth Quintiles by PN pop-based EquityTool national score distribution"
	lab var wealth_quintile_inc "Wealth Quintiles by last month income"
	tab1 wealth_quintile_ns wealth_quintile_inc, m 
	*/
	
	tab NationalQuintile wealth_quintile_ns
	
	* breastfeeding *
	svy: mean eibf 
	svy: mean ebf2d 
	svy: mean ebf 
	svy: mean pre_bf 
	svy: mean mixmf 
	svy: mean bof 
	svy: mean cbf

	// eibf 
	svy: tab stratum_num eibf, row 
	svy: tab NationalQuintile eibf, row	
	
	// ebf2d 
	svy: tab stratum_num ebf2d, row 
	svy: tab NationalQuintile ebf2d, row	
	
	// ebf 
	svy: tab stratum_num ebf, row 
	svy: tab NationalQuintile ebf, row	
	
	// pre_bf 
	svy: tab stratum_num pre_bf, row 
	svy: tab NationalQuintile pre_bf, row	
	
	// mixmf 
	svy: tab stratum_num mixmf, row 
	svy: tab NationalQuintile mixmf, row	
	
	// bof 
	svy: tab stratum_num bof, row 
	svy: tab NationalQuintile bof, row	
	
	// cbf
	svy: tab stratum_num cbf, row 
	svy: tab NationalQuintile cbf, row 

	
	svy: tab hhitems_phone eibf, row 
	svy: tab prgexpo_pn eibf, row 
	svy: tab edu_exposure eibf, row 
	
	svy: tab hhitems_phone ebf, row 
	svy: tab prgexpo_pn ebf, row 
	svy: tab edu_exposure ebf, row 
	
	svy: tab hhitems_phone cbf, row 
	svy: tab prgexpo_pn cbf, row 
	svy: tab edu_exposure cbf, row 
	

	foreach var of varlist eibf ebf2d ebf pre_bf mixmf bof cbf{
	    
		di "`var'"
		
		svy: tab wealth_quintile_ns `var', row
	
	}
	
	foreach var of varlist eibf ebf2d ebf pre_bf mixmf bof cbf{
	    
		di "`var'"
		
		svy: tab wealth_quintile_modify `var', row
	
	}
	
	local outcome eibf ebf2d ebf pre_bf mixmf bof cbf
	* Concentration Index - absolute
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}

	* Concentration Index - absolute
 	local outcome eibf ebf2d ebf pre_bf mixmf bof cbf
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile /*income_lastmonth hh_mem_highedu_all*/ {
		
			di "`v'"	
			conindex `v', rank(`var') svy truezero generalized
		}
	
	}	
	
	gen stratum_org_inter = stratum * org_name_num  
	gen KDHW = (stratum_num == 5)


	foreach v in `outcome' {
		
		svy: logit `v' KDHW stratum i.org_name_num 
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/02_bf_table.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	

	foreach v in `outcome' {
		
		svy: logit `v' KDHW i.org_name_num##stratum
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/02_bf_table_m2.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	
	
	* complementary feeding * 
	svy: mean isssf 
	svy: mean food_g1 
	svy: mean food_g2 
	svy: mean food_g3 
	svy: mean food_g4 
	svy: mean food_g5 
	svy: mean food_g6 
	svy: mean food_g7 
	svy: mean food_g8
	
	// isssf
	svy: tab stratum_num isssf, row 
	svy: tab NationalQuintile isssf, row

	// food_g1 
	svy: tab stratum_num food_g1 , row 
	svy: tab NationalQuintile food_g1 , row
	
	// food_g2 
	svy: tab stratum_num food_g2, row 
	svy: tab NationalQuintile food_g2, row
	
	// food_g3 
	svy: tab stratum_num food_g3, row 
	svy: tab NationalQuintile food_g3, row
	
	// food_g4 
	svy: tab stratum_num food_g4, row 
	svy: tab NationalQuintile food_g4, row	
	
	// food_g5 
	svy: tab stratum_num food_g5, row 
	svy: tab NationalQuintile food_g5, row
	
	// food_g6 
	svy: tab stratum_num food_g6, row 
	svy: tab NationalQuintile food_g6, row	
	
	// food_g7 
	svy: tab stratum_num food_g7, row 
	svy: tab NationalQuintile food_g7, row
	
	// food_g8 
	svy: tab stratum_num food_g8, row 
	svy: tab NationalQuintile food_g8, row

	
	foreach var of varlist isssf food_g1 food_g2 food_g3 food_g4 food_g5 food_g6 food_g7 food_g8 {
	    
		di "`var'"
		
		svy: tab wealth_quintile_ns `var', row
	
	}
	
	
	foreach var of varlist isssf food_g1 food_g2 food_g3 food_g4 food_g5 food_g6 food_g7 food_g8 {
	    
		di "`var'"
		
		svy: tab wealth_quintile_modify `var', row
	
	}	
	
	
	
	local outcome isssf food_g1 food_g2 food_g3 food_g4 food_g5 food_g6 food_g7 food_g8
	* Concentration Index - relative 
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}

	* Concentration Index - absolute
 	local outcome isssf food_g1 food_g2 food_g3 food_g4 food_g5 food_g6 food_g7 food_g8
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
	

	estout `outcome' using "$out/reg_output/03_child_fg_table.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	
	foreach v in `outcome' {
		
		svy: logit `v' KDHW i.org_name_num##stratum
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/03_child_fg_table_m2.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	* minimum dietary *
	svy: mean dietary_tot 
	svy: mean mdd 
	svy: mean mmf_bf_6to8 
	svy: mean mmf_bf_9to23 
	svy: mean mmf_bf 
	svy: mean mmf_nonbf 
	svy: mean mmf 
	svy: mean mmff 
	svy: mean mad 
	svy: mean mad_bf 
	svy: mean mad_nobf 
	
	// dietary_tot 
	svy: mean dietary_tot, over(stratum_num)
	svy: reg dietary_tot i.stratum_num
	
	svy: mean dietary_tot, over(NationalQuintile)
	svy: reg dietary_tot i.NationalQuintile
	svy: reg dietary_tot wempo_index 

	// mdd 
	svy: tab stratum_num mdd, row 
	svy: tab NationalQuintile mdd, row
	svy: reg mdd wempo_index 
	
	// mmf_bf_6to8 
	svy: tab stratum_num mmf_bf_6to8 , row 
	svy: tab NationalQuintile mmf_bf_6to8 , row
	
	// mmf_bf_9to23
	svy: tab stratum_num mmf_bf_9to23, row 
	svy: tab NationalQuintile mmf_bf_9to23, row
	
	// mmf_bf 
	svy: tab stratum_num mmf_bf , row 
	svy: tab NationalQuintile mmf_bf, row
	
	// mmf_nonbf 
	svy: tab stratum_num mmf_nonbf, row 
	svy: tab NationalQuintile mmf_nonbf, row
	
	// mmf 
	svy: tab stratum_num mmf , row 
	svy: tab NationalQuintile mmf , row
	svy: reg mmf wempo_index 
	
	// mmff 
	svy: tab stratum_num mmff, row 
	svy: tab NationalQuintile mmff, row
	
	// mad 
	svy: tab stratum_num mad, row 
	svy: tab NationalQuintile mad, row
	svy: reg mad wempo_index 

	// mad_bf 
	svy: tab stratum_num  mad_bf, row 
	svy: tab NationalQuintile  mad_bf, row
	
	// mad_nobf 
	svy: tab stratum_num mad_nobf, row 
	svy: tab NationalQuintile mad_nobf, row

	
	// dietary_tot 
	svy: mean dietary_tot, over(hhitems_phone)
	test _b[c.dietary_tot@0bn.hhitems_phone] = _b[c.dietary_tot@1bn.hhitems_phone]

	svy: mean dietary_tot, over(prgexpo_pn)
	test _b[c.dietary_tot@0bn.prgexpo_pn] = _b[c.dietary_tot@1bn.prgexpo_pn]

	svy: mean dietary_tot, over(edu_exposure)
	test _b[c.dietary_tot@0bn.edu_exposure] = _b[c.dietary_tot@1bn.edu_exposure]

	
	svy: tab hhitems_phone mdd, row 
	svy: tab prgexpo_pn mdd, row 
	svy: tab edu_exposure mdd, row 
	
	svy: tab hhitems_phone mmf, row 
	svy: tab prgexpo_pn mmf, row 
	svy: tab edu_exposure mmf, row 

	svy: tab hhitems_phone mad, row 
	svy: tab prgexpo_pn mad, row 
	svy: tab edu_exposure mad, row 

	svy: mean dietary_tot, over(wealth_quintile_ns)
	svy: mean dietary_tot, over(wealth_quintile_modify)

	foreach var of varlist mdd mmf_bf_6to8 mmf_bf_9to23 mmf_bf mmf_nonbf mmf mmff mad mad_bf mad_nobf  {
	    
		di "`var'"
		
		svy: tab wealth_quintile_ns `var', row
	
	}
	
	foreach var of varlist mdd mmf_bf_6to8 mmf_bf_9to23 mmf_bf mmf_nonbf mmf mmff mad mad_bf mad_nobf  {
	    
		di "`var'"
		
		svy: tab wealth_quintile_modify `var', row
	
	}	
	
	
	
	* Concentration Index - relative 
	local outcome dietary_tot 
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 8)
		}
	
	}		
	
	* Concentration Index - absolute 	
	local outcome dietary_tot 
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy truezero generalized
		}
	
	}	
	
	
	foreach v in `outcome' {
		
		svy: reg `v' KDHW stratum org_name_num 
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/04_diet_score_table.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	   
	foreach v in `outcome' {
		
		svy: reg `v' KDHW i.org_name_num##stratum
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/04_diet_score_table_m2.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	local outcome mdd mmf_bf_6to8 mmf_bf_9to23 mmf_bf mmf_nonbf mmf mmff mad mad_bf mad_nobf 
	* Concentration Index - relative 
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}
	
	
	* Concentration Index - absolute
 	local outcome mdd mmf_bf_6to8 mmf_bf_9to23 mmf_bf mmf_nonbf mmf mmff mad mad_bf mad_nobf 
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile /*income_lastmonth hh_mem_highedu_all*/ {
		
			di "`v'"	
			conindex `v', rank(`var') svy truezero generalized
		}
	
	}	
	
	local outcome mdd /*mmf_bf_6to8*/ mmf_bf_9to23 mmf_bf mmf_nonbf mmf mmff mad mad_bf mad_nobf 
	
	foreach v in `outcome' {
		
		svy: logit `v' KDHW stratum org_name_num 
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/05_min_dietary_table.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	
	
	
	foreach v in `outcome' {
		
		svy: logit `v' KDHW i.org_name_num##stratum
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/05_min_dietary_table_m2.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   

	   
	* IYCF ALL *
	local outcome ebf pre_bf dietary_tot mdd mmf mad 
	
	foreach v in `outcome' {
		
		svy: reg `v' wempo_index NationalQuintile stratum NationalQuintile_stratum i.org_name_num
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/05_child_iycf_FINAL.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	
	* Design Effect Calculation 
	svy: mean eibf 
    estat svyset
    estat effects, deff deft meff meft
		
	svy: mean ebf 
    estat svyset
    estat effects, deff deft meff meft
	
	svy: mean mdd 
    estat svyset
    estat effects, deff deft meff meft
	
	svy: mean mmf 
    estat svyset
    estat effects, deff deft meff meft
	
	svy: mean mad 
    estat svyset
    estat effects, deff deft meff meft
	
	   
	* IYCF ALL *
	// 		svy: reg `v' wempo_index NationalQuintile stratum NationalQuintile_stratum i.org_name_num

	local outcome dietary_tot  
	
	// Model 1 
	local i = 1
	foreach var of varlist org_name_num NationalQuintile stratum wempo_index {
	    
		foreach v in `outcome' {
			
			if `i' < 3 {
			    svy: reg `v' i.`var'
			} 
			else {
				svy: reg `v' `var'
			}
			//eststo model`i'
			estimates store `v', title(`v')
			
		}
		
		estout `outcome' using "$out/reg_output/FINAL_IYCF_Model_1_`var'.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
		   legend label varlabels(_cons constant)              ///
		   stats(r2 df_r bic) replace	
		
		local i = `i' + 1
	}


	// Model 2
	foreach v in `outcome' {
		
		svy: reg `v' i.NationalQuintile i.org_name_num stratum 
		eststo model_A
		estimates store `v', title(`v')
		
	}
		
		estout `outcome' using "$out/reg_output/FINAL_IYCF_Model_2.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
		   legend label varlabels(_cons constant)              ///
		   stats(r2 df_r bic) replace	
		

	// Model 3
	foreach v in `outcome' {
		
		svy: reg `v' i.NationalQuintile i.org_name_num i.NationalQuintile##stratum 
		eststo model_B
		estimates store `v', title(`v')
		
	}
		
		estout `outcome' using "$out/reg_output/FINAL_IYCF_Model_3.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
		   legend label varlabels(_cons constant)              ///
		   stats(r2 df_r bic) replace	

		   
	// Model 4
	foreach v in `outcome' {
		
		svy: reg `v' i.NationalQuintile i.org_name_num i.NationalQuintile stratum wempo_index
		eststo model_B
		estimates store `v', title(`v')
		
	}
		
		estout `outcome' using "$out/reg_output/FINAL_IYCF_Model_4.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
		   legend label varlabels(_cons constant)              ///
		   stats(r2 df_r bic) replace	
		   
	foreach v in `outcome' {
		
		svy: reg `v' i.wealth_quintile_ns i.org_name_num i.wealth_quintile_ns stratum wempo_index
		eststo model_B
		estimates store `v', title(`v')
		
	}
		
		estout `outcome' using "$out/reg_output/FINAL_IYCF_Model_4_PNDist.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
		   legend label varlabels(_cons constant)              ///
		   stats(r2 df_r bic) replace	
		   
		   
	// nested model test    
	nestreg: reg dietary_tot (i.NationalQuintile) (i.org_name_num) (i.NationalQuintile##stratum) (wempo_index)
	
	reg dietary_tot i.NationalQuintile i.org_name_num 
	eststo model_A
	reg dietary_tot i.NationalQuintile i.org_name_num i.NationalQuintile##stratum
	eststo model_B

	lrtest model_A model_B
	
	
	// Model 4
	local outcome	ebf pre_bf mdd mmf mad 
	foreach v in `outcome' {
		
		svy: logit `v' i.NationalQuintile i.org_name_num i.NationalQuintile stratum wempo_index
		//eststo model_B
		estimates store `v', title(`v')
		
	}
		
		estout `outcome' using "$out/reg_output/FINAL_IYCF_Model_4_logistic.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
		   legend label varlabels(_cons constant)              ///
		   stats(r2 df_r bic) replace	
		
		
	foreach v in `outcome' {
		
		svy: logit `v' i.wealth_quintile_ns i.org_name_num i.wealth_quintile_ns stratum wempo_index
		//eststo model_B
		estimates store `v', title(`v')
		
	}
		
		estout `outcome' using "$out/reg_output/FINAL_IYCF_Model_4_logistic_PNDist.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
		   legend label varlabels(_cons constant)              ///
		   stats(r2 df_r bic) replace		
	
	

	// FINAL TABLEs
	local outcomes	ebf pre_bf mdd mmf mad 
	
	foreach outcome in `outcomes' {
	 
		local regressor  resp_highedu org_name_num stratum NationalQuintile wempo_index progressivenss wempo_category mkt_distance hfc_distance
		
		foreach v in `regressor' {
			
			putexcel set "$out/reg_output/IYCF_`outcome'_logistic_models.xls", sheet("`v'") modify 
		
			if "`v'" != "wempo_index" {
				svy: logistic `outcome' i.`v'
			}
			else {
				svy: logistic `outcome' `v'
			}
			
			estimates store `v', title(`v')
			
			putexcel (A1) = etable
			
		}
			
	}
	

	local outcomes	ebf pre_bf mdd mmf mad 
	
	foreach outcome in `outcomes' {
	 
			
		putexcel set "$out/reg_output/IYCF_`outcome'_logistic_models.xls", sheet("Final_model") modify 
		
		svy: logistic `outcome' i.resp_highedu i.NationalQuintile i.wempo_category i.hfc_distance i.org_name_num stratum  
	
		putexcel (A1) = etable
			
	}
	
	
	local regressor  resp_highedu org_name_num stratum NationalQuintile wempo_index progressivenss wempo_category mkt_distance hfc_distance
	
	foreach v in `regressor' {
		
		putexcel set "$out/reg_output/IYCF_dietary_tot_logistic_models.xls", sheet("`v'") modify 
	
		if "`v'" != "wempo_index" {
		    svy: reg dietary_tot i.`v'
		}
		else {
		    svy: reg dietary_tot `v'
		}
		
		estimates store `v', title(`v')
		
		putexcel (A1) = etable
		
	}
	
	putexcel set "$out/reg_output/IYCF_dietary_tot_logistic_models.xls", sheet("Final_model") modify 
	
	svy: reg dietary_tot i.resp_highedu i.NationalQuintile i.wempo_category i.hfc_distance i.org_name_num stratum 
	
	putexcel (A1) = etable
	
	

	svy: tab progressivenss ebf , row 
	svy: tab progressivenss mdd , row 
	svy: tab progressivenss mmf , row 
	svy: tab progressivenss mad , row 
	svy: mean dietary_tot , over(progressivenss) 
	
	svy: tab wempo_category ebf , row 
	svy: tab wempo_category mdd , row 
	svy: tab wempo_category mmf , row 
	svy: tab wempo_category mad , row 
	svy: mean dietary_tot , over(wempo_category) 
	
	svy: tab hfc_distance ebf , row 
	svy: tab hfc_distance mdd , row 
	svy: tab hfc_distance mmf , row 
	svy: tab hfc_distance mad , row 
	svy: mean dietary_tot , over(hfc_distance) 
	
	svy: tab mkt_distance mdd , row 
	svy: tab mkt_distance mmf , row 
	svy: tab mkt_distance mad , row 
	svy: mean dietary_tot , over(mkt_distance) 
	
	svy: tab resp_highedu ebf , row 
	svy: tab resp_highedu mdd , row 
	svy: tab resp_highedu mmf , row 
	svy: tab resp_highedu mad , row 
	svy: mean dietary_tot , over(resp_highedu) 
	
	svy: tab org_name_num ebf , row 
	svy: tab org_name_num mdd , row 
	svy: tab org_name_num mmf , row 
	svy: tab org_name_num mad , row 
	svy: mean dietary_tot , over(org_name_num) 
	
	
	// EBF 
	putexcel set "$out/reg_output/IYCF_ebf_logistic_models.xls", sheet("Final_model") modify 
	svy: logistic ebf i.resp_highedu i.hfc_distance 
	putexcel (A1) = etable
	
	conindex ebf, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 ebf, rank(NationalScore) covars(i.resp_highedu i.hfc_distance) svy wagstaff bounded limits(0 1)

	conindex ebf, rank(resp_highedu_ci) svy wagstaff bounded limits(0 1)
	conindex2 ebf, rank(resp_highedu_ci) covars(i.hfc_distance) svy wagstaff bounded limits(0 1)	

	conindex ebf, rank(wempo_index) svy wagstaff bounded limits(0 1)
	conindex2 ebf, rank(wempo_index) covars(i.resp_highedu i.hfc_distance) svy wagstaff bounded limits(0 1)	


	// MDD
	putexcel set "$out/reg_output/IYCF_mdd_logistic_models.xls", sheet("Final_model") modify 
	svy: logistic mdd i.resp_highedu i.NationalQuintile i.wempo_category i.hfc_distance stratum
	putexcel (A1) = etable
	
	conindex mdd, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 mdd, rank(NationalScore) covars(i.resp_highedu i.wempo_category i.hfc_distance stratum) svy wagstaff bounded limits(0 1)	

	conindex mdd, rank(resp_highedu_ci) svy wagstaff bounded limits(0 1)
	conindex2 mdd, rank(resp_highedu_ci) covars(NationalScore i.wempo_category i.hfc_distance stratum) svy wagstaff bounded limits(0 1)	

	conindex mdd, rank(wempo_index) svy wagstaff bounded limits(0 1)
	conindex2 mdd, rank(wempo_index) covars(NationalScore i.resp_highedu i.hfc_distance stratum) svy wagstaff bounded limits(0 1)	


	// MMF
	putexcel set "$out/reg_output/IYCF_mmf_logistic_models.xls", sheet("Final_model") modify 
	svy: logistic mmf i.resp_highedu i.hfc_distance i.mkt_distance 
	putexcel (A1) = etable

	conindex mmf, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 mmf, rank(NationalScore) covars(i.resp_highedu i.hfc_distance i.mkt_distance) svy wagstaff bounded limits(0 1)	
	
	conindex mmf, rank(resp_highedu_ci) svy wagstaff bounded limits(0 1)
	conindex2 mmf, rank(resp_highedu_ci) covars(i.hfc_distance i.mkt_distance) svy wagstaff bounded limits(0 1)	

	conindex mmf, rank(wempo_index) svy wagstaff bounded limits(0 1)
	conindex2 mmf, rank(wempo_index) covars(i.resp_highedu i.hfc_distance i.mkt_distance) svy wagstaff bounded limits(0 1)	

	
	// MAD
	putexcel set "$out/reg_output/IYCF_mad_logistic_models.xls", sheet("Final_model") modify 
	svy: logistic mad i.resp_highedu i.NationalQuintile i.wempo_category i.hfc_distance stratum
	putexcel (A1) = etable

	conindex mad, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 mad, rank(NationalScore) covars(i.resp_highedu i.wempo_category i.hfc_distance stratum) svy wagstaff bounded limits(0 1)	
	
	conindex mad, rank(resp_highedu_ci) svy wagstaff bounded limits(0 1)
	conindex2 mad, rank(resp_highedu_ci) covars(NationalScore i.wempo_category i.hfc_distance stratum) svy wagstaff bounded limits(0 1)	

	conindex dietary_tot, rank(wempo_index) svy truezero generalized
	conindex2 dietary_tot, rank(wempo_index) covars(NationalScore i.resp_highedu i.hfc_distance stratum) svy truezero generalized	

	
	// Food Groups 
	putexcel set "$out/reg_output/IYCF_dietary_tot_logistic_models.xls", sheet("Final_model") modify 
	svy: reg dietary_tot i.resp_highedu i.NationalQuintile i.wempo_category i.hfc_distance stratum
	putexcel (A1) = etable

	conindex dietary_tot, rank(NationalScore) svy truezero generalized
	conindex2 dietary_tot, rank(NationalScore) covars(i.resp_highedu i.wempo_category i.hfc_distance stratum) svy truezero generalized

	conindex dietary_tot, rank(NationalScore)  svy wagstaff bounded limits(0 8)
	conindex2 dietary_tot, rank(NationalScore) covars(i.resp_highedu i.wempo_category i.hfc_distance stratum) svy wagstaff bounded limits(0 8)

	
	conindex dietary_tot, rank(resp_highedu_ci) svy truezero generalized
	conindex2 dietary_tot, rank(resp_highedu_ci) covars(NationalScore i.wempo_category i.hfc_distance stratum) svy truezero generalized	

	conindex dietary_tot, rank(resp_highedu_ci) svy wagstaff bounded limits(0 8)
	conindex2 dietary_tot, rank(resp_highedu_ci) covars(NationalScore i.wempo_category i.hfc_distance stratum) svy wagstaff bounded limits(0 8)	

	
	
	conindex dietary_tot, rank(wempo_index) svy truezero generalized
	conindex2 dietary_tot, rank(wempo_index) covars(NationalScore i.resp_highedu i.hfc_distance stratum) svy truezero generalized	

	conindex dietary_tot, rank(wempo_index) svy wagstaff bounded limits(0 8)
	conindex2 dietary_tot, rank(wempo_index) covars(NationalScore i.resp_highedu i.hfc_distance stratum) svy wagstaff bounded limits(0 8)	

	// stratum_num
	svy: tab stratum ebf, row
	svy: tab stratum mdd, row
	svy: tab stratum mmf, row
	svy: tab stratum mad, row

	svy: mean dietary_tot, over(stratum)
	
	
	* plots for publication 
    global graph_opts1 ///
           bgcolor(white) ///
           graphregion(color(white)) ///
           legend(region(lc(none) fc(none))) ///
           ylab(,angle(0) nogrid) ///
           title(, justification(left) color(black) span pos(11)) ///
           subtitle(, justification(left) color(black))
		 
	// ebf
	gen ebf_pct = ebf * 100
	
	graph bar 	ebf_pct [aweight = weight_final], over(NationalQuintile) ///
				${graph_opts1} ///
				blabel(bar, format(%9.1f)) ///
				ytitle("% of 0-5 months Children", size(small) height(-6))								///
				title("Proportion of Exclusively Breastfed Children" "(by Wealth Quintile)", 		///
						justification(left) color(black) span pos(11) size(medium)) 							///
				plotregion(fcolor(white)) 														///
				graphregion(fcolor(white)) ///
				note(	"", size(vsmall) span)
				
	graph export "$plots/PN_Paper_Child_Nutrition/02_EBF_by_Wealth.png", replace

	
	graph bar 	ebf_pct [aweight = weight_final], over(resp_highedu) ///
				${graph_opts1} ///
				blabel(bar, format(%9.1f)) ///
				ytitle("% of 0-5 months Children", size(small) height(-6))								///
				title("Proportion of Exclusively Breastfed Children" "(by Respondent's Education)", 		///
						justification(left) color(black) span pos(11) size(medium)) 							///
				plotregion(fcolor(white)) 														///
				graphregion(fcolor(white)) ///
				note(	"", size(vsmall) span)
				
	graph export "$plots/PN_Paper_Child_Nutrition/02_EBF_by_Edu.png", replace
	
	
	graph bar 	ebf_pct [aweight = weight_final], over(wempo_category) ///
				${graph_opts1} ///
				blabel(bar, format(%9.1f)) ///
				ytitle("% of 0-5 months Children", size(small) height(-6))								///
				title("Proportion of Exclusively Breastfed Children" "(by Women Empowerment)", 		///
						justification(left) color(black) span pos(11) size(medium)) 							///
				plotregion(fcolor(white)) 														///
				graphregion(fcolor(white)) ///
				note(	"", size(vsmall) span)
				
	graph export "$plots/PN_Paper_Child_Nutrition/02_EBF_by_WomenEmpowerment.png", replace
	

	// mdd
	gen mdd_pct = mdd * 100
	
	graph bar 	mdd_pct [aweight = weight_final], over(NationalQuintile) ///
				${graph_opts1} ///
				blabel(bar, format(%9.1f)) ///
				ytitle("% of 6-23 months Children", size(small) height(-6))								///
				title("Proportion of Children Met Minimum Dietary Diversity" "(by Wealth Quintile)", 		///
						justification(left) color(black) span pos(11) size(medium)) 							///
				plotregion(fcolor(white)) 														///
				graphregion(fcolor(white)) ///
				note(	"", size(vsmall) span)
				
	graph export "$plots/PN_Paper_Child_Nutrition/03_MDD_by_Wealth.png", replace

	
	graph bar 	mdd_pct [aweight = weight_final], over(resp_highedu) ///
				${graph_opts1} ///
				blabel(bar, format(%9.1f)) ///
				ytitle("% of 6-23 months Children", size(small) height(-6))								///
				title("Proportion of Children Met Minimum Dietary Diversity" "(by Respondent's Education)", 		///
						justification(left) color(black) span pos(11) size(medium)) 							///
				plotregion(fcolor(white)) 														///
				graphregion(fcolor(white)) ///
				note(	"", size(vsmall) span)
				
	graph export "$plots/PN_Paper_Child_Nutrition/03_MDD_by_Edu.png", replace
	
	
	graph bar 	mdd_pct [aweight = weight_final], over(wempo_category) ///
				${graph_opts1} ///
				blabel(bar, format(%9.1f)) ///
				ytitle("% of 6-23 months Children", size(small) height(-6))								///
				title("Proportion of Children Met Minimum Dietary Diversity" "(by Women Empowerment)", 		///
						justification(left) color(black) span pos(11) size(medium)) 							///
				plotregion(fcolor(white)) 														///
				graphregion(fcolor(white)) ///
				note(	"", size(vsmall) span)
				
	graph export "$plots/PN_Paper_Child_Nutrition/03_MDD_by_WomenEmpowerment.png", replace
	

	// mmf
	gen mmf_pct = mmf * 100
	
	graph bar 	mmf_pct [aweight = weight_final], over(NationalQuintile) ///
				${graph_opts1} ///
				blabel(bar, format(%9.1f)) ///
				ytitle("% of 6-23 months Children", size(small) height(-6))								///
				title("Proportion of Children Met Minimum Meal Frequency" "(by Wealth Quintile)", 		///
						justification(left) color(black) span pos(11) size(medium)) 							///
				plotregion(fcolor(white)) 														///
				graphregion(fcolor(white)) ///
				note(	"", size(vsmall) span)
				
	graph export "$plots/PN_Paper_Child_Nutrition/04_MMF_by_Wealth.png", replace

	
	graph bar 	mmf_pct [aweight = weight_final], over(resp_highedu) ///
				${graph_opts1} ///
				blabel(bar, format(%9.1f)) ///
				ytitle("% of 6-23 months Children", size(small) height(-6))								///
				title("Proportion of Children Met Minimum Meal Frequency" "(by Respondent's Education)", 		///
						justification(left) color(black) span pos(11) size(medium)) 							///
				plotregion(fcolor(white)) 														///
				graphregion(fcolor(white)) ///
				note(	"", size(vsmall) span)
				
	graph export "$plots/PN_Paper_Child_Nutrition/04_MMF_by_Edu.png", replace
	
	
	graph bar 	mmf_pct [aweight = weight_final], over(wempo_category) ///
				${graph_opts1} ///
				blabel(bar, format(%9.1f)) ///
				ytitle("% of 6-23 months Children", size(small) height(-6))								///
				title("Proportion of Children Met Minimum Meal Frequency" "(by Women Empowerment)", 		///
						justification(left) color(black) span pos(11) size(medium)) 							///
				plotregion(fcolor(white)) 														///
				graphregion(fcolor(white)) ///
				note(	"", size(vsmall) span)
				
	graph export "$plots/PN_Paper_Child_Nutrition/04_MMF_by_WomenEmpowerment.png", replace
	
	// mdd
	gen mad_pct = mad * 100
	
	graph bar 	mad_pct [aweight = weight_final], over(NationalQuintile) ///
				${graph_opts1} ///
				blabel(bar, format(%9.1f)) ///
				ytitle("% of 6-23 months Children", size(small) height(-6))								///
				title("Proportion of Children Met Minimum Acceptable Diet" "(by Wealth Quintile)", 		///
						justification(left) color(black) span pos(11) size(medium)) 							///
				plotregion(fcolor(white)) 														///
				graphregion(fcolor(white)) ///
				note(	"", size(vsmall) span)
				
	graph export "$plots/PN_Paper_Child_Nutrition/05_MAD_by_Wealth.png", replace

	
	graph bar 	mad_pct [aweight = weight_final], over(resp_highedu) ///
				${graph_opts1} ///
				blabel(bar, format(%9.1f)) ///
				ytitle("% of 6-23 months Children", size(small) height(-6))								///
				title("Proportion of Children Met Minimum Acceptable Diet" "(by Respondent's Education)", 		///
						justification(left) color(black) span pos(11) size(medium)) 							///
				plotregion(fcolor(white)) 														///
				graphregion(fcolor(white)) ///
				note(	"", size(vsmall) span)
				
	graph export "$plots/PN_Paper_Child_Nutrition/05_MAD_by_Edu.png", replace
	
	
	graph bar 	mad_pct [aweight = weight_final], over(wempo_category) ///
				${graph_opts1} ///
				blabel(bar, format(%9.1f)) ///
				ytitle("% of 6-23 months Children", size(small) height(-6))								///
				title("Proportion of Children Met Minimum Acceptable Diet" "(by Women Empowerment)", 		///
						justification(left) color(black) span pos(11) size(medium)) 							///
				plotregion(fcolor(white)) 														///
				graphregion(fcolor(white)) ///
				note(	"", size(vsmall) span)
				
	graph export "$plots/PN_Paper_Child_Nutrition/05_MAD_by_WomenEmpowerment.png", replace
	
	
	
	****************************************************************************
	* Child Health Data *
	****************************************************************************

	use "$dta/pnourish_child_health_final.dta", clear 
	
	merge m:1 _parent_index using "$dta/pnourish_WOMEN_EMPOWER_final.dta", keepusing(wempo_index)
	
	drop if _merge == 2 
	drop _merge 

	
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	* generate the interaction variable - stratum Vs quantile 
	gen NationalQuintile_stratum  =   NationalQuintile*stratum 

	/*
	
	 - for vaccinations, we wanted to look at the change in "ever vaccinated" for our households, not just compare with mcct baseline. Can we do this/have we done, for children under 1, under 2 (since coup) or older? Can we also map this and write a bit more in the section? It was an area of interest for EHOs.

	*/
	
	recode child_age_month (0/11 = 1)(12/23 = 2)(24/35 = 3)(36/47 = 4)(48/59 = 5), gen(child_age_yrs)
	tab child_age_yrs, m 
	

	** Child Birth Weight **
	svy: mean child_vita 
	svy: mean child_deworm 
	svy: mean child_vaccin 
	svy: mean child_vaccin_card 
	svy: mean child_bwt_lb 
	svy: mean child_low_bwt
	
	* cross-tab 
	// child_vita
	svy: tab stratum_num child_vita, row 
	svy: tab NationalQuintile child_vita, row 
	svy: tab child_age_yrs child_vita if child_age_yrs < 3 & child_age_month >= 6 & !mi(child_age_month), row 
	svy: reg child_vita child_age_yrs i.org_name_num stratum if child_age_yrs < 3 & child_age_month >= 6 & !mi(child_age_month)

	// child_deworm
	svy: tab stratum_num child_deworm, row 
	svy: tab NationalQuintile child_deworm, row 
	svy: tab child_age_yrs child_deworm if child_age_yrs < 3 & child_age_month >= 6 & !mi(child_age_month), row 
	svy: reg child_deworm child_age_yrs i.org_name_num stratum if child_age_yrs < 3 & child_age_month >= 6 & !mi(child_age_month)

	// child_vaccin  
	svy: tab stratum_num child_vaccin, row 
	svy: tab NationalQuintile child_vaccin, row 
	svy: tab child_age_yrs child_vaccin, row 
	svy: reg child_vaccin child_age_yrs i.org_name_num stratum 

	// child_vaccin_card 
	svy: tab stratum_num child_vaccin_card, row 
	svy: tab NationalQuintile child_vaccin_card, row 
	svy: tab child_age_yrs child_vaccin_card, row 
	svy: reg child_vaccin_card child_age_yrs i.org_name_num stratum 
	svy: reg child_vaccin_card child_age_yrs i.org_name_num stratum if child_age_yrs < 3 

	// child_bwt_lb 
	svy: mean child_bwt_lb, over(stratum_num)
	svy: reg child_bwt_lb i.stratum_num
	
	svy: mean child_bwt_lb, over(NationalQuintile)
	svy: reg child_bwt_lb i.NationalQuintile

	// child_low_bwt  
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row 
	svy: tab child_age_yrs child_low_bwt, row 

	
	svy: tab hhitems_phone child_vita, row 
	svy: tab prgexpo_pn child_vita, row 
	svy: tab edu_exposure child_vita, row 
	
	svy: tab hhitems_phone child_deworm, row 
	svy: tab prgexpo_pn child_deworm, row 
	svy: tab edu_exposure child_deworm, row 
	
	svy: tab hhitems_phone child_vaccin, row 
	svy: tab prgexpo_pn child_vaccin, row 
	svy: tab edu_exposure child_vaccin, row 

	svy: tab hhitems_phone child_vaccin_card, row 
	svy: tab prgexpo_pn child_vaccin_card, row 
	svy: tab edu_exposure child_vaccin_card, row 
	
	svy: mean child_bwt_lb, over(wealth_quintile_ns)
	svy: mean child_bwt_lb, over(wealth_quintile_modify)
	
	foreach var of varlist child_vita child_deworm child_vaccin child_vaccin_card  child_low_bwt {
	    
		di "`var'"
		
		svy: tab wealth_quintile_ns `var', row
	
	}
	
	foreach var of varlist child_vita child_deworm child_vaccin child_vaccin_card  child_low_bwt {
	    
		di "`var'"
		
		svy: tab wealth_quintile_modify `var', row
	
	}	
	
	
	
	gen stratum_org_inter = stratum * org_name_num  
	gen KDHW = (stratum_num == 5)
	
	local outcome child_bwt_lb
	* Concentration Index - relative 
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(2 44)
		}
	
	}	
	
	* Concentration Index - absolute
 	local outcome child_bwt_lb
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
	

	estout `outcome' using "$out/reg_output/06_child_bweight_table.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	
	foreach v in `outcome' {
		
		svy: reg `v' KDHW i.org_name_num##stratum  
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/06_child_bweight_table_m2.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	   
	local outcome 	child_vita child_deworm child_vaccin child_vaccin_card  child_low_bwt
	* Concentration Index - relative 
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}
	
	* Concentration Index - absolute
 	local outcome child_vita child_deworm child_vaccin child_vaccin_card  child_low_bwt
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
	

	estout `outcome' using "$out/reg_output/07_child_health_table.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	foreach v in `outcome' {
		
		svy: logit `v' KDHW i.org_name_num##stratum  
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/07_child_health_table_m2.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	   
	* illness *
	
	svy: mean child_ill0 
	svy: mean child_ill1 
	svy: mean child_ill2 
	svy: mean child_ill3 
	svy: mean child_ill888

	// child_ill0 
	svy: tab stratum_num child_ill0, row 
	svy: tab NationalQuintile child_ill0, row 
	
	// child_ill1 
	svy: tab stratum_num child_ill1, row 
	svy: tab NationalQuintile child_ill1, row 
	
	// child_ill2 
	svy: tab stratum_num child_ill2, row 
	svy: tab NationalQuintile child_ill2, row 
	
	// child_ill3 
	svy: tab stratum_num child_ill3, row 
	svy: tab NationalQuintile child_ill3, row 
	
	// child_ill888
	svy: tab stratum_num child_ill888, row 
	svy: tab NationalQuintile child_ill888, row 
	
	
	foreach var of varlist child_ill0 child_ill1 child_ill2 child_ill3 child_ill888 {
	    
		di "`var'"
		
		svy: tab wealth_quintile_ns `var', row
	
	}
	
	
	
	foreach var of varlist child_ill0 child_ill1 child_ill2 child_ill3 child_ill888 {
	    
		di "`var'"
		
		svy: tab wealth_quintile_modify `var', row
	
	}	
	
	
	local outcome  child_ill0 child_ill1 child_ill2 child_ill3 child_ill888
	* Concentration Index - relative 
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}

	
	* Concentration Index - absolute
 	local outcome child_ill0 child_ill1 child_ill2 child_ill3 child_ill888
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
	

	estout `outcome' using "$out/reg_output/08_child_ill_table.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	foreach v in `outcome' {
		
		svy: logit `v' KDHW i.org_name_num##stratum  
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/08_child_ill_table_m2.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	   
	***** DIARRHEA *****
	// child_diarrh_treat
	svy: mean child_diarrh_treat
	svy: tab stratum_num child_diarrh_treat, row 
	svy: tab NationalQuintile child_diarrh_treat, row 
	
	svy: reg child_diarrh_treat hfc_near_dist_dry 
	svy: reg child_diarrh_treat hfc_near_dist_rain 
	
	
	// child_diarrh_where
	svy: tab child_diarrh_where,ci
	svy: tab stratum_num child_diarrh_where, row 
	svy: tab NationalQuintile child_diarrh_where, row 
	svy: tab wealth_quintile_ns child_diarrh_where, row 
	
	// child_diarrh_who
	svy: tab child_diarrh_who,ci 
	svy: tab stratum_num child_diarrh_who, row 
	svy: tab NationalQuintile child_diarrh_who, row 
	svy: tab wealth_quintile_ns child_diarrh_who, row 
	
	// child_diarrh_trained 
	svy: mean child_diarrh_trained
	svy: tab stratum_num child_diarrh_trained, row 
	svy: tab NationalQuintile child_diarrh_trained, row 

	svy: reg child_diarrh_trained hfc_near_dist_dry 
	svy: reg child_diarrh_trained hfc_near_dist_rain 

	// child_diarrh_notreat
	svy: mean child_diarrh_notreat1 child_diarrh_notreat2 child_diarrh_notreat3 child_diarrh_notreat4 child_diarrh_notreat5 child_diarrh_notreat6 child_diarrh_notreat7 child_diarrh_notreat8 child_diarrh_notreat9 child_diarrh_notreat10 child_diarrh_notreat11 child_diarrh_notreat12 child_diarrh_notreat13 child_diarrh_notreat14 child_diarrh_notreat15 child_diarrh_notreat888 child_diarrh_notreat777 child_diarrh_notreat999
	
	
	// child_diarrh_pay
	svy: mean child_diarrh_pay
	svy: tab stratum_num child_diarrh_pay, row 
	svy: tab NationalQuintile child_diarrh_pay, row 
	
	// child_diarrh_cope
	svy: mean child_diarrh_cope1 child_diarrh_cope2 child_diarrh_cope3 child_diarrh_cope4 child_diarrh_cope5 child_diarrh_cope6 child_diarrh_cope7 child_diarrh_cope8 child_diarrh_cope9 child_diarrh_cope10 child_diarrh_cope11 child_diarrh_cope12 child_diarrh_cope13 child_diarrh_cope14 child_diarrh_cope888 child_diarrh_cope666
	
	
	foreach var of varlist child_diarrh_treat child_diarrh_trained child_diarrh_pay {
	    
		di "`var'"
		
		svy: tab wealth_quintile_ns `var', row
	
	}
	
	
	local outcome child_diarrh_treat child_diarrh_trained child_diarrh_pay
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}
	
	foreach v in `outcome' {
		
		svy: logit `v' KDHW stratum org_name_num 
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/09_child_diarrhea_table.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	foreach v in `outcome' {
		
		svy: logit `v' KDHW i.org_name_num## stratum  
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/09_child_diarrhea_table_m2.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	   
	***** COUGH *****
	// child_cough_treat
	svy: mean child_cough_treat
	svy: tab stratum_num child_cough_treat, row 
	svy: tab NationalQuintile child_cough_treat, row 
	
	svy: reg child_cough_treat hfc_near_dist_dry 
	svy: reg child_cough_treat hfc_near_dist_rain 
	
	// child_cough_where
	svy: tab child_cough_where,ci
	svy: tab stratum_num child_cough_where, row 
	svy: tab NationalQuintile child_cough_where, row 
	svy: tab wealth_quintile_ns child_cough_where, row 
	
	
	// child_cough_who
	svy: tab child_cough_who,ci
	svy: tab stratum_num child_cough_who, row 
	svy: tab NationalQuintile child_cough_who, row 
	svy: tab wealth_quintile_ns child_cough_who, row 
	
	// child_cough_trained 
	svy: mean child_cough_trained
	svy: tab stratum_num child_cough_trained, row 
	svy: tab NationalQuintile child_cough_trained, row 

	svy: reg child_cough_trained hfc_near_dist_dry 
	svy: reg child_cough_trained hfc_near_dist_rain 
	
	// child_cough_notreat
	svy: mean child_cough_notreat1 child_cough_notreat2 child_cough_notreat3 child_cough_notreat4 child_cough_notreat5 child_cough_notreat6 child_cough_notreat7 child_cough_notreat8 child_cough_notreat9 child_cough_notreat10 child_cough_notreat11 child_cough_notreat12 child_cough_notreat13 child_cough_notreat14 child_cough_notreat15 child_cough_notreat888 child_cough_notreat777 child_cough_notreat999
	
	// child_cough_pay
	svy: mean child_cough_pay
	svy: tab stratum_num child_cough_pay, row 
	svy: tab NationalQuintile child_cough_pay, row
	
	// child_cough_cope
	svy: mean child_cough_cope1 child_cough_cope2 child_cough_cope3 child_cough_cope4 child_cough_cope5 child_cough_cope6 child_cough_cope7 child_cough_cope8 child_cough_cope9 child_cough_cope10 child_cough_cope11 child_cough_cope12 child_cough_cope13 child_cough_cope14 child_cough_cope888 child_cough_cope666
	
	
	foreach var of varlist child_cough_treat child_cough_trained child_cough_pay {
	    
		di "`var'"
		
		svy: tab wealth_quintile_ns `var', row
	
	}	
	
	
	local outcome child_cough_treat child_cough_trained child_cough_pay
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}
	
	foreach v in `outcome' {
		
		svy: logit `v' KDHW stratum org_name_num 
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/10_child_cough_table.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	foreach v in `outcome' {
		
		svy: logit `v' KDHW i.org_name_num##stratum  
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/10_child_cough_table_m2.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace	   
	
	***** FEVER *****
	// child_fever_treat, m 
	svy: mean  child_fever_treat
	svy: tab stratum_num child_fever_treat, row 
	svy: tab NationalQuintile child_fever_treat, row

	svy: reg child_fever_treat hfc_near_dist_dry 
	svy: reg child_fever_treat hfc_near_dist_rain 
	
	// child_fever_where, m 
	svy: tab child_fever_where, ci 
	svy: tab stratum_num child_fever_where, row 
	svy: tab NationalQuintile child_fever_where, row
	svy: tab wealth_quintile_ns child_fever_where, row
	
	// child_fever_who  
	svy: tab child_fever_who, ci
	svy: tab stratum_num child_fever_who, row 
	svy: tab NationalQuintile child_fever_who, row
	svy: tab wealth_quintile_ns child_fever_who, row
	
	// child_fever_trained
	svy: mean child_fever_trained
	svy: tab stratum_num child_fever_trained, row 
	svy: tab NationalQuintile child_fever_trained, row

	svy: reg child_fever_trained hfc_near_dist_dry 
	svy: reg child_fever_trained hfc_near_dist_rain 
	
	// child_fever_notreat
	svy: mean child_fever_notreat1 child_fever_notreat2 child_fever_notreat3 child_fever_notreat4 child_fever_notreat5 child_fever_notreat6 child_fever_notreat7 child_fever_notreat8 child_fever_notreat9 child_fever_notreat10 child_fever_notreat11 child_fever_notreat12 child_fever_notreat13 child_fever_notreat14 child_fever_notreat15 child_fever_notreat888 child_fever_notreat777 child_fever_notreat999
	
	
	// child_fever_pay
	svy: mean child_fever_pay
	svy: tab stratum_num child_fever_pay, row 
	svy: tab NationalQuintile child_fever_pay, row
	
	// child_fever_cope
	svy: mean child_fever_cope1 child_fever_cope2 child_fever_cope3 child_fever_cope4 child_fever_cope5 child_fever_cope6 child_fever_cope7 child_fever_cope8 child_fever_cope9 child_fever_cope10 child_fever_cope11 child_fever_cope12 child_fever_cope13 child_fever_cope14 child_fever_cope888 child_fever_cope666
	
	
	svy: tab hhitems_phone child_diarrh_trained, row 
	svy: tab prgexpo_pn child_diarrh_trained, row 
	svy: tab edu_exposure child_diarrh_trained, row 

	svy: tab hhitems_phone child_cough_trained, row 
	svy: tab prgexpo_pn child_cough_trained, row 
	svy: tab edu_exposure child_cough_trained, row 

	svy: tab hhitems_phone child_fever_trained, row 
	svy: tab prgexpo_pn child_fever_trained, row 
	svy: tab edu_exposure child_fever_trained, row 

	
	foreach var of varlist child_fever_treat child_fever_trained child_fever_pay {
	    
		di "`var'"
		
		svy: tab wealth_quintile_ns `var', row
	
	}	
	
	
	foreach var of varlist child_fever_treat child_fever_trained child_fever_pay {
	    
		di "`var'"
		
		svy: tab wealth_quintile_ns `var', row
	
	}
	
	
	local outcome child_fever_treat child_fever_trained child_fever_pay
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}
	
	
	foreach v in `outcome' {
		
		svy: logit `v' KDHW stratum org_name_num 
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/11_child_fever_table.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	foreach v in `outcome' {
		
		svy: logit `v' KDHW i.org_name_num##stratum  
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/11_child_fever_table_m2.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	   
	* Childhood illness vs WASH 
	merge m:1 _parent_index using "$dta/pnourish_WASH_final.dta"    
	
	drop if _merge == 2
	drop _merge 
	
	// Sanitation Ladder and illness
	svy: tab sanitation_ladder child_ill1, row 
	svy: tab water_winter_ladder child_ill1, row 

	// Handwashing - critical time with soap 
	svy: tab hw_critical_soap child_ill1, row 
	svy: tab hw_critical_soap child_ill2, row 
	svy: tab hw_critical_soap child_ill3, row 

	
	
	* Child Health ALL *
	local outcome	child_vita child_deworm child_vaccin child_vaccin_card  child_low_bwt ///
					child_ill1 child_ill2 child_ill3 ///
					child_diarrh_trained child_cough_trained child_fever_trained 
	
	foreach v in `outcome' {
		
		svy: reg `v' wempo_index NationalQuintile stratum NationalQuintile_stratum i.org_name_num
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/11_child_health_FINAL.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	
	
	// Model 4
	local outcome	child_vita child_deworm child_vaccin child_vaccin_card child_low_bwt ///
					child_ill1 child_ill2 child_ill3 ///
					child_diarrh_trained child_cough_trained child_fever_trained 
	foreach v in `outcome' {
		
		svy: logit `v' i.NationalQuintile i.org_name_num i.NationalQuintile stratum wempo_index
		//eststo model_B
		estimates store `v', title(`v')
		
	}
		
		estout `outcome' using "$out/reg_output/FINAL_Child_Model_4_logistic.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
		   legend label varlabels(_cons constant)              ///
		   stats(r2 df_r bic) replace	
	
	
	foreach v in `outcome' {
		
		svy: logit `v' i.wealth_quintile_ns i.org_name_num i.wealth_quintile_ns stratum wempo_index
		//eststo model_B
		estimates store `v', title(`v')
		
	}
		
		estout `outcome' using "$out/reg_output/FINAL_Child_Model_4_logistic_PNDist.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
		   legend label varlabels(_cons constant)              ///
		   stats(r2 df_r bic) replace	
	
	
	
// END HERE 



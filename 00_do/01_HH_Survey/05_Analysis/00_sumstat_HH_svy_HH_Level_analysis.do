/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: Data analysis - HH Level			
Author				:	Nicholus Tint Zaw
Date				: 	03/01/2023
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

	****************************************************************************
	* Respondent Characteristics *
	****************************************************************************

	use "$dta/pnourish_respondent_info_final.dta", clear   

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	
	* stratum 
	svy: tab stratum_num, ci 
	
	** respondent characteristics ** 
	svy: tab respd_who, ci 
	
	svy: mean respd_age
	svy: tab respd_status, ci 
	svy: tab respd_preg, ci 
	svy: tab respd_chid_num, ci 
	svy: mean respd_chid_num 
	svy: tab respd_phone, ci 

	svy: tab resp_hhhead, ci 
	svy: tab resp_highedu, ci 
	svy: tab hh_mem_highedu_all, ci 
	svy: tab resp_occup, ci 
		
	svy: tab hhitems_phone, ci 
	svy: tab prgexpo_pn, ci 
	svy: tab edu_exposure, ci 
	
	** HH Characteristics **
	svy: mean hh_tot_num
	
	svy: tab NationalQuintile, ci 
	svy: tab wealth_quintile_ns, ci 
	svy: tab wealth_quintile_modify, ci 
	

	* cross-tab 
	// phone 
	svy: tab stratum_num resp_highedu, row 
	svy: tab NationalQuintile resp_highedu, row 

	svy: tab stratum_num hh_mem_highedu_all, row 
	svy: tab NationalQuintile hh_mem_highedu_all, row 

	svy: tab wealth_quintile_ns resp_highedu, row 
	svy: tab wealth_quintile_ns hh_mem_highedu_all, row 

	
	// program exposure 
	svy: tab resp_highedu prgexpo_pn, row 
	svy: tab hh_mem_highedu_all prgexpo_pn, row 

	
	****************************************************************************
	* HH Income *
	****************************************************************************

	use "$dta/pnourish_INCOME_WEALTH_final.dta", clear   

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)
	
	/*
	xtile wealth_quintile_ns = NationalScore [pweight=weight_final], nq(5)
	xtile wealth_quintile_inc = d3_inc_lmth [pweight=weight_final], nq(5)
	lab def w_quintile 1"Poorest" 2"Poor" 3"Medium" 4"Wealthy" 5"Wealthiest"
	lab val wealth_quintile_ns wealth_quintile_inc w_quintile
	lab var wealth_quintile_ns "Wealth Quintiles by PN pop-based EquityTool national score distribution"
	lab var wealth_quintile_inc "Wealth Quintiles by last month income"
	tab1 wealth_quintile_ns wealth_quintile_inc, m 
	
	tab NationalQuintile wealth_quintile_ns
	*/
	
	* HH mobile phone ownership by quintiles 
	
	//xtile wealth_10pct_ns_noph = NationalScore_noph [pweight=weight_final], nq(20)
	xtile wealth_10pct_inc = income_lastmonth_trim [pweight=weight_final], nq(100) // d3_inc_lmth
	xtile wealth_10pct_ns = NationalScore [pweight=weight_final], nq(40)
	
	// replace income_lastmonth_trim = .m if d3_inc_lmth
	// pctile pct = income_lastmonth_trim [pweight = weight_final], nq(40)
	
	// NationalScore
	// NationalScore_noph
	
	//svy: tab wealth_10pct_ns_noph hhitems_phone, row
	svy: tab wealth_10pct_ns hhitems_phone, row
	svy: tab wealth_10pct_inc hhitems_phone, row
	
	svy: tab NationalScore hhitems_phone, row
	svy: tab NationalScore_noph hhitems_phone, row
	svy: tab d3_inc_lmth hhitems_phone, row
	
	svy: tab wealth_quintile_ns
	svy: tab NationalQuintile wealth_quintile_ns

	//svy: tab wealth_quintile_inc
	//svy: tab NationalQuintile wealth_quintile_inc
	
	
	** Dummy Variable - based on percentile vs mobile phone ** 
	gen wealth_10pct_ns_cut1 = (wealth_10pct_ns < 7.5)
	gen wealth_10pct_ns_cut2 = (wealth_10pct_ns < 17.5)
	replace wealth_10pct_ns_cut1 = .m if mi(wealth_10pct_ns)
	replace wealth_10pct_ns_cut2 = .m if mi(wealth_10pct_ns)
	
	svy: tab wealth_10pct_ns_cut1 hhitems_phone, row 
	svy: tab wealth_10pct_ns_cut2 hhitems_phone, row 
	
	
	svy: mean d3_inc_lmth, over(wealth_quintile_ns)

	
	svy: mean d3_inc_lmth
	svy: mean income_lastmonth_trim
	
	svy: tab d4_inc_status, ci 
	
	// d5_reason
	local reasons 	d5_reason1 d5_reason2 d5_reason3 d5_reason4 d5_reason5 d5_reason6 ///
					d5_reason7 d5_reason8 d5_reason9 d5_reason10 d5_reason11 d5_reason12 ///
					d5_reason13 d5_reason14 d5_reason15 d5_reason16 d5_reason17 d5_reason18 d5_reason99
	
	svy: mean `reasons'

	// d6_cope
	local copes d6_cope1 d6_cope2 d6_cope3 d6_cope4 d6_cope5 d6_cope6 d6_cope7 ///
				d6_cope8 d6_cope9 d6_cope10 d6_cope11 d6_cope12 d6_cope13 d6_cope14 ///
				d6_cope15 d6_cope16 d6_cope17 d6_cope18 d6_cope19 d6_cope20 d6_cope99
	
	svy: mean `copes'

	svy: tab jan_incom_status, ci 
	svy: tab thistime_incom_status, ci 
	svy: tab d7_inc_govngo, ci 
	
	
	* cross-tab 
	svy: tab stratum_num NationalQuintile, row 
	svy: tab stratum_num wealth_quintile_ns, row 
	
	svy: mean d3_inc_lmth, over(stratum_num)
	svy: reg d3_inc_lmth i.stratum_num
	
	svy: mean d3_inc_lmth, over(NationalQuintile)
	svy: reg d3_inc_lmth i.NationalQuintile

	// phone 
	svy: tab stratum_num hhitems_phone, row 
	svy: tab NationalQuintile hhitems_phone, row 

	// program exposure 
	svy: tab stratum_num prgexpo_pn, row 
	svy: tab NationalQuintile prgexpo_pn, row 

	// sbcc exposure 
	svy: tab stratum_num edu_exposure, row 
	svy: tab NationalQuintile edu_exposure, row 

	svy: tab wealth_quintile_ns hhitems_phone, row 
	svy: tab wealth_quintile_ns prgexpo_pn, row 
	svy: tab wealth_quintile_ns edu_exposure, row 

	
	// income 			
	svy: reg d3_inc_lmth i.stratum_num
	mat list e(b)
	test 1b.stratum_num = 2.stratum_num = 3.stratum_num = 4.stratum_num = 5.stratum_num
			
	svy: reg d3_inc_lmth i.NationalQuintile
	mat list e(b)
	test 1b.NationalQuintile = 2.NationalQuintile = 3.NationalQuintile = 4.NationalQuintile = 5.NationalQuintile
		


	
	****************************************************************************
	** WASH **
	****************************************************************************

	use "$dta/pnourish_WASH_final.dta", clear   

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	
	** Drinking Water Ladder **
	// water_sum 
	svy: tab water_sum, ci 
	
	// water_rain 
	svy: tab water_rain, ci 
	
	// water_winter 
	svy: tab water_winter, ci 

	// water_sum_ladder 
	svy: tab water_sum_ladder, ci 
	svy: tab stratum_num water_sum_ladder, row 
	svy: tab NationalQuintile water_sum_ladder, row
	
	// water_rain_ladder 
	svy: tab water_rain_ladder, ci 
	svy: tab stratum_num water_rain_ladder, row 
	svy: tab NationalQuintile water_rain_ladder, row
	
	// water_winter_ladder
	svy: tab water_winter_ladder, ci 
	svy: tab stratum_num water_winter_ladder, row 
	svy: tab NationalQuintile water_winter_ladder, row


	svy: tab hhitems_phone water_sum_ladder, row 
	svy: tab hhitems_phone water_rain_ladder, row 
	svy: tab hhitems_phone water_winter_ladder, row 
	
	svy: tab prgexpo_pn water_sum_ladder, row 	
	svy: tab prgexpo_pn water_rain_ladder, row 	
	svy: tab prgexpo_pn water_winter_ladder, row 	

	svy: tab edu_exposure water_sum_ladder, row 
	svy: tab edu_exposure water_rain_ladder, row 
	svy: tab edu_exposure water_winter_ladder, row 
	
	svy: tab wealth_quintile_ns water_sum_ladder
	svy: tab wealth_quintile_ns water_rain_ladder
	svy: tab wealth_quintile_ns water_winter_ladder

	
	** Sanitation Ladder ** 
	// latrine_type
	svy: tab latrine_type, ci 
	
	// sanitation_ladder 
	svy: tab sanitation_ladder, ci 
	svy: tab stratum_num sanitation_ladder, row 
	svy: tab NationalQuintile sanitation_ladder, row
	
	
	svy: tab hhitems_phone sanitation_ladder, row 
	svy: tab prgexpo_pn sanitation_ladder, row 	
	svy: tab edu_exposure sanitation_ladder, row 
	
	svy: tab wealth_quintile_ns sanitation_ladder

	** Hygiene Ladder ** 
	// hw_ladder
	svy: tab hw_ladder, ci 
	svy: tab stratum_num hw_ladder, row 
	svy: tab NationalQuintile hw_ladder, row
	
	svy: tab hhitems_phone hw_ladder, row 
	svy: tab prgexpo_pn hw_ladder, row 	
	svy: tab edu_exposure hw_ladder, row 
	
	svy: tab wealth_quintile_ns hw_ladder

	** Handwashing at Critical Time ** 
	// soap_yn
	svy: tab soap_yn, ci 
	svy: tab stratum_num soap_yn, row 
	svy: tab NationalQuintile soap_yn, row


	// frequency 
	/* soap_tiolet soap_clean_baby soap_child_faeces ///
							soap_before_eat soap_before_cook soap_feed_child ///
							soap_handle_child */
	

	svy: tab hw_critical_soap, ci 
	svy: tab stratum_num hw_critical_soap, row 
	svy: tab NationalQuintile hw_critical_soap, row					

	svy: tab hhitems_phone hw_critical_soap, row 
	svy: tab prgexpo_pn hw_critical_soap, row 	
	svy: tab edu_exposure hw_critical_soap, row 

	svy: tab wealth_quintile_ns soap_yn
	svy: tab wealth_quintile_ns hw_critical_soap

	** Water Treatment **
	// water_sum_treat water_rain_treat water_winter_treat
	svy: mean water_sum_treat water_rain_treat water_winter_treat
	
	// watertx_sum_good 
	svy: tab watertx_sum_good, ci 
	svy: tab stratum_num watertx_sum_good, row 
	svy: tab NationalQuintile watertx_sum_good, row
	
	// watertx_rain_good 
	svy: tab watertx_rain_good, ci 
	svy: tab stratum_num watertx_rain_good, row 
	svy: tab NationalQuintile watertx_rain_good, row
	
	// watertx_winter_good
	svy: tab watertx_winter_good, ci 
	svy: tab stratum_num watertx_winter_good, row 
	svy: tab NationalQuintile watertx_winter_good, row
	
	svy: tab wealth_quintile_ns watertx_sum_good
	svy: tab wealth_quintile_ns watertx_rain_good
	svy: tab wealth_quintile_ns watertx_winter_good

	** Water Pot ** 
	// waterpot_yn
	svy: tab waterpot_yn, ci 
	svy: tab stratum_num waterpot_yn, row 
	svy: tab NationalQuintile waterpot_yn, row

	svy: tab wealth_quintile_ns waterpot_yn, row 
	
	// waterpot_capacity
	svy: mean  waterpot_capacity

	
	// waterpot_condition
	tab1 waterpot_condition1 waterpot_condition2 waterpot_condition3 waterpot_condition4 waterpot_condition0, m 
	
	svy: mean 	waterpot_condition1 waterpot_condition2 waterpot_condition3 ///
				waterpot_condition4 waterpot_condition0
	
	svy: mean 	waterpot_condition1 waterpot_condition2 waterpot_condition3 ///
				waterpot_condition4 waterpot_condition0, over(stratum_num)
	
	foreach var of varlist 	waterpot_condition1 waterpot_condition2 waterpot_condition3 ///
							waterpot_condition4 waterpot_condition0 {
		
		svy: tab stratum_num `var', row 
	}
	
	svy: mean 	waterpot_condition1 waterpot_condition2 waterpot_condition3 ///
				waterpot_condition4 waterpot_condition0, over(NationalQuintile)
	
	foreach var of varlist 	waterpot_condition1 waterpot_condition2 waterpot_condition3 ///
							waterpot_condition4 waterpot_condition0 {
		
		svy: tab NationalQuintile `var', row 
	}
	
	 
	foreach var of varlist 	waterpot_condition1 waterpot_condition2 waterpot_condition3 ///
							waterpot_condition4 waterpot_condition0 {
		
		svy: tab wealth_quintile_ns `var', row 
	} 

		
		
	replace prgexpo_pn = 0 if prgexpo_pn == 999
	
	svy: tab hhitems_phone water_sum_ladder, row 
	svy: tab prgexpo_pn water_sum_ladder, row 	

	svy: tab hhitems_phone sanitation_ladder, row 
	svy: tab prgexpo_pn sanitation_ladder, row 	

	svy: tab hhitems_phone hw_ladder, row 
	svy: tab prgexpo_pn hw_ladder, row 	

	
	****************************************************************************
	** FIES **
	****************************************************************************

	use "$dta/pnourish_FIES_final.dta", clear   

	// get the women empowerment index 
	merge 1:1 uuid using "$dta/pnourish_WOMEN_EMPOWER_final.dta", keepusing(wempo_index progressivenss)  
	drop _merge 
	
	* FIES - food insecurity dummy outcome * 
	* cutoffs for the raw score of 4+ = food insecurity 
	gen fies_insecurity = (fies_rawscore >= 4) 
	replace fies_insecurity = .m if mi(fies_rawscore)
	lab def fies_insecurity 0"Food secure" 1"Food insecue"
	lab val fies_insecurity fies_insecurity
	tab fies_insecurity, m 
	
	* treated other and monestic education as missing
	gen resp_highedu_ci = resp_highedu
	replace resp_highedu_ci = .m if resp_highedu_ci > 7 
	tab resp_highedu_ci, m 
	
	replace resp_highedu = .m if resp_highedu > 7 
	replace resp_highedu = 4 if resp_highedu > 4 & !mi(resp_highedu)
	tab resp_highedu, m 
	
	
	replace hh_mem_highedu_all = 4 if hh_mem_highedu_all > 4 & !mi(hh_mem_highedu_all)
	tab hh_mem_highedu_all, m 
	
	* Interaction term 
	gen wempo_index_inter_wealth = wempo_index * NationalScore
	lab var wempo_index_inter_wealth "Women Empowerment Index * Health EquityTool National Score"
	
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)
	
	* fies category 
	svy: tab fies_category, ci 
	svy: tab stratum_num fies_category, row 
	svy: tab NationalQuintile fies_category, row
	svy: tab wealth_quintile_modify fies_category, row

	// fies_rawscore
	svy: mean  fies_rawscore

	svy: mean fies_rawscore, over(stratum_num)
	svy: reg fies_rawscore i.stratum_num
	
	svy: mean fies_rawscore, over(NationalQuintile)
	svy: reg fies_rawscore i.NationalQuintile
	
	svy: mean fies_insecurity
	svy: mean fies_insecurity, over(NationalQuintile)
	conindex fies_insecurity, rank(NationalQuintile) svy wagstaff bounded limits(0 1)

	
	svy: mean fies_rawscore, over(hhitems_phone)
	test _b[c.fies_rawscore@0bn.hhitems_phone] = _b[c.fies_rawscore@1bn.hhitems_phone]

	svy: mean fies_rawscore, over(prgexpo_pn)
	test _b[c.fies_rawscore@0bn.prgexpo_pn] = _b[c.fies_rawscore@1bn.prgexpo_pn]

	svy: mean fies_rawscore, over(edu_exposure)
	test _b[c.fies_rawscore@0bn.edu_exposure] = _b[c.fies_rawscore@1bn.edu_exposure]

	svy: tab wealth_quintile_ns fies_category, row 
	svy: mean fies_rawscore, over(wealth_quintile_ns)
	svy: mean fies_rawscore, over(wealth_quintile_modify)
	
	
	* Concentration Index - relative 
	foreach var of varlist fies_rawscore {
	    
		di "`var'"		
		conindex `var', rank(NationalQuintile) svy wagstaff bounded limits(0 8)
	
	}
	
	
	* Concentration Index - absolute 
	foreach var of varlist fies_rawscore {
	    
		di "`var'"		
		conindex `var', rank(NationalQuintile) svy truezero generalized
	
	}
	
	
	svy: logit fies_insecurity wempo_index
	svy: reg fies_rawscore wempo_index

	svy: tab hhitems_phone fies_insecurity, row 
	svy: logit fies_insecurity hhitems_phone

	svy: tab resp_highedu fies_insecurity, row 
	svy: logit fies_insecurity i.resp_highedu

	svy: tab stratum_num fies_insecurity, row 
	svy: logit fies_insecurity i.stratum_num
	
	svy: tab NationalQuintile fies_insecurity, row 
	svy: logit fies_insecurity i.NationalQuintile

	svy: tab org_name_num fies_insecurity, row 
	svy: tab stratum fies_insecurity, row 

	svy: tab hh_mem_highedu_all fies_insecurity, row 

	svy: tab resp_hhhead fies_insecurity, row 
	svy: tab progressivenss fies_insecurity, row 
		
		
	svy: mean income_lastmonth, over(fies_insecurity)
	svy: mean wempo_index, over(fies_insecurity)

	
	conindex fies_insecurity, rank(NationalQuintile) svy wagstaff bounded limits(0 1)
	
	
	local regressor  hhitems_phone resp_highedu org_name_num stratum NationalQuintile hh_mem_highedu_all resp_hhhead income_lastmonth wempo_index progressivenss
	
	foreach v in `regressor' {
		
		putexcel set "$out/reg_output/FIES_logistic_models.xls", sheet("`v'") modify 
	
		if "`v'" != "income_lastmonth" & "`v'" != "wempo_index" {
		    svy: logistic fies_insecurity i.`v'
		}
		else {
		    svy: logistic fies_insecurity `v'
		}
		
		estimates store `v', title(`v')
		
		putexcel (A1) = etable
		
	}
		
		
	/*
	Model 1 – HH wealth + [other SES vars eg education gap male/female; education; income… 
	whichever were p<0.1 in crude model – check variance inflation (vif) to guard against collinearity]
	*/
	putexcel set "$out/reg_output/FIES_logistic_models.xls", sheet("model 1") modify
	
	svy: logistic fies_insecurity i.NationalQuintile i.resp_highedu i.org_name_num stratum
	estimates store model1, title(model1)

	putexcel (A1) = etable
	
	/*
	Model 2 – women's empowerment + [whichever SES were significant in 1]
	*/
	
	putexcel set "$out/reg_output/FIES_logistic_models.xls", sheet("model 2") modify

	svy: logistic fies_insecurity wempo_index i.NationalQuintile i.resp_highedu i.org_name_num stratum
	estimates store model2, title(model2)
	
	putexcel (A1) = etable
	
	
	/*
	Model 3 - interaction wealth vs women empowerment - both continious 
	*/	

	putexcel set "$out/reg_output/FIES_logistic_models.xls", sheet("model 3") modify
	
	svy: logistic fies_insecurity wempo_index i.NationalQuintile i.resp_highedu i.org_name_num stratum wempo_index_inter_wealth
	estimates store model3, title(model3)

	putexcel (A1) = etable


	/*
	Model 4 - interaction wealth vs women empowerment - both category 
	*/	
	
	putexcel set "$out/reg_output/FIES_logistic_models.xls", sheet("model 4") modify

	svy: logistic fies_insecurity /*wempo_index*/ i.NationalQuintile##i.progressivenss i.resp_highedu i.org_name_num stratum  
	estimates store model4, title(model4)
	
	putexcel (A1) = etable

	/*
	// not able to export OR, only coefficient 
	estout `regressor' model1 model2 model3 model4 using "$out/reg_output/FIES_logistic_bivariate.xls", cells(b(star fmt(3)) ci(par fmt(2)))  ///
	legend label varlabels(_cons constant)              ///
	stats(r2 df_r bic) replace	
	*/
	
	
	putexcel set "$out/reg_output/FIES_logistic_models.xls", sheet("final model") modify

	svy: logistic fies_insecurity i.NationalQuintile i.resp_highedu i.org_name_num stratum progressivenss

	estimates store model4, title(model4)
	
	putexcel (A1) = etable
	
	// health equitytools national score as rank 
	conindex fies_insecurity, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 fies_insecurity, rank(NationalScore) covars(i.resp_highedu i.org_name_num stratum progressivenss) svy wagstaff bounded limits(0 1)	

	conindex fies_rawscore, rank(NationalScore) svy wagstaff bounded limits(0 8)
	conindex2 fies_rawscore, rank(NationalScore) covars(i.resp_highedu i.org_name_num stratum progressivenss) svy wagstaff bounded limits(0 8)	
	
	// resp edu as rank 
	conindex fies_rawscore, rank(resp_highedu_ci) svy wagstaff bounded limits(0 8)
	conindex2 fies_rawscore, rank(resp_highedu_ci) covars(NationalScore i.org_name_num stratum progressivenss) svy wagstaff bounded limits(0 8)	
	
	conindex fies_insecurity, rank(resp_highedu_ci) svy wagstaff bounded limits(0 1)
	conindex2 fies_insecurity, rank(resp_highedu_ci) covars(NationalScore i.org_name_num stratum progressivenss) svy wagstaff bounded limits(0 1)	

	
	// Women empowerment as rank 
	conindex fies_rawscore, rank(wempo_index) svy wagstaff bounded limits(0 8)
	conindex2 fies_rawscore, rank(wempo_index) covars(NationalScore i.resp_highedu i.org_name_num stratum) svy wagstaff bounded limits(0 8)	
	
	conindex fies_insecurity, rank(wempo_index) svy wagstaff bounded limits(0 1)
	conindex2 fies_insecurity, rank(wempo_index) covars(NationalScore i.resp_highedu i.org_name_num stratum) svy wagstaff bounded limits(0 1)	

	
	
	/*
	Model 3 - adjusted for model 1 vars and [anything else significant a p<0.1 in crude model]
	
	svy: logit fies_insecurity wempo_index i.NationalQuintile i.resp_highedu i.org_name_num##i.stratum


	wempo_index
	hhitems_phone
	resp_highedu
	NationalQuintile
	*/
	
	****************************************************************************
	** Program Exposure **
	****************************************************************************

	use "$dta/pnourish_program_exposure_final.dta", clear   

	// get the women empowerment index 
	merge 1:1 uuid using "$dta/pnourish_WOMEN_EMPOWER_final.dta", keepusing(wempo_index progressivenss)  
	drop _merge 

	
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)
	
	// prgexpo_pn
	svy: mean  prgexpo_pn
	svy: tab stratum_num prgexpo_pn, row 
	svy: tab NationalQuintile prgexpo_pn, row

	svy: tab wealth_quintile_ns prgexpo_pn, row 

	
	// prgexpo_join1 prgexpo_join2 prgexpo_join3 prgexpo_join4 prgexpo_join5 prgexpo_join6 prgexpo_join7 prgexpo_join8 prgexpo_join9
	svy: mean prgexpo_join1 
	svy: mean prgexpo_join2 
	svy: mean prgexpo_join3 
	svy: mean prgexpo_join4 
	svy: mean prgexpo_join5 
	svy: mean prgexpo_join6 
	svy: mean prgexpo_join7 
	svy: mean prgexpo_join8 
	svy: mean prgexpo_join9
				
	foreach var of varlist 	prgexpo_join1 prgexpo_join2 prgexpo_join3 prgexpo_join4 ///
							prgexpo_join5 prgexpo_join6 prgexpo_join7 prgexpo_join8 ///
							prgexpo_join9 {
								
		svy: tab stratum_num `var', row 
		
							}
							
	svy: mean 	prgexpo_join1 prgexpo_join2 prgexpo_join3 prgexpo_join4 prgexpo_join5 ///
				prgexpo_join6 prgexpo_join7 prgexpo_join8 prgexpo_join9, ///
				over(stratum_num)	
	
	foreach var of varlist 	prgexpo_join1 prgexpo_join2 prgexpo_join3 prgexpo_join4 ///
							prgexpo_join5 prgexpo_join6 prgexpo_join7 prgexpo_join8 ///
							prgexpo_join9 {
								
		svy: tab NationalQuintile `var', row 
		
							}
						
	
	foreach var of varlist 	prgexpo_pn prgexpo_join1 prgexpo_join2 prgexpo_join3 prgexpo_join4 ///
							prgexpo_join5 prgexpo_join6 prgexpo_join7 prgexpo_join8 {
					
		di "`var'"
		//svy: tab NationalQuintile `var', row 
		conindex `var', rank(NationalScore) svy wagstaff bounded limits(0 1)
		
		}
							
	sum prgexpo_pn prgexpo_join1 prgexpo_join2 prgexpo_join3 prgexpo_join4 ///
							prgexpo_join5 prgexpo_join6 prgexpo_join7 prgexpo_join8				
	
	svy: mean 	prgexpo_join1 prgexpo_join2 prgexpo_join3 prgexpo_join4 prgexpo_join5 ///
				prgexpo_join6 prgexpo_join7 prgexpo_join8 prgexpo_join9, ///
				over(NationalQuintile)		
	
	foreach var of varlist 	prgexpo_join1 prgexpo_join2 prgexpo_join3 prgexpo_join4 ///
							prgexpo_join5 prgexpo_join6 prgexpo_join7 prgexpo_join8 ///
							prgexpo_join9 {
								
		svy: tab wealth_quintile_ns `var', row 
		
							}
							
	svy: mean 	prgexpo_join1 prgexpo_join2 prgexpo_join3 prgexpo_join4 prgexpo_join5 ///
				prgexpo_join6 prgexpo_join7 prgexpo_join8 prgexpo_join9, ///
				over(wealth_quintile_ns)		

	
	// prgexp_freq_1 prgexp_freq_2 prgexp_freq_3 prgexp_freq_4 prgexp_freq_5 prgexp_freq_6 prgexp_freq_7 prgexp_freq_8 prgexp_freq_9
	svy: mean  	prgexp_freq_1 prgexp_freq_2 prgexp_freq_3 prgexp_freq_4 ///
				prgexp_freq_5 prgexp_freq_6 prgexp_freq_7 prgexp_freq_8 ///
				prgexp_freq_9

	svy: mean 	prgexp_freq_1 prgexp_freq_2 prgexp_freq_3 prgexp_freq_4 ///
				prgexp_freq_5 prgexp_freq_6 prgexp_freq_7 prgexp_freq_8 ///
				prgexp_freq_9, ///
				over(stratum_num)
				
	foreach var of varlist prgexp_freq_1 prgexp_freq_2 prgexp_freq_3 prgexp_freq_4 ///
				prgexp_freq_5 prgexp_freq_6 prgexp_freq_7 prgexp_freq_8 ///
				prgexp_freq_9 {
					
		quietly svy: reg `var' i.stratum_num
		quietly mat list e(b)
		test 1b.stratum_num = 2.stratum_num = 3.stratum_num = 4.stratum_num = 5.stratum_num
		
		}
	

	svy: mean 	prgexp_freq_1 prgexp_freq_2 prgexp_freq_3 prgexp_freq_4 ///
				prgexp_freq_5 prgexp_freq_6 prgexp_freq_7 prgexp_freq_8 ///
				prgexp_freq_9, ///
				over(NationalQuintile)
				
	foreach var of varlist prgexp_freq_1 prgexp_freq_2 prgexp_freq_3 prgexp_freq_4 ///
				prgexp_freq_5 prgexp_freq_6 prgexp_freq_7 prgexp_freq_8 ///
				prgexp_freq_9 {
					
		quietly svy: reg `var' i.NationalQuintile
		quietly mat list e(b)
		test 1b.NationalQuintile = 2.NationalQuintile = 3.NationalQuintile = 4.NationalQuintile = 5.NationalQuintile
		
		}
	
	// prgexp_iec0 prgexp_iec1 prgexp_iec2 prgexp_iec3 prgexp_iec4 prgexp_iec5 prgexp_iec6 prgexp_iec7 
	svy: mean 	prgexp_iec0 prgexp_iec1 prgexp_iec2 prgexp_iec3 prgexp_iec4 ///
				prgexp_iec5 prgexp_iec6 prgexp_iec7 
				
	foreach var of varlist 	prgexp_iec0 prgexp_iec1 prgexp_iec2 prgexp_iec3 ///
							prgexp_iec4 prgexp_iec5 prgexp_iec6 prgexp_iec7  {
								
		svy: tab stratum_num `var', row 
		
							}
							
	svy: mean 	prgexp_iec0 prgexp_iec1 prgexp_iec2 prgexp_iec3 prgexp_iec4 ///
				prgexp_iec5 prgexp_iec6 prgexp_iec7 , ///
				over(stratum_num)	
	
	foreach var of varlist 	prgexp_iec0 prgexp_iec1 prgexp_iec2 prgexp_iec3 ///
							prgexp_iec4 prgexp_iec5 prgexp_iec6 prgexp_iec7  {
								
		svy: tab NationalQuintile `var', row 
		
							}
							
	svy: mean 	prgexp_iec0 prgexp_iec1 prgexp_iec2 prgexp_iec3 prgexp_iec4 ///
				prgexp_iec5 prgexp_iec6 prgexp_iec7 , ///
				over(NationalQuintile)		
	
	foreach var of varlist 	prgexp_iec0 prgexp_iec1 prgexp_iec2 prgexp_iec3 ///
							prgexp_iec4 prgexp_iec5 prgexp_iec6 prgexp_iec7  {
								
		svy: tab wealth_quintile_ns `var', row 
		
							}
			
	svy: mean 	prgexp_iec0 prgexp_iec1 prgexp_iec2 prgexp_iec3 prgexp_iec4 ///
				prgexp_iec5 prgexp_iec6 prgexp_iec7 , ///
				over(wealth_quintile_ns)		
	
	
	
	** Program Access **
	// pn_access pn_muac_access pn_msg_access pn_wash_access pn_sbcc_access pn_hgdn_access pn_emgy_access
	
	foreach var of varlist pn_access pn_muac_access pn_msg_access pn_wash_access pn_sbcc_access pn_hgdn_access pn_emgy_access {
	    
		di "`var'"
		//svy: mean  `var'
		//svy: tab stratum_num `var', row 
		//svy: tab NationalQuintile `var', row
		
		svy: tab wealth_quintile_ns `var', row
	
	}
	
	foreach var of varlist pn_access pn_muac_access pn_msg_access pn_wash_access pn_sbcc_access pn_hgdn_access pn_emgy_access {
	    
		di "`var'"	
		svy: tab wealth_quintile_modify `var', row
	
	}
	
	
	
	* Additional Variable ** 
	// food Exposure 
	svy: mean foodcash_exposure_d
	svy: tab foodcash_exposure, ci 

	svy: tab stratum_num foodcash_exposure, row 
	svy: tab NationalQuintile foodcash_exposure, row
	
	svy: mean foodcash_exposure, over(stratum_num)
	svy: mean foodcash_exposure, over(NationalQuintile)

	svy: mean foodcash_exposure, over(wealth_quintile_ns)

	
	
	// nutrition sensitive 
	svy: mean nutsensitive_exposure_d
	svy: tab nutsensitive_exposure, ci 
	
	svy: tab stratum_num nutsensitive_exposure, row 
	svy: tab NationalQuintile nutsensitive_exposure, row	

	svy: mean nutsensitive_exposure, over(stratum_num)
	svy: mean nutsensitive_exposure, over(NationalQuintile)
	
	svy: mean nutsensitive_exposure, over(wealth_quintile_ns)
	
	
	* Concentration Index - relative 
	foreach var of varlist pn_access /*pn_muac_access*/ pn_msg_access pn_wash_access pn_sbcc_access pn_hgdn_access pn_emgy_access {
	    
		di "`var'"		
		conindex `var', rank(NationalQuintile) svy wagstaff bounded limits(0 1)
		conindex2 `var', rank(NationalQuintile) covars(i.resp_highedu i.org_name_num stratum progressivenss) svy wagstaff bounded limits(0 1)
	
	}
	
	
	* Concentration Index - absolute 
	foreach var of varlist pn_access /*pn_muac_access*/ pn_msg_access pn_wash_access pn_sbcc_access pn_hgdn_access pn_emgy_access {
	    
		di "`var'"		
		//conindex `var', rank(NationalQuintile) svy truezero generalized
	
	}
	
	
// END HERE 



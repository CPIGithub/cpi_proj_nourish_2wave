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
	

	* cross-tab 
	// phone 
	svy: tab stratum_num resp_highedu, row 
	svy: tab NationalQuintile resp_highedu, row 

	svy: tab stratum_num hh_mem_highedu_all, row 
	svy: tab NationalQuintile hh_mem_highedu_all, row 

	// program exposure 
	svy: tab resp_highedu prgexpo_pn, row 
	svy: tab hh_mem_highedu_all prgexpo_pn, row 

	
	****************************************************************************
	* HH Income *
	****************************************************************************

	use "$dta/pnourish_INCOME_WEALTH_final.dta", clear   

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	
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
	
	
	** Hygiene Ladder ** 
	// hw_ladder
	svy: tab hw_ladder, ci 
	svy: tab stratum_num hw_ladder, row 
	svy: tab NationalQuintile hw_ladder, row
	
	svy: tab hhitems_phone hw_ladder, row 
	svy: tab prgexpo_pn hw_ladder, row 	
	svy: tab edu_exposure hw_ladder, row 
	
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
	
	** Water Pot ** 
	// waterpot_yn
	svy: tab waterpot_yn, ci 
	svy: tab stratum_num waterpot_yn, row 
	svy: tab NationalQuintile waterpot_yn, row

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

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)
	
	  
	// fies_rawscore
	svy: mean  fies_rawscore

	svy: mean fies_rawscore, over(stratum_num)
	svy: reg fies_rawscore i.stratum_num
	
	svy: mean fies_rawscore, over(NationalQuintile)
	svy: reg fies_rawscore i.NationalQuintile
	
	
	svy: mean fies_rawscore, over(hhitems_phone)
	test _b[c.fies_rawscore@0bn.hhitems_phone] = _b[c.fies_rawscore@1bn.hhitems_phone]

	svy: mean fies_rawscore, over(prgexpo_pn)
	test _b[c.fies_rawscore@0bn.prgexpo_pn] = _b[c.fies_rawscore@1bn.prgexpo_pn]

	svy: mean fies_rawscore, over(edu_exposure)
	test _b[c.fies_rawscore@0bn.edu_exposure] = _b[c.fies_rawscore@1bn.edu_exposure]

	
	****************************************************************************
	** Program Exposure **
	****************************************************************************

	use "$dta/pnourish_program_exposure_final.dta", clear   

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)
	
	// prgexpo_pn
	svy: mean  prgexpo_pn
	svy: tab stratum_num prgexpo_pn, row 
	svy: tab NationalQuintile prgexpo_pn, row
	
	
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
							
	svy: mean 	prgexpo_join1 prgexpo_join2 prgexpo_join3 prgexpo_join4 prgexpo_join5 ///
				prgexpo_join6 prgexpo_join7 prgexpo_join8 prgexpo_join9, ///
				over(NationalQuintile)		
	
	
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
	
	** Program Access **
	// pn_access pn_muac_access pn_msg_access pn_wash_access pn_sbcc_access pn_hgdn_access pn_emgy_access
	
	foreach var of varlist pn_access pn_muac_access pn_msg_access pn_wash_access pn_sbcc_access pn_hgdn_access pn_emgy_access {
	    
		di "`var'"
		svy: mean  `var'
		svy: tab stratum_num `var', row 
		svy: tab NationalQuintile `var', row
	
	}

	
// END HERE 



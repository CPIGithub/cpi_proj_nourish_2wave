/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: Data analysis 			
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

	use "$dta/pnourish_INCOME_WEALTH_final.dta", clear   

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

	svy: tab hh_mem_head, ci 
	svy: tab hh_mem_highedu, ci 
	svy: tab hh_mem_occup, ci 
	
	
	** HH Characteristics **
	
	svy: mean hh_tot_num
	
	svy: tab NationalQuintile, ci 
	
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


	****************************************************************************
	* Child MUAC Module *
	****************************************************************************

	use "$dta/pnourish_child_muac_final.dta", clear   
	
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
	svy: reg u5_muac i.stratum_num
	
	svy: mean u5_muac, over(NationalQuintile)
	svy: reg u5_muac i.NationalQuintile

	****************************************************************************
	* Child IYCF Data *
	****************************************************************************
	
	use "$dta/pnourish_child_iycf_final.dta", clear 
	
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

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
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row	
	
	// ebf 
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row	
	
	// pre_bf 
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row	
	
	// mixmf 
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row	
	
	// bof 
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row	
	
	// cbf
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row 

	
	* complementary feeding * 
	svy: mean isssf 
	svy: mean food_g1 food_g2 food_g3 food_g4 food_g5 food_g6 food_g7 food_g8
	
	// isssf
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row

	// food_g1 
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row
	
	// food_g2 
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row
	
	// food_g3 
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row
	
	// food_g4 
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row	
	
	// food_g5 
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row
	
	// food_g6 
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row	
	
	// food_g7 
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row
	
	// food_g8 
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row


	* minimum dietary *
	svy: mean dietary_tot mdd mmf_bf_6to8 mmf_bf_9to23 mmf_bf mmf_nonbf mmf mmff mad mad_bf mad_nobf 
	
	// dietary_tot 
	svy: mean dietary_tot, over(stratum_num)
	svy: reg dietary_tot i.stratum_num
	
	svy: mean dietary_tot, over(NationalQuintile)
	svy: reg dietary_tot i.NationalQuintile
	
	// madd 
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row
	
	// mmf_bf_6to8 
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row
	
	// mmf_bf_9to23
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row
	
	// mmf_bf 
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row
	
	// mmf_nonbf 
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row
	
	// mmf 
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row
	
	// mmmff 
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row
	
	// mad 
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row
	
	// mad_bf 
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row
	
	// mad_nobf 
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row

	
	****************************************************************************
	* Child Health Data *
	****************************************************************************

	use "$dta/pnourish_child_health_final.dta", clear 
	
	
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)


	** Child Birth Weight **
	svy: mean child_vita child_deworm child_vaccin child_vaccin_card child_bwt_lb child_low_bwt
	
	* cross-tab 
	// child_vita
	svy: tab stratum_num child_vita, row 
	svy: tab NationalQuintile child_vita, row 

	// child_deworm
	svy: tab stratum_num child_deworm, row 
	svy: tab NationalQuintile child_deworm, row 

	// child_vaccin  
	svy: tab stratum_num child_vaccin, row 
	svy: tab NationalQuintile child_vaccin, row 

	// child_vaccin_card 
	svy: tab stratum_num child_vaccin_card, row 
	svy: tab NationalQuintile child_vaccin_card, row 

	// child_bwt_lb 
	svy: mean child_bwt_lb, over(stratum_num)
	svy: reg child_bwt_lb i.stratum_num
	
	svy: mean child_bwt_lb, over(NationalQuintile)
	svy: reg child_bwt_lb i.NationalQuintile

	// child_low_bwt  
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row 
	

	* illness *
	
	svy: mean child_ill0 child_ill1 child_ill2 child_ill3 child_ill888

	// child_ill0 
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row 
	
	// child_ill1 
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row 
	
	// child_ill2 
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row 
	
	// child_ill3 
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row 
	
	// child_ill888
	svy: tab stratum_num child_low_bwt, row 
	svy: tab NationalQuintile child_low_bwt, row 
	
	***** DIARRHEA *****
	// child_diarrh_treat
	svy: mean child_diarrh_treat
	
	// child_diarrh_where
	svy: tab child_gam, ci 
	
	// child_diarrh_who
	svy: tab child_gam, ci 
	
	// child_diarrh_trained 
	svy: mean child_diarrh_trained
	
	// child_diarrh_notreat
	svy: mean child_diarrh_notreat1 child_diarrh_notreat2 child_diarrh_notreat3 child_diarrh_notreat4 child_diarrh_notreat5 child_diarrh_notreat6 child_diarrh_notreat7 child_diarrh_notreat8 child_diarrh_notreat9 child_diarrh_notreat10 child_diarrh_notreat11 child_diarrh_notreat12 child_diarrh_notreat13 child_diarrh_notreat14 child_diarrh_notreat15 child_diarrh_notreat888 child_diarrh_notreat777 child_diarrh_notreat999
	
	// child_diarrh_pay
	svy: mean child_diarrh_pay
	
	// child_diarrh_cope
	svy: mean child_diarrh_cope1 child_diarrh_cope2 child_diarrh_cope3 child_diarrh_cope4 child_diarrh_cope5 child_diarrh_cope6 child_diarrh_cope7 child_diarrh_cope8 child_diarrh_cope9 child_diarrh_cope10 child_diarrh_cope11 child_diarrh_cope12 child_diarrh_cope13 child_diarrh_cope14 child_diarrh_cope888 child_diarrh_cope666
	
	
	***** COUGH *****
	// child_cough_treat
	svy: mean child_cough_treat
	
	// child_cough_where
	svy: tab child_gam, ci 
	
	// child_cough_who
	svy: tab child_gam, ci 
	
	// child_cough_trained 
	svy: mean child_cough_trained
	
	// child_cough_notreat
	svy: mean child_cough_notreat1 child_cough_notreat2 child_cough_notreat3 child_cough_notreat4 child_cough_notreat5 child_cough_notreat6 child_cough_notreat7 child_cough_notreat8 child_cough_notreat9 child_cough_notreat10 child_cough_notreat11 child_cough_notreat12 child_cough_notreat13 child_cough_notreat14 child_cough_notreat15 child_cough_notreat888 child_cough_notreat777 child_cough_notreat999
	
	// child_cough_pay
	svy: mean child_cough_pay
	
	// child_cough_cope
	svy: mean child_cough_cope1 child_cough_cope2 child_cough_cope3 child_cough_cope4 child_cough_cope5 child_cough_cope6 child_cough_cope7 child_cough_cope8 child_cough_cope9 child_cough_cope10 child_cough_cope11 child_cough_cope12 child_cough_cope13 child_cough_cope14 child_cough_cope888 child_cough_cope666
	
	***** FEVER *****
	// child_fever_treat, m 
	svy: mean  child_fever_treat
	
	// child_fever_where, m 
	svy: tab child_fever_where, ci 
	
	// child_fever_who  
	svy: tab child_fever_who, ci 
	
	// child_fever_trained
	svy: mean child_fever_trained
	
	// child_fever_notreat
	svy: mean child_fever_notreat1 child_fever_notreat2 child_fever_notreat3 child_fever_notreat4 child_fever_notreat5 child_fever_notreat6 child_fever_notreat7 child_fever_notreat8 child_fever_notreat9 child_fever_notreat10 child_fever_notreat11 child_fever_notreat12 child_fever_notreat13 child_fever_notreat14 child_fever_notreat15 child_fever_notreat888 child_fever_notreat777 child_fever_notreat999
	
	
	// child_fever_pay
	svy: mean child_fever_pay
	
	// child_fever_cope
	svy: mean child_fever_cope1 child_fever_cope2 child_fever_cope3 child_fever_cope4 child_fever_cope5 child_fever_cope6 child_fever_cope7 child_fever_cope8 child_fever_cope9 child_fever_cope10 child_fever_cope11 child_fever_cope12 child_fever_cope13 child_fever_cope14 child_fever_cope888 child_fever_cope666
	
	
	****************************************************************************
	** Mom Dietary Diversity **
	****************************************************************************

	use "$dta/pnourish_mom_diet_final.dta", clear 
	
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)


	
	// mom_meal_freq
	tab mom_meal_freq, m 
	
	// food groups 
	mddw_grain mddw_pulses mddw_nut mddw_milk mddw_meat ///
								mddw_moom_egg mddw_green_veg mddw_vit_vegfruit ///
								mddw_oth_veg mddw_oth_fruit
								
	tab mddw_score, m 

	tab mddw_yes, m 
	
	
	
	****************************************************************************
	* Mom Health Module *
	****************************************************************************

	use "$dta/pnourish_mom_health_final.dta", clear   

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	****************************************************************************
	** Mom ANC **
	****************************************************************************

	// anc_yn 
	tab anc_yn, m 
	
	// anc_where 
	tab anc_where, m 
	
	
	// anc_*_who
	anc_who_1 anc_who_2 anc_who_3 anc_who_4 anc_who_5 anc_who_6 anc_who_7 anc_who_8 anc_who_9 anc_who_10 anc_who_11 anc_who_888
 

	tab anc_who_trained, m 
	


	// anc_*_visit
	anc_who_visit_1 anc_who_visit_2 anc_who_visit_3 anc_who_visit_4 anc_who_visit_5 anc_who_visit_6 anc_who_visit_7 anc_who_visit_8 anc_who_visit_9 anc_who_visit_10 anc_who_visit_11 anc_who_visit_888
	

	tab anc_visit_trained, m 
	
	tab anc_visit_trained_4times, m 
	
	
	****************************************************************************
	** Mom Deliverty **
	****************************************************************************
	// deliv_place 
	tab deliv_place, m 

	// Institutional Deliveries
	tab insti_birth, m 
	
	
	// deliv_assist
	tab deliv_assist, m 
	
	// Births attended by skilled health personnel
	tab skilled_battend, m 


	****************************************************************************
	** Mom PNC **
	****************************************************************************
	// pnc_yn 
	tab pnc_yn, m 
	
	// pnc_where 
	tab pnc_where, m 

	// pnc_*_who
	pnc_who_1 pnc_who_2 pnc_who_3 pnc_who_4 pnc_who_5 pnc_who_6 pnc_who_7 pnc_who_8 pnc_who_9 pnc_who_10 pnc_who_11 pnc_who_888
	
	tab pnc_who_trained, m 
	
	
	****************************************************************************
	** Mom NBC **
	****************************************************************************
	// nbc_yn 
	tab nbc_yn, m 
	
	// nbc_2days_yn
	tab nbc_2days_yn, m 
	
	// nbc_where
	tab nbc_where, m 
	
	// nbc_*_who
	nbc_who_1 nbc_who_2 nbc_who_3 nbc_who_4 nbc_who_5 nbc_who_6 nbc_who_7 nbc_who_8 nbc_who_9 nbc_who_10 nbc_who_11 nbc_who_888
	
	tab nbc_who_trained, m 

	
	
	****************************************************************************
	** WASH **
	****************************************************************************

	use "$dta/pnourish_WASH_final.dta", clear   

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	
	** Drinking Water Ladder **
	water_sum water_rain water_winter 
		
	
	water_sum_ladder water_rain_ladder water_winter_ladder
	

	 
	** Sanitation Ladder ** 
	
	tab latrine_type

	tab sanitation_ladder 
	
	
	** Hygiene Ladder ** 
	tab hw_ladder, m 
	
	
	** Handwashing at Critical Time ** 
	tab soap_yn, m 

	lab def soapfreq 	1 "Never" ///
						2 "Rarely/Sometimes" ///
						3 "Often" ///
						4 "Always" ///
						0 "Never experience this condition" 



	tab1 soap_tiolet soap_clean_baby soap_child_faeces ///
							soap_before_eat soap_before_cook soap_feed_child ///
							soap_handle_child 
	
	


	** Water Treatment **
	watertx_sum_good watertx_rain_good watertx_winter_good
	
	** Water Pot ** 
	// waterpot_yn
	tab waterpot_yn, m 

	// waterpot_capacity
	tab waterpot_capacity, m 
	
	// waterpot_condition
	tab1 waterpot_condition1 waterpot_condition2 waterpot_condition3 waterpot_condition4 waterpot_condition0, m 
	
	
	****************************************************************************
	** FIES **
	****************************************************************************

	use "$dta/pnourish_FIES_final.dta", clear   

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)
	
	  
	// fies_rawscore
	
	****************************************************************************
	** PHQ9 **
	****************************************************************************
	
	use "$dta/pnourish_PHQ9_final.dta", clear  

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)
	
	tab phq9_cat, m 
	
	****************************************************************************
	** Women Empowerment **
	****************************************************************************
	
	use "$dta/pnourish_WOMEN_EMPOWER_final.dta", clear  

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	
	tab1 wempo_childcare wempo_mom_health wempo_child_health ///
							wempo_women_wages wempo_major_purchase wempo_visiting ///
							wempo_women_health wempo_child_wellbeing 
	// 1) Own health care.
	tab women_ownhealth, m 

	// 2) Large household purchases.
	tab women_hhpurchase, m 
	
	// 3) Visits to family or relatives.
	tab women_visit, m 

// END HERE 



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
	svy: tab resp_occup, ci 
		
	svy: tab hhitems_phone, ci 
	svy: tab prgexpo_pn, ci 
	svy: tab edu_exposure, ci 
	
	** HH Characteristics **
	svy: mean hh_tot_num
	
	svy: tab NationalQuintile, ci 
	
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
	
	
	svy: tab hhitems_phone child_gam, row 
	svy: tab prgexpo_pn child_gam, row 
	svy: tab edu_exposure child_gam, row 
	svy: tab prgexpo_join8 child_gam, row 
	
	
	foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
		conindex child_gam, rank(`var') svy wagstaff bounded limits(0 1)
	}


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
	

	local outcome eibf ebf2d ebf pre_bf mixmf bof cbf
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}

	
	

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

	
	local outcome isssf food_g1 food_g2 food_g3 food_g4 food_g5 food_g6 food_g7 food_g8
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}

	
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
	
	// mdd 
	svy: tab stratum_num mdd, row 
	svy: tab NationalQuintile mdd, row
	
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
	
	// mmff 
	svy: tab stratum_num mmff, row 
	svy: tab NationalQuintile mmff, row
	
	// mad 
	svy: tab stratum_num mad, row 
	svy: tab NationalQuintile mad, row
	
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

	
	local outcome dietary_tot
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') truezero svy 
		}
	
	}	
	
	local outcome mdd mmf_bf_6to8 mmf_bf_9to23 mmf_bf mmf_nonbf mmf mmff mad mad_bf mad_nobf 
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}

	****************************************************************************
	* Child Health Data *
	****************************************************************************

	use "$dta/pnourish_child_health_final.dta", clear 
	
	
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)


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
	
	
	
	local outcome child_bwt_lb
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') truezero svy 
		}
	
	}	
	
	local outcome 	child_vita child_deworm child_vaccin child_vaccin_card  child_low_bwt
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}
	
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
	
	
	
	local outcome  child_ill0 child_ill1 child_ill2 child_ill3 child_ill888
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}

	
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
	
	// child_diarrh_who
	svy: tab child_diarrh_who,ci 
	svy: tab stratum_num child_diarrh_who, row 
	svy: tab NationalQuintile child_diarrh_who, row 
	
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
	
	
	local outcome child_diarrh_treat child_diarrh_trained child_diarrh_pay
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}
	
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
	
	// child_cough_who
	svy: tab child_cough_who,ci
	svy: tab stratum_num child_cough_who, row 
	svy: tab NationalQuintile child_cough_who, row 
	
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
	
	
	local outcome child_cough_treat child_cough_trained child_cough_pay
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}
	
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
	
	// child_fever_who  
	svy: tab child_fever_who, ci
	svy: tab stratum_num child_fever_who, row 
	svy: tab NationalQuintile child_fever_who, row
	
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


	local outcome child_fever_treat child_fever_trained child_fever_pay
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}
	
	****************************************************************************
	** Mom Dietary Diversity **
	****************************************************************************

	use "$dta/pnourish_mom_diet_final.dta", clear 
	
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	
	// mom_meal_freq
	svy: mean mom_meal_freq

	svy: mean mom_meal_freq, over(stratum_num)
	svy: reg mom_meal_freq i.stratum_num
	
	svy: mean mom_meal_freq, over(NationalQuintile)
	svy: reg mom_meal_freq i.NationalQuintile

	
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
								
	
	// mddw_score
	svy: mean  mddw_score

	svy: mean mddw_score, over(stratum_num)
	svy: reg mddw_score i.stratum_num
	
	svy: mean mddw_score, over(NationalQuintile)
	svy: reg mddw_score i.NationalQuintile

	
	// mddw_yes
	svy: mean  mddw_yes
	svy: tab stratum_num mddw_yes, row 
	svy: tab NationalQuintile mddw_yes, row
	
	svy: tab hhitems_phone mddw_yes, row 
	svy: tab prgexpo_pn mddw_yes, row 	
	
	svy: reg mddw_score hhitems_phone
	svy: reg mddw_score prgexpo_pn

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

	
	local outcome mddw_score mom_meal_freq
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') truezero svy 
		}
	
	}	
	
	
	local outcome 	mddw_yes ///
					mddw_grain mddw_pulses mddw_nut mddw_milk mddw_meat ///
					mddw_moom_egg mddw_green_veg mddw_vit_vegfruit ///
					mddw_oth_veg mddw_oth_fruit
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}
	
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
	svy: mean  anc_yn
	svy: tab stratum_num anc_yn, row 
	svy: tab NationalQuintile anc_yn, row

	svy: reg anc_yn hfc_near_dist_dry 
	svy: reg anc_yn hfc_near_dist_rain 

	
	// anc_where 
	svy: tab anc_where,ci
	svy: tab stratum_num anc_where, row 
	svy: tab NationalQuintile anc_where, row 
	
	
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
	

	// anc_who_trained
	svy: mean  anc_who_trained
	svy: tab stratum_num anc_who_trained, row 
	svy: tab NationalQuintile anc_who_trained, row
	
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
	
	svy: reg anc_visit_trained_4times hfc_near_dist_dry 
	svy: reg anc_visit_trained_4times hfc_near_dist_rain 	
	
	svy: tab hhitems_phone anc_yn, row 
	svy: tab prgexpo_pn anc_yn, row 	
	svy: tab edu_exposure anc_yn, row 

	svy: tab hhitems_phone anc_who_trained, row 
	svy: tab prgexpo_pn anc_who_trained, row 	
	svy: tab edu_exposure anc_who_trained, row 
	
	svy: tab hhitems_phone anc_visit_trained_4times, row 
	svy: tab prgexpo_pn anc_visit_trained_4times, row 	
	svy: tab edu_exposure anc_visit_trained_4times, row 

	svy: reg anc_visit_trained hhitems_phone
	svy: reg anc_visit_trained prgexpo_pn
	svy: tab edu_exposure prgexpo_pn, row 

	
	local outcome anc_visit_trained
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') truezero svy 
		}
	
	}	
	
	
	local outcome 	anc_yn anc_who_trained anc_visit_trained_4times
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}
	
	
	****************************************************************************
	** Mom Deliverty **
	****************************************************************************
	// deliv_place 
	svy: tab deliv_place,ci
	svy: tab stratum_num deliv_place, row 
	svy: tab NationalQuintile deliv_place, row 

	// Institutional Deliveries
	svy: mean  insti_birth
	svy: tab stratum_num insti_birth, row 
	svy: tab NationalQuintile insti_birth, row

	svy: reg insti_birth hfc_near_dist_dry 
	svy: reg insti_birth hfc_near_dist_rain 	
	
	// deliv_assist
	svy: tab deliv_assist,ci
	svy: tab stratum_num deliv_assist, row 
	svy: tab NationalQuintile deliv_assist, row 
	
	// Births attended by skilled health personnel
	svy: mean  skilled_battend
	svy: tab stratum_num skilled_battend, row 
	svy: tab NationalQuintile skilled_battend, row

	svy: reg skilled_battend hfc_near_dist_dry 
	svy: reg skilled_battend hfc_near_dist_rain 	
	
	svy: tab hhitems_phone skilled_battend, row 
	svy: tab prgexpo_pn skilled_battend, row 	
	svy: tab edu_exposure skilled_battend, row 

	svy: tab hhitems_phone insti_birth, row 
	svy: tab prgexpo_pn insti_birth, row 	
	svy: tab edu_exposure insti_birth, row 

	
	local outcome 	insti_birth skilled_battend
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}
	
	
	****************************************************************************
	** Mom PNC **
	****************************************************************************
	// pnc_yn 
	svy: mean  pnc_yn
	svy: tab stratum_num pnc_yn, row 
	svy: tab NationalQuintile pnc_yn, row

	svy: reg pnc_yn hfc_near_dist_dry 
	svy: reg pnc_yn hfc_near_dist_rain 	
	
	// pnc_where 
	svy: tab pnc_where,ci
	svy: tab stratum_num pnc_where, row 
	svy: tab NationalQuintile pnc_where, row 

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
		
	// pnc_who_trained
	svy: mean  pnc_who_trained
	svy: tab stratum_num pnc_who_trained, row 
	svy: tab NationalQuintile pnc_who_trained, row

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
	
	
	****************************************************************************
	** Mom NBC **
	****************************************************************************
	// nbc_yn 
	svy: mean  nbc_yn
	svy: tab stratum_num nbc_yn, row 
	svy: tab NationalQuintile nbc_yn, row

	svy: reg nbc_yn hfc_near_dist_dry 
	svy: reg nbc_yn hfc_near_dist_rain 	
	
	// nbc_2days_yn
	svy: mean  nbc_2days_yn
	svy: tab stratum_num nbc_2days_yn, row 
	svy: tab NationalQuintile nbc_2days_yn, row

	svy: reg nbc_2days_yn hfc_near_dist_dry 
	svy: reg nbc_2days_yn hfc_near_dist_rain 	
	
	// nbc_where
	svy: tab nbc_where,ci
	svy: tab stratum_num nbc_where, row 
	svy: tab NationalQuintile nbc_where, row 
	
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
	
	
	// nbc_who_trained
	svy: mean  nbc_who_trained
	svy: tab stratum_num nbc_who_trained, row 
	svy: tab NationalQuintile nbc_who_trained, row

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
	
	foreach var of varlist 	wempo_childcare wempo_mom_health wempo_child_health ///
							wempo_women_wages wempo_major_purchase wempo_visiting ///
							wempo_women_health wempo_child_wellbeing {
								
		gen `var'_d = (`var' ==  1)
		replace `var'_d = .m if mi(`var')
		drop `var'
		rename `var'_d `var'
		tab `var', m 
							}

							
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
	svy: mean 	prgexpo_join1 prgexpo_join2 prgexpo_join3 prgexpo_join4 prgexpo_join5 ///
				prgexpo_join6 prgexpo_join7 prgexpo_join8 prgexpo_join9
				
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



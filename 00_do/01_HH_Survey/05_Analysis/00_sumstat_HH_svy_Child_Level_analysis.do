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

	
	local outcome isssf food_g1 food_g2 food_g3 food_g4 food_g5 food_g6 food_g7 food_g8
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
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
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
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
	   

	****************************************************************************
	* Child Health Data *
	****************************************************************************

	use "$dta/pnourish_child_health_final.dta", clear 
	
	
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

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
	

	gen stratum_org_inter = stratum * org_name_num  
	gen KDHW = (stratum_num == 5)
	
	local outcome child_bwt_lb
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') truezero svy 
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
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
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
	
	
	
	local outcome  child_ill0 child_ill1 child_ill2 child_ill3 child_ill888
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
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

	
	
	
	
	
// END HERE 



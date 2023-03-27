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

	
	
	
	svy: mean eibf ebf2d ebf pre_bf mixmf bof cbf


	tab eibf, m 
	
	tab ebf2d, m 

	tab ebf, m 

	tab pre_bf, m 

	tab mixmf, m

	tab bof, m 

	tab cbf, m

	svy: mean isssf food_g1 food_g2 food_g3 food_g4 food_g5 food_g6 food_g7 food_g8
	
	tab isssf, m 


	
	tab1 food_g1 food_g2 food_g3 food_g4 food_g5 food_g6 food_g7 food_g8 

	svy: mean dietary_tot madd mmf_bf_6to8 mmf_bf_9to23 mmf_bf mmf_nonbf mmf mmmff mad mad_bf mad_nobf 
	
	svy dietary_tot, m 

	tab mdd, m


	tab mmf_bf_6to8, m 

	tab mmf_bf_9to23, m 

	tab mmf_bf, m 

	tab mmf_nonbf, m 

	tab mmf, m 

	tab mmff, m 

	tab mad, m 

	tab mad_bf, m 

	tab mad_nobf, m 

	* Add Weight variable *
	stratum_num weight_final

	
	* Add Wealth Quantile variable **
	NationalQuintile NationalScore
	



// END HERE 



/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: Village svy data cleaning 			
Author				:	Nicholus Tint Zaw
Date				: 	03/01/2023
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

********************************************************************************
* Village survey *
********************************************************************************

	** Village Survey: Main Dataset: constructed WIDE format dataset **
	use "$dta/PN_Village_Survey_FINAL_Constructed.dta", clear   	
	
	
	
	****************************************************************************
	** I. Geographic Information **
	****************************************************************************
	// stratum_num
	tab stratum_num, m 
	
	// respd_sex
	tab respd_sex, m 
	
	// respd_role
	tab respd_role, m 
	
	// respd_role_yrs
	mean respd_role_yrs
	
	// respd_1stround
	tab respd_1stround, m 


	****************************************************************************
	** III. Demographic profile **
	****************************************************************************
	
	// number 
	mean demo_hh_number demo_pop_number demo_u5_number demo_u2_number demo_plw_number 
	
	// changes 
	foreach var of varlist demo_hh_change demo_pop_change demo_u5_change demo_u2_change demo_plw_change {
		
		replace `var' = .d if `var' == 777
	}
	
	mean demo_hh_change demo_pop_change demo_u5_change demo_u2_change demo_plw_change
	
	// changes scale 
	tab1 demo_hh_scale demo_pop_scale demo_u5_scale demo_u2_scale demo_plw_scale, nolab 


	** MIGRATION **
	mean demo_migrate demo_migrate_hh
	
	** IDP - INTERNALLY DISPLACED PEOPLE **
	mean demo_idp demo_idp_pop
	
	** DISPLACED PEOPLE **
	mean demo_dspl demo_dspl_hh
	
	
	
	****************************************************************************
	** IV. Health Facilities and Health concerns **
	****************************************************************************
	
	// hfc_vill
	mean hfc_vill0 hfc_vill1 hfc_vill2 hfc_vill3 hfc_vill4 hfc_vill5 hfc_vill6 hfc_vill888 
	
	// hfc_vill_staff
	replace hfc_vill_staff = .m if hfc_vill0 == 1
	
	recode hfc_vill_staff (1 = 0) (0 = 1), gen(staff_notpresent)
	
	mean staff_notpresent
	
	// hf_vill_season
	mean hf_vill_season1 hf_vill_season2 hf_vill_season3 hf_vill_season0
	
	
	// hfc_near
	mean hfc_near0 hfc_near1 hfc_near2 hfc_near3 hfc_near4 hfc_near5 hfc_near6 hfc_near888  
	
	mean hfc_near_dist_dry hfc_near_dist_rain

	// hfc_near_staff
	recode hfc_near_staff (1 = 0) (0 = 1), gen(near_staff_notpresent)
	
	mean near_staff_notpresent
	
	
	// hfc_near_season
	tab1 hfc_near_season1 hfc_near_season2 hfc_near_season3 hfc_near_season0


	// hfc_visit
	mean hfc_visit1 hfc_visit2 hfc_visit888 
	
	tab hfc_visit1, m 
	
	// to replace .m if hfc_visit1 == 0
	// hfc_visit_eho_type
	foreach var of varlist hfc_visit_eho_type1 hfc_visit_eho_type2 hfc_visit_eho_type3 hfc_visit_eho_type888 {
		
		replace `var' = .m if hfc_visit1 == 0
		tab `var', m 
	}
	
	mean hfc_visit_eho_type1 hfc_visit_eho_type2 hfc_visit_eho_type3 hfc_visit_eho_type888 
	
	// hfc_visit_eho_freq
	replace hfc_visit_eho_freq = .m if hfc_visit_eho_freq == 9999
	mean hfc_visit_eho_freq
	
	// hfc_visit_eho_past
	tab hfc_visit_eho_past
	
	// hfc_visit_eho_coup
	tab hfc_visit_eho_coup

	
	// hfc_visit_gov_type
	foreach var of varlist hfc_visit_gov_type1 hfc_visit_gov_type2 hfc_visit_gov_type3 hfc_visit_gov_type888 {
		
		replace `var' = .m if hfc_visit2 == 0
	}
	
	mean hfc_visit_gov_type1 hfc_visit_gov_type2 hfc_visit_gov_type3 hfc_visit_gov_type888
	
	// hfc_visit_gov_freq
	replace hfc_visit_gov_freq = .m if hfc_visit_gov_freq == 9999
	mean hfc_visit_gov_freq 
	
	// hfc_visit_gov_past
	tab hfc_visit_gov_past
	
	// hfc_visit_gov_coup
	tab hfc_visit_gov_coup

	// hfc_visit_othpty_type
	// hfc_visit_othpty_freq
	// hfc_visit_othpty_past
	// hfc_visit_othpty_coup

	
	
	// hfc_diseases
	tab1 	hfc_diseases1 hfc_diseases2 hfc_diseases3 hfc_diseases4 hfc_diseases5 ///
			hfc_diseases6 hfc_diseases7 hfc_diseases8 hfc_diseases9 hfc_diseases10 ///
			hfc_diseases11 hfc_diseases12 hfc_diseases888
	
	mean 	hfc_diseases1 hfc_diseases2 hfc_diseases3 hfc_diseases4 hfc_diseases5 ///
			hfc_diseases6 hfc_diseases7 hfc_diseases8 hfc_diseases9 hfc_diseases10 ///
			hfc_diseases11 hfc_diseases12 hfc_diseases888
	
	tab1 hfc_*_past 
	tab1 hfc_*_coup
	
	
	// Malnutrition Cases 
	foreach var of varlist hfc_mnut_p_num hfc_mnut_c_num hfc_mnut_t_num {
		
		replace `var' = .m if `var' == 9999
	}
	
	mean hfc_mnut_p_num 
	mean hfc_mnut_c_num 
	mean hfc_mnut_t_num
	
	
	tab1 hfc_mnut_p_past hfc_mnut_p_coup
	
	tab1 hfc_mnut_c_past hfc_mnut_c_coup

	tab1 hfc_mnut_t_past hfc_mnut_t_coup

	
	// Covid - 19 
	foreach var of varlist hfc_covid_s_case hfc_covid_c_case hfc_covid_prev_case {
		
		replace `var' = .m if `var' == 9999
	}
	
	mean hfc_covid_s_case 
	mean hfc_covid_c_case 
	mean hfc_covid_prev_case
	
	tab1 hfc_covid_s_past hfc_covid_s_coup
	
	tab1 hfc_covid_c_past hfc_covid_c_coup

	tab1 hfc_covid_prev_past hfc_covid_prev_coup

	
	****************************************************************************
	** V. Market Accessibility **
	****************************************************************************
	
	// Market 
	* in village 
	mean mkt_hshop_vill
	mean mkt_vill
	
	tab mkt_vill_type
	tab mkt_vill_days
	mean mkt_vill_days


	* nearest market 
	tab mkt_near_type
	mean mkt_near_days

	tab1 mkt_near_dist_dry mkt_near_dist_rain
	mean mkt_near_dist_dry 
	mean mkt_near_dist_rain

	// car mobile 
	mean mkt_mobile_car mkt_mobile_mbike

	// price 
	tab1 mkt_comod_rice mkt_comod_bean mkt_comod_salt mkt_comod_oil mkt_comod_chicken mkt_comod_pork mkt_comod_beef
	
	mean mkt_comod_rice 
	mean mkt_comod_bean 
	mean mkt_comod_salt mkt_comod_oil mkt_comod_chicken mkt_comod_pork mkt_comod_beef

	
	****************************************************************************
	** VI. Livelihood and Income **
	****************************************************************************
	// lh_num
	tab lh_num, m 
	
	/*
	lh_hh
	lh_season
	lh_hh_past
	lh_hh_coup
	lh_income
	lh_income_past
	lh_income_coup
	*/

	foreach var of varlist 	mainlh_hh_1 mainlh_hh_2 mainlh_hh_3 ///
							mainlh_hh_4 mainlh_hh_past_* {
		
		replace `var' = .m if `var' == 9999 | `var' == 777
		
	}
	
	
	// Agriculture and livestock 
	tab1 mainlh_1 mainlh_hh_past_1 mainlh_hh_coup_1 
	
	mean mainlh_hh_1
	
	mean mainlh_hhincome_1 
	
	tab1 mainlh_hhincome_past_1 mainlh_hhincome_coup_1 
		

	// Casual labour 
	tab1 mainlh_2 mainlh_hh_past_2 mainlh_hh_coup_2
	
	mean mainlh_hh_2
	
	mean mainlh_hhincome_2

	tab1 mainlh_hhincome_past_2 mainlh_hhincome_coup_2 
	
	// Commodity Trading 
	tab1 mainlh_3 mainlh_hh_past_3 mainlh_hh_coup_3 
	
	mean mainlh_hh_3
	
	mean mainlh_hhincome_3 
	
	tab1 mainlh_hhincome_past_3 mainlh_hhincome_coup_3 
	
	// Migrant workers
	tab1 mainlh_4 mainlh_hh_past_4 mainlh_hh_coup_4 
	
	mean mainlh_hh_4
	
	mean mainlh_hhincome_4 
	
	tab1 mainlh_hhincome_past_4 mainlh_hhincome_coup_4

	****************************************************************************
	** VII. Project Nourish Coverage and implementation **
	****************************************************************************
	
	** DEVELOPMENT PROJECT **
	
	tab1 dev_proj_1 dev_proj_2  
	
	mean dev_proj_num_1 dev_proj_num_2 dev_proj_tot
	
	// pn_dev_act
	// Food and Nutrition WASH Health Shelter Livelihood
	mean proj_act_1 proj_act_2 proj_act_3 proj_act_4 proj_act_5
	mean proj_act_num_1 proj_act_num_2 proj_act_num_3 proj_act_num_4 proj_act_num_5


	// Project Nourished Implementation 

	tab1 pn_sbcc_yn pn_muac_yn pn_wsbcc_yn pn_wash_yn pn_emgy_yn pn_hgdn_yn pn_msg_yn
	
	foreach var of varlist pn_sbcc_yn pn_muac_yn pn_wsbcc_yn pn_wash_yn pn_emgy_yn pn_hgdn_yn pn_msg_yn {
		
		replace `var' = .m if `var' == 777
		tab `var'
	}
	
	mean pn_sbcc_yn 
	mean pn_muac_yn 
	mean pn_wsbcc_yn 
	mean pn_wash_yn 
	mean pn_emgy_yn 
	mean pn_hgdn_yn
	mean pn_msg_yn
		
	tab1 pn_sbcc_freq pn_muac_freq pn_wsbcc_freq pn_wash_freq pn_emgy_freq pn_hgdn_freq pn_msg_freq
	
	foreach var of varlist pn_sbcc_freq pn_muac_freq pn_wsbcc_freq pn_wash_freq pn_emgy_freq pn_hgdn_freq pn_msg_freq {
		
		replace `var' = .m if `var' == 9999
		tab `var', m 
	}
	
	mean pn_sbcc_freq 
	mean pn_muac_freq 
	mean pn_wsbcc_freq 
	mean pn_wash_freq 
	mean pn_emgy_freq 
	mean pn_hgdn_freq 
	mean pn_msg_freq
	
	tab1 pn_sbcc_past pn_muac_past pn_wsbcc_past pn_wash_past pn_emgy_past pn_hgdn_past pn_msg_past

	
// END HERE 



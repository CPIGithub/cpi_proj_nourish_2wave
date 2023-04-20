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

	** Village Survey: Main Dataset **
	use "$dta/PN_Village_Survey_FINAL_Cleaned.dta", clear 
	
	* Stratum Number * 
	gen stratum_num = .m 
	replace stratum_num = 1 if org_name == "YSDA" & stratum == 1
	replace stratum_num = 2 if org_name == "YSDA" & stratum == 2
	replace stratum_num = 3 if org_name == "KEHOC" & stratum == 1
	replace stratum_num = 4 if org_name == "KEHOC" & stratum == 2
	replace stratum_num = 5 if org_name == "KDHW" & stratum == 1
	replace stratum_num = 6 if org_name == "KDHW" & stratum == 2

	lab def stratum_num 1"YSDA: Stratum 1" 2"YSDA: Stratum 2" 3"KEHOC: Stratum 1" ///
						4"KEHOC: Stratum 2" 5"KDHW: Stratum 1" 6"KDHW: Stratum 2"
	lab val stratum_num stratum_num
	tab stratum_num, m 


	** MIGRATION **
	// demo_migrate
	tab demo_migrate, m 
	
	// demo_migrate_num
	replace demo_migrate_num = .m if demo_migrate == 0
	tab demo_migrate_num, m 
	
	// demo_migrate_hh
	// some enter as proportoion - replaced with total HH number
	forvalue x = 1/4 {
		
		tab demo_migrate_hh_`x', m 
		
		replace demo_migrate_hh_`x' = .d if demo_migrate_hh_`x' == 9999
		replace demo_migrate_hh_`x' = (demo_migrate_hh_`x' * demo_hh_number) if demo_migrate_hh_`x' < 1
		tab demo_migrate_hh_`x', m 
		
	}
	
	egen demo_migrate_hh = rowtotal(demo_migrate_hh_*)
	tab demo_migrate_hh, m 
	
	
	
	
	** IDP - INTERNALLY DISPLACED PEOPLE **
	// demo_idp
	tab demo_idp, m 
	
	// demo_idp_num 
	replace demo_idp_num = .m if demo_idp == 0
	tab demo_idp_num, m 

	// demo_idp_pop
	forvalue x = 1/3 {
		
		tab demo_idp_pop_`x', m 
		
		replace demo_idp_pop_`x' = .d if demo_idp_pop_`x' == 9999
		tab demo_idp_pop_`x', m 
		
	}
		
	
	egen demo_idp_pop = rowtotal(demo_idp_pop_*)
	tab demo_idp_pop, m 
	
	
	** DISPLACED PEOPLE **
	// demo_dspl
	tab demo_dspl, m 
	
	// demo_dspl_num
	replace demo_dspl_num = .m if demo_dspl == 0 
	tab demo_dspl_num, m 
	
	// demo_dspl_hh
	forvalue x = 1/4 {
		
		tab demo_dspl_hh_`x', m 
		
		replace demo_dspl_hh_`x' = .d if demo_dspl_hh_`x' == 9999
		tab demo_dspl_hh_`x', m 
		
	}
		
	egen demo_dspl_hh = rowtotal(demo_dspl_hh_*)
	tab demo_dspl_hh, m 		
		

	
	****************************************************************************
	** IV. Health Facilities and Health concerns **
	****************************************************************************
		
	// hfc_vill hfc_near
	// reconciliation health facility at village and nearest facility 
	
	// health facility at village 
	replace hfc_vill0 = 1 if hfc_vill6 == 1
	
	
	// health facility near village 
	replace hfc_near6 = 1 if hfc_vill6 == 1
	
	foreach var of varlist 	hfc_near0 hfc_near1 hfc_near2 hfc_near3 ///
							hfc_near4 hfc_near5 hfc_near888  {
		
		replace `var' = 0 if hfc_vill6 == 1
		tab `var'
								
	}
	
	replace hfc_vill6 = 0 if hfc_vill6 == 1
	
	tab1 hfc_vill0 hfc_vill1 hfc_vill2 hfc_vill3 hfc_vill4 hfc_vill5 hfc_vill6 hfc_vill888 
	tab1 hfc_near0 hfc_near1 hfc_near2 hfc_near3 hfc_near4 hfc_near5 hfc_near6 hfc_near888 

	
		
	// Proximity to Health care 
	foreach var of varlist hfc_near_dist_dry hfc_near_dist_rain {
		
		replace `var' = 0 if hfc_vill0 != 1
		
		tab `var'
		
		}
		
	* replace the re-coding EHO mobile team village with EHO clinics' distance mean values 
	tab hfc_near_dist_dry hfc_near6, m 
	tab hfc_near_dist_dry hfc_near4
	
	sum hfc_near_dist_dry if hfc_near4 == 1, d
	replace hfc_near_dist_dry = round(`r(mean)', 2) if mi(hfc_near_dist_dry) & hfc_near6 == 1
	tab hfc_near_dist_dry, m 
		
	sum hfc_near_dist_rain if hfc_near4 == 1, d
	replace hfc_near_dist_rain = round(`r(mean)', 2) if mi(hfc_near_dist_rain) & hfc_near6 == 1
	tab hfc_near_dist_rain, m 

	
	** MARKET **
	local mkprice	mkt_comod_rice mkt_comod_bean mkt_comod_salt ///
					mkt_comod_oil mkt_comod_chicken mkt_comod_pork ///
					mkt_comod_beef

	foreach v in `mkprice' {
		
		tab `v', m 
		
		replace `v' = .d if `v' == 888 | `v' == 999
		
	}


	tab1 mkt_near_dist_dry mkt_near_dist_rain
	foreach var of varlist mkt_near_dist_dry mkt_near_dist_rain {
		
		replace `var' = 0 if mkt_vill == 1
		tab `var'
	}

	
	** LIVELIHOOD **
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

	// lh_season - multiple choice - complex to code - leave it for now 
	drop lh_season0_* lh_season1_* lh_season2_* lh_season3_* 

		
	// lh_hh
	tab1 lh_name_*, m 
	
	forvalues x = 1/4 {
		
		gen mainlh_`x' = 		(lh_name_1 == `x' | lh_name_2 == `x' | ///
								lh_name_3 == `x' | lh_name_4 == `x' | ///
								lh_name_5 == `x' )
		tab mainlh_`x', m 
		
		
		// lh_hh
		gen mainlh_hh_`x' = lh_hh_`x' if		lh_name_1 == `x' | ///
												lh_name_2 == `x' | ///
												lh_name_3 == `x' | ///
												lh_name_4 == `x' | ///
												lh_name_5 == `x' 
		tab mainlh_hh_`x', m 
		drop lh_hh_`x'
		
		// lh_season - multiple choice - complex to code - leave it for now 
		
		
		// 	lh_hh_past
		gen mainlh_hh_past_`x' = lh_hh_past_`x' if		lh_name_1 == `x' | ///
														lh_name_2 == `x' | ///
														lh_name_3 == `x' | ///
														lh_name_4 == `x' | ///
														lh_name_5 == `x' 
		tab mainlh_hh_past_`x', m 
		drop lh_hh_past_`x'
		
		// lh_hh_coup
		gen mainlh_hh_coup_`x' = lh_hh_coup_`x' if		lh_name_1 == `x' | ///
														lh_name_2 == `x' | ///
														lh_name_3 == `x' | ///
														lh_name_4 == `x' | ///
														lh_name_5 == `x' 
		tab mainlh_hh_coup_`x', m 			
		drop lh_hh_coup_`x'
		
		// lh_income
		gen mainlh_hhincome_`x' = lh_income_`x' if		lh_name_1 == `x' | ///
														lh_name_2 == `x' | ///
														lh_name_3 == `x' | ///
														lh_name_4 == `x' | ///
														lh_name_5 == `x' 
		tab mainlh_hhincome_`x', m 	
		drop lh_income_`x'
		
		// lh_income_past
		gen mainlh_hhincome_past_`x' = lh_income_past_`x' if	lh_name_1 == `x' | ///
																lh_name_2 == `x' | ///
																lh_name_3 == `x' | ///
																lh_name_4 == `x' | ///
																lh_name_5 == `x' 
		tab mainlh_hhincome_past_`x', m 	
		drop lh_income_past_`x'
		
		// lh_income_coup
		gen mainlh_hhincome_coup_`x' = lh_income_coup_`x' if	lh_name_1 == `x' | ///
																lh_name_2 == `x' | ///
																lh_name_3 == `x' | ///
																lh_name_4 == `x' | ///
																lh_name_5 == `x' 
		tab mainlh_hhincome_coup_`x', m 
		drop lh_income_coup_`x'
	}
	
	
	order 	mainlh_1 mainlh_hh_1 mainlh_hh_past_1 mainlh_hh_coup_1 mainlh_hhincome_1 mainlh_hhincome_past_1 mainlh_hhincome_coup_1 ///
			mainlh_2 mainlh_hh_2 mainlh_hh_past_2 mainlh_hh_coup_2 mainlh_hhincome_2 mainlh_hhincome_past_2 mainlh_hhincome_coup_2 ///
			mainlh_3 mainlh_hh_3 mainlh_hh_past_3 mainlh_hh_coup_3 mainlh_hhincome_3 mainlh_hhincome_past_3 mainlh_hhincome_coup_3 ///
			mainlh_4 mainlh_hh_4 mainlh_hh_past_4 mainlh_hh_coup_4 mainlh_hhincome_4 mainlh_hhincome_past_4 mainlh_hhincome_coup_4, ///
			after(lh_num)
			
	drop lh_name_* 
	
	

	local lh `""Agriculture and livestock" "Casual labour" "Commodity Trading" "Migrant workers""'

	local i = 1 
	
	foreach n in `lh' {
		
			lab var mainlh_`i' 					"Main Livelihood: `n'"
			lab var mainlh_hh_`i' 				"% of HH: `n'"
			lab var mainlh_hh_past_`i' 			"Changed (HH) after February 2021: `n'"
			lab var mainlh_hh_coup_`i' 			"Type of changes: `n'"
			lab var mainlh_hhincome_`i' 		"Avg HH income: `n'"
			lab var mainlh_hhincome_past_`i' 	"Changed (income) compared to last year: `n'"
			lab var mainlh_hhincome_coup_`i'	"Changed (income) compared to early 2021: `n'"
			
			local i = `i' + 1
	}  
	

	
	** DEVELOPMENT PROJECT **
	
	// pn_dev_type
	local types `""Humanitarian" "Development""'
	local x = 1 
	foreach j in `types' {
		
		egen dev_proj_num_`x' = rowtotal(pn_dev_type`x'_*)
		tab dev_proj_num_`x', m 
		
		gen dev_proj_`x' = (dev_proj_num_`x' > 0)
		tab dev_proj_`x', m
		
		lab var dev_proj_num_`x'	"Number of `j' Projects (2020-now)"
		lab var dev_proj_`x'		"`j' Projects (2020-now)"
		
		local x = `x' + 1
		
	}
	
	egen dev_proj_tot = rowtotal(dev_proj_num_*)
	
	lab var dev_proj_tot "Number of projects (both types)"
	
	order dev_proj_1 dev_proj_num_1 dev_proj_2 dev_proj_num_2 dev_proj_tot, after(proj_num)
	
	
	// pn_dev_act
	local acts `""Food and Nutrition" "WASH" "Health" "Shelter" "Livelihood""'
	local x = 1
	foreach a in `acts' {
		
		egen proj_act_num_`x' = rowtotal(pn_dev_act`x'_*)
		tab proj_act_num_`x', m 
		
		gen proj_act_`x' = (proj_act_num_`x' > 0)
		tab proj_act_`x', m 
		
		lab var proj_act_num_`x' "Number of `a' activity"
		lab var proj_act_`x' "Activity: `a'"
		
		local x = `x' + 1
		
	}
	
	
	// Project Nourished Implementation 

	tab1 pn_sbcc_yn pn_muac_yn pn_wsbcc_yn pn_wash_yn pn_emgy_yn pn_hgdn_yn pn_msg_yn
	
	foreach var of varlist pn_sbcc_yn pn_muac_yn pn_wsbcc_yn pn_wash_yn pn_emgy_yn pn_hgdn_yn pn_msg_yn {
		
		replace `var' = .m if `var' == 777
		tab `var'
	}
	
	egen pn_tot = rowtotal(pn_sbcc_yn pn_muac_yn pn_wsbcc_yn pn_wash_yn pn_emgy_yn pn_hgdn_yn pn_msg_yn)
	tab pn_tot, m 
	
	gen pn_yes = (pn_tot > 0 & !mi(pn_tot))
	lab var pn_yes "Exposure with at least one of the Project Nourish Activity"
	tab pn_yes, m 
	


	* save as labeled var dataset  
	save "$dta/PN_Village_Survey_FINAL_Constructed.dta", replace  



// END HERE 



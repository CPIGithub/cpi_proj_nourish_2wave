/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	Endline data collection: Program exposure data cleaning 			
Author				:	Nicholus Tint Zaw
Date				: 	06/13/2024
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"


	****************************************************************************
	* HH Level Dataset *
	****************************************************************************
	use "$dta/endline/PN_HH_Survey_Endline_FINAL_Cleaned.dta", clear
	
	* keep only HH income and characteristc modules 
	local maingeo 	org_name stratum geo_town township_name geo_vt geo_eho_vt_name geo_vill geo_eho_vill_name
	local mainresp 	respd_id respd_who respd_name respd_sex respd_age respd_status ///
					resp_hhhead resp_highedu resp_occup respd_preg respd_child ///
					respd_1stpreg_age respd_chid_num hhhead_highedu hhhead_occup hh_mem_highedu_all
	
	keep 	`maingeo' `mainresp' ///
			uuid _parent_index ///
			iycf_knw_note - hwash_k_oth
			
	// drop cal* // cla*
	
	* Check for Missing variable label and variable label 
	//iecodebook template using "$raw/endline/codebook/pnourish_knowledge_module_final.xlsx" // export template
	//lab drop vill_accessibility_midterm_cat // problem with var lab
	iecodebook apply using "$raw/endline/codebook/pnourish_knowledge_module_final.xlsx" 
	
	destring random_iycf_num random_food_num, replace 
	
	** Knowledge of IYCF practices ** 
	* module 1 
	// iycf_knw_v2_1 iycf_knw_v2_2 iycf_knw_v2_3 iycf_knw_v2_4 iycf_knw_v2_5 iycf_knw_v2_6 
	foreach var of varlist iycf_knw_v2_1 iycf_knw_v2_2 iycf_knw_v2_3 iycf_knw_v2_4 iycf_knw_v2_5 iycf_knw_v2_6 {
		
		replace `var' = .d if `var' == 98
		replace `var' = .r if `var' == 97
		tab `var', m 
		
	}
	
	
	* EIBF 
	gen eibf_k = (iycf_knw_v2_1 < 3)
	replace eibf_k = .m if iycf_knw_v2_1 == .m | iycf_knw_v2_1 == .n 
	lab var eibf_k "Knowledge: Early initiation of Breastfeeding"
	lab val eibf_k yesno 
	tab eibf_k, m 
	
	* Intro semi-solid food 
	gen isssf_food_k = (iycf_knw_v2_2 >= 6 & iycf_knw_v2_2 <= 8)
	replace isssf_food_k = .m if iycf_knw_v2_2 == .m | iycf_knw_v2_2 == .n
	lab var isssf_food_k "Knowledge: Introduction of solid, semi-solid or soft foods 6-8 months"
	lab val isssf_food_k yesno 
	tab isssf_food_k, m 
	
	* Intro water 
	gen isssf_water_k = (iycf_knw_v2_3 >= 6 & !mi(iycf_knw_v2_3))
	replace isssf_water_k = .m if iycf_knw_v2_3 == .m | iycf_knw_v2_3 == .n
	lab var isssf_water_k "Knowledge: Introduction of Water (6 months or above)"
	lab val isssf_water_k yesno 
	tab isssf_water_k, m 	
	
	* Intro water 
	gen isssf_liquid_k = (iycf_knw_v2_4 >= 6 & !mi(iycf_knw_v2_4))
	replace isssf_liquid_k = .m if iycf_knw_v2_4 == .m | iycf_knw_v2_4 == .n
	lab var isssf_liquid_k "Knowledge: Introduction of Juice and other liquid (6 months or above)"
	lab val isssf_liquid_k yesno 
	tab isssf_liquid_k, m 	
	
	* Stop breastfeeding
	gen be_stop_k = (iycf_knw_v2_5 == 5 | iycf_knw_v2_5 == 6 )
	replace be_stop_k = .m if iycf_knw_v2_5 == .m | iycf_knw_v2_5 == .n
	lab var be_stop_k "Knowledge: stop breastfeeding (>= 2 years)"
	lab val be_stop_k yesno 
	tab be_stop_k, m 	
	
	* EBF 
	/* 
	EIBF == 1
	Intro Food: iycf_knw_v2_2 >= 6 months 
	Intro water: iycf_knw_v2_3 >= 6 months 
	Intro other liquid: iycf_knw_v2_4 >= 6 months 
	
	BF stop: iycf_knw_v2_5 >= 6 months  
	
	Treat don't know or refuse as No
	*/
	gen ebf_k = (	eibf_k == 1 & ///
					iycf_knw_v2_2 >= 6 & !mi(iycf_knw_v2_2) & ///
					iycf_knw_v2_3 >= 6 & !mi(iycf_knw_v2_3) & ///
					iycf_knw_v2_4 >= 6 &  !mi(iycf_knw_v2_4) & ///
					iycf_knw_v2_5 != 1 & !mi(iycf_knw_v2_5))
	//replace ebf_k = .m if mi(eibf_k) | mi(iycf_knw_v2_2) | mi(iycf_knw_v2_3) | mi(iycf_knw_v2_4) | mi(iycf_knw_v2_5)
	lab var ebf_k "Knowledge: Exclusively BF"
	lab val ebf_k yesno 
	tab ebf_k, m 

	* BF vs NBF feeding 
	gen meal_req_k = (iycf_knw_v2_6 == 1)
	replace meal_req_k = .m if iycf_knw_v2_6 == .m | iycf_knw_v2_6 == .n
	lab var meal_req_k "Knowledge: Non-BF children requires more meal than BF children"
	lab val meal_req_k yesno 
	tab meal_req_k, m 		
	
	* Priority Food 
	local foods 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 98 
	
	foreach x in `foods' {
		
		gen priority_food_k_`x' = iycf_knw_v2_7`x'
		replace priority_food_k_`x' = iycf_knw_v3_7`x' if mi(priority_food_k_`x') & !mi(iycf_knw_v3_7`x')
		tab priority_food_k_`x', m 
	}
		
	gen food_g2_k = (priority_food_k_1 ==  1 | priority_food_k_2 == 1)
	replace food_g2_k = .m if mi(priority_food_k_1) & mi(priority_food_k_2)
	tab food_g2_k, m 
	
	gen food_g3_k = (priority_food_k_3 == 1 | priority_food_k_4 == 1)
	replace food_g3_k = .m if mi(priority_food_k_3) & mi(priority_food_k_4)
	tab food_g3_k, m 
	
	gen food_g4_k = (priority_food_k_5 == 1)
	replace food_g4_k = .m if mi(priority_food_k_5) 
	tab food_g4_k, m 
	
	gen food_g5_k = (priority_food_k_6 == 1| priority_food_k_7 == 1| priority_food_k_8 == 1)
	replace food_g5_k = .m if mi(priority_food_k_6) & mi(priority_food_k_7) & mi(priority_food_k_8)
	tab food_g5_k, m 
	
	gen food_g6_k = priority_food_k_9
	tab food_g6_k, m 

	gen food_g7_k = (priority_food_k_10 ==1 | priority_food_k_11 == 1 | priority_food_k_12 == 1)
	replace food_g7_k = .m if mi(priority_food_k_10) & mi(priority_food_k_11) & mi(priority_food_k_12)
	tab food_g7_k, m 
	
	gen food_g8_k = (priority_food_k_13 == 1 |  priority_food_k_14 == 1)
	replace food_g8_k = .m if mi(priority_food_k_13) & mi(priority_food_k_14)
	tab food_g8_k, m 
	
	egen dietary_tot_k = rowtotal(food_g2_k food_g3_k food_g4_k food_g5_k food_g6_k food_g7_k food_g8_k), missing
	replace dietary_tot_k = .m if mi(food_g2_k) & mi(food_g3_k) & mi(food_g4_k) & ///
								mi(food_g5_k) & mi(food_g6_k) & mi(food_g7_k) & ///
								mi(food_g8_k)
	lab var dietary_tot_k "Knowledge: Food group score [0-7]"
	tab dietary_tot_k, m 
	
	gen dietary_4grp_k = (dietary_tot_k == 4)
	replace dietary_4grp_k = .m if mi(dietary_tot_k)
	lab var dietary_4grp_k "Knowledge: Priority Food from 4 distinct food groups (IYCF food groups)"
	lab val dietary_4grp_k yesno 
	tab dietary_4grp_k, m 
	

	// iycf_knw_v2_8 
	replace iycf_knw_v2_8 = .d if iycf_knw_v2_8 == 999
	
	sum iycf_knw_v2_8, d 
	replace iycf_knw_v2_8 = `r(p99)' if iycf_knw_v2_8 > `r(p99)' & !mi(iycf_knw_v2_8)
	tab iycf_knw_v2_8, m 
	
	
	// iycf_knw_v2_9
	replace iycf_knw_v2_9 = .d if iycf_knw_v2_9 == 999
	
	sum iycf_knw_v2_9, d 
	replace iycf_knw_v2_9 = `r(p99)' if iycf_knw_v2_9 > `r(p99)' & !mi(iycf_knw_v2_9)
	tab iycf_knw_v2_9, m 
	
	
	gen meal_freq_k = (iycf_knw_v2_8 >= 2 &  !mi(iycf_knw_v2_8) & iycf_knw_v2_9 >= 3 & !mi(iycf_knw_v2_9))
	replace meal_freq_k = .m if mi(iycf_knw_v2_8) | mi(iycf_knw_v2_9)
	lab var meal_freq_k "BF child meal frequency knowledge"
	lab val meal_freq_k yesno 
	tab meal_freq_k
	
	
	egen iycf_k_tot = rowtotal(eibf_k isssf_food_k isssf_water_k isssf_liquid_k be_stop_k ebf_k meal_req_k dietary_4grp_k meal_freq_k)
	lab var iycf_k_tot "IYCF Knowledge question score (raw score)"
	tab iycf_k_tot, m 
	
	sum iycf_k_tot, d
	gen iycf_k_yes = (iycf_k_tot >= `r(mean)')
	lab var iycf_k_yes "Know IYCF optimal practices (6 out of 9 questions: mean raw score 6.04)"
	tab iycf_k_yes, m 
	
	
	// iycf_knw_v2_7 
	/* iycf_knw_v2_71 iycf_knw_v2_72 iycf_knw_v2_73 iycf_knw_v2_74 iycf_knw_v2_75 iycf_knw_v2_76 iycf_knw_v2_77 iycf_knw_v2_78 iycf_knw_v2_79 iycf_knw_v2_710 iycf_knw_v2_711 iycf_knw_v2_712 iycf_knw_v2_713 iycf_knw_v2_714 iycf_knw_v2_715 iycf_knw_v2_798 */
	
	// iycf_knw_v3_7 
	/* iycf_knw_v3_71 iycf_knw_v3_72 iycf_knw_v3_73 iycf_knw_v3_74 iycf_knw_v3_75 iycf_knw_v3_76 iycf_knw_v3_77 iycf_knw_v3_78 iycf_knw_v3_79 iycf_knw_v3_710 iycf_knw_v3_711 iycf_knw_v3_712 iycf_knw_v3_713 iycf_knw_v3_714 iycf_knw_v3_715 iycf_knw_v3_798 */
	
	forvalues x = 1/15 {
		
		sum iycf_knw_v2_7`x' iycf_knw_v3_7`x'
		
	}
	
	
	// iycf_knw_v2_8 iycf_knw_v2_9
	foreach var of varlist iycf_knw_v2_8 iycf_knw_v2_9 {
		
		replace `var' = .d if `var' == 999
		tab `var', m 
		
	}
	
	
	* module - 2
	tab1 iycf_knw_1 iycf_knw_2 iycf_knw_3 iycf_knw_4 iycf_knw_5 iycf_knw_6 iycf_knw_7, m 
	// treat don't remember and refuse as NO
	
	forvalues x = 1/7 {
		
		replace iycf_knw_`x' = .m if random_iycf_num != 1
		replace iycf_knw_`x' = 0 if iycf_knw_`x' > 1 &  !mi(iycf_knw_`x')
		lab val iycf_knw_`x' yesno 
		tab iycf_knw_`x', m 
	}
	
	egen iycf_kscore_tot_dq = rowtotal(iycf_knw_1 iycf_knw_2 iycf_knw_3 iycf_knw_4 iycf_knw_5 iycf_knw_6 iycf_knw_7)
	replace iycf_kscore_tot_dq = .m if random_iycf_num != 1
	lab var iycf_kscore_tot_dq "Total IYCF Knowledge Raw Score [0-7] - opended questions"
	tab iycf_kscore_tot_dq, m 
	
	egen iycf_kscore_bf_dq = rowtotal(iycf_knw_1 iycf_knw_3 iycf_knw_4)
	replace iycf_kscore_bf_dq = .m if random_iycf_num != 1
	lab var iycf_kscore_bf_dq "Breastfeeding Knowledge Raw Score [0-3] - opended questions"
	tab iycf_kscore_bf_dq, m 	
	
	egen iycf_kscore_cf_dq = rowtotal(iycf_knw_2 iycf_knw_5 iycf_knw_6 iycf_knw_7)
	replace iycf_kscore_cf_dq = .m if random_iycf_num != 1
	lab var iycf_kscore_cf_dq "Complementary Feeding Knowledge Raw Score [0-4] - opended questions"
	tab iycf_kscore_cf_dq, m 		
	
	
	
	** Understanding Barriers and Facilitators to Optimal Infant and Young Child Feeding Practices ** 
	// iycf_k_ebfwater 
	//iycf_k_ebfwater1 iycf_k_ebfwater2 iycf_k_ebfwater3 iycf_k_ebfwater4 iycf_k_ebfwater5 iycf_k_ebfwater888 iycf_k_ebfwater_oth 
	
	// iycf_k_earlyfood 
	//iycf_k_earlyfood1 iycf_k_earlyfood2 iycf_k_earlyfood3 iycf_k_earlyfood4 iycf_k_earlyfood5 iycf_k_earlyfood888 iycf_k_earlyfood_oth 
	
	// iycf_k_notfeed_1 
	//iycf_k_notfeed_11 iycf_k_notfeed_12 iycf_k_notfeed_13 iycf_k_notfeed_14 iycf_k_notfeed_1888 iycf_k_notfeed_1_oth 
	
	// iycf_k_notfeed_2 
	//iycf_k_notfeed_21 iycf_k_notfeed_22 iycf_k_notfeed_23 iycf_k_notfeed_24 iycf_k_notfeed_2888 iycf_k_notfeed_2_oth 
	
	// iycf_k_notfeed_3 
	//iycf_k_notfeed_31 iycf_k_notfeed_32 iycf_k_notfeed_33 iycf_k_notfeed_34 iycf_k_notfeed_3888 iycf_k_notfeed_3_oth 
	
	// iycf_k_notfeed_4 
	//iycf_k_notfeed_41 iycf_k_notfeed_42 iycf_k_notfeed_43 iycf_k_notfeed_44 iycf_k_notfeed_4888 iycf_k_notfeed_4_oth 
	
	// iycf_k_notfeed_5 
	//iycf_k_notfeed_51 iycf_k_notfeed_52 iycf_k_notfeed_53 iycf_k_notfeed_54 iycf_k_notfeed_5888 iycf_k_notfeed_5_oth 
	
	// iycf_k_notfeed_6 
	//iycf_k_notfeed_61 iycf_k_notfeed_62 iycf_k_notfeed_63 iycf_k_notfeed_64 iycf_k_notfeed_6888 iycf_k_notfeed_6_oth
	
	
	** Handwashing ** 
	tab1 hwash_k hwash_k1 hwash_k2 hwash_k3 hwash_k4 hwash_k5 hwash_k6 hwash_k7 hwash_k8 hwash_k888 hwash_k_oth, m 
	
	/* program team definition 
	WASH practice in critical situation include Hand Washing 

	before food preparation, 
	before and after having meal and 
	feeding to child, 
	after going to toilet, 
	after handling child fecal matters 
	*/

	egen hw_critical_soap_k 	= rowtotal(hwash_k4 hwash_k2 hwash_k3 hwash_k5 hwash_k1 hwash_k8)
	replace hw_critical_soap_k 	= 0 if hw_critical_soap_k < 6
	replace hw_critical_soap_k 	= 1 if hw_critical_soap_k == 6
	replace hw_critical_soap_k 	= .m if 	mi(hwash_k4) | mi(hwash_k2) | ///
											mi(hwash_k3) | mi(hwash_k5) | ///
											mi(hwash_k1) | mi(hwash_k8)
	tab hw_critical_soap_k, m 
	lab var hw_critical_soap_k "Handwashing with soap at 5 critical times - knowledge (Program Team def)"


	* Add Weight variable *
	merge m:1 geo_vill 	using "$dta/endline/pnourish_endline_hh_weight_final.dta", ///
						keepusing(stratum stratum_num org_name_num weight_final) ///
						assert(3) nogen 
	
	
	
	* Add Wealth Quantile variable **
	// drop prgexpo_pn
	merge m:1 _parent_index using "$dta/endline/pnourish_INCOME_WEALTH_final.dta", ///
							keepusing(income_lastmonth wealth_quintile_ns wealth_quintile_modify ///
							NationalQuintile NationalScore hhitems_phone prgexpo_pn edu_exposure) ///
							assert(3) nogen 

	* Add Village Survey Info 
	global villinfo 	hfc_near_dist_dry hfc_near_dist_rain ///
						mkt_near_dist_dry mkt_near_dist_rain ///
						dev_proj_tot ///
						pn_yes pn_sbcc_yn pn_muac_yn pn_wsbcc_yn pn_wash_yn pn_emgy_yn pn_hgdn_yn pn_msg_yn
	
	merge m:1 geo_vill using 	"$dta/endline/PN_Village_Survey_Endline_FINAL_Constructed.dta", ///
								keepusing($villinfo)
	
	drop if _merge == 2
	
	drop _merge 
	
	
	** SAVE for analysis dataset 
	save "$dta/endline/pnourish_knowledge_module_final.dta", replace  


// END HERE 



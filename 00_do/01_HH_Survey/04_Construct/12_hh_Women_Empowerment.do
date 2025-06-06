/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: hh Income and Wealth Quantile cleaning 			
Author				:	Nicholus Tint Zaw
Date				: 	03/01/2023
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

********************************************************************************
* household survey *
********************************************************************************

	** HH Survey Dataset **
	use "$dta/PN_HH_Survey_HH_Level_raw.dta", clear 
	
	* keep only HH income and characteristc modules 
	local maingeo 	org_name stratum geo_town township_name geo_vt geo_eho_vt_name geo_vill geo_eho_vill_name
	local mainresp 	respd_id respd_who respd_name respd_sex respd_age respd_status ///
					resp_hhhead resp_highedu resp_occup respd_preg respd_child ///
					respd_1stpreg_age respd_chid_num hhhead_highedu hhhead_occup hh_mem_highedu_all
	
	keep 	`maingeo' `mainresp' ///
			uuid _parent_index ///
			cal_sum_feadult ///
			cal_wemp_start-cal_wemp_end
			
	rename cal_sum_feadult female_adult
			
	drop cal* // cla*
	
	** Women empowerment 
	// ref: https://www.dhsprogram.com/Data/Guide-to-DHS-Statistics/index.cfm
	
	destring female_adult, replace 
	
	foreach v of varlist 	wempo_childcare wempo_mom_health wempo_child_health ///
							wempo_women_wages wempo_major_purchase wempo_visiting ///
							wempo_women_health wempo_child_wellbeing  {
		
		replace `v' = .m if female_adult == 0 
		tab `v', m 
	}
	
	
	foreach v of varlist 	wempo_childcare wempo_mom_health wempo_child_health ///
							wempo_women_wages wempo_major_purchase wempo_visiting ///
							wempo_women_health wempo_child_wellbeing  {
		
		replace `v' = .m if female_adult == 0 
		tab `v', m 
		
		* Gen dummy one
		local oldlab : variable label `v'
		
		gen `v'_yes = (`v' == 1)
		replace `v'_yes = .m if mi(`v')
		lab var `v'_yes "`oldlab'"
		tab `v'_yes, m 

	}
	
	
	// 1) Own health care.
	gen women_ownhealth = (wempo_mom_health == 1)
	replace women_ownhealth = .m if mi(wempo_mom_health)
	lab var women_ownhealth "Own health care"
	tab women_ownhealth, m 

	// 2) Large household purchases.
	gen women_hhpurchase = (wempo_major_purchase == 1)
	replace women_hhpurchase = .m if mi(wempo_major_purchase)
	lab var women_hhpurchase "Large household purchases"
	tab women_hhpurchase, m 
	
	// 3) Visits to family or relatives.
	gen women_visit = (wempo_visiting == 1)
	replace women_visit = .m if mi(wempo_visiting)
	lab var women_visit "Visits to family or relatives"
	tab women_visit, m 
	
	
	// wempo_group 
	foreach v of varlist wempo_group1 wempo_group2 wempo_group3 wempo_group4 wempo_group5 wempo_group888 wempo_group777 wempo_group999 {
		
		replace `v' = .m if female_adult == 0 
		tab `v', m 
	}
	
	
	* Add Weight variable *
	merge m:1 geo_vill 	using "$dta/pnourish_midterm_hh_weight_final.dta", /// // pnourish_hh_weight_final 
						keepusing(stratum stratum_num org_name_num weight_final)
	
	keep if _merge == 3
	
	drop _merge 
	
	
	* Add Wealth Quantile variable **
	//drop prgexpo_pn
	merge m:1 _parent_index using "$dta/pnourish_INCOME_WEALTH_final.dta", ///
							keepusing(enu_name income_lastmonth wealth_quintile_ns ///
							wealth_quintile_modify NationalQuintile NationalScore hhitems_phone prgexpo_pn edu_exposure)
	
	keep if _merge == 3
	
	drop _merge 

	* Add Village Survey Info 
	global villinfo 	hfc_near_dist_dry hfc_near_dist_rain ///
						mkt_near_dist_dry mkt_near_dist_rain ///
						dev_proj_tot ///
						pn_yes pn_sbcc_yn pn_muac_yn pn_wsbcc_yn pn_wash_yn pn_emgy_yn pn_hgdn_yn pn_msg_yn
	
	merge m:1 geo_vill using 	"$dta/PN_Village_Survey_FINAL_Constructed.dta", ///
								keepusing($villinfo)
	
	drop if _merge == 2
	
	drop _merge 
	
	
	
	** Inverse covariance weighting - application **
	* recode the variable applied for index development
	/*
	-1 Men vs 1 Women and 0 for joint
	
	
	*/
	
	local attributes 	wempo_childcare wempo_mom_health wempo_child_health wempo_women_wages ///
						wempo_major_purchase wempo_visiting wempo_women_health wempo_child_wellbeing
	
	/*
	// this is the code use at midterm and have flaw in value assignment - for women and men deicision making 
	// improved at endline but the midterm result did not change much as only slightly changes in value and still significant among qealth quintiles
	
	foreach var in `attributes' { 
	    
		gen `var'_d = (`var' == 1) 
		replace `var'_d = -1 if `var' == 2
		replace `var'_d = .m if `var' == 0 | `var' > 3
		tab `var'_d, m 
	}
	*/
	
	// endline improvement code 
	foreach var in `attributes' {
	    
		gen `var'_d = (`var' == 1) // women alone 
		replace `var'_d = -1 if `var' >= 3 & !mi(`var') // husband or others
		replace `var'_d = .m if mi(`var') // `var' == 0 //| `var' > 3
		tab `var'_d, m 
	}
	
	* code as -1 for no working women 
	replace wempo_women_wages_d = -1 if wempo_women_wages == 0 
	
	gen wempo_hnut_act_ja = (wempo_child_health < 3 | wempo_childcare < 3 | wempo_child_wellbeing < 3)
	replace wempo_hnut_act_ja = .m if mi(wempo_child_health) & mi(wempo_childcare) & mi(wempo_child_wellbeing)
	lab var wempo_hnut_act_ja "Health and nutritional activities of children (either joint or alone)"
	tab wempo_hnut_act_ja, m 	
	
	egen wempo_grp_tot = rowtotal(wempo_group2 wempo_group3 wempo_group4 wempo_group5 wempo_group888)
	replace wempo_grp_tot = 0 if wempo_group1 == 1
	replace wempo_grp_tot = .m if mi(wempo_group)
	tab wempo_grp_tot, m 
	  
	* standartized the variable  inputs for ICW index development 
	local inputs 	wempo_grp_tot wempo_childcare_d wempo_mom_health_d ///
					wempo_child_health_d wempo_women_wages_d wempo_major_purchase_d ///
					wempo_visiting_d wempo_women_health_d wempo_child_wellbeing_d
	
	foreach var in `inputs' {
	    
		zindex `var', gen(`var'_z) 
		
	}
	
	* index development // not included the # of groups participate 
	icw_index	wempo_childcare_d_z wempo_mom_health_d_z wempo_child_health_d_z ///
				wempo_women_wages_d_z wempo_major_purchase_d_z wempo_visiting_d_z ///
				wempo_women_health_d_z wempo_child_wellbeing_d_z, gen(wempo_index)
	
	lab var wempo_index "Women Empowerment Index (ICW-index)"		
	tab wempo_index, m 
	
	icw_index	wempo_childcare_d wempo_mom_health_d wempo_child_health_d ///
				wempo_women_wages_d wempo_major_purchase_d wempo_visiting_d ///
				wempo_women_health_d wempo_child_wellbeing_d, gen(wempo_index_d)
	
	lab var wempo_index_d "Women Empowerment Index (ICW-index) - not z-score"		
	tab1 wempo_index wempo_index_d, m 
	sum wempo_index wempo_index_d
	
	** Revised the Womem empowerment index subcategory ** 
	icw_index	wempo_childcare_d_z wempo_child_health_d_z wempo_child_wellbeing_d_z, gen(wempo_child_index)
	icw_index	wempo_mom_health_d_z wempo_women_health_d_z , gen(wempo_mom_index)
	icw_index	wempo_women_wages_d_z wempo_major_purchase_d_z wempo_visiting_d_z, gen(wempo_othd_index)
		
	lab var wempo_child_index "Women Empowerment (Child Care and Health) Index (ICW-index)"		
	lab var wempo_mom_index "Women Empowerment (Women and Mother Health) Index (ICW-index)"		
	lab var wempo_othd_index "Women Empowerment (Other Decision Making) Index (ICW-index)"		
	
	sum wempo_index wempo_*_index
	
	* Category - by quintile 
	xtile wempo_category = wempo_index [pweight=weight_final], nq(3)
	lab var wempo_category "Women Empowerment (Category)"
	
	gen wempo_category_sd = (wempo_index <= -0.25)
	replace wempo_category_sd = 2 if (wempo_index > -0.25 & wempo_index < 0.25)
	replace wempo_category_sd = 3 if wempo_index >= 0.25 &  !mi(wempo_index)
	replace wempo_category_sd = .m if mi(wempo_index)
	lab def wempolabel 1 "Low" 2 "Moderate" 3 "High"
	label values wempo_category_sd wempolabel
	tab1 wempo_category wempo_category_sd, m 
	tab wempo_category wempo_category_sd, m 
	
	xtile wempo_child_cat = wempo_child_index [pweight=weight_final], nq(3)
	lab var wempo_child_cat "Women Empowerment: Child Care and Health (Category)"
	
	xtile wempo_mom_cat = wempo_mom_index [pweight=weight_final], nq(3)
	lab var wempo_mom_cat "Women Empowerment: Women and Mother Health (Category)"
	
	lab def wempo_category 1"Low" 2"Moderate" 3"High"
	lab val wempo_category wempo_child_cat wempo_mom_cat wempo_category
	tab1 wempo_category wempo_child_cat wempo_mom_cat, m 
	
	histogram wempo_index, normal ///
		title("Distribution of ICW Empowerment Index") ///
		xtitle("ICW Index") ytitle("Frequency")
	
	kdensity wempo_index, normal ///
		title("Kernel Density of ICW Index with Normal Curve") ///
		xtitle("ICW Index")

	
	* progressiveness 
	foreach var of varlist wempo_index wempo_child_index wempo_mom_index wempo_othd_index {
		
		epctile `var' , p(50) svy
		mat def m = e(b)
		local median = m[1,1]
		
		gen `var'_l = (`var' < `median')
		replace `var'_l = .m if mi(`var')
		svy: tab `var'_l
		
		gen `var'_h = (`var'_l == 0)
		replace `var'_h = .m if mi(`var'_l)
		svy: tab `var'_h
	}
		
	rename wempo_index_l progressivenss 
	rename wempo_index_h high_empower
	
	lab var progressivenss "Low Women Empowerment (Index < median score)"
	lab var high_empower "High Women Empowerment (Index > median score)"
	
	rename wempo_child_index_l progressivenss_child 
	rename wempo_child_index_h high_empower_child
	rename wempo_mom_index_l progressivenss_mom
	rename wempo_mom_index_h high_empower_mom
	rename wempo_othd_index_l progressivenss_othd
	rename wempo_othd_index_h high_empower_othd
	
	lab var progressivenss_child "Low Women Empowerment: Child Care and Health (Index < median score)"
	lab var high_empower_child "High Women Empowerment: Child Care and Health (Index > median score)"
	lab var progressivenss_mom "Low Women Empowerment: Women and Mother Health (Index < median score)"
	lab var high_empower_mom "High Women Empowerment: Women and Mother Health (Index > median score)"
	lab var progressivenss_othd "Low Women Empowerment: Other decision making dimensions (Index < median score)"
	lab var high_empower_othd "High Women Empowerment: Other decision making dimensions (Index > median score)"

	merge 1:1 respd_id using "$dta/pnourish_FIES_final.dta"
		 
	* Check for Missing variable label and variable label 
	// iecodebook template using "$out/pnourish_WOMEN_EMPOWER_final.xlsx" // export template
	
	iecodebook apply using "$raw/pnourish_WOMEN_EMPOWER_cleaning.xlsx" 
	
	* Income Quantile
	xtile income_quintile = income_lastmonth [pweight=weight_final], nq(5)
	lab var income_quintile "HH Income (Last month) Quintile"
	
	
	* Income Category - 
	* ref: https://www.tandfonline.com/doi/epdf/10.1080/10095020.2023.2250388?needAccess=true
	gen income_quintile_cust = (income_lastmonth < 50000)
	replace income_quintile_cust = 2  if income_lastmonth >= 50000 & income_lastmonth < 100000
	replace income_quintile_cust = 3  if income_lastmonth >= 100000 & income_lastmonth < 200000
	replace income_quintile_cust = 4  if income_lastmonth >= 200000 & income_lastmonth < 400000
	replace income_quintile_cust = 5  if income_lastmonth >= 400000 & !mi(income_lastmonth)
	replace income_quintile_cust = .m if mi(income_lastmonth)
	lab def income_quintile_cust 	1"Poorest (< 50000 MMK)" 2"Poor (50000-100000 MMK)" ///
									3"Medium (100000-200000 MMK)" 4"Wealthy (200000-400000 MMK)" ///
									5"Wealthiest (>= 400000 MMK)"
	lab val income_quintile_cust income_quintile_cust
	lab var income_quintile_cust "Wealth Category (by last month HH income)"
	tab income_quintile_cust, m 
	
	** SAVE for analysis dataset 
	save "$dta/pnourish_WOMEN_EMPOWER_final.dta", replace  


// END HERE 



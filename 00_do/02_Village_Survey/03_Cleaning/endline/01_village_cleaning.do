/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	Endline data collection: Village svy data cleaning 			
Author				:	Nicholus Tint Zaw
Date				: 	06/13/2024
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
	use "$dta/endline/pnourish_endline_village_svy_wide.dta", clear 
	
	// will_participate
	tab will_participate, m 
	
	keep if will_participate == 1 // keep onl consent villages 

	
	* village geo data cleaning * 
	// inital attempt 
	order	geo_town cal_town geo_vt cal_vt vt_cluster_cat cluster_cat geo_vill cal_vill ///
			vill_data_yes vill_data_no, after(enu_name)
	

	// replacement 
	order	rpl_cluster_cat rpl_geo_town cal_rpl_town rpl_geo_vt cal_rpl_vt ///
			rpl_vt_cluster_cat rpl_geo_vill cal_rpl_vill rpl_vill_data_yes ///
			rpl_vill_data_no, after(vill_data_no)

	* identify the actual village made data collection 
	// vill_data_yes 
	replace vill_data_yes = 1 if mi(vill_data_yes) // as this was newly added villages initial submission one were missing field 
	tab vill_data_yes, m 
	
	// rpl_vill_data_yes
	replace rpl_vill_data_yes = .m if vill_data_yes == 1
	tab rpl_vill_data_yes, m 
		
	
	* keep only village where field team can make data collection 
	keep if rpl_vill_data_yes == 1 | vill_data_yes == 1
	
	rename (cal_rpl_town cal_rpl_vt cal_rpl_vill) (rpl_cal_town rpl_cal_vt rpl_cal_vill)
	/*
	local geoinfo geo_town cal_town geo_vt cal_vt vt_cluster_cat cluster_cat geo_vill cal_vill
	
	foreach v in `geoinfo' {
		
		local old_label: variable label `v'
		
		gen f_`v' 		= `v' 
		replace f_`v' 	= rpl_`v' if vill_data_yes == 0 & rpl_vill_data_yes == 1
		order f_`v', after(`v')
		
		lab var f_`v' "`old_label'"
		
		drop `v' rpl_`v'
		
		rename f_`v' `v'
		
	} 
	*/
	
	* Respondent info * 
	
	
	** Duplicate Check **
	distinct geo_vill
	
	sort geo_vill starttime
	bysort geo_vill: keep if _n == 1
	
	
	// respd_name
	tab respd_name, m 
	
	// respd_sex
	tab respd_sex, m 
	
	// respd_role
	tab respd_role, m 
	tab respd_role, m 

	// respd_role_oth
	tab respd_role_oth, m 
	
	// respd_role_yrs
	tab respd_role_yrs, m 
	
	// respd_1stround
	replace respd_1stround = .r if respd_1stround == 777 
	tab respd_1stround, m 
	
	// respd_2ndround
	tab respd_2ndround, m 

	tab respd_1stround respd_2ndround, m 
	
	** Apply Weight **
	// merge 1:1 geo_vill using "$dta/pnourish_hh_weight_final.dta", keepusing(cluster_prob)  

	* save as labeled var dataset  
	save "$dta/endline/PN_Village_Survey_Endline_FINAL.dta", replace  


// END HERE 



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
	use "$dta/pnourish_village_svy_wide.dta", clear 
	
	
	***************************************
	// check for the replacement villages patterm 
	
	preserve 
	
		keep geo_vill vill_data_yes
		
		tempfile initial 
		save `initial', replace 
	
	restore 
	
	preserve 
	
		keep if vill_data_yes == 0 
		keep if rpl_vill_data_yes == 0
		
		keep rpl_geo_vill rpl_vill_data_yes
 
		rename rpl_geo_vill geo_vill
		
		duplicates drop *, force 
		
		tempfile replace 
		save `replace', replace 
	
	restore 	
	
	
	preserve 
	
	use `initial', replace 
	
	sort geo_vill vill_data_yes
	
	bysort geo_vill: keep if _n == _N 
		
	merge 1:1 geo_vill using `replace'
	
	restore 
	
	
	***************************************
	
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
	
	
	* Respondent info * 
	
	
	** Duplicate Check **
	distinct geo_vill
	
	sort geo_vill starttime_c
	bysort geo_vill: keep if _n == 1
	
	
	// respd_name
	tab respd_name, m 
	
	// respd_sex
	tab respd_sex, m 
	
	// respd_role
	tab respd_role, m 
	lab def role 	1"Village tract administrator" ///
					2"Village administrator (10/100 HH leader)" ///
					3"Village Health Committee Members" ///
					4"Village leaders (elder from the villages)" ///
					888"Other" 
	lab val respd_role role
	tab respd_role, m 

	// respd_role_oth
	tab respd_role_oth, m 
	
	// respd_role_yrs
	tab respd_role_yrs, m 
	
	// respd_1stround
	replace respd_1stround = .r if respd_1stround == 777 
	tab respd_1stround, m 

	
	
	
	// Lablening 

	* Define labels for vill_data_yes
	label define vill_data_yes_lbl 1 "Yes" ///
								   0 "No"
								   
	* Apply labels to vill_data_yes variable
	label values vill_data_yes vill_data_yes_lbl

	* Define labels for demo_hh_change
	label define demo_hh_change_lbl 1 "Yes" ///
								   0 "No" ///
								   777 "Not sure"
								   
	* Apply labels to demo_hh_change variable
	label values demo_hh_change demo_hh_change_lbl

	* Define labels for respd_sex
	label define respd_sex_lbl 1 "Male" ///
							  0 "Female"
							  
	* Apply labels to respd_sex variable
	label values respd_sex respd_sex_lbl

	* Define labels for svy_team
	label define svy_team_lbl 1 "Team 1" ///
							 2 "Team 2" ///
							 3 "Team 3"
							 
	* Apply labels to svy_team variable
	label values svy_team svy_team_lbl

	* Define labels for org_team
	label define org_team_lbl 1 "KEHOC" ///
							 2 "YSDA" ///
							 3 "KDHW"
							 
	* Apply labels to org_team variable
	label values org_team org_team_lbl

	* Define labels for respd_role
	label define respd_role_lbl 1 "Village tract administrator" ///
							   2 "Village administrator (10/100 HH leader)" ///
							   3 "Village Health Committee Members" ///
							   4 "Village leaders (elder from the villages)" ///
							   888 "Other (specify)"
							   
	* Apply labels to respd_role variable
	label values respd_role respd_role_lbl

	* Define labels for respd_1stround
	label define respd_1stround_lbl 1 "Yes" ///
									0 "No" ///
									777 "Not remember"
									
	* Apply labels to respd_1stround variable
	label values respd_1stround respd_1stround_lbl

	* Define labels for demo_hh_scale
	label define demo_hh_scale_lbl 1 "Significantly increased" ///
									2 "Slightly increased" ///
									3 "Slightly decreased" ///
									4 "Significantly decreased"
									
	* Apply labels to demo_hh_scale variable
	label values demo_hh_scale demo_hh_scale_lbl

	* Define labels for hfc_visit_eho_past
	label define hfc_visit_eho_past_lbl 1 "Increased" ///
									   2 "Decreased" ///
									   3 "Still the same" ///
									   4 "Not sure"
									   
	* Apply labels to hfc_visit_eho_past variable
	label values hfc_visit_eho_past hfc_visit_eho_past_lbl

	* Define labels for mkt_vill_type
	label define mkt_vill_type_lbl 1 "Small" ///
								  2 "Medium" ///
								  3 "Large"
								  
	* Apply labels to mkt_vill_type variable
	label values mkt_vill_type mkt_vill_type_lbl


	** Apply Weight **
	// merge 1:1 geo_vill using "$dta/pnourish_hh_weight_final.dta", keepusing(cluster_prob)  

	 
	* save as labeled var dataset  
	save "$dta/PN_Village_Survey_FINAL_Cleaned.dta", replace  



// END HERE 



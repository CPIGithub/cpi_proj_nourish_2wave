/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	M&E MUAC DATA				
Author				:	Nicholus Tint Zaw
Date				: 	11/24/2022
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"


	********************************************************************************
	* import HH survey *
	********************************************************************************

	use "$dta/01_final/Pnourish_HH_Level_Dataset.dta", clear
	
	// get village list 
	bysort township_name geo_eho_vt_name geo_eho_vill_name: keep if _n == 1
	
	keep township_name geo_eho_vt_name geo_eho_vill_name stratum_num
	
	// merge with MUAC data 
	merge 1:m township_name geo_eho_vt_name geo_eho_vill_name using "$dta/MUAC.dta"
	
	keep if _merge == 3
	
	drop _merge 
	
	tab stratum_num
	
	tabstat muac, by(stratum_num)
	
	drop muaccategory no
	
	* Child Malnourish Status 
	rename muac u5_muac
	
	// child malnutrition 
	gen child_gam = (u5_muac < 12.5)
	replace child_gam = .m if mi(u5_muac) 
	lab var child_gam "Acute Malnutrition (MUAC < 12.5)"
	tab child_gam, m 

	gen child_mam = (u5_muac >= 11.5 & u5_muac < 12.5)
	replace child_mam = .m if mi(u5_muac)
	lab var child_mam "Moderate Acute Malnutrition (11.5 >= MUAC <= 12.5)"
	tab child_mam, m 

	gen child_sam = (u5_muac < 11.5)
	replace child_sam = .m if mi(u5_muac) 
	lab var child_sam "Moderate Acute Malnutrition (MUAC < 11.5)"
	tab child_sam, m 

	//lab def yesno 1"Yes" 0"No"
	lab val child_gam yesno 
	lab val child_mam yesno 
	lab val child_sam yesno 
		
	rename childsex child_sex
	replace child_sex = "1" if child_sex == "Male"
	replace child_sex = "0" if child_sex == "Female"
	destring child_sex, replace 
	
	//lab def gender 1"Male" 0"Female"
	lab val child_sex gender 
	

	* measurement month 
	gen measure_month = month(date)
	
	lab def month 8"Aug-22" 9"Sep-22" 10"Oct-22" 11"Nov-22" 12"Dec-22"
	lab val measure_month month 

	

	order measure_month, after(date)
	
	sort township_name geo_eho_vt_name geo_eho_vill_name measure_month

	
	bysort stratum_num measure_month: egen gam_prev = mean(child_gam) 
	replace gam_prev = round(gam_prev * 100, 0.01)
	
	bysort stratum_num measure_month: gen child_N = _N 
	
	bysort stratum_num measure_month: keep if _n == 1
	
	br stratum_num measure_month gam_prev child_N
	
	

// end of dofile 
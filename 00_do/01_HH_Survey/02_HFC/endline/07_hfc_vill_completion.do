/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	Endline data collection: village completion comparision		
Author				:	Nicholus Tint Zaw
Date				: 	06/13/2024
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "00_dir_setting.do"

	********************************************************************************
	* household survey - village completion *
	********************************************************************************

	* HH svy 
	use "$dta/endline/pnourish_endline_hh_svy_wide.dta", clear

	keep if will_participate == 1

	keep geo_vill cal_vill

	bysort geo_vill cal_vill: keep if _n == 1

	gen hh_svy_village = 1
	
	tempfile hhsvy
	save `hhsvy', replace 

	* Village svy 
	use "$dta/endline/PN_Village_Survey_ENDLINE_FINAL.dta", clear 
	
	keep if will_participate == 1
	
	keep geo_vill cal_vill

	bysort geo_vill cal_vill: keep if _n == 1

	gen vill_svy_village = 1
	
	
	* Matched two dataset 
	merge 1:1 geo_vill using `hhsvy'

	gen vill_hh_svy_village = _merge 
	
	drop _merge 
	
	lab def vill_hh_svy_village 1"Village survey only" 2"HH survey only" 3"Finished both surveys"
	lab val vill_hh_svy_village vill_hh_svy_village
	
	tab vill_hh_svy_village, m 


	if _N > 0 {

		export excel using "$out/endline/07_village_completion_compare.xlsx", sheet("HH_VS_Village_Svys") firstrow(varlabels) sheetreplace
		
	}



	* END here 


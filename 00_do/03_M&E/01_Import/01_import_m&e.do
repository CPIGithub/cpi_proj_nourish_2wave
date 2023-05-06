/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	import M&E data				
Author				:	Nicholus Tint Zaw
Date				: 	11/24/2022
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"


	********************************************************************************
	* import M&E survey *
	********************************************************************************

	import excel using "$raw/PN_M&E_FORMATS.xlsx", describe

	forvalue x = 1/`r(N_worksheet)' {
		
		local sheet_`x' `r(worksheet_`x')'
	}

	forvalue x = 1/`r(N_worksheet)' {
		
		import excel using "$raw/PN_M&E_FORMATS.xlsx", sheet("`sheet_`x''") cellrange(A2) firstrow case(lower) clear 
		
		
		* rename variable 
		rename township			township_name 
		rename villagetracteho 	geo_eho_vt_name 
		rename villagenameeho	geo_eho_vill_name

		
		save "$dta/`sheet_`x''.dta", replace 
	}


// end of dofile 
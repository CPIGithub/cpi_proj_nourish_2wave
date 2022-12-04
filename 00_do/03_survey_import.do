/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	import raw data into dta format 				
Author				:	Nicholus Tint Zaw
Date				: 	11/24/2022
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "00_dir_setting.do"

********************************************************************************
* import villages survey *
********************************************************************************

import excel using "$raw/pnourish_village_svy.xlsx", describe 

forvalues x = 1/`r(N_worksheet)'{
    
	local sheet_`x' = "`r(worksheet_`x')'"
}


forvalues x = 1/`r(N_worksheet)'{
    
	import excel using "$raw/pnourish_village_svy.xlsx", sheet("`sheet_`x''") firstrow clear 
	
	save "$dta/pn_vill_`sheet_`x''.dta", replace
	
}


********************************************************************************
* import household survey *
********************************************************************************

import excel using "$raw/pnourish_secondwave.xlsx", describe 

forvalues x = 1/`r(N_worksheet)'{
    
	local sheet_`x' = "`r(worksheet_`x')'"
}


forvalues x = 1/`r(N_worksheet)'{
    
	import excel using "$raw/pnourish_secondwave.xlsx", sheet("`sheet_`x''") firstrow allstring clear 
	
	destring _all, replace 
	
	save "$dta/pn_hh_`sheet_`x''.dta", replace 
	
}




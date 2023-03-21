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
	
	
	** PHQ-9 
	local phq9 phq9_1 phq9_2 phq9_3 phq9_4 phq9_5 phq9_6 phq9_7 phq9_8 phq9_9

	foreach v in `phq9' {
		replace `v' = `v' - 1 
		tab `v', m 
	} 

	egen phq9_score = rowtotal(	phq9_1 phq9_2 phq9_3 phq9_4 phq9_5 phq9_6 phq9_7 phq9_8 phq9_9)
	replace phq9_score = .m if 	mi(phq9_1) | mi(phq9_2) | mi(phq9_3) | mi(phq9_4) | ///
								mi(phq9_5) | mi(phq9_6) | mi(phq9_7) | mi(phq9_8) | ///
								mi(phq9_9)
	tab phq9_score, m  
	

	gen phq9_cat = .m 
	replace phq9_cat =  1 if phq9_score <= 4
	replace phq9_cat =  2 if phq9_score > 4 & phq9_score <= 9
	replace phq9_cat =  3 if phq9_score > 9 & phq9_score <= 14
	replace phq9_cat =  4 if phq9_score > 14 & phq9_score <= 19
	replace phq9_cat =  5 if phq9_score > 19 & phq9_score <= 27
		lab def phq9_cat 1"None-minimal" 2"Mild" 3"Moderate" 4"Moderately Severe" 5"Severe"
	lab val phq9_cat phq9_cat
	tab phq9_cat, m 

	
	
	** SAVE for analysis dataset 
	save "$dta/pnourish_PHQ9_final.dta", replace  


// END HERE 



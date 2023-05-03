/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: Construct Master Dofile  			
Author				:	Nicholus Tint Zaw
Date				: 	03/01/2023
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

	****************************************************************************
	* (0): Weight Calculation *
	****************************************************************************

	do "$hhconstruct/00_weight_calculation.do"

	****************************************************************************
	* (1): HH Income & Equity Wealth - Quantile *
	****************************************************************************

	do "$hhconstruct/01_hh_INCOME_Wealth_Quantile.do"

	****************************************************************************
	* (2): Respondent Information *
	****************************************************************************

	do "$hhconstruct/02_HH_Respondent_Info.do"


	****************************************************************************
	* (3): Child IYCF Data *
	****************************************************************************

	do "$hhconstruct/03_construct_child_iycf.do"
	
	****************************************************************************
	* (4): Child Health Data *
	****************************************************************************

	do "$hhconstruct/04_construct_child_health.do"
	
	****************************************************************************
	* (5): Child MUAC Module *
	****************************************************************************
	
	do "$hhconstruct/05_construct_child_muac.do"
	
	****************************************************************************
	* (6): Mom Health Module *
	****************************************************************************
	
	do "$hhconstruct/06_construct_mom_health.do"
	
	****************************************************************************
	* (7): Mom Health Module *
	****************************************************************************
	
	do "$hhconstruct/07_construct_mom_diet.do"
	
	****************************************************************************
	* (8): Program Exposure *
	****************************************************************************
	
	do "$hhconstruct/08_construct_programexpo.do"
	
	****************************************************************************
	* (9): HH WASH *
	****************************************************************************
	
	do "$hhconstruct/09_hh_WASH.do"
	
	****************************************************************************
	* (10): HH FIES *
	****************************************************************************
	
	do "$hhconstruct/10_hh_FIES.do"
	
	****************************************************************************
	* (11): Mom Health Module *
	****************************************************************************

	do "$hhconstruct/11_hh_PHQ9.do"
	
	****************************************************************************
	* (12): Women Empowerment *
	****************************************************************************
	
	do "$hhconstruct/12_hh_Women_Empowerment.do"
	

	** SAVE for analysis dataset 
	//save "$dta/pnourish_child_iycf_final.dta", replace  


// END HERE 



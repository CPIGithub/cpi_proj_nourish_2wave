/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	Endline data collection: HH Survey HFC dofile set-up			
Author				:	Nicholus Tint Zaw
Date				: 	11/24/2022
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$hhimport/endline/01_survey_import_hh.do"

********************************************************************************
* dofile - 1: Completion Progress *
********************************************************************************

do "$hhhfc/endline/01_hfc_completion.do"

********************************************************************************
* dofile - 2: Duplicate Check *
********************************************************************************

do "$hhhfc/endline/02_hfc_duplicate.do"

********************************************************************************
* dofile - 3:  Missingness Check *
********************************************************************************

// do "$hhhfc/03_hfc_missing.do"

********************************************************************************
* dofile - 4:  Outliers Check*
********************************************************************************

do "$hhhfc/endline/04_hfc_outlier.do"

********************************************************************************
* dofile - 5: Skip-pattern Check *
********************************************************************************

//do "$hhhfc/05_hfc_skip_pattern.do"

********************************************************************************
* dofile - 6:  Enumerator Performance *
********************************************************************************

do "$hhhfc/endline/06_hfc_enuperform.do"


********************************************************************************
* dofile - 7:  Village Level Completion *
********************************************************************************

do "$hhhfc/endline/07_hfc_vill_completion.do"

********************************************************************************
* dofile - 8:  Other Specify Translation Work *
********************************************************************************

do "$hhhfc/endline/08_hfc_other_opinion_check.do"

** END OF DOFILE **
 
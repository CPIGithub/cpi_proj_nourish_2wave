/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: Construct HH/Individual Level Dataset  			
Author				:	Nicholus Tint Zaw
Date				: 	03/01/2023
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

	****************************************************************************
	* (1): HH Level Data *
	****************************************************************************

	* include: (1) respondent info (2) all other hh level module 
	* not include: Mother Health and Child Health 
	
	use "$dta/pnourish_respondent_info_final.dta", clear 
	
	merge 1:1 uuid using "$dta/pnourish_INCOME_WEALTH_final.dta"
	drop _merge 
	
	merge 1:1 uuid using "$dta/pnourish_WASH_final.dta"
	drop _merge
	
	merge 1:1 uuid using "$dta/pnourish_FIES_final.dta"
	drop _merge
	
	merge 1:1 uuid using "$dta/pnourish_PHQ9_final.dta"
	drop _merge
	
	merge 1:1 uuid using "$dta/pnourish_WOMEN_EMPOWER_final.dta"
	drop _merge
	
	merge 1:1 uuid using "$dta/pnourish_program_exposure_final.dta"
	drop _merge
	
	
	** SAVE AS HH LEVEL DATASET
	save "$dta/01_final/Pnourish_HH_Level_Dataset.dta", replace  
	
	* create codebook 
	iecodebook template using "$dta/01_Final/Pnourish_HH_Level_Dataset.xlsx", replace 

	** Created De-ID Data 
	drop	org_name township_name geo_eho_vt_name geo_eho_vill_name ///
			respd_name respd_phonnum
			
	label drop stratum_num
	
	save "$dta/02_Deidentified/Pnourish_HH_Level_DEID_Dataset.dta", replace  
	
	* create codebook 
	iecodebook template using "$dta/02_Deidentified/Pnourish_HH_Level_DEID_Dataset.xlsx", replace 


	
	****************************************************************************
	* (1): Chid Level Data *
	****************************************************************************
	* include: (1) Child MUAC (2) Child Health  (3) Child IYCF

	use "$dta/pnourish_child_muac_final.dta", clear 
	
	merge 1:1 _parent_index roster_index using "$dta/pnourish_child_health_final.dta"
	drop _merge 
	
	merge 1:1 _parent_index roster_index using "$dta/pnourish_child_iycf_final.dta"
	drop _merge 
	
	** SAVE AS CHILD LEVEL DATASET
	save "$dta/01_final/Pnourish_CHILD_Level_Dataset.dta", replace  
	
	* create codebook 
	iecodebook template using "$dta/01_Final/Pnourish_CHILD_Level_Dataset.xlsx", replace 

	** Created De-ID Data 
	drop	child_pos child_pos3 hh_mem_name child_pos4
			
	label drop stratum_num
	
	save "$dta/02_Deidentified/Pnourish_CHILD_Level_DEID_Dataset.dta", replace  
	
	* create codebook 
	iecodebook template using "$dta/02_Deidentified/Pnourish_CHILD_Level_DEID_Dataset.xlsx", replace 



	****************************************************************************
	* (2): Mother Level Data *
	****************************************************************************
	* include: (1) Mother Diet (2) Mother Health

	use "$dta/pnourish_mom_diet_final.dta", clear 
	
	merge 1:1 _parent_index roster_index using "$dta/pnourish_mom_health_final.dta"
	drop _merge 
	
	** SAVE AS HH LEVEL DATASET
	save "$dta/01_final/Pnourish_MOTHER_Level_Dataset.dta", replace  
	
	* create codebook 
	iecodebook template using "$dta/01_Final/Pnourish_MOTHER_Level_Dataset.xlsx", replace 

	** Created De-ID Data 
	drop	women_pos1 hh_mem_name
			
	label drop stratum_num
	
	save "$dta/02_Deidentified/Pnourish_MOTHER_Level_DEID_Dataset.dta", replace  
	
	* create codebook 
	iecodebook template using "$dta/02_Deidentified/Pnourish_MOTHER_Level_DEID_Dataset.xlsx", replace 



// END HERE 



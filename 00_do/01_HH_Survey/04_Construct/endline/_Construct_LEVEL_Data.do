/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	endline collection: Construct HH/Individual Level Dataset  			
Author				:	Nicholus Tint Zaw
Date				: 	08/27/2024
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
	
	use "$dta/endline/pnourish_respondent_info_final.dta", clear 
	
	merge 1:1 uuid using "$dta/endline/pnourish_INCOME_WEALTH_final.dta", assert(3) nogen 
	
	merge 1:1 uuid using "$dta/endline/pnourish_WASH_final.dta", assert(3) nogen 
	
	merge 1:1 uuid using "$dta/endline/pnourish_FIES_final.dta", assert(3) nogen 
	
	merge 1:1 uuid using "$dta/endline/pnourish_PHQ9_final.dta", assert(3) nogen 
	
	merge 1:1 uuid using "$dta/endline/pnourish_WOMEN_EMPOWER_final.dta", assert(3) nogen 
	
	merge 1:1 uuid using "$dta/endline/pnourish_program_exposure_final.dta", assert(3) nogen 
	
	merge 1:1 uuid using "$dta/endline/pnourish_knowledge_module_final.dta", assert(3) nogen 
	
	** SAVE AS HH LEVEL DATASET
	save "$dta/endline/01_final/Pnourish_HH_Level_Dataset.dta", replace  
	
	* create codebook 
	iecodebook template using "$dta/01_Final/Pnourish_HH_Level_Dataset.xlsx", replace 
	
	** Created De-ID Data 
	drop	org_name org_name_num township_name geo_eho_vt_name geo_eho_vill_name ///
			respd_name respd_phonnum
			
	label drop stratum_num
	
	save "$dta/endline/02_Deidentified/Pnourish_HH_Level_DEID_Dataset.dta", replace  
	
	* create codebook 
	//iecodebook template using "$dta/endline/02_Deidentified/Pnourish_HH_Level_DEID_Dataset.xlsx", replace 
	iecodebook apply using "$dta/endline/02_Deidentified/Pnourish_HH_Level_DEID_Dataset.xlsx" 
	
	keep if stratum_num == 3 | stratum_num == 4
	
	export excel using 	"$dta/endline/02_Deidentified/KEHOC/PN_Endline_HH_Level_Dataset_KEHOC.xlsx", ///
						sheet("KEHOC") ///
						firstrow(variables) ///
						replace 
		
	* KEHOC
	
	codebookout "$dta/endline/02_Deidentified/KEHOC/PN_Endline_HH_Level_Dataset_CODEBOOK.xlsx", replace 


	****************************************************************************
	* (1): Chid Level Data *
	****************************************************************************
	* include: (1) Child MUAC (2) Child Health  (3) Child IYCF

	use "$dta/endline/pnourish_child_muac_final.dta", clear 
	
	merge 1:1 _parent_index roster_index using "$dta/endline/pnourish_child_health_final.dta"
	drop _merge 
	
	merge 1:1 _parent_index roster_index using "$dta/endline/pnourish_child_iycf_final.dta"
	drop _merge 
	
	** SAVE AS CHILD LEVEL DATASET
	save "$dta/endline/01_final/Pnourish_CHILD_Level_Dataset.dta", replace  
	
	* create codebook 
	//iecodebook template using "$dta/01_Final/Pnourish_CHILD_Level_Dataset.xlsx", replace 

	** Created De-ID Data 
	drop	child_pos child_pos3 hh_mem_name child_pos4
			
	label drop stratum_num
	
	save "$dta/endline/02_Deidentified/Pnourish_CHILD_Level_DEID_Dataset.dta", replace  
	
	* create codebook 
	//iecodebook template using "$dta/endline/02_Deidentified/Pnourish_CHILD_Level_DEID_Dataset.xlsx", replace 
	iecodebook apply using "$dta/endline/02_Deidentified/PN_Child_Level_Dataset_CODEBOOK.xlsx" 

	keep if stratum_num == 3 | stratum_num == 4
	
	export excel using 	"$dta/endline/02_Deidentified/KEHOC/PN_Endline_CHILD_Level_Dataset_KEHOC.xlsx", ///
						sheet("KEHOC") ///
						firstrow(variables) ///
						replace 
	* KEHOC
	codebookout "$dta/endline/02_Deidentified/KEHOC/PN_Endline_CHILD_Level_CODEBOOK.xlsx", replace 

	****************************************************************************
	* (2): Mother Level Data *
	****************************************************************************
	* include: (1) Mother Diet (2) Mother Health

	use "$dta/endline/pnourish_mom_diet_final.dta", clear 
	
	merge 1:1 _parent_index roster_index using "$dta/endline/pnourish_mom_health_final.dta"
	drop _merge 
	
	** SAVE AS HH LEVEL DATASET
	save "$dta/endline/01_final/Pnourish_MOTHER_Level_Dataset.dta", replace  
	
	* create codebook 
	//iecodebook template using "$dta/endline/02_Deidentified/Pnourish_MOTHER_Level_Dataset.xlsx", replace 

	** Created De-ID Data 
	drop	women_pos1 hh_mem_name
			
	label drop stratum_num
	
	save "$dta/endline/02_Deidentified/Pnourish_MOTHER_Level_DEID_Dataset.dta", replace  
	
	* create codebook 
	//iecodebook template using "$dta/endline/02_Deidentified/Pnourish_MOTHER_Level_DEID_Dataset.xlsx", replace 
	iecodebook apply using "$dta/endline/02_Deidentified/Pnourish_MOTHER_Level_DEID_Dataset.xlsx" 


	export excel using 	"$dta/endline/02_Deidentified/KEHOC/PN_Endline_MOTHER_Level_Dataset_KEHOC.xlsx", ///
						sheet("KEHOC") ///
						firstrow(variables) ///
						replace 

	* KEHOC
	codebookout "$dta/endline/02_Deidentified/KEHOC/PN_Endline_Mother_Level_Dataset_CODEBOOK.xlsx", replace 

// END HERE 



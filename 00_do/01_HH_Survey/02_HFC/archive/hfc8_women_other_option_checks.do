* **************************************************************************** *
* **************************************************************************** *
*                                                                      		   *
*   	World Food Program SPB Window - Jordan - Impact Evaluation			   *
*				High Frequency Sruvey - Women Survey						   *
*       	This dofile carries out high frequency checks.		          	   *
*                                                                     		   *
* **************************************************************************** *
* **************************************************************************** *

/*
  ** PURPOSE        Creating tables to monitor the quality of the data 
					(text entrances check).
  ** LAST UPDATE    July 18, 2022
  ** INPUT			hfcs_worker_data_prepped.dta	
  ** OUTPUT			WFP_SPB_Jordan_hfc_worker_baseline.xlsx (Sheet  Other Option Check)
  
  ** CONTENTS
		
		*0. EXPORT TABLE TITLES
		*1. IMPORT DATA
		*2. EXPORT DIRECTION TEXT VARIABLE
		*3. PREPARING DATASET TO EXPORT
		*4. EXPORT ALL THE TEXT ENTRANCES 
		
*******************************************************************************/

	*0. EXPORT TABLE TITLES
	
	*Adding title table 1
		clear
		set obs 1
		gen title = ""
		replace title = "TABLE 1: TEXT ENTRANCE DIRECTION VARIABLE" in 1
		export excel title using "${Worker_hfcout}/Round_1/WFP_SPB_Jordan_hfc_HF_womensvy.xlsx", sheet("Other Option Check") sheetreplace cell(A1) 
		
	*Adding title table 1
		clear
		set obs 1
		gen title = ""
		replace title = "TABLE 2: OTHER OPTION TEXT ENTRANCE" in 1
		export excel title using "${Worker_hfcout}/Round_1/WFP_SPB_Jordan_hfc_HF_womensvy.xlsx", sheet("Other Option Check") sheetmodify cell(I1) 

	
	*1. IMPORT DATA
	
	use "${Worker_hfcdta}/Round_1/hfcs_women_hf_data_prepped.dta", clear

	drop if resp_available == 0
	drop if consent == 0
	drop if worker_located == 0

		
	*2. EXPORT DIRECTION TEXT VARIABLE
			
	preserve
		*local days = 7
		*keep if elapsed_datacheck <= `days' 
		bysort hhid startdate enumerator enumeratorname: keep if _n == 1 // temporary solution for duplicate
		
		keep enumerator enumeratorname hhid startdate direction 
		rename(direction) (txt_direction)
		reshape long txt_, i(hhid startdate enumerator enumeratorname) j(variable) string
		keep if !missing(txt_)
		
		label variable txt_ 	"Text Entrance"

		export excel using "${Worker_hfcout}/Round_1/WFP_SPB_Jordan_hfc_HF_womensvy.xlsx", sheet("Other Option Check") sheetmodify cell (A2) firstrow(varlabels)
	restore	
		
	*3. PREPARING DATASET TO EXPORT
		
		local text_vars /*hhh_relationship_o*/ workercontact_relationship_o ///
						sp4_oth /*sp5_oth*/ ///
						decision_visits_f_o ///
						time_agency_f_o_1 time_agency_f_o_2 time_agency_f_o_3 time_agency_f_o_4 ///
						cons_1_f_o cons_2_f_o cons_3_f_o cons_4_f_o
						 
		local main_vars /*household_head_name*/ workercontact_relationship ///
						sp4 /*sp5_2*/ ///
						decision_visits_f ///
						time_agency_f_1 time_agency_f_2 time_agency_f_3 time_agency_f_4 ///
						cons_1_f cons_2_f cons_3_f cons_4_f 
	
		
		local text_vars_rpt rel_to_hhh_oth* marital_status_oth* ///
							birth_country_oth* nationality_oth* ///
							country_fa_oth* country_mo_oth*		   ///
							reason_left_never_oth*	occupation_oth* ///
							occupation_secondary_o* primary_business_type_o* ///
							secondary_business_type_o* jb_search_n_oth*
			 
		local main_vars_rpt rel_to_hhh_1  marital_status_1  ///
							birth_country_1  nationality_1  ///
							country_fa_1 country_mo_1 		   ///
							reason_left_never_1 occupation_1  ///
							occupation_secondary_1 primary_business_type_1  ///
							secondary_business_type_1 jb_search_n_1 		
							
		*Keeping text variables 
		keep 	hhid key enumerator enumeratorname `text_vars' `main_vars' `text_vars_rpt' `main_vars_rpt'  ///
				activity_select_f_o* activity_select2_f_o* activity_select3_f_o* ///
				add_income_1 add_income_oth1* add_income_oth2* add_income_oth3* ///
				shock_occur_1 shock_occurx* 
		
		*Generating variable with label (to have the question each var refers to)
		foreach var in `main_vars'{
			local varlabel: variable label `var'
			gen lab_`var' = "`varlabel'"
			
    }
		
		local n: word count `text_vars'
		forvalues i = 1/`n' {
			local txt  : word `i' of `text_vars'
			local main : word `i' of `main_vars'
			rename `txt' txt_`main'
		}

		
		*Generating variable with label (to have the question each var refers to) within repeat groups
			
			*Renaming vars for loop to work
			
			rename (occupation_secondary_1 primary_business_type_1 secondary_business_type_1) ///
				   (occ_sec_1 prim_bus_type_1 sec_bus_type_1)
			
			forvalues i = 1/10 {
				
				rename (occupation_secondary_o_`i')    (occ_sec_oth_`i')
				rename (primary_business_type_o_`i')   (prim_bus_type_oth_`i')
				rename (secondary_business_type_o_`i') (sec_bus_type_oth_`i')
			
			}
		
			foreach var in rel_to_hhh marital_status birth_country nationality  ///
						   country_fa country_mo reason_left_never occupation  ///
						   occ_sec prim_bus_type  ///
						   sec_bus_type jb_search_n {
				forvalues i = 1/10 {
					local varlabel: variable label `var'_1
						gen lab_`var'_oth_`i' = "`varlabel'"
					
					rename (`var'_oth_`i') (txt_`var'_oth_`i')
    }
} 

		*Generating labels for variables within time use repeat groups
		foreach var of varlist activity_select_f_o*  ///
							   activity_select2_f_o* ///
							   activity_select3_f_o* {
			gen lab_`var' = "What did you start doing at...?"
			rename (`var') (txt_`var')
		}

		
		local varlabel: variable label add_income_1	 
		foreach var in add_income_oth1 add_income_oth2 add_income_oth3 {
				forvalues i = 1/10 {
					
					gen lab_`var'_`i' = "`varlabel'"
					rename (`var'_`i') (txt_`var'_`i')
    }
}
		
		local varlabel: variable label shock_occur_1	 
				forvalues i = 1/12 {
					
					gen lab_shock_occurx_`i' = "`varlabel'"
					rename (shock_occurx_`i') (txt_shock_occurx_`i')
    }
		
		drop `main_vars'
		
		reshape long txt_ lab_, i(hhid key enumerator enumeratorname) j(variable) string
				
		keep if !missing(txt_)
		
		sort variable
		
		*Including variable labels
		label variable variable "Variable name"
		label variable txt_ 	"Text Entrance"
		label variable lab_ 	"Label Variable"
		
		order key, after (txt_)	
		order lab_, after(variable)
		
	*4. EXPORT ALL THE TEXT ENTRANCES 

	if _N > 0 {
		export excel using "${Worker_hfcout}/Round_1/WFP_SPB_Jordan_hfc_HF_womensvy.xlsx", sheet("Other Option Check") sheetmodify cell(I2) first(varlabels)
	}

****End of do-file	
	



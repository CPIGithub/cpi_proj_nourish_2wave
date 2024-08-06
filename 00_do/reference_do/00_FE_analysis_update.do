* **************************************************************************** *
* **************************************************************************** *
*                                                                      		   *
* 		SHiFT Vietnam Food Environment Data 								   *
*                                                                     		   *
* **************************************************************************** *
* **************************************************************************** *

/*
  ** PURPOSE       	Analysis - For Micronutrient Forum
  ** LAST UPDATE    Sept 28, 2023
  ** CONTENTS
		
	** Availability	
		- Presence of sugar-sweetened beverages by region and type of outlet
		- Presence of fruits by region and type of outlet
		- Presence of vegetables by region and type of outlet
	
	** Vendor and product properties	
		*	Vendor
			- Outlet typology by region
			- Opening hours: hours/week by type of outlet
		* Product
			- Product healthfulness: GDQS overall, + and –, by region and type of outlet
			- Presence of UPFs (NOVA group 4) , by region and type of outlet	
*/ 

********************************************************************************

	
	****************************************************************************
	** Outlet level data **
	****************************************************************************
	
	* Import data 
	use "$foodenv_prep/FE_OUTLETS_FINAL_SAMPLE.dta", clear 
	
	keep if final_sample == 1 // keep only final sample in the dataset 

	* Unique variable 
	isid outlet_code 
	
	gen white_space = 0 // for indicator brekdown in sum-stat table
			
	** Note: put white_space for section break
	tab rural_urban, gen(rural_urban_)
	
	global outcomes		rural_urban_1 rural_urban_2 rural_urban_3 ///
						white_space ///
						white_space ///
						outlet_type_1 outlet_type_2 outlet_type_3 outlet_type_4 outlet_type_5 ///
						outlet_type_6 outlet_type_7 outlet_type_8 outlet_type_9 outlet_type_10 ///
						outlet_type_11 outlet_type_12 outlet_type_13 outlet_type_14 outlet_type_15 outlet_type_97 ///					
						white_space ///
						nova4_yes ssb_yes fruit_grp_yes vegetable_grp_yes fruitveg_grp_yes ///
						white_space ///
						gdqs_yes gdqs_score_plus gdqs_score_minus ///
						white_space ///
						gdqs_healthy_yes gdqs_healthy_num gdqs_unhealthy_yes gdqs_unhealthy_num gdqs_neutral_yes ///
						white_space ///
						gdqs_grp_1_yes gdqs_grp_2_yes gdqs_grp_3_yes gdqs_grp_4_yes gdqs_grp_5_yes gdqs_grp_6_yes gdqs_grp_7_yes gdqs_grp_8_yes gdqs_grp_9_yes gdqs_grp_10_yes gdqs_grp_11_yes gdqs_grp_12_yes gdqs_grp_13_yes gdqs_grp_14_yes gdqs_grp_15_yes gdqs_grp_16_yes gdqs_grp_17_yes gdqs_grp_18_yes gdqs_grp_19_yes gdqs_grp_20_yes gdqs_grp_21_yes gdqs_grp_22_yes gdqs_grp_23_yes gdqs_grp_24_yes gdqs_grp_25_yes
						
	
	* All Obs
	preserve 

		keep $outcomes   
		
		do "$foodenv_analysis/00_frequency_table"


		export excel $export_table 	using "$foodenv_out/FE_SUMSTAT_UPDATED.xlsx",  /// 
									sheet("Sum-stat Ouput Raw") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* By Geo Breakdown
	levelsof rural_urban, local(geo)
	
	foreach x in `geo' {
		
		preserve 
		
			keep if rural_urban == `x'
			
			keep $outcomes   
			
			do "$foodenv_analysis/00_frequency_table"


			export excel $export_table 	using "$foodenv_out/FE_SUMSTAT_UPDATED.xlsx",  /// 
										sheet("rural_urban `x'") firstrow(varlabels) keepcellfmt sheetreplace 	
		
		restore 
		
	}
	
	
	* By Geo Breakdown &  Outlet Type
	global outcomes		nova4_yes ssb_yes fruit_grp_yes vegetable_grp_yes fruitveg_grp_yes ///
						white_space ///
						gdqs_yes gdqs_score_plus gdqs_score_minus ///
						white_space ///
						gdqs_healthy_yes gdqs_healthy_num gdqs_unhealthy_yes gdqs_unhealthy_num gdqs_neutral_yes ///
						white_space ///
						gdqs_grp_1_yes gdqs_grp_2_yes gdqs_grp_3_yes gdqs_grp_4_yes gdqs_grp_5_yes gdqs_grp_6_yes gdqs_grp_7_yes gdqs_grp_8_yes gdqs_grp_9_yes gdqs_grp_10_yes gdqs_grp_11_yes gdqs_grp_12_yes gdqs_grp_13_yes gdqs_grp_14_yes gdqs_grp_15_yes gdqs_grp_16_yes gdqs_grp_17_yes gdqs_grp_18_yes gdqs_grp_19_yes gdqs_grp_20_yes gdqs_grp_21_yes gdqs_grp_22_yes gdqs_grp_23_yes gdqs_grp_24_yes gdqs_grp_25_yes
		
	levelsof outlet_type, local(outlet_typo)
	
	foreach x in `outlet_typo' {
		
		preserve 
		
			keep if outlet_type == `x'
			
			if _N > 0 {
				
				* number of outcome variables 
				local num_vars : word count $outcomes 
				di _N

				if `num_vars' > _N {
					// Add new observation only if needed
					local add_row = `num_vars' - _N
				}

				di _N
				di `num_vars'
				di `add_row'
				
				clear 
				set obs `add_row'
				tempfile emptydf
				save `emptydf', emptyok

			}				
			
		restore
	
	
		preserve 
		
			keep if outlet_type == `x'
			
			if _N > 0 {
				
				if `num_vars' > _N {
					
					
					di _N 
					
					append using `emptydf'
					
					di _N
					
				}
			
			keep $outcomes   
			
			do "$foodenv_analysis/00_frequency_table"


			export excel $export_table 	using "$foodenv_out/FE_SUMSTAT_UPDATED.xlsx",  /// 
										sheet("outlet_type_`x'") firstrow(varlabels) keepcellfmt sheetreplace 	
			
			}
			
		restore 
		
	}
	
						
	levelsof rural_urban, local(geo)
	levelsof outlet_type, local(outlet_typo)
	
	foreach x in `geo' {
		
		foreach y in `outlet_typo' {
		
			
			preserve 
			
				keep if rural_urban == `x' &  outlet_type == `y'
				
				if _N > 0 {
					
					* number of outcome variables 
					local num_vars : word count $outcomes 
					di _N

					if `num_vars' > _N {
						// Add new observation only if needed
						local add_row = `num_vars' - _N
					}

					di _N
					di `num_vars'
					di `add_row'
					
					clear 
					set obs `add_row'
					tempfile emptydf
					save `emptydf', emptyok

				}				
				
			restore
			
			
			preserve 

				keep if rural_urban == `x' &  outlet_type == `y'
				
				if _N > 0 {
					
					if `num_vars' > _N {
						
						
						di _N 
						
						append using `emptydf'
						
						di _N
						
					}
					
					
					keep $outcomes   
					
					do "$foodenv_analysis/00_frequency_table"


					export excel $export_table 	using "$foodenv_out/FE_SUMSTAT_UPDATED.xlsx",  /// 
												sheet("rural_urban_`x'_`y'") firstrow(varlabels) keepcellfmt sheetreplace 	
					
				}
			
			restore 
		
		}
		
	}
		
	** end of dofile 
	

/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	Endline data collection: other specify check		
Author				:	Nicholus Tint Zaw
Date				: 	06/13/2024
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "00_dir_setting.do"

	********************************************************************************
	* Main Survey Sheet *
	********************************************************************************

	clear 
	tempfile empty_df 
	save `empty_df', emptyok 
	
	* HH svy 
	use "$dta/endline/PN_HH_Survey_Endline_FINAL.dta", clear

	keep if will_participate == 1

	isid uuid
	
	* search for _oth varaibles 
	lookfor _oth 
	
	local other_specify `r(varlist)'
	
	/*
	local oth_parent ""   // Initialize an empty local macro
	
	foreach var in `other_specify' {
	    
		local root = substr("`var'", 1, length("`var'") - 4) 		// Remove "_oth"
		local oth_parent "`oth_parent' `root' `var'"            	// Add to the list
		
		
		di "`oth_parent'"
	}

	

	di "`oth_parent'"
	*/
	

	foreach var in `other_specify' {
	    
		preserve 
			
			keep uuid `var'
			
			gen var = "`var'"
			
			rename `var' value
			
			drop if mi(value)
			
			capture tostring value, replace 
			
			capture confirm numeric variable value
			
			if !_rc {
			  				
				tab value 
				tab value, nolab 
				
				decode value, gen(value_d)
				drop value 
				rename value_d value 

				append using `empty_df' 
				
				save `empty_df', replace 
				
			}
			else {
				
				append using `empty_df' 
				
				save `empty_df', replace 
				
			}

		
		restore 
	}
	
	
	use `empty_df', clear 
	order uuid var value 
	
	export excel using "$out/endline/08_hh_svy_otherspecify.xlsx", sheet("PN_HH_Survey_Endline_FINAL") firstrow(varlabels) sheetreplace

	
	local dfs grp_hh hh_child_mom_rep grp_q2_5_to_q2_7 child_vc_rep anc_rep mom_covid_rpt child_muac_rep
		
	foreach df in `dfs' {
	    
		clear 
		tempfile empty_df 
		save `empty_df', emptyok 
		
		use "$dta/endline/`df'.dta", clear 
		
		isid _submission__uuid _index _parent_index
		
		* search for _oth varaibles 
		lookfor _oth 
		
		local other_specify `r(varlist)'
		
		foreach var in `other_specify' {
			
			preserve 
				
				keep _submission__uuid _index _parent_index `var'
				
				gen var = "`var'"
				
				rename `var' value
				
				drop if mi(value)
				
				capture tostring value, replace 
				
				capture confirm numeric variable value
				
				if !_rc {
								
					tab value 
					tab value, nolab 
					
					decode value, gen(value_d)
					drop value 
					rename value_d value 

					append using `empty_df' 
					
					save `empty_df', replace 
					
				}
				else {
					
					append using `empty_df' 
					
					save `empty_df', replace 
					
				}

			
			restore 
		}
		
		di "`df'"
		use `empty_df', clear 
		
		if _N > 0 {
		    
			order _submission__uuid _index _parent_index var value 
			
			export excel using "$out/endline/08_hh_svy_otherspecify.xlsx", sheet("`df'") firstrow(varlabels) sheetreplace	
		
		}
		
	}
	
	
	* END here 


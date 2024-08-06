

cap program drop mixed_model
program mixed_model, rclass
	syntax [if] , [controls(varlist)] row(real) [perform(string)]

	qui  {
		preserve
				qui: levelsof $varlist_mixed_model
		
		 if "`r(levels)'" == "0 1"{
			capture xtmixed $varlist_mixed_model SES ||neighborhood:  `controls' `if' , vce(robust) //  for binary outcomes
		
				}
				
		else if "`r(levels)'" != "0 1"{
			capture xtmixed $varlist_mixed_model SES ||neighborhood: `controls' `if', mle //  for continuous outcomes
				}
				
			if _rc {
				if "`perform'"!="quietly" {
					di as err "SummaryStatistics Warning: mixed model (unadjusted for baseline) for variable $varlist_mixed_model could not be computed."
				}
				return local erEndlineOnlyrow `row'
				*exit 110
			}
			if _rc == 504{
				if "`perform'"!="quietly" {
					di as err "(mixed: could not calculate numerical derivatives -- discontinuous region with missing values encountered)"
				}
				return local erEndlineOnlyrow `row'
			}
			if _rc == 459{
				if "`perform'"!="quietly" {
					di as err "(mixed: ${varlist_mixed_model} is constant and zero)"
				}
				return local erEndlineOnlyrow `row'
			}
			
			if !_rc {
				regsave,  pval ci
				keep if var=="$varlist_mixed_model:SES"
				cap mkmat  coef ci_lower ci_upper pval ,	matrix(reg$varlist_mixed_model)
				if _rc==198 {
					di as err "variable name $varlist_mixed_model too long"
					exit 110
				}
				cap mkmat  N ,	 							matrix(regN$varlist_mixed_model) 		
				if _rc==198 {
					di as err "variable name $varlist_mixed_model too long"
					exit 110
				}				

			}
		restore	
	return local stars `stars'
	}	
end



*----------------
cap program drop export_statistics
program export_statistics, rclass
	syntax varlist(max=1) [if] [in] using, excelrow(real) vartype(string) [report_N(varlist) header(string) controls(varlist) omit ]
	//obs_no
	
	* mark sample
	tempvar touse
	mark `touse' `if' `in'
	* mixed model (return stars)
	global varlist_mixed_model `1'
	if "`omit'" == ""	{
		mixed_model `if', controls(`controls') row(`excelrow')
	}
	//local starsEndline  "`r(stars)'"
	* summary statistics
	matrix Endline=J(1, 4,.)
	local mat_col=1
		forvalues SES=0/1 { 
			qui sum `1' if SES==`SES' &  `touse' 

			if "`report_N'"!="" {
				local NEndline`SES' : di %5.0fc `r(N)'
			}			
		
			if "`vartype'"=="dummy" {
				local mean_n_Endline : di %5.0fc `r(sum)'
				if "`r(mean)'"!="" {
					local sd_perc_Endline: di %3.2f `r(mean)'*100 
				}
			}	
			if "`vartype'"=="continuous" {
				if "`r(mean)'"!="" {
					local mean_n_Endline : di %3.2fc `r(mean)'
					local sd_perc_Endline: di %3.2fc `r(sd)'
				}	
			}	
			if `SES'==0 {
				if "`vartype'"=="dummy" {
				*	local mnspEndline`SES' = "`mean_n_Endline' (`sd_perc_Endline'%)"	// added '%' LH
				local mnspEndline`SES' = "`sd_perc_Endline'%"
				}	
				if "`vartype'"=="continuous" {
					local mnspEndline`SES' = "`mean_n_Endline' ± `sd_perc_Endline'"
				}
			}
			if `SES'==1 {
				if "`vartype'"=="dummy" {
					local mnspEndline`SES' = "`sd_perc_Endline'%"	 // added '%' LH
				}	
				if "`vartype'"=="continuous" {
					local mnspEndline`SES' = "`mean_n_Endline' ± `sd_perc_Endline'"
				}
			}
			local mat_col=`mat_col' + 1
		}

	version 14.0
	* labels
	local val_lab : variable label `1'
	version 12.0	
	if $var_num==1 {
		local excelrow_miuns1=`excelrow'-1
		qui putexcel A`excelrow_miuns1'=("`header'")  `using', modify
		if "`report_N'"!="" {
			qui putexcel B`excelrow_miuns1' =("n=`NEndline0'") `using', modify 
			qui putexcel C`excelrow_miuns1' =("n=`NEndline1'") `using', modify 		
		}		
	}
	* export n, mean, sd, %
	qui putexcel A`excelrow' =("`val_lab'")     `using', modify	
	qui putexcel B`excelrow' =("`mnspEndline0'")  `using', modify 
	qui putexcel C`excelrow' =("`mnspEndline1'") `using', modify 	
	version 14.0
	* export beta and p-value
	if "`omit'" == ""	{
		mixed_model `if', controls(`controls') row(`excelrow')
		version 12.0
		if !_rc {
			cap mat reg${varlist_mixed_model}[1,4]=round(reg${varlist_mixed_model}[1,4],0.001) // the p-value
			cap mat reg${varlist_mixed_model}[1,1]=round(reg${varlist_mixed_model}[1,1],0.0001)
			cap mat reg${varlist_mixed_model}[1,2]=round(reg${varlist_mixed_model}[1,2],0.0001)
			cap mat reg${varlist_mixed_model}[1,3]=round(reg${varlist_mixed_model}[1,3],0.0001)			
			

			if "`vartype'"=="dummy" {
				local delta	  : di %3.2f reg${varlist_mixed_model}[1,1]*100
				local delta_value= "`delta'"						
				local CI_lower: di %3.2f reg${varlist_mixed_model}[1,2]*100
				local CI_lower= "`CI_lower'"		
				local CI_upper: di %3.2f reg${varlist_mixed_model}[1,3]*100
				local CI_upper= "`CI_upper'"
				local CI= 		   "(`CI_lower', `CI_upper')"	

			}	
			if "`vartype'"=="continuous" {
				local delta	  : di %3.2f reg${varlist_mixed_model}[1,1]
				local delta_value= "`delta'"						
				local CI_lower: di %3.2f reg${varlist_mixed_model}[1,2]
				local CI_lower= "`CI_lower'"		
				local CI_upper: di %3.2f reg${varlist_mixed_model}[1,3]
				local CI_upper= "`CI_upper'"
				local CI= 		   "(`CI_lower', `CI_upper')"	
			}	
			local p		  : di %4.3f reg${varlist_mixed_model}[1,4]
			local p_value= 	   "`p'"
			qui putexcel D`excelrow'= ("`delta_value'") `using', modify
			qui putexcel E`excelrow'= ("`CI'") `using', modify
			qui putexcel F`excelrow'= ("`p'") `using', modify			
		}	


		version 14.0
	}
	macro drop varlist_mixed_model	
	markout `touse' `varlist'
end

cap program drop StatsByNeighborhood
program StatsByNeighborhood, rclass
	syntax varlist [if] [in]  using, excelrow(real) [header(string) report_N(varlist) controls(varlist) show_omitted omit obs_no]
	if "`show_omitted'"!=""  & "`omit'"=="" {
		local r=`excelrow'
		foreach var of varlist `varlist' {
			global varlist_mixed_model `var'			
				mixed_model `if', controls(`controls') row(`r') perform("quietly")	
					local 		 erEndlineOnlyrow_list `erEndlineOnlyrow_list'  `r(erEndlineOnlyrow)'
			local ++r


			macro drop varlist_mixed_model
		}
	}	
	tokenize `using'	
	qui {	
		cap putexcel set "`2'"
		if !_rc {
			putexcel (A1:F1) ,   hcenter border("bottom", "thin", "black")  
			putexcel (B2:C2) ,  border("bottom", "thin", "black")     hcenter bold font(12)  merge 
			putexcel (D2:F2) ,  border("bottom", "thin", "black")     hcenter bold font(12)  merge 
			putexcel (B3:F3) ,   hcenter border("bottom", "thin", "black")   
			


		} 
		

		version 12.0
		putexcel (B2:C2) =("Socio-Economic Status")  `using',  modify	
		putexcel (D2:F2) =("Model") 	`using',  modify

		putexcel (B3) = ("Low SES")  `using',  modify
		putexcel (C3) = ("Middle SES")  `using',  modify
		putexcel (D3) = ("Δ (pp)")  `using',  modify
		putexcel (E3) = ("95% CI")  `using',  modify
		putexcel (F3) = ("P-value")  `using',  modify

		version 14.0
	}
	
	global var_num=1
	foreach var of varlist `varlist' {
		qui ds `var', has(vallabel)
		if 	"`var'"=="`r(varlist)'" { // has value label, now check if dummy or categoric
				qui ta `var', matrow(names) 
				local rows =  rowsof(names)
				forvalues i = 1/`rows' {	
					local val`i' = names[`i',1]		
				}
			if "`val2'"!="" {
				if `val1'+`val2'==1 {
					di as text  "Note: Variable `var' identified as Dummy"
					local vartype "dummy"
					export_statistics `var' `if' `in' `using', excelrow(`excelrow') report_N(`report_N') header(`header') vartype(`vartype') controls(`controls') `omit' `obs_no'
					local ++excelrow
				}
				if "`omit'" != ""	{
					di "Note: Mixed model suppressed for `var'"
				}	
				if `val1'+`val2'!=1 {
					di as err "SummaryStatistics error: variable `var' identified as Categoric."
				}
			}
			if "`val2'"=="" {
				di as err "SummaryStatistics Warning: Variable `var' is constant at `val1'. No output was produced for `var'."
			}
		}
		else if "`varlist'"!="`r(varlist)'" { // Numeric/Continuous 
			qui ta `var', matrow(names2) 
			local rows2 =  rowsof(names2)
			forvalues i = 1/`rows2' {	
				local val`i'_2 = names2[`i',1]		
			}
			if "`val2_2'"!="" {
				if `val1_2'+`val2_2'==1 & `rows2'<=2 {
					di as err "SummaryStatistics warning: It looks like `var' is a dummy variable without value label."
				}
				di as text "Note: Variable `var' identified as Numeric/Continuous"
					local vartype "continuous"
					export_statistics `var' `if' `in' `using', excelrow(`excelrow') report_N(`report_N') header(`header') vartype(`vartype') controls(`controls') `omit' `obs_no'
					local ++excelrow
			}
			if "`omit'" != ""	{
				di "Note: Mixed model suppressed for `var'"
			}
			if "`val2_2'"=="" {
				di as err "SummaryStatistics Warning: Variable `var' is constant at `val1_2'. No output was produced for `var'."
			}
		}
		global var_num=$var_num +1 
	}	
	cap matrix drop matname	
	macro drop var_num
	qui count if SES==.
	if `r(N)'!=0 {
		di as err "SummaryStatistics warning: SES dummy contains missing values"
	}
end

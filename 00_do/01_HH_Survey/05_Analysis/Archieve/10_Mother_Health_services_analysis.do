/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: Data analysis - Women Health Serices 		
Author				:	Nicholus Tint Zaw
Date				: 	03/01/2023
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

	****************************************************************************
	* BF Status by ANC Counselling Services *
	****************************************************************************

	/*
	1. Breast feeding practice distribution according to mothers receiving the BF counseling during the antenatal care sessions
	2. Breast feeding practice distribution according to mothers education status
	However, when I look at the data, the practice is not associated with wealth status. 
	Or
	Should I focus on young child feeding practice (MAD, MDD and MMF)? If so, only analysis on association with mothers' education status is required.
	*/

	
	// mom dataset 
	use "$dta/pnourish_mom_health_final.dta", clear 
	
	rename roster_index mom_index
	
	distinct _parent_index mom_index , joint
	
	tempfile momdta 
	save `momdta', replace 
	clear 
	

	// child iycf dataset 
	use "$dta/pnourish_child_iycf_final.dta", clear 
	
	rename women_pos1 mom_index
	
	distinct _parent_index mom_index , joint
	
	merge m:1 _parent_index mom_index using `momdta' 
	
	keep if _merge == 3 // keep only matched obs - mother and child match 
	
	drop _merge 
	
	// women empowerment 
	merge m:1 _parent_index using "$dta/pnourish_WOMEN_EMPOWER_final.dta", keepusing(wempo_index progressivenss)

	keep if _merge == 3
	drop _merge 
	
	* RECODE * 
	// resp_highedu
	replace resp_highedu = .m if resp_highedu > 7 
	replace resp_highedu = 4 if resp_highedu > 4 & !mi(resp_highedu)
	tab resp_highedu, m 

	// anc_bf_counselling
	tab anc_bf_counselling, m 
	replace anc_bf_counselling = .d if anc_bf_counselling == 999
	replace anc_bf_counselling = .n if anc_bf_counselling == 777

	
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)
	
	
	* BF outcome by ANC BF Counselling Status 
	// anc_bf_counselling
	// anc_nut_counselling

	
	foreach var of varlist eibf ebf2d ebf pre_bf mixmf bof cbf isssf {
		
		di "`var'"
		
		svy: tab anc_bf_counselling `var', row 
	}
	
	
	* BF outcomes by ANC visit frequency 
	local outcome 	eibf ebf2d ebf pre_bf mixmf bof cbf isssf 
	foreach v in `outcome' {
		
		di "`v'"
		foreach var of varlist anc_visit_trained {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
			
			conindex2 `v', rank(`var') covars(i.resp_highedu i.org_name_num stratum progressivenss anc_bf_counselling) svy wagstaff bounded limits(0 1)

		}
	
	}
	
	
// END HERE 



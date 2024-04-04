/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: Data analysis - Food Security & Depression		
Author				:	Nicholus Tint Zaw
Date				: 	04/02/2024
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

	****************************************************************************
	* Prepare the Dataset *
	****************************************************************************
	
	* Childhood illness * 
	use "$dta/pnourish_child_health_analysisprep.dta", clear 
	
	// prepare as hh level dataset (now it is child level)
	foreach var of varlist child_ill_yes treat_pay cope_food_consumption cope_financial hhpay_saving cope_nonfood cope_adverse_treatcost {
	   
	   bysort _parent_index: egen `var'_h = total(`var')
	   
	   replace `var'_h = 1 if `var'_h > 0 & !mi(`var'_h )
	   
	   replace `var' = `var'_h 
		
	}
	
	bysort _parent_index: keep if _n == 1
	keep	_parent_index child_ill_yes treat_pay cope_food_consumption cope_financial ///
			hhpay_saving cope_nonfood cope_adverse_treatcost respd_chid_num caregiver_u5_num caregiver_chidnum_grp
	
	tempfile childhood_illness
	save `childhood_illness', replace 
	
	* Respondent Characteristics
	use "$dta/pnourish_respondent_info_final.dta", clear  
	
	* HH income 
	merge 1:1 _parent_index using "$dta/pnourish_INCOME_WEALTH_final.dta", assert(3) nogen 
	
	
	* Depression: PHQ9
	merge 1:1 _parent_index using "$dta/pnourish_PHQ9_final.dta", assert(3) nogen 
	
	
	* Food Security 
	merge 1:1 _parent_index using "$dta/pnourish_FIES_final.dta", assert(3) nogen    

	* Women empowerment
	merge 1:1 _parent_index using "$dta/pnourish_WOMEN_EMPOWER_final.dta", assert(3) nogen keepusing(wempo_index wempo_category progressivenss)
	
	* Childhood illness and Payment/Coping 
	merge 1:1 _parent_index using `childhood_illness', assert(1 3) nogen  
	
	* program exposure 
	merge 1:1 _parent_index using "$dta/pnourish_program_exposure_final.dta", assert(1 3) nogen  
	

	

	****************************************************************************
	** Construct the required varaibles for analysis 
	****************************************************************************
	
	* Respondent info 
	* hh head 
	lab var resp_hhhead "HH-head (women)"
	tab resp_hhhead, m 
	
	* treated other and monestic education as missing
	replace resp_highedu = .m if resp_highedu > 7 
	replace resp_highedu = 4 if resp_highedu > 4 & !mi(resp_highedu)
	tab resp_highedu, m 
	
	gen respd_age_grp = (respd_age < 25)
	replace respd_age_grp = 2 if respd_age >= 25 & respd_age < 35 
	replace respd_age_grp = 3 if respd_age >= 35  
	replace respd_age_grp = .m if mi(respd_age)
	lab def respd_age_grp 1"< 25 years old" 2"25 - 34 years old" 3"35+ years old"
	lab val respd_age_grp respd_age_grp
	tab respd_age_grp, m 
	
	* FIES - food insecurity dummy outcome * 
	* cutoffs for the raw score of 4+ = food insecurity 
	gen fies_insecurity = (fies_rawscore >= 4) 
	replace fies_insecurity = .m if mi(fies_rawscore)
	lab def fies_insecurity 0"Food secure" 1"Food insecue"
	lab val fies_insecurity fies_insecurity
	tab fies_insecurity, m 
	
	
	* Depression 
	tab phq9_score, m 
	tab phq9_cat, m 
	
	gen depression_yes = (phq9_cat > 1 & !mi(phq9_cat))
	replace depression_yes = .m if mi(phq9_cat)
	lab var depression_yes "Depression (yes)"
	tab depression_yes, m 
	
	* Income and life perception 
	tab d0_per_std, m 
	
	gen wellbeing_ladder = d0_per_std 
	lab var wellbeing_ladder "Subjective Well-being Ladder Position (top step: 10 & bottom step: 0)"
	tab wellbeing_ladder, m 
	
	tab d4_inc_status, m 
	
	gen income_lower = (d4_inc_status == 1)
	replace income_lower = .m if mi(d4_inc_status)
	lab var income_lower "Lower income than usual (last month)"
	tab income_lower, m 
	
	// d6_cope4 d6_cope5 d6_cope6 d6_cope7 d6_cope10 d6_cope12
	
	****************************************************************************
	** Analysis 
	****************************************************************************
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	&&
	//Childhood_illness_healthseeking
	
	global outcomes		depression_yes
	

	
	foreach var of global outcomes {
	    
			
		local regressor  	resp_highedu respd_age_grp caregiver_chidnum_grp caregiver_u5_num ///
							resp_hhhead wempo_category ///
							child_ill_yes treat_pay income_lower fies_insecurity /*wellbeing_ladder*/ ///
							wealth_quintile_ns org_name_num stratum 
							 
		local i = 2
		
		svy: mean `var'
		
		putexcel set "$result/depression_foodsecurity_results.xlsx", sheet("`var'") modify
		putexcel A1 = matrix(e(b)), names
		putexcel close
		
		foreach reg in `regressor' {
			
			svy: mean `var', over(`reg')
			
			local i = `i' + 2
			
			putexcel set "$result/depression_foodsecurity_results.xlsx", sheet("`var'") modify
			putexcel A`i' = matrix(e(b)), names
			putexcel close
			
			local i = `i' + 2
			
		}
		
		
	}
	

		
	
	** GLM regression - prevalance ratio 
	/*
	
Interpretation:

A prevalence ratio of 1 indicates no difference in prevalence between the comparison groups.
A prevalence ratio greater than 1 indicates a higher prevalence of the outcome variable in the reference group compared to the comparison group.
A prevalence ratio less than 1 indicates a lower prevalence of the outcome variable in the reference group compared to the comparison group.
Example Interpretation:

If the prevalence ratio for households with two children compared to households with one child is 1.20, it means that households with two children have a 20% higher prevalence of childhood illness compared to households with one child.
If the prevalence ratio for households with three or more children compared to households with one child is 0.80, it means that households with three or more children have a 20% lower prevalence of childhood illness compared to households with one child.	
	
	*/

	
	local outcomes	depression_yes
	
	foreach outcome in `outcomes' {
	 
		local regressor  	resp_highedu respd_age_grp caregiver_chidnum_grp caregiver_u5_num ///
							resp_hhhead wempo_category ///
							child_ill_yes treat_pay income_lower fies_insecurity wellbeing_ladder ///
							wealth_quintile_ns org_name_num stratum 
			

		foreach v in `regressor' {
			
			
			putexcel set "$out/reg_output/depression_food_security_`outcome'_glm_models.xlsx", sheet("`v'") modify 
			
			if "`v'" == "wellbeing_ladder" {
			    
			    svy: glm `outcome' `v', family(binomial) link(log) nolog eform
			}
			else {
			    
			    svy: glm `outcome' i.`v', family(binomial) link(log) nolog eform
			}
			
			
			estimates store `v', title(`v')
			
			putexcel (A1) = etable
			
		}
			
	}	
	   

	// depression_yes
	pwcorr fies_insecurity child_ill_yes treat_pay
	
	
	putexcel set "$out/reg_output/depression_food_security_depression_yes_glm_models.xlsx", sheet("Final_model") modify 
	
	svy: glm depression_yes 	fies_insecurity /// 
								respd_age /*i.respd_age_grp*/ ///
								respd_chid_num /*i.caregiver_chidnum_grp*/ ///
								caregiver_u5_num ///
								i.wempo_category ///
								child_ill_yes ///
								treat_pay ///
								i.org_name_num, ///
								family(binomial) link(log) nolog eform 

	putexcel (A1) = etable
	
	** Concentration Index 		
	putexcel set "$result/depression_foodsecurity_results.xlsx", sheet("CI_result") modify
	putexcel A2 = "variable name"
	putexcel B2 = "CI (crude)"
	putexcel C2 = "P val"
	putexcel D2 = "CI (Adjusted)"
	putexcel E2 = "P val"
	
	local i = 3
	
	local ranks NationalScore wellbeing_ladder
	
	foreach var in `ranks' {
		
		conindex depression_yes, rank(`var') svy wagstaff bounded limits(0 1)
		
		putexcel A`i' = "`var'"
		putexcel B`i' = `r(CI)'
		
		putexcel close
		
		local i = `i' + 2
	}
	
	
	// depression_yes - NationalScore
	putexcel set "$result/depression_foodsecurity_results.xlsx", sheet("CI_result") modify
	
	conindex2 depression_yes, 	rank(NationalScore) ///
								covars(	fies_insecurity /// 
										i.respd_age_grp ///
										i.caregiver_chidnum_grp ///
										i.caregiver_u5_num ///
										i.wempo_category ///
										child_ill_yes ///
										treat_pay ///
										i.org_name_num) ///
								svy wagstaff bounded limits(0 1)

	putexcel D3 = `r(CI)'
	putexcel close
	
	// depression_yes - wellbeing_ladder
	putexcel set "$result/depression_foodsecurity_results.xlsx", sheet("CI_result") modify
	
	conindex2 depression_yes, 	rank(wellbeing_ladder) ///
								covars(	fies_insecurity /// 
										i.respd_age_grp ///
										i.caregiver_chidnum_grp ///
										i.caregiver_u5_num ///
										i.wempo_category ///
										child_ill_yes ///
										treat_pay ///
										i.org_name_num) ///
								svy wagstaff bounded limits(0 1)

	putexcel D5 = `r(CI)'
	putexcel close
	
// END HERE 



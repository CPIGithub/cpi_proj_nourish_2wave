/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: Data analysis - Child level			
Author				:	Nicholus Tint Zaw
Date				: 	03/01/2023
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

	
	****************************************************************************
	* Prepare the dataset *
	****************************************************************************
	* Child Health Data *
	use "$dta/pnourish_child_health_final.dta", clear 
	
	
	* Vaccine or not - verified by vaccine card 
	gen child_vaccin_yes = (child_vaccin_card == 1)
	lab var child_vaccin_yes "Vaccinated (verified by vaccinations card)"
	tab child_vaccin_yes, m 
	
	
	* women empowerment dataset 
	merge m:1 _parent_index using "$dta/pnourish_WOMEN_EMPOWER_final.dta", ///
							keepusing(wempo_index wempo_category progressivenss)
	
	drop if _merge == 2 
	drop _merge 

	* mother info
	drop roster_index hh_mem_age
	
	rename women_pos1 roster_index 
	
	distinct roster_index _parent_index, joint 
	
	tab roster_index, m // 777 and 999 mothers death or not from this HH
	* consider main caregiver as respondent - hh member index 1 
	gen caregiver_biochild = (roster_index < 777)
	lab var caregiver_biochild "Biological Child (yes/no)"
	tab caregiver_biochild, m 
	
	replace roster_index = 1 if roster_index >= 777 & !mi(roster_index)
	tab roster_index, m 
	
	merge m:1 	roster_index _parent_index using "$dta/grp_hh_clean.dta", ///
				keepusing(hh_mem_age hh_mem_highedu hh_mem_head hh_mem_u5num hh_mem_u2num) ///
				assert(2 3) nogen keep(match)
	
	* respondent info
	merge m:1 _parent_index using "$dta/pnourish_respondent_info_final.dta", ///
							keepusing(respd_age resp_highedu respd_chid_num) 
	
	drop if _merge == 2 
	drop _merge 
	
	
	* Add Village Survey Info 
	global villinfo 	hfc_near_dist_dry hfc_near_dist_rain ///
						mkt_near_dist_dry mkt_near_dist_rain ///
						hfc_vill1 hfc_vill2 hfc_vill3 hfc_vill4 hfc_vill5 hfc_vill6 hfc_vill888 hfc_vill0 
	
	merge m:1 geo_vill using 	"$dta/PN_Village_Survey_FINAL_Constructed.dta", ///
								keepusing($villinfo) 
	
	drop if _merge == 2
	drop _merge 
	
	// detach value label - resulted from merging 
	foreach var of varlist hfc_near_dist_dry hfc_near_dist_rain mkt_near_dist_dry mkt_near_dist_rain {
		
		lab val `var'
	}
	

	****************************************************************************
	** Construct the required varaibles for analysis 
	****************************************************************************
	* Village level info
	* proximity to health facility 
	egen hfc_near_dist = rowmean(hfc_near_dist_dry hfc_near_dist_rain)
	replace hfc_near_dist = .m if mi(hfc_near_dist_dry) & mi(hfc_near_dist_rain)
	lab var hfc_near_dist "Nearest Health Facility - hours for round trip"
	tab hfc_near_dist, m 
	
	tab hfc_vill0, m 
	gen hfc_vill_yes = (hfc_vill0 == 0)
	replace hfc_vill_yes = .m if mi(hfc_vill0)
	lab val hfc_vill_yes yesno 
	tab hfc_vill_yes, m 
	
	* distance HFC category 
	gen hfc_distance = .m 
	replace hfc_distance = 0 if hfc_near_dist_rain == 0
	replace hfc_distance = 1 if hfc_near_dist_rain > 0 & hfc_near_dist_rain <= 1.5
	replace hfc_distance = 2 if hfc_near_dist_rain > 1.5 & hfc_near_dist_rain <= 3
	replace hfc_distance = 3 if hfc_near_dist_rain > 3 & !mi(hfc_near_dist_rain)
	lab def hfc_distance 0"Health Facility present at village" 1"<= 1.5 hours" 2"1.6 to 3 hours" 3">3 hours"
	lab val hfc_distance hfc_distance
	lab var hfc_distance "Nearest Health Facility - hours for round trip"
	tab hfc_distance, mis
	
	* Caregiver/Mother information 
	// age 
	rename hh_mem_age caregiver_age 
	replace caregiver_age = respd_age if !mi(respd_age) & mi(caregiver_age)
	tab caregiver_age, m 
	
	// education 
	rename hh_mem_highedu caregiver_edu 
	replace caregiver_edu = resp_highedu if !mi(resp_highedu) & mi(caregiver_edu)
	tab caregiver_edu, m 
	
	* treated other and monestic education as missing
	replace caregiver_edu = .m if caregiver_edu > 7 
	replace caregiver_edu = 4 if caregiver_edu > 4 & !mi(caregiver_edu)
	tab caregiver_edu, m 
	
	gen caregiver_age_grp = (caregiver_age < 25)
	replace caregiver_age_grp = 2 if caregiver_age >= 25 & caregiver_age < 35 
	replace caregiver_age_grp = 3 if caregiver_age >= 35  
	replace caregiver_age_grp = .m if mi(caregiver_age)
	lab def caregiver_age_grp 1"< 25 years old" 2"25 - 34 years old" 3"35+ years old"
	lab val caregiver_age_grp caregiver_age_grp
	tab caregiver_age_grp, m 
	
	recode respd_chid_num (1 = 1) (2 = 2) (3/15 = 3), gen(caregiver_chidnum_grp)
	replace caregiver_chidnum_grp = .m if mi(respd_chid_num)
	lab def caregiver_chidnum_grp 1"Has only one child" 2"Has two children" 3"Has three children & more" 
	lab val caregiver_chidnum_grp caregiver_chidnum_grp 
	lab var caregiver_chidnum_grp "Caregiver Number of Children"
	tab caregiver_chidnum_grp, m 
	
	* U5 num 
	egen caregiver_u5_num = rowtotal(hh_mem_u5num hh_mem_u2num)
	replace caregiver_u5_num = .m if mi(hh_mem_u5num) & mi(hh_mem_u2num)
	lab var caregiver_u5_num "Caregiver U5 child number"
	tab caregiver_u5_num, m 
	

	* Child information 
	* gender 
	gen child_sex = hh_mem_sex
	lab var child_sex "child sex (1 male, 0 female)"
	
	
	* first born child or first adopted child 
	* child position age * 
	bysort respd_id: gen u5_indata = _N
	
	gsort +respd_id -child_age_month
	bysort respd_id: gen child_birth_order = _n 
	bysort respd_id: egen child_birth_oldest = min(child_birth_order)
	lab var child_birth_order "age order (eldest to youngest)"
	tab child_birth_order, m 
	
	
	tab respd_chid_num caregiver_u5_num , m 
	tab caregiver_u5_num caregiver_biochild, m 
	tab u5_indata caregiver_biochild, m 
	tab respd_chid_num u5_indata , m 

	
	gen first_born_child = 0 
	replace first_born_child = 1 if respd_chid_num == 1 & caregiver_biochild == 1
	replace first_born_child = 1 if respd_chid_num == 1 & caregiver_biochild == 0
	bysort respd_id: replace first_born_child = 1 if 	caregiver_biochild == 1 & ///
														respd_chid_num <= u5_indata & ///
														child_birth_order == child_birth_oldest	
	bysort respd_id: replace first_born_child = 1 if 	caregiver_biochild == 0 & ///
														respd_chid_num <= u5_indata & ///
														child_birth_order == child_birth_oldest	
	tab first_born_child, m 

	* generate the interaction variable - stratum Vs quantile 
	gen NationalQuintile_stratum  =   NationalQuintile*stratum 

	/*
	 - for vaccinations, we wanted to look at the change in "ever vaccinated" for our households, not just compare with mcct baseline. Can we do this/have we done, for children under 1, under 2 (since coup) or older? Can we also map this and write a bit more in the section? It was an area of interest for EHOs.

	*/
	
	recode child_age_month (0/11 = 1)(12/23 = 2)(24/35 = 3)(36/47 = 4)(48/59 = 5), gen(child_age_yrs)
	tab child_age_yrs, m 
  
	   
	* Outcomes varaibles 
	* illness - any illness*
	gen child_ill_yes = (child_ill0 == 0)
	replace child_ill_yes = .m if mi(child_ill0) | child_ill888 == 1
	lab var child_ill_yes "Experienced illness (diarrhoea, cough, fever) in last 2 weeks"
	tab child_ill_yes, m 
	
	* treatment or not **
	egen child_ill_treat = rowtotal(child_diarrh_treat child_cough_treat child_fever_treat)
	replace child_ill_treat = 1 if child_ill_treat > 0 
	replace child_ill_treat = .m if child_ill888 == 1 | child_ill_yes == 0
	lab var child_ill_treat "Received treatment for illness"
	tab child_ill_treat, m 
	
	* treatment with health personnel or not **
	egen child_ill_trained = rowtotal(child_diarrh_trained child_cough_trained child_fever_trained)
	replace child_ill_trained = 1 if child_ill_trained > 0 
	replace child_ill_trained = .m if child_ill888 == 1 | child_ill_yes == 0
	lab var child_ill_trained "Treated with trained health personnel"
	tab child_ill_trained, m 

	** Treatment 
	
	tab1 child_diarrh_where child_cough_where child_fever_where
	
	tab1 child_diarrh_who child_cough_who child_fever_who
	
	gen child_treat_eho = (	child_diarrh_where == 5 | child_cough_where == 5 | child_fever_where == 5 | ///
							child_diarrh_where == 6 | child_cough_where == 6 | child_fever_where == 6 | ///
							child_diarrh_who == 9 | child_cough_who == 9 | child_fever_who == 9)
	replace child_treat_eho = .m if child_ill888 == 1 | child_ill_yes == 0
	lab var child_treat_eho "Treated at EHO clinic or with health personnel"
	tab child_treat_eho, m 
	
	* illness episode 
	egen child_ill_episode = rowtotal(child_ill1 child_ill2 child_ill3)
	replace child_ill_episode = .m if child_ill888 == 1 | child_ill_yes == 0
	lab var child_ill_episode "Episode of Illness"
	tab child_ill_episode, m 
	

	* Payment and Coping Mechanism * 
	egen treat_pay = rowtotal(child_*_pay)
	replace treat_pay = 1 if treat_pay > 0 
	replace treat_pay = .m if child_ill_treat != 1
	lab var treat_pay "Treatment payment (yes)"
	tab treat_pay, m 
	
	* Coping mechanism 
	egen cope_food_consumption = rowtotal(child_*_cope4)
	replace cope_food_consumption = 1 if cope_food_consumption > 0 
	replace cope_food_consumption = .m if child_ill_treat != 1
	lab var cope_food_consumption "Reduced food consumption"
	tab cope_food_consumption, m 
	
	egen cope_financial = rowtotal(	child_*_cope1 child_*_cope2 child_*_cope9 child_*_cope6 /// // need to correct this child_*_cope9 with child_*_cope5 - now 6 obs different 
									child_*_cope10 child_*_cope11 child_*_cope12 child_*_cope13 child_*_cope14)
	replace cope_financial = 1 if cope_financial > 0 
	replace cope_financial = .m if child_ill_treat != 1
	lab var cope_financial "Financial coping"
	tab cope_financial, m 
	
	egen hhpay_saving = rowtotal(	child_*_cope1 child_*_cope2 child_*_cope9)
	replace hhpay_saving = 1 if hhpay_saving > 0 
	replace hhpay_saving = .m if child_ill_treat != 1
	lab var hhpay_saving "HH with saving amount (only for the sample: HH paid for tratment)"
	tab hhpay_saving, m 
	
	
	egen cope_nonfood = rowtotal(	child_*_cope3 child_*_cope9)
	replace cope_nonfood = 1 if cope_nonfood > 0 
	replace cope_nonfood = .m if child_ill_treat != 1
	lab var cope_nonfood "Reduced Non-food consumption"
	tab cope_nonfood, m 	
	
	egen cope_adverse_treatcost = rowtotal(cope_food_consumption cope_financial cope_nonfood)
	replace cope_adverse_treatcost = 1 if cope_adverse_treatcost > 0 
	replace cope_adverse_treatcost = .m if child_ill_treat != 1
	lab var cope_adverse_treatcost "Any adverse coping mechanism (to pay for treatment)"
	tab cope_adverse_treatcost, m 	

	* Reason for not taking treatment * 
	egen notreat_transport = rowtotal(child_*_notreat1 child_*_notreat2 child_*_notreat3 child_*_notreat9)
	replace notreat_transport = 1 if notreat_transport > 0 
	replace notreat_transport = .m if child_ill_treat != 0
	lab var notreat_transport "Transportation distance/cost"
	tab notreat_transport, m 	
	
	egen notreat_treatcost = rowtotal(child_*_notreat4)
	replace notreat_treatcost = 1 if notreat_treatcost > 0 
	replace notreat_treatcost = .m if child_ill_treat != 0
	lab var notreat_treatcost "Treatment cost"
	tab notreat_treatcost, m 	
	
	egen notreat_conflict = rowtotal(child_*_notreat12)
	replace notreat_conflict = 1 if notreat_conflict > 0 
	replace notreat_conflict = .m if child_ill_treat != 0
	lab var notreat_conflict "Insecurity due to conflict"
	tab notreat_conflict, m 
	
	egen notreat_disability = rowtotal(child_*_notreat13)
	replace notreat_disability = 1 if notreat_disability > 0 
	replace notreat_disability = .m if child_ill_treat != 0
	lab var notreat_disability "Disability"
	tab notreat_disability, m 
	
	egen notreat_covid = rowtotal(child_*_notreat10)
	replace notreat_covid = 1 if notreat_covid > 0 
	replace notreat_covid = .m if child_ill_treat != 0
	lab var notreat_covid "Feat of Covid-19"
	tab notreat_covid, m 

	egen notreat_advise = rowtotal(child_*_notreat5 child_*_notreat6 child_*_notreat15 )
	replace notreat_advise = 1 if notreat_advise > 0 
	replace notreat_advise = .m if child_ill_treat != 0
	lab var notreat_advise "Advise not to/think it is not require take the treatment"
	tab notreat_advise, m 	
	
	egen notreat_notpresent = rowtotal(child_*_notreat14)
	replace notreat_notpresent = 1 if notreat_notpresent > 0 
	replace notreat_notpresent = .m if child_ill_treat != 0
	lab var notreat_notpresent "Health personnel not present at the health facility"
	tab notreat_notpresent, m 	
	
	egen notreat_hhwork = rowtotal(child_*_notreat11)
	replace notreat_hhwork = 1 if notreat_hhwork > 0 
	replace notreat_hhwork = .m if child_ill_treat != 0
	lab var notreat_hhwork "household chores burden"
	tab notreat_hhwork, m 	
	

	
	
	// notreat_transport notreat_treatcost notreat_conflict notreat_disability notreat_covid notreat_advise notreat_notpresent notreat_hhwork hhpay_saving
	tab1 notreat_transport notreat_advise  
	
	****************************************************************************
	** Analysis 
	****************************************************************************
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	
	//Childhood_illness_healthseeking
	
	global outcomes		child_vaccin_yes child_ill_yes child_ill_treat child_ill_trained treat_pay cope_adverse_treatcost 
	

	
	foreach var of global outcomes {
	    
		if "`var'" == "treat_pay" | "`var'" == "cope_adverse_treatcost" {
			
			local regressor  	caregiver_edu caregiver_age_grp caregiver_chidnum_grp caregiver_u5_num ///
								caregiver_biochild first_born_child ///
								child_ill_episode hfc_vill_yes hfc_distance ///
								wealth_quintile_ns wempo_category org_name_num stratum ///
								child_ill1 child_ill2 child_ill3 ///
								child_sex ///
								child_ill_trained child_treat_eho	    
		} 
		else {
		    
			local regressor  	caregiver_edu caregiver_age_grp caregiver_chidnum_grp caregiver_u5_num ///
								caregiver_biochild first_born_child ///
								child_ill_episode hfc_vill_yes hfc_distance ///
								wealth_quintile_ns wempo_category org_name_num stratum ///
								child_ill1 child_ill2 child_ill3 ///
								child_sex 
		}
		
	
		local i = 2
		
		svy: mean `var'
		
		putexcel set "$result/childhood_health_seeking_results.xlsx", sheet("`var'") modify
		putexcel A1 = matrix(e(b)), names
		putexcel close
		
		foreach reg in `regressor' {
			
			svy: mean `var', over(`reg')
			
			local i = `i' + 2
			
			putexcel set "$result/childhood_health_seeking_results.xlsx", sheet("`var'") modify
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

	
	local outcomes	child_vaccin_yes child_ill_yes child_ill_treat child_ill_trained treat_pay cope_adverse_treatcost 
	
	foreach outcome in `outcomes' {
	 
		local regressor  	caregiver_edu caregiver_age_grp caregiver_chidnum_grp caregiver_u5_num ///
							caregiver_biochild first_born_child ///
							child_ill_episode ///
							hfc_vill_yes hfc_distance ///
							wealth_quintile_ns wempo_category org_name_num stratum ///
							child_ill1 child_ill2 child_ill3 ///
							child_sex 
			
		if "`outcome'" == "child_ill_yes" | "`outcome'" == "child_vaccin_yes" {
			
		local regressor  	caregiver_edu caregiver_age_grp caregiver_chidnum_grp caregiver_u5_num ///
							caregiver_biochild first_born_child ///
							hfc_vill_yes hfc_distance ///
							wealth_quintile_ns wempo_category org_name_num stratum ///
							child_sex 
		}
		
		else if "`outcome'" == "treat_pay" | "`outcome'" == "cope_adverse_treatcost" {
		local regressor  	caregiver_edu caregiver_age_grp caregiver_chidnum_grp caregiver_u5_num ///
							caregiver_biochild first_born_child ///
							child_ill_episode ///
							hfc_vill_yes hfc_distance ///
							wealth_quintile_ns wempo_category org_name_num stratum ///
							child_ill1 child_ill2 child_ill3 ///
							child_sex ///
							child_ill_trained child_treat_eho 		    
			
		}

		
		foreach v in `regressor' {
			
			
			putexcel set "$out/reg_output/Childhood_illness_`outcome'_glm_models.xlsx", sheet("`v'") modify 
		
			//if "`v'" != "child_ill_episode" | "`var'" == "caregiver_u5_num" {
				
				//svy: glm `outcome' i.`v', family(binomial) link(log) nolog eform
			//}
			//else {
				
				svy: glm `outcome' i.`v', family(binomial) link(log) nolog eform
			//}
			
			
			estimates store `v', title(`v')
			
			putexcel (A1) = etable
			
		}
			
	}	
	   

							
						
	local outcomes	child_vaccin_yes child_ill_yes child_ill_yes child_ill_treat child_ill_trained treat_pay cope_adverse_treatcost 
	
	* final model [drop the type of illness and number of illness type]
	// child_vaccin_yes
	putexcel set "$out/reg_output/Childhood_illness_child_vaccin_yes_glm_models.xlsx", sheet("Final_model") modify 
	
	svy: glm child_vaccin_yes 	i.caregiver_edu /// 
								i.caregiver_chidnum_grp ///
								i.caregiver_u5_num ///
								caregiver_biochild ///
								first_born_child ///
								i.hfc_distance ///
								i.wealth_quintile_ns ///
								i.wempo_category ///
								i.org_name_num ///
								stratum, ///
								family(binomial) link(log) nolog eform	
	putexcel (A1) = etable
	

	// child_ill_yes
	putexcel set "$out/reg_output/Childhood_illness_child_ill_yes_glm_models.xlsx", sheet("Final_model") modify 
	
	svy: glm child_ill_yes	 	child_sex ///
								i.hfc_distance ///
								i.wealth_quintile_ns ///
								i.wempo_category ///
								i.org_name_num, ///
								family(binomial) link(log) nolog eform	
	putexcel (A1) = etable
	
	
	
	// child_ill_treat
	putexcel set "$out/reg_output/Childhood_illness_child_ill_treat_glm_models.xlsx", sheet("Final_model") modify 
	
	svy: glm child_ill_treat 	i.caregiver_edu /// 
								i.caregiver_u5_num ///
								caregiver_biochild ///
								i.hfc_distance ///
								i.wealth_quintile_ns ///
								i.wempo_category ///
								i.org_name_num ///
								stratum, ///
								family(binomial) link(log) nolog eform

	putexcel (A1) = etable
	

	// child_ill_trained
	putexcel set "$out/reg_output/Childhood_illness_child_ill_trained_glm_models.xlsx", sheet("Final_model") modify 
	
	svy: glm child_ill_trained 	i.caregiver_u5_num ///
								caregiver_biochild ///
								i.hfc_distance ///
								i.wealth_quintile_ns ///
								i.wempo_category ///
								i.org_name_num ///
								stratum, ///
								family(binomial) link(log) nolog eform
	putexcel (A1) = etable
	
	
	// treat_pay 
	putexcel set "$out/reg_output/Childhood_illness_treat_pay_glm_models.xlsx", sheet("Final_model") modify 
	
	svy: glm treat_pay 	child_ill_trained ///
						child_treat_eho ///
						i.org_name_num ///
						stratum, ///
						family(binomial) link(log) nolog eform
	putexcel (A1) = etable	
	
	// cope_adverse_treatcost 
	putexcel set "$out/reg_output/Childhood_illness_cope_adverse_treatcost_glm_models.xlsx", sheet("Final_model") modify 
	
	svy: glm cope_adverse_treatcost 	child_ill_trained ///
										child_treat_eho ///
										i.wempo_category ///
										i.org_name_num ///
										stratum, ///
										family(binomial) link(log) nolog eform
	putexcel (A1) = etable	
	
	
	
	** Concentration Index 		
	putexcel set "$result/childhood_health_seeking_results.xlsx", sheet("CI_result") modify
	putexcel A2 = "variable name"
	putexcel B2 = "CI (crude)"
	putexcel C2 = "P val"
	putexcel D2 = "CI (Adjusted)"
	putexcel E2 = "P val"
	
	local i = 3
	foreach var of global outcomes {
		
		conindex `var', rank(NationalScore) svy wagstaff bounded limits(0 1)
		
		putexcel A`i' = "`var'"
		putexcel B`i' = `r(CI)'
		
		putexcel close
		
		local i = `i' + 2
	}
	
	
	* CI adjusted model 
	// child_vaccin_yes
	putexcel set "$result/childhood_health_seeking_results.xlsx", sheet("CI_result") modify
	
	conindex2 child_vaccin_yes, rank(NationalScore) ///
								covars(	i.caregiver_edu /// 
										i.caregiver_chidnum_grp ///
										i.caregiver_u5_num ///
										caregiver_biochild ///
										first_born_child ///
										i.hfc_distance ///
										i.wealth_quintile_ns ///
										i.wempo_category ///
										i.org_name_num ///
										stratum) ///
								svy wagstaff bounded limits(0 1)
	putexcel D3 = `r(CI)'
	putexcel close
	

	// child_ill_yes
	putexcel set "$result/childhood_health_seeking_results.xlsx", sheet("CI_result") modify
	
	conindex2 child_ill_yes, 	rank(NationalScore) ///
								covars(	child_sex ///
										i.hfc_distance ///
										i.wealth_quintile_ns ///
										i.wempo_category ///
										i.org_name_num) ///
								svy wagstaff bounded limits(0 1)
	putexcel D5 = `r(CI)'
	putexcel close
	
	
	// child_ill_treat
	putexcel set "$result/childhood_health_seeking_results.xlsx", sheet("CI_result") modify
	
	conindex2 child_ill_treat, 	rank(NationalScore) ///
								covars(	i.caregiver_edu /// 
										i.caregiver_u5_num ///
										caregiver_biochild ///
										i.hfc_distance ///
										i.wealth_quintile_ns ///
										i.wempo_category ///
										i.org_name_num ///
										stratum) ///
								svy wagstaff bounded limits(0 1)

	putexcel D7 = `r(CI)'
	putexcel close

	// child_ill_trained
	putexcel set "$result/childhood_health_seeking_results.xlsx", sheet("CI_result") modify
	
	conindex2 child_ill_trained, rank(NationalScore) ///
								covars(	i.caregiver_u5_num ///
										caregiver_biochild ///
										i.hfc_distance ///
										i.wealth_quintile_ns ///
										i.wempo_category ///
										i.org_name_num ///
										stratum) ///
								svy wagstaff bounded limits(0 1)
	putexcel D9 = `r(CI)'
	putexcel close
	
	// treat_pay
	putexcel set "$result/childhood_health_seeking_results.xlsx", sheet("CI_result") modify
	
	conindex2 treat_pay, rank(NationalScore) ///
						covars(	child_ill_trained ///
								child_treat_eho ///
								i.org_name_num ///
								stratum) ///
						svy wagstaff bounded limits(0 1)
	putexcel D11 = `r(CI)'
	putexcel close
	
	
	// cope_adverse_treatcost
	putexcel set "$result/childhood_health_seeking_results.xlsx", sheet("CI_result") modify
	
	conindex2 cope_adverse_treatcost, rank(NationalScore) ///
									covars(	child_ill_trained ///
											child_treat_eho ///
											i.wempo_category ///
											i.org_name_num ///
											stratum) ///
									svy wagstaff bounded limits(0 1)
	putexcel D13 = `r(CI)'
	putexcel close
	

	
	* Reasons for not taking treatment 
	
	local demo hfc_distance wealth_quintile_ns wempo_category org_name_num stratum 
	
	foreach var in `demo' {
	    
		svy: tab `var' notreat_transport, row
		
		svy: tab `var' notreat_advise, row
		
	}
	
	
// END HERE 



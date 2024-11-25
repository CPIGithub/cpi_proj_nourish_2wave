/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: HH survey weight calculation 			
Author				:	Nicholus Tint Zaw
Date				: 	03/21/2023
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

	* endline - village situation update list 
	use "$dta/pn_endline_village_list_updated.dta", clear 
		
	distinct org_name geo_eho_vill_name vill_code, joint 
	
	keep org_name geo_eho_vill_name vill_code  stratum_midterm unaccess_vill midterm_cluster
	
	duplicates tag vill_code, gen(vill_code_dup)
	
	bysort vill_code: replace vill_code = vill_code + "-" + "2" if _n == 2
	
	/*
	
	vill_code	org_name	geo_eho_vill_name
	KRN-002-VIL-071	KEHOC	Noh Htee Leh
	KRN-002-VIL-071-2	KDHW	Noh Htee Leh
	KRN-002-VIL-156	KDHW	Kaw Nyay
	KRN-002-VIL-156-2	KEHOC	Kaw Nyay
	KRN-002-VIL-221	KDHW	Htee Ka Lay
	KRN-002-VIL-221-2	KEHOC	Htee Ka Lay
	KRN-002-VIL-222	KEHOC	Daw Hpyar/ Daw Plat
	KRN-002-VIL-222-2	YSDA	Daw Hpyar/ Daw Plat
	
	
	*/
		
	drop vill_code_dup 
	
	duplicates drop vill_code, force // matching with vill_code get perfect matched 
	
	tempfile endline_list 
	save `endline_list', replace 
	

	* midterm weight data  - preparation 
	********************************************************************************
	* IP villages *
	********************************************************************************

	* endline 
	use "$dta/pn_endline_samplelist.dta", clear  
	 
	rename township_name 				geo_town
	rename vt_sir_num 					geo_vt
	rename vill_sir_num 				geo_vill 

	rename hh_tot 						household 
	rename pop_tot						population
	rename u2_pop 						pop2years 					 						
	rename u2to5_pop 					pop25years 					 					

	distinct geo_vill
	distinct org_name geo_eho_vill_name vill_code, joint 

	tempfile villmaster_endline 
	save `villmaster_endline', replace 
	
	
	
	* Midterm 
	use "$dta/pn_2_samplelist.dta", clear  
	 
	rename fieldnamevillagetracteho  	geo_eho_vt_name
	rename villagenameeho 				geo_eho_vill_name
	rename townshippcode 				geo_town
	rename vt_sir_num 					geo_vt
	rename vill_sir_num 				geo_vill 
	rename organization 				org_name 
	rename villagecode					vill_code

	distinct geo_vill

	drop sr 

	distinct org_name geo_eho_vill_name vill_code, joint 

	tempfile villmaster_midterm 
	save `villmaster_midterm', replace 
	
	* in endline we include 27 village which never implement the activities 
	* to account those village in midterm weight 
	preserve 
	
		merge 1:1 org_name geo_eho_vill_name vill_code using `villmaster_endline'
	
		keep if _merge == 2
		
		keep org_name geo_eho_vill_name
				
		tempfile never_imp_27 
		save `never_imp_27', replace 
		
		use `villmaster_endline', clear 
		
		merge 1:1 org_name geo_eho_vill_name using `never_imp_27'
		
		keep if _merge == 3 
		drop _merge 
		
		keep org_name stratum geo_eho_vill_name geo_vill vill_code household population pop2years pop25years u5_pop
		
		gen endline_add_27vill = 1
		
		tempfile never_imp_27 
		save `never_imp_27', replace 
	
	restore 
	
	append using `never_imp_27'

	tempfile villmaster 
	save `villmaster', replace 

	********************************************************************************
	* household survey *
	********************************************************************************

	use "$dta/pnourish_hh_svy_wide.dta", clear 

	keep if will_participate == 1

	// duplicate by geo-person
	duplicates tag geo_town geo_vt geo_vill respd_name respd_age respd_status, gen(dup_resp)
	tab dup_resp, m 

	order svy_date org_name township_name geo_eho_vt_name geo_eho_vill_name stratum 

	drop dup_resp 


	// Survey per village 
	bysort geo_town stratum geo_vt geo_vill: gen tot_consent_svy = _N
	bysort geo_town stratum geo_vt geo_vill: keep if _n == 1


	/*
	bysort org_name township_name stratum geo_eho_vt_name geo_eho_vill_name: gen tot_consent_svy = _N

	bysort org_name township_name stratum geo_eho_vt_name geo_eho_vill_name: keep if _n == 1
	*/

	order org_name township_name geo_town stratum geo_eho_vt_name geo_vt geo_eho_vill_name geo_vill tot_consent_svy

	keep org_name township_name geo_town stratum geo_eho_vt_name geo_vt geo_eho_vill_name geo_vill tot_consent_svy

	distinct org_name township_name stratum geo_eho_vt_name geo_eho_vill_name, joint 

	distinct township_name stratum geo_eho_vt_name geo_eho_vill_name, joint 

	distinct geo_vill

	// merge with village master dataset 
	//merge 1:1 org_name township_name stratum geo_eho_vt_name geo_eho_vill_name using `villmaster'

	merge 1:1 geo_vill using `villmaster'

	drop _merge 

	order	org_name township_name geo_town ///
			stratum ///
			geo_eho_vt_name geo_vt geo_eho_vill_name geo_vill ///
			vill_samplesize tot_consent_svy ///
			household population pop2years pop25years u5_pop ///
			cluster_cat num_cluster cluster_order ///
			vill_accessibility vill_proj_implement emergency_vill 
	
	duplicates tag vill_code, gen(vill_code_dup)
	
	replace vill_code = "KRN-002-VIL-071-2" if org_name == "KEHOC" & geo_eho_vill_name == "Noh Htee Leh"
	replace vill_code = "KRN-002-VIL-156-2" if org_name == "KEHOC" & geo_eho_vill_name == "Kaw Nyay"
	replace vill_code = "KRN-002-VIL-221-2" if org_name == "KEHOC" & geo_eho_vill_name == "Htee Ka Lay"
	replace vill_code = "KRN-002-VIL-222-2" if org_name == "YSDA" & geo_eho_vill_name == "Daw Hpyar/ Daw Plat"

	duplicates drop vill_code, force // matching with vill_code get perfect matched 
	
	merge 1:1 vill_code using `endline_list' // get feasibility status at endline 
	
	/*
	use "$dta/pnourish_hh_weight_final.dta", clear   

	isid township_name geo_town geo_eho_vt_name geo_eho_vill_name vill_code // geo_vill
	
	distinct org_name geo_eho_vill_name vill_code, joint 
	*/	
	drop if _merge == 2
	
	drop _merge  

	tab1 stratum_midterm unaccess_vill midterm_cluster

	// keep only accessiable villages at endline for comparision 
	keep if unaccess_vill == 0 
	
	// revised the weight calculation - with new sample village 
	** Weight Calculation **
	//bysort org_name township_name geo_town stratum geo_eho_vt_name geo_vt geo_eho_vill_name geo_vill: egen stratum_pop = total(population)

	* step (1): Calculate stratum total pop
	bysort stratum org_name: egen stratum_pop = total(household)

	tab stratum_pop, m 

	* step (2): Calculate stratum sample pop 
	bysort stratum org_name: egen st_sample_pop = total(household) if !mi(tot_consent_svy)
	bysort stratum org_name: egen stratum_sample_pop = max(st_sample_pop) 

	tab stratum_sample_pop, m 
	drop st_sample_pop 

	* step (3): Stratum propability: stratum sample pop/stratum pop/stratum
	gen cluster_prob = stratum_sample_pop/stratum_pop

	tab cluster_prob, m 


	* step (4): HH propability (at village level): sample HH (per village) /total HH (per village)
	gen hh_prob = tot_consent_svy/household
	replace hh_prob = 1 if stratum == 1

	tab hh_prob, m 

	* step (5): Calculate Final Wegith 
	gen weight_final = 1/(cluster_prob * hh_prob)
	replace weight_final = 0 if mi(tot_consent_svy)
	tab weight_final

	order population tot_consent_svy stratum_pop stratum_sample_pop cluster_prob weight_final, after (geo_vill)

	keep if !mi(tot_consent_svy)

	* keep only required variable 
	gen midterm_endline = 0 

	keep 	org_name township_name geo_town geo_eho_vt_name geo_eho_vill_name vill_code geo_vill ///
			weight_final midterm_endline ///
			household population pop2years pop25years u5_pop
			
			
	tempfile midterm 
	save `midterm', replace 

	* endline weight weight 
	use "$dta/endline/pnourish_endline_hh_weight_final.dta", clear   

	isid township_name geo_town geo_eho_vt_name geo_eho_vill_name vill_code // geo_vill
	
	gen midterm_endline = 1

	keep 	township_name geo_town geo_eho_vt_name geo_eho_vill_name vill_code geo_vill ///
			weight_final midterm_endline ///
			household population pop2years pop25years u5_pop

	append using `midterm'
	
	
	tab midterm_endline, m 
	lab def midterm_endline 0"midterm" 1"endline"
	lab val midterm_endline midterm_endline
	tab midterm_endline, m 
	
	
	* save as final weight for comparision 
	save "$dta/endline/pnourish_midterm_vs_endline_hh_comparision_weight_final.dta", replace   

// END HERE 




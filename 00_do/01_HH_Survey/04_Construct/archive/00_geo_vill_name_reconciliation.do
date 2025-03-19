/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: HH survey weight calculation 			
Author				:	Nicholus Tint Zaw
Date				: 	03/21/2023
Modified by			:


*******************************************************************************/

	****************************************************************************
	** Directory Settings **
	****************************************************************************

	do "$do/00_dir_setting.do"
	
	********************************************************************************
	* import Sample Size Data *
	********************************************************************************
	// old pre-loaded file
	import delimited using "$result/pn_2_samplelist_old.csv", clear 
	 
	rename fieldnamevillagetracteho  	geo_eho_vt_name
	rename villagenameeho 				geo_eho_vill_name
	rename townshippcode 				geo_town
	rename vt_sir_num 					geo_vt
	rename vill_sir_num 				geo_vill 

	replace geo_eho_vt_name = geo_eho_vill_name if geo_eho_vill_name == "Wal Ta Ran" 
	replace geo_eho_vt_name = geo_eho_vill_name if geo_eho_vill_name == "Lay Wal"

	gen geo_vt_old 		= geo_vt 
	gen geo_vill_old 	= geo_vill

	local mainvar 	township_name geo_eho_vt_name geo_eho_vill_name stratum num_cluster ///
					vill_samplesize sample_check 

	tempfile dfsamplesize
	save `dfsamplesize', replace 
	clear 

	// new pre-loaded file
	use "$dta/pn_2_samplelist_final.dta", clear  
	 
	rename fieldnamevillagetracteho  	geo_eho_vt_name
	rename villagenameeho 				geo_eho_vill_name
	rename townshippcode 				geo_town
	rename vt_sir_num 					geo_vt
	rename vill_sir_num 				geo_vill 

	// replace geo_vt = 1071 if geo_eho_vill_name == "Ka Yit Kyauk Tan" | geo_eho_vill_name == "Mun Hlaing"
	/*
	local mainvar 	township_name geo_eho_vt_name geo_eho_vill_name stratum num_cluster ///
					vill_samplesize sample_check 
					
					
	foreach var in `mainvar' {
		
		rename `var' `var'_n
		
	} */

	local mainvar_n 	township_name geo_eho_vt_name geo_eho_vill_name stratum ///
						num_cluster vill_samplesize sample_check 

	tempfile dfsamplesize_new
	save `dfsamplesize_new', replace 

	merge m:1 township_name geo_town geo_eho_vt_name geo_eho_vill_name using `dfsamplesize'

	replace geo_vt 		= geo_vt_old 	if _merge == 3 & organization == "YSDA"
	replace geo_vill 	= geo_vill_old 	if _merge == 3 & organization == "YSDA"

	&&

	****************************************************************************
	* household survey *
	****************************************************************************

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

	order org_name township_name geo_town stratum geo_eho_vt_name geo_vt geo_eho_vill_name geo_vill tot_consent_svy cluster_cat_str

	keep org_name township_name geo_town stratum geo_eho_vt_name geo_vt geo_eho_vill_name geo_vill tot_consent_svy cluster_cat_str
	
	distinct geo_town stratum geo_vt geo_vill, joint 
	distinct township_name stratum geo_eho_vt_name geo_eho_vill_name, joint 
	distinct org_name township_name stratum geo_eho_vt_name geo_eho_vill_name, joint 
	
	duplicates list township_name stratum geo_eho_vt_name geo_eho_vill_name
	
	br if geo_eho_vill_name == "Yay Kyaw Gyi"
	
	* to match with the village profile info
	/*
	replace geo_eho_vt_name = "Sin Kyone" if geo_vill == 2024
	replace geo_vt = 1011 if geo_vill == 2024
	replace geo_eho_vill_name = "Taw Gyi Gone" if geo_vill == 2024
	*/

	foreach var of varlist _all {
		
		gen `var'_svy = `var'
		
	}
	
	* drop case not found in village profile 
	/*
	org_name	township_name	geo_town	stratum	geo_eho_vt_name	geo_vt	geo_eho_vill_name	geo_vill
	YSDA	Hpa-An	MMR003001	1	Sin Kyone	1011	Taw Gyi Gone	2024
	*/

	tempfile svy 
	save `svy', replace 

	********************************************************************************
	* IP villages *
	********************************************************************************

	use "$dta/pn_2_samplelist_final.dta", clear  
	 
	rename fieldnamevillagetracteho  	geo_eho_vt_name
	rename villagenameeho 				geo_eho_vill_name
	rename townshippcode 				geo_town
	rename vt_sir_num 					geo_vt
	rename vill_sir_num 				geo_vill 
	rename organization 				org_name 
	rename villagecode					vill_code

	distinct geo_vill

	drop sr 
	
	order org_name township_name geo_town stratum geo_eho_vt_name geo_vt geo_eho_vill_name geo_vill cluster_cat_str
	
	keep org_name township_name geo_town stratum geo_eho_vt_name geo_vt geo_eho_vill_name geo_vill cluster_cat_str

	foreach var of varlist _all {
		
		gen `var'_vp = `var'
		
	}

	* code correction 
	
	replace org_name = "KEHOC" if geo_eho_vill_name == "Yay Kyaw Gyi"
	replace org_name = "KEHOC" if geo_vill == 2009
	replace org_name = "KDHW" if geo_vill == 2012
	
	distinct geo_town stratum geo_vt geo_vill, joint 
	distinct township_name stratum geo_eho_vt_name geo_eho_vill_name, joint 
	distinct org_name township_name stratum geo_eho_vt_name geo_eho_vill_name, joint 
	
	duplicates list township_name stratum geo_eho_vt_name geo_eho_vill_name
	
	br if geo_eho_vill_name == "Yay Kyaw Gyi" // from survey data
	br if geo_eho_vill_name == "Daw Hpyar/ Daw Plat" // in village profile list - not included in the survey list 
	
	duplicates drop township_name stratum geo_eho_vt_name geo_eho_vill_name, force 
	
	tempfile villmaster 
	save `villmaster', replace 
	
	********************************************************************************
	* Check Survey Vs Village Profile 
	********************************************************************************
	use `svy', clear
	
	merge 1:1 org_name township_name stratum geo_eho_vt_name geo_eho_vill_name using `villmaster'
	
	keep if _merge == 3
	
	order org_name* township_name* geo_town* stratum* geo_eho_vt_name* geo_vt* geo_eho_vill_name* geo_vill* cluster_cat_str*
	
	count if geo_eho_vill_name != geo_eho_vill_name_svy 
	count if geo_eho_vill_name != geo_eho_vill_name_vp
	count if geo_eho_vill_name_svy != geo_eho_vill_name_vp
	
	count if geo_vill != geo_vill_svy 
	count if geo_vill != geo_vill_vp 
	count if geo_vill_svy != geo_vill_vp
	
	count if geo_vt != geo_vt_svy
	count if geo_vt != geo_vt_vp 
	count if geo_vt_svy != geo_vt_vp 
	
	count if geo_town != geo_town_svy 
	count if geo_town != geo_town_vp
	count if geo_town_svy != geo_town_vp
	
	
	********************************************************************************
	* Midterm weight - old version 
	********************************************************************************
	
	use "$dta/pnourish_midterm_hh_weight_final.dta", clear 
	
	order org_name township_name geo_town stratum geo_eho_vt_name geo_vt geo_eho_vill_name geo_vill 
	
	keep org_name township_name geo_town stratum geo_eho_vt_name geo_vt geo_eho_vill_name geo_vill 

	foreach var of varlist _all {
		
		gen `var'_wt = `var'
		
	}

	distinct geo_town stratum geo_vt geo_vill, joint 
	distinct township_name stratum geo_eho_vt_name geo_eho_vill_name, joint 
	distinct org_name township_name stratum geo_eho_vt_name geo_eho_vill_name, joint 
	
	duplicates list township_name stratum geo_eho_vt_name geo_eho_vill_name
	duplicates list org_name township_name stratum geo_eho_vt_name geo_eho_vill_name
	
	br if geo_eho_vill_name == "Yay Kyaw Gyi" // from survey data

	br if geo_eho_vill_name == "Mun Hlaing" // from weight dta old data
	
	replace geo_eho_vill_name = "Nwar Chan Kone/ Naw Chawt Kone" if geo_vill == 2251
	
	// merge 1:1 org_name township_name stratum geo_eho_vt_name geo_eho_vill_name using `svy'
	merge 1:1 geo_vill using `svy'
	
	order org_name* township_name* geo_town* stratum* geo_eho_vt_name* geo_vt* geo_eho_vill_name* geo_vill* cluster_cat_str*
	

	count if geo_eho_vill_name_svy != geo_eho_vill_name_wt
	count if geo_eho_vt_name_svy != geo_eho_vt_name_wt
	count if township_name_svy != township_name_wt

	
	&&
	
	sort geo_vill 
	
	bysort geo_vill: gen geo_vill_count = _N 
	
	tab geo_vill_count _merge, m 



********************************************************************************
********************************************************************************
	* Get old calculation one 
	use "$dta/pnourish_WASH_final.dta", clear   

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

		
	keep	org_name township_name geo_eho_vt_name geo_eho_vill_name stratum geo_town geo_vt geo_vill ///
			stratum_num org_name_num weight_final 

	bysort geo_town geo_vt geo_vill: keep if _n == 1

	sort geo_vill 

	save "$dta/pnourish_midterm_hh_weight_final.dta", replace

foreach var of varlist 	org_name township_name geo_eho_vt_name geo_eho_vill_name stratum ///
						stratum_num org_name_num weight_final {
							
	rename `var' `var'_old						
							
	}


merge 1:1 geo_town geo_vt geo_vill using "$dta/pnourish_hh_weight_final_new.dta"

foreach var of varlist 	org_name township_name geo_eho_vt_name geo_eho_vill_name stratum ///
						stratum_num org_name_num weight_final {
							
	order `var'_old, after(`var')						
							
	}	
	

// END HERE 




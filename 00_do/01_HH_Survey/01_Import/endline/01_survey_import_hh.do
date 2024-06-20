/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	import Endline HH raw data into dta format 				
Author				:	Nicholus Tint Zaw
Date				: 	06/13/2024
Modified by			:


*******************************************************************************/

	********************************************************************************
	** Directory Settings **
	********************************************************************************

	do "$do/00_dir_setting.do"

	********************************************************************************
	* import Sample Size Data *
	********************************************************************************
	// old pre-loaded file
	import delimited using "$result/pn_endline_samplelist_new27vill.csv", clear 

	gen vill_samplesize = 14 
	
	gen geo_town = township_pcode
	gen geo_vt = vt_sir_num
	gen geo_vill = vill_sir_num

	local mainvar 	township_name geo_eho_vt_name geo_eho_vill_name stratum num_cluster ///
					vill_samplesize /*sample_check*/

	tempfile dfsamplesize
	save `dfsamplesize', replace 
	clear 

	********************************************************************************
	* import household survey *
	********************************************************************************

	import excel using "$raw/endline/PN_HH_Survey_Endline_FINAL.xlsx", describe

	forvalue x = 1/`r(N_worksheet)' {
		
		local sheet_`x' `r(worksheet_`x')'
	}

	forvalue x = 1/`r(N_worksheet)' {
		
		import excel using "$raw/endline/PN_HH_Survey_Endline_FINAL.xlsx", sheet("`sheet_`x''") firstrow clear 
		
		if `x' == 1 {
			
			* rename variable for proper data processing
			rename _* *
			rename enu_end_note  enu_svyend_note 
			lab var enu_svyend_note "enumerator survey end note"
			 
			lookfor _start _end /*starttime endtime submission_time*/

			foreach var in `r(varlist)' {
				
				di "`var'"
				replace `var' = subinstr(`var', "T", " ", 1)
				split `var', p("+" ".")
				
				if "`var'" != "submission_time" {
					drop `var'2
				} 
				
				gen double `var'_c = clock(`var'1, "20YMDhms" )
				format `var'_c %tc 
				order `var'_c, after(`var')
				
				capture drop `var'1
				capture drop `var'2
				capture drop `var'3
			}

			gen svy_date = dofc(starttime)
			format svy_date %td
			gen svy_end_date = dofc(endtime)
			format svy_end_date %td
			order svy_date, before(starttime)
			order svy_end_date, before(endtime)

			* labeling  
			gen org_name = "KEHOC" if org_team == 1
			replace org_name = "YSDA" if org_team == 2
			replace org_name = "KDHW" if org_team == 3

			/*
			tostring superv_name, replace 
			replace superv_name = "Thiri Aung" 			if superv_name == "1"
			replace superv_name = "Saw Than Naing" 		if superv_name == "2"
			replace superv_name = "Man Win Htwe" 		if superv_name == "3"
			replace superv_name = "Nan Khin Hnin Thaw" 	if superv_name == "4"
			replace superv_name = "Ma Nilar Tun" 		if superv_name == "5"
			replace superv_name = "Saw Ku Mu Kay Htoo" 	if superv_name == "6"
			replace superv_name = "Saw Eh Poh" 			if superv_name == "7"
			replace superv_name = "Naw Say Wai Htoo" 	if superv_name == "8"
			replace superv_name = "Saw Hla Win Tun" 	if superv_name == "9"
			replace superv_name = "Saw Baw Mu Doh Soe" 	if superv_name == "10"
			replace superv_name = "Saw D' Poe" 			if superv_name == "11"				
			*/
			
			// keep only final data colletion data 
			sort svy_date
			
			gen svy_final_obs = (svy_date >= td(11jun2024) & !mi(svy_date) & org_team == 2)
			replace svy_final_obs = 1 if (svy_date >= td(10jun2024) & !mi(svy_date) & org_team != 2)
			tab svy_final_obs, m 
			
			order svy_final_obs, before(svy_date)
			
			
			keep if svy_final_obs == 1
			
			rename index _parent_index
			
			preserve 
			
				keep _parent_index
				
				tempfile _parent_index
				save `_parent_index', replace 
			
			restore 
			
		}
		else {
			
			
			merge m:1 _parent_index using `_parent_index'
			
			keep if _merge == 3
			
			drop _merge 
			
			
		}
		
		save "$dta/endline/`sheet_`x''.dta", replace 
	}


	// Prepare one Wide format dataset 

	use "$dta/endline/PN_HH_Survey_Endline_FINAL.dta", clear
	
	// check var 
	local master _N
	di `master'
	
	merge m:1 geo_town geo_vt geo_vill using `dfsamplesize', keepusing(`mainvar' num_cluster cluster_cat cluster_cat_str)

	keep if _merge == 3 
	drop _merge 
	
	tab org_name, m 
	
	// check var 
	local combined _N
	di `combined'
	
	assert `master' == `combined'

	tab1 	township_name geo_eho_vt_name geo_eho_vill_name stratum num_cluster ///
			vill_samplesize /*sample_check*/, m 

	** Labeling 
	* apply WB codebook command 
	//iecodebook template using "$raw/endline/codebook_PN_HH_Survey_Endline_FINAL.xlsx", replace 
	iecodebook apply using "$raw/endline/codebook/codebook_PN_HH_Survey_Endline_FINAL.xlsx"
	
	
	* save as long dataset hh level only 
	save "$dta/endline/PN_HH_Survey_Endline_FINAL.dta", replace 
	
	export excel using "$dta/endline/codebook/PN_HH_Survey_Endline_FINAL.xlsx", sheet("respondent_hh_module") firstrow(variables) replace 
		
	
	/*
	** Duplicate Check and Solved ** 

		* drop the forms used for trianing KECHO and KDHW
		drop if uuid == "2c77dc30-4f08-4184-a75c-dd9b904cfe07"
		drop if uuid == "43f54051-940f-417e-b9c5-7e0b45ae8cbd"
		drop if uuid == "b334432e-b9ad-4b94-b75a-320045118371"
		drop if uuid == "41a7e30a-2e90-43e7-8188-ae9b4fee2d4c"
		drop if uuid == "2c77dc30-4f08-4184-a75c-dd9b904cfe07"
		drop if uuid == "4962b817-424c-4d9b-851b-a91c3467e784"
		drop if uuid == "277e95b9-b0c4-4db0-8dd2-fafcae3453e1"
		drop if uuid == "8abef67b-ed74-460e-9da5-d4840ed9e42d"
		drop if uuid == "40ccdad4-e766-4d13-aebf-bfddfa87776b"
		drop if uuid == "6053426d-bf6e-4cef-8c12-e1b9fe463664"
		drop if uuid == "ddf3acef-2914-41d8-bc13-59e499119963"
		drop if uuid == "de03fa20-b630-4af4-a946-d7119d8d27cb"

		* duplicate by pilot and actual data collection 
		// br if geo_eho_vill_name == "Kha Yit Kyauk Tan"
		drop if uuid == "09124184-a490-4425-850e-30f101f69300"
		drop if uuid == "710ec8c7-a0cb-4fde-b1a0-fcdbdc91e768"
		drop if uuid == "3a859010-6fa4-4506-8b07-bfe74415847a"
		drop if uuid == "27246f45-d6b1-4c29-9a0a-80df17bc1ade"
		drop if uuid == "974445b9-76c7-42bd-b4e6-1d719e25d533"
		drop if uuid == "65b7222f-53a1-45a9-bb5e-b117fa26e4d9"
		drop if uuid == "a31b2736-4d7e-4492-a07d-1352c6e98da6"
		drop if uuid == "577c1720-2edd-43ac-a161-01e42771f584"
		drop if uuid == "9fb81375-b3d6-4e7a-8630-1ac15cb85c63"
		drop if uuid == "7db08448-67df-43d1-bb61-b51d7b294327"
		drop if uuid == "253684db-9c8a-4617-9ab2-f168732579e9"
		drop if uuid == "eaa6df59-29b1-4b39-8e9a-89da2a0b6e9b"

		
		

		// duplicate by geo-person
		duplicates tag geo_town geo_vt geo_vill respd_name respd_age respd_status, gen(dup_resp)
		tab dup_resp, m 

		order org_name township_name geo_eho_vt_name geo_eho_vill_name stratum 

		// duplicate by personal info (exclude geo)
		duplicates tag respd_name respd_age respd_status respd_preg respd_child respd_1stpreg_age respd_chid_num, gen(dup_person)

		tab dup_person, m 
		
		drop dup_resp dup_person
			
			
		* update the vill_samplesize stratum
		replace vill_samplesize = 10 if stratum == 1 & vill_samplesize == 0
		*/
		


	** add hh roster 
	preserve
		use "$dta/endline/grp_hh.dta", clear
		
		//do "$hhimport/grp_hh_labeling.do"

		drop 	_index _parent_table_name _submission__id _submission__uuid ///
				_submission__submission_time _submission__validation_status ///
				_submission__notes _submission__status _submission__submitted_by ///
				_submission__tags
				
		order _parent_index

		destring test, replace
		
		** Labeling 
		* apply WB codebook command 
		//iecodebook template using "$raw/endline/codebook/codebook_grp_hh.xlsx", replace 
		iecodebook apply using "$raw/endline/codebook/codebook_grp_hh.xlsx"

		rename * *_
		rename test_ test

		reshape wide *_ , i(_parent_index) j(test)

		tempfile grp_hh
		save `grp_hh', replace 

	restore

	merge 1:1 _parent_index using `grp_hh'

	drop if _merge == 2
	drop _merge 


	** add child mom info 
	preserve
	
		use "$dta/endline/hh_child_mom_rep.dta", clear
		
		* lab var 
		//lab var hh_mem_mom "Who is the mother of this child?"
		
		// drop obs not eligable for this module 
		drop if mi(hh_mem_mom)

		drop 	_index _parent_table_name _submission__id _submission__uuid ///
				_submission__submission_time _submission__validation_status ///
				_submission__notes _submission__status _submission__submitted_by ///
				_submission__tags
				
		order _parent_index

		destring cal_hh_cname_id, replace

		** Labeling 
		* apply WB codebook command 
		//iecodebook template using "$raw/endline/codebook/codebook_hh_child_mom_rep.xlsx", replace 
		iecodebook apply using "$raw/endline/codebook/codebook_hh_child_mom_rep.xlsx"

		
		rename * *_
		rename cal_hh_cname_id_ cal_hh_cname_id

		reshape wide *_ , i(_parent_index) j(cal_hh_cname_id)

		tempfile hh_child_mom_rep
		save `hh_child_mom_rep', replace 

	restore

	merge 1:1 _parent_index using `hh_child_mom_rep'

	drop if _merge == 2

	drop _merge 



	** add child iycf info
	preserve
	
		use "$dta/endline/grp_q2_5_to_q2_7.dta", clear
		
		//do "$hhimport/child_iycf_labeling.do"

		// drop obs not eligable for this module 
		drop if mi(child_bf)
		
		drop 	_index _parent_table_name _submission__id _submission__uuid ///
				_submission__submission_time _submission__validation_status ///
				_submission__notes _submission__status _submission__submitted_by ///
				_submission__tags
				
		order _parent_index

		destring child_id_iycf, replace

		** Labeling 
		* apply WB codebook command 
		//iecodebook template using "$raw/endline/codebook/codebook_grp_q2_5_to_q2_7.xlsx", replace 
		iecodebook apply using "$raw/endline/codebook/codebook_grp_q2_5_to_q2_7.xlsx"

		rename * *_
		rename child_id_iycf_ child_id_iycf

		reshape wide *_ , i(_parent_index) j(child_id_iycf)

		tempfile iycf
		save `iycf', replace 

	restore

	merge 1:1 _parent_index using `iycf'

	drop if _merge == 2

	drop _merge 



	** add child health info
	preserve
	
		use "$dta/endline/child_vc_rep.dta", clear
		
		//do "$hhimport/child_health_labeling.do"
		
		// drop obs not eligable for this module 
		drop if mi(child_ill)

		drop 	_index _parent_table_name _submission__id _submission__uuid ///
				_submission__submission_time _submission__validation_status ///
				_submission__notes _submission__status _submission__submitted_by ///
				_submission__tags
				
		order _parent_index

		destring child_id_health, replace

		** Labeling 
		* apply WB codebook command 
		//iecodebook template using "$raw/endline/codebook/codebook_child_vc_rep.xlsx", replace 
		iecodebook apply using "$raw/endline/codebook/codebook_child_vc_rep.xlsx"

		rename * *_
		rename child_id_health_ child_id_health

		reshape wide *_ , i(_parent_index) j(child_id_health)

		tempfile child_vc_rep
		save `child_vc_rep', replace 

	restore

	merge 1:1 _parent_index using `child_vc_rep'

	drop if _merge == 2

	drop _merge 


	** add mom health info
	preserve
	
		use "$dta/endline/anc_rep.dta", clear
		
		* lab var
		// do "$hhimport/mom_health_labeling.do"	
		
		// drop obs not eligable for this module 
		drop if mi(mom_rice) & mi(anc_adopt)

		drop 	_index _parent_table_name _submission__id _submission__uuid ///
				_submission__submission_time _submission__validation_status ///
				_submission__notes _submission__status _submission__submitted_by ///
				_submission__tags
				
		order _parent_index

		destring women_id_pregpast, replace

		** Labeling 
		* apply WB codebook command 
		//iecodebook template using "$raw/endline/codebook/codebook_anc_rep.xlsx", replace 
		iecodebook apply using "$raw/endline/codebook/codebook_anc_rep.xlsx"

		rename * *_
		rename women_id_pregpast_ women_id_pregpast

		reshape wide *_ , i(_parent_index) j(women_id_pregpast)

		tempfile anc_rep
		save `anc_rep', replace 

	restore

	merge 1:1 _parent_index using `anc_rep'

	drop if _merge == 2

	drop _merge 


	** add mom covid info
	preserve
	
		use "$dta/endline/mom_covid_rpt.dta", clear
		
		* lab var 
		lab var mom_covid_note "Covid-19 vaccine - dosage - ${cal_mom_covid} time"
		lab var mom_covid_know "Do you remember the ${cal_mom_covid} time vaccination date? "
		lab var mom_covid_year "If yes, when did you  (${respd_name}) get Covid-19 vaccination?"


		drop 	_index _parent_table_name _submission__id _submission__uuid ///
				_submission__submission_time _submission__validation_status ///
				_submission__notes _submission__status _submission__submitted_by ///
				_submission__tags
				
		order _parent_index

		destring cal_mom_covid, replace

		rename * *_
		rename cal_mom_covid_ cal_mom_covid

		reshape wide *_ , i(_parent_index) j(cal_mom_covid)

		tempfile mom_covid_rpt
		save `mom_covid_rpt', replace 

	restore

	merge 1:1 _parent_index using `mom_covid_rpt'

	drop if _merge == 2

	drop _merge 


	** add child muac info
	preserve
	
		use "$dta/endline/child_muac_rep.dta", clear
		
		* lab var 
		lab var child_muac_yn "Did you able to measure the child's MUAC for ${child_pos4}?"
		lab var child_muac "${child_pos4} MUAC"

		
		// drop obs not eligable for this module 
		drop if mi(child_muac_yn) 

		drop 	_index _parent_table_name _submission__id _submission__uuid ///
				_submission__submission_time _submission__validation_status ///
				_submission__notes _submission__status _submission__submitted_by ///
				_submission__tags
				
		order _parent_index

		destring child_id_muac, replace

		rename * *_
		rename child_id_muac_ child_id_muac

		reshape wide *_ , i(_parent_index) j(child_id_muac)

		tempfile child_muac_rep
		save `child_muac_rep', replace 

	restore

	merge 1:1 _parent_index using `child_muac_rep'

	drop if _merge == 2

	drop _merge 


	save "$dta/endline/pnourish_endline_hh_svy_wide.dta", replace  


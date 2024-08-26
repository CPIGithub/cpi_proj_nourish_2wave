/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	Endline data collection: high level cleaning			
Author				:	Nicholus Tint Zaw
Date				: 	06/13/2024
Modified by			:


	* performed cleaning based on HFC check feedback from field team
	https://docs.google.com/spreadsheets/d/1YuHHm9ZskSGUyobXc2N3k7fX_P4rl4qx/edit?usp=sharing&ouid=107390888012533162614&rtpof=true&sd=true

*******************************************************************************/

	********************************************************************************
	** Directory Settings **
	********************************************************************************

	do "$do/00_dir_setting.do"

	********************************************************************************
	* household survey *
	********************************************************************************

	use "$dta/endline/PN_HH_Survey_Endline_FINAL.dta", clear 

	keep if will_participate == 1

	
	* village name correction * 
	replace cal_vill = "Htoke Kaw Koe" if cal_vill == "Na Bu Taung Nar" | cal_vill == "Thuu Kaw"
	replace geo_vill =  2307 if cal_vill == "Htoke Kaw Koe"
	
	replace svy_visit_num =  1 if cal_vill == "Maw Poe Kloe"
	
	replace cal_vill = "Maung Taing Ka Lay/Maw Thay Del" if cal_vill == "Kaw Tu Toe" & enu_name == "Saw Zaw Min Oo"
	replace cal_vill = "Maung Taing Ka Lay/Maw Thay Del" if cal_vill == "Kaw Tu Toe" & enu_name == "Saw Bwe Tha Yu"
	replace geo_vill =  2149 if cal_vill == "Maung Taing Ka Lay/Maw Thay Del"
	
	replace cal_vill = "May Daw Khoe" if uuid == "1231f1d7-b7d3-476a-abb8-c6b10e8a57fa"
	replace geo_vill = 2147 if uuid == "1231f1d7-b7d3-476a-abb8-c6b10e8a57fa"
	
	replace cal_vill = "Zin Bon/Saw Mu Del" if uuid == "1cda64ee-e7a7-422d-9f50-983f028f8ecb"
	replace geo_vill = 2176 if uuid == "1cda64ee-e7a7-422d-9f50-983f028f8ecb"	
	
	
	replace cal_vill = "Htee Wah Klu" if 	uuid == "9bf3116d-b069-4907-b26b-7c5ee7fbe5bc" | ///
											uuid == "3cb57239-561a-411e-b0ec-7e29f11f35e4" | ///
											uuid == "f9a767e8-18cc-4753-8199-ad2abd12b88f" | ///
											uuid == "3655b644-c390-4101-86f4-0708a60db1d5" | ///
											uuid == "64090cda-7aaa-473d-8cb3-1fa8c6cd2818"
	

	replace geo_vill = 2366 if 	uuid == "9bf3116d-b069-4907-b26b-7c5ee7fbe5bc" | ///
								uuid == "3cb57239-561a-411e-b0ec-7e29f11f35e4" | ///
								uuid == "f9a767e8-18cc-4753-8199-ad2abd12b88f" | ///
								uuid == "3655b644-c390-4101-86f4-0708a60db1d5" | ///
								uuid == "64090cda-7aaa-473d-8cb3-1fa8c6cd2818"
	
	
	* respd_who 
	lab def respd_who 1"Mother (Herself)" 0"Miain Caregiver"
	lab val respd_who respd_who
	tab respd_who, m 
	
	
	** reconstruct the respondent ID 
	tostring cal_respid respd_id, replace 
	replace respd_id = cal_respid
	
	preserve 
	
	keep org_name stratum geo_town geo_vt geo_vill interv_name quest_num uuid respd_id
	
	destring quest_num, replace
	bysort org_name stratum geo_town geo_vt geo_vill interv_name: replace quest_num = _n
	
	gen interv_name_num = interv_name
	tostring geo_town geo_vt geo_vill interv_name_num quest_num, replace 
	
	replace respd_id = geo_town + "_" + geo_vt + "_" + geo_vill + "_" + interv_name_num + "_" + quest_num
	
	distinct respd_id
	
	keep respd_id uuid
	
	tempfile respd_id
	save `respd_id', replace 
	
	restore 
	
	drop respd_id
	
	merge 1:1 uuid using `respd_id'
	
	order respd_id, after(cal_respid)
	drop cal_respid _merge 

	replace cal_vill = "Mi Tan Kyaung Ah Tat" if respd_id == "MMR003007_1102_2420_12_1"
	// replace geo_eho_vill_name = "Mi Tan Kyaung Ah Tat" if respd_id == "MMR003007_1102_2420_12_1"
	replace geo_vill = 2419 if respd_id == "MMR003007_1102_2420_12_1"
	
	
	replace geo_eho_vill_name = cal_vill // data cleaning done with this name
	

	* save as cleaned dataset 
	save "$dta/endline/PN_HH_Survey_Endline_FINAL_Cleaned.dta", replace  

	
	// END HERE 




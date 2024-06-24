/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	Endline data collection: missing check 			
Author				:	Nicholus Tint Zaw
Date				: 	06/13/2024
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

********************************************************************************
* household survey *
********************************************************************************
	
		
use "$dta/endline/pnourish_endline_hh_svy_wide.dta", clear 

// rename for long var 
rename hh_mem_certification_* hh_mem_dob_certify_*
rename child_diarrh_notreat_* c_diarrh_notreat_*
rename child_cough_notreat_* c_cough_notreat_*
rename child_fever_notreat_* c_fever_notreat_*
rename water_*_treatmethod_oth water_*_tm_oth
rename water_winter_treatmethod w_winter_treatmethod

// setting looping group vars 
global	resp_info			will_participate respd_who ///
							respd_name respd_sex respd_age respd_status respd_preg ///
							respd_child respd_1stpreg_age respd_chid_num respd_phone respd_phonnum 
							
global 	hhroster			hh_tot_num ///
							hh_mem_name* hh_mem_sex* hh_mem_age* /*hh_mem_dob_know**/ hh_mem_dob* /*hh_mem_dob_certify_**/ ///
							hh_mem_head* hh_mem_marital* hh_mem_relation* hh_mem_pregnow* hh_mem_caregiver* ///
							hh_mem_u5num* hh_mem_u2num* hh_mem_old_child* hh_mem_single_child* ///
							hh_mem_highedu* hh_mem_occup_1 hh_mem_occup_2 hh_mem_occup_3 hh_mem_occup_4 ///
							hh_mem_occup_5 hh_mem_occup_6 hh_mem_occup_7 hh_mem_occup_8 hh_mem_occup_9 ///
							hh_mem_occup_10 hh_mem_occup_11 hh_mem_occup_12 /*hh_mem_highedu_oth* hh_mem_occup_oth**/ hh_mem_present* ///
							hh_mem_mom* 
							
global ciycf				child_bf* child_eibf* /*child_eibf_hrs* child_eibf_days**/ ///
							chhild_addbf* /*chhild_addbf_oth*/ /*child_bfyest*/ ///
							child_water* child_bms* /*child_bms_freq*/ child_milk* /*child_milk_freq*/ ///
							child_mproduct* /*child_mproduct_freq*/ child_juice* child_tea* ///
							child_energyd* child_broth* child_porridge* child_liquid* /*child_liquid_oth*/ ///
							child_rice* child_potatoes* child_pumpkin* child_beans* child_leafyveg* ///
							child_mango* child_fruit* child_organ* child_beef* child_fish* ///
							child_insects* child_eggs* child_yogurt* child_cheese* child_fat* ///
							child_plam* child_sweets* child_condiments* ///
							/*child_yogurt_num*/ child_othfood* child_food_freq* child_fortified* ///
							child_sprinkles* child_supplement* child_ironformula* child_bottle* 
		
							
global cill					child_ill* /*child_ill_oth*/ ///
							child_diarrh_treat* /*c_diarrh_notreat_1*/ c_diarrh_notreat_2 c_diarrh_notreat_3 ///
							c_diarrh_notreat_4 c_diarrh_notreat_5 c_diarrh_notreat_6 c_diarrh_notreat_7 ///
							c_diarrh_notreat_8 c_diarrh_notreat_9 c_diarrh_notreat_10 /*c_diarrh_notreat_11*/ ///
							c_diarrh_notreat_12 /*child_diarrh_notreat_oth*/ ///
							child_diarrh_notice* ///
							/*child_diarrh_where_1*/ child_diarrh_where_2 child_diarrh_where_3 ///
							child_diarrh_where_4 child_diarrh_where_5 child_diarrh_where_6 ///
							child_diarrh_where_7 child_diarrh_where_8 child_diarrh_where_9 ///
							child_diarrh_where_10 /*child_diarrh_where_11*/ child_diarrh_where_12* /*child_diarrh_where_oth*/ ///
							/*child_diarrh_who_1*/ child_diarrh_who_2 child_diarrh_who_3 child_diarrh_who_4 ///
							child_diarrh_who_5 child_diarrh_who_6 child_diarrh_who_7 child_diarrh_who_8 ///
							child_diarrh_who_9 child_diarrh_who_10 /*child_diarrh_who_11*/ child_diarrh_who_12 /*child_diarrh_who_oth*/ ///
							child_diarrh_pay* /*child_diarrh_cope_1*/ child_diarrh_cope_2 child_diarrh_cope_3 ///
							child_diarrh_cope_4 child_diarrh_cope_5 child_diarrh_cope_6 child_diarrh_cope_7 ///
							child_diarrh_cope_8 child_diarrh_cope_9 child_diarrh_cope_10 /*child_diarrh_cope_11*/ ///
							child_diarrh_cope_12 /*child_diarrh_cope_oth*/ ///
							child_cough_rapbth* child_cough_diffbth* child_cough_treat* ///
							c_cough_notreat_* /*child_cough_notreat_oth*/ ///
							child_cough_notice* /*child_cough_where_1*/ child_cough_where_2 ///
							child_cough_where_3 child_cough_where_4 child_cough_where_5 ///
							child_cough_where_6 child_cough_where_7 child_cough_where_8 ///
							child_cough_where_9 child_cough_where_10 /*child_cough_where_11*/ ///
							child_cough_where_12 /*child_cough_where_oth*/ ///
							/*child_cough_who_1*/ child_cough_who_2 child_cough_who_3 child_cough_who_4 ///
							child_cough_who_5 child_cough_who_6 child_cough_who_7 child_cough_who_8 ///
							child_cough_who_9 child_cough_who_10 /*child_cough_who_11*/ child_cough_who_12 /*child_cough_who_oth*/ ///
							child_cough_pay* /*child_cough_cope_1*/ child_cough_cope_2 child_cough_cope_3 ///
							child_cough_cope_4 child_cough_cope_5 child_cough_cope_6 child_cough_cope_7 ///
							child_cough_cope_8 child_cough_cope_9 child_cough_cope_10 /*child_cough_cope_11*/ ///
							child_cough_cope_12 /*child_cough_cope_oth*/ ///
							child_fever_treat* c_fever_notreat_* /*child_fever_notreat_oth*/ ///
							child_fever_notice* /*child_fever_where_1*/ child_fever_where_2 child_fever_where_3 ///
							child_fever_where_4 child_fever_where_5 child_fever_where_6 child_fever_where_7 ///
							child_fever_where_8 child_fever_where_9 child_fever_where_10 /*child_fever_where_11*/ ///
							child_fever_where_12 /*child_fever_where_oth*/ ///
							child_fever_who* /*child_fever_who_oth*/ ///
							child_fever_pay* /*child_fever_cope_1*/ child_fever_cope_2 child_fever_cope_3 ///
							child_fever_cope_4 child_fever_cope_5 child_fever_cope_6 child_fever_cope_7 ///
							child_fever_cope_8 child_fever_cope_9 child_fever_cope_10 /*child_fever_cope_11*/ ///
							child_fever_cope_12 /*child_fever_cope_oth*/ child_fever_malaria* ///
							child_vaccin* /*child_vaccin_card*/ ///
							child_birthwt* /*child_birthwt_unit*/ ///
							/*child_birthwt_kg child_birthwt_lb* child_birthwt_oz*/ ///
							/*child_birthwt_doc*/ ///
							child_vita* child_deworm* 
							
							
global momdiet				mom_rice* mom_potatoes* mom_beans* mom_nuts* mom_yogurt* ///
							mom_organ* mom_beef* mom_fish* mom_eggs* mom_leafyveg* mom_pumpkin* ///
							mom_mango* mom_veg* mom_fruit* mom_fat* mom_sweets* mom_condiments* mom_meal_freq* 
							
							
global momanc 				anc_adopt* anc_yn* anc_where_* /*anc_where_2 anc_where_3 anc_where_4*/ ///
							/*anc_where_5 anc_where_6 anc_where_7 anc_where_8 anc_where_9 anc_where_10*/ ///
							/*anc_where_11 anc_where_12*/ /*anc_where_oth*/ ///
							anc_home_who_* /*anc_home_who_2 anc_home_who_3 anc_home_who_4 anc_home_who_5*/ ///
							/*anc_home_who_6 anc_home_who_7 anc_home_who_8 anc_home_who_9 anc_home_who_10*/ ///
							/*anc_home_who_11 anc_home_who_12*/ /*anc_home_who_oth*/ anc_home_visit* ///
							anc_hosp_who_* /*anc_hosp_who_2 anc_hosp_who_3 anc_hosp_who_4 anc_hosp_who_5*/ ///
							/*anc_hosp_who_6 anc_hosp_who_7 anc_hosp_who_8 anc_hosp_who_9 anc_hosp_who_10*/ ///
							/*anc_hosp_who_11 anc_hosp_who_12*/ /*anc_hosp_who_oth*/ ///
							anc_hosp_dist_dry* anc_hosp_dist_wet* anc_hosp_visit* ///
							anc_pc_who* /*anc_pc_oth*/ anc_pc_dist_dry* anc_pc_dist_wet* anc_pc_visit* ///
							anc_rhc_who_* /*anc_rhc_who_2 anc_rhc_who_3 anc_rhc_who_4 anc_rhc_who_5*/ ///
							/*anc_rhc_who_6 anc_rhc_who_7 anc_rhc_who_8 anc_rhc_who_9 anc_rhc_who_10*/ ///
							/*anc_rhc_who_11 anc_rhc_who_12*/ /*anc_rhc_who_oth*/ anc_rhc_dist_dry* anc_rhc_dist_wet* anc_rhc_visit* ///
							anc_ehoc_who_* /*anc_ehoc_who_2 anc_ehoc_who_3 anc_ehoc_who_4 anc_ehoc_who_5*/ ///
							/*anc_ehoc_who_6 anc_ehoc_who_7 anc_ehoc_who_8 anc_ehoc_who_9 anc_ehoc_who_10*/ ///
							/*anc_ehoc_who_11 anc_ehoc_who_12*/ /*anc_ehoc_who_oth*/ anc_ehoc_dist_dry* anc_ehoc_dist_wet* anc_ehoc_visit* ///
							anc_ehom_who* /*anc_ehom_oth*/ anc_ehom_dist_dry* anc_ehom_dist_wet* anc_ehom_visit* ///
							anc_vill_who_* /*anc_vill_who_2 anc_vill_who_3 anc_vill_who_4 anc_vill_who_5*/ ///
							/*anc_vill_who_6 anc_vill_who_7 anc_vill_who_8 anc_vill_who_9 anc_vill_who_10*/ ///
							/*anc_vill_who_11 anc_vill_who_12 anc_vill_who_oth*/ anc_vill_dist_dry* anc_vill_dist_wet* anc_vill_visit* ///
							anc_othp_who_* /*anc_othp_who_2 anc_othp_who_3 anc_othp_who_4 anc_othp_who_5*/ ///
							/*anc_othp_who_6 anc_othp_who_7 anc_othp_who_8 anc_othp_who_9 anc_othp_who_10*/ ///
							/*anc_othp_who_11 anc_othp_who_12*/ /*anc_othp_who_oth*/ anc_othp_dist_dry* anc_othp_dist_wet* anc_othp_visit* ///
							anc_bf_counselling* anc_nut_counselling* ///
							anc_cost* anc_cope_* /*anc_cope_2 anc_cope_3 anc_cope_4 anc_cope_5*/ ///
							/*anc_cope_6 anc_cope_7 anc_cope_8 anc_cope_9 anc_cope_10 anc_cope_11 anc_cope_12*/ /*anc_cope_oth*/ ///
							anc_noreason_* /*anc_noreason_2 anc_noreason_3 anc_noreason_4 anc_noreason_5*/ ///
							/*anc_noreason_6 anc_noreason_7 anc_noreason_8 anc_noreason_9 anc_noreason_10*/ ///
							/*anc_noreason_11 anc_noreason_12*/ /*anc_noreason_oth*/ ///
							anc_restrict_1 anc_restrict_2 anc_restrict_3 anc_restrict_4 ///
							/*anc_restrict_5 anc_restrict_6 anc_restrict_7 anc_restrict_8*/ ///
							/*anc_restrict_9 anc_restrict_10 anc_restrict_11 anc_restrict_12*/ ///
							anc_restrict_item_1 anc_restrict_item_2 anc_restrict_item_3 anc_restrict_item_4 ///
							/*anc_restrict_item_5 anc_restrict_item_6 anc_restrict_item_7 anc_restrict_item_8*/ ///
							/*anc_restrict_item_9 anc_restrict_item_10 anc_restrict_item_11 anc_restrict_item_12*/ ///
							/*anc_restrict_item anc_restrict_item_oth anc_restrict_why anc_restrict_why_oth*/ ///
							anc_restrict_why_1 anc_restrict_why_2 anc_restrict_why_3 anc_restrict_why_4 ///
							/*anc_restrict_why_5 anc_restrict_why_6 anc_restrict_why_7 anc_restrict_why_8*/ ///
							/*anc_restrict_why_9 anc_restrict_why_10 anc_restrict_why_11 anc_restrict_why_12*/ ///
							anc_bone* anc_rion_1 anc_rion_2 anc_rion_3 anc_rion_4 ///
							/*anc_rion_5 anc_rion_6 anc_rion_7 anc_rion_8 anc_rion_9 anc_rion_10 anc_rion_11 anc_rion_12*/ ///
							anc_iron_freq_1 anc_iron_freq_2 anc_iron_freq_3 anc_iron_freq_4 ///
							/*anc_iron_freq_5 anc_iron_freq_6 anc_iron_freq_7 anc_iron_freq_8 anc_iron_freq_9 anc_iron_freq_10*/ ///
							/*anc_iron_freq_11 anc_iron_freq_12*/ ///
							anc_iron_count_* anc_rion_length_1 anc_rion_length_2 anc_rion_length_3 anc_rion_length_4 ///
							/*anc_rion_length_5 anc_rion_length_6 anc_rion_length_7 anc_rion_length_8 anc_rion_length_9*/ ///
							/*anc_rion_length_10 anc_rion_length_11 anc_rion_length_12*/ ///
							anc_iron_cost_* anc_iron_source_1 anc_iron_source_2 anc_iron_source_3 anc_iron_source_4 
							/*anc_iron_source_5 anc_iron_source_6 anc_iron_source_7 anc_iron_source_8 anc_iron_source_9*/ ///
							/*anc_iron_source_10 anc_iron_source_11 anc_iron_source_12*/
							/*anc_iron_freq anc_iron_count anc_rion_length anc_rion_length_oth anc_iron_cost anc_iron_source anc_iron_source_oth*/ 
							
							
global momdeli 				deliv_place* /*deliv_place_oth*/ deliv_assist* /*deliv_assist_oth*/ ///
							child_hepatitisb* deliv_cost* deliv_cope* /*deliv_cope_oth*/ 

global mompnc				pnc_yn* pnc_checktime* pnc_checkunit* ///
							pnc_where_* /*pnc_where_2 pnc_where_3 pnc_where_4 pnc_where_5*/ ///
							/*pnc_where_6 pnc_where_7 pnc_where_8 pnc_where_9 pnc_where_10*/ ///
							/*pnc_where_11 pnc_where_12*/ /*pnc_where_oth*/ ///
							pnc_home_who* /*pnc_home_oth*/ pnc_home_visit* ///
							pnc_hosp_who_* /*pnc_hosp_who_2 pnc_hosp_who_3 pnc_hosp_who_4*/ ///
							/*pnc_hosp_who_5 pnc_hosp_who_6 pnc_hosp_who_7 pnc_hosp_who_8*/ ///
							/*pnc_hosp_who_9 pnc_hosp_who_10 pnc_hosp_who_11 pnc_hosp_who_12*/ /*pnc_hosp_who_oth*/ ///
							pnc_hosp_visit* ///
							pnc_pc_who* /*pnc_pc_oth*/ pnc_pc_visit* ///
							pnc_rhc_who_* /*pnc_rhc_who_2 pnc_rhc_who_3 pnc_rhc_who_4 pnc_rhc_who_5*/ ///
							/*pnc_rhc_who_6 pnc_rhc_who_7 pnc_rhc_who_8 pnc_rhc_who_9 pnc_rhc_who_10*/ ///
							/*pnc_rhc_who_11 pnc_rhc_who_12*/ /*pnc_rhc_who_oth*/ pnc_rhc_visit* ///
							pnc_ehoc_who_* /*pnc_ehoc_who_2 pnc_ehoc_who_3 pnc_ehoc_who_4*/ ///
							/*pnc_ehoc_who_5 pnc_ehoc_who_6 pnc_ehoc_who_7 pnc_ehoc_who_8*/ ///
							/*pnc_ehoc_who_9 pnc_ehoc_who_10 pnc_ehoc_who_11 pnc_ehoc_who_12*/ /*pnc_ehoc_who_oth*/ ///
							pnc_ehoc_visit* ///
							pnc_ehom_who* pnc_ehom_oth* pnc_ehom_visit* ///
							pnc_vill_who_* /*pnc_vill_who_2 pnc_vill_who_3 pnc_vill_who_4*/ ///
							/*pnc_vill_who_5 pnc_vill_who_6 pnc_vill_who_7 pnc_vill_who_8*/ ///
							/*pnc_vill_who_9 pnc_vill_who_10 pnc_vill_who_11 pnc_vill_who_12*/ /*pnc_vill_who_oth*/ ///
							pnc_vill_visit* ///
							pnc_othp_who_* /*pnc_othp_who_2 pnc_othp_who_3 pnc_othp_who_4*/ ///
							/*pnc_othp_who_5 pnc_othp_who_6 pnc_othp_who_7 pnc_othp_who_8*/ ///
							/*pnc_othp_who_9 pnc_othp_who_10 pnc_othp_who_11 pnc_othp_who_12*/ /*pnc_othp_who_oth*/ ///
							pnc_othp_visit* ///
							pnc_bone_1 pnc_bone_2 pnc_bone_3 pnc_bone_4 /*pnc_bone_5*/ ///
							/*pnc_bone_6 pnc_bone_7 pnc_bone_8 pnc_bone_9 pnc_bone_10*/ ///
							/*pnc_bone_11 pnc_bone_12*/ ///
							pnc_bone_months_1 pnc_bone_months_2 pnc_bone_months_3 ///
							/*pnc_bone_months_4 pnc_bone_months_5 pnc_bone_months_6*/ ///
							/*pnc_bone_months_7 pnc_bone_months_8 pnc_bone_months_9*/ ///
							/*pnc_bone_months_10 pnc_bone_months_11 pnc_bone_months_12*/ ///
							pnc_bone_weeks_1 pnc_bone_weeks_2 pnc_bone_weeks_3 ///
							/*pnc_bone_weeks_4 pnc_bone_weeks_5 pnc_bone_weeks_6*/ ///
							/*pnc_bone_weeks_7 pnc_bone_weeks_8 pnc_bone_weeks_9*/ ///
							/*pnc_bone_weeks_10 pnc_bone_weeks_11 pnc_bone_weeks_12*/ ///
							pnc_cost* pnc_cope_1 pnc_cope_2 pnc_cope_3 pnc_cope_4 
							/*pnc_cope_5 pnc_cope_6 pnc_cope_7 pnc_cope_8 pnc_cope_9*/ 
							/*pnc_cope_10 pnc_cope_11 pnc_cope_12 pnc_cope_oth*/ 



global momnbc				nbc_yn* nbc_2days_yn* nbc_where_* /*nbc_where_2 nbc_where_3*/ ///
							/*nbc_where_4 nbc_where_5 nbc_where_6 nbc_where_7 nbc_where_8*/ ///
							/*nbc_where_9 nbc_where_10 nbc_where_11 nbc_where_12*/ /*nbc_where_oth*/ ///
							nbc_home_who_* /*nbc_home_oth*/ nbc_home_visit* ///
							nbc_hosp_who_* /*nbc_hosp_who_2 nbc_hosp_who_3 nbc_hosp_who_4 nbc_hosp_who_5*/ ///
							/*nbc_hosp_who_6 nbc_hosp_who_7 nbc_hosp_who_8 nbc_hosp_who_9 nbc_hosp_who_10*/ ///
							/*nbc_hosp_who_11 nbc_hosp_who_12*/ /*nbc_hosp_who_oth*/ nbc_hosp_visit* ///
							nbc_pc_who* nbc_pc_oth* nbc_pc_visit* ///
							nbc_rhc_who_* /*nbc_rhc_who_2 nbc_rhc_who_3 nbc_rhc_who_4 nbc_rhc_who_5*/ ///
							/*nbc_rhc_who_6 nbc_rhc_who_7 nbc_rhc_who_8 nbc_rhc_who_9 nbc_rhc_who_10*/ ///
							/*nbc_rhc_who_11 nbc_rhc_who_12*/ /*nbc_rhc_who_oth*/ nbc_rhc_visit* ///
							nbc_ehoc_who_* /*nbc_ehoc_who_2 nbc_ehoc_who_3 nbc_ehoc_who_4 nbc_ehoc_who_5*/ ///
							/*nbc_ehoc_who_6 nbc_ehoc_who_7 nbc_ehoc_who_8 nbc_ehoc_who_9 nbc_ehoc_who_10*/ ///
							/*nbc_ehoc_who_11 nbc_ehoc_who_12*/ /*nbc_ehoc_who_oth*/ nbc_ehoc_visit* ///
							nbc_ehom_who_* /*nbc_ehom_oth*/ nbc_ehom_visit* ///
							nbc_vill_who_* /*nbc_vill_who_2 nbc_vill_who_3 nbc_vill_who_4 nbc_vill_who_5*/ ///
							/*nbc_vill_who_6 nbc_vill_who_7 nbc_vill_who_8 nbc_vill_who_9 nbc_vill_who_10*/ ///
							/*nbc_vill_who_11 nbc_vill_who_12*/ /*nbc_vill_who_oth*/ nbc_vill_visit* ///
							nbc_othp_who_* /*nbc_othp_who_2 nbc_othp_who_3 nbc_othp_who_4*/ ///
							/*nbc_othp_who_5 nbc_othp_who_6 nbc_othp_who_7 nbc_othp_who_8*/ ///
							/*nbc_othp_who_9 nbc_othp_who_10 nbc_othp_who_11 nbc_othp_who_12*/ /*nbc_othp_who_oth*/ ///
							nbc_othp_visit* ///
							nbc_cost* nbc_cope_* /*nbc_cope_2 nbc_cope_3 nbc_cope_4 nbc_cope_5*/ 
							/*nbc_cope_6 nbc_cope_7 nbc_cope_8 nbc_cope_9 nbc_cope_10 nbc_cope_11*/ 
							/*nbc_cope_12 nbc_cope_oth*/  


global momcovid 			mom_covid mom_covid_doses mom_covid_know* mom_covid_year* 


global hhcharacter			house_roof house_roof_oth house_wall house_wall_oth house_floor house_floor_oth ///
							house_room house_light house_light_oth house_electric house_electric_check ///
							house_electric_perday house_electric_source /*house_electric_perday_oth house_electric_oth*/ ///
							house_cooking house_cooking_oth house_elecook_note1 ///
							hhitems_tv hhitems_phone hhitems_refrigerator hhitems_table ///
							hhitems_chair hhitems_bed hhitems_cupboard hhitems_fan ///
							hhitems_computer hhitems_watch hhitems_bankacc

global wempower 			wempo_childcare wempo_mom_health wempo_child_health ///
							wempo_women_wages wempo_major_purchase wempo_visiting ///
							wempo_women_health wempo_child_wellbeing wempo_group

global mentalh				phq9_1 phq9_2 phq9_3 phq9_4 phq9_5 ///
							phq9_6 phq9_7 phq9_8 phq9_9


global wash 				water_sum water_time water_sum_treat water_sum_treatmethod /*water_sum_oth water_sum_tm_oth*/ ///
							water_rain water_time_rain water_rain_treat water_rain_treatmethod /*water_rain_oth water_rain_tm_oth*/ ///
							water_winter water_time_winter water_winter_treat w_winter_treatmethod /*water_winter_oth water_winter_tm_oth*/ ///
							waterpot_yn waterpot_capacity waterpot_condition ///
							latrine_type  latrine_type_oth latrine_share latrine_observe ///
							soap_yn soap_why soap_why_oth ///
							soap_tiolet soap_before_eat soap_after_eat soap_handle_child ///
							soap_before_cook soap_feed_child soap_clean_baby soap_child_faeces ///
							observ_washplace observ_water soap_present observ_washplace_oth


global hhincome 			d0_per_std d3_inc_lmth d4_inc_status d5_reason /*d5_reason_oth*/ d6_cope /*d6_cope_oth*/ ///
							jan_incom_status thistime_incom_status d7_inc_govngo d7_inc_govngo_nm /*d7_inc_govngo_nm_oth*/ ///
							health_visit health_exp health_exp_cope /*health_exp_cope_oth*/

global fies 				gfi1_notegh gfi2_unhnut gfi3_fewfd gfi4_skp_ml gfi5_less ///
							gfi6_rout_fd gfi7_hunger gfi8_wout_eat

global progexp 				prgexpo_pn prgexpo_join prgexpo_join_oth ///
							prgexp_freq_* prgexp_monthly_* ///
							prgexp_why_1 prgexp_why_2 prgexp_why_3 prgexp_why_4 prgexp_why_5 ///
							prgexp_why_6 prgexp_why_7 prgexp_why_8 prgexp_why_9 /*prgexp_why_oth_*/ prgexp_iec

global cmuac 				/*child_muac_yn**/ child_muac_* 

global svynote 				svy_visit_num svy_interview_mode enu_svyend_note

						
							
// missing per variables 
	gen sir = _n 
	gen tot_obs 		= _N
	bysort svy_team enu_name: gen enu_tot_obs		= _N 



local 	loopgrp 	resp_info hhroster ciycf cill momdiet ///
					momanc momdeli mompnc momnbc momcovid ///
					hhcharacter wempower mentalh wash hhincome ///
					fies cmuac progexp svynote
	
foreach grp in `loopgrp' {
    
	foreach var of varlist $`grp' {
		
		gen `var'_m 		= mi(`var')
		
		egen `var'_m_t 		= total(`var'_m)
		gen `var'_m_shared 	= round(`var'_m_t / tot_obs, 0.001)
		
		gen `var'_nomiss	= !mi(`var')
		egen `var'_nomiss_t	= total(`var'_nomiss)
		gen `var'_s_m		= (`var'_nomiss_t == 0)
		
		
		// gen `var'_nomiss = (`var'_m_t != _N)
		
		bysort svy_team superv_name enu_name: egen `var'_em 		= total(`var'_m)
		bysort svy_team superv_name enu_name: gen `var'_em_shared 	= round(`var'_em / enu_tot_obs, 0.001)
		
		tab `var'_m_t

	}
	
	
	preserve 
	
		*Adding title table 1
		clear
		set obs 1
		gen title = ""
		replace title = "TABLE 1: %MISSING BY VARIABLE" in 1
		export excel title using "$out/endline/02_hfc_hh_missing.xlsx", sheet("`grp'") sheetreplace cell(A1) 

		*Adding title table 2
		clear
		set obs 1
		gen title = ""
		replace title = "TABLE 2: MISSING VARIABLE BY ENUMERATOR" in 1
		export excel title using "$out/endline/02_hfc_hh_missing.xlsx", sheet("`grp'") sheetmodify cell(G1) 

		*Adding title table 3
		clear
		set obs 1
		gen title = ""
		replace title = "TABLE 3: MISSING VARIABLE SUMMAR BY ENUMERATOR" in 1
		export excel title using "$out/endline/02_hfc_hh_missing.xlsx", sheet("`grp'") sheetmodify cell(O1) 
		
		*Adding title table 1
		clear
		set obs 1
		gen title = ""
		replace title = "TABLE 1: AT LEAST ONE OBS MISSING BY VARIABLE" in 1
		export excel title using "$out/endline/02_hfc_hh_missing_varlist.xlsx", sheet("`grp'") sheetreplace cell(A1) 
		
	restore 


	// all variables 
	preserve
	keep if _n == 1

	keep sir *_m_t *_m_shared tot_obs

	rename *_m_t 		m_t_*
	rename *_m_shared	m_shared_*

	reshape long m_t_ m_shared_, i(sir) j(var) string 

	rename m_t_ 		missing_num 
	rename m_shared_	missing_shared

	replace sir = _n 

	// lab var 
	lab var var				"Variable Names"
	lab var sir 			"No."
	lab var missing_num		"Number of missing"
	lab var missing_shared 	"Shared missing number"
	lab var tot_obs			"Total survey"

	// export table
	
	if _N > 0 {
	    
		export excel using 	"$out/endline/02_hfc_hh_missing.xlsx", ///
							sheet("`grp'") cell(A2) firstrow(varlabels) keepcellfmt sheetmodify
		
	}

	restore 

	// at least one obs missing 
	preserve
	keep if _n == 1

	keep sir *_s_m

	rename *_s_m 		s_m_*

	reshape long s_m_, i(sir) j(var) string 
	
	keep if s_m_ == 1

	replace sir = _n 

	// lab var 
	lab var var				"Variable Names"
	lab var sir 			"No."
	lab var s_m_			"at least one obs has missing value"


	// export table
	
	if _N > 0 {
	    
		export excel using 	"$out/endline/02_hfc_hh_missing_varlist.xlsx", ///
							sheet("`grp'") cell(A2) firstrow(varlabels) keepcellfmt sheetmodify
						
	}

	restore 
	
	
	
	// variables per enumerator 
	preserve
	//bysort svy_team superv_name enu_name: keep if _n == 1

	keep sir *_m svy_team superv_name enu_name 

	//drop cla_* calc_* cal_* svy_team_* enu_name_*

	rename *_m m_*

	//drop *note*

	reshape long m_, i(sir) j(var) string 

	keep if m_ == 1
	
	if _N > 0 {
		
		drop m_ 

		replace sir = _n 

		// lab var 
		lab var var				"Variable Names"
		lab var sir 			"No."
		lab var svy_team 		"Survey Teams"
		lab var superv_name 	"Supervisor Names"
		lab var enu_name		"Enumerator Names"


		// export table
		if _N > 0 {
		    
			export excel using "$out/endline/02_hfc_hh_missing.xlsx", ///
							sheet("`grp'") cell(G2) firstrow(varlabels) keepcellfmt sheetmodify
			
		}
		
		
	}


	restore 


	// overall total  
	preserve

	// bysort svy_team enu_name: egen tot_missing = total(missing_num)
	bysort svy_team superv_name enu_name: keep if _n == 1

	keep sir enu_tot_obs *_em *_em_shared svy_team superv_name enu_name

	rename *_em 		em_*
	rename *_em_shared	em_shared_*

	reshape long em_ em_shared_, i(sir) j(var) string 

	replace sir = _n 
	keep if em_ > 0 
	
	if _N > 0 {
		
		// lab var 
		lab var var				"Variable Names"
		lab var sir 			"No."
		lab var svy_team 		"Survey Teams"
		lab var superv_name 	"Supervisor Names"
		lab var enu_name		"Enumerator Names"
		lab var em_				"Number of missing"
		lab var em_shared_ 		"Shared missing number"
		lab var enu_tot_obs		"Total survey"

		// export table
		if _N > 0 {
		    
			export excel using "$out/endline/02_hfc_hh_missing.xlsx", ///
								sheet("`grp'") cell(O2) firstrow(varlabels) keepcellfmt sheetmodify
			
		}
		
		
	}


	restore 
	
	drop *_m_t *_m_shared  *_m  *_em *_em_shared
	
	di "finished `grp'"
	
}


* END here 


 


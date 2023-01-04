/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: missing check 			
Author				:	Nicholus Tint Zaw
Date				: 	11/24/2022
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "00_dir_setting.do"

********************************************************************************
* household survey *
********************************************************************************

use "$dta/pnourish_hh_svy.dta", clear 

local	variables_interest	will_participate respd_who ///
							respd_name respd_sex respd_age respd_status respd_preg ///
							respd_child respd_1stpreg_age respd_chid_num respd_phone respd_phonnum ///
							hh_tot_num ///
							hh_mem_name* hh_mem_sex* hh_mem_age* hh_mem_dob_know* hh_mem_dob* hh_mem_certification* ///
							hh_mem_head* hh_mem_marital* hh_mem_relation* hh_mem_pregnow* hh_mem_caregiver* ///
							hh_mem_u5num* hh_mem_u2num* hh_mem_old_child* hh_mem_single_child* ///
							hh_mem_highedu* hh_mem_occup* hh_mem_highedu_oth* hh_mem_occup_oth* hh_mem_present* ///
							hh_mem_mom* ///
							child_bf* child_eibf* child_eibf_hrs* child_eibf_days* ///
							chhild_addbf* chhild_addbf_oth* child_bfyest* ///
							child_water child_bms child_bms_freq child_milk child_milk_freq ///
							child_mproduct child_mproduct_freq child_juice child_tea ///
							child_energyd child_broth child_porridge child_liquid child_liquid_oth ///
							child_rice child_potatoes child_pumpkin child_beans child_leafyveg ///
							child_mango child_fruit child_organ child_beef child_fish ///
							child_insects child_eggs child_yogurt child_cheese child_fat ///
							child_plam child_sweets child_condiments ///
							child_yogurt_num child_othfood child_food_freq child_fortified ///
							child_sprinkles child_supplement child_ironformula child_bottle ///
							child_ill child_ill_oth ///
							child_diarrh_treat child_diarrh_notreat child_diarrh_notreat_oth ///
							child_diarrh_notice ///
							child_diarrh_where child_diarrh_where_oth ///
							child_diarrh_who child_diarrh_who_oth ///
							child_diarrh_pay child_diarrh_cope child_diarrh_cope_oth ///
							child_cough_rapbth child_cough_diffbth child_cough_treat ///
							child_cough_notreat child_cough_notreat_oth ///
							child_cough_notice child_cough_where child_cough_where_oth ///
							child_cough_who child_cough_who_oth ///
							child_cough_pay child_cough_cope child_cough_cope_oth ///
							child_fever_treat child_fever_notreat child_fever_notreat_oth ///
							child_fever_notice child_fever_where child_fever_where_oth ///
							child_fever_who child_fever_who_oth ///
							child_fever_pay child_fever_cope child_fever_cope_oth child_fever_malaria ///
							child_vaccin child_vaccin_card ///
							child_birthwt child_birthwt_unit ///
							child_birthwt_kg child_birthwt_lb child_birthwt_oz ///
							child_birthwt_doc ///
							child_vita* child_deworm* ///
							mom_rice* mom_potatoes* mom_beans* mom_nuts* mom_yogurt* ///
							mom_organ mom_beef mom_fish mom_eggs mom_leafyveg mom_pumpkin ///
							mom_mango mom_veg mom_fruit mom_fat mom_sweets mom_condiments mom_meal_freq ///



anc_adopt anc_yn anc_where anc_where_oth ///
anc_home_who anc_home_who_oth anc_home_visit ///


anc_hosp_who
anc_hosp_who_oth
anc_hosp_dist_dry
anc_hosp_dist_wet
anc_hosp_visit


anc_pc_who
anc_pc_oth
anc_pc_dist_dry
anc_pc_dist_wet
anc_pc_visit


anc_rhc_who
anc_rhc_who_oth
anc_rhc_dist_dry
anc_rhc_dist_wet
anc_rhc_visit

anc_ehoc_who
anc_ehoc_who_oth
anc_ehoc_dist_dry
anc_ehoc_dist_wet
anc_ehoc_visit

anc_ehom_who
anc_ehom_oth
anc_ehom_dist_dry
anc_ehom_dist_wet
anc_ehom_visit


anc_vill_who
anc_vill_who_oth
anc_vill_dist_dry
anc_vill_dist_wet
anc_vill_visit


anc_othp_who
anc_othp_who_oth
anc_othp_dist_dry
anc_othp_dist_wet
anc_othp_visit



anc_bf_counselling
anc_nut_counselling


anc_cost
anc_cope
anc_cope_oth


anc_noreason
anc_noreason_oth
anc_restrict
anc_restrict_item
anc_restrict_item_oth
anc_restrict_why
anc_restrict_why_oth

anc_bone
anc_rion
anc_iron_freq
anc_iron_count
anc_rion_length
anc_rion_length_oth
anc_iron_cost
anc_iron_source
anc_iron_source_oth



deliv_place
deliv_place_oth
deliv_assist
deliv_assist_oth
child_hepatitisb
deliv_cost
deliv_cope
deliv_cope_oth


pnc_yn
pnc_checktime
pnc_checkunit


pnc_where
pnc_where_oth


pnc_home_who
pnc_home_oth
pnc_home_visit



pnc_hosp_who
pnc_hosp_who_oth
pnc_hosp_visit



pnc_pc_who
pnc_pc_oth
pnc_pc_visit


pnc_rhc_who
pnc_rhc_who_oth
pnc_rhc_visit


pnc_ehoc_who
pnc_ehoc_who_oth
pnc_ehoc_visit


pnc_ehom_who
pnc_ehom_oth
pnc_ehom_visit


pnc_vill_who
pnc_vill_who_oth
pnc_vill_visit


pnc_othp_who
pnc_othp_who_oth
pnc_othp_visit


pnc_bone
pnc_bone_months
pnc_bone_weeks

pnc_cost
pnc_cope
pnc_cope_oth


nbc_yn
nbc_2days_yn
nbc_where
nbc_where_oth

nbc_home_who
nbc_home_oth
nbc_home_visit
nbc_home

nbc_hosp
nbc_hosp_who
nbc_hosp_who_oth
nbc_hosp_visit
nbc_hosp

nbc_pc
nbc_pc_who
nbc_pc_oth
nbc_pc_visit
nbc_pc

nbc_rhc
nbc_rhc_who
nbc_rhc_who_oth
nbc_rhc_visit
nbc_rhc

nbc_ehoc
nbc_ehoc_who
nbc_ehoc_who_oth
nbc_ehoc_visit
nbc_ehoc

nbc_ehom
nbc_ehom_who
nbc_ehom_oth
nbc_ehom_visit
nbc_ehom

nbc_vill
nbc_vill_who
nbc_vill_who_oth
nbc_vill_visit
nbc_vill

nbc_othp
nbc_othp_who
nbc_othp_who_oth
nbc_othp_visit
nbc_othp

nbc_cost* nbc_cope* nbc_cope_oth*  ///

mom_covid mom_covid_doses mom_covid_know mom_covid_year ///

house_roof
house_roof_oth
house_wall
house_wall_oth
house_floor
house_floor_oth
house_room
house_light
house_light_oth
house_electric
house_electric_check

house_electric_perday
house_electric_source
house_electric_perday_oth
house_electric_oth

house_cooking
house_cooking_oth
house_elecook_note1

hhitems_tv
hhitems_phone
hhitems_refrigerator
hhitems_table
hhitems_chair
hhitems_bed
hhitems_cupboard
hhitems_fan
hhitems_computer
hhitems_watch
hhitems_bankacc

wempo_childcare
wempo_mom_health
wempo_child_health
wempo_women_wages
wempo_major_purchase
wempo_visiting
wempo_women_health
wempo_child_wellbeing
wempo_group

phq9_1
phq9_2
phq9_3
phq9_4
phq9_5
phq9_6
phq9_7
phq9_8
phq9_9


water_sum
cal_water_source1
water_time
water_sum_treat
water_sum_treatmethod
water_sum_oth
water_sum_treatmethod_oth

water_rain
cal_water_source2
water_time_rain
water_rain_treat
water_rain_treatmethod
water_rain_oth
water_rain_treatmethod_oth

water_winter
cal_water_source3
water_time_winter
water_winter_treat
water_winter_treatmethod
water_winter_oth
water_winter_treatmethod_oth

waterpot_yn
waterpot_capacity
waterpot_condition

latrine_type
latrine_type_oth
latrine_share
latrine_observe

soap_yn
soap_why
soap_why_oth


soap_tiolet
soap_before_eat
soap_after_eat
soap_handle_child
soap_before_cook
soap_feed_child
soap_clean_baby
soap_child_faeces


observ_washplace
observ_water
soap_present
observ_washplace_oth


d0_per_std
d3_inc_lmth
d4_inc_status
d5_reason
d5_reason_oth
d6_cope
d6_cope_oth

jan_incom_status
thistime_incom_status
d7_inc_govngo
d7_inc_govngo_nm
d7_inc_govngo_nm_oth
health_visit
health_exp
health_exp_cope
health_exp_cope_oth

gfi1_notegh
gfi2_unhnut
gfi3_fewfd
gfi4_skp_ml
gfi5_less
gfi6_rout_fd
gfi7_hunger
gfi8_wout_eat


prgexpo_pn
prgexpo_join
prgexpo_join_oth


prgexp_freq_*
prgexp_monthly_*
prgexp_why_*
prgexp_why_oth_*

prgexp_iec

child_muac_yn*
child_muac* 


svy_visit_num
svy_interview_mode
enu_end_note







							///


// missing per variables 
foreach var of varlist `variables_interest' {
    
	gen `var'_m = mi(`var')
	
	egen `var'_m_t = total(`var'_m)
	
	// gen `var'_nomiss = (`var'_m_t != _N)
	
	bysort svy_team enu_name: egen `var'_em = total(`var'_m)
	
	tab `var'_m_t

}

gen sir = _n 


// all variables 
preserve
keep if _n == 1

keep sir *_m_t

drop cla_* calc_* cal_*

rename *_m_t m_t_*

drop *note*

reshape long m_t_, i(sir) j(var) string 

rename m_t_ missing_num 

// lab var 
lab var missing_num	"Number of missing"

// export table
export excel using "$out/02_hfc_hh_missing.xlsx", sheet("01_per_var") firstrow(varlabels) sheetreplace
restore 

// variables per enumerator 
bysort svy_team enu_name: keep if _n == 1

keep sir *_em svy_team enu_name

drop cla_* calc_* cal_* svy_team_* enu_name_*

rename *_em em_*

drop *note*

reshape long em_, i(sir) j(var) string 

rename em_ missing_num 

// lab var 
lab var missing_num	"Number of missing"

// export table
export excel using "$out/02_hfc_hh_missing.xlsx", sheet("02_per_var_enu") firstrow(varlabels) sheetreplace


// overall total  
bysort svy_team enu_name: egen tot_missing = total(missing_num)
bysort svy_team enu_name: keep if _n == 1

keep svy_team enu_name tot_missing

// lab var 
lab var tot_missing	"Number of missing"

// export table
export excel using "$out/02_hfc_hh_missing.xlsx", sheet("03_per_enu_tot") firstrow(varlabels) sheetreplace

* END here 


 


/*******************************************************************************
Project Name		: 	Project Nourish
Purpose				:	1st round data collection - Mothers data cleaning			
Author				:	Nicholus Tint Zaw
Date				: 	5/09/2022
Modified by			:

*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "00_dir_setting.do"
do "00_dir_setting_w1.do"

	********************************************************************************
	** Wave - 1 Data **
	********************************************************************************
	use "$w1dta/mothers_cleaned.dta", clear  

	// MINIMUM DIETARY DIVERSITY 6–23 MONTHS (MDD)
	// cf_rice cf_pulses cf_milk cf_meat cf_eggs cf_veg_vit cf_veg_fruit_oth cf_sweet cf_snack cf_no_veg_fruit

	drop dietary_tot mdd 
	
	egen dietary_tot = rowtotal(bf_breastmilk cf_rice cf_pulses cf_milk cf_meat ///
								cf_eggs cf_veg_vit cf_veg_fruit_oth), missing
	replace dietary_tot = .m if mi(bf_breastmilk) & mi(cf_rice) & mi(cf_pulses) & ///
								mi(cf_milk) & mi(cf_meat) & mi(cf_eggs) & ///
								mi(cf_veg_vit) & mi(cf_veg_fruit_oth) & ///
								(youngest_age_month >= 6 & youngest_age_month < 24)
	replace dietary_tot = .m if mi(youngest_age_month)
	replace dietary_tot = .m if youngest_age_month < 6 
	replace dietary_tot = .m if youngest_age_month >= 24
	lab var dietary_tot "Food group score"
	tab dietary_tot, m 

	gen mdd = (dietary_tot >= 5 & !mi(dietary_tot) & youngest_age_month >= 6 & youngest_age_month < 24)
	replace mdd = .m if mi(dietary_tot) | mi(youngest_age_month)
	replace mdd = .m if youngest_age_month < 6 
	replace mdd = .m if youngest_age_month >= 24
	lab var mdd "Minimum Dietary Diversity"
	tab mdd, m
	
	** Child - Food Group Matching ** 
	rename bf_breastmilk		c_breastmilk
	rename cf_rice				c_grain
	rename cf_pulses 			c_pulses
	rename cf_milk 				c_diary
	rename cf_meat   			c_meat
	rename cf_eggs 				c_egg
	rename cf_veg_vit 			c_vitfruitveg
	rename cf_veg_fruit_oth 	c_othfruitveg
	
	

	** Mom - Food Group Matching ** 
	// mom - mddw_grain mddw_pulses mddw_nut mddw_milk mddw_meat mddw_moom_egg mddw_green_veg mddw_vit_vegfruit mddw_oth_veg mddw_oth_fruit mddw_score mddw_yes
	
	gen m_grain = (mddw_grain == 1 | mddw_pulses == 1)
	replace m_grain = .m if mi(mddw_grain) & mi(mddw_pulses)
	tab m_grain, m 
	
	gen m_pulses = (mddw_pulses == 1 | mddw_nut == 1)
	replace m_pulses = .m if mi(mddw_pulses) & mi(mddw_nut)
	tab m_pulses, m 
	
	gen m_diary = (mddw_milk == 1)
	replace m_diary = .m if mi(mddw_milk)
	tab m_diary, m 	
	
	gen m_meat = (mddw_meat == 1)
	replace m_meat = .m if mi(mddw_meat)
	tab m_meat, m 	
	
	gen m_egg = (mddw_moom_egg == 1)
	replace m_egg = .m if mi(mddw_moom_egg)
	tab m_egg, m 	
	
	gen m_vitfruitveg = (mddw_green_veg == 1 | mddw_vit_vegfruit == 1)
	replace m_vitfruitveg = .m if mi(mddw_green_veg) & mi(mddw_vit_vegfruit) 
	tab m_vitfruitveg, m 

	gen m_othfruitveg = (mddw_oth_veg == 1 | mddw_oth_fruit == 1)
	replace m_othfruitveg = .m if mi(mddw_oth_veg) & mi(mddw_oth_fruit) 
	tab m_othfruitveg, m 
	
	** Respondent Characteristics Matching ** 
	
	rename resp_age respd_age 
	rename youngest_age_month child_age_month
	rename wt_final weight_final 
	recode resp_edu (6 = 1) ///
					(1 = 2) ///
					(2 = 3) ///
					(3 = 4) ///
					(4 = 5) ///
					(5 = 8) ///
					(777 = 888) ///
					(444 = .m), gen(resp_highedu)
	
	
	local diddta	respd_age resp_highedu weight_final ///
					child_age_month c_breastmilk ///
					m_grain m_pulses m_diary m_meat m_egg m_vitfruitveg m_othfruitveg ///
					c_grain c_pulses c_diary c_meat c_egg c_vitfruitveg c_othfruitveg

	keep	`diddta'
	gen source = 0
	
	keep if child_age_month > 5 & child_age_month < 24 // keep 6-59 m obs

	gen index_obs = _n
	
	tempfile wave1
	save `wave1', replace 
	
	clear 
	

	********************************************************************************
	** Wave - 2 Data **
	********************************************************************************
	// mom dataset 
	use "$dta/pnourish_mom_diet_final.dta", clear 
	
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
	
	keep if stratum == 1 // keep only stratum 1 as it is equivalance to Wave 1 sample 
	
	** (1) Food Group Matching ** 
	rename food_g1	c_breastmilk
	rename food_g2 	c_grain
	rename food_g3 	c_pulses
	rename food_g4 	c_diary
	rename food_g5 	c_meat
	rename food_g6 	c_egg
	rename food_g7 	c_vitfruitveg
	rename food_g8	c_othfruitveg
	
	** Mom - Food Group Matching ** 
	// mom - mddw_grain mddw_pulses mddw_nut mddw_milk mddw_meat mddw_moom_egg mddw_green_veg mddw_vit_vegfruit mddw_oth_veg mddw_oth_fruit mddw_score mddw_yes
	
	gen m_grain = (mddw_grain == 1 | mddw_pulses == 1)
	replace m_grain = .m if mi(mddw_grain) & mi(mddw_pulses)
	tab m_grain, m 
	
	gen m_pulses = (mddw_pulses == 1 | mddw_nut == 1)
	replace m_pulses = .m if mi(mddw_pulses) & mi(mddw_nut)
	tab m_pulses, m 
	
	gen m_diary = (mddw_milk == 1)
	replace m_diary = .m if mi(mddw_milk)
	tab m_diary, m 	
	
	gen m_meat = (mddw_meat == 1)
	replace m_meat = .m if mi(mddw_meat)
	tab m_meat, m 	
	
	gen m_egg = (mddw_moom_egg == 1)
	replace m_egg = .m if mi(mddw_moom_egg)
	tab m_egg, m 	
	
	gen m_vitfruitveg = (mddw_green_veg == 1 | mddw_vit_vegfruit == 1)
	replace m_vitfruitveg = .m if mi(mddw_green_veg) & mi(mddw_vit_vegfruit) 
	tab m_vitfruitveg, m 

	gen m_othfruitveg = (mddw_oth_veg == 1 | mddw_oth_fruit == 1)
	replace m_othfruitveg = .m if mi(mddw_oth_veg) & mi(mddw_oth_fruit) 
	tab m_othfruitveg, m 
		      
	keep	`diddta'
	gen source = 1 
	lab def source 0"Wave 1" 1"Wave 2"
	lab val source source 
	tab source 
	
	keep if child_age_month > 5 & child_age_month < 24 // keep 6-59 m obs

	gen index_obs = _n

	
	append using `wave1'
	
	order `diddta'
	
	tab source, m 
	
	** DID Implementation ** 
	** 𝑦 = 𝛽0 + 𝛽1𝑡𝑖𝑚𝑒 + 𝛽2𝑡𝑟𝑒𝑎𝑡𝑒𝑑 + 𝛽3𝑡𝑖𝑚𝑒 ∗ 𝑡𝑟𝑒𝑎𝑡𝑒𝑑 + 𝜀
	
	local fgs grain pulses diary meat egg vitfruitveg othfruitveg
	foreach fg in `fgs' {
		
		rename *_`fg' `fg'_*
	}
	
	reshape long `fgs', i(index_obs source) j(person) string 
	
	
	// source as time (wave - 1 vs wave - 2)
	tab source, m 
	
	// person - as treatment (child) vs control (mother)
	replace person = "0" if person == "_m" 
	replace person = "1" if person == "_c" 
	destring person, replace 
	lab def person 0"Mother" 1"Child"
	lab val person person 
	tab person, m 
	
	// did indicator 
	gen did = source * person
	tab did, m 
	
	foreach var of varlist grain pulses diary meat egg vitfruitveg othfruitveg {
		
		di "`var'"
		diff `var' [pweight = weight_final], t(person) p(source) cov(respd_age resp_highedu child_age_month)
		// reg `var' source person did respd_age resp_highedu child_age_month c_breastmilk [pweight = weight_final], r
		
	}
	


					
					
					
	/*
	** Food Groups GAP 
	gen gap_grain = (m_grain == 1 & c_grain == 0)
	replace gap_grain = .m if mi(m_grain) | mi(c_grain)
	tab gap_grain, m 
	
	gen gap_pulses = (gap_pulses == 1 & gap_pulses == 0)
	replace gap_pulses = .m if mi(gap_pulses) | mi(gap_pulses)
	tab gap_pulses, m 
	
	gen gap_diary = (gap_diary == 1 & gap_diary == 0)
	replace gap_diary = .m if (gap_diary) & mi(gap_diary)
	tab gap_diary, m 	
	
	gen gap_meat = (gap_meat == 1 & gap_meat == 0)
	replace gap_meat = .m if (gap_meat) & mi(gap_meat)
	tab gap_meat, m 	
	
	gen gap_egg = (gap_egg == 1 & gap_egg == 0)
	replace gap_egg = .m if (gap_egg) & mi(gap_egg)
	tab gap_egg, m 	
	
	gen gap_vitfruitveg = (gap_vitfruitveg == 1 & gap_vitfruitveg == 0)
	replace gap_vitfruitveg = .m if (gap_vitfruitveg) & mi(gap_vitfruitveg)
	tab gap_vitfruitveg, m 

	gen gap_othfruitveg = (gap_othfruitveg == 1 & gap_othfruitveg == 0)
	replace gap_othfruitveg = .m if (gap_othfruitveg) & mi(gap_othfruitveg)
	tab gap_othfruitveg, m 
	
	egen gap_score = rowtotal(gap_grain gap_pulses gap_diary gap_meat gap_egg gap_vitfruitveg gap_othfruitveg)
	replace gap_score = .m if mi(gap_grain) | mi(gap_pulses) | mi(gap_diary) | mi(gap_meat) | mi(gap_egg) | mi(gap_vitfruitveg) | mi(gap_othfruitveg)
	tab gap_score, m 

	*/
	

** end of dofile 

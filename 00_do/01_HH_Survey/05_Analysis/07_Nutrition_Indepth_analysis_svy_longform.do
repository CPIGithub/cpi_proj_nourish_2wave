/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: Nutrition Indepth Analysis 			
Author				:	Nicholus Tint Zaw
Date				: 	05/21/2023
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

	****************************************************************************
	** Mom Dietary Diversity **
	****************************************************************************

	use "$dta/pnourish_mom_diet_final.dta", clear 
	
	rename roster_index mom_index
	
	distinct _parent_index mom_index , joint
	
	gen gap_grain = (mddw_grain == 1)
	replace gap_grain = .m if mi(mddw_grain)
	tab gap_grain, m 
	
	gen gap_pulses = (mddw_pulses == 1 | mddw_nut == 1)
	replace gap_pulses = .m if mi(mddw_pulses) & mi(mddw_nut)
	tab gap_pulses, m 
	
	gen gap_diary = (mddw_milk == 1)
	replace gap_diary = .m if mi(mddw_milk)
	tab gap_diary, m 	
	
	gen gap_meat = (mddw_meat == 1)
	replace gap_meat = .m if mi(mddw_meat)
	tab gap_meat, m 	
	
	gen gap_egg = (mddw_moom_egg == 1)
	replace gap_egg = .m if mi(mddw_moom_egg)
	tab gap_egg, m 	
	
	gen gap_vitfruitveg = (mddw_green_veg == 1 | mddw_vit_vegfruit == 1)
	replace gap_vitfruitveg = .m if mi(mddw_green_veg) & mi(mddw_vit_vegfruit)
	tab gap_vitfruitveg, m 

	gen gap_othfruitveg = (mddw_oth_veg == 1 | mddw_oth_fruit == 1)
	replace gap_othfruitveg = .m if mi(mddw_oth_veg) & mi(mddw_oth_fruit)
	tab gap_othfruitveg, m 
	
	gen mom_child = 0
	
	tempfile momdta 
	save `momdta', replace 
	clear 
	

	****************************************************************************
	* Child IYCF Data *
	****************************************************************************
	
	use "$dta/pnourish_child_iycf_final.dta", clear 
	
	rename women_pos1 mom_index
	
	distinct _parent_index mom_index , joint
	
	gen gap_grain = (food_g2 == 1)
	replace gap_grain = .m if mi(food_g2)
	tab gap_grain, m 
	
	gen gap_pulses = (food_g3 == 1)
	replace gap_pulses = .m if mi(food_g3)
	tab gap_pulses, m 
	
	gen gap_diary = (food_g4 == 1)
	replace gap_diary = .m if mi(food_g4)
	tab gap_diary, m 	
	
	gen gap_meat = (food_g5 == 1)
	replace gap_meat = .m if mi(food_g5)
	tab gap_meat, m 	
	
	gen gap_egg = (food_g6 == 1)
	replace gap_egg = .m if mi(food_g6)
	tab gap_egg, m 	
	
	gen gap_vitfruitveg = (food_g7 == 1)
	replace gap_vitfruitveg = .m if mi(food_g7)
	tab gap_vitfruitveg, m 

	gen gap_othfruitveg = (food_g8 == 1)
	replace gap_othfruitveg = .m if mi(food_g8)
	tab gap_othfruitveg, m 
	
	gen mom_child = 1
	lab def mom_child 0"Mother" 1"Child" 
	lab val mom_child mom_child
	tab mom_child, m 
	
	append using `momdta' 
	
	* Analysis * 
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	svy: mean gap_grain, over(mom_child)
	
	
	svy: tab mom_child gap_grain, row

	
	
// END HERE 



/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: Child IYCF data cleaning 			
Author				:	Nicholus Tint Zaw
Date				: 	03/01/2023
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"


	****************************************************************************
	* Child IYCF Data *
	****************************************************************************
	use "$dta/pnourish_child_iycf_raw.dta", clear 
	
	// _parent_index child_id_iycf
	
	rename child_id_iycf roster_index
	

	** HH Roster **
	preserve 

	use "$dta/grp_hh.dta", clear
	
	do "$hhimport/grp_hh_labeling.do"

	drop 	_index _parent_table_name _submission__id _submission__uuid ///
			_submission__submission_time _submission__validation_status ///
			_submission__notes _submission__status _submission__submitted_by ///
			_submission__tags
			
	order _parent_index

	destring test calc_age_months, replace

	keep	_parent_index test hh_mem_name hh_mem_sex hh_mem_age hh_mem_age_month ///
			hh_mem_dob_know hh_mem_dob hh_mem_certification calc_age_months
	
	rename test roster_index

	tempfile grp_hh
	save `grp_hh', replace 

	restore

	merge 1:1 _parent_index roster_index using `grp_hh'

	keep if _merge == 3
	drop _merge 

	
	** Children Mother ** 
	preserve 
	use "$dta/hh_child_mom_rep.dta", clear
	
	* lab var 
	lab var hh_mem_mom "Who is the mother of this child?"
	
	// drop obs not eligable for this module 
	drop if mi(hh_mem_mom)

	drop 	_index _parent_table_name _submission__id _submission__uuid ///
			_submission__submission_time _submission__validation_status ///
			_submission__notes _submission__status _submission__submitted_by ///
			_submission__tags
			
	order _parent_index

	destring cal_hh_cname_id, replace
	
	keep _parent_index cal_hh_cname_id hh_mem_mom

	rename cal_hh_cname_id roster_index

	tempfile hh_child_mom_rep
	save `hh_child_mom_rep', replace 

	restore

	merge 1:1 _parent_index roster_index using `hh_child_mom_rep'
	
	keep if _merge == 3

	drop _merge 
	
	
	****************************************************************************
	** Child Age Calculation **
	****************************************************************************
	gen child_age_month		= calc_age_months if hh_mem_certification == 1
	replace child_age_month = hh_mem_age_month if mi(child_age_month)
	replace child_age_month = .m if mi(child_age_month)
	lab var child_age_month "Child Age in months"

	****************************************************************************
	** IYCF Indicators **
	****************************************************************************
	
	// EARLY INITIATION OF BREASTFEEDING (EIBF)
	destring child_eibf child_eibf_hrs, replace 
	
	gen eibf = ((child_eibf == 0 | child_eibf_hrs < 1) & child_age_month < 24) 
	replace eibf = .m if (mi(child_eibf) & mi(child_eibf_hrs)) | mi(child_age_month)
	lab var eibf "Early iinitiation of breasfeeding (EIBF)"
	tab eibf, m 
	
	
	// EXCLUSIVELY BREASTFED FOR THE FIRST TWO DAYS AFTER BIRTH (EBF2D)
	gen ebf2d 		= (chhild_addbf5 == 1 & child_age_month < 24)
	replace ebf2d 	= .m if mi(chhild_addbf) | mi(child_age_month)
	lab var ebf2d "Exclusively breastfed for the first two days after birth (EBF2D)"
	tab ebf2d, m 

	// EXCLUSIVE BREASTFEEDING UNDER SIX MONTHS (EBF)
	
	local liquid	child_water child_bms child_milk child_mproduct ///
					child_juice child_tea child_energyd child_broth ///
					child_porridge child_liquid
					
	foreach v in `liquid' {
		
		replace `v' = .m if `v' == 999
		tab `v', m 
	}
	
	// strict rules 
	egen liquid = rowtotal(	child_water child_bms child_milk child_mproduct ///
							child_juice child_tea child_energyd child_broth ///
							child_porridge child_liquid), missing
	replace liquid = .m if 	mi(child_water) & mi(child_bms) & mi(child_milk) | ///
							mi(child_mproduct) & mi(child_juice) & mi(child_tea) & ///
							mi(child_energyd) & mi(child_broth) & mi(child_porridge) & ///
							mi(child_liquid)
	tab liquid, m 

	local solid	child_rice child_potatoes child_pumpkin child_beans child_leafyveg ///
				child_mango child_fruit child_organ child_beef child_fish child_insects ///
				child_eggs child_yogurt child_cheese child_fat child_plam child_sweets ///
				child_condiments
				
	foreach v in `solid' {
		
		replace `v' = .m if `v' == 999
		tab `v', m 
	}
	
	egen solid = rowtotal(	child_rice child_potatoes child_pumpkin child_beans ///
							child_leafyveg child_mango child_fruit child_organ ///
							child_beef child_fish child_insects child_eggs child_yogurt ///
							child_cheese child_fat child_plam child_sweets child_condiments), missing
	
	replace solid = .m if 	mi(child_rice) & mi(child_potatoes) & mi(child_pumpkin) & ///
							mi(child_beans) & mi(child_leafyveg) & mi(child_mango) & ///
							mi(child_fruit) & mi(child_organ) & mi(child_beef) & ///
							mi(child_fish) & mi(child_insects) & mi(child_eggs) & ///
							mi(child_yogurt) & mi(child_cheese) & mi(child_fat) & ///
							mi(child_plam) & mi(child_sweets) & mi(child_condiments)
	tab solid, m 

	gen ebf = (child_bfyest == 1 & solid == 0 & liquid == 0 & child_age_month < 6)
	replace ebf = .m if mi(child_bfyest) | mi(solid) | mi(liquid) | mi(child_age_month)
	replace ebf = .m if child_age_month >= 6 
	lab var ebf "Exclusive breastfeeding under six months (EBF)"
	tab ebf, m 
	

	// Predominant breastfeeding (< 6 months)
	// treat missing as 0 
	egen non_water_liquid = rowtotal(child_bms child_milk child_mproduct ///
									child_juice child_tea child_energyd child_broth ///
									child_porridge child_liquid), missing
	replace non_water_liquid = .m if 	mi(child_bms) & mi(child_milk) & ///
										mi(child_mproduct) & mi(child_juice) & mi(child_tea) & ///
										mi(child_energyd) & mi(child_broth) & mi(child_porridge) & ///
										mi(child_liquid)
	tab non_water_liquid, m 

	gen pre_bf = (child_bfyest == 1 & solid == 0 & non_water_liquid == 0 & child_age_month < 6)
	replace pre_bf = .m if mi(child_bfyest) | mi(solid) | mi(non_water_liquid) | mi(child_age_month)
	replace pre_bf = .m if child_age_month >= 6 
	lab var pre_bf "Predominant breastfeeding under six months (EBF)"
	tab pre_bf, m 


	// MIXED MILK FEEDING UNDER SIX MONTHS (MixMF)
	foreach var of varlist child_bms child_milk {
		
		replace `var' = .m if `var' == 999
		tab `var', m 
	}
	
	egen bf_othmilk_freq 	= rowtotal(child_bms child_milk), missing 
	replace bf_othmilk_freq = .m if mi(child_bms) | mi(child_milk)
	tab bf_othmilk_freq, m 
	
	gen mixmf 		= (child_age_month < 6 & bf_othmilk_freq > 0 & child_bfyest == 1)
	replace mixmf 	= .m if mi(child_age_month) | mi(bf_othmilk_freq)  | mi(child_bfyest)
	replace mixmf = .m if child_age_month >= 6 
	lab var mixmf "Mixed milk feeding under 6 months"
	tab mixmf, m

	// BOTTLE FEEDING 0–23 MONTHS (BoF)
	gen bof 	= (child_age_month < 24 & child_bottle == 1)
	replace bof = .m if mi(child_age_month) | mi(child_bottle)
	lab var bof "Bottle feeding 0-23 months"
	tab bof, m 

	// CONTINUED BREASTFEEDING 12–23 MONTHS (CBF)
	gen cbf 	= (child_age_month >= 12 & child_age_month < 24 & child_bfyest == 1)
	replace cbf = .m if mi(child_age_month) | mi(child_age_month) | mi(child_bfyest) 
	replace cbf = .m if child_age_month < 12 
	replace cbf = .m if child_age_month >= 24
	lab var cbf "Continious breastfeeding 12-23 months"
	tab cbf, m

	// INTRODUCTION OF SOLID, SEMI-SOLID OR SOFT FOODS 6–8 MONTHS (ISSSF)
	gen isssf 		= (child_age_month >= 6 & child_age_month < 9 & solid >=  1)
	replace isssf 	= .m if mi(child_age_month) | mi(child_age_month) | mi(solid)
	replace isssf = .m if child_age_month < 6 
	replace isssf = .m if child_age_month >= 9
	lab var isssf "Introduction of solid, semi-solid or soft foods 6-8 months"
	tab isssf, m 

	// MINIMUM DIETARY DIVERSITY 6–23 MONTHS (MDD)
	// treat missing as 0 
	gen food_g1 = child_bfyest
	
	gen food_g2 = (child_rice ==  1 | child_potatoes == 1)
	replace food_g2 = .m if mi(child_rice) & mi(child_potatoes)
	
	gen food_g3 = child_beans
	
	gen food_g4 = (child_bms == 1| child_milk == 1 | child_mproduct == 1 | child_yogurt == 1 | child_cheese == 1)
	replace food_g4 = .m if mi(child_bms) & mi(child_milk) & mi(child_mproduct) & mi(child_yogurt) & mi(child_cheese) 
	
	gen food_g5 = (child_organ == 1| child_beef == 1| child_fish == 1 | child_insects == 1)
	replace food_g5 = .m if mi(child_organ) & mi(child_beef) & mi(child_fish) & mi(child_insects)
	
	gen food_g6 = child_eggs

	gen food_g7 = (child_pumpkin ==1 | child_mango == 1 | child_leafyveg == 1)
	replace food_g7 = .m if mi(child_pumpkin) & mi(child_mango) & mi(child_leafyveg)
	
	gen food_g8 = child_fruit
	
	foreach var of varlist food_g1 food_g2 food_g3 food_g4 food_g5 food_g6 food_g7 food_g8 {
	    
		replace `var' = .m if `var' == 999
		tab `var', m 
	}
	
	egen dietary_tot = rowtotal(food_g1 food_g2 food_g3 food_g4 food_g5 food_g6 food_g7 food_g8), missing
	replace dietary_tot = .m if mi(food_g1) & mi(food_g2) & mi(food_g3) & ///
								mi(food_g4) & mi(food_g5) & mi(food_g6) & ///
								mi(food_g7) & mi(food_g8) & ///
								(child_age_month >= 6 & child_age_month < 24)
	replace dietary_tot = .m if mi(child_age_month)
	replace dietary_tot = .m if child_age_month < 6 
	replace dietary_tot = .m if child_age_month >= 24
	lab var dietary_tot "Food group score"
	tab dietary_tot, m 

	gen mdd = (dietary_tot >= 5 & !mi(dietary_tot) & child_age_month >= 6 & child_age_month < 24)
	replace mdd = .m if mi(dietary_tot) | mi(child_age_month)
	replace mdd = .m if child_age_month < 6 
	replace mdd = .m if child_age_month >= 24
	lab var mdd "Minimum Dietary Diversity"
	tab mdd, m

	// MINIMUM MEAL FREQUENCY 6–23 MONTHS (MMF)
	// technical note: not include all category of milk food recall as WHO questionniares 
	// 6-8 breastfed child
	gen mmf_bf_6to8 		= (child_age_month >= 6 & child_age_month < 9 & child_bfyest == 1 & child_food_freq >= 2)
	replace mmf_bf_6to8 	= .m if mi(child_age_month) |mi(child_bfyest) | mi(child_food_freq)
	replace mmf_bf_6to8 = .m if child_age_month < 6 
	replace mmf_bf_6to8 = .m if child_age_month >= 9
	replace mmf_bf_6to8 = .m if child_bfyest == 0
	lab var mmf_bf_6to8 "Breastfeeding MMF - 6 to 8 months"
	tab mmf_bf_6to8, m 

	// 9-23 breastfed child
	gen mmf_bf_9to23 		= (child_age_month >= 9 & child_age_month < 24 & child_bfyest == 1 & child_food_freq >= 3)
	replace mmf_bf_9to23 	= .m if mi(child_age_month) |mi(child_bfyest) | mi(child_food_freq)
	replace mmf_bf_9to23 = .m if child_age_month < 9 
	replace mmf_bf_9to23 = .m if child_age_month >= 24
	replace mmf_bf_9to23 = .m if child_bfyest == 0
	lab var mmf_bf_9to23 "Breastfeeding MMF - 9 to 23 months"
	tab mmf_bf_9to23, m 

	gen mmf_bf 		= (mmf_bf_9to23 == 1 |  mmf_bf_6to8 == 1)
	replace mmf_bf 	= .m if mi(mmf_bf_9to23) & mi(mmf_bf_6to8)
	lab var mmf_bf "Breastfeeding MMF"
	tab mmf_bf, m 

	// non-breastfeed 6-23 months
	// treat missing as 0   
	egen milk_food_freq 	= rowtotal(child_bms_freq child_milk_freq child_mproduct_freq child_food_freq)
	replace milk_food_freq 	= .m if mi(child_bms_freq) & mi(child_milk_freq) & mi(child_mproduct_freq) & mi(child_food_freq)
	tab milk_food_freq, m 

	gen mmf_nonbf 		= (	child_age_month >= 6 & child_age_month < 24 & ///
							child_bfyest == 0 & milk_food_freq >= 4 & child_food_freq >= 1)
	replace mmf_nonbf 	= .m if mi(child_age_month) | mi(child_bfyest) | mi(milk_food_freq) | mi(child_food_freq)
	replace mmf_nonbf = .m if child_age_month < 6 
	replace mmf_nonbf = .m if child_age_month >= 24
	replace mmf_nonbf = .m if child_bfyest == 1
	lab var mmf_nonbf "Non-Breastfeeding MMF"
	tab mmf_nonbf, m 

	gen mmf 	= (mmf_nonbf == 1 | mmf_bf == 1)
	replace mmf = .m if mi(mmf_nonbf) & mi(mmf_bf)
	lab var mmf "Minimum Meal Frequency"
	tab mmf, m 


	// MINIMUM MILK FEEDING FREQUENCY FOR NON-BREASTFED CHILDREN 6–23 MONTHS (MMFF)
	gen mmff 		= (child_age_month >= 6 & child_age_month < 24 & child_bfyest == 0 & milk_food_freq >= 2)
	replace mmff 	= .m if mi(child_age_month) | mi(child_bfyest) | mi(milk_food_freq)
	replace mmff = .m if child_age_month < 6 
	replace mmff = .m if child_age_month >= 24
	replace mmff = .m if child_bfyest == 1
	lab var mmff "Minimum milk feeding frequency for non-breastfed children"
	tab mmff, m 

	// MINIMUM ACCEPTABLE DIET 6–23 MONTHS (MAD)
	// strict rules 
	gen mad 	= (child_age_month >= 6 & child_age_month < 24 & mdd == 1 & mmf == 1 & (mmff == 1 | child_bfyest == 1))
	replace mad = .m if mi(child_age_month) | mi(mdd) | mi(mmf) | (mi(mmff) & mi(child_bfyest))
	replace mad = .m if child_age_month < 6 
	replace mad = .m if child_age_month >= 24
	lab var mad "Minimum Acceptable Diet"
	tab mad, m 


	gen mad_bf 	= (child_age_month >= 6 & child_age_month < 24 & mdd == 1 & mmf == 1 & child_bfyest == 1)
	replace mad_bf = .m if mi(child_age_month) | mi(mdd) | mi(mmf) | mi(child_bfyest)
	replace mad_bf = .m if child_age_month < 6 
	replace mad_bf = .m if child_age_month >= 24
	replace mad_bf = .m if child_bfyest != 1
	lab var mad_bf "Minimum Acceptable Diet (Breastfeeding)"
	tab mad_bf, m 


	gen mad_nobf 	= (child_age_month >= 6 & child_age_month < 24 & mdd == 1 & mmf == 1 & mmff == 1 & child_bfyest == 0)
	replace mad_nobf = .m if mi(child_age_month) | mi(mdd) | mi(mmf) | (mi(mmff) & mi(child_bfyest))
	replace mad_nobf = .m if child_age_month < 6 
	replace mad_nobf = .m if child_age_month >= 24
	replace mad_nobf = .m if child_bfyest == 1
	lab var mad_nobf "Minimum Acceptable Diet (non-Breastfeeding)"
	tab mad_nobf, m 

	****************************************************************************
	** Area Graph **
	****************************************************************************
	* ref: WHO indicators guideline 
	
	gen anyfood = 0
	gen nofood = 1
	gen noliquid = 1
	
	local solidfood	child_rice child_potatoes child_pumpkin child_beans child_leafyveg ///
					child_mango child_fruit child_organ child_beef child_fish child_insects ///
					child_eggs child_yogurt child_cheese child_fat child_plam child_sweets ///
					child_condiments
	
	foreach q in `solidfood' {
	    
		if ("`q'" != "q7s") { // exclude q7s - any solid, semi-solid or soft food
		replace anyfood = 1 if `q' == 1
		replace nofood = 0 if `q' != 0
	 }
	}
	
	tab1 anyfood nofood, m 
	
	local liquidfood 	child_bms child_milk child_mproduct child_juice child_tea ///
						child_energyd child_broth child_porridge child_liquid
	foreach q in `liquidfood' {
	    
		replace noliquid = 0 if `q' != 0

	}
	
	tab noliquid, m 
	
	* Initialize feeding variable for the missing category
	gen feeding = 7
	
	* Not breastfed
	replace feeding = 6 if child_bfyest != 1
	
	* Breastmilk and solid, semi-solid, and soft foods
	replace feeding = 5 if child_bfyest == 1 & anyfood

	* Breastmilk and other animal milk and/or formula
	replace feeding = 4 if 	child_bfyest == 1 & nofood & ///
							(child_bms == 1 | child_milk == 1 | child_mproduct == 1)
	 
	* Breastmilk and non-milk liquids 
	replace feeding = 3 if 	child_bfyest == 1 & nofood & ///
							(child_bms == 0 & child_milk == 0 & child_mproduct == 0 ) & ///
							(child_juice == 1 | child_tea == 1 | child_energyd == 1 | ///
							child_broth == 1 | child_porridge == 1 | child_liquid == 1)
	
	* Breastmilk and plain water
	replace feeding = 2 if child_bfyest == 1 & child_water == 1 & nofood & noliquid 
	
	* Breastmilk only (exclusively breastfed)
	replace feeding = 1 if child_bfyest == 1 & child_water == 0 & nofood & noliquid 
	
	lab var feeding "Feeding categories"
	lab def feeding ///
			1 "Exclusively breastfed" ///
			2 "Breastfed and plain water only" ///
			3 "Breastfed and non-milk liquids" ///
			4 "Breastfed and other milk or formula" ///
			5 "Breastfed and solid, semi-solid, or soft foods" ///
			6 "Not breastfed" ///
			7 "Unknown"
	lab val feeding feeding
	tab feeding, m 
	
	* Age in 2-month groups
	/*
	gen ageg = int(agedays/(2*30.4375)) // average of 30.4375 days per month
	lab var ageg "age in 2-month groups"
	lab def ageg 0 "0-1" 1 "2-3" 2 "4-5"
	lab val ageg ageg
	*/ 
	
	gen ageg 		= .m 
	replace ageg	= 0 if calc_age_months < 2 
	replace ageg 	= 1 if calc_age_months >= 2 & calc_age_months < 4 
	replace ageg	= 2 if calc_age_months >= 4 & calc_age_months < 6
	lab def ageg 0 "0-1" 1 "2-3" 2 "4-5"
	lab val ageg ageg
	tab ageg, m 
	
	tab calc_age_months, m 
	
	* Tabulate feeding categories by age group 
	tab ageg feeding, m row
	
	
	* Add Weight variable *
	merge m:1 geo_vill using "$dta/pnourish_hh_weight_final.dta", keepusing(stratum_num weight_final)
	
	keep if _merge == 3
	
	drop _merge 
	
	
	* Add Wealth Quantile variable **
	merge m:1 _parent_index using "$dta/pnourish_INCOME_WEALTH_final.dta", ///
							keepusing(NationalQuintile NationalScore hhitems_phone prgexpo_pn)
	
	keep if _merge == 3
	
	drop _merge 
	
	** SAVE for analysis dataset 
	save "$dta/pnourish_child_iycf_final.dta", replace  


// END HERE 



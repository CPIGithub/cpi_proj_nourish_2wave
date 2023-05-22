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
	
	tempfile momdta 
	save `momdta', replace 
	clear 
	

	****************************************************************************
	* Child IYCF Data *
	****************************************************************************
	
	use "$dta/pnourish_child_iycf_final.dta", clear 
	
	rename women_pos1 mom_index
	
	distinct _parent_index mom_index , joint
	
	merge m:1 _parent_index mom_index using `momdta' 
	
	keep if _merge == 3 // keep only matched obs - mother and child match 
	
	drop _merge 
	
	
	** (1) Food Group Matching ** 
	
	// child - food_g1 food_g2 food_g3 food_g4 food_g5 food_g6 food_g7 food_g8 dietary_tot mdd
	// mom - mddw_grain mddw_pulses mddw_nut mddw_milk mddw_meat mddw_moom_egg mddw_green_veg mddw_vit_vegfruit mddw_oth_veg mddw_oth_fruit mddw_score mddw_yes
	
	
	gen gap_grain = (mddw_grain == 1 & food_g2 == 0)
	replace gap_grain = .m if mddw_grain != 1 | mi(food_g2)
	tab gap_grain, m 
	
	gen gap_pulses = ((mddw_pulses == 1 | mddw_nut == 1) & food_g3 == 0)
	replace gap_pulses = .m if (mddw_pulses != 1 & mddw_nut != 1) & mi(food_g3)
	tab gap_pulses, m 
	
	gen gap_diary = (mddw_milk == 1 & food_g4 == 0)
	replace gap_diary = .m if (mddw_milk != 1) & mi(food_g4)
	tab gap_diary, m 	
	
	gen gap_meat = (mddw_meat == 1 & food_g5 == 0)
	replace gap_meat = .m if (mddw_meat != 1) & mi(food_g5)
	tab gap_meat, m 	
	
	gen gap_egg = (mddw_moom_egg == 1 & food_g6 == 0)
	replace gap_egg = .m if (mddw_moom_egg != 1) & mi(food_g6)
	tab gap_egg, m 	
	
	gen gap_vitfruitveg = ((mddw_green_veg == 1 | mddw_vit_vegfruit == 1) & food_g7 == 0)
	replace gap_vitfruitveg = .m if (mddw_green_veg != 1 & mddw_vit_vegfruit != 1) & mi(food_g7)
	tab gap_vitfruitveg, m 

	gen gap_othfruitveg = ((mddw_oth_veg == 1 | mddw_oth_fruit == 1) & food_g8 == 0)
	replace gap_othfruitveg = .m if (mddw_oth_veg != 1 & mddw_oth_fruit != 1) & mi(food_g8)
	tab gap_othfruitveg, m 
	
	egen gap_score = rowtotal(gap_grain gap_pulses gap_diary gap_meat gap_egg gap_vitfruitveg gap_othfruitveg)
	replace gap_score = .m if mi(gap_grain) | mi(gap_pulses) | mi(gap_diary) | mi(gap_meat) | mi(gap_egg) | mi(gap_vitfruitveg) | mi(gap_othfruitveg)
	tab gap_score, m 
	
	
	* GAP plot - individual food group 
	preserve 
	
	keep if child_age_month >= 6 & !mi(child_age_month)
	
	foreach var of varlist 	gap_grain gap_pulses gap_diary gap_meat gap_egg gap_vitfruitveg {
	    	
		replace `var' = `var' * 100 

	}
	
	sum food_g1
	local Nobs = r(N)
	

	graph hbar 	(mean) gap_grain (mean) gap_pulses ///
				(mean) gap_diary (mean) gap_meat (mean) gap_egg ///
				(mean) gap_vitfruitveg (mean) gap_othfruitveg, ///
				nofill 																			///
				bargap(20) 																		///
				bar(1, color($cpi1) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(2, color($cpi2) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(3, color($cpi2*0.7) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(4, color($cpi3) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(5, color($cpi3) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(6, color($cpi4) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(7, color($cpi5) lwidth(thin) lcolor(black) lalign(outside)) 			///
				blabel(bar, format(%9.1f) size(vsmall))														///	
				legend(off) 																	///
				showyvars 																		///
				yvaroptions(relabel( 															///
					1	"Grains, roots and tubers"  ///
					2	"Pulses, nuts and seeds" ///
					3	"Dairy products" /// 
					4	"Flesh foods" /// 
					5	"Eggs" ///
					6	"Vit-A rich fruits and vegetables" ///
					7	"Other fruits and vegetables")											///
				label(labsize(tiny)))															///
				l1title("Food Groups Gap", size(small)) 											///
				ytitle("Share of food consumption gap", size(small) height(-6))								///
				title("Share of Food Consumption Gap by Food Group (Mom vs. Child)", 		///
						justification(left) color(black) span pos(11) size(medium)) 							///
				plotregion(fcolor(white)) 														///
				graphregion(fcolor(white)) ///
				note(	"Obs: `Nobs'" ///
						"Source: $dtasource", size(tiny) span)		

						* Add percentage to labels
		local nb=`.Graph.plotregion1.barlabels.arrnels'
		forval i=1/`nb' {
		  di "`.Graph.plotregion1.barlabels[`i'].text[1]'"
		  .Graph.plotregion1.barlabels[`i'].text[1]="`.Graph.plotregion1.barlabels[`i'].text[1]'%"
		}
		.Graph.drawgraph
		
	graph export "$plots/GAP_mom_child_foodconsumption.png", replace
	
	restore 
	
	
	* Analysis * 
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	svy: mean gap_score, over(stratum_num)
	svy: mean gap_score, over(NationalQuintile)
	conindex gap_score, rank(NationalQuintile) truezero svy 

	gen child_age_edu_exposure = edu_exposure * child_age_month
	
	* regression model 
	svy: reg gap_score child_age_month dietary_tot mddw_score edu_exposure stratum i.NationalQuintile
	
	
// END HERE 



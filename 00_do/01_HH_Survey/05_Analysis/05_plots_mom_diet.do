/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: Mom Health data cleaning 			
Author				:	Nicholus Tint Zaw
Date				: 	03/01/2023
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

	global dtasource "Project Nourish 2nd Wave"

	****************************************************************************
	* Mom Diet Module *
	****************************************************************************
	use "$dta/pnourish_mom_diet_final.dta", clear 
	
	
	****************************************************************************
	** Mom Dietary Diversity **
	****************************************************************************
	
	// mom_meal_freq
	tab mom_meal_freq, m 
	sum     mom_meal_freq 
	local   wtmean = round(r(mean), 0.1)
	local 	Nobs	= r(N)
	sum     mom_meal_freq, d
	local   wtmedian = "3" // round(`r(p50)', 0.1)
	
	* Plot
	* ----
	twoway  (kdensity mom_meal_freq , 	color($cpi2)), ///
			xline(`wtmean', 	lcolor(maroon) 		lpattern(dash)) ///
			xline(`wtmedian', 	lcolor(navy)	 	lpattern(dash)) ///
			xtitle(Birth-weight (lb)) ///
			/*xlabel(0 "0" `wtmedian' "Median=`wtmedian', Mean=`wtmean'" 10 "10"  20 "20" 30 "30" 40 "40", angle(45))*/ ///
			ytitle(Density) ///
			title("Distribution of Mother Meals Consumption Frequency (24 hours recall)" , 		///
					justification(left) color(black) span pos(11) size(medium)) 							///
			plotregion(fcolor(white)) 														///
			graphregion(fcolor(white)) ///
			note(	"Median: `wtmedian'" "Mean: `wtmean'" ///
					"Obs: `Nobs'" ///
					"Source: $dtasource", size(vsmall) span)

	graph export "$plots/14_mom_meal_frequency_distribution.png", replace
	
	
	// Food Groups
	local fgs 	mddw_grain mddw_pulses mddw_nut mddw_milk mddw_meat ///
				mddw_moom_egg mddw_green_veg mddw_vit_vegfruit ///
				mddw_oth_veg mddw_oth_fruit
				

	foreach var in `fgs' {
		
		replace `var' = `var' * 100 

	}
	
	sum mddw_grain 
	local Nobs = r(N)
	
	graph hbar 	(mean) mddw_grain (mean) mddw_pulses (mean) mddw_nut ///
				(mean) mddw_milk (mean) mddw_meat (mean) mddw_moom_egg ///
				(mean) mddw_green_veg (mean) mddw_vit_vegfruit (mean) mddw_oth_veg ///
				(mean) mddw_oth_fruit, ///
				nofill 																			///
				bargap(20) 																		///
				bar(1, color($blue4) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(2, color($cpi1) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(3, color(maroon) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(4, color($cpi2) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(5, color($cpi2*0.7) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(6, color($cpi4) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(7, color($cpi4) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(8, color(erose) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(9, color($cpi5) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(10, color($blue9) lwidth(thin) lcolor(black) lalign(outside))			///
				blabel(bar, format(%9.1f) size(vsmall))														///	
				legend(off) 																	///
				showyvars 																		///
				yvaroptions(relabel( 															///
					1	"Grains, roots, and tubers" /// 
					2	"Pulses"  ///
					3	"Nuts and seeds"  ///
					4	"Dairy" /// 
					5	"Meat, poultry, and fish" /// 
					6	"Eggs" ///
					7	"Dark leafy greens and vegetables" ///
					8	"Other Vitamin A-rich fruits and vegetables" ///
					9	"Other vegetables" ///
					10	"Other fruits")											///
				label(labsize(tiny)))															///
				l1title("Food Groups", size(small)) 											///
				ytitle("Share of Women [Pregnant and Lactating Women]", size(small) height(-6))								///
				title("Share of Food Groups Consumed by Women (24 hours recall)", 		///
						justification(left) color(black) span pos(11) size(medium)) 							///
				plotregion(fcolor(white)) 														///
				graphregion(fcolor(white)) ///
				note(	"Obs: `Nobs'" "Source: $dtasource", size(vsmall) span)		

						* Add percentage to labels
		local nb=`.Graph.plotregion1.barlabels.arrnels'
		forval i=1/`nb' {
		  di "`.Graph.plotregion1.barlabels[`i'].text[1]'"
		  .Graph.plotregion1.barlabels[`i'].text[1]="`.Graph.plotregion1.barlabels[`i'].text[1]'%"
		}
		.Graph.drawgraph
		
	graph export "$plots/15_mom_fooditems.png", replace

								
	// mddw_score
	sum     mddw_score 
	local   wtmean = "4.8" // round(r(mean), 0.1)
	local 	Nobs	= r(N)
	sum     mddw_score, d
	local   wtmedian = "5" // round(`r(p50)', 0.1)
	
	* Plot
	* ----
	twoway  (kdensity mddw_score , 	color($cpi2)), ///
			xline(`wtmean', 	lcolor(maroon) 		lpattern(dash)) ///
			xline(`wtmedian', 	lcolor(navy)	 	lpattern(dash)) ///
			xtitle(Birth-weight (lb)) ///
			/*xlabel(0 "0" `wtmedian' "Median=`wtmedian', Mean=`wtmean'" 10 "10"  20 "20" 30 "30" 40 "40", angle(45))*/ ///
			ytitle(Density) ///
			title("Distribution of MDD-W Score (24 hours recall)" "Minimum Dietary Diversity for Women [0-10]" , 		///
					justification(left) color(black) span pos(11) size(medium)) 							///
			plotregion(fcolor(white)) 														///
			graphregion(fcolor(white)) ///
			note(	"Median: `wtmedian'" "Mean: `wtmean'" ///
					"Obs: `Nobs'" ///
					"Source: $dtasource", size(vsmall) span)

	graph export "$plots/16_mom_mddw_distribution.png", replace

	
	// mddw_yes
	tab mddw_yes, m 
	sum mddw_yes
	local Nobs = r(N)
	tab mddw_yes if mddw_yes == 0
	local survey_no = r(N)
	tab mddw_yes if mddw_yes == 1
	local survey_yes = r(N)

	graph pie, over(mddw_yes) 															///
		sort descending 																			///
		ptext(170 37 "(`survey_yes')"  $ptext_format)			 ///
		ptext(5 35  "(`survey_no')" $ptext_format)			 ///
		pie(1 ,color($cpi2)) 																	///
		pie(2 ,color($blue9)) 																		///
		plabel(1 percent, size(small) format(%2.0f) gap(1))									///	
		plabel(2 percent, size(small) format(%2.0f) gap(1))									///	
		plabel(1 "Yes", color(black) size(vsmall) gap(20) format(%2.0f))				///
		plabel(2 "No", color(black) size(vsmall) gap(20) format(%2.0f))				///
		line(lcolor(black) lalign(center))															///
		title("Share of Women Who Met MDD-W:" "[>= 5 Food Groups out of 10]", 													///
				justification(left) color(black) span pos(11) margin(medsmall))  					///				
		graphregion(fcolor(white)) 																	///
		legend(region(lstyle(none))) 																///
		legend(off) note("n=`Nobs'" "Source: $dtasource", size(vsmall))	 	
		
	graph export "$plots/17_mom_mddw.png", replace




// END HERE 



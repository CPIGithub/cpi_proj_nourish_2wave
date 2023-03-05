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

	global dtasource "Project Nourish 2nd Wave"

	
	use "$dta/pnourish_child_iycf_final.dta", clear   

	****************************************************************************
	** IYCF Indicators **
	****************************************************************************
	// breastfeeding 
	local i = 1
	
	foreach var of varlist 	eibf ebf2d ebf pre_bf mixmf bof cbf  {
	    	
		replace `var' = `var' * 100 
		
		sum `var'
		local n_`i'	= r(N)
		
		local i = `i' + 1
	}
	
	
	graph hbar 	(mean) eibf (mean) ebf2d (mean) ebf ///
				(mean) pre_bf (mean) mixmf (mean) bof ///
				(mean) cbf, ///
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
					1	"EIBF [0-23] (`n_1')"  ///
					2	"EBF2D [0-23] (`n_2')"  ///
					3	"EBF [0-6] (`n_3')" ///
					4	"Pre-BF [0-6] (`n_4')" /// 
					5	"MixMF [0-6] (`n_5')" /// 
					6	"BoF [0-23] (`n_6')" ///
					7	"CBF [12-23] (`n_7')")											///
				label(labsize(tiny)))															///
				l1title("Breastfeeding Indicators", size(small)) 											///
				ytitle("Share of U2 children [0-23 months]", size(small) height(-6))								///
				title("Distribution of Brestfeeding Indicators:" "[0-23 months]", 		///
						justification(left) color(black) span pos(11) size(medium)) 							///
				plotregion(fcolor(white)) 														///
				graphregion(fcolor(white)) ///
				note(	"Early iinitiation of breasfeeding (EIBF)"	///
						"Exclusively breastfed for the first two days after birth (EBF2D)" ///
						"Exclusive breastfeeding under six months (EBF)" ///
						"Predominant breastfeeding under six months (Pre-BF)" ///
						"Mixed milk feeding under 6 months (MixMF)" ///
						"Bottle feeding 0-23 months (BoF)" ///
						"Continious breastfeeding 12-23 months (CBF)" ///
						"" ///
						"Source: $dtasource", size(tiny) span)		

						* Add percentage to labels
		local nb=`.Graph.plotregion1.barlabels.arrnels'
		forval i=1/`nb' {
		  di "`.Graph.plotregion1.barlabels[`i'].text[1]'"
		  .Graph.plotregion1.barlabels[`i'].text[1]="`.Graph.plotregion1.barlabels[`i'].text[1]'%"
		}
		.Graph.drawgraph
		
	graph export "$plots/18_child_breastfeed.png", replace
	

	// INTRODUCTION OF SOLID, SEMI-SOLID OR SOFT FOODS 6–8 MONTHS (ISSSF)
	// isssf
	tab isssf, m 
	sum isssf
	local Nobs = r(N)
	tab isssf if isssf == 0
	local survey_no = r(N)
	tab isssf if isssf == 1
	local survey_yes = r(N)

	graph pie, over(isssf) 															///
		sort descending 																			///
		ptext(145 35 "(`survey_yes')"  $ptext_format)			 ///
		ptext(-15 33  "(`survey_no')" $ptext_format)			 ///
		pie(1 ,color($cpi2)) 																	///
		pie(2 ,color($blue9)) 																		///
		plabel(1 percent, size(small) format(%2.0f) gap(1))									///	
		plabel(2 percent, size(small) format(%2.0f) gap(1))									///	
		plabel(1 "Yes", color(black) size(vsmall) gap(20) format(%2.0f))				///
		plabel(2 "No", color(black) size(vsmall) gap(20) format(%2.0f))				///
		line(lcolor(black) lalign(center))															///
		title("Introduction of solid, semi-solid or soft foods 6-8 months (ISSSF)", 													///
				justification(left) color(black) span pos(11) margin(medsmall))  					///				
		graphregion(fcolor(white)) 																	///
		legend(region(lstyle(none))) 																///
		legend(off) note("n=`Nobs'" "Source: $dtasource", size(vsmall))	 	
		
	graph export "$plots/19_child_intro_solid.png", replace

	
	
	
	
	foreach var of varlist 	food_g1 food_g2 food_g3 food_g4 food_g5 food_g6 food_g7 food_g8 {
	    	
		replace `var' = `var' * 100 

	}
	
	sum food_g1
	local Nobs = r(N)
	
	graph hbar 	(mean) food_g1 (mean) food_g2 (mean) food_g3 ///
				(mean) food_g4 (mean) food_g5 (mean) food_g6 ///
				(mean) food_g7 (mean) food_g8, ///
				nofill 																			///
				bargap(20) 																		///
				bar(1, color($cpi1) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(2, color($cpi2) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(3, color($cpi2*0.7) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(4, color($cpi3) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(5, color($cpi3) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(6, color($cpi4) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(7, color($cpi5) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(8, color($blue4) lwidth(thin) lcolor(black) lalign(outside))			///
				blabel(bar, format(%9.1f) size(vsmall))														///	
				legend(off) 																	///
				showyvars 																		///
				yvaroptions(relabel( 															///
					1	"Breastmilk"  ///
					2	"Grains, roots and tubers"  ///
					3	"Pulses, nuts and seeds" ///
					4	"Dairy products" /// 
					5	"Flesh foods" /// 
					6	"Eggs" ///
					7	"Vit-A rich fruits and vegetables" ///
					8	"Other fruits and vegetables")											///
				label(labsize(tiny)))															///
				l1title("Food Groups", size(small)) 											///
				ytitle("Share of U2 children [6-23 months]", size(small) height(-6))								///
				title("Share of Food Group Consumped by U2 Children:" "[0-23 months]", 		///
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
		
	graph export "$plots/20_child_foodconsumption.png", replace
	

	// MINIMUM DIETARY DIVERSITY 6–23 MONTHS (MDD)
	tab dietary_tot, m 

	sum     dietary_tot 
	local   wtmean = "3.9" // round(r(mean), 0.1)
	local 	Nobs	= r(N)
	sum     dietary_tot, d
	local   wtmedian = "4" // round(`r(p50)', 0.1)
	
	* Plot
	* ----
	twoway  (kdensity dietary_tot , 	color($cpi2)), ///
			xline(`wtmean', 	lcolor(maroon) 		lpattern(dash)) ///
			xline(`wtmedian', 	lcolor(navy)	 	lpattern(dash)) ///
			xtitle(Birth-weight (lb)) ///
			/*xlabel(0 "0" `wtmedian' "Median=`wtmedian', Mean=`wtmean'" 10 "10"  20 "20" 30 "30" 40 "40", angle(45))*/ ///
			ytitle(Density) ///
			title("Distribution of Child Dietary Diversity Score [0-8]" , 		///
					justification(left) color(black) span pos(11) size(medium)) 							///
			plotregion(fcolor(white)) 														///
			graphregion(fcolor(white)) ///
			note(	"Median: `wtmedian'" "Mean: `wtmean'" ///
					"Obs: `Nobs'" ///
					"Source: $dtasource", size(vsmall) span)

	graph export "$plots/21_child_DDS.png", replace
	

	local mind mdd mmf mad 
		
	local i = 1
	
	foreach var in `mind' {
		
		replace `var' = `var' * 100
		
		sum `var'
		local n_`i'	= r(N)
		
		local i = `i' + 1
		
	}
	

	
	graph hbar 	(mean) mdd (mean) mmf (mean) mad, ///
				nofill 																			///
				bargap(20) 																		///
				bar(1, color($cpi1) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(2, color($cpi2) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(3, color($cpi3) lwidth(thin) lcolor(black) lalign(outside))			///
				blabel(bar, format(%9.1f) size(vsmall))														///	
				legend(off) 																	///
				showyvars 																		///
				yvaroptions(relabel( 															///
					1 `"""Minimum Dietary Diversity" "(`n_1')"""'														///
					2 `"""Minimum Meal Frequency" "(`n_2')"""'															///
					3 `"""Minimum Acceptable Diet" "(`n_3')"""')											///
				label(labsize(tiny)))															///
				l1title("Type of Indicators", size(small)) 											///
				ytitle("Share of U5 children [6-23 months]", size(small) height(-6))								///
				title("Proportion of Children with Minimum Dietary Practices", 		///
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
		
	graph export "$plots/22_child_min_diet.png", replace

	&&&&
	// MINIMUM MEAL FREQUENCY 6–23 MONTHS (MMF)
	
	local bfnbf mmf_bf mmf_nonbf mad_bf mad_nobf
	
	lab var mmf_bf_6to8 "Breastfeeding MMF - 6 to 8 months"
	tab mmf_bf_6to8, m 

	// 9-23 breastfed child
	lab var mmf_bf_9to23 "Breastfeeding MMF - 9 to 23 months"
	tab mmf_bf_9to23, m 

	lab var mmf_bf "Breastfeeding MMF"
	tab mmf_bf, m 

	// non-breastfeed 6-23 months
	lab var mmf_nonbf "Non-Breastfeeding MMF"
	tab mmf_nonbf, m 

	lab var mmf "Minimum Meal Frequency"
	tab mmf, m 


	// MINIMUM MILK FEEDING FREQUENCY FOR NON-BREASTFED CHILDREN 6–23 MONTHS (MMFF)
	lab var mmff "Minimum milk feeding frequency for non-breastfed children"
	tab mmff, m 

	// MINIMUM ACCEPTABLE DIET 6–23 MONTHS (MAD)
	lab var mad "Minimum Acceptable Diet"
	tab mad, m 


	lab var mad_bf "Minimum Acceptable Diet (Breastfeeding)"
	tab mad_bf, m 


	lab var mad_nobf "Minimum Acceptable Diet (non-Breastfeeding)"
	tab mad_nobf, m 




// END HERE 



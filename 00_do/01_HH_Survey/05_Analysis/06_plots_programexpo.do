/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: Program exposure data cleaning 			
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
	* HH Level Dataset *
	****************************************************************************
	use "$dta/pnourish_program_exposure_final.dta", clear 
	
	// prgexpo_pn 
	tab prgexpo_pn, m 
	sum prgexpo_pn
	local Nobs = r(N)
	tab prgexpo_pn if prgexpo_pn == 0
	local survey_no = r(N)
	tab prgexpo_pn if prgexpo_pn == 1
	local survey_yes = r(N)

	graph pie, over(prgexpo_pn) 															///
		sort descending 																			///
		ptext(155 40 "(`survey_yes')"  $ptext_format)			 ///
		ptext(0 35  "(`survey_no')" $ptext_format)			 ///
		pie(1 ,color($cpi2)) 																	///
		pie(2 ,color($blue9)) 																		///
		plabel(1 percent, size(small) format(%2.0f) gap(1))									///	
		plabel(2 percent, size(small) format(%2.0f) gap(1))									///	
		plabel(1 "Yes", color(black) size(vsmall) gap(20) format(%2.0f))				///
		plabel(2 "No", color(black) size(vsmall) gap(20) format(%2.0f))				///
		line(lcolor(black) lalign(center))															///
		title("Share of Household Know the Project Nourish", 													///
				justification(left) color(black) span pos(11) margin(medsmall))  					///				
		graphregion(fcolor(white)) 																	///
		legend(region(lstyle(none))) 																///
		legend(off) note("n=`Nobs'" "Source: $dtasource", size(vsmall))	 	

		
	graph export "$plots/09_pn_know.png", replace
	
	// prgexpo_join 
	local pnact 	prgexpo_join0 prgexpo_join1 prgexpo_join2 prgexpo_join3 prgexpo_join4 ///
					prgexpo_join5 prgexpo_join6 prgexpo_join7 prgexpo_join8 ///
					prgexpo_join888 

	
	foreach var in `pnact' {
		
		replace `var' = `var' * 100 

	}
	
	sum prgexpo_join0 
	local Nobs = r(N)
	
	graph hbar 	(mean) prgexpo_join0 (mean) prgexpo_join1 (mean) prgexpo_join2 ///
				(mean) prgexpo_join3 (mean) prgexpo_join4 (mean) prgexpo_join5 ///
				(mean) prgexpo_join6 (mean) prgexpo_join7 (mean) prgexpo_join8 ///
				(mean) prgexpo_join888, ///
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
					1	"Don't Know'" /// 
					2	"Covid-19 Food Support"  ///
					3	"Covid-19 Kits"  ///
					4	"Food/Cash for Food" /// 
					5	"WASH Infra Support" /// 
					6	"SBCC" ///
					7	"Mother Support Group" ///
					8	"Home Gardening" ///
					9	"MUAC Screening" ///
					10	"Other")											///
				label(labsize(tiny)))															///
				l1title("Project Nourish's Activities", size(small)) 											///
				ytitle("Share of Household [with U5 Children]", size(small) height(-6))								///
				title("Share of Household exposured to Project Nourish's Activities", 		///
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
		
	graph export "$plots/10_pn_activities.png", replace

	
	* prgexp_iec0
	local iecs	prgexp_iec0 prgexp_iec1 prgexp_iec2 prgexp_iec3 prgexp_iec4 ///
				prgexp_iec5 prgexp_iec6 prgexp_iec7 
				
	
	
	foreach var in `iecs' {
		
		replace `var' = `var' * 100 

	}
	
	sum prgexp_iec0 
	local Nobs = r(N)
	
	graph hbar 	(mean) prgexp_iec0 (mean) prgexp_iec1 (mean) prgexp_iec2 ///
				(mean) prgexp_iec3 (mean) prgexp_iec4 (mean) prgexp_iec5 ///
				(mean) prgexp_iec6 (mean) prgexp_iec7, ///
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
				blabel(bar, format(%9.1f) size(vsmall))														///	
				legend(off) 																	///
				showyvars 																		///
				yvaroptions(relabel( 															///
					1	"Never seem before" /// 
					2	"Stunting infograph"  ///
					3	"Wasting infograph"  ///
					4	"Low-birth-weight infograph" /// 
					5	"Anaemia infograph" /// 
					6	"Breastfeeding infograph" ///
					7	"IYCF poster" ///
					8	"Power of 1000 days infograph")											///
				label(labsize(tiny)))															///
				l1title("Project Nourish's IECs", size(small)) 											///
				ytitle("Share of Household [with U5 Children]", size(small) height(-6))								///
				title("Share of Household exposured to Project Nourish's IECs", 		///
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
		
	graph export "$plots/10_pn_iecs.png", replace	
	
	
	
	

// END HERE 



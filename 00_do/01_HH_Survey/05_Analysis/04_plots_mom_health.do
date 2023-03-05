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


	****************************************************************************
	* Mom Health Module *
	****************************************************************************
	use "$dta/pnourish_mom_health_final.dta", clear 
	
	
	****************************************************************************
	** Mom ANC **
	****************************************************************************
	// anc_yn 
	sum anc_yn
	local Nobs1 = r(N)
	tab anc_yn if anc_yn == 0
	local survey_no = r(N)
	tab anc_yn if anc_yn == 1
	local survey_yes = r(N)

	graph pie, over(anc_yn) 															///
		sort descending 																			///
		ptext(155 35 "(`survey_yes')"  $ptext_format)			 ///
		ptext(0 35  "(`survey_no')" $ptext_format)			 ///
		pie(1 ,color($cpi2)) 																	///
		pie(2 ,color($blue9)) 																		///
		plabel(1 percent, size(small) format(%2.0f) gap(1))									///	
		plabel(2 percent, size(small) format(%2.0f) gap(1))									///	
		plabel(1 "Yes", color(black) size(vsmall) gap(20) format(%2.0f))				///
		plabel(2 "No", color(black) size(vsmall) gap(20) format(%2.0f))				///
		line(lcolor(black) lalign(center))															///
		title("Antenatal Care (ANC)", 													///
				justification(left) color(black) span pos(11) margin(medsmall))  					///				
		graphregion(fcolor(white)) 																	///
		legend(region(lstyle(none))) 																///
		legend(off)  	///
		name("anc_yn", replace)		
	
	
	* pnc_yn     
	sum pnc_yn
	local Nobs2 = r(N)
	tab pnc_yn if pnc_yn == 0
	local survey_no = r(N)
	tab pnc_yn if pnc_yn == 1
	local survey_yes = r(N)

	graph pie, over(pnc_yn) 															///
		sort descending 																			///
		ptext(155 35 "(`survey_yes')"  $ptext_format)			 ///
		ptext(-10 32  "(`survey_no')" $ptext_format)			 ///
		pie(1 ,color($cpi2)) 																	///
		pie(2 ,color($blue9)) 																		///
		plabel(1 percent, size(small) format(%2.0f) gap(1))									///	
		plabel(2 percent, size(small) format(%2.0f) gap(1))									///	
		plabel(1 "Yes", color(black) size(vsmall) gap(20) format(%2.0f))				///
		plabel(2 "No", color(black) size(vsmall) gap(20) format(%2.0f))				///
		line(lcolor(black) lalign(center))															///
		title("Postnatal Care (PNC)", 													///
				justification(left) color(black) span pos(11) margin(medsmall))  					///				
		graphregion(fcolor(white)) 																	///
		legend(region(lstyle(none))) 																///
		legend(off)  	///
		name("pnc_yn", replace)		

	
	* nbc_yn 
	sum nbc_yn
	local Nobs3 = r(N)
	tab nbc_yn if nbc_yn == 0
	local survey_no = r(N)
	tab nbc_yn if nbc_yn == 1
	local survey_yes = r(N)

	graph pie, over(nbc_yn) 															///
		sort descending 																			///
		ptext(150 35 "(`survey_yes')"  $ptext_format)			 ///
		ptext(-5 35  "(`survey_no')" $ptext_format)			 ///
		pie(1 ,color($cpi2)) 																	///
		pie(2 ,color($blue9)) 																		///
		plabel(1 percent, size(small) format(%2.0f) gap(1))									///	
		plabel(2 percent, size(small) format(%2.0f) gap(1))									///	
		plabel(1 "Yes", color(black) size(vsmall) gap(20) format(%2.0f))				///
		plabel(2 "No", color(black) size(vsmall) gap(20) format(%2.0f))				///
		line(lcolor(black) lalign(center))															///
		title("Newborn Care (NBC)", 													///
				justification(left) color(black) span pos(11) margin(medsmall))  					///				
		graphregion(fcolor(white)) 																	///
		legend(region(lstyle(none))) 																///
		legend(off)  	///
		name("nbc_yn", replace)		

	
	 ** Combined Plots **
	graph combine   anc_yn pnc_yn nbc_yn, ///
					rows(1) ///
					imargin(0 0 0 0) graphregion(margin(l=22 r=22)) ///
                    graphregion(color(white)) plotregion(color(white)) ///
					title("Mother Health Seeking Behaviours", 								///
						justification(left) color(black) span pos(11) size(large)) ///
					note(	"ANC:`Nobs1' obs" ///
							"PNC:`Nobs2' obs" ///
							"NBC:`Nobs3' obs" ///
							"Source: $dtasource", size(vsmall) span) ///  
					xsize(8) ysize(2)
						
				
	graph export "$plots/23_mom_health_anc_pnc_nbc.png", replace
	
	
	// anc_where 
	tab anc_where
	levelsof anc_where, local(levels)
	foreach x in `levels' {
		
		gen anc_where_`x' = (anc_where == `x') *100
		replace anc_where_`x' = .m if mi(anc_where)
		tab anc_where_`x', m 
		
	}
	
	sum anc_where 
	local Nobs = r(N)
	
	graph hbar 	(mean) anc_where_1 (mean) anc_where_2 (mean) anc_where_3 ///
				(mean) anc_where_4 (mean) anc_where_5 (mean) anc_where_7 ///
				(mean) anc_where_888 , ///
				nofill 																			///
				bargap(20) 																		///
				bar(1, color($blue4) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(2, color($cpi1) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(3, color($cpi2) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(4, color($cpi2*0.7) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(5, color($cpi3) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(6, color($cpi4) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(7, color($cpi5) lwidth(thin) lcolor(black) lalign(outside)) 			///
				/*bar(8, color($blue4*0.4) lwidth(thin) lcolor(black) lalign(outside))*/			///
				blabel(bar, format(%9.1f) size(vsmall))														///	
				legend(off) 																	///
				showyvars 																		///
				yvaroptions(relabel( 															///
					1 "Home"														///
					2 "Government hospital" 															///
					3 "Private Clinic" 													///
					4 "SRHC-RHC"															///
					5 "EHO Clinic"												///
					6  "Routine ANC place within village"														///
					8 "Other")											///
				label(labsize(tiny)))															///
				l1title("Type of institutions", size(small)) 											///
				ytitle("Share of U2 Mothers", size(small) height(-6))								///
				title("Share of Institutions Taking Treatment for ANC:", 		///
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

	graph export "$plots/24_mom_health_anc_where.png", replace

	
		
	****************************************************************************
	** Mom Deliverty **
	****************************************************************************
	// deliv_place 
/*	
	1	Home
	2	Government hospital
	3	Private Clinic
	4	SRHC-RHC
	5	EHO Clinic
	6	EHO clinic mobile team (within village)
	888	Other (specify)
*/
	tab deliv_place, m 
	levelsof deliv_place, local(levels)
	foreach x in `levels' {
		
		gen deliv_place_`x' = (deliv_place == `x') *100
		replace deliv_place_`x' = .m if mi(deliv_place)
		tab deliv_place_`x', m 
		
	}
	
	sum deliv_place 
	local Nobs = r(N)
	
	graph hbar 	(mean) deliv_place_1 (mean) deliv_place_2 (mean) deliv_place_3 ///
				(mean) deliv_place_4 (mean) deliv_place_5 (mean) deliv_place_888 , ///
				nofill 																			///
				bargap(20) 																		///
				bar(1, color($blue4) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(2, color($cpi1) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(3, color($cpi2) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(4, color($cpi2*0.7) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(5, color($cpi3) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(6, color($cpi4) lwidth(thin) lcolor(black) lalign(outside))			///
				/*bar(7, color($cpi5) lwidth(thin) lcolor(black) lalign(outside))*/ 			///
				/*bar(8, color($blue4*0.4) lwidth(thin) lcolor(black) lalign(outside))*/			///
				blabel(bar, format(%9.1f) size(vsmall))														///	
				legend(off) 																	///
				showyvars 																		///
				yvaroptions(relabel( 															///
					1 "Home"														///
					2 "Government hospital" 															///
					3 "Private Clinic" 													///
					4 "SRHC-RHC"															///
					5 "EHO Clinic"												///
					6 "Other")											///
				label(labsize(tiny)))															///
				l1title("Type of institutions", size(small)) 											///
				ytitle("Share of U2 Mothers", size(small) height(-6))								///
				title("Share of Institutions Where Mothers are Receiving Delivery Care", 		///
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

	graph export "$plots/25_mom_health_deli_where.png", replace
	


	// deliv_assist
/*
	1	Doctor 
	2	Nurse 
	3	Health assistant 
	4	Private doctor 
	5	LHV 
	6	Midwife 
	7	AMW 
	8	Ethnic health worker
	9	Community Health Worker 
	10	TBA
	11	On my own
	12	Relatives
	888	Other (specify)
	999	Don't Know

*/
	tab deliv_assist
	levelsof deliv_assist, local(levels)
	foreach x in `levels' {
		
		gen deliv_assist_`x' = (deliv_assist == `x') * 100
		replace deliv_assist_`x' = .m if mi(deliv_assist)
		tab deliv_assist_`x', m 
		
	}
	
	sum deliv_assist 
	local Nobs = r(N)
	
	graph hbar 	(mean) deliv_assist_1 (mean) deliv_assist_2 (mean) deliv_assist_4 ///
				(mean) deliv_assist_5 (mean) deliv_assist_6 (mean) deliv_assist_7 ///
				(mean) deliv_assist_8 (mean) deliv_assist_10 (mean) deliv_assist_11 ///
				(mean) deliv_assist_12 (mean) deliv_assist_888, ///
				nofill 																			///
				bargap(20) 																		///
				bar(1, color($cpi1) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(2, color(maroon) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(3, color(maroon*0.6) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(4, color($cpi2) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(5, color($cpi2*0.7) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(6, color($cpi3) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(7, color(erose) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(8, color(erose*0.5) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(9, color(maroon*0.2) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(10, color(erose*0.2) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(11, color($white) lwidth(thin) lcolor(black) lalign(outside)) 			///
				blabel(bar, format(%9.1f) size(vsmall))														///	
				legend(off) 																	///
				showyvars 																		///
				yvaroptions(relabel( 															///
					1	"Doctor" /// 
					2	"Nurse" ///
					3	"Private Doctor" ///
					4	"LHV" ///
					5	"Midwife" /// 
					6	"AMW"  ///
					7	"Ethnic Health Worker" ///
					8	"TBA" ///
					9	"On my own" ///
					10	"Relatives" ///
					11	"Other")											///
				label(labsize(tiny)))															///
				l1title("Health Care Professional", size(small)) 											///
				ytitle("Share of U2 Mothers", size(small) height(-6))								///
				title("Share of Deliveries Assisted by Healthcare Professionals", 		///
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
		
	graph export "$plots/25_mom_health_deli_who.png", replace
	
	

	****************************************************************************
	** Mom PNC **
	****************************************************************************
/*	
	1	Home
	2	Government hospital
	3	Private Clinic
	4	SRHC-RHC
	5	EHO Clinic
	6	EHO clinic mobile team (within village)
	888	Other (specify)
*/
	// pnc_where 
	tab pnc_where
	levelsof pnc_where, local(levels)
	foreach x in `levels' {
		
		gen pnc_where_`x' = (pnc_where == `x') *100
		replace pnc_where_`x' = .m if mi(pnc_where)
		tab pnc_where_`x', m 
		
	}
	
	sum pnc_where 
	local Nobs = r(N)
	
	graph hbar 	(mean) pnc_where_1 (mean) pnc_where_2 (mean) pnc_where_3 ///
				(mean) pnc_where_4 (mean) pnc_where_5 (mean) pnc_where_888 , ///
				nofill 																			///
				bargap(20) 																		///
				bar(1, color($blue4) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(2, color($cpi1) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(3, color($cpi2) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(4, color($cpi2*0.7) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(5, color($cpi3) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(6, color($cpi4) lwidth(thin) lcolor(black) lalign(outside))			///
				/*bar(7, color($cpi5) lwidth(thin) lcolor(black) lalign(outside))*/ 			///
				/*bar(8, color($blue4*0.4) lwidth(thin) lcolor(black) lalign(outside))*/			///
				blabel(bar, format(%9.1f) size(vsmall))														///	
				legend(off) 																	///
				showyvars 																		///
				yvaroptions(relabel( 															///
					1 "Home"														///
					2 "Government hospital" 															///
					3 "Private Clinic" 													///
					4 "SRHC-RHC"															///
					5 "EHO Clinic"												///
					6 "Other")											///
				label(labsize(tiny)))															///
				l1title("Type of institutions", size(small)) 											///
				ytitle("Share of U2 Mothers", size(small) height(-6))								///
				title("Share of Institutions Taking Care for PNC:", 		///
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

	graph export "$plots/26_mom_health_pnc_where.png", replace
	
	****************************************************************************
	** Mom PNC **
	****************************************************************************
/*	
	1	Home
	2	Government hospital
	3	Private Clinic
	4	SRHC-RHC
	5	EHO Clinic
	6	EHO clinic mobile team (within village)
	888	Other (specify)
*/
	
	// nbc_where
	tab nbc_where
	levelsof nbc_where, local(levels)
	foreach x in `levels' {
		
		gen nbc_where_`x' = (nbc_where == `x') *100
		replace nbc_where_`x' = .m if mi(nbc_where)
		tab nbc_where_`x', m 
		
	}
	
	sum nbc_where 
	local Nobs = r(N)
	
	graph hbar 	(mean) nbc_where_1 (mean) nbc_where_2 (mean) nbc_where_3 ///
				(mean) nbc_where_4 (mean) nbc_where_5 (mean) nbc_where_888 , ///
				nofill 																			///
				bargap(20) 																		///
				bar(1, color($blue4) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(2, color($cpi1) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(3, color($cpi2) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(4, color($cpi2*0.7) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(5, color($cpi3) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(6, color($cpi4) lwidth(thin) lcolor(black) lalign(outside))			///
				/*bar(7, color($cpi5) lwidth(thin) lcolor(black) lalign(outside))*/ 			///
				/*bar(8, color($blue4*0.4) lwidth(thin) lcolor(black) lalign(outside))*/			///
				blabel(bar, format(%9.1f) size(vsmall))														///	
				legend(off) 																	///
				showyvars 																		///
				yvaroptions(relabel( 															///
					1 "Home"														///
					2 "Government hospital" 															///
					3 "Private Clinic" 													///
					4 "SRHC-RHC"															///
					5 "EHO Clinic"												///
					6 "Other")											///
				label(labsize(tiny)))															///
				l1title("Type of institutions", size(small)) 											///
				ytitle("Share of U2 Mothers", size(small) height(-6))								///
				title("Share of Institutions Taking Care for NBC:", 		///
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

	graph export "$plots/27_mom_health_nbc_where.png", replace

// END HERE 



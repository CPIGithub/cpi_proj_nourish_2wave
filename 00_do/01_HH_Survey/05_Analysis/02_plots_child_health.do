/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: child health data cleaning 			
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
	* Child Health Data *
	****************************************************************************
	use "$dta/pnourish_child_health_final.dta", clear 
	

	****************************************************************************
	** Child Birth Weight **
	****************************************************************************

	local i = 1
	
	foreach var of varlist 	child_vaccin child_vaccin_card child_deworm child_vita child_low_bwt {
	    	
		replace `var' = `var' * 100 
		
		sum `var'
		local n_`i'	= r(N)
		
		local i = `i' + 1
	}
	
	graph hbar 	(mean) child_vaccin (mean) child_vaccin_card (mean) child_deworm ///
				(mean) child_vita (mean) child_low_bwt , ///
				nofill 																			///
				bargap(20) 																		///
				bar(1, color($cpi1) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(2, color($cpi2) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(3, color($cpi3) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(4, color($cpi4) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(5, color($cpi5) lwidth(thin) lcolor(black) lalign(outside))			///
				blabel(bar, format(%9.1f))														///	
				legend(off) 																	///
				showyvars 																		///
				yvaroptions(relabel( 															///
					1 "Immunized Children (`n_1')"														///
					2 "Immunization Card (`n_2')" 														///
					3 "Deworming (`n_3')"														///
					4 "Vit-A (`n_4')" 														///
					5 "Low-Birth Weight (`n_5')")											///
				label(labsize(vsmall)))															///
				l1title("Indicators", size(small)) 											///
				ytitle("Share of U5 children [0-5 years old]", size(small) height(-6))								///
				title("Immunization and Vitamin Supplementation [0-5 years old Children]", 		///
						justification(left) color(black) span pos(11) size(medium)) 							///
				plotregion(fcolor(white)) 														///
				graphregion(fcolor(white)) ///
				note(	"Source: $dtasource", size(vsmall) span)
				
	* Add percentage to labels
		local nb=`.Graph.plotregion1.barlabels.arrnels'
		forval i=1/`nb' {
		  di "`.Graph.plotregion1.barlabels[`i'].text[1]'"
		  .Graph.plotregion1.barlabels[`i'].text[1]="`.Graph.plotregion1.barlabels[`i'].text[1]'%"
		}
		.Graph.drawgraph
	
	graph export "$plots/01_child_health_immu_suplement.png", replace
			
			
	
	sum     child_bwt_lb 
	local   wtmean = round(r(mean), 0.1)
	local 	Nobs	= r(N)
	sum     child_bwt_lb, d
	local   wtmedian = "6.6" // round(`r(p50)', 0.1)
	
	* Plot
	* ----
	twoway  (kdensity child_bwt_lb , 	color($cpi2)), ///
			xline(`wtmean', 	lcolor(maroon) 		lpattern(dash)) ///
			xline(`wtmedian', 	lcolor(navy)	 	lpattern(dash)) ///
			xtitle(Birth-weight (lb)) ///
			/*xlabel(0 "0" `wtmedian' "Median=`wtmedian', Mean=`wtmean'" 10 "10"  20 "20" 30 "30" 40 "40", angle(45))*/ ///
			ytitle(Density) ///
			title("Distribution of Number of Children's Birth-weight" , 		///
					justification(left) color(black) span pos(11) size(medium)) 							///
			plotregion(fcolor(white)) 														///
			graphregion(fcolor(white)) ///
			note(	"Median: `wtmedian'" "Mean: `wtmean'" ///
					"Obs: `Nobs'" ///
					"Source: $dtasource", size(vsmall) span)

	graph export "$plots/02_child_birth_weight_plot.png", replace
			
			
			
	********************************************************************************
	** Childood illness: **
	********************************************************************************
	// child_ill 
	    
	sum     child_ill0 
	local 	Nobs	= r(N)
	
	local i = 1
	
	foreach var of varlist 	child_ill0 child_ill1 child_ill2 child_ill3 child_ill888  {
	    	
		replace `var' = `var' * 100 
		
		sum `var'
		local n_`i'	= r(N)
		
		local i = `i' + 1
	}
	
	graph hbar 	(mean) child_ill0 (mean) child_ill1 (mean) child_ill2 ///
				(mean) child_ill3 (mean) child_ill888 , ///
				nofill 																			///
				bargap(20) 																		///
				bar(1, color($cpi1) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(2, color($cpi2) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(3, color($cpi3) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(4, color($cpi4) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(5, color($cpi5) lwidth(thin) lcolor(black) lalign(outside))			///
				blabel(bar, format(%9.1f) size(vsmall))														///	
				legend(off) 																	///
				showyvars 																		///
				yvaroptions(relabel( 															///
					1 "No Diseases"														///
					2 "Diarrhea" 														///
					3 "Cough"														///
					4 "Fever" 														///
					5 "Other Diseases")											///
				label(labsize(vsmall)))															///
				l1title("Type of common childhood illness", size(small)) 											///
				ytitle("Share of U5 children [0-5 years old]", size(small) height(-6))								///
				title("Proportion of Children with Common Childhood Illness:" "[0-5 years old Children]", 		///
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
	
	graph export "$plots/03_child_illness_type.png", replace
	
	
	
	* child_diarrh_treat 
	sum child_diarrh_treat
	local Nobs = r(N)
	tab child_diarrh_treat if child_diarrh_treat == 0
	local survey_no = r(N)
	tab child_diarrh_treat if child_diarrh_treat == 1
	local survey_yes = r(N)

	graph pie, over(child_diarrh_treat) 															///
		sort descending 																			///
		ptext(165 35 "(`survey_yes')"  $ptext_format)			 ///
		ptext(10 35  "(`survey_no')" $ptext_format)			 ///
		pie(1 ,color($cpi2)) 																	///
		pie(2 ,color($blue9)) 																		///
		plabel(1 percent, size(small) format(%2.0f) gap(1))									///	
		plabel(2 percent, size(small) format(%2.0f) gap(1))									///	
		plabel(1 "Yes", color(black) size(vsmall) gap(20) format(%2.0f))				///
		plabel(2 "No", color(black) size(vsmall) gap(20) format(%2.0f))				///
		line(lcolor(black) lalign(center))															///
		title("Diarrhoea", 													///
				justification(left) color(black) span pos(11) margin(medsmall))  					///				
		graphregion(fcolor(white)) 																	///
		legend(region(lstyle(none))) 																///
		legend(off)  	///
		name("child_diarrh_treat", replace)		
	
	
	* child_cough_treat   
	sum child_cough_treat
	local Nobs = r(N)
	tab child_cough_treat if child_cough_treat == 0
	local survey_no = r(N)
	tab child_cough_treat if child_cough_treat == 1
	local survey_yes = r(N)

	graph pie, over(child_cough_treat) 															///
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
		title("Cough", 													///
				justification(left) color(black) span pos(11) margin(medsmall))  					///				
		graphregion(fcolor(white)) 																	///
		legend(region(lstyle(none))) 																///
		legend(off)  	///
		name("child_cough_treat", replace)		

	
	* child_fever_treat 
	sum child_fever_treat
	local Nobs = r(N)
	tab child_fever_treat if child_fever_treat == 0
	local survey_no = r(N)
	tab child_fever_treat if child_fever_treat == 1
	local survey_yes = r(N)

	graph pie, over(child_fever_treat) 															///
		sort descending 																			///
		ptext(150 35 "(`survey_yes')"  $ptext_format)			 ///
		ptext(00 35  "(`survey_no')" $ptext_format)			 ///
		pie(1 ,color($cpi2)) 																	///
		pie(2 ,color($blue9)) 																		///
		plabel(1 percent, size(small) format(%2.0f) gap(1))									///	
		plabel(2 percent, size(small) format(%2.0f) gap(1))									///	
		plabel(1 "Yes", color(black) size(vsmall) gap(20) format(%2.0f))				///
		plabel(2 "No", color(black) size(vsmall) gap(20) format(%2.0f))				///
		line(lcolor(black) lalign(center))															///
		title("Diarrhoea", 													///
				justification(left) color(black) span pos(11) margin(medsmall))  					///				
		graphregion(fcolor(white)) 																	///
		legend(region(lstyle(none))) 																///
		legend(off)  	///
		name("child_fever_treat", replace)		

	
	 ** Combined Plots **
	graph combine   child_diarrh_treat child_cough_treat child_fever_treat, ///
					rows(1) ///
					imargin(0 0 0 0) graphregion(margin(l=22 r=22)) ///
                    graphregion(color(white)) plotregion(color(white)) ///
					title("Seek advice or Treatment for;", 								///
						justification(left) color(black) span pos(11) size(large)) ///
					note("n=`Nobs'" "Source: $dtasource", size(vsmall) span) ///  
					xsize(8) ysize(2)
						
				
	graph export "$plots/04_child_illness_treat_all.png", replace
	
	
	
	***** DIARRHEA *****
	// child_diarrh_where
	tab child_diarrh_where
	levelsof child_diarrh_where, local(levels)
	foreach x in `levels' {
		
		gen child_diarrh_where_`x' = (child_diarrh_where == `x') *100
		replace child_diarrh_where_`x' = .m if mi(child_diarrh_where)
		tab child_diarrh_where_`x', m 
		
	}
	
	sum child_diarrh_where 
	local Nobs = r(N)
	
	graph hbar 	(mean) child_diarrh_where_1 /*(mean) child_diarrh_where_2*/ (mean) child_diarrh_where_3 ///
				(mean) child_diarrh_where_4 (mean) child_diarrh_where_5 /*(mean) child_diarrh_where_6*/  ///
				/*(mean) child_diarrh_where_7 (mean) child_diarrh_where_8*/ ///
				(mean) child_diarrh_where_888 , ///
				nofill 																			///
				bargap(20) 																		///
				bar(1, color($blue4) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(2, color($cpi1) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(3, color($cpi2) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(4, color($cpi2*0.7) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(5, color($cpi3) lwidth(thin) lcolor(black) lalign(outside))			///
				/*bar(6, color($cpi4) lwidth(thin) lcolor(black) lalign(outside))*/			///
				/*bar(7, color($cpi5) lwidth(thin) lcolor(black) lalign(outside))*/ 			///
				/*bar(8, color($blue4*0.4) lwidth(thin) lcolor(black) lalign(outside))*/			///
				blabel(bar, format(%9.1f) size(vsmall))														///	
				legend(off) 																	///
				showyvars 																		///
				yvaroptions(relabel( 															///
					1 "Home"														///
					2 "Private Clinic" /*"Government hospital" 	*/														///
					3 "SRHC-RHC"  /* "Private Clinic" */													///
					4 "EHO Clinic" /* "SRHC-RHC" */ 															///
					5 "Other" /*"EHO Clinic"	*/													///
					/*6 "EHO clinic mobile team (within village)" */															///
					/*7  "Routine ANC place within village"	*/													///
					/*8 "Other"*/)											///
				label(labsize(tiny)))															///
				l1title("Type of institutions", size(small)) 											///
				ytitle("Share of U5 children [0-5 years old]", size(small) height(-6))								///
				title("Share of Institutions Taking Treatment for Diarrhea:" "[0-5 years old Children]", 		///
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
		
	graph export "$plots/05_child_diarrhea_where.png", replace
	

	// child_diarrh_who
	/*
	1	Specialist 
	2	Doctor 
	3	Nurse 
	4	Health assistant 
	5	Private doctor 
	6	LHV 
	7	Midwife 
	8	AMW 
	9	Ethnic health worker
	10	Community Health Worker 
	11	TBA
	888	Other (specify): 
	*/
	tab child_diarrh_who
	levelsof child_diarrh_who, local(levels)
	foreach x in `levels' {
		
		gen child_diarrh_who_`x' = (child_diarrh_who == `x') * 100
		replace child_diarrh_who_`x' = .m if mi(child_diarrh_who)
		tab child_diarrh_who_`x', m 
		
	}
	
	sum child_diarrh_who 
	local Nobs = r(N)
	
	graph hbar 	(mean) child_diarrh_who_2 (mean) child_diarrh_who_3 (mean) child_diarrh_who_7 ///
				(mean) child_diarrh_who_9 (mean) child_diarrh_who_10 ///
				(mean) child_diarrh_who_888 , ///
				nofill 																			///
				bargap(20) 																		///
				bar(1, color($cpi1) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(2, color($cpi2) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(3, color($cpi2*0.7) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(4, color($cpi3) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(5, color($cpi3) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(6, color($cpi4) lwidth(thin) lcolor(black) lalign(outside))			///
				/*bar(7, color($cpi5) lwidth(thin) lcolor(black) lalign(outside))*/ 			///
				/*bar(8, color($blue4) lwidth(thin) lcolor(black) lalign(outside))*/			///
				blabel(bar, format(%9.1f) size(vsmall))														///	
				legend(off) 																	///
				showyvars 																		///
				yvaroptions(relabel( 															///
					1	"Doctor" /// 
					2	"Nurse" /// 
					3	"Midwife" /// 
					4	"Ethnic Health Worker" ///
					5	"Community Health Worker" /// 
					6	"Other")											///
				label(labsize(tiny)))															///
				l1title("Health Care Professional", size(small)) 											///
				ytitle("Share of U5 children [0-5 years old]", size(small) height(-6))								///
				title("Share of Health Care Professional Taking Treatment for Diarrhea:" "[0-5 years old Children]", 		///
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
		
	graph export "$plots/05_child_diarrhea_who.png", replace
	

	
	***** COUGH *****

	
	// child_cough_where
	tab child_cough_where
	levelsof child_cough_where, local(levels)
	foreach x in `levels' {
		
		gen child_cough_where_`x' = (child_cough_where == `x') * 100
		replace child_cough_where_`x' = .m if mi(child_cough_where)
		tab child_cough_where_`x', m 
		
	}
	
	sum child_diarrh_where 
	local Nobs = r(N)
	
	graph hbar 	(mean) child_cough_where_1 (mean) child_cough_where_2 (mean) child_cough_where_3 ///
				(mean) child_cough_where_4 (mean) child_cough_where_5 /*(mean) child_cough_where_6*/  ///
				/*(mean) child_cough_where_7 (mean) child_cough_where_8*/ ///
				(mean) child_cough_where_888 , ///
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
					4 "SRHC-RHC" 															///
					5 "EHO Clinic" 													///
					6 "Other" /*"EHO clinic mobile team (within village)" */															///
					/*7  "Routine ANC place within village"	*/													///
					/*8 "Other"*/)											///
				label(labsize(tiny)))															///
				l1title("Type of institutions", size(small)) 											///
				ytitle("Share of U5 children [0-5 years old]", size(small) height(-6))								///
				title("Share of Institutions Taking Treatment for Cough" "[0-5 years old Children]", 		///
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
		
	graph export "$plots/06_child_cough_where.png", replace
	
	// child_cough_who
	/*
	1	Specialist 
	2	Doctor 
	3	Nurse 
	4	Health assistant 
	5	Private doctor 
	6	LHV 
	7	Midwife 
	8	AMW 
	9	Ethnic health worker
	10	Community Health Worker 
	11	TBA
	888	Other (specify): 
	*/
	tab child_cough_who
	levelsof child_cough_who, local(levels)
	foreach x in `levels' {
		
		gen child_cough_who_`x' = (child_cough_who == `x') * 100
		replace child_cough_who_`x' = .m if mi(child_cough_who)
		tab child_cough_who_`x', m 
		
	}
	
	sum child_cough_who 
	local Nobs = r(N)
	
	graph hbar 	(mean) child_cough_who_2 (mean) child_cough_who_3 (mean) child_cough_who_4 ///
				(mean) child_cough_who_5 (mean) child_cough_who_7 (mean) child_cough_who_9 ///
				(mean) child_cough_who_10 (mean) child_cough_who_888, ///
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
					1	"Doctor"  ///
					2	"Nurse"  ///
					3	"Health Assistant" ///
					4	"Private Doctor" /// 
					5	"Midwife" /// 
					6	"Ethnic Health Worker" ///
					7	"Community Health Worker" ///
					8	"Other")											///
				label(labsize(tiny)))															///
				l1title("Health Care Professional", size(small)) 											///
				ytitle("Share of U5 children [0-5 years old]", size(small) height(-6))								///
				title("Share of Health Care Professional Taking Treatment for Cough:" "[0-5 years old Children]", 		///
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
		
	graph export "$plots/06_child_cough_who.png", replace
	

	
	***** FEVER *****
	// child_fever_where
	tab child_fever_where
	levelsof child_fever_where, local(levels)
	foreach x in `levels' {
		
		gen child_fever_where_`x' = (child_fever_where == `x') * 100
		replace child_fever_where_`x' = .m if mi(child_fever_where)
		tab child_fever_where_`x', m 
		
	}
	
	sum child_fever_where 
	local Nobs = r(N)
	
	graph hbar 	(mean) child_fever_where_1 /*(mean) child_fever_where_2*/ (mean) child_fever_where_3 ///
				(mean) child_fever_where_4 (mean) child_fever_where_5 /*(mean) child_fever_where_6*/  ///
				/*(mean) child_fever_where_7 (mean) child_fever_where_8*/ ///
				(mean) child_fever_where_888 , ///
				nofill 																			///
				bargap(20) 																		///
				bar(1, color($blue4) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(2, color($cpi1) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(3, color($cpi2) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(4, color($cpi2*0.7) lwidth(thin) lcolor(black) lalign(outside)) 			///
				bar(5, color($cpi3) lwidth(thin) lcolor(black) lalign(outside))			///
				/*bar(6, color($cpi4) lwidth(thin) lcolor(black) lalign(outside))*/			///
				/*bar(7, color($cpi5) lwidth(thin) lcolor(black) lalign(outside))*/ 			///
				/*bar(8, color($blue4*0.4) lwidth(thin) lcolor(black) lalign(outside))*/			///
				blabel(bar, format(%9.1f) size(vsmall))														///	
				legend(off) 																	///
				showyvars 																		///
				yvaroptions(relabel( 															///
					1 "Home"														///
					2 "Private Clinic" /*"Government hospital"*/ 															///
					3 "SRHC-RHC"  /*"Private Clinic"*/ 													///
					4 "EHO Clinic" /*"SRHC-RHC"*/ 															///
					5 "Other" /*"EHO Clinic"*/ 													///
					/*6 "EHO clinic mobile team (within village)"	*/														///
					/*7  "Routine ANC place within village"	*/													///
					/*8 "Other"*/)											///
				label(labsize(tiny)))															///
				l1title("Type of institutions", size(small)) 											///
				ytitle("Share of U5 children [0-5 years old]", size(small) height(-6))								///
				title("Share of Institutions Taking Treatment for Fever:" "[0-5 years old Children]", 		///
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
		
	graph export "$plots/07_child_fever_where.png", replace
	

	
	// child_fever_who
	/*
	1	Specialist 
	2	Doctor 
	3	Nurse 
	4	Health assistant 
	5	Private doctor 
	6	LHV 
	7	Midwife 
	8	AMW 
	9	Ethnic health worker
	10	Community Health Worker 
	11	TBA
	888	Other (specify): 
	*/
	tab child_fever_who
	levelsof child_fever_who, local(levels)
	foreach x in `levels' {
		
		gen child_fever_who_`x' = (child_fever_who == `x') * 100
		replace child_fever_who_`x' = .m if mi(child_fever_who)
		tab child_fever_who_`x', m 
		
	}
	
	sum child_fever_who 
	local Nobs = r(N)
	
	graph hbar 	(mean) child_fever_who_1 (mean) child_fever_who_2 (mean) child_fever_who_3 ///
				(mean) child_fever_who_5 (mean) child_fever_who_7 (mean) child_fever_who_9 ///
				(mean) child_fever_who_10 (mean) child_fever_who_888, ///
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
					1	"Specialist" /// 
					2	"Doctor"  ///
					3	"Nurse"  ///
					4	"Private Doctor" /// 
					5	"Midwife" /// 
					6	"Ethnic Health Worker" ///
					7	"Community Health Worker" ///
					8	"Other")											///
				label(labsize(tiny)))															///
				l1title("Health Care Professional", size(small)) 											///
				ytitle("Share of U5 children [0-5 years old]", size(small) height(-6))								///
				title("Share of Health Care Professional Taking Treatment for Fever:" "[0-5 years old Children]", 		///
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
		
	graph export "$plots/07_child_fever_who.png", replace
	



// END HERE 



/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: child MUAC data cleaning 			
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
	* Child MUAC Module *
	****************************************************************************
	use "$dta/pnourish_child_muac_final.dta", clear 
	
	
	****************************************************************************
	** Child Age **
	****************************************************************************

	tab child_age_month, m 
	* limit the obs with student less than 1000 students
	sum     child_age_month 
	local   agemean = round(r(mean), 0.1)
	local 	Nobs	= r(N)

	
	* Plot
	* ----
	twoway  (kdensity child_age_month , 	color($cpi2)), ///
			xline(`agemean', 	lcolor(maroon) 		lpattern(dash)) ///
			xtitle(Age (months)) ///
			ytitle(Density) ///
			title("Distribution of Chil's Age in Month'" , 		///
					justification(left) color(black) span pos(11) size(medium)) 							///
			plotregion(fcolor(white)) 														///
			graphregion(fcolor(white)) ///
			note(	"Mean: `agemean'" ///
					"Obs: `Nobs'" ///
					"Source: $dtasource", size(vsmall) span)

	graph export "$plots/11_child_age_distribution.png", replace
	
	
	graph bar 	(count), over(child_age_month) ///
				nofill 																			///
				bargap(20) 	///
				legend(off) 																	///
				ytitle("Number of U5 children [0-59 months]", size(small) height(-6))								///
				title("Distribution of Child's age (months)", 		///
						justification(left) color(black) span pos(11) size(medium)) 							///
				plotregion(fcolor(white)) 														///
				graphregion(fcolor(white)) ///
				note(	"Obs: `Nobs'" 		///
						"Source: $dtasource", size(vsmall) span)


				
	****************************************************************************
	** MUAC Indicators **
	****************************************************************************

	* u5_muac
	sum     u5_muac 
	local   wtmean = round(r(mean), 0.1)
	local 	Nobs	= r(N)
	sum     u5_muac, d
	local   wtmedian = "15" // round(`r(p50)', 0.1)
	
	* Plot
	* ----
	twoway  (kdensity u5_muac , 	color($cpi2)), ///
			xline(`wtmean', 	lcolor(maroon) 		lpattern(dash)) ///
			xline(`wtmedian', 	lcolor(navy)	 	lpattern(dash)) ///
			xtitle(Birth-weight (lb)) ///
			/*xlabel(0 "0" `wtmedian' "Median=`wtmedian', Mean=`wtmean'" 10 "10"  20 "20" 30 "30" 40 "40", angle(45))*/ ///
			ytitle(Density) ///
			title("Distribution of Child's MUAC (cm)" , 		///
					justification(left) color(black) span pos(11) size(medium)) 							///
			plotregion(fcolor(white)) 														///
			graphregion(fcolor(white)) ///
			note(	"Median: `wtmedian'" "Mean: `wtmean'" ///
					"Obs: `Nobs'" ///
					"Source: $dtasource", size(vsmall) span)

	graph export "$plots/13_child_muac_distribution.png", replace
	
	* child_gam child_mam child_sam
	local muac child_gam child_mam child_sam
	
	foreach var in `muac' {
		
		replace `var' = `var' * 100
		
	}
	
	
	local gamw1 0.3
	    
	//global  pct `" 0 "0%" .3 "0.3%" 1 "1%" 2 "2%" 3 "3%" "'


	sum child_gam 
	local Nobs = r(N)
	
	graph hbar 	(mean) child_gam (mean) child_mam (mean) child_sam, ///
				nofill 																			///
				bargap(20) 																		///
				bar(1, color($cpi3) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(2, color($cpi1) lwidth(thin) lcolor(black) lalign(outside))			///
				bar(3, color($cpi2) lwidth(thin) lcolor(black) lalign(outside))			///
				/*yline(`gamw1', lcolor($cpi3) lwidth(thin)) */							///
				/*ylab($pct)*/						///
				blabel(bar, format(%9.1f) size(vsmall))									///	
				legend(off) 																	///
				showyvars 																		///
				yvaroptions(relabel( 															///
					1 `"""Global Acute Malnutrition" "[MUAC < 12.5 cm]"""'														///
					2 `"""Moderate Acute Malnutrition" "[12.5 cm < MUAC >= 11.5]"""'															///
					3 `"""Seevere Acute Malnutrition" "[MUAC < 11.5 cm]"""')											///
				label(labsize(tiny)))															///
				l1title("Type of Acute Malnutrition", size(small)) 											///
				ytitle("Share of U5 children [6-59 months]", size(small) height(-6))								///
				title("Proportion of Children with Different Category of Malnutrition:" "[6-59 months]", 		///
						justification(left) color(black) span pos(11) size(medium)) 							///
				plotregion(fcolor(white)) 														///
				graphregion(fcolor(white)) ///
				note(	"1st Wave: `gamw1'%" ///
						"Obs: `Nobs'" 		///
						"Source: $dtasource", size(vsmall) span)		
				

		* Add percentage to labels
		local nb=`.Graph.plotregion1.barlabels.arrnels'
		forval i=1/`nb' {
		  di "`.Graph.plotregion1.barlabels[`i'].text[1]'"
		  .Graph.plotregion1.barlabels[`i'].text[1]="`.Graph.plotregion1.barlabels[`i'].text[1]'%"
		}
		.Graph.drawgraph
		
	graph export "$plots/12_child_muac_gam.png", replace
	
	

// END HERE 



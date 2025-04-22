/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: Equi Plot			
Author				:	Nicholus Tint Zaw
Date				: 	04/03/2025
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"


	* Equi Plot: Child health seeking **
	import excel using "$result/childhood_health_seeking_results.xlsx", sheet("equiplot") firstrow clear 
	
	equiplot Poorest Poor Medium Wealthy Wealthiest, over(indicator)
	
	equiplot 	Poorest Poor Medium Wealthy Wealthiest, ///
				over(indicator) sort(order) dotsize(3) ///
				xtitle("% of U2 children ") legtitle("Wealth Quintiles") connected

	graph export "$plots/EquiPlot_Child_Health_Seeking.png", replace
	
	* Equi Plot : Women Health **
	* ref: https://www.equidade.org/equiplot
	import excel using "$result/01_sumstat_formatted_U2Mom_Sample.xlsx", sheet("equiplot") firstrow clear 
	
	equiplot Poorest Poor Medium Wealthy Wealthiest, over(indicator)
	
	equiplot 	Poorest Poor Medium Wealthy Wealthiest, ///
				over(indicator) sort(order) dotsize(1.5) ///
				xtitle("% of Mothers with U2 children ") ///
				legtitle("Maternal Health Service Utilization by Wealth Quintile") connected

	graph export "$plots/EquiPlot_Mom_Health_Seeking.png", replace
	
	
	* ANC with two type of Quintile - Wealth vs Multivarite 
	preserve 
	
		keep if (order >= 9 & order <= 10) |  order == 13
	
		lab var Poorest 		"Q1"
		lab var Poor 			"Q2"
		lab var Medium 			"Q3"
		lab var Wealthy 		"Q4"
		lab var Wealthiest 		"Q5"
		
		equiplot 	Poorest Poor Medium Wealthy Wealthiest, ///
					over(indicator) sort(order) dotsize(1.5) ///
					xtitle("% of Mothers with U2 children ") ///
					legtitle("ANC Service Utilization Across Different Equity Stratifications") connected
					
		graph export "$plots/EquiPlot_ANC_DiffQ_Compare.png", replace
	
	restore 
	
	* ANC with two WQ 
	preserve 
	
		keep if order >= 9 & order <= 10 
	
		equiplot 	Poorest Poor Medium, ///
					over(indicator) sort(order) dotsize(1.5) ///
					xtitle("% of Mothers with U2 children ") ///
					legtitle("ANC Service Utilization by Women Empowerment Level") connected
					
		graph export "$plots/EquiPlot_ANC_Compare.png", replace
	
	restore 
	
	* ANC with WEI 
	preserve 
	
		keep if order == 11 

		drop Wealthy Wealthiest
		
		lab var Poorest "Low"
		lab var Poor 	"Moderate"
		lab var Medium	"High"
		
		replace indicator = "ANC" if indicator == "ANC (WEI)"
		
		equiplot 	Poorest Poor Medium,  ///
					over(indicator) sort(order) dotsize(1.5) ///
					xtitle("% of Mothers with U2 children ") ///
					legtitle("ANC Service Utilization by Women Empowerment Level") connected
					
		graph export "$plots/EquiPlot_ANC_WEI.png", replace
	
	restore 
	
	
	* ANC with HFC Distance 
	preserve 
	
		keep if order == 12

		drop Wealthiest
		
		lab var Poorest "Village Health Facility"
		lab var Poor 	"<= 1.5 hrs"
		lab var Medium	"1.6 - 3 hrs"
		lab var Wealthy	">3 hrs"
		
		replace indicator = "ANC" if indicator == "ANC (HFC Dist.)"
		
		equiplot 	Poorest Poor Medium Wealthy, ///
					over(indicator) sort(order) dotsize(1.5) ///
					xtitle("% of Mothers with U2 children ") ///
					legtitle("ANC Service Utilization by Distance to Health Facility") connected
					
		graph export "$plots/EquiPlot_ANC_HFC_Dist.png", replace
	
	restore 
	
	
	* Equi Plot : Nutrition Paper
	* ref: https://www.equidade.org/equiplot
	import excel using "$result/01_sumstat_formatted.xlsx", sheet("CI_WealthQ_Table") firstrow cellrange(B2:K29) clear 
	
	sort order2
	
	equiplot Poorest Poor Medium Wealthy Wealthiest, over(indicator) 
	
	drop if order2 == 2 | order2 == 3
	
	sort order2
	
	* Women_Empowerment
	preserve 
		
		keep if order2 > 1 & order2 < 22 
		
		equiplot 	Poorest Poor Medium Wealthy Wealthiest, ///
					over(indicator) sort(order2) dotsize(1.5) /// 
					xtitle("% of Eligible Households/Women") ///
					legtitle("Women's Empowerment and Project Nourish Coverage by Wealth Quintile") connected 

		graph export "$plots/EquiPlot_Women_Empowerment_Long.png", replace
		//graph export "$plots/EquiPlot_Women_Empowerment.gph", replace
	
	restore 
	
	preserve 
		
		keep if order2 > 1 & order2 < 14 
		
		equiplot 	Poorest Poor Medium Wealthy Wealthiest, ///
					over(indicator) sort(order2) dotsize(1.5) /// 
					xtitle("Percentage of Women with Children Under 5 (%)") ///
					legtitle("Women's Empowerment Indicators by Wealth Quintile") connected

		graph export "$plots/EquiPlot_Women_Empowerment.png", replace
		//graph export "$plots/EquiPlot_Women_Empowerment.gph", replace
	
	restore 
	
	* Program Coverage 
	preserve 
	
		keep if order2 > 15 & order2 < 22 
		
		equiplot 	Poorest Poor Medium Wealthy Wealthiest, ///
					over(indicator) sort(order2) dotsize(1.5) /// 
					xtitle("% of Households with U5 Children") ///
					legtitle("Coverage of Project Nourish Interventions by Wealth Quintile") connected

		graph export "$plots/EquiPlot_PN_Coverage.png", replace
		//graph export "$plots/EquiPlot_PN_Coverage.gph", replace
	
	restore 
	
	* Food Security 
	preserve 
	
		keep if order2 > 22 & !mi(order2)
		
		equiplot 	Poorest Poor Medium Wealthy Wealthiest, ///
					over(indicator) sort(order2) dotsize(1.5) /// 
					xtitle("Percent of Population Meeting Indicator (%)") ///
					legtitle("Food Security and Dietary Diversity Indicators by Wealth Quintile") connected

		graph export "$plots/EquiPlot_Food_Security.png", replace
		//graph export "$plots/EquiPlot_Food_Security.gph", replace
	
	restore 

	
	//gr combine "$plots/EquiPlot_PN_Coverage.gph" "$plots/EquiPlot_Food_Security.gph"
	
// END HERE 



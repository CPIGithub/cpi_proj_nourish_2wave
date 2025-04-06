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
				over(indicator) sort(order) dotsize(3) ///
				xtitle("% of Mothers with U2 children ") legtitle("Wealth Quintiles") connected

	graph export "$plots/EquiPlot_Mom_Health_Seeking.png", replace
	
	
	* Equi Plot : Nutrition Paper
	* ref: https://www.equidade.org/equiplot
	import excel using "$result/01_sumstat_formatted.xlsx", sheet("CI_WealthQ_Table") firstrow cellrange(B2:K21) clear 
	
	equiplot Poorest Poor Medium Wealthy Wealthiest, over(indicator)
	
	equiplot 	Poorest Poor Medium Wealthy Wealthiest, ///
				over(indicator) sort(order2) dotsize(1.5) /// 
				xtitle("% of Mothers with U5 children ") legtitle("Wealth Quintiles") connected

	graph export "$plots/EquiPlot_Women_Empowerment.png", replace
	
	

// END HERE 



* **************************************************************************** *
* **************************************************************************** *
*                                                                      		   *
* 		SHiFT Vietnam Food Environment Data 								   *
*                                                                     		   *
* **************************************************************************** *
* **************************************************************************** *

/*
  ** PURPOSE       	FE static analysis - PAPER TABLES/PLOTS - Distance/Proximity
  ** LAST UPDATE    07 22 2024 
  ** CONTENTS
  
	* Develop a dataset which only include 
			- hhid, 
			- some key demographic var, 
			- main outcomes variables
		
	And, all two different dataset HH + School enviroment and Home to School Route dataset
	were appended into one combined dataset.
	The final output dataset will be in long format with dataset level (outcome per enviroment per HH)
	
	
  ** ref dofile: Ghana's dofile 
  IFPRI Dropbox\Data-GH-Urban Ghana adolescent nutrition\Confidential\Banku Data Management\Dofiles\Paper_FE
	
*/ 

********************************************************************************

	
	****************************************************************************
	** Prepare A Combined LONG Dataset for analysis **
	****************************************************************************
	
	* use HH/School Enviroment dataset - 100 meters
	use "$foodenv_prep\FE_GPS_static_prepared_100m_adolescent_level.dta", clear 
	
	* append home to school route dataset - 10 meters
	merge 1:1 hhid using "$foodenv_prep\FE_GPS_static_prepared_HHtoSchool_Route_10m_adolescent_level.dta", assert(3) nogen 
		
	distinct hhid 

	* keep only available variables 
	keep 	hhid ///
			rural_urban ///
			school_id *_near *_near_nova4 *_near_ssb *_near_fruit *_near_vegetable *_near_fruitveg *_near_gdqs_yes *_near_gdqs_healthy *_near_gdqs_unhealthy *_near_gdqs_neutral *_near_gdqs_1 *_near_gdqs_2 *_near_gdqs_3 *_near_gdqs_4 *_near_gdqs_5 *_near_gdqs_6 *_near_gdqs_7 *_near_gdqs_8 *_near_gdqs_9 *_near_gdqs_10 *_near_gdqs_11 *_near_gdqs_12 *_near_gdqs_13 *_near_gdqs_14 *_near_gdqs_15 *_near_gdqs_16 *_near_gdqs_17 *_near_gdqs_18 *_near_gdqs_19 *_near_gdqs_20 *_near_gdqs_21 *_near_gdqs_22 *_near_gdqs_23 *_near_gdqs_24 *_near_gdqs_25 *_gdqs_healthy_num *_gdqs_unhealthy_num *_gdqs_healthy_score *_gdqs_unhealthy_score
		
	* rename for reshape dataset 
	rename hh_* *_hh
	rename scho_* *_scho
	rename h2s_* *_h2s 
			
	* set local rshape variables 
	local long_var	near_ ///
					near_nova4_ near_ssb_ near_fruit_ near_vegetable_ near_fruitveg_ ///
					near_gdqs_yes_ near_gdqs_healthy_ near_gdqs_unhealthy_ near_gdqs_neutral_ ///
					near_gdqs_1_ near_gdqs_2_ near_gdqs_3_ near_gdqs_4_ near_gdqs_5_ near_gdqs_6_ ///
					near_gdqs_7_ near_gdqs_8_ near_gdqs_9_ near_gdqs_10_ near_gdqs_11_ near_gdqs_12_ ///
					near_gdqs_13_ near_gdqs_14_ near_gdqs_15_ near_gdqs_16_ near_gdqs_17_ near_gdqs_18_ ///
					near_gdqs_19_ near_gdqs_20_ near_gdqs_21_ near_gdqs_22_ near_gdqs_23_ near_gdqs_24_ near_gdqs_25_ ///
					gdqs_healthy_num_ gdqs_unhealthy_num_ gdqs_healthy_score_ gdqs_unhealthy_score_

	reshape long `long_var', i(hhid) j(enviroment) string
	
	// drop un-necessary obs 
	egen outcome_miss_all = rowtotal(`long_var')
	tab outcome_miss_all, m 

	drop if outcome_miss_all == 0 
	drop outcome_miss_all
	
	rename *_ * 
	
	distinct hhid enviroment, joint 
	isid hhid enviroment 
	
	* enviroment
	tab enviroment, m 
	replace enviroment = "1" if enviroment == "hh"
	replace enviroment = "2" if enviroment == "scho"
	replace enviroment = "3" if enviroment == "h2s"
	destring enviroment, replace 
	lab var enviroment "FE analysis enviroment"
	lab def enviroment 1"Home" 2"School" 3"Home to School Route"
	lab val enviroment enviroment
	tab enviroment, m 
	
	* rename and lableing work
	// iecodebook template using "$foodenv_prep/Codebook/FE_paper_analysis_codebook.xlsx", replace 
	iecodebook apply using "$foodenv_prep/Codebook/FE_paper_analysis_codebook.xlsx"
		
	* Set Function 
	qui do "$foodenv_analysis/analysis_function_do/StatsByNeighborhood.do"    

	* define the parameter to apply in function 
	* neighborhood : means the cluster varaible
	* SES : means the variable for category of sample (for comparision)
	
	rename school_id neighborhood // in vietname, use school as cluster 

	gen SES = enviroment
	lab val SES enviroment
	tab SES, m 

	* Set reporting variables 
	global outcomes	near_any_outlet ///
					near_nova4 near_ssb near_fruit near_vegetable near_fruitveg ///
					near_gdqs_yes near_gdqs_healthy near_gdqs_unhealthy near_gdqs_neutral ///
					near_gdqs_1 near_gdqs_2 near_gdqs_3 near_gdqs_4 near_gdqs_5 near_gdqs_6 ///
					near_gdqs_7 near_gdqs_8 near_gdqs_9 near_gdqs_10 near_gdqs_11 near_gdqs_12 ///
					near_gdqs_13 near_gdqs_14 near_gdqs_15 near_gdqs_16 near_gdqs_17 near_gdqs_18 ///
					near_gdqs_19 near_gdqs_20 near_gdqs_21 near_gdqs_22 near_gdqs_23 near_gdqs_24 near_gdqs_25 ///
					gdqs_healthy_num gdqs_healthy_score gdqs_unhealthy_num gdqs_unhealthy_score
	

	/*
	** Export Analysis Tables **
	** (1): Home Vs School comparision 
	
	preserve 
	
	tab SES, m 
	tab SES, m nolab 
	
	keep if SES < 3
	
	recode SES (1 = 0) (2 = 1) // to matched with function command 
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_distance\Viet_Compare_distance_HH_vs_school.xls", ///
			report_N(near_any_outlet) excelrow(5)
		
	restore 
	
	** (2): HH enviroment: Geo comparision - Rural Vs Peri-Urban 
	preserve 
	
	keep if enviroment == 1 
	
	drop SES 
	
	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	drop if SES == 3
	
	recode SES (1 = 0) (2 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_distance\Regressions_proximity_HH_Rural_Vs_PeriUrban.xls", ///
			report_N(near_any_outlet) excelrow(5)
		
	restore 
	
	** (3): HH enviroment: Geo comparision - Rural Vs Urban 
	preserve 
	
	keep if enviroment == 1 
	
	drop SES 
	
	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	drop if SES == 2
	
	recode SES (1 = 0) (3 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_distance\Regressions_proximity_HH_Rural_Vs_Urban.xls", ///
			report_N(near_any_outlet) excelrow(5)
		
	restore 	
	
	** (4): HH enviroment: Geo comparision - Urban Vs Peri-Urban 
	preserve 
	
	keep if enviroment == 1 
	
	drop SES 
	
	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	drop if SES == 1
	
	recode SES (2 = 0) (3 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_distance\Regressions_proximity_HH_PeriUrban_Vs_Urban.xls", ///
			report_N(near_any_outlet) excelrow(5)
		
	restore 	
	
	** (5): School enviroment: Geo comparision - Rural Vs Peri-Urban
	preserve 
	
	keep if enviroment == 2
	
	drop SES 
	
	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	drop if SES == 3
	
	recode SES (1 = 0) (2 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_distance\Regressions_proximity_School_Rural_Vs_PeriUrban.xls", ///
			report_N(near_any_outlet) excelrow(5)
		
	restore 	
	
	** (6): School enviroment: Geo comparision - Rural Vs Urban 
	preserve 
	
	keep if enviroment == 2
	
	drop SES 
	
	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	drop if SES == 2
	
	recode SES (1 = 0) (3 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_distance\Regressions_proximity_School_Rural_Vs_Urban.xls", ///
			report_N(near_any_outlet) excelrow(5)
		
	restore 	
	
	** (7): School enviroment: Geo comparision - Urban Vs Peri-Urban 
	preserve 
	
	keep if enviroment == 2
	
	drop SES 
	
	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	drop if SES == 1
	
	recode SES (2 = 0) (3 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_distance\Regressions_proximity_School_PeriUrban_Vs_Urban.xls", ///
			report_N(near_any_outlet) excelrow(5)
		
	restore 	
	
	
	
	** (8): HH to School Route: Geo comparision - Rural Vs Peri-Urban
	preserve 
	
	keep if enviroment == 3
	
	drop SES 
	
	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	drop if SES == 3
	
	recode SES (1 = 0) (2 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_distance\Regressions_proximity_H2S_Rural_Vs_PeriUrban.xls", ///
			report_N(near_any_outlet) excelrow(5)
		
	restore 		
	
	** (9): HH to School Route: Geo comparision - Rural Vs Urban 
	preserve 
	
	keep if enviroment == 3
	
	drop SES 
	
	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	drop if SES == 2
	
	recode SES (1 = 0) (3 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_distance\Regressions_proximity_H2S_Rural_Vs_Urban.xls", ///
			report_N(near_any_outlet) excelrow(5)
		
	restore 	
	
	** (10): HH to School Route: Geo comparision - Urban Vs Peri-Urban 
	preserve 
	
	keep if enviroment == 3
	
	drop SES 
	
	gen SES = rural_urban
	lab val SES rural_urban
	tab SES, m 
	
	drop if SES == 1
	
	recode SES (2 = 0) (3 = 1)
	
		xi:StatsByNeighborhood ///
			$outcomes ///
			using "$foodenv_out\For paper\Tables_distance\Regressions_proximity_H2S_PeriUrban_Vs_Urban.xls", ///
			report_N(near_any_outlet) excelrow(5)
		
	restore 	
	
	*/
	****************************************************************************
	** EquityTool Wealth Quintile **
	****************************************************************************
	
	merge m:1 hhid using "$hh_prep/section4_prepared.dta", assert(2 3) keep(match) keepusing(NationalQuintile svy_wealth_quintile)

	// reg near_nova4 i.svy_wealth_quintile
	
	* Set reporting variables 
	global outcomes	near_any_outlet ///
					near_nova4 near_ssb near_fruit near_vegetable near_fruitveg ///
					near_gdqs_yes near_gdqs_healthy near_gdqs_unhealthy near_gdqs_neutral ///
					near_gdqs_1 near_gdqs_2 near_gdqs_3 near_gdqs_4 near_gdqs_5 near_gdqs_6 ///
					near_gdqs_7 near_gdqs_8 near_gdqs_9 near_gdqs_10 near_gdqs_11 near_gdqs_12 ///
					near_gdqs_13 near_gdqs_14 /*near_gdqs_15*/ near_gdqs_16 near_gdqs_17 near_gdqs_18 ///
					near_gdqs_19 near_gdqs_20 near_gdqs_21 near_gdqs_22 near_gdqs_23 near_gdqs_24 near_gdqs_25 ///
					gdqs_healthy_num gdqs_healthy_score gdqs_unhealthy_num gdqs_unhealthy_score
					
					
	* (1) HH Enviroment
	foreach v in $outcomes {
		
		preserve 
		
			keep if SES == 1
			
			count if !mi(`v')
			
			if `r(N)' > 0 {
				
				* Survey Distribution Quintile			
				reg `v' i.svy_wealth_quintile
				
				estimates store `v', title(`v')
			
			}
			
		restore 
		
	}
		
		
	estout 	$outcomes ///
			using "$foodenv_out/For paper/EquityTool/proximity/HH_proximity_by_wealth_quintile_SQ.csv", ///
			cells(b(star fmt(3)) se(par fmt(2)))  ///
			legend label varlabels(_cons constant) ///
			stats(r2 df_r bic) replace 
			
			
	foreach v in $outcomes {
		
		preserve 
		
			keep if SES == 1
			
			count if !mi(`v')
			
			if `r(N)' > 0 {
				
				* National Quintile 				
				reg `v' i.NationalQuintile
				
				estimates store `v', title(`v')
				
			}
			
		restore 
		
	}
	
	estout 	$outcomes ///
			using "$foodenv_out/For paper/EquityTool/proximity/HH_proximity_by_wealth_quintile_NQ.csv", ///
			cells(b(star fmt(3)) se(par fmt(2)))  ///
			legend label varlabels(_cons constant) ///
			stats(r2 df_r bic) replace 
			
			
	// by geo location 
	
	levelsof rural_urban, local(geo)
		
	foreach g in `geo' {
		
		preserve 
		
		keep if rural_urban == `g'
		
			foreach v in $outcomes {
				
				count if !mi(`v')
				
				if `r(N)' > 0 {
					
					* Survey Distribution Quintile				
					reg `v' i.svy_wealth_quintile
					
					estimates store `v', title(`v')
				
				}
				
			}
			
		estout 	$outcomes ///
				using "$foodenv_out/For paper/EquityTool/proximity/HH_geo_`g'_proximity_by_wealth_quintile_SQ.csv", ///
				cells(b(star fmt(3)) se(par fmt(2)))  ///
				legend label varlabels(_cons constant) ///
				stats(r2 df_r bic) replace 	
			
		restore 
		
	}
	

			
	foreach g in `geo' {
		
		preserve 
		
		keep if rural_urban == `g'
		
			foreach v in $outcomes {
				
				count if !mi(`v')
				
				if `r(N)' > 0 {
					
					* National Quintile 					
					reg `v' i.NationalQuintile
					
					estimates store `v', title(`v')
									
				}
				
			}
			
		estout 	$outcomes ///
				using "$foodenv_out/For paper/EquityTool/proximity/HH_geo_`g'_proximity_by_wealth_quintile_NQ.csv", ///
				cells(b(star fmt(3)) se(par fmt(2)))  ///
				legend label varlabels(_cons constant) ///
				stats(r2 df_r bic) replace 
			
		restore 
		
	}
	
			
			
	* (2) School Enviroment
	foreach v in $outcomes {
		
		preserve 
		
			keep if SES == 2
			
			count if !mi(`v')
			
			if `r(N)' > 0 {
				
				* Survey Distribution Quintile			
				reg `v' i.svy_wealth_quintile
				
				estimates store `v', title(`v')

			}
			
		restore 
		
	}
		

	estout 	$outcomes ///
			using "$foodenv_out/For paper/EquityTool/proximity/School_proximity_by_wealth_quintile_SQ.csv", ///
			cells(b(star fmt(3)) se(par fmt(2)))  ///
			legend label varlabels(_cons constant) ///
			stats(r2 df_r bic) replace 
			
	foreach v in $outcomes {
		
		preserve 
		
			keep if SES == 2
			
			count if !mi(`v')
			
			if `r(N)' > 0 {
				
				* National Quintile 				
				reg `v' i.NationalQuintile
				
				estimates store `v', title(`v')					
			
			}
			
		restore 
		
	}
				
	estout 	$outcomes ///
			using "$foodenv_out/For paper/EquityTool/proximity/School_proximity_by_wealth_quintile_NQ.csv", ///
			cells(b(star fmt(3)) se(par fmt(2)))  ///
			legend label varlabels(_cons constant) ///
			stats(r2 df_r bic) replace 
			
			
	// by geo location 
	
	levelsof rural_urban, local(geo)
		
	foreach g in `geo' {
		
		preserve 
		
		keep if rural_urban == `g'
		
			foreach v in $outcomes {
				
				count if !mi(`v')
				
				if `r(N)' > 0 {
					
					* Survey Distribution Quintile			
					reg `v' i.svy_wealth_quintile
					
					estimates store `v', title(`v')
				
				}
				
			}
		
		estout 	$outcomes ///
				using "$foodenv_out/For paper/EquityTool/proximity/School_geo_`g'_proximity_by_wealth_quintile_SQ.csv", ///
				cells(b(star fmt(3)) se(par fmt(2)))  ///
				legend label varlabels(_cons constant) ///
				stats(r2 df_r bic) replace 
			
		restore 
		
	}
	

			
	foreach g in `geo' {
		
		preserve 
		
		keep if rural_urban == `g'
		
			foreach v in $outcomes {
				
				count if !mi(`v')
				
				if `r(N)' > 0 {
					
					* National Quintile 					
					reg `v' i.NationalQuintile
					
					estimates store `v', title(`v')
									
				}
				
			}
			
		estout 	$outcomes ///
				using "$foodenv_out/For paper/EquityTool/proximity/School_geo_`g'_proximity_by_wealth_quintile_NQ.csv", ///
				cells(b(star fmt(3)) se(par fmt(2)))  ///
				legend label varlabels(_cons constant) ///
				stats(r2 df_r bic) replace 
			
		restore 
		
	}
			
			
			
	* (3) HH to School Route 
	foreach v in $outcomes {
		
		preserve 
		
			keep if SES == 3
			
			count if !mi(`v')
			
			if `r(N)' > 0 {
				
				* Survey Distribution Quintile			
				reg `v' i.svy_wealth_quintile
				
				estimates store `v', title(`v')
			
			}
			
		restore 
		
	}
		
	
	estout 	$outcomes ///
			using "$foodenv_out/For paper/EquityTool/proximity/H2S_proximity_by_wealth_quintile_SQ.csv", ///
			cells(b(star fmt(3)) se(par fmt(2)))  ///
			legend label varlabels(_cons constant) ///
			stats(r2 df_r bic) replace 
			
	foreach v in $outcomes {
		
		preserve 
		
			keep if SES == 3
			
			count if !mi(`v')
			
			if `r(N)' > 0 {
				
				* National Quintile 				
				reg `v' i.NationalQuintile
				
				estimates store `v', title(`v')
							
			}
			
		restore 
		
	}
	
	estout 	$outcomes ///
			using "$foodenv_out/For paper/EquityTool/proximity/H2S_proximity_by_wealth_quintile_NQ.csv", ///
			cells(b(star fmt(3)) se(par fmt(2)))  ///
			legend label varlabels(_cons constant) ///
			stats(r2 df_r bic) replace 
			
			
	// by geo location 
	
	levelsof rural_urban, local(geo)
		
	foreach g in `geo' {
		
		preserve 
		
		keep if rural_urban == `g'
		
			foreach v in $outcomes {
				
				count if !mi(`v')
				
				if `r(N)' > 0 {
					
					* Survey Distribution Quintile				
					reg `v' i.svy_wealth_quintile
					
					estimates store `v', title(`v')
				
				}
				
			}
			
		estout 	$outcomes ///
				using "$foodenv_out/For paper/EquityTool/proximity/H2S_geo_`g'_proximity_by_wealth_quintile_SQ.csv", ///
				cells(b(star fmt(3)) se(par fmt(2)))  ///
				legend label varlabels(_cons constant) ///
				stats(r2 df_r bic) replace 
			
		restore 
		
	}
	
			
	foreach g in `geo' {
		
		preserve 
		
		keep if rural_urban == `g'
		
			foreach v in $outcomes {
				
				count if !mi(`v')
				
				if `r(N)' > 0 {
					
					* National Quintile 					
					reg `v' i.NationalQuintile
					
					estimates store `v', title(`v')
									
				}
				
			}
			
		estout 	$outcomes ///
				using "$foodenv_out/For paper/EquityTool/proximity/H2S_geo_`g'_proximity_by_wealth_quintile_NQ.csv", ///
				cells(b(star fmt(3)) se(par fmt(2)))  ///
				legend label varlabels(_cons constant) ///
				stats(r2 df_r bic) replace 
			
		restore 
		
	}
	
			
			
	** end of dofile 
	

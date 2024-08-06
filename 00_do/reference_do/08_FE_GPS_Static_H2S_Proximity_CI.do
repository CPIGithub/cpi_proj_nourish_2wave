* **************************************************************************** *
* **************************************************************************** *
*                                                                      		   *
* 		SHiFT Vietnam Food Environment Data 								   *
*                                                                     		   *
* **************************************************************************** *
* **************************************************************************** *

/*
  ** PURPOSE       	HH to School route 10 m radius - CI on exposure outcomes 
  ** LAST UPDATE    03 06 2024 
  ** CONTENTS
		
	
*/ 

********************************************************************************

	
	****************************************************************************
	** Adolescent level data **
	****************************************************************************

	* Import data 
	use "$foodenv_prep\FE_GPS_static_prepared_HHtoSchool_Route_10m_adolescent_level.dta", clear 
	
	* Unique variable 
	distinct hhid school_code outlet_code 
	
	tab hhid_fe_merge, m 
	distinct hhid outlet_code hhid_fe_merge, joint // dataset level: hh id by outlet 


	gen white_space = 0 // for indicator brekdown in sum-stat table
			
	** Note: put white_space for section break
	
	merge m:1 hhid using "$hh_prep/section4_prepared.dta", assert(3) nogen keepusing(NationalQuintile svy_wealth_quintile NationalScore)

	
	****************************************************************************
	** (1) Type of outlets 
	****************************************************************************
	
	* outcome varaible global definition 
	global outcomes	ado_expo_h2s_yes ///
					h2s_near_outlet_1 h2s_near_outlet_2 h2s_near_outlet_3 h2s_near_outlet_4 h2s_near_outlet_5 ///
					h2s_near_outlet_6 h2s_near_outlet_7 h2s_near_outlet_8 h2s_near_outlet_9 h2s_near_outlet_10 ///
					h2s_near_outlet_11 h2s_near_outlet_12 h2s_near_outlet_13 h2s_near_outlet_14 h2s_near_outlet_15 h2s_near_outlet_97 ///
					nova4_h2s_yes ssb_h2s_yes fruit_h2s_yes vegetable_h2s_yes fruitveg_h2s_yes ///
					gdqs_yes_h2s_yes gdqs_healthy_h2s_yes gdqs_unhealthy_h2s_yes gdqs_neutral_h2s_yes ///
					gdqs_1_h2s_yes gdqs_2_h2s_yes gdqs_3_h2s_yes gdqs_4_h2s_yes gdqs_5_h2s_yes gdqs_6_h2s_yes ///
					gdqs_7_h2s_yes gdqs_8_h2s_yes gdqs_9_h2s_yes gdqs_10_h2s_yes gdqs_11_h2s_yes gdqs_12_h2s_yes ///
					gdqs_13_h2s_yes gdqs_14_h2s_yes gdqs_15_h2s_yes gdqs_16_h2s_yes gdqs_17_h2s_yes gdqs_18_h2s_yes ///
					gdqs_19_h2s_yes gdqs_20_h2s_yes gdqs_21_h2s_yes gdqs_22_h2s_yes gdqs_23_h2s_yes gdqs_24_h2s_yes gdqs_25_h2s_yes
					
					
					
	// by geo location 
	levelsof rural_urban, local(geo)
	
	foreach g in `geo' {
		
		preserve 
		
		keep if rural_urban == `g'
		
		local outcomes_in_analysis_`g' ""
		
			foreach v in $outcomes {
				
				count if `v' == 1
				
				if `r(N)' > 0 {
					
					count if `v' == 0
					
					if `r(N)' != 0 {
						
						* Survey Distribution Quintile	
						di "`v'"
						conindex `v', rank(NationalScore) wagstaff bounded limits(0 1)

						estimates store `v', title(`v')		
						
						local outcomes_in_analysis_`g' "`outcomes_in_analysis_`g'' `v'" 
						
					}
				
				}
				
			}
			
		estout 	`outcomes_in_analysis_`g'' ///
				using "$foodenv_out/For paper/EquityTool/proximity/H2S_geo_`g'_proximity_CI.csv", ///
				cells(b(star fmt(3)) se(par fmt(2)))  ///
				legend label varlabels(_cons constant) ///
				stats(r2 df_r bic) replace 	
			
		restore 
		
	}
		
	
	global outcomes	h2s_gdqs_healthy_num  

	// by geo location 
	levelsof rural_urban, local(geo)
	
	foreach g in `geo' {
		
		preserve 
		
		keep if rural_urban == `g'
		
		local outcomes_in_analysis_`g' ""
		
			foreach v in $outcomes {
				
				count if !mi(`v')
				
				if `r(N)' > 0 {
					
					//count if `v' == 0
					
					//if `r(N)' != 0 {
						
						* Survey Distribution Quintile	
						di "`v'"
						conindex `v', rank(NationalScore) wagstaff bounded limits(0 16)

						estimates store `v', title(`v')		
						
						local outcomes_in_analysis_`g' "`outcomes_in_analysis_`g'' `v'" 
						
					//}
				
				}
				
			}
			
		estout 	`outcomes_in_analysis_`g'' ///
				using "$foodenv_out/For paper/EquityTool/proximity/h2s_gdqs_healthy_num_geo_`g'_proximity_CI.csv", ///
				cells(b(star fmt(3)) se(par fmt(2)))  ///
				legend label varlabels(_cons constant) ///
				stats(r2 df_r bic) replace 	
			
		restore 
		
	}
	
	
	global outcomes h2s_gdqs_unhealthy_num 

		
	// by geo location 
	levelsof rural_urban, local(geo)
	local outcomes_in_analysis ""
	
	
	foreach g in `geo' {
		
		preserve 
		
		keep if rural_urban == `g'
		
		local outcomes_in_analysis_`g' ""
		
			foreach v in $outcomes {
				
				count if !mi(`v')
				
				if `r(N)' > 0 {
					
					//count if `v' == 0
					
					//if `r(N)' != 0 {
						
						* Survey Distribution Quintile	
						di "`v'"
						conindex `v', rank(NationalScore) wagstaff bounded limits(0 7)

						estimates store `v', title(`v')		
						
						local outcomes_in_analysis_`g' "`outcomes_in_analysis_`g'' `v'" 
						
					//}
				
				}
				
			}
			
		estout 	`outcomes_in_analysis_`g'' ///
				using "$foodenv_out/For paper/EquityTool/proximity/h2s_gdqs_unhealthy_num_geo_`g'_proximity_CI.csv", ///
				cells(b(star fmt(3)) se(par fmt(2)))  ///
				legend label varlabels(_cons constant) ///
				stats(r2 df_r bic) replace 	
			
		restore 
		
	}
	
	
	global outcomes h2s_gdqs_healthy_score 

	// by geo location 
	levelsof rural_urban, local(geo)
	local outcomes_in_analysis ""
	
	
	foreach g in `geo' {
		
		preserve 
		
		keep if rural_urban == `g'
		
		local outcomes_in_analysis_`g' ""
		
			foreach v in $outcomes {
				
				count if !mi(`v')
				
				if `r(N)' > 0 {
					
					///count if `v' == 0
					
					//if `r(N)' != 0 {
						
						* Survey Distribution Quintile	
						di "`v'"
						conindex `v', rank(NationalScore) wagstaff bounded limits(0 32)

						estimates store `v', title(`v')		
						
						local outcomes_in_analysis_`g' "`outcomes_in_analysis_`g'' `v'" 
						
					//}
				
				}
				
			}
			
		estout 	`outcomes_in_analysis_`g'' ///
				using "$foodenv_out/For paper/EquityTool/proximity/h2s_gdqs_healthy_score_geo_`g'_proximity_CI.csv", ///
				cells(b(star fmt(3)) se(par fmt(2)))  ///
				legend label varlabels(_cons constant) ///
				stats(r2 df_r bic) replace 	
			
		restore 
		
	}
	
	global outcomes h2s_gdqs_unhealthy_score  
					
	// by geo location 
	levelsof rural_urban, local(geo)
	local outcomes_in_analysis ""
	
	
	foreach g in `geo' {
		
		preserve 
		
		keep if rural_urban == `g'
		
		local outcomes_in_analysis_`g' ""
		
			foreach v in $outcomes {
				
				count if !mi(`v')
				
				if `r(N)' > 0 {
					
					//count if `v' == 0
					
					//if `r(N)' != 0 {
						
						* Survey Distribution Quintile	
						di "`v'"
						conindex `v', rank(NationalScore) wagstaff bounded limits(-14 0)

						estimates store `v', title(`v')		
						
						local outcomes_in_analysis_`g' "`outcomes_in_analysis_`g'' `v'" 
						
					//}
				
				}
				
			}
			
		estout 	`outcomes_in_analysis_`g'' ///
				using "$foodenv_out/For paper/EquityTool/proximity/h2s_gdqs_unhealthy_score_geo_`g'_proximity_CI.csv", ///
				cells(b(star fmt(3)) se(par fmt(2)))  ///
				legend label varlabels(_cons constant) ///
				stats(r2 df_r bic) replace 	
			
		restore 
		
	}
	
	

	** end of dofile 
	

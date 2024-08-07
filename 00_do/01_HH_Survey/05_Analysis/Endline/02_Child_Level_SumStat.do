/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	Endline: Data analysis - Child level			
Author				:	Nicholus Tint Zaw
Date				: 	08/06/2024
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

	****************************************************************************
	* Child MUAC Module *
	****************************************************************************

	use "$dta/endline/pnourish_child_muac_final.dta", clear   
	
	lab var hh_mem_sex "Child sex (Male)"

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	global outcomes hh_mem_sex u5_muac child_gam child_mam child_sam
	

	* All Obs
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		do "$hhdo/Function/00_frequency_table_one.do"


		export excel $export_table 	using "$out/endline/sumstat/CHILD_MUAC_SUMSTAT.xlsx", /// 
									sheet("MUAC") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* by STRATUM 
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		global sub_grp stratum_num
		
		do "$hhdo/Function/00_frequency_crosstable.do"

		export excel $export_table 	using "$out/endline/sumstat/CHILD_MUAC_SUMSTAT.xlsx", /// 
									sheet("$sub_grp") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* by STRATUM 
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		global sub_grp wealth_quintile_ns
		
		do "$hhdo/Function/00_frequency_crosstable.do"


		export excel $export_table 	using "$out/endline/sumstat/CHILD_MUAC_SUMSTAT.xlsx", /// 
									sheet("$sub_grp") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore		
	

	
	****************************************************************************
	* Child IYCF Data *
	****************************************************************************
	
	use "$dta/endline/pnourish_child_iycf_final.dta", clear 
	
	merge m:1 _parent_index using "$dta/pnourish_WOMEN_EMPOWER_final.dta", keepusing(wempo_index wempo_category progressivenss)
	
	drop if _merge == 2 
	drop _merge 
	
	* Add Village Survey Info 
	global villinfo 	hfc_near_dist_dry hfc_near_dist_rain ///
						mkt_near_dist_dry mkt_near_dist_rain ///
						hfc_vill1 hfc_vill2 hfc_vill3 hfc_vill4 hfc_vill5 hfc_vill6 hfc_vill888 hfc_vill0 
	
	merge m:1 geo_vill using 	"$dta/PN_Village_Survey_FINAL_Constructed.dta", ///
								keepusing($villinfo) 
	
	drop if _merge == 2
	drop _merge 
	
	* Village level info 
	egen mkt_near_dist = rowmean(mkt_near_dist_dry mkt_near_dist_rain)
	replace mkt_near_dist = .m if mi(mkt_near_dist_dry) & mi(mkt_near_dist_rain)
	lab var mkt_near_dist "Nearest Market - hours for round trip"
	tab mkt_near_dist, m 
	
	egen hfc_near_dist = rowmean(hfc_near_dist_dry hfc_near_dist_rain)
	replace hfc_near_dist = .m if mi(hfc_near_dist_dry) & mi(hfc_near_dist_rain)
	lab var hfc_near_dist "Nearest Health Facility - hours for round trip"
	tab hfc_near_dist, m 
	
	gen mkt_distance = .m 
	replace mkt_distance = 0 if mkt_near_dist_rain == 0
	replace mkt_distance = 1 if mkt_near_dist_rain > 0 & mkt_near_dist_rain <= 1.5
	replace mkt_distance = 2 if mkt_near_dist_rain > 1.5 & mkt_near_dist_rain <= 5
	replace mkt_distance = 3 if mkt_near_dist_rain > 5 & !mi(mkt_near_dist_rain)
	lab var mkt_distance "Nearest Market - hours for round trip"
	lab def mkt_distance 0"Market at village" 1"< 1.5 hrs" 2"1.5 - 5 hrs" 3"> 5 hrs"
	lab val mkt_distance mkt_distance
	tab mkt_distance, mis

	gen hfc_distance = .m 
	replace hfc_distance = 0 if hfc_near_dist_rain == 0
	replace hfc_distance = 1 if hfc_near_dist_rain > 0 & hfc_near_dist_rain <= 1.5
	replace hfc_distance = 2 if hfc_near_dist_rain > 1.5 & hfc_near_dist_rain <= 3
	replace hfc_distance = 3 if hfc_near_dist_rain > 3 & !mi(hfc_near_dist_rain)
	lab def hfc_distance 0"Health Facility present at village" 1"<= 1.5 hours" 2"1.6 to 3 hours" 3">3 hours"
	lab val hfc_distance hfc_distance
	lab var hfc_distance "Nearest Health Facility - hours for round trip"
	tab hfc_distance, mis

	* treated other and monestic education as missing
	gen resp_highedu_ci = resp_highedu
	replace resp_highedu_ci = .m if resp_highedu_ci > 7 
	tab resp_highedu_ci, m 
	
	replace resp_highedu = .m if resp_highedu > 7 
	replace resp_highedu = 4 if resp_highedu > 4 & !mi(resp_highedu)
	tab resp_highedu, m 
	
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	
	global outcomes	eibf ebf2d ebf pre_bf mixmf bof cbf ///
					isssf food_g1 food_g2 food_g3 food_g4 food_g5 food_g6 food_g7 food_g8 ///
					mdd dietary_tot ///
					mmf_bf_6to8 mmf_bf_9to23 mmf_bf mmf_nonbf mmf mmff mad mad_bf mad_nobf


	* All Obs
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		do "$hhdo/Function/00_frequency_table_one.do"


		export excel $export_table 	using "$out/endline/sumstat/CHILD_IYCF_SUMSTAT.xlsx", /// 
									sheet("IYCF") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* by STRATUM 
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		global sub_grp stratum_num
		
		do "$hhdo/Function/00_frequency_crosstable.do"

		export excel $export_table 	using "$out/endline/sumstat/CHILD_IYCF_SUMSTAT.xlsx", /// 
									sheet("$sub_grp") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* by STRATUM 
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		global sub_grp wealth_quintile_ns
		
		do "$hhdo/Function/00_frequency_crosstable.do"


		export excel $export_table 	using "$out/endline/sumstat/CHILD_IYCF_SUMSTAT.xlsx", /// 
									sheet("$sub_grp") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore			
					
	
	****************************************************************************
	* Child Health Data *
	****************************************************************************

	use "$dta/endline/pnourish_child_health_final.dta", clear 
	
	merge m:1 _parent_index using "$dta/pnourish_WOMEN_EMPOWER_final.dta", keepusing(wempo_index)
	
	drop if _merge == 2 
	drop _merge 

	
	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)

	global outcomes	child_vita child_deworm child_vaccin child_vaccin_card child_low_bwt ///
					child_ill0 child_ill1 child_ill2 child_ill3 child_ill888 ///
					child_diarrh_treat child_diarrh_trained child_diarrh_pay ///
					child_cough_treat child_cough_trained child_cough_pay ///
					child_fever_treat child_fever_trained child_fever_pay
	
	
	
	* All Obs
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		do "$hhdo/Function/00_frequency_table_one.do"


		export excel $export_table 	using "$out/endline/sumstat/CHILD_HEALTH_SUMSTAT.xlsx", /// 
									sheet("Child_Health") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* by STRATUM 
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		global sub_grp stratum_num
		
		do "$hhdo/Function/00_frequency_crosstable.do"

		export excel $export_table 	using "$out/endline/sumstat/CHILD_HEALTH_SUMSTAT.xlsx", /// 
									sheet("$sub_grp") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore	
	
	
	* by STRATUM 
	preserve 

		keep $outcomes weight_final geo_vill stratum_num wealth_quintile_ns
		
		global sub_grp wealth_quintile_ns
		
		do "$hhdo/Function/00_frequency_crosstable.do"


		export excel $export_table 	using "$out/endline/sumstat/CHILD_HEALTH_SUMSTAT.xlsx", /// 
									sheet("$sub_grp") firstrow(varlabels) keepcellfmt sheetreplace 
	
	restore		


	
// END HERE 



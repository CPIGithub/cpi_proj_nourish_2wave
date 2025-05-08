	/*******************************************************************************

	Project Name		: 	Project Nourish
	Purpose				:	2nd round data collection: 
							Data analysis Mother Health Care: Bivariate - wealth Vs. Multivariate 
	Author				:	Nicholus Tint Zaw
	Date				: 	03/01/2023
	Modified by			:


	*******************************************************************************/

	********************************************************************************
	** Directory Settings **
	********************************************************************************

	do "$do/00_dir_setting.do"

	****************************************************************************
	** Mom Health Services **
	****************************************************************************
	use "$dta/pnourish_mom_health_analysis_final.dta", clear    
	
	merge m:1 _parent_index using "$dta/pnourish_WOMEN_EMPOWER_final.dta", ///
							keepusing(*_d_z) assert(2 3) keep(matched) nogen 
							
							
	merge m:1 _parent_index using "$dta/pnourish_respondent_info_final.dta", ///
							keepusing(township_name geo_eho_vt_name geo_eho_vill_name geo_town geo_vt) assert( 2 3) keep(matched) nogen

	order township_name geo_eho_vt_name geo_eho_vill_name geo_town geo_vt, before(geo_vill)

	** Addressing missing issue **
	count if mi(hfc_near_dist)
	tab hfc_near_dist, m 
	
	replace hfc_near_dist = 1.5 if geo_eho_vt_name == "Kha Nein Hpaw" & stratum == 1 & mi(hfc_near_dist) // 11 obs
	replace hfc_near_dist = 1.1 if geo_eho_vt_name == "Ka Yit Kyauk Tan" & stratum == 1 & mi(hfc_near_dist) // 9 obs 
	replace hfc_near_dist = 4 if geo_eho_vt_name == "Bo Khar Lay Kho" & stratum == 2 & mi(hfc_near_dist) // 5 obs 
	replace hfc_near_dist = 4 if geo_eho_vt_name == "Sho Kho" & stratum == 2 & mi(hfc_near_dist)		 // 1 obs
	replace hfc_near_dist = 1 if geo_eho_vt_name == "Naung Pa Laing" & stratum == 1 & mi(hfc_near_dist)	 // 9 obs 
	
	tab hfc_near_dist, m 

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)
	
	conindex insti_birth_skilled, rank(NationalScore) svy wagstaff bounded limits(0 1)

	* apply imputation for missing value 
	
	
	** ANC **
	* Bivariate - Crude * 
	svy: tab anc_yn
	conindex anc_yn, rank(NationalScore) svy wagstaff bounded limits(0 1)
	
	* Bivariate  - Adjusted * 
	conindex2 anc_yn, 	rank(NationalScore) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)
	
	****************************************************************************
	** Concentration Index (Multivariate) **
	****************************************************************************
	** Preparation for Multivar CI **
	sum NationalScore income_lastmonth wempo_index hfc_near_dist stratum resp_highedu anc_yn 
	
	count if mi(NationalScore) & !mi(anc_yn) // 3 obs 
	count if mi(income_lastmonth) & !mi(anc_yn) // 0 obs  
	count if mi(wempo_index) & !mi(anc_yn) // 5 obs  
	count if mi(hfc_near_dist) & !mi(anc_yn) // 0 obs 
	count if mi(stratum) & !mi(anc_yn) // 0 obs  
	count if mi(resp_highedu) & !mi(anc_yn) // 5 obs 
	
	count if 	!mi(NationalScore) & !mi(income_lastmonth) & !mi(wempo_index) & ///
				!mi(hfc_near_dist) & !mi(stratum) & !mi(resp_highedu) & ///
				!mi(anc_yn) // 404 obs with no missing in anc + covaraite 
				
	count if 	!mi(NationalScore) & !mi(income_lastmonth) & !mi(wempo_index) & ///
				!mi(hfc_near_dist) & !mi(stratum) & !mi(resp_highedu) // 494 obs with no obs covariate 

	global all_unfiar "NationalScore income_lastmonth wempo_index hfc_near_dist stratum i.resp_highedu"
	
	//global all_fiar "i.org_name_num i.respd_chid_num_grp i.mom_age_grp resp_hhhead"

	global outcomes anc_yn anc_who_trained anc_visit_trained_4times ///
					insti_birth skilled_battend ///
					pnc_yn pnc_who_trained nbc_yn nbc_who_trained

	gen bivar_rank = NationalScore
	
	preserve 
	
		do "$hhfun/CI_comparision.do"
		
		export excel 	using "$out/CI_Comparision_Table.xlsx", /// 
						sheet("Women_Health") firstrow(varlabels) keepcellfmt sheetreplace 
						
		export excel 	using "$result/01_sumstat_formatted_U2Mom_Sample.xlsx", /// 
						sheet("Women_Health") firstrow(varlabels) keepcellfmt sheetreplace 						
		
	restore 
		
// END HERE 
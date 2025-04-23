	/*******************************************************************************

	Project Name		: 	Project Nourish
	Purpose				:	2nd round data collection: 
							Data analysis Mother Health Care: Test different calculation of CI approach
							Bivariate - wealth Vs. Multivariate 
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

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)
	
	conindex insti_birth_skilled, rank(NationalScore) svy wagstaff bounded limits(0 1)

	
	** ANC **
	* Bivariate - Crude * 
	conindex anc_visit_trained_4times, rank(NationalScore) svy wagstaff bounded limits(0 1)
	
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
						
	** Concentration Index (Multivariate) **
	global all_unfiar "NationalScore income_lastmonth wempo_index hfc_near_dist stratum i.resp_highedu i.hhhead_highedu"
	
	global all_fiar "i.org_name_num i.respd_chid_num_grp i.mom_age_grp resp_hhhead"

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
		

	* Sample code for Multivariate CI 
	svy: logit anc_yn $all_unfiar 
	
	predict p_anc_yn_all, pr
	
	xtile p_anc_quintile = p_anc_yn_all [pweight=weight_final], nq(5)
	lab var p_anc_quintile "Quintile of unfair ANC access index (predicted from unfair factors)"
	
	tab p_anc_quintile, m 
	
	svy: tab p_anc_quintile anc_yn, row 
	&&
	
	//lorenz estimate anc_yn, over(p_anc_yn_all)
	//lorenz graph
	
	conindex anc_yn, rank(NationalScore) wagstaff bounded limits(0 1) svy  
	
	conindex anc_yn, rank(p_anc_yn_all) truezero svy graph
	
	
	glcurve anc_yn, glvar(gl) pvar(p) sortvar(NationalScore)
	glcurve anc_yn, glvar(gl_m) pvar(p_m) sortvar(p_anc_quintile)

    twoway line gl p , sort || line p p , ///
        xlabel(0(.1)1) ylabel(0(.1)1)      ///
        xline(0(.1)1) yline(0(.1)1)        ///
        title("(A) ANC: Health EquityTool Index") ///
        legend(label(1 "Health EquityTool Index") label(2 "Perfect equality")) ///
        plotregion(margin(zero)) aspectratio(1) scheme(economist)

	graph export "$plots/Lorenz_curve_ANC_HealthEquity.png", replace
	
    twoway line gl_m p_m , sort || line p_m p_m , ///
        xlabel(0(.1)1) ylabel(0(.1)1)      ///
        xline(0(.1)1) yline(0(.1)1)        ///
        title("(B) ANC: Multivariate Unfair Index") ///
        legend(label(1 "Multivariate Unfair Index") label(2 "Perfect equality")) ///
        plotregion(margin(zero)) aspectratio(1) scheme(economist)

	graph export "$plots/Lorenz_curve_ANC_MultivarIndex.png", replace
	*/
	
	conindex anc_yn, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex anc_yn, rank(p_anc_yn_all) svy wagstaff bounded limits(0 1)




// END HERE 



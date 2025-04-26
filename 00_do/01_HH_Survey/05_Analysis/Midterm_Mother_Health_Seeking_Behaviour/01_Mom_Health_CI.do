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
							
							
	merge m:1 _parent_index using "$dta/pnourish_respondent_info_final.dta", ///
							keepusing(township_name geo_eho_vt_name geo_eho_vill_name geo_town geo_vt) assert( 2 3) keep(matched) nogen

	order township_name geo_eho_vt_name geo_eho_vill_name geo_town geo_vt, before(geo_vill)

	** Addressing missing issue **
	count if mi(hfc_near_dist)
	tab hfc_near_dist, m 
	
	replace hfc_near_dist = 1.5 if geo_eho_vt_name == "Kha Nein Hpaw" & stratum == 1 & mi(hfc_near_dist) // 11 obs
	replace hfc_near_dist = 1.1 if geo_eho_vt_name == "Ka Yit Kyauk Tan" & stratum == 1 & mi(hfc_near_dist)
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
						
	** Concentration Index (Multivariate) **
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
	
	global all_fiar "i.org_name_num i.respd_chid_num_grp i.mom_age_grp resp_hhhead"

	global outcomes anc_yn anc_who_trained anc_visit_trained_4times ///
					insti_birth skilled_battend ///
					pnc_yn pnc_who_trained nbc_yn nbc_who_trained

	gen bivar_rank = NationalScore
	
	* CI for ranking varaible
	// NationalScore income_lastmonth wempo_index hfc_near_dist stratum resp_highedu fies_rawscore
	conindex wempo_index, rank(NationalScore) svy wagstaff bounded limits(-2.64 .85)
	conindex hfc_near_dist, rank(NationalScore) svy wagstaff bounded limits(0 25)
	conindex stratum, rank(NationalScore) svy wagstaff bounded limits(1 2)
	conindex resp_highedu_ci, rank(NationalScore) svy wagstaff bounded limits(1 7)
	conindex fies_rawscore, rank(NationalScore) svy wagstaff bounded limits(0 8)
	
	* Outcome CI (crude) by different rank varaible
	
	foreach var of varlist NationalScore income_lastmonth wempo_index hfc_near_dist stratum resp_highedu_ci fies_rawscore { // resp_highedu_ci use for CI 
	    
		di "Rank Var: `var'"
		
		* Concentration index 
		conindex anc_yn, rank(`var') svy wagstaff bounded limits(0 1)
		
		scalar CI = r(CI) 
		
		sum anc_yn 
		scalar anc_mean = r(mean)
		
		* Achievement index - WB chapter 9 - formula 9.9  (mean * (1 - CI))
		
		di "ANC Achievement index (by `var' rank var): " anc_mean * (1 - CI)
		
	}
	
	conindex anc_yn, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex anc_yn, rank(income_lastmonth) svy wagstaff bounded limits(-2.64 .85)
	conindex anc_yn, rank(wempo_index) svy wagstaff bounded limits(-2.64 .85)
	conindex anc_yn, rank(hfc_near_dist) svy wagstaff bounded limits(0 25)
	conindex anc_yn, rank(stratum) svy wagstaff bounded limits(1 2)
	conindex anc_yn, rank(resp_highedu) svy wagstaff bounded limits(1 4)
	conindex anc_yn, rank(fies_rawscore) svy wagstaff bounded limits(0 8)
	
	

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
	
	conindex anc_yn, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex anc_yn, rank(p_anc_yn_all) svy wagstaff bounded limits(0 1)



	//lorenz estimate anc_yn, over(p_anc_yn_all)
	//lorenz graph
	
	** lorenz graph **
	// error in conindex code for anc_yn, working well for other varaible 
	//conindex anc_yn, rank(p_anc_yn_all) truezero svy graph
	//conindex nbc_yn, rank(NationalScore) truezero svy graph
	
	** HH income last month ** 
	glcurve anc_yn [aweight=weight_final], gl(gl_m) p(p_m) replace sort(income_lastmonth) lorenz
	
    twoway line gl_m p_m, sort lcolor(blue) lwidth(medium) || ///
		line p_m p_m , lcolor(gs12) lwidth(thin) , ///
        xline(1, lcolor(black) lpattern(solid) lwidth(thin)) ///
        xlabel(0(.1)1) ylabel(0(.1)1)      ///
        title("ANC: Lorenz Curve") subtitle("HH Income (Last month)") ///
        legend(label(1 "Lorenz curve") label(2 "Perfect equality")) ///
        plotregion(margin(zero)) aspectratio(1) scheme(economist) $graph_opts1

	graph export "$plots/Nairobi_Workshop/Lorenz_curve_ANC_Income.png", replace
	
	** FIES Score ** 
	glcurve anc_yn [aweight=weight_final], gl(gl_m) p(p_m) replace sort(fies_rawscore) lorenz
	
    twoway line gl_m p_m, sort lcolor(blue) lwidth(medium) || ///
		line p_m p_m , lcolor(gs12) lwidth(thin) , ///
        xline(1, lcolor(black) lpattern(solid) lwidth(thin)) ///
        xlabel(0(.1)1) ylabel(0(.1)1)      ///
        title("ANC: Lorenz Curve") subtitle("FIES Score (Raw)") ///
        legend(label(1 "Lorenz curve") label(2 "Perfect equality")) ///
        plotregion(margin(zero)) aspectratio(1) scheme(economist) $graph_opts1

	graph export "$plots/Nairobi_Workshop/Lorenz_curve_ANC_FIES_Score.png", replace
	
	** two different index WQ **
	glcurve anc_yn [aweight=weight_final], gl(gl) p(p) replace sort(NationalScore) lorenz 
	
    twoway line gl p, sort lcolor(red) lwidth(medium) || ///
		line p p , lcolor(gs12) lwidth(thin) , ///
        xline(1, lcolor(black) lpattern(solid) lwidth(thin)) ///
        xlabel(0(.1)1) ylabel(0(.1)1)      ///
        title("ANC: Lorenz Curve") subtitle("Health EquityTool Index") ///
        legend(label(1 "Lorenz curve") label(2 "Perfect equality")) ///
        plotregion(margin(zero)) aspectratio(1) scheme(economist) $graph_opts1

	graph export "$plots/Nairobi_Workshop/Lorenz_curve_ANC_HealthEquity.png", replace

	glcurve anc_yn [aweight=weight_final], gl(gl_m) p(p_m) replace sort(p_anc_yn_all) lorenz 
	
    twoway line gl_m p_m, sort lcolor(red) lwidth(medium) || ///
		line p_m p_m , lcolor(gs12) lwidth(thin) , ///
        xline(1, lcolor(black) lpattern(solid) lwidth(thin)) ///
        xlabel(0(.1)1) ylabel(0(.1)1)      ///
        title("ANC: Lorenz Curve") subtitle("Multivariate Unfair Index") ///
        legend(label(1 "Lorenz curve") label(2 "Perfect equality")) ///
        plotregion(margin(zero)) aspectratio(1) scheme(economist) $graph_opts1

	graph export "$plots/Nairobi_Workshop/Lorenz_curve_ANC_MultivarIndex.png", replace
	
	preserve 
	
		keep anc_yn NationalScore weight_final
		gen source = 	1
		
		rename NationalScore rank
		
		tempfile NationalScore
		save `NationalScore', replace 
	
	restore 
	
	
	preserve 

		keep anc_yn p_anc_yn_all weight_final
		gen source = 	2
		
		rename p_anc_yn_all rank 
		
		tempfile p_anc_yn_all
		save `p_anc_yn_all', replace 
	
	restore 
	
	use `NationalScore', clear 
	
	append using `p_anc_yn_all'
	
	lab def source 1"Wealth Index" 2"Multivariate Index"
	lab val source source 
	
	glcurve anc_yn [aweight=weight_final], gl(gl_m) p(p_m) replace sort(rank) split by(source) lorenz 
	
	graph export "$plots/Nairobi_Workshop/Lorenz_curve_ANC_Compare_Index_Without_Perfect_Equality.png", replace
	
	twoway ///
		line gl_m_1 p_m, sort lcolor(blue) lwidth(thin) || ///
		line gl_m_2 p_m , sort lcolor(red) lwidth(thin) || ///
		line p_m p_m , lcolor(gs12) lwidth(thin) , ///
		xline(1, lcolor(black) lpattern(solid) lwidth(thin)) ///
		xlabel(0(.1)1) ylabel(0(.1)1) ///
		title("ANC: Lorenz Curve") subtitle("Across Different Equity Stratifications") ///
		legend(label(1 "Wealth Index") label(2 "Multivariate Index") label(3 "Perfect equality") size(small)) ///
		plotregion(margin(zero)) aspectratio(1) scheme(economist) $graph_opts1
		
	graph export "$plots/Nairobi_Workshop/Lorenz_curve_ANC_Compare_Index_With_Perfect_Equality.png", replace
	


	
	
// END HERE 



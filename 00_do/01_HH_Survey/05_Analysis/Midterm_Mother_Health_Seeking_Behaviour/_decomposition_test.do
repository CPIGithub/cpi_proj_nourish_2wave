	/*******************************************************************************

	Project Name		: 	Project Nourish
	Purpose				:	2nd round data collection: 
							Data analysis Mother Health Care			
	Author				:	Nicholus Tint Zaw
	Date				: 	03/01/2023
	Modified by			:


	*******************************************************************************/

	********************************************************************************
	** Directory Settings **
	********************************************************************************

	do "$do/00_dir_setting.do"

	set logtype text 
	//log using "$do/anc_decomposition_workflow.text", replace 
	
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
	
	** CI calculation - using chapeter 8 - formula 8.7 
	 glcurve NationalScore [aw = weight_final], pvar(rank) nograph
	
	* F - weight prepration 
	sum weight_final // identify the longest decimal point 
	di `r(max)' - floor(`r(max)')
	
	gen weight_final_int = weight_final * 10^6 // need integer weight var for fw weight 
	gen new_weight = int(weight_final_int)
	
	** option 2: equation 8.7 
	qui sum rank [fw = new_weight]
	sca var_rank = r(Var)
	qui sum anc_yn [fw = new_weight]
	scalar mean = r(mean)

	gen lhs = 2 * var_rank * (anc_yn / mean)
	regr lhs rank [pw = weight_final], vce(cluster stratum_num) // control culster 
	sca CI = _b[rank]
	sca list CI

	** Calculation of Decomposition: Chapter 15 **
	** Using same-set of unfair from Multivariable CI estimation ** 
	global all_unfiar "NationalScore income_lastmonth wempo_index hfc_near_dist stratum i.resp_highedu"
	
	** Decomposition of the concentration index ** - Chapter 13					
	foreach var of varlist 	stratum org_name_num respd_chid_num_grp ///
							mom_age_grp resp_hhhead resp_highedu hhhead_highedu {
						    
		tab `var', gen(`var'_)			
							
				}
				
	global X 			/*income_lastmonth*/ wempo_index ///
						stratum_2 ///
						org_name_num_2 org_name_num_3 ///
						respd_chid_num_grp_2 respd_chid_num_grp_3 ///
						mom_age_grp_2 mom_age_grp_3 ///
						resp_highedu_2 resp_highedu_3 resp_highedu_4 ///
						resp_hhhead ///
						hhhead_highedu_2 hhhead_highedu_3 hhhead_highedu_4 ///
						/*hhhead_highedu_5*/ hhhead_highedu_6 hhhead_highedu_7 /*hhhead_highedu_8*/
						
	/*
	Note for dropping var 
	note: hhhead_highedu_5 != 0 predicts failure perfectly;
		  hhhead_highedu_5 omitted and 1 obs not used.
	note: hhhead_highedu_8 != 0 predicts failure perfectly;
		  hhhead_highedu_8 omitted and 1 obs not used.
	*/
						
	svy: probit anc_yn $X 
	dprobit anc_yn $X [pw = weight_final]
	
	foreach z of global X {
	 gen copy_`z'=`z'
	 qui sum `z' [aw = weight_final]
	 replace `z' = r(mean)
	 }
	 
	predict yhat 
	 
	foreach z of global X {
	 replace `z' = copy_`z'
	 drop copy_`z'
	 }
	 
	sum yhat /*m_yhat*/ [aw = weight_final]
	sca m_y = r(mean)
	gen yst = anc_yn - yhat + m_y
 
	
	dprobit anc_yn $X [pw = weight_final]
	
	matrix dfdx = e(dfdx)
	
	preserve 
		clear 
		tempfile empty 
		save `empty', emptyok 
	restore 
	
	gen sir					= .m 
	gen var 				= ""
	gen elasticity			= .m
	gen var_ci				= .m
	gen contribution		= .m
	gen contribution_pct 	= .m
	
	sca need = 0
	local i = 1
	 foreach x of global X {
		 /*qui*/ {
			mat b_`x' = dfdx[1,"`x'"]
			sca b_`x' = b_`x'[1,1] 
			
			corr rank `x' [aw = weight_final], c
			sca cov_`x' = r(cov_12)    
			
			sum `x' [aw = weight_final]
			sca m_`x' = r(mean)    
			
			sca elas_`x' = (b_`x' * m_`x') / m_y 
			sca CI_`x' = 2 * cov_`x' / m_`x'     
			sca con_`x' = elas_`x' * CI_`x'   
			sca prcnt_`x' = con_`x' / CI   
			sca need = need + con_`x'
			
			
		 }
		 di "`x' elasticity:", elas_`x'
		 di "`x' concentration index:", CI_`x'
		 di "`x' contribution:", con_`x'
		 di "`x' percentage contribution:", prcnt_`x'
		 
		 replace sir				= `i'
		 replace var 				= "`x'"
		 replace elasticity			= elas_`x'
		 replace var_ci				= CI_`x'
		 replace contribution		= con_`x'
		 replace contribution_pct 	= prcnt_`x'
		 
		 preserve 
		 
			 keep sir var elasticity var_ci contribution contribution_pct
			 
			 keep if _n == 1
			 
			 append using `empty'
			 
			 save `empty', replace 
			 
		 restore 

		local i = `i' + 1
	 }
 

	di "Inequality due to need factors:", need 
	//di "Inequality due to non-need factors:", nonneed
	sca HI = CI - need
	di "Horizontal Inequity Index:", HI
	
	
	use `empty', clear 
	
	sort sir 
	drop sir 
	
	gen need_factor 		= need
	gen ANC_CI 				= CI 
	gen horizontal_index 	= HI 
	
	egen tot_fact_contr_pct = total(contribution_pct)
	
	gen residual = CI - need_factor
	
	lab var var 				"Unfair factor variable names"
	lab var elasticity 			"Elasticities" 
	lab var var_ci 				"CI: Unfair factors"
	lab var contribution 		"Contributions"
	lab var contribution_pct 	"Percentage contributions"
	lab var need_factor 		"Total Unfair factor's contributions"
	lab var ANC_CI 				"CI: ANC (any)"
	lab var horizontal_index 	"Horizontal inequity index"
	lab var tot_fact_contr_pct 	"Total Percentage contributions"
	lab var residual			"Residual"
	
	export excel 	using "$out/Decomposition_CI_ANC.xlsx", /// 
					sheet("ANC_Decomposition") firstrow(varlabels) keepcellfmt sheetreplace 
				
	export excel 	using "$result/01_sumstat_formatted_U2Mom_Sample.xlsx", /// 
					sheet("ANC_Decompose") firstrow(varlabels) keepcellfmt sheetreplace 		
	//log close 
	
 
	&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
	&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
	
	** Chapter 8 - CI calculation 
	* ranking assingment using Health Equity Index score - apply weight 
	glcurve NationalScore [aw=weight_final], pvar(rank) nograph
	
	* F - weight prepration 
	sum weight_final // identify the longest decimal point 
	di `r(max)' - floor(`r(max)')
	
	gen weight_final_int = weight_final * 10^6 // need integer weight var for fw weight 
	gen new_weight = int(weight_final_int)
	
	** option 1: equation 8.3
	qui sum anc_yn [fw = new_weight]
	scalar mean = r(mean)
	cor anc_yn rank [fw = new_weight], c
	sca c=(2 / mean) * r(cov_12)
	sca list c
	
	** option 2: equation 8.7 
	qui sum rank [fw = new_weight]
	sca var_rank = r(Var)
	qui sum anc_yn [fw = new_weight]
	scalar mean = r(mean)

	gen lhs = 2 * var_rank * (anc_yn / mean)
	regr lhs rank [pw = weight_final], vce(cluster stratum_num) // control culster 
	sca c = _b[rank]
	sca list c
	
	
	conindex anc_yn, rank(NationalScore) svy wagstaff bounded limits(0 1)
	
	* >>>>>>>>>>>>>>>>. got different result 
	drop rank 
	
	set logtype text 
	log using "$do/decomposing_erreygers_CI_sample.text", replace  
	
	* ranking assingment using Health Equity Index score - apply weight 
	glcurve NationalScore [aw=weight_final], pvar(rank) nograph
	
	** Decomposition of the concentration index ** - Chapter 13					
	foreach var of varlist resp_highedu /// 
						mom_age_grp ///
						respd_chid_num_grp ///
						hfc_distance ///
						wempo_category ///
						org_name_num ///
						stratum {
						    
		tab `var', gen(`var'_)			
							
						}
						
						
	global X 			resp_highedu_1 resp_highedu_2 resp_highedu_3 resp_highedu_4 /// 
						mom_age_grp_1 mom_age_grp_2 mom_age_grp_3 ///
						respd_chid_num_grp_1 respd_chid_num_grp_2 respd_chid_num_grp_3 ///
						hfc_distance_1 hfc_distance_2 hfc_distance_3 hfc_distance_4 ///
						wempo_category_1 wempo_category_2 wempo_category_3 ///
						org_name_num_1 org_name_num_2 org_name_num_3 ///
						stratum_1 stratum_2

	conindex anc_yn [aw = weight_final], rank(NationalScore) bounded limits(0 1) erreygers
	sca CI = r(CI)
	
	reg anc_yn 	$X [pw = weight_final]
	sum anc_yn [aw = weight_final]
	sca m_y = r(mean) 
 
	foreach x of varlist $X {
	    
		sca b_`x'=_b[`x']
	
	}
	
	local i = 0 
	
	foreach x of global X {
		qui {
		    
			//sca b_`x' = _b[`x']    
			corr rank `x' [aw = weight_final], c
			sca cov_`x' = r(cov_12)    
			sum `x' [aw = weight_final]
			
			sca elas_`x' = (b_`x'*r(mean))/m_y  
			
			conindex `x' [aw=weight_final], rank(NationalScore) bounded limits(0 1) erreygers
			sca CI_`x' = r(CI)
			//sca CI_`x' = 2*cov_`x'/r(mean)   
			
			sca con_`x' = elas_`x'*CI_`x'
			sca prcnt_`x' = (con_`x'/CI) * 100
			
		}
		
		di "`x' elasticity:", elas_`x'
		di "`x' concentration index:", CI_`x'
		di "`x' contribution:", con_`x'
		di "`x' percentage contribution:", prcnt_`x'
		
		local i = `i' +  prcnt_`x'
		
	}
	
	log close 
	
	di `i'
	
	&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
	
	* revised code: from STATA forum 
	* ref : https://www.statalist.org/forums/forum/general-stata-discussion/general/1373417-decomposing-erreygers-concentration-index-stata
	
	conindex anc_yn [aw = weight_final], rank(NationalScore) bounded limits(0 1) erreygers

	conindex anc_yn [aw = weight_final], rank(rank) bounded limits(0 1) erreygers
	sca CI = r(CI)
	
	global X 	hfc_vill_yes progressivenss //stratum
	
	qui sum anc_yn [aw=weight_final]
	sca m_y=r(mean)
	qui glm anc_yn $X [aw=weight_final], family(binomial) link(probit)
	qui margins , dydx(*) post
	
	foreach x of varlist $X {
	    
		sca b_`x'=_b[`x']
	
	}
	
	foreach x of varlist $X {
	    
		qui{
		    
		conindex `x' [aw=weight_final], rank(rank) bounded limits(0 1) erreygers
		sca CI_`x' = r(CI)
		sum `x' [aw=weight_final]
		sca elas_`x' = 4*(b_`x' * r(mean))
		sca contri_`x' = elas_`x' * CI_`x'
		sca prcnt_`x' = (contri_`x'/CI)*100
		
		}
		
		di "`x' elasticity:", elas_`x'
		di "`x' concentration index:", CI_`x'
		di "`x' contribution:", contri_`x'
		di "`x' percentage contribution:", prcnt_`x'
		
	}
 
 
 
	* code from chapeter 12 
	
	
	decompose anc_yn 	$X [pw = weight_final], by(wealth_quintile_ns) detail estimates
 
 
	
	conindex anc_yn, rank(NationalScore) svy wagstaff bounded limits(0 1)
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
	

// END HERE 



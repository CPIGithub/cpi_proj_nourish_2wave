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
	global all_unfiar "NationalScore income_lastmonth wempo_index i.hfc_near_dist stratum i.org_name_num i.respd_chid_num_grp i.mom_age_grp resp_hhhead i.resp_highedu i.hhhead_highedu"
	
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
	
 
	&&&
	
	
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
	
	&&
	
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
	
	****************************************************************************
	** Mom (REspondent) Characteristics **
	****************************************************************************
	
	// resp_highedu
	svy: tab resp_highedu, ci 
	
	// mom_age_grp
	svy: tab mom_age_grp,ci
	
	svy: tab respd_chid_num_grp, ci 
	
	// wempo_index
	svy: mean wempo_index

	// progressivenss
	svy: tab progressivenss,ci

	// wempo_category
	svy: tab wempo_category,ci
	
	
	svy: tab stratum_num progressivenss, row 
	svy: tab stratum_num wempo_category, row 

	svy: mean wempo_index
	svy: mean wempo_index, over(stratum_num)
	test 	_b[c.wempo_index@1bn.stratum_num] = ///
			_b[c.wempo_index@2bn.stratum_num] = ///
			_b[c.wempo_index@3bn.stratum_num] = ///
			_b[c.wempo_index@4bn.stratum_num] = ///
			_b[c.wempo_index@5bn.stratum_num]
			
	conindex wempo_index, rank(NationalScore) svy truezero generalized
	
	svy: tab wealth_quintile_ns progressivenss, row 
	svy: tab wealth_quintile_ns wempo_category, row 
	conindex progressivenss, rank(NationalScore) svy wagstaff bounded limits(0 1)

	svy: mean wempo_index
	svy: mean wempo_index, over(wealth_quintile_ns)
	test 	_b[c.wempo_index@1bn.wealth_quintile_ns] = ///
			_b[c.wempo_index@2bn.wealth_quintile_ns] = ///
			_b[c.wempo_index@3bn.wealth_quintile_ns] = ///
			_b[c.wempo_index@4bn.wealth_quintile_ns] = ///
			_b[c.wempo_index@5bn.wealth_quintile_ns]
			
	svy: mean high_empower
	svy: mean high_empower, over(wealth_quintile_ns)
	conindex high_empower, rank(NationalScore) svy wagstaff bounded limits(0 1)
	
	****************************************************************************
	** Mom ANC **
	****************************************************************************
	* adjustment - make 0 for those who did not get ANC
	foreach var of varlist anc_who_trained anc_visit_trained anc_visit_trained_4times {
	    
	    tab `var', m 
		replace `var' = 0 if anc_yn == 0
		tab `var', m 
	}

	// anc_yn 
	svy: mean  anc_yn
	svy: tab stratum_num anc_yn, row 
	svy: tab NationalQuintile anc_yn, row
	svy: tab wealth_quintile_ns anc_yn, row 
	svy: tab hh_mem_dob_str anc_yn, row 
	
	lab var anc_yn "ANC - yes"

	* Create a scatter plot with lowess curves 
	twoway scatter anc_yn hh_mem_dob_str, ///
		mcolor(blue) msize(small) ///
		ytitle("Miles per Gallon") xtitle("Weight") ///
		title("Scatter Plot with Lowess Curves") ///
		legend(off)

	* Add lowess curves
	lowess anc_yn hh_mem_dob_str, ///
		lcolor(red) lwidth(medium) ///
		legend(label(1 "Lowess Curve"))
		
	graph export "$plots/lowess_anc_childob.png", replace
	
	svy: reg anc_yn hfc_near_dist_dry 
	svy: reg anc_yn hfc_near_dist_rain 


	// anc_where 
	svy: mean anc_where_1 anc_where_2 anc_where_3 anc_where_4 anc_where_5 anc_where_6 anc_where_7 anc_where_888
	svy: tab stratum_num anc_where, row 
	svy: tab NationalQuintile anc_where, row 
	svy: tab wealth_quintile_ns anc_where, row 
	svy: tab wealth_quintile_ns anc_where, row 
	
	svy: mean 	anc_where_1 anc_where_2 anc_where_3 anc_where_4 anc_where_5 anc_where_6 anc_where_7 anc_where_888, ///
				over(stratum_num)
	
	svy: mean 	anc_where_1 anc_where_2 anc_where_3 anc_where_4 anc_where_5 anc_where_6 anc_where_7 anc_where_888, ///
				over(NationalQuintile)	
	
	svy: mean 	anc_where_1 anc_where_2 anc_where_3 anc_where_4 anc_where_5 anc_where_6 anc_where_7 anc_where_888, ///
				over(wealth_quintile_ns)			
	
	// anc_*_who
	// anc_who_1 anc_who_2 anc_who_3 anc_who_4 anc_who_5 anc_who_6 anc_who_7 anc_who_8 anc_who_9 anc_who_10 anc_who_11 anc_who_888
 	svy: mean 	anc_who_1 anc_who_2 anc_who_3 anc_who_4 anc_who_5 anc_who_6 ///
				anc_who_7 anc_who_8 anc_who_9 anc_who_10 anc_who_11 anc_who_888
	
	svy: mean 	anc_who_1 anc_who_2 anc_who_3 anc_who_4 anc_who_5 anc_who_6 ///
				anc_who_7 anc_who_8 anc_who_9 anc_who_10 anc_who_11 anc_who_888, ///
				over(stratum_num)
	
	foreach var of varlist 	anc_who_1 anc_who_2 anc_who_3 anc_who_4 anc_who_5 ///
							anc_who_6 anc_who_7 anc_who_8 anc_who_9 anc_who_10 ///
							anc_who_11 anc_who_888 {
		
		svy: tab stratum_num `var', row 
	}
	
	svy: mean 	anc_who_1 anc_who_2 anc_who_3 anc_who_4 anc_who_5 anc_who_6 ///
				anc_who_7 anc_who_8 anc_who_9 anc_who_10 anc_who_11 anc_who_888, ///
				over(NationalQuintile)
	
	svy: mean 	anc_who_1 anc_who_2 anc_who_3 anc_who_4 anc_who_5 anc_who_6 ///
				anc_who_7 anc_who_8 anc_who_9 anc_who_10 anc_who_11 anc_who_888, ///
				over(wealth_quintile_ns)				
				
	
	foreach var of varlist 	anc_who_1 anc_who_2 anc_who_3 anc_who_4 anc_who_5 ///
							anc_who_6 anc_who_7 anc_who_8 anc_who_9 anc_who_10 ///
							anc_who_11 anc_who_888 {
		
		svy: tab NationalQuintile `var', row 
	}
	

	foreach var of varlist 	anc_who_1 anc_who_2 anc_who_3 anc_who_4 anc_who_5 ///
							anc_who_6 anc_who_7 anc_who_8 anc_who_9 anc_who_10 ///
							anc_who_11 anc_who_888 {
		
		svy: tab NationalQuintile_recod `var', row 
	}
	
	foreach var of varlist 	anc_who_1 anc_who_2 anc_who_3 anc_who_4 anc_who_5 ///
							anc_who_6 anc_who_7 anc_who_8 anc_who_9 anc_who_10 ///
							anc_who_11 anc_who_888 {
		
		svy: tab wealth_quintile_ns `var', row 
	}	
	

	// anc_who_trained
	svy: mean  anc_who_trained
	svy: tab stratum_num anc_who_trained, row 
	svy: tab NationalQuintile anc_who_trained, row
	svy: tab wealth_quintile_ns anc_who_trained, row
	
	svy: tab hh_mem_dob_str anc_who_trained, row 

	* Create a scatter plot with lowess curves 
	twoway scatter anc_who_trained hh_mem_dob_str, ///
		mcolor(blue) msize(small) ///
		ytitle("Miles per Gallon") xtitle("Weight") ///
		title("Scatter Plot with Lowess Curves") ///
		legend(off)

	* Add lowess curves
	lowess anc_who_trained hh_mem_dob_str, ///
		lcolor(red) lwidth(medium) ///
		legend(label(1 "Lowess Curve"))
		
	graph export "$plots/lowess_anc_who_trained_childob.png", replace
	
	
	svy: reg anc_who_trained hfc_near_dist_dry 
	svy: reg anc_who_trained hfc_near_dist_rain 


	// anc_*_visit
	// anc_who_visit_1 anc_who_visit_2 anc_who_visit_3 anc_who_visit_4 anc_who_visit_5 anc_who_visit_6 anc_who_visit_7 anc_who_visit_8 anc_who_visit_9 anc_who_visit_10 anc_who_visit_11 anc_who_visit_888
	
	
	svy: mean anc_who_visit_1 anc_who_visit_2 anc_who_visit_3 anc_who_visit_4 anc_who_visit_5 anc_who_visit_6 anc_who_visit_7 anc_who_visit_8 anc_who_visit_9 anc_who_visit_10 anc_who_visit_11 anc_who_visit_888
	
	svy: mean	anc_who_visit_1 
	
	svy: mean	anc_who_visit_2 
	
	svy: mean	anc_who_visit_3 
	
	svy: mean	anc_who_visit_4 ///
	
	svy: mean	anc_who_visit_5 
	
	svy: mean	anc_who_visit_6 
	
	svy: mean	anc_who_visit_7 
	
	svy: mean	anc_who_visit_8 ///
				
	svy: mean	anc_who_visit_9 
	
	svy: mean	anc_who_visit_10 
	
	svy: mean	anc_who_visit_11 
	
	svy: mean	anc_who_visit_888
		

	// anc_visit_trained
	svy: mean  anc_visit_trained
	svy: mean anc_visit_trained if child_dob_year < 2023, over(child_dob_season_yr) 

	svy: mean anc_visit_trained, over(stratum_num)
	svy: reg anc_visit_trained i.stratum_num
	
	svy: mean anc_visit_trained, over(NationalQuintile)
	svy: reg anc_visit_trained i.NationalQuintile

	svy: mean anc_visit_trained, over(wealth_quintile_ns)
	svy: reg anc_visit_trained i.wealth_quintile_ns	
	
	svy: reg anc_visit_trained hfc_near_dist_dry 
	svy: reg anc_visit_trained hfc_near_dist_rain 

	// anc_visit_trained_4times
	svy: mean  anc_visit_trained_4times
	svy: tab stratum_num anc_visit_trained_4times, row 
	svy: tab NationalQuintile anc_visit_trained_4times, row
	svy: tab wealth_quintile_ns anc_visit_trained_4times, row
	
	svy: tab hh_mem_dob_str anc_visit_trained_4times, row 

	* Create a scatter plot with lowess curves 
	twoway scatter anc_visit_trained_4times hh_mem_dob_str, ///
		mcolor(blue) msize(small) ///
		ytitle("Miles per Gallon") xtitle("Weight") ///
		title("Scatter Plot with Lowess Curves") ///
		legend(off)

	* Add lowess curves
	lowess anc_visit_trained_4times hh_mem_dob_str, ///
		lcolor(red) lwidth(medium) ///
		legend(label(1 "Lowess Curve"))
		
	graph export "$plots/lowess_anc_visit_trained_4times_childob.png", replace
	
	
	svy: reg anc_visit_trained_4times hfc_near_dist_dry 
	svy: reg anc_visit_trained_4times hfc_near_dist_rain 	
	
	svy: tab hhitems_phone anc_yn, row 
	svy: tab prgexpo_pn anc_yn, row 	
	svy: tab edu_exposure anc_yn, row 
	svy: tab child_dob_season_yr anc_yn if child_dob_year < 2023, row 

	svy: tab hhitems_phone anc_who_trained, row 
	svy: tab prgexpo_pn anc_who_trained, row 	
	svy: tab edu_exposure anc_who_trained, row 
	svy: tab child_dob_season_yr anc_who_trained if child_dob_year < 2023, row 
	
	svy: tab hhitems_phone anc_visit_trained_4times, row 
	svy: tab prgexpo_pn anc_visit_trained_4times, row 	
	svy: tab edu_exposure anc_visit_trained_4times, row 
	svy: tab child_dob_season_yr anc_visit_trained_4times if child_dob_year < 2023, row 

	svy: reg anc_visit_trained hhitems_phone
	svy: reg anc_visit_trained prgexpo_pn
	svy: tab edu_exposure prgexpo_pn, row 

	
	svy: reg anc_yn wempo_index 
	svy: reg anc_who_trained wempo_index 
	svy: reg anc_visit_trained wempo_index 

	
	svy: mean anc_visit_trained, over(wealth_quintile_ns)

	foreach var of varlist anc_yn anc_who_trained anc_visit_trained_4times	{
	    
		di "`var'"
		
		svy: tab wealth_quintile_ns `var', row
	
	}	
	
	local outcome anc_visit_trained
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') truezero svy 
		}
	
	}	
	
	
	gen stratum_org_inter = stratum * org_name_num  

	gen KDHW = (stratum_num == 5)

		
	foreach v in `outcome' {
		
		svy: reg `v' KDHW stratum org_name_num 
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/14_mom_anc_visit_table.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace

	   
	foreach v in `outcome' {
		
		svy: reg `v' KDHW i.org_name_num##stratum  
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/14_mom_anc_visit_table_m2.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	   
	local outcome 	anc_yn anc_who_trained anc_visit_trained_4times
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}
	
	
	
	foreach v in `outcome' {
		
		svy: logit `v' KDHW stratum org_name_num 
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/15_mom_anc_all_table.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace

	foreach v in `outcome' {
		
		svy: logit `v' KDHW i.org_name_num##stratum  
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/15_mom_anc_all_table_m2.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	   

	* additional table for ANC paper 
	// resp_highedu
	svy: tab resp_highedu anc_yn, row 
	svy: tab resp_highedu anc_who_trained, row 	
	svy: tab resp_highedu anc_visit_trained_4times, row 

	svy: mean anc_visit_trained, over(resp_highedu)
	svy: reg anc_visit_trained i.resp_highedu
	
	foreach var of varlist anc_who_1 anc_who_2 anc_who_3 anc_who_4 anc_who_5 anc_who_6 anc_who_7 anc_who_8 anc_who_9 anc_who_10 anc_who_11 anc_who_888 {
	   
	   svy: tab resp_highedu `var', row 
	   
	}
	
	// stratum
	svy: tab stratum anc_yn, row 
	svy: tab stratum anc_who_trained, row 	
	svy: tab stratum anc_visit_trained_4times, row 

	svy: mean anc_visit_trained, over(stratum)
	svy: reg anc_visit_trained i.stratum
	
	svy: tab stratum anc_where, row 
	svy: tab hfc_vill_yes anc_where, row 

	svy: mean hfc_near_dist, over(anc_where)
	svy: reg hfc_near_dist i.anc_where
	
	foreach var of varlist anc_who_1 anc_who_2 anc_who_3 anc_who_4 anc_who_5 anc_who_6 anc_who_7 anc_who_8 anc_who_9 anc_who_10 anc_who_11 anc_who_888 {
	   
	   svy: tab stratum `var', row 
	   
	}
	

	// hfc_vill_yes
	svy: tab hfc_vill_yes anc_yn, row 
	svy: tab hfc_vill_yes anc_who_trained, row 	
	svy: tab hfc_vill_yes anc_visit_trained_4times, row 

	svy: mean anc_visit_trained, over(hfc_vill_yes)
	svy: reg anc_visit_trained i.hfc_vill_yes

	svy: tab resp_highedu anc_where, row 

	foreach var of varlist anc_who_1 anc_who_2 anc_who_3 anc_who_4 anc_who_5 anc_who_6 anc_who_7 anc_who_8 anc_who_9 anc_who_10 anc_who_11 anc_who_888 {
	   
	   svy: tab hfc_vill_yes `var', row 
	   
	}	
	
	
	//hfc_vill_yes
	//hfc_near_dist
	
	
	// hfc_vill1 hfc_vill2 hfc_vill3 hfc_vill4 hfc_vill5 hfc_vill6 hfc_vill888
	
	// anc cope: anc_cope1 anc_cope2 anc_cope3 anc_cope4 anc_cope5 anc_cope6 anc_cope7 anc_cope8 anc_cope9 anc_cope10 anc_cope11 anc_cope12 anc_cope13 anc_cope14 anc_cope888
	svy: mean anc_cope1 anc_cope2 anc_cope3 anc_cope4 anc_cope5 anc_cope6 anc_cope7 anc_cope8 anc_cope9 anc_cope10 anc_cope11 anc_cope12 anc_cope13 anc_cope14 anc_cope888


	// anc no - why: anc_noreason1 anc_noreason2 anc_noreason3 anc_noreason4 anc_noreason5 anc_noreason6 anc_noreason7 anc_noreason8 anc_noreason9 anc_noreason10 anc_noreason11 anc_noreason12 anc_noreason13 anc_noreason888
	svy: mean anc_noreason1 anc_noreason2 anc_noreason3 anc_noreason4 anc_noreason5 anc_noreason6 anc_noreason7 anc_noreason8 anc_noreason9 anc_noreason10 anc_noreason11 anc_noreason12 anc_noreason13 anc_noreason888
	
	// Mom age
	svy: tab mom_age_grp, ci 
	
	svy: tab mom_age_grp anc_yn, row 
	svy: tab mom_age_grp anc_who_trained, row 	
	svy: tab mom_age_grp anc_visit_trained_4times, row 

	svy: mean anc_visit_trained, over(mom_age_grp)
	svy: reg anc_visit_trained i.mom_age_grp

	svy: tab mom_age_grp anc_yn, row 
	svy: tab mom_age_grp anc_yn, row 
	
	
	svy: tab mom_age_grp anc_where, row 
	
	foreach var of varlist anc_who_1 anc_who_2 anc_who_3 anc_who_4 anc_who_5 anc_who_6 anc_who_7 anc_who_8 anc_who_9 anc_who_10 anc_who_11 anc_who_888 {
	   
	   svy: tab mom_age_grp `var', row 
	   
	}
	
	**********************
	** FOR FINAL TABLES **
	**********************
	
	// anc_yn
	svy: tab anc_yn, ci 
	
	svy: tab resp_highedu anc_yn, row 
	svy: tab mom_age_grp anc_yn, row 
	svy: tab respd_chid_num_grp anc_yn, row 

	svy: mean anc_month_dry_2s , over(anc_yn) 
	svy: mean anc_month_wet_2s , over(anc_yn) 
	
	svy: tab hfc_vill_yes anc_yn, row 
	svy: mean hfc_near_dist , over(anc_yn) 
	svy: tab hfc_distance anc_yn, row 
	
	svy: tab wealth_quintile_ns anc_yn, row 
	svy: tab progressivenss anc_yn, row 
	svy: tab wempo_category anc_yn, row 
	

	svy: tab org_name_num anc_yn, row 
	svy: tab stratum anc_yn, row 

	// CI 
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
	
	// anc_who_trained
	svy: tab anc_who_trained, ci 
	
	svy: tab resp_highedu anc_who_trained, row 
	svy: tab mom_age_grp anc_who_trained, row 
	svy: tab respd_chid_num_grp anc_who_trained, row 

	svy: mean anc_month_dry_2s , over(anc_who_trained) 
	svy: mean anc_month_wet_2s , over(anc_who_trained) 
	
	svy: tab hfc_vill_yes anc_who_trained, row 
	svy: mean hfc_near_dist , over(anc_who_trained) 
	svy: tab hfc_distance anc_who_trained, row 
	
	svy: tab wealth_quintile_ns anc_who_trained, row 
	svy: tab progressivenss anc_who_trained, row 
	svy: tab wempo_category anc_who_trained, row 

	svy: tab org_name_num anc_who_trained, row 
	svy: tab stratum anc_who_trained, row 	
	
	conindex anc_who_trained, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 anc_who_trained, 	rank(NationalScore) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)
						
	// anc_visit_trained_4times
	svy: tab anc_visit_trained_4times, ci 
	
	svy: tab resp_highedu anc_visit_trained_4times, row 
	svy: tab mom_age_grp anc_visit_trained_4times, row 
	svy: tab respd_chid_num_grp anc_visit_trained_4times, row 

	svy: mean anc_month_dry_2s , over(anc_visit_trained_4times) 
	svy: mean anc_month_wet_2s , over(anc_visit_trained_4times) 
	
	svy: tab hfc_vill_yes anc_visit_trained_4times, row 
	svy: mean hfc_near_dist , over(anc_visit_trained_4times) 
	svy: tab hfc_distance anc_visit_trained_4times, row 
	
	svy: tab wealth_quintile_ns anc_visit_trained_4times, row 
	svy: tab progressivenss anc_visit_trained_4times, row 
	svy: tab wempo_category anc_visit_trained_4times, row 

	svy: tab org_name_num anc_visit_trained_4times, row 
	svy: tab stratum anc_visit_trained_4times, row 
	
	conindex anc_visit_trained_4times, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 anc_visit_trained_4times, 	rank(NationalScore) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)
						
	// Logistic regression 	
	local outcomes	anc_yn anc_who_trained anc_visit_trained_4times
	
	foreach outcome in `outcomes' {
	 
		local regressor  	resp_highedu mom_age_grp respd_chid_num_grp ///
							/*anc_month_dry_2s anc_month_wet_2s*/ ///
							/*hfc_vill_yes*/ hfc_distance ///
							wealth_quintile_ns wempo_category org_name_num stratum  
		
		foreach v in `regressor' {
			
			putexcel set "$out/reg_output/ANC_`outcome'_logistic_models.xls", sheet("`v'") modify 
		
			if "`v'" == "anc_month_dry_2s" | "`v'" == "anc_month_wet_2s" | "`v'" == "hfc_near_dist" {
				svy: glm `outcome' `v', family(poisson) link(log) nolog eform // svy: logistic 
			}
			else {
				svy: glm `outcome' i.`v', family(poisson) link(log) nolog eform // svy: logistic 
			}
			
			estimates store `v', title(`v')
			
			putexcel (A1) = etable
			
		}
			
	}
	

	local outcomes	anc_yn anc_who_trained anc_visit_trained_4times
	
	foreach outcome in `outcomes' {
	 
			
		putexcel set "$out/reg_output/ANC_`outcome'_logistic_models.xls", sheet("Final_model") modify 
		
		svy: glm 		`outcome' 	i.resp_highedu /// // svy: logistic 
									i.mom_age_grp ///
									i.respd_chid_num_grp ///
									hfc_vill_yes ///
									i.hfc_distance ///
									i.wealth_quintile_ns ///
									i.wempo_category ///
									i.org_name_num ///
									stratum, ///
									family(binomial) link(log) nolog eform
	
		putexcel (A1) = etable
			
	}
	
	** anc_yn	
	
	svy: glm anc_yn i.resp_highedu, family(poisson) link(log) nolog eform
	svy: glm anc_yn i.resp_highedu, family(binomial) link(log) nolog eform
	
	local outcomes	anc_yn 
	
	foreach outcome in `outcomes' {
	 
			
		putexcel set "$out/reg_output/ANC_`outcome'_logistic_models.xls", sheet("Final_model") modify 
		
		svy: glm 		`outcome' 	i.resp_highedu /// // svy: logistic 
									/*i.mom_age_grp*/ ///
									i.respd_chid_num_grp ///
									i.hfc_distance ///
									i.wealth_quintile_ns ///
									i.wempo_category ///
									i.org_name_num ///
									stratum, ///
									family(poisson) link(log) nolog eform
	
		putexcel (A1) = etable
			
	}
					
	conindex anc_yn, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 anc_yn, 	rank(NationalScore) ///
						covars(	i.resp_highedu ///
								/*i.mom_age_grp*/ ///
								i.respd_chid_num_grp ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)
						
	// Education as rank
	conindex anc_yn, rank(resp_highedu_ci) svy wagstaff bounded limits(0 1)
	conindex2 anc_yn, 	rank(resp_highedu_ci) ///
						covars(	i.wealth_quintile_ns ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)
						
						
	// Women empowerment as rank 
	conindex anc_yn, rank(wempo_index) svy wagstaff bounded limits(0 1)
	conindex2 anc_yn, 	rank(wempo_index) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wealth_quintile_ns) ///
						svy wagstaff bounded limits(0 1)

						
	** anc_who_trained 
	local outcomes	anc_who_trained 
	
	foreach outcome in `outcomes' {
	 
			
		putexcel set "$out/reg_output/ANC_`outcome'_logistic_models.xls", sheet("Final_model") modify 
		
		svy: glm 		`outcome' 	/*i.resp_highedu*/ /// // svy: logistic 
									i.mom_age_grp ///
									i.respd_chid_num_grp ///
									i.hfc_distance ///
									i.wealth_quintile_ns ///
									/*i.wempo_category*/ ///
									i.org_name_num ///
									stratum, ///
									family(poisson) link(log) nolog eform
	
		putexcel (A1) = etable
			
	}
					
	conindex anc_who_trained, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 anc_who_trained, 	rank(NationalScore) ///
						covars(	/*i.resp_highedu*/ /// // svy: logistic 
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								i.hfc_distance ///
								/*i.wempo_category*/ ///
								i.org_name_num ///
								stratum) ///
						svy wagstaff bounded limits(0 1)
						
	// Education as rank
	conindex anc_who_trained, rank(resp_highedu_ci) svy wagstaff bounded limits(0 1)
	conindex2 anc_who_trained, 	rank(resp_highedu_ci) ///
						covars(	i.wealth_quintile_ns ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)
						
						
	// Women empowerment as rank 
	conindex anc_who_trained, rank(wempo_index) svy wagstaff bounded limits(0 1)
	conindex2 anc_who_trained, 	rank(wempo_index) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wealth_quintile_ns) ///
						svy wagstaff bounded limits(0 1)
	
	** anc_visit_trained_4times 
	local outcomes	anc_visit_trained_4times 
	
	foreach outcome in `outcomes' {
	 
			
		putexcel set "$out/reg_output/ANC_`outcome'_logistic_models.xls", sheet("Final_model") modify 
		
		svy: glm 		`outcome' 	i.resp_highedu /// // svy: logistic 
									/*i.mom_age_grp*/ ///
									i.respd_chid_num_grp ///
									i.hfc_distance ///
									i.wealth_quintile_ns ///
									i.wempo_category ///
									i.org_name_num ///
									stratum, ///
									family(poisson) link(log) nolog eform
	
		putexcel (A1) = etable
			
	}
					
	conindex anc_visit_trained_4times, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 anc_visit_trained_4times, 	rank(NationalScore) ///
									covars(	i.resp_highedu /// // svy: logistic 
											/*i.mom_age_grp*/ ///
											i.respd_chid_num_grp ///
											i.hfc_distance ///
											i.wempo_category ///
											i.org_name_num ///
											stratum) ///
									svy wagstaff bounded limits(0 1)
						
	// Education as rank
	conindex anc_visit_trained_4times, rank(resp_highedu_ci) svy wagstaff bounded limits(0 1)
	conindex2 anc_visit_trained_4times, 	rank(resp_highedu_ci) ///
						covars(	i.wealth_quintile_ns ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)
						
						
	// Women empowerment as rank 
	conindex anc_visit_trained_4times, rank(wempo_index) svy wagstaff bounded limits(0 1)
	conindex2 anc_visit_trained_4times, 	rank(wempo_index) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wealth_quintile_ns) ///
						svy wagstaff bounded limits(0 1)
						
	****************************************************************************
	** Mom Deliverty **
	****************************************************************************
	// deliv_place 
	svy: tab deliv_place,ci
	svy: tab stratum_num deliv_place, row 
	svy: tab NationalQuintile deliv_place, row 
	svy: tab NationalQuintile_recod deliv_place, row 
	svy: tab wealth_quintile_ns deliv_place, row

	// Institutional Deliveries
	svy: mean  insti_birth
	svy: tab stratum_num insti_birth, row 
	svy: tab NationalQuintile insti_birth, row
	svy: tab wealth_quintile_ns insti_birth, row

	svy: reg insti_birth hfc_near_dist_dry 
	svy: reg insti_birth hfc_near_dist_rain 	
	
	// deliv_assist
	svy: tab deliv_assist,ci
	svy: tab stratum_num deliv_assist, row 
	svy: tab NationalQuintile deliv_assist, row 
	svy: tab NationalQuintile_recod deliv_assist, row 
	svy: tab wealth_quintile_ns deliv_assist, row

	svy: tab child_dob_season_yr deliv_assist if child_dob_year < 2023, row

	
	// Births attended by skilled health personnel
	svy: mean  skilled_battend
	svy: tab stratum_num skilled_battend, row 
	svy: tab NationalQuintile skilled_battend, row
	svy: tab child_dob_season_yr skilled_battend if child_dob_year < 2023, row

	svy: reg skilled_battend i.delivery_month_season child_dob_year if child_dob_year < 2023

	svy: reg skilled_battend hfc_near_dist_dry 
	svy: reg skilled_battend hfc_near_dist_rain 	
	
	svy: tab hhitems_phone skilled_battend, row 
	svy: tab prgexpo_pn skilled_battend, row 	
	svy: tab edu_exposure skilled_battend, row 

	svy: tab hhitems_phone insti_birth, row 
	svy: tab prgexpo_pn insti_birth, row 	
	svy: tab edu_exposure insti_birth, row 
	svy: tab child_dob_season_yr insti_birth if child_dob_year < 2023, row

	svy: reg insti_birth i.delivery_month_season child_dob_year if child_dob_year < 2023

	svy: reg skilled_battend wempo_index 
	svy: reg insti_birth wempo_index 
	
	svy: tab wealth_quintile_ns insti_birth, row
	svy: tab wealth_quintile_ns skilled_battend, row

	
	local outcome 	insti_birth skilled_battend
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}
	
	
	foreach v in `outcome' {
		
		svy: logit `v' KDHW stratum org_name_num 
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/16_mom_deli_table.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	foreach v in `outcome' {
		
		svy: logit `v' KDHW i.org_name_num##stratum  
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/16_mom_deli_table_m2.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	svy: tab hh_mem_dob_str insti_birth, row 
	svy: tab hh_mem_dob_str skilled_battend, row 
	
	
	* additional table for ANC paper 
	// resp_highedu
	svy: tab resp_highedu insti_birth, row 
	svy: tab resp_highedu skilled_battend, row 	
	svy: tab resp_highedu deliv_place, row 
	svy: tab resp_highedu deliv_assist, row 
	
	
	// stratum
	svy: tab stratum insti_birth, row 
	svy: tab stratum skilled_battend, row 

	svy: tab stratum deliv_place, row 
	svy: tab stratum deliv_assist, row 

	
	// hfc_vill_yes
	svy: tab hfc_vill_yes deliv_place, row 
	svy: tab hfc_vill_yes deliv_assist, row 

	svy: tab hfc_vill_yes insti_birth, row 
	svy: tab hfc_vill_yes skilled_battend, row 
	
	// mom_age_grp
	svy: tab mom_age_grp deliv_place, row 
	svy: tab mom_age_grp deliv_assist, row 

	svy: tab mom_age_grp insti_birth, row 
	svy: tab mom_age_grp skilled_battend, row 
	
	
	svy: mean deliv_cope1 deliv_cope2 deliv_cope3 deliv_cope4 deliv_cope5 deliv_cope6 deliv_cope7 deliv_cope8 deliv_cope9 deliv_cope10 deliv_cope11 deliv_cope12 deliv_cope13 deliv_cope14 deliv_cope888
	
	
	// ANC vs Delivery 
	svy: tab anc_yn insti_birth , row 
	svy: tab anc_yn skilled_battend, row 

	svy: tab anc_who_trained insti_birth, row 	
	svy: tab anc_who_trained skilled_battend, row 	

	svy: tab anc_yn deliv_place , row 
	svy: tab anc_who_trained deliv_place, row 	
	
	**************************
	** FINAL MODEL TABLES **
	**************************
	// insti_birth
	svy: tab insti_birth, ci 
	
	svy: tab resp_highedu insti_birth, row 
	svy: tab mom_age_grp insti_birth, row 
	svy: tab respd_chid_num_grp insti_birth, row 

	svy: tab delivery_month_season insti_birth, row
	
	svy: tab hfc_vill_yes insti_birth, row 
	svy: mean hfc_near_dist , over(insti_birth) 
	svy: tab hfc_distance insti_birth, row 
	
	svy: tab wealth_quintile_ns insti_birth, row 
	svy: tab progressivenss insti_birth, row 
	svy: tab wempo_category insti_birth, row 

	svy: tab org_name_num insti_birth, row 
	svy: tab stratum insti_birth, row 
	
	conindex insti_birth, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 insti_birth, 	rank(NationalScore) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								i.delivery_month_season ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)

	// skilled_battend
	svy: tab skilled_battend, ci 
	
	svy: tab resp_highedu skilled_battend, row 
	svy: tab mom_age_grp skilled_battend, row 
	svy: tab respd_chid_num_grp skilled_battend, row 

	svy: tab delivery_month_season skilled_battend, row 
	
	svy: tab hfc_vill_yes skilled_battend, row 
	svy: mean hfc_near_dist , over(skilled_battend) 
	svy: tab hfc_distance skilled_battend, row 
	
	svy: tab wealth_quintile_ns skilled_battend, row 
	svy: tab progressivenss skilled_battend, row 
	svy: tab wempo_category skilled_battend, row 

	svy: tab org_name_num skilled_battend, row 
	svy: tab stratum skilled_battend, row 
	
	conindex skilled_battend, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 skilled_battend, 	rank(NationalScore) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								i.delivery_month_season ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)

						
	// Logistic regression 					
	local outcomes	insti_birth skilled_battend 
	
	foreach outcome in `outcomes' {
	 
		local regressor  	resp_highedu mom_age_grp respd_chid_num_grp ///
							delivery_month_season ///
							/*hfc_vill_yes*/ hfc_distance ///
							wealth_quintile_ns wempo_category org_name_num stratum  
		
		foreach v in `regressor' {
			
			putexcel set "$out/reg_output/Delivery_`outcome'_logistic_models.xls", sheet("`v'") modify 
		
			if "`v'" == "hfc_near_dist" {
				svy: glm `outcome' `v', family(poisson) link(log) nolog eform // svy: logistic
			}
			else {
				svy: glm `outcome' i.`v', family(poisson) link(log) nolog eform // svy: logistic
			}
			
			estimates store `v', title(`v')
			
			putexcel (A1) = etable
			
		}
			
	}
	

	local outcomes	insti_birth skilled_battend 
	
	foreach outcome in `outcomes' {
	 
			
		putexcel set "$out/reg_output/Delivery_`outcome'_logistic_models.xls", sheet("Final_model") modify 
		
		svy: glm `outcome' 	i.resp_highedu /// // svy: logistic
							i.mom_age_grp ///
							i.respd_chid_num_grp ///
							i.delivery_month_season ///
							hfc_vill_yes ///
							i.hfc_distance ///
							i.wealth_quintile_ns ///
							i.wempo_category ///
							i.org_name_num ///
							stratum, ///
							family(binomial) link(log) nolog eform
		putexcel (A1) = etable
			
	}
	
	
	** insti_birth 
	local outcomes	insti_birth  
	
	foreach outcome in `outcomes' {
	 
			
		putexcel set "$out/reg_output/Delivery_`outcome'_logistic_models.xls", sheet("Final_model") modify 
		
		svy: glm `outcome' 	i.resp_highedu /// // svy: logistic
							/*i.mom_age_grp*/ ///
							i.respd_chid_num_grp ///
							/*i.delivery_month_season*/ ///
							i.hfc_distance ///
							i.wealth_quintile_ns ///
							/*i.wempo_category*/ ///
							/*i.org_name_num*/ ///
							stratum, ///
							family(poisson) link(log) nolog eform
		putexcel (A1) = etable
			
	}
							
	conindex insti_birth, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 insti_birth, 	rank(NationalScore) ///
						covars(	i.resp_highedu /// // svy: logistic
							/*i.mom_age_grp*/ ///
							i.respd_chid_num_grp ///
							/*i.delivery_month_season*/ ///
							i.hfc_distance ///
							/*i.wempo_category*/ ///
							/*i.org_name_num*/ ///
							stratum) ///
						svy wagstaff bounded limits(0 1)
						
	// Education as rank
	conindex insti_birth, rank(resp_highedu_ci) svy wagstaff bounded limits(0 1)
	conindex2 insti_birth, 	rank(resp_highedu_ci) ///
						covars(	i.wealth_quintile_ns ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)
						
						
	// Women empowerment as rank 
	conindex insti_birth, rank(wempo_index) svy wagstaff bounded limits(0 1)
	conindex2 insti_birth, 	rank(wempo_index) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wealth_quintile_ns) ///
						svy wagstaff bounded limits(0 1)
						
	** skilled_battend
	local outcomes	skilled_battend  
	
	foreach outcome in `outcomes' {
	 
			
		putexcel set "$out/reg_output/Delivery_`outcome'_logistic_models.xls", sheet("Final_model") modify 
		
		svy: glm `outcome' 	i.resp_highedu /// // svy: logistic
							/*i.mom_age_grp*/ ///
							i.respd_chid_num_grp ///
							/*i.delivery_month_season*/ ///
							i.hfc_distance ///
							i.wealth_quintile_ns ///
							/*i.wempo_category*/ ///
							i.org_name_num ///
							stratum, ///
							family(poisson) link(log) nolog eform
		putexcel (A1) = etable
			
	}
							
	conindex , rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 skilled_battend, 	rank(NationalScore) ///
						covars(	i.resp_highedu /// // svy: logistic
								/*i.mom_age_grp*/ ///
								i.respd_chid_num_grp ///
								/*i.delivery_month_season*/ ///
								i.hfc_distance ///
								/*i.wempo_category*/ ///
								i.org_name_num ///
								stratum) ///
						svy wagstaff bounded limits(0 1)

	// Education as rank
	conindex skilled_battend, rank(resp_highedu_ci) svy wagstaff bounded limits(0 1)
	conindex2 skilled_battend, 	rank(resp_highedu_ci) ///
						covars(	i.wealth_quintile_ns ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)
						
						
	// Women empowerment as rank 
	conindex skilled_battend, rank(wempo_index) svy wagstaff bounded limits(0 1)
	conindex2 skilled_battend, 	rank(wempo_index) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wealth_quintile_ns) ///
						svy wagstaff bounded limits(0 1)
							
	****************************************************************************
	** Mom PNC **
	****************************************************************************
	
	* adjustment - make 0 for those who did not get ANC
	foreach var of varlist pnc_who_trained {
	    
	    tab `var', m 
		replace `var' = 0 if pnc_yn == 0
		tab `var', m 
	}
	
	
	// pnc_yn 
	svy: mean  pnc_yn
	svy: tab stratum_num pnc_yn, row 
	svy: tab NationalQuintile pnc_yn, row
	svy: tab child_dob_season_yr pnc_yn if child_dob_year < 2023, row
	svy: tab wealth_quintile_ns pnc_yn, row
	
	svy: reg pnc_yn hfc_near_dist_dry 
	svy: reg pnc_yn hfc_near_dist_rain 	
	
	svy: tab hhitems_phone pnc_yn, row 
	svy: tab prgexpo_pn pnc_yn, row 	
	svy: tab edu_exposure pnc_yn, row 
	
	// pnc_where 
	svy: mean pnc_where_1 pnc_where_2 pnc_where_3 pnc_where_4 pnc_where_5 pnc_where_6 pnc_where_888 pnc_where_999
	svy: tab stratum_num pnc_where, row 
	svy: tab NationalQuintile pnc_where, row 
	svy: tab NationalQuintile_recod pnc_where, row 
	svy: tab wealth_quintile_ns pnc_where, row 
	
	svy: mean 	pnc_where_1 pnc_where_2 pnc_where_3 pnc_where_4 pnc_where_5 pnc_where_6 pnc_where_888 pnc_where_999, ///
				over(stratum_num)
				
	svy: mean 	pnc_where_1 pnc_where_2 pnc_where_3 pnc_where_4 pnc_where_5 pnc_where_6 pnc_where_888 pnc_where_999, ///
				over(NationalQuintile)
				
	svy: mean 	pnc_where_1 pnc_where_2 pnc_where_3 pnc_where_4 pnc_where_5 pnc_where_6 pnc_where_888 pnc_where_999, ///
				over(wealth_quintile_ns)
				
	// pnc_*_who
	// pnc_who_1 pnc_who_2 pnc_who_3 pnc_who_4 pnc_who_5 pnc_who_6 pnc_who_7 pnc_who_8 pnc_who_9 pnc_who_10 pnc_who_11 pnc_who_888
	
	
	svy: mean 	pnc_who_1 pnc_who_2 pnc_who_3 pnc_who_4 pnc_who_5 pnc_who_6 ///
				pnc_who_7 pnc_who_8 pnc_who_9 pnc_who_10 pnc_who_11 pnc_who_888
	
	svy: mean 	pnc_who_1 pnc_who_2 pnc_who_3 pnc_who_4 pnc_who_5 pnc_who_6 ///
				pnc_who_7 pnc_who_8 pnc_who_9 pnc_who_10 pnc_who_11 pnc_who_888, ///
				over(stratum_num)
	
	foreach var of varlist 	pnc_who_1 pnc_who_2 pnc_who_3 pnc_who_4 pnc_who_5 ///
							pnc_who_6 pnc_who_7 pnc_who_8 pnc_who_9 pnc_who_10 ///
							pnc_who_11 pnc_who_888 {
		
		svy: tab stratum_num `var', row 
	}
	
	svy: mean 	pnc_who_1 pnc_who_2 pnc_who_3 pnc_who_4 pnc_who_5 pnc_who_6 ///
				pnc_who_7 pnc_who_8 pnc_who_9 pnc_who_10 pnc_who_11 pnc_who_888, ///
				over(NationalQuintile)
				
	svy: mean 	pnc_who_1 pnc_who_2 pnc_who_3 pnc_who_4 pnc_who_5 pnc_who_6 ///
				pnc_who_7 pnc_who_8 pnc_who_9 pnc_who_10 pnc_who_11 pnc_who_888, ///
				over(wealth_quintile_ns)
				
	
	foreach var of varlist 	pnc_who_1 pnc_who_2 pnc_who_3 pnc_who_4 pnc_who_5 ///
							pnc_who_6 pnc_who_7 pnc_who_8 pnc_who_9 pnc_who_10 ///
							pnc_who_11 pnc_who_888 {
		
		svy: tab NationalQuintile `var', row 
	}
	
	
	foreach var of varlist 	pnc_who_1 pnc_who_2 pnc_who_3 pnc_who_4 pnc_who_5 ///
							pnc_who_6 pnc_who_7 pnc_who_8 pnc_who_9 pnc_who_10 ///
							pnc_who_11 pnc_who_888 {
		
		svy: tab NationalQuintile_recod `var', row 
	}
		
	
	foreach var of varlist 	pnc_who_1 pnc_who_2 pnc_who_3 pnc_who_4 pnc_who_5 ///
							pnc_who_6 pnc_who_7 pnc_who_8 pnc_who_9 pnc_who_10 ///
							pnc_who_11 pnc_who_888 {
		
		svy: tab wealth_quintile_ns `var', row 
	}	
	
		
	// pnc_who_trained
	svy: mean  pnc_who_trained
	svy: tab stratum_num pnc_who_trained, row 
	svy: tab NationalQuintile pnc_who_trained, row
	svy: tab child_dob_season_yr pnc_who_trained if child_dob_year < 2023, row
	svy: tab wealth_quintile_ns pnc_who_trained, row

	svy: reg pnc_who_trained hfc_near_dist_dry 
	svy: reg pnc_who_trained hfc_near_dist_rain 	
	
	svy: tab hhitems_phone pnc_yn, row 
	svy: tab prgexpo_pn pnc_yn, row 	
	svy: tab edu_exposure pnc_yn, row 
	
	svy: tab hhitems_phone pnc_who_trained, row 
	svy: tab prgexpo_pn pnc_who_trained, row 	
	svy: tab edu_exposure pnc_who_trained, row 
	
	
	local outcome 	pnc_yn pnc_who_trained
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}
	
	
	foreach v in `outcome' {
		
		svy: logit `v' KDHW stratum org_name_num 
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/17_mom_pnc_all_table.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace

	foreach v in `outcome' {
		
		svy: logit `v' KDHW i.org_name_num##stratum  
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/17_mom_pnc_all_table_m2.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	svy: tab hh_mem_dob_str pnc_yn, row 
	svy: tab hh_mem_dob_str pnc_who_trained, row 
	
	svy: reg pnc_yn wempo_index 
	svy: reg pnc_who_trained wempo_index 

	**************************
	** FINAL MODEL TABLES **
	**************************
	
	// pnc_yn
	svy: tab pnc_yn, ci 
	
	svy: tab resp_highedu pnc_yn, row 
	svy: tab mom_age_grp pnc_yn, row 
	svy: tab respd_chid_num_grp pnc_yn, row 

	svy: tab delivery_month_season pnc_yn, row 
	
	svy: tab hfc_vill_yes pnc_yn, row 
	svy: mean hfc_near_dist , over(pnc_yn) 
	svy: tab hfc_distance pnc_yn, row 
	
	svy: tab wealth_quintile_ns pnc_yn, row 
	svy: tab progressivenss pnc_yn, row 
	svy: tab wempo_category pnc_yn, row 

	svy: tab org_name_num pnc_yn, row 
	svy: tab stratum pnc_yn, row 
	
	conindex pnc_yn, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 pnc_yn, 	rank(NationalScore) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								i.delivery_month_season ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)		
		
	// pnc_who_trained
	svy: tab pnc_who_trained, ci 
	
	svy: tab resp_highedu pnc_who_trained, row 
	svy: tab mom_age_grp pnc_who_trained, row 
	svy: tab respd_chid_num_grp pnc_who_trained, row 

	svy: tab delivery_month_season pnc_who_trained, row 
	
	svy: tab hfc_vill_yes pnc_who_trained, row 
	svy: mean hfc_near_dist , over(pnc_who_trained) 
	svy: tab hfc_distance pnc_who_trained, row 
	
	svy: tab wealth_quintile_ns pnc_who_trained, row 
	svy: tab progressivenss pnc_who_trained, row 
	svy: tab wempo_category pnc_who_trained, row 

	svy: tab org_name_num pnc_who_trained, row 
	svy: tab stratum pnc_who_trained, row 
	
	conindex pnc_who_trained, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 pnc_who_trained, 	rank(NationalScore) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								i.delivery_month_season ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)

	
	// Logistic regression 					
	local outcomes	pnc_yn pnc_who_trained 
	
	foreach outcome in `outcomes' {
	 
		local regressor  	resp_highedu mom_age_grp respd_chid_num_grp ///
							delivery_month_season ///
							hfc_distance ///
							wealth_quintile_ns wempo_category org_name_num stratum  
		
		foreach v in `regressor' {
			
			putexcel set "$out/reg_output/PNC_`outcome'_logistic_models.xls", sheet("`v'") modify 
		
			if "`v'" == "hfc_near_dist" {
				svy: glm `outcome' `v', family(poisson) link(log) nolog eform // svy: logistic
			}
			else {
				svy: glm `outcome' i.`v', family(poisson) link(log) nolog eform // svy: logistic
			}
			
			estimates store `v', title(`v')
			
			putexcel (A1) = etable
			
		}
			
	}
	

	local outcomes	pnc_yn pnc_who_trained
	
	foreach outcome in `outcomes' {
	 
			
		putexcel set "$out/reg_output/PNC_`outcome'_logistic_models.xls", sheet("Final_model") modify 
		
		svy: glm `outcome' 	i.resp_highedu /// // svy: logistic
							i.mom_age_grp ///
							i.respd_chid_num_grp ///
							i.delivery_month_season ///
							hfc_vill_yes ///
							i.hfc_distance ///
							i.wealth_quintile_ns ///
							i.wempo_category ///
							i.org_name_num ///
							stratum, ///
							family(binomial) link(log) nolog eform
		putexcel (A1) = etable
			
	}
	
	
	** pnc_yn  
	
	local outcomes	pnc_yn 
	
	foreach outcome in `outcomes' {
	 
			
		putexcel set "$out/reg_output/PNC_`outcome'_logistic_models.xls", sheet("Final_model") modify 
		
		svy: glm `outcome' 	i.resp_highedu /// // svy: logistic
							/*i.mom_age_grp*/ ///
							i.respd_chid_num_grp ///
							/*i.delivery_month_season*/ ///
							i.hfc_distance ///
							i.wealth_quintile_ns ///
							/*i.wempo_category*/ ///
							i.org_name_num ///
							stratum, ///
							family(poisson) link(log) nolog eform
		putexcel (A1) = etable
			
	}
						
	conindex pnc_yn, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 pnc_yn, 	rank(NationalScore) ///
						covars(	i.resp_highedu /// // svy: logistic
								/*i.mom_age_grp*/ ///
								i.respd_chid_num_grp ///
								/*i.delivery_month_season*/ ///
								i.hfc_distance ///
								/*i.wempo_category*/ ///
								i.org_name_num ///
								stratum) ///
						svy wagstaff bounded limits(0 1)
						
	// Education as rank
	conindex pnc_yn, rank(resp_highedu_ci) svy wagstaff bounded limits(0 1)
	conindex2 pnc_yn, 	rank(resp_highedu_ci) ///
						covars(	i.wealth_quintile_ns ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)
						
						
	// Women empowerment as rank 
	conindex pnc_yn, rank(wempo_index) svy wagstaff bounded limits(0 1)
	conindex2 pnc_yn, 	rank(wempo_index) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wealth_quintile_ns) ///
						svy wagstaff bounded limits(0 1)
							
							
	** pnc_who_trained
	local outcomes	pnc_who_trained
	
	foreach outcome in `outcomes' {
	 
			
		putexcel set "$out/reg_output/PNC_`outcome'_logistic_models.xls", sheet("Final_model") modify 
		
		svy: glm `outcome' 	i.resp_highedu /// // svy: logistic
							/*i.mom_age_grp*/ ///
							i.respd_chid_num_grp ///
							/*i.delivery_month_season*/ ///
							i.hfc_distance ///
							i.wealth_quintile_ns ///
							/*i.wempo_category*/ ///
							/*i.org_name_num*/ ///
							stratum, ///
							family(poisson) link(log) nolog eform
		putexcel (A1) = etable
			
	}
						
	conindex pnc_who_trained, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 pnc_who_trained, 	rank(NationalScore) ///
						covars(	i.resp_highedu /// // svy: logistic
								/*i.mom_age_grp*/ ///
								i.respd_chid_num_grp ///
								/*i.delivery_month_season*/ ///
								i.hfc_distance ///
								/*i.wempo_category*/ ///
								/*i.org_name_num*/ ///
								stratum) ///
						svy wagstaff bounded limits(0 1)
						
	// Education as rank
	conindex pnc_who_trained, rank(resp_highedu_ci) svy wagstaff bounded limits(0 1)
	conindex2 pnc_who_trained, 	rank(resp_highedu_ci) ///
						covars(	i.wealth_quintile_ns ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)
						
						
	// Women empowerment as rank 
	conindex pnc_who_trained, rank(wempo_index) svy wagstaff bounded limits(0 1)
	conindex2 pnc_who_trained, 	rank(wempo_index) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wealth_quintile_ns) ///
						svy wagstaff bounded limits(0 1)
							
							
	****************************************************************************
	** Mom NBC **
	****************************************************************************
	* adjustment - make 0 for those who did not get ANC
	foreach var of varlist  nbc_who_trained {
	    
	    tab `var', m 
		replace `var' = 0 if nbc_yn == 0
		tab `var', m 
	}
	
	replace nbc_2days_yn = 0 if mi(nbc_2days_yn) & nbc_yn == 0
	tab nbc_2days_yn, m 
	
	// nbc_yn 
	svy: mean  nbc_yn
	svy: tab stratum_num nbc_yn, row 
	svy: tab NationalQuintile nbc_yn, row
	svy: tab child_dob_season_yr nbc_yn if child_dob_year < 2023, row
	svy: tab wealth_quintile_ns nbc_yn, row
	
	svy: reg nbc_yn hfc_near_dist_dry 
	svy: reg nbc_yn hfc_near_dist_rain 	
	
	// nbc_2days_yn
	svy: mean  nbc_2days_yn
	svy: tab stratum_num nbc_2days_yn, row 
	svy: tab NationalQuintile nbc_2days_yn, row
	svy: tab child_dob_season_yr nbc_2days_yn if child_dob_year < 2023, row
	svy: tab wealth_quintile_ns nbc_2days_yn, row

	svy: reg nbc_2days_yn hfc_near_dist_dry 
	svy: reg nbc_2days_yn hfc_near_dist_rain 	
	
	// nbc_where
	svy: mean nbc_where_1 nbc_where_2 nbc_where_3 nbc_where_4 nbc_where_5 nbc_where_6 nbc_where_7 nbc_where_888
	svy: tab stratum_num nbc_where, row 
	svy: tab NationalQuintile nbc_where, row 
	svy: tab NationalQuintile_recod nbc_where, row 
	svy: tab wealth_quintile_ns nbc_where, row 
	
	svy: mean nbc_where_1 nbc_where_2 nbc_where_3 nbc_where_4 nbc_where_5 nbc_where_6 nbc_where_7 nbc_where_888, ///
				over(stratum_num)
	
	svy: mean nbc_where_1 nbc_where_2 nbc_where_3 nbc_where_4 nbc_where_5 nbc_where_6 nbc_where_7 nbc_where_888, ///
				over(NationalQuintile)
	
	svy: mean nbc_where_1 nbc_where_2 nbc_where_3 nbc_where_4 nbc_where_5 nbc_where_6 nbc_where_7 nbc_where_888, ///
				over(wealth_quintile_ns)
	
	// nbc_*_who
	// nbc_who_1 nbc_who_2 nbc_who_3 nbc_who_4 nbc_who_5 nbc_who_6 nbc_who_7 nbc_who_8 nbc_who_9 nbc_who_10 nbc_who_11 nbc_who_888
	
	svy: mean 	nbc_who_1 nbc_who_2 nbc_who_3 nbc_who_4 nbc_who_5 nbc_who_6 ///
				nbc_who_7 nbc_who_8 nbc_who_9 nbc_who_10 nbc_who_11 nbc_who_888
	
	svy: mean 	nbc_who_1 nbc_who_2 nbc_who_3 nbc_who_4 nbc_who_5 nbc_who_6 ///
				nbc_who_7 nbc_who_8 nbc_who_9 nbc_who_10 nbc_who_11 nbc_who_888, ///
				over(stratum_num)
	
	foreach var of varlist 	nbc_who_1 nbc_who_2 nbc_who_3 nbc_who_4 nbc_who_5 ///
							nbc_who_6 nbc_who_7 nbc_who_8 nbc_who_9 nbc_who_10 ///
							nbc_who_11 nbc_who_888 {
		
		svy: tab stratum_num `var', row 
	}
	
	svy: mean 	nbc_who_1 nbc_who_2 nbc_who_3 nbc_who_4 nbc_who_5 nbc_who_6 ///
				nbc_who_7 nbc_who_8 nbc_who_9 nbc_who_10 nbc_who_11 nbc_who_888, ///
				over(NationalQuintile)
	
	svy: mean 	nbc_who_1 nbc_who_2 nbc_who_3 nbc_who_4 nbc_who_5 nbc_who_6 ///
				nbc_who_7 nbc_who_8 nbc_who_9 nbc_who_10 nbc_who_11 nbc_who_888, ///
				over(wealth_quintile_ns)
				
	foreach var of varlist 	nbc_who_1 nbc_who_2 nbc_who_3 nbc_who_4 nbc_who_5 ///
							nbc_who_6 nbc_who_7 nbc_who_8 nbc_who_9 nbc_who_10 ///
							nbc_who_11 nbc_who_888 {
		
		svy: tab NationalQuintile `var', row 
	}
	
	
	foreach var of varlist 	nbc_who_1 nbc_who_2 nbc_who_3 nbc_who_4 nbc_who_5 ///
							nbc_who_6 nbc_who_7 nbc_who_8 nbc_who_9 nbc_who_10 ///
							nbc_who_11 nbc_who_888 {
		
		svy: tab NationalQuintile_recod `var', row 
	}	
	
	
	foreach var of varlist 	nbc_who_1 nbc_who_2 nbc_who_3 nbc_who_4 nbc_who_5 ///
							nbc_who_6 nbc_who_7 nbc_who_8 nbc_who_9 nbc_who_10 ///
							nbc_who_11 nbc_who_888 {
		
		svy: tab wealth_quintile_ns `var', row 
	}	
		
	
	// nbc_who_trained
	svy: mean  nbc_who_trained
	svy: tab stratum_num nbc_who_trained, row 
	svy: tab NationalQuintile nbc_who_trained, row
	svy: tab child_dob_season_yr nbc_who_trained if child_dob_year < 2023, row
	svy: tab wealth_quintile_ns nbc_who_trained, row

	svy: reg nbc_who_trained hfc_near_dist_dry 
	svy: reg nbc_who_trained hfc_near_dist_rain 	
	
	svy: tab hhitems_phone nbc_yn, row 
	svy: tab prgexpo_pn nbc_yn, row 	
	svy: tab edu_exposure nbc_yn, row 
	
	svy: tab hhitems_phone nbc_2days_yn, row 
	svy: tab prgexpo_pn nbc_2days_yn, row 	
	svy: tab edu_exposure nbc_2days_yn, row 
	
	svy: tab hhitems_phone nbc_who_trained, row 
	svy: tab prgexpo_pn nbc_who_trained, row 	
	svy: tab edu_exposure nbc_who_trained, row 
	
	
	local outcome 	nbc_yn nbc_2days_yn nbc_who_trained
	
	foreach v in `outcome' {
		
		foreach var of varlist NationalQuintile income_lastmonth hh_mem_highedu_all {
		
			conindex `v', rank(`var') svy wagstaff bounded limits(0 1)
		}
	
	}
	
	
	
	foreach v in `outcome' {
		
		svy: logit `v' KDHW stratum org_name_num 
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/18_mom_nbc_all_table.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	foreach v in `outcome' {
		
		svy: logit `v' KDHW i.org_name_num##stratum  
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/18_mom_nbc_all_table_m2.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	svy: tab hh_mem_dob_str nbc_yn, row 
	svy: tab hh_mem_dob_str nbc_2days_yn, row 
	svy: tab hh_mem_dob_str nbc_who_trained, row 
	
	svy: reg nbc_yn wempo_index 
	svy: reg nbc_2days_yn wempo_index 
	svy: reg nbc_who_trained wempo_index 
	
	
	**************************
	** FINAL MODEL TABLES **
	**************************
	
	// nbc_yn 
	svy: tab nbc_yn, ci 

	svy: tab resp_highedu nbc_yn, row 
	svy: tab mom_age_grp nbc_yn, row 
	svy: tab respd_chid_num_grp nbc_yn, row 

	svy: tab delivery_month_season nbc_yn, row 
	
	svy: tab hfc_vill_yes nbc_yn, row 
	svy: mean hfc_near_dist , over(nbc_yn) 
	svy: tab hfc_distance nbc_yn, row 
	
	svy: tab wealth_quintile_ns nbc_yn, row 
	svy: tab progressivenss nbc_yn, row 
	svy: tab wempo_category nbc_yn, row 

	svy: tab org_name_num nbc_yn, row 
	svy: tab stratum nbc_yn, row 
	
	conindex nbc_yn, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 nbc_yn, 	rank(NationalScore) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								i.delivery_month_season ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)		
		
	// nbc_2days_yn 
	svy: tab nbc_2days_yn, ci 
	
	svy: tab resp_highedu nbc_2days_yn, row 
	svy: tab mom_age_grp nbc_2days_yn, row 
	svy: tab respd_chid_num_grp nbc_2days_yn, row 

	svy: tab delivery_month_season nbc_2days_yn, row 
	
	svy: tab hfc_vill_yes nbc_2days_yn, row 
	svy: mean hfc_near_dist , over(nbc_2days_yn) 
	svy: tab hfc_distance nbc_2days_yn, row 
	
	svy: tab wealth_quintile_ns nbc_2days_yn, row 
	svy: tab progressivenss nbc_2days_yn, row 
	svy: tab wempo_category nbc_2days_yn, row 

	svy: tab org_name_num nbc_2days_yn, row 
	svy: tab stratum nbc_2days_yn, row 
	
	conindex nbc_2days_yn, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 nbc_2days_yn, 	rank(NationalScore) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								i.delivery_month_season ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)

	// nbc_who_trained
	svy: tab nbc_who_trained, ci 

	svy: tab resp_highedu nbc_who_trained, row 
	svy: tab mom_age_grp nbc_who_trained, row 
	svy: tab respd_chid_num_grp nbc_who_trained, row 

	svy: tab delivery_month_season nbc_who_trained, row 
	
	svy: tab hfc_vill_yes nbc_who_trained, row 
	svy: mean hfc_near_dist , over(nbc_who_trained) 
	svy: tab hfc_distance nbc_who_trained, row 
	
	svy: tab wealth_quintile_ns nbc_who_trained, row 
	svy: tab progressivenss nbc_who_trained, row 
	svy: tab wempo_category nbc_who_trained, row 

	svy: tab org_name_num nbc_who_trained, row 
	svy: tab stratum nbc_who_trained, row 
	
	conindex nbc_who_trained, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 nbc_who_trained, 	rank(NationalScore) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								i.delivery_month_season ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)
						
	// Logistic regression 					
	local outcomes	nbc_yn nbc_2days_yn nbc_who_trained
	
	foreach outcome in `outcomes' {
	 
		local regressor  	resp_highedu mom_age_grp respd_chid_num_grp ///
							delivery_month_season ///
							hfc_distance ///
							wealth_quintile_ns wempo_category org_name_num stratum  
		
		foreach v in `regressor' {
			
			putexcel set "$out/reg_output/NBC_`outcome'_logistic_models.xls", sheet("`v'") modify 
		
			if "`v'" == "hfc_near_dist" {
				svy: glm `outcome' `v', family(poisson) link(log) nolog eform // svy: logistic 
			}
			else {
				svy: glm `outcome' i.`v', family(poisson) link(log) nolog eform // svy: logistic 
			}
			
			estimates store `v', title(`v')
			
			putexcel (A1) = etable
			
		}
			
	}
	

	local outcomes	nbc_yn nbc_2days_yn nbc_who_trained
	
	foreach outcome in `outcomes' {
	 
			
		putexcel set "$out/reg_output/NBC_`outcome'_logistic_models.xls", sheet("Final_model") modify 
		
		svy: glm `outcome' 	i.resp_highedu /// // svy: logistic
							i.mom_age_grp ///
							i.respd_chid_num_grp ///
							i.delivery_month_season ///
							hfc_vill_yes ///
							i.hfc_distance ///
							i.wealth_quintile_ns ///
							i.wempo_category ///
							i.org_name_num ///
							stratum, ///
							family(binomial) link(log) nolog eform
		putexcel (A1) = etable
			
	}
	
	
	** nbc_yn   
	* got same RR from two models in both version 
	svy: glm nbc_yn i.wempo_category, family(poisson) link(log) nolog eform 
	svy: glm nbc_yn i.wempo_category, family(binomial) link(log) nolog eform 

	local outcomes	nbc_yn 
	
	foreach outcome in `outcomes' {
	 
			
		putexcel set "$out/reg_output/NBC_`outcome'_logistic_models.xls", sheet("Final_model") modify 
		
		svy: glm `outcome' 	i.resp_highedu /// // svy: logistic
							/*i.mom_age_grp*/ ///
							i.respd_chid_num_grp ///
							/*i.delivery_month_season*/ ///
							i.hfc_distance ///
							i.wealth_quintile_ns ///
							i.wempo_category ///
							i.org_name_num ///
							stratum, ///
							family(poisson) link(log) nolog eform
		putexcel (A1) = etable
			
	}
	
	* binomial had convergence not achieved issue
	svy: glm nbc_yn 	i.resp_highedu /// // svy: logistic
						/*i.mom_age_grp*/ ///
						i.respd_chid_num_grp ///
						/*i.delivery_month_season*/ ///
						i.hfc_distance ///
						i.wealth_quintile_ns ///
						i.wempo_category ///
						i.org_name_num ///
						stratum, ///
						family(binomial) link(log) nolog eform
			
	* SAME output svy: poisson , irr VS glm, family(poisson) link(log) nolog eform
	svy: poisson nbc_yn i.resp_highedu /// // svy: logistic
						/*i.mom_age_grp*/ ///
						i.respd_chid_num_grp ///
						/*i.delivery_month_season*/ ///
						i.hfc_distance ///
						i.wealth_quintile_ns ///
						i.wempo_category ///
						i.org_name_num ///
						stratum, ///
						irr
						
	svy: glm nbc_yn 	i.resp_highedu /// // svy: logistic
						/*i.mom_age_grp*/ ///
						i.respd_chid_num_grp ///
						/*i.delivery_month_season*/ ///
						i.hfc_distance ///
						i.wealth_quintile_ns ///
						i.wempo_category ///
						i.org_name_num ///
						stratum, ///
						family(poisson) link(log) nolog eform
								
	conindex nbc_yn, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 nbc_yn, 	rank(NationalScore) ///
						covars(	i.resp_highedu /// // svy: logistic
								/*i.mom_age_grp*/ ///
								i.respd_chid_num_grp ///
								/*i.delivery_month_season*/ ///
								i.hfc_distance ///
								i.wempo_category ///
								i.org_name_num ///
								stratum) ///
						svy wagstaff bounded limits(0 1)
						
	// Education as rank
	conindex nbc_yn, rank(resp_highedu_ci) svy wagstaff bounded limits(0 1)
	conindex2 nbc_yn, 	rank(resp_highedu_ci) ///
						covars(	i.wealth_quintile_ns ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)
						
						
	// Women empowerment as rank 
	conindex nbc_yn, rank(wempo_index) svy wagstaff bounded limits(0 1)
	conindex2 nbc_yn, 	rank(wempo_index) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wealth_quintile_ns) ///
						svy wagstaff bounded limits(0 1)
	
	** nbc_who_trained  
	local outcomes	nbc_who_trained 
	
	foreach outcome in `outcomes' {
	 
			
		putexcel set "$out/reg_output/NBC_`outcome'_logistic_models.xls", sheet("Final_model") modify 
		
		svy: glm `outcome' 	i.resp_highedu /// // svy: logistic
							/*i.mom_age_grp*/ ///
							i.respd_chid_num_grp ///
							/*i.delivery_month_season*/ ///
							i.hfc_distance ///
							i.wealth_quintile_ns ///
							i.wempo_category ///
							i.org_name_num ///
							stratum, ///
							family(poisson) link(log) nolog eform
		putexcel (A1) = etable
			
	}
						
	conindex nbc_who_trained, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex2 nbc_who_trained, 	rank(NationalScore) ///
						covars(	i.resp_highedu /// // svy: logistic
								/*i.mom_age_grp*/ ///
								i.respd_chid_num_grp ///
								/*i.delivery_month_season*/ ///
								i.hfc_distance ///
								i.wempo_category ///
								i.org_name_num ///
								stratum) ///
						svy wagstaff bounded limits(0 1)
						
	// Education as rank
	conindex nbc_who_trained, rank(resp_highedu_ci) svy wagstaff bounded limits(0 1)
	conindex2 nbc_who_trained, 	rank(resp_highedu_ci) ///
						covars(	i.wealth_quintile_ns ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wempo_category) ///
						svy wagstaff bounded limits(0 1)
						
						
	// Women empowerment as rank 
	conindex nbc_who_trained, rank(wempo_index) svy wagstaff bounded limits(0 1)
	conindex2 nbc_who_trained, 	rank(wempo_index) ///
						covars(	i.resp_highedu ///
								i.mom_age_grp ///
								i.respd_chid_num_grp ///
								hfc_vill_yes ///
								i.hfc_distance ///
								i.org_name_num ///
								stratum ///
								i.wealth_quintile_ns) ///
						svy wagstaff bounded limits(0 1)
						
	****************************************************************************
	** ALL MOM HEALTH **
	
	local outcome	anc_yn anc_who_trained anc_visit_trained anc_visit_trained_4times ////
					insti_birth skilled_battend ///
					pnc_yn pnc_who_trained ///
					nbc_yn nbc_2days_yn nbc_who_trained 
	   	
	foreach v in `outcome' {
		
		svy: reg `v' wempo_index NationalQuintile stratum NationalQuintile_stratum i.org_name_num 
		estimates store `v', title(`v')
		
	}
	

	estout `outcome' using "$out/reg_output/18_mom_healthseeking_all_FINAL.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
	   legend label varlabels(_cons constant)              ///
	   stats(r2 df_r bic) replace
	   
	// Model 4
	local outcome	anc_visit_trained
	
	foreach v in `outcome' {
		
		svy: reg `v' i.NationalQuintile i.org_name_num i.NationalQuintile stratum wempo_index // i.resp_highedu i.hh_mem_highedu_all
		//eststo model_B
		estimates store `v', title(`v')
		
	}
		
		estout `outcome' using "$out/reg_output/FINAL_MomHealth_Model_4.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
		   legend label varlabels(_cons constant)              ///
		   stats(r2 df_r bic) replace	

	foreach v in `outcome' {
		
		svy: reg `v' i.wealth_quintile_ns i.org_name_num i.wealth_quintile_ns stratum wempo_index // i.resp_highedu i.hh_mem_highedu_all
		//eststo model_B
		estimates store `v', title(`v')
		
	}
		
		estout `outcome' using "$out/reg_output/FINAL_MomHealth_Model_4_PNDist.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
		   legend label varlabels(_cons constant)              ///
		   stats(r2 df_r bic) replace
		   
	local outcome	anc_yn anc_who_trained anc_visit_trained_4times ////
					insti_birth skilled_battend ///
					pnc_yn pnc_who_trained ///
					nbc_yn nbc_2days_yn nbc_who_trained 
	
	foreach v in `outcome' {
		
		svy: logit `v' i.NationalQuintile i.org_name_num i.NationalQuintile stratum wempo_index // i.resp_highedu i.hh_mem_highedu_all
		//eststo model_B
		estimates store `v', title(`v')
		
	}
		
		estout `outcome' using "$out/reg_output/FINAL_MomHealth_Model_4_logistic.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
		   legend label varlabels(_cons constant)              ///
		   stats(r2 df_r bic) replace	
	
	foreach v in `outcome' {
		
		svy: logit `v' i.wealth_quintile_ns i.org_name_num i.wealth_quintile_ns stratum wempo_index // i.resp_highedu i.hh_mem_highedu_all
		//eststo model_B
		estimates store `v', title(`v')
		
	}
		
		estout `outcome' using "$out/reg_output/FINAL_MomHealth_Model_4_logistic_PNDist.xls", cells(b(star fmt(3)) se(par fmt(2)))  ///
		   legend label varlabels(_cons constant)              ///
		   stats(r2 df_r bic) replace		
	
	** lowess curve: distance to hfc and mom health indicator 
	lab var anc_yn "Received ANC with anyone"
	lab var anc_who_trained "Received ANC with trained health personnel"
	lab var anc_visit_trained_4times "At least four ANC visits"
	lab var pnc_yn "Received PNC with anyone"
	lab var pnc_who_trained "Received PNC with trained health personnel"
	lab var nbc_yn "Received NBC with anyone"
	lab var nbc_who_trained "Received NBC with trained health personnel"

	local outcome anc_yn anc_who_trained anc_visit_trained_4times ///
					insti_birth skilled_battend ///
					pnc_yn pnc_who_trained ///
					nbc_yn nbc_who_trained
					
	
	foreach var in `outcome' {
		
		* Create a scatter plot with lowess curves 
		twoway scatter `var' hfc_near_dist, ///
			mcolor(blue) msize(small) ///
			legend(off)

		* Add lowess curves
		lowess `var' hfc_near_dist, ///
			lcolor(red) lwidth(medium) ///
			legend(label(1 "Lowess Curve"))
			
		graph export "$plots/lowess_`var'_hfc_distance.png", replace
	
	}
	

	
	* Equi Plot * 
	* ref: https://www.equidade.org/equiplot
	import excel using "$result/01_sumstat_formatted_U2Mom_Sample.xlsx", sheet("equiplot") firstrow clear 
	
	equiplot Poorest Poor Medium Wealthy Wealthiest, over(indicator)
	
	equiplot 	Poorest Poor Medium Wealthy Wealthiest, ///
				over(indicator) sort(order) dotsize(3) ///
				xtitle("% of Mothers with U2 children ") legtitle("Wealth Quintiles") connected

	graph export "$plots/EquiPlot_Mom_Health_Seeking.png", replace
	
	
	****************************************************************************
	** PHQ9 **
	****************************************************************************
	
	use "$dta/pnourish_PHQ9_final.dta", clear  

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)
	
	svy: tab phq9_cat, ci 
	svy: tab stratum_num phq9_cat, row 
	svy: tab NationalQuintile phq9_cat, row

	svy: tab hhitems_phone phq9_cat, row 
	svy: tab prgexpo_pn phq9_cat, row 	
	svy: tab edu_exposure phq9_cat, row 
	
	svy: tab wealth_quintile_ns phq9_cat, row 
	
	
	

	****************************************************************************
	** Women Empowerment **
	****************************************************************************
	
	use "$dta/pnourish_WOMEN_EMPOWER_final.dta", clear  

	* svy weight apply 
	svyset [pweight = weight_final], strata(stratum_num) vce(linearized) psu(geo_vill)


	// 1) Own health care.
	// women_ownhealth
	svy: mean  women_ownhealth
	svy: tab stratum_num women_ownhealth, row 
	svy: tab NationalQuintile women_ownhealth, row
	

	// 2) Large household purchases.
	// women_hhpurchase
	svy: mean  women_hhpurchase
	svy: tab stratum_num women_hhpurchase, row 
	svy: tab NationalQuintile women_hhpurchase, row
	
	// 3) Visits to family or relatives.
	tab women_visit, m 
	svy: mean  women_visit
	svy: tab stratum_num women_visit, row 
	svy: tab NationalQuintile women_visit, row
	
/*	foreach var of varlist 	wempo_childcare wempo_mom_health wempo_child_health ///
							wempo_women_wages wempo_major_purchase wempo_visiting ///
							wempo_women_health wempo_child_wellbeing {
								
		gen `var'_d = (`var' ==  1)
		replace `var'_d = .m if mi(`var')
		drop `var'
		rename `var'_d `var'
		tab `var', m 
							}*/

							
	* Individual parameter - dummy variables 
	svy: mean	wempo_childcare_yes wempo_mom_health_yes wempo_child_health_yes ///
				wempo_women_wages_yes wempo_major_purchase_yes wempo_visiting_yes ///
				wempo_women_health_yes wempo_child_wellbeing_yes
							
	
	foreach var of varlist 	wempo_childcare_yes wempo_mom_health_yes wempo_child_health_yes ///
							wempo_women_wages_yes wempo_major_purchase_yes wempo_visiting_yes ///
							wempo_women_health_yes wempo_child_wellbeing_yes{
								
		di "`var'"
		svy: tab wealth_quintile_ns `var', row   
		//conindex `var', rank(NationalScore) svy wagstaff bounded limits(0 1)
		
		}	
	
	svy: mean 	wempo_childcare wempo_mom_health wempo_child_health ///
				wempo_women_wages wempo_major_purchase wempo_visiting ///
				wempo_women_health wempo_child_wellbeing
				
	foreach var of varlist 	wempo_childcare wempo_mom_health wempo_child_health ///
							wempo_women_wages wempo_major_purchase wempo_visiting ///
							wempo_women_health wempo_child_wellbeing {
								
		svy: tab stratum_num `var', row 
		
							}
							
	svy: mean 	wempo_childcare wempo_mom_health wempo_child_health ///
				wempo_women_wages wempo_major_purchase wempo_visiting ///
				wempo_women_health wempo_child_wellbeing, ///
				over(stratum_num)	
	
	foreach var of varlist 	wempo_childcare wempo_mom_health wempo_child_health ///
							wempo_women_wages wempo_major_purchase wempo_visiting ///
							wempo_women_health wempo_child_wellbeing {
								
		svy: tab NationalQuintile `var', row 
		
							}
							
	svy: mean 	wempo_childcare wempo_mom_health wempo_child_health ///
				wempo_women_wages wempo_major_purchase wempo_visiting ///
				wempo_women_health wempo_child_wellbeing, ///
				over(NationalQuintile)	
				
	
	
	foreach var of varlist 	wempo_childcare wempo_mom_health wempo_child_health ///
							wempo_women_wages wempo_major_purchase wempo_visiting ///
							wempo_women_health wempo_child_wellbeing {
					
		di "`var'"
		gen `var'_w = (`var' == 1)
		replace `var'_w = .m if mi(`var')
		//svy: tab NationalQuintile `var', row 
		conindex `var'_w, rank(NationalScore) svy wagstaff bounded limits(0 1)
		
		}
			
			
	sum wempo_childcare wempo_mom_health wempo_child_health ///
							wempo_women_wages wempo_major_purchase wempo_visiting ///
							wempo_women_health wempo_child_wellbeing
							
	// women group 
	svy: mean 	wempo_group1 wempo_group2 wempo_group3 wempo_group4 wempo_group5 wempo_group888
	
	
	// wempo_childcare 
	svy: tab hhitems_phone wempo_childcare, row 
	svy: tab prgexpo_pn wempo_childcare, row 	
	svy: tab edu_exposure wempo_childcare, row 

	// wempo_mom_health 
	svy: tab hhitems_phone wempo_mom_health, row 
	svy: tab prgexpo_pn wempo_mom_health, row 	
	svy: tab edu_exposure wempo_mom_health, row 
	
	// wempo_child_health 
	svy: tab hhitems_phone wempo_child_health, row 
	svy: tab prgexpo_pn wempo_child_health, row 	
	svy: tab edu_exposure wempo_child_health, row 
		
	// wempo_women_wages 
	svy: tab hhitems_phone wempo_women_wages, row 
	svy: tab prgexpo_pn wempo_women_wages, row 	
	svy: tab edu_exposure wempo_women_wages, row 
	
	// wempo_major_purchase 
	svy: tab hhitems_phone wempo_major_purchase, row 
	svy: tab prgexpo_pn wempo_major_purchase, row 	
	svy: tab edu_exposure wempo_major_purchase, row 
	
	// wempo_visiting 
	svy: tab hhitems_phone wempo_visiting, row 
	svy: tab prgexpo_pn wempo_visiting, row 	
	svy: tab edu_exposure wempo_visiting, row 
							
	// wempo_women_health 
	svy: tab hhitems_phone wempo_women_health, row 
	svy: tab prgexpo_pn wempo_women_health, row 	
	svy: tab edu_exposure wempo_women_health, row 
	
	// wempo_child_wellbeing
	svy: tab hhitems_phone wempo_child_wellbeing, row 
	svy: tab prgexpo_pn wempo_child_wellbeing, row 	
	svy: tab edu_exposure wempo_child_wellbeing, row 
	
	// wempo_index - Women Empowerment Index - ICW - Index 
	svy: mean wempo_index, over(NationalQuintile)	
	svy: mean wempo_index, over(stratum_num)
	
	svy: mean wempo_index, over(hhitems_phone)
	svy: mean wempo_index, over(prgexpo_pn)
	svy: mean wempo_index, over(edu_exposure)
	
	svy: reg wempo_grp_tot wempo_index 

	
	* Women empowerment by stratum 
	svy: mean wempo_index
	svy: mean wempo_index, over(stratum_num)
	test _b[c.wempo_index@1bn.stratum_num] = _b[c.wempo_index@2bn.stratum_num] = _b[c.wempo_index@3bn.stratum_num] = _b[c.wempo_index@4bn.stratum_num] = _b[c.wempo_index@5bn.stratum_num]

	
	* Women empowerment by wealth quintile - national cut-off 
	svy: mean wempo_index, over(NationalQuintile)
	test _b[c.wempo_index@1bn.NationalQuintile] = _b[c.wempo_index@2bn.NationalQuintile] = _b[c.wempo_index@3bn.NationalQuintile] = _b[c.wempo_index@4bn.NationalQuintile] = _b[c.wempo_index@5bn.NationalQuintile]
	
	* Women empowerment by wealth quintile - project nourish cut-off  
	svy: mean wempo_index, over(wealth_quintile_ns)
	test _b[c.wempo_index@1bn.wealth_quintile_ns] = _b[c.wempo_index@2bn.wealth_quintile_ns] = _b[c.wempo_index@3bn.wealth_quintile_ns] = _b[c.wempo_index@4bn.wealth_quintile_ns] = _b[c.wempo_index@5bn.wealth_quintile_ns]

	svy: mean wempo_index, over(wealth_quintile_modify)
	test _b[c.wempo_index@1bn.wealth_quintile_modify] = _b[c.wempo_index@2bn.wealth_quintile_modify] = _b[c.wempo_index@3bn.wealth_quintile_modify] = _b[c.wempo_index@4bn.wealth_quintile_modify] = _b[c.wempo_index@5bn.wealth_quintile_modify]

	svy: tab stratum_num wempo_category , row 
	svy: tab wealth_quintile_ns wempo_category , row 
	
	
	svy: mean wempo_index, over(hhitems_phone) 
	svy: mean wempo_index, over(pn_yes)  
	svy: mean wempo_index, over(edu_exposure) 
	
	encode enu_name, gen(enu_name_num)
	svy: mean wempo_index if org_name_num == 1, over(enu_name_num)
	svy: mean wempo_index if org_name_num == 2, over(enu_name_num)
	svy: mean wempo_index if org_name_num == 3, over(enu_name_num)
	
	
	conindex progressivenss, rank(NationalScore) svy wagstaff bounded limits(0 1)
	conindex wempo_index, rank(NationalScore) svy truezero generalized
	
	
	sum wempo_index
	gen wempo_index_rescale = wempo_index + abs(r(min))
	sum wempo_index wempo_index_rescale
	
	conindex wempo_index_rescale, rank(NationalScore) svy wagstaff bounded limits(0 2.500905)
	
	
	svy: mean progressivenss
	svy: mean progressivenss, over(NationalQuintile)
	
	svy: mean high_empower
	svy: mean high_empower, over(NationalQuintile)
	conindex high_empower, rank(NationalScore) svy wagstaff bounded limits(0 1)

	
	
// END HERE 



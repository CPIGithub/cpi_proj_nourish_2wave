* original draft file - decompisition 
	****************************************************************************
	** Decomposition of the concentration index ** - Chapter 13	
	****************************************************************************
	* creating the dummy varaibles 
	foreach var of varlist 	stratum resp_highedu_ci {
						    
		tab `var', gen(`var'_)			
							
				}
			
	global X_raw		income_lastmonth wempo_index hfc_near_dist ///
						stratum_2 ///
						resp_highedu_ci_2 resp_highedu_ci_3 resp_highedu_ci_4 ///
						resp_highedu_ci_5 resp_highedu_ci_6

	
	gen rank = NationalScore 
	gen weight_var = weight_final
	
	
	
	* ANC CI * 
	conindex anc_yn, rank(NationalScore) svy wagstaff bounded limits(0 1)
	scalar CI = r(CI)
	
	* identify the omitted variables 
	svy: probit anc_yn $X_raw 
	dprobit anc_yn $X_raw [pw = weight_final]

	matrix b = e(b)
	local names : colfullnames e(b)
	
	di "`names'"

	local names	= subinstr("`names'", "_cons", "", 1)
	di "`names'"
	
	* redefine the unfair var set without omitted var 
	global X "`names'"
	
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
		 	
			di "this is working `x'"
			
			mat b_`x' = dfdx[1,"`x'"]
			sca b_`x' = b_`x'[1,1] 
			
			//corr NationalScore `x' [aw = weight_final], c // rank - use NationalScore
			//sca cov_`x' = r(cov_12)    
			
			sum `x' [aw = weight_final]
			sca m_`x' = r(mean)    
			
			sca elas_`x' = (b_`x' * m_`x') / m_y 
			//sca CI_`x' = 2 * cov_`x' / m_`x'  // replace with same CI formula use for outcome var
			sum `x' [aw = weight_final]
			local minb = round(r(min), 0.0000001)
			local maxb = round(r(max), 0.0000001)
			di "conindex `x', rank(NationalScore) svy wagstaff bounded limits(`minb' `maxb')"
			conindex `x', rank(NationalScore) svy wagstaff bounded limits(`minb' `maxb')
			sca CI_`x' = r(CI)
			
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
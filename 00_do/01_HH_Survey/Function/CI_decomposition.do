	/*******************************************************************************
	Purpose				:	generate a CI decomposition table			
	Author				:	Nicholus Tint Zaw
	Date				: 	04/29/2025
	Modified by			:
	
	Ref: WB ** Decomposition of the concentration index ** - Chapter 13	+ 15
		- for binary yes/no outcome only 

	*******************************************************************************/

	* Step 1: Estimate CI of outcome
	conindex $outcome_var, rank(rank) svy wagstaff bounded limits(0 1)
	scalar CI = r(CI)
	
	* Step 2: Estimate full model and detect omitted variables
	svy: probit $outcome_var $X_raw 
	dprobit $outcome_var $X_raw [pw = weight_var]

	matrix b = e(b)
	local names : colfullnames e(b)
	
	di "`names'"

	local names	= subinstr("`names'", "_cons", "", 1)
	di "`names'"
	
	* redefine the unfair var set without omitted var 
	global X "`names'"
	
	svy: probit $outcome_var $X 
	dprobit $outcome_var $X [pw = weight_var]
	
	* Step 3: Standardize covariates
	foreach z of global X {
	 gen copy_`z'=`z'
	 qui sum `z' [aw = weight_var]
	 replace `z' = r(mean)
	 }
	 
	predict yhat 
	 
	foreach z of global X {
	 replace `z' = copy_`z'
	 drop copy_`z'
	 }
	 
	sum yhat [aw = weight_var]
	sca m_y = r(mean)
	gen yst = $outcome_var - yhat + m_y
 
	* Step 4: Re-estimate marginal effects
	dprobit $outcome_var $X [pw = weight_var]
	matrix dfdx = e(dfdx)
	
	preserve 
		clear 
		tempfile empty 
		save `empty', emptyok 
	restore 
	
	* Step 5: Initialize results
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
		 	
			di "Now working for the covariate - `x'"
			
			mat b_`x' = dfdx[1,"`x'"]
			sca b_`x' = b_`x'[1,1] 
						
			* Elasticity 
			//corr NationalScore `x' [aw = weight_final], c // rank - use NationalScore
			//sca cov_`x' = r(cov_12) // replace with same CI formula use for outcome var

			sum `x' [aw = weight_var]
			sca m_`x' = r(mean)    
			sca elas_`x' = (b_`x' * m_`x') / m_y 
			
			* Concentration index of the variable
			//sca CI_`x' = 2 * cov_`x' / m_`x'  // replace with same CI formula use for outcome var
			
			sum `x' [aw = weight_var]
			local minb = round(r(min), 0.0001) - 0.001
			local maxb = round(r(max), 0.0001) + 0.001
			
			//levelsof `x', local(covar)
			//if "`covar'" == "0 1" {
				
				di "conindex `x', rank(rank) svy wagstaff bounded limits(`minb' `maxb')"
				conindex `x', rank(rank) svy wagstaff bounded limits(`minb' `maxb')
			//}
			//else {
				
				//conindex `x', rank(rank) svy // truezero generalized
			//}

			
			
			sca CI_`x' = r(CI)
			
			* Contribution
			sca con_`x' = elas_`x' * CI_`x'   
			sca prcnt_`x' = con_`x' / CI   
			sca need = need + con_`x'
		 }
		 
		di "`x' elasticity:", elas_`x'
		di "`x' concentration index:", CI_`x'
		di "`x' contribution:", con_`x'
		di "`x' percentage contribution:", prcnt_`x'
		 
		replace sir					= `i'
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
	sca HI = CI - need
	di "Horizontal Inequity Index:", HI
	
	* Finalize dataset
	use `empty', clear 
	sort sir 
	drop sir 
	
    gen need_factor 			= need
    gen outcome_ci 				= CI
    gen horizontal_index 		= CI - need
	gen contribution_pct_abs	= abs(contribution_pct)
    egen tot_fact_contr_pct 	= total(contribution_pct_abs)
	drop contribution_pct_abs
    gen residual 				= CI - need_factor
	
	lab var var 				"Unfair factor variable names"
	lab var elasticity 			"Elasticities" 
	lab var var_ci 				"CI: Unfair factors"
	lab var contribution 		"Contributions"
	lab var contribution_pct 	"Percentage contributions"
	lab var need_factor 		"Total Unfair factor's contributions"
	lab var outcome_ci 			"CI of outcome: `outcome'"
	lab var horizontal_index 	"Horizontal inequity index"
	lab var tot_fact_contr_pct 	"Total Percentage contributions"
	lab var residual			"Residual"
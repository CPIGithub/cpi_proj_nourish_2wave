	/*******************************************************************************
	Purpose				:	Sample Demo Workflow for CI decomposition Analysis			
	Author				:	Nicholus Tint Zaw
	Date				: 	05/27/2025
	Modified by			:
	
	Ref: WB ** Decomposition of the concentration index ** - Chapter 13	+ 15
		- for binary yes/no outcome only 

	*******************************************************************************/

	****************************************************************************
	* Step 0: Prepration of ranking variable for Multivar CI 
	****************************************************************************
	
	* Final set of unfiar var 
	* post-fix 0m: moving min to ZERO (for z score type var) and 
	* post-fix 0n: binary dummy var for categegory var 
	
	global X_raw		NationalScore_m0 logincome /// 
						wempo_index_m0 ///
						hfc_distance_1 hfc_distance_2 hfc_distance_3 ///
						stratum_1 ///
						resp_highedu_2 resp_highedu_3 resp_highedu_4
						
	* Estimate full model and detect omitted variables
	* use demo outcome var - Received ANC - Yes/NO
	
	svy: logit anc_yn $X_raw
	matrix b = e(b)
	local names : colfullnames e(b)
	
	di "`names'"

	local names	= subinstr("`names'", "_cons", "", 1)
	local names	= subinstr("`names'", "$outcome_var:", " ", .)
	di "`names'"
	
	* redefine the unfair var set without omitted var 
	global X "`names'"

	svy: logit anc_yn $X
	predict rank, pr
			
	****************************************************************************
	
	* Step 1: Estimate CI of outcome
	sum anc_yn [aw = weight_var]
	sca m_anc_yn = r(mean)    

	corr rank anc_yn [aw = weight_final], c // rank - multivar rank 
	sca cov_anc_yn = r(cov_12) // replace with same CI formula use for outcome var
	sca CI = 2 * cov_anc_yn / m_anc_yn  // replace with same CI formula use for outcome var

	svy: qui probit anc_yn $X 
	qui dprobit anc_yn $X [pw = weight_var]
	
	* Step 2: Standardize covariates
	foreach z of global X { // X mean the final unfiar variable applied at line # 40
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
	gen yst = anc_yn - yhat + m_y
 
	* Step 3: Re-estimate marginal effects
	dprobit anc_yn $X [pw = weight_var]
	matrix dfdx = e(dfdx)
	
	preserve // prepare an empty dataset to store decompisition analysis results
		clear 
		tempfile empty 
		save `empty', emptyok 
	restore 
	
	* Step 4: Initialize results
	gen sir					= .m 
	gen var 				= ""
	gen elasticity			= .m
	gen var_ci				= .m
	gen contribution		= .m
	gen contribution_pct 	= .m
	
	sca need = 0
	local i = 1
	 foreach x of global X { // perform decomposition analysis - run the code for each unfiar variable assigned at line # 40
		 qui {
		 	
			di "Now working for the covariate - `x'"
			
			mat b_`x' = dfdx[1,"`x'"]
			sca b_`x' = b_`x'[1,1] 
						
			* Elasticity 
			sum `x' [aw = weight_var]
			sca m_`x' = r(mean)    
			sca elas_`x' = (b_`x' * m_`x') / m_y 
			
			* Concentration index of the variable
			corr rank `x' [aw = weight_final], c // rank - multivar rank 
			sca cov_`x' = r(cov_12) // replace with same CI formula use for outcome var
			sca CI_`x' = 2 * cov_`x' / m_`x'  // replace with same CI formula use for outcome var
			
			* Contribution
			sca con_`x' = elas_`x' * CI_`x'   
			sca prcnt_`x' = (con_`x' / CI) * 100  
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
	
    gen contribution_tot 				= need
    gen outcome_ci 						= CI
    gen residual 						= CI - contribution_tot
	gen contribution_pct_abs			= abs(contribution_pct)
    egen contribution_pct_tot_abs 		= total(contribution_pct_abs)
    egen contribution_pct_tot 			= total(contribution_pct)
    gen residual_pct 					= 100 - contribution_pct_tot
	
	lab var var 						"Unfair factor variable names"
	lab var elasticity 					"Elasticities" 
	lab var var_ci 						"CI: Unfair factors"
	lab var contribution 				"Contributions"
	lab var contribution_pct 			"Percentage contributions"
	lab var contribution_tot 			"Total Unfair factor's contributions"
	lab var outcome_ci 					"CI of outcome: `outcome'"
	lab var residual					"Residual"
	lab var contribution_pct_abs		"(abs) Percentage contributions"
	lab var contribution_pct_tot_abs 	"Total (Abs) Percentage contributions"
	lab var contribution_pct_tot	 	"Total Percentage contributions"
	lab var residual_pct			 	"Residual Percentage"
	
	order	var elasticity var_ci contribution ///
			contribution_tot outcome_ci residual ///
			contribution_pct contribution_pct_abs contribution_pct_tot_abs contribution_pct_tot residual_pct
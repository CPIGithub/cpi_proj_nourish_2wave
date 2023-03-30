/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: hh Income and Wealth Quantile cleaning 			
Author				:	Nicholus Tint Zaw
Date				: 	03/01/2023
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

********************************************************************************
* household survey *
********************************************************************************

	** HH Survey Dataset **
	use "$dta/PN_HH_Survey_HH_Level_raw.dta", clear 
	
	
	** HOUSEHOLD INCOME
	// d0_per_std
	replace d0_per_std =  .d if d0_per_std ==  98 |  d0_per_std == 77
	tab d0_per_std, m 
	
	// d3_inc_lmth 
	tab d3_inc_lmth, m 
	gen income_lastmonth = d3_inc_lmth
	
	sum d3_inc_lmth, d 
	gen income_lastmonth_trim = d3_inc_lmth 
	replace income_lastmonth_trim = .m if d3_inc_lmth > `r(p99)' & !mi(d3_inc_lmth)
	tab income_lastmonth_trim, m 
	
	sum income_lastmonth_trim, d 
	
	// d4_inc_status
	replace d4_inc_status = .d if d4_inc_status == 98
	lab def d4_inc_status 1"yes, lower" 2"no, same" 3"no, higher"
	lab val d4_inc_status d4_inc_status
	tab d4_inc_status, m 
	
	// d5_reason
	local reasons 	d5_reason1 d5_reason2 d5_reason3 d5_reason4 d5_reason5 d5_reason6 ///
					d5_reason7 d5_reason8 d5_reason9 d5_reason10 d5_reason11 d5_reason12 ///
					d5_reason13 d5_reason14 d5_reason15 d5_reason16 d5_reason17 d5_reason18 d5_reason99
	
	foreach v in `reasons' {
		
		replace `v' = .m if d4_inc_status != 1
		tab `v', m 
		
	}

	// d6_cope
	local copes d6_cope1 d6_cope2 d6_cope3 d6_cope4 d6_cope5 d6_cope6 d6_cope7 d6_cope8 d6_cope9 d6_cope10 d6_cope11 d6_cope12 d6_cope13 d6_cope14 d6_cope15 d6_cope16 d6_cope17 d6_cope18 d6_cope19 d6_cope20 d6_cope99
	
	foreach v in `copes' {

		replace `v' = .m if d4_inc_status != 1
		tab `v', m 
		
	}

	// jan_incom_status
	replace jan_incom_status = .d if jan_incom_status == 98
	lab def jan_incom_status 	1 "Much lower now (for example, fallen by 20% or more)" ///
								2 "Somewhat lower now (fallen by less than 20%)" ///
								3 "About the same now" ///
								4 "Somewhat higher now (increased by less than 20%)" ///
								5 "Much higher now (increased by more than 20%)" ///
								98 "don't know"
	lab val jan_incom_status jan_incom_status
	tab jan_incom_status, m 
	
	// thistime_incom_status
	replace thistime_incom_status = .d if thistime_incom_status == 98
	lab def thistime_incom_status 	1 "Much lower now (for example, fallen by 20% or more)" ///
									2 "Somewhat lower now (fallen by less than 20%)" ///
									3 "About the same now" ///
									4 "Somewhat higher now (increased by less than 20%)" ///
									5 "Much higher now (increased by more than 20%)" ///
									98 "don't know"
	lab val thistime_incom_status thistime_incom_status
	tab thistime_incom_status, m 
	
	// d7_inc_govngo
	replace d7_inc_govngo = .m if d7_inc_govngo == 98
	tab d7_inc_govngo, m 

	// d7_inc_govngo_nm
	local orgs d7_inc_govngo_nm1 d7_inc_govngo_nm2 d7_inc_govngo_nm3 d7_inc_govngo_nm4 d7_inc_govngo_nm5 d7_inc_govngo_nm98 d7_inc_govngo_nm99
	
	foreach v in `orgs' {
		
		replace `v' = .m if d7_inc_govngo != 1
		tab `v', m 
	}

	// health_visit
	replace health_visit = .d if health_visit == 999
	tab health_visit, m 
	
	// health_exp
	replace health_exp = .m if health_visit != 1
	tab health_exp, m 
	
	// health_exp_cope
	local copes 	health_exp_cope1 health_exp_cope2 health_exp_cope3 health_exp_cope4 ///
					health_exp_cope5 health_exp_cope6 health_exp_cope7 health_exp_cope8 ///
					health_exp_cope9 health_exp_cope10 health_exp_cope11 health_exp_cope12 ///
					health_exp_cope13 health_exp_cope14 health_exp_cope888 health_exp_cope666
	
	foreach v in `copes' {

		replace `v' = .m if health_exp != 1
		tab `v', m 
			
	}
	


	
	** Equity Wealth - Quantile 
	// recoding for national wealth quantile calculation 
	
	local i = 1
	foreach var of varlist 	hhitems_tv ///
							hhitems_phone ///
							hhitems_refrigerator ///
							hhitems_table ///
							hhitems_chair ///
							hhitems_bed ///
							hhitems_cupboard ///
							hhitems_fan ///
							hhitems_computer ///
							hhitems_watch ///
							hhitems_bankacc {
				
	replace `var' 	= .r if `var' == 666
	tab `var', m 
	
	gen Q`i' = `var'
	tab Q`i', m 
	
	local i = `i' + 1
							}

	// water_sum
	tab water_sum, m 
	
	gen Q12 = (water_sum == 12)
	replace Q12 = .m if mi(water_sum)
	tab Q12, m 
	
	// house_floor
	tab house_floor, m 
	
	gen Q13 = (house_floor == 4)
	replace Q13 = .m if mi(house_floor)
	tab Q13, m 
	
	// house_wall
	tab house_wall, m 
	
	gen Q14 = (house_wall == 3)
	replace Q14 = .m if mi(house_wall)
	tab Q14, m 
	
	// house_cooking
	tab house_cooking, m 
	
	gen Q15 = (house_cooking == 4)
	replace Q15 = .m if mi(house_cooking)
	replace Q15 = 2 if house_cooking == 3
	tab Q15, m 
 
	
	* national quantile score 
	recode Q1 	(1 =0.0690823167469157) 	(0=-0.090564375679863)  	(else = .), generate (Q1_NAT)
	recode Q2 	(1 =0.0425159468667336) 	(0=-0.102017459669619)  	(else = .), generate (Q2_NAT)
	recode Q3 	(1 =0.196151902825549) 		(0=-0.0347236890124324)  	(else = .), generate (Q3_NAT)
	recode Q4 	(1 =0.039846704588856) 		(0=-0.0932240427690655)  	(else = .), generate (Q4_NAT)
	recode Q5 	(1 =0.0601696840973599) 	(0=-0.0914676246157446)  	(else = .), generate (Q5_NAT)
	recode Q6 	(1 =0.0860143518664307) 	(0=-0.0588690059465842)  	(else = .), generate (Q6_NAT)
	recode Q7 	(1 =0.053153739646388) 		(0=-0.0902879152715415)  	(else = .), generate (Q7_NAT)
	recode Q8 	(1 =0.145901751708448) 		(0=-0.0506677564135179)  	(else = .), generate (Q8_NAT)
	recode Q9 	(1 =0.253757481765658) 		(0=-0.0113242934366423)  	(else = .), generate (Q9_NAT)
	recode Q10 	(1 =0.0333845651540212) 	(0=-0.0422556495324506)  	(else = .), generate (Q10_NAT)
	recode Q11 	(1 =0.148211753309913) 		(0=-0.0201035838731444)  	(else = .), generate (Q11_NAT)
	recode Q12 	(1 =0.162636747669074) 		(0=-0.0277509041255903)  	(else = .), generate (Q12_NAT)
	recode Q13 	(1 =0.155494152541655) 		(0=-0.0248934954185016)  	(else = .), generate (Q13_NAT)
	recode Q14 	(1 =-0.0528762137328121) 	(0=0.0479863944863473)  	(else = .), generate (Q14_NAT)
	recode Q15 	(1 =0.24423835602352) 		(2=-0.0964473961662472) 	(0=0.0582018771645681)  (else = .), generate (Q15_NAT)

	
	** Calculate the sum of the national scores
	gen double NationalScore =  Q1_NAT+ Q2_NAT+ Q3_NAT+ Q4_NAT+ Q5_NAT+ Q6_NAT+ ///
								Q7_NAT+ Q8_NAT+ Q9_NAT+ Q10_NAT+ Q11_NAT+ ///
								Q12_NAT+ Q13_NAT+ Q14_NAT+ Q15_NAT

	** Assign respondents to national quintiles based on their national scores
	generate NationalQuintile = .
	replace NationalQuintile = 1 if 	NationalScore > -100 & NationalScore <-0.523858129524
	replace NationalQuintile = 2 if   	NationalScore >=-0.523858129524
	replace NationalQuintile = 3 if  	NationalScore >=-0.231140689739
	replace NationalQuintile = 4 if 	NationalScore >=0.075731996126
	replace NationalQuintile = 5 if 	NationalScore >=0.587364826752
	replace NationalQuintile = . if 	NationalScore ==.

	tab NationalQuintile, m 
	
	lab def hequantile 1"Poorest" 2"Poor" 3"Medium" 4"Wealthy" 5"Wealthiest"
	lab val NationalQuintile hequantile
	tab NationalQuintile, m 
	
	
	** PHONE ** 
	tab hhitems_phone, m 
	
	** PROJECT NOURISH COVERAGE **
	replace prgexpo_pn = 0 if prgexpo_pn == 999
	tab prgexpo_pn, m 
	

	* Add Weight variable *
	merge m:1 geo_vill 	using "$dta/pnourish_hh_weight_final.dta", ///
						keepusing(NationalQuintile NationalScore hhitems_phone prgexpo_pn)
	
	keep if _merge == 3
	
	drop _merge 
	
	
	** SAVE for analysis dataset 
	save "$dta/pnourish_INCOME_WEALTH_final.dta", replace  


// END HERE 


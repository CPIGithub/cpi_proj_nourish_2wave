/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: child health data cleaning 			
Author				:	Nicholus Tint Zaw
Date				: 	03/01/2023
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"


	****************************************************************************
	* Child IYCF Data *
	****************************************************************************
	use "$dta/pnourish_child_health_raw.dta", clear 
	
	// _parent_index child_id_health
	
	rename child_id_health roster_index
	

	** HH Roster **
	preserve 

	use "$dta/grp_hh.dta", clear
	
	do "$hhimport/grp_hh_labeling.do"

	drop 	_index _parent_table_name _submission__id _submission__uuid ///
			_submission__submission_time _submission__validation_status ///
			_submission__notes _submission__status _submission__submitted_by ///
			_submission__tags
			
	order _parent_index

	destring test calc_age_months, replace

	keep	_parent_index test hh_mem_name hh_mem_sex hh_mem_age hh_mem_age_month ///
			hh_mem_dob_know hh_mem_dob hh_mem_certification calc_age_months
	
	rename test roster_index

	tempfile grp_hh
	save `grp_hh', replace 

	restore

	merge 1:1 _parent_index roster_index using `grp_hh'

	keep if _merge == 3
	drop _merge 

	
	** Children Mother ** 
	preserve 
	use "$dta/hh_child_mom_rep.dta", clear
	
	* lab var 
	lab var hh_mem_mom "Who is the mother of this child?"
	
	// drop obs not eligable for this module 
	drop if mi(hh_mem_mom)

	drop 	_index _parent_table_name _submission__id _submission__uuid ///
			_submission__submission_time _submission__validation_status ///
			_submission__notes _submission__status _submission__submitted_by ///
			_submission__tags
			
	order _parent_index

	destring cal_hh_cname_id, replace
	
	keep _parent_index cal_hh_cname_id hh_mem_mom

	rename cal_hh_cname_id roster_index

	tempfile hh_child_mom_rep
	save `hh_child_mom_rep', replace 

	restore

	merge 1:1 _parent_index roster_index using `hh_child_mom_rep'
	
	keep if _merge == 3

	drop _merge 
	
	
	****************************************************************************
	** Child Age Calculation **
	****************************************************************************
	gen child_age_month		= calc_age_months if hh_mem_certification == 1
	replace child_age_month = hh_mem_age_month if mi(child_age_month)
	replace child_age_month = .m if mi(child_age_month)
	lab var child_age_month "Child Age in months"

	****************************************************************************
	** Child Birth Weight **
	****************************************************************************

	// child_vita
	replace child_vita = .d if child_vita == 999
	replace child_vita = .n if mi(child_vita)
	lab var child_vita "Vit-A supplementation"
	tab child_vita, m 

	// child_deworm 
	replace child_deworm = .d if child_deworm == 999
	replace child_deworm = .n if mi(child_deworm)
	lab var child_deworm "Deworming"
	tab child_deworm, m 

	// child_vaccin
	tab child_vaccin, m 
	
	// child_vaccin_card
	replace child_vaccin_card = .m if child_vaccin == 0
	tab child_vaccin_card, m 
	
	// child_birthwt
	// Low birth weight has been defined by WHO as weight at birth of < 2500 grams (5.5 pounds).
	// 1 kg 2.2 lb, 16 oz 1 lb 
	tab child_birthwt, m 

	foreach var of varlist 	child_birthwt_kg child_birthwt_lb child_birthwt_oz {
    
	replace `var' = .m if child_birthwt == 0
	tab `var', m 
	
}	
	replace child_birthwt_oz =  round(child_birthwt_oz/ 16, 0.01)
	tab child_birthwt_oz, m 
	
	replace child_birthwt_kg = round(child_birthwt_kg * 2.2, 0.01)
	tab child_birthwt_kg, m 
	
	egen child_bwt_lb 		= rowtotal(child_birthwt_kg child_birthwt_lb child_birthwt_oz)
	replace child_bwt_lb 	= .m if child_birthwt == 0
	tab child_bwt_lb, m 
	
	gen child_low_bwt 		= (child_bwt_lb < 5.5)
	replace child_low_bwt 	= .m if mi(child_bwt_lb)
	lab var child_low_bwt "Low-birth weight"
	tab child_low_bwt, m 

	
	********************************************************************************
	** Childood illness: **
	********************************************************************************
	// child_ill 
	tab child_ill, m 
	
	foreach var of varlist child_ill0 child_ill1 child_ill2 child_ill3 child_ill888 {
	    
		tab `var', m 
	}

	
	***** DIARRHEA *****
	// child_diarrh_treat
	replace child_diarrh_treat = .m if child_ill1 != 1
	tab child_diarrh_treat, m 
	
	// child_diarrh_where&&
	replace child_diarrh_where = .m if child_diarrh_treat != 1
	replace child_diarrh_where = .d if child_diarrh_where == 999
	tab child_diarrh_where, m 
	
	// child_diarrh_who
	replace child_diarrh_who = .m if child_diarrh_treat != 1
	tab child_diarrh_who, m 

	
	***** COUGH *****
	// child_cough_treat
	replace child_cough_treat = .m if child_ill2 != 1
	tab child_cough_treat, m 
	
	// child_cough_where
	replace child_cough_where = .m if child_cough_treat != 1
	replace child_cough_where = .d if child_cough_where == 999
	tab child_cough_where, m 
	
	// child_cough_who
	replace child_cough_who = .m if child_cough_treat != 1
	tab child_cough_who, m 

	
	***** FEVER *****
	// child_fever_treat
	replace child_fever_treat = .m if child_ill3 != 1
	tab child_fever_treat, m 
	
	// child_fever_where
	replace child_fever_where = .m if child_fever_treat != 1
	replace child_fever_where = .d if child_fever_where == 999
	tab child_fever_where, m 
	
	// child_fever_who
	replace child_fever_who = .m if child_fever_treat != 1
	tab child_fever_who, m 

	** SAVE for analysis dataset 
	save "$dta/pnourish_child_health_final.dta", replace  

	
	&&
	
********************************************************************************
** Childood illness: **
********************************************************************************
// child_ill 
tab child_ill, m 

// child_ill child_ill_1 child_ill_2 child_ill_3 child_ill_4 child_ill_777 
tab child_ill, m 

replace child_ill =  subinstr(child_ill, "E2", "", .)
replace child_ill =  subinstr(child_ill, "E13", "", .)
replace child_ill =  subinstr(child_ill, "E24", "", .)
replace child_ill =  subinstr(child_ill, "No. 4.", "", .)
replace child_ill =  subinstr(child_ill, "(မေးခွန်းနံပါတ် 4 သို့သွားပါ)", "", .)

moss child_ill, match("([0-9]+)") regex

drop _pos*
sum _count

forval x = 1/`r(max)' {
	destring _match`x', replace
	rename _match`x' child_ill`x'
}

drop _count

rename child_ill_1 child_ill_0 
rename child_ill_2 child_ill_1
rename child_ill_3 child_ill_2
rename child_ill_4 child_ill_3

local num 0 1 2 3 777  

foreach x in `num'{
	tab child_ill_`x'
	drop child_ill_`x'
	gen child_ill_`x' = (child_ill1 == `x' | child_ill2 == `x' | child_ill3 == `x')
	order child_ill_`x', before(child_ill_oth)
	tab child_ill_`x', m
}

lab var child_ill_0 "No illness"
lab var child_ill_1 "Diarrhea"
lab var child_ill_2 "Cough"
lab var child_ill_3 "Sickness (Fever)"
lab var child_ill_777 "Other type of illness"

// child_ill_oth 
tab child_ill_oth, m 

preserve
keep if child_ill_777 == 1
if _N > 0 {
	export 	excel $respinfo child_ill_oth using "$out/mother_other_specify.xlsx", ///
			sheet("child_ill_oth") firstrow(varlabels) sheetreplace 
}
restore

// diarrhea_treat 
tab diarrhea_treat, m 

split diarrhea_treat, p(".")
drop diarrhea_treat2-diarrhea_treat5
order diarrhea_treat1, after(diarrhea_notreat_why)
drop diarrhea_treat
rename diarrhea_treat1 diarrhea_treat
destring diarrhea_treat, replace 
replace diarrhea_treat = 0 if diarrhea_treat == 2
replace diarrhea_treat = .m if child_ill_1 != 1
lab var diarrhea_treat "treated diarrhea"
tab diarrhea_treat, m 

// diarrhea_notreat_why diarrhea_notreat_why_1 diarrhea_notreat_why_2 diarrhea_notreat_why_3 diarrhea_notreat_why_4 diarrhea_notreat_why_5 diarrhea_notreat_why_6 diarrhea_notreat_why_7 diarrhea_notreat_why_8 diarrhea_notreat_why_888 diarrhea_notreat_why_999 diarrhea_notreat_why_777 diarrhea_notreat_why_9 diarrhea_notreat_why_10 diarrhea_notreat_why_11 diarrhea_notreat_why_12 diarrhea_notreat_why_13 diarrhea_notreat_why_14 diarrhea_notreat_why_15 
tab diarrhea_notreat_why, m 
replace diarrhea_notreat_why = subinstr(diarrhea_notreat_why, "Fear of contracting Covid-19", "", .)

moss diarrhea_notreat_why, match("([0-9]+)") regex

drop _pos*
sum _count

forval x = 1/`r(max)' {
	destring _match`x', replace
	rename _match`x' diarrhea_notreat_why`x'
}

drop _count

local num 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 777  

foreach x in `num'{
	tab diarrhea_notreat_why_`x', m 
	drop diarrhea_notreat_why_`x'
	gen diarrhea_notreat_why_`x' = (diarrhea_notreat_why1 == `x' | diarrhea_notreat_why2 == `x')
	replace diarrhea_notreat_why_`x' = .m if diarrhea_treat != 0 
	order diarrhea_notreat_why_`x', before(diarrhea_notreat_why_oth)
	tab diarrhea_notreat_why_`x', m
}

lab var diarrhea_notreat_why_1 "No health facility"
lab var diarrhea_notreat_why_2 "Very far from health facility"
lab var diarrhea_notreat_why_3 "Not easy to go to health facility"
lab var diarrhea_notreat_why_4 "Expensive medical expense"
lab var diarrhea_notreat_why_5 "Not necessary to get treatment"
lab var diarrhea_notreat_why_6 "Advice not to get treatment"
lab var diarrhea_notreat_why_7 "Received other treatment"
lab var diarrhea_notreat_why_8 "Don't remember"
lab var diarrhea_notreat_why_9 "Cost of transportation"
lab var diarrhea_notreat_why_10 "Fear of contracting Covid-19"
lab var diarrhea_notreat_why_11 "Have to take care of children"
lab var diarrhea_notreat_why_12 "Insecurity due to active conflict"
lab var diarrhea_notreat_why_13 "Mobility restrictions"
lab var diarrhea_notreat_why_14 "Health care provider absent"
lab var diarrhea_notreat_why_15 "Family doesn't allow"
lab var diarrhea_notreat_why_777 "Other reasons"

// diarrhea_notreat_why_oth
tab diarrhea_notreat_why_oth, m 

preserve
keep if diarrhea_notreat_why_777 == 1
if _N > 0 {
	export 	excel $respinfo diarrhea_notreat_why_oth using "$out/mother_other_specify.xlsx", ///
			sheet("diarrhea_notreat_why_oth") firstrow(varlabels) sheetreplace 
}
restore


// diarrhea_treat_day 
tab diarrhea_treat_day, m 
replace diarrhea_treat_day = .m if diarrhea_treat != 1 
lab var diarrhea_treat_day "days of first treatment"
tab diarrhea_treat_day, m 

// diarrhea_treat_place 
tab diarrhea_treat_place, m 

split diarrhea_treat_place, p(".")
drop diarrhea_treat_place2
order diarrhea_treat_place1, after(diarrhea_treat_place)
drop diarrhea_treat_place
rename diarrhea_treat_place1 diarrhea_treat_place
destring diarrhea_treat_place, replace 
replace diarrhea_treat_place = .m if diarrhea_treat != 1 
tab diarrhea_treat_place, m 

local num 1 2 3 4 5 6 7 8 9 10 11 12 13 777 

foreach x in `num'{
	gen diarrhea_treat_place_`x' = (diarrhea_treat_place == `x')
	replace diarrhea_treat_place_`x' = .m if mi(diarrhea_treat_place)
	order diarrhea_treat_place_`x', before(diarrhea_treat_place_oth)
	tab diarrhea_treat_place_`x', m
}

lab var diarrhea_treat_place_1 "Township hospital" 
lab var diarrhea_treat_place_2 "District hospital"
lab var diarrhea_treat_place_3 "Rural health center"
lab var diarrhea_treat_place_4 "Sub-rural health center"
lab var diarrhea_treat_place_5 "Private clinic"
lab var diarrhea_treat_place_6 "Community health volunteer"
lab var diarrhea_treat_place_7 "Traditional medicine"
lab var diarrhea_treat_place_8 "Quack"
lab var diarrhea_treat_place_9 "Medicines from shops"
lab var diarrhea_treat_place_10 "EHO clinic"
lab var diarrhea_treat_place_11 "Family member"
lab var diarrhea_treat_place_12 "NGO clinic"
lab var diarrhea_treat_place_13 "Auxiliary midwife"
lab var diarrhea_treat_place_777 "Other places"

// diarrhea_treat_place_oth 
tab diarrhea_treat_place_oth, m 

preserve
keep if diarrhea_treat_place_777 == 1
if _N > 0 {
	export 	excel $respinfo diarrhea_treat_place_oth using "$out/mother_other_specify.xlsx", ///
			sheet("diarrhea_treat_place_oth") firstrow(varlabels) sheetreplace 
}
restore

// diarrhea_treat_place_2nd 
tab diarrhea_treat_place_2nd, m 

split diarrhea_treat_place_2nd, p(".")
drop diarrhea_treat_place_2nd2
order diarrhea_treat_place_2nd1, after(diarrhea_treat_place_2nd)
drop diarrhea_treat_place_2nd
rename diarrhea_treat_place_2nd1 diarrhea_treat_place_2nd
destring diarrhea_treat_place_2nd, replace 
replace diarrhea_treat_place_2nd = .m if diarrhea_treat != 1 
tab diarrhea_treat_place_2nd, m 

local num 0 1 2 3 4 5 6 7 8 9 10 11 12 13 777 

foreach x in `num'{
	gen diarrhea_treat_place_2nd_`x' = (diarrhea_treat_place_2nd == `x')
	replace diarrhea_treat_place_2nd_`x' = .m if mi(diarrhea_treat_place_2nd)
	order diarrhea_treat_place_2nd_`x', before(diarrhea_treat_place_2nd_oth)
	tab diarrhea_treat_place_2nd_`x', m
}

lab var diarrhea_treat_place_2nd_0 "nowhere"
lab var diarrhea_treat_place_2nd_1 "Township hospital"
lab var diarrhea_treat_place_2nd_2 "District hospital"
lab var diarrhea_treat_place_2nd_3 "Rural health center"
lab var diarrhea_treat_place_2nd_4 "Sub-rural health center"
lab var diarrhea_treat_place_2nd_5 "Private clinic/hospital"
lab var diarrhea_treat_place_2nd_6 "Community health volunteer"
lab var diarrhea_treat_place_2nd_7 "Traditional medicine"
lab var diarrhea_treat_place_2nd_8 "Quack"
lab var diarrhea_treat_place_2nd_9 "Medicines from shops"
lab var diarrhea_treat_place_2nd_10 "EHO clinic"
lab var diarrhea_treat_place_2nd_11 "Family member"
lab var diarrhea_treat_place_2nd_12 "NGO clinic"
lab var diarrhea_treat_place_2nd_13 "Auxiliary midwife"
lab var diarrhea_treat_place_2nd_777 "Other places"
			
// diarrhea_treat_place_2nd_oth 
tab diarrhea_treat_place_2nd_oth, m 

preserve
keep if diarrhea_treat_place_2nd_777 == 1
if _N > 0 {
	export 	excel $respinfo diarrhea_treat_place_2nd_oth using "$out/mother_other_specify.xlsx", ///
			sheet("diarrhea_treat_place_2nd_oth") firstrow(varlabels) sheetreplace 
}
restore

// diarrhea_treat_pay 
tab diarrhea_treat_pay, m 

split diarrhea_treat_pay, p(".")
drop diarrhea_treat_pay2-diarrhea_treat_pay5
order diarrhea_treat_pay1, after(diarrhea_treat_pay)
drop diarrhea_treat_pay
rename diarrhea_treat_pay1 diarrhea_treat_pay
destring diarrhea_treat_pay, replace 
replace diarrhea_treat_pay = .m if diarrhea_treat != 1 
replace diarrhea_treat_pay = 0 if diarrhea_treat_pay == 2 
lab var diarrhea_treat_pay "Treatment payment"
tab diarrhea_treat_pay, m 

// diarrhea_treat_amount 
tab diarrhea_treat_amount, m 
replace diarrhea_treat_amount = .m if diarrhea_treat_pay != 1
lab var diarrhea_treat_amount "payment amount"
tab diarrhea_treat_amount, m 

// outlier check 
sum diarrhea_treat_amount, d
if _N > 0 {
	export 	excel $respinfo diarrhea_treat_amount using "$out/mother_outlier.xlsx" if diarrhea_treat_amount > `r(p90)' & !mi(diarrhea_treat_amount), ///
			sheet("diarrhea_treat_amount") firstrow(varlabels) sheetreplace 
}

// diarrhea_treat_spent diarrhea_treat_spent_1 diarrhea_treat_spent_2 diarrhea_treat_spent_3 diarrhea_treat_spent_4 diarrhea_treat_spent_5 diarrhea_treat_spent_6 diarrhea_treat_spent_888 diarrhea_treat_spent_999 diarrhea_treat_spent_777 
tab diarrhea_treat_spent, m 

moss diarrhea_treat_spent, match("([0-9]+)") regex

drop _pos*
sum _count

forval x = 1/`r(max)' {
	destring _match`x', replace
	rename _match`x' diarrhea_treat_spent`x'
}

drop _count

local num 1 2 3 4 5 6 777  

foreach x in `num'{
	tab diarrhea_treat_spent_`x', m 
	drop diarrhea_treat_spent_`x'
	gen diarrhea_treat_spent_`x' = (diarrhea_treat_spent1 == `x' | ///
									diarrhea_treat_spent2 == `x' | ///
									diarrhea_treat_spent3 == `x' | ///
									diarrhea_treat_spent4 == `x' | ///
									diarrhea_treat_spent5 == `x')
	replace diarrhea_treat_spent_`x' = .m if diarrhea_treat_pay != 1
	order diarrhea_treat_spent_`x', before(diarrhea_treat_spent_oth)
	tab diarrhea_treat_spent_`x', m
}

lab var diarrhea_treat_spent_1 "Travel cost"
lab var diarrhea_treat_spent_2 "Registration fees"
lab var diarrhea_treat_spent_3 "Medicine"
lab var diarrhea_treat_spent_4 "Blood test"
lab var diarrhea_treat_spent_5 "Investigation"
lab var diarrhea_treat_spent_6 "Gift"
lab var diarrhea_treat_spent_777 "Other cost categories"
	
// diarrhea_treat_spent_oth 
tab diarrhea_treat_spent_oth, m 

preserve
keep if diarrhea_treat_spent_777 == 1
if _N > 0 {
	export 	excel $respinfo diarrhea_treat_spent_oth using "$out/mother_other_specify.xlsx", ///
			sheet("diarrhea_treat_spent_oth") firstrow(varlabels) sheetreplace 
}
restore

// diarrhea_treat_loan 
tab diarrhea_treat_loan, m 

split diarrhea_treat_loan, p(".")
drop diarrhea_treat_loan2
order diarrhea_treat_loan1, after(diarrhea_treat_loan)
drop diarrhea_treat_loan
rename diarrhea_treat_loan1 diarrhea_treat_loan
destring diarrhea_treat_loan, replace 
replace diarrhea_treat_loan = .m if diarrhea_treat_pay != 1 
replace diarrhea_treat_loan = 0 if diarrhea_treat_loan == 2 
lab var diarrhea_treat_loan "treatment payment loan"
tab diarrhea_treat_loan, m 

// diarrhea_still 
tab diarrhea_still, m 

split diarrhea_still, p(".")
drop diarrhea_still2-diarrhea_still5
order diarrhea_still1, after(diarrhea_still)
drop diarrhea_still
rename diarrhea_still1 diarrhea_still
destring diarrhea_still, replace 
replace diarrhea_still = .m if child_ill_1 != 1
replace diarrhea_still = 0 if diarrhea_still == 2 
lab var diarrhea_still "Still having diarrhea"
tab diarrhea_still, m 

// diarrhea_recovery_day 
tab diarrhea_recovery_day, m 
replace diarrhea_recovery_day = .n if mi(diarrhea_recovery_day)
replace diarrhea_recovery_day = .m if diarrhea_still != 0
lab var diarrhea_recovery_day "Recovery days"
tab diarrhea_recovery_day, m 

// outlier check 
sum diarrhea_recovery_day, d
export 	excel $respinfo diarrhea_recovery_day using "$out/mother_outlier.xlsx" if diarrhea_recovery_day > `r(p90)' & !mi(diarrhea_recovery_day), ///
		sheet("diarrhea_recovery_day") firstrow(varlabels) sheetreplace 


// cough_treat 
tab cough_treat, m 

split cough_treat, p(".")
drop cough_treat2-cough_treat5
order cough_treat1, after(cough_notreat_why)
drop cough_treat
rename cough_treat1 cough_treat
destring cough_treat, replace 
replace cough_treat = 0 if cough_treat == 2
replace cough_treat = .m if child_ill_2 != 1
lab var cough_treat "treated cough"
tab cough_treat, m 


// cough_notreat_why cough_notreat_why_1 cough_notreat_why_2 cough_notreat_why_3 cough_notreat_why_4 cough_notreat_why_5 cough_notreat_why_6 cough_notreat_why_7 cough_notreat_why_8 cough_notreat_why_888 cough_notreat_why_999 cough_notreat_why_777 cough_notreat_why_9 cough_notreat_why_10 cough_notreat_why_11 cough_notreat_why_12 cough_notreat_why_13 cough_notreat_why_14 cough_notreat_why_15 

tab cough_notreat_why, m 
replace cough_notreat_why = subinstr(cough_notreat_why, "Fear of contracting Covid-19", "", .)

moss cough_notreat_why, match("([0-9]+)") regex

drop _pos*
sum _count

forval x = 1/`r(max)' {
	destring _match`x', replace
	rename _match`x' cough_notreat_why`x'
}

drop _count

local num 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 777  

foreach x in `num'{
	tab cough_notreat_why_`x', m 
	drop cough_notreat_why_`x'
	gen cough_notreat_why_`x' = (cough_notreat_why1 == `x' | ///
								 cough_notreat_why2 == `x' | ///
								 cough_notreat_why3 == `x')
	replace cough_notreat_why_`x' = .m if cough_treat != 0 
	order cough_notreat_why_`x', before(cough_notreat_why_oth)
	tab cough_notreat_why_`x', m
}

lab var cough_notreat_why_1 "No health facility"
lab var cough_notreat_why_2 "Very far from health facility"
lab var cough_notreat_why_3 "Not easy to go to health facility"
lab var cough_notreat_why_4 "Expensive medical expense"
lab var cough_notreat_why_5 "Not necessary to get treatment"
lab var cough_notreat_why_6 "Advice not to get treatment"
lab var cough_notreat_why_7 "Received other treatment"
lab var cough_notreat_why_8 "Don't remember"
lab var cough_notreat_why_9 "Cost of transportation"
lab var cough_notreat_why_10 "Fear of contracting Covid-19"
lab var cough_notreat_why_11 "Have to take care of children"
lab var cough_notreat_why_12 "Insecurity due to active conflict"
lab var cough_notreat_why_13 "Mobility restrictions"
lab var cough_notreat_why_14 "Health care provider absent"
lab var cough_notreat_why_15 "Family doesn't allow"
lab var cough_notreat_why_777 "Other reasons"


// cough_notreat_why_oth 
tab cough_notreat_why_oth, m 

preserve
keep if cough_notreat_why_777 == 1
if _N > 0 {
	export 	excel $respinfo cough_notreat_why_oth using "$out/mother_other_specify.xlsx", ///
			sheet("cough_notreat_why_oth") firstrow(varlabels) sheetreplace 
}
restore


// cough_treat_day 
tab cough_treat_day, m 
replace cough_treat_day = .m if cough_treat != 1 
lab var cough_treat_day "days of first treatment"
tab cough_treat_day, m 

// cough_treat_place 
tab cough_treat_place, m 

split cough_treat_place, p(".")
drop cough_treat_place2
order cough_treat_place1, after(cough_treat_place)
drop cough_treat_place
rename cough_treat_place1 cough_treat_place
destring cough_treat_place, replace 
replace cough_treat_place = .m if cough_treat != 1 
tab cough_treat_place, m 

local num 1 2 3 4 5 6 7 8 9 10 11 12 13 777 

foreach x in `num'{
	gen cough_treat_place_`x' = (cough_treat_place == `x')
	replace cough_treat_place_`x' = .m if mi(cough_treat_place)
	order cough_treat_place_`x', before(cough_notreat_why_oth)
	tab cough_treat_place_`x', m
}

replace cough_treat_place_6 =  1 if cough_treat_place_oth_eng == "Comunity health worker" | ///
									cough_treat_place_oth_eng == "Trained health staff" 

replace cough_treat_place_9 = 1 if 	cough_treat_place_oth_eng == "ကိုယ်တိုင်ဆေး၀ယ်ပြီးတိုက်သည်" | ///
									cough_treat_place_oth_eng == "Bought medicines from medical person from the village and took them."

replace cough_treat_place_13 = 1 if cough_treat_place_oth_eng == "AMW" 

replace cough_treat_place_777 = 0 if cough_treat_place_oth_eng == "Comunity health worker" | ///
									 cough_treat_place_oth_eng == "Trained health staff" | ///
									 cough_treat_place_oth_eng == "ကိုယ်တိုင်ဆေး၀ယ်ပြီးတိုက်သည်" | ///
									 cough_treat_place_oth_eng == "Bought medicines from medical person from the village and took them." | ///
									 cough_treat_place_oth_eng == "AMW" 
									 
lab var cough_treat_place_1 "Township hospital"
lab var cough_treat_place_2 "District hospital"
lab var cough_treat_place_3 "Rural health center"
lab var cough_treat_place_4 "Sub-rural health center"
lab var cough_treat_place_5 "Private clinic/hospital"
lab var cough_treat_place_6 "Community health volunteer"
lab var cough_treat_place_7 "Traditional medicine"
lab var cough_treat_place_8 "Quack"
lab var cough_treat_place_9 "Medicines from shops"
lab var cough_treat_place_10 "EHO clinic"
lab var cough_treat_place_11 "Family member"
lab var cough_treat_place_12 "NGO clinic"
lab var cough_treat_place_13 "Auxiliary midwife"
lab var cough_treat_place_777 "Other places"

// cough_treat_place_oth 
tab cough_treat_place_oth, m 

preserve
keep if cough_treat_place_777 == 1
if _N > 0 {
	export 	excel $respinfo cough_treat_place_oth using "$out/mother_other_specify.xlsx", ///
			sheet("cough_treat_place_oth") firstrow(varlabels) sheetreplace 
}
restore

// cough_treat_place_2nd 
tab cough_treat_place_2nd, m 

split cough_treat_place_2nd, p(".")
drop cough_treat_place_2nd2
order cough_treat_place_2nd1, after(cough_treat_place_2nd)
drop cough_treat_place_2nd
rename cough_treat_place_2nd1 cough_treat_place_2nd
destring cough_treat_place_2nd, replace 
replace cough_treat_place_2nd = .m if cough_treat != 1 
tab cough_treat_place_2nd, m 

local num 0 1 2 3 4 5 6 7 8 9 10 11 12 13 777 

foreach x in `num'{
	gen cough_treat_place_2nd_`x' = (cough_treat_place_2nd == `x')
	replace cough_treat_place_2nd_`x' = .m if mi(cough_treat_place_2nd)
	order cough_treat_place_2nd_`x', before(cough_treat_place_2nd_oth)
	tab cough_treat_place_2nd_`x', m
}
									 
lab var cough_treat_place_2nd_0 "nowhere"
lab var cough_treat_place_2nd_1 "Township hospital"
lab var cough_treat_place_2nd_2 "District hospital"
lab var cough_treat_place_2nd_3 "Rural health center"
lab var cough_treat_place_2nd_4 "Sub-rural health center"
lab var cough_treat_place_2nd_5 "Private clinic/hospital"
lab var cough_treat_place_2nd_6 "Community health volunteer"
lab var cough_treat_place_2nd_7 "Traditional medicine"
lab var cough_treat_place_2nd_8 "Quack"
lab var cough_treat_place_2nd_9 "Medicines from shops"
lab var cough_treat_place_2nd_10 "EHO clinic"
lab var cough_treat_place_2nd_11 "Family member"
lab var cough_treat_place_2nd_12 "NGO clinic"
lab var cough_treat_place_2nd_13 "Auxiliary midwife"
lab var cough_treat_place_2nd_777 "Other places"

// cough_treat_place_2nd_oth 
tab cough_treat_place_2nd_oth, m 

preserve
keep if cough_treat_place_2nd_777 == 1
if _N > 0 {
	export 	excel $respinfo cough_treat_place_2nd_oth using "$out/mother_other_specify.xlsx", ///
			sheet("cough_treat_place_2nd_oth") firstrow(varlabels) sheetreplace 
}
restore

// cough_treat_pay 
tab cough_treat_pay, m 

split cough_treat_pay, p(".")
drop cough_treat_pay2-cough_treat_pay5
order cough_treat_pay1, after(cough_treat_pay)
drop cough_treat_pay
rename cough_treat_pay1 cough_treat_pay
destring cough_treat_pay, replace 
replace cough_treat_pay = .m if cough_treat != 1 
replace cough_treat_pay = 0 if cough_treat_pay == 2 
lab var cough_treat_pay "Treatment payment"
tab cough_treat_pay, m 

// cough_treat_amount 
tab cough_treat_amount, m 
replace cough_treat_amount = .m if cough_treat_pay != 1
lab var cough_treat_amount "payment amount"
tab cough_treat_amount, m 

sum cough_treat_amount, d 
// outlier check 
export 	excel $respinfo cough_treat_amount using "$out/mother_outlier.xlsx" if cough_treat_amount > `r(p90)' & !mi(cough_treat_amount), ///
		sheet("cough_treat_amount") firstrow(varlabels) sheetreplace 


// cough_treat_spent cough_treat_spent_1 cough_treat_spent_2 cough_treat_spent_3 cough_treat_spent_4 cough_treat_spent_5 cough_treat_spent_6 cough_treat_spent_888 cough_treat_spent_999 cough_treat_spent_777 
tab cough_treat_spent, m 

moss cough_treat_spent, match("([0-9]+)") regex

drop _pos*
sum _count

forval x = 1/`r(max)' {
	destring _match`x', replace
	rename _match`x' cough_treat_spent`x'
}

drop _count

local num 1 2 3 4 5 6 777  

foreach x in `num'{
	tab cough_treat_spent_`x', m 
	drop cough_treat_spent_`x'
	gen cough_treat_spent_`x' = (cough_treat_spent1 == `x' | ///
								 cough_treat_spent2 == `x')
	replace cough_treat_spent_`x' = .m if cough_treat_pay != 1
	order cough_treat_spent_`x', before(cough_treat_spent_oth)
	tab cough_treat_spent_`x', m
}

lab var cough_treat_spent_1 "Travel cost"
lab var cough_treat_spent_2 "Registration fees"
lab var cough_treat_spent_3 "Medicine"
lab var cough_treat_spent_4 "Blood test"
lab var cough_treat_spent_5 "Investigation"
lab var cough_treat_spent_6 "Gift"
lab var cough_treat_spent_777 "Other cost categories"

// cough_treat_spent_oth 
tab cough_treat_spent_oth, m 

preserve
keep if cough_treat_spent_777 == 1
if _N > 0 {
	export 	excel $respinfo cough_treat_spent_oth using "$out/mother_other_specify.xlsx", ///
			sheet("cough_treat_spent_oth") firstrow(varlabels) sheetreplace 
}
restore

// cough_treat_loan 
tab cough_treat_loan, m 

split cough_treat_loan, p(".")
drop cough_treat_loan2
order cough_treat_loan1, after(cough_treat_loan)
drop cough_treat_loan
rename cough_treat_loan1 cough_treat_loan
destring cough_treat_loan, replace 
replace cough_treat_loan = .m if cough_treat_pay != 1 
replace cough_treat_loan = 0 if cough_treat_loan == 2 
lab var cough_treat_loan "treatment payment loan"
tab cough_treat_loan, m 

// cough_still 
tab cough_still, m 

split cough_still, p(".")
drop cough_still2-cough_still5
order cough_still1, after(cough_still)
drop cough_still
rename cough_still1 cough_still
destring cough_still, replace 
replace cough_still = .n if mi(cough_still)
replace cough_still = .m if child_ill_2 != 1
replace cough_still = 0 if cough_still == 2 
lab var cough_still "Still having diarrhea"
tab cough_still, m 

// cough_recovery_day 
tab cough_recovery_day, m 
replace cough_recovery_day = .n if mi(cough_recovery_day)
replace cough_recovery_day = .m if cough_still != 0
replace cough_recovery_day = .d if cough_recovery_day == 888
lab var cough_recovery_day "Recovery days"
tab cough_recovery_day, m 

// outlier check 
sum cough_recovery_day, d
export 	excel $respinfo cough_recovery_day using "$out/mother_outlier.xlsx" if cough_recovery_day > `r(p90)' & !mi(cough_recovery_day), ///
		sheet("cough_recovery_day") firstrow(varlabels) sheetreplace 


// fever_treat 
tab fever_treat, m 

split fever_treat, p(".")
drop fever_treat2-fever_treat5
order fever_treat1, after(fever_notreat_why)
drop fever_treat
rename fever_treat1 fever_treat
destring fever_treat, replace 
replace fever_treat = 0 if fever_treat == 2
replace fever_treat = .m if child_ill_3 != 1
lab var fever_treat "treated Sickness (Fever)"
tab fever_treat, m 

// fever_notreat_why fever_notreat_why_1 fever_notreat_why_2 fever_notreat_why_3 fever_notreat_why_4 fever_notreat_why_5 fever_notreat_why_6 fever_notreat_why_7 fever_notreat_why_8 fever_notreat_why_888 fever_notreat_why_999 fever_notreat_why_777 fever_notreat_why_9 fever_notreat_why_10 fever_notreat_why_11 fever_notreat_why_12 fever_notreat_why_13 fever_notreat_why_14 fever_notreat_why_15 

tab fever_notreat_why, m 
replace fever_notreat_why = subinstr(fever_notreat_why, "Fear of contracting Covid-19", "", .)

moss fever_notreat_why, match("([0-9]+)") regex

drop _pos*
sum _count

forval x = 1/`r(max)' {
	destring _match`x', replace
	rename _match`x' fever_notreat_why`x'
}

drop _count

local num 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 777  

foreach x in `num'{
	tab fever_notreat_why_`x', m 
	drop fever_notreat_why_`x'
	gen fever_notreat_why_`x' = (fever_notreat_why1 == `x' | ///
								 fever_notreat_why2 == `x' | ///
								 fever_notreat_why3 == `x')
	replace fever_notreat_why_`x' = .m if fever_treat != 0 
	order fever_notreat_why_`x', before(fever_notreat_why_oth)
	tab fever_notreat_why_`x', m
}

replace fever_notreat_why_5 = 1 if fever_notreat_why_oth_eng == "Not very severe"

replace fever_notreat_why_4 =  1 if fever_notreat_why_oth_eng == "Financial difficulty to get treatment"

replace fever_notreat_why_14 =  1 if fever_notreat_why_oth_eng == "There was no health staff at the clinic"

replace fever_notreat_why_777 = 0 if 	fever_notreat_why_oth_eng == "Not very severe" | ///
										fever_notreat_why_oth_eng == "Financial difficulty to get treatment" | ///
										fever_notreat_why_oth_eng == "There was no health staff at the clinic"
									
lab var fever_notreat_why_1 "No health facility"
lab var fever_notreat_why_2 "Very far from health facility"
lab var fever_notreat_why_3 "Not easy to go to health facility"
lab var fever_notreat_why_4 "Expensive medical expense"
lab var fever_notreat_why_5 "Not necessary to get treatment"
lab var fever_notreat_why_6 "Advice not to get treatment"
lab var fever_notreat_why_7 "Received other treatment"
lab var fever_notreat_why_8 "Don't remember"
lab var fever_notreat_why_9 "Cost of transportation"
lab var fever_notreat_why_10 "Fear of contracting Covid-19"
lab var fever_notreat_why_11 "Have to take care of children"
lab var fever_notreat_why_12 "Insecurity due to active conflict"
lab var fever_notreat_why_13 "Mobility restrictions"
lab var fever_notreat_why_14 "Health care provider absent"
lab var fever_notreat_why_15 "Family doesn't allow"
lab var fever_notreat_why_777 "Other reasons"

// fever_notreat_why_oth
tab fever_notreat_why_oth, m 

preserve
keep if fever_notreat_why_777 == 1
if _N > 0 {
	export 	excel $respinfo fever_notreat_why_oth using "$out/mother_other_specify.xlsx", ///
			sheet("fever_notreat_why_oth") firstrow(varlabels) sheetreplace 
}
restore

// fever_treat_day 
tab fever_treat_day, m 
replace fever_treat_day = .m if fever_treat != 1 
lab var fever_treat_day "days of first treatment"
tab fever_treat_day, m 

// fever_treat_place 
tab fever_treat_place, m 

split fever_treat_place, p(".")
drop fever_treat_place2
order fever_treat_place1, after(fever_treat_place)
drop fever_treat_place
rename fever_treat_place1 fever_treat_place
destring fever_treat_place, replace 
replace fever_treat_place = .m if fever_treat != 1 
replace fever_treat_place = .d if fever_treat_place == 888
tab fever_treat_place, m 

local num 1 2 3 4 5 6 7 8 9 10 11 12 13 777 

foreach x in `num'{
	gen fever_treat_place_`x' = (fever_treat_place == `x')
	replace fever_treat_place_`x' = .m if mi(fever_treat_place)
	order fever_treat_place_`x', before(cough_notreat_why_oth)
	tab fever_treat_place_`x', m
}

replace fever_treat_place_13 = 1 if fever_treat_place_oth == "AMW"

replace fever_treat_place_6 = 1 if fever_treat_place_oth == "သင်တန်းရဆေးဆရာ" | fever_treat_place_oth == "သင်တန်းရဆရာ"

replace fever_treat_place_777 = 0 if 	fever_treat_place_oth == "AMW" | ///
										fever_treat_place_oth == "သင်တန်းရဆေးဆရာ" | ///
										fever_treat_place_oth == "သင်တန်းရဆရာ"
										
lab var fever_treat_place_1 "Township hospital"
lab var fever_treat_place_2 "District hospital"
lab var fever_treat_place_3 "Rural health center"
lab var fever_treat_place_4 "Sub-rural health center"
lab var fever_treat_place_5 "Private clinic/hospital"
lab var fever_treat_place_6 "Community health volunteer"
lab var fever_treat_place_7 "Traditional medicine"
lab var fever_treat_place_8 "Quack"
lab var fever_treat_place_9 "Medicines from shops"
lab var fever_treat_place_10 "EHO clinic"
lab var fever_treat_place_11 "Family member"
lab var fever_treat_place_12 "NGO clinic"
lab var fever_treat_place_13 "Auxiliary midwife"
lab var fever_treat_place_777 "Other places"

// fever_treat_place_oth 
tab fever_treat_place_oth, m 

preserve
keep if cough_notreat_why_777 == 1
if _N > 0 {
	export 	excel $respinfo fever_treat_place_oth using "$out/mother_other_specify.xlsx", ///
			sheet("fever_treat_place_oth") firstrow(varlabels) sheetreplace 
}
restore

// fever_treat_place_2nd 
tab fever_treat_place_2nd, m 

split fever_treat_place_2nd, p(".")
drop fever_treat_place_2nd2
order fever_treat_place_2nd1, after(fever_treat_place_2nd)
drop fever_treat_place_2nd
rename fever_treat_place_2nd1 fever_treat_place_2nd
destring fever_treat_place_2nd, replace 
replace fever_treat_place_2nd = .m if fever_treat != 1 
tab fever_treat_place_2nd, m 

local num 0 1 2 3 4 5 6 7 8 9 10 11 12 13 777 

foreach x in `num'{
	gen fever_treat_place_2nd_`x' = (fever_treat_place_2nd == `x')
	replace fever_treat_place_2nd_`x' = .m if mi(fever_treat_place_2nd)
	order fever_treat_place_2nd_`x', before(fever_treat_place_2nd_oth)
	tab fever_treat_place_2nd_`x', m
}

lab var fever_treat_place_2nd_0 "nowhere"
lab var fever_treat_place_2nd_1 "Township hospital"
lab var fever_treat_place_2nd_2 "District hospital"
lab var fever_treat_place_2nd_3 "Rural health center"
lab var fever_treat_place_2nd_4 "Sub-rural health center"
lab var fever_treat_place_2nd_5 "Private clinic/hospital"
lab var fever_treat_place_2nd_6 "Community health volunteer"
lab var fever_treat_place_2nd_7 "Traditional medicine"
lab var fever_treat_place_2nd_8 "Quack"
lab var fever_treat_place_2nd_9 "Medicines from shops"
lab var fever_treat_place_2nd_10 "EHO clinic"
lab var fever_treat_place_2nd_11 "Family member"
lab var fever_treat_place_2nd_12 "NGO clinic"
lab var fever_treat_place_2nd_13 "Auxiliary midwife"
lab var fever_treat_place_2nd_777 "Other places"

// fever_treat_place_2nd_oth 
tab fever_treat_place_2nd_oth, m 

preserve
keep if fever_treat_place_2nd_777 == 1
if _N > 0 {
	export 	excel $respinfo fever_treat_place_2nd_oth using "$out/mother_other_specify.xlsx", ///
			sheet("fever_treat_place_2nd_oth") firstrow(varlabels) sheetreplace 
}
restore

// fever_treat_pay 
tab fever_treat_pay, m 

split fever_treat_pay, p(".")
drop fever_treat_pay2-fever_treat_pay4
order fever_treat_pay1, after(fever_treat_pay)
drop fever_treat_pay
rename fever_treat_pay1 fever_treat_pay
replace fever_treat_pay = "2" if fever_treat_pay == "မပေးခဲ့ပါ (မေးခွန်းနံပါတ် E33 သို့သွားပါ) No (Please go to Q"
destring fever_treat_pay, replace 
replace fever_treat_pay = .m if fever_treat != 1 
replace fever_treat_pay = 0 if fever_treat_pay == 2 
lab var fever_treat_pay "Treatment payment"
tab fever_treat_pay, m 

// fever_treat_amount 
tab fever_treat_amount, m 
replace fever_treat_amount = .m if fever_treat_pay != 1
lab var fever_treat_amount "payment amount"
tab fever_treat_amount, m 

// outlier check 
sum fever_treat_amount, d
export 	excel $respinfo fever_treat_amount using "$out/mother_outlier.xlsx" if fever_treat_amount > `r(p90)' & !mi(fever_treat_amount), ///
		sheet("fever_treat_amount") firstrow(varlabels) sheetreplace 


// fever_treat_spent fever_treat_spent_1 fever_treat_spent_2 fever_treat_spent_3 fever_treat_spent_4 fever_treat_spent_5 fever_treat_spent_6 fever_treat_spent_888 fever_treat_spent_999 fever_treat_spent_777 
tab fever_treat_spent, m 

moss fever_treat_spent, match("([0-9]+)") regex

drop _pos*
sum _count

forval x = 1/`r(max)' {
	destring _match`x', replace
	rename _match`x' fever_treat_spent`x'
}

drop _count

local num 1 2 3 4 5 6 777  

foreach x in `num'{
	tab fever_treat_spent_`x', m 
	drop fever_treat_spent_`x'
	gen fever_treat_spent_`x' = (fever_treat_spent1 == `x' | ///
								 fever_treat_spent2 == `x' | ///
								 fever_treat_spent3 == `x' | ///
								 fever_treat_spent4 == `x' | ///
								 fever_treat_spent5 == `x')
	replace fever_treat_spent_`x' = .d if fever_treat_spent1 == 888 | ///
										  fever_treat_spent2 == 888 | ///
										  fever_treat_spent3 == 888 | ///
										  fever_treat_spent4 == 888 | ///
										  fever_treat_spent5 == 888
	replace fever_treat_spent_`x' = .m if fever_treat_pay != 1
	order fever_treat_spent_`x', before(fever_treat_spent_oth)
	tab fever_treat_spent_`x', m
}

lab var fever_treat_spent_1 "Travel cost"
lab var fever_treat_spent_2 "Registration fees"
lab var fever_treat_spent_3 "Medicine"
lab var fever_treat_spent_4 "Blood test"
lab var fever_treat_spent_5 "Investigation"
lab var fever_treat_spent_6 "Gift"
lab var fever_treat_spent_777 "Other cost categories"

// fever_treat_spent_oth 
tab fever_treat_spent_oth, m 

preserve
keep if fever_treat_spent_777 == 1
if _N > 0 {
	export 	excel $respinfo fever_treat_spent_oth using "$out/mother_other_specify.xlsx", ///
			sheet("fever_treat_spent_oth") firstrow(varlabels) sheetreplace 
}
restore


// fever_treat_loan 
tab fever_treat_loan, m 

split fever_treat_loan, p(".")
drop fever_treat_loan2
order fever_treat_loan1, after(fever_treat_loan)
drop fever_treat_loan
rename fever_treat_loan1 fever_treat_loan
destring fever_treat_loan, replace 
replace fever_treat_loan = .m if fever_treat_pay != 1 
replace fever_treat_loan = 0 if fever_treat_loan == 2 
lab var fever_treat_loan "treatment payment loan"
tab fever_treat_loan, m 

// fever_still 
tab fever_still, m 

split fever_still, p(".")
drop fever_still2-fever_still5
order fever_still1, after(fever_still)
drop fever_still
rename fever_still1 fever_still
destring fever_still, replace 
replace fever_still = .n if mi(fever_still)
replace fever_still = .m if child_ill_3 != 1
replace fever_still = 0 if fever_still == 2 
lab var fever_still "Still having diarrhea"
tab fever_still, m 

// fever_recovery_day 
tab fever_recovery_day, m 
replace fever_recovery_day = .n if mi(fever_recovery_day)
replace fever_recovery_day = .m if fever_still != 0
lab var fever_recovery_day "Recovery days"
tab fever_recovery_day, m 

// outlier check 
sum fever_recovery_day, d
export 	excel $respinfo fever_recovery_day using "$out/mother_outlier.xlsx" if fever_recovery_day > `r(p90)' & !mi(fever_recovery_day), ///
		sheet("fever_recovery_day") firstrow(varlabels) sheetreplace 


// fever_malaria_test 
tab fever_malaria_test, m 

split fever_malaria_test, p(".")
drop fever_malaria_test2
order fever_malaria_test1, after(fever_malaria_test)
drop fever_malaria_test
rename fever_malaria_test1 fever_malaria_test
destring fever_malaria_test, replace 
replace fever_malaria_test = .n if mi(fever_malaria_test)
replace fever_malaria_test = .m if child_ill_3 != 1
replace fever_malaria_test = 0 if fever_malaria_test == 2 
replace fever_malaria_test = .d if fever_malaria_test == 888 
lab var fever_malaria_test "Malaria test"
tab fever_malaria_test, m 


** seeking treatment with trained health personnel **
local illtype	diarrhea cough fever

foreach var in `illtype'{
    
	gen `var'_skilltreat = (`var'_treat_place_1 == 1 | `var'_treat_place_2 == 1 | ///
							`var'_treat_place_3 == 1 | `var'_treat_place_4 == 1 | ///
							`var'_treat_place_5 == 1 | `var'_treat_place_10 ==  1 | ///
							`var'_treat_place_12 == 1)
	replace `var'_skilltreat = .m if `var'_treat != 1
	lab var `var'_skilltreat "trained health personnel - `var'"
	tab `var'_skilltreat, m 
							
}

********************************************************************************
** E (ii) Child growth monitoring & immunization **
********************************************************************************
// e_note 
/*
odk response code
1. ၂၄လနှင့်၂၄လအောက် သို့မဟုတ် ၂ နှစ်နှင့်၂နှစ်အောက် <=24months old or <=2 year old
2. ၂၄ လအထက် သို့မဟုတ် ၂နှစ်အထက်>24 months old or >2 year old
*/
tab e_note, m 

split e_note, p(".")
drop e_note2
order e_note1, after(e_note)
drop e_note
rename e_note1 e_note
destring e_note, replace 
replace e_note = 0 if e_note == 2 // treat over 2 yrs as 0
replace e_note = .n if mi(e_note)

tab e_note, m 
/*
odk response code 
1. ၂၄လနှင့်၂၄လအောက် သို့မဟုတ် ၂ နှစ်နှင့်၂နှစ်အောက် <=24months old or <=2 year old
2. ၂၄ လအထက် သို့မဟုတ် ၂နှစ်အထက်>24 months old or >2 year old
*/
tab d_note, m 

tab d_note, m 

// eligable child check 
preserve
keep if e_note != d_note & !mi(d_note)
if _N > 0 {
	export 	excel $respinfo svy_date u5_dob_1 cal_cage_1 u5_dob_2 cal_cage_2 u5_dob_3 cal_cage_3 ///
			cal_u2_tot d_note e_note using "$out/mother_logical_check.xlsx", ///
			sheet("u2_inconsistant") firstrow(varlabels) sheetreplace 
}
restore	

// e_note_1 
tab e_note_1, m 
drop e_note_1 

/* 
Data issue note:
Inconsistant U2 identification between IYCF and child health module and this immunization module
and not matched with child DOB calculated child age info
but use this e_note var for data cleaning as it was applied in the ODK programming as
relevant criteria for skip pattern

*** THIS PRACTICE SERIOUSLY EFFECT ONE IDENTIFICATION OF ELIGABLE OBS FOR INDICATOR CALCULATION ***
*/
// wt_monitor 
tab wt_monitor, m 

split wt_monitor, p(".")
drop wt_monitor2
order wt_monitor1, after(wt_monitor)
drop wt_monitor
rename wt_monitor1 wt_monitor
destring wt_monitor, replace 
replace wt_monitor = .n if mi(wt_monitor)
replace wt_monitor = .m if e_note != 1
replace wt_monitor = .d if wt_monitor == 888
tab wt_monitor, m 

forvalue x = 1/4 {
	gen wt_monitor_`x' = (wt_monitor == `x')
	replace wt_monitor_`x' = .m if mi(wt_monitor)
	order wt_monitor_`x', before(wt_monitor_freq)
	tab wt_monitor_`x', m
}

lab var wt_monitor_1 "at facility"
lab var wt_monitor_2 "at community"
lab var wt_monitor_3 "at both facility and community "
lab var wt_monitor_4 "No growth monitoring"

// wt_monitor_freq 
tab wt_monitor_freq, m 

preserve
keep if !mi(wt_monitor_freq) & wt_monitor == 4 & (wt_monitor_freq == 0 | wt_monitor_freq == 444)
if _N > 0 {
	export 	excel $respinfo wt_monitor wt_monitor_freq using "$out/mother_logical_check.xlsx", ///
			sheet("wt_monitor_freq") firstrow(varlabels) sheetreplace 
}
restore	

replace wt_monitor_freq = .d if wt_monitor_freq == 888
replace wt_monitor_freq = .m if wt_monitor > 3
lab var wt_monitor_freq "growth monitoring frequency"
tab wt_monitor_freq, m 

// outlier check 
sum wt_monitor_freq, d
export 	excel $respinfo wt_monitor_freq using "$out/mother_outlier.xlsx" if wt_monitor_freq > `r(p95)' & !mi(wt_monitor_freq), ///
		sheet("wt_monitor_freq") firstrow(varlabels) sheetreplace 


// vaccin_yes 
tab vaccin_yes, m 

split vaccin_yes, p(".")
drop vaccin_yes2-vaccin_yes4
order vaccin_yes1, after(vaccin_yes)
drop vaccin_yes
rename vaccin_yes1 vaccin_yes
destring vaccin_yes, replace 
replace vaccin_yes = .n if mi(vaccin_yes)
replace vaccin_yes = .m if e_note != 1
lab var vaccin_yes "childhood vaccination - yes"
tab vaccin_yes, m 

// vaccin_card 
tab vaccin_card, m 

split vaccin_card, p(".")
drop vaccin_card2-vaccin_card4
order vaccin_card1, after(vaccin_card)
drop vaccin_card
rename vaccin_card1 vaccin_card
destring vaccin_card, replace 
replace vaccin_card = .n if mi(vaccin_card)
replace vaccin_card = .m if vaccin_yes != 1
lab var vaccin_card "Immunication card - yes"
tab vaccin_card, m 

// e_note_2 
tab e_note_2, m 
drop e_note_2

// vaccin_card_bcg vaccin_card_hpb vaccin_card_penta5_1 vaccin_card_penta5_2 vaccin_card_penta5_3 vaccin_card_polio_oral vaccin_card_polio_1 vaccin_card_polio_2 vaccin_card_polio_3 vaccin_card_measles_1 vaccin_card_measles_2 vaccin_card_rubella vaccin_card_encephalitis 

local vaccine	bcg hpb penta5_1 penta5_2 penta5_3 polio_oral polio_1 polio_2 polio_3 ///
				measles_1 measles_2 rubella encephalitis 

foreach var in `vaccine'{
    tab vaccin_card_`var', m 
    split vaccin_card_`var', p(".")
	drop vaccin_card_`var'2
	order vaccin_card_`var'1, after(vaccin_card_`var')
	drop vaccin_card_`var'
	rename vaccin_card_`var'1 vaccin_card_`var'
	destring vaccin_card_`var', replace 
	replace vaccin_card_`var' = .n if mi(vaccin_card_`var')
	replace vaccin_card_`var' = .m if vaccin_card != 1
	tab vaccin_card_`var', m 
}

lab var vaccin_card_bcg "BCG"
lab var vaccin_card_hpb "Hep B"
lab var vaccin_card_penta5_1 "PENTA-5 - 1st time" 
lab var vaccin_card_penta5_2 "PENTA-5 - 2nd time"
lab var vaccin_card_penta5_3 "PENTA-5 - 3rd time"
lab var vaccin_card_polio_oral "Oral polio - 1st time" 
lab var vaccin_card_polio_1 "Injectioni polio"
lab var vaccin_card_polio_2 "Oral polio - 2nd time"
lab var vaccin_card_polio_3 "Oral polio - 3rd time"
lab var vaccin_card_measles_1 "Measles - 1st time" 
lab var vaccin_card_measles_2 "Measles - 2nd time"
lab var vaccin_card_rubella "Rubella"
lab var vaccin_card_encephalitis "Japanese Encephalitis"

// e_note_3 
tab e_note_3, m // this doesn't tell any information 

/*
Data cleaning note
Skip pattern error note were observed 
*/

// vaccin_nocard_bcg 
tab vaccin_nocard_bcg, m 

split vaccin_nocard_bcg, p(".")
drop vaccin_nocard_bcg2
order vaccin_nocard_bcg1, after(vaccin_nocard_bcg)
drop vaccin_nocard_bcg
rename vaccin_nocard_bcg1 vaccin_nocard_bcg
destring vaccin_nocard_bcg, replace 
replace vaccin_nocard_bcg = .n if mi(vaccin_nocard_bcg)
replace vaccin_nocard_bcg = .m if vaccin_card != 0
replace vaccin_nocard_bcg = .d if vaccin_nocard_bcg == 888
lab var vaccin_nocard_bcg "BCG"
tab vaccin_nocard_bcg, m 

// immunization no card var renaming 
rename vaccin_nocard_penta5_1 vaccin_nocard_penta5
rename vaccin_nocard_penta5_2 vaccin_nocard_penta5_freq
rename vaccin_nocard_penta5_3 vaccin_nocard_pcv // not include this type in the card record 
rename vaccin_nocard_polio_oral vaccin_nocard_pcv_freq 
rename vaccin_nocard_polio_1 vaccin_nocard_polio_oral  
rename vaccin_nocard_polio_2 vaccin_nocard_polio_freq
rename vaccin_nocard_polio_3 vaccin_nocard_polio_inj
rename vaccin_nocard_measles_2 vaccin_nocard_measles_freq
rename vaccin_nocard_measles_1 vaccin_nocard_measles

// vaccin_nocard_hpb vaccin_nocard_penta5 vaccin_nocard_pcv vaccin_nocard_polio_oral vaccin_nocard_polio_inj vaccin_nocard_measles vaccin_nocard_rubella vaccin_nocard_encephalitis

local vaccine	hpb penta5 penta5_freq pcv pcv_freq polio_oral polio_inj measles ///
				measles_freq rubella encephalitis 

foreach var in `vaccine'{
    tab vaccin_nocard_`var', m 
    split vaccin_nocard_`var', p(".")
	drop vaccin_nocard_`var'2
	order vaccin_nocard_`var'1, after(vaccin_nocard_`var')
	drop vaccin_nocard_`var'
	rename vaccin_nocard_`var'1 vaccin_nocard_`var'
	destring vaccin_nocard_`var', replace 
	replace vaccin_nocard_`var' = .n if mi(vaccin_nocard_`var')
	replace vaccin_nocard_`var' = .m if vaccin_card != 0
	replace vaccin_nocard_`var' = .d if vaccin_nocard_`var' == 888
	tab vaccin_nocard_`var', m 
}

lab var vaccin_nocard_hpb "Hep B"
lab var vaccin_nocard_penta5 "PENTA-5" 
lab var vaccin_nocard_pcv "PCV"
lab var vaccin_nocard_polio_oral "Oral polio vaccine"  
lab var vaccin_nocard_polio_inj "Injectioni polio"
lab var vaccin_nocard_measles "Measles"
lab var vaccin_nocard_rubella "Rubella"
lab var vaccin_nocard_encephalitis "Japanese Encephalitis"

// vaccin_nocard_penta5_freq
tab vaccin_nocard_penta5_freq, m 
replace vaccin_nocard_penta5_freq = .m if vaccin_nocard_penta5 != 1
lab var vaccin_nocard_penta5_freq "PENTA-5 - frequency" 
tab vaccin_nocard_penta5_freq, m 

forvalue x = 1/3{
    gen vaccin_nocard_penta5_`x' 		= (vaccin_nocard_penta5_freq == `x')
	replace vaccin_nocard_penta5_`x' 	= .m if mi(vaccin_nocard_penta5_freq)
	lab var vaccin_nocard_penta5_`x' "PENTA-5 - `x'"
	tab vaccin_nocard_penta5_`x', m 
}

// vaccin_nocard_pcv_freq 
tab vaccin_nocard_pcv_freq, m 
replace vaccin_nocard_pcv_freq = .m if vaccin_nocard_pcv != 1
lab var vaccin_nocard_pcv_freq "PCV - frequency"
tab vaccin_nocard_pcv_freq, m 

forvalue x = 1/3{
    gen vaccin_nocard_pcv_`x' 		= (vaccin_nocard_pcv_freq == `x')
	replace vaccin_nocard_pcv_`x' 	= .m if mi(vaccin_nocard_pcv_freq)
	lab var vaccin_nocard_pcv_`x' "PCV - `x'"
	tab vaccin_nocard_pcv_`x', m 
}

// vaccin_nocard_polio_freq
tab vaccin_nocard_polio_freq, m 
replace vaccin_nocard_polio_freq = .m if vaccin_nocard_polio_oral != 1
lab var vaccin_nocard_polio_freq "Oral polio vaccine - frequency"
tab vaccin_nocard_polio_freq, m 

forvalue x = 1/3{
    gen vaccin_nocard_polio_`x' 		= (vaccin_nocard_polio_freq == `x')
	replace vaccin_nocard_polio_`x' 	= .m if mi(vaccin_nocard_polio_freq)
	lab var vaccin_nocard_polio_`x' "Oral polio - `x'"
	tab vaccin_nocard_polio_`x', m 
}

// outlier check 
sum vaccin_nocard_polio_freq, d
export 	excel $respinfo vaccin_nocard_polio_freq using "$out/mother_outlier.xlsx" if vaccin_nocard_polio_freq > 2 & !mi(vaccin_nocard_polio_freq), ///
		sheet("vaccin_nocard_polio_freq") firstrow(varlabels) sheetreplace 

// vaccin_nocard_measles_freq
tab vaccin_nocard_measles_freq, m 
replace vaccin_nocard_measles_freq = .m if vaccin_nocard_measles != 1
lab var vaccin_nocard_measles_freq "Measles - frequency"
tab vaccin_nocard_measles_freq, m 

forvalue x = 1/2{
    gen vaccin_nocard_measles_`x' 		= (vaccin_nocard_measles_freq == `x')
	replace vaccin_nocard_measles_`x' 	= .m if mi(vaccin_nocard_measles_freq)
	lab var vaccin_nocard_measles_`x' "Measles - `x'"
	tab vaccin_nocard_measles_`x', m 
}


** Reporting indicators **			
// BCG 
gen vaccin_bcg 		= (vaccin_nocard_bcg == 1 | vaccin_card_bcg == 1)			
replace vaccin_bcg 	= .m if mi(vaccin_nocard_bcg) & mi(vaccin_card_bcg)
lab var vaccin_bcg "BCG"
tab vaccin_bcg, m 

// HPB
gen vaccin_hpb 		= (vaccin_nocard_hpb == 1 | vaccin_card_hpb == 1)			
replace vaccin_hpb 	= .m if mi(vaccin_nocard_hpb) & mi(vaccin_card_hpb)
lab var vaccin_hpb "Hep B"
tab vaccin_hpb, m 

// PENTA-5 
gen vaccin_penta5_1 	= (vaccin_card_penta5_1 == 1 | vaccin_nocard_penta5_1 == 1)
replace vaccin_penta5_1 = .m if mi(vaccin_card_penta5_1) & mi(vaccin_nocard_penta5_1)
lab var vaccin_penta5_1 "PENTA-5 - 1st time"
tab vaccin_penta5_1, m 

gen vaccin_penta5_2 	= (vaccin_card_penta5_2 == 1 | vaccin_nocard_penta5_2 == 1)
replace vaccin_penta5_2 = .m if mi(vaccin_card_penta5_2) & mi(vaccin_nocard_penta5_2)
lab var vaccin_penta5_2 "PENTA-5 - 2nd time"
tab vaccin_penta5_2, m 

gen vaccin_penta5_3 	= (vaccin_card_penta5_3 == 1 | vaccin_nocard_penta5_3 == 1)
replace vaccin_penta5_3 = .m if mi(vaccin_card_penta5_3) & mi(vaccin_nocard_penta5_3)
lab var vaccin_penta5_3 "PENTA-5 - 3rd time"
tab vaccin_penta5_3, m 

// PCV 
gen vaccin_pcv_1 = vaccin_nocard_pcv_1
lab var vaccin_pcv_1 "PCV - 1st time"
tab vaccin_pcv_1, m 

gen vaccin_pcv_2 = vaccin_nocard_pcv_2 
lab var vaccin_pcv_2 "PCV - 2nd time"
tab vaccin_pcv_2, m 

gen vaccin_pcv_3 = vaccin_nocard_pcv_3 
lab var vaccin_pcv_3 "PCV - 3rd time"
tab vaccin_pcv_3, m 

// Polio injection 
gen vaccin_polio_inj 	= (vaccin_nocard_polio_inj == 1 | vaccin_card_polio_1 == 1)
replace vaccin_polio_inj = .m if mi(vaccin_nocard_polio_inj) & mi(vaccin_card_polio_1)
lab var vaccin_polio_inj "Polio injection"
tab vaccin_polio_inj, m 

// Polio Oral 
gen vaccin_polio_oral_1 	= (vaccin_card_polio_oral == 1 | vaccin_nocard_polio_1 == 1)
replace vaccin_polio_oral_1 = .m if mi(vaccin_card_penta5_1) & mi(vaccin_nocard_polio_1)
lab var vaccin_polio_oral_1 "Oral polio - 1st time"
tab vaccin_polio_oral_1, m 

gen vaccin_polio_oral_2 	= (vaccin_card_polio_2 == 1 | vaccin_nocard_polio_2 == 1)
replace vaccin_polio_oral_2 = .m if mi(vaccin_card_polio_2) & mi(vaccin_nocard_polio_2)
lab var vaccin_polio_oral_2 "Oral polio - 2nd time"
tab vaccin_polio_oral_2, m 

gen vaccin_polio_oral_3 	= (vaccin_card_polio_3 == 1 | vaccin_nocard_polio_3 == 1)
replace vaccin_polio_oral_3 = .m if mi(vaccin_card_polio_3) & mi(vaccin_nocard_polio_3)
lab var vaccin_polio_oral_3 "Oral polio - 3rd time"
tab vaccin_polio_oral_3, m 

// Measles
gen vaccin_measles_1 		= (vaccin_card_measles_1 == 1 | vaccin_nocard_measles_1 == 1)
replace vaccin_measles_1 	= .m if mi(vaccin_card_measles_1) & mi(vaccin_nocard_measles_1)
lab var vaccin_measles_1 "Measles - 1st time"
tab vaccin_measles_1, m 

gen vaccin_measles_2 		= (vaccin_card_measles_2 == 1 | vaccin_nocard_measles_2 == 1)
replace vaccin_measles_2 	= .m if mi(vaccin_card_measles_2) & mi(vaccin_nocard_measles_2)
lab var vaccin_measles_2 "Measles - 2nd time"
tab vaccin_measles_2, m 

// Rubella
gen vaccin_rubella 		= (vaccin_card_rubella == 1 | vaccin_nocard_rubella == 1)
replace vaccin_rubella 	= .m if mi(vaccin_card_rubella) & mi(vaccin_nocard_rubella) 
lab var vaccin_rubella "Rubella"
tab vaccin_rubella, m 		
				
// vaccin_card_encephalitis
gen vaccin_encephalitis 		= (vaccin_card_encephalitis == 1 | vaccin_nocard_encephalitis == 1)
replace vaccin_encephalitis 	= .m if mi(vaccin_card_encephalitis) & mi(vaccin_nocard_encephalitis)
lab var vaccin_encephalitis "Encephalitis"
tab vaccin_encephalitis, m 

// Immunization Access
gen vaccin_access = vaccin_bcg
lab var vaccin_access "Immunization access"
tab vaccin_access, m 

// Immunization Utilization - completed all PENTA-5 
gen vaccin_utilize 		= (vaccin_penta5_1 == 1 & vaccin_penta5_2 == 1 & vaccin_penta5_3 == 1)
replace vaccin_utilize 	= .m if mi(vaccin_penta5_1) | mi(vaccin_penta5_2) | mi(vaccin_penta5_3) 
lab var vaccin_utilize "Immunization utilization"
tab vaccin_utilize, m

// Full immunized- 12-23 months 
gen vaccin_full		= (	vaccin_bcg == 1 & vaccin_hpb == 1 & vaccin_penta5_1 == 1 & ///
						vaccin_penta5_2 == 1 & vaccin_penta5_3 == 1 & ///
						vaccin_polio_oral_1 == 1 & vaccin_polio_oral_2 == 1 & ///
						vaccin_polio_oral_3 == 1 & vaccin_measles_1 == 1 & ///
						vaccin_rubella == 1 & vaccin_encephalitis == 1)
replace vaccin_full	= .m if mi(vaccin_bcg) | mi(vaccin_hpb) | mi(vaccin_penta5_1) | ///
							mi(vaccin_penta5_2) | mi(vaccin_penta5_3) | mi(vaccin_polio_oral_1) | ///
							mi(vaccin_polio_oral_2) | mi(vaccin_polio_oral_3) | mi(vaccin_measles_1) | ///
							mi(vaccin_rubella) | mi(vaccin_encephalitis)
lab var vaccin_full "Full immunization coverage"
tab vaccin_full, m 	
 		
** Age appropriate immunisation status **
// BCG 
gen age_vaccin_bcg = vaccin_bcg
lab var age_vaccin_bcg "BCG"

// HPB
gen age_vaccin_hpb =  vaccin_hpb
lab var age_vaccin_hpb "Hep B"

// PENTA-5
* at 2 months 
gen age_vaccin_penta5_1 	=  vaccin_penta5_1
replace age_vaccin_penta5_1 = .m if youngest_age_month < 2 | mi(youngest_age_month)
lab var age_vaccin_penta5_1 "PENTA-5 - 1st time"
tab age_vaccin_penta5_1, m 

* at 4 monhts 
gen age_vaccin_penta5_2 	=  vaccin_penta5_2
replace age_vaccin_penta5_2 = .m if youngest_age_month < 4 | mi(youngest_age_month)
lab var age_vaccin_penta5_2 "PENTA-5 - 2nd time"
tab age_vaccin_penta5_2, m 

* at 6 monhts 
gen age_vaccin_penta5_3 	=  vaccin_penta5_3
replace age_vaccin_penta5_3 = .m if youngest_age_month < 6 | mi(youngest_age_month)
lab var age_vaccin_penta5_3 "PENTA-5 - 3rd time"
tab age_vaccin_penta5_3, m 

// PCV 
* at 2 months 
gen age_vaccin_pcv_1 		= vaccin_pcv_1
replace age_vaccin_pcv_1 	= .m if youngest_age_month < 2 | mi(youngest_age_month)
lab var age_vaccin_pcv_1 "PCV - 1st time"
tab age_vaccin_pcv_1, m 

* at 4 monhts 
gen age_vaccin_pcv_2 		=  vaccin_pcv_2
replace age_vaccin_pcv_2 	= .m if youngest_age_month < 4 | mi(youngest_age_month)
lab var age_vaccin_pcv_2 "PCV - 2nd time"
tab age_vaccin_pcv_2, m 

* at 6 monhts 
gen age_vaccin_pcv_3 		=  vaccin_pcv_3
replace age_vaccin_pcv_3 	= .m if youngest_age_month < 6 | mi(youngest_age_month)
lab var age_vaccin_pcv_3 "PCV - 3rd time"
tab age_vaccin_pcv_3, m 

// Polio injection 
* at 4 monhts 
gen age_vaccin_polio_inj 		=  vaccin_polio_inj
replace age_vaccin_polio_inj 	= .m if youngest_age_month < 4 | mi(youngest_age_month)
lab var age_vaccin_polio_inj "Polio injection"
tab age_vaccin_polio_inj, m 

// Polio Oral 
* at 2 months 
gen age_vaccin_polio_oral_1 		= vaccin_polio_oral_1
replace age_vaccin_polio_oral_1 	= .m if youngest_age_month < 2 | mi(youngest_age_month)
lab var age_vaccin_polio_oral_1 "Oral polio - 1st time"
tab age_vaccin_polio_oral_1, m 

* at 4 monhts 
gen age_vaccin_polio_oral_2 		=  vaccin_polio_oral_2
replace age_vaccin_polio_oral_2 	= .m if youngest_age_month < 4 | mi(youngest_age_month)
lab var age_vaccin_polio_oral_2 "Oral polio - 2nd time"
tab age_vaccin_polio_oral_2, m 

* at 6 monhts 
gen age_vaccin_polio_oral_3 		=  vaccin_polio_oral_3
replace age_vaccin_polio_oral_3 	= .m if youngest_age_month < 6 | mi(youngest_age_month)
lab var age_vaccin_polio_oral_3 "Oral polio - 3rd time"
tab age_vaccin_polio_oral_3, m 

// Measles
* at 9 months
gen age_vaccin_measles_1 		= vaccin_measles_1
replace age_vaccin_measles_1 	= .m if youngest_age_month < 9 | mi(youngest_age_month)
lab var age_vaccin_measles_1 "Measles - 1st time"
tab age_vaccin_measles_1, m 

* at 18 months 
gen age_vaccin_measles_2 		= vaccin_measles_2
replace age_vaccin_measles_2 	= .m if youngest_age_month < 18 | mi(youngest_age_month)
lab var age_vaccin_measles_2 "Measles - 2nd time"
tab age_vaccin_measles_2, m 

// Rubella
* at 9 months
gen age_vaccin_rubella		= vaccin_rubella
replace age_vaccin_rubella 	= .m if youngest_age_month < 9 | mi(youngest_age_month)
lab var age_vaccin_rubella "Rubella"
tab age_vaccin_rubella, m 	
				
// vaccin_card_encephalitis
* at 9 months
gen age_vaccin_encephalitis 		= vaccin_encephalitis
replace age_vaccin_encephalitis 	= .m if youngest_age_month < 9 | mi(youngest_age_month)
lab var age_vaccin_encephalitis "Encephalitis"
tab age_vaccin_encephalitis, m 

* Age appropriate immunisation - < 2 months 
gen age_epi_1 	= (youngest_age_month < 2 & age_vaccin_bcg == 1)
replace age_epi_1 = .m if youngest_age_month >= 2 | mi(age_vaccin_bcg)
tab age_epi_1, m 

gen age_epi_1_mcct = age_epi_1

* Age appropriate immunisation - >= 2 & 4 months 
gen age_epi_2 		= (	youngest_age_month >= 2 & youngest_age_month < 4 & ///
						age_vaccin_bcg == 1 &  age_vaccin_penta5_1 == 1 & ///
						age_vaccin_pcv_1 == 1 & age_vaccin_polio_oral_1 == 1)
replace age_epi_2 	= .m if mi(age_vaccin_bcg) | ///
							mi(age_vaccin_penta5_1) | mi(age_vaccin_pcv_1) | ///
							mi(age_vaccin_polio_oral_1)
replace age_epi_2 	= .m if youngest_age_month < 2 | youngest_age_month >= 4
tab age_epi_2, m 

gen age_epi_2_mcct 		= (	youngest_age_month >= 2 & youngest_age_month < 4 & ///
						age_vaccin_bcg == 1 &  age_vaccin_penta5_1 == 1 & ///
						age_vaccin_polio_oral_1 == 1)
replace age_epi_2_mcct 	= .m if mi(age_vaccin_bcg) | ///
							mi(age_vaccin_penta5_1) | mi(age_vaccin_polio_oral_1)
replace age_epi_2_mcct 	= .m if youngest_age_month < 2 | youngest_age_month >= 4
tab age_epi_2_mcct, m 

* Age appropriate immunisation - >= 4 & 6 months 
gen age_epi_3 		= (	youngest_age_month >= 4 & youngest_age_month < 6 & ///
						age_vaccin_bcg == 1 &  age_vaccin_penta5_1 == 1 & ///
						age_vaccin_pcv_1 == 1 & age_vaccin_polio_oral_1 == 1 & ///
						age_vaccin_penta5_2 == 1 & age_vaccin_pcv_2 == 1 & ///
						age_vaccin_polio_inj == 1 & age_vaccin_polio_oral_2 == 1)
replace age_epi_3 	= .m if mi(age_vaccin_bcg) | ///
							mi(age_vaccin_penta5_1) | mi(age_vaccin_pcv_1) | ///
							mi(age_vaccin_polio_oral_1) | mi(age_vaccin_penta5_2) | ///
							mi(age_vaccin_pcv_2) | mi(age_vaccin_polio_inj) | ///
							mi(age_vaccin_polio_oral_2)
replace age_epi_3 	= .m if youngest_age_month < 4 | youngest_age_month >= 6
tab age_epi_3, m 


gen age_epi_3_mcct 		= (	youngest_age_month >= 4 & youngest_age_month < 6 & ///
						age_vaccin_bcg == 1 &  age_vaccin_penta5_1 == 1 & ///
						age_vaccin_polio_oral_1 == 1 & ///
						age_vaccin_penta5_2 == 1 & ///
						age_vaccin_polio_oral_2 == 1)
replace age_epi_3_mcct 	= .m if mi(age_vaccin_bcg) | ///
							mi(age_vaccin_penta5_1) | ///
							mi(age_vaccin_polio_oral_1) | mi(age_vaccin_penta5_2) | ///
							mi(age_vaccin_polio_oral_2)
replace age_epi_3_mcct 	= .m if youngest_age_month < 4 | youngest_age_month >= 6
tab age_epi_3_mcct, m 


* Age appropriate immunisation - >= 6 & 9 months 
gen age_epi_4 		= (	youngest_age_month >= 6 & youngest_age_month < 9 & ///
						age_vaccin_bcg == 1 &  age_vaccin_penta5_1 == 1 & ///
						age_vaccin_pcv_1 == 1 & age_vaccin_polio_oral_1 == 1 & ///
						age_vaccin_penta5_2 == 1 & age_vaccin_pcv_2 == 1 & ///
						age_vaccin_polio_inj == 1 & age_vaccin_polio_oral_2 == 1 & ///
						age_vaccin_penta5_3 == 1 & age_vaccin_pcv_3 == 1 & ///
						age_vaccin_polio_oral_3 == 1)
replace age_epi_4 	= .m if mi(age_vaccin_bcg) | ///
							mi(age_vaccin_penta5_1) | mi(age_vaccin_pcv_1) | ///
							mi(age_vaccin_polio_oral_1) | mi(age_vaccin_penta5_2) | ///
							mi(age_vaccin_pcv_2) | mi(age_vaccin_polio_inj) | ///
							mi(age_vaccin_polio_oral_2) | mi(age_vaccin_penta5_3) | ///
							mi(age_vaccin_pcv_3) | mi(age_vaccin_polio_oral_3)
replace age_epi_4 	= .m if youngest_age_month < 6 | youngest_age_month >= 9
tab age_epi_4, m 


gen age_epi_4_mcct 		= (	youngest_age_month >= 6 & youngest_age_month < 9 & ///
						age_vaccin_bcg == 1 &  age_vaccin_penta5_1 == 1 & ///
						age_vaccin_polio_oral_1 == 1 & ///
						age_vaccin_penta5_2 == 1 & age_vaccin_polio_oral_2 == 1 & ///
						age_vaccin_penta5_3 == 1 & ///
						age_vaccin_polio_oral_3 == 1)
replace age_epi_4_mcct 	= .m if mi(age_vaccin_bcg) | ///
							mi(age_vaccin_penta5_1) | ///
							mi(age_vaccin_polio_oral_1) | mi(age_vaccin_penta5_2) | ///
							mi(age_vaccin_polio_oral_2) | mi(age_vaccin_penta5_3) | ///
							mi(age_vaccin_polio_oral_3)
replace age_epi_4_mcct 	= .m if youngest_age_month < 6 | youngest_age_month >= 9
tab age_epi_4_mcct, m 


* Age appropriate immunisation - >= 9 & 18 months 
gen age_epi_5 		= (	youngest_age_month >= 9 & youngest_age_month < 18 & ///
						age_vaccin_bcg == 1 &  age_vaccin_penta5_1 == 1 & ///
						age_vaccin_pcv_1 == 1 & age_vaccin_polio_oral_1 == 1 & ///
						age_vaccin_penta5_2 == 1 & age_vaccin_pcv_2 == 1 & ///
						age_vaccin_polio_inj == 1 & age_vaccin_polio_oral_2 == 1 & ///
						age_vaccin_penta5_3 == 1 & age_vaccin_pcv_3 == 1 & ///
						age_vaccin_polio_oral_3 == 1 & age_vaccin_measles_1 == 1 & ///
						age_vaccin_rubella == 1 & age_vaccin_encephalitis == 1)
replace age_epi_5 	= .m if mi(age_vaccin_bcg) | ///
							mi(age_vaccin_penta5_1) | mi(age_vaccin_pcv_1) | ///
							mi(age_vaccin_polio_oral_1) | mi(age_vaccin_penta5_2) | ///
							mi(age_vaccin_pcv_2) | mi(age_vaccin_polio_inj) | ///
							mi(age_vaccin_polio_oral_2) | mi(age_vaccin_penta5_3) | ///
							mi(age_vaccin_pcv_3) | mi(age_vaccin_polio_oral_3) | ///
							mi(age_vaccin_measles_1) | mi(age_vaccin_rubella) | ///
							mi(age_vaccin_encephalitis)
replace age_epi_5 	= .m if youngest_age_month < 9 | youngest_age_month >= 18
tab age_epi_5, m 

gen age_epi_5_mcct 		= (	youngest_age_month >= 9 & youngest_age_month < 18 & ///
						age_vaccin_bcg == 1 &  age_vaccin_penta5_1 == 1 & ///
						age_vaccin_polio_oral_1 == 1 & ///
						age_vaccin_penta5_2 == 1 & ///
						age_vaccin_polio_oral_2 == 1 & ///
						age_vaccin_penta5_3 == 1 & ///
						age_vaccin_polio_oral_3 == 1 & age_vaccin_measles_1 == 1 & ///
						age_vaccin_rubella == 1)
replace age_epi_5_mcct 	= .m if mi(age_vaccin_bcg) | ///
							mi(age_vaccin_penta5_1) | ///
							mi(age_vaccin_polio_oral_1) | mi(age_vaccin_penta5_2) | ///
							mi(age_vaccin_polio_oral_2) | mi(age_vaccin_penta5_3) | ///
							mi(age_vaccin_polio_oral_3) | ///
							mi(age_vaccin_measles_1) | mi(age_vaccin_rubella)
replace age_epi_5_mcct 	= .m if youngest_age_month < 9 | youngest_age_month >= 18
tab age_epi_5_mcct, m 


* Age appropriate immunisation - >= 18 months 
gen age_epi_6 		= (	youngest_age_month >= 18 & ///
						age_vaccin_bcg == 1 &  age_vaccin_penta5_1 == 1 & ///
						age_vaccin_pcv_1 == 1 & age_vaccin_polio_oral_1 == 1 & ///
						age_vaccin_penta5_2 == 1 & age_vaccin_pcv_2 == 1 & ///
						age_vaccin_polio_inj == 1 & age_vaccin_polio_oral_2 == 1 & ///
						age_vaccin_penta5_3 == 1 & age_vaccin_pcv_3 == 1 & ///
						age_vaccin_polio_oral_3 == 1 & age_vaccin_measles_1 == 1 & ///
						age_vaccin_rubella == 1 & age_vaccin_encephalitis == 1 & ///
						age_vaccin_measles_2 == 1)
replace age_epi_6 	= .m if mi(age_vaccin_bcg) | ///
							mi(age_vaccin_penta5_1) | mi(age_vaccin_pcv_1) | ///
							mi(age_vaccin_polio_oral_1) | mi(age_vaccin_penta5_2) | ///
							mi(age_vaccin_pcv_2) | mi(age_vaccin_polio_inj) | ///
							mi(age_vaccin_polio_oral_2) | mi(age_vaccin_penta5_3) | ///
							mi(age_vaccin_pcv_3) | mi(age_vaccin_polio_oral_3) | ///
							mi(age_vaccin_measles_1) | mi(age_vaccin_rubella) | ///
							mi(age_vaccin_encephalitis) | mi(age_vaccin_measles_2)
replace age_epi_6 	= .m if youngest_age_month < 18 | mi(youngest_age_month)
tab age_epi_6, m 

gen age_epi_6_mcct 		= (	youngest_age_month >= 18 & ///
						age_vaccin_bcg == 1 &  age_vaccin_penta5_1 == 1 & ///
						age_vaccin_polio_oral_1 == 1 & ///
						age_vaccin_penta5_2 == 1 & age_vaccin_polio_oral_2 == 1 & ///
						age_vaccin_penta5_3 == 1 & ///
						age_vaccin_polio_oral_3 == 1 & age_vaccin_measles_1 == 1 & ///
						age_vaccin_rubella == 1 & ///
						age_vaccin_measles_2 == 1)
replace age_epi_6_mcct 	= .m if mi(age_vaccin_bcg) | ///
							mi(age_vaccin_penta5_1) | ///
							mi(age_vaccin_polio_oral_1) | mi(age_vaccin_penta5_2) | ///
							mi(age_vaccin_polio_oral_2) | mi(age_vaccin_penta5_3) | ///
							mi(age_vaccin_polio_oral_3) | ///
							mi(age_vaccin_measles_1) | mi(age_vaccin_rubella) | ///
							mi(age_vaccin_measles_2)
replace age_epi_6_mcct 	= .m if youngest_age_month < 18 | mi(youngest_age_month)
tab age_epi_6_mcct, m 


* Age appropriate immunisation - combined 
egen age_epi 	= rowtotal(age_epi_1 age_epi_2 age_epi_3 age_epi_4 age_epi_5 age_epi_6)
replace age_epi = .m if mi(age_epi_1) & mi(age_epi_2) & mi(age_epi_3) & mi(age_epi_4) & mi(age_epi_5) & mi(age_epi_6)
lab var age_epi "Age-appropriate immunization"
tab age_epi, m 

egen age_epi_mcct 		= rowtotal(age_epi_1 age_epi_2_mcct age_epi_3_mcct age_epi_4_mcct age_epi_5_mcct age_epi_6_mcct)
replace age_epi_mcct 	= .m if mi(age_epi_1) & mi(age_epi_2_mcct) & mi(age_epi_3_mcct) & mi(age_epi_4_mcct) & mi(age_epi_5_mcct) & mi(age_epi_6_mcct)
lab var age_epi_mcct "Age-appropriate immunization (MCCT)"
tab age_epi_mcct, m 

lab var age_epi_1 "less than 2 months"
lab var age_epi_2 "2 months to less than 4 months"
lab var age_epi_3 "4 months to less than 6 months"
lab var age_epi_4 "6 months to less than 9 months"
lab var age_epi_5 "9 months to less than 18 months"
lab var age_epi_6 "18 months or more"

lab var age_epi_1_mcct "less than 2 months"
lab var age_epi_2_mcct "2 months to less than 4 months"
lab var age_epi_3_mcct "4 months to less than 6 months"
lab var age_epi_4_mcct "6 months to less than 9 months"
lab var age_epi_5_mcct "9 months to less than 18 months"
lab var age_epi_6_mcct "18 months or more"


global vaccine	vaccin_yes vaccin_card vaccin_card_bcg vaccin_card_hpb vaccin_card_penta5_1 ///
				vaccin_card_penta5_2 vaccin_card_penta5_3 vaccin_card_polio_oral ///
				vaccin_card_polio_1 vaccin_card_polio_2 vaccin_card_polio_3 vaccin_card_measles_1 ///
				vaccin_card_measles_2 vaccin_card_rubella vaccin_card_encephalitis ///
				vaccin_nocard_bcg vaccin_nocard_hpb vaccin_nocard_penta5_1 vaccin_nocard_penta5_2 vaccin_nocard_penta5_3 ///
				vaccin_nocard_pcv_1 vaccin_nocard_pcv_2 ///
				vaccin_nocard_polio_1 vaccin_nocard_polio_2 vaccin_nocard_polio_3 ///
				vaccin_nocard_polio_inj vaccin_nocard_measles_1 vaccin_nocard_measles_2 ///
				vaccin_nocard_rubella vaccin_nocard_encephalitis ///
				vaccin_bcg vaccin_hpb vaccin_penta5_1 vaccin_penta5_2 vaccin_penta5_3 ///
				vaccin_pcv_1 vaccin_pcv_2 vaccin_polio_inj vaccin_polio_oral_1 ///
				vaccin_polio_oral_2 vaccin_polio_oral_3 vaccin_measles_1 vaccin_measles_2 ///
				vaccin_rubella vaccin_encephalitis vaccin_access vaccin_utilize vaccin_full ///
				age_vaccin_bcg age_vaccin_hpb age_vaccin_penta5_1 age_vaccin_penta5_2 ///
				age_vaccin_penta5_3 age_vaccin_pcv_1 age_vaccin_pcv_2 age_vaccin_pcv_3 ///
				age_vaccin_polio_inj age_vaccin_polio_oral_1 age_vaccin_polio_oral_2 ///
				age_vaccin_polio_oral_3 age_vaccin_measles_1 age_vaccin_measles_2 ///
				age_vaccin_rubella age_vaccin_encephalitis ///
				age_epi_1 age_epi_2  age_epi_3  age_epi_4  age_epi_5  age_epi_6 ///
				age_epi_1_mcct age_epi_2_mcct age_epi_3_mcct age_epi_4_mcct age_epi_5_mcct age_epi_6_mcct ///
				age_epi age_epi_mcct 
				
				
				
foreach var in $vaccine {
    replace `var' = .m if youngest_age_month >= 24 
}

foreach var of varlist vaccin_yes vaccin_card vaccin_access vaccin_utilize vaccin_full {
	
	tab `var' under_over_14m
	forvalue x = 0/1{
		gen `var'_`x' = `var'
		replace `var'_`x' = .m if under_over_14m == `x'
		tab `var'_`x'
	}
}



// END HERE 



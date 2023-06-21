/*******************************************************************************
Project Name		: 	Project Nourish
Purpose				:	1st round data collection - Mothers data cleaning			
Author				:	Nicholus Tint Zaw
Date				: 	5/09/2022
Modified by			:

*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "00_dir_setting.do"
do "00_dir_setting_w1.do"

********************************************************************************
** Wave - 1 Data **
********************************************************************************
use "$dta/mothers_cleaned.dta", clear  


&&



Module 

Mom dietary 
Child dietary 
Women empowerment
Respondent info - ?
- age 
- edu 
- hh head



global respinfo	interview_id vill_name svy_date enu_name supervisor_name resp_age

********************************************************************************
** DATA CLEANING **
********************************************************************************
// start 
tab start, m 

// end 
tab end, m 

// interview_id 
tab interview_id, m 
distinct interview_id // all unique 

// vill_name 
tab vill_name, m 
distinct vill_name // 64 unique 

gen village_id =  ustrregexra(interview_id, "([0-9])", "")
replace village_id = subinstr(village_id, "-", " ", .)

split village_id, p(" ")

replace village_id2 = village_id3 if mi(village_id2) & !mi(village_id3)
replace village_id3 = "" if village_id2 == village_id3

gen village_id_new = village_id1 + "-" + village_id2 if mi(village_id3)
replace village_id_new = village_id1 + "-" + village_id2 + "-" + village_id3 if !mi(village_id3)

drop village_id village_id1-village_id3
rename village_id_new village_id 
order village_id, after(vill_name)

gen vill_name_original = vill_name
order vill_name_original, after(vill_name)

preserve
bysort vill_name village_id: gen survey_yes = _N
bysort vill_name village_id:keep if _n == 1

keep vill_name vill_name_original village_id survey_yes
export 	excel using "$out/village_and_svy_list.xlsx", ///
		sheet("village_list") firstrow(varlabels) replace  

restore

gen vill_name_old = vill_name 

* Village Name Correction - NCL correction * 
readreplace using "$raw/project_nourish_baseline_sampling_info_akr_replace.xlsx", ///
			id("village_id") variable("variable") value("correction") ///		
			excel import(firstrow sheet("svy_village_list")) 
								
/* NCL note 
with assumption of village id - KC-KLW (village name - Law Lar Wah) was from the 
KEHOC village - Kalaw Wah (village id KC-KW) 
*/				
replace vill_name 	= "Kalaw Wah" if village_id == "KC-KLW"
replace village_id 	= "KC-KW" if village_id == "KC-KLW"
replace village_id 	= "KC-KW" if village_id == "KC-KLW_"


* Village Name/ ID Correction - checked with CPI* 
readreplace using "$raw/mothers_cleaned_cpi_checked.xlsx", ///
			id("interview_id") variable("variable") value("correction") ///		
			excel import(firstrow sheet("replacement")) 

replace village_id = "KC-ME-TYK" if village_id == "KC-TYK"

			
replace interview_id = "KW-OKK-11" if interview_id == "KK-OKK-11"
replace interview_id = "KW-HHHYT-2" if interview_id == "Kw-HHKYT-2"
replace interview_id = "KW-OKK-10" if interview_id == "KW-0KK-10"
replace interview_id = "KW-YK-9" if interview_id == "KY-YK-9"
replace interview_id = "KW-ONP-2" if interview_id == "KW-0NP-2"
replace interview_id = "KW-ONP-3" if interview_id == "KW-0NP-3"
replace interview_id = "KC-KW-8" if interview_id == "KC-KLW-8"
replace interview_id = "KC-KW-12" if interview_id == "KC-KLW-12"
replace interview_id = "KC-KW-5" if interview_id == "KC-KLW-5"
replace interview_id = "KC-KW-11" if interview_id == "KC-KLW-11"
replace interview_id = "KC-KW-10" if interview_id == "KC-KLW-10"
replace interview_id = "KC-KW-14" if interview_id == "KC-KLW-14"
replace interview_id = "KC-KW-6" if interview_id == "KC-KLW-6"
replace interview_id = "KC-KW-9" if interview_id == "KC-KLW-9"
replace interview_id = "KC-KW-7" if interview_id == "KC-KLW-7"
replace interview_id = "KC-KW-13" if interview_id == "KC-KLW-13"
replace interview_id = "KC-KW-4" if interview_id == "KC-KLW-4"
replace interview_id = "KC-KW-1" if interview_id == "KC-KLW-1"
replace interview_id = "KC-KW_3" if interview_id == "KC-KLW-3"
replace interview_id = "KC-KW-2" if interview_id == "KC-KLW-2"
replace interview_id = "YA-MNKD-2" if interview_id == "YA-MMKD-2"

distinct interview_id village_id vill_name vill_name_original

tab village_id, m 

// village id check 
gen village_id_c =  ustrregexra(interview_id, "([0-9])", "")
replace village_id_c = subinstr(village_id, "-", " ", .)

split village_id_c, p(" ")

replace village_id_c2 = village_id_c3 if mi(village_id_c2) & !mi(village_id_c3)
replace village_id_c3 = "" if village_id_c2 == village_id_c3

gen village_id_new_c = village_id_c1 + "-" + village_id_c2 if mi(village_id_c3)
replace village_id_new_c = village_id_c1 + "-" + village_id_c2 + "-" + village_id_c3 if !mi(village_id_c3)

order village_id_new_c, after(village_id)

replace village_id = strrtrim(village_id)

count if village_id_new_c != village_id // 0 - correct ID correction

gen org_name = village_id_c1
replace org_name = "KEHOC" if village_id_c1 == "KC"
replace org_name = "KDHW" if village_id_c1 == "KW"
replace org_name = "YSDA" if village_id_c1 == "YA"
tab org_name, m 

drop village_id_c1-village_id_c3

// husband_occup
rename husband_occup husband_edu_oth 

* Other Specify Translation Add *
foreach var of varlist	child_birth_wt child_ill_oth cough_notreat_why_oth cough_treat_place_2nd_oth ///
						cough_treat_place_oth diarrhea_notreat_why_oth diarrhea_treat_spent_oth ///
						dispose_faeces_oth fever_notreat_why_oth husband_edu_oth husband_occup_oth ///
						latrines_type_oth mom_anc_no_why_oth mom_anc_place_oth mom_anc_vit_oth ///
						mom_anc_vit_place_oth mom_cdtest_oth mom_covid_vaccine_when ///
						mom_delivery_place_oth mom_nut_counsel_who_oth mom_pnc_no_why_oth moveback_oth ///
						protein_source_oth resp_edu_oth rice_source_oth veg_source_oth ///
						water_soruce_oth water_treat_oth wempo_group_oth women_occup_oth {
	
	gen `var'_eng = `var'
	order `var'_eng, after(`var')
}

* Other specify english translation  * 
readreplace using "$raw/mother_other_specify_translated.xlsx", ///
			id("interview_id") variable("variable") value("correction") ///		
			excel import(firstrow sheet("eng_translate")) 

// svy_date 

// starttime endtime 
rename startime starttime
foreach var of varlist starttime endtime {
	gen `var'_tc = clock(`var', "hms#")
	order `var'_tc, after(`var')
	format `var'_tc %tcHH:MM
	drop `var'
	rename `var'_tc `var'
}

// enu_name 
tab enu_name, m 
distinct enu_name // 36 enumerators 

// supervisor_name 
tab supervisor_name, m 
distinct supervisor_name // 10 supervisor 


********************************************************************************
** A. Socio-demographic characteristics **
********************************************************************************
// resp_age 
tab resp_age, m 
lab var resp_age "Respondent age"
preserve
keep if resp_age > 45 & !mi(resp_age)
if _N > 0 {
	export 	excel $respinfo resp_age using "$out/mother_outlier.xlsx", ///
			sheet("resp_age") firstrow(varlabels) sheetreplace 
}
restore

// resp_edu 
tab resp_edu, m 

egen resp_edu_num = sieve(resp_edu), keep(numeric)
order resp_edu_num, after(resp_edu)
drop resp_edu
rename resp_edu_num resp_edu

tab resp_edu, m 
destring resp_edu, replace 

local num 1 2 3 4 5 6 777

foreach x in `num'{
	gen resp_edu_`x' = (resp_edu == `x')
	replace resp_edu_`x' = .m if mi(resp_edu) | resp_edu == 444
	order resp_edu_`x', before(resp_edu_oth)
	tab resp_edu_`x', m 
}

lab var resp_edu_1 "Primary school"
lab var resp_edu_2 "Secondary school"
lab var resp_edu_3 "High school"
lab var resp_edu_4 "Graduate from university/college"
lab var resp_edu_5 "Monastery school"
lab var resp_edu_6 "Never been to school"
lab var resp_edu_777 "Other education level"


// resp_edu_oth 
tab resp_edu_oth, m // translation need
preserve
keep if resp_edu_777 == 1
if _N > 0 {
	export 	excel $respinfo resp_edu_oth using "$out/mother_other_specify.xlsx", ///
			sheet("resp_edu_oth") firstrow(varlabels) sheetreplace 
}
restore
		
		
// women_occup 
tab women_occup, m 

drop women_occup_dup_1 women_occup_dup_2 women_occup_dup_3 women_occup_dup_4 ///
	 women_occup_dup_5 women_occup_dup_6 women_occup_dup_7 women_occup_dup_8 ///
	 women_occup_dup_999 women_occup_dup_777 
	 
// women_occup_1 women_occup_2 women_occup_3 women_occup_4 women_occup_5 women_occup_6 women_occup_7 women_occup_8 women_occup_777 

moss women_occup, match("([0-9]+)") regex

drop _pos*
sum _count

forval x = 1/`r(max)' {
	destring _match`x', replace
	rename _match`x' women_occup`x'
}

drop _count

local num 1 2 3 4 5 6 7 8 777  

foreach x in `num'{
	tab women_occup_`x'
	drop women_occup_`x'
	gen women_occup_`x' = (women_occup1 == `x' | women_occup2 == `x' | ///
						   women_occup3 == `x')
	replace women_occup_`x' = .n if mi(women_occup_`x')
	order women_occup_`x', before(women_occup_oth)
	tab women_occup_`x', m
}

gen women_occup_9 = (women_occup_oth_eng == "Dependent" | women_occup_oth_eng == "Housewife")
replace women_occup_9 = .m if mi(women_occup1) & mi(women_occup2) & mi(women_occup3)
order women_occup_9, before(women_occup_oth)
tab women_occup_9, m

replace women_occup_1 = 1 if women_occup_oth_eng == "Farming"
replace women_occup_4 = 1 if women_occup_oth_eng == "Baby sitting"

replace women_occup_777 = 0 if 	women_occup_oth_eng == "Farming" | women_occup_oth_eng == "Baby sitting" | ///
								women_occup_oth_eng == "Dependent" | women_occup_oth_eng == "Housewife"
														
lab var women_occup_1 "Agriculture"
lab var women_occup_2 "Fisheries"
lab var women_occup_3 "Weaving"
lab var women_occup_4 "Daily worker"
lab var women_occup_5 "Staff from private companies"
lab var women_occup_6 "Government staff"
lab var women_occup_7 "Own business"
lab var women_occup_8 "Jobless"
lab var women_occup_9 "Housewife/Dependent"
lab var women_occup_777 "Other type of occupation"

			
// women_occup_oth 
tab women_occup_oth, m // translation need
preserve
keep if women_occup_777 == 1
if _N > 0 {
	export 	excel $respinfo women_occup_oth using "$out/mother_other_specify.xlsx", ///
			sheet("women_occup_oth") firstrow(varlabels) sheetreplace 
}
restore

// resp_marital 
tab resp_marital, m 

egen resp_marital_num = sieve(resp_marital), keep(numeric)
order resp_marital_num, after(resp_marital)
drop resp_marital
rename resp_marital_num resp_marital

tab resp_marital, m 
destring resp_marital, replace 

local num 1 2 3 4 

foreach x in `num'{
	gen resp_marital_`x' = (resp_marital == `x')
	replace resp_marital_`x' = .m if mi(resp_marital) //| resp_marital == 444
	order resp_marital_`x', before(resp_marital)
	tab resp_marital_`x', m 
}

lab var resp_marital_1 "Married"
lab var resp_marital_2 "Divorced/Separated"
lab var resp_marital_3 "Widow"
lab var resp_marital_4 "Never married"
	
preserve
keep if resp_marital > 4 & resp_marital < 999
if _N > 0 {
	export 	excel $respinfo resp_marital using "$out/mother_logical_check.xlsx", ///
			sheet("resp_marital") firstrow(varlabels) sheetreplace 
}
restore	
		
// resp_married_age 
replace resp_married_age = .m if resp_marital == 4 | resp_married_age == 444
replace resp_married_age = .n if mi(resp_married_age)
tab resp_married_age, m 

lab var resp_married_age "Respondent age at married"

preserve
keep if resp_married_age > resp_age & !mi(resp_married_age)
if _N > 0 {
	export 	excel $respinfo resp_marital resp_married_age resp_age using "$out/mother_logical_check.xlsx", ///
			sheet("resp_married_age") firstrow(varlabels) sheetreplace 
}
restore	


// husband_edu 
tab husband_edu, m 

egen resp_edu_num = sieve(husband_edu), keep(numeric)
order resp_edu_num, after(husband_edu)
drop husband_edu
rename resp_edu_num husband_edu

tab husband_edu, m 
destring husband_edu, replace 
replace husband_edu = .m if resp_marital == 4 

local num 1 2 3 4 5 6 777

foreach x in `num'{
	gen husband_edu_`x' = (husband_edu == `x')
	replace husband_edu_`x' = .m if mi(husband_edu) | husband_edu == 444 | resp_marital == 4 
	order husband_edu_`x', before(husband_edu_oth)
	tab husband_edu_`x', m 
}

lab var husband_edu_1 "Primary school"
lab var husband_edu_2 "Secondary school"
lab var husband_edu_3 "High school"
lab var husband_edu_4 "Graduate from university/college"
lab var husband_edu_5 "Monastery school"
lab var husband_edu_6 "Never been to school"
lab var husband_edu_777 "Other education level"
				
// husband_occup 
tab husband_edu_oth, m 

preserve
keep if husband_edu_777 == 1
if _N > 0 {
	export 	excel $respinfo husband_edu_oth using "$out/mother_other_specify.xlsx", ///
			sheet("husband_edu_oth") firstrow(varlabels) sheetreplace 
}
restore

// husband_occup_dup_1
rename husband_occup_dup_1 husband_occup
tab husband_occup, m 

forvalues x = 2/9{
	local y = `x' - 1
	rename husband_occup_dup_`x' husband_occup_dup_`y'

}

drop husband_occup_dup_1 husband_occup_dup_2 husband_occup_dup_3 husband_occup_dup_4 ///
	 husband_occup_dup_5 husband_occup_dup_6 husband_occup_dup_7 husband_occup_dup_8 ///
	 husband_occup_dup_9 husband_occup_dup_444 husband_occup_dup_999 husband_occup_dup_777 

// husband_occup_1 husband_occup_2 husband_occup_3 husband_occup_4 husband_occup_5 husband_occup_6 husband_occup_7 husband_occup_8 husband_occup_777

moss husband_occup, match("([0-9]+)") regex

drop _pos*
sum _count

forval x = 1/`r(max)' {
	destring _match`x', replace
	rename _match`x' husband_occup`x'
}

drop _count

local num 1 2 3 4 5 6 7 8 777  

foreach x in `num'{
	tab husband_occup_`x'
	drop husband_occup_`x'
	gen husband_occup_`x' = (husband_occup1 == `x' | husband_occup2 == `x' | ///
						     husband_occup3 == `x')
	replace husband_occup_`x' = .n if mi(husband_occup_`x')
	replace husband_occup_`x' = .m if resp_marital == 4 
	order husband_occup_`x', before(husband_occup_oth)
	tab husband_occup_`x', m
}

replace husband_occup_1 = 1 if	husband_occup_oth_eng == "Farming" | ///
								husband_occup_oth_eng == "Farming and rubber tapping" | ///
								husband_occup_oth_eng == "Farming/soilder"

gen husband_occup_9 = (husband_occup_oth_eng == "Work abroad" | husband_occup_oth_eng == "Work at Thailand")
replace husband_occup_9 = .m if mi(husband_occup_8)
order husband_occup_9, before(husband_occup_oth)
tab husband_occup_9, m

replace husband_occup_777 = 0 if husband_occup_oth_eng == "Farming" | ///
								 husband_occup_oth_eng == "Farming and rubber tapping" | ///
								 husband_occup_oth_eng == "Farming/soilder" | ///
								 husband_occup_oth_eng == "Work abroad" | ///
								 husband_occup_oth_eng == "Work at Thailand"
								 
lab var husband_occup_1 "Agriculture"
lab var husband_occup_2 "Fisheries"
lab var husband_occup_3 "Weaving"
lab var husband_occup_4 "Daily worker"
lab var husband_occup_5 "Staff from private companies"
lab var husband_occup_6 "Government staff"
lab var husband_occup_7 "Own business"
lab var husband_occup_8 "Jobless"
lab var husband_occup_9 "Working at Thailand"
lab var husband_occup_777 "Other type of occupation"

// husband_occup_oth 
tab husband_occup_oth, m 

preserve
keep if husband_occup_777 == 1
if _N > 0 {
	export 	excel $respinfo husband_occup_oth using "$out/mother_other_specify.xlsx", ///
			sheet("husband_occup_oth") firstrow(varlabels) sheetreplace 
}
restore

// hh_head_sex 
tab hh_head_sex, m 

egen hh_head_sex_num = sieve(hh_head_sex), keep(numeric)
order hh_head_sex_num, after(hh_head_sex)
drop hh_head_sex
rename hh_head_sex_num hh_head_sex

tab hh_head_sex, m 
destring hh_head_sex, replace 

local num 1 2 3 

foreach x in `num'{
	gen hh_head_sex_`x' = (hh_head_sex == `x')
	replace hh_head_sex_`x' = .m if mi(hh_head_sex) | hh_head_sex == 444 
	order hh_head_sex_`x', before(hh_member_num)
	tab hh_head_sex_`x', m 
}

lab var hh_head_sex_1 "HH Head - Male"
lab var hh_head_sex_2 "HH Head - Female"
lab var hh_head_sex_3 "HH Head - Both"
			
********************************************************************************
** B. Household background **
********************************************************************************

// hh_member_num 
tab hh_member_num, m 
lab var hh_member_num "Number of HH members"

preserve
sum hh_member_num, d
keep if hh_member_num > `r(p95)' & !mi(hh_member_num)
if _N > 0 {
	export 	excel $respinfo hh_member_num using "$out/mother_outlier.xlsx", ///
			sheet("hh_member_num") firstrow(varlabels) sheetreplace 
}
restore

// hh_income 
tab hh_income, m 

split hh_income, p(".")
drop hh_income2
order hh_income1, after(hh_income)
drop hh_income
rename hh_income1 hh_income
destring hh_income, replace 

replace hh_income = .d if hh_income == 888
replace hh_income = .r if hh_income == 999 
tab hh_income, m 

local num 1 2 3 4 5 6 7 8 9 

foreach x in `num'{
	gen hh_income_`x' = (hh_income == `x')
	replace hh_income_`x' = .m if mi(hh_income) 
	order hh_income_`x', before(resp_income_compare)
	tab hh_income_`x', m 
}

lab var hh_income_1 "Less than Ks 25,000"
lab var hh_income_2 "Ks 25,000 – Ks 50,000"
lab var hh_income_3 "> Ks 50,000 – Ks 75,000"
lab var hh_income_4 "> Ks 75,000 – Ks 100,000"
lab var hh_income_5 "> Ks 100,000 – Ks 150,000"
lab var hh_income_6 "> Ks 150,000 – Ks 200,000"
lab var hh_income_7 "> Ks 200,000 – Ks 250,000"
lab var hh_income_8 "> Ks 250,000 – Ks 300,000"
lab var hh_income_9 "Over Ks 300,000 "

// resp_income_compare
tab resp_income_compare, m 

egen resp_income_compare_num = sieve(resp_income_compare), keep(numeric)
order resp_income_compare_num, after(resp_income_compare)
drop resp_income_compare
rename resp_income_compare_num resp_income_compare

tab resp_income_compare, m 
destring resp_income_compare, replace 

local num 1 2 3 4 

foreach x in `num'{
	gen resp_income_compare_`x' = (resp_income_compare == `x')
	replace resp_income_compare_`x' = .m if mi(resp_income_compare) | resp_income_compare == 444 
	replace resp_income_compare_`x' = .r if resp_income_compare == 999 
	order resp_income_compare_`x', before(hh_resident_status)
	tab resp_income_compare_`x', m 
}

lab var resp_income_compare_1 "More than him"
lab var resp_income_compare_2 "Less than him"
lab var resp_income_compare_3 "Equal"
lab var resp_income_compare_4 "Husband/partner does not bring in money"
				
// hh_resident_status 
tab hh_resident_status, m 

split hh_resident_status, p(".")
drop hh_resident_status2 hh_resident_status3 hh_resident_status4 hh_resident_status5
order hh_resident_status1, after(hh_resident_status)
drop hh_resident_status
rename hh_resident_status1 hh_resident_status
destring hh_resident_status, replace 

tab hh_resident_status, m 

local num 1 2 3 4 5 6 7 

foreach x in `num'{
	gen hh_resident_status_`x' = (hh_resident_status == `x')
	replace hh_resident_status_`x' = .m if mi(hh_resident_status)
	order hh_resident_status_`x', before(hh_resident_status)
	tab hh_resident_status_`x', m 
}

lab var hh_resident_status_1 "Permanent residents"
lab var hh_resident_status_2 "IDPs (in last 12 months)"
lab var hh_resident_status_3 "IDPs (1-5yrs)"
lab var hh_resident_status_4 "IDPs (5yrs +)"
lab var hh_resident_status_5 "Returnees (in last 12mths)"
lab var hh_resident_status_6 "Returnees (1-5yrs)"
lab var hh_resident_status_7 "Returnees (5yrs +)"
				
// moveback moveback_1 moveback_2 moveback_3 moveback_4 moveback_5 moveback_6 moveback_7 moveback_8 moveback_444 moveback_999 moveback_777 
tab moveback, m 

moss moveback, match("([0-9]+)") regex

drop _pos*
sum _count

forval x = 1/`r(max)' {
	destring _match`x', replace
	rename _match`x' moveback`x'
}

drop _count

local num 1 2 3 4 5 6 7 8 777  

foreach x in `num'{
	tab moveback_`x'
	drop moveback_`x'
	gen moveback_`x' = (moveback1 == `x' | moveback2 == `x')
	replace moveback_`x' = .m if hh_resident_status == 1 
	order moveback_`x', before(moveback_oth)
	tab moveback_`x', m
}

lab var moveback_1 "Work"
lab var moveback_2 "Education"
lab var moveback_3 "Family"
lab var moveback_4 "Marriage"
lab var moveback_5 "Improved security"
lab var moveback_6 "Land confiscated"
lab var moveback_7 "No reason"
lab var moveback_8 "Refugee return"
lab var moveback_777 "Other reasons" 

// moveback_oth 
tab moveback_oth, m 

preserve
keep if moveback_777 == 1
if _N > 0 {
	export 	excel $respinfo moveback_oth using "$out/mother_other_specify.xlsx", ///
			sheet("moveback_oth") firstrow(varlabels) sheetreplace 
}
restore


// house_ownership 
tab house_ownership, m 

egen house_ownership_num = sieve(house_ownership), keep(numeric)
order house_ownership_num, after(house_ownership)
drop house_ownership
rename house_ownership_num house_ownership

tab house_ownership, m 
destring house_ownership, replace 

local num 1 2 3 4 5 

foreach x in `num'{
	gen house_ownership_`x' = (house_ownership == `x')
	replace house_ownership_`x' = .m if mi(house_ownership) | house_ownership == 444 
	replace house_ownership_`x' = .r if house_ownership == 999 
	order house_ownership_`x', before(u5_num)
	tab house_ownership_`x', m 
}

lab var house_ownership_1 "Homeless"
lab var house_ownership_2 "Wife owns the house alone"
lab var house_ownership_3 "Husband owns the house alone"
lab var house_ownership_4 "Husband and wife jointly own the house"
lab var house_ownership_5 "Other relative owns the house"
	
********************************************************************************
** C. Information of under 5 children **
********************************************************************************

// u5_num 
tab u5_num, m 
count if hh_member_num < u5_num

// logic check 
preserve
keep if u5_num > 3 & !mi(u5_num)
if _N > 0 {
	export 	excel $respinfo u5_num u5_sex_* u5_rank_* u5_age_month_* u5_dob_* u5_muac_* u5_oedema_* ///
	using "$out/mother_logical_check.xlsx", sheet("u5_info") firstrow(varlabels) sheetreplace 
}
restore	

// outlier check
preserve
keep if u5_num > 3
if _N > 0 {
	export 	excel $respinfo u5_num using "$out/mother_outlier.xlsx", ///
			sheet("u5_num") firstrow(varlabels) sheetreplace 
}
restore

// u5_sex 
forvalue x = 1/3{
	
	tab u5_sex_`x', m 
	egen u5_sex_`x'_num = sieve(u5_sex_`x'), keep(numeric)
	order u5_sex_`x'_num, after(u5_sex_`x')
	drop u5_sex_`x'
	rename u5_sex_`x'_num u5_sex_`x'
	
	destring u5_sex_`x', replace 
	replace u5_sex_`x' = 0 if u5_sex_`x' == 2
	tab u5_sex_`x', m 
}

// u5_rank 
forvalue x = 1/3{
	
	tab u5_rank_`x', m  
}


// u5_age_month
forvalue x = 1/3{
	
	tab u5_age_month_`x', m  
}

// u5_dob_5 
forvalue x = 1/3{
	
	tab u5_dob_`x', m  
}

gen u5_dob_1_date = date(u5_dob_1, "MDY")
format %td u5_dob_1_date
order u5_dob_1_date, after(u5_dob_1)
drop u5_dob_1
rename u5_dob_1_date u5_dob_1

gen u5_dob_3_date = date(u5_dob_3, "DMY")
format %td u5_dob_3_date
order u5_dob_3_date, after(u5_dob_3)
drop u5_dob_3
rename u5_dob_3_date u5_dob_3

// u5_muac 
forvalue x = 1/3{
	
	tab u5_muac_`x', m  
}

// u5_oedema 
forvalue x = 1/3{
	
	tab u5_oedema_`x', m 
	egen u5_oedema_`x'_num = sieve(u5_oedema_`x'), keep(numeric)
	order u5_oedema_`x'_num, after(u5_oedema_`x')
	drop u5_oedema_`x'
	rename u5_oedema_`x'_num u5_oedema_`x'
	
	destring u5_oedema_`x', replace 
	replace u5_oedema_`x' = 0 if u5_oedema_`x' == 2
	tab u5_oedema_`x', m 
}

// eligable child check 
forvalue x = 1/3{
	gen cal_cage_`x' = round((svy_date - u5_dob_`x')/30.44,0.1)
	tab cal_cage_`x', m
	
	gen cal_u2_yes_`x' = (cal_cage_`x' < 24)
}

egen cal_u2_tot = rowtotal(cal_u2_yes_1 cal_u2_yes_2 cal_u2_yes_3)

tab cal_u2_tot, m 

// CHILD ANTHRO DATASET PREPARATION 
preserve

keep $respinfo u5_sex_* u5_rank_* u5_age_month_* u5_dob_* u5_muac_* u5_oedema_* cal_cage_*
//drop u5_sex_4-u5_oedema_5

reshape long u5_sex_ u5_rank_ u5_age_month_ u5_dob_ u5_muac_ u5_oedema_ cal_cage_, i(interview_id) j("child_sir")

rename *_ *
keep if !mi(u5_rank) //& !mi(u5_sex) & !mi(u5_age_month) & !mi(u5_dob) & !mi(u5_muac) & !mi(u5_oedema) & !mi(cal_cage)

order $respinfo u5_rank u5_sex u5_dob u5_age_month cal_cage u5_muac u5_oedema 

lab var u5_sex "Child sex (Male)"
lab var u5_rank "Child ranking in U5 list"
lab var u5_age_month "Reported child age - months"
lab var u5_dob "Child DOB"
lab var u5_muac "Child MUAC"
lab var u5_oedema "Child Oedema"
lab var cal_cage "Child age months - DOB calculated"

// MUAC Quality check 
tostring u5_muac, gen(u5_muac_str)
split u5_muac_str, p(".")

replace u5_muac_str2 = "0" if !mi(u5_muac_str1) & !mi(u5_muac_str) & mi(u5_muac_str2)
destring u5_muac_str2, replace
replace u5_muac_str2 = .m if mi(u5_muac)

drop u5_muac_str u5_muac_str1 
rename u5_muac_str2 u5_muac_decimalp

// outlier check 
export 	excel $respinfo u5_muac using "$out/mother_outlier.xlsx" if u5_muac == 3333, ///
		sheet("u5_muac") firstrow(varlabels) sheetreplace 
		
// logical check
export 	excel $respinfo u5_oedema using "$out/mother_logical_check.xlsx" if u5_oedema > 1 & !mi(u5_oedema), ///
		sheet("u5_oedema") firstrow(varlabels) sheetreplace 

replace u5_oedema = .m if u5_oedema == 3333

// child malnutrition 
gen child_gam = (u5_muac < 12.5 | u5_oedema == 1)
replace child_gam = .m if mi(u5_muac) & mi(u5_oedema) 
replace child_gam = .m if u5_age_month < 6 & u5_age_month >= 60
lab var child_gam "Acute Malnutrition (MUAC < 12.5 or Oedema)"
tab child_gam, m 

gen child_mam = (u5_muac >= 11.5 & u5_muac < 12.5)
replace child_mam = .m if mi(u5_muac)
replace child_mam = .m if u5_age_month < 6 & u5_age_month >= 60
lab var child_mam "Moderate Acute Malnutrition (11.5 >= MUAC <= 12.5)"
tab child_mam, m 

gen child_sam = (u5_muac < 11.5 | u5_oedema == 1)
replace child_sam = .m if mi(u5_muac) & mi(u5_oedema)
replace child_sam = .m if u5_age_month < 6 & u5_age_month >= 60
lab var child_sam "Moderate Acute Malnutrition (MUAC < 11.5 or Oedema)"
tab child_sam, m 

gen under_over_14m = (u5_age_month >= 14 & !mi(u5_age_month))
replace under_over_14m = .m if mi(u5_age_month) 
lab var under_over_14m "Under or Over 14 months"
lab def under_over_14m 1">= 14 months" 0"< 14 months"
lab val under_over_14m under_over_14m
tab under_over_14m, m 


foreach var of varlist child_gam {
	
	tab `var' under_over_14m
	forvalue x = 0/1{
		gen `var'_`x' = `var'
		replace `var'_`x' = .m if under_over_14m == `x'
		tab `var'_`x'
	}
}

save "$dta/child_anthro_cleaned.dta", replace 

bysort interview_id: keep if _n == 1
rename u5_age_month youngest_age_month
rename u5_sex youngest_age_sex
keep interview_id youngest_age_month youngest_age_sex under_over_14m

tempfile childage
save `childage', replace

restore	
 

****************************************************************************************
** D. Infant and young child feeding (IYCF) practices (For under 2-year-old children) **
****************************************************************************************
// d_note 
/*
odk response code 
1. ၂၄လနှင့်၂၄လအောက် သို့မဟုတ် ၂ နှစ်နှင့်၂နှစ်အောက် <=24months old or <=2 year old
2. ၂၄ လအထက် သို့မဟုတ် ၂နှစ်အထက်>24 months old or >2 year old
*/
tab d_note, m 

split d_note, p(".")
drop d_note2
order d_note1, after(d_note)
drop d_note
rename d_note1 d_note
destring d_note, replace 
replace d_note = 0 if d_note == 2 // treat over 2 yrs as 0
replace d_note = .n if mi(d_note)

tab d_note, m 

preserve
keep if cal_u2_tot != d_note & !mi(d_note)
if _N > 0 {
	export 	excel $respinfo svy_date u5_dob_1 cal_cage_1 u5_dob_2 cal_cage_2 u5_dob_3 cal_cage_3 ///
			cal_u2_tot d_note using "$out/mother_logical_check.xlsx", ///
			sheet("u2_number_error") firstrow(varlabels) sheetreplace 
}
restore	

// d_note_1 
tab d_note_1, m 
drop d_note_1

merge 1:1 interview_id using `childage'


// bf_immediate bf_fist2days bf_only_u6 cf_age_month d_note_2 liquid_water liquid_nonmilk liquid_bms liquid_ors cf_yesterday bf_bottle
local bfvar bf_immediate bf_fist2days bf_only_u6 d_note_2 liquid_water liquid_nonmilk liquid_bms liquid_ors cf_yesterday bf_bottle

foreach var in `bfvar'{
    tab `var', m 

	egen `var'_num = sieve(`var'), keep(numeric)
	order `var'_num, after(`var')
	drop `var'
	rename `var'_num `var'
	
	destring `var', replace 
	replace `var' = 0 if `var' == 2
	replace `var' = .n if mi(`var')
	replace `var' = .d if `var' == 888
	replace `var' = .r if `var' == 999
	replace `var' = .m if d_note != 1
	tab `var', m 
}

lab var bf_only_u6 "Exclusively breastfed under-6 months (self reported)"

// cf_age_month
tab cf_age_month, m 
replace cf_age_month = .n if cf_age_month == 666 | cf_age_month == 444 | mi(cf_age_month)
replace cf_age_month = .m if d_note != 1
replace cf_age_month = .d if cf_age_month == 888
replace cf_age_month = .r if cf_age_month == 999
tab cf_age_month, m 


// d_note_3 
/* 
Data issue note:
Inconsistant U2 identification between IYCF not matched with number of U2 children 
identified by DOB data
but use this d_note var for data cleaning as it was applied in the ODK programming as
relevant criteria for skip pattern

*** THIS PRACTICE SERIOUSLY EFFECT ONE IDENTIFICATION OF ELIGABLE OBS FOR INDICATOR CALCULATION ***
*/
/*
1. ၆ လနှင့် ၆ လအောက် <= 6 months old 
2. ၆ လ အထက် > 6 months old
*/
tab d_note_3, m 

split d_note_3, p(".")
drop d_note_32
order d_note_31, after(d_note_3)
drop d_note_3
rename d_note_31 d_note_3
destring d_note_3, replace 
replace d_note_3 = 0 if d_note_3 == 2 // treat over 6 months as 0

tab d_note_3, m 

// eligable child check 
forvalue x = 1/3{
	
	gen cal_u6month_yes_`x' = (cal_cage_`x' < 6)
}

egen cal_u6month_tot = rowtotal(cal_u6month_yes_1 cal_u6month_yes_2 cal_u6month_yes_3)

tab cal_u6month_tot, m 

preserve
keep if cal_u6month_tot != d_note_3 & !mi(d_note_3)
if _N > 0 {
	export 	excel $respinfo svy_date u5_dob_1 cal_cage_1 u5_dob_2 cal_cage_2 u5_dob_3 cal_cage_3 ///
			cal_u6month_tot d_note_3 using "$out/mother_logical_check.xlsx", ///
			sheet("u6_number_error") firstrow(varlabels) sheetreplace 
}
restore	

// bf_breastmilk cf_rice cf_pulses cf_milk cf_meat cf_eggs cf_veg_vit cf_veg_fruit_oth cf_sweet cf_snack cf_no_veg_fruit 
local cfvar bf_breastmilk cf_rice cf_pulses cf_milk cf_meat cf_eggs cf_veg_vit cf_veg_fruit_oth cf_sweet cf_snack cf_no_veg_fruit

foreach var in `cfvar'{
    tab `var', m 

	egen `var'_num = sieve(`var'), keep(numeric)
	order `var'_num, after(`var')
	drop `var'
	rename `var'_num `var'
	
	destring `var', replace 
	replace `var' = 0 if `var' == 2
	replace `var' = .n if mi(`var')
	replace `var' = .d if `var' == 888
	replace `var' = .r if `var' == 999
	replace `var' = .m if d_note != 1
	tab `var', m 
}

// bf_breastfeed_freq 
tab bf_breastfeed_freq, m 

replace bf_breastfeed_freq = .n if mi(bf_breastfeed_freq)
replace bf_breastfeed_freq = .m if bf_breastmilk != 1
replace bf_breastfeed_freq = .d if bf_breastfeed_freq == 888
replace bf_breastfeed_freq = .n if bf_breastfeed_freq == 444
replace bf_breastfeed_freq = .m if d_note != 1
tab bf_breastfeed_freq, m 

preserve
keep if bf_breastfeed_freq == 0 & bf_breastmilk == 1
if _N > 0 {
	export 	excel $respinfo bf_breastmilk bf_breastfeed_freq using "$out/mother_logical_check.xlsx", ///
			sheet("bf_breastfeed_freq") firstrow(varlabels) sheetreplace 
}
restore	

// bf_othmilk_freq 
tab bf_othmilk_freq, m 

replace bf_othmilk_freq = .n if mi(bf_othmilk_freq)
replace bf_othmilk_freq = .d if bf_othmilk_freq == 888
replace bf_othmilk_freq = .r if bf_othmilk_freq == 999
replace bf_othmilk_freq = .n if bf_othmilk_freq == 444
replace bf_othmilk_freq = .m if d_note != 1
tab bf_othmilk_freq, m 

// cf_soild_freq 
tab cf_soild_freq, m 

replace cf_soild_freq = .n if mi(cf_soild_freq)
replace cf_soild_freq = .d if cf_soild_freq == 888
replace cf_soild_freq = .r if cf_soild_freq == 999
replace cf_soild_freq = .n if cf_soild_freq == 444
replace cf_soild_freq = .m if d_note != 1
lab var cf_soild_freq "Child meal frequency"
tab cf_soild_freq, m 

// CALCULATION OF IYCF INDICATOR
// bf_immediate bf_fist2days bf_only_u6 cf_age_month d_note_2 liquid_water liquid_nonmilk liquid_bms liquid_ors cf_yesterday bf_bottle
// bf_breastmilk cf_rice cf_pulses cf_milk cf_meat cf_eggs cf_veg_vit cf_veg_fruit_oth cf_sweet cf_snack cf_no_veg_fruit 
// bf_breastfeed_freq bf_othmilk_freq cf_soild_freq

// EARLY INITIATION OF BREASTFEEDING (EIBF)
gen eibf = (bf_immediate == 1 & youngest_age_month < 24) 
replace eibf = .m if mi(bf_immediate) | mi(youngest_age_month)
lab var eibf "Early iinitiation of breasfeeding (EIBF)"
tab eibf, m 

// EXCLUSIVELY BREASTFED FOR THE FIRST TWO DAYS AFTER BIRTH (EBF2D)
gen ebf2d 		= (bf_fist2days == 1 & youngest_age_month < 24)
replace ebf2d 	= .m if mi(bf_fist2days) | mi(youngest_age_month)
lab var ebf2d "Exclusively breastfed for the first two days after birth (EBF2D)"
tab ebf2d, m 

// EXCLUSIVE BREASTFEEDING UNDER SIX MONTHS (EBF)
// strict rules 
egen liquid = rowtotal(liquid_water liquid_nonmilk liquid_bms), missing
replace liquid = .m if mi(liquid_water) | mi(liquid_nonmilk) | mi(liquid_bms)
tab liquid, m 

egen solid = rowtotal(cf_rice cf_pulses cf_milk cf_meat cf_eggs cf_veg_vit ///
					  cf_veg_fruit_oth cf_sweet cf_snack cf_no_veg_fruit), missing
replace solid = .m if mi(cf_rice) | mi(cf_pulses) | mi(cf_milk) | mi(cf_meat) | ///
					  mi(cf_eggs) | mi(cf_veg_vit) | mi(cf_veg_fruit_oth) | ///
					  mi(cf_sweet) | mi(cf_snack) | mi(cf_no_veg_fruit)
tab solid, m 

gen ebf = (bf_breastmilk == 1 & solid == 0 & liquid == 0 & youngest_age_month < 6)
replace ebf = .m if mi(bf_breastmilk) | mi(solid) | mi(liquid) | mi(youngest_age_month)
replace ebf = .m if youngest_age_month >= 6 
lab var ebf "Exclusive breastfeeding under six months (EBF)"
tab ebf, m 

// treated missing as 0 
egen liquid_l = rowtotal(liquid_water liquid_nonmilk liquid_bms), missing
replace liquid_l = .m if mi(liquid_water) & mi(liquid_nonmilk) & mi(liquid_bms)
tab liquid_l, m 

egen solid_l = rowtotal(cf_rice cf_pulses cf_milk cf_meat cf_eggs cf_veg_vit ///
					  cf_veg_fruit_oth cf_sweet cf_snack cf_no_veg_fruit), missing
replace solid_l = .m if mi(cf_rice) & mi(cf_pulses) & mi(cf_milk) & mi(cf_meat) & ///
					  mi(cf_eggs) & mi(cf_veg_vit) & mi(cf_veg_fruit_oth) & ///
					  mi(cf_sweet) & mi(cf_snack) & mi(cf_no_veg_fruit)
tab solid_l, m 

gen ebf_l = (bf_breastmilk == 1 & solid_l == 0 & liquid_l == 0 & youngest_age_month < 6)
replace ebf_l = .m if mi(bf_breastmilk) | mi(solid_l) | mi(liquid_l) | mi(youngest_age_month)
replace ebf_l = .m if youngest_age_month >= 6 
lab var ebf_l "Exclusive breastfeeding under six months (EBF)"
tab ebf_l, m 


// Predominant breastfeeding (< 6 months)
// strict rules 
egen non_water_liquid = rowtotal(liquid_nonmilk liquid_bms), missing
replace non_water_liquid = .m if mi(liquid_nonmilk) | mi(liquid_bms)
tab non_water_liquid, m 

gen pre_bf = (bf_breastmilk == 1 & solid == 0 & non_water_liquid == 0 & youngest_age_month < 6)
replace pre_bf = .m if mi(bf_breastmilk) | mi(solid) | mi(non_water_liquid) | mi(youngest_age_month)
replace pre_bf = .m if youngest_age_month >= 6 
lab var pre_bf "Predominant breastfeeding under six months (EBF)"
tab pre_bf, m 

// treat missing as 0 
egen non_water_liquid_l = rowtotal(liquid_nonmilk liquid_bms), missing
replace non_water_liquid_l = .m if mi(liquid_nonmilk) & mi(liquid_bms)
tab non_water_liquid_l, m 

gen pre_bf_l = (bf_breastmilk == 1 & solid == 0 & non_water_liquid_l == 0 & youngest_age_month < 6)
replace pre_bf_l = .m if mi(bf_breastmilk) | mi(solid) | mi(non_water_liquid_l) | mi(youngest_age_month)
replace pre_bf_l = .m if youngest_age_month >= 6 
lab var pre_bf_l "Predominant breastfeeding under six months (EBF)"
tab pre_bf_l, m 

// MIXED MILK FEEDING UNDER SIX MONTHS (MixMF)
// technical note: not include all category of milk food recall as WHO questionniares 
gen mixmf 		= (youngest_age_month < 6 & bf_othmilk_freq > 0 & bf_breastmilk == 1)
replace mixmf 	= .m if mi(youngest_age_month) | mi(bf_othmilk_freq)  | mi(bf_breastmilk)
replace mixmf = .m if youngest_age_month >= 6 
lab var mixmf "Mixed milk feeding under 6 months"
tab mixmf, m

// BOTTLE FEEDING 0–23 MONTHS (BoF)
gen bof 	= (youngest_age_month < 24 & bf_bottle == 1)
replace bof = .m if mi(youngest_age_month) | mi(bf_bottle)
lab var bof "Bottle feeding 0-23 months"
tab bof, m 

// CONTINUED BREASTFEEDING 12–23 MONTHS (CBF)
gen cbf 	= (youngest_age_month >= 12 & youngest_age_month < 24 & bf_breastmilk == 1)
replace cbf = .m if mi(youngest_age_month) | mi(youngest_age_month) | mi(bf_breastmilk) 
replace cbf = .m if youngest_age_month < 12 
replace cbf = .m if youngest_age_month >= 24
lab var cbf "Continious breastfeeding 12-23 months"
tab cbf, m

// INTRODUCTION OF SOLID, SEMI-SOLID OR SOFT FOODS 6–8 MONTHS (ISSSF)
gen isssf 		= (youngest_age_month >= 6 & youngest_age_month < 9 & solid >=  1)
replace isssf 	= .m if mi(youngest_age_month) | mi(youngest_age_month) | mi(solid)
replace isssf = .m if youngest_age_month < 6 
replace isssf = .m if youngest_age_month >= 9
lab var isssf "Introduction of solid, semi-solid or soft foods 6-8 months"
tab isssf, m 

// MINIMUM DIETARY DIVERSITY 6–23 MONTHS (MDD)
// strict rules 
egen dietary_tot = rowtotal(bf_breastmilk cf_rice cf_pulses cf_milk cf_meat ///
							cf_eggs cf_veg_vit cf_veg_fruit_oth), missing
replace dietary_tot = .m if mi(bf_breastmilk) | mi(cf_rice) | mi(cf_pulses) | ///
							mi(cf_milk) | mi(cf_meat) | mi(cf_eggs) | ///
							mi(cf_veg_vit) | mi(cf_veg_fruit_oth) & ///
							(youngest_age_month >= 6 & youngest_age_month < 24)
replace dietary_tot = .m if mi(youngest_age_month)
replace dietary_tot = .m if youngest_age_month < 6 
replace dietary_tot = .m if youngest_age_month >= 24
lab var dietary_tot "Food group score"
tab dietary_tot, m 

gen mdd = (dietary_tot >= 5 & !mi(dietary_tot) & youngest_age_month >= 6 & youngest_age_month < 24)
replace mdd = .m if mi(dietary_tot) | mi(youngest_age_month)
replace mdd = .m if youngest_age_month < 6 
replace mdd = .m if youngest_age_month >= 24
lab var mdd "Minimum Dietary Diversity"
tab mdd, m

// treated missing as 0 
egen dietary_tot_l = rowtotal(bf_breastmilk cf_rice cf_pulses cf_milk cf_meat ///
							cf_eggs cf_veg_vit cf_veg_fruit_oth), missing
replace dietary_tot_l = .m if mi(bf_breastmilk) | mi(cf_rice) | mi(cf_pulses) | ///
							mi(cf_milk) | mi(cf_meat) | mi(cf_eggs) | ///
							mi(cf_veg_vit) | mi(cf_veg_fruit_oth) & ///
							(youngest_age_month >= 6 & youngest_age_month < 24)
replace dietary_tot_l = .m if mi(youngest_age_month)
replace dietary_tot_l = .m if youngest_age_month < 6 
replace dietary_tot_l = .m if youngest_age_month >= 24
lab var dietary_tot_l "Food group score"
tab dietary_tot_l, m 

gen mdd_l = (dietary_tot_l >= 5 & !mi(dietary_tot_l) & youngest_age_month >= 6 & youngest_age_month < 24)
replace mdd_l = .m if mi(dietary_tot_l) | mi(youngest_age_month)
replace mdd_l = .m if youngest_age_month < 6 
replace mdd_l = .m if youngest_age_month >= 24
lab var mdd_l "Minimum Dietary Diversity"
tab mdd_l, m

// lab var bf_breastmilk cf_rice cf_pulses cf_milk cf_meat cf_eggs cf_veg_vit cf_veg_fruit_oth

// MINIMUM MEAL FREQUENCY 6–23 MONTHS (MMF)
// technical note: not include all category of milk food recall as WHO questionniares 
// 6-8 breastfed child
gen mmf_bf_6to8 		= (youngest_age_month >= 6 & youngest_age_month < 9 & bf_breastmilk == 1 & cf_soild_freq >= 2)
replace mmf_bf_6to8 	= .m if mi(youngest_age_month) |mi(bf_breastmilk) | mi(cf_soild_freq)
replace mmf_bf_6to8 = .m if youngest_age_month < 6 
replace mmf_bf_6to8 = .m if youngest_age_month >= 9
replace mmf_bf_6to8 = .m if bf_breastmilk == 0
lab var mmf_bf_6to8 "Breastfeeding MMF - 6 to 8 months"
tab mmf_bf_6to8, m 

// 9-23 breastfed child
gen mmf_bf_9to23 		= (youngest_age_month >= 9 & youngest_age_month < 24 & bf_breastmilk == 1 & cf_soild_freq >= 3)
replace mmf_bf_9to23 	= .m if mi(youngest_age_month) |mi(bf_breastmilk) | mi(cf_soild_freq)
replace mmf_bf_9to23 = .m if youngest_age_month < 9 
replace mmf_bf_9to23 = .m if youngest_age_month >= 24
replace mmf_bf_9to23 = .m if bf_breastmilk == 0
lab var mmf_bf_9to23 "Breastfeeding MMF - 9 to 23 months"
tab mmf_bf_9to23, m 

gen mmf_bf 		= (mmf_bf_9to23 == 1 |  mmf_bf_6to8 == 1)
replace mmf_bf 	= .m if mi(mmf_bf_9to23) & mi(mmf_bf_6to8)
lab var mmf_bf "Breastfeeding MMF"
tab mmf_bf, m 

// non-breastfeed 6-23 months
// strict rules 
egen milk_food_freq 	= rowtotal(bf_othmilk_freq cf_soild_freq)
replace milk_food_freq 	= .m if mi(bf_othmilk_freq) | mi(cf_soild_freq)
tab milk_food_freq, m 

gen mmf_nonbf 		= (	youngest_age_month >= 6 & youngest_age_month < 24 & ///
						bf_breastmilk == 0 & milk_food_freq >= 4 & cf_soild_freq >= 1)
replace mmf_nonbf 	= .m if mi(youngest_age_month) | mi(bf_breastmilk) | mi(milk_food_freq) | mi(cf_soild_freq)
replace mmf_nonbf = .m if youngest_age_month < 6 
replace mmf_nonbf = .m if youngest_age_month >= 24
replace mmf_nonbf = .m if bf_breastmilk == 1
lab var mmf_nonbf "Non-Breastfeeding MMF"
tab mmf_nonbf, m 

gen mmf 	= (mmf_nonbf == 1 | mmf_bf == 1)
replace mmf = .m if mi(mmf_nonbf) & mi(mmf_bf)
lab var mmf "Minimum Meal Frequency"
tab mmf, m 

// treat missing as 0 
egen milk_food_freq_l 	= rowtotal(bf_othmilk_freq cf_soild_freq)
replace milk_food_freq_l 	= .m if mi(bf_othmilk_freq) & mi(cf_soild_freq)
tab milk_food_freq_l, m 

gen mmf_nonbf_l 		= (	youngest_age_month >= 6 & youngest_age_month < 24 & ///
						bf_breastmilk == 0 & milk_food_freq_l >= 4 & cf_soild_freq >= 1)
replace mmf_nonbf_l 	= .m if mi(youngest_age_month) | mi(bf_breastmilk) | mi(milk_food_freq_l) | mi(cf_soild_freq)
replace mmf_nonbf_l = .m if youngest_age_month < 6 
replace mmf_nonbf_l = .m if youngest_age_month >= 24
replace mmf_nonbf_l = .m if bf_breastmilk == 1
lab var mmf_nonbf_l "Non-Breastfeeding MMF"
tab mmf_nonbf_l, m 

gen mmf_l 	= (mmf_nonbf_l == 1 | mmf_bf == 1)
replace mmf_l = .m if mi(mmf_nonbf_l) & mi(mmf_bf)
lab var mmf_l "Minimum Meal Frequency"
tab mmf_l, m 

// MINIMUM MILK FEEDING FREQUENCY FOR NON-BREASTFED CHILDREN 6–23 MONTHS (MMFF)
// technical note: not include all category of milk food recall as WHO questionniares 
gen mmff 		= (youngest_age_month >= 6 & youngest_age_month < 24 & bf_breastmilk == 0 & bf_othmilk_freq >= 2)
replace mmff 	= .m if mi(youngest_age_month) | mi(bf_breastmilk) | mi(bf_othmilk_freq)
replace mmff = .m if youngest_age_month < 6 
replace mmff = .m if youngest_age_month >= 24
replace mmff = .m if bf_breastmilk == 1
lab var mmff "Minimum milk feeding frequency for non-breastfed children"
tab mmff, m 

// MINIMUM ACCEPTABLE DIET 6–23 MONTHS (MAD)
// strict rules 
gen mad 	= (youngest_age_month >= 6 & youngest_age_month < 24 & mdd == 1 & mmf == 1 & (mmff == 1 | bf_breastmilk == 1))
replace mad = .m if mi(youngest_age_month) | mi(mdd) | mi(mmf) | (mi(mmff) & mi(bf_breastmilk))
replace mad = .m if youngest_age_month < 6 
replace mad = .m if youngest_age_month >= 24
lab var mad "Minimum Acceptable Diet"
tab mad, m 

// treated missing as zero in food groups
gen mad_l 	= (youngest_age_month >= 6 & youngest_age_month < 24 & mdd_l == 1 & mmf_l == 1 & (mmff == 1 | bf_breastmilk == 1))
replace mad_l = .m if mi(youngest_age_month) | mi(mdd_l) | mi(mmf_l) | (mi(mmff) & mi(bf_breastmilk))
replace mad_l = .m if youngest_age_month < 6 
replace mad_l = .m if youngest_age_month >= 24
lab var mad_l "Minimum Acceptable Diet"
tab mad_l, m 

foreach var of varlist mdd mmf mad {
	
	tab `var' under_over_14m
	forvalue x = 0/1{
		gen `var'_`x' = `var'
		replace `var'_`x' = .m if under_over_14m == `x'
		tab `var'_`x'
	}
}


********************************************************************************
** E (i) Child illness: **
********************************************************************************
// child_ill_module 
tab child_ill_module, m 
drop child_ill_module

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
lab var diarrhea_notreat_why_15 "Family doesn’t allow"
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
lab var cough_notreat_why_15 "Family doesn’t allow"
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
lab var fever_notreat_why_15 "Family doesn’t allow"
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


// vit_a_yes 
tab vit_a_yes, m 

split vit_a_yes, p(".")
drop vit_a_yes2
order vit_a_yes1, after(vit_a_yes)
drop vit_a_yes
rename vit_a_yes1 vit_a_yes
destring vit_a_yes, replace 
replace vit_a_yes = .n if mi(vit_a_yes)
replace vit_a_yes = .m if e_note != 1
replace vit_a_yes = .d if vit_a_yes == 888
lab var vit_a_yes "Vit-A supplementation"
tab vit_a_yes, m 

// deworming_yes 
tab deworming_yes, m

split deworming_yes, p(".")
drop deworming_yes2
order deworming_yes1, after(deworming_yes)
drop deworming_yes
rename deworming_yes1 deworming_yes
destring deworming_yes, replace 
replace deworming_yes = .n if mi(deworming_yes)
replace deworming_yes = .m if e_note != 1
replace deworming_yes = .d if deworming_yes == 888
lab var deworming_yes "Deworming"
tab deworming_yes, m 

// child_birth_wt_yes 
tab child_birth_wt_yes, m 

split child_birth_wt_yes, p(".")
drop child_birth_wt_yes2
order child_birth_wt_yes1, after(child_birth_wt_yes)
drop child_birth_wt_yes
rename child_birth_wt_yes1 child_birth_wt_yes
destring child_birth_wt_yes, replace 
replace child_birth_wt_yes = .n if mi(child_birth_wt_yes)
replace child_birth_wt_yes = .m if e_note != 1
replace child_birth_wt_yes = .d if child_birth_wt_yes == 888
lab var child_birth_wt_yes "Know child birth-weight"
tab child_birth_wt_yes, m 

// child_birth_wt
tab child_birth_wt, m

preserve
keep if !mi(child_birth_wt)
if _N > 0 {
	export 	excel $respinfo child_birth_wt using "$out/mother_other_specify.xlsx", ///
			sheet("child_birth_wt") firstrow(varlabels) sheetreplace 
}
restore


********************************************************************************
** F. Mother’s dietary diversity ** 
********************************************************************************

// mom_rice mom_rice_freq mom_roots mom_roots_freq mom_pulses mom_pulses_freq mom_nut mom_nut_freq mom_milk mom_milk_freq mom_organ mom_organ_freq mom_meat mom_meat_freq mom_fish mom_fish_freq moom_egg moom_egg_freq mom_green_veg mom_green_veg_freq mom_vit_veg mom_vit_veg_freq mom_vit_fruit mom_vit_fruit_freq mom_oth_veg mom_oth_veg_freq mom_oth_fruit mom_oth_fruit_freq mom_insects mom_insects_freq mom_oil_veg mom_oil_veg_freq mom_oil_animal mom_oil_animal_freq mom_snacks mom_snacks_freq mom_sweet mom_sweet_freq mom_beverages mom_beverages_freq mom_condiments mom_condiments_freq mom_oth_food mom_oth_food_freq 

rename moom_egg mom_egg 
rename moom_egg_freq mom_egg_freq

local foods rice roots pulses nut milk organ meat fish egg green_veg vit_veg ///
			vit_fruit oth_veg oth_fruit insects oil_veg oil_animal snacks sweet ///
			beverages condiments oth_food

foreach var in `foods'{
    // yes - no
	di "mom_`var'"
    tab mom_`var', m 
    split mom_`var', p(".")
	drop mom_`var'2
	order mom_`var'1, after(mom_`var')
	drop mom_`var'
	rename mom_`var'1 mom_`var'
	destring mom_`var', replace 
	replace mom_`var' = .n if mi(mom_`var')
	replace mom_`var' = .d if mom_`var' == 888
	replace mom_`var' = .r if mom_`var' == 999
	replace mom_`var' = 0 if mom_`var' == 2
	tab mom_`var', m 
	
	// frequency 
	di "mom_`var'_freq"
	capture confirm numeric variable mom_`var'_freq // check for variable type
	if !_rc {
	    di "mom_`var'_freq numeric"

		tab mom_`var'_freq, m 
		replace mom_`var'_freq = .n if mi(mom_`var'_freq)
		replace mom_`var'_freq = .m if mom_`var' != 1
		tab mom_`var', m 
	}
	else {
	    di "mom_`var'_freq not numeric"

		tab mom_`var'_freq, m 
		split mom_`var'_freq, p(".")
		drop mom_`var'_freq2
		order mom_`var'_freq1, after(mom_`var'_freq)
		drop mom_`var'_freq
		rename mom_`var'_freq1 mom_`var'_freq
		destring mom_`var'_freq, replace 
		replace mom_`var'_freq = .n if mi(mom_`var'_freq)
		replace mom_`var'_freq = .m if mom_`var' != 1
		tab mom_`var'_freq, m 
	
	}
	// outlier check 
	preserve
	keep if mom_`var'_freq > 3 & !mi(mom_`var'_freq)
	if _N > 0 {
		export 	excel $respinfo mom_`var' mom_`var'_freq using "$out/mother_outlier.xlsx", ///
				sheet("mom_`var'_freq") firstrow(varlabels) sheetreplace 
	}

	restore 
}

lab var mom_rice "Grains"
lab var mom_rice_freq "Grains frequency" 
lab var mom_roots "Roots and tubers"
lab var mom_roots_freq "Roots and tubers frequency" 
lab var mom_pulses "Pulses"
lab var mom_pulses_freq "Pulses frequency" 
lab var mom_nut "Nuts and seeds"
lab var mom_nut_freq "Nuts and seeds frequency" 
lab var mom_milk " Milk and milk products"
lab var mom_milk_freq " Milk and milk products frequency" 
lab var mom_organ "Organ meat"
lab var mom_organ_freq "Organ meat  frequency" 
lab var mom_meat " Meat and poultry"
lab var mom_meat_freq " Meat and poultry frequency" 
lab var mom_fish "Fish and seafood"
lab var mom_fish_freq "Fish and seafood frequency" 
lab var mom_egg "Eggs"
lab var mom_egg_freq "Eggs frequency" 
lab var mom_green_veg "Dark green leafy vegetables"
lab var mom_green_veg_freq "Dark green leafy vegetables frequency"
lab var mom_vit_veg "Vitamin A-rich vegetables"
lab var mom_vit_veg_freq "Vitamin A-rich vegetables frequency"
lab var mom_vit_fruit "Vitamin A-rich fruits"
lab var mom_vit_fruit_freq "Vitamin A-rich fruits frequency"
lab var mom_oth_veg "Other vegetables"
lab var mom_oth_veg_freq "Other vegetables frequency" 
lab var mom_oth_fruit "Other fruits"
lab var mom_oth_fruit_freq "Other fruits frequency"
lab var mom_insects "Insects and other small protein foods"
lab var mom_insects_freq "Insects and other small protein foods frequency"
lab var mom_oil_veg "Red palm oil"
lab var mom_oil_veg_freq "Red palm oil frequency"
lab var mom_oil_animal "Other oils and fats"
lab var mom_oil_animal_freq "Other oils and fats frequency"
lab var mom_snacks "Savoury and fried snacks"
lab var mom_snacks_freq "Savoury and fried snacks frequency"
lab var mom_sweet "Sweets"
lab var mom_sweet_freq "Sweets frequency"
lab var mom_beverages "Sugar-sweetened beverages"
lab var mom_beverages_freq "Sugar-sweetened beverages frequency"
lab var mom_condiments "Condiments and seasonings"
lab var mom_condiments_freq "Condiments and seasonings frequency"
lab var mom_oth_food "Other type of food"
lab var mom_oth_food_freq "Other type of food frequency"

// CALCULATION MINIMUM DIETARY DIVERSITY FOR WOMEN
gen mddw_grain = (mom_rice == 1 | mom_roots == 1)
replace mddw_grain = .m if mi(mom_rice == 1) | mi(mom_roots == 1)
tab mddw_grain, m 

gen mddw_pulses = mom_pulses

gen mddw_nut = mom_nut

gen mddw_milk = mom_milk

gen mddw_meat = (mom_organ == 1 | mom_meat == 1 | mom_fish == 1 | mom_insects == 1)
replace mddw_meat = .m if mi(mom_organ) | mi(mom_meat) | mi(mom_fish) | mi(mom_insects)
tab mddw_meat, m 

gen mddw_moom_egg = mom_egg

gen mddw_green_veg = mom_green_veg  
		  
gen mddw_vit_vegfruit = (mom_vit_veg == 1 | mom_vit_fruit == 1)		  
replace mddw_vit_vegfruit = .m if mi(mom_vit_veg) | mi(mom_vit_fruit )
tab mddw_vit_vegfruit, m
	  
gen mddw_oth_veg = mom_oth_veg  

gen mddw_oth_fruit = mom_oth_fruit  

// strict rules 
egen mddw_score = rowtotal(	mddw_grain mddw_pulses mddw_nut mddw_milk mddw_meat ///
							mddw_moom_egg mddw_green_veg mddw_vit_vegfruit ///
							mddw_oth_veg mddw_oth_fruit), missing
replace mddw_score = .m if 	mi(mddw_grain) | mi(mddw_pulses) | mi(mddw_nut) | ///
							mi(mddw_milk) | mi(mddw_meat) | mi(mddw_moom_egg) | ///
							mi(mddw_green_veg) | mi(mddw_vit_vegfruit) | ///
							mi(mddw_oth_veg) | mi(mddw_oth_fruit)
tab mddw_score, m 

gen mddw_yes = (mddw_score >= 5 & !mi(mddw_score))
replace mddw_yes = .m if mi(mddw_score)
tab mddw_yes, m 

// treat missing as 0 
egen mddw_score_l = rowtotal(mddw_grain mddw_pulses mddw_nut mddw_milk mddw_meat ///
							mddw_moom_egg mddw_green_veg mddw_vit_vegfruit ///
							mddw_oth_veg mddw_oth_fruit), missing
replace mddw_score_l = .m if 	mi(mddw_grain) & mi(mddw_pulses) & mi(mddw_nut) | ///
							mi(mddw_milk) & mi(mddw_meat) & mi(mddw_moom_egg) | ///
							mi(mddw_green_veg) & mi(mddw_vit_vegfruit) | ///
							mi(mddw_oth_veg) & mi(mddw_oth_fruit)
tab mddw_score_l, m 

gen mddw_yes_l = (mddw_score_l >= 5 & !mi(mddw_score_l))
replace mddw_yes_l = .m if mi(mddw_score_l)
tab mddw_yes_l, m 


lab var mddw_grain "Grains, roots, and tubers"
lab var mddw_pulses "Pulses"
lab var mddw_nut "Nuts and seeds"
lab var mddw_milk "Dairy"
lab var mddw_meat "Meat, poultry, and fish"
lab var mddw_moom_egg "Eggs"
lab var mddw_green_veg "Dark leafy greens and vegetables"
lab var mddw_vit_vegfruit "Other Vitamin A-rich fruits and vegetables"
lab var mddw_oth_veg "Other vegetables"
lab var mddw_oth_fruit "Other fruits"					
lab var mddw_score "MDD-W Score"
lab var mddw_yes "MDD-W yes"

// rice_source rice_source_1 rice_source_2 rice_source_3 rice_source_4 rice_source_5 rice_source_999 rice_source_777  
tab rice_source, m 
moss rice_source, match("([0-9]+)") regex

drop _pos*
sum _count

forval x = 1/`r(max)' {
	destring _match`x', replace
	rename _match`x' rice_source`x'
}

drop _count

local num 1 2 3 4 5 777  

foreach x in `num'{
	tab rice_source_`x', m 
	drop rice_source_`x'
	gen rice_source_`x' = (rice_source1 == `x' | ///
						   rice_source2 == `x' | ///
						   rice_source3 == `x')
	replace rice_source_`x' = .r if rice_source1 == 999 | ///
								    rice_source2 == 999 | ///
								    rice_source3 == 999
	replace rice_source_`x' = .m if mi(rice_source)
	order rice_source_`x', before(rice_source_oth)
	tab rice_source_`x', m
}

replace rice_source_3 = 1 if	rice_source_oth_eng == "Bought in the village" | ///
								rice_source_oth_eng == "Bought from those who cultivates it."


replace rice_source_777 = 0 if	rice_source_oth_eng == "Bought in the village" | ///
								rice_source_oth_eng == "Bought from those who cultivates it."
							
lab var rice_source_1 "Own farm"
lab var rice_source_2 "Food aid"
lab var rice_source_3 "Purchase from market"
lab var rice_source_4 "Food loans"
lab var rice_source_5 "Foraging"
lab var rice_source_777 "Other type of sources"

// rice_source_oth
tab rice_source_oth, m 

preserve
keep if rice_source_777 == 1
if _N > 0 {
	export 	excel $respinfo rice_source_oth using "$out/mother_other_specify.xlsx", ///
			sheet("rice_source_oth") firstrow(varlabels) sheetreplace 
}
restore


// protein_source protein_source_1 protein_source_2 protein_source_3 protein_source_4 protein_source_5 protein_source_999 protein_source_777 
tab protein_source, m 
moss protein_source, match("([0-9]+)") regex

drop _pos*
sum _count

forval x = 1/`r(max)' {
	destring _match`x', replace
	rename _match`x' protein_source`x'
}

drop _count

local num 1 2 3 4 5 777  

foreach x in `num'{
	tab protein_source_`x', m 
	drop protein_source_`x'
	gen protein_source_`x' = (protein_source1 == `x' | ///
							  protein_source2 == `x' | ///
							  protein_source3 == `x' | ///
							  protein_source4 == `x')
	replace protein_source_`x' = .r if protein_source1 == 999 | ///
									   protein_source2 == 999 | ///
									   protein_source3 == 999 | ///
									   protein_source4 == 999
	replace protein_source_`x' = .m if mi(protein_source)
	order protein_source_`x', before(protein_source_oth)
	tab protein_source_`x', m
}

replace protein_source_1 = 1 if protein_source_oth_eng == "Livestock" | ///
								protein_source_oth_eng == "Livestock-chicken"

replace protein_source_3 = 1 if protein_source_oth_eng == "Village shop" | ///
								protein_source_oth_eng == "Mobile market" | ///
								protein_source_oth_eng == "Shop in the village" | ///
								protein_source_oth_eng == "Bought in the village" | ///
								protein_source_oth_eng == "Bought from those selling in the village." | ///
								protein_source_oth_eng == "Shop" | ///
								protein_source_oth_eng == "Bought from the village chicken farm." | ///
								protein_source_oth_eng == "The seller sells in the village." | ///
								protein_source_oth_eng == "Bought from the village market"| ///
								protein_source_oth_eng == "Village shop and the seller sells in the village."


replace protein_source_777 = 0 if	protein_source_oth_eng == "Livestock" | ///
									protein_source_oth_eng == "Livestock-chicken" | ///
									protein_source_oth_eng == "Village shop" | ///
									protein_source_oth_eng == "Mobile market" | ///
									protein_source_oth_eng == "Shop in the village" | ///
									protein_source_oth_eng == "Bought in the village" | ///
									protein_source_oth_eng == "Bought from those selling in the village." | ///
									protein_source_oth_eng == "Shop" | ///
									protein_source_oth_eng == "Bought from the village chicken farm." | ///
									protein_source_oth_eng == "The seller sells in the village." | ///
									protein_source_oth_eng == "Bought from the village market"| ///
									protein_source_oth_eng == "Village shop and the seller sells in the village."

lab var protein_source_1 "Own farm"
lab var protein_source_2 "Food aid"
lab var protein_source_3 "Purchase from market"
lab var protein_source_4 "Food loans"
lab var protein_source_5 "Foraging"
lab var protein_source_777 "Other type of sources"

// protein_source_oth
tab protein_source_oth, m 
 
preserve
keep if protein_source_777 == 1
if _N > 0 {
	export 	excel $respinfo protein_source_oth using "$out/mother_other_specify.xlsx", ///
			sheet("protein_source_oth") firstrow(varlabels) sheetreplace 
}
restore

// veg_source veg_source_1 veg_source_2 veg_source_3 veg_source_4 veg_source_5 veg_source_999 veg_source_777 
tab veg_source, m 
moss veg_source, match("([0-9]+)") regex

drop _pos*
sum _count

forval x = 1/`r(max)' {
	destring _match`x', replace
	rename _match`x' veg_source`x'
}

drop _count

local num 1 2 3 4 5 777  

foreach x in `num'{
	tab veg_source_`x', m 
	drop veg_source_`x'
	gen veg_source_`x' = (veg_source1 == `x' | ///
						  veg_source2 == `x' | ///
						  veg_source3 == `x')
	replace veg_source_`x' = .r if veg_source1 == 999 | ///
								   veg_source2 == 999 | ///
								veg_source3 == 999
	replace veg_source_`x' = .m if mi(veg_source)
	order veg_source_`x', before(veg_source_oth)
	tab veg_source_`x', m
}

replace veg_source_3 = 1 if	veg_source_oth_eng == "Village shop" | veg_source_oth_eng == "Bought from the village shop." | ///
							veg_source_oth_eng == "Village shop and the seller sells in the village." | ///
							veg_source_oth_eng == "Bought in the village" | veg_source_oth_eng == "Bought from the mobile market." | ///
							veg_source_oth_eng == "Shop" | veg_source_oth_eng == "From the seller." | ///
							veg_source_oth_eng == "Mobile market" | veg_source_oth_eng == "Bought in the village." | ///
							veg_source_oth_eng == "The seller sells in the village." | ///
							veg_source_oth_eng == "Frrom those cultivating them."
									
replace veg_source_1 = 1 if	veg_source_oth_eng == "Own cultivating" | veg_source_oth_eng == "Cultivating"

replace veg_source_777 = 0 if 	veg_source_oth_eng == "Village shop" | veg_source_oth_eng == "Bought from the village shop." | ///
								veg_source_oth_eng == "Village shop and the seller sells in the village." | ///
								veg_source_oth_eng == "Bought in the village" | veg_source_oth_eng == "Bought from the mobile market." | ///
								veg_source_oth_eng == "Shop" | veg_source_oth_eng == "From the seller." | ///
								veg_source_oth_eng == "Mobile market" | veg_source_oth_eng == "Bought in the village." | ///
								veg_source_oth_eng == "The seller sells in the village." | ///
								veg_source_oth_eng == "Frrom those cultivating them." | ///
								veg_source_oth_eng == "Own cultivating" | veg_source_oth_eng == "Cultivating"

								
lab var veg_source_1 "Own farm"
lab var veg_source_2 "Food aid"
lab var veg_source_3 "Purchase from market"
lab var veg_source_4 "Food loans"
lab var veg_source_5 "Foraging"
lab var veg_source_777 "Other type of sources"

// veg_source_oth
tab veg_source_oth, m 
 
preserve
keep if veg_source_777 == 1
if _N > 0 {
	export 	excel $respinfo veg_source_oth using "$out/mother_other_specify.xlsx", ///
			sheet("veg_source_oth") firstrow(varlabels) sheetreplace 
}
restore


********************************************************************************
** G. Maternal health (For under 2-year-old children) **
********************************************************************************

// g_note 
tab g_note, m 
drop g_note

// mom_firstpreg_age 
tab mom_firstpreg_age, m 
replace mom_firstpreg_age = .n if mi(mom_firstpreg_age)
replace mom_firstpreg_age = .m if e_note != 1
lab var mom_firstpreg_age "age at first pregnancy"
tab mom_firstpreg_age, m 

// age discripency check 
count if resp_married_age > mom_firstpreg_age & !mi(resp_married_age) & !mi(mom_firstpreg_age)

preserve
keep if resp_married_age > mom_firstpreg_age & !mi(resp_married_age) & !mi(mom_firstpreg_age)
if _N > 0 {
	export 	excel $respinfo resp_age resp_married_age mom_firstpreg_age using "$out/mother_logical_check.xlsx", ///
			sheet("married_preg_age") firstrow(varlabels) sheetreplace 
}
restore	

count if resp_age < mom_firstpreg_age & !mi(resp_age) & !mi(mom_firstpreg_age)

preserve
keep if resp_age < mom_firstpreg_age & !mi(resp_age) & !mi(mom_firstpreg_age)
if _N > 0 {
	export 	excel $respinfo resp_age resp_married_age mom_firstpreg_age using "$out/mother_logical_check.xlsx", ///
			sheet("preg_age_issue") firstrow(varlabels) sheetreplace 
}
restore	


// mom_anc_yes 
tab mom_anc_yes, m 

split mom_anc_yes, p(".")
drop mom_anc_yes2-mom_anc_yes5
order mom_anc_yes1, after(mom_anc_yes)
drop mom_anc_yes
rename mom_anc_yes1 mom_anc_yes
destring mom_anc_yes, replace 
replace mom_anc_yes = .n if mi(mom_anc_yes)
replace mom_anc_yes = .m if e_note != 1
replace mom_anc_yes = .d if mom_anc_yes == 888
replace mom_anc_yes = 0 if mom_anc_yes == 2
lab var mom_anc_yes "Received ANC"
tab mom_anc_yes, m 

// mom_anc_no_why mom_anc_no_why_1 mom_anc_no_why_2 mom_anc_no_why_3 mom_anc_no_why_4 mom_anc_no_why_5 mom_anc_no_why_6 mom_anc_no_why_7 mom_anc_no_why_8 mom_anc_no_why_9 mom_anc_no_why_10 mom_anc_no_why_11 mom_anc_no_why_12 mom_anc_no_why_13 mom_anc_no_why_888 mom_anc_no_why_999 mom_anc_no_why_777 

tab mom_anc_no_why, m 
replace mom_anc_no_why = subinstr(mom_anc_no_why, "Covid-19", "", .)

moss mom_anc_no_why, match("([0-9]+)") regex

drop _pos*
sum _count

forval x = 1/`r(max)' {
	destring _match`x', replace
	rename _match`x' mom_anc_no_why`x'
}

drop _count

local num 1 2 3 4 5 6 7 8 9 10 11 12 13 777  

foreach x in `num'{
	tab mom_anc_no_why_`x', m 
	drop mom_anc_no_why_`x'
	gen mom_anc_no_why_`x' = (mom_anc_no_why1 == `x' | ///
							  mom_anc_no_why2 == `x' | ///
							  mom_anc_no_why3 == `x' | ///
							  mom_anc_no_why4 == `x' | ///
							  mom_anc_no_why5 == `x')
	replace mom_anc_no_why_`x' = .r if 	mom_anc_no_why1 == 999 | ///
										mom_anc_no_why2 == 999 | ///
										mom_anc_no_why3 == 999 | /// 
										mom_anc_no_why4 == 999 | ///
										mom_anc_no_why5 == 999
	replace mom_anc_no_why_`x' = .m if mom_anc_yes != 0
	order mom_anc_no_why_`x', before(mom_anc_no_why_oth)
	tab mom_anc_no_why_`x', m
}

replace mom_anc_no_why_13 = 1 if mom_anc_no_why_oth_eng == "There is no health care staff."

replace mom_anc_no_why_777 = 0 if mom_anc_no_why_oth_eng == "There is no health care staff."

lab var mom_anc_no_why_1 "Not important"
lab var mom_anc_no_why_2 "Very far from health facility"
lab var mom_anc_no_why_3 "Family doesn’t allow"
lab var mom_anc_no_why_4 "No family member to accompany me"
lab var mom_anc_no_why_5 "No health service nearby"
lab var mom_anc_no_why_6 "No health care provider nearby"
lab var mom_anc_no_why_7 "Financial difficulty"
lab var mom_anc_no_why_8 "Cost of transportation"
lab var mom_anc_no_why_9 "Fear of contracting Covid-19"
lab var mom_anc_no_why_10 "Have to take care of children"
lab var mom_anc_no_why_11 "Insecurity due to active conflict"
lab var mom_anc_no_why_12 "Mobility restrictions"
lab var mom_anc_no_why_13 "Health care provider absent"
lab var mom_anc_no_why_777 "Other reasons"

// mom_anc_no_why_oth 
tab mom_anc_no_why_oth, m 
 
preserve
keep if mom_anc_no_why_777 == 1
if _N > 0 {
	export 	excel $respinfo mom_anc_no_why_oth using "$out/mother_other_specify.xlsx", ///
			sheet("mom_anc_no_why_oth") firstrow(varlabels) sheetreplace 
}
restore

// mom_anc_freq 
tab mom_anc_freq, m 
replace mom_anc_freq = .n if mi(mom_anc_freq)
replace mom_anc_freq =  .d if mom_anc_freq == 888
replace mom_anc_freq = .m if mom_anc_yes != 1
replace mom_anc_freq =  .n if mom_anc_freq == 444
lab var mom_anc_freq "ANC frequency"
tab mom_anc_freq, m 

// outlier check 
sum mom_anc_freq, d
export 	excel $respinfo mom_anc_freq using "$out/mother_outlier.xlsx" if mom_anc_freq > `r(p95)' & !mi(mom_anc_freq), ///
		sheet("mom_anc_freq") firstrow(varlabels) sheetreplace 

		
// mom_anc_first_wk 
tab mom_anc_first_wk, m 
replace mom_anc_first_wk = .n if mi(mom_anc_first_wk)
replace mom_anc_first_wk =  .d if mom_anc_first_wk == 888
replace mom_anc_first_wk = .m if mom_anc_yes != 1
replace mom_anc_first_wk =  .n if mom_anc_first_wk == 444
lab var mom_anc_first_wk "Pregnancy weeks of 1st ANC"
tab mom_anc_first_wk, m 

// outlier check 
sum mom_anc_first_wk, d
export 	excel $respinfo mom_anc_first_wk using "$out/mother_outlier.xlsx" if mom_anc_first_wk > `r(p95)' & !mi(mom_anc_first_wk), ///
		sheet("mom_anc_first_wk") firstrow(varlabels) sheetreplace 

	
	
// mom_anc_place 
tab mom_anc_place, m 

split mom_anc_place, p(".")
drop mom_anc_place2
order mom_anc_place1, after(mom_anc_place)
drop mom_anc_place
rename mom_anc_place1 mom_anc_place
replace mom_anc_place_oth = "ေကျးရွာကျန်းမာရေး‌ေစတနာ့ဝန်ထမ်း" if mom_anc_place == "ေကျးရွာကျန်းမာရေး‌ေစတနာ့ဝန်ထမ်း"
replace mom_anc_place = "777" if mom_anc_place == "ေကျးရွာကျန်းမာရေး‌ေစတနာ့ဝန်ထမ်း"
destring mom_anc_place, replace 
replace mom_anc_place = .n if mi(mom_anc_place)
replace mom_anc_place = .m if mom_anc_yes != 1
replace mom_anc_place = .d if mom_anc_place == 888
replace mom_anc_place = 0 if mom_anc_place == 2
tab mom_anc_place, m 


local num 1 2 3 4 5 6 7 8 9 10 11 12 13 777  

foreach x in `num'{
	gen mom_anc_place_`x' = (mom_anc_place == `x')
	replace mom_anc_place_`x' = .m if mi(mom_anc_place)
	order mom_anc_place_`x', before(mom_anc_place_oth)
	tab mom_anc_place_`x', m
}

lab var mom_anc_place_1 "Township hospital"
lab var mom_anc_place_2 "District hospital"
lab var mom_anc_place_3 "Rural health center"
lab var mom_anc_place_4 "Sub-rural health center"
lab var mom_anc_place_5 "Private clinic/hospital"
lab var mom_anc_place_6 "Community health volunteer"
lab var mom_anc_place_7 "Traditional medicine"
lab var mom_anc_place_8 "Quack"
lab var mom_anc_place_9 "Medicines from shops"
lab var mom_anc_place_10 "EHO clinic"
lab var mom_anc_place_11 "Family member"
lab var mom_anc_place_12 "NGO clinic"
lab var mom_anc_place_13 "Auxiliary midwife"
lab var mom_anc_place_777 "Other type of health facilities"
				
// mom_anc_place_oth 
tab mom_anc_place_oth, m 

preserve
keep if mom_anc_place_777 == 1
if _N > 0 {
	export 	excel $respinfo mom_anc_place_oth using "$out/mother_other_specify.xlsx", ///
			sheet("mom_anc_place_oth") firstrow(varlabels) sheetreplace 
}
restore

** ANC with trained health personnel **
egen anc_skilled = rowtotal(mom_anc_place_1 mom_anc_place_2 mom_anc_place_3 mom_anc_place_4 mom_anc_place_5 mom_anc_place_10 mom_anc_place_12)
replace anc_skilled = .m if mom_anc_yes != 1
lab var anc_skilled "ANC with trained health personnel"
tab anc_skilled, m

gen anc_skill_visit_one 	= (anc_skilled == 1 & mom_anc_freq > 0)
replace anc_skill_visit_one = .m if mi(anc_skilled) | mi(mom_anc_freq)
lab var anc_skill_visit_one "At least one ANC visit with trained health personnel"
tab anc_skill_visit_one, m 

gen anc_skill_visit_four 	= (anc_skilled == 1 & mom_anc_freq > 4)
replace anc_skill_visit_four = .m if mi(anc_skilled) | mi(mom_anc_freq)
lab var anc_skill_visit_four "At least four ANC visit with trained health personnel"
tab anc_skill_visit_four, m 


// mom_anc_vit mom_anc_vit_1 mom_anc_vit_2 mom_anc_vit_3 mom_anc_vit_4 mom_anc_vit_5 mom_anc_vit_6 mom_anc_vit_7 mom_anc_vit_888 mom_anc_vit_999 mom_anc_vit_777 
tab mom_anc_vit, m 
replace mom_anc_vit = subinstr(mom_anc_vit, "B1", "", .)

moss mom_anc_vit, match("([0-9]+)") regex

drop _pos*
sum _count

forval x = 1/`r(max)' {
	destring _match`x', replace
	rename _match`x' mom_anc_vit`x'
}

drop _count

local num 1 2 3 4 5 6 7 777  

foreach x in `num'{
	tab mom_anc_vit_`x', m 
	drop mom_anc_vit_`x'
	gen mom_anc_vit_`x' = (	mom_anc_vit1 == `x' | ///
							mom_anc_vit2 == `x' | ///
							mom_anc_vit3 == `x' | ///
							mom_anc_vit4 == `x' | ///
							mom_anc_vit5 == `x' | ///
							mom_anc_vit6 == `x')
	replace mom_anc_vit_`x' = .r if mom_anc_vit1 == 999 | ///
									mom_anc_vit2 == 999 | ///
									mom_anc_vit3 == 999 | ///
									mom_anc_vit4 == 999 | ///
									mom_anc_vit5 == 999 | ///
									mom_anc_vit6 == 999
	replace mom_anc_vit_`x' = .d if mom_anc_vit1 == 888 | ///
									mom_anc_vit2 == 888 | ///
									mom_anc_vit3 == 888 | ///
									mom_anc_vit4 == 888 | ///
									mom_anc_vit5 == 888 | ///
									mom_anc_vit6 == 888
	replace mom_anc_vit_`x' = .m if e_note != 1
	order mom_anc_vit_`x', before(mom_anc_vit_oth)
	tab mom_anc_vit_`x', m
}

lab var mom_anc_vit_1 "Iron rich multivitamins"
lab var mom_anc_vit_2 "Vitamin B1"
lab var mom_anc_vit_3 "Iron"
lab var mom_anc_vit_4 "Folic acid"
lab var mom_anc_vit_5 "Calcium"
lab var mom_anc_vit_6 "Zinc"
lab var mom_anc_vit_7 "Deworming"
lab var mom_anc_vit_777 "Other type of supplementation"

// mom_anc_vit_oth 
tab mom_anc_vit_oth, m 
 
preserve
keep if mom_anc_vit_777 == 1
if _N > 0 {
	export 	excel $respinfo mom_anc_vit_oth using "$out/mother_other_specify.xlsx", ///
			sheet("mom_anc_vit_oth") firstrow(varlabels) sheetreplace 
}
restore


// mom_anc_vit_place 
tab mom_anc_vit_place, m 

moss mom_anc_vit_place, match("([0-9]+)") regex

drop _pos*
sum _count

forval x = 1/`r(max)' {
	destring _match`x', replace
	rename _match`x' mom_anc_vit_place`x'
}

drop _count

local num 1 2 3 4 5 6 7 8 9 10 11 12 13 777  

foreach x in `num'{
	gen mom_anc_vit_place_`x' = (	mom_anc_vit_place1 == `x' | ///
									mom_anc_vit_place2 == `x' )
	replace mom_anc_vit_place_`x' = .r if 	mom_anc_vit_place1 == 999 | ///
											mom_anc_vit_place2 == 999 
	replace mom_anc_vit_place_`x' = .d if 	mom_anc_vit_place1 == 888 | ///
											mom_anc_vit_place2 == 888
	replace mom_anc_vit_place_`x' = .m if 	mom_anc_vit_place1 == 444 | ///
											mom_anc_vit_place2 == 444
	replace mom_anc_vit_place_`x' = .m if e_note != 1
	order mom_anc_vit_place_`x', before(mom_anc_vit_place_oth)
	tab mom_anc_vit_place_`x', m
}

lab var mom_anc_vit_place_1 "Township hospital"
lab var mom_anc_vit_place_2 "District hospital"
lab var mom_anc_vit_place_3 "Rural health center"
lab var mom_anc_vit_place_4 "Sub-rural health center"
lab var mom_anc_vit_place_5 "Private clinic/hospital"
lab var mom_anc_vit_place_6 "Community health volunteer"
lab var mom_anc_vit_place_7 "Traditional medicine"
lab var mom_anc_vit_place_8 "Quack"
lab var mom_anc_vit_place_9 "Medicines from shops"
lab var mom_anc_vit_place_10 "EHO clinic"
lab var mom_anc_vit_place_11 "Family member"
lab var mom_anc_vit_place_12 "NGO clinic"
lab var mom_anc_vit_place_13 "Auxiliary midwife"
lab var mom_anc_vit_place_777 "Other type of health facilities"
				
// mom_anc_vit_place_oth 
tab mom_anc_vit_place_oth, m 
 
preserve
keep if mom_anc_vit_place_777 == 1
if _N > 0 {
	export 	excel $respinfo mom_anc_vit_place_oth using "$out/mother_other_specify.xlsx", ///
			sheet("mom_anc_vit_place_oth") firstrow(varlabels) sheetreplace 
}
restore

// mom_nut_counsel 
tab mom_nut_counsel, m 

split mom_nut_counsel, p(".")
drop mom_nut_counsel2-mom_nut_counsel5
order mom_nut_counsel1, after(mom_nut_counsel)
drop mom_nut_counsel
rename mom_nut_counsel1 mom_nut_counsel
destring mom_nut_counsel, replace 
replace mom_nut_counsel = .n if mi(mom_nut_counsel)
replace mom_nut_counsel = .m if e_note != 1
replace mom_nut_counsel = .d if mom_nut_counsel == 888
replace mom_nut_counsel = .m if mom_nut_counsel == 444
replace mom_nut_counsel = 0 if mom_nut_counsel == 2
lab var mom_nut_counsel "Received any nutrition counselling"
tab mom_nut_counsel, m 


// mom_nut_counsel_who mom_nut_counsel_who_1 mom_nut_counsel_who_2 mom_nut_counsel_who_3 mom_nut_counsel_who_4 mom_nut_counsel_who_5 mom_nut_counsel_who_6 mom_nut_counsel_who_888 mom_nut_counsel_who_999 mom_nut_counsel_who_777 
tab mom_nut_counsel_who, m 
moss mom_nut_counsel_who, match("([0-9]+)") regex

drop _pos*
sum _count

forval x = 1/`r(max)' {
	destring _match`x', replace
	rename _match`x' mom_nut_counsel_who`x'
}

drop _count

local num 1 2 3 4 5 6 777  

foreach x in `num'{
	tab mom_nut_counsel_who_`x', m 
	drop mom_nut_counsel_who_`x'
	gen mom_nut_counsel_who_`x' = (	mom_nut_counsel_who1 == `x' | ///
									mom_nut_counsel_who2 == `x' | ///
									mom_nut_counsel_who3 == `x')
	replace mom_nut_counsel_who_`x' = .d if mom_nut_counsel_who1 == 888 | ///
											mom_nut_counsel_who3 == 888 | ///
											mom_nut_counsel_who3 == 888
	replace mom_nut_counsel_who_`x' = .m if mom_nut_counsel != 1
	order mom_nut_counsel_who_`x', before(mom_nut_counsel_who_oth)
	tab mom_nut_counsel_who_`x', m
}

lab var mom_nut_counsel_who_1 "EHO staff "
lab var mom_nut_counsel_who_2 "MOHS Health staff "
lab var mom_nut_counsel_who_3 "Community health volunteer "
lab var mom_nut_counsel_who_4 "NGO staff"
lab var mom_nut_counsel_who_5 "Family member"
lab var mom_nut_counsel_who_6 "Friends (i.e. peers)"
lab var mom_nut_counsel_who_777 "Other source of information"				
				
// mom_nut_counsel_who_oth 
tab mom_nut_counsel_who_oth, m 
 
preserve
keep if mom_nut_counsel_who_777 == 1
if _N > 0 {
	export 	excel $respinfo mom_nut_counsel_who_oth using "$out/mother_other_specify.xlsx", ///
			sheet("mom_nut_counsel_who_oth") firstrow(varlabels) sheetreplace 
}
restore

// mom_bf_counsel 
tab mom_bf_counsel, m 

split mom_bf_counsel, p(".")
drop mom_bf_counsel2
order mom_bf_counsel1, after(mom_bf_counsel)
drop mom_bf_counsel
rename mom_bf_counsel1 mom_bf_counsel
destring mom_bf_counsel, replace 
replace mom_bf_counsel = .n if mi(mom_bf_counsel)
replace mom_bf_counsel = .m if e_note != 1
replace mom_bf_counsel = .d if mom_bf_counsel == 888
replace mom_bf_counsel = 0 if mom_bf_counsel == 2
lab var mom_bf_counsel "Received any counselling about exclusive breastfeeding"
tab mom_bf_counsel, m 

// mom_anc_wt 
tab mom_anc_wt, m 

split mom_anc_wt, p(".")
drop mom_anc_wt2
order mom_anc_wt1, after(mom_anc_wt)
drop mom_anc_wt
rename mom_anc_wt1 mom_anc_wt
destring mom_anc_wt, replace 
replace mom_anc_wt = .n if mi(mom_anc_wt)
replace mom_anc_wt = .m if e_note != 1
replace mom_anc_wt = .d if mom_anc_wt == 888
replace mom_anc_wt = 0 if mom_anc_wt == 2
lab var mom_anc_wt "Pregnancy weight measurement"
tab mom_anc_wt, m 

// mom_anc_muac 
tab mom_anc_muac, m 

split mom_anc_muac, p(".")
drop mom_anc_muac2
order mom_anc_muac1, after(mom_anc_muac)
drop mom_anc_muac
rename mom_anc_muac1 mom_anc_muac
destring mom_anc_muac, replace 
replace mom_anc_muac = .n if mi(mom_anc_muac)
replace mom_anc_muac = .m if e_note != 1
replace mom_anc_muac = .d if mom_anc_muac == 888
replace mom_anc_muac = 0 if mom_anc_muac == 2
lab var mom_anc_muac "Pregnancy MUAC measurement"
tab mom_anc_muac, m 

// mom_cdtest mom_cdtest_1 mom_cdtest_2 mom_cdtest_3 mom_cdtest_4 mom_cdtest_5 mom_cdtest_888 mom_cdtest_999 mom_cdtest_777 
tab mom_cdtest, m 
moss mom_cdtest, match("([0-9]+)") regex

drop _pos*
sum _count

forval x = 1/`r(max)' {
	destring _match`x', replace
	rename _match`x' mom_cdtest`x'
}

drop _count

local num 1 2 3 4 5 777  

foreach x in `num'{
	tab mom_cdtest_`x', m 
	drop mom_cdtest_`x'
	gen mom_cdtest_`x' = (mom_cdtest1 == `x' | ///
						  mom_cdtest2 == `x' | ///
						  mom_cdtest3 == `x' | ///
						  mom_cdtest4 == `x' | ///
						  mom_cdtest5 == `x')
	replace mom_cdtest_`x' = .d if	mom_cdtest1 == 888
	replace mom_cdtest_`x' = .m if e_note != 1
	order mom_cdtest_`x', before(mom_cdtest_oth)
	tab mom_cdtest_`x', m
}

lab var mom_cdtest_1 "No testing"
lab var mom_cdtest_2 "Hepatitis B"
lab var mom_cdtest_3 "Hepatitis C"
lab var mom_cdtest_4 "HIV/AIDS"
lab var mom_cdtest_5 "Syphilis"
lab var mom_cdtest_777 "Other type of testings"
				
// mom_cdtest_oth 
tab mom_cdtest_oth, m 
 
preserve
keep if mom_cdtest_777 == 1
if _N > 0 {
	export 	excel $respinfo mom_cdtest_oth using "$out/mother_other_specify.xlsx", ///
			sheet("mom_cdtest_oth") firstrow(varlabels) sheetreplace 
}
restore

// mom_delivery_place 
tab mom_delivery_place, m 

split mom_delivery_place, p(".")
drop mom_delivery_place2
order mom_delivery_place1, after(mom_delivery_place)
drop mom_delivery_place
rename mom_delivery_place1 mom_delivery_place
destring mom_delivery_place, replace 
replace mom_delivery_place = .n if mi(mom_delivery_place)
replace mom_delivery_place = .m if e_note != 1
tab mom_delivery_place, m 


local num 1 2 3 4 5 6 7 8 9 10 11 12 13 777  

foreach x in `num'{
	gen mom_delivery_place_`x' = (mom_delivery_place == `x')
	replace mom_delivery_place_`x' = .m if mi(mom_delivery_place)
	order mom_delivery_place_`x', before(mom_delivery_place_oth)
	tab mom_delivery_place_`x', m
}

replace mom_delivery_place_2 =  1 if 	mom_delivery_place_oth_eng == "Regional hospital" | ///
										mom_delivery_place_oth_eng == "Military hospital" | ///
										mom_delivery_place_oth_eng == "Taungkalay hospital" | ///
										mom_delivery_place_oth_eng == "Taungkalay military hospital" | ///
										mom_delivery_place_oth_eng == "Taungoo military hospital"

gen mom_delivery_place_14 =	(mom_delivery_place_oth_eng == "Home-birth" | mom_delivery_place_oth_eng == "Home of TTBA" | ///
							mom_delivery_place_oth_eng == "TBA" | mom_delivery_place_oth_eng == "TTBA" | ///
							mom_delivery_place_oth_eng == "Delivered baby by TBA" | mom_delivery_place_oth_eng == "At home" | ///
							mom_delivery_place_oth_eng == "Delivered baby by village TBA" | ///
							mom_delivery_place_oth_eng == "Delivered baby by TBA in village" | ///
							mom_delivery_place_oth_eng == "By TBA at home" | mom_delivery_place_oth_eng == "Delivered baby by TBA at home" | ///
							mom_delivery_place_oth_eng == "Home-birth by TBA" | /// 
							mom_delivery_place_oth_eng == "Home-birth by a midwife" | ///
							mom_delivery_place_oth_eng == "Delivered baby by AMW at home" | ///
							mom_delivery_place_oth_eng == "Delivered baby by midwife at home")
replace mom_delivery_place_14 = .m if mi(mom_delivery_place)
order mom_delivery_place_14, before(mom_delivery_place_oth)
tab mom_delivery_place_14, m
							
replace mom_delivery_place_777 = 0 if	mom_delivery_place_oth_eng == "Home-birth" | mom_delivery_place_oth_eng == "Home of TTBA" | ///
										mom_delivery_place_oth_eng == "TBA" | mom_delivery_place_oth_eng == "TTBA" | ///
										mom_delivery_place_oth_eng == "Delivered baby by TBA" | mom_delivery_place_oth_eng == "At home" | ///
										mom_delivery_place_oth_eng == "Delivered baby by village TBA" | ///
										mom_delivery_place_oth_eng == "Delivered baby by TBA in village" | ///
										mom_delivery_place_oth_eng == "By TBA at home" | ///
										mom_delivery_place_oth_eng == "Delivered baby by TBA at home" | ///
										mom_delivery_place_oth_eng == "Home-birth by TBA" | /// 
										mom_delivery_place_oth_eng == "Home-birth by a midwife" | ///
										mom_delivery_place_oth_eng == "Delivered baby by AMW at home" | ///
										mom_delivery_place_oth_eng == "Delivered baby by midwife at home" | ///
										mom_delivery_place_oth_eng == "Regional hospital" | ///
										mom_delivery_place_oth_eng == "Military hospital" | ///
										mom_delivery_place_oth_eng == "Taungkalay hospital" | ///
										mom_delivery_place_oth_eng == "Taungkalay military hospital" | ///
										mom_delivery_place_oth_eng == "Taungoo military hospital"

replace mom_delivery_place_777 = .m if mi(mom_delivery_place)
								
lab var mom_delivery_place_1 "Township hospital"
lab var mom_delivery_place_2 "District hospital"
lab var mom_delivery_place_3 "Rural health center"
lab var mom_delivery_place_4 "Sub-rural health center"
lab var mom_delivery_place_5 "Private clinic/hospital"
lab var mom_delivery_place_6 "Community health volunteer"
lab var mom_delivery_place_7 "Traditional medicine"
lab var mom_delivery_place_8 "Quack"
lab var mom_delivery_place_9 "Medicines from shops"
lab var mom_delivery_place_10 "EHO clinic"
lab var mom_delivery_place_11 "Family member"
lab var mom_delivery_place_12 "NGO clinic"
lab var mom_delivery_place_13 "Auxiliary midwife"
lab var mom_delivery_place_14 "Home Delivery"
lab var mom_delivery_place_777 "Other type of health facilities"


// Home delivery vs BF status [private vs public vs EHO vs other skills] add a note about groupomg category 
egen delivery_public = rowtotal(	mom_delivery_place_1 mom_delivery_place_2 ///
										mom_delivery_place_3 mom_delivery_place_4 ///
										mom_delivery_place_12)
replace delivery_public = 1 if delivery_public > 1 & !mi(delivery_public)
tab delivery_public, m 

egen delivery_private = rowtotal(mom_delivery_place_5)
tab delivery_private, m 

egen delivery_eho = rowtotal(mom_delivery_place_10)
tab delivery_eho, m 

egen delivery_othtrained = rowtotal(mom_delivery_place_6 mom_delivery_place_13)
replace delivery_othtrained = 1 if delivery_othtrained > 1 & !mi(delivery_othtrained)
tab delivery_othtrained, m 

egen delivery_othnotrain = rowtotal(mom_delivery_place_7 mom_delivery_place_13 ///
									mom_delivery_place_14 mom_delivery_place_777)
replace delivery_othnotrain = 1 if delivery_othnotrain > 1 & !mi(delivery_othnotrain)
tab delivery_othnotrain, m 


// mom_delivery_place_oth 
tab mom_delivery_place_oth, m 
 
preserve
keep if mom_delivery_place_777 == 1
if _N > 0 {
	export 	excel $respinfo mom_delivery_place_oth using "$out/mother_other_specify.xlsx", ///
			sheet("mom_delivery_place_oth") firstrow(varlabels) sheetreplace 
}
restore

** Delivery assisted by trained health personnel **
egen delivery_skilled	= rowtotal(	mom_delivery_place_1 mom_delivery_place_2 mom_delivery_place_3 ///
									mom_delivery_place_4 mom_delivery_place_5 mom_delivery_place_10 ///
									mom_delivery_place_12 mom_delivery_place_13)
replace delivery_skilled = .m if mi(mom_delivery_place)
lab var delivery_skilled "Delivery assited trained health personnel"
tab delivery_skilled, m

	
// mom_pnc_yes 
tab mom_pnc_yes, m 

split mom_pnc_yes, p(".")
drop mom_pnc_yes2-mom_pnc_yes5
order mom_pnc_yes1, after(mom_pnc_yes)
drop mom_pnc_yes
rename mom_pnc_yes1 mom_pnc_yes
destring mom_pnc_yes, replace 
replace mom_pnc_yes = .n if mi(mom_pnc_yes)
replace mom_pnc_yes = .m if e_note != 1
replace mom_pnc_yes = .d if mom_pnc_yes == 888
replace mom_pnc_yes = 0 if mom_pnc_yes == 2
lab var mom_pnc_yes "Received PNC"
tab mom_pnc_yes, m 

// mom_pnc_no_why mom_pnc_no_why_1 mom_pnc_no_why_2 mom_pnc_no_why_3 mom_pnc_no_why_4 mom_pnc_no_why_5 mom_pnc_no_why_6 mom_pnc_no_why_7 mom_pnc_no_why_8 mom_pnc_no_why_9 mom_pnc_no_why_10 mom_pnc_no_why_11 mom_pnc_no_why_12 mom_pnc_no_why_13 mom_pnc_no_why_888 mom_pnc_no_why_999 mom_pnc_no_why_777 
tab mom_pnc_no_why, m 
moss mom_pnc_no_why, match("([0-9]+)") regex

drop _pos*
sum _count

forval x = 1/`r(max)' {
	destring _match`x', replace
	rename _match`x' mom_pnc_no_why`x'
}

drop _count

local num 1 2 3 4 5 6 7 8 9 10 11 12 13 777  

foreach x in `num'{
	tab mom_pnc_no_why_`x', m 
	drop mom_pnc_no_why_`x'
	gen mom_pnc_no_why_`x' = (	mom_pnc_no_why1 == `x' | ///
								mom_pnc_no_why2 == `x' | ///
								mom_pnc_no_why3 == `x' | ///
								mom_pnc_no_why4 == `x' | ///
								mom_pnc_no_why5 == `x' | ///
								mom_pnc_no_why6 == `x') 
	replace mom_pnc_no_why_`x' = .r if mom_pnc_no_why1 == 999
	replace mom_pnc_no_why_`x' = .d if mom_pnc_no_why1 == 888
	replace mom_pnc_no_why_`x' = .m if mom_pnc_yes != 0
	order mom_pnc_no_why_`x', before(mom_pnc_no_why_oth)
	tab mom_pnc_no_why_`x', m
}

replace mom_pnc_no_why_1 = 1 if mom_pnc_no_why_oth_eng == "Thought it was not needed" | ///
								mom_pnc_no_why_oth_eng == "Thought it was not needed as it was nothing."

replace mom_pnc_no_why_13 = 1 if mom_pnc_no_why_oth_eng == "The health staff joined the CDM movement."

replace mom_pnc_no_why_777 = 0 if 	mom_pnc_no_why_oth_eng == "Thought it was not needed" | ///
									mom_pnc_no_why_oth_eng == "Thought it was not needed as it was nothing." | ///
									mom_pnc_no_why_oth_eng == "The health staff joined the CDM movement."

lab var mom_pnc_no_why_1 "Not important"
lab var mom_pnc_no_why_2 "Very far from health facility"
lab var mom_pnc_no_why_3 "Family doesn’t allow"
lab var mom_pnc_no_why_4 "No family member to accompany me"
lab var mom_pnc_no_why_5 "No health service nearby"
lab var mom_pnc_no_why_6 "No health care provider nearby"
lab var mom_pnc_no_why_7 "Financial difficulty"
lab var mom_pnc_no_why_8 "Cost of transportation"
lab var mom_pnc_no_why_9 "Fear of contracting Covid-19"
lab var mom_pnc_no_why_10 "Have to take care of children"
lab var mom_pnc_no_why_11 "Insecurity due to active conflict"
lab var mom_pnc_no_why_12 "Mobility restrictions"
lab var mom_pnc_no_why_13 "Health care provider absent"
lab var mom_pnc_no_why_777 "Other reasons"

// mom_pnc_no_why_oth 
tab mom_pnc_no_why_oth, m 
 
preserve
keep if mom_pnc_no_why_777 == 1
if _N > 0 {
	export 	excel $respinfo mom_pnc_no_why_oth using "$out/mother_other_specify.xlsx", ///
			sheet("mom_pnc_no_why_oth") firstrow(varlabels) sheetreplace 
}
restore

// mom_pnc_when 
tab mom_pnc_when, m 

split mom_pnc_when, p(".")
drop mom_pnc_when2
order mom_pnc_when1, after(mom_pnc_when)
drop mom_pnc_when
rename mom_pnc_when1 mom_pnc_when
replace mom_pnc_when = "888" if mom_pnc_when == "888 မသိပါ /မမှတ်မိပါ    Don't know"
destring mom_pnc_when, replace 
replace mom_pnc_when = .n if mi(mom_pnc_when)
replace mom_pnc_when = .m if e_note != 1
replace mom_pnc_when = .d if mom_pnc_when == 888
tab mom_pnc_when, m 

local num 1 2 3 4  

foreach x in `num'{
	gen mom_pnc_when_`x' = (	mom_pnc_when == `x')
	replace mom_pnc_when_`x' = .m if mi(mom_pnc_when)
	order mom_pnc_when_`x', before(mom_covid_vaccine)
	tab mom_pnc_when_`x', m
}

lab var mom_pnc_when_1 "Within 1 day"
lab var mom_pnc_when_2 "Within 3 days"
lab var mom_pnc_when_3 "Within 1 week"
lab var mom_pnc_when_4 "Over a week"

// mom_covid_vaccine 
tab mom_covid_vaccine, m 

split mom_covid_vaccine, p(".")
drop mom_covid_vaccine2 mom_covid_vaccine3
order mom_covid_vaccine1, after(mom_covid_vaccine)
drop mom_covid_vaccine
rename mom_covid_vaccine1 mom_covid_vaccine
destring mom_covid_vaccine, replace 
replace mom_covid_vaccine = .n if mi(mom_covid_vaccine)
replace mom_covid_vaccine = .m if e_note != 1
replace mom_covid_vaccine = 0 if mom_covid_vaccine == 2
lab var mom_covid_vaccine "Received Covid-19 vaccination"

tab mom_covid_vaccine, m 

// mom_covid_vaccine_doses 
tab mom_covid_vaccine_doses, m 
replace mom_covid_vaccine_doses = .m if mom_covid_vaccine != 1
lab var mom_covid_vaccine_doses "Covid-19 vaccination doses"
tab mom_covid_vaccine_doses, m 

// mom_covid_vaccine_when 
tab mom_covid_vaccine_when, m 

preserve
keep if mom_covid_vaccine == 1
if _N > 0 {
	export 	excel $respinfo mom_covid_vaccine_when using "$out/mother_other_specify.xlsx", ///
			sheet("mom_covid_vaccine_when") firstrow(varlabels) sheetreplace 
}
restore


********************************************************************************
** H. Knowledge of IYCF practices **
********************************************************************************
// h_note 

// k_bf_eibf k_solid_age k_ebf k_bf_2yrs k_nonbf_food k_cf_923_freq k_cf_68_freq 
foreach var of varlist k_bf_eibf k_solid_age k_ebf k_bf_2yrs k_nonbf_food k_cf_923_freq k_cf_68_freq {
     
	tab `var', m 
    split `var', p(" ")
	drop `var'2
	order `var'1, after(`var')
	drop `var'
	rename `var'1 `var'
	destring `var', replace 
	replace `var' = .n if mi(`var')
	replace `var' = .d if `var' == 888
	replace `var' = .r if `var' == 999
	replace `var' = .n if `var' == 444
	replace `var' = 0 if `var' == 2
	tab `var', m 
}

lab var k_bf_eibf "Early initiation of breastfeeding"
lab var k_solid_age "Introduction of semi-solid food"
lab var k_ebf "Exclusively breastfed for under 6 months child"
lab var k_bf_2yrs "Continious breastfeeding"
lab var k_nonbf_food "Increase meals for non-breastfed child"
lab var k_cf_923_freq "Complementary feeding frequency - 9 to 23 months child"
lab var k_cf_68_freq "Complementary feeding frequency - 6 to 8 months child"


********************************************************************************
** I. Consumption-based coping strategies index **
********************************************************************************
// i_note 
tab i_note, m 
drop i_note

// fcope_less_exp_food fcope_food_credit fcope_food_borrow fcope_food_size fcope_food_restrict fcope_sent_hhmem fcope_reduce_freq fcope_food_skip 
local cope_con	fcope_less_exp_food fcope_food_credit fcope_food_borrow fcope_food_size ///
				fcope_food_restrict fcope_sent_hhmem fcope_reduce_freq fcope_food_skip

foreach var in `cope_con' {
    tab `var', m 
    replace `var' = .d if `var' == 888
	replace `var' = .r if `var' == 999
	replace `var' = .n if `var' == 444
	tab `var', m 
	
	// dummy var 
	gen `var'_yes = (`var' > 0 & !mi(`var'))
	replace `var'_yes = .m if mi(`var')
	tab `var'_yes, m 
	
	// outlier
	preserve
	keep if `var' > 7 & !mi(`var')
	if _N > 0 {
		export 	excel $respinfo `var' using "$out/mother_outlier.xlsx", ///
				sheet("`var'") firstrow(varlabels) sheetreplace 
	}
	restore
}

lab var fcope_less_exp_food "less preferred or expensive food (days)"
lab var fcope_food_credit "Purchased food on credit (days)"
lab var fcope_food_borrow "Borrow food (days)"
lab var fcope_food_size "Limit portion size (days)"
lab var fcope_food_restrict "Restrict consumption by adults (days)" 
lab var fcope_sent_hhmem "Send household members to eat elsewhere (days)"
lab var fcope_reduce_freq "Reduce the number of meals eaten in a day (days)"
lab var fcope_food_skip "Go an entire day without eating any food (days)"

lab var fcope_less_exp_food_yes "less preferred or expensive food"
lab var fcope_food_credit_yes "Purchased food on credit "
lab var fcope_food_borrow_yes "Borrow food"
lab var fcope_food_size_yes "Limit portion size"
lab var fcope_food_restrict_yes "Restrict consumption by adults" 
lab var fcope_sent_hhmem_yes "Send household members to eat elsewhere"
lab var fcope_reduce_freq_yes "Reduce the number of meals eaten in a day"
lab var fcope_food_skip_yes "Go an entire day without eating any food"


/*
Technical note: the standard consumption based coping strategies index includes 12
questions. The reduced-CSI included 5 questions. The mother survey collected 8 questions
on CSI module and only r-CSI index can calculate. 
*/

// fcope_less_exp_food 
gen conindex_prices_w 		= fcope_less_exp_food * 1
replace conindex_prices_w 	= .m if mi(fcope_less_exp_food)
tab conindex_prices_w, m

// fcope_food_borrow 
gen conindex_borrow_w 		= fcope_food_borrow * 2
replace conindex_borrow_w 	= .m if mi(fcope_food_borrow)
tab conindex_borrow_w, m

// fcope_food_size 
gen conindex_sizelimit_w 		= fcope_food_size * 1
replace conindex_sizelimit_w 	= .m if mi(fcope_food_size)
tab conindex_sizelimit_w, m

// fcope_food_restrict 
gen conindex_restrictage_w 		= fcope_food_restrict * 3
replace conindex_restrictage_w 	= .m if mi(fcope_food_restrict)
tab conindex_restrictage_w, m

// fcope_reduce_freq
gen conindex_reducefreq_w 		= fcope_reduce_freq * 1
replace conindex_reducefreq_w 	= .m if mi(fcope_reduce_freq)
tab conindex_reducefreq_w, m

// strict form 
gen csi_score		= 	conindex_prices_w + conindex_borrow_w + conindex_sizelimit_w + ///
						conindex_restrictage_w + conindex_reducefreq_w
replace csi_score	= .m if mi(conindex_prices_w) | mi(conindex_borrow_w) | mi(conindex_sizelimit_w) | ///
							mi(conindex_restrictage_w) | mi(conindex_reducefreq_w)
tab  csi_score, m

// treated missing as "0"
egen csi_score_l		= 	rowtotal(conindex_prices_w conindex_borrow_w conindex_sizelimit_w ///
								conindex_restrictage_w conindex_reducefreq_w)
replace csi_score_l	= .m if mi(conindex_prices_w) & mi(conindex_borrow_w) & mi(conindex_sizelimit_w) & ///
							mi(conindex_restrictage_w) & mi(conindex_reducefreq_w)
tab  csi_score_l, m


lab var csi_score "Reduced HH CSI Score"
lab var csi_score_l "Reduced HH CSI Score"

********************************************************************************
** J. Livelihood-based coping strategies index **
********************************************************************************
// j_note 
tab j_note, m 
drop j_note

// lcope_assets lcope_animals_more lcope_transport lcope_land lcope_school_withdrew lcope_school_cheap lcope_animals_female lcope_begged lcope_migrate lcope_spent_saveing lcope_borrow lcope_reduce_expense lcope_crops lcope_sell_seed lcope_reduce_inputs lcope_new_job lcope_adv_salary 

local lcope	lcope_assets lcope_animals_more lcope_transport lcope_land lcope_school_withdrew ///
			lcope_school_cheap lcope_animals_female lcope_begged lcope_migrate lcope_spent_saveing ///
			lcope_borrow lcope_reduce_expense lcope_crops lcope_sell_seed lcope_reduce_inputs ///
			lcope_new_job lcope_adv_salary 
			
			
foreach var in `lcope' {
    tab `var', m 
    replace `var' = .d if `var' == 888
	replace `var' = .r if `var' == 999
	replace `var' = .n if `var' == 444
	tab `var', m 
	
	// dummy var 
	gen `var'_yes = (`var' > 0 & !mi(`var'))
	// replace `var'_yes = .m if mi(`var')
	replace `var'_yes = 0 if mi(`var')
	tab `var'_yes, m 
	
	// outlier 
	preserve
	keep if `var' > 7 & !mi(`var')
	if _N > 0 {
		export 	excel $respinfo `var' using "$out/mother_outlier.xlsx", ///
				sheet("`var'") firstrow(varlabels) sheetreplace 
	}
	restore
}
			
lab var lcope_assets 			"Sold household assets (days)"
lab var lcope_animals_more 		"Sold more animals than usual (days)"
lab var lcope_transport 		"Sold productive assets (days)"
lab var lcope_land 				"Sold house or land (days)"
lab var lcope_school_withdrew 	"Withdrew children from school (days)"
lab var lcope_school_cheap 		"Move children to less expensive school (days)"
lab var lcope_animals_female 	"Sold last female animals (days)"
lab var lcope_begged 			"Begged (days)"
lab var lcope_migrate 			"Migrated to look for livelihood opportunities (days)"
lab var lcope_spent_saveing 	"Spent savings (days)"
lab var lcope_borrow 			"Borrowed money (days)"
lab var lcope_reduce_expense 	"Reduced non-food expenses (days)"
lab var lcope_crops 			"Harvested crops before it’s right time to do (days)"
lab var lcope_sell_seed 		"Consumed seed stocks (days)"
lab var lcope_reduce_inputs 	"Decreased expenditures on agriculture inputs (days)"
lab var lcope_new_job 			"Started a new job (days)"
lab var lcope_adv_salary 		"Took advance of next month salary (days)"

lab var lcope_assets_yes 			"Sold household assets"
lab var lcope_animals_more_yes 		"Sold more animals than usual"
lab var lcope_transport_yes 		"Sold productive assets"
lab var lcope_land_yes 				"Sold house or land"
lab var lcope_school_withdrew_yes 	"Withdrew children from school"
lab var lcope_school_cheap_yes 		"Move children to less expensive school"
lab var lcope_animals_female_yes 	"Sold last female animals"
lab var lcope_begged_yes 			"Begged"
lab var lcope_migrate_yes 			"Migrated to look for livelihood opportunities"
lab var lcope_spent_saveing_yes 	"Spent savings"
lab var lcope_borrow_yes 			"Borrowed money"
lab var lcope_reduce_expense_yes 	"Reduced non-food expenses"
lab var lcope_crops_yes 			"Harvested crops before it’s right time to do"
lab var lcope_sell_seed_yes 		"Consumed seed stocks"
lab var lcope_reduce_inputs_yes 	"Decreased expenditures on agriculture inputs"
lab var lcope_new_job_yes 			"Started a new job"
lab var lcope_adv_salary_yes 		"Took advance of next month salary"
	
/*
Technical note: 
reference: https://resources.vam.wfp.org/data-analysis/quantitative/food-security/livelihood-coping-strategies-food-security

LCSI indicator based on three different context: general, urgan and rural
For this survye, as all the study area is rural area, the rural context one with 
10 questions were applied in the analysis. 

Which might be differet from the MCCT baseline as it cover both rural and urban area.  

*/
// Using the strict coding rules - missing were not treated as zero and don't account in analysis  
egen lcis_stress_count		= rowtotal(lcope_assets lcope_animals_more lcope_spent_saveing lcope_borrow)
replace lcis_stress_count 	= .m if mi(lcope_assets) | mi(lcope_animals_more) | mi(lcope_spent_saveing) | mi(lcope_borrow)
tab lcis_stress_count, m

egen lcis_crisis_count		= rowtotal(lcope_transport lcope_school_withdrew lcope_reduce_expense)
replace lcis_crisis_count 	= .m if mi(lcope_transport) | mi(lcope_school_withdrew) | mi(lcope_reduce_expense)
tab lcis_crisis_count, m

egen lcis_emergency_count		= rowtotal(lcope_land lcope_animals_female lcope_begged)
replace lcis_emergency_count 	= .m if mi(lcope_land) | mi(lcope_animals_female) | mi(lcope_begged)
tab lcis_emergency_count, m

gen lcis_secure			= (lcis_stress_count == 0 & lcis_crisis_count == 0 & lcis_emergency_count == 0)
replace lcis_secure		= .m if mi(lcis_stress_count) | mi(lcis_crisis_count) | mi(lcis_emergency_count)
tab lcis_secure, m

gen lcis_stress 		= (lcis_stress_count > 0 & lcis_crisis_count == 0 & lcis_emergency_count == 0)
replace lcis_stress		= .m if mi(lcis_stress_count) | mi(lcis_crisis_count) | mi(lcis_emergency_count)
tab lcis_stress, m

gen lcis_crisis 		= (lcis_crisis_count > 0 & lcis_emergency_count == 0)
replace lcis_crisis		= .m if mi(lcis_crisis_count) | mi(lcis_emergency_count)
tab lcis_crisis, m

gen lcis_emergency 		= (lcis_emergency_count > 0)
replace lcis_emergency	= .m if mi(lcis_emergency_count)
tab lcis_emergency, m

** reporting variables **
lab var lcis_secure		"livelihood based CSI - secure"
lab var lcis_stress		"livelihood based CSI - stress"
lab var lcis_crisis		"livelihood based CSI - crisis"
lab var lcis_emergency 	"livelihood based CSI - emergency"

// Rural context based index
egen lcis_rural_stress_count		= rowtotal(lcope_assets lcope_animals_more lcope_spent_saveing) 
* missing one factor -  Sent household members to eat elsewhere due to lack of food  
replace lcis_rural_stress_count 	= .m if mi(lcope_assets) | mi(lcope_animals_more) | mi(lcope_spent_saveing)
tab lcis_rural_stress_count, m

egen lcis_rural_crisis_count		= rowtotal(lcope_crops lcope_sell_seed lcope_reduce_inputs)
replace lcis_rural_crisis_count 	= .m if mi(lcope_crops) | mi(lcope_sell_seed) | mi(lcope_reduce_inputs)
tab lcis_rural_crisis_count, m

egen lcis_rural_emergency_count		= rowtotal(lcope_land lcope_animals_female lcope_begged)
replace lcis_rural_emergency_count 	= .m if mi(lcope_land) | mi(lcope_animals_female) | mi(lcope_begged)
tab lcis_rural_emergency_count, m

gen lcis_rural_secure			= (lcis_rural_stress_count == 0 & lcis_rural_crisis_count == 0 & lcis_rural_emergency_count == 0)
replace lcis_rural_secure		= .m if mi(lcis_rural_stress_count) | mi(lcis_rural_crisis_count) | mi(lcis_rural_emergency_count)
tab lcis_rural_secure, m

gen lcis_rural_stress 			= (lcis_rural_stress_count > 0 & lcis_rural_crisis_count == 0 & lcis_rural_emergency_count == 0)
replace lcis_rural_stress		= .m if mi(lcis_rural_stress_count) | mi(lcis_rural_crisis_count) | mi(lcis_rural_emergency_count)
tab lcis_rural_stress, m

gen lcis_rural_crisis 			= (lcis_rural_crisis_count > 0 & lcis_rural_emergency_count == 0)
replace lcis_rural_crisis		= .m if mi(lcis_rural_crisis_count) | mi(lcis_rural_emergency_count)
tab lcis_rural_crisis, m

gen lcis_rural_emergency 		= (lcis_rural_emergency_count > 0)
replace lcis_rural_emergency	= .m if mi(lcis_rural_emergency_count)
tab lcis_rural_emergency, m

lab var lcis_rural_secure		"LCSI (Rural) - secure"
lab var lcis_rural_stress		"LCSI (Rural) - stress"
lab var lcis_rural_crisis		"LCSI (Rural) - crisis"
lab var lcis_rural_emergency 	"LCSI (Rural) - emergency"

// Less strict code apply - treat 0 for individual missing - if all variable are missing, don't account that obs 
// Using the MCCT baseline code 
egen lcis_stress_count_l		= rowtotal(lcope_assets lcope_animals_more lcope_spent_saveing lcope_borrow)
replace lcis_stress_count_l 	= .m if mi(lcope_assets) & mi(lcope_animals_more) & mi(lcope_spent_saveing) & mi(lcope_borrow)
tab lcis_stress_count_l, m

egen lcis_crisis_count_l		= rowtotal(lcope_transport lcope_school_withdrew lcope_reduce_expense)
replace lcis_crisis_count_l 	= .m if mi(lcope_transport) & mi(lcope_school_withdrew) & mi(lcope_reduce_expense)
tab lcis_crisis_count_l, m

egen lcis_emergency_count_l		= rowtotal(lcope_land lcope_animals_female lcope_begged)
replace lcis_emergency_count_l 	= .m if mi(lcope_land) & mi(lcope_animals_female) & mi(lcope_begged)
tab lcis_emergency_count_l, m

gen lcis_secure_l			= (lcis_stress_count_l == 0 & lcis_crisis_count_l == 0 & lcis_emergency_count_l == 0)
replace lcis_secure_l		= .m if mi(lcis_stress_count_l) & mi(lcis_crisis_count_l) & mi(lcis_emergency_count_l)
tab lcis_secure_l, m

gen lcis_stress_l 			= (lcis_stress_count_l > 0 & lcis_crisis_count_l == 0 & lcis_emergency_count_l == 0)
replace lcis_stress_l		= .m if mi(lcis_stress_count_l) & mi(lcis_crisis_count_l) & mi(lcis_emergency_count_l)
tab lcis_stress_l, m

gen lcis_crisis_l 			= (lcis_crisis_count_l > 0 & lcis_emergency_count_l == 0)
replace lcis_crisis_l		= .m if mi(lcis_crisis_count_l) & mi(lcis_emergency_count_l)
tab lcis_crisis_l, m

gen lcis_emergency_l 		= (lcis_emergency_count_l > 0)
replace lcis_emergency_l	= .m if mi(lcis_emergency_count_l)
tab lcis_emergency_l, m

** reporting variables **
lab var lcis_secure_l		"livelihood based CSI - secure"
lab var lcis_stress_l		"livelihood based CSI - stress"
lab var lcis_crisis_l		"livelihood based CSI - crisis"
lab var lcis_emergency_l 	"livelihood based CSI - emergency"

// Rural context based index
egen lcis_rural_stress_count_l		= rowtotal(lcope_assets lcope_animals_more lcope_spent_saveing) 
* missing one factor -  Sent household members to eat elsewhere due to lack of food  
replace lcis_rural_stress_count_l 	= .m if mi(lcope_assets) & mi(lcope_animals_more) & mi(lcope_spent_saveing)
tab lcis_rural_stress_count_l, m

egen lcis_rural_crisis_count_l		= rowtotal(lcope_crops lcope_sell_seed lcope_reduce_inputs)
replace lcis_rural_crisis_count_l 	= .m if mi(lcope_crops) & mi(lcope_sell_seed) & mi(lcope_reduce_inputs)
tab lcis_rural_crisis_count_l, m

egen lcis_rural_emergency_count_l		= rowtotal(lcope_land lcope_animals_female lcope_begged)
replace lcis_rural_emergency_count_l 	= .m if mi(lcope_land) & mi(lcope_animals_female) & mi(lcope_begged)
tab lcis_rural_emergency_count_l, m

gen lcis_rural_secure_l			= (lcis_rural_stress_count_l == 0 & lcis_rural_crisis_count_l == 0 & lcis_rural_emergency_count_l == 0)
replace lcis_rural_secure_l		= .m if mi(lcis_rural_stress_count_l) & mi(lcis_rural_crisis_count_l) & mi(lcis_rural_emergency_count_l)
tab lcis_rural_secure_l, m

gen lcis_rural_stress_l 		= (lcis_rural_stress_count_l > 0 & lcis_rural_crisis_count_l == 0 & lcis_rural_emergency_count_l == 0)
replace lcis_rural_stress_l		= .m if mi(lcis_rural_stress_count_l) & mi(lcis_rural_crisis_count_l) & mi(lcis_rural_emergency_count_l)
tab lcis_rural_stress_l, m

gen lcis_rural_crisis_l 		= (lcis_rural_crisis_count_l > 0 & lcis_rural_emergency_count_l == 0)
replace lcis_rural_crisis_l		= .m if mi(lcis_rural_crisis_count_l) & mi(lcis_rural_emergency_count_l)
tab lcis_rural_crisis_l, m

gen lcis_rural_emergency_l 		= (lcis_rural_emergency_count_l > 0)
replace lcis_rural_emergency_l	= .m if mi(lcis_rural_emergency_count_l)
tab lcis_rural_emergency_l, m

lab var lcis_rural_secure_l		"LCSI (Rural) - secure"
lab var lcis_rural_stress_l		"LCSI (Rural) - stress"
lab var lcis_rural_crisis_l		"LCSI (Rural) - crisis"
lab var lcis_rural_emergency_l 	"LCSI (Rural) - emergency"

********************************************************************************
** K. Water, Sanitation and Hygiene (WASH) **
********************************************************************************
// handwash_food handwash_meal handwash_feeding handwash_toilet handwash_faecal 
replace handwash_meal = "1.လက်ဆေးပါသည်" if handwash_meal == "လက်ဆေးပါသည်"

foreach var of varlist handwash_food handwash_meal handwash_feeding handwash_toilet handwash_faecal {
    
	tab `var', m 
    split `var', p(".")
	drop `var'2
	order `var'1, after(`var')
	drop `var'
	rename `var'1 `var'
	destring `var', replace 
	replace `var' = .n if mi(`var')
	replace `var' = .d if `var' == 888
	replace `var' = .r if `var' == 999
	replace `var' = 0 if `var' == 2
	tab `var', m 
}

// ref: // https://www.wsp.org/sites/wsp.org/files/publications/WSP-Practical-Guidance-Measuring-Handwashing-Behavior-2013-Update.pdf
egen handwash_critical_sum		= rowtotal(handwash_food handwash_meal handwash_feeding handwash_toilet handwash_faecal), missing
replace handwash_critical_sum 	= .m if mi(handwash_food) | mi(handwash_meal) | mi(handwash_feeding) | mi(handwash_toilet) | mi(handwash_faecal)
tab handwash_critical_sum, m  

gen handwash_critical 		= (handwash_critical_sum > 0)
replace handwash_critical 	= .m if mi(handwash_critical_sum)
tab handwash_critical, m 

lab var handwash_food		"Before food preparation"
lab var handwash_meal 		"Before having meal"
lab var handwash_feeding 	"Before feeding to child"
lab var handwash_toilet 	"After going to toilet"
lab var handwash_faecal 	"After handling child fecal matters"
lab var handwash_critical	"Handwashing at critical times"

// dispose_faeces dispose_faeces_1 dispose_faeces_2 dispose_faeces_3 dispose_faeces_999 dispose_faeces_777 
tab dispose_faeces, m 
moss dispose_faeces, match("([0-9]+)") regex

drop _pos*
sum _count

forval x = 1/`r(max)' {
	destring _match`x', replace
	rename _match`x' dispose_faeces`x'
}

drop _count

local num 1 2 3 777  

foreach x in `num'{
	tab dispose_faeces_`x', m 
	drop dispose_faeces_`x'
	gen dispose_faeces_`x' = (dispose_faeces1 == `x' | ///
						  dispose_faeces2 == `x' | ///
						  dispose_faeces3 == `x')
	replace dispose_faeces_`x' = .r if dispose_faeces1 == 999
	replace dispose_faeces_`x' = .m if mi(dispose_faeces)
	order dispose_faeces_`x', before(veg_source_oth)
	tab dispose_faeces_`x', m
}

replace dispose_faeces_2 = 1 if dispose_faeces_oth_eng == "Beside the toilet in the backyard." | ///
								dispose_faeces_oth_eng == "Flushed in the toilet." | ///
								dispose_faeces_oth_eng == "He can go to the toilet by himself."

replace dispose_faeces_1 =  1 if 	dispose_faeces_oth_eng == "ခြုံထဲပစ်" | dispose_faeces_oth_eng == "Beside the house." | ///
									dispose_faeces_oth_eng == "Disposed outside of the yard." | ///
									dispose_faeces_oth_eng == "Disposed outside of the yard. Sometimes, the dog eats." | ///
									dispose_faeces_oth_eng == "Diposed outside." | ///
									dispose_faeces_oth_eng == "Disposed in the bushes" | ///
									dispose_faeces_oth_eng == "Disposed in the bushes beside the house." | ///
									dispose_faeces_oth_eng == "Disposed at the backyard." | ///
									dispose_faeces_oth_eng == "Disposed beside the house." | ///
									dispose_faeces_oth_eng == "Disposed near the tree around the bushes." | ///
									dispose_faeces_oth_eng == "Disposed near the house." | ///
									dispose_faeces_oth_eng == "Disposed beside the house and in the bushes." | ///
									dispose_faeces_oth_eng == "Disposed in the backyard." | ///
									dispose_faeces_oth_eng == "Disposed in the yard." | dispose_faeces_oth_eng == "Burned in the yard." | ///
									dispose_faeces_oth_eng == "Disposed as it is." | dispose_faeces_oth_eng == "Outside" | ///
									dispose_faeces_oth_eng == "Disposed in the bushes."

gen dispose_faeces_4 =	(dispose_faeces_oth_eng == "Washed with water." | dispose_faeces_oth_eng == "Washed clothes." | ///
						dispose_faeces_oth_eng == "အိမ်ပေါ်မှရေနှင့်ဆေးချ" | dispose_faeces_oth_eng == "Washed." | ///
						dispose_faeces_oth_eng == "Washed the dirty clothes with water." | ///
						dispose_faeces_oth_eng == "Washed the clothes in the stream." )
replace dispose_faeces_4 = .m if mi(dispose_faeces)
order dispose_faeces_4, before(veg_source_oth)
tab dispose_faeces_4, m


gen dispose_faeces_5 =	(dispose_faeces_oth_eng == "In the hole." | dispose_faeces_oth_eng == "In the trash hole." | ///
						dispose_faeces_oth_eng == "In the old well." | dispose_faeces_oth_eng == "Disposed in the hole." | ///
						dispose_faeces_oth_eng == "In the dirt hole." | dispose_faeces_oth_eng == "Burned in the hole." | ///
						dispose_faeces_oth_eng == "Disposed in the trash hole." | ///
						dispose_faeces_oth_eng == "Disposed in the hole and burned.")
replace dispose_faeces_5 = .m if mi(dispose_faeces)
order dispose_faeces_5, before(veg_source_oth)
tab dispose_faeces_5, m

replace dispose_faeces_777 = 0 if 	dispose_faeces_oth_eng == "Beside the toilet in the backyard." | ///
									dispose_faeces_oth_eng == "Flushed in the toilet." | ///
									dispose_faeces_oth_eng == "He can go to the toilet by himself." | ///
									dispose_faeces_oth_eng == "ခြုံထဲပစ်" | dispose_faeces_oth_eng == "Beside the house." | ///
									dispose_faeces_oth_eng == "Disposed outside of the yard." | ///
									dispose_faeces_oth_eng == "Disposed outside of the yard. Sometimes, the dog eats." | ///
									dispose_faeces_oth_eng == "Diposed outside." | ///
									dispose_faeces_oth_eng == "Disposed in the bushes" | ///
									dispose_faeces_oth_eng == "Disposed in the bushes beside the house." | ///
									dispose_faeces_oth_eng == "Disposed at the backyard." | ///
									dispose_faeces_oth_eng == "Disposed beside the house." | ///
									dispose_faeces_oth_eng == "Disposed near the tree around the bushes." | ///
									dispose_faeces_oth_eng == "Disposed near the house." | ///
									dispose_faeces_oth_eng == "Disposed beside the house and in the bushes." | ///
									dispose_faeces_oth_eng == "Disposed in the backyard." | ///
									dispose_faeces_oth_eng == "Disposed in the yard." | dispose_faeces_oth_eng == "Burned in the yard." | ///
									dispose_faeces_oth_eng == "Disposed as it is." | dispose_faeces_oth_eng == "Outside" | ///
									dispose_faeces_oth_eng == "Disposed in the bushes." | dispose_faeces_oth_eng == "Washed with water." | ///
									dispose_faeces_oth_eng == "Washed clothes." | dispose_faeces_oth_eng == "အိမ်ပေါ်မှရေနှင့်ဆေးချ" | ///
									dispose_faeces_oth_eng == "Washed." | dispose_faeces_oth_eng == "Washed the dirty clothes with water." | ///
									dispose_faeces_oth_eng == "Washed the clothes in the stream." | ///
									dispose_faeces_oth_eng == "In the hole." | dispose_faeces_oth_eng == "In the trash hole." | ///
									dispose_faeces_oth_eng == "In the old well." | dispose_faeces_oth_eng == "Disposed in the hole." | ///
									dispose_faeces_oth_eng == "In the dirt hole." | dispose_faeces_oth_eng == "Burned in the hole." | ///
									dispose_faeces_oth_eng == "Disposed in the trash hole." | ///
									dispose_faeces_oth_eng == "Disposed in the hole and burned."
						
lab var dispose_faeces_1	"Bury them in the yard"
lab var dispose_faeces_2 	"Dispose in the toilet"
lab var dispose_faeces_3 	"Dispose in the litter"
lab var dispose_faeces_4	"Wash with water"
lab var dispose_faeces_5	"Bury in the hole"
lab var dispose_faeces_777	"Other methods"

// dispose_faeces_oth 
tab dispose_faeces_oth, m 

preserve
keep if dispose_faeces_777 == 1
if _N > 0 {
	export 	excel $respinfo dispose_faeces_oth using "$out/mother_other_specify.xlsx", ///
			sheet("dispose_faeces_oth") firstrow(varlabels) sheetreplace 
}
restore

// water_soruce 
tab water_soruce, m 

// water_soruce_dup_1 water_soruce_dup_2 water_soruce_dup_3 water_soruce_dup_4 water_soruce_dup_5 water_soruce_dup_6 water_soruce_dup_7 water_soruce_dup_8 water_soruce_dup_9 water_soruce_dup_10 water_soruce_dup_11 water_soruce_dup_12 water_soruce_dup_13 water_soruce_dup_888 water_soruce_dup_999 water_soruce_dup_777 

// water_soruce_1 water_soruce_2 water_soruce_3 water_soruce_4 water_soruce_5 water_soruce_6 water_soruce_7 water_soruce_8 water_soruce_9 water_soruce_10 water_soruce_11 water_soruce_12 water_soruce_888 water_soruce_999 water_soruce_777 

local num 1 2 3 4 5 6 7 8 9 10 11 12 888 999 777

foreach x in `num'{
	di `x'
	count if water_soruce_dup_`x' != water_soruce_`x'
}

drop water_soruce_dup_1 water_soruce_dup_2 water_soruce_dup_3 water_soruce_dup_4 water_soruce_dup_5 water_soruce_dup_6 water_soruce_dup_7 water_soruce_dup_8 water_soruce_dup_9 water_soruce_dup_10 water_soruce_dup_11 water_soruce_dup_12 water_soruce_dup_888 water_soruce_dup_999 water_soruce_dup_777 

rename water_soruce_dup_13 water_soruce_13

tab water_soruce, m 
moss water_soruce, match("([0-9]+)") regex

drop _pos*
sum _count

forval x = 1/`r(max)' {
	destring _match`x', replace
	rename _match`x' water_soruce`x'
}

drop _count

local num 1 2 3 4 5 6 7 8 9 10 11 12 13 777  

foreach x in `num'{
	tab water_soruce_`x', m 
	drop water_soruce_`x'
	gen water_soruce_`x' = (water_soruce1 == `x' | ///
							water_soruce2 == `x' | ///
							water_soruce3 == `x')
	replace water_soruce_`x' = .r if water_soruce1 == 999
	replace water_soruce_`x' = .d if water_soruce1 == 888
	replace water_soruce_`x' = .m if mi(water_soruce)
	order water_soruce_`x', before(water_soruce_oth)
	tab water_soruce_`x', m
}

// water_soruce
replace water_soruce_10 = 1 if 	water_soruce_oth_eng == "Water pipe connected from the mountain." | ///
								water_soruce_oth_eng == "Spring water"

replace water_soruce_11 = 1 if	water_soruce_oth_eng == "Rain water"

replace water_soruce_3 =  1 if water_soruce_oth_eng == "Neighbor's public tap"

replace water_soruce_7 = 1 if water_soruce_oth_eng == "Protected public well"

replace water_soruce_8 = 1 if 	water_soruce_oth_eng == "Public well" | water_soruce_oth_eng == "Neighbor's well" | ///
								water_soruce_oth_eng == "Well in the yard" | water_soruce_oth_eng == "Well" | ///
								water_soruce_oth_eng == "Borehole (Own)" | water_soruce_oth_eng == "Own borehole" | ///
								water_soruce_oth_eng == "Neighbor's borehole" | water_soruce_oth_eng == "Borehole" | ///
								water_soruce_oth_eng == "As having no well at home, have to use other people house's well."


replace water_soruce_777 = 0 if 	water_soruce_oth_eng == "Water pipe connected from the mountain." | ///
									water_soruce_oth_eng == "Spring water" | water_soruce_oth_eng == "Rain water" | ///
									water_soruce_oth_eng == "Neighbor's public tap" | ///
									water_soruce_oth_eng == "Protected public well" | water_soruce_oth_eng == "Public well" | ///
									water_soruce_oth_eng == "Neighbor's well" | ///
									water_soruce_oth_eng == "Well in the yard" | water_soruce_oth_eng == "Well" | ///
									water_soruce_oth_eng == "Borehole (Own)" | water_soruce_oth_eng == "Own borehole" | ///
									water_soruce_oth_eng == "Neighbor's borehole" | water_soruce_oth_eng == "Borehole" | ///
									water_soruce_oth_eng == "As having no well at home, have to use other people house's well."
							
								
lab var water_soruce_1 "Piped water into dwelling"
lab var water_soruce_2 "Piped water into yard/plot"
lab var water_soruce_3 "Public tap/standpipe"
lab var water_soruce_4 "Cart with small tank/drum"
lab var water_soruce_5 "Tanker/truck"
lab var water_soruce_6 "Tube well/borehole"
lab var water_soruce_7 "Protected dug well "
lab var water_soruce_8 "Unprotected dug well"
lab var water_soruce_9 "Protected spring"
lab var water_soruce_10 "Unprotected spring"
lab var water_soruce_11 "Rainwater collection"
lab var water_soruce_12 "Bottled purified water"
lab var water_soruce_13 "Surface water"
lab var water_soruce_777 "Other sources"
			
// water_soruce_oth 
tab water_soruce_oth, m 

preserve
keep if water_soruce_777 == 1
if _N > 0 {
	export 	excel $respinfo water_soruce_oth using "$out/mother_other_specify.xlsx", ///
			sheet("water_soruce_oth") firstrow(varlabels) sheetreplace 
}
restore

** Water Service Ladder ** 
// ref: https://washdata.org/monitoring/drinking-water
gen water_surface = (water_soruce_13 == 1)
replace water_surface = .m if mi(water_soruce_13)
tab water_surface, m 

gen water_limited		= (	water_soruce_1 == 1 | water_soruce_2 == 1 | water_soruce_3 == 1 | ///
							water_soruce_4 == 1 | water_soruce_5 == 1 | water_soruce_6 == 1 | ///
							water_soruce_7 == 1 | water_soruce_9 == 1 | water_soruce_11 == 1 | ///
							water_soruce_12 == 1)
replace water_limited 	= .m if mi(water_soruce_1) & mi(water_soruce_2) & mi(water_soruce_3) & ///
								mi(water_soruce_4) & mi(water_soruce_5) & mi(water_soruce_6) & ///
								mi(water_soruce_7) & mi(water_soruce_9) & mi(water_soruce_11) & ///
								mi(water_soruce_12)
tab water_limited, m 


gen water_unimprove 	= (water_soruce_8 == 1 | water_soruce_10 == 1 | water_soruce_777 == 1) 
replace water_unimprove = .m if mi(water_soruce_8) & mi(water_soruce_10) & mi(water_soruce_777)
tab water_unimprove, m 

lab var water_limited	"Drinking water - limited"
lab var water_unimprove	"Drinking water - unimproved"
lab var water_surface	"Drinking water - surface water"

// water_treat water_treat_1 water_treat_2 water_treat_3 water_treat_4 water_treat_5 water_treat_6 water_treat_7 water_treat_8 water_treat_9 water_treat_888 water_treat_999 water_treat_777

// ref: https://www.cdc.gov/safewater/manual/sws_manual.pdf
tab water_treat, m 
moss water_treat, match("([0-9]+)") regex

drop _pos*
sum _count

forval x = 1/`r(max)' {
	destring _match`x', replace
	rename _match`x' water_treat`x'
}

drop _count

local num 1 2 3 4 5 6 7 8 9 777  

foreach x in `num'{
	tab water_treat_`x', m 
	drop water_treat_`x'
	gen water_treat_`x' = (	water_treat1 == `x' | ///
							water_treat2 == `x' | ///
							water_treat3 == `x')
	replace water_treat_`x' = .r if water_treat1 == 999
	replace water_treat_`x' = .d if water_treat1 == 888
	replace water_treat_`x' = .m if mi(water_treat)
	order water_treat_`x', before(water_treat_oth)
	tab water_treat_`x', m
}

replace water_treat_9 = 1 if 	water_treat_oth_eng == "Drink normal water_not boiled" | ///
								water_treat_oth_eng == "No treatment" | water_treat_oth_eng == "Drink normal water" | ///
								water_treat_oth_eng == "Borewell"

replace water_treat_5 = 1 if	water_treat_oth_eng == "Use filter bought from the market" | ///
								water_treat_oth_eng == "Use filter bought from the shop"


replace water_treat_777 = 0 if 	water_treat_oth_eng == "Drink normal water_not boiled" | ///
								water_treat_oth_eng == "No treatment" | water_treat_oth_eng == "Drink normal water" | ///
								water_treat_oth_eng == "Borewell" | water_treat_oth_eng == "Use filter bought from the market" | ///
								water_treat_oth_eng == "Use filter bought from the shop"
								
lab var water_treat_1 "Boil"
lab var water_treat_2 "Add bleach/chlorine"
lab var water_treat_3 "Add iodine"
lab var water_treat_4 "Strain it through a cloth"
lab var water_treat_5 "Use a water filter"
lab var water_treat_6 "Composite filters"
lab var water_treat_7 "Solar disinfection"
lab var water_treat_8 "Let it stand and settle"
lab var water_treat_9 "Nothing (drink it as is)"
lab var water_treat_777	"Other methods"


// water_treat_oth 
tab water_treat_oth, m 

preserve
keep if water_treat_777 == 1
if _N > 0 {
	export 	excel $respinfo water_treat_oth using "$out/mother_other_specify.xlsx", ///
			sheet("water_treat_oth") firstrow(varlabels) sheetreplace 
}
restore


// ref: https://cdn.who.int/media/docs/default-source/wash-documents/wash-chemicals/iodine-02032018.pdf?sfvrsn=4d414c11_5
// ref: HWTS: https://sswm.info/sswm-solutions-bop-markets/affordable-wash-services-and-products/affordable-water-supply/household-water-treatment-and-safe-storage-%28hwts%29#:~:text=According%20to%20the%20WHO%20(WHO,taken%20up%20by%20vulnerable%20populations.

gen water_treat_yes = (water_treat_9 != 1)
replace water_treat_yes = .m if mi(water_treat_9)
lab var water_treat_yes "Water treatment"
tab water_treat_yes, m

gen water_treat_effective 		= (	water_treat_1 == 1 | water_treat_2 == 1 | ///
									water_treat_3 == 1 | water_treat_4 == 1 | ///
									water_treat_5 == 1 | water_treat_6 == 1 | ///
									water_treat_7 == 1)
replace water_treat_effective 	= .m if mi(water_treat_1) | mi(water_treat_2) | ///
										mi(water_treat_3) | mi(water_treat_4) | ///
										mi(water_treat_5) | mi(water_treat_6) | ///
										mi(water_treat_7)
lab var water_treat_effective "Use effective water treatment"
tab water_treat_effective, m 

// latrines_type latrines_type_1 latrines_type_2 latrines_type_3 latrines_type_4 latrines_type_5 latrines_type_6 latrines_type_888 latrines_type_999 latrines_type_777 

tab latrines_type, m 
moss latrines_type, match("([0-9]+)") regex

drop _pos*
sum _count

forval x = 1/`r(max)' {
	destring _match`x', replace
	rename _match`x' latrines_type`x'
}

drop _count

local num 1 2 3 4 5 6 777  

foreach x in `num'{
	tab latrines_type_`x', m 
	drop latrines_type_`x'
	gen latrines_type_`x' = (latrines_type1 == `x' | ///
							 latrines_type2 == `x' | ///
						     latrines_type3 == `x')
	replace latrines_type_`x' = .r if latrines_type1 == 999
	replace latrines_type_`x' = .d if latrines_type1 == 888
	replace latrines_type_`x' = .m if mi(latrines_type)
	order latrines_type_`x', before(latrines_type_oth)
	tab latrines_type_`x', m
}

lab var latrines_type_1 	"Water flush with septic tank"
lab var latrines_type_2 	"Water flush without tank"
lab var latrines_type_3 	"Pit latrine fly proof"
lab var latrines_type_4 	"Pit latrine not fly proof"
lab var latrines_type_5 	"Latrine above water (or floating)"
lab var latrines_type_6 	"Open space (open defecation)"
lab var latrines_type_777	"Other type of latrines"	

// latrines_type_oth 
tab latrines_type_oth, m 

preserve
keep if latrines_type_777 == 1
if _N > 0 {
	export 	excel $respinfo latrines_type_oth using "$out/mother_other_specify.xlsx", ///
			sheet("latrines_type_oth") firstrow(varlabels) sheetreplace 
}
restore

// latrines_use_othhh 
tab latrines_use_othhh, m 

split latrines_use_othhh, p(".")
drop latrines_use_othhh2
order latrines_use_othhh1, after(latrines_use_othhh)
drop latrines_use_othhh
rename latrines_use_othhh1 latrines_use_othhh
destring latrines_use_othhh, replace 
replace latrines_use_othhh = .n if mi(latrines_use_othhh)
replace latrines_use_othhh = .r if latrines_use_othhh == 999
replace latrines_use_othhh = .n if latrines_use_othhh == 444
replace latrines_use_othhh = 0 if latrines_use_othhh == 2
lab var latrines_use_othhh "Share toilet with outside of HH"
tab latrines_use_othhh, m 

** Sanitation Service Ladder ** 
// ref: https://washdata.org/monitoring/sanitation
gen latrine_basic 		= ((latrines_type_1 == 1 | latrines_type_2 == 1 | ///
							latrines_type_3 == 1) & latrines_use_othhh == 0)
replace latrine_basic 	= .m if mi(latrines_type_1) | mi(latrines_type_2) | /// 
								mi(latrines_type_3) | mi(latrines_use_othhh)
tab latrine_basic, m 


gen latrine_limited		= ((latrines_type_1 == 1 | latrines_type_2 == 1 | ///
							latrines_type_3 == 1) & latrines_use_othhh == 1)
replace latrine_limited 	= .m if mi(latrines_type_1) | mi(latrines_type_2) | /// 
								mi(latrines_type_3) | mi(latrines_use_othhh)
tab latrine_limited, m 


gen latrine_unimprove		= (	latrines_type_4 == 1 | latrines_type_5 == 1 | ///
								latrines_type_777 == 1)
replace latrine_unimprove	= .m if mi(latrines_type_4) | mi(latrines_type_5) | ///
									mi(latrines_type_777)
tab latrine_unimprove, m 

gen latrine_opendef 	= (latrines_type_6 == 1)
replace latrine_opendef = .m if mi(latrines_type_6)
tab latrine_opendef, m 

lab var latrine_basic 			"latrine - basic" 
lab var latrine_limited 		"latrine - limited"
lab var latrine_unimprove 		"latrine - unimproved"
lab var latrine_opendef			"latrine - open defication"

// handwash_facility 
// technical note: not able to calculate standard indicator
// ref - https://washdata.org/monitoring/hygiene
tab handwash_facility, m 

split handwash_facility, p(".")
drop handwash_facility2
order handwash_facility1, after(handwash_facility)
drop handwash_facility
rename handwash_facility1 handwash_facility
destring handwash_facility, replace 
replace handwash_facility = .n if mi(handwash_facility)
replace handwash_facility = .r if handwash_facility == 999
replace handwash_facility = 0 if handwash_facility == 2
lab var handwash_facility "HH access to handwashing facilities"
tab handwash_facility, m 

		
********************************************************************************
** L. Psychosocial wellbeing screening **
********************************************************************************
// l_note
tab l_note, m 
drop l_note

// wellb_less_interest wellb_depress wellb_sleeping wellb_tired wellb_eating wellb_failure wellb_concentration wellb_locomotion wellb_self_hurting wellb_anxious wellb_notcontrol wellb_worrying wellb_relaxing wellb_restless wellb_irritable wellb_afraid 

local wellbeing	wellb_less_interest wellb_depress wellb_sleeping wellb_tired ///
				wellb_eating wellb_failure wellb_concentration wellb_locomotion ///
				wellb_self_hurting wellb_anxious wellb_notcontrol wellb_worrying ///
				wellb_relaxing wellb_restless wellb_irritable wellb_afraid 

foreach var in `wellbeing' {
    tab `var', m 
	replace `var' = "1" if `var' == "လုံးဝမဖြစ်ခဲ့ Not at all"
	replace `var' = "2" if `var' == "၁-၆ ရက်အတွင်း  1-6 Days"
	replace `var' = "3" if `var' == "၇ ရက် နှင့် အထက် More than half the days"
	replace `var' = "4" if `var' == "နေ့တိုင်း နီးပါး Nearly everyday"
	destring `var', replace 
	tab `var', m 

	forvalue x = 1/4{
		gen `var'_`x' = (`var' == `x')
		replace `var'_`x' = .m if mi(`var')
		tab `var'_`x', m 
		
		if `x' == 1 {
		    lab var `var'_`x' "Not at all"
		}
		else if `x' == 2 {
		    lab var `var'_`x' "1-6 Days"
		}
		else if `x' == 3 {
		    lab var `var'_`x' "More than half the days"
		}
		else if `x' == 4 {
		    lab var `var'_`x' "Nearly everyday"
		}
	}

}

lab var wellb_less_interest 	"Little interest or pleasure in doing things"
lab var wellb_depress 			"Feeling down, depressed or hopeless"
lab var wellb_sleeping 			"Sleeping disorder"
lab var wellb_tired 			"Feeling tired or having little energy"
lab var wellb_eating 			"Eating disorder"
lab var wellb_failure 			"Feeling bad about yourself"
lab var wellb_concentration 	"Trouble concentrating on things"
lab var wellb_locomotion 		"Changes in moving or speaking"
lab var wellb_self_hurting 		"Thoughts that you would be better off dead"
lab var wellb_anxious 			"Feeling nervous, anxious or on edge"
lab var wellb_notcontrol 		"Not being able to stop or control worrying"
lab var wellb_worrying 			"Worrying too much about different things"
lab var wellb_relaxing 			"Trouble relaxing"
lab var wellb_restless 			"Being so restless it is hard to sit sill"
lab var wellb_irritable 		"Becoming easily annoyed or irritable"
lab var wellb_afraid 			"Feeling afraid as if something awful might happen"


// Patient Health Questionnaire (PHQ-9)
local phq	wellb_less_interest wellb_depress wellb_sleeping wellb_tired ///
			wellb_eating wellb_failure wellb_concentration wellb_locomotion ///
			wellb_self_hurting 		
			
foreach var in `phq'{
    recode `var' (1 = 0) (2 = 1) (3 = 2) (4 = 3), gen(`var'_rc) 
	tab `var'_rc, m 
}

egen phq_tot = rowtotal(wellb_less_interest_rc wellb_depress_rc wellb_sleeping_rc ///
						wellb_tired_rc wellb_eating_rc wellb_failure_rc ///
						wellb_concentration_rc wellb_locomotion_rc wellb_self_hurting_rc )


//replace phq_tot = round(phq_tot/27, 0.1)
tab phq_tot, m 

//Depression Severity: 0-4 none, 5-9 mild, 10-14 moderate, 15-19 moderately severe, 20-27 severe.

gen depression_non = (phq_tot < 5)
replace depression_non = .m if mi(phq_tot)
lab var depression_non "Depression: None"
tab depression_non, m 

gen depression_mild = (phq_tot >= 5 & phq_tot < 10)
replace depression_mild = .m if mi(phq_tot)
lab var depression_mild "Depression: Mild"
tab depression_mild, m 

gen depression_moderate = (phq_tot >= 10 & phq_tot < 15)
replace depression_moderate = .m if mi(phq_tot)
lab var depression_moderate "Depression: Moderate"
tab depression_moderate, m 

gen depression_modsevere = (phq_tot >= 15 & phq_tot < 20)
replace depression_modsevere = .m if mi(phq_tot)
lab var depression_modsevere "Depression: Moderately severe"
tab depression_modsevere, m 

gen depression_severe = (phq_tot >= 20)
replace depression_severe = .m if mi(phq_tot)
lab var depression_severe "Depression: Severe"
tab depression_severe, m 

// depression_non depression_mild depression_moderate depression_modsevere depression_severe

// Generalised Anxiety Disorder Assessment (GAD-7)
local gad	wellb_anxious wellb_notcontrol wellb_worrying wellb_relaxing ///
			wellb_restless wellb_irritable wellb_afraid 			

foreach var in `gad'{
    recode `var' (1 = 0) (2 = 1) (3 = 2) (4 = 3), gen(`var'_rc) 
	tab `var'_rc, m 
}

egen gad_tot = rowtotal(wellb_anxious_rc wellb_notcontrol_rc wellb_worrying_rc ///
						wellb_relaxing_rc wellb_restless_rc wellb_irritable_rc ///
						wellb_afraid_rc)
//replace gad_tot = round(gad_tot/21, 0.1)
tab gad_tot, m 

//Scores of 5, 10, and 15 are taken as the cut-off points for mild, moderate and severe anxiety, respectively. 

gen anxiety_non = (gad_tot < 5)
replace anxiety_non = .m if mi(gad_tot)
lab var anxiety_non "Anxiety: None"
tab anxiety_non, m 

gen anxiety_mild = (gad_tot >= 5 & gad_tot < 10)
replace anxiety_mild = .m if mi(gad_tot)
lab var anxiety_mild "Anxiety: Mild"
tab anxiety_mild, m 

gen anxiety_moderate = (gad_tot >= 10 & gad_tot < 15)
replace anxiety_moderate = .m if mi(gad_tot)
lab var anxiety_moderate "Anxiety: Moderate"
tab anxiety_moderate, m 

gen anxiety_severe = (gad_tot >= 15)
replace anxiety_severe = .m if mi(gad_tot)
lab var anxiety_severe "Anxiety: Severe"
tab anxiety_severe, m 

// anxiety_non anxiety_mild anxiety_moderate anxiety_severe

********************************************************************************
** M. Women empowerment **
********************************************************************************
// wempo_childcare wempo_mom_health wempo_child_health wempo_women_wages wempo_major_purchase wempo_visiting wempo_women_health wempo_child_wellbeing 

local wempower	wempo_childcare wempo_mom_health wempo_child_health wempo_women_wages ///
				wempo_major_purchase wempo_visiting wempo_women_health wempo_child_wellbeing 
				

				
foreach var in `wempower'{
    split `var', p(".")
	drop `var'2-`var'4
	order `var'1, after(`var')
	drop `var'
	rename `var'1 `var'
	destring `var', replace 
	replace `var' = .n if mi(`var')
	tab `var', m 
	
	forvalue x = 1/4 {
	    gen `var'_`x' = (`var' == `x')
		replace `var'_`x' = .m if mi(`var')
		tab `var'_`x', m 
		
		if `x' == 1 {
		lab var `var'_`x' "Woman alone"
		}
		else if `x' == 2 {
		    lab var `var'_`x' "Woman and husband/partner"
		}
		else if `x' == 3 {
		    lab var `var'_`x' "Husband/partner alone"
		}
		else if `x' == 4 {
		    lab var `var'_`x' "Someone else"
		}
	}
}		


lab var wempo_childcare 		"Feeding the children on a daily basis"
lab var wempo_mom_health 		"Maternal health in your household"
lab var wempo_child_health 		"Child health in your household"
lab var wempo_women_wages 		"Control over the woman’s earnings"
lab var wempo_major_purchase 	"Major household purchases"
lab var wempo_visiting 			"Visits to family or relatives"
lab var wempo_women_health 		"About the woman’s health care"
lab var wempo_child_wellbeing 	"Well-being of children in the household"

// wempo_group wempo_group_1 wempo_group_2 wempo_group_3 wempo_group_4 wempo_group_5 wempo_group_888 wempo_group_999 wempo_group_777 
tab wempo_group, m 
moss wempo_group, match("([0-9]+)") regex

drop _pos*
sum _count

forval x = 1/`r(max)' {
	destring _match`x', replace
	rename _match`x' wempo_group`x'
}

drop _count

local num 1 2 3 4 5 777  

foreach x in `num'{
	tab wempo_group_`x', m 
	drop wempo_group_`x'
	gen wempo_group_`x' = (wempo_group1 == `x' | ///
						  wempo_group2 == `x' | ///
						  wempo_group3 == `x' | ///
						  wempo_group4 == `x')
	replace wempo_group_`x' = .d if veg_source1 == 888
	replace wempo_group_`x' = .m if mi(wempo_group)
	order wempo_group_`x', before(wempo_group_oth)
	tab wempo_group_`x', m
}

lab var wempo_group_1		"None of the groups"
lab var wempo_group_2		"Religious group"
lab var wempo_group_3 		"Mother’s support group"
lab var wempo_group_4 		"Community development group"
lab var wempo_group_5 		"Village savings and loan group"
lab var wempo_group_777		"Other type of group"

// wempo_group_oth 
tab wempo_group_oth, m 

preserve
keep if wempo_group_777 == 1
if _N > 0 {
	export 	excel $respinfo wempo_group_oth using "$out/mother_other_specify.xlsx", ///
			sheet("wempo_group_oth") firstrow(varlabels) sheetreplace 
}
restore

// remark 
tab remark, m 

********************************************************************************
** WEIGHT CALCULATION **
********************************************************************************

** Prepare Dataset for Weight Calculation **
bysort org_name vill_name: gen survey_num = _N

drop _merge 

preserve 
bysort org_name vill_name: keep if _n == 1

keep org_name vill_name village_id survey_num u5_num

merge 1:m org_name vill_name using "$dta/proj_villages_info.dta"

gen mother_svy = (_merge == 3)
lab def mother_svy 1"mother survey finishe" 0"no mother survey"
lab val mother_svy mother_svy
tab mother_svy, m 

drop _merge 

* First stage - cluster weight * 
destring hh_tot, replace 

egen all_hh_tot = total(hh_tot)
tab all_hh_tot, m 

egen svy_hh_tot = total(hh_tot) if mother_svy == 1
tab svy_hh_tot, m 

gen cluster_prop = svy_hh_tot/all_hh_tot
replace cluster_prop = .m if mother_svy != 1
tab cluster_prop, m 

* Second stage - hh weight * 
gen hh_village_prop = mother_svy/hh_tot
replace hh_village_prop = .m if mother_svy != 1
tab hh_village_prop, m 

keep if mother_svy == 1
keep village_id cluster_prop hh_village_prop 

tempfile weight_svy
save `weight_svy', replace 
restore  

merge m:1 village_id using `weight_svy'

drop _merge 

* Thrid stage - child weight * 
* Thrid stage - child weight * 
gen child_hh_prop = 1/u5_num
tab child_hh_prop, m 

* Final weight * 
// for anthro obs weight
gen wt_final = 1/(cluster_prop * hh_village_prop)
lab var wt_final "Final weight - anthro"
tab wt_final, m 

// for u5 modules obs weight 
gen wt_u5module = 1/(cluster_prop * hh_village_prop * child_hh_prop)
lab var wt_u5module "Final weight - anthro"
tab wt_u5module, m 

********************************************************************************
** SAVE AS CLEANED DATASET **
********************************************************************************

// merge with village profile information 
preserve
use "$dta/VTHC_cleaned.dta", clear
keep hfc_type-vill_rutf_oth_eng vill_name-vill_telecoms4
tempfile vthc
save `vthc', replace 
restore 

merge m:1 village_id using `vthc'

drop if _merge == 2
drop _merge 

save "$dta/mothers_cleaned.dta", replace 

export excel using "$out/mothers_cleaned.xlsx", firstrow(variables) replace 

clear

********************************************************************************
** ADD CHILD ANTHRO DATASET WEIGHT **
********************************************************************************

use "$dta/child_anthro_cleaned.dta", clear

merge m:1 interview_id using "$dta/mothers_cleaned.dta", keepusing(wt_final village_id)

drop _merge 

save "$dta/child_anthro_cleaned.dta", replace 


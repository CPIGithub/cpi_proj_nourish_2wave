/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	create village participation index based on project monitoring data				
Author				:	Nicholus Tint Zaw
Date				: 	11/23/2024
Modified by			:


*******************************************************************************/

	********************************************************************************
	** Directory Settings **
	********************************************************************************

	do "$do/00_dir_setting.do"


	********************************************************************************
	* import population data *
	********************************************************************************
	* sampling frame - to use for merging data (minitoring vs sample weight dta)
	use "$dta/endline/endline_sampling_frame_vill_feasibility_status.dta", clear 
	
	duplicates drop vill_code, force 
	
	tempfile vill_code
	save `vill_code', replace 
	
	
	* use population figure applied in sampling - not the 2024 updated one
	* take from sample weight calculation file 
	use "$dta/endline/pnourish_midterm_vs_endline_hh_comparision_weight_final.dta", clear
	
	distinct township_name geo_eho_vt_name geo_eho_vill_name midterm_endline, joint 
	
	duplicates list township_name geo_eho_vt_name geo_eho_vill_name midterm_endline
	
	distinct vill_code midterm_endline, joint 

	bysort vill_code: keep if _n == 1
	
	distinct vill_code  
	
	distinct township_name geo_eho_vt_name geo_eho_vill_name, joint 
	
	drop township_name geo_eho_vt_name geo_eho_vill_name
		
	merge 1:1 	vill_code using ///
				`vill_code', ///
				keepusing(township_name geo_eho_vt_name geo_eho_vill_name) ///
				assert(2 3) keep(matched) nogen 

	sort township_name geo_eho_vt_name geo_eho_vill_name 

	duplicates tag township_name geo_eho_vt_name geo_eho_vill_name, gen(dup_villname)
	
	duplicates drop township_name geo_eho_vt_name geo_eho_vill_name, force 

	tempfile wtdta 
	save `wtdta', replace 
	
	
	** Midterm vs endline combined data (for village weight)
	* endline 
	use "$dta/endline/pnourish_WASH_final.dta", clear  
	
	gen midterm_endline = 1 
	
	append using "$dta/pnourish_WASH_final.dta"
	
	replace midterm_endline = 0 if mi(midterm_endline)
	tab midterm_endline, m 
	
	drop weight_final
	
	distinct geo_vill midterm_endline, joint 
	bysort geo_vill: keep if _n == 1
	
	keep geo_vill
	
	tempfile combined
	save `combined', replace 
	
	********************************************************************************
	* import monitoring data *
	********************************************************************************

	//import excel using "$raw/monitoring_data/PN_M&E_FORMATS_2023 data added_20241121.xlsx", describe

	//import excel using "$raw/monitoring_data/PN_M&E_FORMATS_2023 data added_20241121.xlsx", sheet("MSG") cellrange(B2) firstrow clear 
	
	** Use SBCC Data - most comprehensive and had more wider coverage 
	import excel using 	"$raw/monitoring_data/PN_M&E_FORMATS_2023 data added_20241121.xlsx", ///
						sheet("SBCC") cellrange(B2) firstrow clear ///
						case(lower)

	* var name 
	rename township 			township_name
	rename villagetracteho 		geo_eho_vt_name
	rename villagenameeho 		geo_eho_vill_name
	
	rename sbcctopic 			sbcc_topic
	rename attendance 			attend_tot
	rename attendancemale 		attend_m
	rename attendancefemale		attend_f 
	
	* update correct name 
	replace geo_eho_vt_name = vt_correct if !mi(vt_correct)
	replace geo_eho_vill_name = vill_correct if !mi(vill_correct)
	
	drop vt_correct vill_correct
	
	* drop missing obs lines 
	drop if mi(attend_tot) & mi(attend_m) & mi(attend_f)
	
	//bysort township_name geo_eho_vt_name geo_eho_vill_name: keep if _n == 1
	
	distinct township_name geo_eho_vt_name geo_eho_vill_name, joint 

	* get pop data 
	merge m:1 	township_name geo_eho_vt_name geo_eho_vill_name using `wtdta', ///
				keepusing(population geo_vill) keep(matched) nogen

	* date 
	replace date = "01-Jan-2023" if date == "Q1 2023"
	replace date = "01-Apr-2023" if date == "Q2 2023"
	replace date = "01-Jul-2023" if date == "Q3 2023"
	replace date = "01-Oct-2023" if date == "Q4 2023"
	
	* Generate a temporary variable for intermediate conversion
	generate temp_date = date

	* Convert dates in "dd-Mon-yy" format to "ddmmmyy" format
	replace temp_date = subinstr(temp_date, "-21", "-2021", .) 
	replace temp_date = subinstr(temp_date, "-22", "-2022", .) 
	replace temp_date = subinstr(temp_date, "-", "", .) // Remove hyphens
	replace temp_date = lower(temp_date) // Convert to lowercase

	* Convert to Stata date format, handling potential errors
	generate date_num = daily(temp_date, "DMY")
	format date_num %td
	
	* Generate quarterly variable
	gen quarter = quarter(date_num)
	gen year = year(date_num)
	egen quarterly_year = group(quarter year), label

	
	order temp_date date_num year quarter quarterly_year, after(date)

	* unique ID 
	sort township_name geo_eho_vt_name geo_eho_vill_name date_num quarterly_year sbcc_topic  
	
	distinct township_name geo_eho_vt_name geo_eho_vill_name sbcc_topic date_num, joint 
	
	duplicates tag township_name geo_eho_vt_name geo_eho_vill_name sbcc_topic date_num, gen(dup_obs)
	
	tab dup_obs, m 
	
	
	** Parameter preparation **
	** (1) SBCC Attendance Quartely **
	/*
	Because of the available datastructure - as some village info were record at the quartely level 
	it created some duplicate cases, but it is not duplicate in reality 
	
	So, create the maximum number at the quartely level
	*/
	
	** attendance numbers 
	local groups tot m f 
	local levels township_name geo_eho_vt_name geo_eho_vill_name quarterly_year
	
	foreach g in `groups' {
	    
		* replace missing with 0 
		replace attend_`g' = 0 if mi(attend_`g')
		
		bysort `levels': egen attend_`g'_max = max(attend_`g')
		tab attend_`g'_max, m 
	}
	
	** attendance percent by tot pop
	
	local groups attend_tot attend_m attend_f
	
	foreach var in `groups'  {
	    
		gen `var'_pct = (`var'_max/population)
		replace `var'_pct = .m if mi(`var'_max)
		
	}
	

	** (2) SBCC session **
	bysort `levels': gen vill_sbcc_tot = _N 
	tab vill_sbcc_tot, m 
	
	** (3) SBCC topic coverage - unique topics **		
	bysort `levels' sbcc_topic: keep if _n == 1
	
	bysort `levels': gen unique_topic = _N 
	
	tab unique_topic, m 
	
	bysort `levels': keep if _n == 1

	
	****************************************************************************
	** Village & Quartely Level Info **
	****************************************************************************
	
	distinct township_name geo_eho_vt_name geo_eho_vill_name quarterly_year, joint 
	
	** Index development
	* Standardising input variables
	foreach var of varlist attend_tot_pct attend_m_pct attend_f_pct vill_sbcc_tot unique_topic {
		
		// Z-score
		zindex `var', gen(`var'_z) 
		sum `var'*, d
	}
	
	
	* ICW - index 
	icw_index *z, gen(vill_part_icw)
	
	sum vill_part_icw, d 
	
	* Weight - adjustment 
	/*
	Weight Quarters by Data Availability
	Villages with fewer quarters should contribute less to the final score. 
	Assign weights proportional to the number of quarters recorded for the village.
	*/
	gen quarter_weight = (1/vill_sbcc_tot)
	
	bysort township_name geo_eho_vt_name geo_eho_vill_name : egen vill_sum_qrtwt = total(quarter_weight)
	
	/*
	Aggregate the ICW scores from each quarter into one final value for the village by taking a weighted average of the quarterly ICW values:
	*/
	
	gen weight_icw = (quarter_weight * vill_part_icw)
	bysort township_name geo_eho_vt_name geo_eho_vill_name : egen vill_sum_wticw = total(weight_icw)
	
	drop vill_part_icw
	
	gen vill_part_icw = (vill_sum_wticw/vill_sum_qrtwt)
	
	bysort township_name geo_eho_vt_name geo_eho_vill_name : keep if _n == 1
	
	sum vill_part_icw, d 
	
	/*
	Assign a Distinct Value for No Participation
	To clearly distinguish villages without participation from those with participation:

	Assign a unique value that is lower than the minimum possible ICW value. 
	For instance, a value of -1 or another arbitrarily low value can represent "no participation."
	This ensures that these villages are clearly differentiated when interpreting the index.
	
	*/
	
	merge 1:1 geo_vill using `combined'
	
	replace vill_part_icw = -1 if _merge == 2
	
	keep geo_vill vill_part_icw
	
	* save as final dataset 
	save "$dta/DiG/pn_svyvill_participation_icw_index.dta", replace   

	
	
	



	** For HFC distance imputation 

	use "$dta/pnourish_mom_health_analysis_final.dta", clear    
	
	merge m:1 _parent_index using "$dta/pnourish_WOMEN_EMPOWER_final.dta", ///
							keepusing(*_d_z) assert(2 3) keep(matched) nogen 
							
							
	merge m:1 _parent_index using "$dta/pnourish_respondent_info_final.dta", ///
							keepusing(township_name geo_eho_vt_name geo_eho_vill_name geo_town geo_vt) assert( 2 3) keep(matched) nogen

	order township_name geo_eho_vt_name geo_eho_vill_name geo_town geo_vt, before(geo_vill)

	* Check for the village where hfc distance missing
	preserve 
		
		bysort geo_vill: keep if !mi(hfc_near_dist)
		bysort geo_vill: keep if _n == 1
		
		encode township_name, gen(geo_town_int)
		
		svy: mean hfc_near_dist, over(geo_town_int)

		keep hfc_near_dist	stratum	geo_vill	township_name	geo_eho_vt_name	geo_eho_vill_name	geo_town	geo_vt	org_name_num

		export excel 	using "$out/HFC_Dist_Imputation_Info.xlsx", /// 
						sheet("HFC not missing") firstrow(varlabels) keepcellfmt sheetreplace 

	restore 

	preserve 
		
		bysort geo_vill: keep if mi(hfc_near_dist)
		bysort geo_vill: keep if _n == 1
		
		keep hfc_near_dist	stratum	geo_vill	township_name	geo_eho_vt_name	geo_eho_vill_name	geo_town	geo_vt	org_name_num

		export excel 	using "$out/HFC_Dist_Imputation_Info.xlsx", /// 
						sheet("HFC missing") firstrow(varlabels) keepcellfmt sheetreplace 

	restore 
	

	** Check for each township 
	// Kawkareik 
	tab geo_eho_vt_name hfc_near_dist if (township_name == "Kawkareik") & stratum == 1, m // 20 missing 
	
	count if geo_eho_vt_name == "Kha Nein Hpaw" & stratum == 1 & mi(hfc_near_dist) // 11 obs 
	count if geo_eho_vt_name == "Ka Yit Kyauk Tan" & stratum == 1 & mi(hfc_near_dist) // 9 obs, all village had missing value 
	
	tab geo_vill hfc_near_dist if geo_eho_vt_name == "Ka Yit Kyauk Tan", m // all missing 
	tab geo_vill hfc_near_dist if (township_name == "Kawkareik") & stratum == 1, m 
	
	replace hfc_near_dist = 1.5 if geo_eho_vt_name == "Kha Nein Hpaw" & stratum == 1 & mi(hfc_near_dist) // 11 obs 
	replace hfc_near_dist = 1.1 if geo_eho_vt_name == "Ka Yit Kyauk Tan" & stratum == 1 & mi(hfc_near_dist) // 9 obs, replace with mean value from township, drop after extreme distance 12.5 cases
	
	tab geo_eho_vt_name hfc_near_dist if (township_name == "Kawkareik") & stratum == 2, m // 0 obs 

	// Thandaunggyi
	tab geo_eho_vt_name hfc_near_dist if (township_name == "Thandaunggyi") & stratum == 1, m // no missing 
	
	tab geo_eho_vt_name hfc_near_dist if (township_name == "Thandaunggyi") & stratum == 2, m // 6 missing
	
	count if geo_eho_vt_name == "Bo Khar Lay Kho" & stratum == 2 & mi(hfc_near_dist) // 5 obs 
	count if geo_eho_vt_name == "Sho Kho" & stratum == 2 & mi(hfc_near_dist) // 1 obs 
	
	replace hfc_near_dist = 4 if geo_eho_vt_name == "Bo Khar Lay Kho" & stratum == 2 & mi(hfc_near_dist)
	replace hfc_near_dist = 4 if geo_eho_vt_name == "Sho Kho" & stratum == 2 & mi(hfc_near_dist)
	
	// Hpa-An
	tab geo_eho_vt_name hfc_near_dist if (township_name == "Hpa-An") & stratum == 1, m // 9 missing 
	
	count if geo_eho_vt_name == "Naung Pa Laing" & stratum == 1 & mi(hfc_near_dist) // 9 obs 
	replace hfc_near_dist = 1 if geo_eho_vt_name == "Naung Pa Laing" & stratum == 1 & mi(hfc_near_dist)
	
	tab geo_eho_vt_name hfc_near_dist if (township_name == "Hpa-An") & stratum == 2, m // no missing 
	
	// Hlaingbwe
	tab geo_eho_vt_name hfc_near_dist if (township_name == "Hlaingbwe") & stratum == 1, m // no missing 
	tab geo_eho_vt_name hfc_near_dist if (township_name == "Hlaingbwe") & stratum == 2, m // no missing 
	
	// Myawaddy
	tab geo_eho_vt_name hfc_near_dist if (township_name == "Myawaddy") & stratum == 1, m // no missing 
	tab geo_eho_vt_name hfc_near_dist if (township_name == "Myawaddy") & stratum == 2, m // no missing 

	// Kyainseikgyi
	tab geo_eho_vt_name hfc_near_dist if (township_name == "Kyainseikgyi") & stratum == 1, m // no missing 
	tab geo_eho_vt_name hfc_near_dist if (township_name == "Kyainseikgyi") & stratum == 2, m // no missing 

	// Kyaikmaraw
	tab geo_eho_vt_name hfc_near_dist if (township_name == "Kyaikmaraw") & stratum == 1, m // no missing 
	tab geo_eho_vt_name hfc_near_dist if (township_name == "Kyaikmaraw") & stratum == 2, m // no missing 
	
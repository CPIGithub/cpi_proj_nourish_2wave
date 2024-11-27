/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	endline prepration - randomization 			
Author				:	Nicholus Tint Zaw
Date				: 	5/8/2024
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "$do/00_dir_setting.do"

********************************************************************************
********************************************************************************

* Get midterm data 
use "$dta/pnourish_respondent_info_final.dta", clear

* Org name - correction 
replace org_name = "YSDA" if geo_eho_vt_name == "Naung Pa Laing" & geo_eho_vill_name == "Tadar Oo"
replace org_name = "YSDA" if geo_eho_vt_name == "Yae Kyaw" & geo_eho_vill_name == "Yay Kyaw Gyi"
replace org_name = "YSDA" if geo_eho_vt_name == "Myaing Ka Lay" & geo_eho_vill_name == "Myaing Kalay Out Ywar"

bysort org_name township_name geo_eho_vill_name: gen mt_survey_per_vill = _N 
lab var mt_survey_per_vill "# of survey per village (cluster) midterm"

gen midterm_cluster = 1 
lab var midterm_cluster "Midtern observed cluster (village)"

bysort org_name township_name geo_eho_vill_name: keep if _n == 1

keep	geo_vill org_name township_name geo_eho_vt_name geo_eho_vill_name ///
		stratum geo_town geo_vt geo_vill ///
		mt_survey_per_vill midterm_cluster
		
distinct township_name geo_eho_vt_name geo_eho_vill_name, joint 


tempfile midterm_data
save `midterm_data', replace 


********************************************************************************
* IP villages *
********************************************************************************
* prepare tempfile for stratum 1
clear all
tempfile stratum1
save `stratum1', emptyok 

**  feasibility first wave ** 
import excel 	using "$sample/01_village_profile/PN_Coverage_List_2024_accessiblityinfo.xlsx", ///
				sheet("LIFT") cellrange(A3:AR507) case(lower) clear 

* drop un-necessary var
keep AD AE AM-AQ AI-AL B-R AR

* rename variable 
rename B	vill_code
rename C	org_name
rename D 	state_mimu 
rename E	state_pcode
rename F	dist_eho 
rename G	township_name
rename H	township_pcode 
rename I	township_eho 
rename J	clinic_code 
rename K	clinic_name 
rename L	hospital_name
rename M	geo_eho_vt_name  
rename N	vt_pcode
rename O	vill_mimu 
rename P	vill_mimu_mmr
rename Q 	geo_eho_vill_name 
rename R	vill_pcode 
rename AI	hh_tot
rename AJ	pop_tot 
rename AK	u2_pop
rename AL 	u2to5_pop 
rename AM	vill_accessibility
rename AN 	vill_proj_implement 
rename AO 	remark_ips
rename AP 	remark_cpi
rename AQ	remark 
rename AD	vill_accessibility_midterm
rename AE 	vill_proj_implement_midterm 
rename AR	new_stratum_2

* Matched with midterm data 
distinct org_name township_name geo_eho_vill_name, joint 

save "$dta/endline/endline_sampling_frame_vill_feasibility_status.dta", replace 

merge 1:1 	org_name township_name geo_eho_vill_name ///
			using `midterm_data', ///
			assert(1 3) nogen ///
			keepusing(mt_survey_per_vill midterm_cluster)

replace vill_proj_implement_midterm = "" if vill_proj_implement_midterm == "-"
destring vill_proj_implement_midterm, replace 
replace vill_proj_implement_midterm = vill_proj_implement_midterm * 100 if vill_proj_implement_midterm <= 1
tab vill_proj_implement_midterm, m 
tab vill_proj_implement, m 

* check 
assert vill_proj_implement == vill_proj_implement_midterm if vill_proj_implement == 0
count if vill_proj_implement != 0 & vill_proj_implement_midterm == 0

egen u5_pop = rowtotal(u2_pop u2to5_pop)
replace u5_pop = .m if mi(u2_pop) & mi(u2to5_pop)
order u5_pop, after(u2to5_pop)
tab u5_pop, m 

encode org_name, gen(org_name_cat)
encode vill_accessibility, gen(vill_accessibility_cat)
replace vill_accessibility_midterm = "" if vill_accessibility_midterm == "-"
encode vill_accessibility_midterm, gen(vill_accessibility_midterm_cat)

* Stratum classification 
gen stratum_midterm = (vill_accessibility_midterm != "3. neither in person nor phone interviews")
replace stratum_midterm = 2 if stratum_midterm == 0
replace stratum_midterm = .m if mi(vill_proj_implement_midterm) | vill_proj_implement_midterm == 0
tab stratum_midterm, m 

* un-accessible village 
gen unaccess_vill = (vill_accessibility == "3. neither in person nor phone interviews" &  org_name != "KDHW")
tab unaccess_vill, m 

tab stratum_midterm unaccess_vill, m 

/*
gen stratum = (vill_accessibility != "3. neither in person nor phone interviews")
replace stratum = 2 if stratum == 0
replace stratum = 2 if new_stratum_2 == 1
replace stratum = .m if mi(vill_accessibility) | vill_proj_implement == 0
tab stratum, m 

tab stratum_midterm stratum if unaccess_vill != 1, m 

* drop if there is no project implementation or missing info villages *
keep if vill_proj_implement != 0 & !mi(vill_proj_implement)

tab vill_proj_implement, m 
tab vill_accessibility, m 

* CHECKING Sampling Frame 
tab stratum stratum_midterm, m col 

* keep only village with at least SBCC activity implemented
keep if vill_proj_implement >= 50 &  !mi(vill_proj_implement)

tab vill_proj_implement, m 
tab vill_accessibility org_name, m 

* KEHOC and YSDA has village which were not able to conduct field visit 
tab vill_proj_implement if org_name_cat > 1 & !mi(org_name_cat) & vill_accessibility_cat == 2
drop if org_name_cat > 1 & !mi(org_name_cat) & vill_accessibility_cat == 2

table vill_proj_implement vill_accessibility_cat org_name_cat , stat(freq)

tab vill_proj_implement, m 
tab vill_proj_implement org_name_cat, m 
tab vill_proj_implement stratum, m 
*/

* save to use for comparision study 
save "$dta/pn_endline_village_list_updated.dta", replace 

* keep for final sampling frame 
drop if unaccess_vill == 1 
drop if vill_proj_implement_midterm == 0 & vill_proj_implement == 0

* stratum - new 27 vill 
tab stratum_midterm, m 

gen stratum = stratum_midterm
replace stratum = 1 if (vill_accessibility != "3. neither in person nor phone interviews") & mi(stratum)
replace stratum = 2 if mi(stratum)
tab stratum, m 

tab vill_proj_implement*, m 

********************************************************************************
* 5 villages from 27 newly implemented villages *
********************************************************************************

preserve 

	keep if mi(stratum_midterm) & unaccess_vill == 0 & vill_proj_implement != 0
	
	gen rdm_order = _n 
	
	bysort org_name: gen cluster_cat = (rdm_order <= round(_N/5, 1)) // get 30 clusters as priority and other as replacement 
	lab def cluster_cat 1"priority cluster" 0"reserved cluster"
	lab val cluster_cat cluster_cat
	tab cluster_cat org_name, m

order cluster_cat , after(org_name)
sort org_name cluster_cat 

export excel using "$result/Endline_sample_village_list_NEW27vill.xlsx", ///
					sheet("New_Implemented_Villages", replace) firstrow(varlabels) 
					
restore 



********************************************************************************
* SAMPLING - stratum - 2: Limited Accessible villages *
********************************************************************************

preserve

keep if stratum == 2 

set seed 234

gen rnd_num = runiform()


** setting priority cluster and reserve cluster 
sort org_name rnd_num
bysort org_name: gen rdm_order = _n 

bysort org_name: gen cluster_cat = (rdm_order <= round(_N/2.8, 1)) // get 30 clusters as priority and other as replacement 
lab def cluster_cat 1"priority cluster" 0"reserved cluster"
lab val cluster_cat cluster_cat
tab cluster_cat org_name, m

drop rnd_num rdm_order

bysort org_name cluster_cat: gen cluster_order = _n 

order cluster_cat cluster_order, after(org_name)
lab var cluster_cat 	"Cluster category"
lab var cluster_order 	"Cluster selection order (random assignment)"

sort org_name cluster_cat cluster_order

sum u5_pop, d // average U5 pop: 68 per village << need to check

/*
gen vill_samplesize = 12 if emergency_vill == "Yes"
replace vill_samplesize = 20 if emergency_vill == "No"
tab vill_samplesize, m 

gen sample_check = (u5_pop >= vill_samplesize)
lab def sample_check 1"have enough U5 sample size" 0"not enough U5 sample size"
lab val sample_check sample_check
tab sample_check, m 
*/

// gsort org_name - cluster_cat

export excel using "$result/Endline_sample_village_list_NEW27vill.xlsx", ///
					sheet("stratum_2", replace) firstrow(varlabels) 

* save as tempfile 
tempfile stratum2 
save `stratum2', replace 

restore 



********************************************************************************
* SAMPLING - stratum - 1: Accessible villages *
********************************************************************************
* need to update with final sample size collection 
di 14 * 30 // sample size from stratum 2 
di 627 - (14 * 30) // required sample for stratum 1 
di 14 * 15

// 15 clusters and 14 HH per cluster 

keep if stratum == 1
tab org_name, m 

levelsof org_name, local(orgs)

foreach org in `orgs' {
    
	preserve 

		keep if stratum == 1 & org_name == "`org'"

		local cluster_num = round(15 * (_N / 296), 1)

		sum u5_pop, d // average U2 pop: 83 per village << need to check 

		set seed 443332

		samplepps pps_cluster, size(pop_tot) n(`cluster_num') withrepl // add additional cluster to save sample size from rounding work

		tab pps_cluster, m


		** setting priority cluster and reserve cluster 
		gen cluster_cat = (pps_cluster > 0)
		lab def cluster_cat 1"priority cluster" 0"reserved cluster"
		lab val cluster_cat cluster_cat
		tab cluster_cat org_name, m

		set seed 234
		gen rnd_num = runiform() if cluster_cat == 0

		sort org_name cluster_cat rnd_num
		bysort org_name cluster_cat: gen cluster_order = _n if cluster_cat == 0

		drop rnd_num 

		order cluster_cat cluster_order, after(org_name)
		lab var cluster_cat 	"Cluster category"
		lab var cluster_order 	"Cluster selection order (random assignment)"

		tab cluster_cat, m 
		tab cluster_order if cluster_cat == 0, m 

		sort org_name cluster_cat cluster_order

		// keep if pps_cluster != 0 

		rename pps_cluster num_cluster
		/*
		gen vill_samplesize = (num_cluster * 10)

		gen sample_check = (u5_pop >= vill_samplesize)
		lab def sample_check 1"have enough U5 sample size" 0"not enough U5 sample size"
		lab val sample_check sample_check
		tab sample_check, m 

		gsort org_name -cluster_cat
		*/

		* save as tempfile 
		append using `stratum1' 
		save `stratum1', replace 

	restore 

}

clear 

* export as excel file 
use `stratum1', clear 

keep if !mi(cluster_cat)

export excel using "$result/Endline_sample_village_list_NEW27vill.xlsx", sheet("stratum_1", replace) firstrow(varlabels) 

clear 



** export for preloaded dataset **
use `stratum1', clear 

append using `stratum2'

distinct org_name township_name geo_eho_vt_name geo_eho_vill_name, joint 

* keep only required variables
//keep township_name townshippcode fieldnamevillagetracteho villagenameeho stratum num_cluster vill_samplesize sample_check organization cluster_cat
//replace stratum = 2 if stratum == 0

* generate pseudo code [ get from midline file]
* Matched with midterm data 
preserve

	import excel using 	"$result/pn_2_samplelist.xlsx", ///
						sheet("pn_2_samplelist") ///
						firstrow clear   
						
	rename organization org_name
	rename fieldnamevillagetracteho geo_eho_vt_name
	rename villagenameeho geo_eho_vill_name
	
	distinct org_name township_name geo_eho_vt_name geo_eho_vill_name, joint
	
	tempfile midterm_sf
	save `midterm_sf', replace 

restore 


merge 1:1 	org_name township_name geo_eho_vt_name geo_eho_vill_name ///
			using `midterm_sf', ///
			keepusing(vill_sir_num vt_sir_num /*vt_cluster_cat*/)
			
drop if _merge == 2 // village not accessible at endline

drop _merge 

* village tract  id number update 
sum vt_sir_num 
replace vt_sir_num = _n + `r(max)' if mi(vt_sir_num)

count if mi(vt_sir_num)
assert `r(N)' == 0 

sum vt_sir_num
distinct vt_sir_num 

* village id number update 
sum vill_sir_num 
replace vill_sir_num = _n + `r(max)' if mi(vill_sir_num)

count if mi(vill_sir_num)
assert `r(N)' == 0 

sum vill_sir_num
distinct vill_sir_num 
assert `r(ndistinct)' == _N 

/*
preserve

	keep township_pcode geo_eho_vt_name vill_sir_num // vt_sir_num
	bysort township_pcode geo_eho_vt_name: keep if _n == 1

	replace vt_sir_num = _n + 1000 if mi(vt_sir_num)

	tempfile vt_sir_num
	save `vt_sir_num', replace 

restore 

merge m:1 	township_pcode geo_eho_vt_name using `vt_sir_num', ///
			keepusing(vt_sir_num) update replace 

drop _merge 

replace vill_sir_num = _n + 2000 if mi(vill_sir_num)
*/


tostring cluster_cat, gen(cluster_cat_str)
tostring vt_sir_num, gen(vt_sir_num_str)

gen vt_cluster_cat = cluster_cat_str + "_" + vt_sir_num_str // if mi(vt_cluster_cat)

drop cluster_cat_str vt_sir_num_str

decode cluster_cat, gen(cluster_cat_str) 


order org_name township_name township_pcode  geo_eho_vt_name vt_sir_num cluster_cat cluster_cat_str geo_eho_vill_name vill_sir_num
 
//order org_name township_name townshippcode fieldnamevillagetracteho vt_sir_num cluster_cat cluster_cat_str villagenameeho vill_sir_num

export delimited using "$result/pn_endline_samplelist_new27vill.csv", nolabel replace  
save "$dta/pn_endline_samplelist.dta", replace 

export excel using "$result/pn_endline_samplelist_new27vill.xlsx", sheet("endline_samplelist") firstrow(variable)  nolabel replace 


			
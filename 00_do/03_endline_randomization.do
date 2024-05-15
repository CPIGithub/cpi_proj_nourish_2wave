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
* IP villages *
********************************************************************************
* prepare tempfile for stratum 1
tempfile stratum1
save `stratum1', emptyok 

**  feasibility first wave ** 
import excel 	using "$sample/01_village_profile/PN_Coverage_List_2024_accessiblityinfo.xlsx", ///
				sheet("LIFT") cellrange(A3:AQ507) case(lower) clear 

* drop un-necessary var
keep AM-AQ AI-AL B-R

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
rename M	vt_eho 
rename N	vt_pcode
rename O	vill_mimu 
rename P	vill_mimu_mmr
rename Q 	vill_eho 
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


tab vill_proj_implement, m 

egen u5_pop = rowtotal(u2_pop u2to5_pop)
replace u5_pop = .m if mi(u2_pop) & mi(u2to5_pop)
order u5_pop, after(u2to5_pop)
tab u5_pop, m 


* drop if there is no project implementation or missing info villages *
keep if vill_proj_implement != 0 & !mi(vill_proj_implement)

tab vill_proj_implement, m 

tab vill_accessibility, m 

gen stratum = (vill_accessibility != "3. neither in person nor phone interviews")
replace stratum = 2 if stratum == 0
tab stratum, m 

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

bysort org_name: gen cluster_cat = (rdm_order <= round(_N/7.9, 1)) // get 30 clusters as priority and other as replacement 
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

export excel using "$result/Endline_sample_village_list.xlsx", ///
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


tab org_name if stratum == 1


levelsof org_name, local(orgs)

foreach org in `orgs' {
    
	preserve 

		keep if stratum == 1 & org_name == "`org'"

		local cluster_num = round(15 * (_N / 236), 1)

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

export excel using "$result/Endline_sample_village_list.xlsx", sheet("stratum_1", replace) firstrow(varlabels) 

clear 



** export for preloaded dataset **
use `stratum1', clear 

append using `stratum2'

* keep only required variables
//keep township_name townshippcode fieldnamevillagetracteho villagenameeho stratum num_cluster vill_samplesize sample_check organization cluster_cat
replace stratum = 2 if stratum == 0

* generate pseudo code
preserve
keep township_pcode vt_eho
bysort township_pcode vt_eho: keep if _n == 1

gen vt_sir_num = _n + 1000

tempfile vt_sir_num
save `vt_sir_num', replace 

restore 

merge m:1 township_pcode vt_eho using `vt_sir_num', keepusing(vt_sir_num)
drop _merge 

gen vill_sir_num = _n + 2000


tostring cluster_cat, gen(cluster_cat_str)
tostring vt_sir_num, gen(vt_sir_num_str)

gen vt_cluster_cat = cluster_cat_str + "_" + vt_sir_num_str 

drop cluster_cat_str vt_sir_num_str

decode cluster_cat, gen(cluster_cat_str) 


order org_name township_name township_pcode  vt_eho vt_sir_num cluster_cat cluster_cat_str vill_eho vill_sir_num
 
//order org_name township_name townshippcode fieldnamevillagetracteho vt_sir_num cluster_cat cluster_cat_str villagenameeho vill_sir_num

export delimited using "$result/pn_endline_samplelist.csv", nolabel replace  
save "$dta/pn_endline_samplelist.dta", replace 

export excel using "$result/pn_endline_samplelist.xlsx", sheet("endline_samplelist") firstrow(variable)  nolabel replace 


			
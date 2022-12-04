/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection: enumerator performance			
Author				:	Nicholus Tint Zaw
Date				: 	11/24/2022
Modified by			:


*******************************************************************************/

********************************************************************************
** Directory Settings **
********************************************************************************

do "00_dir_setting.do"

********************************************************************************
* household survey *
********************************************************************************

use "$dta/pn_hh_pnourish_secondwave.dta", clear 




// format starttime  %tcCCYY-NN-DD_HH:MM:SS.sss

format starttime %tcDDmonCCYY_Hh:MM_AM




gen duration = endtime - starttime

&&&
rename startime starttime


foreach var of varlist starttime endtime {
	gen `var'_tc = clock(`var', "hms#")
	order `var'_tc, after(`var')
	format `var'_tc %tcHH:MM
	drop `var'
	rename `var'_tc `var'
}




geo_town geo_vt geo_vill svy_team superv_name interv_name 

intrv_date quest_num cal_respid 

will_participate 

starttime endtime 

_submission_time 

_uuid 

_id


&&


// export table
export excel using "$out/06_survey_duration.xlsx", sheet("03_per_enu_tot") firstrow(varlabels) sheetreplace

* END here 


 


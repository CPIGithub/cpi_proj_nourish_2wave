* **************************************************************************** *
* **************************************************************************** *
*                                                                      		   *
*   	World Food Program SPB Window - Jordan - Impact Evaluation			   *
*								Child survey						    	   *
*       	This dofile carries out high frequency checks.		          	   *
*                                                                     		   *
* **************************************************************************** *
* **************************************************************************** *

/*
  ** PURPOSE        Creating tables to monitor the progress of data collection 
					by enumerator.
  ** LAST UPDATE    August 30, 2022
  ** INPUT			hfc_child_survey_dta_prepped.dta	
  ** OUTPUT			child_survey_enumerator_track.dta
					WFP_SPB_jordan_hfc_child_survey.xlsx 
					(Enumerator Report (Aggregate))
					(Enumerator Report (Last Day))
					(Enumerator Comments)
  
  ** CONTENTS

		*0. EXPORT TABLE TITLES
		*1. IMPORT DATA
		*2. CREATING VARIABLES OF INTEREST
		*3. EXPORT GENERAL AGGREGATED TABLE
		*4. EXPORT GENERAL ENUMERATOR TABLE (AGGRGEATE)
		*5. CREATING VARIABLES OF INTEREST FOR LAST DAY TABLE
		*6. EXPORT ENUMERATOR TABLE (LAST DAY)
		*7. EXPORTING LIST OF SURVEYS WITH ISSUES 
		*8. SAVING DATASET FOR TRACKING SHEET
		*9. EXPORTING ENUMERATOR COMMENTS
		
*******************************************************************************/

	*0. EXPORT TABLE TITLES
	
		*Adding title table 1
		clear
		set obs 1
		gen title = ""
		replace title = "TABLE 1: AGGREGATED STATISTICS" in 1
		export excel title using "${hfc_outputs}/WFP_SPB_jordan_hfc_child_survey.xlsx", sheet("Enumerator Report (Aggregate)") sheetreplace 
		
		*Adding title table 2
		clear
		set obs 1
		gen title = ""
		replace title = "TABLE 2: COMPLETION PROGRESS BY ENUMERATOR" in 1
		export excel title using "${hfc_outputs}/WFP_SPB_jordan_hfc_child_survey.xlsx", sheet("Enumerator Report (Aggregate)") sheetmodify cell(A5)  
		
		*Adding title table 3
		clear
		set obs 1
		gen title = ""
		replace title = "TABLE 3: COMPLETION PROGRESS" in 1
		export excel title using "${hfc_outputs}/WFP_SPB_jordan_hfc_child_survey.xlsx", sheet("Enumerator Report (Aggregate)") sheetmodify cell(A80)  
		
		*Adding title table 4
		clear
		set obs 1
		gen title = ""
		replace title = "TABLE 4: COMPLETION PROGRESS BY SCHOOL" in 1
		export excel title using "${hfc_outputs}/WFP_SPB_jordan_hfc_child_survey.xlsx", sheet("Enumerator Report (Aggregate)") sheetmodify cell(I80)  
		
		*Adding title table 1
		clear
		set obs 1
		gen title = ""
		replace title = "TABLE 1: LAST DAY DATA COLLECTION" in 1
		export excel title using "${hfc_outputs}/WFP_SPB_jordan_hfc_child_survey.xlsx", sheet("Enumerator Report (Last Day)") sheetreplace
		
		*Adding title table 2
			clear
			set obs 1
			gen title = ""
			replace title = "TABLE 2: List of Surveys with Issues" in 1
			export excel title using "${hfc_outputs}/WFP_SPB_jordan_hfc_child_survey.xlsx", sheet("Enumerator Report (Last Day)") sheetmodify cell(A57) 
	
	
	*1. IMPORT DATA
	use "$hfc_data/hfc_child_survey_data_prepped.dta",clear
	*use "${hfc_data}/hfc_child_survey_data_prepped.dta", clear

	*2. CREATING VARIABLES OF INTEREST

		*Total surveys by enumerator
			foreach var of varlist completed declined {
				egen tot_`var' = sum(`var')
				bysort enumerator: egen enu_tot_`var' = sum(`var')
			}
		
		
		*Average survey duration by enumerator (in minutes)
			**Using end_survey instead of endtime
		destring duration, replace
		gen duration_1 = duration/60 // modify here with start and end survey if necessary
		egen avg_duration = mean(duration_1)
		egen med_duration = median(duration_1)
		bysort enumerator: egen enu_avg_duration = mean(duration_1)
		bysort enumerator: egen enu_med_duration = median(duration_1)

		
		*Average consent/EGMA/EGRA/Digit spam modules duration by enumerator (in minutes)
		*Add today date
		local date: display "$S_DATE"
		
		gen date = "`date'"
		order date, before(student_id)
		label variable date "Today's Date"
		
			*drop if duration_1 <= 9 
								  
			
		local vars_mod /// consent
				egra egma digit_span stroop_test revens // cognitive tests
		
		
		foreach var in `vars_mod' {
			gen  dur_mod_`var' = ((end_`var'_dt - start_`var'_dt)/(3600*1000))*60
			egen avg_dur_`var' = mean(dur_mod_`var')
			egen med_dur_`var' = median(dur_mod_`var')
			bysort enumerator: egen enu_avg_dur_`var' = mean(dur_mod_`var')
			bysort enumerator: egen enu_med_dur_`var' = median(dur_mod_`var')
		} 
		
						
		*Total of surveys too long/short
		egen sd_dur = sd(duration_1)
		
		gen low_dur = avg_duration - 3*sd_dur
		gen up_dur = avg_duration + 3*sd_dur
		
			*Generating dummy
			gen short_sur = (duration_1 < 15) | (duration_1 < low_dur)
			gen long_sur = (duration_1 > up_dur)
			
		*Dummy for surveys started too early (8am)/too late (8pm)
		gen start_h = hh(starttime_dt)
		gen end_h = hh(end_survey_dt) // NEED TO ADD END SURVEY DURATION

		gen early_sur = (start_h < 8)
		gen late_sur = (end_h > 20) // NEED TO ADD END SURVEY DURATION
		
		*Surveys with different start/end/submission dates
		gen dif_st_end = (startdate != enddate)
		gen dif_st_sub = (startdate != subdate)
		
		ta short_sur
		ta long_sur
		*Surveys consent duration is 0
		

			
			foreach var of varlist short_sur long_sur early_sur late_sur dif_st_end dif_st_sub { // NEED TO ADD  late_sur
				egen tot_`var' = sum(`var')
				bysort enumerator: egen enu_tot_`var' = sum(`var')
				
			}
			
		*Labelling variables
		
		
				  		
		label variable tot_completed 			 "Completed Surveys"
		label variable tot_declined	 			 "Declined Surveys"
		label variable enu_tot_completed		 "Completed Surveys"
		label variable enu_tot_declined			 "Declined Surveys"
		
		label variable avg_duration	 			 "Avg. Survey Duration (Min)"
		label variable med_duration				 "Median Survey Duration (Min)"
		label variable enu_avg_duration	 		 "Avg. Survey Duration (Min)"
		label variable enu_med_duration			 "Median Survye Duration (Min)"

	
		label variable avg_dur_egra 			 "Avg. EGRA. Duration (Min)"
		label variable med_dur_egra			 "Median EGRA mod. Duration (Min)"
		label variable enu_avg_dur_egra 		 "Avg. EGRA mod. Duration (Min)"
		label variable enu_med_dur_egra 		 "Median EGRA mod. Duration (Min)" 
		
		label variable avg_dur_egma 		 "Avg. EGMA mod. Duration (Min)"
		label variable med_dur_egma  		 "Median EGMA mod. Duration (Min)"
		label variable enu_avg_dur_egma 	 "Avg. EGMA mod. Duration (Min)"
		label variable enu_med_dur_egma  	 "Median EGMA mod. Duration (Min)"
		
		label variable avg_dur_digit_span 	 "Avg. Digit Span mod. Duration (Min)"
		label variable med_dur_digit_span	 "Median Digit Span mod. Duration (Min)"
		label variable enu_avg_dur_digit_span "Avg. Digit Span mod. Duration (Min)"
		label variable enu_med_dur_digit_span "Median Digit Span mod. Duration (Min)"
		
		label variable avg_dur_stroop_test 	 	"Avg. Stroop test mod. Duration (Min)"
		label variable med_dur_stroop_test 	   "Median Stroop test mod. Duration (Min)"
		label variable enu_avg_dur_stroop_test "Avg. Stroop test mod. Duration (Min)"
		label variable enu_med_dur_stroop_test "Median Stroop test mod. Duration (Min)"
		
		label variable avg_dur_revens 	 	"Avg. Ravens mod. Duration (Min)"
		label variable med_dur_revens 	    "Median Ravens test mod. Duration (Min)"
		label variable enu_avg_dur_revens   "Avg. Ravens mod. Duration (Min)"
		label variable enu_med_dur_revens   "Median Ravens mod. Duration (Min)"
		
		label variable tot_short_sur 			 "Short Surveys"
		label variable tot_long_sur 	   		 "Long Surveys"
		label variable enu_tot_short_sur 		 "Short Surveys"
		label variable enu_tot_long_sur 	     "Long Surveys"
		label variable tot_early_sur			 "Early Surveys"
		label variable tot_late_sur 			 "Late Surveys"
		label variable enu_tot_early_sur		 "Early Surveys"
		label variable enu_tot_late_sur			 "Late Surveys"
		label variable tot_dif_st_end 			 "Different start and end date"
		label variable tot_dif_st_sub			 "Different start and submision date"
		label variable enu_tot_dif_st_end		 "Different start and end date"
		label variable enu_tot_dif_st_sub		 "Different start and submision date"


		label variable duration_1				 "Survey Duration"

		tempfile enumerator_data
		save `enumerator_data', replace
		
			
	*3. EXPORT GENERAL AGGREGATED TABLE
	
		*Exporting Aggregated Table
			 
			*Importing data and keeping relevant observations 
			use `enumerator_data', clear
			
			keep tot_completed tot_declined ///
				 avg_duration med_duration ///
				 avg_dur_egra med_dur_egra avg_dur_egma med_dur_egma ///
				 avg_dur_digit_span med_dur_digit_span ///
				 avg_dur_stroop_test med_dur_stroop_test ///
				 avg_dur_revens med_dur_revens ///
				 tot_long_sur tot_short_sur tot_early_sur tot_late_sur  ///
				 tot_dif_st_end tot_dif_st_sub 	 

			duplicates drop	
			order tot_declined ///
				  med_duration	avg_duration ///
				  med_dur_egra avg_dur_egra ///
				  med_dur_egma avg_dur_egma ///
				  med_dur_digit_span avg_dur_digit_span ///
				  med_dur_stroop_test avg_dur_stroop_test ///
				  med_dur_revens avg_dur_revens //////
				  tot_short_sur tot_long_sur  tot_late_sur ///
				  tot_early_sur tot_dif_st_end tot_dif_st_sub, after(tot_completed) 
		
			
			export excel using "${hfc_outputs}/WFP_SPB_jordan_hfc_child_survey.xlsx", sheet("Enumerator Report (Aggregate)") sheetmodify cell(A2)  firstrow(varlabels)
	
	*4. EXPORT COMPLETION PROGRESS TABLE BY DATE 

	use "$hfc_data/hfc_child_survey_data_prepped.dta",clear
	
		foreach var of varlist completed declined {
				bysort startdate: egen `var'_day = sum(`var')
			}

		*Counting unique schools visitied every day	
			
			*Total number of unique schools (has to be generate by municipality and treatment)
			egen tag = tag(school_id)
			egen tot_unq_sch = total(tag)
			bysort startdate: egen tot_unq_sch_day = total(tag)
		
		keep completed_day declined_day tot_unq_sch_day startdate
		
		order tot_unq_sch_day completed_day declined_day, after(startdate)
		duplicates drop
		
		label variable tot_unq_sch_day "Total Unique Schools"
		label variable completed_day   "Completed Surveys"
		label variable declined_day	   "Declined Surveys"
		
		export excel using "${hfc_outputs}/WFP_SPB_jordan_hfc_child_survey.xlsx", sheet("Enumerator Report (Aggregate)") sheetmodify cell(A81)  firstrow(varlabels)
	
	*4. EXPORT COMPLETION PROGRESS TABLE BY SCHOOL
	
	use "$hfc_data/hfc_child_survey_data_prepped.dta",clear
	
		foreach var of varlist completed declined {
				bysort school_id: egen `var'_sch = sum(`var')
			}

	keep school_id completed_sch declined_sch 
		
		duplicates drop
		
		label variable completed_sch "Completed Surveys"
		label variable declined_sch   "Declined Surveys"
		
		export excel using "${hfc_outputs}/WFP_SPB_jordan_hfc_child_survey.xlsx", sheet("Enumerator Report (Aggregate)") sheetmodify cell(I81)  firstrow(varlabels)
	
	
	*4. EXPORT GENERAL ENUMERATOR TABLE (AGGRGEATE)
	
		*Exporting Aggregated Table
			 
			*Importing data and keeping relevant observations 
			use `enumerator_data', clear
			save "${hfc_data}/enumerator_track_dta_for_graphs.dta", replace
			
			keep enumeratorname enumerator ///
				 enu_*

			duplicates drop	
			order enumerator ///
				  enu_*
		
			*Var counting total issues
			egen enu_tot_issues = rowtotal(enu_tot_short_sur enu_tot_long_sur ///
										   enu_tot_early_sur enu_tot_late_sur ///
										   enu_tot_dif_st_end enu_tot_dif_st_sub) 	
										   
										   
			order enumerator enu_tot_completed enu_tot_declined ///
				  enu_med_duration enu_avg_duration ///
				  enu_avg_dur_egra enu_med_dur_egra enu_avg_dur_egma enu_med_dur_egma ///
				  enu_avg_dur_digit_span enu_med_dur_digit_span ///
				  enu_avg_dur_stroop_test enu_med_dur_stroop_test ///
				  enu_avg_dur_revens enu_med_dur_revens ///
				  enu_tot_short_sur enu_tot_long_sur enu_tot_early_sur enu_tot_late_sur ///
				  enu_tot_dif_st_end enu_tot_dif_st_sub /// 
				  enu_tot_issues				   
			
			label variable enu_tot_issues "Total Issues"
		
			export excel using "${hfc_outputs}/WFP_SPB_jordan_hfc_child_survey.xlsx", sheet("Enumerator Report (Aggregate)") sheetmodify cell(A6)  firstrow(varlabels)

			
	
	*5. CREATING VARIABLES OF INTEREST FOR LAST DAY TABLE
	
	use `enumerator_data', clear
	
	*Keeping only surveys of last day of data collection
	*MANUAL INPUT: Set number of days in the past you wish to look into.

		local days = 7
		keep if elapsed_datacheck <= `days' 

	if _N > 0 {
		*Total surveys by enumerator
		foreach var of varlist completed declined {
			bysort enumerator: egen tot_`var'_ld = sum(`var')
			}
		
		*Average survey duration by enumerator (in minutes)
		bysort enumerator: egen avg_duration_ld = mean(duration_1)
		bysort enumerator: egen med_duration_ld = median(duration_1)

	
		*Average consent/procurement/enrollment module duration by enumerator (in minutes)
		
		local vars_mod /// consent
				egra egma digit_span stroop_test revens  // cognitive tests
		
		foreach var in `vars_mod' {
			gen    dur_mod_`var'_ld = ((end_`var'_dt - start_`var'_dt)/(3600*1000))*60
			bysort enumerator: egen avg_dur_`var'_ld = mean(dur_mod_`var')
			bysort enumerator: egen med_dur_`var'_ld = median(dur_mod_`var')
		
		}

		 
		*Total of surveys too long/short/early/late			
			
			foreach var of varlist short_sur long_sur early_sur late_sur dif_st_end dif_st_sub {
				bysort enumerator: egen tot_`var'_ld = sum(`var')
				
			}
			
		*Labelling variables
		label variable tot_completed_ld 			 "Completed Surveys"
		label variable tot_declined_ld	 			 "Declined Surveys"
		label variable avg_duration_ld	 			 "Avg. Survey Duration (Min)"
		label variable med_duration_ld				 "Median Survey Duration (Min)"

		
		label variable avg_dur_egra_ld 			 "Avg. EGRA. Duration (Min)"
		label variable med_dur_egra_ld			 "Median EGRA mod. Duration (Min)"
		
		label variable avg_dur_egma_ld 		 "Avg. EGMA mod. Duration (Min)"
		label variable med_dur_egma_ld  		 "Median EGMA mod. Duration (Min)"
		
		label variable avg_dur_digit_span_ld 	 "Avg. Digit Span mod. Duration (Min)"
		label variable med_dur_digit_span_ld	 "Median Digit Span mod. Duration (Min)"
		
		label variable avg_dur_stroop_test_ld 	 "Avg. Stroop test mod. Duration (Min)"
		label variable med_dur_stroop_test_ld	 "Median Stroop test mod. Duration (Min)"
		
		label variable avg_dur_revens_ld 	 "Avg. Revens mod. Duration (Min)"
		label variable med_dur_revens_ld	 "Median Revens mod. Duration (Min)"
		
		label variable tot_short_sur_ld 			 "Short Surveys"
		label variable tot_long_sur_ld 	   			 "Long Surveys"
		label variable tot_early_sur_ld			 	 "Early Surveys"
		label variable tot_late_sur_ld 				 "Late Surveys"
		label variable tot_dif_st_end_ld 			 "Different start and end date"
		label variable tot_dif_st_sub_ld			 "Different start and submision date"
			
	tempfile enumerator_data_ld
	save `enumerator_data_ld', replace

	*6. EXPORT ENUMERATOR TABLE (LAST DAY)
			 
			*Importing data and keeping relevant observations 
			use `enumerator_data_ld', clear
			
			keep level1 enumerator tot_completed_ld tot_declined_ld ///
				 avg_duration_ld med_duration_ld ///
				 avg_dur_digit_span_ld avg_dur_egma_ld avg_dur_egra_ld avg_dur_stroop_test_ld avg_dur_revens_ld ///
				 med_dur_digit_span_ld med_dur_egma_ld med_dur_egra_ld med_dur_stroop_test_ld med_dur_revens_ld ///
				 tot_long_sur_ld tot_short_sur_ld tot_early_sur_ld tot_late_sur_ld ///
				 tot_dif_st_end_ld tot_dif_st_sub_ld date_current

			duplicates drop	
			order enumerator tot_completed_ld tot_declined_ld ///
				  med_duration_ld avg_duration_ld ///
				  med_dur_egra_ld avg_dur_egra_ld ///
				  med_dur_egma_ld avg_dur_egma_ld ///
				  med_dur_digit_span_ld avg_dur_digit_span_ld ///
				  med_dur_stroop_test_ld avg_dur_stroop_test_ld ///
				  med_dur_revens_ld avg_dur_revens_ld ///				  
				  tot_short_sur_ld tot_long_sur_ld tot_early_sur_ld tot_late_sur_ld ///
				  tot_dif_st_sub_ld tot_dif_st_end_ld, after(level1)
				  
			*Var counting total issues
			egen enu_tot_issues = rowtotal(tot_short_sur_ld  tot_long_sur_ld ///
										   tot_early_sur_ld  tot_late_sur_ld ///
										   tot_dif_st_end_ld tot_dif_st_sub_ld)
										   
			label variable enu_tot_issues "Total Issues"
		
		export excel using "${hfc_outputs}/WFP_SPB_jordan_hfc_child_survey.xlsx", sheet("Enumerator Report (Last Day)") sheetmodify cell(A2) firstrow(varlabels)
	
	
	*7. EXPORTING LIST OF SURVEYS WITH ISSUES 
	
		use `enumerator_data_ld', clear

		*Keeping only last day of data collection observations
		
		keep startdate enddate subdate student_id enumerator key school_id school_name ///
			 short_sur long_sur early_sur late_sur dif_st_end dif_st_sub date_current

			 rename (short_sur long_sur early_sur late_sur) (dif_short_sur dif_long_sur dif_early_sur dif_late_sur )
			  count
			reshape long dif_, ///
				i(startdate enddate subdate student_id enumerator key school_name school_id) ///
				j(variable) string	  
				
		 keep if dif_ == 1
		 
		
		gen Issue = ""
		replace Issue = "Short survey: lower then 10 minutes" 	 if variable == "short_sur"
		replace Issue = "Long survey"  						    if variable == "long_sur"
		replace Issue = "Survey started too early (before 8am)" if variable == "early_sur"
		replace Issue = "Survey finished too late (after 8pm)"  if variable == "late_sur"
		replace Issue = "Different start and end date" 		  	if variable == "st_end"
		replace Issue = "Different start and submission date" 	if variable == "st_sub"


		
		keep if !missing(Issue)

		keep student_id school_id school_name enumerator startdate enddate subdate Issue key date_current
		order school_id school_name enumerator startdate enddate subdate Issue key date_current, after(student_id)		

		
		if _N > 0	{
		export excel using "${hfc_outputs}/WFP_SPB_jordan_hfc_child_survey.xlsx", sheet("Enumerator Report (Last Day)") sheetmodify cell(A58) firstrow(varlabels)
		}

	*8. SAVING DATASET FOR TRACKING SHEET
	
		*Saving dataset to export to tracking sheet
		save "${hfc_data}/child_survey_enumerator_track.dta", replace
		
	*9. EXPORTING ENUMERATOR COMMENTS 

		use `enumerator_data', clear
		
		keep if !missing(end_comment)
		keep enumerator school_id end_comment startdate
		
		if _N > 0	{
			export excel using "${hfc_outputs}/WFP_SPB_jordan_hfc_child_survey.xlsx", sheet("Enumerator Comments") sheetreplace firstrow(varlabels)
		}
	}
	
****End of do-file

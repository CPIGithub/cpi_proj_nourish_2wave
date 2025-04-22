
/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection				
Author				:	Nicholus Tint Zaw
Date				: 	9/19/2022
Modified by			:


*******************************************************************************/

** Settings for stata ** 
clear all
label drop _all

set more off
set mem 100m
set matsize 11000
set maxvar 32767


********************************************************************************
***SET ROOT DIRECTORY HERE AND ONLY HERE***

// create a local to identify current user
local user = c(username)
di "`user'"

// Set root directory depending on current user
if "`user'" == "Nicholus Tint Zaw" {
    * Nicholus Directory
	
	global dir		"I:\.shortcut-targets-by-id\1qS9e_FKPO2IwvcIAch8aqRrLnWosl6ja\2nd round Project Nourish Survey"
	global github	"C:\Users\Nicholus Tint Zaw\Documents\GitHub\cpi_proj_nourish_2wave"
	
}

else if "`user'" == "wb598050" {
    * NCL
	global dir		"C:\Users\wb598050\Dropbox\PN_DataWork"
	global github		"C:\Users\wb598050\cpi_proj_nourish_2wave"
	
}

// Adam, please update your machine directory 
else if "`user'" == "XX" {
    * Adam Directory

}

// CPI team, please update your machine directory. 
// pls replicate below `else if' statement based on number of user going to use this analysis dofiles  
else if "`user'" == "XX" {
    * CPI team Directory
	
}

	global	wflow			"$dir/02_workflow"
	global	sample			"$dir/01_sampling"
	global 	do				"$github/00_do"
	global	xls				"$sample/02_Questionnaires/FINAL"


	* dofile directory 
	// HH survey
	global 	hhdo			"$do/01_HH_Survey"
	global	hhimport		"$hhdo/01_Import"
	global	hhhfc			"$hhdo/02_HFC"
	global	hhcleaning		"$hhdo/03_Cleaning"
	global	hhconstruct		"$hhdo/04_Construct"
	global	hhanalysis		"$hhdo/05_Analysis"
	global 	hhfun			"$hhdo/Function"

	// Village survey
	global 	villdo			"$do/02_Village_Survey"
	global	villimport		"$villdo/01_Import"
	global	villhfc			"$villdo/02_HFC"
	global	villcleaning	"$villdo/03_Cleaning"
	global	villconstruct	"$villdo/04_Construct"
	global	villanalysis	"$villdo/05_Analysis"

	* data directory  
	global  raw	 			"$wflow/01_raw"
	global 	dta				"$wflow/02_dta"
	global 	out				"$wflow/03_output"
	global 	result 			"$wflow/04_result"
	global 	plots			"$wflow/04_result/Figures"

	****************************************************************************
	****************************************************************************
	
   ** Plot Setting 
	
	* Setting graph colors (dark to light)
	global cpi1  		maroon*1.5 
	global cpi2    		cranberry
	global cpi3			cranberry*0.4
	global cpi4			maroon*0.4	
	global cpi5			erose*0.6
	global blue4		"87 87 87 *0.4" 		// Grey
	global blue9		"gs15*0.5" 				// light gray 
	global white		white
	
	* Figure globals
	global CompletionRatesPie   "sort descending pie(1,color($wfp_blue1)) pie(2,color($blue2)) plabel(_all percent, size(medium) format(%2.0f)) plabel(_all name, color(black) size(small) gap(22) format(%2.0f)) line(lcolor(black) lalign(center)) graphregion(fcolor(white)) legend(off) title("$title1" "$title2", color(black) margin(medsmall)) note("$note", size(medium))"					
	global Pie					"sort descending plabel(_all percent, size(small) format(%2.0f) gap(21)) line(lcolor(black) lalign(center)) graphregion(fcolor(white)) legend(region(lstyle(none)))"
	global Bar					"ylabel(,nogrid) asyvars showyvars bargap(10) blabel(bar, format(%2.0f)) plotregion(fcolor(white)) graphregion(fcolor(white)) b1title($b1title, color(black)) ytitle($ytitle, color(black)) title("$title1" "$title2", color(black)) note($note)"
	
	* Formatting add-ons
	
	* Pie charts
	global ptext_format ", color(black) size(small)"
	
	* Bar graphs
	global bar_format 			"lwidth(thin) lcolor(black) lalign(outside)"
	global label_format			"label(labsize(small))"
	global label_format_45 		"label(labsize(small) angle(45))"
	global legend_label_format 	"size(vsmall) region(lstyle(none))"
	
	global graph_opts1 ///
	   bgcolor(white) ///
	   graphregion(color(white)) ///
	   legend(region(lc(none) fc(none))) ///
	   ylab(,angle(0) nogrid) ///
	   title(, justification(left) color(black) span pos(11)) ///
	   subtitle(, justification(left) color(black))

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

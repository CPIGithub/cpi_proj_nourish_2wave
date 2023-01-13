/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	2nd round data collection				
Author				:	Nicholus Tint Zaw
Date				: 	9/19/2022
Modified by			:


*******************************************************************************/

** Settings for stata ** 
clear all
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
	
	global dir		"H:\.shortcut-targets-by-id\1qS9e_FKPO2IwvcIAch8aqRrLnWosl6ja\2nd round Project Nourish Survey"
	global github	"C:\Users\Nicholus Tint Zaw\Documents\GitHub\cpi_proj_nourish_2wave"
	
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


* dofile directory 
// HH survey
global 	hhdo			"$do/01_HH_Survey"
global	hhimport		"$hhdo/01_Import"
global	hhhfc			"$hhdo/02_HFC"
global	hhcleaning		"$hhdo/03_Cleaning"
global	hhconstruct		"$hhdo/04_Construct"
global	hhanalysis		"$hhdo/05_Analysis"

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


//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
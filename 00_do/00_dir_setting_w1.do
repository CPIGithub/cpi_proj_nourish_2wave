/*******************************************************************************

Project Name		: 	Project Nourish
Purpose				:	1st round data collection				
Author				:	Nicholus Tint Zaw
Date				: 	5/09/2022
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
	
	global dir		"H:\.shortcut-targets-by-id\1FlMBezA98hhmxqH0wJcxkcRb1-QfJM5R\1st Round Data Collection\Data_workflow"
	
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


global w1raw	 	"$dir/01_raw"
global w1do			"$dir/02_do"
global w1dta		"$dir/03_cleaned_data"
global w1out		"$dir/04_outputs"
global w1result 	"$dir/05_results"


//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

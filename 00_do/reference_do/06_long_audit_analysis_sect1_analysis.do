
	* bring in data
	use "$foodenv_prep/2023_food_vendor_detailed_prep_sect1.dta", clear 
	
		*** create tables ***
		gen temp=rural_urban
	
		*** user input ***
		scalar numberoftables=1 /*PUT THE TOTAL NUMBER OF TABLES HERE */
		global excel foodenv_tables /* PUT THE EXCEL EXPORT PATHWAY HERE */

		global matrixname1 "sec1" /* PUT THE TABLE NAME HERE */
		global ${matrixname1}tablevars "outlet_wetmarket-outlet_adyn"  /*LIST VARS HERE*/
		global ${matrixname1}tablecatvars "outlet_wetmarket" /*LIST CATEGORICAL VARIABLES (i.e. more than 2 categories!) HERE */
		global ${matrixname1}tablecondition "" /* PUT ANY OTHER CONDITION FOR TABLE HERE */
		global ${matrixname1}tableexcelfile "foodenv_detailed_audit.xlsx" /* PUT NAME EXCEL FILE HERE */
		
	*** baseline table generation ***
		do "${foodenv_ado}00_desc_table_loop.do"			
		
		
		*** Questions ***
			
			* create variables on outlets selling GDQS healthy? GDQS unhealthy? Nova 4 foods?
			
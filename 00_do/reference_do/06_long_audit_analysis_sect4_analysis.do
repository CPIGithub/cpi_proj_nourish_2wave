
	* bring in advertisement-level data
	use "$foodenv_prep/2023_food_vendor_detailed_prep_sect4_adlevel.dta", clear 
	
		*** create tables ***
			
			*** stratifying rural/urban ***
			gen temp=rural_urban
		
			* having trouble exporting out variables with long labels - modifying label *
			label list gdqs_foodcat
			label def gdqs_foodcat 5 "Citrus fruits" 8 "Dark green leafy vegetables", modify
			
			*** user input ***
			scalar numberoftables=1 /*PUT THE TOTAL NUMBER OF TABLES HERE */
			global excel foodenv_tables /* PUT THE EXCEL EXPORT PATHWAY HERE */

			global matrixname1 "sec4_ads" /* PUT THE TABLE NAME HERE */
			global ${matrixname1}tablevars "ad*"  /*LIST VARS HERE*/
			global ${matrixname1}tablecatvars "ad_where ad_setting ad_chartype ad_gdqs ad_gdqsnegdet ad_gdqsposdet ad_brand" /*LIST CATEGORICAL VARIABLES (i.e. more than 2 categories!) HERE */
			global ${matrixname1}tablecondition "" /* PUT ANY OTHER CONDITION FOR TABLE HERE */
			global ${matrixname1}tableexcelfile "foodenv_detailed_audit.xlsx" /* PUT NAME EXCEL FILE HERE */
			
			*** baseline table generation ***
			do "${foodenv_ado}00_desc_table_loop.do"	
			
			drop temp
		
			*** stratifying inside/outside by outlet type ***
			gen temp=ad_where
			
			*** user input ***
			scalar numberoftables=1 /*PUT THE TOTAL NUMBER OF TABLES HERE */
			global excel foodenv_tables /* PUT THE EXCEL EXPORT PATHWAY HERE */

			global matrixname1 "sec4ads_setting" /* PUT THE TABLE NAME HERE */
			global ${matrixname1}tablevars "outlet_typecat outlet_type rural_urban"  /*LIST VARS HERE*/
			global ${matrixname1}tablecatvars "outlet_typecat outlet_type rural_urban" /*LIST CATEGORICAL VARIABLES (i.e. more than 2 categories!) HERE */
			global ${matrixname1}tablecondition "" /* PUT ANY OTHER CONDITION FOR TABLE HERE */
			global ${matrixname1}tableexcelfile "foodenv_detailed_audit.xlsx" /* PUT NAME EXCEL FILE HERE */
			
			*** baseline table generation ***
			do "${foodenv_ado}00_desc_table_loop_2c.do"	

		
	
	* bring in outlet-level data
	use "$foodenv_prep/2023_food_vendor_detailed_prep_sect4_outletlevel.dta", clear 
	
		*** create tables ***
		gen temp=rural_urban
		
		*** user input ***
		scalar numberoftables=1 /*PUT THE TOTAL NUMBER OF TABLES HERE */
		global excel foodenv_tables /* PUT THE EXCEL EXPORT PATHWAY HERE */

		global matrixname1 "sec4_outlet" /* PUT THE TABLE NAME HERE */
		global ${matrixname1}tablevars "outletad*"  /*LIST VARS HERE*/
		global ${matrixname1}tablecatvars "outletad_type" /*LIST CATEGORICAL VARIABLES (i.e. more than 2 categories!) HERE */
		global ${matrixname1}tablecondition "" /* PUT ANY OTHER CONDITION FOR TABLE HERE */
		global ${matrixname1}tableexcelfile "foodenv_detailed_audit.xlsx" /* PUT NAME EXCEL FILE HERE */
		
	*** baseline table generation ***
		do "${foodenv_ado}00_desc_table_loop.do"			
	
	
		*** Questions ***
			
			* create variables on outlets selling GDQS healthy? GDQS unhealthy? Nova 4 foods?
			
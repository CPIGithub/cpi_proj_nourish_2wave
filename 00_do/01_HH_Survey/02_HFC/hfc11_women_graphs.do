* **************************************************************************** *
* **************************************************************************** *
*                                                                      		   *
*   	World Food Program SPB Window - Jordan - Impact Evaluation			   *
*				High Frequency Sruvey - Women Survey						   *
*       	This dofile carries out high frequency checks.		          	   *
*                                                                     		   *
* **************************************************************************** *
* **************************************************************************** *

/*
  ** PURPOSE        Creating graphs to monitor the progress and quality of data collection.
  ** LAST UPDATE    July 18, 2022
  ** INPUT			hfcs_worker_data_prepped.dta	
  ** OUTPUT			total_surveys_line.png, total_surveys_histogram.png, 
					total_surveys_histogram_non_cumul.png, 
					enumerator_tot_surveys.png, 
					duration_enum1.png, duration_enum2.png, duration_enum3.png, 
					duration_enum4.png, duration_enum5.png, duration_enum6.png,
					duration_enum7.png, duration_enum8.png, duration_enum9.png, 
					duration_enum10.png, duration_enum11.png
  
  ** CONTENTS
		
		*1. IMPORT DATA
		*2. GRAPH GLOBALS
		*3. GRAPH 1: Total Completed/Declined Surveys by Date
		*4. GRAPH 2: Total Completed Surveys by Enumerator
		*5. GRAPH 3: Distribution Survey duration by Enumerator

		
*******************************************************************************/

	 *1. IMPORT DATA
	
	use "${Worker_hfcdta}/Round_1/hfcs_women_hf_data_prepped.dta", clear
		
	*2. GRAPHS GLOBALS
	
		global graph_opts ///
		  title(, justification(left) color(black) span pos(11)) ///
		  graphregion(color(white)) ///
		  xtit(,placement(center) justification(center)) ///
		  ylab(,angle(0) nogrid) ///
		  legend(region(lc(none) fc(none))) 

	*3. GRAPH 1: Total Completed/Declined Surveys by Date
		
		*Creating variables of interest: 
			*Totals
			foreach var of varlist completed declined {
					bysort startdate: egen tot_`var' = sum(`var')
				}
			
			format startdate %dM_d

			preserve
				keep tot_completed tot_declined startdate 
				duplicates drop 
				sort startdate 
				
				*Creating aggregated total of surveys variable
				gen id = 1
				bysort id (startdate): gen total_com_ag = sum(tot_completed)  
				bysort id (startdate): gen total_decl_ag = sum(tot_declined)  
				
				*Graph 1.1: line graph
				line total_com_ag total_decl_ag startdate,  ///
						ytitle(Number of surveys) 			///
						 legend(on                       	/// 
								order(1 "Completed"        	/// Set label to show up in legend
									  2 "Declined")        	///
								cols(2)                  	/// Show all legends in one line (2 columns)
								pos(12))  					///
								${graph_opts} 				
				
				graph export "${Worker_hfcout}/Round_1/graphs/total_surveys_line.png", replace width(600) height(450)
				
				*Graph 1.2: histogram
				twoway bar total_com_ag  startdate, base(0) barw(0.4) ///
					|| bar total_decl_ag startdate, base(0) barw(0.4)	///
						ytitle(Number of surveys) 			///
						 legend(on                       	/// 
								order(1 "Completed"        	/// Set label to show up in legend
									  2 "Declined")        	///
								cols(2)                  	/// Show all legends in one line (2 columns)
								pos(12))  					///
								${graph_opts} 				
				
				graph export "${Worker_hfcout}/Round_1/graphs/total_surveys_histogram.png", replace width(600) height(450)
				
				*Graph 1.3: histogram (non-cumultative)
				twoway bar tot_completed  startdate, base(0) barw(0.4) ///
					|| bar tot_declined startdate, base(0) barw(0.4)	///
						ytitle(Number of surveys) 			///
						 legend(on                       	/// 
								order(1 "Completed"        	/// Set label to show up in legend
									  2 "Declined")        	///
								cols(2)                  	/// Show all legends in one line (2 columns)
								pos(12))  					///
								${graph_opts} 				
				
				graph export "${Worker_hfcout}/Round_1/graphs/total_surveys_histogram_non_cumul.png", replace width(600) height(450)
			restore     
			 

	*3. GRAPHS 2: Total Completed Surveys by Enumerator
			 
		*Creating variables of interest: 
			*Totals
			bysort enumeratorname startdate: egen tot_completed_enum = sum(completed)
				
			preserve
				keep enumerator enumeratorname tot_completed_enum startdate 
				duplicates drop 
				sort startdate 
				
				*Creating aggregated total of surveys variable
				bysort enumeratorname (startdate): gen total_com_ag = sum(tot_completed_enum)  
				
				sort enumeratorname startdate
				
				*Graph: Line Graph
				
				twoway ///
					(line total_com_ag startdate if enumerator == "2000005689") 		///
					(line total_com_ag startdate if enumerator == "2000049861") 		///
					(line total_com_ag startdate if enumerator == "2000076695") 		///
					(line total_com_ag startdate if enumerator == "2000082397") 		///
					(line total_com_ag startdate if enumerator == "9752046229") 		///
					(line total_com_ag startdate if enumerator == "9752046648") 		///
					(line total_com_ag startdate if enumerator == "9822058918") 		///
					(line total_com_ag startdate if enumerator == "9832049891") 		///
					(line total_com_ag startdate if enumerator == "9842049038") 		///
					(line total_com_ag startdate if enumerator == "9862003660") 		///
					(line total_com_ag startdate if enumerator == "9882039159") 		///
					(line total_com_ag startdate if enumerator == "9902052056") 		///
					(line total_com_ag startdate if enumerator == "9912016679") 		///
					(line total_com_ag startdate if enumerator == "9912041195") 		///
					(line total_com_ag startdate if enumerator == "9912041697") 		///
					(line total_com_ag startdate if enumerator == "9922056804") 		///
					(line total_com_ag startdate if enumerator == "9931013624") 		///
					(line total_com_ag startdate if enumerator == "9932020416") 		///
					(line total_com_ag startdate if enumerator == "9932021102") 		///
					(line total_com_ag startdate if enumerator == "9932032217") 		///
					(line total_com_ag startdate if enumerator == "9932058817") 		///
					(line total_com_ag startdate if enumerator == "9942011954") 		///
					(line total_com_ag startdate if enumerator == "9942022053") 		///
					(line total_com_ag startdate if enumerator == "9942023210") 		///
					(line total_com_ag startdate if enumerator == "9942049366") 		///
					(line total_com_ag startdate if enumerator == "9942058548") 		///
					(line total_com_ag startdate if enumerator == "9952004597") 		///
					(line total_com_ag startdate if enumerator == "9952015188") 		///
					(line total_com_ag startdate if enumerator == "9952019965") 		///
					(line total_com_ag startdate if enumerator == "9952031008") 		///
					(line total_com_ag startdate if enumerator == "9952066497") 		///
					(line total_com_ag startdate if enumerator == "9962013885") 		///
					(line total_com_ag startdate if enumerator == "9962020511") 		///
					(line total_com_ag startdate if enumerator == "9962033789") 		///
					(line total_com_ag startdate if enumerator == "9962045582") 		///
					(line total_com_ag startdate if enumerator == "9992019744") 		///
					(line total_com_ag startdate if enumerator == "9992029706") 		///
					(line total_com_ag startdate if enumerator == "9992032061") 		///
					(line total_com_ag startdate if enumerator == "9992040666") 		///
					(line total_com_ag startdate if enumerator == "9992040931") , 		///
						 ytitle(Number of surveys) 										///
						 legend(on                       								/// 
								order(	1  	"Enum. N. 2000005689"      					///
										2  	"Enum. N. 2000049861"      					///
										3  	"Enum. N. 2000076695"      					///
										4  	"Enum. N. 2000082397"      					///
										5  	"Enum. N. 9752046229"      					///
										6  	"Enum. N. 9752046648"      					///
										7  	"Enum. N. 9822058918"      					///
										8  	"Enum. N. 9832049891"      					///
										9  	"Enum. N. 9842049038"      					///
										10  "Enum. N. 9862003660"      					///
										11  "Enum. N. 9882039159"      					///
										12  "Enum. N. 9902052056"      					///
										13  "Enum. N. 9912016679"      					///
										14  "Enum. N. 9912041195"      					///
										15  "Enum. N. 9912041697"      					///
										16  "Enum. N. 9922056804"     					///
										17  "Enum. N. 9931013624"      					///
										18  "Enum. N. 9932020416"      					///
										19  "Enum. N. 9932021102"      					///
										20  "Enum. N. 9932032217"      					///
										21  "Enum. N. 9932058817"      					///
										22  "Enum. N. 9942011954"      					///
										23  "Enum. N. 9942022053"      					///
										24  "Enum. N. 9942023210"      					///
										25  "Enum. N. 9942049366"      					///
										26  "Enum. N. 9942058548"      					///
										27  "Enum. N. 9952004597"      					///
										28  "Enum. N. 9952015188"      					///
										29  "Enum. N. 9952019965"      					///
										30  "Enum. N. 9952031008"      					///
										31  "Enum. N. 9952066497"      					///
										32  "Enum. N. 9962013885"      					///
										33  "Enum. N. 9962020511"      					///
										34  "Enum. N. 9962033789"      					///
										35  "Enum. N. 9962045582"      					///
										36  "Enum. N. 9992019744"      					///
										37  "Enum. N. 9992029706"      					///
										38  "Enum. N. 9992032061"      					///
										39  "Enum. N. 9992040666"      					///
										40  "Enum. N. 9992040931")				   	    ///
									  cols(1)               /// Show all legends in one line (1 column)
									  pos(3))    			///
									  ${graph_opts}			
				
				graph export "${Worker_hfcout}/Round_1/graphs/enumerator_tot_surveys.png", replace width(600) height(450)
			 restore     
			 
			 
	*4. GRAPH 3: Durantion Survey by Enumerator
	 
		*Importing data
		use "${Worker_hfcdta}/Round_1/worker_enumerator_data.dta", clear
		
		gen duration_2 = duration_1/60
		
		label variable duration_1 "Survey duration (minutes)"
		label variable duration_2 "Survey duration (hours)"

		*Graphs by enumerator 
		levelsof enumerator, local(enuid)
		
		local i = 1
		
		foreach enu in `enuid' {
			
			histogram duration_2 if enumerator == "`enu'", ///
			percent lcolor(green) fcolor(green*0.2) /// 
			ytitle(Percentage (%)) 				   ///
			${graph_opts}	
			graph export "${Worker_hfcout}/Round_1/graphs/duration_enum`i'.png", replace width(600) height(450)
			
			local i = 1 + `i'
			
		}
				
			

****End do-file. 

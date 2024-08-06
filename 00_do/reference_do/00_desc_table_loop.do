set trace on	
		forvalue m=1(1)`=scalar(numberoftables)' { 
			preserve 
			display "Currently creating ${matrixname`m'}"
			local ifnotcat ""
			if "${${matrixname`m'}tablecondition}"!="" { /* only keep relevant subsample */
				keep ${${matrixname`m'}tablecondition}
			}
			
			if "${${matrixname`m'}tablecatvars}"=="" {
				local ifnotcat ""\`j'" != """	/* condition if no categorical vars */
			}
			else { 
				local j=1
				local numbvars: word count "${${matrixname`m'}tablecatvars}"
				foreach c in ${${matrixname`m'}tablecatvars} {	/* create if statement used to identify categorical variables */
					if `j'==1 {
						local ifnotcat ""\`j'" != "`c'""	/* backslash prevents macro expansion */
					}
					else {
						local ifnotcat "`macval(ifnotcat)' & "\`j'" != "`c'""	/* macval function prevents macro expansion */
					}
					local j=`j'+1
				}
			}
	
			matrix define ${matrixname`m'}=J(300,100,.) /* no need to specify number of rows; extra (empty) rows eliminated below */

			global rowname ""N" "		/* row name for first row */
			global rownameshort ""N" "	
			global footnote0 ""
			global footnote1 ""
			global footnote ""
			
			local i=2 				/* first row reserved for max sample size numbers */				
			local obsallmin=r(N)	/* these locals are used to keep track of (min/max) number of observations for each table */
			local obsallmax=0
			forvalue c=1(1)3 {
				quietly count if temp==`c'
				local obsc`c'min=r(N)
				local obsc`c'max=0
			}
			quietly foreach j of varlist ${${matrixname`m'}tablevars} {
				local col=1				/* column to start in */
				if `ifnotcat' {			/* ifnotcat local defined above; contains all categorical variables */
					quietly levelsof `j', local(levels) /* define multiplicator to get % in the 0 to 100 range for dichotomous vars */
					local multiplicator=1
					local sdnecessary=1
					local testn: word count `levels'
					if `testn'>1 { /* need this condition for vars w/o variability; if only one value, test1 is not defined */
						local test0: word 1 of `levels'
						local test1: word 2 of `levels'
						if `test0'==0 & `test1'==1 & `testn'==2 {	/* this defines a dichotomous variable */
							local multiplicator=100
							local sdnecessary=.
						}
					}
					else if `testn'==1 { /* need this condition for binary vars w/o variability and all equal to 1 */
						local test0: word 1 of `levels'
						if `test0'==1 {
							local multiplicator=100
							local sdnecessary=.
						}
					}
					else {
						local sdnecessary=.
					}
					quietly sum `j', d
					matrix ${matrixname`m'}[`i',`col']=r(mean)*`multiplicator'
					matrix ${matrixname`m'}[`i',`col'+1]=r(sd)*`multiplicator'*`sdnecessary'
					matrix ${matrixname`m'}[`i',`col'+2]=r(p50)*`multiplicator'
					matrix ${matrixname`m'}[`i',`col'+3]=r(p25)*`multiplicator'
					matrix ${matrixname`m'}[`i',`col'+4]=r(p75)*`multiplicator'
					matrix ${matrixname`m'}[`i',`col'+5]=r(N)
					local rowlabel: var l `j' /* populate the rownames */
					local rowlabelshort=substr("`rowlabel'",1,32)
					global rownameshort "$rownameshort "`rowlabelshort'"" /* this one used for matrix, full length for excel export */
					global rowname "$rowname "`rowlabel'""	
					if `obsallmax' < r(N) {
						local obsallmax=r(N)
					}
					if `obsallmin' > r(N) {
						local obsallmin=r(N)
					}
					local col=`col'+6
					forvalue c=1(1)3 {
						quietly sum `j' if temp==`c', d
						matrix ${matrixname`m'}[`i',`col']=r(mean)*`multiplicator'
						matrix ${matrixname`m'}[`i',`col'+1]=r(sd)*`multiplicator'*`sdnecessary'
						matrix ${matrixname`m'}[`i',`col'+2]=r(p50)*`multiplicator'
						matrix ${matrixname`m'}[`i',`col'+3]=r(p25)*`multiplicator'
						matrix ${matrixname`m'}[`i',`col'+4]=r(p75)*`multiplicator'*`sdnecessary'						
						matrix ${matrixname`m'}[`i',`col'+5]=r(N)
						if `obsc`c'max' < r(N) {
							local obsc`c'max=r(N)
						}
						if `obsc`c'min' > r(N) {
							local obsc`c'min=r(N)
						}
						local col=`col'+6
					}
					sum `j'
					local allobs`j'=r(N)
					sum `j' if temp==1
					local c1obs`j'=r(N)
					sum `j' if temp==2
					local c2obs`j'=r(N)
					sum `j' if temp==3
					local c3obs`j'=r(N)
					if `allobs`j''!=0 & `c1obs`j''!=0 & `c2obs`j''!=0 & `c3obs`j''!=0 {
						quietly xi: reg `j' i.temp
						quietly testparm *temp*	
						matrix ${matrixname`m'}[`i',`col']=_se[_Itemp_2]*`multiplicator'
						matrix ${matrixname`m'}[`i',`col'+1]=(1-F(e(df_m),e(df_r),e(F)))
					}
					local i=`i'+1
					local col=`col'+1
					macro drop levels
				}
				else {
					local rowlabel: var l `j' /* populate the rownames */
					local rowlabelshort=substr("`rowlabel'",1,32)
					global rownameshort "$rownameshort "`rowlabelshort'"" /* this one used for matrix, full length for excel export */
					global rowname "$rowname "`rowlabel'""		
					local i=`i'+1	/* empty line at the start of each categorical variable; only information on this line is the row name */
					quietly levelsof `j', local(levels)
					local levelcount: word count `levels'
					local lastlevel: word `levelcount' of `levels'
					count if `j'!=.
					if `obsallmax' < r(N) {
						local obsallmax=r(N)
					}
					if `obsallmin' > r(N) {
						local obsallmin=r(N)
					}
					forvalue c=1(1)3 {
						quietly count if `j'!=. & temp==`c'
						if `obsc`c'max' < r(N) {
							local obsc`c'max=r(N)
						}
						if `obsc`c'min' > r(N) {
							local obsc`c'min=r(N)
						}
					}
					foreach l of local levels {
						local tempcount=0	/* this local used to add up number of observations across all levels */
						quietly count if `j'!=.
						local total=r(N)
						quietly sum `j' if `j'==`l'
						matrix ${matrixname`m'}[`i',1]=r(N)/`total'*100
						matrix ${matrixname`m'}[`i',6]=r(N)
						local labelname: value label `j'
						if "`labelname'"=="" {		/* in case no value labels are defined */
							local rowlabel=`l'
						}
						else {
							local rowlabel: label `labelname' `l'
							local rowlabelshort=substr("`rowlabel'",1,32)
						}
						global rownameshort "$rownameshort "`rowlabelshort'"" /* this one used for matrix, full length for excel export */
						global rowname "$rowname "`rowlabel'""	
						local col=6
						forvalue c=1(1)3 {
							quietly count if `j'!=. & temp==`c'
							local total=r(N)
							quietly sum `j' if `j'==`l' & temp==`c'
							matrix ${matrixname`m'}[`i',`col'+1]=r(N)/`total'*100
							matrix ${matrixname`m'}[`i',`col'+6]=r(N)
							local col=`col'+6
						}
						if `l'==`lastlevel' {
							local col=`col'+2
							*** use tab chi2 ***
							sum `j'
							if r(N)!=0 {
								tab `j' temp, chi2
								matrix ${matrixname`m'}[`i',`col']=r(p)
							}
						}
						local i=`i'+1
					}    
				}
			}
			matrix ${matrixname`m'}[1,6]=`obsallmax' /* write max sample size to top of each column */
			forvalue c=1(1)3 {
				matrix ${matrixname`m'}[1,6+`c'*6]=`obsc`c'max'
			}
			
			*** generate sample size footnote ***
			local footnotenecessary=0
			global footnote "${footnote}Sample size ranged from "
	/*		if `obsallmin' !=`obsallmax' {
				global footnote "${footnote}N = `obsallmin' to `obsallmax' in the full sample; "
				local footnotenecessary=1
			}*/
			tokenize `""Baseline" "COVID Round 1" "COVID Round 2""'
			forvalue c=1(1)3 {
				if `obsc`c'min' !=`obsc`c'max' {
					global footnote "${footnote}N = `obsc`c'min' to `obsc`c'max' in ``c''; " 
					local footnotenecessary=1
				} 
			}
			if `footnotenecessary'==0 {	/* if complete sample for all variables: no footnote necessary */
				global footnote ""
			}
			else { /* replace final ";" to "." and add "and" after the last ";" */
				local l=length("${footnote}")-2
				global footnote=substr("${footnote}",1,`l')+"."
				local numbersemicolon=length("${footnote}") - length(subinstr("${footnote}", ";", "", .))
				global footnote=subinstr("${footnote}", ";", "; and", `numbersemicolon')
				global footnote=subinstr("${footnote}", "; and", ";", `numbersemicolon'-1)
			}
		
		display `i'
		display `col'
		
		*** elimate empty rows ***
			mat temp=${matrixname`m'}[1..`i'-1,1..`col']
			mat drop ${matrixname`m'}
			mat rename temp ${matrixname`m'}
			
		*** name rows/cols; transfer to data set ***
			mat rown ${matrixname`m'}=$rownameshort			
			mat coln ${matrixname`m'}=%ma sda p50a p25a p75a #a %m1 sd1 p501 p251 p751 #1 %m2 sd2 p502 p252 p752 #2 %m3 sd3 p503 p253 p753 #3 se p
			noisily mat list ${matrixname`m'}
			display "$footnote" 
		
			svmat2 ${matrixname`m'}, names(pctma sda p50a p25a p75a na pctm1 sd1 p501 p251 p751 n1 pctm2 sd2 p502 p252 p752 n2 pctm3 sd3 p503 p253 p753 n3 se p)
			** rnames(vars) option doesn't work (long strings are truncated) **
			** extract var names differently **
			gen str150 vars=""
			local c=1 
			foreach i in $rowname {
				quietly replace vars="`i'" in `c'
				local c=`c'+1
			}	
			
			keep vars pctma sda na pctm1 sd1 n1 pctm2 sd2 n2 pctm3 sd3 n3 se p 
			order vars pctma sda na pctm1 sd1 n1 pctm2 sd2 n2 pctm3 sd3 n3 se p 
			format %9.1f pc* sd*
			format %9.3f p
			
		*** add footnote ***
			gen str2045 footnote="$footnote" in 1

		*** export to excel ***	
			noisily export excel using "${${excel}}${${matrixname`m'}tableexcelfile}", sheet(${matrixname`m'}) firstrow(variables) sheetmodify
			restore
			
		}

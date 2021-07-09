*!version5.0 12JUN2020

/* -----------------------------------------------------------------------------
** PROGRAM NAME: summtab
** VERSION: 5.0
** DATE: JUNE 12, 2020
** -----------------------------------------------------------------------------
** CREATED BY: JOHN GALLIS
** DEDICATED TO THE MEMORY OF TIRZAH ELISE GALLIS
** -----------------------------------------------------------------------------
** PURPOSE: THIS PROGRAM ALLOWS THE USER TO CREATE NICELY-FORMATTED SUMMARY
			TABLES OVERALL AND/OR STRATIFIED BY A CATEGORICAL VARIABLE
** UPDATES: 
		MAY 30, 2018 - ADDED OPTION TO CHOOSE OUTPUT DIRECTORY
		MAY 31, 2018 - ADDED ABILITY FOR PROGRAM TO TAKE CATEGORICAL "BY" VARIABLES 
							CODED AS STRING VARIABLES
					 - FIXED AN ERROR WHERE MISSING VALUES IN THE TOTAL COLUMN 
							FOR CATEGORICAL VARIABLES WERE SHOWING UP AS MISSING
		JUL 10, 2018 - FIXED AN ERROR IN THE COMMA FOR QUARTILES IN THE OVERALL COLUMN
		AUG 16, 2018 - ADDED FUNCTIONALITY FOR CLUSTERED P-VALUES
		SEP 17, 2018 - FIXED ERROR IN WEIGHTING OF CATEGORICAL VARIABLES
		OCT 02, 2018 - ADDING FUNCTIONALITY TO COMPUTE ROW PERCENTAGE, RATHER THAN COLUMN PERCENTAGE
		MAR 05, 2019 - REMOVED DEPENDENCE ON THE PACKAGE "DISTINCT"
		MAR 05, 2019 - MODIFIED TO ALLOW OUTPUT OF ONLY AN EXCEL FILE
		MAR 15, 2019 - CORRECTING ERROR THAT MADE THE TOTAL COLUMN HAVE MISSING % FOR CATEGORICAL VARIABLES
		MAR 15, 2019 - CORRECTING ERROR WHERE PVALUES WEREN'T BEING DISPLAYED
		MAR 18, 2019 - ADDING OPTION FOR TOTAL # NONMISSING FOR CONTINUOUS VARIABLES
		MAR 18, 2019 - PUTTING N AND PERCENT NON-MISSING ON THEIR OWN LINE
		APR 11, 2019 - ALLOWING FOR APPENDING OF WORD FILES, AND ADDING OF SHEETS TO EXCEL FILES
					 - ADDED OPTION TO SPECIFY NUMBER OF DIGITS AFTER THE DECIMAL POINT FOR CATEGORICAL PERCENTAGES
					 - FIXED BUG IN WEIGHTS OPTION, WHERE P-VALUE WASN'T BEING COMPUTED FOR CATEGORICAL VARIABLES
		APR 15, 2019 - FIXED A BUG WHERE IF MEAN, MEDIAN, AND PNONMISS WERE SELECTED, PUTDOCX ROWS WERE NOT ADDED TO 
						THE DOCUMENT CORRECTLY
					 - MADE ptype=2 THE DEFAULT IF ONLY MEDIAN IS SELECTED
		APR 22, 2019 - FIXED ERROR WHERE MIN, MAX WAS NOT INCLUDING THE COMMA IF MEDIAN IS NOT ALSO SELECTED
						FIXED ERROR WHERE PROGRAM WAS NOT ALLOWING THE INCLUSION OF MEAN AND PNONMISS ONLY, IN WORD DOCUMENTS
		NOV 05, 2019 - ADDED THE ABILITY TO OBTAIN MISSING VALUES FOR CATEGORICAL VARIABLES THAT ARE ENTIRELY ZERO AT SOME LEVEL
						OF THE "BY" VARIABLE, USING A MODIFIED VERSION OF NICK COX'S TABCOUNT.  USEFUL ESPECIALLY FOR SUMMARIZING
						LONGITUDINAL DATA ACROSS TIME POINTS WHERE SOME OF THE DATA IS NOT COLLECTED AT ALL TIME POINTS.  THIS MODIFIED
						PROGRAM ALSO ALLOWS FOR ANALYSIS WEIGHTS.
					 - ADDED OPTIONS FOR MORE NUANCE FOR HOW MISSING VALUES ARE HANDLED FOR CATEGORICAL VARIABLES, USING CATMISSTYPE OPTION.  THREE OPTIONS:
							- none: Missing values are not summarized (default)
							- missperc: Missing values are treated as another category and included in the percent of the total
							- missnoperc: Missing values are treated as another category, but are not included in the percent of the total.
					 - ADDED OPTIONS TO DISPLAY FREQUENCIES WHEN WEIGHTING CATEGORICAL VARIABLES.  THREE OPTIONS:
							- off: Do not display frequencies for weighted categorical variables (default)
							- fractional: Display fractional frequencies
							- ceiling: Display frequencies rounded up.
					 - FOR clustpval, REPLACES P-VALUES FOR CATEGORICAL VARIABLES WITH MISSING VALUES, SINCE COMPUTING CLUSTERED (AND SURVEY WEIGHTED) P-VALUES
						FOR CATEGORICAL CROSS-TABULATIONS IS PROBLEMATIC. 
		NOV 07, 2019 - CONTINUOUS VARIABLES AT ONLY ONE LEVEL OF THE "BY" VARIABLE HAVE P-VALUES AS MISSING NOW.
		JUN 12, 2020 - FIXED BUG THAT DID NOT ALLOW ONE TO REPORT MEAN, RANGE, AND N (%) TOGETHER
					 - ADDED FUNCTIONALITY TO REPORT PERCENT MISSING FOR CONTINUOUS VARIABLES
					 - ADDED FUNCTIONALITY TO REPORT MEAN (SD) ON THE SAME ROW AS THE VARIABLE LABEL THROUGH THE MEANROW OPTION
					 - ADDED FUNCTIONALITY TO REPORT N (%) ON THE SAME ROW AS THE VARIABLE LABEL THROUGH THE CATROW OPTION
** -----------------------------------------------------------------------------
** OPTIONS: SEE HELP FILE
** -----------------------------------------------------------------------------
*/

program define summtab
	version 15
	#delimit ;
	syntax [if] [in], [by(varname) total contvars(varlist) catvars(varlist) meanrow catrow mean median range pnonmiss pmiss rowperc catmisstype(string) pval 
								contptype(integer 1) catptype(integer 1) clustpval clustid(varname) wts(varname) wtfreq(string) fracfmt(integer 2)
								mnfmt(integer 2) medfmt(integer 1) rangefmt(integer 1) pnonmissfmt(integer 1) pmissfmt(integer 1) catfmt(integer 1) pfmt(integer 3)
								title(string) directory(string) word wordname(string) excel excelname(string) replace append sheetname(string) *]
	
	;
	#delimit cr
	
	
/* ERROR MESSAGES */	
	if "`pnonmiss'" == "pnonmiss" & "`pmiss'" == "pmiss" {
		di as error "pnonmiss and pmiss cannot be specified at the same time"
		exit 198
	}
	if "`word'" == "" & "`excel'" == "" {
		di as error "Must specify either Word or Excel output (or both)"
		exit 198
	}
	
	if "`contvars'" == "" & "`catvars'" == "" {
		di as error "Must specify at least one variable to summarize."
		exit 198
	}
	
	if "`contvars'" != "" & "`mean'" == "" & "`median'" == "" & "`range'" == "" & "`pnonmiss'" == "" {
		di as error "Must specify at least one summary statistic for continuous variables."
		exit 198
	}
	
	if "`meanrow'" == "meanrow" & ("`median'" == "median" | "`range'" == "range" | "`pnonmiss'" == "pnonmiss") {
		di as error "If using 'meanrow' option, only 'mean' can be specified" 
		exit 198
	}
	
	if "`directory'"!="" {
		quietly cd "`directory'"
	}
	
	/* SET WEIGHTING FREQUENCY REPORTING DEFAULT AS "OFF" */
	if "`wtfreq'" == "" local wtfreq "off"
	
	/* SET CATMISSTYPE DEFAULT AS NONE */
	if "`catmisstype'" == "" local catmisstype "none"
	if "`catmisstype'" != "none" & "`catmisstype'" != "missperc" & "`catmisstype'" != "missnoperc" {
		di as error "Invalid catmisstype specification"
		exit 198
	}
	
	* catrow can only be specified if missingness is "none"
	if "`catrow'" == "catrow" & "`catmisstype'" != "none" {
		di as error "catrow option only works if catmisstype = none"
		exit 198
	}
	
	/* CLEAR PUTDOCX */
/* for word table ||||||||||||||||||||||||||||||| */
	if "`word'" == "word" {
		capture putdocx clear
	}
	
	marksample touse
	qui tempfile _temp
	qui save "`_temp'"
	qui keep if `touse'

/*||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||| START PUTDOCX |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| */

/* for word table ||||||||||||||||||||||||||||||| */
	if "`word'" == "word" {
		putdocx begin, `options' 
	}

/* TITLE */
	if "`title'" == "" {
		local title "Table 1"
	}
		
	if "`word'" == "word" {
		putdocx paragraph
		putdocx text ("`title'"), bold
	}
/* HEADER |||||||||||||||||||||||||||||||||||||||||||||||||||||| */

	
	/* BY OPTION SPECIFIED ||||||||||||||||||||||||||||||||||| */
	if "`by'" != "" {
		qui tab `by'
		local n_cats = r(r)
	
	/* LOGIC FOR INCLUDING OR EXCLUDING A TOTAL COLUMN */
		if "`total'" == "total" {
			if "`pval'" == "pval" {
				local col = 2+2+`n_cats'
			}
			else if "`pval'" == "" {
				local col = 1+2 + `n_cats'
			}
		}
		else if "`total'" != "total" {
			if "`pval'" == "pval" {
				local col = 1+2 + `n_cats'
			}
			else if "`pval'" == "" {
				local col = 2 + `n_cats'
			}
		}
	}
	
	/* BY OPTION NOT SPECIFIED ||||||||||||||||||||||||||||| */
	else if "`by'" == "" {
		local col = 3
	}
	
	if "`excelname'" == ""{
		local excelname "table1"
	}
	
	if "`excel'" == "excel" {
		if "`sheetname'" == "" {
			qui putexcel set `excelname', `replace'
		}
		else if "`sheetname'" != "" {
			qui putexcel set `excelname', modify sheet("`sheetname'", replace)
		}
		qui putexcel A1 = " "
		qui putexcel A2 = " "
	}

	/* for word table ||||||||||||||||||||||||||||||| */
	if "`word'" == "word" {
		putdocx table tbl1 = (2,`col'), border(all, nil) memtable layout(fixed)
		putdocx table tbl1(1,1) = (" "), halign(left) border(top) colspan(2)
		putdocx table tbl1(2,1) = (" "), halign(left) border(bottom) colspan(2)
	}

/* |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| */

	local c_col = 2
	
	local i=1
	
	/* BY OPTION SPECIFIED ||||||||||||||||||||||||||||||||||| */
	if "`by'" != "" {
		qui levelsof `by', local(`by'_g)
		local lbe: value label `by' 
		
		foreach l of local `by'_g {
			if "`lbe'" != ""{	
				local var_lab: label `lbe' `l'
			}
			else {
				local var_lab `l'
			}
			
			/* for word table ||||||||||||||||||||||||||||||| */
			if "`word'" == "word" {
				putdocx table tbl1(1,`c_col') = ("`var_lab'"), halign(center) border(top) colspan(1) valign(center) 
			}
		
			/* for excel table ||||||||||||||||||||||||||||||| */
			if "`excel'" == "excel" {
				local i = `i' + 1
				local letter : word `i' of `c(ALPHA)'
				qui putexcel `letter'1 = "`var_lab'", hcenter
			}
			/* ||||||||||||||||||||||||||||||||||||||||||||||| */
			
			if substr("`:type `by''" , 1, 3) == "str" {
				quietly: sum if `by' == "`l'"
			}
			else {
				quietly: sum if `by' == `l'
			}
			local obs_`l' = r(N)
			
			/* for word table ||||||||||||||||||||||||||||||| */
			if "`word'" == "word" {
				putdocx table tbl1(2,`c_col') = ("(N = `obs_`l'')"), halign(center) border(bottom) colspan(1) valign(center) 
			}
			local ++c_col
			
			/* for excel table ||||||||||||||||||||||||||||||| */
			if "`excel'" == "excel" {
				qui putexcel `letter'2 = "(N = `obs_`l'')", hcenter
			}
			/* ||||||||||||||||||||||||||||||||||||||||||||||| */
		}
	
		/* LOGIC FOR INCLUDING OR EXCLUDING A TOTAL COLUMN */
		if "`total'" == "total" {
			if substr("`:type `by''" , 1, 3) == "str" {
				quietly: sum if `by' != ""
			}
			else {
				quietly: sum if `by' != .
			}
			local obs_all = r(N)
			
			/* for word table ||||||||||||||||||||||||||||||| */
			if "`word'" == "word" {
				putdocx table tbl1(1,`c_col') = ("Total"), halign(center) border(top) colspan(1) valign(center) 
				putdocx table tbl1(2,`c_col') = ("(N = `obs_all')"), halign(center) border(bottom) colspan(1) valign(center) 
			}
		
			/* for excel table ||||||||||||||||||||||||||||||| */
			if "`excel'" == "excel" {
				local i = `i' + 1
				local letter : word `i' of `c(ALPHA)'
				qui putexcel `letter'1 = "Total", hcenter
				qui putexcel `letter'2 = "(N = `obs_all')", hcenter
			}
			/* ||||||||||||||||||||||||||||||||||||||||||||||| */
		}
	
	
		if "`pval'" == "pval" {
			if "`total'" == "total" local ++c_col
				
			/* for word table ||||||||||||||||||||||||||||||| */
			if "`word'" == "word" {
				putdocx table tbl1(1,`c_col') = (" "), halign(right) border(top) 
				putdocx table tbl1(2,`c_col') = ("p-value"), halign(center) border(bottom)
			}
				
			/* for excel table ||||||||||||||||||||||||||||||| */
			if "`excel'" == "excel" {
				local i = `i' + 1
				local letter : word `i' of `c(ALPHA)'
				qui putexcel `letter'1 = " "
				qui putexcel `letter'2 = "p-value", hcenter
			}
			/* ||||||||||||||||||||||||||||||||||||||||||||||| */
		}
	}
	else if "`by'" == "" {
		quietly: sum
		local obs_all = r(N)

		/* for word table ||||||||||||||||||||||||||||||| */
		if "`word'" == "word" {
			putdocx table tbl1(1,`c_col') = ("Total"), halign(center) border(top) colspan(1) valign(center) 
			putdocx table tbl1(2,`c_col') = ("(N = `obs_all')"), halign(center) border(bottom) colspan(1) valign(center) 
		}
		/* for excel table ||||||||||||||||||||||||||||||| */
		if "`excel'" == "excel" {
			local i = `i' + 1
			local letter : word `i' of `c(ALPHA)'
			qui putexcel `letter'1 = "Total", hcenter
			qui putexcel `letter'2 = "(N = `obs_all')", hcenter
		}
	}
	
	*continuous variables
	local row 1
	
	/* BY OPTION SPECIFIED ||||||||||||||||||||||||||||||||||| */
	if "`by'" != "" {
		if "`total'" == "total" {
			if "`pval'" == "pval" {
				local col = 2+2+`n_cats'
			}
			else if "`pval'" == "" {
				local col = 1+2+`n_cats'
			}
		}
		else if "`total'" != "total" {
			if "`pval'" == "pval" {
				local col = 1+2+`n_cats'
			}
			else if "`pval'" == "" {
				local col = 2+`n_cats'
			}
		}
	}
	else if "`by'" == "" {
		local col=3
	}
	/* for word table ||||||||||||||||||||||||||||||| */
	if "`word'" == "word" {
		putdocx table tbl2 = (1,`col'), memtable cellmargin(left, 0.015) cellmargin(right, 0.015) layout(fixed) border(all,nil)
		putdocx table tbl2(`row',.), addrows(1)
	}

	
	/* BY OPTION SPECIFIED ||||||||||||||||||||||||||||||||||| */
	if "`by'" != "" {
		local sub_head = `col'-1
		
		/* for word table ||||||||||||||||||||||||||||||| */
		if "`word'" == "word" {
			forvalues c = 3/`sub_head'{
				putdocx table tbl2(`row',`c') = (" "), halign(right) valign(bottom)
				putdocx table tbl2(`row',`c') = (" "), halign(left) valign(bottom)
			}
		}
	}
/* |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||CONTINUOUS VARIABLE LOOP ||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| */
	
	local j=2
	local q=1
	foreach cv of local contvars {
	
		if "`meanrow'" == "meanrow" {
			if "`word'" == "word" putdocx table tbl2(`row',.), addrows(1)
		}
		else {
	/* for word table ||||||||||||||||||||||||||||||| */
			if "`word'" == "word" {
				if "`mean'" == "mean" & "`median'" != "median" & "`range'" != "range" & ("`pnonmiss'" != "pnonmiss" & "`pmiss'" != "pmiss") {
					putdocx table tbl2(`row',.), addrows(2)
				}
				else if "`mean'" == "mean" & "`median'" == "median" & "`range'" != "range" & ("`pnonmiss'" != "pnonmiss" & "`pmiss'" != "pmiss") {
					putdocx table tbl2(`row',.), addrows(3)		
				}
				else if "`mean'" == "mean" & "`median'" != "median" & "`range'" != "range" & ("`pnonmiss'" == "pnonmiss" | "`pmiss'" == "pmiss") {
					putdocx table tbl2(`row',.), addrows(3)		
				}
				else if "`mean'" == "mean" & "`median'" != "median" & "`range'" == "range" & ("`pnonmiss'" != "pnonmiss" & "`pmiss'" != "pmiss") {
					putdocx table tbl2(`row',.), addrows(3)		
				}
				else if "`mean'" == "mean" & "`median'" != "median" & "`range'" != "range" & ("`pnonmiss'" == "pnonmiss" | "`pmiss'" == "pmiss") {
					putdocx table tbl2(`row',.), addrows(3)		
				}
				else if "`mean'" == "mean" & "`median'" == "median" & "`range'" == "range" & ("`pnonmiss'" != "pnonmiss" & "`pmiss'" != "pmiss") {
					putdocx table tbl2(`row',.), addrows(4)		
				}
				else if "`mean'" == "mean" & "`median'" == "median" & "`range'" != "range" & ("`pnonmiss'" == "pnonmiss" | "`pmiss'" == "pmiss") {
					putdocx table tbl2(`row',.), addrows(4)		
				}
				else if "`mean'" == "mean" & "`median'" != "median" & "`range'" == "range" & ("`pnonmiss'" == "pnonmiss" | "`pmiss'" == "pmiss") {
					putdocx table tbl2(`row',.), addrows(4)		
				}
				else if "`mean'" == "mean" & "`median'" == "median" & "`range'" == "range" & ("`pnonmiss'" == "pnonmiss" | "`pmiss'" == "pmiss") {
					putdocx table tbl2(`row',.), addrows(5)		
				}
				
							
				else if "`mean'" != "mean" & "`median'" == "median" & "`range'" != "range" & ("`pnonmiss'" != "pnonmiss" & "`pmiss'" != "pmiss") {
					putdocx table tbl2(`row',.), addrows(2)		
				}
				else if "`mean'" != "mean" & "`median'" == "median" & "`range'" == "range" & ("`pnonmiss'" != "pnonmiss" & "`pmiss'" != "pmiss") {
					putdocx table tbl2(`row',.), addrows(3)		
				}
				else if "`mean'" != "mean" & "`median'" == "median" & "`range'" != "range" & ("`pnonmiss'" == "pnonmiss" | "`pmiss'" == "pmiss") {
					putdocx table tbl2(`row',.), addrows(3)		
				}
				else if "`mean'" != "mean" & "`median'" == "median" & "`range'" == "range" & ("`pnonmiss'" == "pnonmiss" | "`pmiss'" == "pmiss") {
					putdocx table tbl2(`row',.), addrows(4)		
				}
				
				
				else if "`mean'" != "mean" & "`median'" != "median" & "`range'" != "range" & ("`pnonmiss'" == "pnonmiss" | "`pmiss'" == "pmiss") {
					putdocx table tbl2(`row',.), addrows(2)		
				}
				else if "`mean'" != "mean" & "`median'" != "median" & "`range'" == "range" & ("`pnonmiss'" != "pnonmiss" & "`pmiss'" != "pmiss") {
					putdocx table tbl2(`row',.), addrows(2)		
				}
				else if "`mean'" != "mean" & "`median'" != "median" & "`range'" == "range" & ("`pnonmiss'" == "pnonmiss" | "`pmiss'" == "pmiss") {
					putdocx table tbl2(`row',.), addrows(3)		
				}
			}
		}
			
		
		if "`q'" != "1" {
			local ++row
		}
		
		local ++q

		local var_lab : variable label `cv'
		if "`var_lab'" == ""{
			local var_lab `cv'
		}
		
		/* for excel table ||||||||||||||||||||||||||||||| */
		if "`excel'" == "excel" {
			local i=1
			local j = `j' + 1
			local letter : word `i' of `c(ALPHA)'
			
			qui putexcel `letter'`j' = "`var_lab'"
			if "`meanrow'" == "" {
				if "`mean'" == "mean" {
					local j = `j' + 1
					qui putexcel `letter'`j' = "      Mean (SD)"
				}
			}
		}
		/* ||||||||||||||||||||||||||||||||||||||||||||||| */
		
		/* for word table ||||||||||||||||||||||||||||||| */
		if "`word'" == "word" {
			putdocx table tbl2(`row',1) = ("`var_lab'"), halign(left) colspan(2) bold
		}
		if "`meanrow'" == "" {
			if "`mean'" == "mean" {
				local ++row
				if "`word'" == "word" {
					putdocx table tbl2(`row',1) = ("      Mean (SD)"), colspan(2) halign(left)
				}
			}
		}
		/* ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
		|||||||||||||||||||||||| MEAN |||||||||||||||||||||||||||||||||||||||||||||||||||||||
		||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| */
		if "`mean'" == "mean" {
			local cur_col 2
			
			local k=1
			
			
			/* BY OPTION SPECIFIED ||||||||||||||||||||||||||||||||||| */
			if "`by'" != "" {
				qui levelsof `by', local(over_group)
				foreach i of local over_group {
					/* WEIGHT OPTION SPECIFIED ||||||||||||||||||||||| */
					if "`wts'" != "" {
						if substr("`:type `by''" , 1, 3) == "str" {
							qui summ `cv' if `by'=="`i'" [aweight=`wts']
						}
						else {
							qui summ `cv' if `by'==`i' [aweight=`wts']
						}
					}
					else {
						if substr("`:type `by''" , 1, 3) == "str" {
							qui summ `cv' if `by'=="`i'"
						}
						else {
							qui summ `cv' if `by'==`i'
						}
					}
					local mn: di %9.`mnfmt'f r(mean)
					local mn = strltrim("`mn'")
					local sd: di %9.`mnfmt'f r(sd)
					local sd = strtrim("`sd'")
					local p_m " ("
					local p_n ")"
					local mnsd `mn'`p_m'`sd'`p_n'
					/* for word table ||||||||||||||||||||||||||||||| */
					if "`word'" == "word" {
						putdocx table tbl2(`row',`cur_col') = ("`mnsd'"), halign(center)
					}
					
					/* for excel table ||||||||||||||||||||||||||||||| */
					if "`excel'" == "excel" {
						local k=`k' + 1
						local letter : word `k' of `c(ALPHA)'
						qui putexcel `letter'`j' = "`mnsd'", right
					}
					/* ||||||||||||||||||||||||||||||||||||||||||||||| */
					
					
					local ++cur_col
					/*putdocx table tbl2(`row',`cur_col') = ("`sd'"), halign(right)
					local ++cur_col*/
					if "`pval'" == "pval" {
						if `contptype' == 1 {
							/* 8/16/2018 - added functionality for clustered p-values */
							/* 9/17/2018 - added functionality for weighted p-valus */
							if "`clustpval'" == "" {
								if "`wts'" != "" {
									qui regress `cv' i.`by' [aweight=`wts']
									qui testparm i.`by'
									
									local p : di %9.`pfmt'f r(p)
									if `p' < 0.001 {
										local p "<0.001"
									}
								}
								else if "`wts'" == "" {
									qui regress `cv' i.`by'
									if `e(F)' == 0 {
										local p = "."
									}
									else {
										qui testparm i.`by'
									
									
										local p : di %9.`pfmt'f r(p)
										if `p' < 0.001 {
											local p "<0.001"
										}
									}
								}
							}
							else if "`clustpval'" == "clustpval" {
								if "`clustid'" == "" {
									di as error "Must specify clustid if requesting clustpval"
									exit 198
								}
								if "`wts'" != "" {
									qui mixed `cv' i.`by' || `clustid': [pweight=`wts']
									qui testparm i.`by'
									
									local p : di %9.`pfmt'f r(p)
									if `p' < 0.001 {
										local p "<0.001"
									}
								}
								else if "`wts'" == "" {
									qui mixed `cv' i.`by' || `clustid':
									qui testparm i.`by'
									
									local p : di %9.`pfmt'f r(p)
									if `p' < 0.001 {
										local p "<0.001"
									}
								}
							}
							else {
								di as error "Invalid specification of cluster p-value; enter 0 or 1"
								exit 198
							}
						}
						else if `contptype' == 2 {
							if "`clustpval'" == "" {
								if "`wts'" != "" {
									qui kwallis `cv' [aweight=`wts'], by(`by') 
									
									local p: di %9.`pfmt'f 1 - chi2(r(df),r(chi2))
									if `p' < 0.001 {
										local p "<0.001"
									}
								}
								else if "`wts'" == "" {
									qui kwallis `cv', by(`by') 
									
									local p: di %9.`pfmt'f 1 - chi2(r(df),r(chi2))
									if `p' < 0.001 {
										local p "<0.001"
									}
								}
							}
							else if "`clustpval'" == "clustpval" {
								if "`clustid'" == "" {
									di as error "Must specify clustid if requesting clustpval"
									exit 198
								}
								capture : which somersd
								if (_rc) {
									display as error `"Please install package {it:somersd} from SSC in order to run clustered p-values;"' _newline ///
										`"you can do so by clicking this link: {stata "ssc install somersd":auto-install somersd}"'
									exit 499
								}
								if "`wts'" != "" {
									qui xi, noomit: somersd `cv' i.`by' [aweight=`wts'], transf(z) tdist cluster(`clustid')
									testparm _I*
									local p : di %9.`pfmt'f r(p)
									if `p' < 0.001 {
										local p "<0.001"
									}
								}
								else if "`wts'" == "" {
									qui xi, noomit: somersd `cv' i.`by', transf(z) tdist cluster(`clustid')
									testparm _I*
									local p : di %9.`pfmt'f r(p)
									if `p' < 0.001 {
										local p "<0.001"
									}
								}
							}
							else {
								di as error "Invalid specification of cluster p-value; enter 0 or 1"
								exit 198
							}
						}
						else  {
							di as error "Invalid continuous p-value type (contptype) specification"
							exit 198
						}
					}
				}
				
				/* LOGIC FOR INCLUDING OR EXCLUDING A TOTAL COLUMN */
				if "`total'" == "total" {
					/* WEIGHT OPTION SPECIFIED ||||||||||||||||||||||| */
					if "`wts'" != "" {
						if substr("`:type `by''" , 1, 3) == "str" {
							qui summ `cv' if `by'!=""  [aweight=`wts']
						}
						else {
							qui summ `cv' if `by'!=. [aweight=`wts']
						}
						
					}
					else {
						if substr("`:type `by''" , 1, 3) == "str" {
							qui summ `cv' if `by'!=""
						}
						else {
							qui summ `cv' if `by'!=.
						}
					}
					local mn: di %9.`mnfmt'f r(mean)
					local mn = strltrim("`mn'")
					local sd: di %9.`mnfmt'f r(sd)
					local sd = strtrim("`sd'")
					local p_m " ("
					local p_n ")"
					local mnsd `mn'`p_m'`sd'`p_n'
					/* for word table ||||||||||||||||||||||||||||||| */
					if "`word'" == "word" {
						putdocx table tbl2(`row',`cur_col') = ("`mnsd'"), halign(center) 
					}
					
					/* for excel table ||||||||||||||||||||||||||||||| */
					if "`excel'" == "excel" {
						local k=`k' + 1
						local letter : word `k' of `c(ALPHA)'
						qui putexcel `letter'`j' = "`mnsd'", right
					}
					/* ||||||||||||||||||||||||||||||||||||||||||||||| */
				}
					
				if "`pval'" == "pval" {
					if "`total'" == "total" local ++cur_col
					
					if "`meanrow'" == "meanrow" {
						local row2 = `row'
					}
					else {
						local row2 = `row'-1
					}
					/* for word table ||||||||||||||||||||||||||||||| */
					if "`word'" == "word" {
						putdocx table tbl2(`row2',`cur_col') = ("`p'"), halign(center)  
					}
					
					/* for excel table ||||||||||||||||||||||||||||||| */
					if "`excel'" == "excel" {
						local k=`k' + 1
						local letter : word `k' of `c(ALPHA)'
						if "`meanrow'" == "meanrow" {
							local l = `j'
						}
						else {
							local l = `j' - 1
						}
						qui putexcel `letter'`l' = "`p'", right
					}
					/* ||||||||||||||||||||||||||||||||||||||||||||||| */
				}
			}
			else if "`by'" == "" {
				/* WEIGHT OPTION SPECIFIED ||||||||||||||||||||||| */
				if "`wts'" != "" {
					qui summ `cv' [aweight=`wts']
				}
				else {
					qui summ `cv'
				}
				local mn: di %9.`mnfmt'f r(mean)
				local mn = strltrim("`mn'")
				local sd: di %9.`mnfmt'f r(sd)
				local sd = strtrim("`sd'")
				local p_m " ("
				local p_n ")"
				local mnsd `mn'`p_m'`sd'`p_n'
				/* for word table ||||||||||||||||||||||||||||||| */
				if "`word'" == "word" {
					putdocx table tbl2(`row',`cur_col') = ("`mnsd'"), halign(center) 
				}
				
				/* for excel table ||||||||||||||||||||||||||||||| */
				if "`excel'" == "excel" {
					local k=`k' + 1
					local letter : word `k' of `c(ALPHA)'
					qui putexcel `letter'`j' = "`mnsd'", right
				}
			}
		}	
		
		
		/* ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
		|||||||||||||||||||||||| MEAN END |||||||||||||||||||||||||||||||||||||||||||||||||||
		||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| */
		/* ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
		|||||||||||||||||||||||| MEDIAN |||||||||||||||||||||||||||||||||||||||||||||||||||||
		||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| */
		if "`median'" == "median" {
			local ++row
			
			
			/* for excel table ||||||||||||||||||||||||||||||| */
			if "`excel'" == "excel" {
				local i=1
				local letter : word `i' of `c(ALPHA)'
				local j = `j' + 1
				qui putexcel `letter'`j' = "      Median (Q1, Q3)"
			}
			/* ||||||||||||||||||||||||||||||||||||||||||||||| */
			
			/* for word table ||||||||||||||||||||||||||||||| */
			if "`word'" == "word" {
				putdocx table tbl2(`row',1) = ("      Median (Q1, Q3)"), colspan(2) halign(left)
			}
			local cur_col 2
			local k=1
		
			
			/* BY OPTION SPECIFIED ||||||||||||||||||||||||||||||||||| */
			if "`by'" != "" {
			qui levelsof `by', local(over_group)
				foreach i of local over_group {
				
					/* WEIGHT OPTION SPECIFIED ||||||||||||||||||||||| */
					if "`wts'" != "" {
						if substr("`:type `by''" , 1, 3) == "str" {
							qui summ `cv' if `by'=="`i'" [aweight=`wts'], detail 
						}
						else {
							qui summ `cv' if `by'==`i' [aweight=`wts'], detail 
						}
						
					}
					else {
						if substr("`:type `by''" , 1, 3) == "str" {
							qui summ `cv' if `by'=="`i'", detail 
						}
						else {
							qui summ `cv' if `by'==`i', detail 
						}
					}
					local med: di %9.`medfmt'f r(p50)
					local med = strltrim("`med'")
					local p25: di %9.`medfmt'f r(p25)
					local p25 = strltrim("`p25'")
					local p75: di %9.`medfmt'f r(p75)
					local p75 = strltrim("`p75'")
					local p_m " ("
					local p_n ")"
					local comma ", "
					local medq `med'`p_m'`p25'`comma'`p75'`p_n'
					/* for word table ||||||||||||||||||||||||||||||| */
					if "`word'" == "word" {
						putdocx table tbl2(`row',`cur_col') = ("`medq'"), halign(center)
					}
					
					local ++cur_col
					
					/* for excel table ||||||||||||||||||||||||||||||| */
					if "`excel'" == "excel" {
						local k=`k' + 1
						local letter : word `k' of `c(ALPHA)'
						qui putexcel `letter'`j' = "`medq'", right
					}
					/* ||||||||||||||||||||||||||||||||||||||||||||||| */
						
						
				}
				
					if "`mean'" != "mean" {
						if "`pval'" == "pval" {
							if "`clustpval'" == "" {
								if "`wts'" != "" {
									qui kwallis `cv' [aweight=`wts'], by(`by') 
									
									local p: di %9.`pfmt'f 1 - chi2(r(df),r(chi2))
									if `p' < 0.001 {
										local p "<0.001"
									}
								}
								else if "`wts'" == "" {
									qui kwallis `cv', by(`by') 
									
									local p: di %9.`pfmt'f 1 - chi2(r(df),r(chi2))
									if `p' < 0.001 {
										local p "<0.001"
									}
								}
							}
							else if "`clustpval'" == "clustpval" {
								if "`clustid'" == "" {
									di as error "Must specify clustid if requesting clustpval"
									exit 198
								}
								capture : which somersd
								if (_rc) {
									display as error `"Please install package {it:somersd} from SSC in order to run clustered p-values;"' _newline ///
										`"you can do so by clicking this link: {stata "ssc install somersd":auto-install somersd}"'
									exit 499
								}
								if "`wts'" != "" {
									qui xi, noomit: somersd `cv' i.`by' [aweight=`wts'], transf(z) tdist cluster(`clustid')
									testparm _I*
									local p : di %9.`pfmt'f r(p)
									if `p' < 0.001 {
										local p "<0.001"
									}
								}
								else if "`wts'" == "" {
									qui xi, noomit: somersd `cv' i.`by', transf(z) tdist cluster(`clustid')
									testparm _I*
									local p : di %9.`pfmt'f r(p)
									if `p' < 0.001 {
										local p "<0.001"
									}
								}
							}
							else {
								di as error "Invalid specification of cluster p-value; enter 0 or 1"
								exit 198
							}
						}
					}
				
					
				if "`total'" == "total" {
					/* WEIGHT OPTION SPECIFIED ||||||||||||||||||||||| */
					if "`wts'" != "" {
						if substr("`:type `by''" , 1, 3) == "str" {
							qui summ `cv' if `by'!="" [aweight=`wts'], detail 
						}
						else {
							qui summ `cv' if `by'!=. [aweight=`wts'], detail 
						}
					}
					else {
						if substr("`:type `by''" , 1, 3) == "str" {
							qui summ `cv' if `by'!="", detail 
						}
						else {
							qui summ `cv' if `by'!=., detail 
						}
					}
					
					local med: di %9.`medfmt'f r(p50)
					local med = strltrim("`med'")
					local p25: di %9.`medfmt'f r(p25)
					local p25 = strltrim("`p25'")
					local p75: di %9.`medfmt'f r(p75)
					local p75 = strltrim("`p75'")
					local p_m " ("
					local p_n ")"
					local comma ", "
					local medq `med'`p_m'`p25'`comma'`p75'`p_n'
					/* for word table ||||||||||||||||||||||||||||||| */
					if "`word'" == "word" {
						putdocx table tbl2(`row',`cur_col') = ("`medq'"), halign(center)
					}
					
					/* for excel table ||||||||||||||||||||||||||||||| */
					if "`excel'" == "excel" {
						local k=`k' + 1
						local letter : word `k' of `c(ALPHA)'
						qui putexcel `letter'`j' = "`medq'", right
					}
					/* ||||||||||||||||||||||||||||||||||||||||||||||| */
				}
				if "`mean'" != "mean" {
					if "`pval'" == "pval" {
						if "`total'" == "total" local ++cur_col
						
						if "`meanrow'" == "meanrow" {
							local row2 = `row'
						}
						else {
							local row2 = `row'-1
						}
						/* for word table ||||||||||||||||||||||||||||||| */
						if "`word'" == "word" {
							putdocx table tbl2(`row2',`cur_col') = ("`p'"), halign(center) 
						}
						
						/* for excel table ||||||||||||||||||||||||||||||| */
						if "`excel'" == "excel" {
							local k=`k' + 1
							local letter : word `k' of `c(ALPHA)'
							if "`meanrow'" == "meanrow" {
								local l = `j'
							}
							else {
								local l = `j' - 1
							}
							qui putexcel `letter'`l' = "`p'", right
						}
						/* ||||||||||||||||||||||||||||||||||||||||||||||| */
					}
				}
				
			}
			else if "`by'" == "" {
					/* WEIGHT OPTION SPECIFIED ||||||||||||||||||||||| */
					if "`wts'" != "" {
						qui summ `cv' [aweight=`wts'], detail
					}
					else {
						qui summ `cv', detail 
					}
					
					local med: di %9.`medfmt'f r(p50)
					local med = strltrim("`med'")
					local p25: di %9.`medfmt'f r(p25)
					local p25 = strltrim("`p25'")
					local p75: di %9.`medfmt'f  r(p75)
					local p75 = strltrim("`p75'")
					local p_m " ("
					local p_n ")"
					local comma ", "
					local medq `med'`p_m'`p25'`comma'`p75'`p_n'
					/* for word table ||||||||||||||||||||||||||||||| */
					if "`word'" == "word" {
						putdocx table tbl2(`row',`cur_col') = ("`medq'"), halign(center) 
					}
					
					/* for excel table ||||||||||||||||||||||||||||||| */
					if "`excel'" == "excel" {
						local k=`k' + 1
						local letter : word `k' of `c(ALPHA)'
						qui putexcel `letter'`j' = "`medq'", right
					}
					/* ||||||||||||||||||||||||||||||||||||||||||||||| */
			}
		}
		/* ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
		|||||||||||||||||||||||| MEDIAN END |||||||||||||||||||||||||||||||||||||||||||||||||
		||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| */
		
		/* ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
		|||||||||||||||||||||||| RANGE ||||||||||||||||||||||||||||||||||||||||||||||||||||||
		||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| */
		if "`range'" == "range" {
		
		/* for excel table ||||||||||||||||||||||||||||||| */
		if "`excel'" == "excel" {
			local i=1
			local letter : word `i' of `c(ALPHA)'
			local j = `j' + 1
				qui putexcel `letter'`j' = "      Min, Max"

		}
		/* ||||||||||||||||||||||||||||||||||||||||||||||| */
		
		local ++row
		/* for word table ||||||||||||||||||||||||||||||| */
		if "`word'" == "word" {
			putdocx table tbl2(`row',1) = ("      Min, Max"), colspan(2) halign(left)
		}
		local cur_col 2
		local k=1
		
		if "`mean'" != "mean" & "`median'" != "median" {
			if "`pval'" == "pval" {
				di as error "p-value not allowed when only reporting the min and max"
				exit 198
			}
		}
			
			/* BY OPTION SPECIFIED ||||||||||||||||||||||||||||||||||| */
			if "`by'" != "" {
			qui levelsof `by', local(over_group)
				foreach i of local over_group {
					/* WEIGHT OPTION SPECIFIED ||||||||||||||||||||||| */
					if "`wts'" != "" {
						if substr("`:type `by''" , 1, 3) == "str" {
							qui summ `cv' if `by'=="`i'" [aweight=`wts']
						}
						else {
							qui summ `cv' if `by'==`i' [aweight=`wts'] 
						}
					}
					else {
						if substr("`:type `by''" , 1, 3) == "str" {
							qui summ `cv' if `by'=="`i'"
						}
						else {
							qui summ `cv' if `by'==`i'
						}
					}
					
					local min: di %9.`rangefmt'f r(min)
					local min = strltrim("`min'")
					local max: di %9.`rangefmt'f r(max)
					local max = strltrim("`max'")
					local num: di r(N)
					if "`wts'" != "" {
						if substr("`:type `by''" , 1, 3) == "str" {
							qui summ `c' if `by' == "`i'" [aweight=`wts']
						}
						else {
							qui summ `c' if `by' == `i' [aweight=`wts']
						}
					}
					else {					
						if substr("`:type `by''" , 1, 3) == "str" {
							qui summ `c' if `by' == "`i'"
						}
						else {
							qui summ `c' if `by' == `i'
						}
					}
					
					
					local comma ", "
					local minmax `min'`comma'`max'
						
					/* for word table ||||||||||||||||||||||||||||||| */
					if "`word'" == "word" {
						putdocx table tbl2(`row',`cur_col') = ("`minmax'"), halign(center)
					}
					local ++cur_col
						
					/* for excel table ||||||||||||||||||||||||||||||| */
					if "`excel'" == "excel" {
						local k=`k' + 1
						local letter : word `k' of `c(ALPHA)'
						qui putexcel `letter'`j' = "`minmax'", right
					}
					/* ||||||||||||||||||||||||||||||||||||||||||||||| */
						
				}
					
				if "`total'" == "total" {
					/* WEIGHT OPTION SPECIFIED ||||||||||||||||||||||| */
					if "`wts'" != "" {
						if substr("`:type `by''" , 1, 3) == "str" {
							qui summ `cv' if `by'!="" [aweight=`wts'], detail 
						}
						else {
							qui summ `cv' if `by'!=. [aweight=`wts'], detail 
						}
					}
					else {
						if substr("`:type `by''" , 1, 3) == "str" {
							qui summ `cv' if `by'!="", detail 
						}
						else {
							qui summ `cv' if `by'!=., detail 
						}
					}
					
					local min: di %9.`rangefmt'f r(min)
					local min = strltrim("`min'")
					local max: di %9.`rangefmt'f r(max)
					local max = strltrim("`max'")
					local num: di r(N)
					if "`wts'" != "" {
						qui summ `c' [aweight=`wts']
					}
					else {					
						qui summ `c'
					}
					
					local comma ", "
					local minmax `min'`comma'`max'
					
					/* for word table ||||||||||||||||||||||||||||||| */
					if "`word'" == "word" {
						putdocx table tbl2(`row',`cur_col') = ("`minmax'"), halign(center)
					}
					
					/* for excel table ||||||||||||||||||||||||||||||| */
					if "`excel'" == "excel" {
						local k=`k' + 1
						local letter : word `k' of `c(ALPHA)'
						qui putexcel `letter'`j' = "`minmax'", right
					}
					/* ||||||||||||||||||||||||||||||||||||||||||||||| */
				}
			}
			else if "`by'" == "" {
				/* WEIGHT OPTION SPECIFIED ||||||||||||||||||||||| */
				if "`wts'" != "" {
					qui summ `cv' [aweight=`wts']
				}
				else {
					qui summ `cv'				
				}
				
				local min: di %9.`rangefmt'f r(min)
				local min = strltrim("`min'")
				local max: di %9.`rangefmt'f r(max)
				local max = strltrim("`max'")
				local num: di r(N)
				if "`wts'" != "" {
					qui summ `c' [aweight=`wts']
				}
				else {					
					qui summ `c'
				}
				
				local comma ", "
				local minmax `min'`comma'`max'
				
				/* for word table ||||||||||||||||||||||||||||||| */
				if "`word'" == "word" {
					putdocx table tbl2(`row',`cur_col') = ("`minmax'"), halign(center)  
				}
					
				/* for excel table ||||||||||||||||||||||||||||||| */
				if "`excel'" == "excel" {
					local k=`k' + 1
					local letter : word `k' of `c(ALPHA)'
					qui putexcel `letter'`j' = "`minmax'", right
				}
				/* ||||||||||||||||||||||||||||||||||||||||||||||| */
			}
			
		}
		/* ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
		|||||||||||||||||||||||| RANGE END ||||||||||||||||||||||||||||||||||||||||||||||||||
		||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| */
	
		
		/* ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
		|||||||||||||||||||||||| N AND % MISSING/NON MISSING BEGIN ||||||||||||||||||||||||||
		||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| */
		if ("`pnonmiss'" == "pnonmiss" | "`pmiss'" == "pmiss") {
		
		/* for excel table ||||||||||||||||||||||||||||||| */
		if "`excel'" == "excel" {
			local i=1
			local letter : word `i' of `c(ALPHA)'
			local j = `j' + 1
			if "`pnonmiss'" == "pnonmiss" qui putexcel `letter'`j' = "      N (% Non-missing)"
			else if "`pmiss'" == "pmiss" qui putexcel `letter'`j' = "      N (% Missing)"
		}
		/* ||||||||||||||||||||||||||||||||||||||||||||||| */
		
		local ++row
		/* for word table ||||||||||||||||||||||||||||||| */
		if "`word'" == "word" {
			if "`pnonmiss'" == "pnonmiss" putdocx table tbl2(`row',1) = ("      N (% Non-missing)"), colspan(2) halign(left)
			else if "`pmiss'" == "pmiss" putdocx table tbl2(`row',1) = ("      N (% Missing)"), colspan(2) halign(left)
		}
		local cur_col 2
		local k=1
		
		if "`mean'" != "mean" & "`median'" != "median" {
			if "`pval'" == "pval" {
				di as error "p-value not allowed when only reporting N and % missing/non-missing"
				exit 198
			}
		}
			
			/* BY OPTION SPECIFIED ||||||||||||||||||||||||||||||||||| */
			if "`by'" != "" {
			qui levelsof `by', local(over_group)
				foreach i of local over_group {
					/* WEIGHT OPTION SPECIFIED ||||||||||||||||||||||| */
					if "`wts'" != "" {
						if substr("`:type `by''" , 1, 3) == "str" {
							qui summ `cv' if `by'=="`i'" [aweight=`wts']
						}
						else {
							qui summ `cv' if `by'==`i' [aweight=`wts'] 
						}
					}
					else {
						if substr("`:type `by''" , 1, 3) == "str" {
							qui summ `cv' if `by'=="`i'"
						}
						else {
							qui summ `cv' if `by'==`i'
						}
					}
					
					local num: di r(N)

					if "`wts'" != "" {
						if substr("`:type `by''" , 1, 3) == "str" {
							qui summ `c' if `by' == "`i'" [aweight=`wts']
						}
						else {
							qui summ `c' if `by' == `i' [aweight=`wts']
						}
					}
					else {					
						if substr("`:type `by''" , 1, 3) == "str" {
							qui summ `c' if `by' == "`i'"
						}
						else {
							qui summ `c' if `by' == `i'
						}
					}
					
					if "`pnonmiss'" == "pnonmiss" {
						local percnonmiss: di %9.`pnonmissfmt'f `num'/r(N)*100
						local percnonmiss = strltrim("`percnonmiss'")
						local comma ", "
						local perc "%"
						local p_m " ("
						local p_n ")"
					
						local pnmiss `num'`p_m'`percnonmiss'`perc'`p_n'
					}
					if "`pmiss'" == "pmiss" {
						local num2 = r(N) - `num'
						local percmiss: di %9.`pmissfmt'f `num2'/r(N)*100
						local percmiss = strltrim("`percmiss'")
						local comma ", "
						local perc "%"
						local p_m " ("
						local p_n ")"
					
						local pmis `num'`p_m'`percmiss'`perc'`p_n'
					}
					
					/* for word table ||||||||||||||||||||||||||||||| */
					if "`word'" == "word" {
						if "`pnonmiss'" == "pnonmiss" putdocx table tbl2(`row',`cur_col') = ("`pnmiss'"), halign(center)
						else if "`pmiss'" == "pmiss" putdocx table tbl2(`row',`cur_col') = ("`pmis'"), halign(center)
						
					}
					local ++cur_col
						
					/* for excel table ||||||||||||||||||||||||||||||| */
					if "`excel'" == "excel" {
						local k=`k' + 1
						local letter : word `k' of `c(ALPHA)'
						if "`pnonmiss'" == "pnonmiss" qui putexcel `letter'`j' = "`pnmiss'", right
						else if "`pmiss'" == "pmiss" qui putexcel `letter'`j' = "`pmis'", right
					}
					/* ||||||||||||||||||||||||||||||||||||||||||||||| */
						
				}
					
				if "`total'" == "total" {
					/* WEIGHT OPTION SPECIFIED ||||||||||||||||||||||| */
					if "`wts'" != "" {
						if substr("`:type `by''" , 1, 3) == "str" {
							qui summ `cv' if `by'!="" [aweight=`wts'], detail 
						}
						else {
							qui summ `cv' if `by'!=. [aweight=`wts'], detail 
						}
					}
					else {
						if substr("`:type `by''" , 1, 3) == "str" {
							qui summ `cv' if `by'!="", detail 
						}
						else {
							qui summ `cv' if `by'!=., detail 
						}
					}
					
					local num: di r(N)
					
					if "`wts'" != "" {
						qui summ `c' [aweight=`wts']
					}
					else {					
						qui summ `c'
					}
					
					if "`pnonmiss'" == "pnonmiss" {
						local percnonmiss: di %9.`pnonmissfmt'f `num'/r(N)*100
						local percnonmiss = strltrim("`percnonmiss'")
						local comma ", "
						local perc "%"
						local p_m " ("
						local p_n ")"
					
						local pnmiss `num'`p_m'`percnonmiss'`perc'`p_n'
					}
					if "`pmiss'" == "pmiss" {
						local num2 = r(N) - `num'
						local percmiss: di %9.`pmissfmt'f `num2'/r(N)*100
						local percmiss = strltrim("`percmiss'")
						local comma ", "
						local perc "%"
						local p_m " ("
						local p_n ")"
					
						local pmis `num'`p_m'`percmiss'`perc'`p_n'
					}
					
					/* for word table ||||||||||||||||||||||||||||||| */
					if "`word'" == "word" {
						if "`pnonmiss'" == "pnonmiss" putdocx table tbl2(`row',`cur_col') = ("`pnmiss'"), halign(center)
						else if "`pmiss'" == "pmiss" putdocx table tbl2(`row',`cur_col') = ("`pmis'"), halign(center)
						
					}
					local ++cur_col
						
					/* for excel table ||||||||||||||||||||||||||||||| */
					if "`excel'" == "excel" {
						local k=`k' + 1
						local letter : word `k' of `c(ALPHA)'
						if "`pnonmiss'" == "pnonmiss" qui putexcel `letter'`j' = "`pnmiss'", right
						else if "`pmiss'" == "pmiss" qui putexcel `letter'`j' = "`pmis'", right
					}
					/* ||||||||||||||||||||||||||||||||||||||||||||||| */
				}
			}
			else if "`by'" == "" {
				/* WEIGHT OPTION SPECIFIED ||||||||||||||||||||||| */
				if "`wts'" != "" {
					qui summ `cv' [aweight=`wts']
				}
				else {
					qui summ `cv'				
				}
				
				local num: di r(N)
				
				if "`wts'" != "" {
					qui summ `c' [aweight=`wts']
				}
				else {					
					qui summ `c'
				}
				
				if "`pnonmiss'" == "pnonmiss" {
						local percnonmiss: di %9.`pnonmissfmt'f `num'/r(N)*100
						local percnonmiss = strltrim("`percnonmiss'")
						local comma ", "
						local perc "%"
						local p_m " ("
						local p_n ")"
					
						local pnmiss `num'`p_m'`percnonmiss'`perc'`p_n'
					}
					if "`pmiss'" == "pmiss" {
						local num2 = r(N) - `num'
						local percmiss: di %9.`pmissfmt'f `num2'/r(N)*100
						local percmiss = strltrim("`percmiss'")
						local comma ", "
						local perc "%"
						local p_m " ("
						local p_n ")"
					
						local pmis `num'`p_m'`percmiss'`perc'`p_n'
					}
					
					/* for word table ||||||||||||||||||||||||||||||| */
					if "`word'" == "word" {
						if "`pnonmiss'" == "pnonmiss" putdocx table tbl2(`row',`cur_col') = ("`pnmiss'"), halign(center)
						else if "`pmiss'" == "pmiss" putdocx table tbl2(`row',`cur_col') = ("`pmis'"), halign(center)
						
					}
					local ++cur_col
						
					/* for excel table ||||||||||||||||||||||||||||||| */
					if "`excel'" == "excel" {
						local k=`k' + 1
						local letter : word `k' of `c(ALPHA)'
						if "`pnonmiss'" == "pnonmiss" qui putexcel `letter'`j' = "`pnmiss'", right
						else if "`pmiss'" == "pmiss" qui putexcel `letter'`j' = "`pmis'", right
					}
					/* ||||||||||||||||||||||||||||||||||||||||||||||| */
				/* ||||||||||||||||||||||||||||||||||||||||||||||| */
			}
			
		}
		/* ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
		|||||||||||||||||||||||| N AND % NONMISSING END||||||||||||||||||||||||||||||||||||||
		||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| */
	
	
	}
/* |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||CONTINUOUS VARIABLE LOOP END ||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| */
	if "`contvars'" != "" local ++row
	

/* |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||||||||||||||||||||||||||||||||||| CATEGORICAL VARIABLE LOOP ||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| */
	foreach cv of local catvars{
		if "`catmisstype'" == "none" {
			qui levelsof `cv', local(cols) 
			qui tabcount2 `cv', v1(`cols') zero matrix(Mat)
			local MAT=rowsof(Mat)
			local categories = `MAT'+1
		}
		else if "`catmisstype'" == "missperc" {
			qui tab `cv', miss
			local categories = r(r)+1
		}
		else if "`catmisstype'" == "missnoperc" {
			qui tab `cv', miss
			local categories = r(r)+1
		}
		/* for word table ||||||||||||||||||||||||||||||| */
		if "`word'" == "word" {
			if `categories' == 3 & "`catrow'" == "catrow" {
				putdocx table tbl2(`row',.), addrows(1)
			}
			else {
				putdocx table tbl2(`row',.), addrows(`categories')
			}
		}
		
		
		
		*label categorical variable
		local var_lab : variable label `cv'
		if "`var_lab'" == ""{
			local var_lab `cv'
		}
		
		/* for excel table ||||||||||||||||||||||||||||||| */
		if "`excel'" == "excel" {
			local i=1
			local letter : word `i' of `c(ALPHA)'
			local exc = `row' + 2
			qui putexcel `letter'`exc' = "`var_lab'"
		}
		/* ||||||||||||||||||||||||||||||||||||||||||||||| */
		
		
		/* BY OPTION SPECIFIED ||||||||||||||||||||||||||||||||||| */
		if "`by'" != "" {
			if "`pval'" == "pval" {
				if "`clustpval'" == "" {
					if `catptype' == 1 {
						if "`wts'" != "" {
							qui svyset `wts'
							qui svy: tab `cv' `by'
							
							local p : di %9.`pfmt'f e(p_Pear)
							if `p' < 0.001 {
								local p "<0.001"
							}
						}
						else if "`wts'" == "" {
							qui tab `cv' `by', chi2
							
							local p : di %9.`pfmt'f r(p)
							if `p' < 0.001 {
								local p "<0.001"
							}
						}
					}
					else if `catptype' == 2 {
						if "`wts'" != "" {
							di as error "Note: Exact tests are not used with weighted data; running design-based F-test instead"
							qui svyset `wts'
							qui svy: tab `cv' `by'
							
							local p : di %9.`pfmt'f e(p_Pear)
							if `p' < 0.001 {
								local p "<0.001"
							}
						}
						if "`wts'" == "" {
							qui tab `cv' `by', exact
							
							local p : di %9.`pfmt'f r(p_exact)
							if `p' < 0.001 {
								local p "<0.001"
							}
						}
					}
					else  {
						di as error "Invalid categorical p-value type (catptype) specification"
						exit 198
					}
				}
				else if "`clustpval'" == "clustpval" {
					di as error "Warning: Clustered p-values will not be reported for categorical variables"
					local p "."
				}
			}
			if "`pval'" != "" {
			
				/* for word table ||||||||||||||||||||||||||||||| */
				if "`word'" == "word" {
					putdocx table tbl2(`row',`col') = ("`p'"), halign(center)
				}
				
				/* for excel table ||||||||||||||||||||||||||||||| */
				if "`excel'" == "excel" {
					local s=`row' + 2
					local col2=`col'-1
					local letter: word `col2' of `c(ALPHA)'
					qui putexcel `letter'`s' = "`p'", right
				}
				/* ||||||||||||||||||||||||||||||||||||||||||||||| */
				
			}
			
		}
		
		

		/* START HERE */
		
		/* June 9, 2020 */
		if `categories' == 3 & "`catrow'" == "catrow" {
		}
		else {
			/* for word table ||||||||||||||||||||||||||||||| */
			if "`word'" == "word" {
				putdocx table tbl2(`row',1) = ("`var_lab'"), halign(left) colspan(2) bold
			}
			local ++row
		}
		
		
		
		local m 1
		local cur_col 1
		
		
		
		/* BY OPTION SPECIFIED ||||||||||||||||||||||||||||||||||| */
		if "`by'" != "" {
			qui levelsof `by', local(over_group)
			foreach i of local over_group{
				local r = `row'
				
				if "`catmisstype'" == "none" {
					qui levelsof `cv', local(c_l)
				}
				else if "`catmisstype'" == "missperc" {
					qui levelsof `cv', local(c_l) miss
				}
				else if "`catmisstype'" == "missnoperc" {
					qui levelsof `cv', local(c_l) miss
				}
				
				
				
				local lbe: value label `cv' 
				local k = 1
				
				if "`catrow'" == "catrow" & `categories' == 3 {
					local c_l: word 2 of `c_l'
				}
				
				
				local s=1
				local v=`j'
				foreach c of local c_l {
					local d = `cur_col'
					if "`lbe'" != ""{	
						local ct: label `lbe' `c'
					}
					else {
						local ct `c'
					}
					/* MOVING WEIGHT VS. NONWEIGHT CODE */
					
					if "`catmisstype'" == "none" {
						qui levelsof `cv', local(rows1)
						qui levelsof `by', local(cols1)
						if "`wts'" != "" qui tabcount2 `cv' `by' [aweight=`wts'], v1(`rows1') v2(`cols1') matrix(M) zero
						else qui tabcount2 `cv' `by', v1(`rows1') v2(`cols1') matrix(M) zero
					}
					
					else if "`catmisstype'" == "missperc" {
						if "`wts'" != "" qui tab `cv' `by' [aweight=`wts'], matcell(M) miss
						else qui tab `cv' `by', matcell(M) miss
					}
					
					else if "`catmisstype'" == "missnoperc" {
						qui levelsof `cv', local(rows1)
						qui levelsof `by', local(cols1)
						if "`wts'" != "" {
							qui tabcount2 `cv' `by' [aweight=`wts'], v1(`rows1') v2(`cols1') matrix(M1) zero
							qui tab `cv' `by' [aweight=`wts'], matcell(M2) miss
						}
						else {
							qui tabcount2 `cv' `by', v1(`rows1') v2(`cols1') matrix(M1) zero
							qui tab `cv' `by', matcell(M2) miss							
						}
						
						local Mcount = rowsof(M2)
						
					}
					
					
					if "`catmisstype'" == "none" | "`catmisstype'" == "missperc" {
						if "`catrow'" == "catrow" & `categories' == 3 {
							local k=2
						}
						local freq_1 = M[`k',`m']
						if "`wts'" != "" local freq_1: di %9.`fracfmt'f `freq_1'
						local freq_1 = strltrim("`freq_1'")
						
						
						if "`rowperc'" == "" {
							mata: st_matrix("M", (st_matrix("M")  :/ colsum(st_matrix("M"))))
						}
						else if "`rowperc'" == "rowperc" {
							mata: st_matrix("M", (st_matrix("M")  :/ rowsum(st_matrix("M"))))
						}
						
						local perc_1 = M[`k',`m']
						
						local perc_1 = strltrim("`perc_1'")
						
						local pt_1 =`perc_1'*100
						local pt_1: di %9.`catfmt'f `pt_1'
						local pt_1 = strltrim("`pt_1'")
						local p_m " ("
						local p_n ")"
						local perc "%"
						
							*set frequency to missing if it's a column of zeroes
						if "`wts'" != "" {
							if "`wtfreq'" == "off" {
								local freqperc `pt_1'`perc'
							}
							else if "`wtfreq'" == "fractional" {
								if "`perc_1'" != "." {
									local freqperc `freq_1'`p_m'`pt_1'`perc'`p_n'	
								}
								else if "`perc_1'" == "." {
									local mis = .
									local freqperc `mis'`p_m'`pt_1'`perc'`p_n'	
								}
							}
							else if "`wtfreq'" == "ceiling" {
								local freq_1 = ceil(`freq_1')
								local freq_1 = strltrim("`freq_1'")
								if "`perc_1'" != "." {
									local freqperc `freq_1'`p_m'`pt_1'`perc'`p_n'	
								}
								else if "`perc_1'" == "." {
									local mis = .
									local freqperc `mis'`p_m'`pt_1'`perc'`p_n'	
								}	
							}
							else {
								di as error "Invalid wtfreq specification"
								exit 198
							}
						}
						else {
							local freqperc `freq_1'`p_m'`pt_1'`perc'`p_n'	
						}
					}
					else if "`catmisstype'" == "missnoperc" {
						
						matrix M3 = M2[`Mcount',1...]
						matrix M = M1\M3
						local freq_1 = M[`k',`m']
						if "`wts'" != "" local freq_1: di %9.`fracfmt'f `freq_1'
						local freq_1 = strltrim("`freq_1'")
						
						if "`rowperc'" == "" {
							mata: st_matrix("M1", (st_matrix("M1")  :/ colsum(st_matrix("M1"))))
						}
						else if "`rowperc'" == "rowperc" {
							mata: st_matrix("M1", (st_matrix("M1")  :/ rowsum(st_matrix("M1"))))
						}
						
						
						matrix X1 = M3*.
						matrix M4 = M1\X1
						
						matrix M = M1\M3
						local freq_1 = M[`k',`m']
						if "`wts'" != "" local freq_1: di %9.`fracfmt'f `freq_1'
						local freq_1 = strltrim("`freq_1'")
						
						
						local perc_1 = M4[`k',`m']
						local perc_1 = strltrim("`perc_1'")
						
						local pt_1 =`perc_1'*100
						local pt_1: di %9.`catfmt'f `pt_1'
						local pt_1 = strltrim("`pt_1'")
						local p_m " ("
						local p_n ")"
						local perc "%"
					
						if "`wts'" != "" {
							if "`wtfreq'" == "off" {
								local freqperc `pt_1'`perc'
							}
							else if "`wtfreq'" == "fractional" {
								local freqperc `freq_1'`p_m'`pt_1'`perc'`p_n'	
							}
							else if "`wtfreq'" == "ceiling" {
								local freq_1 = ceil(`freq_1')
								local freq_1 = strltrim("`freq_1'")
								local freqperc `freq_1'`p_m'`pt_1'`perc'`p_n'	
							}
							else {
								di as error "Invalid wtfreq specification"
								exit 198
							}
						}
						else {
							local freqperc `freq_1'`p_m'`pt_1'`perc'`p_n'
						}
					}
					
					
					if `cur_col'==1{
						/* for word table ||||||||||||||||||||||||||||||| */
											
						if "`word'" == "word" {
							if `categories' == 3 & "`catrow'" == "catrow" {
								putdocx table tbl2(`r',`d') = ("`var_lab'"), halign(left) colspan(2) bold
							}
							else {
								putdocx table tbl2(`r',`d') = ("      `ct'"), halign(left) colspan(2)
							}
						}
						
						/* for excel table ||||||||||||||||||||||||||||||| */
						if "`excel'" == "excel" {
							local s = `r' + 2
							local letter : word `d' of `c(ALPHA)' 
							if `categories' == 3 & "`catrow'" == "catrow" qui putexcel `letter'`s' = "`var_lab'"
							else qui putexcel `letter'`s' = "      `ct'"
						}
						/* ||||||||||||||||||||||||||||||||||||||||||||||| */
						
					}
					local ++d
					
				
					/* for word table ||||||||||||||||||||||||||||||| */
					if "`word'" == "word" {
						putdocx table tbl2(`r',`d') = ("`freqperc'"), halign(center)
					}
					
					
					/* for excel table ||||||||||||||||||||||||||||||| */
					if "`excel'" == "excel" {
						local s=`r' + 2
						local letter: word `d' of `c(ALPHA)'
						qui putexcel `letter'`s' = "`freqperc'", right
					}
					/* ||||||||||||||||||||||||||||||||||||||||||||||| */
					local ++r
					local ++k
				} 
				
			
					local ++cur_col
					
			
				local ++m

			}	
			
			/* LOGIC FOR INCLUDING OR EXCLUDING A TOTAL COLUMN */
			if "`total'" == "total" {
				if "`catmisstype'" == "none" {
					qui levelsof `cv', local(c_l)
				}
				else if "`catmisstype'" == "missperc" {
					qui levelsof `cv', local(c_l) miss
				}
				else if "`catmisstype'" == "missnoperc" {
					qui levelsof `cv', local(c_l) miss
				}
				
				local k = 1
				
				if "`catrow'" == "catrow" & `categories' == 3 {
					local c_l: word 2 of `c_l'
				}
				local ++d

				local r=`row'
				foreach c of local c_l {
					/* WEIGHT OPTION SPECIFIED ||||||||||||||||||||||| */
					if "`catmisstype'" == "none" {
						qui levelsof `cv', local(rows1)
						if "`wts'" != "" qui tabcount2 `cv'  [aweight=`wts'], v1(`rows1') matrix(M) zero
						else qui tabcount2 `cv' , v1(`rows1') matrix(M) zero
					}
					
					else if "`catmisstype'" == "missperc" {
						if "`wts'" != "" qui tab `cv' [aweight=`wts'], matcell(M) miss
						else qui tab `cv', matcell(M) miss
					}
					
					else if "`catmisstype'" == "missnoperc" {
						qui levelsof `cv', local(rows1)
						if "`wts'" != "" {
							qui tabcount2 `cv' [aweight=`wts'], v1(`rows1') v2(`cols1') matrix(M1) zero
							qui tab `cv' [aweight=`wts'], matcell(M2) miss
						}
						else {
							qui tabcount2 `cv', v1(`rows1') v2(`cols1') matrix(M1) zero
							qui tab `cv', matcell(M2) miss							
						}
						local Mcount = rowsof(M2)
					}
					
					
					if "`catmisstype'" == "none" | "`catmisstype'" == "missperc" {
						if "`catrow'" == "catrow" & `categories' == 3 {
							local k=2
						}
						local freq_1 = M[`k',1]
						if "`wts'" != "" local freq_1: di %9.`fracfmt'f `freq_1'
						local freq_1 = strltrim("`freq_1'")
						
						
						if "`rowperc'" == "" {
							mata: st_matrix("M", (st_matrix("M")  :/ colsum(st_matrix("M"))))
						}
						else if "`rowperc'" == "rowperc" {
							mata: st_matrix("M", (st_matrix("M")  :/ rowsum(st_matrix("M"))))
						}
						
						local perc_1 = M[`k',1]
						
						local perc_1 = strltrim("`perc_1'")
						
						local pt_1 =`perc_1'*100
						local pt_1: di %9.`catfmt'f `pt_1'
						local pt_1 = strltrim("`pt_1'")
						local p_m " ("
						local p_n ")"
						local perc "%"
						
							*set frequency to missing if it's a column of zeroes
						if "`wts'" != "" {
							if "`wtfreq'" == "off" {
								local freqperc `pt_1'`perc'
							}
							else if "`wtfreq'" == "fractional" {
								if "`perc_1'" != "." {
									local freqperc `freq_1'`p_m'`pt_1'`perc'`p_n'	
								}
								else if "`perc_1'" == "." {
									local mis = .
									local freqperc `mis'`p_m'`pt_1'`perc'`p_n'	
								}
							}
							else if "`wtfreq'" == "ceiling" {
								local freq_1 = ceil(`freq_1')
								local freq_1 = strltrim("`freq_1'")
								if "`perc_1'" != "." {
									local freqperc `freq_1'`p_m'`pt_1'`perc'`p_n'	
								}
								else if "`perc_1'" == "." {
									local mis = .
									local freqperc `mis'`p_m'`pt_1'`perc'`p_n'	
								}	
							}
							else {
								di as error "Invalid wtfreq specification"
								exit 198
							}
						}
						else {
							local freqperc `freq_1'`p_m'`pt_1'`perc'`p_n'	
						}
					}
					else if "`catmisstype'" == "missnoperc" {
						
						matrix M3 = M2[`Mcount',1...]
						matrix M = M1\M3
						local freq_1 = M[`k',1]
						if "`wts'" != "" local freq_1: di %9.`fracfmt'f `freq_1'
						local freq_1 = strltrim("`freq_1'")
						
						if "`rowperc'" == "" {
							mata: st_matrix("M1", (st_matrix("M1")  :/ colsum(st_matrix("M1"))))
						}
						else if "`rowperc'" == "rowperc" {
							mata: st_matrix("M1", (st_matrix("M1")  :/ rowsum(st_matrix("M1"))))
						}
						
						
						matrix X1 = M3*.
						matrix M4 = M1\X1
						
						
						local perc_1 = M4[`k',1]
						local perc_1 = strltrim("`perc_1'")
						
						local pt_1 =`perc_1'*100
						local pt_1: di %9.`catfmt'f `pt_1'
						local pt_1 = strltrim("`pt_1'")
						local p_m " ("
						local p_n ")"
						local perc "%"
					
						if "`wts'" != "" {
							if "`wtfreq'" == "off" {
								local freqperc `pt_1'`perc'
							}
							else if "`wtfreq'" == "fractional" {
								local freqperc `freq_1'`p_m'`pt_1'`perc'`p_n'	
							}
							else if "`wtfreq'" == "ceiling" {
								local freq_1 = ceil(`freq_1')
								local freq_1 = strltrim("`freq_1'")
								local freqperc `freq_1'`p_m'`pt_1'`perc'`p_n'	
							}
							else {
								di as error "Invalid wtfreq specification"
								exit 198
							}
						}
						else {
							local freqperc `freq_1'`p_m'`pt_1'`perc'`p_n'
						}
					}
				
					
					/* for word table ||||||||||||||||||||||||||||||| */
					if "`word'" == "word" {
						putdocx table tbl2(`r',`d') = ("`freqperc'"), halign(center) 
					}

					/* for excel table ||||||||||||||||||||||||||||||| */
					if "`excel'" == "excel" {
						local s=`r' + 2
						local letter: word `d' of `c(ALPHA)'
						qui putexcel `letter'`s' = "`freqperc'", right
					}
					/* ||||||||||||||||||||||||||||||||||||||||||||||| */
					
					local ++r
					local ++k
				}
			}
		}
		else if "`by'" == "" {
			
			local r = `row'
				
			if "`catmisstype'" == "none" {
				qui levelsof `cv', local(c_l)
			}
			else if "`catmisstype'" == "missperc" {
				qui levelsof `cv', local(c_l) miss
			}
			else if "`catmisstype'" == "missnoperc" {
				qui levelsof `cv', local(c_l) miss
			}
				
			local lbe: value label `cv' 
			local k = 1
			
			if "`catrow'" == "catrow" & `categories' == 3 {
				local c_l: word 2 of `c_l'
			}
			
			
			local s=1
			local v=`j'
			foreach c of local c_l {
				
				local d = `cur_col'
				if "`lbe'" != ""{	
					local ct: label `lbe' `c'
				}
				else {
					local ct `c'
				}
				
				/* WEIGHT OPTION SPECIFIED ||||||||||||||||||||||| */
					if "`catmisstype'" == "none" {
						qui levelsof `cv', local(rows1)
						if "`wts'" != "" qui tabcount2 `cv' [aweight=`wts'], v1(`rows1') matrix(M) zero
						else qui tabcount2 `cv', v1(`rows1') matrix(M) zero
					}
						
						else if "`catmisstype'" == "missperc" {
							if "`wts'" != "" qui tab `cv' [aweight=`wts'], matcell(M) miss
							else qui tab `cv', matcell(M) miss
						}
						
						else if "`catmisstype'" == "missnoperc" {
							qui levelsof `cv', local(rows1)
							qui levelsof `by', local(cols1)
							if "`wts'" != "" {
								qui tabcount2 `cv' `by' [aweight=`wts'], v1(`rows1') v2(`cols1') matrix(M1) zero
								qui tab `cv' `by' [aweight=`wts'], matcell(M2) miss
							}
							else {
								qui tabcount2 `cv' `by', v1(`rows1') v2(`cols1') matrix(M1) zero
								qui tab `cv' `by', matcell(M2) miss							
							}
							
							local Mcount = rowsof(M2)
							
						}
						
						
						if "`catmisstype'" == "none" | "`catmisstype'" == "missperc" {
							if "`catrow'" == "catrow" & `categories' == 3 {
								local k=2
							}
							local freq_1 = M[`k',1]
							if "`wts'" != "" local freq_1: di %9.`fracfmt'f `freq_1'
							local freq_1 = strltrim("`freq_1'")
							
							
							if "`rowperc'" == "" {
								mata: st_matrix("M", (st_matrix("M")  :/ colsum(st_matrix("M"))))
							}
							else if "`rowperc'" == "rowperc" {
								mata: st_matrix("M", (st_matrix("M")  :/ rowsum(st_matrix("M"))))
							}
							
							local perc_1 = M[`k',1]
							
							local perc_1 = strltrim("`perc_1'")
							
							local pt_1 =`perc_1'*100
							local pt_1: di %9.`catfmt'f `pt_1'
							local pt_1 = strltrim("`pt_1'")
							local p_m " ("
							local p_n ")"
							local perc "%"
							
								
							*set frequency to missing if it's a column of zeroes
						if "`wts'" != "" {
							if "`wtfreq'" == "off" {
								local freqperc `pt_1'`perc'
							}
							else if "`wtfreq'" == "fractional" {
								if "`perc_1'" != "." {
									local freqperc `freq_1'`p_m'`pt_1'`perc'`p_n'	
								}
								else if "`perc_1'" == "." {
									local mis = .
									local freqperc `mis'`p_m'`pt_1'`perc'`p_n'	
								}
							}
							else if "`wtfreq'" == "ceiling" {
								local freq_1 = ceil(`freq_1')
								local freq_1 = strltrim("`freq_1'")
								if "`perc_1'" != "." {
									local freqperc `freq_1'`p_m'`pt_1'`perc'`p_n'	
								}
								else if "`perc_1'" == "." {
									local mis = .
									local freqperc `mis'`p_m'`pt_1'`perc'`p_n'	
								}	
							}
							else {
								di as error "Invalid wtfreq specification"
								exit 198
							}
							}
							else {
								local freqperc `freq_1'`p_m'`pt_1'`perc'`p_n'	
							}
						}
						else if "`catmisstype'" == "missnoperc" {
							
							matrix M3 = M2[`Mcount',1...]
							matrix M = M1\M3
							local freq_1 = M[`k',1]
							if "`wts'" != "" local freq_1: di %9.`fracfmt'f `freq_1'
							local freq_1 = strltrim("`freq_1'")
							
							if "`rowperc'" == "" {
								mata: st_matrix("M1", (st_matrix("M1")  :/ colsum(st_matrix("M1"))))
							}
							else if "`rowperc'" == "rowperc" {
								mata: st_matrix("M1", (st_matrix("M1")  :/ rowsum(st_matrix("M1"))))
							}
							
							
							matrix X1 = M3*.
							matrix M4 = M1\X1
							
							local perc_1 = M4[`k',1]
							local perc_1 = strltrim("`perc_1'")
							
							local pt_1 =`perc_1'*100
							local pt_1: di %9.`catfmt'f `pt_1'
							local pt_1 = strltrim("`pt_1'")
							local p_m " ("
							local p_n ")"
							local perc "%"
						
							if "`wts'" != "" {
							if "`wtfreq'" == "off" {
								local freqperc `pt_1'`perc'
							}
							else if "`wtfreq'" == "fractional" {
								local freqperc `freq_1'`p_m'`pt_1'`perc'`p_n'	
							}
							else if "`wtfreq'" == "ceiling" {
								local freq_1 = ceil(`freq_1')
								local freq_1 = strltrim("`freq_1'")
								local freqperc `freq_1'`p_m'`pt_1'`perc'`p_n'	
							}
							else {
								di as error "Invalid wtfreq specification"
								exit 198
							}
							}
							else {
								local freqperc `freq_1'`p_m'`pt_1'`perc'`p_n'
							}
						}
					
				
				if `cur_col'==1{
					/* for word table ||||||||||||||||||||||||||||||| */
					if "`word'" == "word" {
						if `categories' == 3 & "`catrow'" == "catrow" {
								putdocx table tbl2(`r',`d') = ("`var_lab'"), halign(left) colspan(2) bold
						}
						else {
							putdocx table tbl2(`r',`d') = ("      `ct'"), halign(left) colspan(2)
						}
					}
					
					/* for excel table ||||||||||||||||||||||||||||||| */
					if "`excel'" == "excel" {
						local s = `r' + 2
						local letter : word `d' of `c(ALPHA)'
						if `categories' == 3 & "`catrow'" == "catrow" qui putexcel `letter'`s' = "`var_lab'"
						else qui putexcel `letter'`s' = "      `ct'"
					}
					/* ||||||||||||||||||||||||||||||||||||||||||||||| */
					
				}
				local ++d
				
			
				/* for word table ||||||||||||||||||||||||||||||| */
				if "`word'" == "word" {
					putdocx table tbl2(`r',`d') = ("`freqperc'"), halign(center)
				}
				
				/* for excel table ||||||||||||||||||||||||||||||| */
				if "`excel'" == "excel" {
					local s=`r' + 2
					local letter: word `d' of `c(ALPHA)'
					qui putexcel `letter'`s' = "`freqperc'", right
				}
				/* ||||||||||||||||||||||||||||||||||||||||||||||| */
				
				local ++r
				local ++k
			}
		}	
		local row = `r'	
	}
/* |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||||||||||||||||||||||||||||||||||| CATEGORICAL VARIABLE LOOP END ||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| */

	* Have Stata drop extra blank rows
	
	/* for word table ||||||||||||||||||||||||||||||| */
	if "`word'" == "word" {
		qui putdocx describe tbl2
		local droprow = `r(nrows)'-1
		di "`droprow'"
		putdocx table tbl2(`r(nrows)',.), drop
		putdocx table tbl2(`droprow',.), drop
	}

	if "`wordname'" == ""{

		local wordname "table1.docx"
	}
	
	/* for word table ||||||||||||||||||||||||||||||| */
	if "`word'" == "word" {
		putdocx table tbl12 = (2,1), border(all, nil) /*headerrow(1)*/ layout(fixed) cellspacing(0.01)
		putdocx table tbl12(1,1) = table(tbl1)
		putdocx table tbl12(2,1) = table(tbl2), border(bottom)
		putdocx table tbl12(2,1) = table(tbl2), border(bottom)
		putdocx save `wordname', `replace' `append'
	}
	

	if "`pval'" == "pval" & "`mean'" != "mean" {
		di as text "Note: continuous variable p-value type is automatically Kruskall-Wallis test since 'mean' option is not selected"
	}

	if "`directory'"!="" {
		if "`word'" == "word" {
			di as text "Table '`wordname'' saved in `directory'"
		}
		if "`excel'" == "excel" {
			di as text "Excel file '`excelname'' saved in `directory'"
		}
	}
	else {
		if "`word'" == "word" {
			di as text "Table '`wordname'' saved in current working directory"
		}
		if "`excel'" == "excel" {
			di as text "Excel file '`excelname'' saved in current working directory"
		}
	}
	
	qui use "`_temp'", clear

end


/* |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||||||||||||||||||||| MODIFICATION OF NICK COX'S TABCOUNT FUNCTION TO ALLOW FOR AWEIGHTS |||
||||||||||||||||||||| WHEN THERE ARE ROWS OR COLUMNS WITH ZEROES |||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| */
*! NJC 2.0.2 17 Sept 2004       
* NJC 2.0.1 7 Sept 2004         
* NJC 2.0.0 20 June 2003    
capture program drop tabcount2    
capture program drop Repeat12
capture program drop Repeat22
capture program drop Tomatrix2
*! NJC 2.0.2 17 Sept 2004       
* NJC 2.0.1 7 Sept 2004         
* NJC 2.0.0 20 June 2003        
program tabcount2, byable(recall) 
        syntax varlist [if] [in] [aweight/] ,     /// 
        [v(str asis) v1(str asis) v2(str asis)   ///
          MATrix(str) replace zero MISSing freq(str) * ]   

		  quietly {
                tokenize `varlist' 
                local nvars : word count `varlist'

                if `nvars' > 2 & "`matrix'" != "" { 
                        di as err "matrix() not allowed with `nvars' variables"
                        exit 198 
                }       

                if _by() & "`matrix'" != "" { 
                        di as err "matrix() may not be combined with by:"
                        exit 198 
                }       
                
                if _by() & "`replace'" != "" { 
                        di as err "replace may not be combined with by:"
                        exit 198 
                }       
        
                if "`missing'" != "" local novarlist "novarlist"
                marksample touse, strok `novarlist'  
                count if `touse' 
                if r(N) == 0 error 2000 

                // v() is a synonym for v1() with one variable 
                if `nvars' == 1 & `"`v1'"' == "" { 
                        local v1 `"`v'"'
                }       
                
                forval i = 1/`nvars' { 
                        if `"`v`i''"' != "" local vlist "`vlist'`i' "  
                } 
                
                // c() is a synonym for c1() with one variable 
                if `nvars' == 1 & `"`c1'"' == "" { 
                        local c1 `"`c'"'
                }       
                
                forval i = 1/`nvars' { 
                        if `"`c`i''"' != "" local clist "`clist'`i' "  
                } 

                local inter : list vlist & clist 
                if "`inter'" != "" { 
                        di as err "cannot specify both v?() and c?()" 
                        exit 198 
                }

                local union : list vlist | clist 
                local union : list sort union 
                local nopts : list sizeof union 

                if `nopts' != `nvars' { 
                        if `nvars' > 1 local s "s" 
                        di as err "must specify `nvars' v?() or c?() option`s'"
                        exit 198 
                } 
                        
                local nc = 1 
                foreach i of local vlist { 
                        capture numlist "`v`i''", miss
                        if _rc == 0 local v`i' "`r(numlist)'" 
                        local nc = `nc' * `: word count `v`i''' 
                } 

                foreach i of local clist { 
                        local nc = `nc' * `: word count `c`i''' 
                } 
                
                if `nc' > _N { 
                        preserve 
                        set obs `nc'
                } 
                else if "`replace'" != "" { 
                        preserve
                }       
                
                tempvar toshow wt 
                gen long `toshow' = .
                label var `toshow' "Freq."

                local j = 1 
                local cond "`touse'" 
                foreach i of local union { 
                        tempvar V`i' 
                        
                        if `"`v`i''"' != "" { 
                                Repeat12 `V`i'', values(`v`i'') block(`j')
                                local vallbl : value label ``i'' 
                                if "`vallbl'" != "" label val `V`i'' `vallbl' 
                                local cond "`cond' & ``i'' == `V`i''[@]" 
                        }       
                        else {
                                tempvar C`i'  
                                Repeat22 `V`i'' `C`i'', cond(`c`i'') block(`j') 
                                local cond "`cond' & ``i'' `V`i''" 
                                local Clist "`Clist' `V`i''" 
                                local V`i' "`C`i''" 
                        }       
                        
                        local Union "`Union' `V`i''" 
                        _crcslbl `V`i'' ``i'' 
                        local j = `j' * `r(nvals)' 
                } 
			

                if "`exp'" == "" local exp 1 
                gen `wt' = `exp' 
                
                forval i = 1/`nc' { 
                        local COND : subinstr local cond "[@]" "[`i']", all  

                        foreach C of local Clist {
                                local COND : ///
                                subinstr local COND "`C'" `"`= `C'[`i']'"' 
                        }
						local var1: word 1 of `varlist'
						local var2: word 2 of `varlist'
						if "`var2'" != "" {
							su `wt' if `var1' != . & `var2' != ., meanonly
						}
						else if "`var2'" == "" {
							su `wt' if `var1' != ., meanonly
						}
						local N = r(sum)
						local num = r(sum_w)
                        su `wt' if `COND', meanonly
						local N2=r(sum)
                        replace `toshow' = `N2'*`num'/`N' in `i' 
                } 
                
                if "`zero'" == "" replace `toshow' = . if `toshow' == 0 
          }

        tokenize `Union' 
        local vars "`1' `2' `3'"
        if `nvars' >= 4 local byvars "by(`4' `5' `6' `7')"
		noisily tabdisp `vars' in 1/`nc', c(`toshow') `byvars' `options'
		

        quietly { 
                if "`matrix'`replace'" != "" { 
                        replace `toshow' = 0 if missing(`toshow') 
                } 
                
                if "`matrix'" != "" { 
                        Tomatrix2 `1' `2' `toshow' in 1/`nc', ///
                        matrix(`matrix') `missing' 
                }       
                
                if "`replace'" != "" { 
                        if "`freq'" == "" { 
                                capture confirm new variable _freq
                                if _rc == 0 local freq "_freq"
                                else {
                                        di as err "_freq already defined: " ///
                        "use freq() option to specify frequency variable"
                                        exit 110
                                }
                        }
                        else confirm new variable `freq'
                
                        local i = 1 
                        foreach v of local varlist { 
                                drop `v' 
                                rename ``i++'' `v' 
                        }       
                        rename `toshow' `freq' 
                        keep in 1/`nc' 
                        keep `varlist' `freq'
                        compress 
                        restore, not 
                }       
        }       
end 
         
program Repeat12, rclass 
* NJC 1.0.0 12 June 2003 
        version 8 
        syntax newvarlist(max=1), Values(str asis) [ Block(int 1) ]

        qui { 
                tempvar obs which 
                gen long `obs' = _n  
        
                capture numlist "`values'", miss 
                local isstr = _rc  
                if `isstr' { 
                        gen `varlist' = "" 
                        local nvals : word count `values' 
                        tokenize `"`values'"' 
                } 
                else { 
                        gen double `varlist' = .
                        local nvals : word count `r(numlist)' 
                        tokenize "`r(numlist)'" 
                } 
                
                gen long `which' = 1 + int(mod((`obs' - 1) / `block', `nvals'))

                if `isstr' { 
                        forval i = 1 / `nvals' { 
                                replace `varlist' = "``i''" if `which' == `i'  
                        }
                }       
                else {  
                        forval i = 1 / `nvals' { 
                                replace `varlist' = ``i'' if `which' == `i' 
                        }       
                }
        }       
        return local nvals = `nvals' 
end

program Repeat22, rclass 
* NJC 1.0.0 12 June 2003 
        version 8 
        syntax newvarlist(max=2), Cond(str asis) [ Block(int 1) ]

        qui { 
                tokenize `varlist' 
                args newvar which 
                gen `newvar' = ""
                local nvals : word count `cond' 
                gen long `which' = 1 + int(mod((_n - 1) / `block', `nvals'))
                
                tokenize `"`cond'"' 
                local oper "> < ! ~" 
                
                forval i = 1 / `nvals' {
                        label def `which' `i' "``i''", modify 
                        capture confirm number ``i'' 
                        if _rc == 0 { 
                                local `i' "== ``i''"
                                replace `newvar' = "``i''" if `which' == `i'  
                        }
                        else { 
                                local char = substr(trim(`"``i''"'),1,1) 
                                if `: list char in oper' { 
                                        replace `newvar' = `"``i''"' if `which' == `i'
                                }       
                                else replace `newvar' = ///
                                `" == `"``i''"'"' if `which' == `i' 
                        }       
                }
                label val `which' `which'   
        }       
        return local nvals = `nvals' 
end

program Tomatrix2, sort  
        syntax varlist(min=1 max=3) [if] [in] , Matrix(str) [ missing ] 
        
        marksample touse, novarlist
        qui count if `touse' 
        if r(N) == 0 error 2000 
        local N = r(N) 

        tokenize `varlist' 
        local nvars : word count `varlist' 

        if `nvars' == 3 { 
                args row col val 
                qui levels `row' if `touse', local(lr) `missing' 
                local nr : word count `lr' 
                qui levels `col' if `touse', local(lc) `missing' 
                local nc : word count `lc'
                
                if `N' != (`nr' * `nc') { 
                        di as err "`nr' X `nc' matrix expected; `N' values"
                        exit 498 
                }
        } 
        else if `nvars' == 2 { 
                args row val 
                qui levels `row' if `touse', local(lr) `missing' 
                local nr : word count `lr'
                local nc = 1 
                if `N' != (`nr' * `nc') { 
                        di as err "`nr' X `nc' matrix expected; `N' values"
                        exit 498 
                }
        
        } 
        else if `nvars' == 1 { 
                local nr = `N' 
                local nc = 1 
        } 

        matrix `matrix' = J(`nr',`nc',0) 

        tempvar obs 
        sort `touse' `row' `col' `_sortindex' 
        qui gen long `obs' = _n if `touse'
        su `obs', meanonly 
        local k = `r(min)' 
        forval i = 1/`nr' { 
                forval j = 1/`nc' { 
                        matrix `matrix'[`i',`j'] = `val'[`k++'] 
                }
        } 

        if `nvars' >= 2 { 
                capture matrix rownames `matrix' = `lr' 
                if _rc { 
                        numlist "1/`nr'" 
                        matrix rownames `matrix' = `r(numlist)'
                }       
        }
        if `nvars' == 3 { 
                capture matrix colnames `matrix' = `lc'
                if _rc { 
                        numlist "1/`nc'" 
                        matrix colnames `matrix' = `r(numlist)'
                } 
        }       
end 
        

/* |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| */





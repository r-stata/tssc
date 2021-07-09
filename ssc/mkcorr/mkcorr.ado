program mkcorr, byable(recall)
syntax varlist [if] [in],Log(string) [Replace] [CDec(integer 2)] [MDec(integer 3)] [Means] [Sig] [Num] [Label] ///
[NOCorr] [CASEwise]

version 8.0

*! Author: Glenn Hoetker
*! Date: 08Mar2014
*! Version: 2.0.1

/*
Version history

1.0 (03 September 2003) Initial release
1.1 (15 September 2003) Bug fixes and feature additions
	* Rewrote to avoid use of preserve/restore to speed up the code
	* Fixed a bug that could calcuate the significance value on a different
	  set of observations than the correlations as a whole.
	* Fixed two typos in the help file (mdec, not mdeq.  cdec, not cdeq)
	* Added "nocorr" option to allow for just producing summary stats
1.2 (17 September 2003)
	* Added code so that log(foo.log) will generate foo.log, not foo.log.log
	* Added code to handle situation in which some, but not all labels exist
	* Removed unnecessary definition of local variables rho and n
	* Fixed some spelling errors in the help file.
1.3 (7 October 2003)
	* Fixed code to allow use to specify her own file suffix. log(foo.out)
	  now generates the file foo.out, not foo.out.log.
	* Fixed code to allow users to specify a path as part of the logfile.
	* Fixed code to allow users to specify a logfile name that includes a space.
2.0 (17 November 2005) Significant upgrade/bug fix
	* Fixed code to appropriately handle pairwise deletion.  That is, unless
	  "casewise" is specified, the results will duplicate those produced by 
	  "pwcorr".  This also addresses a problem that could arise with calculated 
	  significance values.  They are now accurate.
2.0.1 (8 March 2014) Updated author contact information in help file.
*/

/* Macros */
local width=`cdec'+2
local cformat "%`width'.`cdec'f"
local mformat "%9.`mdec'f"
tempname output
tempvar touse
local n_rows:list sizeof varlist
local n_cols: list sizeof varlist

//Limit the sample to those with observations for all vars if CASEwise selected
if "`casewise'"~="" {
	marksample touse
	if "`if'"~="" {
		local if="`if'" + " & \`touse'"
	}
	else {
		local if "if \`touse'"
		}
	}	
		//Open and write to the file.

if index(`"`log'"',".")>0 {
	local logname `log'
	}
else {
	local logname `log'.log
	}
	
file open `output' using `"`logname'"', write text `replace'

//The labels across the top
	file write `output' _tab
	if "`num'"~="" file write `output' _tab
	if "`means'"~="" {
		file write `output' "Mean" _tab "S.D." _tab "Min" _tab "Max" _tab
		}
	
		//Put either variable names or numbers
		if "`nocorr'"=="" {
			if "`num'"=="" {
				foreach var of local varlist{
					local lab: variable label `var'
					if "`label'"=="" | `"`lab'"'=="" {
						local lab `var'
						}
					file write `output' "`lab'" _tab
					}
				}
				else {
					forvalues x=1/`n_cols' {
						file write `output' "(" (`x') ")" _tab
					}
				}
			}
	file write `output' _n


//Output rows of the matrix one at a time, starting with the variable name and then the values

forvalues row=1/`n_rows' {
	//The number of the variable, if requested by NUM
	if "`num'"~="" {
		file write `output' "(" (`row') ")" _tab
		}
	
	//The variable name
	local var: word `row' of `varlist'
	local lab: variable label `var'
	if "`label'"=="" | `"`lab'"'==""{
		local lab `var'
		}
	file write `output' "`lab'" _tab
	
	//The values
		//If we are putting in means
		if "`means'"~="" {
		quietly summarize `var' `if' `in'
		file write `output' `mformat' (`r(mean)') _tab ///
		`mformat' (`r(sd)') _tab `mformat' (`r(min)') _tab `mformat' (`r(max)') _tab
		}
	//Correlations
	if "`nocorr'"=="" {
		forvalues col=1/`row' {     //Notice that we are only doing the bottom half
			local var1:word `row' of `varlist'
			local var2:word `col' of `varlist'
			qui corr(`var1' `var2') `if' `in'
			local val=r(rho)
			file write `output' `cformat' (`val') _tab 
		}	
		file write `output' _n
	
		//Put in the significance in the next row, if requested
		if "`sig'"~="" {
			file write `output' _tab
			if "`means'"~="" {
				file write `output' _tab(4)
				}
			if "`num'"~="" {
				file write `output' _tab
				}
			forvalues col=1/`row' {
				local var1:word `row' of `varlist'
				local var2:word `col' of `varlist'
				if "`row'"=="`col'" {
					file write `output' "" _tab
					}
				else {
				qui correlate `var1' `var2' `if' `in'
				local rho=`r(rho)'
				local n=`r(N)'
				local p=min(tprob(r(N)-2,r(rho)*sqrt(r(N)-2)/sqrt(1-r(rho)^2)),1)
				file write `output' "(" `cformat' (`p') ")" _tab
				}
			}
			file write `output' _n
			}
		}
	else file write `output' _n
	}

file close `output'

end


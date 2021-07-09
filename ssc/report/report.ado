*! Date        : 17 Feb 2020
*! Version     : 1.15
*! Authors     : Adrian Mander
*! Email       : mandera@cardiff.ac.uk
*!
*! Docx reporting

/*
v1.00 19Mar19 command is born
v1.01  2Jun19 adding in totals and percentages
v1.02 18Jun19 removed bug wrt missing data in frequency table
v1.03 20Jun19 sorted out table options and paragraph options
v1.04 21Jun19 sorted out note error
v1.05 21Jun19 changed newfile to replace
v1.06 15Jul19 adding in a listing option
v1.07  7Aug19 Allowing columns to be adjacent not nested Adding BY of mean results and strings
v1.08 18Sep19 Checks the value labels and expand cols or rows to add in additional values that might not occur
v1.09 22Nov19 Altered the helpfile slightly
v1.10 10Jan20 Adding, overall on summary statistics, missing rather than non-missing, rowsadjacent on summary
v1.11 14Jan20 Fixing bugs
v1.12 15Jan20 add rowtotals to frequency tables with adjacent rows
v1.13 20Jan20 variable names 16 characters long are unable to be used in the summarise part..
v1.14 22Jan20 captured some issues around display formats of some variable categories being dates..
v1.15 17Feb20 made sure that variable names have 30 characters or fewer.. at the limit causes problems

FUTURE get rid of freq dependency.. use tempname...
*/

/* START HELP FILE
title[A command to produce tables for XML]

desc[
 {cmd:report} produces a single table that can be added to an existing docx file or 
 used to create a new docx file.
]

opt[adjacentcolumns() indicates that columns are placed next to each other and not nested.]
opt[adjacentrows() indicates that rows are placed next to each other and not nested.]
opt[cols() specifies the variables used for the columns of the table.]
opt[coltotals() specifies to produce column totals for a frequency table.]
opt[column() specifies to produce column percentages for a frequency table.]
opt[dropfirst() specifies that the first # lines are dropped.]
opt[droplast() specifies that the last # lines are dropped.]
opt[file() specifies the filename of the file to contain the new table.]
opt[font() specifies the font to be used in the table.]
opt[landscape specifies whether the table is created in landscape mode.]
opt[missing() specifies that missing values will be reported separately for frequency tables and NOT summary tables.]
opt[nofreq() indicates that frequency values are not included in the table.]
opt[note() specifies the text to place in the table note.]
opt[overall() specifies that overall summary statistics are included in the summary statistics tables.]
opt[pagesize() specifies the page size.]
opt[rowsby() indicates that the summary statistics table has a subdivision on the rows, this can be used in conjuntion with cols() but not adjacentcolumns().]
opt[rowtotals() specifies that additional totals are added to the inner row variable.]
opt[rows() specifies the variable(s) used for the rows of the table.]
opt[row() specifies to produce row percentages for a frequency table.]
opt[totals() specifies to produce total columns and rows for a frequency table.]
opt[replace()  specifies that a new file be created.]
opt[title() specifies the text used as the title of the table.]
opt[toptions() specifies the additional text options used for the table.]
opt[tableoptions() specifies the additional options used for the table.]
opt[usecollabels uses the value label to determine the values tabulated as opposed to which values are observed.]
opt[userowlabels uses the value label to determine the values tabulated as opposed to which values are observed.]
opt[* extras]

example[
First read in some data

{stata webuse citytemp2, clear} <--- this will delete your data!

The simplest table is to create a list of unique levels of a variable and places it 
in a file called test.docx (replacing it if it already exists).

{stata report,  rows(region) nofreq file(test) replace}

Then freqencies of each category and percentages can be added to the same filename test.docx (by not specifying replace)

{stata report,  rows(region) title(Frequency and row percentages) file(test) row}


Often the same sort of report can be desired for two variables, this can be done by adding in an additional variable
into the rows() option.

{stata report,  rows(region agecat)   title(2-way Freq table) file(test) row}

However, this is not the usual way of producing a frequency table and the useful one is having
region as the row variable and agecat as the column variable. To give the more familiar table.

{stata report, rows(region) cols(agecat) column totals file(test)}

Higher dimensions are allowable 

{stata report, rows(region division) cols(agecat) column totals file(test)}

which does not seem correct because region is derived from division and there are plenty of zero cells
in the table. However you could do separate tables with rows either region or division but to 
combine into one table you can use the adjacentrows option

{stata report, rows(region division) cols(agecat) column totals file(test) adjacentrows}


A table containing summary statistics can also be created with the following command. Note that you can put formating statements for each of 
the summary statistics. Also the statistics are the words used in the collapse command and any of the collapse 
statistics can be used.

{stata report, rows(tempjan, mean %5.2f | tempjan, sd  %5.2f| tempjan, count | tempjuly, mean  %5.2f| tempjuly, median  %5.2f) cols(region agecat)  font(,8) file(test)}


Rather than nesting age within region, it might be preferred to have the columns alongside each other and here we add the adjacentcolumns option

{stata report, rows(tempjan, mean %5.2f | tempjan, sd  %5.2f| tempjan, count | tempjuly, mean  %5.2f| tempjuly, median  %5.2f) cols(region agecat)  font(,8) file(test) adjacentcolumns}

Also it is possible to add the overall category alongside the column variables.

{stata report, rows(tempjan, mean %5.2f | tempjan, sd  %5.2f| tempjan, count | tempjuly, mean  %5.2f| tempjuly, median  %5.2f) cols(region agecat)  font(,8) file(test) adjacentcolumns overall}

Or perhaps you want to subdivide the rows by region and have age categories as columns, this is handled by adding a rowsby() option.

{stata report, rows(tempjan, mean %5.2f | tempjan, sd  %5.2f| tempjan, count | tempjuly, mean  %5.2f| tempjuly, median  %5.2f) cols(agecat) rowsby(region) font(,8) file(test) }

Then to produce the table in landscape because it doesn't fit well in portrait (which is the default)
{stata report, rows(heatdd, mean %5.2f | heatdd, count | heatdd, sd %5.3f | tempjan, mean %5.2f | tempjan, sd  %5.2f| tempjan, count | tempjuly, mean  %5.2f| tempjuly, median  %5.2f) cols(region agecat)  font(,8) landscape file(test2) replace}

]

author[Prof Adrian Mander]
institute[Cardiff University]
email[mandera@cardiff.ac.uk]

freetext[]

END HELP FILE */

prog def report
  preserve
  /* Allow use on earlier versions of stata that have not been fully tested */
  local version = _caller()
  local myversion = 16.0
  if `version' < `myversion' {
    di "{err}WARNING: Tested only for Stata version `myversion' and higher."
    di "{err}Your Stata version `version' is not officially supported."
  }
  else {
    version `myversion'
  }
 
  syntax , ROWS(string) [ COLS(string) FILE(string) Title(string asis) TOPTIONS(string asis) ADJacentcolumns  ADJACENTROWS ///
  TABLEOPTIONS(string asis) USECOLLABELS USEROWLABELS FONT(string) LANDSCAPE PAGESIZE(string) ROW COLumn TOTALS ///
  NOTE(string) NOFREQ REPLACE MISSING DROPFIRST(integer 0) DROPLAST(integer 0) ROWTOTALS COLTOTALS ///
  rowsby(varname)  overall *]
  /* I have removed the two options MEMORY(string) JOINTABLES(string) for now the code still exists */
  local docx_options "`options'"

  /**************************
   * For memory save table
   **************************/

  /*******************************************************************************
   * NOTE: I need to drop all missing values in the frequency table to begin with
   *******************************************************************************/
  if "`missing'"=="" & "`adjacentrows'"=="" {
    if (strpos(`"`rows'"',",")==0 & strpos(`"`cols'"',",")==0) { /* the if statement to rule out non-freq tables*/
      if `"`cols'"'~="" {
        foreach cvar of varlist `cols' {
          qui drop if `cvar'==.
        }
      }
      foreach rvar of varlist `rows' {
        qui drop if `rvar'==.
      }  
    }
  }

  /*************************************************
   * The start of the document options 
   *************************************************/
  local begindoc "putdocx begin, "
  /* just check on page size */
  if "`pagesize'"=="" {
    local begindoc "`begindoc' pagesize(A4)"
  }
  else {
    local begindoc "`begindoc' pagesize(`pagesize')"
  }
  /* Add all the cell fmts together and the overall font setting */
  local format ""
  if "`font'"~="" {
    local format `"`format' font(`font')"'
    local begindoc "`begindoc' font(`font')"
  }
  else {
    local begindoc "`begindoc' font(Palatino)"
  }

  tempname data
  if "`file'"=="" {
    tempname fileroot
    local file "`fileroot'.docx"
  }
  /**** holds a table in memory but doesn't close the file ***/
  if "`memory'"=="" {
    /* start putdocx */
    putdocx clear
    `begindoc' `landscape'
    putdocx paragraph, `docx_options'
    putdocx text ("`title'"), `toptions'
  }
  else {
    cap `begindoc' `landscape'
    putdocx paragraph, `docx_options'
    putdocx text ("`title'"), `toptions'
    local mtab `"memtable"'
  }
  if "`memory'"=="" local memory "whole"

  /* work out if you are including row and column percentages */
  if ("`row'"~="" & "`column'"~="") local xtra `"`xtra' note("Row and Column percentages")"' 
  else if ("`row'"~="" & "`column'"=="")  local xtra `"`xtra' note("Row percentages")"'
  else if ("`row'"=="" & "`column'"~="" ) local xtra `"`xtra' note("Column percentages")"'
  if ("`note'"~="") local xtra `"`xtra' note("`note'")"'
 
/*******************************************************************************
 *
 *  A basic command that allows a frequency table without specifying a column 
 *
 *******************************************************************************/

if `"`cols'"'=="" {
  /* error check*/
  if "`adjacentcolumns'"~="" {
    di "{err} WARNING adjacentcolumns cannot be specified for a frequency table yet"
  }
  if "`adjacentrows'"~="" {
    di "{err} WARNING adjacentrows cannot be specified for a frequency table yet"
  }

  /* need to identify that last variable */
  if "`rowtotals'"~="" {
    local nr 1
    foreach var of varlist `rows' {
      local lastrowvar "`var'"
      local `nr++'
    }
    if "`--nr'"=="1" {
      di "{err} You can not specify row totals with a single row variable use totals"
      exit(198)
    }
  }
  /* The start code is setting up the macros and dimensions of the table */
  qui sort `rows'
  qui su `rows'
  local rowss "`r(N)'" /*get the totals for row percentages*/
  tempname freq
  qui by `rows': gen `freq'=_N
  qui by `rows': keep if _n== _N
  /* Work out dimnesions of the table first*/
  local ntabrows 1
  local nrowvars 0
  /* Sort out the row variables getting number levels, levels and labels */
  local nr 1
  foreach var of varlist `rows' {
    if (length("`var'")>=31) { /* long variable names are a problem*/
      di "{err} Variable `var' has >30 characters, this needs to be shorten to a maximum 30 characters"
      exit(198)
    }
    local `var'l: variable label `var'
    local `var'v: value label `var'
    if "`userowlabels'"=="" {
      qui levelsof `var', `missing'
      local nrowlevs`nr' "`r(r)'" 
      local rowlevs`nr' "`r(levels)'"
      if "`rowtotals'"~="" & "`var'"=="`lastrowvar'" {
        local ntabrows = `ntabrows'*(`r(r)'+1)
        local nrowlevs`nr' = `r(r)'+1
      }
      else local ntabrows = `ntabrows'*`r(r)'
      local `nr++'
      local nrowvars = `nrowvars'+1
    }
    else {
      qui _labelvector `var'
      local nrowlevs`nr' "`r(r)'" 
      local rowlevs`nr' "`r(values)'"
      if "`rowtotals'"~="" & "`var'"=="`lastrowvar'" {
        local ntabrows = `ntabrows'*(`r(r)'+1)
        local nrowlevs`nr' = `r(r)'+1
      }
      else local ntabrows = `ntabrows'*`r(r)'
      local `nr++'
      local nrowvars = `nrowvars'+1
    }
  }
  /* Add an extra row and column for totals */
  if "`nofreq'"=="" {
    local extraline 1
    putdocx table `memory' = (`=`ntabrows'+1', `=2*`nrowvars'+1'), border(start, nil)  border(end, nil) layout(autofitwindow) `xtra' `tableoptions' `mtab'
  }
  else {
    local extraline 0
    putdocx table `memory' = (`=`ntabrows'', `=2*`nrowvars''), border(start, nil)  border(end, nil) layout(autofitwindow) `xtra' `tableoptions' `mtab'
  }
  
   /* Figuring out the spacing of the variable labels */
   /* Do the row set up of table  */
  local nr 1
  foreach var of varlist `rows' {
    /* get the variable label if it exists*/ 	 
    if "``var'l'"~="" putdocx table `memory'(`=1+`extraline'', `=2*`nr'-1')= ("``var'l'") , rowspan(`=`ntabrows'') `format'
    else putdocx table `memory'(`=1+`extraline'',`=2*`nr'-1')= ("`var'") , rowspan(`=`ntabrows'') `format'
    /* for the 2nd, 3rd,... row variables need to repeat the labels*/
	 local rowspan 1
	 local nrepeats 1
	 if `nr'>1 {
	   forv i=1/`=`nr'-1' {
	     local nrepeats = `nrepeats'*`nrowlevs`i''
	   }
	 }
	 if `nr'<`nrowvars' { /* need a span if it isn't last row variable*/
       forv i =`=`nr'+1'/`nrowvars' {
         local rowspan = `rowspan'*`nrowlevs`i''
       }
     }
	 local rowi 1
	 forv i=1/`nrepeats' {
	   foreach lev in `rowlevs`nr'' {
	     if "``var'v'"~="" local txtlab: label ``var'v' `lev'
         else local txtlab=""
         if "`txtlab'"=="" putdocx table `memory'(`=`rowi'+`extraline'',`=2*`nr'')= ("`lev'") , rowspan(`rowspan') `format'
         else putdocx table `memory'(`=`rowi'+`extraline'',`=2*`nr'')= ("`txtlab'") , rowspan(`rowspan') `format'		
         local rowi = `rowi'+`rowspan'	 
      }
      if "`var'"=="`lastrowvar'" {
        putdocx table `memory'(`=`rowi'+`extraline'',`=2*`nr'')= ("Row total")
        local rowi = `rowi'+1
      }
    }
    local nr= `nr'+1
  }
   
/* Work out the number of cells */
  local ncells 1
  local nrows 1
  forv nr = 1/`nrowvars' {
    local nrows = `nrows'*`nrowlevs`nr''
    local ncells = `ncells'*`nrowlevs`nr''
  }

   /* generate an if statement to do the frequency calculation per row */
  local tot_rowline 1
    forv i=0/`=`ncells'-1' {
      /* use mod to get if statement */
      local ifcell ""
	  

	  /* work out the row line  
	  rowline1 contains the level of the first row var
	  rowline2 contains the level of the second row var etc..
	  */
	  local nr 1 /* numbered row variable */
	  local rowline 1  /* I think this is the rowline of the table */
	  local left "`i'"  /* left has the cell number */
	  foreach rvar of varlist `rows' {
	    local cond = mod(`left',`nrowlevs`nr'')  /* we know total nrowlevs */
		local chk : word `=`cond'+1' of `rowlevs`nr'' /* chk is empty for lastrowvar last element*/
		local rowline`nr' = `cond'+1
		if "`ifcell'"=="" {
		  if `"`chk'"'~="" {
		    cap confirm str variable `rvar'
		    if (!_rc) local ifcell `"`ifcell' `rvar'=="`chk'""'
		    else local ifcell `"`ifcell' `rvar'==`chk'"'
		  }
		}
		else {
          if `"`chk'"'~="" {
		    cap confirm str variable `rvar'
		    if (!_rc)  ifcell  `"`ifcell' & `rvar'=="`chk'""'
		    else local ifcell  `"`ifcell' & `rvar'==`chk'"'
		  }
		}
		local left = (`left' - mod(`left',`nrowlevs`nr''))/`nrowlevs`nr''
		local `nr++'
	  }
	  	  
      forv nr = `nrowvars'(-1)1 {
        if `nr' == `nrowvars' {
		  local rowline = `rowline`nr''
		  local rowblock = `nrowlevs`nr''
		}
		else {
		  local rowline = `rowline'+(`rowline`nr''-1)*`rowblock'
		  local rowblock = `rowblock'*`nrowlevs`nr''
		}
      }
	  qui su `freq' if `ifcell'
	  local txt "`r(sum)'"
		  
	  /* Put total text in table and then calculate row and column totals */
	  local totalstart 1
	  if "`nofreq'"=="" {
        if (`totalstart') {
		  local totalstart 0
		  putdocx table `memory'(`=1+1-1',`=2*`nrowvars'+1')= ("Total")
		}

          qui su `freq' if `ifcell'  /*changed from ifcellrow*/
		  local txttot =`r(sum)'
		  putdocx table `memory'(`=`rowline'+`extraline'',`=2*`nrowvars'+1')= ("`txttot'"), `format'
        if "`row'"~="" {
		  local txtrow : di %5.2f 100*`txttot'/`rowss'
          putdocx table `memory'(`=`rowline'+`extraline'',`=1+2*`nrowvars''), linebreak
          putdocx table `memory'(`=`rowline'+`extraline'',`=1+2*`nrowvars'')= ("`txtrow'%"), append
	    }	
	  }
   }
 }
 
 /*******************************************************************************
 *
 * Code for Frequency TABLES with ADAJACENT ROWS
 *
 *******************************************************************************/

  else if strpos(`"`rows'"',",")==0 & strpos(`"`cols'"',",")==0 & "`adjacentrows'"~="" {
    /* need to loop over each row variable creating the table, preserving the data
    */
    /* error check*/
    if "`adjacentcolumns'"~="" {
      di "{err} WARNING adjacentcolumns cannot be specified for a frequency table yet"
    }

  /*
   * Work out dimnesions of the table first and open the table docx file 
   */
    if "`overall'"~="" di "{err}WARNING: Overall option specified but can not be used on a frequency table do you mean totals?"
    local ntabrows 0
    local ntabcols 1
    local nrowvars 0
    local ncolvars 0
    local nr 1
    local nc 1
    foreach var of varlist `rows' {
      if (length("`var'")>=31) { /* long variable names are a problem*/
        di "{err} Variable `var' has >30 characters, this needs to be shorten to a maximum 30 characters"
        exit(198)
      }
      local `var'l: variable label `var'
      local `var'v: value label `var'
      if "`userowlabels'"=="" {
        qui levelsof `var', `missing'
        if (`r(r)'==0 | `r(N)'==0) {
          di "{err} The variable {ul:`var'} has no values to tabulate"
          exit(198)
        }
        local nrowlevs`nr' "`r(r)'" 
        local rowlevs`nr' "`r(levels)'"
        if "`coltotals'"~="" {
          local ntabrows = `ntabrows'+`r(r)'+1
          local nrowlevs`nr' = `r(r)'+1
        }
        else local ntabrows = `ntabrows'+`r(r)'
        local `nr++'
        local nrowvars = `nrowvars'+1
      }
      else {
        qui _labelvector `var'
        local nrowlevs`nr' "`r(r)'" 
        local rowlevs`nr' "`r(values)'"
        if "`coltotals'"~="" {
          local ntabrows = `ntabrows'+`r(r)'+1
          local nrowlevs`nr' = `r(r)'+1
        }
        else local ntabrows = `ntabrows'+`r(r)'
        local `nr++'
        local nrowvars = `nrowvars'+1
      }
    }
    foreach var of varlist `cols' {
      if (length("`var'")>=31) { /* long variable names are a problem*/
        di "{err} Variable `var' has >30 characters, this needs to be shorten to a maximum 30 characters"
        exit(198)
      }
      if "`usecollabels'"=="" {
        qui levelsof `var', `missing'
        local ncollevs`nc' "`r(r)'"
        local collevs`nc++' "`r(levels)'"
        local ntabcols = `ntabcols'*`r(r)'
        local ncolvars = `ncolvars'+1
      }
      else {
        qui _labelvector `var'
        local ncollevs`nc' "`r(r)'" 
        local collevs`nc++' "`r(values)'"
        local ntabcols = `ntabcols'*`r(r)'
        local ncolvars = `ncolvars'+1
      }
      local `var'l: variable label `var'
      local `var'v: value label `var'
    }
   /* Add an extra row and column for totals */
   if "`rowtotals'"~="" {
     putdocx table `memory' = (`=`ntabrows'+`ncolvars'*2', `=`ntabcols'+2+1'), border(start, nil)  border(end, nil) layout(autofitwindow) `xtra' `tableoptions' `mtab'
   }
   else {
     putdocx table `memory' = (`=`ntabrows'+`ncolvars'*2', `=`ntabcols'+2'), border(start, nil)  border(end, nil) layout(autofitwindow) `xtra' `tableoptions' `mtab'
   }

    local nr 1
    /* This code just makes frequencies for summing up later DO not delete */
    tempname freq
    qui gen `freq'=1
 
    /*
     * Table column header   --- Figuring out the spacing of the variable labels 
     */
    local nc 1
    foreach var of varlist `cols' {
      /* get the variable label if it exists*/
      local varlab: variable label `var'	 
      /* note the 3 column is because we only have 2 columns for all row variables */
//di "ntabcols `ntabcols'"
      if "`varlab'"~=""  putdocx table `memory'(`=2*`nc'-1',3)= ("`varlab'") , colspan(`ntabcols') `format'
      else putdocx table `memory'(`=`nc'*2-1',3)= ("`var'"), colspan(`ntabcols') `format'
      local colspan 1
      local nrepeats 1
      if `nc'>1 {
        forv i=1/`=`nc'-1' {
          local nrepeats = `nrepeats'*`ncollevs`i''
        }
      }
      if `nc'<`ncolvars' {
        forv i =`=`nc'+1'/`ncolvars' {
          local colspan = `colspan'*`ncollevs`i''
        }
      }
      local coli 1
      forv i=1/`nrepeats' {
        foreach lev in `collevs`nc'' {
          if "``var'v'"~="" local txtlab: label ``var'v' `lev'
          else local txtlab ""
          if "`txtlab'"=="" putdocx table `memory'(`=2*`nc'',`=`coli'+2')= ("`lev'") , colspan(`colspan') `format'
          else putdocx table `memory'(`=2*`nc'',`=`coli'+2')= ("`txtlab'") , colspan(`colspan') `format'		
          local coli = `coli'+1	 
        }
      }
      local nc= `nc'+1
    }

    /*
     * Do the row variables set up of table  
     */
    local nr 1
    local rowline = `ncolvars'*2+1
    foreach var of varlist `rows' {
      /* get the variable label if it exists*/
      local varlab: variable label `var'	 
      if "`varlab'"~=""  putdocx table `memory'(`rowline', 1)= ("`varlab'") , rowspan(`nrowlevs`nr'') `format'
      else putdocx table `memory'(`rowline',1)= ("`var'") , rowspan(`nrowlevs`nr'') `format'
      local rowi = `rowline'
      foreach lev in `rowlevs`nr'' {
        if "``var'v'"~="" local txtlab: label ``var'v' `lev'
        else local txtlab=""
        if "`txtlab'"=="" putdocx table `memory'(`rowi',2)= ("`lev'") , `format'
        else putdocx table `memory'(`rowi',2)= ("`txtlab'") ,  `format'		
        local rowi = `rowi'+1 
      }

    
    local rowline = `rowline' + `nrowlevs`nr''
    local nr= `nr'+1
  }
  if "`rowtotals'"~="" {
    putdocx table `memory'(`=`ncolvars'*2',`=`ntabcols'+2+1')= ("Total")
  }

  /* Work out the number of cells */
  local ncells 0
  local nrows 0
  local ncols 1
  forv nr = 1/`nrowvars' {
    local nrows = `nrows'+`nrowlevs`nr''
    local ncells = `ncells'+`nrowlevs`nr''
  }
  forv nc = 1/`ncolvars' {
    local ncells = `ncells'*`ncollevs`nc''
	  local ncols = `ncols'*`ncollevs`nc''
  }
   
  /*
   * generate an if statement to do the frequency calculation per row/col 
   * Then populate the table internal cells
   */
  local tot_rowline 1
  forv i=0/`=`ncells'-1' {
    /* use mod to get if statement */
	  local ifcell ""
	  /* work out the row line  
	  rowline1 contains the level of the first row var
	  */
	  local nr 1 /* numbered row variable */
    local left = mod(`i',`nrows') /* left has the cell number but mod makes a row line number */
    local rowline = `left'
	  foreach rvar of varlist `rows' {
      if "`coltotals'"=="" {
        if `left'>=`nrowlevs`nr'' {
          local left = `left'-`nrowlevs`nr''
        }
        else {
          if `"`ifcell'"'==`""' {
            local chk : word `=`left'+1' of `rowlevs`nr''
            cap confirm str variable `rvar'
            if (!_rc)  ifcell  `"`ifcell' `rvar'=="`chk'" &"'
            else local ifcell  `"`ifcell'  `rvar'==`chk' &"'
          }
        }
      }
      else {
       if `left'>=`=`nrowlevs`nr''' {
          local left = `left'-`nrowlevs`nr''
        }
        else {
            if (`left'==`nrowlevs`nr''-1) {
              local ifcell `"`ifcell' "'
            }
            else {
              if `"`ifcell'"'==`""' {
                local chk : word `=`left'+1' of `rowlevs`nr''
                if "`chk'"~="" { /* this must be the row total */
                  cap confirm str variable `rvar'
                  if (!_rc)  ifcell  `"`ifcell' `rvar'=="`chk'" &"'
                  else local ifcell  `"`ifcell'  `rvar'==`chk' &"'
                }
              }
            }
          }
        }
        local `nr++'  
      }
      local ifcell =trim(`"`ifcell'"')
      local ifcellrow =substr(`"`ifcell'"', 1, length(`"`ifcell'"')-1 )

      /* Given the cell number work out the variable if statement */
      local ifcellcol ""
      local left = (`i'-mod(`i',`nrows'))/`nrows'
	    /* work out which column by looping over the column variables */
      local nc 1
      foreach cvar of varlist `cols' {
        local cond = mod(`left',`ncollevs`nc'')
        local colline`nc' = `cond'+1
        local chk : word `=`cond'+1' of `collevs`nc''
        if `nc'~=`ncolvars'  {
          cap confirm string variable `cvar'
          if (!_rc) {
            local ifcell `"`ifcell' `cvar'=="`chk'" &"'
            local ifcellcol `"`ifcellcol' `cvar'=="`chk'" &"'
          }
          else {
            local ifcell `"`ifcell' `cvar'==`chk' &"'
            local ifcellcol `"`ifcellcol' `cvar'==`chk' &"'
          }
        }
        else {
          cap confirm string variable `cvar'
          if (!_rc) {
            local ifcell `"`ifcell' `cvar'=="`chk'" "'
            local ifcellcol `"`ifcellcol' `cvar'=="`chk'" "'
          }
          else {
            local ifcell `"`ifcell' `cvar'==`chk' "'
            local ifcellcol `"`ifcellcol' `cvar'==`chk' "'
          }
        }
        local left = (`left' - mod(`left',`ncollevs`nc''))/`ncollevs`nc''
        local `nc++'
      }
	  
    /* works out the position in the table */
    forv nc = `ncolvars'(-1)1 {
      if `nc' == `ncolvars' {
        local colline = `colline`nc''
        local colblock = `ncollevs`nc''
      }
      else {
        local colline = `colline'+(`colline`nc''-1)*`colblock'
        local colblock = `colblock'*`ncollevs`nc''
      }
    }  

	  qui su `freq' if `ifcell'
	  local txt "`r(sum)'"
	  if (trim("`ifcellrow'")=="") qui su `freq' 
    else qui su `freq' if `ifcellrow'
	  if `txt'==0 local txtrow "0"
	  else local txtrow: di %5.2f 100*`txt'/`r(sum)'
	  qui su `freq' if `ifcellcol'
	  if `txt'==0 local txtcol "0"
	  else local txtcol :di %5.2f 100*`txt'/`r(sum)'

/* CODE is needed if I want col totals in the table
	  local totalstart 1
	  if "`coltotals'"~="" {
      if (`totalstart') {
        local totalstart 0
        putdocx table `memory'(`=`nrows'+`ncolvars'*2+1',`=2*`nrowvars'')= ("Row Total")
        putdocx table `memory'(`=1+`ncolvars'*2-1',`=`ncols'+2*`nrowvars'+1')= ("Row Total")
      }
	    if "`nrows'"=="`rowline'" {
        qui su freq if `ifcellcol'
        local txttot =`r(sum)'
        putdocx table `memory'(`=`rowline'+`ncolvars'*2+1',`=`colline'+2*`nrowvars'')= ("`txttot'"), `format'		
      }
	    if "`ncols'"=="`colline'" {
        if (trim("`ifcellrow'")=="") qui su freq 
        else qui su freq if `ifcellrow'
        local txttot =`r(sum)'
        putdocx table `memory'(`=`rowline'+`ncolvars'*2',`=`colline'+2*`nrowvars'+1')= ("`txttot'"), `format'
      }
    }
*/
	   
	  putdocx table `memory'(`=`rowline'+`ncolvars'*2+1',`=`colline'+2')= ("`txt'"), `format'
	  if "`column'"~="" {
      putdocx table `memory'(`=`rowline'+`ncolvars'*2+1',`=`colline'+2'), linebreak
      putdocx table `memory'(`=`rowline'+`ncolvars'*2+1',`=`colline'+2')= ("`txtcol'%"), `format' append
	  }
    if "`row'"~="" {
      putdocx table `memory'(`=`rowline'+`ncolvars'*2+1',`=`colline'+2'), linebreak
      putdocx table `memory'(`=`rowline'+`ncolvars'*2+1',`=`colline'+2')= ("`txtrow'%"), `format' append
	  }
  }

  /* 
   * Put row totals text in table  
   */
  if "`rowtotals'"~="" {
    forv rr =  1/`nrows' { 
      local left "`rr'"
      local nr 1
      local found 0
      foreach rvar of varlist `rows' {
        if `left'>`nrowlevs`nr'' {
          local left = `left'-`nrowlevs`nr''
          local nr= `nr'+1
        }
        else {
          if (!`found') {
            local found 1
            local rrvar "`rvar'"
          }
        }
      }
      local chk : word `left' of `rowlevs`nr''         
      cap confirm str variable `rrvar'
      if (!_rc)  ifrowcell  `" `rrvar'=="`chk'" "'
      else local ifrowcell  `" `rrvar'==`chk' "'
      qui su `freq' if `ifrowcell'
      local txttot =`r(sum)'
      putdocx table `memory'(`=`rr'+`ncolvars'*2',`=`ntabcols'+2+1')= ("`txttot'"), `format'		
    }
  }

}

   
/*******************************************************************************
 *
 * Code for Frequency TABLES minimum is 2 by 2 but can be any dimension
 *
 *******************************************************************************/

else if strpos(`"`rows'"',",")==0 & strpos(`"`cols'"',",")==0 {
  /* need to identify that last variable */
  if "`rowtotals'"~="" {
    local nr 1
    foreach var of varlist `rows' {
      local lastrowvar "`var'"
      local `nr++'
    }
    if "`--nr'"=="1" {
      di "{err} You can not specify row totals with a single row variable use totals"
      exit(198)
    }
  }
  /* error check*/
  if "`adjacentcolumns'"~="" {
    di "{err} WARNING adjacentcolumns cannot be specified for a frequency table yet"
  }
  if "`adjacentrows'"~="" {
    di "{err} WARNING adjacentrows cannot be specified for a frequency table yet"
  }
   
  /* The start code is setting up the macros and dimensions of the table */
  qui sort `rows' `cols'
  tempname freq
  by `rows' `cols': gen `freq'=_N
  qui by `rows' `cols': keep if _n== _N
  /* Work out dimnesions of the table first*/
  local ntabrows 1
  local ntabcols 1
  local nrowvars 0
  local ncolvars 0
  
  local nr 1
  local nc 1
  foreach var of varlist `rows' {
     if (length("`var'")>=31) { /* long variable names are a problem*/
        di "{err} Variable `var' has >30 characters, this needs to be shorten to a maximum 30 characters"
        exit(198)
      }
    local `var'l: variable label `var'
    local `var'v: value label `var'
    if "`userowlabels'"=="" {
      qui levelsof `var', `missing'
      local nrowlevs`nr' "`r(r)'" 
      local rowlevs`nr' "`r(levels)'"
      if "`rowtotals'"~="" & "`var'"=="`lastrowvar'" {
        local ntabrows = `ntabrows'*(`r(r)'+1)
        local nrowlevs`nr' = `r(r)'+1
      }
      else local ntabrows = `ntabrows'*`r(r)'
      local `nr++'
      local nrowvars = `nrowvars'+1
    }
    else {
      qui _labelvector `var'
      local nrowlevs`nr' "`r(r)'" 
      local rowlevs`nr' "`r(values)'"
      if "`rowtotals'"~="" & "`var'"=="`lastrowvar'" {
        local ntabrows = `ntabrows'*(`r(r)'+1)
        local nrowlevs`nr' = `r(r)'+1
      }
      else local ntabrows = `ntabrows'*`r(r)'
      local `nr++'
      local nrowvars = `nrowvars'+1
    }
  }
  foreach var of varlist `cols' {
     if (length("`var'")>=31) { /* long variable names are a problem*/
        di "{err} Variable `var' has >30 characters, this needs to be shorten to a maximum 30 characters"
        exit(198)
      }

    if "`usecollabels'"=="" {
      qui levelsof `var', `missing'
      local ncollevs`nc' "`r(r)'"
      local collevs`nc++' "`r(levels)'"
      local ntabcols = `ntabcols'*`r(r)'
      local ncolvars = `ncolvars'+1
    }
    else {
      qui _labelvector `var'
      local ncollevs`nc' "`r(r)'" 
      local collevs`nc++' "`r(values)'"
      local ntabcols = `ntabcols'*`r(r)'
      local ncolvars = `ncolvars'+1
    }
    local `var'l: variable label `var'
    local `var'v: value label `var'
  }
  /* Add an extra row and column for totals */
  if "`totals'"~="" {
    putdocx table `memory' = (`=`ntabrows'+`ncolvars'*2+1', `=`ntabcols'+2*`nrowvars'+1'), border(start, nil)  border(end, nil) layout(autofitwindow) `xtra' `tableoptions' `mtab'
  }
  else {
    putdocx table `memory' = (`=`ntabrows'+`ncolvars'*2', `=`ntabcols'+2*`nrowvars''), border(start, nil)  border(end, nil) layout(autofitwindow) `xtra' `tableoptions' `mtab'
  }
  
  /* Figuring out the spacing of the variable labels */
  local nc 1
  foreach var of varlist `cols' {
    /* get the variable label if it exists*/
    local varlab: variable label `var'	 
    if "`varlab'"~=""  putdocx table `memory'(`=2*`nc'-1',`=`nrowvars'*2+1')= ("`varlab'") , colspan(`ntabcols') `format'
    else {
      putdocx table `memory'(`=`nc'*2-1',`=`nrowvars'*2+1')= ("`var'") , colspan(`ntabcols') `format'
    }
    local colspan 1
    local nrepeats 1
    if `nc'>1 {
      forv i=1/`=`nc'-1' {
        local nrepeats = `nrepeats'*`ncollevs`i''
      }
    }
    if `nc'<`ncolvars' {
      forv i =`=`nc'+1'/`ncolvars' {
        local colspan = `colspan'*`ncollevs`i''
      }
    }
    local coli 1
    forv i=1/`nrepeats' {
      foreach lev in `collevs`nc'' {
        if "``var'v'"~="" local txtlab: label ``var'v' `lev'
        else local txtlab ""
        if "`txtlab'"=="" {
          /* get the display format of the variable *might be a date*/
          local vardispformat: format `var'
          putdocx table `memory'(`=2*`nc'',`=`coli'+`nrowvars'*2')= ("`lev'"), colspan(`colspan') `format' nformat(`vardispformat')
        }
        else putdocx table `memory'(`=2*`nc'',`=`coli'+`nrowvars'*2')= ("`txtlab'") , colspan(`colspan') `format'		
        local coli = `coli'+1	 
      }
    }
    local nc= `nc'+1
  }
  /* Do the row set up of table  */
  local nr 1
  foreach var of varlist `rows' {
    /* get the variable label if it exists*/
    local varlab: variable label `var'	 
    if "`varlab'"~=""  putdocx table `memory'(`=`ncolvars'*2+1', `=2*`nr'-1')= ("`varlab'"), rowspan(`=`ntabrows'') `format'
    else putdocx table `memory'(`=`ncolvars'*2+1',`=2*`nr'-1')= ("`var'") , rowspan(`=`ntabrows'') `format'
    local rowspan 1
    local nrepeats 1
    if `nr'>1 {
      forv i=1/`=`nr'-1' {
        local nrepeats = `nrepeats'*`nrowlevs`i''
      }
    }
    if `nr'<`nrowvars' {
      forv i =`=`nr'+1'/`nrowvars' {
        local rowspan = `rowspan'*`nrowlevs`i''
      }
    }

    local rowi 1
    forv i=1/`nrepeats' {
      foreach lev in `rowlevs`nr'' {
        if "``var'v'"~="" local txtlab: label ``var'v' `lev'
        else local txtlab=""
        if "`txtlab'"=="" {
          /* capture the displayformat*/
          local vardispformat:format `var'
          putdocx table `memory'(`=`rowi'+`ncolvars'*2',`=2*`nr'')= ("`lev'") , rowspan(`rowspan') `format' nformat(`vardispformat')
        }
        else putdocx table `memory'(`=`rowi'+`ncolvars'*2',`=2*`nr'')= ("`txtlab'") , rowspan(`rowspan') `format'		
        local rowi = `rowi'+`rowspan'	 
      }
      if "`var'"=="`lastrowvar'" {
        putdocx table `memory'(`=`rowi'+`ncolvars'*2',`=2*`nr'')= ("Row total")
        local rowi = `rowi'+1
      }
    }
    local nr= `nr'+1
  }

/* Work out the number of cells */
   local ncells 1
   local nrows 1
   local ncols 1
   forv nr = 1/`nrowvars' {
     local nrows = `nrows'*`nrowlevs`nr''
     local ncells = `ncells'*`nrowlevs`nr''
   }
   forv nc = 1/`ncolvars' {
      local ncells = `ncells'*`ncollevs`nc''
	  local ncols = `ncols'*`ncollevs`nc''
   }
   
   /* generate an if statement to do the frequency calculation per row/col */
   local tot_rowline 1
   forv i=0/`=`ncells'-1' {
      /* use mod to get if statement */
	  local ifcell ""

	  /* work out the row line  
	  rowline1 contains the level of the first row var
	  rowline2 contains the level of the second row var etc..
	  */
	  local nr 1 /* numbered row variable */
	  local rowline 1  /* I think this is the rowline of the table */
	  local left "`i'"  /* left has the cell number */
	  foreach rvar of varlist `rows' {
	    local cond = mod(`left',`nrowlevs`nr'')  /* we know total nrowlevs */
		local chk : word `=`cond'+1' of `rowlevs`nr''
		local rowline`nr' = `cond'+1
        if `"`chk'"'~="" {
          cap confirm str variable `rvar'
		  if (!_rc)  ifcell  `"`ifcell' `rvar'=="`chk'" &"'
		  else local ifcell  `"`ifcell'  `rvar'==`chk' &"'
		}
		local left = (`left' - mod(`left',`nrowlevs`nr''))/`nrowlevs`nr''
		local `nr++'
	  }
	  local ifcellrow =substr(`"`ifcell'"', 1, length(`"`ifcell'"')-1 )
	  
      forv nr = `nrowvars'(-1)1 {
        if `nr' == `nrowvars' {
		  local rowline = `rowline`nr''
		  local rowblock = `nrowlevs`nr''
		}
		else {
		  local rowline = `rowline'+(`rowline`nr''-1)*`rowblock'
		  local rowblock = `rowblock'*`nrowlevs`nr''
		}
      }
	  
	  local ifcellcol ""
	  /* work out which column by looping over the column variables */
	  local nc 1
	  foreach cvar of varlist `cols' {
	    local cond = mod(`left',`ncollevs`nc'')
        local colline`nc' = `cond'+1
		local chk : word `=`cond'+1' of `collevs`nc''
		if `nc'~=`ncolvars'  {
		  cap confirm string variable `cvar'
		  if (!_rc) {
		    local ifcell `"`ifcell' `cvar'=="`chk'" &"'
		    local ifcellcol `"`ifcellcol' `cvar'=="`chk'" &"'
		  }
		  else {
		    local ifcell `"`ifcell' `cvar'==`chk' &"'
		    local ifcellcol `"`ifcellcol' `cvar'==`chk' &"'
		  }
		}
		else {
          cap confirm string variable `cvar'
		  if (!_rc) {
		    local ifcell `"`ifcell' `cvar'=="`chk'" "'
		    local ifcellcol `"`ifcellcol' `cvar'=="`chk'" "'
		  }
		  else {
		    local ifcell `"`ifcell' `cvar'==`chk' "'
		    local ifcellcol `"`ifcellcol' `cvar'==`chk' "'
		  }
		}
		local left = (`left' - mod(`left',`ncollevs`nc''))/`ncollevs`nc''
		local `nc++'
	  }
	  
      /* works out the position in the table */
      forv nc = `ncolvars'(-1)1 {
        if `nc' == `ncolvars' {
		  local colline = `colline`nc''
		  local colblock = `ncollevs`nc''
		}
		else {
		  local colline = `colline'+(`colline`nc''-1)*`colblock'
		  local colblock = `colblock'*`ncollevs`nc''
		}
      }
	  

	  qui su `freq' if `ifcell'
	  local txt "`r(sum)'"
	  qui su `freq' if `ifcellrow'
	  if `txt'==0 local txtrow "0"
	  else local txtrow: di %5.2f 100*`txt'/`r(sum)'
	  qui su `freq' if `ifcellcol'
	  if `txt'==0 local txtcol "0"
	  else local txtcol :di %5.2f 100*`txt'/`r(sum)'
	  
	  /* Put total text in table and then calculate row and column totals */
	  local totalstart 1
	  if "`totals'"~="" {
        if (`totalstart') {
		  local totalstart 0
		  putdocx table `memory'(`=`nrows'+`ncolvars'*2+1',`=2*`nrowvars'')= ("Total")
		  putdocx table `memory'(`=1+`ncolvars'*2-1',`=`ncols'+2*`nrowvars'+1')= ("Total")
		}
	    if "`nrows'"=="`rowline'" {
		  qui su `freq' if `ifcellcol'
		  local txttot =`r(sum)'
		  putdocx table `memory'(`=`rowline'+`ncolvars'*2+1',`=`colline'+2*`nrowvars'')= ("`txttot'"), `format'
		
		}
	    if "`ncols'"=="`colline'" {
          qui su `freq' if `ifcellrow'
		  local txttot =`r(sum)'
		  putdocx table `memory'(`=`rowline'+`ncolvars'*2',`=`colline'+2*`nrowvars'+1')= ("`txttot'"), `format'
		}
	  }
	  
//	 di "AT cell(`rowline',`colline') if cell `ifcell'"  
	  putdocx table `memory'(`=`rowline'+`ncolvars'*2',`=`colline'+2*`nrowvars'')= ("`txt'"), `format'
	  if "`column'"~="" {
        putdocx table `memory'(`=`rowline'+`ncolvars'*2',`=`colline'+2*`nrowvars''), linebreak
        putdocx table `memory'(`=`rowline'+`ncolvars'*2',`=`colline'+2*`nrowvars'')= ("`txtcol'%"), `format' append
	  }
      if "`row'"~="" {
        putdocx table `memory'(`=`rowline'+`ncolvars'*2',`=`colline'+2*`nrowvars''), linebreak
        putdocx table `memory'(`=`rowline'+`ncolvars'*2',`=`colline'+2*`nrowvars'')= ("`txtrow'%"), `format' append
	  }
   }

   }

/**********************************************************************
 *
 * Handle the summary statistics table with ADJACENT columns
 *                                          --------
 **********************************************************************/
 /* First handle the rows if there is a comma that is the collapsing variable */
 else if strpos(`"`rows'"',",")~=0 & "`adjacentcolumns'"~="" { 
   /* This code just checks out how many column variables there are */
   local ncolvars 0
   local colvars ""
   local rowvars ""
   local rowvarsstat "" 
   local nc 1
   foreach var of varlist `cols' {
     local colvars "`colvars' `var'"
     local `ncolvars++'
     local `var'vallab:value label `var' /* capture the value labs */
     qui levelsof `var', `missing'
     local ncollevs`nc' "`r(r)'"
     local collevs`nc++' "`r(levels)'"
   }

 /******************************************************************************
  * Next form a variable list included in the vertical axis of the table and 
  *  put in macros r1, r2,... 
  *  tokenize rows(age, mean %5.2f| age, count | sex_n, count) into 
  * 1  age, mean %5.2f
  * 2 age, count
  *
  * need a row format   in macro rfmt1, rfmt2..
  ******************************************************************************/
  tokenize `"`rows'"', parse("|")   
  local i 1
  while "`1'"~="" {
    if "`1'"=="|" mac shift
    local r`i' "`1'"
    local i = `i'+1
    mac shift
  }
  local nrows  = `i'-1
  local nrowvars `nrows'
  forv i=1/`=`nrows'' {
    /* Now figure out the collapse statement per variable and statistic specified */
    /*  next we need to strip out the format in case  age, mean %5.2f */
    tokenize "`r`i''", parse(",")
    local chk:word count `3'
    if `chk'>1 {
      local rfmt`i':word 2 of `3'
      local stat: word 1 of `3'
    }
    else local stat "`3'"
	 
    /* Adjacent columns has to loop the next bit */
    qui save `data',replace
    local rowvarlab:variable label `1'
    local rowvars "`rowvars' `1'"
    local rowvarsstat "`rowvarsstat' `stat'"
	 
    local first 1
    foreach coli of local cols { /* Need to check if coli has missing values and then delete them */
      use `data',replace
      qui drop if `coli'==.  /* missing in columns is handled this way otherwise collapse allows missing in by()*/
      collapse (`stat') `1', by(`coli')
      if "``1'`stat''"=="" tempname `1'`stat'
      rename `1' ``1'`stat''
      qui gen `1'=.
      lab var `1' `"`rowvarlab'"' 
      if `first++'==1 qui save temptemp,replace
      else {
        qui append using temptemp
        qui save temptemp,replace
      }
    }
    sort `cols'
    qui save temptemp,replace
    if `i'==1 qui save temp,replace
    if `i'~=1 {
      qui merge `cols' using temp
      qui drop _merge
      sort `cols'
      qui save temp,replace
    }
    qui use `data'
  /* NOW do the overall statistics */
//di "overall `overall'"
    if "`overall'"~="" {
      collapse (`stat') `1'
      rename `1' ``1'`stat''
      qui gen `1'=.
      lab var `1' `"`rowvarlab'"' 
      qui append using temptemp
      sort `cols'
      qui save temptemp,replace
      qui merge `cols' using temp
      qui drop _merge
      sort `cols'
      qui save temp,replace
      qui use `data'
    }

  }
  qui use temp,replace  
   /* Now loop the columns to give better table header
     if there are 2 column variables take second one and collapse cells and label
     last row will be overall if it is there
   */
  
   qui d  /* need this to get the macrocs!!!*/
   local ntabcols = `r(N)'+2
   local ntabrows = `nrowvars'+2
   di "Table dimension `ntabrows' `ntabcols'"
   putdocx table `memory' = (`ntabrows', `ntabcols'), border(start, nil)  border(end, nil) layout(autofitwindow) `xtra' `tableoptions' `mtab'
	
 /***   First deal with the header part of the table ******/
   //di "no tab cols = `ntabcols'"
  local tabline 1
  local nc 1
  local colline 3
  foreach var of varlist `colvars' {

     /* get the variable label if it exists*/
    local varlab: variable label `var'	 
    if "`varlab'"~=""  putdocx table `memory'(`tabline',`colline')= ("`varlab'") , colspan(`=`ncollevs`nc''') `format'
    else putdocx table `memory'(`tabline',`colline++')= ("`var'") , colspan(`=`ncollevs`nc''') `format'
  }
  local `tabline++'
  local colline 3
  local nc 1
  foreach var of varlist `colvars' {
    /* Now table the values of the variable above */
    forv nci = 1/`ncollevs`nc'' {
      local txt: word `nci' of `collevs`nc''
      if "``var'vallab'"~="" local txtlab: label ``var'vallab' `txt'
      else local txtlab=""
      if "`txtlab'"=="" putdocx table `memory'(`tabline',`colline')= ("`txt'") ,  `format'
      else putdocx table `memory'(`tabline',`colline')= ("`txtlab'") ,  `format'
      local `colline++'
    }
    local `nc++'
  }
  /* Write overall if there is this column */
  if "`overall'"~="" {
    putdocx table `memory'(`tabline',`colline')= ("Overall") 
  }
  local `tabline++'
  
/******************************
 *  Then the body of the table 
 ******************************/
   forv i=1/`nrowvars' {
     local var: word `i' of `rowvars'
     local stat:word `i' of `rowvarsstat'
      local varlab: variable label `var'
      /* Now check how far in front is the rowspan */
      local rowspan "`i'"
      local nxvar:word `=`rowspan'+1' of `rowvars'
      while ("`nxvar'"=="`var'") & (`rowspan'<`nrowvars') {
        local rowspan =`rowspan'+1
        local nxvar: word `=`rowspan'+1' of `rowvars'
      }
	/* Now place the row variables(name) in first column with right amount of span*/
      if `i'>1 {
        local lastvar: word `=`i'-1' of `rowvars'
        if ("`lastvar'"~="`var'") {
          if "`varlab'"=="" putdocx table `memory'(`tabline',1)=("`var'"), rowspan(`=`rowspan'-`i'+1') `format'
          else putdocx table `memory'(`tabline',1)=("`varlab'"), rowspan(`=`rowspan'-`i'+1') `format'
        }
      }
      else {
        if "`varlab'"=="" putdocx table `memory'(`tabline',1)=("`var'"), rowspan(`=`rowspan'-`i'+1') `format'
        else putdocx table `memory'(`tabline',1)=("`varlab'"), rowspan(`=`rowspan'-`i'+1') `format'
      }
	
      /* just alter the stat from count to N */
      if "`stat'"=="count" putdocx table `memory'(`tabline',2)=("N"), `format'
      else putdocx table `memory'(`tabline',2)=("`stat'"), `format'
      forv j=1/`=_N' {
        local txt = ``var'`stat''[`j']
        if "`rfmt`i''"~="" local txt:di `rfmt`i'' ``var'`stat''[`j']
        putdocx table `memory'(`tabline',`=2+`j'')= ("`txt'") , `format'
      }
      local `tabline++'
    }
}

/*******************************************************************************
 *
 * Handle the summary statistics table with NESTED columns
 *                                          ------
 *******************************************************************************/
/* First handle the rows if there is a comma that is the collapsing variable */
  else if strpos(`"`rows'"',",")~=0 {
    /* This code just checks out how many column variables there are */
    local ncolvars 0
    local colvars ""
    foreach vv of varlist `cols' { /* expanding the varlist*/
     if (length("`vv'")>=31) { /* long variable names are a problem*/
        di "{err} Variable `var' has >30 characters, this needs to be shorten to a maximum 30 characters"
        exit(198)
      }
      local colvars "`colvars' `vv'" /* col var list */
      local `vv'l:variable label `vv' /* capture the variable label of cols */
      local `vv'v:value label `vv' /* capture the value labs of cols */
//di "VALUE LAB `vv' ``vv'vallab'"
      local `ncolvars++'
    }

    /* initialise row variable information*/
    local rowvars ""
    local rowvarsstat ""

 /*-----------------------------------------------------------------------------
  * next form a variable list included in the vertical axis of the table and 
  * put in macros r1, r2,... 
  *  tokenize rows(age, mean %5.2f| age, count | sex_n, count) into 
  *  1  age, mean %5.2f
  *  2 age, count
  *
  * need a row format   in macro rfmt1, rfmt2..
  *----------------------------------------------------------------------------*/
    tokenize `"`rows'"', parse("|")   
    local i 1
    while "`1'"~="" {
      if "`1'"=="|" mac shift
      local r`i++' "`1'"
      mac shift
    }
   
    local nrows  = `i'-1 /* need this later and needs to be expanded if BYs are used..*/
    local nrowvars = `nrows'
    forv i=1/`=`nrows'' {
//di "Start `i'"
 
     /* Now figure out the collapse statement per variable and statistic specified */
      //di `" {err}  tokenize "`r`i''", parse(",") "'
	 
      /* First check if by() is in there and delete that part first 
      byvar contains the name byyes is 1 if it needs to be by */

      /* If there is a by variable then I need the levels and values */
      if ("`rowsby'"~="") {
     if (length("`rowsby'")>=31) { /* long variable names are a problem*/
        di "{err} Variable `var' has >30 characters, this needs to be shorten to a maximum 30 characters"
        exit(198)
      }
 
        local `rowsby'v: value label `rowsby' /* capture the value labs */
        local `rowsby'l: variable label `rowsby' /* capture the variable labs */
        qui levelsof `rowsby', `missing'
        local nrowsbylevs "`r(r)'"
        local rowsbylevs "`r(levels)'"
        if "`missing'"=="" qui drop if `rowsby'==.
      }
//di "rowsby `nrowsbylevs' levels `rowsbylevs'"

      /*  next we need to strip out the format in case  age, mean %5.2f */
      tokenize "`r`i''", parse(",")
      local chk:word count `3'
      if `chk'>1 {
        local rfmt`i':word 2 of `3'
        local stat: word 1 of `3'
      }
      else local stat "`3'"
	 
      qui save `data',replace
      local rowvarlab: variable label `1' /* Don't need value labels as this is not on same scale*/
      qui collapse (`stat') `1', by(`rowsby' `cols' )   /* this is the collapse statement */
      local rowvars "`rowvars' `1'"
      local rowvarsstat "`rowvarsstat' `stat'"
      if "``1'`stat''"=="" tempname `1'`stat'
      rename `1' ``1'`stat''
      qui gen `1'=.
      qui lab var `1' `"`rowvarlab'"'  /* Need to keep the original variable label */
 
	// qui gen `1'`3' = "`3'"
//di "{res}NOW"
     /* save the results in temp sorted by the columns */
      sort `rowsby' `cols'
      if `i'==1 qui save temp,replace
      else {
        qui merge `rowsby' `cols' using temp
        qui drop _merge
        sort `rowsby' `cols'
        qui save temp,replace
      }
      qui use `data'
      if "`overall'"~="" {
        if "`rowsby'"=="" {
          local rowvarlab:variable label `1'
          qui collapse (`stat') `1'
          rename `1' ``1'`stat''
          qui gen `1'=.
          qui lab var `1' `"`rowvarlab'"'  /* Need to keep the original label*/
          foreach v in `rowsby' `cols' {
            qui gen `v'=.
            qui lab var `v' `"``v'v'"'
            qui lab values `v' ``v'v'
          }
          sort `rowsby' `cols'
          merge `rowsby' `cols' using temp
          qui drop _merge
          sort `rowsby' `cols'
          qui save temp,replace
        }
        qui use `data'
      }
    }
    qui use temp,replace

   /* Now loop the columns to give better table header
     if there are 2 column variables take second one and collapse cells and label
   */

    qui d /* need this to get the macrocs!!!*/
    if ("`rowsby'"=="") {
      local ntabcols = `r(N)'+2
      local ntabrows = `nrowvars'+`ncolvars'*2
      di "{txt}Table dimensions {res}`ntabrows' `ntabcols'"
      putdocx table `memory' = (`ntabrows', `ntabcols'), border(start, nil)  border(end, nil) layout(autofitwindow) `xtra' `tableoptions' `mtab'
    }
    else {
      local ntabcols = `r(N)'/`nrowsbylevs'+3
      local ntabrows = `nrowvars'*`nrowsbylevs'+`ncolvars'*2	  
      di "{txt}Table dimension `ntabrows' `ntabcols'"
      putdocx table `memory' = (`ntabrows', `ntabcols'), border(start, nil)  border(end, nil) layout(autofitwindow) `xtra' `tableoptions' `mtab'
    }
	
 /****  First deal with the columns header part of the table ****/

    if "`overall'"~="" local ntabcols = `ntabcols'-1

    local tabline 1   
    foreach var of varlist `colvars' {
//di "`var' value ``var'vallab' variable label ``var'varlab'"
      /* get the variable label if it exists*/
      local varlab "``var'l'"
      if "`rowsby'"=="" {
        if "`varlab'"~=""  putdocx table `memory'(`tabline',3)= ("`varlab'") , colspan(`=`ntabcols'-2') `format'
        else putdocx table `memory'(`tabline',3)= ("`var'") , colspan(`=`ntabcols'-2') `format'
      }
      else {
        if "`varlab'"~=""  putdocx table `memory'(`tabline',4)= ("`varlab'") , colspan(`=`ntabcols'-3') `format'
        else putdocx table `memory'(`tabline',4)= ("`var'") , colspan(`=`ntabcols'-3') `format'
      }
      local `tabline++'
    /* Now handle the contents of the column variable and set up the column values but need colspans... */
      local colspan 1
      if ("`rowsby'"=="") local coli 3
      else local coli 4
      local end 0
      forv i=1/`=_N' {
        if(!`end') {
        if (`var'[`=`i'+1']==`var'[`i']) & (`i'<`=_N') {
          local colspan = `colspan'+1
        }
        else {
          local txt = `var'[`i']
          if "``var'v'"~="" local txtlab: label ``var'v' `txt'
//di "txtlab. `txtlab' |txt|`txt'"
          else local txtlab=""
          if "`txt'"~="." {
            if "`txtlab'"=="" putdocx table `memory'(`tabline',`coli')= ("`txt'") , colspan(`colspan') `format'
            else putdocx table `memory'(`tabline',`coli')= ("`txtlab'") , colspan(`colspan') `format'
          }
          local colspan 1
          local coli =`coli'+1
        } 
        if ("`rowsby'"~="" ) {
          if (`rowsby'[`=`i'+1']~=`rowsby'[`i']) {
            local end 1
          }
        }
      }
    }
    local `tabline++'  
  }
  if "`overall'"~="" {
    local `tabline--'
    putdocx table `memory'(`tabline++',`--coli')= ("Overall")
  }
 
/* Then the body of the table note everything is further subdivided by rowsby or NOT */
  forv i=1/`nrowvars' {
    local var: word `i' of `rowvars'     /* the row variable name*/
    local stat:word `i' of `rowvarsstat' /* the stat */
    local varlab: variable label `var'   /* Get the variable label */
    /* Now check how far in front is the rowspan */
    local rowspan `i' /* this is the cumulative line number */
    local nxvar:word `=`rowspan'+1' of `rowvars'
    while ("`nxvar'"=="`var'") & (`rowspan'<`nrowvars') {
      local rowspan =`rowspan'+1
      local nxvar: word `=`rowspan'+1' of `rowvars'
    }
    /* now need to modify the span the number of levels in byrows */
    if "`rowsby'"~="" {
      local rowspan = (`rowspan'-`i'+1)*`nrowsbylevs'
    }
    else {
      local rowspan = `rowspan'-`i'+1
    }
	
    /* Now place the row variables(name) in first column with right amount of span*/
    if `i'>1 {
      local lastvar: word `=`i'-1' of `rowvars'
      if ("`lastvar'"~="`var'") {
        if "`varlab'"=="" putdocx table `memory'(`tabline',1)=("`var'"), rowspan(`rowspan') `format'
        else putdocx table `memory'(`tabline',1)=("`varlab'"), rowspan(`rowspan') `format'
      }
    }
    else {
      if "`varlab'"=="" putdocx table `memory'(`tabline',1)=("`var'"), rowspan(`rowspan') `format'
	    else putdocx table `memory'(`tabline',1)=("`varlab'"), rowspan(`rowspan') `format'
    }
	
    /* just alter the stat from count to N  and print the statistic text adding extra col for rowsby */
    if "`rowsby'"~="" {
      if "`stat'"=="count" putdocx table `memory'(`tabline',2)=("N"), rowspan(`nrowsbylevs') `format'
      else if "`stat'"=="mean" putdocx table `memory'(`tabline',2)=("Mean"), rowspan(`nrowsbylevs') `format'
      else putdocx table `memory'(`tabline',2)=("`stat'"), rowspan(`nrowsbylevs') `format'
    }
    else {
      if "`stat'"=="count" putdocx table `memory'(`tabline',2)=("N"), `format'
      else if "`stat'"=="mean" putdocx table `memory'(`tabline',2)=("Mean"), `format'
      else putdocx table `memory'(`tabline',2)=("`stat'"), `format'	
    }
    /* If there is a rowsby variable then add the column header and values */
    if "`rowsby'"~="" {
      local rowsbylab: variable label `rowsby' /* Get the variable label */
      if "`rowsbylab'"=="" putdocx table `memory'(`=`ncolvars'*2', 3)=("`rowsby'"), `format'
      else putdocx table `memory'(`=`ncolvars'*2', 3)=("`rowsbylab'"), `format'
      forv j=1/`nrowsbylevs' {
        local lev: word `j' of `rowsbylevs'
        if "``rowsby'v'"~="" {
		    local txtlab: label ``rowsby'v' `lev'  
        putdocx table `memory'(`=`tabline'+`j'-1',3)=("`txtlab'"), `format'
      }
		  else putdocx table `memory'(`=`tabline'+1+`j'',3)=("`lev'"), `format'   
    }
	}
	
	/**** These are the cell entries ****/
	forv j=1/`=_N' {
	  if "`rowsby'"=="" {
      local txt = ``var'`stat''[`j']
	    if "`rfmt`i''"~="" local txt:di `rfmt`i'' ``var'`stat''[`j']
        putdocx table `memory'(`tabline',`=2+`j'')= ("`txt'") , `format'
      }
      else { /* need to split the line printing by adding a line each level of rowsby var*/
        local txt = ``var'`stat''[`j']
        if "`rfmt`i''"~="" local txt:di `rfmt`i'' ``var'`stat''[`j']
        local cline = mod(`=`j'-1',`=_N/`nrowsbylevs'')+1
        local rowline = (`j'-mod(`=`j'-1',`=_N/`nrowsbylevs'')-1)/ `=_N/`nrowsbylevs''
        putdocx table `memory'(`=`tabline'+`rowline'',`=2+`cline'+1')= ("`txt'") , `format'
      }
    }
    if "`rowsby'" ~="" local tabline = `tabline'+`nrowsbylevs'
    else local tabline = `tabline'+1
  }
}

/* The stats parts are along the horizontal */
else if strpos(`"`cols'"',",")~=0 { 
  di "{err} This command is not finished and you can't have columns as the statistics and rows as the by variable yet"
  exit(198)
}

/*******************************************
 * Deleting lines of the table
 *******************************************/

 qui putdocx describe `memory'
 local lastrownumber "`r(nrows)'"
if `droplast'>0 {
  forv i=1/`droplast' {
    putdocx table `memory'(`lastrownumber--',.), drop
  }
}
if `dropfirst'>0 {
  forv i=1/`dropfirst' {
    putdocx table `memory'(1,.), drop
  }
}

if "`memory'"=="whole" {
  if "`replace'"~="" {
    putdocx save "`file'",replace
  }
  else {
    cap putdocx save "`file'",append  /* if it doesn't exist then just save it*/
    if _rc==601 putdocx save "`file'"
  }
}

cap putdocx describe tab1
if _rc==0 putdocx describe tab1
cap putdocx describe tab2
if _rc==0 putdocx describe tab2

if "`jointables'"~="" {

  local i 1
  local j 1
  putdocx table all=(2,1)
  foreach word in `jointables' {
    putdocx table all(`i',`j') = table(`word')
	local i = `i'+1
   
  }
  
    putdocx table all2=(26,9)/*
	forv i=1/26 {
	 forv j=1/9 {
	   putdocx table all2(`i',`j') = table(tab1(`i',`j'))
	 
	 }
	}*/
	
    putdocx table all2(1(1)14,1(1)9) = table(tab2)
 //   putdocx table all2(1,1) = table(tab1) span(3,3)

  if "`replace'"~="" {
    putdocx save "`file'",replace
  }
  else {
    cap putdocx save "`file'",append  /* if it doesn't exist then just save it*/
    if _rc==601 putdocx save "`file'"
  }
 
}

restore
end

/*************************************************************************
 * Program to extract the vector of values from a variables value list
 *************************************************************************/
program def _labelvector, rclass
  syntax varlist(min=1 max=1)
  local lab: value label `varlist'
  tempfile labfile
  label save `lab' using `"`labfile'"'
  local `lab'values ""
  tempname fh
  file open `fh' using `"`labfile'"', text read
  file read `fh' line
  local i 0
  while r(eof)==0 {
    local `i++'
    gettoken word    line : line // label
    gettoken word    line : line // define
    gettoken labname line : line
    gettoken value   line : line
    gettoken ltext   line : line, parse(", ") match(paren)
    local `lab'values "``lab'values' `value'"
    file read `fh' line
  }
  file close `fh'
  return local values "``lab'values'"
  return local r = `i'
end

*! outtable 1.0.8  CF Baum and JP Azevedo 03aug2014
*! outtable    cfb 3612  for Petia
* 1.0.1: 1714 rev for table->caption, add table env
* key option removed; not interacting properly with SciWord
* 1.0.2: 1C26 add option norowlab
* 1.0.3: 2227 problem with non-symmetric being claimed as symmetric (Ben Kriechel)
* 1.0.4: 3612 above problem removed by using issym() from Stata v8
* 1.0.5: 4130 braces removed from single-line if statements
* 1.0.6: 5606 Azevedo additions: longtable, clabel(string), label options
* 1.0.7: 8420 CFB allow multiple-column formats a la mat2txt
* 1.0.8: D803 CFB allow nodots option to suppress numeric missing values
*
program define outtable,rclass
version 8.0
syntax using/, mat(string) [Replace APPend noBOX Center ASIS CAPtion(string) Format(string) noROWlab noDOTS longtable clabel(string) label]
tempname hh dd ddd

local formatn: word count `format'
local nr=rowsof(`mat')
local nc=colsof(`mat')

if "`clabel'"=="" {
    local labelc "clabel"
}
else {
    local labelc  "`clabel'"
}

if "`replace'" == "replace" local opt "replace"
if "`append'" == "append" local opt "append"
file open `hh' using "`using'.tex", write `opt'
file write `hh' "% matrix: `mat' file: `using'.tex  $S_DATE $S_TIME" _n
* add h to prefer here

local nc1 = `nc'-1
if "`box'" ~= "nobox" {
    local vb "|"
    local hl "\hline"
    }
else {
    local hg "\hline"
}

local align "l"
if "`center'" == "center" local align "c"
local l "`vb'l"
forv i=1/`nc' {
    local l "`l'`vb'`align'"
    }

local symm 0
if (issym(`mat')) {
    local symm 1
    }
local rnames : rownames(`mat')
local cnames : colnames(`mat')
local l "`l'`vb'"


if "`longtable'"=="" {
    file write `hh' "\begin{table}[htbp]" _n
    if "`caption'" ~= "" {
        file write `hh' "\caption{\label{`labelc'} `caption'}\centering\medskip" _n
        }
    file write `hh' "\begin{tabular}{`l'}"  "`hl' `hg' `hg'" _n
    forv i=1/`nc' {
        local cn : word `i' of `cnames'
        local cnw = cond("`asis'"=="asis","`cn'",subinstr("`cn'","_"," ",.))

        if `i'==1 & "`rowlab'" == "norowlab" {
            file write `hh' " \multicolumn{1}{c}{ `cnw' } "
        }
        else {
            file write `hh' " & `cnw' "
        }
    }
    file write `hh' " \" "\ `hl' `hg' " _n
}

if "`longtable'"!="" {
    file write `hh' "\begin{center}" _n
    file write `hh' "\begin{longtable}{`l'}" _n
    if "`caption'" != "" {
        file write `hh' "\caption{\label{`labelc'} `caption'}\\\" _n
        }
    forv i=1/`nc' {
        local cn : word `i' of `cnames'
        local cnw = cond("`asis'"=="asis","`cn'",subinstr("`cn'","_"," ",.))
        local nc2 = `nc'+1
        if `i'==1 & "`rowlab'" == "norowlab" {
            local mainheader1 " \multicolumn{1}{c}{ `cnw' } "
            local nc2 = `nc'
        }
        else {
            local mainheader1 " \multicolumn{1}{c}{Variable Names} "
            local mainheader2 "`mainheader2' & `cnw' "
        }
        local mainheader "`mainheader1' `mainheader2'"
    }
    file write `hh'            "\hline  " _n
    file write `hh'            "\hline  " _n
    file write `hh'            "`mainheader' \\\" _n
    file write `hh'            "\hline " _n
    file write `hh'            " \endfirsthead" _n
    file write `hh'            "\multicolumn{`nc2'}{l}{\emph{... table \thetable{} continued}} \\\" _n
    file write `hh'            "\hline \hline " _n
    file write `hh'            "`mainheader' \\\" _n

    file write `hh'            "\hline" _n
    file write `hh'            "\endhead" _n
    file write `hh'            "\hline" _n
    file write `hh'            "\multicolumn{`nc2'}{r}{\emph{Continued on next page...}}\\\" _n
    file write `hh'            "\endfoot" _n
    file write `hh'            "\endlastfoot" _n
}





local jlim `nc1'
local klim `nc'
forv i=1/`nr' {
    local rn : word `i' of `rnames'

    if "`label'"!="" & "`rn'" != "r1" {
        local rn : variable label  `rn'
    }

    local rnw = cond("`asis'"=="asis","`rn'",subinstr("`rn'","_"," ",.))
    if "`rowlab'" ~= "norowlab" file write `hh' "`rnw' & "
    if `symm'==1 {
        local jlim = `i'-1
        local klim = `i'
        }
    forv j=1/`jlim' {
    	local fmt
    	if "`format'"!="" {
                if `formatn'>1 local fmt: word `j' of `format'
                else local fmt "`format'"
		}
		if "`dots'" ~= "nodots" { 
			file write `hh' `fmt' (`mat'[`i',`j']) " & "
		} 
		else {
			if mi(`mat'[`i',`j']) {
				file write `hh'  " & "
			}
			else {
				file write `hh' `fmt' (`mat'[`i',`j']) " & "
			}
		}
		}
    if "`format'"!="" {
    	if `formatn'>1 local fmt: word `nc' of `format'
        else local fmt "`format'"
	}
	if "`dots'" ~= "nodots" { 
			file write `hh' `fmt' (`mat'[`i',`klim']) 
		} 
	else {
		if !mi(`mat'[`i',`klim']) {
			file write `hh' `fmt' (`mat'[`i',`klim']) 
		}
	}
	file write `hh' " \" "\ `hl' " _n
    }
*if "`key'" ~= "" {
*   file write `hh' "\label{`key'}" _n
*   }
if "`longtable'"=="" {
    file write `hh' "`hg' `hg' \end{tabular}" _n
    file write `hh' "\end{table}" _n
    file close `hh'
}
if "`longtable'"!="" {
    file write `hh' "`hg' `hg' \end{longtable} " _n
    file write `hh' "\end{center}" _n
    file close `hh'
}


end

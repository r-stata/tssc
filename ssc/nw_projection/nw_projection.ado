*! Date        : 05/04/2020
*! Version     : 1.1
*! Author      : Charlie Joyez, Université Côte d'Azur
*! Email	   : charlie.joyez@univ-cotedazur.fr

capture program drop nw_projection
program nw_projection, rclass
	version 9
	syntax 	[, x(string) y(string) Sequence(string) NSequence(string) OUTput(string) NETname(string) BINary NORMalize SELFloops]	

foreach v in nid cnode freq_node  _noid {
capture drop `v' 
}

keep `x' `y' `sequence'

	
quietly{
	if missing(`x'){
        display as err "x() is missing"
        exit 198
    }

	if missing(`y') {
        display as err "y() is missing"
        exit 198
	}	
	
	if "`y'"=="`x'" {
        display as err "y() and x() cannot be the same variable."
        exit 198
	}	

	if "`nsequence'" != "" & "`sequence'"==""{
        noi display as err "sequence() must be specified with NSequence()"
        exit 198
    }
	
	if "`nsequence'" == "" & "`sequence'"!=""{
        noi display  "Option nsequence() not specified. All previous linkages considered"
    }

	if "`output'" != "edgelist" & "`output'" != "matrix" & "`output'" != ""{
		noi di as error "output() incorrectely specified. Set to matrix"
    }
	
}
	
set more off

quietly{	
egen cnode=group(`x')
drop if cnode==.
bysort cnode : gen freq_node = _N
tab cnode
local nnode = r(r)



bysort `y' : gen nid=_N
su nid
local nbid=r(max)

noi di "progress:"		


if `"`sequence'"'==""{ 
	sort `y' `x'
		quie forvalues i= 1/`nnode' { 
		  noi di " `i'/`nnode'... " _cont
		  gen `x'_`i'=0 
	   quie forvalues j=1/`nbid' {
		   bysort `y' : replace `x'_`i'=1 if cnode[`j']==`i'
		}
		if "`selfloop'" != "true" {
   		replace `x'_`i'=0 if cnode==`i' /*removing self loops*/
		}
	}
}

if `"`sequence'"'!=""{ 

 if `"`nsequence'"'==""{ 
  sort `y' `sequence' `x'
  forvalues i= 1/`nnode' { 
	noi di " `i'/`nnode'... " _cont
		gen `x'_`i'=0
		quie  forvalues j=1/`nbid' {
			bysort `y' : replace `x'_`i'=1 if cnode[`j']==`i' & `sequence'<=`sequence'[`j']
   }
   if "`selfloop'" != "true" {
   		replace `x'_`i'=0 if cnode==`i' /*removing self loops*/
	}
  }
 }
  
 if `"`nsequence'"'!=""{
	local k="`nsequence'"
	sort `y' `sequence' `x' 
	forvalues i= 1/`nnode' { 
	  noi di " `i'/`nnode'... " _cont
		gen `x'_`i'=0
		quie  forvalues j=1/`nbid' {
			bysort `y' : replace `x'_`i'=1 if cnode[`j']==`i' & `sequence'<=`sequence'[`j'] & `sequence'>=`sequence'[`j']-`k' 
   }
   		   if "`selfloop'" != "true" {
   		replace `x'_`i'=0 if cnode==`i' /*removing self loops*/
		}

  }
 }

}


	
sort cnode `y'
duplicates drop `y' cnode `x'_*, force
	
forvalues i= 1/`nnode' {
bysort cnode : replace `x'_`i'=sum(`x'_`i')
di "`binary'"
if "`binary'" != "" {	
	replace `x'_`i'=1 if `x'_`i'>0 & `x'_`i'!=.

	}

}
 
by cnode : keep if _n==_N


sort `x' `y'
if "`normalize'" == ""{

if "`sequence'" == "" {			
nwset `x'_* , undirected name(`netname') labs(`x')   
}
if "`sequence'" != "" {	
nwset `x'_* , directed name(`netname') labs(`x')   
}
}

if "`normalize'" != ""{
mkmat `x'_* ,matrix(stmat)
mata M=st_matrix("stmat")
mata maxM=max(M)

mata st_local("maxM", strofreal(maxM))



forvalues i= 1/`nnode' {
replace `x'_`i'=`x'_`i'/`maxM'
}

if "`sequence'" == ""  {			
nwset `x'_* , undirected name(`netname') labs(`x')   
}
else {	

nwset `x'_* , directed name(`netname') labs(`x')   
}
}

tostring `x',replace
order `x'  `x'_*
forvalues i= 1/`nnode' {
local p=`x'[`i']
 
rename `x'_`i'  _`p'
}


drop nid cnode freq_node  `y' 
capture drop `sequence'
capture drop _noid

}

noi di" "
noi di "Projection into `x' space generated"
nwsummarize `netname'
nwtomata `netname', mat(M_proj)
mata st_matrix("M_proj",M_proj)

quietly{
	if "`output'" == "edgelist"{ 
	nwtoedge `netname', fromvar(`x') tovar(`x') 
	capture rename network weight
	capture rename `netname' weight
	keep from to weight
	order from to weight
	drop if weight==0
	browse
	}
}

return matrix M_proj=M_proj


end



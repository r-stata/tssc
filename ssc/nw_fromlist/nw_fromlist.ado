*! Date        : 12/06/2017
*! Version     : 1.0.0
*! Author      : Charlie Joyez, Paris-Dauphine University
*! Email	   : charlie.joyez@dauphine.fr

capture program drop nw_fromlist
program nw_fromlist, rclass
	version 9
	syntax [anything(name=netname)]	[, node(string) id(string) DIRection(string) BINary NORMalize SELFloops]	

foreach v in nid cnode freq_node  _noid {
capture drop `v' 
}

keep `node' `id' `direction'

	qui di "1"

quietly{
	    if missing(`node'){
			qui di "1a"
        display as err "node() is missing"
        exit 198
    }
	


if "`id'" == "" {
noi di "id() is missing: no idinviduals considered"
gen _noid=1
local id = "_noid"
}
	
	qui di "1b"
set more off

	qui di "2"

egen cnode=group(`node')
drop if cnode==.
bysort cnode : gen freq_node = _N
qui tab cnode
local nnode = r(r)

	qui di "3"


bysort `id' : gen nid=_N
qui su nid
local nbid=r(max)
sort `id' `node'


	qui di "4"
	
	qui di "`binary'"
	
forvalues i= 1/`nnode' { 
 gen `node'_`i'=0
 
    forvalues j=1/`nbid' {
       bysort `id' : replace `node'_`i'=1 if cnode[`j']==`i'
    
	}
 if "`direction'" !=  "" {
  sort `id' `node' 
      forvalues j=1/`nbid' {
      replace `node'_`i'=0 if cnode[`j']==`i' & `direction'>`direction'[`j']
di "nbid:" `nbid'
di "i:" `i'
di "j :" `j'
   }
  }


	if "`selfloop'" != "true" {
	replace `node'_`i'=0 if cnode==`i' /*removing self loops*/
}

}


	qui di "5"
sort cnode `id'
duplicates drop `id' cnode `node'_*, force
	qui di "6"
	
forvalues i= 1/`nnode' {
bysort cnode : replace `node'_`i'=sum(`node'_`i')
qui di "`binary'"
if "`binary'" != "" {	
	replace `node'_`i'=1 if `node'_`i'>0 & `node'_`i'!=.

	}

}
 
qui di "7"
by cnode : keep if _n==_N



sort `node' `id'
	qui di "8"
if "`normalize'" == ""{
qui di "non normalized"
if "`direction'" == "" {			
nwset `node'_* , undirected name(`netname') labs(`node')   
}
if "`direction'" != "" {	
qui di "55"		
nwset `node'_* , directed name(`netname') labs(`node')   
}
}


qui di "12"

if "`normalize'" != ""{
qui di "normalized"
mkmat var2_* ,matrix(stmat)
mata M=st_matrix("stmat")
mata maxM=max(M)
noi mata maxM
qui di "13"
mata st_local("maxM", strofreal(maxM))

forvalues i= 1/`nnode' {
replace `node'_`i'=`node'_`i'/`maxM'
}
if "`direction'" == "" {			
nwset `node'_* , undirected name(`netname') labs(`node')   
}
if "`direction'" != "" {	
qui di "55"		
nwset `node'_* , directed name(`netname') labs(`node')   
}
}

tostring `node',replace
order `node'  `node'_*
forvalues i= 1/`nnode' {
local p=`node'[`i']
 
rename `node'_`i'  _`p'
}


drop nid cnode freq_node  `id' 
capture drop `direction'
capture drop _noid
nwsummarize
nwtomata `netname', mat(M)
	qui di "9"
return scalar nb_node=`nnode'
	qui di "10"
return scalar nb_id=`nbid'	
	qui di "11"	

qui mata M
}
 
bro

end



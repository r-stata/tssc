*!  usepackage.ado -- Stata module to download and install user packages necessary to run a do-file
*!  Eric A. Booth  <ebooth@tamu.edu>
*!  v 1.0.0   3 May 2011

program define usepackage
syntax anything [, Update NEARest ]
version 9.2
loc _i = 0 
if `"`update'"' == "update" loc _or "or updating"
di in yellow as smcl `"Installing `_or' missing packages..."'
foreach _f in `anything' {
di as smcl in white `"[`++_i'] "' in green `"`_f': "'
**update: uninstall/reinstall/update package
if `"`update'"' != "" {
qui cap ado uninstall `pg'
loc _opts  "replace force"
}

**check to see if exists:
qui cap which `_f'

**does exist:
if !_rc  {
	if  `"`update'"' == "" {
	di in yellow as smcl `"   Package {help `_f'}{it: already installed}"'
	continue
		}
	if `"`update'"' == "update" {
	qui cap ssc install `_f', replace
		if !_rc {
		di in yellow as smcl `"   Updating already installed package {help `_f'} ..."'
		ssc install `_f', replace all
		continue
		}
	  }
	}



**doesnt exist, first try SSC:	
qui cap which `_f'
if _rc {
	qui cap ssc install `_f', replace
	if !_rc {
	di in yellow as smcl `"   Package {stata ado describe `_f': `_f'} installed from SSC"'
	continue
	   }
   }	
	
**if doesnt exist, but not at SSC,  see if exists under package name:
qui cap which `_f'
if _rc qui ado describe `_f'
	if !_rc {
	di in yellow as smcl `"   Package {stata ado describe `_f': `_f'}{it: already installed}"'
	continue
	}
	
**if not install, try ssc install first:
qui cap which `_f'
if _rc qui cap ssc install `_f', replace
if !_rc {
	di in yellow as smcl `"   Package {stata ado describe `_f': `_f'} installed from SSC"'
	continue
	}
	
**not on SSC and not installed**
qui cap which `_f'
if _rc == 111 {
tempfile _searchpackages`_f'
qui cap log close searchpackages
qui log using "`_searchpackages`_f''", text replace name(searchpackages)
di in yellow as smcl `"{bf: net search} matches for `_f' (if any):  "'
net search `_f'
qui log close searchpackages

preserve
qui insheet using "`_searchpackages`_f''", clear nonames
	**find row with pattern <pkg> from <site>
	qui g __i  = .
	qui replace __i = 1 if strpos(v1, "`_f' from ")  //best match
	qui g __flag = 1 if strpos(v1, "`_f':")
	qui replace __i = 1 if strpos(v1, " from ") & mi(__i) & __flag[_n+1] == 1  //match if pkgname in descr
	if `"`nearest'"' == "nearest" qui replace __i = 1 if strpos(v1, " from ") & mi(__i) //match any package in descr.
	qui g __i1 = _n  if __i==1
	qui keep if !mi(__i1)
	qui cap drop __i __i1 
	qui cap drop __flag
	**check for obs:
	if _N == 0 {
		di `"  "'
		di in red `"  No exact match for package `_f' found at SSC nor via a {bf: net search} -- try specifying {bf: nearest} option"'
		di `"  "'
		continue
		}
	qui split v1
	loc pg `=v11[1]'
	loc fm `=v13[1]'
restore

**install st pg from fm
qui cap ssc install `pg', replace
		di `"  "'
if !_rc di in yellow as smcl `"   Package {help `pg'} installed from SSC"'
		di `"  "'
if _rc {
qui cap net install `pg', all `_opts' from(`fm')
	di `"  "'
if _rc di in red `"   No match for package `_f' found at SSC nor `fm' -- try specifying {bf: nearest} option"'
if !_rc di in yellow as smcl `"   Package {bf:`pg'} (`_f') installed from {stata "net describe `pg', from(`fm')": `fm'}"'
	di `"  "'
	}
} // pkg not installed and not at SSC
} // _f loop
*di in yellow `"Done"'
end


/*
**EXAMPLES**

// Setup //
**Make sure user packages statplot and bacon are uninstalled

    . cap ado uninstall statplot
    . cap ado uninstall st0197 //uninstall package bacon

**Specify that usepackage is installed from SSC

    . cap ssc install usepackage
        
// Install a list of user packages from various internet locations //
    . usepackage estout dropmiss rtfutil ralpha mac_unab

// Install missing package statplot (from SSC) //
    . usepackage statplot

// Install missing package bacon (aka package st0197) (from Stata Journal) // 
    . usepackage bacon
    . usepackage st0197,
    
// Install and Update packages, including near-matches, from various locations //
    . usepackage tabou dropmis num2word, near update
 
    . usepackage rtfutil, updat nearest
*/


*! Program to calculate distance-based variables and export the distances to a text file
*! Author: P. Wlner Jeanty
*! 1.0.0 June 6, 2008: Born
*! 1.0.1 October 2008: Option for a neighbor count in a ring added
*! 1.0.2 January 2009: Options for incremental distance calculation added
*! 1.0.3 June 2009: 
*! Statistics can now be calculated for neighbors falling in a ring, nearest neighbors, and all neighbors
*! Options to export distance matrix to a tab delimited file and to calculated distance weighted statistics added
*! 1.0.4 December 2009: Option to export distance matrix in sparse form to a file added
*! 1.0.5 March 2010: Option iidist added
*! 1.0.6 December 2010: Mata file updated
*! 1.0.7 November 2011: Option minmaxd added
program define nearstat, rclass
	version 10.1
	syntax varlist(min=2 max=2 numeric) [if] [in], near(varlist min=2 max=2 numeric) DISTvar(str) ///
		 [kth(integer 1) nid(namelist min=2 max=2) cart r(str) CONTVar(varlist numeric) ///
		 STATVar(namelist) STATName(str) INCdist(str) atpop(numlist min=1 max=1 >0) knn(str) ///
		 DName(str) NCount(str) DBand(numlist min=2 max=2 >=0 sort) ALLnei alpha(str) ///
		 EXPDist(str) expto(str) SPArse(str) NOZero des(str) replace favor(str) iidist(str) MINMaxd(namelist min=2 max=2)]
	mata: mata clear
	capture scalar drop nearstat_*
	marksample touse
	if "`favor'"!="" & !inlist("`favor'", "space", "speed") {
		di as err " Option favor(`favor') not allowed"
		exit 198
	}
	if `:word count `r' `cart''==2 {
		di
		di as err " Options {bf:cart} and {bf:r()} may not be combined"
		exit 198
	}
	* Checking the coordinates
	gettoken lat1 long1: varlist
	gettoken lat2 long2: near 
	if "`cart'"=="" {
		foreach crd in `lat1' `lat2' {
			quietly count if `crd'<. & abs(`crd')>90 
			if `r(N)'>0  { 
				di as err "Spherical latitudes must be in [-90,90]"
				exit 198
			}
		}
		foreach crd in `long1' `long2' {
			quietly count if `crd'<. & abs(`crd')>180 
			if `r(N)'>0  { 
				di as err "Spherical longitudes must be in [-180,180]"
				exit 198
			}
		}
		if "`r'"=="" local rad= 6371.009 /* Calculcated as rad=(2*a+b)/3
 		with a=6,356.752 km (Polar radius) b=6,378.137 km (Equatorial radius) */
		else local rad=`r'		
	}
	else if `lat1'<0 | `lat2'<0 | `long1'<0 | `long2'<0  {
		di
		di as err " Cartesian coordinates must be positive"
		exit 198
	}
	if "`expto'"!="" & "`expdist'"=="" {
		di as err "Option {bf:expto()} not allowed without {bf:expdist()}"
		exit 198
	}
	if "`nozero'"!="" & "`sparse'"=="" {
		di as err "{bf:nozero} allowed only when {bf:sparse()} is specified.
		exit 198
	}
	local wform=0
	local matform "" 
	if "`expdist'"!="" {
		if `:word count `expto' `sparse''!=1 {
			di as err "One and only one of {bf:expto()} and {bf:sparse()} is required"
			exit 198
		}		
		if "`expto'"!="" {
			if !inlist("`expto'", "Stata", "Mata", "tab", "csv") {
				di as err "Option {bf:expto()} takes one of {it:Stata}, {it:Mata}, {it:csv}, and {it:tab}"
				exit 198
			}
			local matform `expto'
			local wform=1
		}
		else if "`sparse'"!="" {
			if !inlist("`sparse'", "Mata", "tab", "csv") {
				di as err "Option {bf:sparse()} takes one of {it:Mata}, {it:csv}, and {it:tab}"
				exit 198
			}
			local matform `sparse'
			mata: nearstat_zero="`nozero'"
			local wform=2
		}    
		if "`matform'"=="csv" local expdist `expdist'.csv
		if inlist("`matform'", "tab", "Mata", "csv") {
			cap confirm new file `expdist'
			if _rc & "`replace'"!="" erase `expdist'
			else if _rc & "`replace'"=="" confirm new file `expdist'
		}
		mata: nearstat_expto="`matform'"
		mata: nearstat_wform=`wform'
	}   
	if "`incdist'`atpop'"!="" & "`statvar'"!="" {
		di
		di as err "Options {bf:incdist()} and {bf:atpop()} may not be combined with {bf:statvar()}
		exit 198
	}
	local stcont1=0
	if "`contvar'"!="" & ("`statvar'"!="" | "`incdist'"!="") {
		confirm var `contvar'
		if "`statvar'"!="" {		
			if `: word count `contvar''!= `:word count `statvar'' {
				di
				di as err " Options {bf:contvar()} and {bf:statvar()} must have the same number of elements"
				exit 198
			}
		}
		local stcont1=1
	}
	if "`contvar'"=="" & ("`incdist'"!="" | "`atpop'"!="")  {
		di 
		di as err ///
		"Option {bf:contvar()} must be specified when either {bf:incdist()} or {bf:atpop()} is specified"
		exit 198
	}
	if `: word count `incdist' `atpop''==1 {
		di 
		di as err "Options {bf:incdist()} and {bf:atpop()} must be combined"
		exit 198
	}
	local inc=0
	if "`incdist'"!="" & "`atpop'"!="" {
		Confnewvar `incdist' `replace'
		local inc=1
		mata: nearstat_Pop=`atpop'
	}
	mata: nearstat_Inc=`inc'
	if "`statname'"=="" & "`knn'`allneigh'"!="" {
		di
		di as err "{bf:knn(#)} or {bf:allneigh} not allowed when {bf:statname()} is not specified"
		exit 198
	}
	local Alfa=-1 
	local neigh=0
	if "`statname'"!="" {
		if !inlist(`"`statname'"', "mean", "min", "max", "std", "sum") {
			di
			di as err " Option {bf:statname()} accepts either mean, min, max, std, or sum"
			exit 198
		}
		if  "`statvar'"=="" &  "`contvar'"=="" {
			di
			di as err ///
			" Options {bf:contvar()} and {bf:statvar()} must be specified when option {bf:statname()} is specified"
			exit 198
		}
		local checknei :word count `knn' `dband' `allnei'
		if inlist(`checknei', 0, 4) {
			di
			di as err "One or at most two of {bf:knn()}, {bf:dband()}, and {bf:allnei} required with {bf:statname()}"
			exit 198
		}	
		if `:word count `knn' `allnei''==2 {
			di
			di as err "One of {bf:knn()} and {bf:allnei} may be specified"
			exit 198
		}	
		if `:word count `dband' `allnei''==3 local neigh=1
		else if `:word count `dband' `knn''==3 local neigh=2
		else if "`dband'"!="" local neigh=3
		else if "`knn'"!="" local neigh=4		
		else if "`allnei'"!="" local neigh=5
		if inlist(`neigh', 2, 4) {
			local nk2=real("`knn'")
			if `nk2'<2 {
				di
				di as err " The value provided for option {bf:knn(#)} must be greater than or equal to 2"
				exit 198
			}
		}
		if inlist(`neigh', 1, 2, 3) {
			tokenize `dband'
			args band1 band2
		}
		if "`statvar'"!="" & "`contvar'"!=""  local stcont1=2
		if "`alpha'"=="" local Alfa=0
		else local Alfa=real("`alpha'")		
	}
	mata: nearstat_Alfa=`Alfa'
	mata: nearstat_neigh=`neigh'
	local wnnc `dname' `ncount'
	if "`wnnc'"!="" {
		if "`dband'"=="" {
			di
			di as err ///
			" Option {bf:dband()} required when {bf:dname()} or {bf:ncount()} specified"
			exit 198
		}
		else {
			tokenize `dband'
			args band1 band2
		}
		foreach x of local wnnc {
			Confnewvar `x' `replace'
		}
	}
	if inlist(`neigh', 1, 2) & "`wnnc'"=="" {
		di
		di as err "You must specify either {bf:dname()} or {bf:ncount()}"
		exit 198
	}
* Checking missing values for the Near features and the variables in contvar() 
	if inlist(`stcont1', 1, 2) {		
		mata: nearstat_compcoord("`near'", "`contvar'")
		if scalar(obsnear)!=scalar(val_obscont) {
			di
			di as err ///
			" Variables listed in {bf:contvar()} must have the same number of valid observations as those listed in {bf:near()}" 
			exit 198
		}
	}
	if `stcont1'==2 & "`knn'"!="" {
		if `nk2' > scalar(obsnear) { // Another message in Mata takes care of situation where input=near
			di
			di as err ///
			" Values provided for {bf:knn(#)} option cannot be larger than the number of valid observations for the Near features"
			exit 198
		}
	}
	qui count if !mi(`lat2') // I can use only one of the coordinates since the program won't work if !mi(`lat2')!=!mi(long2)
      if `kth'>r(N) { // if input=near then kth should be <= r(N)-1
		di
		di as err " The order for the nearest neighbor cannot be greater than the number of near features"
		exit 198
	}
	if "`alpha'"!="" & "`statname'"=="" {
		di 
		di as err ///
		"Option {bf:alpha()} may be specified only when {bf:statname()} is specified"
		exit 198
	}
	Confnewvar `distvar' `replace'
	if "`iidist'"!="" Confnewvar `iidist' `replace'
	if "`nid'"!="" {
		gettoken neid1 neid2: nid
		confirm var `neid1'  // Assuming that the first element specified is the id variable
		local idtype `:type `neid1'' 
		Confnewvar `neid2' `replace' // Assuming that the second element is the name for the id of the nearest neighbor
		local chkid=0
		if substr("`idtype'",1,3) == "str" local chkid=1
		if `chkid'==0 qui gen `idtype' `neid2'=.
		else qui gen `idtype' `neid2'=""
	} 	
	if "`statvar'"!="" {
		foreach elt of local statvar {
			Confnewvar `elt' `replace'
		}
	}
	if "`des'"!="" {
		tokenize "`des'", parse(",")
		local basix "`1'"
		local kuart "`3'"
		if "`basix'"!="stat" {
			di
			di as err ///
			"Option {bf:des()} takes only {bf:stat} as an option and {bf:quart} as a suboption"
			exit 198
		}
		if "`kuart'"!="" & "`kuart'"!="quart" {
			di
			di as err "Option {bf:des()} takes only {bf:quart} as a suboption"
			exit 198
		}
	}
	local tominmax=0
	if "`minmaxd'"!="" {
		gettoken mmname mmtype: minmaxd
		local minmaxtype `mmtype'
		if !inlist("`minmaxtype'", "min", "max") {
			di as err "Option {bf:minmaxd()} takes either {bf:min} or {bf:max} as sub-option"
			exit 198
		}	
		Confnewvar `mmname' `replace' // The first element must be the name of the variable to hold min or max distance
		local tominmax=1
	}	
	mata: nearstat_minmax=`tominmax'
	if "`favor'"=="" & c(matafavor)=="space" mata: mata set matafavor speed
	if "`favor'"=="speed" & c(matafavor)=="space" mata: mata set matafavor speed
	if "`favor'"=="space" & c(matafavor)=="speed" mata: mata set matafavor space 
	mata: nearstat_calcdist("`varlist'", "`touse'", "`near'")

** Now create report
	if "`des'"!="" {
		tempname desta1  nei1  forkth1 
		mat `desta1'=(obs_d, mean_d, std_d, min_d, max_d) 
		qui sum `distvar', detail
		mat `forkth1' =(r(N), r(mean), r(sd), r(min), r(max))
 		mat `desta1'=`desta1' \ `forkth1'
 		if "`kuart'"!="" {
			tempname desta2 nei2 forkth2
			mat `desta2'=(obs_d, Q1_d, Q2_d, Q3_d)
			mat `forkth2' =(r(N), r(p25), r(p50), r(p75))
			mat `desta2'=`desta2' \ `forkth2'
		}
            local rspeci "rspec(--&-)"
		local numnei ""
            if "`ncount'"!="" {
            	qui sum `ncount', detail
                  mat `nei1' =(r(N), r(mean), r(sd), r(min), r(max))
                  mat `desta1'=`desta1' \ `nei1'
			if "`kuart'"!="" {
                  	mat `nei2' =(r(N), r(p25), r(p50), r(p75))
				mat `desta2'=`desta2' \ `nei2'
			}
                  local tit ***: Number of neighbors falling in the distance band: " as res "`band1'<dij<=`band2'
                  local neic `ncount'***
                  local rspeci "rspec(--&&-)"
			local numnei and Number of Neighbors
            }
            if `kth'==1 local fork first
            if `kth'==2 local fork second
            if `kth'==3 local fork third
            if inlist(`kth',1,2,3)==0 local fork `kth'th      
            mat rown `desta1' = distance* `distvar'** `neic'
            mat coln `desta1'  = Obs Mean Std Min Max 
            di
            di as txt "{title: Descriptive Statistics for Distance `numnei'}" 
            matlist `desta1', row(Variable) cspec(|L %16s | %10.0f & %8.2f & %8.2f & %8.2f & %9.2f|) `rspeci'
		if "`kuart'"!="" {
            	mat rown `desta2' = distance* `distvar'** `neic'
            	mat coln `desta2' = Obs Q1 Q2 Q3 
			di
			di as txt "{title: Quartile Distance `numnei' }"
            	matlist `desta2', nob row(Variable) cspec(|L %16s|%10.0f & %8.2f & %8.2f & %8.2f|) `rspeci'
		} 		
		di as txt "*:   Distance between each input feature and all near features"
		di as txt "**:  Distance from each input feature to its " in y "`fork'" as txt " nearest neighbor"
		di as txt "`tit'"
	}	
	if "`cart'"=="" {
		local dunit km
		if "`r'"!="" & "`r'"=="3958.761" local dunit miles
		local forunit (in `dunit') 
	}
	di
	di in y " Distance `forunit' calculations completed successfully and/or all requests processed" 
	if "`cart'"!="" {
		di
		di as txt " NB: The distance unit is the same as that of the projected coordinates"
	}
	if "`expdist'"!="" {
		if "`expto'"!="" {
			if "`expto'" == "tab" local matfile "tab delimited file"
			else if "`expto'"=="Mata" local matfile "Mata file" 
			else if "`expto'"=="csv" local matfile ".csv file"
			else if "`expto'"=="Stata" & scalar(nearstat_ind)==0 local matfile "Stata matrix"
			if inlist("`expto'", "Mata", "csv", "tab") local expdist `c(pwd)'`c(dirsep)'`expdist' 
			di
			di as txt " Also, distance between input and near features exported to the `matfile': " in y "`expdist'" as txt "."
		}
		if "`sparse'"!="" {
			if "`sparse'" == "tab" local matfile "tab delimited file"
			else if "`sparse'"=="Mata" local matfile "Mata file" 
			else if "`sparse'"=="csv" local matfile "csv file"
			if inlist("`sparse'", "Mata", "csv", "tab") local expdist `c(pwd)'`c(dirsep)'`expdist' 
			di
			di as txt " Also, distance between input and near features exported as a sparse matrix to the `matfile': " in y "`expdist'" as txt "."
		}
	}	
	ret sca Obs=obs_d
	ret sca min_dist=min_d
	ret sca Q1_dist=Q1_d
	ret sca mean_dist=mean_d
	ret sca Q2_dist=Q2_d
	ret sca Q3_dist=Q3_d
	ret sca max_dist=max_d
	ret sca n_input=nfeat
	ret sca n_near=nnear
	ret sca nearest_mean=kn_mean
	ret sca nearest_max=kn_max
	ret sca nearest_min=kn_min
	capture scalar drop nearstat_*
	mata: mata clear	
end
prog define Confnewvar
	version 10.1
 	args varname replace
	loc confv confirm new var 
	cap `confv' `varname' 
	if _rc==110 {
		if "`replace'"!=""  drop `varname'
		else {
			di		
 			`confv' `varname'
		}
	} 
end

*! version 1.0.0  09jun2017 
*! Robert Picard    picard@netbox.com
*! Nicholas J. Cox  n.j.cox@durham.ac.uk 
*! requires -rangestat- version 1.1.1 or newer, available from SSC
program define rangerun, sortpreserve sclass

	version 11
	
	sreturn local rangerun_version 1.0.0

	cap rangestat
	if _rc == 199 {
		dis as error "This command requires rangestat (from SSC)."
		dis as error "To install rangestat, click on the link below"
		dis as txt "{stata ssc install rangestat}"
		exit _rc
	}
	else {
		if "`r(rangestat_version)'" < "1.1.1" {		
			dis as error "This command requires the latest version of rangestat (from SSC)."
			dis as error "To update rangestat, click on the link below"
			dis as txt "{stata adoupdate rangestat, update}"
			exit _rc
		}
		dis as txt "  (using rangestat version `r(rangestat_version)')"
		sreturn local rangestat_version `r(rangestat_version)'
	}

	syntax name(name=progname id=program_name) 	///
		[if] [in] 				///
		, 						///
		Interval(string)		///
		[						///
		Use(varlist numeric)	///
		BY(varlist)				///
		Sprefix(string)			///
		Verbose					///
		]


	cap unab curvars : *
	if _rc {
		dis as err "no variables defined"
		exit 111
	}
	
	if "`use'" == "" {
		qui ds, has(type numeric)
		local use `r(varlist)'
	}
	
	gettoken vkey : interval, parse(", ")
	marksample touse
	markout `touse' `vkey'
	qui count if `touse'
	if r(N) == 0 error 2000
	
	// note the initial order of obs, it's used to break ties
	tempvar obs
	gen long `obs' = _n
	
	// the index to observations in range in the touse sample
	sort `touse' `by' `vkey' `obs'	
	qui by `touse': replace `obs' = _n
	tempname obslow obshigh
	rangestat (min) `obslow'=`obs' (max) `obshigh'=`obs' if `touse', ///
		by(`by') interval(`interval')


	mata: rangerun_doit("`progname'", "`use'", "`touse'", "`obslow'", "`obshigh'", "`sprefix'", "`verbose'")
		
	
end


version 11
mata:
mata set matastrict on


void rangerun_doit(

	string scalar pname,	// program name
	string scalar vuse,		// variables to use for data in range
	string scalar touse,
	string scalar ilow,		// index of the first obs in range
	string scalar ihigh,	// index of the last obs in range
	string scalar prefix,	// prefix of scalars populated with values for current obs
	string scalar output	// if "verbose", display execution ouput
)
{
	real matrix	///
		X,			// data in touse sample of vuse variables 
		LH,			// low and high index of observations in range
		Xi,			// observations in range of current observation
		Xres		// results for current obs accumulated here
				
	string rowvector ///
		Vuse,		// variables to use for data in range
		Vres,		// results variable names
		Vpost,		// variables in memory at end of program run
		Vtype		// variable type of Vpost variables
					 
	transmorphic ///
		VresIndex	// associative array to store index of Xres variables
		
	real scalar i, j, rc, k, kres, ioutput
	string scalar v
	
	if (output == "verbose") ioutput = 0
	else ioutput = 1
	
	Vuse = tokens(vuse)
	X = st_data(., Vuse, touse)
	LH = st_data(., (ilow, ihigh), touse)
	
	VresIndex = asarray_create()
	for (j = 1; j <= cols(Vuse); j++) {
		asarray(VresIndex, Vuse[1,j], 0)	// mark out vuse vars
	}
	
	kres = 0
	Xres = J(rows(X),0,.)
	Vres = J(1,0,"")
	Vtype = J(1,0,"")
	
	stata("preserve")
	
	for (i=1; i<=rows(X); i++) {
	
		if (missing(LH[i,1])) continue
		
		stata("drop _all")
		
		Xi = X[|LH[i,1],1 \ LH[i,2],.|]
		st_addobs(rows(Xi), 1)
		st_store(., st_addvar("double", Vuse), Xi)
		
		if (prefix != "") {
			for (j = 1; j <= cols(X); j++) {
				v = prefix + Vuse[j]
				if (st_isname(v)) st_numscalar(v, X[i,j])
			}
		}

		rc = _stata(pname, ioutput)
		
		if (rc == 0 & st_nvar() & st_nobs() > 0) {
			Vpost = st_varname((1..st_nvar()))
			for (j = 1; j <= cols(Vpost); j++) {
				v = Vpost[1,j]
				if (st_isnumvar(v)) {
					if (!asarray_contains(VresIndex, v)) {
						kres = kres + 1
						Xres = (Xres,J(rows(X),1,.))
						asarray(VresIndex,v,kres)
						Vres = (Vres,v)
						Vtype = (Vtype,st_vartype(v))
					}
					k = asarray(VresIndex,v)
					if (k > 0) {
						Xres[i,k] = st_data(st_nobs(), j)
					}
				}
			}
		}
		
	}
		
	stata("restore")

	st_store(., st_addvar(Vtype, Vres), touse, Xres)

}

end

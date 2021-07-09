*! bidensity:  bivariate kernel density estimation
*! version 0.9.0 25jul2012 by John Luke Gallup and Kit Baum (jlgallup@pdx.edu)

program define bidensity, rclass
 
	version 12.1
	syntax varlist(min=2 max=2) [if] [in] [fw aw] [, N(integer 50) ///
		XWidth(real 0.0) YWidth(real 0.0) Saving(string) REPLACE ///
		MName(string) kernel(string) noGRaph SCatter SCAtter1(string) *] 
		// mname specifies name stub for global mata matrices for 
		//	density, xvalues, yvalues

	local k : word count `kernel'
	if `k' == 0 local kernel epanechnikov
	else {
		if `k' > 1 {
			di as err "only one kernel may be specified"
			exit 198
		}
		_kernel_name, kernel(`"`kernel'"')
		local kernel `s(kernel)'
		if `"`kernel'"' == "" {
			di as err "invalid kernel function"
			exit 198
		}
	}

	preserve

	marksample touse
	qui count if `touse'
	if r(N)==0 error 2000
	quietly keep if `touse' 

	if "`weight'" != "" {
		quietly {
			tempvar wvar
			gen double `wvar' `exp'
			if "`weight'" == "aweight" {
				summ `wvar', meanonly
				replace `wvar' = `wvar'/r(mean)
			}
		}
	}

	mata: _BiDensity("`kernel'", "`varlist'", `xwidth',	///
					`ywidth', `n', "`wvar'", 	///
					("`saving'"!="")|("`graph'"==""), "`mname'", "`replace'")
	local newvars "_d _`return(yvar)' _`return(xvar)'"
	if ("`graph'"=="") {
		if ("`scatter'"!="" | `"`scatter1'"'!="") ///
			local scatter `"scatter `varlist', `scatter1' || "'
		if (strpos("`options'", "ylab") == 0) loc options "`options' ylab(,angle(0))"
		twoway `scatter'contourline `newvars' if _d!=.,  `options'
	}
	if ("`saving'"!="") {
		keep `newvars'
		qui keep if !missing(_d)
		save `saving', `replace'
	}
	restore 
end	


// parsing facility to retrieve kernel name (from kdensity.ado)
program _kernel_name, sclass
	syntax , KERNEL(string)
	local kernlist epanechnikov epan2 gaussian triangle rectangle
	// currently unused kernels: biweight cosine parzen
	local maxabbrev 2 3 5 3 3 // # of letters for abbreviation
	tokenize `maxabbrev'
	local i = 1
	foreach kern of local kernlist {
		if substr("`kern'",1,length(`"`kernel'"')) == `"`kernel'"' ///
					     & length(`"`kernel'"') >= ``i'' {
			sreturn local kernel `kern'
			continue, break
		}
		else {
			sreturn local kernel
		}
		local ++i
	}
end

 
version 12.1
mata:

void _BiDensity(string scalar kernel, 	///
					string scalar varlist, 	///
					real scalar xwid, 		///
					real scalar ywid, 		///
					real scalar n, 			///
					string scalar wvar,		///
					real scalar sav_graph,	///
					string scalar mname,		///
					string scalar replace)
{  // calculate bivariate kernel density values (x vs. y)
	//    of dimensions n^2
	yxvar = tokens(varlist)
	st_view(x,.,yxvar[2])
	st_view(y,.,yxvar[1])

	N = st_nobs()  // N is number of observations in data
	if (n>N) { 	 // n is number of bins
		errprintf("warning: n(%f) > no. of observations; n set to %f",n,N)
		n = N
	}
	if (n<=1) n = max((N,50)) 

	// create weight variable
	if (wvar=="") w = 1
	else {
		st_view(w,.,wvar)
		N = sum(w)
	}

	// calculate bandwidths
	if (xwid<=0) xwid = 0.9*min((sqrt(variance(x,w)),mm_iqrange(x,w)/1.349))/(N^0.20)
	if (ywid<=0) ywid = 0.9*min((sqrt(variance(y,w)),mm_iqrange(y,w)/1.349))/(N^0.20)

	// make grid of x & y values (n of each)
	xymin = colmin((x,y))
	xyscale = 1/(n-1)*(colmax((x,y))-xymin+2*(xwid,ywid))
	mxy = J(n,1,xyscale)
	mxy[1,] = (0,0)
	mxy = (runningsum(mxy[,1]),runningsum(mxy[,2]))
	mxy = mxy :+ (xymin-(xwid,ywid))	
	mx = mxy[,1]
	my = mxy[,2]

	wid = xwid*ywid
	d = J(n,n,.)

	if (kernel=="epanechnikov") {
		for (i=1; i<=n; i++) {
			azx = abs((x :- mx[i])/xwid)
			zx2_1 = (1:-azx:^2:/5) :* (azx:<1)
			for (j=1; j<=n; j++) {
				azy = abs((y :- my[j])/ywid)
				k = zx2_1 :* (1:-azy:^2:/5) :* (azy:<1)
				d[j,i] = mean(k,w)
			}
		}
		d = 0.1125/wid*mean(w) :* d  // rescale; 0.1125 = 9/80
	}
	if (kernel=="epan2") {
		for (i=1; i<=n; i++) {
			azx = abs((x :- mx[i])/xwid)
			zx2_1 = 1:-azx:^2 :* (azx:<1)
			for (j=1; j<=n; j++) {
				azy = abs((y :- my[j])/ywid)
				k = zx2_1 :* (1:-azy:^2) :* (azy:<1)
				d[j,i] = mean(k,w)
			}
		}
		d = 0.5625/wid*mean(w) :* d  // rescale; 0.5625 = 9/16
	}
	else if (kernel=="gaussian") {
		for (i=1; i<=n; i++) {
			zx2 = ((x :- mx[i])/xwid):^2
			for (j=1; j<=n; j++) {
				zy2 = ((y :- my[j])/ywid):^2
				k = exp(-0.5 :* (zx2 :+ zy2))
				d[j,i] = mean(k,w)
			}
		}
		d = 1/(2*pi()*wid)*mean(w) :* d  // rescale
	}
	else if (kernel=="triangle") {
		for (i=1; i<=n; i++) {
			azx = abs((x :- mx[i])/xwid)
			zx1 = 1:-azx :* (azx:<1)
			for (j=1; j<=n; j++) {
				azy = abs((y :- my[j])/ywid)
				k = zx1 :* (1:-azy) :* (azy:<1)
				d[j,i] = mean(k,w)
			}
		}
		d = mean(w)/wid :* d  // rescale
	}
	else if (kernel=="rectangle") {
		for (i=1; i<=n; i++) {
			azx = abs((x :- mx[i])/xwid) :< 1
			for (j=1; j<=n; j++) {
				k = azx :* (abs((y :- my[j])/ywid) :< 1)
				d[j,i] = mean(k,w)
			}
		}
		d = 0.25*mean(w)/wid :* d  // rescale
	}
	_editmissing(d,0) // replace any . with 0 in d

	if (sav_graph) {
		ylab = st_varlabel(yxvar[1])
		xlab = st_varlabel(yxvar[2])
		dvecn = n^2  // length of vec(d)
		if (dvecn>N) st_addobs(dvecn-N)
		nvec = J(n,1,1)
		newvars = ("_d","_":+yxvar)
		st_store((1,dvecn), st_addvar("double", newvars), (vec(d),nvec#my,mx#nvec))
		st_varlabel(newvars[2], ylab)
		st_varlabel(newvars[3], xlab)
	}

	st_rclear()
	st_global("return(kernel)", kernel)
	st_global("return(xvar)", yxvar[2])
	st_global("return(yvar)", yxvar[1])
	st_numscalar("return(xwidth)", xwid)
	st_numscalar("return(ywidth)", ywid)
	st_numscalar("return(xscale)", xyscale[,1])
	st_numscalar("return(yscale)", xyscale[,2])
	st_numscalar("return(N)", n)
	if (mname!="") {  // put results in global mata matrics
		mnames = mname:+("_x","_y","_d")
		for (i=1; i<=3; i++) rmexternal(mnames[i])
		*crexternal(mnames[1]) = mx
		*crexternal(mnames[2]) = my
		*crexternal(mnames[3]) = d
	}
}

end // end of mata

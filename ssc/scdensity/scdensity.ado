*! scdensity version 1.0.1 Joerg Luedicke 16January2013 
* new:
* - non-negativity correction 
* - at() option 
* - twoway options 
* - expand option
* scdensity version 1.0.0 Joerg Luedicke 9July2012

cap program drop scdensity
program define scdensity, rclass
	
	version 9.2
	
	syntax varname(numeric) [if] [in] [ , 	///
		n(integer 0) 						///
		Generate(string) 					///
		NOGraph								///
		Range(string) 						///
		EXpand								///
		at(string)							///
		CORrection 							///
		gtd									///
		TOLerance(real 1e-4)				///
		INItial(real 1)						///
		INTERval(real 1) * ]
	
	marksample touse
	
	// Temporary variables
	tempvar den dat
    
	// Checking syntax and requirements
	qui count if `touse'
	if r(N)==0 {
		error 2000
    }
	
	capt mata mata which mm_which()
	if _rc {
		di as error "mm_which() from -moremata- is required; type -ssc install moremata- to obtain it"
		exit 499
	}
	
	local wc : word count `generate'		
	if `wc'>2 {
		di as error "Check generate() option; asking for more than 2 variables not allowed"
		exit 198
	}	
	if "`generate'"!="" {
		local yn: word 1 of `generate'
		local xn: word 2 of `generate'
		confirm new var `yn' `xn'
	}
	
	if "`range'"!="" & "`at'"!="" {
		di as error "Specify either range() or at(), but not both"
		exit 499
	}
	
	if "`at'"!="" & "`correction'"!="" {
		di in red "Warning: " as res "correction unfeasible if at() does not contain a regular grid of points"
	}

	if "`at'"!="" {
		confirm var `at'
                qui sum `at', meanonly
                local xmin=r(min)
                local xmax=r(max)
	}	
	
	local rac : word count `range'
	if `rac'!=0 & `rac'!=2 {
		di as error "Range option not correctly specified"
		exit 499
	}
	if `rac'==2 {
		local minr : word 1 of `range'
		local maxr : word 2 of `range'
		if `minr'>=`maxr' {
			di as error "Check your range() statement; elements out of order"
			exit 124
		}
	}
	
	// Graph options
	_get_gropts , graphopts(`options') gettwoway
		
	// Determining number of evaluation points
	qui cou if `touse'
	loc N=r(N)
	
	if "`at'"=="" {	
		if `n'==0 & r(N)>=1000 {
			loc npoints=1000
		}
		else if `n'==0 & r(N)<1000 {
			loc npoints=r(N)
		}
		else if `n'!=0 & `n'<=r(N) {
			loc npoints=`n'
		}
		else if `n'!=0 & `n'>r(N) {
			loc npoints=r(N)
			di in red "Warning: " as res "Evaluation points set to n = `npoints'" 
		}
	}
	else {
		loc npoints=r(N)
	}
	
	// Calling Mata function
	mata: scden("`varlist'", "`touse'")
	
	// Plot
	loc t1="Self-consistent density estimate"
	
	if "`correction'"!="" { 
		loc t2=", corrected"
	}
	
	local lab : var label `varlist'
	if "`lab'"=="" local lab="`varlist'"
	
	if "`nograph'"==""{
			line `den' `dat', sort 	///
			title("`t1'`t2'") 		///
			xtitle("`lab'")		///
			ytitle("Density")		///
			`s(twowayopts)'
	}
	
	// Saving variable(s)
	if `wc' {
		if `wc'==1 {
			qui gen double `yn'=`den'
			lab var `yn' "Self-consistent density estimate: `varlist'"
		}
		if `wc'==2 {
			qui gen double `yn'=`den'
			qui gen double `xn'=`dat'
			lab var `yn' "Self-consistent density estimate: `varlist'"
			lab var `xn' "Grid points: `varlist'"
		}
	}
	
	// Saved results
	
	// Range
	return scalar range_max=`xmax'
	return scalar range_min=`xmin'
		
	// Number of grid points
	return scalar n_points = `npoints'
	return scalar n_data = `N'
	
end


version 9.0
mata:

void scden(string scalar varname, string scalar touse)
{
	complex colvector ch_est, ch_inf, denest
	real colvector dum, ftsq, indpos, tvec, tvec2, x, xvec
	real scalar nx, dt, dx, i, ndata, nt, nt0, nuse, ok, prop, prop1, prop2, tmax, xwidth, xwidth2, index1, index2
 	string scalar den, dat
		
	st_view(x=., ., varname, touse)
	nx=strtoreal(st_local("npoints"))
	nt0=51  
	nt=1001 
	prop1=0.4
	prop2=0.6
	prop=0.5
	ndata=colnonmissing(x)
	
	if (st_local("at")=="") {	
		xvec=scgrid(x)
	}
	
	else {	
		st_view(at=., ., st_local("at"), touse)
		xvec=at
	}
	
	xmax=max(xvec)
	xmin=min(xvec)
	
	xwidth=xmax-xmin
	tmax=pi()/xwidth
	dt=2*tmax/(nt0-1)
	tvec=range(-tmax, tmax, dt)
	
	ok=0
	while (ok==0) {
		ch_est=rangen(0,0,nt0)
		for (i=1; i<=ndata; i++) {
			ch_est=ch_est+C(cos(tvec*x[i]), sin(tvec*x[i]))
		}
		ch_est=ch_est/ndata
		nuse=sum((abs(ch_est):^2):>(4*(ndata-1)/(ndata^2)))
		if (nuse/nt0>prop1 & nuse/nt0<prop2) ok=1
		else {
			tmax=tmax*(nuse/nt0)/prop
			dt=2*tmax/(nt0-1)
			tvec=range(-tmax,tmax,dt)
		}
	}
	
	dt=2*tmax/(nt-1)
	tvec=range(-tmax,tmax,dt)
	ch_est=rangen(0,0,nt)
	
	for (i=1; i<=ndata; i++) {
		ch_est=ch_est+C(cos(tvec*x[i]), sin(tvec*x[i]))
	}
	ch_est=ch_est/ndata
	indpos=mm_which((abs(ch_est):^2):>(4*(ndata-1)/(ndata^2)))
	dum=(abs(ch_est):^2)*(ndata^2)/2
	ftsq=1:/(dum:-(ndata-1):-sqrt(abs(dum:*(dum:-2*(ndata-1)))))
	ch_inf=ndata:*ch_est[indpos]:/(ndata-1:+1:/ftsq[indpos])
	tvec2=tvec[indpos]
	xwidth2=2*pi()/dt
	
	if (xwidth2<xwidth) {
		xwidth=xwidth2
		dx=xwidth/(nx-1)
		xvec=range((mean(x)-xwidth/2),(mean(x)+xwidth/2),dx)  
	}
	
	denest=rangen(0,0,nx)
	for (i=1; i<=length(tvec2); i++) {
		denest=denest+ch_inf[i]*C(cos(tvec2[i]*xvec), -sin(tvec2[i]*xvec))
	}
	
	denest=Re(denest)*dt/(2*pi())
	
	if (st_local("correction")!="") {
		dx=xwidth/(nx-1)
		denest=sccorr(denest, dx)
	}		
	
	index1=st_addvar("double", den=st_tempname())
	st_store((1,rows(denest)),index1,denest)
	st_local("den",den)
	index2=st_addvar("double", dat=st_tempname())
	st_store((1,rows(xvec)),index2,xvec)
	st_local("dat",dat)
		
}
 
function scgrid(real colvector x) 
{
	nx=strtoreal(st_local("npoints"))
	ran=strtoreal(st_local("rac"))
	if (ran<1) {
	
		xmax=max(x)
		xmin=min(x)
	
		if (st_local("expand")!="") {
			nd=rows(x)
			width=xmax-xmin
			add=(0.5 * (nd^-0.3)) * width
			xmin = xmin - add
			xmax = xmax + add
		}
		
	}
	
	else {
		xmax=strtoreal(st_local("maxr"))
		xmin=strtoreal(st_local("minr"))
	}
	
	dx=(xmax-xmin)/(nx-1)
	grid=range(xmin,xmax,dx)
	st_local("xmin",strofreal(xmin))
	st_local("xmax",strofreal(xmax))
	return(grid)
}		

function sccorr(real colvector x, real scalar dx)
{
		
	tol=strtoreal(st_local("tolerance"))
	
	z=initial(x, dx)
	z0=z
			
	if (st_local("interval")!="" & strtoreal(st_local("interval"))!=1) {
		inter=strtoreal(st_local("interval"))
	}
	
	else {
	
		if (st_local("gtd")!="") {
			inter=z
		}	
		else {
			s=1/tol/100
			inter=z/s
		}
		
	}
		
	if (min(x)<0) {
		fxpos=x:*(x:>0)
		fxdxpos=sum(fxpos)*dx
		e=fxdxpos-1
				
		if (abs(e)<=tol) {
			fpos=fxpos
			printf("{hline 71}\n")
			printf("Density correction: density successfully corrected\n")
			printf("\n")
			printf("f(x)dx = %f\n", sum(fpos)*dx)
			printf("{hline 71}\n")
		}
		
		else if (abs(e)>tol) {
			while (abs(e)>tol) {
				f=x:-z
				fxpos=f:*(f:>0)
				fxdxpos=sum(fxpos)*dx
				e=fxdxpos-1
				
				if (fxdxpos==0) {
					printf("{hline 62}\n")
					printf("Density correction failed: initial xi or interval too large;\n")
					printf("try smaller initial and/or interval values,\n")
					printf("or increase tolerance.\n")
					printf("{hline 62}\n")
					printf("Values:\n")
					printf("\n")
					printf("initial xi = %f\n", z0)
					printf("final xi = %f\n", z)
					printf("\n")
					printf("interval = %f\n", inter)
					printf("tolerance = %f\n", tol)
					printf("{hline 62}\n")
					exit(499)
				}

				if (st_local("gtd")!="") {
					inter=z*(e^2)
				}
				z=z+inter
			}
			
			fpos=f:*(f:>0)
			printf("{hline 51}\n")
			printf("Density correction: density successfully corrected.\n")
			printf("{hline 51}\n")
			printf("Values:\n")
			printf("\n")
			printf("initial xi = %f\n", z0)
			printf("final xi = %f\n", z)
			printf("\n")
			printf("interval = %f\n", inter)
			printf("tolerance = %f\n", tol)
			printf("\n")
			printf("f(x)dx = %f\n", sum(fpos)*dx)
			printf("{hline 51}\n")
			
		}

	}

	else if (min(x)>=0) {
		fpos=x
		printf("{hline 41}\n")
		printf("Density correction: no correction needed,\n")
		printf("density is non-negative.\n")
		printf("{hline 41}\n")
	}

	return(fpos)
}

function initial(real colvector x, real scalar dx)
{

	if (st_local("initial")!="" & strtoreal(st_local("initial"))!=1) {
		z=strtoreal(st_local("initial"))
	}
	
	else {
		nx=sum(x:>0)
		fxpos=x:*(x:>0)
		fxdxpos=sum(fxpos)*dx
		mass=fxdxpos-1
		z=mass/nx/dx
		z=z/10
	}
	
	return(z)

}

end


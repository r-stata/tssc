*! version 1.3 jkc 31oct2014
/*
bipolate provides bivariate interpolation and smooth surface fitting for values given at irregularly distributed points.
Author: 
    Joseph Canner
    Johns Hopkins University School of Medicine
    Department of Surgery
    Center for Surgical Trials and Outcomes Research
	jcanner1@jhmi.edu
Version 1.0.0 May  19, 2014
Version 1.1 September 17, 2014
 adds support for :
 (1) using a variable number of nearest neighbors for computing derivatives (old Akima method)
 (2) using the interpolation methods employed by twoway contour
 (3) varlist ordering consistent with twoway contour and ipolate
Version 1.2 October 20, 2014
 adds support for :
 (1) Thin-plate spline (Green & Silverman)--equivalent to Stata method
 (2) Thin-plate spline plus smoothing
 (3) Shepard--equivalent to Stata method
 (4) New option scheme ("interp" by default, "fill" implied by fillusing, convexhull available for all interp methods)
Version 1.3 October 31, 2014
  adds support for :
 (1) incorporating variability in z (i.e., multiple z values for a given (x,y) pair)
*/
program bipolate
  version 12
  syntax varlist(min=3 max=3 numeric) [if] [in] [using] [, SAVing(string) METHod(string) CONTOURmethod(string) ///
                                                           XGrid(numlist) XLevels(numlist integer >1 min=1 max=1) ///
                                                           YGrid(numlist) YLevels(numlist >1 integer min=1 max=1) ///
														   FILLusing(string) CONVEXhull COLLapse(string) ///
														   KEEPMISSing NEAR(numlist >1 integer min=1 max=1) ///
														   SMOOTH(real 0) REPS(integer 1) SEED(integer -1)]

  preserve
  tokenize `varlist' 
  local z `1'
  local y `2'
  local x `3'
    
  if ("`using'"!="") {
    qui use `using', clear
  }
  
  if ("`if'"!="" | "`in'"!="") {
    qui keep `if' `in'
  }
  
  if ("`near'"!="") { 
    if (`near'<2 | `near'>min(25,`=_N')) {
      di as red "Near must be be at least 2 and no larger than 25 or the number of observations, whichever is less"
      exit
    }
  }
  else {
    local near=-1
  }
  
  if `reps'<1 {
    di as red "Reps must be at least 1"
	exit
  }
  
  // Implied option "mode" (interp or fill)
  local mode "interp"
  if ("`fillusing'"!="") {
    local mode "fill"
  }

  // Determine method
  if ("`method'"=="") {
    local method="akima"   // The default
  }
  else {
    local method=lower("`method'")
  }
  
  // Check for contradictory options
  if ("`contourmethod'"!="" & "`method'"!="contour") {
     di as red "may not use option contourmethod() without method(contour)"
	 exit
  }
  if (("`method'"=="contour" | "`contourmethod'"!="") & ("`xgrid'"!="" | "`ygrid'"!="" | "`xlevels'"!="" | "`ylevels'"!="")) {
     di as red "may not combine options method(contour)/contourmethod() and xgrid()/ygrid()/xlevels()/ylevels()"
	 exit
  }
  if ("`fillusing'"!="" & ("`xgrid'"!="" | "`ygrid'"!="" | "`xlevels'"!="" | "`ylevels'"!="")) {
     di as red "may not combine options xgrid()/ygrid()/xlevels()/ylevels() and fillusing()"
     exit
  }
  if (("`xgrid'"!="" & "`xlevels'"!="") | ("`ygrid'"!="" & "`ylevels'"!="")) {
     di as red "may not combine option xgrid()/ygrid() and xlevels()/ylevels()"
	 exit
  }
  if ("`fillusing'"!="" & "`convexhull'"!="") {
     di as red "Can't specify both fillusing and convexhull"
	 exit
  }
  if `reps'>1 & "`collapse'"!="" {
    di as red "may not combine collapse() with reps()"
	exit
  }
  
  recast double `x' `y' `z'
  
  // If multiple z-values for a given (x,y) pair, choose a method to collapse and get rid of the duplicates (unless reps>1)
  if `reps'==1 {
    local collapse=lower("`collapse'")
    if ("`collapse'"=="") {
      local collapse="mean"
    }
    if ("`collapse'"!="none") {
      collapse (`collapse') `z'_`collapse'=`z', by(`x' `y')
    }
    else {
      rename `z' `z'_none
    }
	
	qui drop if `x'==. | `y'==.
    if ("`keepmissing'"=="") {
      qui drop if `z'_`collapse'==.    
    }
	keep `x' `y' `z'_`collapse'
	
  }
  else {  // do mean and sd
  
    // Need to add a check that ignores reps() if there are no (x,y) pairs with multiple z values
	
    collapse (mean) `z'_mean=`z' (sd) `z'_sd=`z', by(`x' `y')
	
    qui drop if `x'==. | `y'==.
    if ("`keepmissing'"=="") {
      qui drop if `z'_mean==.    
    }
	
    keep `x' `y' `z'_mean `z'_sd
  }
  
  // Calculate xgrid from xlevels
  if ("`xlevels'"!="" & "`mode'"=="interp") {
     qui summ `x'
	 local width=(`r(max)'-`r(min)')/(`xlevels'-1)
	 numlist "`r(min)'(`width')`r(max)'"
	 local xgrid "`r(numlist)'"
	 //di "`xgrid'"
  }
  // Calculate ygrid from ylevels
  if ("`ylevels'"!="" & "`mode'"=="interp") {
     qui summ `y'
	 local width=(`r(max)'-`r(min)')/(`ylevels'-1)
	 numlist "`r(min)'(`width')`r(max)'"
	 local ygrid "`r(numlist)'"
	 //di "`ygrid'"
  }
  
  // Calculate xgrid from data
  if ("`xgrid'"=="" & "`xlevels'"=="" & "`mode'"=="interp") {
    qui levelsof `x', local(xgrid)
  }
  // Calculate ygrid from data
  if ("`ygrid'"=="" & "`ylevels'"=="" & "`mode'"=="interp") {
    qui levelsof `y', local(ygrid)
  }
    
  if ("`convexhull'"!="") {
	 // Use convex hull method to generating a fillusing dataset 
	 // Already used one preserve command, use tempfile to preserve again
	 tempfile preserve 
	 qui save "`preserve'", replace
	 bip_cvxhull `y' `x', noreport nograph

	 qui gen x1=`x'
     qui gen y1=min(_cvxh1l,_cvxh1r)

	 // Keep just the hull vertices
     qui keep if !mi(x1) & !mi(y1)
	 
	 // Find approximate center of hull
	 qui summ x1
	 local xmin=`r(min)'
	 local xmax=`r(max)'
     local cx1=(`xmax'+`xmin')/2
	 qui summ y1
 	 local ymin=`r(min)'
	 local ymax=`r(max)'
     local cy1=(`ymax'+`ymin')/2

	 // Compute angles between center and each point and sort in angle order
     qui gen angle=atan2(y1-`cy1',x1-`cx1')
     sort angle
	 
	 // Find each points' next neighbor
	 qui gen x2=x1[_n+1]
     qui gen y2=y1[_n+1]
	 // Join the last point to the first point
     qui replace x2=x1[1] in l   // l=last
	 qui replace y2=y1[1] in l
	 
     keep x1 x2 y1 y2 angle
	 
	 // For each potential point in the grid, determine if it is to the "left" of all sides of the hull.  If so, skip it; if not, add it
	 // See http://bbs.dartmouth.edu/~fangq/MATH/download/source/Determining%20if%20a%20point%20lies%20on%20the%20interior%20of%20a%20polygon.htm
     qui gen `x'=.
     qui gen `y'=.
     qui gen left=.
	 qui count 
	 local nsides=`r(N)'
	 // Loop through values of x and y implied by xgrid and ygrid
     foreach xx of numlist `xgrid' {
       foreach yy of numlist`ygrid' {
	     //di "`xx' `yy'"
	     // Determine if this potential point is to the "left" of all sides of the hull
    	 qui replace left=(`yy'-y1)*(x2-x1)-(`xx'-x1)*(y2-y1)
		 // Count the number of points to the "left"
	     qui count if left>=0 & !mi(left)   
		 // If all points are to the left, it is inside the hull, so add it to the list
	     if `r(N)'==`nsides' {   
	       qui set obs `=_N+1'
	       qui replace `x'=`xx' in `=_N'
   	       qui replace `y'=`yy' in `=_N'
	     }
      }
    }

	// Drop the originall hull points since they are included in the above algorithm
    qui drop if !mi(angle)

    keep `x' `y'
	//scatter `y' `x'
	
	// Create a temporary fillusing file to use later
	tempfile fillusing
    qui save "`fillusing'", replace
    local mode "fill"
	
    use "`preserve'", clear

  }
 
  
  
  if ("`mode`'"=="fill") {
	qui merge 1:1 `x' `y' using `fillusing'
	drop _merge
  }
    
  if `reps'==1 {	
	
    if ("`method'"=="contour") {    // Stata method from twoway contour
      capture noisily call_contour `z'_`collapse' `y' `x', `contourmethod'
	  if (_rc!=0) exit
    }
    else {
      capture noisily call_bivar `z'_`collapse' `y' `x', xgrid(`xgrid') ygrid(`ygrid') mode(`mode') `method' near(`near') smooth(`smooth')
      if (_rc!=0) exit
    }
  }
  else {
    // Preserve analysis file so that results can be accumulated
    tempfile preserve1
    qui gen `z'_sim=.
    qui save `preserve1', replace
  
    tempfile results
  
    di "Reps:" _continue
	if `seed'>=0 {
	  set seed `seed'
	}
    forval rep=1/`reps' {

	  if mod(`rep',5)==0 {
	    di "`rep'" _continue
	  }
	  else {
	    di "." _continue
	  }
      qui use `preserve1', clear
      qui replace `z'_sim=rnormal(`z'_mean,`z'_sd)
      qui replace `z'_sim=`z'_mean if inlist(`z'_sd,0,.)
      drop `z'_mean `z'_sd
  
      if ("`method'"=="contour") {    // Stata method from twoway contour
        capture noisily call_contour `z'_sim `y' `x', `contourmethod'
	    if (_rc!=0) exit
      }
      else {
        capture noisily call_bivar `z'_sim `y' `x', xgrid(`xgrid') ygrid(`ygrid') mode(`mode') `method' near(`near') smooth(`smooth')
        if (_rc!=0) exit
      }

      //desc 
      //summ `z'_sim, det
  
      capture append using `results'
      qui save `results', replace
	}
    di _newline
	
    collapse (mean) `z'_mean=`z'_sim (sd) `z'_sd=`z'_sim, by(`x' `y')
  }
  
  if ("`saving'"!="") {
    save `saving'
  }
  
end

program call_bivar
version 12
  syntax varlist(min=3 max=3 numeric) , MODE(string)  NEAR(integer) SMOOTH(real) ///
                                        [XGrid(numlist) YGrid(numlist) THINplatespline SHEPARD AKIMA]

  tokenize `varlist' 
  local z `1'
  local y `2'
  local x `3'
  
  if ("`akima'"!="") {
    //di "Akima: `x' `y' `z' `xgrid' `ygrid' `mode' `near'"
    mata: bivar("`x'","`y'","`z'","`xgrid'","`ygrid'","`mode'",`near')
  }
  else if ("`thinplatespline'"!="") {
    //di "TPS: `x' `y' `z' `xgrid' `ygrid' `mode' `smooth'"
    mata: tps("`x'","`y'","`z'","`xgrid'","`ygrid'","`mode'",`smooth')  
  }
  else if ("`shepard'"!="") {
    //di "Shep: `x' `y' `z' `xgrid' `ygrid' `mode' "
    mata: shep("`x'","`y'","`z'","`xgrid'","`ygrid'","`mode'")
  }
  
end

program call_contour
  version 12
  syntax varlist(min=3 max=3 numeric) [, THINplatespline SHEPARD]
  
  tokenize `varlist' 
  local z `1'
  local y `2'
  local x `3'

  if ("`thinplatespline'"!="" & "`shepard'"!="") {
    di as red "specify only one interpolation method for option contourmethod()"
	error 1
  }
  if ("`shepard'"=="") {
    local contourmethod "tps"
  }
  else {
    local contourmethod "shepard"
  }
  mata: data=contour_interp("`z'","`y'","`x'","`contourmethod'")
  
  clear
  getmata (`1' `2' `3')=data, replace force
  
end 

version 12
mata:
mata set matastrict on


real matrix contour_interp(string zvar, string yvar, string xvar, string method)
{
real matrix Z, data
real scalar re, rn, dim, i, j

Z = _contour_setup(zvar,yvar,xvar,newx=.,newy=. ,method)

re = rows(newx)
rn = rows(newy)
dim = re*rn

data = J(dim, 3, .)

for(i=1; i<=re; i++) {
   for(j=1; j<=rn; j++) {
                pos = (i-1)*rn+j
                data[pos, .] = (Z[j,i] ,newy[j], newx[i])
   } 
}

return(data)
}

void bivar(string xvar, string yvar, string zvar, string xgrid, string ygrid, string mode, real scalar ncp)
{
real vector iwk, wk

real vector x, y, z, xi, yi, zi, xd, yd, zd
real matrix zij
real scalar npt, ni, i, j, n
x=st_data(.,xvar)'
y=st_data(.,yvar)'
z=st_data(.,zvar)'
npt=st_nobs()

if (mode=="interp") {   

  real scalar nxi, nyi, nzi

  xi=strtoreal(tokens(xgrid))
  nxi=cols(xi)

  yi=strtoreal(tokens(ygrid))
  nyi=cols(yi)
  nzi=nxi

  zij=J(nzi,nyi,.)
  iwk=J(1,max((31,27+ncp))*npt+nxi*nyi,.)
  wk=J(1,6*npt,.)
  
  idsfft (1, ncp, npt, x, y, z, nxi, nyi, nzi, xi, yi, zij, iwk, wk)

  // Drop current observations and replace with newly interpolated observations
  st_dropobsin(.)
  st_addobs(nxi*nyi)
  n=0
  for (i=1; i<=nxi; i++) {
    for (j=1; j<=nyi; j++) {
      n++
      st_store(n,xvar, xi[i])
      st_store(n,yvar, yi[j])
      st_store(n,zvar, zij[i,j])
    }
  }

}
else if (mode=="fill") {

  // Complete data set (original+filled) goes into xi,yi,zi
  ni=npt
  xi=x
  yi=y
  zi=J(1,ni,.)

  // Save points with non-missing z-values to be used for generating interpolation function
  norig=0
  for (i=1; i<=npt; i++) {
    if (z[i]!=.) {
	  norig++
	  xd=(xd,x[i])
	  yd=(yd,y[i])
	  zd=(zd,z[i])
	}
  }
  npt=norig
  
  iwk=J(1,max((31,27+ncp))*npt+ni,.)
  wk=J(1,8*npt,.)
  
  idbvip ( 1, ncp, npt, xd, yd, zd, ni, xi, yi, zi, iwk, wk )

  // Drop current observations and replace with newly filled-in observations (which will include the original observations)
  st_dropobsin(.)
  st_addobs(ni)
  st_store(.,xvar, xi')
  st_store(.,yvar, yi')
  st_store(.,zvar, zi')
  
}

return
}  

void tps(string xvar, string yvar, string zvar, string xgrid, string ygrid, string mode, scalar alpha)
{
real vector iwk, wk

real vector x, y, z, xi, yi, zi, xd, yd, zd
real matrix zij
real scalar n, ni, i, j, xx, yy

x=st_data(.,xvar)'
y=st_data(.,yvar)'
z=st_data(.,zvar)
n=st_nobs()

if (mode=="interp") {   

  real scalar nxi, nyi, nzi

  xi=strtoreal(tokens(xgrid))
  nxi=cols(xi)
   
  yi=strtoreal(tokens(ygrid))
  nyi=cols(yi)
  nzi=nxi

  zij=J(nzi,nyi,.)
  
  // TPS Code
  
  Ivec=J(1,n,1)

  t=x\y
  T=Ivec\x\y
 
  E=J(n,n,.)
  for (i=1; i<=n; i++) {
    for (j=1; j<=n; j++) {
      if (i==j) {
	    E[i,j]=0
	  }
	  else {
        E[i,j]=(1/(16*pi()))*(norm(t[.,i]-t[.,j])^2)*log(norm(t[.,i]-t[.,j])^2)
  	  }
    }
  }
  
  //"E="
  //E
  
  mat0=J(3,3,0)
  vec0=J(3,1,0)
  A=(E+alpha*I(n,n),T'\T,mat0)
  B=(z\vec0)

  //"A= B="
  // A
  //B
  
  X=lusolve(A,B)

  //"X="
  //X
  
  d=X[1..n,.]
  a=X[n+1..n+3,.] 

  //"d= a="
  //d
  //a
  
  //"Tdelta"
  //T*d
  
  //"xi yi"
  //xi
  //yi
  
  for (xx=1; xx<=nxi; xx++) {
    for (yy=1; yy<=nyi; yy++) {
	  /*
	  "xx yy xy"
	  xx
	  yy
	  */
	  xy=(xi[xx]\yi[yy])
	  //xy
	  g1=0
      for (i=1; i<=n; i++) {
	    /*
        "i"
	    i
	    t[.,i]
		*/
		if (xy!=t[.,i]) {
          g1=g1+d[i]*(1/(16*pi()))*(norm(xy-t[.,i])^2)*log(norm(xy-t[.,i])^2)
		}
	  }
      g2=a[1]+a[2]*xi[xx]+a[3]*yi[yy]
      zij[xx,yy]=g1+g2
    }
  }
  
  // Drop current observations and replace with newly interpolated observations
  st_dropobsin(.)
  st_addobs(nxi*nyi)
  n=0
  for (i=1; i<=nxi; i++) {
     for (j=1; j<=nyi; j++) {
      n++
      st_store(n,xvar, xi[i])
      st_store(n,yvar, yi[j])
      st_store(n,zvar, zij[i,j])
    }
  }

}
else if (mode=="fill") {

  // Complete data set (original+filled) goes into xi,yi,zi
  ni=n
  xi=x
  yi=y
  zi=J(1,ni,.)

  // Save points with non-missing z-values to be used for generating interpolation function
  norig=0
  for (i=1; i<=n; i++) {
    if (z[i]!=.) {
	  norig++
	  xd=(xd,x[i])
	  yd=(yd,y[i])
	  zd=(zd,z[i])
	}
  }
  n=norig
  
  Ivec=J(1,n,1)

  t=xd\yd
  T=Ivec\xd\yd
 
 
  E=J(n,n,.)
  for (i=1; i<=n; i++) {
    for (j=1; j<=n; j++) {
      if (i==j) {
	    E[i,j]=0
	  }
	  else {
        E[i,j]=(1/(16*pi()))*(norm(t[.,i]-t[.,j])^2)*log(norm(t[.,i]-t[.,j])^2)
  	  }
    }
  }
  
  //"E="
  //E
  
  mat0=J(3,3,0)
  vec0=J(3,1,0)
  A=(E+alpha*I(n,n),T'\T,mat0)
  //zd
  //vec0
  B=(zd'\vec0)

  //"A= B="
  //A
  //B
  
  X=lusolve(A,B)

  //"X="
  //X
  
  d=X[1..n,.]
  a=X[n+1..n+3,.] 

  //"d= a="
  //d
  //a
  
  //"Tdelta"
  //T*d
  
  //"xi yi"
  //xi
  //yi
  
  for (i=1; i<=ni; i++) {
    xy=(xi[i]\yi[i])
    g1=0
    for (j=1; j<=n; j++) {
      if (xy!=t[.,j]) {
          g1=g1+d[j]*(1/(16*pi()))*(norm(xy-t[.,j])^2)*log(norm(xy-t[.,j])^2)
	  }
	}
    g2=a[1]+a[2]*xi[i]+a[3]*yi[i]
    zi[i]=g1+g2
  }
  
  // Drop current observations and replace with newly filled-in observations (which will include the original observations)
  st_dropobsin(.)
  st_addobs(ni)
  st_store(.,xvar, xi')
  st_store(.,yvar, yi')
  st_store(.,zvar, zi')
  
}

return
}  

real scalar f(scalar y, scalar x)
{
return(1/(x^2+y^2))
}

void shep(string xvar, string yvar, string zvar, string xgrid, string ygrid, string mode)
{
real vector iwk, wk

real vector x, y, z, xi, yi, zi, xd, yd, zd
real matrix zij
real scalar npt, ni, i, j, n
x=st_data(.,xvar)'
y=st_data(.,yvar)'
z=st_data(.,zvar)
n=st_nobs()

if (mode=="interp") {   

  real scalar nxi, nyi, nzi

  xi=strtoreal(tokens(xgrid))
  nxi=cols(xi)
   
  yi=strtoreal(tokens(ygrid))
  nyi=cols(yi)
  nzi=nxi

  zij=J(nzi,nyi,.)
  
  // Shepard (from Stata documentation, G-2 page 200)
  
  for (xx=1; xx<=nxi; xx++) {
    for (yy=1; yy<=nyi; yy++) {
       denom=0
	   for (i=1; i<=n; i++) {
	     denom=denom+f(yi[yy]-y[i],xi[xx]-x[i])
	   }
	   numer=0
	   for (i=1; i<=n; i++) {
		 numer=numer+z[i]*f(yi[yy]-y[i],xi[xx]-x[i])
	   }
	   zij[xx,yy]=numer/denom
    }
  }
		 
  
  // Drop current observations and replace with newly interpolated observations
  st_dropobsin(.)
  st_addobs(nxi*nyi)
  n=0
  for (i=1; i<=nxi; i++) {
     for (j=1; j<=nyi; j++) {
      n++
      st_store(n,xvar, xi[i])
      st_store(n,yvar, yi[j])
      st_store(n,zvar, zij[i,j])
    }
  }

}
else if (mode=="fill") {

  // Complete data set (original+filled) goes into xi,yi,zi
  ni=n
  xi=x
  yi=y
  zi=J(1,ni,.)

  // Save points with non-missing z-values to be used for generating interpolation function
  norig=0
  for (i=1; i<=n; i++) {
    if (z[i]!=.) {
	  norig++
	  xd=(xd,x[i])
	  yd=(yd,y[i])
	  zd=(zd,z[i])
	}
  }
  npt=norig
  
  for (i=1; i<=ni; i++) {
    denom=0
    for (j=1; j<=n; j++) {
	   denom=denom+f(yi[i]-yd[j],xi[i]-xd[j])
	}
	numer=0
    for (j=1; j<=n; j++) {
	  numer=numer+zd[j]*f(yi[i]-yd[j],xi[i]-xd[j])
    }
	zi[i]=numer/denom
  }

  
  // Drop current observations and replace with newly filled-in observations (which will include the original observations)
  st_dropobsin(.)
  st_addobs(ni)
  st_store(.,xvar, xi')
  st_store(.,yvar, yi')
  st_store(.,zvar, zi')
  
}

return
} 
 
void idbvip ( real scalar md, real scalar ncp, real scalar ndp, real vector xd,real vector yd,real vector zd,real scalar nip,real vector xi,real vector yi,real vector zi, real vector iwk,real vector wk )
{

/*
!
!*******************************************************************************
!
!! IDBVIP performs bivariate interpolation of irregular X, Y data.
!
!
!  Discussion:
!
!    The data points must be distinct and their projections in the
!    X-Y plane must not be collinear, otherwise an error return
!    occurs.
!
!    Inadequate work space IWK and WK may cause incorrect results.
!
!  Latest revision:
!
!    January, 1985
!
!  Purpose:
!
!    To provide bivariate interpolation and smooth surface fitting for 
!    values given at irregularly distributed points.
!
!    The resulting interpolating function and its first-order partial 
!    derivatives are continuous.
!
!    The method employed is local, i.e. a change in the data in one area 
!    of the plane does not affect the interpolating function except in
!    that local area.  This is advantageous over global interpolation 
!    methods.
!
!    Also, the method gives exact results when all points lie in a plane. 
!    This is advantageous over other methods such as two-dimensional
!    Fourier series interpolation.
!
!  Usage:
!
!    This package contains two user entries, IDBVIP and IDSFFT, both 
!    requiring input data to be given at points
!      ( X(I), Y(I) ), I = 1,...,N.
!
!    If the user desires the interpolated data to be output at grid 
!    points, i.e. at points
!      ( XI(I), YI(J) ), I = 1,...,NXI, J=1,...,NYI,
!    then IDSFFT should be used.  This is useful for generating an 
!    interpolating surface.
!
!    The other user entry point, IDBVIP, will produce interpolated 
!    values at scattered points
!      ( XI(I), YI(I) ), i = 1,...,NIP.  
!    This is useful for filling in missing data points on a grid.
!
!  History:
!
!    The original version of BIVAR was written by Hiroshi Akima in 
!    August 1975 and rewritten by him in late 1976.  It was incorporated 
!    into NCAR's public software libraries in January 1977.  In August 
!    1984 a new version of BIVAR, incorporating changes described in the 
!    Rocky Mountain Journal of Mathematics article cited below, was 
!    obtained from Dr Akima by Michael Pernice of NCAR's Scientific 
!    Computing Division, who evaluated it and made it available in February, 
!    1985.
!
!  Accuracy:
!
!    Accurate to machine precision on the input data points.  Accuracy at 
!    other points greatly depends on the input data.
!
!  References:
!
!    Hiroshi Akima,  
!    A Method of Bivariate Interpolation and Smooth Surface Fitting
!      for Values Given at Irregularly Distributed Points,
!    ACM Transactions on Mathematical Software, 
!    Volume 4, Number 2, June 1978.
!
!    Hiroshi Akima,  
!    On Estimating Partial Derivatives for Bivariate Interpolation
!      of Scattered Data,
!    Rocky Mountain Journal of Mathematics,
!    Volume 14, Number 1, Winter 1984.
!
!  Method:
!
!    The XY plane is divided into triangular cells, each cell having 
!    projections of three data points in the plane as its vertices, and
!    a bivariate quintic polynomial in X and Y is fitted to each 
!    triangular cell.
!
!    The coefficients in the fitted quintic polynomials are determined 
!    by continuity requirements and by estimates of partial derivatives 
!    at the vertices and along the edges of the triangles.  The method 
!    described in the rocky mountain journal reference guarantees that 
!    the generated surface depends continuously on the triangulation.
!
!    The resulting interpolating function is invariant under the following 
!    types of linear coordinate transformations:
!      1) a rotation of the XY coordinate system
!      2) linear scale transformation of the Z axis
!      3) tilting of the XY plane, i.e. new coordinates (u,v,w) given by
!           u = x
!           v = y
!           w = z + a*x + b*y
!         where a, b are arbitrary constants.
!
!    complete details of the method are given in the reference publications.
!
!  Parameters:
!
!    Input, integer MD, mode of computation.   MD must be 1,
!    2, or 3, else an error return occurs.
!
!    1: if this is the first call to this subroutine, or if the
!    value of NDP has been changed from the previous call, or
!    if the contents of the XD or YD arrays have been changed
!    from the previous call.
!
!    2: if the values of NDP and the XD and YD arrays are unchanged
!    from the previous call, but new values for XI, YI are being
!    used.  If MD = 2 and NDP has been changed since the previous
!    call to IDBVIP, an error return occurs.
!
!    3: if the values of NDP, NIP, XD, YD, XI, YI are unchanged from
!    the previous call, i.e. if the only change on input to idbvip is
!    in the ZD array.  If MD = 3 and NDP or NIP has been changed since
!    the previous call to IDBVIP, an error return occurs.
!
!    Between the call with MD = 2 or MD = 3 and the preceding call, the
!    IWK and WK work arrays should not be disturbed.
!
!    Input, integer NDP, the number of data points (must be 4 or
!    greater, else an error return occurs).
!
!    Input, real  XD(NDP), YD(NDP), the X and Y coordinates of the data points.
!
!    Input, real  ZD(NDP), the data values at the data points.
!
!    Input, integer NIP, the number of output points at which
!    interpolation is to be performed (must be 1 or greater, else an
!    error return occurs).
!
!    Input, real  XI(NIP), YI(NIP), the coordinates of the points at which
!    interpolation is to be performed.
!
!    Output, real  ZI(NIP), the interpolated data values.
!
!    Workspace, integer IWK(31*NDP+NIP).
!
!    Workspace, real  WK(8*NDP).
!
*/
//  implicit none

  //real scalar ndp
  //real scalar nip

  //real scalar ap
  //real scalar bp
  //real scalar cp
  //real scalar dp
  real scalar iip
  //real scalar itipv
  //real scalar itpv
  //real vector iwk
  real scalar  jwipl
  real scalar  jwipt
  real scalar  jwit
  real scalar  jwit0
  real scalar  jwiwk
  real scalar  jwiwl
  real scalar  jwiwp
  real scalar  jwwpd
  
  //real scalar  md
  real scalar  nl
  real scalar  nt
  /*
  real scalar  ntsc
  real scalar p00
  real scalar p01
  real scalar p02
  real scalar p03
  real scalar p04
  real scalar p05
  real scalar p10
  real scalar p11
  real scalar p12
  real scalar p13
  real scalar p14
  real scalar p20
  real scalar p21
  real scalar p22
  real scalar p23
  real scalar p30
  real scalar p31
  real scalar p32
  real scalar p40
  real scalar p41
  real scalar p50
  */
  //real vector wk
  //real scalar x0
  //real vector xd
  //real vector xi
  //real scalar xs1
  //real scalar xs2
  //real scalar y0
  //real vector yd
  //real vector yi
  //real scalar ys1
  //real scalar ys2
  //real vector zd
  //real vector zi
  
  real vector ipt, ipl, iwl, iwp, ipc
  real vector ngp, igp
  real vector wpd
  real scalar tzi
  real scalar it
  real vector tiwk
  
//  save /idlc/
//  save /idpt/

//  common /idlc/ itipv,xs1,xs2,ys1,ys2,ntsc(9)
//  common /idpt/ itpv,x0,y0,ap,bp,cp,dp, &
//                p00,p10,p20,p30,p40,p50,p01,p11,p21,p31,p41, &
//                p02,p12,p22,p32,p03,p13,p23,p04,p14,p05
  external real scalar itipv,xs1,xs2,ys1,ys2
  external real vector ntsc
  external real scalar itpv,x0,y0,ap,bp,cp,dp, p00,p10,p20,p30,p40,p50,p01,p11,p21,p31,p41, p02,p12,p22,p32,p03,p13,p23,p04,p14,p05


//  Error check.

  if ( md < 1 | md > 3 ) {
    _error(1,"IDBVIP - Fatal error:  Input parameter MD out of range.")
    return 
  }
 
  if (ncp!=-1 & (ncp < 2 | ncp >= min((25,ndp))) ) {
    _error(6,"IDBVIP - Fatal error: Input parameter NCP out of range.")
	return
  }
  
  if ( ndp < 4 ) {
    _error(2,"IDBVIP - Fatal error:  Input parameter NDP out of range.")
    return 
  }
 
  if ( nip < 1 ) {
    _error(3,"IDBVIP - Fatal error:  Input parameter NIP out of range.")
    return 
  }
 
  if ( md == 1 ) {
    iwk[1] = ncp
    iwk[2] = ndp
  }
  else {
    if ( ncp != iwk[1] ) {
      _error(4,"IDBVIP - Fatal error:  MD = 2 or 3 but NCP was changed since last call.")
      return
    }
 
    if ( ndp != iwk[2] ) {
      _error(5,"IDBVIP - Fatal error:  MD = 2 or 3 but NDP was changed since last call.")
      return
    }
  }

  if ( md <= 2 ) {
    iwk[3] = nip
  }
  else {
    if ( nip < iwk[3] ) {
      _error (6,"IDBVIP - Fatal error:  MD = 3 but NIP was changed since last call.")
      return 
    }
  }

//  Allocation of storage areas in the IWK array.

  jwipt = 16
  jwiwl = 6*ndp+1
  jwiwk = jwiwl
  jwipl = 24*ndp+1
  jwiwp = 30*ndp+1
  jwipc = 27*ndp+1
  jwit0 = max((31,27+ncp))*ndp
  jwwpd = 5*ndp+1

//  Triangulate the XY plane.

  if ( md == 1 ) {


    ipt=iwk[|jwipt\.|]
    ipl=iwk[|jwipl\.|]
    iwl=iwk[|jwiwl\.|]
    iwp=iwk[|jwiwp\.|]
//    idtang ( ndp, xd, yd, nt, iwk[|jwipt\.|], nl, iwk[|jwipl\.|], iwk[|jwiwl\.|], iwk[|jwiwp\.|], wk )
    idtang ( ndp, xd, yd, nt, ipt, nl, ipl, iwl, iwp, wk )
    iwk[|jwipt\.|]=ipt
    iwk[|jwipl\.|]=ipl
    
    iwk[5] = nt
    iwk[6] = nl

    if ( nt == 0 ) {
      return
    }
  }
  else {

    nt = iwk[5]
    nl = iwk[6]

  }
/*
  C DETERMINES NCP POINTS CLOSEST TO EACH DATA POINT.  (FOR MD=1)
   50 IF(MD0.GT.1)   GO TO 60
      CALL IDCLDP(NDP0,XD,YD,NCP0,IWK(JWIPC))
      IF(IWK(JWIPC).EQ.0)      RETURN
*/

     if (md == 1 & ncp>=2) {
      idcldp(ndp, xd, yd, ncp, ipc)

      //iwk[|jwipc\.|]=ipc     // For some reason this doesn't work here
      for (i=1; i<=cols(ipc); i++) {
        iwk[jwipc+i-1]=ipc[i]
      }
	  if (iwk[jwipc] == 0) {
	    return
	  }
    }
//  Locate all points at which interpolation is to be performed.

  if ( md <= 2 ) {

    itipv = 0
    jwit = jwit0

	for (iip=1; iip<=nip; iip++) {

      jwit = jwit+1

	  ipt=iwk[|jwipt\.|]
      ipl=iwk[|jwipl\.|]
      tiwk=iwk[|jwiwk\.|]
	  it=iwk[jwit]

//      idlctn ( ndp, xd, yd, nt, iwk[|jwipt\.|], nl, iwk[|jwipl\.|], xi[iip], yi[iip], iwk[jwit], iwk[|jwiwk\.|], wk )
      idlctn ( ndp, xd, yd, nt, ipt, nl, ipl, xi[iip], yi[iip], it, tiwk, wk )
	  iwk[|jwiwk\.|]=tiwk
	  iwk[jwit]=it
	  
    }

  }

//  Estimate the partial derivatives at all data points.

  if (ncp==-1) {
    wpd=wk[|jwwpd\.|]
    //  idpdrv ( ndp, xd, yd, zd, nt, iwk[|jwipt\.|], wk, wk[|jwwpd\.|] )
    idpdrv ( ndp, xd, yd, zd, nt, ipt, wk, wpd )
    wk[|jwwpd\.|]=wpd
  }
  else {
    ipc=iwk[|jwipc\.|]
    idpdrv_near ( ndp, xd, yd, zd, ncp, ipc, wk)
    iwk[|jwipc\.|]=ipc
  }  
  
  
  
  
//  Interpolate the ZI values.

  itpv = 0
  jwit = jwit0

  for (iip=1; iip<=nip; iip++) {

    jwit = jwit + 1

    //idptip ( ndp, xd, yd, zd, nt, iwk[jwipt], nl, iwk[jwipl], wk, iwk[jwit], xi[iip], yi[iip], zi[iip] )
    tzi=.
    idptip ( ndp, xd, yd, zd, nt, ipt, nl, ipl, wk, iwk[jwit], xi[iip], yi[iip], tzi )
    zi[iip]=tzi
  }
 
  return
}


real scalar spdt(real scalar u1, real scalar v1, real scalar u2, real scalar v2,real scalar u3,real scalar v3) 
{
  return((u1-u2)*(u3-u2)+(v1-v2)*(v3-v2))
}

real scalar vpdt(real scalar u1, real scalar v1, real scalar u2, real scalar v2,real scalar u3,real scalar v3) 
{
  return((u1-u3)*(v2-v3)-(v1-v3)*(u2-u3))
}

void idgrid ( real vector xd, real vector yd, real scalar nt, real vector ipt, real scalar nl, real vector ipl, real scalar nxi, real scalar nyi, real vector xi, real vector yi, real vector ngp, real vector igp )
{
/*
!*******************************************************************************
!
!! IDGRID organizes grid points for surface fitting.
!
!
!  Discussion:
!
!    IDGRID sorts the points in ascending order of triangle numbers and 
!    of the border line segment number.
!
!  Parameters:
!
!    Input, real scalar XD(NDP), YD(NDP), the X and Y coordinates of the data 
!    points.
!
!    Input, integer NT, the number of triangles.
!
!    Input, integer IPT(3*NT), the indices of the triangle vertexes.
!
!    Input, integer NL, the number of border line segments.
!
!    Input, integer IPL(3*NL), containing the point numbers of the end points 
!    of the border line segments and their respective triangle numbers,
!
!    Input, integer NXI, NYI, the number of grid points in the X and Y
!    coordinates.
!
!    Input, real scalar XI(NXI), YI(NYI), the coordinates of the grid points.
!
!    Output, integer NGP(2*(NT+2*NL)) where the
!    number of grid points that belong to each of the
!    triangles or of the border line segments are to be stored.
!
!    Output, integer IGP(NXI*NYI), where the grid point numbers are to be 
!    stored in ascending order of the triangle number and the border line
!    segment number.
!
*/
//  implicit none

  //real scalar nl
  //real scalar nt
  //real scalar nxi
  //real scalar nyi

  //real scalar igp(nxi*nyi)
  real scalar il0
  real scalar il0t3
  real scalar ilp1
  real scalar ilp1t3
  real scalar insd
  real scalar ip1
  real scalar ip2
  real scalar ip3
  //real vector ipl(3*nl)
  //real vector ipt(3*nt)
  real scalar it0
  real scalar it0t3
  real scalar ixi
  real scalar iximn
  real scalar iximx
  real scalar iyi
  real scalar izi
  real scalar jigp0
  real scalar jigp1
  real scalar jigp1i
  real scalar jngp0
  real scalar jngp1
  real scalar l
  //real scalar ngp(2*(nt+2*nl))
  real scalar ngp0
  real scalar ngp1
  real scalar nl0
  real scalar nt0
  real scalar nxinyi
  //real scalar spdt
  //real scalar u1
  //real scalar u2
  //real scalar u3
  //real scalar v1
  //real scalar v2
  //real scalar v3
  //real scalar vpdt
  real scalar x1
  real scalar x2
  real scalar x3
  //real scalar xd(*)
  //real scalar xi(nxi)
  real scalar xii
  real scalar ximn
  real scalar ximx
  real scalar xmn
  real scalar xmx
  real scalar y1
  real scalar y2
  real scalar y3
  //real scalar yd(*)
  //real scalar yi(nyi)
  real scalar yii
  real scalar yimn
  real scalar yimx
  real scalar ymn
  real scalar ymx
/*
!
!  Statement functions
!
// Put these outside
  spdt(u1,v1,u2,v2,u3,v3) = (u1-u2)*(u3-u2)+(v1-v2)*(v3-v2)

  vpdt(u1,v1,u2,v2,u3,v3) = (u1-u3)*(v2-v3)-(v1-v3)*(u2-u3)
*/

//  Preliminary processing

  nt0 = nt
  nl0 = nl
  nxinyi = nxi * nyi
  ximn = min (( xi[1], xi[nxi] ))
  ximx = max (( xi[1], xi[nxi] ))
  yimn = min (( yi[1], yi[nyi] ))
  yimx = max (( yi[1], yi[nyi] ))

//  Determine grid points inside the data area.

  jngp0 = 0
  jngp1 = 2*(nt0+2*nl0)+1
  jigp0 = 0
  jigp1 = nxinyi + 1
 
  for (it0=1; it0<=nt0; it0++) {

    ngp0 = 0
    ngp1 = 0
    it0t3 = it0*3
    ip1 = ipt[it0t3-2]
    ip2 = ipt[it0t3-1]
    ip3 = ipt[it0t3]
    x1 = xd[ip1]
    y1 = yd[ip1]
    x2 = xd[ip2]
    y2 = yd[ip2]
    x3 = xd[ip3]
    y3 = yd[ip3]
    xmn = min (( x1, x2, x3 ))
    xmx = max (( x1, x2, x3 ))
    ymn = min (( y1, y2, y3 ))
    ymx = max (( y1, y2, y3 ))
    insd = 0

    for (ixi=1; ixi<=nxi; ixi++) {

      if ( xi[ixi] < xmn | xi[ixi] > xmx ) {
        if ( insd == 0 ) {
          continue  // cycle
        }
        iximx = ixi-1
        goto L23
      }

      if ( insd != 1 ) {
        insd = 1
        iximn = ixi
      }

    }
 
    if ( insd == 0 ) {
      goto L38
    }

    iximx = nxi

L23:

    for (iyi = 1; iyi<=nyi; iyi++) {

      yii = yi[iyi]

      if ( yii < ymn | yii > ymx ) {
        goto L37
      }

      for (ixi = iximn; ixi<=iximx; ixi++) {

        xii = xi[ixi]
        l = 0

        if ( vpdt(x1,y1,x2,y2,xii,yii) < 0) goto L36
        else if ( vpdt(x1,y1,x2,y2,xii,yii) == 0) goto L25
        else if ( vpdt(x1,y1,x2,y2,xii,yii) > 0) goto L26

L25:

        l = 1
L26:
        if ( vpdt(x2,y2,x3,y3,xii,yii) < 0) goto L36
        else if ( vpdt(x2,y2,x3,y3,xii,yii) == 0) goto L27
        else if ( vpdt(x2,y2,x3,y3,xii,yii) > 0) goto L28

L27:    
        l = 1
L28:
        if ( vpdt(x3,y3,x1,y1,xii,yii) < 0) goto L36
        else if ( vpdt(x3,y3,x1,y1,xii,yii) == 0) goto L29
        else if ( vpdt(x3,y3,x1,y1,xii,yii) > 0) goto L30

L29:
        l = 1
L30:
        izi = nxi*(iyi-1)+ixi

        if ( l == 1 ) goto L31

        ngp0 = ngp0+1
        jigp0 = jigp0+1
        igp[jigp0] = izi
        goto L36

L31:
 
        for (jigp1i = jigp1; jigp1i<=nxinyi; jigp1i++) {
          if ( izi == igp[jigp1i] ) {
            goto L36
          }
        }
 
        ngp1 = ngp1+1
        jigp1 = jigp1-1
        igp[jigp1] = izi

L36:

      }

L37:    

    }

L38:

    jngp0 = jngp0+1
    ngp[jngp0] = ngp0
    jngp1 = jngp1-1
    ngp[jngp1] = ngp1

  }

//  Determine grid points outside the data area.
//  in semi-infinite rectangular area.

  for (il0 = 1; il0<=nl0; il0++) {

    ngp0 = 0
    ngp1 = 0
    il0t3 = il0*3
    ip1 = ipl[il0t3-2]
    ip2 = ipl[il0t3-1]
    x1 = xd[ip1]
    y1 = yd[ip1]
    x2 = xd[ip2]
    y2 = yd[ip2]

    xmn = ximn
    xmx = ximx
    ymn = yimn
    ymx = yimx

    if ( y2 >= y1 ) {
      xmn = min (( x1, x2 ))
    }

    if ( y2 <= y1 ) {
      xmx = max (( x1, x2 ))
    }

    if ( x2 <= x1 ) {
      ymn = min (( y1, y2 ))
    }

    if ( x2 >= x1 ) {
      ymx = max (( y1, y2 ))
    }

    insd = 0

    for ( ixi = 1; ixi<=nxi; ixi++) {

      if ( xi[ixi] < xmn | xi[ixi] > xmx ) {
        if ( insd == 0 ) {
          goto L42
        }
        iximx = ixi-1
        goto L43
      }

      if ( insd != 1 ) {
        insd = 1
        iximn = ixi
      }

L42:

    }

    if ( insd == 0 ) goto L58

    iximx = nxi

L43:

    for (iyi = 1; iyi<=nyi; iyi++) {

      yii = yi[iyi]
      if(yii<ymn |  yii>ymx) goto L57

      for (ixi = iximn; ixi<=iximx; ixi++) {

        xii = xi[ixi]
        l = 0

        if ( vpdt(x1,y1,x2,y2,xii,yii) < 0) goto L46
        else if ( vpdt(x1,y1,x2,y2,xii,yii) == 0) goto L45
        else if ( vpdt(x1,y1,x2,y2,xii,yii) > 0) goto L56

   L45:       l = 1
   L46:
        if ( spdt(x2,y2,x1,y1,xii,yii) < 0) goto L56
        else if ( spdt(x2,y2,x1,y1,xii,yii) == 0) goto L47
        else if ( spdt(x2,y2,x1,y1,xii,yii) > 0) goto L48

   L47:       l = 1
   L48:       
        if ( spdt(x1,y1,x2,y2,xii,yii) < 0) goto L56
        else if ( spdt(x1,y1,x2,y2,xii,yii) == 0) goto L49
        else if ( spdt(x1,y1,x2,y2,xii,yii) > 0) goto L50

   L49:       l = 1
   L50:       izi = nxi*(iyi-1)+ixi
        if(l==1)    goto L51
        ngp0 = ngp0+1
        jigp0 = jigp0+1
        igp[jigp0] = izi
        goto L56
 
L51:
 
        for (jigp1i = jigp1; jigp1i<=nxinyi; jigp1i++) {
          if(izi==igp[jigp1i])     goto L56
        }
 
L53: 

        ngp1 = ngp1+1
        jigp1 = jigp1-1
        igp[jigp1] = izi

L56:

      }

L57:

    }

L58:

    jngp0 = jngp0+1
    ngp[jngp0] = ngp0
    jngp1 = jngp1-1
    ngp[jngp1] = ngp1

//  In semi-infinite triangular area.

L60:

    ngp0 = 0
    ngp1 = 0
    ilp1 = mod(il0,nl0)+1
    ilp1t3 = ilp1*3
    ip3 = ipl[ilp1t3-1]
    x3 = xd[ip3]
    y3 = yd[ip3]
    xmn = ximn
    xmx = ximx
    ymn = yimn
    ymx = yimx
    if(y3>=y2 &  y2>=y1)   xmn = x2
    if(y3<=y2 &  y2<=y1)   xmx = x2
    if(x3<=x2 &  x2<=x1)   ymn = y2
    if(x3>=x2 &  x2>=x1)   ymx = y2
    insd = 0

    for (ixi = 1; ixi<=nxi; ixi++) {

      if ( xi[ixi] < xmn | xi[ixi] > xmx ) {
        if(insd==0)   goto L62
        iximx = ixi-1
        goto L63
      }

      if ( insd != 1 ) {
        insd = 1
        iximn = ixi
      }

L62:

    }

    if(insd==0)     goto L78

    iximx = nxi
 
L63:

    for (iyi = 1; iyi<=nyi; iyi++) {
 
      yii = yi[iyi]
      if(yii<ymn |  yii>ymx)        goto L77
 
      for (ixi = iximn; ixi<=iximx; ixi++) {
 
        xii = xi[ixi]
        l = 0
      
        if ( spdt(x1,y1,x2,y2,xii,yii) < 0) goto L66
        else if ( spdt(x1,y1,x2,y2,xii,yii) == 0) goto L65
        else if ( spdt(x1,y1,x2,y2,xii,yii) > 0) goto L76

   L65:       l = 1
   L66:       
        if ( spdt(x3,y3,x2,y2,xii,yii) < 0) goto L70
        else if ( spdt(x3,y3,x2,y2,xii,yii) == 0) goto L67
        else if ( spdt(x3,y3,x2,y2,xii,yii) > 0) goto L76

   L67:       l = 1
   L70:       izi = nxi*(iyi-1)+ixi
 
        if ( l != 1 ) {
          ngp0 = ngp0+1
          jigp0 = jigp0+1
          igp[jigp0] = izi
          goto L76
        }
 
        for (jigp1i = jigp1; jigp1i<=nxinyi; jigp1i++) {
          if(izi==igp[jigp1i]) goto L76
        }
 
        ngp1 = ngp1+1
        jigp1 = jigp1-1
        igp[jigp1] = izi
 
L76:

      }
 
L77:

    }
 
L78: 

    jngp0 = jngp0+1
    ngp[jngp0] = ngp0
    jngp1 = jngp1-1
    ngp[jngp1] = ngp1
 
  }
 
  return
}

void idlctn (real scalar ndp, real vector xd, real vector yd, real scalar nt, real vector ipt, real scalar nl, real vector ipl, real scalar xii, real scalar yii, real scalar iti, real vector iwk, real vector wk )
{
/*
!
!*******************************************************************************
!
!! IDLCTN finds the triangle that contains a point.
!
!
!  Discusstion:
!
!    IDLCTN determines what triangle a given point (XII, YII) belongs to.  
!    When the given point does not lie inside the data area, IDLCTN 
!    determines the border line segment when the point lies in an outside
!    rectangular area, and two border line segments when the point
!    lies in an outside triangular area.
!
!  Parameters:
!
!    Input, integer NDP, the number of data points.
!
!    Input, real scalar XD(NDP), YD(NDP), the X and Y coordinates of the data.
!
!    Input, integer NT, the number of triangles.
!
!    Input, integer IPT(3*NT), the point numbers of the vertexes of 
!    the triangles,
!
!    Input, integer NL, the number of border line segments.
!
!    Input, integer IPL(3*NL), the point numbers of the end points of 
!    the border line segments and their respective triangle numbers.
!
!    Input, real scalar XII, YII, the coordinates of the point to be located.
!
!    Output, integer ITI, the triangle number, when the point is inside the
!    data area, or two border line segment numbers, il1 and il2,
!    coded to il1*(nt+nl)+il2, when the point is outside the data area.
!
!    Workspace, integer IWK(18*NDP).
!
!    Workspace, real scalar WK(8*NDP).
!
*/
//  implicit none

  //real scalar ndp
  //real scalar nl
  //real scalar nt

  real scalar i1
  real scalar i2
  real scalar i3
  real scalar idp
  real vector idsc
  real scalar il1
  real scalar il1t3
  real scalar il2
  real scalar ip1
  real scalar ip2
  real scalar ip3
  //real scalar ipl(3*nl)
  //real scalar ipt(3*nt)
  real scalar isc
  real scalar it0
  real scalar it0t3
  //real scalar iti
  //real scalar itipv
  real scalar itsc
  //real vector iwk
  real scalar jiwk
  real scalar jwk
  real scalar nl0
  real scalar nt0
  real scalar ntl
  //real vector ntsc
  real scalar ntsci
  //real scalar spdt
  //real scalar u1
  //real scalar u2
  //real scalar u3
  //real scalar v1
  //real scalar v2
  //real scalar v3
  //real scalar vpdt
  //real vector wk
  real scalar x0
  real scalar x1
  real scalar x2
  real scalar x3
  //real scalar xd(ndp)
  //real scalar xii
  real scalar xmn
  real scalar xmx
  //real scalar xs1
  //real scalar xs2
  real scalar y0
  real scalar y1
  real scalar y2
  real scalar y3
  //real scalar yd(ndp)
  //real scalar yii
  real scalar ymn
  real scalar ymx
  //real scalar ys1
  //real scalar ys2

//  save /idlc/

//  common /idlc/ itipv,xs1,xs2,ys1,ys2,ntsc(9)
  external real scalar itipv,xs1,xs2,ys1,ys2
  external real vector ntsc

/*
!
!  Statement functions
!
  spdt(u1,v1,u2,v2,u3,v3) = (u1-u2)*(u3-u2)+(v1-v2)*(v3-v2)

  vpdt(u1,v1,u2,v2,u3,v3) = (u1-u3)*(v2-v3)-(v1-v3)*(u2-u3)
*/

//  Preliminary processing

  nt0 = nt
  nl0 = nl
  ntl = nt0+nl0
  x0 = xii
  y0 = yii

//  Processing for a new set of data points

  if ( itipv!=0)      goto L30

//  Divide the x-y plane into nine rectangular sections.

  xmn = xd[1]
  xmx = xd[1]
  ymn = yd[1]
  ymx = yd[1]
  for (idp = 2; idp<=ndp; idp++) {
    xmn = min (( xd[idp], xmn ))
    xmx = max (( xd[idp], xmx ))
    ymn = min (( yd[idp], ymn ))
    ymx = max (( yd[idp], ymx ))
  }
 
  xs1 = ( xmn + xmn + xmx ) / 3.0E+00
  xs2 = ( xmn + xmx + xmx ) / 3.0E+00
  ys1 = ( ymn + ymn + ymx ) / 3.0E+00
  ys2 = ( ymn + ymx + ymx ) / 3.0E+00

//  Determine and store in the iwk array, triangle numbers of
//  the triangles associated with each of the nine sections.

  ntsc=J(1,9,0)
  idsc=J(1,9,0)
 
  it0t3 = 0
  jwk = 0

  for (it0 = 1; it0<=nt0; it0++) {

    it0t3 = it0t3+3
    i1 = ipt[it0t3-2]
    i2 = ipt[it0t3-1]
    i3 = ipt[it0t3]
    xmn = min (( xd[i1], xd[i2], xd[i3] ))
    xmx = max (( xd[i1], xd[i2], xd[i3] ))
    ymn = min (( yd[i1], yd[i2], yd[i3] ))
    ymx = max (( yd[i1], yd[i2], yd[i3] ))

    if ( ymn <= ys1 ) {
      if(xmn<=xs1)                   idsc[1] = 1
      if(xmx>=xs1 &   xmn<=xs2)      idsc[2] = 1
      if(xmx>=xs2)                   idsc[3] = 1
    }

    if ( ymx >= ys1 & ymn <= ys2 ) {
      if(xmn<=xs1)                   idsc[4] = 1
      if(xmx>=xs1 &   xmn<=xs2)      idsc[5] = 1
      if(xmx>=xs2)                   idsc[6] = 1
    }

    if(ymx<ys2)                   goto L25
    if(xmn<=xs1)                  idsc[7] = 1
    if(xmx>=xs1 &   xmn<=xs2)     idsc[8] = 1
    if(xmx>=xs2)                  idsc[9] = 1

L25:

    for (isc = 1; isc<=9; isc++) {
      if ( idsc[isc] != 0 ) {
        jiwk = 9*ntsc[isc]+isc
        iwk[jiwk] = it0
        ntsc[isc] = ntsc[isc]+1
        idsc[isc] = 0
      }
    }

//  Store in the wk array the minimum and maximum of the X and
//  Y coordinate values for each of the triangle.

    jwk = jwk+4
    wk[jwk-3] = xmn
    wk[jwk-2] = xmx
    wk[jwk-1] = ymn
    wk[jwk]   = ymx

  }

  goto L60

//  Check if in the same triangle as previous.

L30:

  it0 = itipv

  if(it0>nt0)      goto L40

  it0t3 = it0*3
  ip1 = ipt[it0t3-2]
  x1 = xd[ip1]
  y1 = yd[ip1]
  ip2 = ipt[it0t3-1]
  x2 = xd[ip2]
  y2 = yd[ip2]
  if(vpdt(x1,y1,x2,y2,x0,y0) < 0.0E+00 )      goto L60
  ip3 = ipt[it0t3]
  x3 = xd[ip3]
  y3 = yd[ip3]
  if(vpdt(x2,y2,x3,y3,x0,y0) < 0.0E+00 )      goto L60
  if(vpdt(x3,y3,x1,y1,x0,y0) < 0.0E+00 )      goto L60

  iti = it0
  itipv = it0

  return

//  Check if on the same border line segment.

L40:
  il1 = trunc(it0 / ntl)
  il2 = it0-il1*ntl
  il1t3 = il1*3
  ip1 = ipl[il1t3-2]
  x1 = xd[ip1]
  y1 = yd[ip1]
  ip2 = ipl[il1t3-1]
  x2 = xd[ip2]
  y2 = yd[ip2]
  if(il2!=il1)      goto L50
  if(spdt(x1,y1,x2,y2,x0,y0) < 0.0E+00 )      goto L60
  if(spdt(x2,y2,x1,y1,x0,y0) < 0.0E+00 )      goto L60
  if(vpdt(x1,y1,x2,y2,x0,y0) > 0.0E+00 )      goto L60
  
  iti = it0
  itipv = it0

  return

//  Check if between the same two border line segments.

L50:

  if(spdt(x1,y1,x2,y2,x0,y0) > 0.0E+00 )      goto L60

  ip3 = ipl[3*il2-1]
  x3 = xd[ip3]
  y3 = yd[ip3]

  if ( spdt(x3,y3,x2,y2,x0,y0) <= 0.0E+00 )  {
    iti = it0
    itipv = it0
    return
  }

//  Locate inside the data area.
//  Determine the section in which the point in question lies.

L60:

  isc = 1

  if ( x0 >= xs1 ) {
    isc = isc+1
  }

  if ( x0 >= xs2 ) {
    isc = isc+1
  }

  if ( y0 >= ys1 ) {
    isc = isc+3
  }

  if ( y0 >= ys2 ) {
    isc = isc+3
  }

//  Search through the triangles associated with the section.

  ntsci = ntsc[isc]
  if(ntsci<=0)      goto L70
  jiwk = -9+isc

  for (itsc = 1; itsc<=ntsci; itsc++) {

    jiwk = jiwk+9
    it0 = iwk[jiwk]
    jwk = it0*4
    if(x0<wk[jwk-3])    goto L61
    if(x0>wk[jwk-2])    goto L61
    if(y0<wk[jwk-1])    goto L61
    if(y0>wk[jwk])      goto L61
    it0t3 = it0*3
    ip1 = ipt[it0t3-2]
    x1 = xd[ip1]
    y1 = yd[ip1]
    ip2 = ipt[it0t3-1]
    x2 = xd[ip2]
    y2 = yd[ip2]
    if(vpdt(x1,y1,x2,y2,x0,y0)<0.0E+00 )    goto L61
    ip3 = ipt[it0t3]
    x3 = xd[ip3]
    y3 = yd[ip3]

    if ( vpdt(x2,y2,x3,y3,x0,y0) >= 0.0E+00 ) {

      if ( vpdt(x3,y3,x1,y1,x0,y0) >= 0.0E+00 ) {
        iti = it0
        itipv = it0
        return
      }

    }

L61:

  }

//  Locate outside the data area.

L70:

  for (il1 = 1; il1<=nl0; il1++) {

    il1t3 = il1*3
    ip1 = ipl[il1t3-2]
    x1 = xd[ip1]
    y1 = yd[ip1]
    ip2 = ipl[il1t3-1]
    x2 = xd[ip2]
    y2 = yd[ip2]
    if(spdt(x2,y2,x1,y1,x0,y0)<0.0E+00 )    goto L72
    if(spdt(x1,y1,x2,y2,x0,y0)<0.0E+00 )    goto L71
    if(vpdt(x1,y1,x2,y2,x0,y0)>0.0E+00 )    goto L72
    il2 = il1
    goto L75

   L71:

    il2 = mod(il1,nl0)+1
    ip3 = ipl[3*il2-1]
    x3 = xd[ip3]
    y3 = yd[ip3]
    if(spdt(x3,y3,x2,y2,x0,y0)<=0.0E+00 )    goto L75

   L72:

  }
 
  it0 = 1
  iti = it0
  itipv = it0

  return

   L75:

  it0 = il1*ntl+il2
  iti = it0
  itipv = it0

  return
}
real scalar dsqf(real scalar u1, real scalar v1, real scalar u2, real scalar v2)
{
  return((u2-u1)^2+(v2-v1)^2)
}
void idpdrv ( real scalar ndp, real vector xd, real vector yd, real vector zd, real scalar nt, real vector ipt, real vector pd, real vector wk )
{
/*
!
!*******************************************************************************
!
!! IDPDRV estimates first and second partial derivatives at data points.
!
!
!  Parameters:
!
!    Input, integer NDP, the number of data points.
!
!    Input, real scalar XD(NDP), YD(NDP), the X and Y coordinates of the data.
!
!    Input, real scalar ZD(NDP), the data values.
!
!    Input, integer NT, the number of triangles.
!
!    Input, integer IPT(3*NT), the point numbers of the vertexes of the 
!    triangles.
!
!    Output, real scalar PD(5*NDP), the estimated zx, zy, zxx, zxy, and zyy values 
!    at the ith data point are to be stored as  the (5*i-4)th, (5*i-3)rd, 
!    (5*i-2)nd, (5*i-1)st and (5*i)th elements, respectively, where i = 
!    1, 2, ..., ndp.
!
!    Workspace, real scalar WK(NDP).
!
*/
//  implicit none

  //integer ndp
  //integer nt

  real scalar d12
  real scalar d23
  real scalar d31
  real scalar dx1
  real scalar dx2
  real scalar dy1
  real scalar dy2
  real scalar dz1
  real scalar dz2
  real scalar dzx1
  real scalar dzx2
  real scalar dzy1
  real scalar dzy2
  real scalar epsln
  epsln = 1.0E-06
  real scalar idp
  //real scalar ipt(3*nt)
  real vector ipti
  ipti=J(1,3,.)
  real scalar it
  real scalar iv
  real scalar jpd
  real scalar jpd0
  real scalar jpdmx
  real scalar jpt
  real scalar jpt0
  real scalar nt0
  //real scalar pd(5*ndp)
  real scalar vpx
  real scalar vpxx
  real scalar vpxy
  real scalar vpy
  real scalar vpyx
  real scalar vpyy
  real scalar vpz
  real scalar vpzmn
  real vector w1
  w1=J(1,3,.)
  real scalar w2
  w2=J(1,3,.)
  real scalar wi
  //real scalar wk(ndp)
  //real scalar xd(ndp)
  real scalar xv
  xv=J(1,3,.)
  //real scalar yd(ndp)
  real scalar yv
  yv=J(1,3,.)
  //real scalar zd(ndp)
  real scalar zv
  zv=J(1,3,.)
  real scalar zxv
  zxv=J(1,3,.)
  real scalar zyv
  zyv=J(1,3,.)

//  Preliminary processing.

  nt0 = nt

//  Clear the PD array.

  jpdmx = 5*ndp

  pd[1..jpdmx]=J(1,jpdmx,0.0E+00)

  wk[1..ndp]=J(1,ndp,0.0E+00)

//  Estimate ZX and ZY.

  for (it = 1; it<=nt0; it++) {
 
    jpt0 = 3*(it-1)

    for (iv = 1; iv<=3; iv++) {
      jpt = jpt0+iv
      idp = ipt[jpt]
      ipti[iv] = idp
      xv[iv] = xd[idp]
      yv[iv] = yd[idp]
      zv[iv] = zd[idp]
    }
 
    // Compute Vector Product of P1P2 and P1P3
    dx1 = xv[2]-xv[1]
    dy1 = yv[2]-yv[1]
    dz1 = zv[2]-zv[1]
    dx2 = xv[3]-xv[1]
    dy2 = yv[3]-yv[1]
    dz2 = zv[3]-zv[1]
    vpx = dy1*dz2-dz1*dy2
    vpy = dz1*dx2-dx1*dz2
    vpz = dx1*dy2-dy1*dx2
 

    vpzmn = abs(dx1*dx2+dy1*dy2)*epsln

    // Adjustment based on Rocky Mountain paper
    if ( abs(vpz) > vpzmn ) {
 
      // Compute distance between each pair of points in the triangle
      d12 = sqrt((xv[2]-xv[1])^2+(yv[2]-yv[1])^2)
      d23 = sqrt((xv[3]-xv[2])^2+(yv[3]-yv[2])^2)
      d31 = sqrt((xv[1]-xv[3])^2+(yv[1]-yv[3])^2)
	  
	  // Compute weights (reciprocal of the product of the paired distances)
      w1[1] = 1.0E+00 / (d31*d12)
      w1[2] = 1.0E+00 / (d12*d23)
      w1[3] = 1.0E+00 / (d23*d31)
      w2[1] = vpz*w1[1]
      w2[2] = vpz*w1[2]
      w2[3] = vpz*w1[3]
 
      // Sum up 3 vectors
      for (iv = 1; iv<=3; iv++) {
        idp = ipti[iv]
        jpd0 = 5*(idp-1)
        wi = (w1[iv]^2)*w2[iv]
        pd[jpd0+1] = pd[jpd0+1]+vpx*wi
        pd[jpd0+2] = pd[jpd0+2]+vpy*wi
        wk[idp] = wk[idp]+vpz*wi
      }
 
    }
  }
 
  for (idp = 1; idp<=ndp; idp++) {
    jpd0 = 5*(idp-1)
    pd[jpd0+1] = -pd[jpd0+1]/wk[idp]
    pd[jpd0+2] = -pd[jpd0+2]/wk[idp]
  }

//  Estimate ZXX, ZXY, and ZYY.

  for (it = 1; it<=nt0; it++) {
 
    jpt0 = 3*(it-1)
 
    for (iv = 1; iv<=3; iv++) {
      jpt = jpt0+iv
      idp = ipt[jpt]
      ipti[iv] = idp
      xv[iv] = xd[idp]
      yv[iv] = yd[idp]
      jpd0 = 5*(idp-1)
      zxv[iv] = pd[jpd0+1]
      zyv[iv] = pd[jpd0+2]
    }
 
    dx1 = xv[2]-xv[1]
    dy1 = yv[2]-yv[1]
    dzx1 = zxv[2]-zxv[1]
    dzy1 = zyv[2]-zyv[1]
    dx2 = xv[3]-xv[1]
    dy2 = yv[3]-yv[1]
    dzx2 = zxv[3]-zxv[1]
    dzy2 = zyv[3]-zyv[1]
    vpxx = dy1*dzx2-dzx1*dy2
    vpxy = dzx1*dx2-dx1*dzx2
    vpyx = dy1*dzy2-dzy1*dy2
    vpyy = dzy1*dx2-dx1*dzy2
    vpz = dx1*dy2-dy1*dx2
    vpzmn = abs(dx1*dx2+dy1*dy2)*epsln
 
    if ( abs(vpz) > vpzmn ) {
 
      d12 = sqrt((xv[2]-xv[1])^2+(yv[2]-yv[1])^2)
      d23 = sqrt((xv[3]-xv[2])^2+(yv[3]-yv[2])^2)
      d31 = sqrt((xv[1]-xv[3])^2+(yv[1]-yv[3])^2)
      w1[1] = 1.0E+00 /(d31*d12)
      w1[2] = 1.0E+00 /(d12*d23)
      w1[3] = 1.0E+00 /(d23*d31)
      w2[1] = vpz*w1[1]
      w2[2] = vpz*w1[2]
      w2[3] = vpz*w1[3]
 
      for (iv = 1; iv<=3; iv++) {
        idp = ipti[iv]
        jpd0 = 5*(idp-1)
        wi = (w1[iv]^2)*w2[iv]
        pd[jpd0+3] = pd[jpd0+3]+vpxx*wi
        pd[jpd0+4] = pd[jpd0+4]+(vpxy+vpyx)*wi
        pd[jpd0+5] = pd[jpd0+5]+vpyy*wi
      }
 
    }
 
  }
 
  for (idp = 1; idp<=ndp; idp++) {
    jpd0 = 5*(idp-1)
    pd[jpd0+3] = -pd[jpd0+3]/wk[idp]
    pd[jpd0+4] = -pd[jpd0+4]/(2.0*wk[idp])
    pd[jpd0+5] = -pd[jpd0+5]/wk[idp]
  }
 
  return
}


void idcldp(real scalar NDP, real vector XD, real vector YD, real scalar NCP, real vector IPC)
{
// Subroutine required by old version of IDPDRV
/*
SUBROUTINE  IDCLDP(NDP,XD,YD,NCP,IPC)                             ID002720
C THIS SUBROUTINE SELECTS SEVERAL DATA POINTS THAT ARE CLOSEST
C TO EACH OF THE DATA POINT.
C THE INPUT PARAMETERS ARE
C     NDP = NUMBER OF DATA POINTS,
C     XD,YD = ARRAYS OF DIMENSION NDP CONTAINING THE X AND Y
C           COORDINATES OF THE DATA POINTS,
C     NCP = NUMBER OF DATA POINTS CLOSEST TO EACH DATA
C           POINTS.
C THE OUTPUT PARAMETER IS
C     IPC = INTEGER ARRAY OF DIMENSION NCP*NDP, WHERE THE
C           POINT NUMBERS OF NCP DATA POINTS CLOSEST TO
C           EACH OF THE NDP DATA POINTS ARE TO BE STORED.
C THIS SUBROUTINE ARBITRARILY SETS A RESTRICTION THAT NCP MUST
C NOT EXCEED 25.
C THE LUN CONSTANT IN THE DATA INITIALIZATION STATEMENT IS THE
C LOGICAL UNIT NUMBER OF THE STANDARD OUTPUT UNIT AND IS,
C THEREFORE, SYSTEM DEPENDENT.
C DECLARATION STATEMENTS
      DIMENSION   XD(100),YD(100),IPC(400)
      DIMENSION   DSQ0(25),IPC0(25)
      DATA  NCPMX/25/, LUN/6/
C STATEMENT FUNCTION
      DSQF(U1,V1,U2,V2)=(U2-U1)**2+(V2-V1)**2
*/
real scalar NCPMX 
NCPMX=25
real vector DSQ0, IPC0
DSQ0=J(1,NCPMX,.)
IPC0=J(1,NCPMX,.)
IPC=J(1,NCP*NDP,.)


//C PRELIMINARY PROCESSING
L10:
      NDP0=NDP
      NCP0=NCP

      if((NDP0<2) | (NCP0<1) |  (NCP0>NCPMX) |  (NCP0>=NDP0))    {
	    _error(2090,"IDCLPD: IMPROPER INPUT PARAMETER VALUE(S)")
	    return
     }

//C CALCULATION
L20:
      for (IP1=1; IP1<=NDP0; IP1++) {
//C - SELECTS NCP POINTS.
        X1=XD[IP1]
        Y1=YD[IP1]
        J1=0
        DSQMX=0.0
        for   (IP2=1; IP2<=NDP0; IP2++) {
          if(IP2 == IP1)  goto L22
          DSQI=dsqf(X1,Y1,XD[IP2],YD[IP2])
          J1=J1+1
          DSQ0[J1]=DSQI
          IPC0[J1]=IP2
          if(DSQI <= DSQMX)    goto L21
          DSQMX=DSQI
          JMX=J1
L21:
          if(J1 >= NCP0)  goto L23
L22:
        }
L23:
        IP2MN=IP2+1
        if(IP2MN >  NDP0)      goto L30
        for   (IP2=IP2MN; IP2<=NDP0; IP2++) {
          if(IP2 == IP1)  goto L25
          DSQI=dsqf(X1,Y1,XD[IP2],YD[IP2])
          if(DSQI >= DSQMX)    goto L25
          DSQ0[JMX]=DSQI
          IPC0[JMX]=IP2
          DSQMX=0.0
          for   (J1=1; J1<=NCP0; J1++) {
            if(DSQ0[J1] <= DSQMX)   goto L24
            DSQMX=DSQ0[J1]
            JMX=J1
L24:

          }
L25:
        }    
//C - CHECKS IF ALL THE NCP+1 POINTS ARE COLLINEAR.
L30:
        IP2=IPC0[1]
        DX12=XD[IP2]-X1
        DY12=YD[IP2]-Y1
        for   (J3=2;J3<=NCP0; J3++) {
          IP3=IPC0[J3]
          DX13=XD[IP3]-X1
          DY13=YD[IP3]-Y1
          if((DY13*DX12-DX13*DY12) != 0.0)    goto L50
        }
//C - SEARCHES FOR THE CLOSEST NONCOLLINEAR POINT.
L40:
        NCLPT=0
        for   (IP3=1;IP3<=NDP0; IP3++) {
          if(IP3 == IP1)       goto L43
          for   (J4=1;J4<=NCP0;J4++) {
            if(IP3 == IPC0[J4])     goto L43
          }       
          DX13=XD[IP3]-X1
          DY13=YD[IP3]-Y1
          if((DY13*DX12-DX13*DY12) == 0.0)    goto L43
          DSQI=dsqf(X1,Y1,XD[IP3],YD[IP3])
          if(NCLPT == 0)       goto L42
          if(DSQI >= DSQMN)    goto L43
L42:
          NCLPT=1
          DSQMN=DSQI
          IP3MN=IP3
L43:
        }
        if(NCLPT == 0) {
    	    _error(2091,"IDCLPD: ALL COLLINEAR DATA POINTS")
	        return
		}
        DSQMX=DSQMN
        IPC0[JMX]=IP3MN
//C - REPLACES THE LOCAL ARRAY FOR THE OUTPUT ARRAY.
L50:
        J1=(IP1-1)*NCP0
        for  (J2=1;J2<=NCP0;J2++) {
          J1=J1+1
          IPC[J1]=IPC0[J2]
        }
      }
/*
C ERROR EXIT
   90 WRITE (LUN,2090)
      GO TO 92
   91 WRITE (LUN,2091)
   92 WRITE (LUN,2092)  NDP0,NCP0
      IPC(1)=0
      RETURN
*/

return
}

void idpdrv_near ( real scalar NDP, real vector XD, real vector YD, real vector ZD, real scalar NCP, real vector IPC, real vector PD )
{
// Old version of IDPDRV that allows nearest neighbor derivatives

/*
C THIS SUBROUTINE ESTIMATES PARTIAL DERIVATIVES OF THE FIRST AND
C SECOND ORDER AT THE DATA POINTS.
C THE INPUT PARAMETERS ARE
C     NDP = NUMBER OF DATA POINTS,
C     XD,YD,ZD = ARRAYS OF DIMENSION NDP CONTAINING THE X,
C           Y, AND Z COORDINATES OF THE DATA POINTS,
C     NCP = NUMBER OF ADDITIONAL DATA POINTS USED FOR ESTI-
C           MATING PARTIAL DERIVATIVES AT EACH DATA POINT,
C     IPC = INTEGER ARRAY OF DIMENSION NCP*NDP CONTAINING
C           THE POINT NUMBERS OF NCP DATA POINTS CLOSEST TO
C           EACH OF THE NDP DATA POINTS.
C THE OUTPUT PARAMETER IS
C     PD  = ARRAY OF DIMENSION 5*NDP, WHERE THE ESTIMATED
C           ZX, ZY, ZXX, ZXY, AND ZYY VALUES AT THE DATA
C           POINTS ARE TO BE STORED.
*/
//C DECLARATION STATEMENTS
//    DIMENSION   XD(100),YD(100),ZD(100),IPC(400),PD(500)
      real scalar  NMX,NMY,NMZ,NMXX,NMXY,NMYX,NMYY
	  PD=J(1,5*NDP,.)
//C PRELIMINARY PROCESSING
L10:
      NDP0=NDP
      NCP0=NCP
      NCPM1=NCP0-1
//C ESTIMATION OF ZX AND ZY
L20:
   for (IP0=1; IP0<=NDP0; IP0++) {
        X0=XD[IP0]
        Y0=YD[IP0]
        Z0=ZD[IP0]
        NMX=0.0
        NMY=0.0
        NMZ=0.0
        JIPC0=NCP0*(IP0-1)
        for (IC1=1; IC1<=NCPM1; IC1++) {
          JIPC=JIPC0+IC1
          IPI=IPC[JIPC]
          DX1=XD[IPI]-X0
          DY1=YD[IPI]-Y0
          DZ1=ZD[IPI]-Z0
          IC2MN=IC1+1
          for (IC2=IC2MN; IC2<=NCP0; IC2++) {
            JIPC=JIPC0+IC2
            IPI=IPC[JIPC]
            DX2=XD[IPI]-X0
            DY2=YD[IPI]-Y0
            DNMZ=DX1*DY2-DY1*DX2

            if(DNMZ == 0.0)    goto  L22
            DZ2=ZD[IPI]-Z0
            DNMX=DY1*DZ2-DZ1*DY2
            DNMY=DZ1*DX2-DX1*DZ2

            if(DNMZ >= 0.0)    goto  L21
            DNMX=-DNMX
            DNMY=-DNMY
            DNMZ=-DNMZ
L21:
            NMX=NMX+DNMX
            NMY=NMY+DNMY
            NMZ=NMZ+DNMZ

L22:
          }
        }
        JPD0=5*IP0
        PD[JPD0-4]=-NMX/NMZ
        PD[JPD0-3]=-NMY/NMZ
      }
//C ESTIMATION OF ZXX, ZXY, AND ZYY
L30:
     for (IP0=1; IP0<=NDP0; IP0++) {
        JPD0=JPD0+5
        X0=XD[IP0]
        JPD0=5*IP0
        Y0=YD[IP0]
        ZX0=PD[JPD0-4]
        ZY0=PD[JPD0-3]
        NMXX=0.0
        NMXY=0.0
        NMYX=0.0
        NMYY=0.0
        NMZ =0.0
        JIPC0=NCP0*(IP0-1)
        for    (IC1=1; IC1<=NCPM1; IC1++) {
          JIPC=JIPC0+IC1
          IPI=IPC[JIPC]
          DX1=XD[IPI]-X0
          DY1=YD[IPI]-Y0
          JPD=5*IPI
          DZX1=PD[JPD-4]-ZX0
          DZY1=PD[JPD-3]-ZY0
          IC2MN=IC1+1
          for  ( IC2=IC2MN; IC2<=NCP0; IC2++) {
            JIPC=JIPC0+IC2
            IPI=IPC[JIPC]
            DX2=XD[IPI]-X0
            DY2=YD[IPI]-Y0
            DNMZ =DX1*DY2 -DY1*DX2
            if(DNMZ == 0.0)    goto  L32
            JPD=5*IPI
            DZX2=PD[JPD-4]-ZX0
            DZY2=PD[JPD-3]-ZY0
            DNMXX=DY1*DZX2-DZX1*DY2
            DNMXY=DZX1*DX2-DX1*DZX2
            DNMYX=DY1*DZY2-DZY1*DY2
            DNMYY=DZY1*DX2-DX1*DZY2
            if(DNMZ >= 0.0)    goto  L31
            DNMXX=-DNMXX
            DNMXY=-DNMXY
            DNMYX=-DNMYX
            DNMYY=-DNMYY
            DNMZ =-DNMZ
L31:
            NMXX=NMXX+DNMXX
            NMXY=NMXY+DNMXY
            NMYX=NMYX+DNMYX
            NMYY=NMYY+DNMYY
            NMZ =NMZ +DNMZ
L32:
          }
        }
        PD[JPD0-2]=-NMXX/NMZ
        PD[JPD0-1]=-(NMXY+NMYX)/(2.0*NMZ)
        PD[JPD0]  =-NMYY/NMZ

      }
      return
}


void idptip ( real scalar ndp, real vector xd, real vector yd, real vector zd, real scalar nt, real vector ipt, real scalar nl, real vector ipl, real vector pdd, real scalar iti, real scalar xii, real scalar yii, real scalar zii )
{
/*
!
!*******************************************************************************
!
!! IDPTIP performs interpolation, determining a value of Z given X and Y.
!
!
!  Modified:
!
!    19 February 2001
!
!  Parameters:
!
!    Input, integer NDP, the number of data values.
!
!    Input, real scalar XD(NDP), YD(NDP), the X and Y coordinates of the data.
!
!    Input, real scalar ZD(NDP), the data values.
!
!    Input, integer NT, the number of triangles.
!
!    Input, ipt = integer array of dimension 3*nt containing the
!    point numbers of the vertexes of the triangles,
!
!    Input, integer NL, the number of border line segments.
!
!    Input, integer IPL(3*NL), the point numbers of the end points of the 
!    border line segments and their respective triangle numbers,
!
!    Input, real  PDD(5*NDP). the partial derivatives at the data points,
!
!    Input, integer ITI, triangle number of the triangle in which lies
!    the point for which interpolation is to be performed,
!
!    Input, real  XII, YII, the X and Y coordinates of the point for which
!    interpolation is to be performed.
!
!    Output, real  ZII, the interpolated Z value.
!
*/
//  implicit none

  //real scalar ndp
  //real scalar nl
  //real scalar nt

  real scalar a
  real scalar aa
  real scalar ab
  real scalar ac
  real scalar act2
  real scalar ad
  real scalar adbc
  //real scalar ap
  real scalar b
  real scalar bb
  real scalar bc
  real scalar bdt2
  //real scalar bp
  real scalar c
  real scalar cc
  real scalar cd
  //real scalar cp
  real scalar csuv
  real scalar d
  real scalar dd
  real scalar dlt
  //real scalar dp
  real scalar dx
  real scalar dy
  real scalar g1
  real scalar g2
  real scalar h1
  real scalar h2
  real scalar h3
  real scalar i
  real scalar idp
  real scalar il1
  real scalar il2
  //real scalar ipl(3*nl)
  //real scalar ipt(3*nt)
  real scalar it0
  //real scalar iti
  //real scalar itpv
  real scalar jipl
  real scalar jipt
  real scalar jpd
  real scalar jpdd
  real scalar kpd
  real scalar ntl
  real scalar lu
  real scalar lv
  real scalar p0
  //real scalar p00
  //real scalar p01
  //real scalar p02
  //real scalar p03
  //real scalar p04
  //real scalar p05
  real scalar p1
  //real scalar p10
  //real scalar p11
  //real scalar p12
  //real scalar p13
  //real scalar p14
  real scalar p2
  //real scalar p20
  //real scalar p21
  //real scalar p22
  //real scalar p23
  real scalar p3
  //real scalar p30
  //real scalar p31
  //real scalar p32
  real scalar p4
  //real scalar p40
  //real scalar p41
  //real scalar p5
  //real scalar p50
  real scalar pd
  pd=J(1,15,.)
  //real scalar pdd(5*ndp)
  real scalar thsv
  real scalar thus
  real scalar thuv
  real scalar thxu
  real scalar u
  real scalar v
  real scalar x
  x=J(1,3,.)
  //real scalar x0
  //real scalar xd(*)
  //real scalar xii
  real scalar y
  y=J(1,3,.)
  //real scalar y0
  //real scalar yd(*)
  //real scalar yii
  real scalar z
  z=J(1,3,.)
  real scalar z0
  //real scalar zd(*)
  //real scalar zii
  real scalar zu
  zu=J(1,3,.)
  real scalar zuu
  zuu=J(1,3,.)
  real scalar zuv
  zuv=J(1,3,.)
  real scalar zv
  zv=J(1,3,.)
  real scalar zvv
  zvv=J(1,3,.)



//  save /idpt/
/*
  common /idpt/ itpv,x0,y0,ap,bp,cp,dp, &
                p00,p10,p20,p30,p40,p50,p01,p11,p21,p31,p41, &
                p02,p12,p22,p32,p03,p13,p23,p04,p14,p05
*/
external real scalar itpv,x0,y0,ap,bp,cp,dp, p00,p10,p20,p30,p40,p50,p01,p11,p21,p31,p41, p02,p12,p22,p32,p03,p13,p23,p04,p14,p05

//  Preliminary processing

  it0 = iti
  ntl = nt+nl

  if ( it0 > ntl ) {
    il1 = trunc(it0/ntl)
    il2 = it0-il1*ntl

    if(il1==il2)      goto L40
    goto L60
  }

//  Calculation of ZII by interpolation.
//  Check if the necessary coefficients have been calculated.

  if ( it0 == itpv )     goto L30

//  Load coordinate and partial derivative values at the vertexes.

  jipt = 3*(it0-1)
  jpd = 0
 
  for (i = 1; i<=3; i++) {
 
    jipt = jipt+1
    idp = ipt[jipt]
    x[i] = xd[idp]
    y[i] = yd[idp]
    z[i] = zd[idp]
    jpdd = 5*(idp-1)
 
    for (kpd = 1; kpd<=5; kpd++) {
      jpd = jpd+1
      jpdd = jpdd+1
      pd[jpd] = pdd[jpdd]
    }
 
  }

//  Determine the coefficients for the coordinate system
//  transformation from the XY system to the UV system and vice versa.

  x0 = x[1]
  y0 = y[1]
  a = x[2]-x0
  b = x[3]-x0
  c = y[2]-y0
  d = y[3]-y0
  ad = a*d
  bc = b*c
  dlt = ad-bc
  ap =  d/dlt
  bp = -b/dlt
  cp = -c/dlt
  dp =  a/dlt

//  Convert the partial derivatives at the vertexes of the
//  triangle for the UV coordinate system.

  aa = a*a
  act2 = 2.0E+00 *a*c
  cc = c*c
  ab = a*b
  adbc = ad+bc
  cd = c*d
  bb = b*b
  bdt2 = 2.0E+00 *b*d
  dd = d*d
 
  for (i = 1; i<=3; i++) {
    jpd = 5*i
    zu[i] = a*pd[jpd-4]+c*pd[jpd-3]
    zv[i] = b*pd[jpd-4]+d*pd[jpd-3]
    zuu[i] = aa*pd[jpd-2]+act2*pd[jpd-1]+cc*pd[jpd]
    zuv[i] = ab*pd[jpd-2]+adbc*pd[jpd-1]+cd*pd[jpd]
    zvv[i] = bb*pd[jpd-2]+bdt2*pd[jpd-1]+dd*pd[jpd]
  }

//  Calculate the coefficients of the polynomial.

  p00 = z[1]
  p10 = zu[1]
  p01 = zv[1]
  p20 = 0.5E+00 * zuu[1]
  p11 = zuv[1]
  p02 = 0.5E+00 * zvv[1]
  h1 = z[2]-p00-p10-p20
  h2 = zu[2]-p10-zuu[1]
  h3 = zuu[2]-zuu[1]
  p30 =  10.0E+00 * h1 - 4.0E+00 * h2 + 0.5E+00 * h3
  p40 = -15.0E+00 * h1 + 7.0E+00 * h2           - h3
  p50 =   6.0E+00 * h1 - 3.0E+00 * h2 + 0.5E+00 * h3
  h1 = z[3]-p00-p01-p02
  h2 = zv[3]-p01-zvv[1]
  h3 = zvv[3]-zvv[1]
  p03 =  10.0E+00 * h1 - 4.0E+00 * h2 + 0.5E+00 * h3
  p04 = -15.0E+00 * h1 + 7.0E+00 * h2    -h3
  p05 =   6.0E+00 * h1 - 3.0E+00 * h2 + 0.5E+00 * h3
  lu = sqrt(aa+cc)
  lv = sqrt(bb+dd)
//  thxu = atan2(c,a)
  thxu = atan2(a,c)
//  thuv = atan2(d,b)-thxu
  thuv = atan2(b,d)-thxu
  csuv = cos(thuv)
  p41 = 5.0E+00*lv*csuv/lu*p50
  p14 = 5.0E+00*lu*csuv/lv*p05
  h1 = zv[2]-p01-p11-p41
  h2 = zuv[2]-p11-4.0E+00 * p41
  p21 =  3.0E+00 * h1-h2
  p31 = -2.0E+00 * h1+h2
  h1 = zu[3]-p10-p11-p14
  h2 = zuv[3]-p11- 4.0E+00 * p14
  p12 =  3.0E+00 * h1-h2
  p13 = -2.0E+00 * h1+h2
  thus = atan2(b-a,d-c)-thxu
  thsv = thuv-thus
  aa =  sin(thsv)/lu
  bb = -cos(thsv)/lu
  cc =  sin(thus)/lv
  dd =  cos(thus)/lv
  ac = aa*cc
  ad = aa*dd
  bc = bb*cc
  g1 = aa * ac*(3.0E+00*bc+2.0E+00*ad)
  g2 = cc * ac*(3.0E+00*ad+2.0E+00*bc)
  h1 = -aa*aa*aa*(5.0E+00*aa*bb*p50+(4.0E+00*bc+ad)*p41)-cc*cc*cc*(5.0E+00*cc*dd*p05+(4.0E+00*ad+bc)*p14)
  h2 = 0.5E+00 * zvv[2]-p02-p12
  h3 = 0.5E+00 * zuu[3]-p20-p21
  p22 = (g1*h2+g2*h3-h1)/(g1+g2)
  p32 = h2-p22
  p23 = h3-p22
  itpv = it0

//  Convert XII and YII to UV system.

L30:

  dx = xii-x0
  dy = yii-y0
  u = ap*dx+bp*dy
  v = cp*dx+dp*dy

//  Evaluate the polynomial.

  p0 = p00+v*(p01+v*(p02+v*(p03+v*(p04+v*p05))))
  p1 = p10+v*(p11+v*(p12+v*(p13+v*p14)))
  p2 = p20+v*(p21+v*(p22+v*p23))
  p3 = p30+v*(p31+v*p32)
  p4 = p40+v*p41
  p5 = p50
  zii = p0+u*(p1+u*(p2+u*(p3+u*(p4+u*p5))))
  return

//  Calculation of ZII by extrapolation in the rectangle.
//  Check if the necessary coefficients have been calculated.

L40:

  if(it0==itpv)     goto L50

//  Load coordinate and partial derivative values at the end
//  points of the border line segment.

  jipl = 3*(il1-1)
  jpd = 0
 
  for (i = 1; i<=2; i++) {
 
    jipl = jipl+1
    idp = ipl[jipl]
    x[i] = xd[idp]
    y[i] = yd[idp]
    z[i] = zd[idp]
    jpdd = 5*(idp-1)
 
    for (kpd = 1; kpd<=5; kpd++) {
      jpd = jpd+1
      jpdd = jpdd+1
      pd[jpd] = pdd[jpdd]
    }
 
  }

//  Determine the coefficients for the coordinate system
//  transformation from the XY system to the UV system
//  and vice versa.

  x0 = x[1]
  y0 = y[1]
  a = y[2]-y[1]
  b = x[2]-x[1]
  c = -b
  d = a
  ad = a*d
  bc = b*c
  dlt = ad-bc
  ap =  d/dlt
  bp = -b/dlt
  cp = -bp
  dp =  ap

//  Convert the partial derivatives at the end points of the
//  border line segment for the UV coordinate system.

  aa = a*a
  act2 = 2.0E+00 * a * c
  cc = c*c
  ab = a*b
  adbc = ad+bc
  cd = c*d
  bb = b*b
  bdt2 = 2.0E+00 * b * d
  dd = d*d
 
  for (i = 1; i<=2; i++) {
    jpd = 5*i
    zu[i] = a*pd[jpd-4]+c*pd[jpd-3]
    zv[i] = b*pd[jpd-4]+d*pd[jpd-3]
    zuu[i] = aa*pd[jpd-2]+act2*pd[jpd-1]+cc*pd[jpd]
    zuv[i] = ab*pd[jpd-2]+adbc*pd[jpd-1]+cd*pd[jpd]
    zvv[i] = bb*pd[jpd-2]+bdt2*pd[jpd-1]+dd*pd[jpd]
  }

//  Calculate the coefficients of the polynomial.

  p00 = z[1]
  p10 = zu[1]
  p01 = zv[1]
  p20 = 0.5E+00 * zuu[1]
  p11 = zuv[1]
  p02 = 0.5E+00 * zvv[1]

  h1 = z[2]-p00-p01-p02
  h2 = zv[2]-p01-zvv[1]
  h3 = zvv[2]-zvv[1]

  p03 =  10.0E+00 * h1 - 4.0E+00*h2+0.5E+00*h3
  p04 = -15.0E+00 * h1 + 7.0E+00*h2    -h3
  p05 =   6.0E+00 * h1 - 3.0E+00*h2+0.5E+00*h3

  h1 = zu[2]-p10-p11
  h2 = zuv[2]-p11

  p12 =  3.0E+00*h1-h2
  p13 = -2.0E+00*h1+h2
  p21 = 0.0E+00
  p23 = -zuu[2]+zuu[1]
  p22 = -1.5E+00*p23

  itpv = it0

//  Convert XII and YII to UV system.

L50:

  dx = xii-x0
  dy = yii-y0
  u = ap*dx+bp*dy
  v = cp*dx+dp*dy

//  Evaluate the polynomial.

  p0 = p00+v*(p01+v*(p02+v*(p03+v*(p04+v*p05))))
  p1 = p10+v*(p11+v*(p12+v*p13))
  p2 = p20+v*(p21+v*(p22+v*p23))
  zii = p0+u*(p1+u*p2)

  return

//  Calculation of ZII by extrapolation in the triangle.
//  Check if the necessary coefficients have been calculated.

L60:

  if ( it0 != itpv ) {

//  Load coordinate and partial derivative values at the vertex of the triangle.


    jipl = 3*il2-2
    idp = ipl[jipl]
    x0 = xd[idp]
    y0 = yd[idp]
    z0 = zd[idp]
    jpdd = 5*(idp-1)

    for (kpd = 1; kpd<=5; kpd++) {
      jpdd = jpdd+1
      pd[kpd] = pdd[jpdd]
    }

//  Calculate the coefficients of the polynomial.

    p00 = z0
    p10 = pd[1]
    p01 = pd[2]
    p20 = 0.5E+00*pd[3]
    p11 = pd[4]
    p02 = 0.5E+00*pd[5]
    itpv = it0

  }

//  Convert XII and YII to UV system.

  u = xii-x0
  v = yii-y0

//  Evaluate the polynomial.

  p0 = p00+v*(p01+v*p02)
  p1 = p10+v*p11
  zii = p0+u*(p1+u*p20)
 
return
}
void idsfft ( real scalar md, real scalar ncp, real scalar ndp, real vector xd, real vector yd, real vector zd, real scalar nxi, real scalar nyi, real scalar nzi, real vector xi, real vector yi, real matrix zi, real vector iwk, real vector wk )
{
/*
!
!*******************************************************************************
!
!! IDSFFT fits a smooth surface Z(X,Y) given irregular (X,Y,Z) data.
!
!
!  Discussion:
!
!    IDSFFT performs smooth surface fitting when the projections of the
!    data points in the (X,Y) plane are irregularly distributed.
!
!  Special conditions:
!
!    Inadequate work space IWK and WK may may cause incorrect results.
!
!    The data points must be distinct and their projections in the XY
!    plane must not be collinear, otherwise an error return occurs.
!
!  Parameters:
!
!    Input, integer MD, mode of computation (must be 1, 2, or 3,
!    else an error return will occur).
!
!    1, if this is the first call to this routine, or if the value of 
!    NDP has been changed from the previous call, or if the contents of 
!    the XD or YD arrays have been changed from the previous call.
!
!    2, if the values of NDP and the XD, YD arrays are unchanged from 
!    the previous call, but new values for XI, YI are being used.  If 
!    MD = 2 and NDP has been changed since the previous call to IDSFFT, 
!    an error return occurs.
!
!    3, if the values of NDP, NXI, NYI, XD, YD, XI, YI are unchanged 
!    from the previous call, i.e. if the only change on input to idsfft 
!    is in the ZD array.  If MD = 3 and NDP, nxi or nyi has been changed 
!    since the previous call to idsfft, an error return occurs.
!
!    Between the call with MD = 2 or MD = 3 and the preceding call, the 
!    iwk and wk work arrays should not be disturbed.
!
!    Input, integer NDP, the number of data points.  NDP must be at least 4.
!
!    Input, real  XD(NDP), YD(NDP), the X and Y coordinates of the data.
!
!    Input, real  ZD(NDP), the data values.
!
!    Input, integer NXI, NYI, the number of output grid points in the
!    X and Y directions.  NXI and NYI must each be at least 1.
!
!    Input, integer NZI, the first dimension of ZI.  NZI must be at
!    least NXI.
!
!    Input, real XI(NXI), YI(NYI), the X and Y coordinates of the grid
!    points.
!
!    Workspace, integer IWK(31*NDP+NXI*NYI).
!
!    Workspace, real WK(6*NDP).
!
!    Output, real ZI(NZI,NYI), contains the interpolated Z values at the
!    grid points.
!
*/
//  implicit none

  //real scalar ndp
  //real scalar nxi
  //real scalar nyi
  //real scalar nzi

  //real scalar ap
  //real scalar bp
  //real scalar cp
  //real scalar dp
  real scalar il1
  real scalar il2
  real scalar iti
  //real scalar itpv
  //real scalar iwk(31*ndp + nxi*nyi)
  real scalar ixi
  real scalar iyi
  real scalar izi
  real scalar jig0mn
  real scalar jig0mx
  real scalar jig1mn
  real scalar jig1mx
  real scalar jigp
  real scalar jngp
  real scalar jwigp
  real scalar jwigp0
  real scalar jwipl
  real scalar jwipt
  real scalar jwiwl
  real scalar jwiwp
  real scalar jwipc
  real scalar jwngp
  real scalar jwngp0
  real scalar jwwpd
  //real scalar md
  real scalar ngp0
  real scalar ngp1
  real scalar nl
  real scalar nngp
  real scalar nt
  //real scalar p00
  //real scalar p01
  //real scalar p02
  //real scalar p03
  //real scalar p04
  //real scalar p05
  //real scalar p10
  //real scalar p11
  //real scalar p12
  //real scalar p13
  //real scalar p14
  //real scalar p20
  //real scalar p21
  //real scalar p22
  //real scalar p23
  //real scalar p30
  //real scalar p31
  //real scalar p32
  //real scalar p40
  //real scalar p41
  //real scalar p50
  //real scalar wk(6*ndp)
  //real scalar x0
  //real scalar xd(ndp)
  //real scalar xi(nxi)
  //real scalar y0
  //real scalar yd(ndp)
  //real scalar yi(nyi)
  //real scalar zd(ndp)
  //real scalar zi(nzi,nyi)
  
  real vector ipt, ipl, iwl, iwp, ipc
  real vector ngp, igp
  real vector wpd
  real scalar tzi

/*
  save /idpt/
!
  common /idpt/ itpv,x0,y0,ap,bp,cp,dp, &
                p00,p10,p20,p30,p40,p50,p01,p11,p21,p31,p41, &
                p02,p12,p22,p32,p03,p13,p23,p04,p14,p05
*/
external real scalar itpv,x0,y0,ap,bp,cp,dp, p00,p10,p20,p30,p40,p50,p01,p11,p21,p31,p41, p02,p12,p22,p32,p03,p13,p23,p04,p14,p05

//  Error check.

  if ( md < 1 | md > 3 ) {
    _error(6,"IDSFFT - Fatal error:  Input parameter MD out of range.")
    return
  }
 
  if (ncp!=-1 & (ncp < 2 | ncp>min((25,ndp))) ) {
     _error(10,"IDSFFT - Fatal error: Input parameter NCP out of range.")
    return
  }
  
  if ( ndp < 4 ) {
    _error(7,"IDSFFT - Fatal error: Input parameter NDP out of range.")
    return
  }
 
  if ( nxi < 1 | nyi < 1 ) {
    _error(8,"IDSFFT - Fatal error:  Input parameter NXI or NYI out of range.")
    return
  }
 
  if ( nxi > nzi ) {
    _error(9,"IDSFFT - Fatal error:  Input parameter NZI is less than NXI.")
    return
  }
 
  if ( md <= 1 ) {
    iwk[1] = ncp
    iwk[2] = ndp
  }
  else {
    if ( ncp != iwk[1] ) {
      _error(10,"IDSFFT - Fatal error:  MD = 2 or 3 but ncp was changed since last call.")
      return
    }

    if ( ndp != iwk[2] ) {
      _error(11,"IDSFFT - Fatal error:  MD = 2 or 3 but ndp was changed since last call.")
      return
    }
  
  }


  if ( md <= 2 ) {

    iwk[3] = nxi
    iwk[4] = nyi
  }  
  else {
 
    if ( nxi != iwk[3] ) {
      _error(12,"IDSFFT - Fatal error: MD = 3 but nxi was changed since last call.")
      return
    }
 
    if ( nyi != iwk[4] ) {
      _error(13,"IDSFFT - Fatal error:  MD = 3 but nyi was changed since last call.")
      return
    }

  }

//  Allocation of storage areas in the IWK array.

  jwipt = 16
  jwiwl = 6*ndp+1
  jwngp0 = jwiwl-1
  jwipl = 24*ndp+1
  jwiwp = 30*ndp+1
  //jwigp0 = 31*ndp
  jwwpd = 5*ndp+1
  jwipc=27*ndp+1
  jwigp0=max((31,27+ncp))*ndp
  
//  Triangulate the XY plane.

  if ( md == 1 ) {
    
	ipt=iwk[|jwipt\.|]
    ipl=iwk[|jwipl\.|]
    iwl=iwk[|jwiwl\.|]
    iwp=iwk[|jwiwp\.|]
//    idtang ( ndp, xd, yd, nt, iwk[|jwipt\.|], nl, iwk[|jwipl\.|], iwk[|jwiwl\.|], iwk[|jwiwp\.|], wk )
    
    idtang ( ndp, xd, yd, nt, ipt, nl, ipl, iwl, iwp, wk )

    iwk[|jwipt\.|]=ipt
    iwk[|jwiwl\.|]=iwl   // Why not done before?
    iwk[|jwipl\.|]=ipl
	iwk[|jwiwp\.|]=iwp   // Why not done before?
	
	iwk[5] = nt
    iwk[6] = nl
 
    if ( nt == 0 ) {
      return
    }
  }
  else {

    nt = iwk[5]
    nl = iwk[6]

  }

// DETERMINES NCP POINTS CLOSEST TO EACH DATA POINT.  (FOR MD=1)
//   50 IF(MD0.GT.1)   GO TO 60
//      CALL IDCLDP(NDP0,XD,YD,NCP0,IWK(JWIPC))
//      IF(IWK(JWIPC).EQ.0)      RETURN

   if (md == 1 & ncp>=2) {
      idcldp(ndp, xd, yd, ncp, ipc)

      //iwk[|jwipc\.|]=ipc     // For some reason this doesn't work here
      for (i=1; i<=cols(ipc); i++) {
        iwk[jwipc+i-1]=ipc[i]
      }
	  
	  if (iwk[jwipc]==0) {
	     return
	  }
   }
   
 
  
// Sort output grid points in ascending order of the triangle
// number and the border line segment number.

  if ( md <= 2 ) {
  
     ipt=iwk[|jwipt\.|]
     ipl=iwk[|jwipl\.|]
     ngp=iwk[|jwngp0+1\.|]
     igp=iwk[|jwigp0+1\.|]
//   idgrid ( xd, yd, nt, iwk[|jwipt\.|], nl, iwk[|jwipl\.|], nxi, nyi, xi, yi, iwk[|jwngp0+1\.|], iwk[|jwigp0+1\.|] )

     idgrid ( xd, yd, nt, ipt, nl, ipl, nxi, nyi, xi, yi, ngp, igp )
     iwk[|jwngp0+1\.|]=ngp
     iwk[|jwigp0+1\.|]=igp
  }

// Estimate partial derivatives at all data points.


//  idpdrv ( ndp, xd, yd, zd, nt, iwk[|jwipt\.|], wk, wk[|jwwpd\.|] )
  if (ncp==-1) {
    wpd=wk[|jwwpd\.|]
    idpdrv ( ndp, xd, yd, zd, nt, ipt, wk, wpd )
    wk[|jwwpd\.|]=wpd
  }
  else {
    ipc=iwk[|jwipc\.|]
    idpdrv_near ( ndp, xd, yd, zd, ncp, ipc, wk)
    iwk[|jwipc\.|]=ipc
  }  
 
 

// Interpolate the ZI values.

  itpv = 0
  jig0mx = 0
  jig1mn = nxi*nyi+1
  nngp = nt+2*nl
 
  for (jngp = 1; jngp<=nngp; jngp++) {

    iti = jngp

    if ( jngp > nt ) {
      il1 = trunc((jngp-nt+1)/2)
      il2 = trunc((jngp-nt+2)/2)
      if(il2>nl) {
        il2 = 1
      }
      iti = il1*(nt+nl)+il2
    }

    jwngp = jwngp0+jngp
    ngp0 = iwk[jwngp]

	if ( ngp0 != 0 ) {

      jig0mn = jig0mx+1
      jig0mx = jig0mx+ngp0
 
      for (jigp = jig0mn; jigp<=jig0mx; jigp++) {

        jwigp = jwigp0+jigp
        izi = iwk[jwigp]   
        iyi = trunc((izi-1)/nxi)+1
        ixi = izi-nxi*(iyi-1)
        
		ipt=iwk[|jwipt\.|]
        ipl=iwk[|jwipl\.|]
		tzi=.
//        idptip ( ndp, xd, yd, zd, nt, iwk[|jwipt\.|], nl, iwk[|jwipl\.|], wk, iti, xi[ixi], yi[iyi], zi[ixi,iyi] )
        idptip ( ndp, xd, yd, zd, nt, ipt, nl, ipl, wk, iti, xi[ixi], yi[iyi], tzi )
        zi[ixi,iyi]=tzi

      }
 
    }

    jwngp = jwngp0+2*nngp+1-jngp
    ngp1 = iwk[jwngp]

    if ( ngp1 != 0 ) {

      jig1mx = jig1mn-1
      jig1mn = jig1mn-ngp1
 
      for (jigp = jig1mn; jigp<=jig1mx; jigp++) {

        jwigp = jwigp0+jigp
        izi = iwk[jwigp]
        iyi = trunc((izi-1)/nxi+1)
        ixi = izi-nxi*(iyi-1)

		ipt=iwk[|jwipt\.|]
        ipl=iwk[|jwipl\.|]
		tzi=.
//        idptip ( ndp, xd, yd, zd, nt, iwk[|jwipt\.|], nl, iwk[|jwipl\.|], wk, iti, xi[ixi], yi[iyi], zi[ixi,iyi] )

        idptip ( ndp, xd, yd, zd, nt, ipt, nl, ipl, wk, iti, xi[ixi], yi[iyi], tzi )
        zi[ixi,iyi]=tzi
      }

    }
 
  }
 
  return
}

// Second version of spdt() that is used only by IDTANG
real scalar t_spdt(real scalar u1, real scalar v1, real scalar u2, real scalar v2,real scalar u3,real scalar v3) 
{
  return((u2-u1)*(u3-u1)+(v2-v1)*(v3-v1))
}
// Second version of vpdt() that is used only by IDTANG
real scalar t_vpdt(real scalar u1, real scalar v1, real scalar u2, real scalar v2,real scalar u3,real scalar v3) 
{
  return((v3-v1)*(u2-u1)-(u3-u1)*(v2-v1))
}

void idtang ( real scalar ndp, real vector xd, real vector yd, real scalar nt, real vector ipt, real scalar nl, real vector ipl, real vector iwl, real vector iwp, real vector wk )
{
/*
!
!*******************************************************************************
!
!! IDTANG performs triangulation.
!
!
!  Discussion:
!
!    The routine divides the XY plane into a number of triangles according to
!    given data points in the plane, determines line segments that form
!    the border of data area, and determines the triangle numbers
!    corresponding to the border line segments.
!
!    At completion, point numbers of the vertexes of each triangle
!    are listed counter-clockwise.  Point numbers of the end points
!    of each border line segment are listed counter-clockwise,
!    listing order of the line segments being counter-clockwise.
!
!  Parameters:
!
!    Input, integer NDP, the number of data points.
!
!    Input, real XD(NDP), YD(NDP), the X and Y coordinates of the data.
!
!    Output, integer NT, the number of triangles,
!
!    Output, integer IPT(6*NDP-15), where the point numbers of the 
!    vertexes of the IT-th triangle are to be stored as entries
!    3*IT-2, 3*IT-1, and 3*IT, for IT = 1 to NT.
!
!    Output, integer NL, the number of border line segments.
!
!    Output, integer IPL(6*NDP), where the point numbers of the end 
!    points of the (il)th border line segment and its respective triangle
!    number are to be stored as the (3*il-2)nd, (3*il-1)st, and (3*il)th
!    elements, il = 1,2,..., nl.
!
!    Workspace, integer IWL(18*NDP),
!
!    Workspace, integer IWP(NDP),
!
!    Workspace, real WK(NDP).
!
*/
//  implicit none

  //integer ndp

  //real scalar dsqf
  real scalar dsqi
  real scalar dsqmn
  real scalar epsln 
  epsln = 1.0E-06
  //real scalar idxchg
  real scalar il
  real scalar ilf
  real scalar iliv
  real scalar ilt3
  real scalar ilvs
  real scalar ip
  real scalar ip1
  real scalar ip1p1
  real scalar ip2
  real scalar ip3
  //real scalar ipl(6*ndp)
  real scalar ipl1
  real scalar ipl2
  real scalar iplj1
  real scalar iplj2
  real scalar ipmn1
  real scalar ipmn2
  //real scalar ipt(6*ndp-15)
  real scalar ipt1
  real scalar ipt2
  real scalar ipt3
  real scalar ipti
  real scalar ipti1
  real scalar ipti2
  real scalar irep
  real scalar it
  real scalar it1t3
  real scalar it2t3
  real vector itf
  itf=J(1,2,.)
  real scalar its
  real scalar itt3
  real scalar itt3r
  //real scalar iwl(18*ndp)
  //real scalar iwp(ndp)
  real scalar ixvs
  real scalar ixvspv
  real scalar jl1
  real scalar jl2
  real scalar jlt3
  real scalar jp
  real scalar jp1
  real scalar jp2
  real scalar jpc
  real scalar jpmn
  real scalar jpmx
  real scalar jwl
  real scalar jwl1
  real scalar jwl1mn
  //real scalar nl
  real scalar nl0
  real scalar nlf
  real scalar nlfc
  real scalar nlft2
  real scalar nln
  real scalar nlnt3
  real scalar nlsh
  real scalar nlsht3
  real scalar nlt3
  real scalar nrep
  nrep = 100
  //real scalar nt
  real scalar nt0
  real scalar ntf
  real scalar ntt3
  real scalar ntt3p3
  real scalar sp
  //real scalar spdt
  //real scalar u1
  //real scalar u2
  //real scalar u3
  //real scalar v1
  //real scalar v2
  //real scalar v3
  real scalar vp
  //real scalar vpdt
  //real scalar wk(ndp)
  real scalar x1
  real scalar x2
  real scalar x3
  //real scalar xd(ndp)
  real scalar xdmp
  real scalar y1
  real scalar y2
  real scalar y3
  //real scalar yd(ndp)
  real scalar ydmp
/*
!
!  Statement functions
!
  dsqf(u1,v1,u2,v2) = (u2-u1)**2+(v2-v1)**2
  spdt(u1,v1,u2,v2,u3,v3) = (u2-u1)*(u3-u1)+(v2-v1)*(v3-v1)
  vpdt(u1,v1,u2,v2,u3,v3) = (v3-v1)*(u2-u1)-(u3-u1)*(v2-v1)
*/


//  Preliminary processing

  if ( ndp < 4 ) {
    _error(12,"IDTANG - Fatal error: Input parameter NDP out of range.")
    return
  }

//  Determine IPMN1 and IPMN2, the closest pair of data points.

  dsqmn = dsqf(xd[1],yd[1],xd[2],yd[2])
  ipmn1 = 1
  ipmn2 = 2
 
  for (ip1 = 1; ip1<=ndp-1; ip1++) {
 
    x1 = xd[ip1]
    y1 = yd[ip1]
    ip1p1 = ip1+1

 
    for (ip2 = ip1p1; ip2<=ndp; ip2++) {
 
      dsqi = dsqf(x1,y1,xd[ip2],yd[ip2])

      if ( dsqi == 0.0 ) {
        _error(13,"IDTANG - Fatal error:  Two of the input data points are identical.")
        return
      }
 
      if(dsqi<dsqmn) {
        dsqmn = dsqi
        ipmn1 = ip1
        ipmn2 = ip2

      }
 
    }
 
  }

//  Compute the midpoint of the closest two data points.

  xdmp = (xd[ipmn1]+xd[ipmn2]) / 2.0E+00
  ydmp = (yd[ipmn1]+yd[ipmn2]) / 2.0E+00

//  Sort the other (NDP-2) data points in ascending order of
//  distance from the midpoint and store the sorted data point
//  numbers in the IWP array.

  jp1 = 2
  for (ip1 = 1; ip1<=ndp; ip1++) {
    if ( ip1 != ipmn1 & ip1 != ipmn2 ) {
      jp1 = jp1+1
      iwp[jp1] = ip1
      wk[jp1] = dsqf(xdmp,ydmp,xd[ip1],yd[ip1])
    }
  }

  for (jp1 = 3; jp1<=ndp-1; jp1++) {
 
    dsqmn = wk[jp1]
    jpmn = jp1

    for (jp2 = jp1; jp2<=ndp; jp2++) {
      if(wk[jp2]<dsqmn) {
        dsqmn = wk[jp2]
        jpmn = jp2
      }
    }
 
    its = iwp[jp1]
    iwp[jp1] = iwp[jpmn]
    iwp[jpmn] = its
    wk[jpmn] = wk[jp1]
 
  }

  
//  If necessary, modify the ordering in such a way that the
//  first three data points are not collinear.

  x1 = xd[ipmn1]
  y1 = yd[ipmn1]
  x2 = xd[ipmn2]
  y2 = yd[ipmn2]
 
  for (jp = 3; jp<=ndp; jp++) {
    ip = iwp[jp]
    sp = t_spdt(xd[ip],yd[ip],x1,y1,x2,y2)
    vp = t_vpdt(xd[ip],yd[ip],x1,y1,x2,y2)
    if ( abs(vp) > ( abs(sp) * epsln ) )   goto L37
  }
 
  _error(14,"IDTANG - Fatal error: All collinear data points.")
  return
  
L37:
 
  if ( jp != 3 ) {
 
    jpmx = jp
 
    for (jpc = 4; jpc<=jpmx; jpc++) {
      jp = jpmx+4-jpc
      iwp[jp] = iwp[jp-1]
    }
 
    iwp[3] = ip
 
  }

//  Form the first triangle.  

//  Store point numbers of the vertexes of the triangle in the IPT array, 
//  store point numbers of the border line segments and the triangle number in
//  the IPL array.

  ip1 = ipmn1
  ip2 = ipmn2
  ip3 = iwp[3]
 
  if ( t_vpdt(xd[ip1],yd[ip1],xd[ip2],yd[ip2],xd[ip3],yd[ip3]) < 0.0E+00 ) {
    ip1 = ipmn2
    ip2 = ipmn1
  }
 
  nt0 = 1
  ntt3 = 3
  ipt[1] = ip1
  ipt[2] = ip2
  ipt[3] = ip3
  nl0 = 3
  nlt3 = 9
  ipl[1] = ip1
  ipl[2] = ip2
  ipl[3] = 1
  ipl[4] = ip2
  ipl[5] = ip3
  ipl[6] = 1
  ipl[7] = ip3
  ipl[8] = ip1
  ipl[9] = 1
  

//  Add the remaining data points, one by one.

  for (jp1 = 4; jp1<=ndp; jp1++) {

    ip1 = iwp[jp1]
    x1 = xd[ip1]
    y1 = yd[ip1]

//  Determine the first invisible and visible border line segments, iliv and
//  ilvs.

    for (il = 1; il <= nl0; il++) {

      ip2 = ipl[3*il-2]
      ip3 = ipl[3*il-1]
      x2 = xd[ip2]
      y2 = yd[ip2]
      x3 = xd[ip3]
      y3 = yd[ip3]
      sp = t_spdt(x1,y1,x2,y2,x3,y3)
      vp = t_vpdt(x1,y1,x2,y2,x3,y3)

      if ( il == 1 ) {
        ixvs = 0
        if(vp<=(abs(sp)*(-epsln)))   ixvs = 1
        iliv = 1
        ilvs = 1
        goto L53
      }

      ixvspv = ixvs

      if ( vp <= (abs(sp)*(-epsln)) ) {
        ixvs = 1
        if(ixvspv==1)      goto L53
        ilvs = il
        if(iliv!=1)        goto L54
        goto L53
      }

      ixvs = 0

      if ( ixvspv != 0 ) {
        iliv = il
        if(ilvs!=1)        goto L54
      }

L53:

    }

    if(iliv==1 & ilvs==1)  ilvs = nl0

L54:

    if(ilvs<iliv)  ilvs = ilvs+nl0

//  Shift (rotate) the IPL array to have the invisible border
//  line segments contained in the first part of the array.

L55:   
 
    if ( iliv != 1 ) {
 
      nlsh = iliv-1
      nlsht3 = nlsh*3
 
      for (jl1 = 1; jl1<=nlsht3; jl1++) {
        jl2 = jl1+nlt3
        ipl[jl2] = ipl[jl1]
      }
 
      for (jl1 = 1; jl1<=nlt3; jl1++) {
        jl2 = jl1+nlsht3
        ipl[jl1] = ipl[jl2]
      }
 
      ilvs = ilvs-nlsh
 
    }

//  Add triangles to the IPT array, 
//  update border line segments in the IPL array, 
//  set flags for the border line segments to be reexamined in the IWL array.

    jwl = 0
    for (il = ilvs; il<=nl0; il++) {
      ilt3 = il*3
      ipl1 = ipl[ilt3-2]
      ipl2 = ipl[ilt3-1]
      it   = ipl[ilt3]

//  Add a triangle to the IPT array.

      nt0 = nt0+1
      ntt3 = ntt3+3
      ipt[ntt3-2] = ipl2
      ipt[ntt3-1] = ipl1
      ipt[ntt3]   = ip1

//  Update border line segments in the IPL array.

      if ( il == ilvs ) {
        ipl[ilt3-1] = ip1
        ipl[ilt3]   = nt0
      }
 
      if ( il == nl0 ) {
        nln = ilvs+1
        nlnt3 = nln*3
        ipl[nlnt3-2] = ip1
        ipl[nlnt3-1] = ipl[1]
        ipl[nlnt3]   = nt0
      }

//  Determine the vertex that does not lie on the border
//  line segments.

      itt3 = it*3
      ipti = ipt[itt3-2]
 
      if ( ipti == ipl1 | ipti == ipl2 ) {
        ipti = ipt[itt3-1]
        if ( ipti == ipl1 | ipti == ipl2 ) {
          ipti = ipt[itt3]
        }
      }

//  Check if the exchange is necessary.

      if ( idxchg(xd,yd,ip1,ipti,ipl1,ipl2) != 0 ) {

//  Modify the IPT array.

        ipt[itt3-2] = ipti
        ipt[itt3-1] = ipl1
        ipt[itt3]   = ip1
        ipt[ntt3-1] = ipti
        if(il==ilvs)  ipl[ilt3] = it
        if(il==nl0 & ipl[3]==it)      ipl[3] = nt0

//  Set flags in the IWL array.

        jwl = jwl+4
        iwl[jwl-3] = ipl1
        iwl[jwl-2] = ipti
        iwl[jwl-1] = ipti
        iwl[jwl]   = ipl2

      }
 
    }
 
    nl0 = nln
    nlt3 = nlnt3
    nlf = jwl/2
    if ( nlf == 0 ) {
      goto L79
    }

//  Improve triangulation.

    ntt3p3 = ntt3+3

    for (irep = 1; irep<=nrep; irep++) {

      for (ilf = 1; ilf<=nlf; ilf++) {

        ipl1 = iwl[2*ilf-1]
        ipl2 = iwl[2*ilf]

//  Locate in the ipt array two triangles on both sides of
//  the flagged line segment.

        ntf = 0

        for (itt3r = 3; itt3r<=ntt3; itt3r=itt3r+3) {
          itt3 = ntt3p3-itt3r
          ipt1 = ipt[itt3-2]
          ipt2 = ipt[itt3-1]
          ipt3 = ipt[itt3]
          if(ipl1!=ipt1 &   ipl1!=ipt2 &    ipl1!=ipt3)      goto L71
          if(ipl2!=ipt1 &   ipl2!=ipt2 &    ipl2!=ipt3)      goto L71
          ntf = ntf+1
          itf[ntf] = trunc(itt3/3)
          if(ntf==2)     goto L72
L71:
        }

        if ( ntf < 2 )       goto L76

//  Determine the vertexes of the triangles that do not lie
//  on the line segment.

L72:

        it1t3 = itf[1]*3
        ipti1 = ipt[it1t3-2]
        if(ipti1!=ipl1 &   ipti1!=ipl2)    goto L73
        ipti1 = ipt[it1t3-1]

        if ( ipti1 == ipl1 | ipti1 == ipl2 ) {
          ipti1 = ipt[it1t3]
        }

L73:

        it2t3 = itf[2]*3
        ipti2 = ipt[it2t3-2]
        if(ipti2!=ipl1 &   ipti2!=ipl2)    goto L74
        ipti2 = ipt[it2t3-1]
        if(ipti2!=ipl1 &   ipti2!=ipl2)    goto L74
        ipti2 = ipt[it2t3]

//  Check if the exchange is necessary.

L74: 

        if(idxchg(xd,yd,ipti1,ipti2,ipl1,ipl2)==0) {
          goto L76
        }

//  Modify the IPT array.

        ipt[it1t3-2] = ipti1
        ipt[it1t3-1] = ipti2
        ipt[it1t3]   = ipl1
        ipt[it2t3-2] = ipti2
        ipt[it2t3-1] = ipti1
        ipt[it2t3]   = ipl2

//  Set new flags.

        jwl = jwl+8
        iwl[jwl-7] = ipl1
        iwl[jwl-6] = ipti1
        iwl[jwl-5] = ipti1
        iwl[jwl-4] = ipl2
        iwl[jwl-3] = ipl2
        iwl[jwl-2] = ipti2
        iwl[jwl-1] = ipti2
        iwl[jwl]   = ipl1
        for (jlt3 = 3; jlt3<=nlt3; jlt3=jlt3+3) {
          iplj1 = ipl[jlt3-2]
          iplj2 = ipl[jlt3-1]

          if((iplj1==ipl1 &   iplj2==ipti2) |  (iplj2==ipl1 &   iplj1==ipti2)) {
                               ipl[jlt3] = itf[1]
          }

          if((iplj1==ipl2 &   iplj2==ipti1) |  (iplj2==ipl2 &   iplj1==ipti1)) {
                              ipl[jlt3] = itf[2]
          }

        }

L76:

      }
 
      nlfc = nlf
      nlf = trunc(jwl/2)

//  Reset the IWL array for the next round.

      if ( nlf == nlfc ) goto L79

      jwl1mn = 2*nlfc+1
      nlft2 = nlf*2
 
      for (jwl1 = jwl1mn; jwl1<=nlft2; jwl1++) {
        jwl = jwl1+1-jwl1mn
        iwl[jwl] = iwl[jwl1]
      }
 
      nlf = trunc(jwl/2)

    }

L79:

  }

//  Rearrange the IPT array so that the vertexes of each triangle
//  are listed counter-clockwise.

  for (itt3 = 3; itt3<=ntt3; itt3=itt3+3) {
 
    ip1 = ipt[itt3-2]
    ip2 = ipt[itt3-1]
    ip3 = ipt[itt3]
 
    if(t_vpdt(xd[ip1],yd[ip1],xd[ip2],yd[ip2],xd[ip3],yd[ip3]) < 0.0E+00 ) {
      ipt[itt3-2] = ip2
      ipt[itt3-1] = ip1
    }

  }
 
  nt = nt0
  nl = nl0

  return
}
real scalar idxchg ( real vector x, real vector y, real scalar i1, real scalar i2, real scalar i3, real scalar i4 )
{
/*
!
!*******************************************************************************
!
!! IDXCHG determines whether two triangles should be exchanged.
!
!
!  Discussion:
!
!    The max-min-angle criterion of C L Lawson is used.
!
!  Parameters:
!
!    Input, real scalar X(*), Y(*), the coordinates of the data points.
!
!    Input, integer I1, I2, I3, I4, are the point numbers of
!    four points P1, P2, P3, and P4 that form a quadrilateral,
!    with P3 and P4 connected diagonally.
!
!    Output, integer IDXCHG, reports whether the triangles should be
!    exchanged:
!    0, no exchange is necessary.
!    1, an exchange is necessary.
!
*/
//  implicit none

  real scalar a1sq
  real scalar a2sq
  real scalar a3sq
  real scalar a4sq
  real scalar c1sq
  real scalar c3sq
  real scalar epsln
  epsln = 1.0E-06
  //real scalar i1
  //real scalar i2
  //real scalar i3
  //real scalar i4
  real scalar idx
  real scalar idxchg
  real scalar s1sq
  real scalar s2sq
  real scalar s3sq
  real scalar s4sq
  real scalar u1
  real scalar u2
  real scalar u3
  real scalar u4
  //real scalar x(*)
  real scalar x1
  real scalar x2
  real scalar x3
  real scalar x4
  //real scalar y(*)
  real scalar y1
  real scalar y2
  real scalar y3
  real scalar y4

//  Preliminary processing

  x1 = x[i1]
  y1 = y[i1]
  x2 = x[i2]
  y2 = y[i2]
  x3 = x[i3]
  y3 = y[i3]
  x4 = x[i4]
  y4 = y[i4]

  idx = 0
 
  u3 = (y2-y3)*(x1-x3)-(x2-x3)*(y1-y3)
  u4 = (y1-y4)*(x2-x4)-(x1-x4)*(y2-y4)
 
  if ( u3 * u4 > 0.0E+00 ) {
 
    u1 = (y3-y1)*(x4-x1)-(x3-x1)*(y4-y1)
    u2 = (y4-y2)*(x3-x2)-(x4-x2)*(y3-y2)

    a1sq = (x1-x3)^2+(y1-y3)^2
    a4sq = (x4-x1)^2+(y4-y1)^2
    c1sq = (x3-x4)^2+(y3-y4)^2
    a2sq = (x2-x4)^2+(y2-y4)^2
    a3sq = (x3-x2)^2+(y3-y2)^2
    c3sq = (x2-x1)^2+(y2-y1)^2

    s1sq = u1*u1 / (c1sq*max((a1sq,a4sq)))    
    s2sq = u2*u2 / (c1sq*max((a2sq,a3sq)))
    s3sq = u3*u3 / (c3sq*max((a3sq,a1sq)))
    s4sq = u4*u4 / (c3sq*max((a4sq,a2sq)))
 
    if ( min (( s3sq, s4sq )) - min (( s1sq, s2sq )) > epsln ) {
      idx = 1
    }
 
  }
 
  idxchg = idx

  return (idxchg)
}
end

// My version of cvxhull (Same as the original but just included here so it doesn't have to be bundled)
* 1.1		RAR 21 January 2004, with improved coding
* 1.0.1	RAR 12 December 2003, with suggestions from NJC
* 1.0		RAR 22 November 2003 - England won RU World Cup
program bip_cvxhull, sortpreserve
	version 8.0
	syntax varlist(min=2 max=2) [if] [in] ///
	[ , Hulls(numlist int min=0 max=2 >0) MDPlot(int 8) ///
	 GROup(varname) SELect(numlist int min=0 >0 sort) ///
	 MEAns PREfix(string) noREPort noRETain ///
	 SCATopt(string) noGRAph SAVing(string)]

	loc reporting = ("`report'" != "noreport")
	if "`retain'" == "noretain" & "`graph'" == "nograph" {
		di as err "That combination of options is silly: quitting now"
		exit 498
	}

* Nick Cox thinks this parsing is still flakey 
	if `"`saving'"' != "" { //  Check saving filename   
		tokenize `"`saving'"', parse(",")
		args saving comma replace
		if index(`"`saving'"', ".") == 0 loc saving `"`saving'.gph"'
		capture confirm file `saving'
		if _rc == 0 { /* existing file */
			if "`replace'" != "replace" {
				di as err "Invalid save file - did you mean to replace?"
				exit 198
			}
			loc saving `"`saving',replace"'
		}
		else confirm new file `saving' // invalid file - unless new
		loc saving `"saving("`saving'")"'
	}

	if "`hulls'" == "" {
		loc hulls = 1 
		loc hullgap = 1 // Set default values
	}
	else {
		tokenize "`hulls'"
		loc hulls = `1'
		if   "`2'" == ""  loc hullgap = 1
		else              loc hullgap = `2'
	}

	marksample touse // Deal with `if', `in' & missing
	qui count if `touse'
	if r(N) == 0 error 2000

	tempvar sample grp scratch count pts hullno
	qui gen `sample'=`touse' // & remember all points considered
	if "`group'" == "" {     // group variable may be absent, string or numeric
		qui gen `grp' = 1
		loc select "1"
		loc maxgrp = 1
	}
	else {
		qui egen `grp' = group(`group') if `touse', label        
		if "`select'" != "" {
			loc j = 0
			foreach i in `select' {
				loc ++j
			}
			loc maxgrp = `j'  // no of items
		}
		else {
			su `grp', meanonly
			loc maxgrp = r(max)
			loc select "1 / `maxgrp'"
		}
		qui {
			egen `scratch' = eqany(`grp'), values(`select')
			replace `touse' = `touse' * `scratch'
		}
		if `reporting' di as txt "Codes for groups based on " as res "`group'"
		label list `grp'
	}

* Double check, in case group selection has dropped all obs
	qui count if `touse'
	if r(N) == 0 error 2000

	loc retd = 1 + int((`hulls'-1)/`hullgap')  // number of hulls
	loc hull = plural(`retd', "hull")
	loc gs = plural(`maxgrp', "group")
	if `reporting'  di as txt "Up to `retd' `hull' to be saved for `maxgrp' `gs'"

	if "`prefix'" == "" loc prefix "_cvxh"
	capture drop `prefix'*l
	capture drop `prefix'*r
	capture drop `prefix'grp
	capture drop `prefix'hull
	capture drop `prefix'pts
	capture drop `prefix'cnt
	capture drop `prefix'*mindex
	capture drop `prefix'*maxdex
	capture drop `scratch'

	tokenize `varlist'
	args y x 
	sort `grp' `x' `y' // within group, by ascending x then y

	qui {
		gen `count' = 0
		gen `pts' = 0
		gen `hullno' = 0
	}
	tempname gap
	loc gap = `hullgap' -1      // force retain hull 1
	loc maxhull = 0

***** Main loop ******************************************
	tempvar leftpath rightpath onhull  // re-use scratch for points on segment
	qui {
		gen `leftpath' = .    // set up outside loop to use replace
		gen `rightpath' = .   // within loop & save RAM allocation time
		gen `onhull' = 0
		gen `scratch' = 0
	}
	forvalues h = 1 / `hulls' { // b1 : brackets numbered for sanity! 
		qui count if `touse'    // stop when all points peeled
		if r(N) > 0  { // b2
		 	qui {
				replace `leftpath' = .
				replace `rightpath' = .
				replace `onhull' = 0
			}
			loc sp = 1          // Starting point
			loc notstarted = 1
			
			while `sp' <= _N  { // b3 scan all observations
				loc curgrp = `grp'[`sp']
				if !`touse'[`sp']  {
					loc ++sp    // ignore point & increment pointer
				}
				else {          // b4 - point processing ...
					while `grp'[`sp'] == `curgrp'  { // b5 within group
						if `notstarted' { // b6 mark first point of current group
							qui {
								replace `leftpath' = `y' in `sp'
								replace `rightpath' = `y' in `sp'
								replace `onhull' = (_n==`sp')
								replace `scratch' = 0
							} 
							loc leftcur = `sp'
							loc rightcur = `sp'
							loc sp1 = `sp'
							loc curgrp = `grp'[`sp']
							loc mindex = 1   
							loc notstarted = 0
							loc ++sp
						} 
						else  { // 6
							loc j = `leftcur' + 1
							loc maxL = -1
							loc maxD = 0
							loc found = 0 
							while `j'<=_N & `grp'[`j']==`curgrp' { // b7 find next left */
								if `touse'[`j']==1 {                 // b8
									loc d = sqrt( (`y'[`j'] - `y'[`leftcur'])^2 + (`x'[`j'] - `x'[`leftcur'])^2 )
									if float(`d') > 0 {  // b9
										loc cosa = (`y'[`j'] - `y'[`leftcur'])/ `d'
										if float(`cosa') > float(`maxL') { // b10 new leftmost direction
											loc maxL = `cosa'
											loc next = `j'
											qui replace `scratch' = (_n==`j')
											qui replace  `scratch' = 1 in `sp1'
											loc found = 1
										} 
										else {
											if float(`cosa') == float(`maxL') { // collinear
												if float(`d') > float(`maxD')  loc next = `j'
												qui replace `scratch' = 1 in `j'
												loc found = 1 
											}
										}
									} // 9
									else { // 9
										qui replace `onhull' = 1 in `j' // coincident with current point
										loc next = `j'
									} //9
								} // 8
								loc ++j
							} // 7
							qui replace `onhull' = (`onhull' | `scratch') 
							if `found' {
								qui {
									replace `leftpath' = `y' in `next'
									loc ++mindex
									loc leftcur = `next'
								} 
							} 
							
							loc j = `rightcur' + 1
							loc maxR = 1
							loc maxD = 0
							loc found = 0 
							while `j'<=_N & `grp'[`j']==`curgrp' { // b7 find next right
								if `touse'[`j']==1  { //8
									loc d = sqrt( (`y'[`j'] - `y'[`rightcur'])^2 + (`x'[`j'] - `x'[`rightcur'])^2 )
									if float(`d') > 0 { //9
										loc cosa = (`y'[`j'] - `y'[`rightcur']) / `d'
										if float(`cosa') < float(`maxR') { //10
											loc maxR = `cosa'
											loc next = `j'
											qui replace `scratch' = (_n==`j')
											qui replace  `scratch' = 1 in `sp1'
											loc found = 1 
										} 
										else {
											if float(`cosa') == float(`maxR')  { // collinear
												if float(`d') > float(`maxD')  loc next = `j'
												qui replace `scratch' = 1 in `j'
												loc found = 1
											} 
										}
									} //9
									else { //9
										qui replace `onhull' = 1 in `j'  // coincident
										loc next = `j'
									} //9
								} //8
								loc ++j
							} // 7
							qui replace `onhull' = (`onhull' | `scratch') 
							if `found' {
								qui {
									replace `rightpath' = `y' in `next' 
									loc ++mindex
									loc rightcur = `next'
								} 
							} 	
						
* Check if found a hull, or continue						
							loc sp = `leftcur'
							if `rightcur' < `leftcur' loc sp = `rightcur' 
							if `leftcur' == `rightcur'   { // hull closed
								qui {
									replace `hullno' = -`h' in `sp'
									replace `hullno' = `h' in `sp1'
									replace `count' = `mindex' - 1 in `sp1'  // last point double counted
									qui count if `onhull'
									replace `count' = r(N) in `sp'
									replace `pts' = `h' if `onhull'
									replace `touse' = 0 if `onhull'
								} 
								loc notstarted = 1
								while `grp'[`sp'] == `curgrp' {
									loc ++sp
								}
							} 
						} // e6
					} // e5 found end of group

					if `mindex' == 1  { // special case - single point hull
						qui {
							qui count if `onhull'
							replace `count' = r(N) in `sp1'
							replace `hullno' = `h' in `sp1'
                    		loc notstarted = 1
						} 
					} 
				} // e4 end point processing 
			} // e3 end loop over data
				
* Save hull if requested
			loc ++gap
			if `gap' == `hullgap' {
				loc ++maxhull
				qui {
				gen `prefix'`h'l = `leftpath'
				gen `prefix'`h'r = `rightpath'
				} 
				if `maxhull' <= `mdplot' loc hulllist "`prefix'1l-`prefix'`h'r"
				loc gap = 0                // restart count
				if `reporting' di as txt "  hull level `h' calculated and saved"
			} 
		} // e2 do nothing if no data points
	} // e1 exit loop when all hulls marked

***** Optional plot 
	if `"`graph'"' != "nograph" {
		if `reporting' di as txt "Graph will be plotted presently"
* Build and execute graph command ... as a very long macro text!
		loc colours "black black blue blue dkorange dkorange magenta magenta emerald emerald khaki khaki cyan cyan red red"
* Set up point plot and add line plots for each selected group
* RAR's preference for default horizontal y labels
		loc gr `"scatter `y' `x' if `sample',yti("`y'")yla(,angle(0))`saving' `scatopt'"'
		if "`means'" == "means" {
			tempvar ymean xmean
			egen `ymean' = mean(`y') if `select', by(`grp')
			egen `xmean' = mean(`x') if `select', by(`grp')
			loc gr `"`gr'||scatter `ymean' `xmean',ms(T)xti("`x'")"'
		} 
		foreach i of numlist `select' {
			loc gr `"`gr'||line `hulllist' `x' if `grp'==`i',clc(`colours')legend(off)"'
		} 
		`gr' // & execute macro command 
	} 
	
	if "`retain'" != "noretain" {
		qui {
			if "`group'" != "" gen `prefix'grp  = `grp'
			gen `prefix'hull = `hullno'
			gen `prefix'cnt  = `count'
			gen `prefix'pts = `pts'
		} 
	} 
	else {
		capture drop `prefix'*l `prefix'*r 
	}

	if `reporting' di as txt "cvxhull run"

end // of cvxhull


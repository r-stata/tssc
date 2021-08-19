*! whittle Stan Hurn/Ken Lindsay/Kit Baum
*! performs local Whittle and exact local Whittle estimation of the memory parameter d
*! 1.0.1 15apr2019
*! 1.0.2 26apr2019  remove adjust option
*! 1.0.3 20jun2019  add logic from gphudak
*! 1.0.4 01nov2019   ensure that d=1 is not passed to fracdiff

capt prog drop whittle
mata:mata clear
prog whittle, rclass byable(recall)

version 13
syntax varlist(numeric ts max=1) [if] [in] [, Powers(numlist >0 <1) DETRend EXACT]

loc qq qui
marksample touse 

// get time variables  
_ts timevar panelvar if `touse', sort onepanel
markout `touse' `timevar'
qui tsreport if `touse'
if r(N_gaps) {
	di as err "sample may not contain gaps"
	exit 498
}
loc st = string(`r(start)', "`r(tsfmt)'")
loc nd = string(`r(end)', "`r(tsfmt)'")

quietly count if `touse'
if `r(N)' == 0  error 2000
loc en = `r(N)'

// if powers not specified set default as 0.65
if "`powers'" == "" {
	loc powers = 0.65   
}

// do the appropriate detrending
tempvar xdt
if "`detrend'" == "detrend" {
	`qq' reg `varlist' `timevar' if `touse'
	loc dt "`varlist', detrended"
} 
else {
	`qq' reg `varlist' if `touse'
	loc dt "`varlist'"
}
qui predict double `xdt' if e(sample), res

// set up the format of the reporting
loc Npowers: word count `powers'
tempname whit
mat `whit' = J(`Npowers', 6, 0)
mat colnames `whit' = N power trunc d se ase
di as res _dup(60) "-"
di as res "    N   Power  Trunc   Est d      StdErr    Asy.StdErr"
di as res _dup(60) "-"

// call the routines 
tokenize `powers'
loc i 1
while "``i''" != "" {
	loc trunc = floor(`en'^``i'')
	loc eye = ``i''
	
	if "`exact'" == "" {
		mata: calcwhittle("`xdt'","`touse'",`trunc',"`st'","`nd'","`dt'")
	}
	else {
		mata: calcewhittle("`xdt'","`touse'",`trunc',"`st'","`nd'","`dt'")
	}

	di as res  %6.0f `en'   " "  %5.2f `eye' " " %5.0f `trunc' ///
	"   "  %8.0g d__ "  "  %8.4g se__ "  " %8.4g ase__ " 

	mat `whit'[`i',1] = `en', ``i'', `trunc', d__, se__, ase__
	loc i = `i' + 1
}
di as res _dup(60) "-"
return local cmdname "whittle"
return local varname `varlist'
mat `whit' = `whit''
ret matrix whittle `whit'

end

version 13
mata:

void function calcwhittle(
                          string scalar xdt,
                          string scalar touse,
						  real scalar m,
						  string scalar st,
						  string scalar nd, 
						  string scalar dt)
{
	st_view(x=.,.,xdt,touse)
	n=rows(x)
		
	// call routine to do local Whittle estimation
	el  = whittle(x,m) 			
	
	// pass results to Stata
 	st_numscalar("N",n)
 	st_numscalar("d__",el[1,1])
 	st_numscalar("se__",el[1,2])
 	st_numscalar("ase__",sqrt(0.25)/sqrt(m))
}

real vector whittle(x,m)
{
/* ---------------------------------------------------------------------------
  Returns the estimated value of the fractional difference parameter, d.
  
  		INPUT	x: data (n*1 vector)
 				m: truncation number
 
  		OUTPUT	d: estimated fractional difference parameter
 
  This program only works for a single time series. Estimation is by 
  Golden Section Search. 
  Search is hardwired to the interval [-0.5,1.0]
 
----------------------------------------------------------------------------- */

	n = rows(x)
 
	// computing the Fourier coefficients  
	tn = 1..n 
	tm = 1..m 
	fac = 2*pi()/n
	arg = J(m,n,fac)
	tt  = tm'*tn
	arg = arg :* tt
	tc  = cos(arg)
	ts  = sin(arg)
	wxr =  (tc * x)  :/ n
	wxi = -(ts * x)  :/ n

	// power spectrum  
	Ix = (wxr:^2 + wxi:^2) 

	// Fourier angular frequencies  
	lambda = fac :* tn'
	Ix     = Ix[1..m]
	lambda = lambda[1..m]

	// Golden Section Search - pre-assigned values of xl,xr fixes search interval to (-0.5,1.0)  
	xl = -0.5
	xr =  1.0
	gratio = 0.618033988749890
    tol = 5.0e-7

	llm    = mean(log(lambda))
	xlower = xl+(xr-xl)*gratio^2	
	vlower = log( mean(lambda:^(2*xlower) :* Ix )) - 2*xlower*llm 
	xupper = xl+(xr-xl)*gratio
	vupper = log( mean(lambda:^(2*xupper) :* Ix )) - 2*xupper*llm 

	do  {
        if ( vlower>=vupper ) {
            xl = xlower 
            xlower = xupper 
            vlower = vupper 
            xupper = xl+(xr-xl)*gratio 
            vupper = log( mean(lambda:^(2*xupper) :* Ix )) - 2*xupper*llm 
        } else {
            xr = xupper;
            xupper = xlower 
            vupper = vlower 
            xlower = xl+(xr-xl)*gratio^2
            vlower = log( mean(lambda:^(2*xlower) :* Ix )) - 2*xlower*llm 
        }
		
	} while ( xr-xl>tol )

	dnew = 0.5*(xr+xl)

    //  test boundaries 
	flag = 1
    if ( (dnew+0.5) < 5.0*tol ) {
        printf("\nUnreliable Whittle estimate - value too close to lower boundary\n") 
		flag = 0
    }
    if ( (1.0-dnew) < 5.0*tol ) {
        printf("\nUnreliable Whittle estimate - value too close to upper boundary\n")
		flag = 0
    } 
    
	// set up values to return 
    if (flag) {
		d0 = mean( lambda:^(2*dnew) :* Ix )
		d1 = 2*mean( log(lambda) :* lambda:^(2*dnew) :* Ix ) 
		d2 = 4*mean( (log(lambda)):^2  :* lambda:^(2*dnew) :* Ix )
		se = d0/(sqrt(m)*sqrt(d0*d2-d1^2))
		x2 = (dnew,se )
		return(x2 )   
	} else {
			return( dnew , -999 )
	}
}

// ---------------------------------------------------------------------------
void function calcewhittle(
					      string scalar xdt,
                          string scalar touse,
						  real scalar m,
						  string scalar st,
						  string scalar nd,
						  string scalar dt)
{
	st_view(x=.,.,xdt,touse)
	n=rows(x)
 	
	// call routine to do exact local Whittle estimation
	el3 = ewhittle(x,m)	
	

	// pass results back to Stata
	st_numscalar("N",n)
	st_numscalar("d__",el3[1,1])
	st_numscalar("se__",el3[1,2])
	st_numscalar("ase__",sqrt(0.25)/sqrt(m))

}

/*-----------------------------------------------------------------------------
  Compute the exact Whittle likelihood Shimotsu and Phillips (2004) and
  Shimotsu (2004).
 
  INPUT	x: data (n*1 vector)
 		d: fractional index  
		m: truncation number
-----------------------------------------------------------------------------*/
real scalar function ewfeval(x,d,m)

{
	n=rows(x)
	dx=fracdiff(x,d)   // calling built-in Mata function

	// computing the Fourier coefficients  
	tn  = 1..n 
	tm  = 1..m 
	fac = 2*pi()/ n
	arg = J(m,n,fac)
	tt  = tm'*tn
	arg = arg :* tt
	tc  = cos(arg)
	ts  = sin(arg)
	wxr =  (tc * dx)  :/  n 
	wxi = -(ts * dx)  :/  n 

	// power spectrum  
	Ix = (wxr:^2 + wxi:^2) 
	
	// Fourier angular frequencies  
	lambda = fac :* tn'
	Ix     = Ix[1..m]
	lambda = lambda[1..m]

	// return function value for exact local Whittle likelihood
	g = mean(Ix) 
	r = log(g) - 2*d*mean(log(lambda)) 
	
	return(r)
}

/*-----------------------------------------------------------------------------
  Compute the fractional difference index based on the exact Whittle likelihood 
  of Shimotsu and Phillips (2004) and Shimotsu (2004).
 
  INPUT	x: data (n*1 vector)
		m: truncation number
-----------------------------------------------------------------------------*/
real vector ewhittle(x,m)
{

	// Golden Section Search - pre-assigned values of xl,xr fixes search interval to (-0.5,1.0)  
	xl = -0.5
	xr =  1.0
	gratio = 0.618033988749890
    tol = 5.0e-7

	xlower = xl+(xr-xl)*gratio^2	
	vlower = ewfeval(x,xlower,m)
	xupper = xl+(xr-xl)*gratio
	vupper = ewfeval(x,xupper,m)

	do  {
        if ( vlower>=vupper ) {
            xl = xlower 
            xlower = xupper 
            vlower = vupper 
            xupper = xl+(xr-xl)*gratio 
            vupper = ewfeval(x,xupper,m)  
        } else {
            xr = xupper
            xupper = xlower 
            vupper = vlower 
            xlower = xl+(xr-xl)*gratio^2
            vlower = ewfeval(x,xlower,m)  
        }
	} while ( xr-xl>tol )

	dnew = 0.5*(xr+xl)

    //  test boundaries
	flag = 1
    if ( (dnew+0.5) < 0.01 ) {
        printf("\nUnreliable eWhittle estimate - value too close to lower boundary\n") 
		flag = 0
    }
    if ( (1.0-dnew) < 0.01 ) {
        printf("\nUnreliable eWhittle estimate - value too close to upper boundary\n") 
		flag = 0
    } 
    
    
	//  finite difference estimate of second derivative  
    if (flag) {
		dl = dnew*0.99
		du = dnew*1.01

		fl = ewfeval(x,dl,m)  
		fc = ewfeval(x,dnew,m)  
		fu = ewfeval(x,du,m)  

		d2 = 1.0e4*(fl - 2*fc + fu)/dnew^2

		//  Test for convexity and return
		if ( d2 > 0 ) {
			x2 = ( dnew, sqrt(1/(m*d2)) )
			return( x2 ) 
		
		} else {  
        printf("\neWhittle likelihood function is not convex\n"); 
        return( dnew , 0 ) 		
		}  
	} else {
		return( dnew , -999 )
	}
}

end


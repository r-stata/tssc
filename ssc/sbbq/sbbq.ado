*! 1.1 Philippe Bracke 13jan2012
*--- phase and window arguments inverted in mbbq: corrected
*--- putmata and getmata substituted by st_data and st_store
* 1.0 Philippe Bracke 22may2011


program sbbq, byable(recall) sortpreserve
	version 9.2
	
	syntax varname(numeric) [if] [in] ///
		[, Phase(integer 2) Window(integer 2) Cycle(integer 5)]
	marksample touse, novarlist
	
	tempvar t
	g `t' = _n
	g `varlist'_point = .

	mata: `varlist' = st_data( ., "`varlist'")
	mata: point=mbbq(`varlist',`phase',`window',`cycle')
	mata: st_store(., "`varlist'_point", point)
	
	qui: count if `varlist'_point==+1 & `touse'
	local i = r(N)
	qui: count if `varlist'_point==-1 & `touse'
	local j = r(N)
	if `i'==1 {
		local peaks peak
	}
	else {
		local peaks peaks
	}
	if `j'==1 {
		local troughs trough
	}
	else {
		local troughs troughs
	}
	di "`i' `peaks' and `j' `troughs' found"
end


version 9.2
mata:
real colvector mbbq(
	real colvector x,
	real scalar phase,
	real scalar halfw,
	real scalar cycle)
{
	real scalar n
	real scalar k
	real matrix A
	real colvector point
	real scalar np
	real scalar i
	real scalar j
	real colvector _seq
	real scalar f
	real scalar l
					

	// Start and end of the time series
	f = first(x)
	l = last(x,f)
	

	// First turning point
	for (k=halfw+f; k<=l-halfw; k++) {

		if (ltpoint(k,halfw,x)==1) {
			A = x[k], k, 1
			break
		}
		
		else if (ltpoint(k,halfw,x)==-1) {
			A= x[k], k, -1
			break
		}
	}

	if (k<l-halfw) {				//there is at least one turning point
		// Second turning point
		stpoint(A,x,halfw,l,phase)

			
		// Other turning points
		otpoint(A,x,halfw,l,phase,cycle)


		// Sometimes first/last turning points are not local minima/maxima
		// If so, remove them
		trimp(A,x,f,l)
		
		
		// Create variable
		n=rows(x)
		point = J(n,1,0) 		// initialise, all zeros 
		np = rows(A)		

		for (i=1; i<=np; i++) {		// write down peaks (+1) 
			j = A[i,2]				// and troughs (-1) where needed
			point[j]=A[i,3]
		}

		return(point)
	}
	
	else {							// if there are no turning points
		point = J(n,i,0)
		return(point)
	}
}


////////////////////////////////////////////////////////////
// FIRST and LAST: Start and end of the time series
real scalar first(
	real vector x)
{
	real scalar f
	real scalar n
	real scalar k
	
	n = rows(x)
	
	for (k=1;k<=n;k++) { 	//			find first non-missing point
		if (x[k]!=.) {
			f = k
			break
		}
	}
	
	return(f)
}

real scalar last(
	real vector x,
	real scalar f)
{
	real scalar l
	real scalar n
	real scalar k
	
	n = rows(x)
	
	for (k=f;k<=n;k++) { 	//			find last non-missing point
		if (x[k]==.) {
			l = k-1
			break
		}
		else {
			l = k
		}
	}
	
	return(l)
}

////////////////////////////////////////////////////////////
// LTPOINT: is this obs a local maximum or minimum?
real scalar ltpoint(
	real scalar k, 
	real scalar halfw,
	real colvector x) 
{
	real scalar  a						// declarations
	real colvector y
	
	y = x[ -halfw+k :: k+halfw ]	// window
	
	if ( x[k] == max(y) ) 	a=1		// max
	else if ( x[k] == min(y) )  a=-1 // min
	else a=0
	
	return(a)
}

////////////////////////////////////////////////////////////
// STPOINT: Second turning point
real matrix stpoint(
	real matrix A,
	real colvector x,
	real scalar halfw,
	real scalar l,
	real scalar phase) 
{
	real scalar nr
	real scalar k
	
	for (k=A[1,2]+1; k<=l-halfw; k++) {
			
		nr = rows(A)			// 	# turning points
				
		if (nr<2) {				
			
			// potential peak
			if ( ltpoint(k,halfw,x)==1) { 
				// 2 peaks in a row
				if (A[1,3]==1 & x[k] >= A[1,1] ) { 
					A[1, .] = x[k] , k , 1
				}
				// first point was a trough
				else if ( (A[1,3]==-1) & (k-A[1,2] >= phase) ) { 
					A =  A \ x[k] , k, 1
				}	
			}
		
			// potential trough
			if ( ltpoint(k,halfw,x)==-1) { 
				// 2 troughs in a row
				if (A[1,3]==-1 & x[k] <= A[1,1] ) { 
					A[1, .] = x[k] , k , -1
				}
				// first point was a peak				
			else if ( A[1,3]==1 & k-A[1,2] >= phase) { 
					A = A \ x[k] , k , -1
				}	
			}
		}

		else {
			break
		}
	}
}

////////////////////////////////////////////////////////////
// OTPOINT: Other turning points
real matrix otpoint(
	real matrix A,
	real colvector x,
	real scalar halfw,
	real scalar l,
	real scalar phase,
	real scalar cycle) 
{
	real scalar nr
	real scalar k
	real scalar nrn
	
	for (k=A[2,2]+1; k<=l-halfw; k++) {
		
		nr = rows(A)			// 	# turning points


		// potential peak
		if ( ltpoint(k,halfw,x)==1) { 
			// two peaks in a row
			if (A[nr,3]==1 & x[k] >= A[nr,1]) { 
					A[nr, .] = x[k] , k , 1
			}
			
			// last point was a trough
			else if (A[nr,3]==-1) {	
				if (k-A[nr,2] >= phase & k-A[nr-1,2] >= cycle) {
					A =  A \ x[k] , k, 1
				}
				
				// violations of censoring rules
				else if (k-A[nr,2]<phase | k-A[nr-1,2]<cycle) {
					if (nr>2) {		
						if  (A[nr-2,1]<A[nr,1] & x[k]>A[nr-1,1]) {
							nrn= nr-1
							A = A[ (1::nrn), .]
							A[nrn,.] = x[k] , k, 1
						}
					}
				}
			}
		}
		
		// potential trough
		else if ( ltpoint(k,halfw,x)==-1) {
			// two troughs in a row
			if ( A[nr,3]==-1 & x[k] <= A[nr,1]) {
					A[nr,.] = x[k], k, -1		
			}
			
			// last point was a peak
			else if (A[nr,3]==1) {
				if (k-A[nr,2] >= phase & k-A[nr-1,2] >= cycle) {
					A =  A \ x[k] , k, -1
				}
				
				// violations of censoring rules
				else if (k-A[nr,2]<phase | k-A[nr-1,2]<cycle) {
					if (nr>2) {
						if (A[nr-2,1]>A[nr,1] & nr>2 & x[k] < A[nr-1,1]) {  
							nrn= nr-1
							A = A[ (1::nrn), .]
							A[nrn,.] = x[k] , k, -1
						}	
					}
				}
			}
		}
		
	}
}

////////////////////////////////////////////////////////////
// TRIMP: Trim A if first and last turning points are not good
real matrix trimp(
	real matrix A,
	real colvector x,
	real scalar f,
	real scalar l) 
{	
	real scalar np
	real scalar npn
	
	real scalar fpt
	real scalar lpt
	
	real vector y
	
	
	// Start
	np = rows(A)		
	fpt=A[1,2]
	y = x[f::fpt]

	if ( 	(A[1,3]==1 & A[1,1]!=max(y)) 	| 
			(A[1,3]==-1 & A[1,1]!=min(y)) 	) {
		A = A[2::np,.] 
	}

	// End
	np = rows(A)		
	lpt=A[np,2]
	y = x[lpt::l]
	npn = np-1
	if ( 	(A[np,3]==1 & A[np,1]!=max(y))	|
			(A[np,3]==-1 & A[np,1]!=min(y))	) {
		A = A[1::npn,.] 
	}
}

end

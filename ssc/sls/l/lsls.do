/*******************************************************************************
 Define Mata functions to be used in do-files as needed.
 These functions are used for semiparametric estimations.

Updates
2013-05-28: allow multiple independent vars/weights in conditional expectation
	calculation. Conditional expectation should be calculated for each 
	column of the y matrix and returned in a matrix of the same dimension.

*******************************************************************************/

*! lsls.do version 1.0 2014-10-11 
*! author: Michael Barker mdb96@georgetown.edu

version 11
program drop _all

* Clear Mata 
mata 
mata clear
mata set matafavor speed
// mata set matalnum on
mata set matastrict on

/*******************************************************************************
 Define CEXP parameter structure 
*******************************************************************************/
struct cexp_parameters {
    pointer(function) scalar method
    pointer(function) scalar kernel
    pointer(function) scalar dkernel
    pointer(function) scalar bwidth

    real scalar twice 
    real vector optbwidth

    // Use these if it becomes necessary to include trim var in structure.
    // real vector tx
    // real scalar trim
}

/*******************************************************************************
 Conditional Expectation Structure Initializer Fxns
*******************************************************************************/
// Define conditional expectation structure and save in referenced mopt. problem.
// Usage is specific to moptimize problems 
// M: moptimize problem name.
// i: index for user info, where new cexp_parameters structure will be saved.
void mopt_cexp_define( transmorphic      	scalar     	M       , 
					 real				scalar		i		,		
                     pointer(function) 	vector     	fxnlist ) {

    struct cexp_parameters scalar CE 
    CE = cexp_define(fxnlist)
    moptimize_init_userinfo(M , i, CE)
}

// Define conditional expectation structure.
struct cexp_parameters scalar cexp_define(
       | pointer(function) vector fxnlist 
       , real scalar twice               ) {
  
    struct cexp_parameters scalar CE
    // Declare Semi-Parametric Parameters 

    // Default Parameters
    if (args()==0) {
        CE.method       = &cexp_vec() 
        CE.kernel       = &kernel_twicing() 
        CE.dkernel      = &dkernel_twicing() 
        CE.bwidth       = &bwidth_pilot() 
        CE.twice        = 0
    }

    // User parameters 
    else { 
        CE.method       = fxnlist[1] 
        CE.kernel       = fxnlist[2] 
        CE.dkernel      = fxnlist[3] 
        CE.bwidth       = fxnlist[4] 
        CE.twice        = twice
    }
    
    return(CE)
}

/*******************************************************************************
 CEXP evaluator: 
 Pass conditional expectation input data and parameters to chosen evaluator
 Return conditional expectation vector

Description of twicing as a discrete process from:
Smoothing Techniques for Curve Estimation
Lecture Notes in Mathematics Volume 757, 1979, pp 191-195
W Stuetzle, Y Mittal - Smoothing techniques for curve estimation, 1979
*******************************************************************************/
real matrix cexp( real matrix y, real matrix X, struct cexp_parameters CE, 
                | real vector tx, real vector h) {  

    // db "Conditional Expectation Called"

    // If indicator trimming vector and bandwidth were not passed, 
    if (args()==3) {
    	// use a vector of ones. -> compute cond. exp. for all observations. 
        tx = J(rows(X),1,1) 
		// Calculate optimal bandwidth
    	h=(*CE.bwidth)(y,X,CE,tx)
    }
	
	// Trimming vector passed but bandwidth was not
	else if (args()==4) {
		// Calculate optimal bandwidth
    	h=(*CE.bwidth)(y,X,CE,tx)
	}

	// Update current bandwidth
	CE.optbwidth=h
    
    // calculate conditional expectation
	real matrix cexp
    cexp = (*CE.method)(y,X,CE,tx)

    // Twicing: Discrete Process 
    if (CE.twice==1) {
		real vector r, rhat 
        r    = y-cexp
        rhat = (*CE.method)(r,X,CE,tx)
        cexp = cexp+rhat   
    }

    return(cexp)
}


/*******************************************************************************
 Kernel weighted distance using NxN matrix.
*******************************************************************************/
real matrix kdist(real matrix X , struct cexp_parameters scalar CE) {

	real scalar n, k, j, h
	real vector H, ones, z
	real matrix K, Z

    n = rows(X)
    k = cols(X)
    H = CE.optbwidth 
   // declare row vector of 1's to project the conditioning vector into nxn 
   ones = J(1,n,1)
   // kernel weighted distance matrix
   K = J(n,n,1)
   // "leave one out" - Set diagonal of K to zero
   _diag(K,0)

   // loop through X's
   for (j=1 ; j<=k ; j++) {   
      z = X[.,j]
      h = H[j] 
      // Duplicate z into n columns 
      Z = z*ones 
      // Create square difference matrix with bandwidth factor
      // update probability accumulation matrix 
      K = K :* ((*CE.kernel)((Z-Z'):/h) )
   } // end for
   
   // return matrix of kernel weighted distances
   return(K)
} 

/*******************************************************************************
 Conditional Expectation: Uses NxN kernel distance weight matrix from kdist() 
*******************************************************************************/
real matrix cexp_mat(real matrix y, real matrix X, 
                     struct cexp_parameters scalar CE,
                     real vector tx) {
   
	// Declarations
	real matrix K
	real matrix num 
	real vector den

    // Get Kernel weighted distance matrix
    K = kdist(X,CE) 
    // Calculate the conditional mean
    num = K*y 
    den = quadrowsum(K)
    return(tx :* (num :/ den))
}

/*******************************************************************************
 Conditional Expectation Vector Method: 
 Compute kernel density by observation/vector
*******************************************************************************/
real matrix cexp_vec(real matrix y , real matrix X ,
                     struct cexp_parameters scalar CE ,
                     real vector tx) {

	real scalar i , k
    real vector h
	real matrix cexp , r

    // Get bandwidth, row vector size K.
    h = CE.optbwidth

	// Initialize cexp accumulation vector: 
    // value=0 for obs that will be trimmed.
    cexp = J(rows(X),cols(y),0) 

    // Calculate conditional expectation row by row.
    for (i=1 ; i<=rows(X) ; i++) {
        // Skip rows that will be trimmed.
        if (tx[i]) {
            // r Nxcols(x) 
            r = (*CE.kernel)((X[i,.] :- X):/h)
			
            // Leave one out
            r[i,1]=0 

            // Accumulate product across columns
			// r[.,1] Nx1
            for (k=2 ; k<=cols(X) ; k++) {
                r[.,1] = r[.,1]:*r[.,k]
            }
			// cexp[i,.] 1xcols(y) 
            cexp[i,.] = cross(r[.,1],y) :/ quadsum(r[.,1])
        }
    }
    return(cexp)
}

/*******************************************************************************
 Derivative of Cond. Exp. WRT Y - Vector Method: 
 Compute derivative of kernel density by observation/vector
*******************************************************************************/
real matrix dcexpdy_vec(real matrix y , real matrix X ,
                     struct cexp_parameters scalar CE ,
                     real vector tx) {

	real scalar i , k
    real vector h
	real matrix cexp , r, dcexpdy

    // Get bandwidth, row vector size K.
    h = CE.optbwidth

	// Initialize cexp accumulation vector: 
    // value=0 for obs that will be trimmed.
    dcexpdy = J(rows(X),cols(y),0) 

    // Calculate conditional expectation row by row.
    for (i=1 ; i<=rows(X) ; i++) {
        // Skip rows that will be trimmed.
        if (tx[i]) {
            // r Nxcols(x) 
            r = (*CE.kernel)((X[i,.] :- X):/h)
			
            // Leave one out
            r[i,1]=0 

            // Accumulate product across columns
			// r[.,1] Nx1
            for (k=2 ; k<=cols(X) ; k++) {
                r[.,1] = r[.,1]:*r[.,k]
            }
			// cexp[i,.] 1xcols(y) 
            dcexpdy[i,.] = cross(r[.,1],y) :/ quadsum(r[.,1])
        }
    }
    return(dcexpdy)
}

/*******************************************************************************
 Derivative of Conditional Expectation with respect to betas. 
 Betas are coefficients of conditional expectation Index: I = x1 + X2*beta  
 If additional indexes are included, pass them in optional argument, I2
 Derivatives are taken only w.r.t. betas of first index.
 Vector Method
*******************************************************************************/
real matrix dcexpdb_vec(real vector y , real colvector I1 , real matrix X , 
                       struct cexp_parameters scalar CE ,
                       real vector tx , real vector h ,| real matrix I2) {

	real scalar i , k
    real vector r1, dr1
	real matrix dcexpdb , r2

    // Get bandwidth, row vector size K.
    // h = CE.optbwidth
	// Adjust for derivative
	// h = h :* rows(I1)^(2/99)
	// h = h :^(9/11)
   
	// Initialize cexp accumulation vector: 
    // value=0 for obs that will be trimmed.
    dcexpdb = J(rows(X),cols(X),0) 
	// Initialize index
	
	// I1 = X*b'
    // Calculate conditional expectation row by row.
    for (i=1 ; i<=rows(X) ; i++) {
        // Skip rows that will be trimmed.
        if (tx[i]) {
            // r1 (x1i - x1j) Nx1 
			// subtract all rows of X from current row, col 1 only
            r1  =  (*CE.kernel)((I1[i] :- I1):/h[1]) 
			dr1 =  (*CE.dkernel)((I1[i] :- I1):/h[1]) :* (X[i,.] :- X) / h[1]
            
			// Leave one out
            r1[i] =0 
			dr1[i,.]=J(1,cols(X),0) 

			// calculate kernel weights of other indeces, if any 
			if (args()==7) {
				// r (X2i - X2j) Nxcols(X)-1
            	r2 = (*CE.kernel)((I2[i,.] :- I2) :/ h[(2..cols(h))] )
            	// Accumulate product across columns
            	for (k=1 ; k<=(cols(r2)) ; k++) {
                	r1  =  r1:*r2[.,k]
					dr1 = dr1:*r2[.,k]
            	}
			}	
			// cexp[i,.] 1xcols(y) 
			real scalar p, dp
			real rowvector ydp, yp
			p   = quadsum(r1)
			dp  = quadcolsum(dr1) 
			yp  = cross(y,r1)
			ydp = cross(y,dr1)
            dcexpdb[i,.] = (ydp:*p - yp:*dp) / p^2
        }
    }
    return(dcexpdb)
}

/*******************************************************************************
 Derivative of conditional expectation w.r.t. index
 Change to dh format
*******************************************************************************/
real matrix dcexpdI_vec(real vector y , real matrix I1 , 
                       struct cexp_parameters scalar CE ,
                       real vector tx , real vector h , 
					   | real matrix I2) {

	real scalar i , k  
    real vector r1, dr1, dcexpdI , p, yp, dLj, dKj
	real matrix r2

    // Get bandwidth, row vector size K.
    // h = CE.optbwidth
	// Adjust for derivative
	// h = h :* rows(I1)^(2/99)
	// h = h :^(9/11)
   
	// Initialize cexp accumulation vector: 
    // value=0 for obs that will be trimmed.
    dcexpdI = J(rows(y),1,0) 
    p   	= J(rows(y),1,0) 
    yp  	= J(rows(y),1,0) 
	dLj  	= J(rows(y),1,0) 
    // Calculate derivative of Li wrt Ii for each row 
    for (i=1 ; i<=rows(y) ; i++) {
        // Skip rows that will be trimmed.
        if (tx[i]) {
            // r1 (x1i - x1j) Nx1 
			// subtract all rows of X from current row, col 1 only
            r1  =  (*CE.kernel)((I1[i] :- I1):/h[1]) 
			dr1 =  (*CE.dkernel)((I1[i] :- I1):/h[1]) / h[1]
            
			// Leave one out
            r1[i] =0 
			dr1[i]=0

			// calculate kernel weights of other indeces, if any 
			if (args()==6) {
				// r (X2i - X2j) Nxcols(X)-1
            	r2 = (*CE.kernel)((I2[i,.] :- I2) :/ h[(2..cols(h))] )
            	// Accumulate product across columns
            	for (k=1 ; k<=(cols(I2)) ; k++) {
                	r1  =  r1:*r2[.,k]
					dr1 = dr1:*r2[.,k]
            	}
			}	

			// cexp[i,.] 1xcols(y) 
			real scalar dp , ydp
			p[i]   = quadsum(r1)
			dp  = quadcolsum(dr1) 
			yp[i]  = cross(y,r1)
			ydp = cross(y,dr1)
            dcexpdI[i] = (ydp:*p[i] - yp[i]:*dp) / p[i]^2
        }
    }
	// Add derivatives of all Lj wrt Ii for each row
	for (i=1 ; i<=rows(y) ; i++) {
		if (tx[i]) {
			dKj = -(*CE.dkernel)((I1 :- I1[i]) /h[1]) /h[1]
			if (args()==6) {
            	for (k=1 ; k<=(cols(I2)) ; k++) {
					dKj = dKj :* (*CE.kernel)((I2[.,k] :- I2[i,k]) / h[k+1]) 
				}
			}
			dLj = dKj :* (p*y[i] - yp) :/ p:^2
			dLj[i]=0
			dcexpdI[i] = dcexpdI[i] + quadsum(dLj)
		}
	}	

    return(dcexpdI)
}

/*******************************************************************************
 Derivative of Conditional Expectation with respect to bandwidth 
 Vector Method
*******************************************************************************/

real matrix dcexpdh_vec(real matrix y , real matrix X ,
                       struct cexp_parameters scalar CE ,
                       real vector tx) {

	real vector h, dcexpdh
	real scalar j

    // Get bandwidth, row vector size K.
    h = CE.optbwidth

	// Initialize return matrix
	dcexpdh = J(rows(X),cols(X),.)

	// Loop through each column of h and X
	for (j=1 ; j<=cols(h) ; j++) {
		// Calculate derivative w.r.t. first bandwidth in vector
		dcexpdh[.,j] = dcexpdh1_vec(y , X , CE , tx , h)
		// Iterate throuch columns of X and h 
		// Move first column to last column, second to first, etc.
		X = (X[.,(2..cols(X))],X[.,1])
		h = (h[.,(2..cols(h))],h[.,1])
	}
	return(dcexpdh)	
}



real vector dcexpdh1_vec(real matrix y , real matrix X ,
                       struct cexp_parameters scalar CE ,
                       real vector tx, real vector h) {

// Note: In this function X contains indexes
// I1 is the distance between two observations (the argument for the kernel function)

	real scalar i , k
    real vector r1, dr1, I1
	real matrix dh1cexp , r 

	// Initialize cexp accumulation vector: 
    // value=0 for obs that will be trimmed.
    dh1cexp = J(rows(X),cols(y),0) 

    // Calculate conditional expectation row by row.
    for (i=1 ; i<=rows(X) ; i++) {
        // Skip rows that will be trimmed.
        if (tx[i]) {
            // r1 (x1i - x1j) Nx1 
			// subtract all rows of X from current row, col 1 only
			I1   =  (X[i,1] :- X[.,1]):/h[1]
            r1  =  (*CE.kernel)(I1) 
			dr1 =  (*CE.dkernel)(I1) :* -I1 :/ (h[1])
			// note: I1 includes division by h, so no squared term needed in derivative
            
			// Leave one out
            r1[i] =0 
			dr1[i]=0 

			// calculate kernel weights of other X variables 
			if (cols(X)>1) {
				// r (X2i - X2j) Nxcols(X)-1
            	r = (*CE.kernel)( ( X[i,(2..cols(X))] :- X[.,(2..cols(X))] ) :/ h[(2..cols(X))] )
            	// Accumulate product across columns
            	for (k=1 ; k<=(cols(X)-1) ; k++) {
                	r1  =  r1:*r[.,k]
					dr1 = dr1:*r[.,k]
            	}
			}	

			// cexp[i,.] 1xcols(y) 
			real scalar p, dp
			real rowvector ydp, yp
			p   = quadsum(r1)
			dp  = quadsum(dr1) 
			yp  = cross(r1,y)
			ydp = cross(dr1,y)
            dh1cexp[i,.] = (ydp*p - yp*dp) / p^2
        }
    }
    return(dh1cexp)
}



/*******************************************************************************
 Kernel Functions

    Note: Step-wise twicing procedure is as follows: 
    1. estimate E[y|x]
    2. calculate r = y - E[y|x]
    3. estimate E[r|x]
    4. revise E*[y|x] = E[y|x]+E[r|x] 

*******************************************************************************/
real kernel_twicing(real X) {
 	return(2*normalden(X) - normalden(X,0,sqrt(2)))
}

real dkernel_twicing(real X) {
	return(-2*X :* normalden(X) + X/2 :* normalden(X,0,sqrt(2)))
}

real kernel_gaussian(real X) {
    return(normalden(X))
}

real dkernel_gaussian(real X) {
    return(-X:*normalden(X))
}

real kernel_epanechnikov(real X) {
	real w
    w = abs(X) :< 1 
    return(w :* 0.75 :* (1 :- X:^2))
}

real kernel_biweight(real X) {
	real w
    w = abs(X) :< 1
    return(w :* 0.9375 :* (1 :- X:^2):^2)
}

real kernel_cosine(real X) {
	real scalar twopi
	real w
    w = abs(X) :< 0.5
    return(w :* cos(2*pi():*X))
}

real kernel_rectangular(real X) {
	real w
    w = abs(X) :< 1 
    return(w :* 0.5)
}

real kernel_triangular(real X) {
	real absx, w
    absx = abs(X) 
    w = absx :< 1
    return(w :* (1-absx))
}


/*******************************************************************************
 Bandwidth Functions
 Constants from Hansen, Bruce E., Lecture Notes on Nonparametrics No. 1 
 To include higher order kernels in future update, kernels should be 
 specified by fxn and order. 
 Let k=num vars, and v=order
 Then C should be specified in a v by k matrix.
 and exponent should be n^(-1/(2*v+k))
*******************************************************************************/

real vector bwidth_pilot(real matrix y , real matrix X ,
                     struct cexp_parameters scalar CE ,
                     real vector tx) {

	// Declarations
	real scalar n, k 
	real vector c, h, r
	pointer scalar ptwicing, pgaussian, pepanech, pbiweight

    n=rows(X) 
    k=cols(X)
 
    // Get address of kernel fxns
    ptwicing=&kernel_twicing()
    // Choose c depending on kernel fxn and order
    if ((CE.kernel)==ptwicing) {
		// r ave values from KV 2010, p.158 (D1)
		r = (.12916667 , .09166667)
        h = sqrt(diagonal(variance(X))) :* n^(-r[k]) 
        // c from Bruce for 2nd order gaussian
		// c = (1.08,1.12)
        // h = c[k] :* sqrt(diagonal(variance(X))) :* n^(-1/(8+k))   
    }
    else {      
        pgaussian =&kernel_gaussian()
        pepanech  =&kernel_epanechnikov()
        pbiweight =&kernel_biweight()   
        // ptriweight=&kernel_triweight() 
        if      (CE.kernel==pgaussian ) c=(1.06,1.00)
        else if (CE.kernel==pepanech  ) c=(2.34,2.20)
        else if (CE.kernel==pbiweight ) c=(2.78,2.61)
        // else if (CE.kernel==ptriweight) c=(3.15,2.96)
        else c=(1,1)
        h = c[k] :* sqrt(diagonal(variance(X))) :* n^(-1/(4+k))   
    }
    return(h')
}

/*******************************************************************************
 SLS Bandwidth
 Find optimal bandwidth (in terms of minimizing sum of squares) for each 
 set of potential parameters.

 Estimate the log of h, rather than h.
 This ensures that h can never be zero or negative.

*******************************************************************************/
void bwidth_sls(todo, real vector lnh, real vector y, real matrix X, 
                struct cexp_parameters scalar CE, real vector tx, 
                real vector minh, ssq, g, H) {
    
	real vector h, est, sqdiff, trim, dEdh

    // Set minimum bandwidth
    h = exp(lnh) + minh 

    // Estimate Conditional Expectation and squared difference
    est = (*CE.method)(y,X,CE,tx)
    sqdiff = (y-est):^2

    // Check for missing values
    trim = missing(sqdiff)
    if (trim>0) {
        printf("%f observations trimmed due to zero denominator in cond. exp. \n", trim)
    }
    _editmissing(sqdiff, 0)

    // Return objective fxn
    ssq = tx :* sqdiff 

	if (todo==1) {
		dEdh = dh1cexp(y,X,CE,tx,h)
		g = -2 :* tx :* (y-est) :* dEdh
	}
}


real vector bwidth_min_sls(real vector y , real matrix X ,
                     struct cexp_parameters scalar CE ,
                     real vector tx) {
   
	real vector h, minh, lnh, delta
	transmorphic scalar S

    h=(bwidth_pilot(y,X,CE,tx))
    minh = h :* 0.1

    // db  "Estimating Optimal Bandwidth"
    // db  "Starting value = "
    // db  h
    // db  "Minimum Bandwidth (1/10 pilot bandwidth)"
    // db  minh

    lnh=ln(h-minh)
    delta=J(1,cols(X),0.1)

    S=optimize_init()
    optimize_init_iterid(S, "Bandwidth")
    optimize_init_valueid(S, "SSq(h)")
    optimize_init_evaluatortype(S, "gf0")
    optimize_init_which(S , "min")
    optimize_init_evaluator(S, &bwidth_sls())
    optimize_init_params(S, lnh)
    optimize_init_tracelevel(S, "none")
    optimize_init_argument(S, 1, y)
    optimize_init_argument(S, 2, X)
    optimize_init_argument(S, 3, CE)
    optimize_init_argument(S, 4, tx)
    optimize_init_argument(S, 5, minh)
    // optimize_init_technique(S,"nr")
    optimize_init_technique(S,"nm")
    optimize_init_nmsimplexdeltas(S,delta)

    // optimize_init_technique(S,"bhhh")

    optimize_init_conv_ignorenrtol(S, "on")
    lnh=optimize(S) 
    
    h = exp(lnh) + minh
		
    // ptol default 1e-6 
    if (mreldif(h, minh) < optimize_init_conv_ptol(S)) {
        printf("Bandwidth selection stopped at minimum (1/10 of pilot bw): \n")
		h
    }

     // db "Optimal Bandwidth:"
     // db h 

    return(h)
 }

/*******************************************************************************
 bandwidth Selection for derivative estimate.
 Minimize score vector of sls objective fxn
*******************************************************************************/
void d1bwidth_sls(todo, real vector lnh, real vector y, real matrix X, 
                struct cexp_parameters scalar CE, real vector tx, 
                real vector minh, real vector r, ssq, g, H) {
    
	real vector h, d1est, sqscore, trim

    // Set minimum bandwidth
    h = exp(lnh) + minh 
    CE.optbwidth = h 

    // Estimate Conditional Expectation and squared difference
    d1est = d1cexp_vec(y,X,CE,tx)
    sqscore = (r :* d1est):^2

    // Check for missing values
    trim = missing(sqscore)
    if (trim>0) {
        printf("%f observations trimmed due to zero denominator in cond. exp. \n", trim)
    }
    _editmissing(sqscore, 0)

    // Return objective fxn
    ssq = tx :* sqscore
}

real vector d1bwidth_min_sls(real vector y , real matrix X ,
                     struct cexp_parameters scalar CE ,
                     real vector tx) {
   
	real vector h, minh, lnh, delta, Ey, r
	transmorphic scalar S

	// Expected value of Y and residual
	Ey = cexp(y, X, CE, tx)
	r  = y-Ey
				
	// Minimum bandwidth
    h=(bwidth_pilot(y,X,CE,tx))
    minh = h :* 0.1
    // db  "Estimating Optimal Bandwidth"
    // db  "Starting value = "
    // db  h
    // db  "Minimum Bandwidth (1/10 pilot bandwidth)"
    // db  minh
    lnh=ln(h-minh)
    delta=0.1

    S=optimize_init()
    optimize_init_iterid(S, "Derivative Bandwidth")
    optimize_init_valueid(S, "SSq(h)")
    optimize_init_evaluatortype(S, "gf0")
    optimize_init_which(S , "min")
    optimize_init_evaluator(S, &d1bwidth_sls())
    optimize_init_params(S, lnh)
    optimize_init_tracelevel(S, "step")
    optimize_init_argument(S, 1, y)
    optimize_init_argument(S, 2, X)
    optimize_init_argument(S, 3, CE)
    optimize_init_argument(S, 4, tx)
    optimize_init_argument(S, 5, minh)
    optimize_init_argument(S, 6, r)
    // optimize_init_technique(S,"nr")
    optimize_init_technique(S,"nm")
    optimize_init_nmsimplexdeltas(S,delta)
    optimize_init_conv_ignorenrtol(S, "on")
    lnh=optimize(S) 
    
    h = exp(lnh) + minh
		
    // ptol default 1e-6 
    if (mreldif(h, minh) < optimize_init_conv_ptol(S)) {
        printf("Derivative Bandwidth selection stopped at minimum (1/10 of pilot bw): \n")
		h
    }

     // db "Optimal Bandwidth:"
     // db h 

	"Optimal Derivative Bandwidth:"
	h 

    return(h)
 }

/*******************************************************************************
 Passthrough bandwidth.
 Function to return current bandwidth parameter. 
 This can be used if the user wants to choose the bandwidth parameter
 or if it is set by an outside optimization routine.
*******************************************************************************/
real vector bwidth_passthru(real matrix y , real matrix X ,
                     struct cexp_parameters scalar CE ,
                     real vector tx) {
	// get current bandwidth vector
	real vector h
	h = CE.optbwidth 
	// ensure that a valid value for h exists.
	if (length(h)==0) {
		_error(3498, "optbwidth must be set before calling bwidth_passthru")
	}
	return(h)
}

 
 /*******************************************************************************
 Smooth Trimming 
 Return trimming vector
 Multiply returned result by original data (element-wise) to get trimmed data
 For large negative values in x, trimming weight is too small to be 
 represented as a double. More precisely, exp(-a*x) is larger than 
 maxdouble(), which results in a missing value. 
 In this case, trim to zero.   

 Note: Do not use smallestdouble(), which is smallest full precision
 number. There are smaller, denormalized numbers that could exist for 
 trimming weights. I should not assign smallestdouble to missing values, 
 because it is not actually the smallest trimming weight available.  
 
*******************************************************************************/
real vector strim(real vector x) {
	real scalar n, a
	real vector t
    n = rows(x)
    a = ln(n):^2
    t = (1:+exp(-a:*x)):^(-1):*sign(x)
    _editmissing(t,0)
    return(t) 
}

/*******************************************************************************
 Indicator Trimming

 Trim by centile. If any variable lies outside the specified centile range
 for a given observation, that observation is omitted from the value function
 calculation.
 
 Returns a binary trimming vector.

 I have to update this fxn for cases of repeated X variables. Currently,
 this function identifies outliers by position, but if the same value lies
 above and below the cut off position, they should be treated the same. Now,
 one would be trimmed and one not trimmed.

 Currently, indicator trimming is based on Stata's _pcentile function.	

*******************************************************************************/

real vector itrim(real matrix X, real scalar lower_centile, real scalar upper_centile ) {

	real scalar n, k, bn, tn, mn, j
	real vector t, tx, invp
	
	n=rows(X) 
	k=cols(X)

	// number of obs to trim from bottom and top of distribution
	bn = floor(lower_centile*n/100)  
	tn = floor((100-upper_centile)*n/100)
	// number of untrimmed obs in the middle
	mn = n-bn-tn

	// ordered trimming vector
	t = (J(bn,1,0) \ J(mn,1,1) \ J(tn,1,0))
	// initialize accumulation trimming vector
	tx = J(n,1,1) 
	// for each X
	for (j=1 ; j<=k ; j++) {
		// get inverse permutation vector...the vector to go from the ordered  
		// trimming vector to the current order of X[.,j]
		invp = order(order(X,j),1)
		// note: I could use the invorder function above, I think. 
		// Update accumulation vector with current vector, reordered to match X[j]
		tx = tx :* t[invp,.]
	} 
	return(tx)
}

/*******************************************************************************
 Wrapper for calling itrim with variable names as strings.
 _st_itrim returns a trimming vector in Mata
 st_itrim  generates a new variable in Stata
*******************************************************************************/
real vector _st_itrim(string scalar varlist, string scalar touse, 
              real scalar lower_centile, real scalar upper_centile) {
	
	real vector tx
    real matrix X

    // Get data from Stata
    st_view(X , . , varlist , touse)
    
    tx = itrim(X,lower_centile,upper_centile)
    
    st_numscalar("r(N)", rows(tx))
    st_numscalar("r(sum)", sum(tx))
    st_numscalar("r(mean)", mean(tx)[1] )

    return(tx)
}

void st_itrim(string scalar varlist, string scalar touse, 
              real scalar lower_centile, real scalar upper_centile,
              string scalar generate) {

	real vector tx, idx

    tx = _st_itrim(varlist, touse, lower_centile, upper_centile)
    // Save trimming vector as new var
    idx = st_addvar("byte", generate)
    st_store(., idx , touse, tx) 

}

/*******************************************************************************
 Save function library 
*******************************************************************************/

// mata mlib create lsls, dir(PERSONAL) replace
mata mlib create lsls, replace
mata mlib add lsls *()
// If no errors, 31 new functions were added.
mata mlib index
mata set matastrict off
end




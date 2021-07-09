* version 1.2.0 13Dec2011 MLB
* version 1.0.0 14Nov2011 MLB
mata 
real matrix function marg_hermitegen_ac(real vector lu, real scalar e,
                     struct margdata scalar data,
					 pointer scalar f, pointer scalar F )
{
	real matrix hermite 
	hermite = marg_initknots_ac(lu,data, f, F)
	hermite = marg_modeknots(hermite, data, f, F)
	hermite = marg_knots_ac(hermite,e,data, f, F)
	return(hermite)
}
mata mlib add lmargdistfit marg_hermitegen_ac()

real matrix function marg_eval_ac(real matrix hermite, real vector x){
	
	real scalar n, m, t, j, i, m0
	real vector y
	real matrix temp
	
    n = length(x)
    m = rows(hermite)
    y = J(n,1,.)
    
	/* ignore values in x that are less than the lowest value in hermite */
	t = hermite[1,1]
    for (m0=j=1;j<=n;j++) {
        if (x[j]>=t) break 
    }
	
                        /* begin approximations                 */
    for (i=j;i<=n;i++) { 
        for (j=m0;j<m;j++) {            /* sic  */
            if (x[i]>=hermite[j,1] & x[i]<hermite[j+1,1]) break 
        }
        if (j>=m) { 
            if (x[i]==hermite[m,1]) j = m-1
        }
        if (j<m) {
			temp = hermite[|j,1\j+1,6|]
			y[i] = marg_as_subeval_ac(x[i],temp)
        }
        m0 = j 
    }
    return(y)
}
mata mlib add lmargdistfit marg_eval_ac()

real matrix function marg_as_ac(real matrix puf) {
	real scalar q, F, f
	real matrix res
	
	q=1
	F=2
	f=3
	res = J(1,3,.)
	res[1,1] = (puf[2,q]-puf[1,q])*puf[1,f]
    res[1,2] = 3*(puf[2,F]-puf[1,F]) - (puf[2,q]-puf[1,q])*(2*puf[1,f] + puf[2,f])
	res[1,3] = 2*(puf[1,F]-puf[2,F]) + (puf[2,q]-puf[1,q])*(  puf[1,f] + puf[2,f])
	return(res)
}
mata mlib add lmargdistfit marg_as_ac()

real scalar function marg_as_subeval_ac(real scalar u, real matrix pufaaa) {
	real scalar a0, ui, a1, a2, a3, ut, res
	
	ui = 1 // = q
	a0 = 2 // = F
	a1 = 4
	a2 = 5
	a3 = 6
	ut = (u - pufaaa[1,ui])/(pufaaa[2,ui]-pufaaa[1,ui])
	res = pufaaa[1,a0] + pufaaa[1,a1]*ut + pufaaa[1,a2]*ut^2+ pufaaa[1,a3]*ut^3
	return(res)
}
mata mlib add lmargdistfit marg_as_subeval_ac()

real matrix function marg_initknots_ac(real vector lu,
                                    struct margdata scalar data , 
									pointer scalar f, pointer scalar F )
{
	real scalar i
	real matrix res, ins
	
	res = lu' 
	res = res,(*F)(data, res)
	
	// split till each interval is less than .05
	i = 1
	do { 
		if (res[i+1,2]-res[i,2] > .05) {
			ins = res[i,1] + (res[i+1,1] - res[i,1]):/2
			ins = ins, (*F)(data,ins)
			res = res[|1,1 \i,2|] \ ins \ res[|i+1,1 \ rows(res), 2|]
		}
		else {
			i = i + 1
		}
	} while (i < rows(res) )

	// add density function
	res = res, (*f)(data, res[.,1])
	return(res)
}
mata mlib add lmargdistfit marg_initknots_ac()

real matrix function marg_modeknots( real matrix res, 
                                     struct margdata scalar data,
									 pointer scalar f, pointer scalar F)
{
	real scalar k, m, j, i, dens
	real matrix res2, temp, ins
	
	res2 = res
	for (k=1; k <= 4; k++) {
		res = res2
		j = 1
		for (i=1; i <= rows(res)-1; i++) {
			// guess of mode based on quadratic spline using info from CDF
			temp = res[|i,1\(i+1), 3|]
			temp =  temp, ( marg_as_ac(temp) \ J(1,3,.) )
			if (abs(3*temp[1,6]) > 1e-6) {	// check for extrema only if enough curveture
				m = -temp[1,5]/(3*temp[1,6]) 
				
				if (m > 1e-4 & m < .05*k) { // shift left knot
					m = res[i,1] + (res[i+1,1] - res[i,1])*m
					dens = (*f)(data,m)
					if (temp[1,6] <= 0) { // approximation finds maximum
						if ( dens > res[i,3] ) { // new is improvement if new is larger than old
							ins = m, (*F)(data,m), dens
							res2[|j,1 \ j,3|] = ins
						}
					}
					else {                // approximation finds minimum
						if ( dens < res[i,3] ) { // new is improvement if new is smaller than old
							ins = m, (*F)(data,m), dens
							res2[|j,1 \ j,3|] = ins
						}
					}
				}
				else if (m < (1-1e-4) & m > (1-.05*k) ) { // shift right knot
					m = res[i,1] + (res[i+1,1] - res[i,1])*m
					dens = (*f)(data,m)
					if (temp[1,6] <= 0) { // approximation finds a maximum
						if ( dens > res[i+1,3] ) { // new is improvement if new is larger than old
							ins = m, (*F)(data,m), dens
							res2[|j+1,1 \ j+1,3|] = ins
						}
					}
					else {                // approximation finds a minimum
						if ( dens < res[i+1,3] ) { // new is improvement if new is smaller than old
							ins = m, (*F)(data,m), dens
							res2[|j+1,1 \ j+1,3|] = ins
						}
					}
				}
				else if ( m >= .05*k & m <= (1-.05*k)) {  // add a knot
					m = res[i,1] + (res[i+1,1] - res[i,1])*m
					ins = m, (*F)(data,m), (*f)(data,m)
					res2 = res2[|1,1 \j,3|] \ ins \ res2[|j+1,1 \ rows(res2), 3|]
					j = j + 1
				}
			}
			j = j+1
		} 
	}
	return(res2)
}
mata mlib add lmargdistfit marg_modeknots()

real matrix function marg_knots_ac(real matrix res, real scalar e, struct margdata scalar data, 
                                pointer scalar f, pointer scalar F ) {
	real scalar i, u, c
	real matrix temp, ins

	i = 1
	res = res, J(rows(res),3,.)
	do {
		temp = res[|i,1\(i+1), 6|]
		temp[|1,4 \1,6|] =  marg_as_ac(temp)
		u = (temp[2,1] - temp[1,1])/2 + temp[1,1]
		c = 3*(temp[2,2] - temp[1,2])/(temp[2,1] - temp[1,1])
		if ( reldif(temp[1,2], 1) < e ) {
			res[|i,4 \ i, 6|] = J(1,3,0)
			i = i + 1
		}
        else if ( reldif(marg_as_subeval_ac(u,temp), (*F)(data,u)) < e & temp[1,3]<= c & temp[2,3]<=c ) {
			res[|i,4 \ i, 6|] = temp[|1,4\1,6|]
			i = i + 1
		}
		else {
			ins = u, (*F)(data,u), (*f)(data,u), ., ., .
			res = res[|1,1 \ i, 6|] \ ins \ res[|i+1, 1 \ rows(res),6|] 
		}
	} while ( i <= (rows(res)-1) )
	return(res)
}
mata mlib add lmargdistfit marg_knots_ac()

end

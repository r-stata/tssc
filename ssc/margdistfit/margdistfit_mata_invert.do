* version 1.2.0 13Dec2011 MLB
* version 1.0.0 14Nov2011 MLB
mata

void function marg_invert(real scalar l, real scalar u, real scalar e,
                     struct margdata scalar data, real vector x,
					 pointer scalar f, pointer scalar F, 
					 string scalar Q, | tl, tu)
{
	real matrix res
	real vector o, op
	if (args() == 8 ) {
		res = marg_initknots(l,u,e,data, f, F)
	}
	else if (args() == 9) {
		res = marg_initknots(l,u,e,data, f, F, tl)
	}
	else if (args() == 10) {
		res = marg_initknots(l,u,e,data, f, F, tl, tu)
	}
	res = marg_modeknots(res, data, f, F)
	res = marg_knots(res,e,data, f, F)
	o = order(x, 1)
	op = invorder(o)
	st_store(.,Q,st_local("touse"),(marg_eval(res,x[o]))[op] )
}
mata mlib add lmargdistfit marg_invert()

real matrix function marg_eval(real matrix hermite, real vector x){
	
	real scalar n, m, t, j, i, m0
	real vector y
	real matrix temp
	
    n = length(x)
    m = rows(hermite)
    y = J(n,1,.)
    
	/* ignore values in x that are less than the lowest value in hermite */
	t = hermite[1,2]
    for (m0=j=1;j<=n;j++) {
        if (x[j]>=t) break 
    }

                        /* begin approximations                 */
    for (i=j;i<=n;i++) { 
        for (j=m0;j<m;j++) {            /* sic  */
            if (x[i]>=hermite[j,2] & x[i]<hermite[j+1,2]) break 
        }
        if (j>=m) { 
            if (x[i]==hermite[m,2]) j = m-1
        }
        if (j<m) {
			temp = hermite[|j,1\j+1,6|]
			y[i] = marg_as_subeval(x[i],temp)
        }
        m0 = j 
    }
    return(y)
}
mata mlib add lmargdistfit marg_eval()

real matrix function marg_as(real matrix puf) {
	real scalar p, u, f
	real matrix res
	
	p=1
	u=2
	f=3
	res = J(1,3,.)
	res[1,1] = (puf[2,u]-puf[1,u])/puf[1,f]
    res[1,2] = 3*(puf[2,p]-puf[1,p]) - (puf[2,u]-puf[1,u])*(2/puf[1,f]+1/puf[2,f])
	res[1,3] = 2*(puf[1,p]-puf[2,p]) + (puf[2,u]-puf[1,u])*(1/puf[1,f]+1/puf[2,f])
	return(res)
}
mata mlib add lmargdistfit marg_as()

real scalar function marg_as_subeval(real scalar u, real matrix pufaaa) {
	real scalar a0, ui, a1, a2, a3, ut
	real matrix res
	
	a0 = 1 // = p
	ui = 2
	a1 = 4
	a2 = 5
	a3 = 6
	ut = (u - pufaaa[1,ui])/(pufaaa[2,ui]-pufaaa[1,ui])
	res = pufaaa[1,a0] + pufaaa[1,a1]*ut + pufaaa[1,a2]*ut^2+ pufaaa[1,a3]*ut^3
	return(res)
}
mata mlib add lmargdistfit marg_as_subeval()

real matrix function marg_initknots(real scalar l, real scalar u, real scalar e, 
                                    struct margdata scalar data , 
									pointer scalar f, pointer scalar F, 
									| real scalar tl , real scalar tu)
{
	real scalar i, ok, diff, p1, p2, p, FF
	real matrix res, ins
	
	res = l \ u 
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

	// expand till cover (e, 1-e)
	if (res[1,2] > e) {
		ok = 0
		diff = (abs(res[2,1] - res[1,1])) 
		do {
			ins = res[1,1] - diff
			if (args() >= 7) {
				if (ins < tl) {
					ins = tl
					ok = 1
				}
			}
			res = (ins, (*F)(data, ins)) \ res
			if (res[1,2] < e) {
				ok = 1
			}
		} while (ok == 0)
	}
	if (res[rows(res),2] < (1-e)) {
		ok = 0
		diff = (abs(res[rows(res),1] - res[rows(res)-1,1])) 
		do {
			ins = res[rows(res),1] + diff
			if (args() == 8) {
				if (ins>tu) {
					ins = tu
					ok = 1
				}
			}
			res = res \ (ins, (*F)(data, ins))
			if (res[rows(res),2] > (1-e)) {
				ok = 1
			}
		} while (ok == 0)
	}

	// ensure largest and smallest value aren't too small (F<.1e, F>1-.1e)
	// but also not to large (F>e, F<1-e)
	if (res[1,2] < .01*e) {
		p1 = res[1,1]
		p2 = res[2,1]
		ok = 0
		do {
			p = (p2-p1)/2 + p1
			FF = (*F)(data,p)
			if (FF < .1*e) {
				p1 = p
				p2 = p2
			}
			else if (FF > e) {
				p1 = p1
				p2 = p
			}
			else {
				res[|1,1\1,2|] = (p , FF)
				ok = 1
			}
		} while(ok == 0)
	}
	if (res[rows(res),2] > (1-.01*e)) {
		p1 = res[(rows(res)-1),1]
		p2 = res[rows(res),1]
		ok = 0
		do {
			p = (p2-p1)/2 + p1
			FF = (*F)(data,p)
			if (FF > (1-.1*e)) {
				p1 = p1
				p2 = p
			}
			else if (FF < (1-e)) {
				p1 = p
				p2 = p2
			}
			else {
				res[|rows(res),1\rows(res),2|] = (p , FF)
				ok = 1
			}
		} while(ok == 0)
	}
	// add density function
	res = res, (*f)(data, res[.,1])
	return(res)
}
mata mlib add lmargdistfit marg_initknots()

real matrix function marg_knots(real matrix res, real scalar e, struct margdata scalar data, 
                                pointer scalar f, pointer scalar F ) {
	real scalar i, c, u, p
	real matrix temp, ins
	
	i = 1
	res = res, J(rows(res),3,.)
	do {
		temp = res[|i,1\(i+1), 3|]
		temp = temp, ( marg_as(temp) \ J(1,3,.) )
		c = 3*(temp[2,1] - temp[1,1])/(temp[2,2] - temp[1,2])
		u = (temp[2,2] - temp[1,2])/2 + temp[1,2]
        if ((reldif((*F)(data,marg_as_subeval(u,temp)), u) < e ) & 1/temp[1,3]<= c & 1/temp[2,3]<=c) {
			res[|i,4 \ i, 6|] = temp[|1,4\1,6|]
			i = i + 1
		}
		else {
			p = (temp[2,1] - temp[1,1])/2 + temp[1,1]
			ins = p, (*F)(data,p), (*f)(data,p), ., ., .
			res = res[|1,1 \ i, 6|] \ ins \ res[|i+1, 1 \ rows(res),6|] 
		}
	} while ( i <= (rows(res)-1) )
	return(res)
}
mata mlib add lmargdistfit marg_knots()

end

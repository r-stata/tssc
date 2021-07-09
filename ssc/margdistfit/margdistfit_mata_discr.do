* version 1.3.0 06May2012 MLB
mata
void function marg_discr_pp(real matrix x, string scalar pvar, 
                            struct margdata scalar data, string scalar touse,
							pointer scalar f, real scalar cumul) {
	real scalar i, n, m, m0, j, k, min
	real vector pr, t, range, o, op, y

	range = minmax(x)
	range = (range[1,1]..range[1,2])'
	pr = (*f)(data,range)
	if (cumul == 0) {
		for (i=2 ; i <= rows(range) ; i++) {
			pr[i] = pr[i-1] + pr[i]
		}
	}
		
	n = rows(x)
	m = length(pr)

	for (k= 1 ; k <= cols(x) ; k++) {
		o  = order(x,k)
		op = invorder(o)
		t = x[o,k]

		y = J(n,1,.)
		/* ignore values in t that are less than the lowest value in range */
		min = t[1,1]
		for (m0=j=1;j<=n;j++) {
			if (range[j]>=min) break 
		}

 		for (i=j;i<=n;i++) { 
			for (j=m0;j<=m;j++) {            /* sic  */
				if (t[i]==range[j,1]) {
					y[i] = pr[j]
					m0 = j
					break
				}
			}
	    }
		x[.,k] = y[op,1]
	}
	st_store(.,tokens(pvar),touse,x)
}
mata mlib add lmargdistfit marg_discr_pp()

void function marg_discr_qq(real matrix obsp, string scalar qvar, 
                            struct margdata scalar data, string scalar touse,
							pointer scalar f, real scalar cumul) {
	real scalar i, n, m, m0, j, k, min, max, npr
	real vector q, pr, t, o, op, y
	
	max = max(obsp)
	q = 1 
	npr = (*f)(data,0)
	pr = npr
	i = 0
	while (npr < max) {
		i = i + 1
		q = q \ i
		npr = (*f)(data,i)
		if (cumul == 0) {
			npr = npr + pr[rows(pr)]
		}
		pr = pr \ npr
	}

	n = rows(obsp)
	m = length(pr)

	for (k= 1 ; k <= cols(obsp) ; k++) {
		o  = order(obsp,k)
		op = invorder(o)
		t = obsp[o,k]

		y = J(n,1,.)
		/* ignore values in pr that are less than the lowest value in obsp */
		min = t[1,1]
		for (m0=j=1;j<=n;j++) {
			if (obsp[j]>=min) break 
		}
 		for (i=j;i<=n;i++) { 
			for (j=m0;j<=m;j++) {            /* sic  */
				if (pr[j,1]>t[i]) {
					y[i] = (j==1 ? 0 : q[j-1])
					m0 = (j==1 ? 1 : j-1)
					break
				}
			}
	    }
		obsp[.,k] = y[op,1]
	}
	st_store(.,tokens(qvar),touse,obsp)
}
mata mlib add lmargdistfit marg_discr_qq()

end

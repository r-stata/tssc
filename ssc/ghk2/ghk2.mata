* ghk2() 1.7.0  16 March 2017
*! Copyright (C) 2017 David Roodman

* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.

* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.

* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.

* Version history
* 1.7.0 Added Faure-Lemieux (2009) scrambler
* 1.6.1 Added a few more primes
* 1.6.0 Dropped u argument from scramblers since u=0::p-1 always
*       Replace pointer structures with struct smatrix
* 1.5.0 Added scrambling to ghk2setup() and halton2()
* 1.4.1 Fixed bug introduced in 1.4.0 in conversion of dfdT to dfdV
* 1.4.0 Added optional pi (prime index) argument to ghk2setup() to control which primes used.
*       For non-generalized Halton sequences, switched from ghalton() to more-exact, non-recursive generation
*       Tightened ghk2setup()
* 1.3.1 Fixed longstanding bug in computing score w.r.t to top-left entry of Cholesky factor of Sigma
* 1.3.0 More precise calculation of normal(U)-normal(L) when U, L large in _ghk_2() and _ghk_2d()
* 1.2.0 Added s argument
* 1.1.2 added ghk2version command
* 1.1.1 Fixed bug in _ghk2_d() and _ghk2_2d() in conversion of df/dT to df/dV
* 1.1.0 Fixed problems in score computation in _ghk2_2d()
* 1.0.3 Fixed bug in computation of scores (X :/ Y / Z != (X :/ Y) / Z  !!)
* 1.0.2 Streamlined ghk2setup() for type=random
* 1.0.1 Added error checking for rows(X) > pts.n

mata
mata clear
mata set matastrict on
mata set mataoptimize on
mata set matalnum off

struct smatrix {
	real matrix M
}

struct ssmatrix {
	struct smatrix colvector M
}

struct sssmatrix {
	struct ssmatrix colvector M
}

struct ghk2points {
	real scalar n, m, d
	struct sssmatrix colvector W  // 2-vector (incl antitheticals) of m-vectors of d-1-vectors of n-vectors
}

struct ghk2points scalar ghk2setup(real scalar n, real scalar m, real scalar d, string scalar type, | real scalar pi, pointer (real colvector function) pfnScrambler) {
	real scalar itype, j, k, hammersley
	real rowvector primes
	real matrix U, S
	struct ghk2points scalar pts

	primes = 2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,101,103,107,109

	if (d<=0 | floor(d)!=d) {
		errprintf("ghk2: dimension must be a positive integer.\n")
		exit(3300)
	}
	if (n<=0 | floor(n)!=n) {
		errprintf("ghk2: number of observations must be a postitive integer.\n")
		exit(3300)
	}
	if (m<=0 | floor(m)!=m) {
		errprintf("ghk2: draws/observation must be a postitive integer.\n") 
		exit(3300)
	}

	itype = cross( (strtrim(strlower(type)) :== ("random"\"halton"\"hammersley"\"ghalton")), 1::4 ) - 1
	if (itype == -1) {
		errprintf("ghk2: point set type must be random, halton, hammersley, or ghalton.\n")
		exit(3300)
	}
	hammersley = itype == 2

	if (itype) {
		if (pi == .) pi = 1
		else if (pi<=0 | floor(pi)!=pi) {
			errprintf("ghk2: prime index must be a positive integer.\n")
			exit(3300)
		}
	
		if (d > length(primes) - hammersley + pi) {
			errprintf("ghk2: maximum dimension is %g.", length(primes) - hammersley + pi)
			exit(3300)
		}

		primes = primes[|pi\.|]
	}

	pts.d=d; pts.m=m; pts.n=n; pts.W=sssmatrix(2,1); pts.W[1].M=pts.W[2].M=ssmatrix(m, 1)

	for (U=J(n*m,k=d-1,0); k; k--)
		U[,k] = itype? (itype==3? ghalton(n*m, primes[k], uniform(1,1)) :
		                          hammersley & k==1? J(n,1,1)#(0.5::m)/m : 
		                                             halton2(n*m, primes[k-hammersley], pfnScrambler)) :
		               uniform(n*m,1)

	S = (1::n)*m 
	for (j=m; j; j--) {
		pts.W[1].M[j].M = pts.W[2].M[j].M = smatrix(d-1, 1)
		for (k=d-1; k; k--) 
			pts.W[2].M[j].M[k].M = 1 :- ( pts.W[1].M[j].M[k].M = U[S,k] )
		S = S :- 1
	}
	return(pts)
}

// exact Halton sequence of length n for base p, to avoid bug in halton() pre-Stata 12.1 
// accepts optional scrambling function a la Kolenikov 2012
real colvector halton2(real scalar n, real scalar p, | pointer (real colvector function) scalar f) {
	real scalar i, p2i, p2Dmi; real colvector retval, one2p
	for (retval = J(p2Dmi=p^(i=floor(ln(n)/ln(p)+1e-6)), 1, p2i=1) # (one2p=(f==NULL? 0::p-1 : (*f)(p))/p); i; i--)
		retval = retval + J(p2Dmi=p2Dmi/p, 1, 1) # (one2p=one2p/p) # J(p2i=p2i*p, 1, 1)
	return (retval[|2\n+1|])
}

real colvector    ghk2SqrtScrambler(real scalar p) return (mod((0::p-1)*floor(sqrt(p)),p))
real colvector ghk2NegSqrtScrambler(real scalar p) return (mod((0::1-p)*floor(sqrt(p)),p))
real colvector      ghk2FLScrambler(real scalar p)	
	return (mod((0::p-1)*
		select((1,1,3,3, 4, 9, 7, 5, 9,18,18, 8,13,31, 9,19,36,33,21,44,43,61,60,56,26, 71, 32, 77, 26), // Faure and Lemieux 2009 recommended multipliers
		   p:==(2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,101,103,107,109)),
	p))

// derivative of vech(V) w.r.t vech(cholesky(V)). Transposed, i.e., one row for each T_ij.
real matrix ghk2_dTdV(real matrix T) {
	real scalar d; real colvector vK, vL; real matrix t
	d = cols(T)
	vK = vech(t = rowshape(1::d*d,d))
	vL = vech(t')
	return ( qrinv((T#I(d))[vL,vL]+(I(d)#T)[vL,vK]) )
}

real colvector ghk2(struct ghk2points scalar pts, real matrix X, real matrix a3, real matrix a4, 
		| real matrix a5, real matrix a6, real matrix a7, real matrix a8, real matrix a9) {
	real scalar na, anti, s
	pointer (real matrix) pXu, pV, pdfdxu, pdfdx, pdfdv

	if (pts.m <= 0) {
		errprintf("ghk2: invalid points structure: number of integration points must be greater than 0.\n")
		exit(3300)
	}
	if (pts.n <= 0) {
		errprintf("ghk2: invalid points structure: length of the structure must be greater than 0.\n")
		exit(3300)
	}
	if (pts.d<=0 | pts.d>20) {
		errprintf("ghk2: invalid points structure: dimension must be between 1 and 20.\n")
		exit(3200)
	}
	if (rows(pts.W.M) != pts.m) {
		errprintf("ghk2: invalid points structure: vector of pointers to sequence matrices is the wrong length.\n")
		exit(3200)
	}
	if (rows(pts.W.M.M) != pts.d-1) {
		errprintf("ghk2: invalid points structure: point set has the wrong dimension.\n")
		exit(3200)
	}
	if (rows(pts.W.M.M.M) != pts.n) {
		errprintf("ghk2: invalid points structure: point set has the wrong length.\n")
		exit(3200)
	}
	
	if ((na = args()) == 5) {
		pV = &a3; anti = a4; s = a5
	} else if (na == 6) {
		pXu = &a3; pV = &a4; anti = a5; s = a6
	} else if (na == 7) {
		pV = &a3; anti = a4; s = a5; pdfdx = &a6; pdfdv = &a7
	} else if (na == 9) {
		pXu = &a3; pV = &a4; anti = a5; s = a6; pdfdx = &a7; pdfdxu = &a8; pdfdv = &a9
	} else {
		errprintf("ghk2: Wrong number of arguments for ghk2. Expected 5, 6, 7, or 9.\n")
		exit(3000)
	}

	if (rows(*pV)>pts.d | cols(*pV)>pts.d | rows(*pV)!= cols(*pV)) {
		errprintf("V must be square with dimension at most %g.\n", pts.d)
		exit(3200)
	}
	if (missing(*pV)) {
		errprintf("matrix V has missing values.\n")
		exit(3351)
	}

	if (s==.) s = 1

	if (na==5 | na==7) {
		if (cols(X) > pts.d) {
			errprintf("ghk2: number of columns of X, %g, cannot exceed the dimension of the points structure, %g.\n", cols(X), pts.d)
			exit(3200)
		}
		if (s - 1 + rows(X) > pts.n) {
			errprintf("ghk2: number of rows of X, %g, plus starting point, %g, cannot exceed the dimension of the points structure, %g.\n", rows(X), s, pts.n)
			exit(3200)
		}
		if (cols(*pV) != cols(X)) {
			errprintf("ghk2: number of columns in X, %g, does not equal the dimension of V, %g.\n", cols(X), cols(*pV))
			exit(3200) 
		}
		return (na==5? _ghk2(pts, X, *pV, anti, s) : _ghk2_d(pts, X, *pV, anti, s, *pdfdx, *pdfdv))
	}
	if (cols(X) > pts.d) {
		errprintf("ghk2: number of columns of Xl, %g, cannot exceed the dimension of the points structure, %g.\n", cols(X), pts.d)
		exit(3200)
	}
	if (cols(*pXu) > pts.d) {
		errprintf("ghk2: number of columns of Xu, %g, cannot exceed the dimension of the points structure, %g.\n", cols(*pXu), pts.d)
		exit(3200)
	}
	if (cols(*pV) != cols(X)) {
		errprintf("ghk2: number of columns in Xl, %g, does not equal the dimension of V, %g.\n", cols(X), cols(*pV))
		exit(3200) 
	}
	if (cols(*pV) != cols(*pXu)) {
		errprintf("ghk2: number of columns in Xu, %g, does not equal the dimension of V, %g.\n", cols(*pXu), cols(*pV))
		exit(3200) 
	}
	if (cols(X) != cols(*pXu) | rows(X) != rows(*pXu) ) {
		errprintf("ghk2: Xl and Xu must have the same dimensions.\n")
		exit(3200) 
	}
	if (s - 1 + rows(X) > pts.n) {
		errprintf("ghk2: number of rows of Xl and Xu, %g, plus starting point, %g, cannot exceed the dimension of the points structure, %g.\n", rows(X), s, pts.n)
		exit(3200)
	}

	return (na == 6?  _ghk2_2(pts, X, *pXu, *pV, anti, s) : _ghk2_2d(pts, X, *pXu, *pV, anti, s, *pdfdx, *pdfdxu, *pdfdv))
}

real colvector _ghk2(struct ghk2points scalar pts, real matrix X, real matrix V, real scalar anti, real scalar s) {
	real scalar j, k, d, n, a
	real colvector p, pk, p1, Phib, u
	real matrix T, z, sz, sW
	struct smatrix colvector pT

	T = cholesky(V)
	if (T[1,1] == .) {
		errprintf("ghk2: covariance matrix is not positive-definite.\n")
		exit(3352)
	}

	if ((d = rows(V)) == 1) return (editmissing(normal(X/T), 1))

	pT = smatrix(d, 1); for (j=d; j>1; j--) pT[j].M = (-T[|j,1 \ j,j-1|]' \ 1) / T[j,j]
	p = J(n=rows(X), 1, 0); _editmissing(p1 = normal(X[,1] / T[1,1]), 1)
	sz = J(2, 2, .); sW = s,. \ s-1+n, .
	for (a=1+(anti!=0); a>0; a--)
		for (k = pts.m; k; k--) {
			z = X
			u = pts.W[a].M[k].M.M[|sW|] // first dimension's draws
			z[,1] = invnormal(u :* p1)
			for (j=2; j<=d-1; j++) {
				sz[2,2] = j
				_editmissing(Phib = normal(z[|sz|] * pT[j].M), 1)
				pragma unset pk
				pk = j==2? Phib : pk:*Phib
				u = pts.W[a].M[k].M[j].M[|sW|]
				z[,j] = invnormal(u :* Phib)
			}
			_editmissing(Phib = normal(z * pT[d].M), 1)
			p = p + (d==2? Phib : pk:*Phib)
		}
	return (p/(anti? 2*pts.m : pts.m) :* p1)
}

/*
real colvector _ghk2_binorm(struct ghk2points scalar pts, real matrix X, real matrix V, real scalar anti, real scalar s) {
	real scalar j, k, d, n, a, rho
	real colvector p, pk, p1, Phib, u, b, bd
	real matrix T, z, sz, sW
	pointer (real colvector) colvector pW, pT
	pragma unset pk

	T = cholesky(V)'
	if (T[1,1] == .) {
		errprintf("ghk2: covariance matrix is not positive-definite.\n")
		exit(3352)
	}

	if ((d = rows(V)) == 1) return (editmissing(normal(X/T), 1))

	pT = J(d, 1, NULL)
	pT[d] = &((d==2? 0 \ 1 : -T[|.,d \ d-2,.|] \ 0 \ 1) / sqrt(T[d,d-1]^2 + T[d,d]^2)) //d==2 part temporary
	for (j=d-1; j>1; j--) pT[j] = &((-T[|.,j \ j-1,j|] \ 1) / T[j,j])
	rho = T[d-1,d] / sqrt(T[d-1,d]^2 + T[d,d]^2)
	
	p = J(n=rows(X), 1, 0); _editmissing(p1 = normal(b = X[,1] / T[1,1]), 1)
	if (d==2) p1 = J(n, 1, 1)
	sz = J(2, 2, .); sW = s,. \ s-1+n, .
	for (a=anti!=0; a>=0; a--)
		for (k = pts.m; k; k--) {
			z = X; pW = *(a? pts.Wa : pts.W)[k]
			u = (*pW[1])[|sW|]
			z[,1] = invnormal(u :* p1)
			if (d>3)
				for (j=2; j<=d-2; j++) {
					sz[2,2] = j
					_editmissing(Phib = normal(b = z[|sz|] * *pT[j]), 1)
					pk = j==2? Phib : pk:*Phib
					u = (*pW[j])[|sW|]
					z[,j] = invnormal(u :* Phib)
				}
			else {
				b = z[|.,.\.,2|] * *pT[2]
				Phib = J(n, 1, .)
			}
			bd = z * *pT[d]
			for (j=n; j; j--)
				Phib[j] = binormal(b[j], bd[j], rho)
			_editmissing(Phib, 1)
			p = p + (d>3? pk:*Phib : Phib)
		}
	return (p/(anti? 2*pts.m : pts.m) :* p1)
}
*/

real colvector _ghk2_2(struct ghk2points scalar pts, real matrix Xl, real matrix Xu, real matrix V, real scalar anti, real scalar s) {
	real scalar j, k, d, n, a
	real colvector p, pk, p1, Phib, Phibl, Phibl1, sign, sign1, L, U
	pragma unset pk; pragma unset p1; pragma unset Phib
	real rowvector Td
	real matrix T, z, sz, sW, _Xu, _Xl, t
	struct smatrix colvector pT

	T = cholesky(V)'
	if (T[1,1] == .) {
		errprintf("ghk2: covariance matrix is not positive-definite.\n")
		exit(3352)
	}

	pT = smatrix(d=rows(V), 1)
	for (j=d; j>1; j--) pT[j].M = T[|.,j \ j-1,j|] / -T[j,j]

	Td = diagonal(T)'
	_editmissing(_Xu = z = Xu :/ Td, maxdouble()); _editmissing(_Xl = Xl :/ Td, -maxdouble())
	
	L = _Xl[,1]; U = _Xu[,1]
	sign1 = (L+U:<=0)*2 :- 1
	p1 = normal(sign1:*U) - (Phibl1 = normal(sign1:*L))  // flip signs for precision. normal(9)-normal(8) is less accurate than -(normal(-8)-normal(-9))

	if (d == 1) return (p1)

	p = J(n=rows(Xl), 1, 0)

	sz = J(2, 2, .); sW = s,. \ s-1+n, .
	for (a=1+(anti!=0); a>0; a--)
		for (k = pts.m; k; k--) {
			z[,1] = sign1 :* invnormal(Phibl1 + pts.W[a].M[k].M.M[|sW|] :* p1)  // u = pts.W[a].M[k].M[1].M[|sW|]
			sz[2,2] = 1
			for (j=2; j<=d-1; sz[2,2]=j++) {
				t = z[|sz|] * pT[j].M
				L = _Xl[,j] + t; U = _Xu[,j] + t
				Phibl = normal((sign = (L+U:<=0)*2 :- 1) :* L)
				z[,j] = sign :* invnormal(Phibl + pts.W[a].M[k].M[j].M[|sW|] :* (Phib = normal(sign:*U) - Phibl))
				pk = j==2? Phib : pk:*Phib
			}
			t = z[|sz|] * pT[d].M
			L = _Xl[,d] + t; U = _Xu[,d] + t
			sign = (L+U:<=0)*2 :- 1
			Phib = normal(sign:*U) - normal(sign:*L)
			p = p + abs(d==2? Phib : pk:*Phib)
		}

	return (p/(anti? 2*pts.m : pts.m) :* abs(p1))
}

real colvector _ghk2_d(struct ghk2points scalar pts, real matrix X, real matrix V, real scalar anti, real scalar s, real matrix dfdx, real matrix dfdv) {
	real scalar i, j, k, d, d2, n, g, l, a, Tdj
	real colvector p, pg, Phib, Phib1, b, b1, phib, phib1, lambdab, u, T2j, Td
	real matrix T, z, sz, sW, nd0, nd20, dlnfdxg, dlnpdtg, dlnfdxg1, dlnpdtg1, dzdb, dbdx, dbdt, t
	struct smatrix colvector pT, pT2, dbdx0, dzdx, dzdt

	T = cholesky(V)
	if (T[1,1] == .) {
		errprintf("ghk2: covariance matrix is not positive-definite.\n")
		exit(3352)
	}

	b1 = X[,1] / T[1,1]
	_editmissing(Phib1 = normal(b1), 1); phib1 = normalden(b1)

	if ((d = rows(V)) == 1) {
		dfdx = phib1 / T
		dfdv = dfdx :* X * ((-.5) / V)
		return (Phib1)
	}
	n = rows(X)
	pT = pT2 = dbdx0 = smatrix(d, 1)
	for (j=d; j>1; j--) {
		pT[j].M = (pT2[j].M = T[|j,1 \ j,j-1|]' / -T[j,j]) \ 1/T[j,j]
		dbdx0[j].M = J(n, 1, 1/T[j,j])
	}

	sz = J(2, 2, .)
	dfdx = nd0 = J(n, d, 0)
	dfdv = nd20 = J(n, d2 = d*(d+1)*.5, 0)
	p = J(n, 1, 0)
	dlnfdxg1 = nd0; dlnpdtg1 = nd20
	dlnpdtg1[,1] = (dlnfdxg1[,1] = (phib1 :/ Phib1) / T[1,1]) :* -b1

	dzdx = smatrix(d,  1); for (k=d;  k; k--) dzdx[k].M = J(n, d-1, 0)
	dzdt = smatrix(d2, 1); for (k=d2; k; k--) dzdt[k].M = J(n, d-1, 0)

	Td = -diagonal(T); Td[1] = -Td[1]

	sW = s,. \ s-1+n,.
	for (a=1+(anti!=0); a>0; a--)
		for (g = pts.m; g; g--) {
			z = X; dlnfdxg = dlnfdxg1; dlnpdtg = dlnpdtg1; dbdx = nd0; dbdt = nd20

			// custom-coded first iteration over dimensions
			u = pts.W[a].M[g].M.M[|sW|]
			dzdb = u :* phib1 :/ normalden(z[,1] = invnormal(u :* Phib1))
			dzdt.M[,1] = ( dzdx.M[,1] = dzdb / Td[1] ) :* (-b1) 
			for (j=2; j<=d-1; j++) {
				sz[2,2] = j; l = j*(j+1)*.5; T2j = pT2[j].M; Tdj = Td[j]
				u = pts.W[a].M[g].M[j].M[|sW|]
				b = z[|sz|] * pT[j].M; _editmissing(Phib = normal(b), 1); phib = normalden(b); lambdab = phib :/ Phib

				pragma unset pg
				pg = j==2? Phib : pg:*Phib
				
				dzdb = u :* phib :/ normalden(z[,j] = invnormal(u :* Phib))
				dzdx[j  ].M[,j] = dzdb :* (dbdx[,j] = dbdx0[j].M)
				dzdt[l--].M[,j] = dzdb :* (dbdt[,l] = b / Tdj)    // j = i = k
	
				for (k=j-1; k; k--)  // j = i > k
					dzdt[l--].M[,j] = dzdb :* (dbdt[,l] = z[,k] / Tdj)
	
				for (i=sz[2,2]=j-1; i; i--) {
					dzdx[i].M[,j] = dzdb :* (dbdx[,i] = dzdx[i].M[|sz|] * T2j)
	
					for (k=i; k; k--) // j > i >= k
						dzdt[l--].M[,j] = dzdb :* (dbdt[,l] = dzdt[l].M[|sz|] * T2j)
				}
				dlnfdxg = dlnfdxg + lambdab :* dbdx
				dlnpdtg = dlnpdtg + lambdab :* dbdt
			}
	
			// custom-coded last iteration
			l = d2; T2j = pT2[d].M; Tdj = Td[d]
			b = z * pT[d].M; _editmissing(Phib = normal(b), 1); lambdab = normalden(b) :/ Phib
			if (d==2) {
				dbdx = nd0; dbdt = nd20
			}
			p = p + (pg = d==2? Phib : pg:*Phib)
			dbdx[,d] =  dbdx0[d].M
			dbdt[,l--] = b / Tdj
			dbdt[|.,l-d+2\.,l|] = z[|.,.\.,d-1|] / Tdj
			l = l - (d - 1)
			for (i=d-1; i; i--) {
				dbdx[,i] = dzdx[i].M * T2j
				for (k=i; k; k--) dbdt[,l--] = dzdt[l].M * T2j
			}
			dfdx = dfdx + (dlnfdxg + lambdab :* dbdx) :* pg
			dfdv = dfdv + (dlnpdtg + lambdab :* dbdt) :* pg
		}

	Phib1 = Phib1 / (anti? 2*pts.m : pts.m)
	dfdx = dfdx :* Phib1
	t = T; for (j=d; j; j--) for(i=j; i; i--) t[j,i] = d2--
	dfdv = (dfdv :* Phib1) * ghk2_dTdV(T)[invorder(vech(t)),]
	return (p :* Phib1)
}

real colvector _ghk2_2d(struct ghk2points scalar pts, real matrix Xl, real matrix Xu, real matrix V, real scalar anti, 
				real scalar s, real matrix dfdxl, real matrix dfdxu, real matrix dfdv) {
	real scalar i, j, j2, k, d, d2, n, g, l, a, Tdj
	real rowvector Td
	real colvector p, pg, Phibu, Phibu1, bu, bu1, phibu, phibu1, Phibl, Phibl1, bl, bl1, phibl, phibl1, u, Tj, p1, pgj, dlnpgjdbu, dlnpgjdbl, dzda, sign, sign1
	real matrix T, z, sz, sW, nd0, nd20, dlnpdxug, dlnpdxlg, dlnpdtg, dlnpdxug1, dlnpdxlg1, dlnpdtg1, dzdbu, dzdb, dbudxu, dbudxl, dbudt, dzdbl, dbldxu,dbldxl, dbldt, t, _Xu, _Xl
	struct smatrix colvector pT, dbdx0, dzdxu, dzdxl, dzdt

	T = cholesky(V)
	if (T[1,1] == .) {
		errprintf("ghk2: covariance matrix is not positive-definite.\n")
		exit(3352)
	}

	n = rows(Xl)
	pT = dbdx0 = smatrix(d=rows(V), 1)
	for (j=d; j>1; j--) {
		pT[j].M = T[|j,1 \ j,j-1|]' / -T[j,j]
		dbdx0[j].M = J(n, 1, 1/T[j,j])
	}
	Td = diagonal(T)'
	_editmissing(_Xu = Xu :/ Td, maxdouble()); _editmissing(_Xl = Xl :/ Td, -maxdouble())
	bu1 = _Xu[,1]; bl1 = _Xl[,1]
	sign1 = (bl1+ bu1:<=0)*2 :- 1
	Phibu1 = normal(sign1:*bu1); phibu1 = normalden(bu1)
	Phibl1 = normal(sign1:*bl1); phibl1 = normalden(bl1)

	p1 = abs(Phibu1 - Phibl1)
	if (d == 1) {
		dfdxu = phibu1 / T; dfdxl = phibl1 / -T
		dfdv = (-0.5)/T * (dfdxu  :* bu1  - dfdxl :* bl1)
		return (p1)
	}

	z = J(n, d-1, 0); p = J(n, 1, 0)
	dlnpdxug1 = dlnpdxlg1 = dfdxu = dfdxl = nd0 = J(n, d, 0)
	dlnpdtg1 = dfdv = nd20 = J(n, d2 = d*(d+1)*.5, 0)

	dlnpgjdbu = phibu1 :/ p1; dlnpgjdbl = phibl1 :/ p1     // dlnp_j/dbu_j = phi(bu_j)/(Phi(bu_j)-Phi(bl_j)). abs(dlnp_j/dbu_j) = phi(bu_j)/(Phi(bu_j)-Phi(bl_j))
	dlnpdxug1[,1] = dlnpgjdbu /  T[1,1]
	dlnpdxlg1[,1] = dlnpgjdbl / -T[1,1]
	_editmissing(bu1, 0); _editmissing(bl1, 0)
	dlnpdtg1[,1] = dlnpgjdbl :* bl1  - dlnpgjdbu :* bu1

	dzdxu = dzdxl = smatrix(d, 1)
	for (k=d; k; k--) {
		dzdxl[k].M = J(n, d-1, 0)
		dzdxu[k].M = J(n, d-1, 0)
	}

	dzdt = smatrix(d2, 1)
	for (k=d2; k; k--) dzdt[k].M = J(n, d-1, 0)

	sz = J(2, 2, .); sW = s,. \ s-1+n, .
	for (a=1+(anti!=0); a>0; a--)
		for (g = pts.m; g; g--) { // iterate over draws
			dlnpdxug = dlnpdxug1; dlnpdxlg = dlnpdxlg1; dlnpdtg = dlnpdtg1; dbudxu = dbudxl = nd0; dbudt = nd20

			// custom-coded first iteration over dimensions
			u = pts.W[a].M[g].M.M[|sW|]
			dzda = 1 :/ normalden(z[,1] = sign1 :* invnormal(sign1 :* u :* p1 :+ Phibl1))
			t = u :* dzda; dzdbu = phibu1 :* t; dzdbl = phibl1 :* (dzda :- t)

			dzdt.M[,1] = ( dzdxu.M[,1] = dzdbu / Td[1] ) :* -bu1 - ( dzdxl.M[,1] = dzdbl / Td[1] ):* bl1

			sz[2,2] = j2 = 1
			for (j=2; j<=d-1; sz[2,2]=j++) { // iterate over dimensions
				l = (j2 = j2 + j); Tdj = Td[j]

				t = z[|sz|] * (Tj = pT[j].M)
				bu = _Xu[,j] + t; bl = _Xl[,j] + t; 
				sign = (bl+ bu:<=0)*2 :- 1
				Phibu = normal(sign:*bu); phibu = normalden(bu)
				Phibl = normal(sign:*bl); phibl = normalden(bl)
				

				pragma unset pg
				pgj = abs(Phibu - Phibl)                                           // probability factor for this dimension
				pg = j==2? pgj : pg:*pgj                                                // cumulative product of probability factors sans first 1
				dlnpgjdbu = phibu :/ pgj                                                // dlnp_j/dbu_j = phi(bu_j)/(Phi(bu_j)-Phi(bl_j))
				dlnpgjdbl = phibl :/ pgj                                                // abs(dlnp_j/dbu_j) = phi(bu_j)/(Phi(bu_j)-Phi(bl_j))

				u = pts.W[a].M[g].M[j].M[|sW|]                                         // the draws
				dzda = 1:/ normalden(z[,j] = sign:* invnormal(sign :* u :* pgj :+ Phibl))              // z_j = invPhi(a_j). dz_j/da_j = 1/phi(z_j)
				t = u :* dzda; dzdbu = phibu :* t; dzdbl = phibl :* (dzda :- t)         // dz_j/dbu_j = u_j * phi(bu_j)/phi(z_j). dz_j/dbl_j = (1-u_j) * phi(bl_j)/phi(z_j)

				dzdb = dzdbu + dzdbl                                                    // total derivative w.r.t bu and bl useful since in most cases dbu's=dbl's
				for (k=j-1; k; k--)                                                     // case j = i > k
					dzdt[l].M[,j] = dzdb :*                                           // dz_j/dt_jk = dz_j/dbu_j * dbu_j/dt_jk + dz_j/dbl_j * dbl_j/dt_jk
						(dbudt[,--l] = z[,k] / -Tdj)                                // dbu_j/dt_jk = dbl_j/dt_jk = -z_k/t_jj  
				for (i=j-1; i; i--) {                                                   // case j > i >= k
					dzdxu[i].M[,j] = dzdb :*                                         // dz_j/dxu_i = dz_j/dbu_j * dbu_j/dxu_i + dz_j/dbl_j * dbl_j/dxu_i 
					            (dbudxu[,i] = dzdxu[i].M[|sz|] * Tj)                 // dbu_j/dxu_i = dbl_j/dxu_i = -sum_j(t_jk * dz_k/dxu_i) / t_jj     

					dzdxl[i].M[,j] = dzdb :*                                         // dz_j/dxl_i = dz_j/dbu_j * dbu_j/dxl_i + dz_j/dbl_j * dbl_j/dxl_i
					            (dbudxl[,i] = dzdxl[i].M[|sz|] * Tj)                 // dbu_j/dxl_i = dbl_j/dxl_i = -sum_j(t_jk * dz_k/dxl_i) / t_jj
	
					for (k=i; k; k--)
						dzdt[l].M[,j] = dzdb :*                                  // dz_j/dt_ik = dz_j/dbu_j * dbu_j/dt_ik + dz_j/dbl_j * dbl_j/dt_ik
							(dbudt[,l] = dzdt[--l].M[|sz|] * Tj)              // dbu_j/dt_ik = dbl_j/dt_ik = -sum_h(t_jh * dz_h/dt_ik) / t_jj
				}

				dbldxu = dbudxu; dbldxl = dbudxl; dbldt = dbudt                         // except for next calculations, dbu's = dbl's
				t = dbudxu[,j] = dbldxl[,j] = dbdx0[j].M                               // dbu_j/dxu_j = dbl_j/dxl_j = 1/t_jj (dbu_j/dxl_j = dbl_j/dxu_j = 0)
				dzdxu[j].M[,j] = dzdbu :* t                                            // dz_j/dxu_j = dz_j/dbu_j * dbu_j/dxu_j ( + dz_j/dbl_j * dbl_j/dxu_j = 0)
				dzdxl[j].M[,j] = dzdbl :* t                                            // dz_j/dxl_j = dz_j/dbl_j * dbl_j/dxl_j ( + dz_j/dbu_j * dbu_j/dxu_j = 0)
    
				_editvalue(bu, maxdouble(), 0); _editvalue(bl, -maxdouble(), 0)
				dzdt[j2].M[,j] = dzdbu :* (dbudt[,j2] = bu / -Td[j]) +                 // case j = i = k.  dbu_j/dt_jj = -bu/t_jj. dbl_j/dt_jj = -bl/t_jj
				                 dzdbl :* (dbldt[,j2] = bl / -Td[j])                   // dz_j/dt_jj = dz_j/dbu_j * dbu_j/dt_jj + dz_j/dbl_j * dbl_j/dt_jj 

				dlnpdxug = dlnpdxug + dlnpgjdbu :* dbudxu - dlnpgjdbl :* dbldxu         // dlnp_j/dxu_(j) = dlnp_j/dbu_j * dbu_j/dxu_(j) - abs(dlnp_j/dbl_j) * dbl_j/dxu_(j)
				dlnpdxlg = dlnpdxlg + dlnpgjdbu :* dbudxl - dlnpgjdbl :* dbldxl         // dlnp_j/dxl_(j) = dlnp_j/dbu_j * dbu_j/dxl_(j) - abs(dlnp_j/dbl_j) * dbl_j/dxl_(j)
				dlnpdtg  = dlnpdtg  + dlnpgjdbu :* dbudt  - dlnpgjdbl :* dbldt          // dlnp_j/dt_(j)  = dlnp_j/dbu_j * dbu_j/dt_(j)  - abs(dlnp_j/dbl_j) * dbl_j/dt_(j)
			}
			// custom-coded last iteration
			t = z * (Tj = pT[d].M)
			bu = _Xu[,j] + t; bl = _Xl[,j] + t; 
			sign = (bl+ bu:<=0)*2 :- 1
			pgj = abs(normal(sign:*bu) - normal(sign:*bl))

			dlnpgjdbu = normalden(bu) :/ pgj
			dlnpgjdbl = normalden(bl) :/ pgj

			p = p + (pg = d==2? pgj: pg :* pgj)

			dbudt[|.,d2-d+1\.,d2-1|] = z[|.,.\.,d-1|] / -Td[d]

			l = d2 - d
			for (i=d-1; i; i--) {
				dbudxu[,i] = dzdxu[i].M * Tj
				dbudxl[,i] = dzdxl[i].M * Tj
				for (k=i; k; k--) dbudt[,l--] = dzdt[l].M * Tj
			}
			dbldxu = dbudxu; dbldxl = dbudxl; dbldt = dbudt
			dbudxu[,d] = dbldxl[,d] = dbdx0[d].M
			_editvalue(bu, maxdouble(), 0); _editvalue(bl, -maxdouble(), 0)
			dbudt[,d2] = bu / -Td[d]
			dbldt[,d2] = bl / -Td[d]
			
			dfdxu = dfdxu + (dlnpdxug + dlnpgjdbu :* dbudxu - dlnpgjdbl :* dbldxu) :* pg 
			dfdxl = dfdxl + (dlnpdxlg + dlnpgjdbu :* dbudxl - dlnpgjdbl :* dbldxl) :* pg 
			dfdv  = dfdv  + (dlnpdtg  + dlnpgjdbu :* dbudt  - dlnpgjdbl :* dbldt ) :* pg
		}
	p1 = p1 / (anti? 2*pts.m : pts.m)
	dfdxu = dfdxu :* p1
	dfdxl = dfdxl :* p1
	t = T; for (j=d; j; j--) for(i=j; i; i--) t[j,i] = d2--
	dfdv = (dfdv :* p1) * ghk2_dTdV(T)[invorder(vech(t)),]
	return (p :* p1)
}

mata mlib create lghk2, dir("`c(sysdir_plus)'l") replace
mata mlib add lghk2 *(), dir("`c(sysdir_plus)'l")
mata mlib index
end


capture log close
set more off
set rmsg on
program drop _all
log using cs_avar, replace
about
which avar
which ivreg2
which ranktest
avar, version

clear
set obs 100
set seed 12345

gen double y1 = runiform()
gen double y2 = runiform()
gen double x1 = runiform()
gen double x2 = runiform()
gen double z1 = runiform()
gen double z2 = runiform()
qui reg y1 x1 x2
predict double e1, resid
qui reg y2 x1 x2
predict double e2, resid
qui reg y1 x1
predict double es1, resid
qui reg y2 x2
predict double es2, resid
qui ivreg y1 (x1 x2 = z1 z2)
predict double eiv1, resid
qui ivreg y2 (x1 x2 = z1 z2)
predict double eiv2, resid
gen int id1 = _n
gen int t1  = _n
gen int id2 = ceil(_n/5)
gen int t2  = 5-(id2*5-t1)

sum
list y1-x2 e1 e2 id1 t1 id2 t2 in 1/10

* Replicate some covariances

* OLS - classical (efficient)
qui mat accum XX=x1 x2
mat Sxx=XX*1/r(N)
mat Sxxi=syminv(Sxx)
qui reg y1 x1 x2
mat V1 = e(V)
qui avar e1 (x1 x2)
mat S=r(S)
mat Si=syminv(S)
mat V2 = syminv(Sxx*Si*Sxx)*1/r(N)
mat V2 = V2 * e(N)/e(df_r)			// Stata small sample correction
assert mreldif(V1,V2) < 1e-7

* OLS - robust (inefficient)
qui mat accum XX=x1 x2
mat Sxx=XX*1/r(N)
mat Sxxi=syminv(Sxx)
qui reg y1 x1 x2, rob
mat V1 = e(V)
qui avar e1 (x1 x2), rob
mat S=r(S)
mat V2 = Sxxi*S*Sxxi*1/r(N)
mat V2 = V2 * e(N)/e(df_r)			// Stata small sample correction
assert mreldif(V1,V2) < 1e-7

* IV - classical (efficient)
qui mat accum ZZ=z1 z2
mat Szz=ZZ*1/r(N)
mat Szzi=syminv(Szz)
qui mat accum A=x1 x2 z1 z2
mat A1 = A[3..5,1..2]
mat A2 = A[3..5,5..5]
mat Szx = (A1 , A2)*1/r(N)
qui ivreg y1 (x1 x2 = z1 z2)
mat V1 = e(V)
qui avar eiv1 (z1 z2)
mat S=r(S)
mat Si=syminv(S)
mat V2 = syminv(Szx'*Si*Szx)*1/r(N)
mat V2 = V2 * e(N)/e(df_r)			// Stata small sample correction
assert mreldif(V1,V2) < 1e-7

* IV - robust (inefficient)
qui mat accum ZZ=z1 z2
mat Szz=ZZ*1/r(N)
mat Szzi=syminv(Szz)
qui mat accum A=x1 x2 z1 z2
mat A1 = A[3..5,1..2]
mat A2 = A[3..5,5..5]
mat Szx = (A1 , A2)*1/r(N)
qui ivreg y1 (x1 x2 = z1 z2), rob
mat V1 = e(V)
qui avar eiv1 (z1 z2), rob
mat S=r(S)
mat V2 = syminv(Szx'*Szzi*Szx)*(Szx'*Szzi*S*Szzi*Szx)*syminv(Szx'*Szzi*Szx)*1/r(N)
mat V2 = V2 * e(N)/e(df_r)			// Stata small sample correction
assert mreldif(V1,V2) < 1e-7

* OLS - cluster
qui mat accum XX=x1 x2
mat Sxx=XX*1/r(N)
mat Sxxi=syminv(Sxx)
qui reg y1 x1 x2, cluster(id1)
mat V1 = e(V)
qui avar e1 (x1 x2), cluster(id1)
mat S=r(S)
mat V2 = Sxxi*S*Sxxi * 1/r(N)
* Stata small-sample correction
mat V2 = V2 * (e(N)-1)/(e(N)-e(df_m)-1) * e(N_clust)/(e(N_clust)-1)
assert mreldif(V1,V2) < 1e-7

* Newey-West
tsset t1
qui mat accum XX=x1 x2
mat Sxx=XX*1/r(N)
mat Sxxi=syminv(Sxx)
qui newey y1 x1 x2, lag(3)
mat V1 = e(V)
qui avar e1 (x1 x2), rob bw(4) kernel(bartlett)
mat S=r(S)
mat V2 = Sxxi*S*Sxxi*1/r(N)
mat V2 = V2 * e(N)/(e(df_r))		// Stata small sample correction
assert mreldif(V1,V2) < 1e-7

* sureg - 2 equations, exactly-identified, non-robust
qui mat accum XX=x1 x2
mat Sxx=XX*1/r(N)
mat Sxxi=syminv(Sxx)
sureg (y1 x1 x2) (y2 x1 x2)
mat V1 = e(V)
qui avar (e1 e2) (x1 x2)
mat S=r(S)
local cn : colfullnames S
mat KSxxi= I(2)#Sxxi				// K for Kronecker
mat V2 = KSxxi*S*KSxxi*1/r(N)		// no small-sample correction needed
mat rownames V2=`cn'
mat colnames V2=`cn'
assert mreldif(V1,V2) < 1e-7

* suest - 2 equations, robust
qui mat accum XX=x1 x2
mat Sxx=XX*1/r(N)
mat Sxxi=syminv(Sxx)
qui reg y1 x1 x2
est store eq_1
qui reg y2 x1 x2
est store eq_2
qui suest eq_1 eq_2
mat V1 = e(V)
mat V1a = V1[1..3,1..3]
mat V1b = V1[5..7,1..3]
mat V1c = V1[5..7,5..7]
mat V1 = (V1a, V1b') \ (V1b, V1c)
qui avar (e1 e2) (x1 x2), rob
mat S=r(S)
local cn : colfullnames S
mat KSxxi= I(2)#Sxxi				// K for Kronecker
mat V2 = KSxxi*S*KSxxi*1/r(N)
mat V2 = V2 * e(N)/(e(N)-1)			// Stata small-sample correction
mat colnames V2=`cn'
mat rownames V2=`cn'
assert mreldif(V1,V2) < 1e-7

* suest - 2 equations, robust, different regressors
qui reg y1 x1
est store eq_1
qui reg y2 x2
est store eq_2
qui suest eq_1 eq_2
mat V1 = e(V)
mat V1a = V1[1..2,1..2]
mat V1b = V1[4..5,1..2]
mat V1c = V1[4..5,4..5]
mat V1 = (V1a, V1b') \ (V1b, V1c)
qui avar (es1 es2) (x1 x2), rob
mat S=r(S)
mat Sa=S[1..1,1..6]
mat Sb=S[3..3,1..6]
mat Sc=S[5..5,1..6]
mat Sd=S[6..6,1..6]
mat S = Sa \ Sb \ Sc \ Sd
mat Sa=S[1..4,1..1]
mat Sb=S[1..4,3..3]
mat Sc=S[1..4,5..5]
mat Sd=S[1..4,6..6]
mat S = Sa , Sb , Sc , Sd
qui mat accum XX1=x1
mat Sxx1=XX1*1/r(N)
mat Sxx1i=syminv(Sxx1)
qui mat accum XX2=x2
mat Sxx2=XX2*1/r(N)
mat Sxx2i=syminv(Sxx2)
mat KSxxi= (Sxx1i, J(2,2,0)) \ (J(2,2,0), Sxx2i)
mat V2 = KSxxi*S*KSxxi*1/r(N)
mat V2 = V2 * e(N)/(e(N)-1)			// Stata small-sample correction
local cn : colfullnames S
mat colnames V2=`cn'
mat rownames V2=`cn'
assert mreldif(V1,V2) < 1e-7

* suest - 2 equations, cluster-robust
qui mat accum XX=x1 x2
mat Sxx=XX*1/r(N)
mat Sxxi=syminv(Sxx)
qui reg y1 x1 x2
est store eq_1
qui reg y2 x1 x2
est store eq_2
qui suest eq_1 eq_2, cluster(id2)
mat V1 = e(V)
mat V1a = V1[1..3,1..3]
mat V1b = V1[5..7,1..3]
mat V1c = V1[5..7,5..7]
mat V1 = (V1a, V1b') \ (V1b, V1c)
qui avar (e1 e2) (x1 x2), rob cluster(id2)
mat S=r(S)
local cn : colfullnames S
mat KSxxi= I(2)#Sxxi						// K for Kronecker
mat V2 = KSxxi*S*KSxxi*1/r(N)
mat V2 = V2 * e(N_clust)/(e(N_clust)-1)		// Stata small-sample correction
mat colnames V2=`cn'
mat rownames V2=`cn'
assert mreldif(V1,V2) < 1e-7

* Mimic mat opaccum - robust
sort id1
avar y1 (x1 x2), rob
mat S=r(S)
mat list S
mat opaccum A = x1 x2, opvar(y1) group(id1)
mat A=A/r(N)
mat list A
assert mreldif(S,A) < 1e-7

* Mimic mat opaccum - cluster
sort id2
avar y1 (x1 x2), rob cluster(id2)
mat S=r(S)
mat opaccum A = x1 x2, opvar(y1) group(id2)
mat A=A/r(N)
mat list A
assert mreldif(S,A) < 1e-7

* Check that smata option works properly
capture mata: mata drop S2
avar (e1 e2) (x1 x2), smata(S2)
mata: st_matrix("S2", S2)
assert mreldif(r(S),S2) < 1e-7

* Illustrate listwise behavior of avar
* Same as behavior of sureg
* sureg - 2 equations, exactly-identified, non-robust
gen double y1a=y1 if _n>10
gen double y2a=y2 if _n<91
sureg (y1a x1 x2) (y2a x1 x2)
mat V1 = e(V)
predict double esur1 if e(sample), eq(y1a) resid
predict double esur2 if e(sample), eq(y2a) resid
qui mat accum XX=x1 x2 if e(sample)
mat Sxx=XX*1/r(N)
mat Sxxi=syminv(Sxx)
qui avar (esur1 esur2) (x1 x2) if e(sample)
mat S=r(S)
local cn : colfullnames S
mat KSxxi= I(2)#Sxxi				// K for Kronecker
mat V2 = KSxxi*S*KSxxi*1/r(N)		// no small-sample correction needed
mat rownames V2=`cn'
assert mreldif(V1,V2) < 1e-7

capture log close
set more on
set rmsg off

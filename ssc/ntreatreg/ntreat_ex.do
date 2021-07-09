*"ntreat_ex.do", v.1.0, 10feb2015, by G. Cerulli
quietly{
set more off
clear
set matsize 1000 , permanently
set obs 200
set seed 10101
gen w=rbinomial(1,0.5)
gsort - w
count if w==1
global N1=r(N)
global N0=_N-$N1
mat def M=J(_N,_N,0) 
global N=_N
* 
forvalues i=1/$N{
forvalues j=1/$N1{
mat M[`i',`j']=runiform()
}
}
mat def SUM=J(_N,1,0)
forvalues i=1/$N{
forvalues j=1/$N1{
mat SUM[`i',1] = SUM[`i',1] + M[`i',`j']
}
}
forvalues i=1/$N{
forvalues j=1/$N1{
mat M[`i',`j']=M[`i',`j']/SUM[`i',1]
}
}
mat omega=M

*******************************
* Data Generating Process (DGP)
*******************************
scalar mu1=2
scalar b11=5
scalar b12=3
scalar e1=rnormal()
scalar mu0=5
scalar b01=7
scalar b02=1
scalar e0=rnormal() 
gen x1=rnormal()
gen x2=rnormal()
scalar gamma=0.8
gsort - w
gen y1 = mu1 + x1*b11 + x2*b12 + e1
gen y1_obs=w*y1
mkmat y1_obs , mat(y1_obs)
mat s = omega*y1_obs
mat list s
svmat s
gen y0 = mu0 + x1*b01 + x2*b02 + gamma*s1 + e0
gen y = y0 + w*(y1-y0)
gen te=y1-y0
sum te
scalar ATE=r(mean)
}
* End of "ntreat_ex.do"
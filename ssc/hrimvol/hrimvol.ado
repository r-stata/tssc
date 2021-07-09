
capture program drop _all
mata:mata clear
version 13.1
mata:
real scalar bs(real scalar s0,real scalar k,real scalar t,real scalar r,real scalar d,real scalar sigma){
x=log(s0/k)+(r-d)*t
sig=sigma*sqrt(t)
d1=x/sig+sig/2
d2=d1-sig
pv=exp(-r*t)
result=s0*normal(d1)-pv*k*normal(d2)
return(result)
}

real scalar hrimvol(real scalar s0,real scalar k,real scalar t,real scalar r,real scalar d,real scalar C){
sigmaL=1e-10
CL=bs(s0,k,t,r,d,sigmaL)
sigmaH=10
CH=bs(s0,k,t,r,d,sigmaH)
while (mean(sigmaH-sigmaL)>1e-10){
sigma=(sigmaL+sigmaH)/2
CM=bs(s0,k,t,r,d,sigma);
CL=CL+(CM<C)*(CM-CL)
sigmaL=sigmaL+(CM<C)*(sigma-sigmaL)
CH=CH+(CM>=C)*(CM-CH)
sigmaH=sigmaH+(CM>=C)*(sigma-sigmaH)
}
return(sigma)
}
end

program hrimvol,rclass
version 13
args s0 k time r d C
marksample touse
mata:hrimvol(`s0',`k',`time',`r',`d',`C')
end





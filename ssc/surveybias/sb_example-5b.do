use all-german-surveys , replace
mfp : reg gbw timetoelection n company1-company5
set scheme s2manual
fracplot , xscale(reverse)
graph export fig-1.eps, replace

use all-german-surveys , replace
mfp : reg gaprimespd timetoelection company2 company4
set scheme s2manual
fracplot , xscale(reverse)
graph export fig-2.eps, replace

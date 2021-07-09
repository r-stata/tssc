* (PBC data (Fleming and Harrington, Appendix D, 1991, Wiley))
use pbc, clear

stset time, f(status)

* unadjusted analysis through 10 years of follow-up
strmst2 treatment, tau(10) rmtl

* adjusted analysis through 10 years of follow-up
strmst2 treatment, tau(10) covariates(age bili albumin) rmtl

* create 3 arms for illustration of example with 3 arms
set seed 1234
replace treatment = 2 if uniform()<.3
tab treatment

strmst2 treatment, tau(10) reference(2) rmtl
strmst2 treatment, tau(10) covariates(age bili albumin) reference(2) rmtl

* pairwise contrasts - arm 0 versus arm 1
strmst2pw _Itreatment_1 _Itreatment_0, rmtl

* pairwise contrasts - arm 1 versus referent (arm 2)
strmst2pw _Itreatment_1, rmtl



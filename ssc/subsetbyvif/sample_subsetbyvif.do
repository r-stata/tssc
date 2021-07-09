log using SampleProgramFor_subsetByVIF.log, replace
* SampleProgramFor_subsetByVIF.log

* subsetByVIF is intended for data sets in which the number of covariates is
* large in comparison to the number of observations and the variance-covariance
* matrix is severely illconditioned. Below we illustrate the use of this program 
* in the sysuse auto data set.

sysuse auto

* collin is a contributed program written by Plilip Ender, that can be used in
* conjunction with subsampleByVIF. It can be downloaded from 
* https://stats.idre.ucla.edu/stat/stata/ado/analysis

collin price mpg weight length displacement gear_ratio foreign

* By default subsetByVIF uses a maximum VIF number of 10

subsetByVIF price mpg weight length displacement gear_ratio foreign

display "Value of vifmax = " r(vifmax1)
display "Number of variables in subset = " r(n1)
display "Subset of covariates = `r(covlist1)'"

* Each covariate in the preceding list has a VIF <=10 when this group of covariates
* are analyzed together.

collin `r(covlist1)'

* The following command gives two lists of covariates.  In the first list each covariate
* will have a VIF <= 15 when this list is analyzed as a group. The covariates in the 
* second list have VIFs <= 5

subsetByVIF price mpg weight length displacement gear_ratio foreign, viflist(15 5)
display "Number of maximum VIFs specified = " r(n_vif)
display "Largest value of vifmax = " r(vifmax1)
display "number of variables in subset = " r(n1)
display "Subset of covariates = " r(covlist1)

display "Second largest value of vifmax = " r(vifmax2)
display "number of variables in subset = " r(n2)
display "Subset of covariates = " r(covlist2)
local covlist2 = r(covlist2)

collin `r(covlist1)'
collin `covlist2'

* Create one list of covariates with VIFs <= 4

subsetByVIF price mpg weight length displacement gear_ratio foreign, viflist(4)

display "Value of vifmax = " r(vifmax1)
display "number of variables in subset = " r(n1)
display "Subset of covariates = " r(covlist1)
collin `r(covlist1)'

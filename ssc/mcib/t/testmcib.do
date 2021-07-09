/* testmcib.do 

Paul Jargowsky
June 14, 2019

*/

clear
cls
set more off

* First, create a temporary file with the bin amounts that will be used
tempfile amounts
input bin min max 
1 0 10000
2 10000 15000
3 15000 20000
4 20000 25000
5 25000 30000
6 30000 35000
7 35000 40000
8 40000 45000
9 45000 50000
10 50000 60000
11 60000 75000
12 75000 100000
13 100000 125000
14 125000 150000
15 150000 200000
16 200000 .
end
save `amounts'

* Now, we use the test data consisting of counts of 
* households by income bracket, aggregated from PUMS 2011
use pumstest 
des
sum
list in 1/3, clean noobs

* Reshape the data to be in metro/bin oberservations
reshape long hhs, i(metaread) j(bin)
merge m:1 bin using `amounts'
assert _merge==3
drop _merge
sort metaread bin
list in 1/48, noobs sepby(metaread)

* Now apply the estimator, using default settings, saving to output
mcib hhs min max, mean(meanhhy) by(metaread) saving(output) replace

* Merge with "true" parameters (estimated from individual-level)
* for comparison
clear
use output
merge 1:1 metaread using parameters
assert _merge==3
drop _merge

* Compute correlation of estimators and parameters as computed
* from the underlying individual data
foreach v of varlist sd-gini shrq? {
	corr `v' `v'_i 
	}

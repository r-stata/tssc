adopath + "C:\Users\\`c(username)\'\Dropbox (Heriot-Watt University Team)\Ditzen\Research\StataCode\simulate2\ado"
cap program drop simulate2
clear all

capture program drop testsimul
program define testsimul, rclass
	syntax anything
	
	clear
	set obs `anything'
	gen x = rnormal(1,4) 
	gen y = 2 + 3*x + rnormal()
	
	reg y x	
	
	matrix b = e(b)
	matrix se = e(V)
	scalar N = e(N)
	
	ereturn clear
	return scalar b = b[1,1]
	return scalar V = se[1,1]
	return scalar N = N
	return local time "`c(current_time)'"

end


local runs = 100

*** speed tests 

*** Oracle run; does not save!
timer clear 1
qui testsimul 200
timer on 1
set seed 123
forvalues i = 1(1)`runs' {
	qui testsimul 200
	noi disp ".", _c
}
timer off 1

*** Simulate
timer clear 2
timer on 2
simulate , reps(`runs') seed(123) : testsimul 200
timer off 2

*** Simulate2
timer clear 3
timer on 3
simulate2 , reps(`runs')  seedsave(test, frame) : testsimul 200
timer off 3

timer list

simulate s = r(b) k = r(N), reps(`runs'): testsimul 200

** only numeric
simulate2 s = r(b) k = r(N), reps(`runs'): testsimul 200
list in 1/10

** only strings
simulate2  v = r(time) , reps(`runs'): testsimul 200
list in 1/10

** mixed, numeric and strings
simulate2 s = r(b) v = r(time) n = r(N), reps(`runs'): testsimul 200
list in 1/10

** all
simulate2 , reps(`runs'): testsimul 200
list in 1/10

simulate2 , reps(`runs')  seed(123) seedsave(test,frame): testsimul 200
simulate2 , reps(`runs')  seed(123) seedsave("test"): testsimul 200

use test, clear
frame test: local seedf  `=seed[1]'
local seeds  `=seed[1]'

display `=("`seedf'"=="`seeds'")'

*** now check that if seed(test seed, frame) and seed(test seed, dta) produce same results
simulate2 , reps(`runs')  seed(123) seedsave(test, frame): testsimul 200
sum
simulate2 , reps(`runs')  seed(123) seedsave(test): testsimul 200
sum
simulate2 , reps(`runs')  seed(test seed, frame) : testsimul 200
sum
simulate2 , reps(`runs')  seed(test seed, frame) : testsimul 200
sum
simulate2 , reps(`runs')  seed(test seed rng seedstream, dta) : testsimul 200
sum

*** do funny things: 1. run MC with 2*reps and repeat with twice
simulate2, reps(`=2*`runs'') seed(123) seedsave(test,frame) saving(allruns, frame): testsimul 200

*** run on 1st 20 seeds; 
simulate2, reps(`runs') seed(test seed , frame start(1)) saving(first, frame): testsimul 200

*** run on seed 101 - 200; 
simulate2, reps(`runs') seed(test seed , frame start(`=`runs'+1')) saving(second, frame): testsimul 200
summarize
frame allruns: sum if _n > `runs'
frame allruns: sum if _n <= `runs'
frame first: sum

** now do the opposite, run, save seeds in frame, run again, append frame and then run all
local runs = 100
simulate2, reps(`runs') seed(123) seedsave(test,frame) saving(first, frame): testsimul 200
simulate2, reps(`runs') seedsave(test,frame append seednumber(`=`runs'+1')) aving(second, frame): testsimul 200

simulate2, reps(`=2*`runs'') seed(test seed ,frame) : testsimul 200
sum if _n <= `runs'
frame first: summarize
sum if _n > `runs'
frame second: summarize

*** look at test frame
frame test: list run rng 

*** save to dta
simulate2 , reps(100)  saving(test, replace): testsimul 200
** append
simulate2 , reps(100)  saving(test, append replace): testsimul 200

*** save to frame
simulate2 , reps(100)  saving(test, frame): testsimul 200
** append
simulate2 , reps(100)  saving(test, append frame): testsimul 200



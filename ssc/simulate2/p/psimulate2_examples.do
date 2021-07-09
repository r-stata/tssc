adopath + "C:\Users\\`c(username)\'\Dropbox (Heriot-Watt University Team)\Ditzen\Research\StataCode\simulate2\ado"
cap program drop simulate2
cap program drop psimulate2
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

local runs = 1000

** Run with simulate2 only
simulate , reps(`runs') seed(123): testsimul 200
frame copy `c(frame)' simulate, replace

** Run with simulate2 only
simulate2 , reps(`runs') seed(123) seedsave(seed1, frame) saving(simulate2, frame): testsimul 200

** Two instances with psimulate2
psimulate2 , reps(`runs') seed(123) p(2, temppath("C:\LocalStore\jd71\temp")) seedsave(seed, frame) saving(total, frame): testsimul 200

** Now run two with 500 and compare them to the results from before. Use the same seeds again
local runs = 500
psimulate2 , reps(`runs') seed(seed seed rng seedstream, frame) p(2, temppath("C:\LocalStore\jd71\temp"))  saving(first, frame): testsimul 200

psimulate2 , reps(`runs') seed(seed seed rng seedstream, frame start(501) ) p(2, temppath("C:\LocalStore\jd71\temp")) saving(second, frame) : testsimul 200

** Check results for _n > 500
sum b V 
frame total: sum b V if _n > 500
frame simulate: sum b V if _n > 500
frame simulate2: sum b V if _n > 500

** Check results for _n <= 500
frame total: sum b V if _n <= 500
frame first: sum b V
frame simulate: sum b V if _n <= 500
frame simulate2: sum b V if _n  <= 500
** simulate and simulate2 are different because simulate2 only uses seed stream number 1!

** To obtain the same results, use seeds saved in seed 1 from simulate2
** Now run two with 500 and compare them to the results from before. Use the same seeds again
local runs = 500
psimulate2 , reps(`runs') seed(seed1 seed rng seedstream, frame) p(2, temppath("C:\LocalStore\jd71\temp"))  saving(first, frame): testsimul 200

psimulate2 , reps(`runs') seed(seed1 seed rng seedstream, frame start(501) ) p(2, temppath("C:\LocalStore\jd71\temp")) saving(second, frame) : testsimul 200

frame second: sum b V 
frame simulate: sum b V if _n > 500
frame simulate2: sum b V if _n > 500

frame first: sum b V
frame simulate: sum b V if _n <= 500
frame simulate2: sum b V if _n  <= 500

*** All restuls are the same, but the seeds need to be know in advance!






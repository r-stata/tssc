*! 3.0.0 NJC 23 May 2007 
* 2.0.0 NJC 13 May 2007 
* 1.0.0 NJC 16 July 1997
* translation of Basic program NJC 1 March 1990
program group1d       
	version 9    
	syntax varname(numeric) [if] [in] , Max(int) [ Generate(str) ] 

	quietly { 
		marksample touse 
		count if `touse' 
		if r(N) == 0 error 2000
		local N = r(N) 

		if !inrange(`max', 1, `N') { 
			di as err "max() should be between 1 and `N'"
			exit 198
		}

		if "`generate'" != "" { 
			foreach g of local generate { 
				local eq = index("`g'", "=") 
				if `eq' == 0 { 
					di as err "generate(): invalid syntax" 
					exit 198
				}
				
				local gen = substr("`g'", 1, `eq' - 1) 
				confirm new variable `gen' 
				local G `G' `gen' 

				local k = substr("`g'", `eq' + 1, .)
				capture confirm integer number `k' 
				if _rc | !inrange(`k', 1, `max') { 
					di as err "generate(): `k' invalid"
					exit 198 
				}

				local K `K' `k' 
			}
		}
	}	

	mata : g1d_work("`varlist'", "`touse'", `max', "`G'", "`K'")
end

mata :  
void g1d_work(string scalar varname, 
	string scalar tousename, 
	real scalar max, 
	string scalar togen, 
	string scalar groups) 
{ 

	real colvector y
	real matrix gen, mg, sg 
	real scalar i, ii, iii, ik, il, iu, j, jj, l, ll, n, ntogen, N, 
		s, sn, ss, var 

	st_view(y = ., .,  varname, tousename) 
	N = length(y) 
	sg = mg = J(N, max, .)
	mg[1,] = J(1, max, 1)
	sg[1,] = J(1, max, 0)

	togen = tokens(togen) 
	groups = strtoreal(tokens(groups)) 
	ntogen = length(togen) 
	gen = J(N, ntogen, .) 

	for (i = 2; i <= N; i++) {
		s = ss = 0
		for (ii = 1; ii <= i; ii++) {
			iii = i - ii + 1
			s = s + y[iii]; ss = ss + y[iii]^2
			var = ss - s^2 / ii
			ik = iii - 1
			if (ik != 0) {
				for (j = 2; j <= max; j++) {
					if (sg[i, j] >= var + sg[ik, j-1]) {
						mg[i, j] = iii
						sg[i, j] = var + sg[ik, j-1] 
					}
				}
		        }
		}
		sg[i, 1] = var
		mg[i, 1] = 1 
	}

	printf("\n  Partitions of %f data up to %f groups\n", N, max) 

	for (j = max; j >= 1; j--) {
		jj = max - j + 1
		if (jj == 1) { 
			printf("\n  1 group:  sum of squares %3.2f\n", 
				sg[N, jj]) 
		} 
		else printf("\n  %f groups: sum of squares %3.2f\n", 
				jj, sg[N, jj]) 
		"Group Size    First            Last           Mean      SD"
		il = N + 1
		for (l = 1; l <= jj; l++) {
			ll = jj - l + 1
			s = ss = 0
			iu = il - 1
			il = mg[iu, ll]
			if (missing(il)) continue 
			
			if (ntogen) { 
				for (n = 1; n <= ntogen; n++) { 
					if (jj == groups[n]) gen[il, n] = il
				}	
			}
						
			for (ii = il; ii <= iu; ii++) {
				s = s + y[ii]; ss = ss + y[ii]^2
        		}
			sn = iu - il + 1
			s = s / sn
			ss = sqrt(ss / sn - s^2)
			printf("%4.0f %7.0f %4.0f %8.0g %7.0f %8.0g %8.2f %7.2f\n", 
				ll, sn, il, y[il], iu, y[iu], s, ss)
    		}

		if (sg[N, jj] == 0) break 
	}

	" " 
	"Groups     Sums of squares" 
	for (j = max; j >= 1; j--) {
		jj = max - j + 1
		printf("%6.0f %15.2f\n", jj, sg[N, jj]) 
    	}

	for (n = 1; n <= ntogen; n++) { 
		for (i = 2; i <= N; i++) { 
			gen[i, n] = 
			missing(gen[i, n]) ? gen[i-1, n] : gen[i-1, n] + 1
		}

		(void) st_addvar("float", togen[n]) 
		st_store(., togen[n], tousename, gen[,n]) 
	}	
}

end
 

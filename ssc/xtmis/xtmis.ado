*! version 1.0.0  18June2008
*! Minh Cong Nguyen / Email: congminh6@gmail.com
* count missing for cross section data by variable for all groups of interest


cap program drop xtmis
program define xtmis, byable(recall) sortpreserve
	
	version 9.2, missing
	
	set more off	
	syntax varlist(min=1 numeric) [if], Id(string)

	local sortby "`id'"	
	local nvars: word count `varlist'
	local varl `varlist'
	quietly {
		cap drop pd1
		bysort `sortby': gen pd1=_N
		xtdefine `sortby'
		mat group1=r(xtstr)
		gsort -pd1
		drop pd1
	}
	
	tomata `sortby'	
	mata: mysub("`varlist'")
end
/* ------------------------------------------------------- */ 
cap program drop xtdefine
prog def xtdefine, rclass sortpreserve
	syntax varlist(max=1)
	tempname pd Np Group
	quietly {
		bysort `varlist': gen `pd'=_N
		bysort `pd': gen `Np'=_N if _n==_N
		gsort -`pd'
		preserve
		keep if `Np'<.
		mkmat `Np', mat(`Group')	
	}
	return matrix xtstr=`Group'	
end

/* ------------------------------------------------------- */ 

version 9.2
mata:
void mysub(string scalar varname)
{
	real matrix Vall, group, X
	real scalar nvar, s, g, a, tmiss,tnonmiss, tobs
	vars = tokens(st_local("varl"))
	byvar = st_local("sortby")
	nvar=length(vars)
	
	Vall=st_data(.,vars)
	VarP=st_sdata(.,byvar)
	group = st_matrix("group1")
	
	printf("\n")
	for (s=1; s<=nvar;s++) {
		a=1
		tmiss=0
		tnonmiss=0
		tobs=0
		b=0
		printf("{txt}          Variable:{space 2} %8s\n", vars[s])
		printf("{txt}          Group by{space 1}{c |}      Obs     Missing  Feq.Missings  NonMiss  Feq.NonMiss\n")
	      printf("{hline 19}{c +}{hline 57}\n")
		for (j=1; j<=rows(group); j++) {
			
			X=Vall[a::group[j]+b,s]
			miss = colmissing(X)
			missP = (miss/group[j])*100
			nonmiss = group[j]-miss
			nonmissP = (nonmiss/group[j])*100
		      printf("{txt}%18s {c |}{res}%10.0g %10.0g %10.0g %10.0g %10.0g\n",VarP[a], group[j], miss, missP, nonmiss, nonmissP )
			a = a + group[j]
			b = b + group[j]
			tmiss = tmiss + miss
			tnonmiss = tnonmiss + nonmiss
			tobs = tobs + group[j]
		}
		tmissP = (tmiss/tobs)*100
		tnonmissP = (tnonmiss/tobs)*100
		printf("{hline 19}{c +}{hline 57}\n")
		printf("{space 19}{c |}{res}%10.0g %10.0g %10.0g %10.0g %10.0g\n", tobs, tmiss, tmissP, tnonmiss, tnonmissP )
		printf("\n")
	}	                                 

}
end

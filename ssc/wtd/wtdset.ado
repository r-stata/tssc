*! version 0.1, HS
*! version 0.2, HS Allow frequency weighting

/* wtdset
   wtdset, clear
   wtdset event exit, start(31dec1996) end(31dec1997) [id(id)
             robust cluster(clid) scale(365.25)]

   Compare with stset.
*/

program define wtdset
version 8.0

if replay() {
  wtd_is
  if `"`0'"' == "" { 
    wtd_show
    exit
  }
}

syntax varlist(numeric min=2 max=2) [if/] [fweight/], /*
                */ START(string)       /*
                */ END(string)        /*
                */ [ Id(varname)        /*
                */ robust               /*
		*/ CLuster(varname)    /*
                */ scale(real 1.0) ]

tokenize `varlist'
local event "`1'"
local exvar "`2'"

wtd_set set 	"`event'"	"`exvar'" /* 
		id	ifexp	  fwexp
	*/	"`id'"	`"`if'"' "`exp'"	/* 

		start		end		
	*/	`"`start'"'	`"`end'"'	/*

               robust
        */      "`robust'"      /*

		cluster
	*/	"`cluster'"	/*

		scale
	*/	"`scale'"
end




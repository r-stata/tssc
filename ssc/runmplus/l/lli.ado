* compare two ll
* update 8-28-2007 with correction factor
* instructions from http://www.statmodel.com/chidiff.shtml

program define lli , rclass
syntax , l0(string) l1(string) p0(string) p1(string) [c0(string) c1(string)]

if "`c1'"=="" {
	local c1=1
}
if "`c0'"=="" {
	local c0=1
}

local cd = (`p0' * `c0' - `p1'*`c1')/(`p0' - `p1')
local TRd = -2*(`l0' - `l1')/`cd'

di "difference test scaling correction (cd) =  " %12.3f `cd' 
di "Chi-square difference test              =  " %12.3f `TRd' "
di "P                                       =  " %12.3f  chiprob(abs(`p0'-`p1'),`TRd')

return scalar sblrt = `TRd'
return scalar sblrtp = chiprob(abs(`p0'-`p1'),`TRd')

end


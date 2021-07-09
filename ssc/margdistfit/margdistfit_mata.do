*  version 1.3.0 17Mar2012 MLB
*  version 1.2.0 13Dec2011 MLB
*  version 1.0.1 21Nov2011 MLB
*  version 1.0.0 14Nov2011 MLB
cd "c:/mijn documenten/projecten/stata/margdepfit/1.3.0"
mata:
mata clear

mata set matastrict on

mata mlib create lmargdistfit , replace

struct margdata {
	real matrix pars, fw
	scalar spar
}
mata mlib add lmargdistfit margdata()

void function marg_dangerous_sort(string scalar var, string scalar touse) {
	real matrix x
	st_view(x =., ., var, touse)
	x[.,.] = x[order(x,1)]
}
mata mlib add lmargdistfit marg_dangerous_sort()

end

do margdistfit_mata_beta.do
do margdistfit_mata_norm.do
do margdistfit_mata_poisson.do
do margdistfit_mata_zip.do
do margdistfit_mata_nb1.do
do margdistfit_mata_nb2.do
do margdistfit_mata_zinb.do
do margdistfit_mata_invert.do
do margdistfit_mata_approxF.do
do margdistfit_mata_discr.do

exit

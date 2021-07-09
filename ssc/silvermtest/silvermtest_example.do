use silica2
sum silica
di r(sd)
critiband1 silica, bwhigh(2.5) bwlow(.4) stsize(.01) mval(40)
set seed 12345
boot bootsamb, args(silica 2.4 4.291535) i(600)
keep ysm _rep
silvtest1 ysm _rep, cr(2.4) m(40) nurf(600) cnm(1) nog
use silica2, replace
set seed 12347
boot bootsamb, args(silica 1.83 4.291535) i(600)
keep ysm _rep
silvtest1 ysm _rep, cr(1.83) m(40) nurf(600) cnm(2) nog
use silica2, replace
set seed 12349
boot bootsamb, args(silica .69 4.291535) i(600)
keep ysm _rep
silvtest1 ysm _rep, cr(.69) m(40) nurf(600) cnm(3) nog
use silica, replace
set seed 12351
boot bootsamb, args(silica .47 4.291535) i(600)
keep ysm _rep
silvtest1 ysm _rep, cr(.47) m(40) nurf(600) cnm(4) nog
use silica2, replace
di (1.82+.69)/2
warpdenm1 silica, b(1.2) m(10) k(6) numodes modes nuamodes amodes
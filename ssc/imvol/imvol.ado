*! imvol V1.0 07jan2012
*! Emad Abd Elmessih Shehata
*! Assistant Professor
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage: http://emadstat.110mb.com/stata.htm
program imvol
version 10
syntax varlist(min=2 max=2) , [IR(str) Time(str) OPTion(str)]
local ps: word 1 of `varlist'
local pk: word 2 of `varlist'
scalar sig2=abs(ln(`ps'/`pk')+`ir'*`time')*(2/`time')
scalar sig=sqrt(sig2)
scalar ps=`ps'
scalar pk=`pk'
scalar tm=`time'
scalar ir=`ir'
scalar opt=`option'
forvalue i = 1/25 {
scalar d1= (ln(ps/pk)+(ir+sig*sig/2)*tm)/(sig*sqrt(tm))
scalar fn= exp(-d1*d1/2)/sqrt(2*_pi)
scalar pf= ps*sqrt(tm)*fn
scalar d2= d1-sig*sqrt(tm)
scalar c1= ps*normal(d1)-pk*exp(-ir*time)*normal(d2)
scalar sig=sig-(c1-opt)/pf
scalar imv=sig
 }
di
di _dup(63) "{bf:{err:=}}"
di as txt "{bf:{err:* Black-Scholes European Pricing Option Model}}"
di _dup(63) "{bf:{err:=}}"
di as txt "- Ps     = Stock  Price" _col(49) " = " as res %10.4f ps
di as txt "- Pk     = Strike Price" _col(49) " = " as res %10.4f pk
di as txt "- Pf     = Frame Prime" _col(49) " = " as res %10.4f pf
di as txt "- Time   = Expiration Time" _col(49) " = " as res %10.4f time
di as txt "- IR     = Interest Rate" _col(49) " = " as res %10.4f ir
di as txt "- Option = CALL or Put Price Option" _col(49) " = " as res %10.4f opt
di as txt "- Imv    = Implied Volatility CaLL or Put Option" _col(49) " = " as res %10.4f imv
di _dup(63) "{bf:{err:=}}"
end

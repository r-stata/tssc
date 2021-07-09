*! bseopm V1.0 07jan2012
*! Emad Abd Elmessih Shehata
*! Assistant Professor
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage: http://emadstat.110mb.com/stata.htm
program bsopm
version 10.0
syntax varlist(numeric min=2 max=2) , IR(str) Time(str) SIGma(str)
local ps: word 1 of `varlist'
local pk: word 2 of `varlist'
scalar ps=`ps'
scalar pk=`pk'
scalar time=`time'
scalar ir=`ir'
scalar sigma= `sigma'
scalar d1 = (ln(ps/pk)+(ir+(sigma^2)/2)*time)/(sigma*sqrt(time))
scalar d2 = d1-sigma*sqrt(time)
scalar CALL= ps*normal(d1)-pk*exp(-ir*time)*normal(d2)
scalar Put =-ps*normal(-d1)+pk*exp(-ir*time)*normal(-d2)
scalar sig2=abs(ln(ps/pk)+ir*time)*(2/time)
scalar sig=sqrt(sig2)
di
di _dup(55) "{bf:{err:=}}"
di as txt "{bf:{err:* Black-Scholes European Pricing Option Model}}"
di _dup(55) "{bf:{err:=}}"
di as txt "- Ps   = Stock  Pric" _col(41) " = " as res %10.4f ps
di as txt "- PK   = Strike Price" _col(41) " = " as res %10.4f pk
di as txt "- Time = Expiration Time" _col(41) " = " as res %10.4f time
di as txt "- IR   = Interest Rate" _col(41) " = " as res %10.4f ir
di as txt "- Sig  = Standard Deviation = Volatility" _col(41) " = " as res %10.4f sigma
di as txt "- CALL = Call Price" _col(41) " = " as res %10.4f CALL
di as txt "- Put  = Put  Price" _col(41) " = " as res %10.4f Put
di _dup(55) "{bf:{err:=}}"
end

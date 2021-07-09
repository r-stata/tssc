*! lmnreg3 V1.0 12dec2011
*! Emad Abd Elmessih Shehata
*! Assistant Professor
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage: http://emadstat.110mb.com/stata.htm

program define lmnreg3 , rclass
version 10
tempname E Sig2 LE Omega uv En
tempvar  E Sig2 TIMEN En
tempvar E Hat U2 DE LDE DF DF1 Es Yt U E2 Time
tempvar e pcs1 pcs2 pcs3 pcs4 estd
tempname estd s sqrtdinv corr corr3 corr4 mpc2 mpc3 mpc4 uinv q1 q2 uinv2
marksample touse
qui gen `TIMEN' =_n if `touse'
qui tsset `TIMEN'

local cmd `e(cmdline)'
local `e(cmdline)'
local method `e(method)'
local N=e(N)
local eQ=e(k_eq)
local eQ `eQ'
local vars `e(depvar)'
matrix `Omega'= e(Sigma)
di
di as txt "{bf:{err:=================================================}}"
di as txt "{bf:{err:* System Non Normality Tests (`e(method)') }}"
di as txt "{bf:{err:=================================================}}"
di "{bf:*** Single Equation Non Normality Tests:}
di as txt _col(2) "{bf: Ho: Normality - Ha: Non Normality}"
di
foreach i of local vars {
qui predict `E'`i' if `touse' , equation(`i') res
qui summ `E'`i' if `touse' , det
scalar lmnjb`i' = (r(N)/6)*((r(skewness)^2)+[(1/4)*(r(kurtosis)-3)^2])
scalar lmnjbp`i'  = chiprob(2, lmnjb`i')

di as txt _col(2) "Eq. `i'" _col(12) ": Jarque-Bera LM Test" _col(36) "=" as res %9.4f lmnjb`i' _col(54) as txt "P-Value > Chi2(2)" _col(73) as res %5.4f lmnjbp`i'
return scalar lmnjb_`i'=lmnjb`i'
return scalar lmnjbp_`i'= lmnjbp`i'
 }
qui mkmat `E'* if `touse' , matrix(`uv')
qui matrix `En'=vec(`uv')
preserve
qui svmat `En' , name(`En')
qui rename `En'1 `En'
qui summ `En' if `touse' , det
tempvar E U2 DE LDE DF DF1 Es Yt U E2 Time pcs1 pcs2 pcs3 pcs4 estd Enorm Enorm2
tempname corr corr3 corr4 mpc2 mpc3 mpc4 s sqrtdinv uinv q1 uinv2 q2
qui tsset `TIMEN'
scalar N=`N'
qui gen `Enorm' = `En' if `touse'
qui gen `Enorm2'=`Enorm'*`Enorm' if `touse' 
qui summ `Enorm' if `touse' , det
scalar Eb=r(mean)
scalar Sk=r(skewness)
scalar Ku=r(kurtosis)
scalar N=r(N)
qui forvalues i = 1/4 {
qui gen `Enorm'`i'=(`Enorm'-Eb)^`i' if `touse' 
qui summ `Enorm'`i' if `touse' , mean
scalar S`i'=r(mean)
 }
scalar M2=S2-S1^2
scalar M3=S3-3*S1*S2+S1^2
scalar M4=S4-4*S1*S3+6*S1^2*S2-3*S1^4
scalar K2=`N'*M2/(`N'-1)
scalar K3=`N'^2*M3/((`N'-1)*(`N'-2))
scalar K4=`N'^2*((`N'+1)*M4-3*(`N'-1)*M2^2)/((`N'-1)*(`N'-2)*(`N'-3))
scalar Ss=K3/(K2^1.5)
scalar Kk=K4/(K2^2)
local N=r(N)
scalar GK = ((Sk^2/6)+((Ku-3)^2/24))
scalar lmnjb =`N'*((Sk^2/6)+((Ku-3)^2/24))
scalar lmnjbp=chiprob(2,lmnjb)
scalar Sksd=sqrt(6*`N'*(`N'-1)/((`N'-2)*(`N'+1)*(`N'+3)))
scalar Kusd=sqrt(24*`N'*(`N'-1)^2/((`N'-3)*(`N'-2)*(`N'+3)*(`N'+5)))
qui gen `DE'=1 if `Enorm' > 0
qui replace `DE'=0 if `Enorm' <= 0
qui count if `DE' > 0
scalar N1=r(N)
scalar N2=N-r(N)
local EeN=(2*N1*N2)/(N1+N2)+1
local S2N=(2*N1*N2*(2*N1*N2-N1-N2))/((N1+N2)^2*(N1+N2-1))
local SN=sqrt((2*N1*N2*(2*N1*N2-N1-N2))/((N1+N2)^2*(N1+N2-1)))
qui gen `LDE'= L.`DE' 
qui replace `LDE'=0 if `DE'==1 in 1
qui gen `DF1'= 1 if `DE' != `LDE'
qui replace `DF1'= 1 if `DE' == `LDE' in 1
qui replace `DF1'= 0 if `DF1' == .
qui count if `DF1' > 0
local Rn=r(N)
scalar lmng=(`Rn'-`EeN')/`SN'
scalar lmngp=chiprob(2,abs(lmng))
local Lower= `EeN'-1.96*`SN'
local Upper= `EeN'+1.96*`SN'
qui summ `Enorm' if `touse' 
local N=r(N)
scalar mean=r(mean)
scalar sd=r(sd)
scalar small= 1e-20
qui cap drop `Es'
qui gen `Es' =`Enorm' if `touse' 
qui sort `Es' 
qui replace `Es'=normprob((`Es'-mean)/sd) if `touse' 
qui gen `Yt'=`Es'*(1-`Es'[`N'-_n+1]) if `touse' 
qui replace `Yt'=small if `Yt' < =0
qui replace `Yt'=sum( (2*_n-1)*log(`Yt')) if `touse' 
scalar A2=-`N'-`Yt'[`N']/`N'
scalar A2=A2*(1+(0.75+2.25/`N')/`N')
scalar X=1000/`N'
scalar B0=2.25247+0.317e-3*exp(0.0295*X)
scalar B1=2.16872+0.00243*exp(0.0277*X)
scalar B2=0.19135+0.00255*exp(0.0283*X)
scalar B3=0.110978+0.16243e-4*exp(0.03904*X)+ 0.00476*exp(0.02137*X)
scalar lmnad=log(A2)
local Z=abs(B0+lmnad*(B1+lmnad*(B2+lmnad*B3)))
scalar lmnadp=normprob(abs(`Z'))
qui summ `Enorm' if `touse' , det
scalar Sk=r(skewness)
scalar Ku=r(kurtosis)
local N=r(N)
scalar w2sq=-1+sqrt(2*((3*(`N'^2+27*`N'-70)/((`N'-2)*(`N'+5))*((`N'+1)/(`N'+7))*((`N'+3)/(`N'+9)))-1))
scalar ve= Sk*sqrt((`N'+1)*(`N'+3)/(6*(`N'-2)))/sqrt(2/(w2sq-1))
scalar lve=log(ve+(ve^2+1)^0.5)
scalar Skn = lve / sqrt(log(sqrt(w2sq)))
scalar g=((`N'+5)/(`N'-3))*((`N'+7)/(`N'+1))/(6*(`N'^2+15*`N'-4))
scalar a=(`N'-2)*(`N'^2+27*`N'-70)*g
scalar c=(`N'-7)*(`N'^2+2*`N'-5)*g
scalar k=(`N'*`N'^2+37*`N'^2+11*`N'-313)*g/2
scalar vz= c*Sk^2 +a
scalar Ku1= (Ku-1-Sk^2)*k*2
scalar Kun=(((Ku1/(2*vz))^(1/3))-1+1/(9*vz))*sqrt(9*vz)
scalar lmndh = Skn^2 + Kun^2
scalar lmndhp=chiprob(2,lmndh)
local n1=sqrt(`N'*(`N'-1))/(`N'-2)
local n2=3*(`N'-1)/(`N'+1)
local n3=(`N'^2-1)/((`N'-2)*(`N'-3))
local eb2=3*(`N'-1)/(`N'+1)
local vb2=24*`N'*(`N'-2)*(`N'-3)/(((`N'+1)^2)*(`N'+3)*(`N'+5))
local svb2=sqrt(`vb2')
scalar k1=6*(`N'*`N'-5*`N'+2)/((`N'+7)*(`N'+9))*sqrt(6*(`N'+3)*(`N'+5)/(`N'*(`N'-2)*(`N'-3)))
scalar a=6+(8/k1)*(2/k1+sqrt(1+4/(k1^2)))
qui summ `Enorm' if `touse' 
qui gen `estd' = `Enorm'-r(mean) if `touse' 
qui gen `pcs1'=sum(`estd') if `touse' 
qui gen `pcs2' =sum(`estd'^2) if `touse' 
qui gen `pcs3'=sum(`estd'^3) if `touse' 
qui gen `pcs4'=sum(`estd'^4) if `touse' 
qui mkmat `estd' if `touse' , matrix(`estd')
scalar dev=`pcs1'[`N']
scalar ss =`pcs2'[`N']
scalar m3 =`pcs3'[`N']
scalar m4 =`pcs4'[`N']
local pc1=dev
local pc2=ss
local pc3=m3
local pc4=m4
scalar devsq=dev*dev/`N'
scalar m2=(ss-devsq)/`N'
scalar sdev=sqrt(m2)
scalar m3=m3/`N'
scalar m4=m4/`N'
scalar sqrtb1=m3/(m2*sdev)
scalar b2=m4/m2^2
scalar g1=`n1'*sqrtb1
scalar g2=(b2-`n2')*`n3'
scalar stm3b2=(b2-`eb2')/`svb2'
scalar lmnsmk2=(1-2/(9*a)-((1-2/a)/(1+stm3b2*sqrt(2/(a-4))))^(1/3))/sqrt(2/(9*a))
scalar lmnsmk2p=(1-normal(abs(lmnsmk2)))
scalar b2minus3=b2-3
matrix `s'=`estd''*`estd'
matrix `sqrtdinv'=sqrt(`s'[1,1])
qui matrix `sqrtdinv'=inv(`sqrtdinv')
matrix `corr'=`sqrtdinv'*`s'*`sqrtdinv'
matrix `corr3'=`corr'[1,1]^3
matrix `corr4'=`corr'[1,1]^4
scalar y=sqrtb1*sqrt((`N'+1)*(`N'+3)/(6*(`N'-2)))
scalar k2=3*(`N'^2+27*`N'-70)*(`N'+1)*(`N'+3)/((`N'-2)*(`N'+5)*(`N'+7)*(`N'+9))
scalar wnw=sqrt(sqrt(2*(k2-1))-1)
scalar delta=1/sqrt(ln(wnw))
scalar alpha=sqrt(2/(wnw*wnw-1))
matrix yalpha = y / alpha
scalar yalpha = yalpha[1,1]
scalar lmnsms2=delta*ln(yalpha+sqrt(1+yalpha^2))
scalar lmnsms2p=2*(1-normal(abs(lmnsms2)))
scalar lmndp=lmnsms2^2+lmnsmk2^2
scalar lmndpp=chiprob(2,lmndp)
matrix `uinv'=inv(`corr3')
matrix `q1'=lmnsms2'*`uinv'*lmnsms2
scalar lmnsms1=`q1'[1,1]
scalar lmnsms1p=chiprob(1,abs(lmnsms1))
matrix `uinv2'=inv(`corr4')
matrix `q2'=lmnsmk2'*`uinv2'*lmnsmk2
scalar lmnsmk1=`q2'[1,1]
scalar lmnsmk1p=chiprob(1,lmnsmk1)
matrix `mpc2'=(`pc2'-(`pc1'^2/`N'))/`N'
matrix `mpc3'=(`pc3'-(3/`N'*`pc1'*`pc2')+(2/(`N'^2)*(`pc1'^3)))/`N'
matrix `mpc4'=(`pc4'-(4/`N'*`pc1'*`pc3')+(6/(`N'^2)*(`pc2'*(`pc1'^2)))-(3/(`N'^3)*(`pc1'^4)))/`N'
scalar pcb1=`mpc3'[1,1]/`mpc2'[1,1]^1.5
scalar pcb2=`mpc4'[1,1]/`mpc2'[1,1]^2
scalar sqb1p=pcb1^2
scalar b2p=pcb2
scalar lmnsvs=sqb1p*`N'/6
scalar lmnsvsp=chiprob(1,lmnsvs)
scalar lmnsvk=(b2p-3)*sqrt(`N'/24)
scalar lmnsvkp=2*(1-normal(abs(lmnsvk)))
di _dup(78) "-"
di
di "{bf:*** Overall System Non Normality Tests:}
di as txt "{bf: Ho: No Overall System Non Normality}"
di
di "{bf:*** Non Normality Tests:}
di as txt "- Jarque-Bera LM Test" _col(36) "=" as res %9.4f lmnjb _col(54) as txt "P-Value > Chi2(2) " _col(73) as res %5.4f lmnjbp
di as txt "- Doornik-Hansen LM Test" _col(36) "=" as res %9.4f lmndh _col(54) as txt "P-Value > Chi2(2) " _col(73) as res %5.4f lmndhp
di as txt "- Geary LM Test" _col(36) "=" as res %9.4f lmng _col(54) as txt "P-Value > Chi2(2) " _col(73) as res %5.4f lmngp
di as txt "- Anderson-Darling Z Test" _col(36) "=" as res %9.4f lmnad _col(54) as txt "P-Value>Z(" %6.3f `Z' ")" _col(73) as res %5.4f lmnadp
di as txt "- D'Agostino-Pearson LM Test " _col(36) "=" as res %9.4f lmndp _col(54) as txt "P-Value > Chi2(2)" _col(73) as res %5.4f lmndpp
di _dup(78) "-"
di "{bf:*** Skewness Tests:}
di as txt "- Srivastava LM Skewness Test" _col(36) "=" as res %9.4f lmnsvs _col(54) as txt "P-Value > Chi2(1)" _col(73) as res %5.4f lmnsvsp
di as txt "- Small LM Skewness Test" _col(36) "=" as res %9.4f lmnsms1 _col(54) as txt "P-Value > Chi2(1)" _col(73) as res %5.4f lmnsms1p
di as txt "- Skewness Z Test" _col(36) "=" as res %9.4f lmnsms2 _col(54) as txt "P-Value > Chi2(1)" _col(73) as res %5.4f lmnsms2p
di _dup(78) "-"
di "{bf:*** Kurtosis Tests:}
di as txt "- Srivastava Z Kurtosis Test" _col(36) "=" as res %9.4f lmnsvk _col(54) as txt "P-Value > Z(0,1)" _col(73) as res %5.4f lmnsvkp
di as txt "- Small LM Kurtosis Test" _col(36) "=" as res %9.4f lmnsmk1 _col(54) as txt "P-Value > Chi2(1)" _col(73) as res %5.4f lmnsmk1p
di as txt "- Kurtosis Z Test" _col(36) "=" as res %9.4f lmnsmk2 _col(54) as txt "P-Value > Chi2(1)" _col(73) as res %5.4f lmnsmk2p
di _dup(78) "-"
di as txt _col(5) "Skewness Coefficient = " _col(30) as res %7.4f Sk as txt "   " "  - Standard Deviation = " _col(48) as res %7.4f Sksd
di as txt _col(5) "Kurtosis Coefficient = " _col(30) as res %7.4f Ku as txt "   " "  - Standard Deviation = " _col(48) as res %7.4f Kusd
di _dup(78) "-"
di as txt _col(5) "Runs Test:" as res " " "(" `Rn' ")" " " as txt "Runs - " as res " " "(" N1 ")" " " as txt "Positives -" " " as res "(" N2 ")" " " as txt "Negatives"
di as txt _col(5) "Standard Deviation Runs Sig(k) = " as res %7.4f `SN' " , " as txt "Mean Runs E(k) = " as res %7.4f `EeN' 
di as txt _col(5) "95% Conf. Interval [E(k)+/- 1.96* Sig(k)] = (" as res %7.4f `Lower' " , " %7.4f `Upper' " )"
qui `cmd'
di _dup(78) "-"
return scalar lmnjb=lmnjb
return scalar lmnjbp= lmnjbp
return scalar lmndh= lmndh
return scalar lmndhp= lmndhp
return scalar lmng= lmng
return scalar lmngp= lmngp
return scalar lmnad= lmnad
return scalar lmnadp= lmnadp
return scalar lmndp= lmndp
return scalar lmndpp= lmndpp
return scalar lmnsvs= lmnsvs
return scalar lmnsvsp= lmnsvsp
return scalar lmnsms1= lmnsms1
return scalar lmnsms1p= lmnsms1p
return scalar lmnsms2= lmnsms2
return scalar lmnsms2p= lmnsms2p
return scalar lmnsvk= lmnsvk
return scalar lmnsvkp= lmnsvkp
return scalar lmnsmk1= lmnsmk1
return scalar lmnsmk1p= lmnsmk1p
return scalar lmnsmk2= lmnsmk2
return scalar lmnsmk2p= lmnsmk2p
return scalar sk= Sk
return scalar sksd= Sksd
return scalar ku= Ku
return scalar kusd= Kusd
return scalar sn= `SN'
return scalar en= `EeN'
return scalar lower= `Lower'
return scalar upper= `Upper'
end

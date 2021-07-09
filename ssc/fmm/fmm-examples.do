*! version 2.0.0  12jul2007
*! version 1.1.0  12jul2007
*! author: Partha Deb
*! version 1.0.0 06mar2007

clear all
set mem 10m
set more off

use http://urban.hunter.cuny.edu/~deb/Stata/datasets/mepssmall.dta
gen mc=(instype>1)


fmm docvis mc female minority age nchroniccond ///
	, mixtureof(poisson) components(2)
mat s=(e(b),0)
fmm docvis mc female minority age nchroniccond, mix(poisson) comp(3)
fmm docvis mc female minority age nchroniccond ///
	, mix(poisson) comp(2) prob(female) from(s)


fmm docvis mc female minority age nchroniccond, mix(negbin2) comp(2)
predict hat
predict hat1, eq(component1)
predict hat2, eq(component2)
predict hatpr, pri eq(component1)
predict hatpo, pos eq(component1)
sum docvis hat*
drop hat*

mfx
mfx, predict(eq(component1))
mfx, predict(eq(component2))

fmm docvis mc female minority age nchroniccond, mix(negbin2) comp(2) prob(female)
predict hatpr, pri eq(component1)
predict hatpo, pos eq(component1)
sum docvis hat*
drop hat*


use http://urban.hunter.cuny.edu/~deb/Stata/datasets/birthweight.dta, clear

fmm birthwt male edu momage income dadcohab parity numdead if white==1 ///
	, mix(normal) comp(2)
predict hat if white==1
predict hat1 if white==1, eq(component1)
predict hat2 if white==1, eq(component2)
predict hatpr if white==1, pri eq(component1)
predict hatpo if white==1, pos eq(component1)
sum birthwt hat*
drop hat*

mfx

fmm birthwt male edu momage income dadcohab parity numdead if white==1 ///
	, mix(normal) comp(2) prob(parity numdead)

fmm birthwt male edu momage income dadcohab parity numdead if white==1 ///
	, mix(studentt) comp(2) df(6)
predict hat if white==1
predict hat1 if white==1, eq(component1)
predict hat2 if white==1, eq(component2)
predict hatpr if white==1, pri eq(component1)
predict hatpo if white==1, pos eq(component1)
sum birthwt hat*
drop hat*

mfx


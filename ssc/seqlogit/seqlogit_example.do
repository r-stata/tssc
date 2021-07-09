discard
set more off
use gss.dta, clear

*Describing data

desc 
tab degree black, col

*Estimating model on white subsample

seqlogit degree sibs south country suburb city ///
   coh if black == 0, or                       ///
   tree(0:1 2 3 4, 1:2 : 3 4, 3 : 4)           ///
   ofinterest(paeduc) over(coh)                ///
   levels(0=9, 1=12, 2=14, 3=16, 4=18) 
estimates store white


*Estimating model on black subsample

drop _paeduc_X_coh

seqlogit degree sibs south country suburb city ///
   coh if black == 1,  or                      ///  
   tree(0:1 2 3 4, 1:2 : 3 4, 3 : 4)           ///
   ofinterest(paeduc) over(coh)                ///   
   levels(0=9, 1=12, 2=14, 3=16, 4=18) 
estimates store black


*Estimating effects on highest achieved level

preserve
sum paeduc, meanonly
local m = r(mean)

replace sibs= 2
replace south = 0
replace country = 0
replace suburb = 0
replace city = 0
replace paeduc = `m'
replace _paeduc_X_coh = coh*`m'

sort coh
by coh: keep if _n == 1

estimates restore white
predict effw, effect 


estimates restore black
predict effb, effect 

gen byr = coh *10 + 1900
label variable byr "year of birth"

twoway line effb effw byr,                             ///
   lpattern(longdash shortdash)                        ///
   xscale(range(1910 1980)) xlab(1920(20)1980)         ///
   ytitle("effect of father's education") name(effect) ///
   legend(order( 1 "black" 2 "white"))
restore

*Decomposing effect for white subsample

estimates restore white
#delimit ;
seqlogitdecomp, 
	overat(coh 2, coh 3, coh 4 , coh 5, coh 6, coh 7) 
	at(sibs 2 south 0 country 0 suburb 0 city 0) 
	subtitle("1920" "1930" "1940" "1950" "1960" "1970") 
	title("white") name(white) 
	eqlabel(
	`""high school or more" "v. less than high school""' 
	`""junior college" "v. high school or" "bachelor and graduate""'
	`""bachelor and graduate" "v. high school or" "junior college""'
	`""graduate" "v. bachelor""'
	) 
	yscale(range(-.1 .3)) xscale(range(-.1 1.2)) xlabel(0(.5)1)
	yline(0) xline(0) ;
#delimit cr


*Decomposing effects on black subsample

estimates restore black

#delimit ;
seqlogitdecomp, 
	overat(coh 2, coh 3, coh 4 , coh 5, coh 6, coh 7) 
	at(sibs 2 south 0 country 0 suburb 0 city 0) 
	subtitle("1920" "1930" "1940" "1950" "1960" "1970") 
	title("black") name(black) 
	eqlabel(
	`""high school or more" "v. less than high school""' 
	`""junior college" "v. high school or" "bachelor and graduate""'
	`""bachelor and graduate" "v. high school or" "junior college""'
	`""graduate" "v. bachelor""'
	) 
	yscale(range(-.1 .3)) xscale(range(-.1 1.2)) xlabel(0(.5)1)
	yline(0) xline(0) ;
#delimit cr

*Transition probabilities

preserve
sum paeduc, meanonly
local m = r(mean)

replace sibs= 2
replace south = 0
replace country = 0
replace suburb = 0
replace city = 0
replace paeduc = `m'
replace _paeduc_X_coh = coh*`m'

sort coh
by coh: keep if _n == 1

estimates restore white
predict prw*, trpr 

gen byr = coh *10 + 1900
label variable byr "year of birth"

twoway line prw* byr, ///
 xscale(range(1910 1980)) xlab(1920(20)1980) ///
 ytitle("transition probability") name(trw) ///
 title("white") ///
 legend(order(  ///
        1 "high school or more v. less than high school" ///
        2 "junior college v. high school or bachelor and graduate" ///
        3 "bachelor and graduate v. high school or junior college" ///
        4 "graduate v. bachelor") ) 


estimates restore black
predict prb*, trpr

twoway line prb* byr, ///
 xscale(range(1910 1980)) xlab(1920(20)1980) ///
 ytitle("transition probability") name(trb) ///
 title("black") ///
 legend(order(  ///
        1 "high school or more v. less than high school" ///
        2 "junior college v. high school or bachelor and graduate" ///
        3 "bachelor and graduate v. high school or junior college" ///
        4 "graduate v. bachelor") ) 

grc1leg trw trb, name(trans)

restore


*Decomposing weights 

preserve
sum paeduc, meanonly
local m = r(mean)

replace sibs= 2
replace south = 0
replace country = 0
replace suburb = 0
replace city = 0
replace paeduc = `m'
replace _paeduc_X_coh = coh*`m'

sort coh
by coh: keep if _n == 1

estimates restore white
predict atriskw*, tratrisk
predict varw*, trvar
predict gainw*, trgain 
predict weiw*, trweight 

gen byr = coh *10 + 1900
label variable byr "year of birth"

twoway line atriskw* byr, name(rw) ///
 xscale(range(1910 1980)) xlab(1920(20)1980) ///
 legend(order( ///
        1 "high school or more v." "less than high school" ///
        2 "junior college v." "high school or" "bachelor and graduate" ///
        3 "bachelor and graduate v." "high school or" "junior college" ///
        4 "graduate v." "bachelor") size(vsmall) ) ///
 ytitle("at risk")
twoway line varw* byr, name(vw) ///
  xscale(range(1910 1980)) xlab(1920(20)1980) ///
  legend(order( ///
        1 "high school or more v." "less than high school" ///
        2 "junior college v." "high school or" "bachelor and graduate" ///
        3 "bachelor and graduate v." "high school or" "junior college" ///
        4 "graduate v." "bachelor") size(vsmall) ) ///
  ytitle("variance")
twoway line gainw* byr, name(gw) ///
 xscale(range(1910 1980)) xlab(1920(20)1980) ///
 legend(order( ///
        1 "high school or more v." "less than high school" ///
        2 "junior college v." "high school or" "bachelor and graduate" ///
        3 "bachelor and graduate v." "high school or" "junior college" ///
        4 "graduate v." "bachelor") size(vsmall) ) ///
  ytitle("gain")
twoway line weiw* byr, name(ww) ///
 xscale(range(1910 1980)) xlab(1920(20)1980) ///
legend(order( ///
        1 "high school or more v." "less than high school" ///
        2 "junior college v." "high school or" "bachelor and graduate" ///
        3 "bachelor and graduate v." "high school or" "junior college" ///
        4 "graduate v." "bachelor") size(vsmall) ) ///
  ytitle("weight")

grc1leg rw vw gw ww, cols(3) holes(4) name(cw) title("white") ring(0) pos(4)


estimates restore black
predict atriskb*, tratrisk
predict varb*, trvar
predict gainb*, trgain 
predict weib*, trweight 

twoway line atriskb* byr, name(rb) ///
 xscale(range(1910 1980)) xlab(1920(20)1980) ///
 legend(order( ///
        1 "high school or more v." "less than high school" ///
        2 "junior college v." "high school or" "bachelor and graduate" ///
        3 "bachelor and graduate v." "high school or" "junior college" ///
        4 "graduate v." "bachelor") size(vsmall) ) ///
  ytitle("at risk")
twoway line varb* byr, name(vb) ///
 xscale(range(1910 1980)) xlab(1920(20)1980) ///
 legend(order( ///
        1 "high school or more v." "less than high school" ///
        2 "junior college v." "high school or" "bachelor and graduate" ///
        3 "bachelor and graduate v." "high school or" "junior college" ///
        4 "graduate v." "bachelor") size(vsmall) ) ///
  ytitle("variance")
twoway line gainb* byr, name(gb) ///
 xscale(range(1910 1980)) xlab(1920(20)1980) ///
 legend(order( ///
        1 "high school or more v." "less than high school" ///
        2 "junior college v." "high school or" "bachelor and graduate" ///
        3 "bachelor and graduate v." "high school or" "junior college" ///
        4 "graduate v." "bachelor") size(vsmall) ) ///
  ytitle("gain")
twoway line weib* byr, name(wb) ///
 xscale(range(1910 1980)) xlab(1920(20)1980) ///
 legend(order( ///
        1 "high school or more v." "less than high school" ///
        2 "junior college v." "high school or" "bachelor and graduate" ///
        3 "bachelor and graduate v." "high school or" "junior college" ///
        4 "graduate v." "bachelor") size(vsmall) ) ///
  ytitle("weight")

grc1leg rb vb gb wb, cols(3) holes(4) name(cb) title("black") ring(0) pos(4)


restore

* Unobserved heterogeneity


drop _paeduc_X_coh
seqlogit degree sibs south country suburb city  coh if black == 0, ///
         or  tree(0:1 2 3 4, 1:2 : 3 4, 3 : 4)  ///
         ofinterest(paeduc) over(coh) sd(1)


uhdesc, draws(10) at(south 0 country 0 suburb 0 city 0)
         
uhdesc, overat(coh 1.5, coh 3 , coh 4.5, coh 6, coh 7.5) ///
        draws(10) overlab(1915 1930 1945 1960 1975) ///
        at(south 0 country 0 suburb 0 city 0)


drop _paeduc_X_coh
seqlogit degree sibs south country suburb city  coh if black == 0, ///
         or  tree(0:1 2 3 4, 1:2 : 3 4, 3 : 4)  ///
         ofinterest(paeduc) over(coh) sd(1) rho(.2)
uhdesc, draws(10) at(south 0 country 0 suburb 0 city 0)

exit

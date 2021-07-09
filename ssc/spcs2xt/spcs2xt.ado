*! spcs2xt V3.0 20/12/2012
*! 
*! Emad Abd Elmessih Shehata
*! Professor (PhD Economics)
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage:               http://emadstat.110mb.com/stata.htm
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

program define spcs2xt
version 10
syntax varlist , Time(string) Matrix(string)
mkmat `varlist' , matrix(`matrix')
mat `matrix'xt =`matrix'#I(`time')
qui svmat `matrix'xt
qui keep `matrix'xt*
qui renpfix `matrix'xt v
di as txt "****************************************************"
di as txt "*** Cross Section Weight Matrix (`matrix')"
di as txt "*** Panel Weight Matrix         (`matrix'xt)"
di as txt "*** Panel Weight Matrix File    (`matrix'xt.dta)"
di as txt "****************************************************"
qui save `matrix'xt.dta , replace
pwd
end


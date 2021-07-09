*! version 3.2 : February 6th, 2012
*! Jean-Benoit Hardouin, Myriam Blanchin
************************************************************************************************************
* raschpower: Estimation of the power of the Wald test in order to compare the means of the latent trait in two groups of individuals
*
* Version 1 : January 25, 2010 (Jean-Benoit Hardouin)
* Version 1.1 : January 26, 2010 (Jean-Benoit Hardouin)
* Version 1.2 : November 1st, 2010 (Jean-Benoit Hardouin)
* version 1.3 : May 2th, 2011 (Jean-Benoit Hardouin)
* version 1.4 : July 7th, 2011 (Jean-Benoit Hardouin) : minor corrections
* version 1.5 : July 11th, 2011 (Jean-Benoit Hardouin) : minor corrections
* version 2 : August 30th, 2011 (Jean-Benoit Hardouin, Myriam Blanchin) : corrections
* version 3 : October 18th, 2011 (Jean-Benoit Hardouin, Myriam Blanchin) : Extension to the PCM, -method- option, -nbpatterns- options, changes in the presentation of the results
* version 3.1 : October 25th, 2011 (Jean-Benoit Hardouin, Myriam Blanchin) : POPULATION+GH method
* version 3.2 : February 6th, 2012 (Jean-Benoit Hardouin, Myriam Blanchin) : minor corrections
*
* Jean-benoit Hardouin, jean-benoit.hardouin@univ-nantes.fr
* Myriam Blanchin, myriam.blanchin@univ-nantes.fr
* EA 4275 "Biostatistics, Pharmacoepidemiology and Subjectives Measures in Health"
* Faculty of Pharmaceutical Sciences - University of Nantes - France
*
* News about this program : http://www.anaqol.org
* FreeIRT Project : http://www.freeirt.org
*
* Copyright 2010-2012 Jean-Benoit Hardouin, Myriam Blanchin
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 2 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
************************************************************************************************************/

program define raschpower,rclass
syntax [varlist] [, n0(int 100) n1(int 100) Gamma(real .5) Difficulties(string) Var(real 1) Method(string) NBPatterns(int 2) nodata EXPectedpower(real -1)]
version 11

tempfile raschpowerfile
capture qui save "`raschpowerfile'",replace
tempname db d
if "`difficulties'"=="" {
   matrix `d'=[-1.151, -0.987\-0.615, -0.325\-0.184, -0.043\0.246, 0.554\0.782, 1.724]
}
else {
   matrix `d'=`difficulties'
}
local nbitems=rowsof(`d')
local nbmodat=colsof(`d')+1
if "`method'"=="MEAN+GH"&`nbpatterns'*(`n1'+`n0')>=`=`nbmodat'^`nbitems'*2' {
   di in gr "The MEAN+GH will be inefficient compared to GH since the maximal number of pattern's responses"
   di in gr "is lesser than the number of pattern retained by the MEAN+GH method."
   di in gr "The -method- option is replaced by GH."
   local method GH
}
else if "`method'"=="" {
    if `nbmodat'^`nbitems'*2<1000 {
        local method GH
    }
    else if `nbmodat'^`nbitems'<10000 {
        local method MEAN+GH
    }
    else if `nbmodat'^`nbitems'<1000000 {
        local method MEAN
    }
    else  {
        local method POPULATION+GH
    }
}



di in gr "Method:  " in ye "`method'"
di in gr "Number of individuals in the first group:  " in ye `n0'
di in gr "Number of individuals in the second group: " in ye `n1'
di in green "Group effect: " in ye `gamma'
di in  gr "Variance of the latent trait: " in ye `var'
di in gr "Number of items: " in ye `nbitems'
di in green "Difficulties parameters of the items: "
tempname dd
matrix `dd'=`d''
local items
forvalues i=1/`nbitems' {
   local items "`items' item`i'"
}
local modalities
forvalues i=1/`=`nbmodat'-1' {
   local modalities "`modalities' delta_`i'"
}

matrix colnames `dd'=`items'
matrix rownames `dd'=`modalities'
matrix list `dd',noblank nohalf  noheader
di in gr "Number of studied response's patterns: " in ye `=`nbmodat'^`nbitems'*2'

matrix `dd'=`d'
local gamma=`gamma'

local tmp=1
qui matrix `db'=J(`=`nbitems'*(`nbmodat'-1)',1,.)
forvalues j=1/`nbitems' {
   forvalues m=1/`=`nbmodat'-1' {
      qui matrix `db'[`tmp',1]=`d'[`j',`m']
      local ++tmp
   }
}

if "`data'"=="" {
   clear
   if "`method'"!="POPULATION+GH"{
      local temp=`nbmodat'^(`nbitems')
      qui range x 0 `=`temp'-1' `temp'
      qui g t=x
      loc i=`nbitems'
      qui count if t>0
      loc z=r(N)
      qui while `z'>0 {
         qui gen item`=`nbitems'-`i'+1'=floor(t/`nbmodat'^`=`i'-1')
         qui replace t=mod(t,`nbmodat'^`=`i'-1')
         qui count if t>0
         loc z=r(N)
         loc i=`i'-1
      }
      drop t
      qui expand 2
      qui gen group=0 in 1/`temp'
      qui replace group=1 in `=`temp'+1'/`=2*`temp''
   }
   else {
      qui simirt, clear pcm(`difficulties') cov(`var') group(`=`n1'/(`n1'+`n0')') deltagroup(`gamma') nbobs(1000000)
      qui drop lt1
      qui contract item* group, freq(freq)
      qui gen keep=0
      qui gsort +group -freq
      qui replace keep=1 in 1/`=`nbpatterns'*`n0''
      qui gsort -group -freq
      qui replace keep=1 in 1/`=`nbpatterns'*`n1''
      qui keep if keep==1
      qui count
      local tmp=r(N)
      di "Number of kept patterns:`tmp'"
      local method GH
   }
   qui gen mean=-`n1'*`gamma'/(`n0'+`n1') if group==0
   qui replace mean=`n0'*`gamma'/(`n0'+`n1') if group==1

   if "`method'"=="GH" {
      local temp=`nbmodat'^(`nbitems')
      local diff0=0
      qui gen proba=.
      local dixj=10
      qui count
      local tmp=r(N)
      forvalues i=1/`tmp' {
         local dix=floor(`tmp'/10)
         if mod(`i',`dix')==0 {
            if "`dixj'"!="10" {
               di ".." _c
            }
            di "`dixj'%" _c
            local dixj=`dixj'+10
         }
         local int=1
         forvalues j=1/`nbitems' {
            qui su item`j' in `i'
            local rep=r(mean)
            local diff0=0
            local diff1=`d'[`j',1]
            local sum "1+exp(x-`diff1')"
            forvalues m=2/`=`nbmodat'-1' {
               local diff`m'=`diff`=`m'-1''+`d'[`j',`m']
               local sum "`sum'+exp(`m'*x-`diff`m'')"
            }
            local int "(`int'*exp(`rep'*x-`diff`rep''))/(`sum')"
         }
         qui su mean in `i'
         local mean=r(mean)
         qui gausshermite `int',mu(`mean') sigma(`=sqrt(`var')') display
         qui replace proba=r(int) in `i'
      }
      di
   }
   else {
      qui gen proba=1
      forvalues i=1/`nbitems' {
         local diff0=0
         local diff1=`d'[`i',1]
         qui gen eps0=1
         qui gen eps1=exp(mean-`diff1')
         qui gen d=eps0+eps1
         forvalues m=2/`=`nbmodat'-1' {
            local diff`m'=`diff`=`m'-1''+`d'[`i',`m']
            qui gen eps`m'=exp(`m'*mean-`diff`m'')
            qui replace d=d+eps`m'
         }
         local listeps
         forvalues m=0/`=`nbmodat'-1' {
            qui replace proba=proba*eps`m'/d if item`i'==`m'
            local listeps `listeps' eps`m'
         }
         qui drop `listeps' d
      }
      if "`method'"=="MEAN+GH" {
      set tracedepth 1
         qui gen keep=0
         qui gsort -group -proba
         local min=min(`=`nbmodat'^`nbitems'',`=`n1'*`nbpatterns'')
         qui replace keep=1 in 1/`min'
         qui gsort +group -proba
         local min=min(`=`nbmodat'^`nbitems'',`=`n0'*`nbpatterns'')
         qui replace keep=1 in 1/`min'
         qui keep if keep==1
         qui su proba if group==0
         local sumproba0=r(sum)*100
         qui su proba if group==1
         local sumproba1=r(sum)*100


         qui drop keep proba
         local diff0=0
         qui gen proba=.
         qui count
         local nnew=r(N)
         di in gr "Number of studied response's patterns for the GH step: " in ye `nnew'
         di in gr "(" in ye %6.2f `sumproba0' in gr "% of the group 0 and " in ye %6.2f `sumproba1' in gr "% of the group 1)"
         local dixj=10
         forvalues i=1/`nnew' {
            local dix=floor(`nnew'/10)
            if mod(`i',`dix')==0 {
               if "`dixj'"!="10" {
                  di ".." _c
               }
               di "`dixj'%" _c
               local dixj=`dixj'+10
            }
            local int=1
            forvalues j=1/`nbitems' {
               qui su item`j' in `i'
               local rep=r(mean)
               local diff0=0
               local diff1=`d'[`j',1]
               local sum "1+exp(x-`diff1')"
               forvalues m=2/`=`nbmodat'-1' {
                  local diff`m'=`diff`=`m'-1''+`d'[`j',`m']
                  local sum "`sum'+exp(`m'*x-`diff`m'')"
               }
               local int "(`int'*exp(`rep'*x-`diff`rep''))/(`sum')"
            }
            qui su mean in `i'
            local mean=r(mean)
            qui gausshermite `int',mu(`mean') sigma(`=sqrt(`var')') display
            qui replace proba=r(int) in `i'
         }
      }
   }
   qui gen eff=.
   forvalues i=0/1 {
      qui replace eff=proba*`n`i'' if group==`i'
   }
   qui replace eff=proba
   qui keep item* eff group proba

   local p1=1/`n1'
   local p0=1/`n0'
   qui gen eff2=.
   qui replace eff2=floor(eff/`p1') if group==1
   qui replace eff2=floor(eff/`p0') if group==0
   qui replace eff=eff-eff2*(`p1'*group+`p0'*(1-group))
   qui su eff2 if group==1
   local aff1=r(sum)
   qui su eff2 if group==0
   local aff0=r(sum)

   local unaff1=`n1'-`aff1'
   local unaff0=`n0'-`aff0'
   qui gen efftmp=eff2
   qui gsort + group - eff
   qui replace eff2=eff2+1 in 1/`unaff0'
   qui gsort - group - eff
   qui replace eff2=eff2+1 in 1/`unaff1'

   qui drop if eff2==0
   gsort group item*
   qui expand eff2
   qui drop proba eff eff2
}

qui alpha item*
local alpha=r(alpha)
qui gen groupc=group-.5
if `nbmodat'==2 {
   qui gen i=_n

   tempname diff
   matrix `diff'=`dd''

   qui reshape long item, i(i)
   qui rename item rep
   qui rename _j item

   qui gen  offset=0
   forvalues i=1/`nbitems' {
      qui replace offset=-`diff'[1,`i'] if item==`i'
   }

  constraint 1 _cons=`=ln(`var')'
  qui xtlogit rep groupc ,nocons i(i) offset(offset) constraint(1)
   tempname b V
}
else {
   matrix `db'=`db''
   di "qui pcm item*, fixed(`db') covariates(groupc) fixedmu fixedvar(`var')"
   *qui pcm item*, fixed(`db') covariates(groupc) fixedmu fixedvar(`var')

}

	tempname b V
	matrix `b'=e(b)
	matrix `V'=e(V)
	local gammaest=`b'[1,1]
	local se=`V'[1,1]^.5


	di
	di
	di in gr "{hline 91}"
	di _col(60)  "Estimation with the "
	di _col(50)  "Cramer-Rao bound" _col(75) "classical formula"
	di in gr "{hline 91}"
	if "`gammafixed'"==""  {
	   di in green "Estimated value of the group effect" _col(59) in ye  %7.2f `gammaest'
	}
	di in green "Estimation of the s.e. of the group effect" _col(59) in ye %7.2f `se'
	di in green "Estimation of the variance of the group effect" _col(56) in ye %10.4f `=`se'^2'
	local power=1-normal(1.96-`gamma'/`se')+normal(-1.96-`gamma'/`se')
	local poweruni=1-normal(1.96-`gamma'/`se')
	local clpower=normal(sqrt(`n1'*`gamma'^2/((`n1'/`n0'+1)*`var'))-1.96)
	di in green "Estimation of the power" _col(60) in ye %6.4f `poweruni' _col(86) in ye %6.4f `clpower'
	local clnsn=(`n1'/`n0'+1)/((`n1'/`n0')*(`gamma'/sqrt(`var'))^2)*(1.96+invnorm(`poweruni'))^2
	di in green "Number of patients for a power of" %6.2f `=`poweruni'*100' "%" _col(59) in ye `n0' "/" `n1' _col(77) in ye %7.2f `clnsn' "/" %7.2f `=`clnsn'*`n1'/`n0''
	local ratio=(`n0'+`n1')/(`clnsn'*(1+`n1'/`n0'))
	di in green "Ratio of the number of patients" in ye %6.2f _col(68)`ratio'
	if `expectedpower'!=-1 {
	   qui sampsi `=-`gamma'/2' `=`gamma'/2', sd1(`=sqrt(`var')') sd2(`=sqrt(`var')') alpha(0.05) power(`expectedpower') ratio(`=`n1'/`n0'')
	   local expn_1=r(N_1)
	   local expn_2=r(N_2)
	   local expn2=`expn_1'*`ratio'
	   di in green "Number of patients for a power of" %6.2f `=`expectedpower'*100' "%" _col(51) in ye %7.2f `expn2' "/" %7.2f `=`expn2'*`n1'/`n0'' _col(77) in ye %7.2f `expn_1' "/" %7.2f `expn_2'
	}
	di in gr "{hline 91}"
	return scalar EstGamma=`gammaest'
	return scalar CRbound=`=`se'^2'
	return scalar CRPower=`poweruni'
	return scalar ClPower=`clpower'
	return scalar ClSS=`clnsn'
	return scalar Ratio=`ratio'
	return scalar CronbachAlpha=`alpha'



capture qui use `raschpowerfile',clear

end

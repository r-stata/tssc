*! Version 1 19 November 2008
*! Jean-Benoit Hardouin
************************************************************************************************************
* Stata program : guttmax
* Research of the maximal number of Guttman Errors for a specific score
*
* Historic :
* Version 1 (November 19, 2008) [Jean-Benoit Hardouin]
*
* Jean-benoit Hardouin, phD, Assistant Professor
* Team of Biostatistics, Clinical Research and Subjective Measures in Health Sciences (UPRES EA 4275)
* University of Nantes - Faculty of Pharmaceutical Sciences
* France
* jean-benoit.hardouin@anaqol.org
*
* Requiered Stata modules:
* -anaoption- (version 1)
* -traces- (version 3.2)
* -gengroup- (version 1)
*
* News about this program :http://www.anaqol.org
* FreeIRT Project website : http://www.freeirt.org
*
* Copyright 2008 Jean-Benoit Hardouin
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
*
***********************************************************************************************************

program define guttmax , rclass
version 10
syntax anything [,Score(int 0)]


local step:word count `anything'
local nbitems=0
forvalues i=1/`step' {
   local step`i':word `i' of `anything'
   if `step`i''>`nbitems' {
      local nbitems=`step`i''
   }
}
di in green "Number of steps: " in ye `step'
di in green "Number of items: " in ye `nbitems'
di in green "Score: " in ye `score'

tempname mate
matrix `mate'=J(1,`step',0)

local maxstep=0
forvalues i=1/`nbitems' {
   local nstep`i'=0
   forvalues j=1/`step' {
       if `step`j''==`i' {
          local ++nstep`i'
          if `nstep`i''>`maxstep' {
             local maxstep=`nstep`i''
          }
       }
   }
}

tempname calcul
matrix `calcul'=J(`nbitems',`maxstep',0)
*matrix list `calcul'
forvalues i=1/`nbitems' {
*di "item `i'"
   local n=1
   forvalues j=1/`step' {
      if `step`j''==`i' {
          forvalues s=`n'/`nstep`i'' {
              matrix `calcul'[`i',`s']=`calcul'[`i',`s']+`j'
          }
      local ++n
      }
   }
   forvalues j=2/`nstep`i'' {
      matrix  `calcul'[`i',`j']=`calcul'[`i',`j']/`j'
   }
}
*matrix list `calcul'

while (`score'>0) {
   local max=0
   forvalues i=1/`nbitems' {
      local s=min(`score',`nstep`i'')
      *di "forvalues j=1/`s' {"
      forvalues j=1/`s' {
          if `calcul'[`i',`j']>`max' {
              local maxi=`i'
              local maxj=`j'
              local max=`calcul'[`i',`j']
          }
      }
   }
   *di "maxi=`maxi' maxj=`maxj'"
   local d=0
   forvalues l=1/`step' {
      if `step`l''==`maxi'&`mate'[1,`l']==0&`d'<=`maxj' {
          matrix `mate'[1,`l']=1
          local ++d
      }
   }
   forvalues l=1/`maxj' {
      matrix `calcul'[`maxi',`l']=0
   }
   local score=`score'-`maxj'
   *matrix list `calcul'
}
local emax=0
forvalue i=1/`step' {
   forvalues j=`=`i'+1'/`step' {
      if `mate'[1,`i']==0&`mate'[1,`j']==1 {
         local ++emax
      }
   }
}


di in green "Responses profile generating the most important number of Guttman error"
matrix list `mate'  ,noheader nonames
di in green "Max number of Guttman errors : " in ye `emax'
return scalar maxegutt =`emax'
end

*! version 4.3  18january2006
************************************************************************************************************
* GEEkel2d: GEE for estimation of unidimensional or 2-dimensional Latent Trait models (Kelderman and Rijkes 1994)
*
* Version 4.3: January 18, 2006 /*Faster version*/
*
* Historic:
* Version 1 (2003-06-23): Jean-Benoit Hardouin
* Version 2 (2003-08-13): Jean-Benoit Hardouin
* version 3 (2003-11-06): Jean-Benoit Hardouin
* Version 4 (2004-06-08): Jean-Benoit Hardouin
* Version 4.1 (2005-04-02): Jean-Benoit Hardouin
* Version 4.2 (2005-07-02): Jean-Benoit Hardouin
*
* Use the ghquadm program (findit ghquadm)
*
* Jean-benoit Hardouin, Regional Health Observatory of Orléans - France
* jean-benoit.hardouin@neuf.fr
*
* News about this program : http://anaqol.free.fr
* FreeIRT Project : http://freeirt.free.fr
*
* Copyright 2003-2006 Jean-Benoit Hardouin
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
*************************************************************************************************************

program define geekel2d ,rclass
version 7.0
syntax varlist(min=2 numeric) [, coef(string) novar ll nbit(integer 30) critconv(real 1e-15) quad(integer 12) ]

preserve
local nbitems: word count `varlist'
tokenize `varlist'

qui count
local N=r(N)

forvalues i=1/`nbitems' {
   qui drop if ``i''==.
}

qui count
local Naf=r(N)

di _col(3) in green "Initial step (N=" in yellow `Naf' in green ")"
di _col(3) in yellow `=`N'-`Naf'' in green " observations are not used for missing values"
di

qui count
local N=r(N)
tempname B Q
if "`coef'"!="" {
   matrix `B'=`coef'
}
else {
   matrix `B'=J(`nbitems',1,1)
}

scalar `Q'=colsof(`B')

/* CALCUL INITIAUX DES PARAMETRES DELTA ET SIGMA ET DE LA MATRICE BETA*/

local sigmath11=0.25

if `Q'==2 {
   local sigmath22=.25
   local sigmath12=0.125
}

tempname beta
matrix `beta'=J(`nbitems'+`Q'*(`Q'+1)/2,1,0)
forvalues i=1/`nbitems' {
   qui count if ``i''==1
   local si`i'=r(N)
   local delta``i''=-log(`si`i''/(`N'-`si`i''))
   matrix `beta'[`i',1]=`delta``i'''
   forvalues j=`i'/`nbitems' {
      quiet count if ``j''==1&``i''==1
      local si`i'j`j'=r(N)
      local si`j'j`i'=r(N)
      if "`var'"=="" {
         forvalues k=`j'/`nbitems' {
             quiet count if ``i''==1&``j''==1&``k''==1
             local si`i'j`j'k`k'=r(N)
             local si`i'j`k'k`j'=r(N)
             local si`j'j`i'k`k'=r(N)
             local si`j'j`k'k`i'=r(N)
             local si`k'j`i'k`j'=r(N)
             local si`k'j`j'k`i'=r(N)
             forvalues l=`k'/`nbitems' {
                quiet count if ``i''==1&``j''==1&``k''==1&``l''==1
                local si`i'j`j'k`k'l`l'=r(N)
                local si`i'j`j'k`l'l`k'=r(N)
                local si`i'j`k'k`j'l`l'=r(N)
                local si`i'j`k'k`l'l`j'=r(N)
                local si`i'j`l'k`j'l`k'=r(N)
                local si`i'j`l'k`k'l`j'=r(N)

                local si`j'j`i'k`k'l`l'=r(N)
                local si`j'j`i'k`l'l`k'=r(N)
                local si`j'j`k'k`i'l`l'=r(N)
                local si`j'j`k'k`l'l`i'=r(N)
                local si`j'j`l'k`i'l`k'=r(N)
                local si`j'j`l'k`k'l`i'=r(N)

                local si`k'j`i'k`j'l`l'=r(N)
                local si`k'j`i'k`l'l`j'=r(N)
                local si`k'j`j'k`i'l`l'=r(N)
                local si`k'j`j'k`l'l`i'=r(N)
                local si`k'j`l'k`i'l`j'=r(N)
                local si`k'j`l'k`j'l`i'=r(N)

                local si`l'j`i'k`j'l`k'=r(N)
                local si`l'j`i'k`k'l`j'=r(N)
                local si`l'j`j'k`i'l`k'=r(N)
                local si`l'j`j'k`k'l`i'=r(N)
                local si`l'j`k'k`i'l`j'=r(N)
                local si`l'j`k'k`j'l`i'=r(N)
            }
         }
      }
   }
}

local l=`nbitems'+1
matrix `beta'[`l',1]=`sigmath11'

if `Q'==2 {
   local l=`nbitems'+2
   matrix `beta'[`l',1]=`sigmath22'
   local l=`nbitems'+3
   matrix `beta'[`l',1]=`sigmath12'
}

tempname variat  V11 V12 V21 V22 D11 D12 D21 D22 V D
matrix `variat'=(1)
local compteur=0
local conv=1


/*********ITERATIONS******************/



while (`variat'[1,1]>`critconv'&`compteur'<=`nbit'&`conv'==1) {
   if `compteur'==0{
      di in green _col(3) "First iteration"
   }
   else {
      di in green _col(3) "iteration:" in yellow _col(14) "`compteur'" in green _col(25) "Convergence index:" in yellow _col(44) %10.7e  "`macrovariat'"
   }
   local compteur=`compteur'+1

   forvalues j=1/`nbitems' {

      /* CALCUL DES DERIVEES 1 A 6 POUR CHAQUE ITEM*/
      local l1``j''=1/(1+exp(`beta'[`j',1]))
      local l2``j''=exp(`beta'[`j',1])/(1+exp(`beta'[`j',1]))^2
      local l3``j''=exp(`beta'[`j',1])*(exp(`beta'[`j',1])-1)/(1+exp(`beta'[`j',1]))^3
      local l4``j''=exp(`beta'[`j',1])*(exp(2*`beta'[`j',1])-4*exp(`beta'[`j',1])+1)/(1+exp(`beta'[`j',1]))^4
      local l5``j''=exp(`beta'[`j',1])*(exp(3*`beta'[`j',1])-11*exp(2*`beta'[`j',1])+11*exp(`beta'[`j',1])-1)/(1+exp(`beta'[`j',1]))^5
      local l6``j''=exp(`beta'[`j',1])*(exp(4*`beta'[`j',1])-26*exp(3*`beta'[`j',1])+66*exp(2*`beta'[`j',1])-26*exp(`beta'[`j',1])+1)/(1+exp(`beta'[`j',1]))^6

      if `Q'==2 {
         local H2i`j'=`B'[`j',1]^2*`sigmath11'+`B'[`j',1]*`B'[`j',2]*`sigmath12'+`B'[`j',2]^2*`sigmath22'
         local H4i`j'=3*`B'[`j',1]^4*`sigmath11'^2+12*`B'[`j',1]^3*`B'[`j',2]*`sigmath11'*`sigmath12'+6*`B'[`j',1]^2*`B'[`j',2]^2*(`sigmath11'*`sigmath22'+2*`sigmath12'^2)+12*`B'[`j',1]*`B'[`j',2]^3*`sigmath22'*`sigmath12'+3*`B'[`j',2]^4*`sigmath22'^2
      }
      else if `Q'==1 {
         local H2i`j'=`B'[`j',1]^2*`sigmath11'
         local H4i`j'=3*`B'[`j',1]^4*`sigmath11'^2
      }

      /* CALCUL DES MOMENTS D'ORDRE 1 ET 2 ET DE LA MATRICE V11*/
      local mui`j'=`l1``j'''+`H2i`j''/2*`l3``j'''+`H4i`j''/24*`l5``j'''
      local sigmai`j'j`j'=`l2``j'''+`H2i`j''/2*(`l3``j'''-2*`l1``j'''*`l3``j''')+`H4i`j''/24*(`l5``j'''-2*(`l3``j''')^2-2*`l1``j'''*`l5``j''')
   }


   matrix `V11'=J(`nbitems',`nbitems',0)

   forvalues j=1/`nbitems' {
      matrix `V11'[`j',`j']=`sigmai`j'j`j''
      forvalues l=`=`j'+1'/`nbitems' {
            if `Q'==2 {
               local H2i`j'j`l'=`B'[`j',1]*`B'[`l',1]*`sigmath11'+(`B'[`j',1]*`B'[`l',2]+`B'[`j',2]*`B'[`l',1])*`sigmath12'+`B'[`j',2]*`B'[`l',2]*`sigmath22'
               local H4i`j'1j`l'3=3*`B'[`j',1]*`B'[`l',1]^3*`sigmath11'^2+3*(3*`B'[`j',1]*`B'[`l',1]^2*`B'[`l',2]+`B'[`j',2]*`B'[`l',1]^3)*`sigmath11'*`sigmath12'+(3*`B'[`j',1]*`B'[`l',1]*`B'[`l',2]^2+3*`B'[`j',2]*`B'[`l',1]^2*`B'[`l',2])*(`sigmath11'*`sigmath22'+2*`sigmath12'^2)+3*(`B'[`j',1]*`B'[`l',2]^3+3*`B'[`j',2]*`B'[`l',1]*`B'[`l',2]^2)*`sigmath22'*`sigmath12'+3*`B'[`j',2]*`B'[`l',2]^3*`sigmath22'^2
               local H4i`j'2j`l'2=3*`B'[`j',1]^2*`B'[`l',1]^2*`sigmath11'^2+6*(`B'[`j',1]^2*`B'[`l',1]*`B'[`l',2]+`B'[`j',1]*`B'[`j',2]*`B'[`l',1]^2)*`sigmath11'*`sigmath12'+(`B'[`j',1]^2*`B'[`l',2]^2+4*`B'[`j',1]*`B'[`j',2]*`B'[`l',1]*`B'[`l',2]+`B'[`j',2]^2*`B'[`l',1]^2)*(`sigmath11'*`sigmath22'+2*`sigmath12'^2)+6*(`B'[`j',1]*`B'[`j',2]*`B'[`l',2]^2+`B'[`j',2]^2*`B'[`l',1]*`B'[`l',2])*`sigmath22'*`sigmath12'+3*`B'[`j',2]^2*`B'[`l',2]^2*`sigmath22'^2
               local H4i`j'3j`l'1=3*`B'[`l',1]*`B'[`j',1]^3*`sigmath11'^2+3*(3*`B'[`l',1]*`B'[`j',1]^2*`B'[`j',2]+`B'[`l',2]*`B'[`j',1]^3)*`sigmath11'*`sigmath12'+(3*`B'[`l',1]*`B'[`j',1]*`B'[`j',2]^2+3*`B'[`l',2]*`B'[`j',1]^2*`B'[`j',2])*(`sigmath11'*`sigmath22'+2*`sigmath12'^2)+3*(`B'[`l',1]*`B'[`j',2]^3+3*`B'[`l',2]*`B'[`j',1]*`B'[`j',2]^2)*`sigmath22'*`sigmath12'+3*`B'[`l',2]*`B'[`j',2]^3*`sigmath22'^2
            }
            else if `Q'==1 {
               local H2i`j'j`l'=`B'[`j',1]*`B'[`l',1]*`sigmath11'
               local H4i`j'1j`l'3=3*`B'[`j',1]*`B'[`l',1]^3*`sigmath11'^2
               local H4i`j'2j`l'2=3*`B'[`j',1]^2*`B'[`l',1]^2*`sigmath11'^2
               local H4i`j'3j`l'1=3*`B'[`l',1]*`B'[`j',1]^3*`sigmath11'^2
            }
            local H2i`l'j`j'=`H2i`j'j`l''
            local H4i`l'1j`j'3=`H4i`j'1j`l'3'
            local H4i`l'2j`j'2=`H4i`j'2j`l'2'
            local H4i`l'3j`j'1=`H4i`j'3j`l'1'
            local sigmai`j'j`l'=`H2i`j'j`l''*(`l2``j'''*`l2``l''')+`H4i`j'1j`l'3'/6*`l2``j'''*`l4``l'''+`H4i`j'3j`l'1'/6*`l4``j'''*`l2``l'''+(`H4i`j'2j`l'2'-`H2i`j''*`H2i`l'')/4*`l3``j'''*`l3``l'''
      }
   }

   /* DEFINITION DE LA MATRICE COMPOCARRE*/
   tempname compocarre  m
   local carre=`nbitems'*(`nbitems'-1)/2
   matrix `compocarre'=J(2,`carre',0)

   local m=0
   forvalues j=1/`nbitems' {
      forvalues l=`=`j'+1'/`nbitems' {
         local m=`m'+1
         matrix `compocarre'[1,`m']=`j'
         matrix `compocarre'[2,`m']=`l'
      }
   }

   /* CALCUL DE LA MATRICE V22*/
   matrix `V22'=J(`carre',`carre',0)
   forvalues k=1/`carre' {
      local j=`compocarre'[1,`k']
      local l=`compocarre'[2,`k']
      matrix `V22'[`k',`k']=(1-2*`mui`j'')*(1-2*`mui`l'')*`sigmai`j'j`l''+`sigmai`j'j`j''*`sigmai`l'j`l''-`sigmai`j'j`l''^2
   }

   /* CALCUL DES MATRICES V12, V21 ET V*/
   matrix `V12'=J(`nbitems',`carre',0)
   forvalues k=1/`carre' {
      local j=`compocarre'[1,`k']
      local l=`compocarre'[2,`k']
      matrix `V12'[`j',`k']=(1-2*`mui`j'')*`sigmai`j'j`l''
      matrix `V12'[`l',`k']=(1-2*`mui`l'')*`sigmai`j'j`l''
   }
   matrix `V21'=`V12' '
   matrix `V'=(`V11',`V12' \ `V21',`V22')

   /*CALCUL DES MATRICES D11*/
   matrix `D11'=J(`nbitems',`nbitems',0)
   matrix `D12'=J(`nbitems',`Q'*(`Q'+1)/2,0)

   forvalues j=1/`nbitems' {
      matrix `D11'[`j',`j']=-`l2``j'''-`H2i`j''/2*`l4``j'''-`H4i`j''/24*`l6``j'''

      if `Q'==2 {
         matrix `D12'[`j',1]=`B'[`j',1]^2*`l3``j'''/2+(`B'[`j',1]^4*`sigmath11'+2*`B'[`j',1]^3*`B'[`j',2]*`sigmath12'+`B'[`j',1]^2*`B'[`j',2]^2*`sigmath22')/4*`l5``j'''
         matrix `D12'[`j',2]=`B'[`j',2]^2*`l3``j'''/2+(`B'[`j',2]^4*`sigmath22'+2*`B'[`j',2]^3*`B'[`j',1]*`sigmath12'+`B'[`j',2]^2*`B'[`j',1]^2*`sigmath11')/4*`l5``j'''
         matrix `D12'[`j',3]=`B'[`j',1]*`B'[`j',2]*`l3``j'''+(`B'[`j',1]^3*`B'[`j',2]*`sigmath11'+2*`B'[`j',1]^2*`B'[`j',2]^2*`sigmath12'+`B'[`j',1]*`B'[`j',2]^3*`sigmath22')/2*`l5``j'''
      }
      else if `Q'==1 {
          matrix `D12'[`j',1]=`B'[`j',1]^2*`l3``j'''/2+`B'[`j',1]^4*`sigmath11'/4*`l5``j'''
      }
   }

   /*CALCUL DES MATRICES D21, D22 et D*/
   matrix `D21'=J(`carre',`nbitems',0)
   matrix `D22'=J(`carre',`Q'*(`Q'+1)/2,0)

   forvalues k=1/`carre' {
      local j=`compocarre'[1,`k']
      local l=`compocarre'[2,`k']
      matrix `D21'[`k',`j']=-`H2i`j'j`l''*`l3``j'''*`l2``l'''-`H4i`j'1j`l'3'/6*`l3``j'''*`l4``l'''-`H4i`j'3j`l'1'/6*`l5``j'''*`l2``l'''-(`H4i`j'2j`l'2'-`H2i`j''*`H2i`l'')/4*`l4``j'''*`l3``l'''
      matrix `D21'[`k',`l']=-`H2i`j'j`l''*`l2``j'''*`l3``l'''-`H4i`j'3j`l'1'/6*`l4``j'''*`l3``l'''-`H4i`j'1j`l'3'/6*`l2``j'''*`l5``l'''-(`H4i`j'2j`l'2'-`H2i`j''*`H2i`l'')/4*`l3``j'''*`l4``l'''

      tempname tmp1 tmp2 tmp3
      if `Q'==2 {
         scalar `tmp1'=`B'[`j',1]*`B'[`l',1]*`l2``j'''*`l2``l'''+(2*`B'[`j',1]*`B'[`l',1]^3*`sigmath11'+(3*`B'[`j',1]*`B'[`l',1]^2*`B'[`l',2]+`B'[`j',2]*`B'[`l',1]^3)*`sigmath12'+(`B'[`j',1]*`B'[`l',1]*`B'[`l',2]^2+`B'[`j',2]*`B'[`l',1]^2*`B'[`l',2])*`sigmath22')/2*`l2``j'''*`l4``l'''
         scalar `tmp2'=(2*`B'[`j',1]^3*`B'[`l',1]*`sigmath11'+(3*`B'[`j',1]^2*`B'[`j',2]*`B'[`l',1]+`B'[`j',1]^3*`B'[`l',2])*`sigmath12'+(`B'[`j',1]*`B'[`j',2]^2*`B'[`l',1]+`B'[`j',1]^2*`B'[`j',2]*`B'[`l',2])*`sigmath22')/2*`l4``j'''*`l2``l'''
         scalar `tmp3'=(`B'[`j',1]^2*`B'[`l',1]^2*`sigmath11'+(`B'[`j',1]^2*`B'[`l',1]*`B'[`l',2]+`B'[`j',1]*`B'[`j',2]*`B'[`l',1]^2)*`sigmath12'+`B'[`j',1]*`B'[`j',2]*`B'[`l',1]*`B'[`l',2]*`sigmath22')*`l3``j'''*`l3``l'''
         matrix `D22'[`k',1]=`tmp1'+`tmp2'+`tmp3'
         scalar `tmp1'=`B'[`j',2]*`B'[`l',2]*`l2``j'''*`l2``l'''+(2*`B'[`j',2]*`B'[`l',2]^3*`sigmath22'+(3*`B'[`j',2]*`B'[`l',2]^2*`B'[`l',1]+`B'[`j',1]*`B'[`l',2]^3)*`sigmath12'+(`B'[`j',2]*`B'[`l',2]*`B'[`l',1]^2+`B'[`j',1]*`B'[`l',2]^2*`B'[`l',1])*`sigmath11')/2*`l2``j'''*`l4``l'''
         scalar `tmp2'=(2*`B'[`j',2]^3*`B'[`l',2]*`sigmath22'+(3*`B'[`j',2]^2*`B'[`j',1]*`B'[`l',2]+`B'[`j',2]^3*`B'[`l',1])*`sigmath12'+(`B'[`j',2]*`B'[`j',1]^2*`B'[`l',2]+`B'[`j',2]^2*`B'[`j',1]*`B'[`l',1])*`sigmath11')/2*`l4``j'''*`l2``l'''
         scalar `tmp3'=(`B'[`j',1]^2*`B'[`l',1]^2*`sigmath22'+(`B'[`j',1]^2*`B'[`l',1]*`B'[`l',2]+`B'[`j',1]*`B'[`j',2]*`B'[`l',1]^2)*`sigmath12'+`B'[`j',1]*`B'[`j',2]*`B'[`l',1]*`B'[`l',2]*`sigmath11')*`l3``j'''*`l3``l'''
         matrix `D22'[`k',2]=`tmp1'+`tmp2'+`tmp3'
         scalar `tmp1'=(`B'[`j',1]*`B'[`l',2]+`B'[`j',2]*`B'[`l',1])*`l2``j'''*`l2``l'''+((3*`B'[`j',1]*`B'[`l',1]^2*`B'[`l',2]+`B'[`j',2]*`B'[`l',1]^3)*`sigmath11'+4*(`B'[`j',1]*`B'[`l',1]*`B'[`l',2]^2+`B'[`j',2]*`B'[`l',1]^2*`B'[`l',2])*`sigmath12'+(`B'[`j',1]*`B'[`l',2]^3+3*`B'[`j',2]*`B'[`l',1]*`B'[`l',2]^2)*`sigmath22')/2*`l2``j'''*`l4``l'''
         scalar `tmp2'=((3*`B'[`j',1]^2*`B'[`j',2]*`B'[`l',1]+`B'[`j',1]^3*`B'[`l',2])*`sigmath11'+4*(`B'[`j',1]*`B'[`j',2]^2*`B'[`l',1]+`B'[`j',1]^2*`B'[`j',2]*`B'[`l',2])*`sigmath12'+(`B'[`j',2]^3*`B'[`l',1]+3*`B'[`j',1]*`B'[`j',2]^2*`B'[`l',2])*`sigmath22')/2*`l4``j'''*`l2``l'''
         scalar `tmp3'=((`B'[`j',1]^2*`B'[`l',1]*`B'[`l',2]+`B'[`j',1]*`B'[`j',2]*`B'[`l',2]^2)*`sigmath11'+(`B'[`j',1]^2*`B'[`l',2]^2+2*`B'[`j',1]*`B'[`j',2]*`B'[`l',1]*`B'[`l',2]+`B'[`j',2]^2*`B'[`l',1]^2)*`sigmath12'+(`B'[`j',1]*`B'[`j',2]*`B'[`l',2]^2+`B'[`j',2]^2*`B'[`l',1]*`B'[`l',2])*`sigmath22')*`l3``j'''*`l3``l'''
         matrix `D22'[`k',3]=`tmp1'+`tmp2'+`tmp3'
      }
      else if `Q'==1 {
         scalar `tmp1'=`B'[`j',1]*`B'[`l',1]*`l2``j'''*`l2``l'''+(2*`B'[`j',1]*`B'[`l',1]^3*`sigmath11')/2*`l2``j'''*`l4``l'''
         scalar `tmp2'=(2*`B'[`j',1]^3*`B'[`l',1]*`sigmath11')/2*`l4``j'''*`l2``l'''
         scalar `tmp3'=(`B'[`j',1]^2*`B'[`l',1]^2*`sigmath11')*`l3``j'''*`l3``l'''
         matrix `D22'[`k',1]=`tmp1'+`tmp2'+`tmp3'
      }
   }
   matrix `D'=(`D11',`D12' \ `D21',`D22')

   /*CALCUL DE LA MATRICE CHSI*/

   tempname chsi
   matrix `chsi'=J(`nbitems'+`carre',1,0)

   forvalues j=1/`nbitems' {
      matrix `chsi'[`j',1]=(`si`j''-`N'*`mui`j'')/`N'
   }
   forvalues k=1/`carre' {
      local j=`compocarre'[1,`k']
      local l=`compocarre'[2,`k']
      local tmp=`nbitems'+`k'
      matrix `chsi'[`tmp',1]=(`si`j'j`l''-`si`j''*`mui`l''-`si`l''*`mui`j''+`N'*`mui`j''*`mui`l''-`N'*`sigmai`j'j`l'')/`N'
   }

   /*CALCUL DE L'ETAPE k*/
   tempname betaold
   matrix `betaold'=`beta'
   matrix `beta'=`betaold'+inv(`D''*inv(`V')*`D')*`D''*inv(`V')*`chsi'

   local l=`nbitems'+1
   local sigmath11=`beta'[`l',1]
   local l=`nbitems'+2
   local sigmath22=`beta'[`l',1]
   local l=`nbitems'+3
   local sigmath12=`beta'[`l',1]

   tempname epsilon variatold
   scalar `variatold'=`variat'[1,1]
   matrix `epsilon'=`betaold'-`beta'
   matrix `variat'=(`epsilon''*`epsilon')

   if `variat'[1,1]>`variatold' {
      matrix `beta'=`betaold'
      local l=`nbitems'+1
      local sigm ath11=`beta'[`l',1]
      if `Q'==2 {
         local l=`nbitems'+2
         local sigmath22=`beta'[`l',1]
         local l=`nbitems'+3
         local sigmath12=`beta'[`l',1]
      }
      local conv=0
   }
   else {
      local macrovariat=`variat'[1,1]
   }
}

/*************************CALCUL des STANDARDS ERRORS DES PARAMETRES *********************/

if "`var'"==""{
   tempname xicarreA xicarreB xicarreC xicarre
   matrix `xicarreA'=J(`nbitems',`nbitems',0)
   matrix `xicarreB'=J(`nbitems',`carre',0)
   matrix `xicarreC'=J(`carre',`carre',0)
   forvalues i=1/`nbitems' {
      forvalues j=`=`i'+1'/`nbitems' {
         matrix `xicarreA'[`i',`j']=`si`i'j`j''-`si`i''*`mui`j''-`si`j''*`mui`i''+`N'*`mui`i''*`mui`j''
         matrix `xicarreA'[`i',`j']=`xicarreA'[`j',`i']
      }
      forvalues col=1/`carre' {
         local j=`compocarre'[1,`col']
         local k=`compocarre'[2,`col']
         matrix `xicarreB'[`i',`col']=`si`i'j`j'k`k''-`mui`i''*`si`j'j`k''-`mui`j''*`si`i'j`k''-`mui`k''*`si`i'j`j''+`mui`i''*`mui`j''*`si`k''+`mui`i''*`mui`k''*`si`j''+`mui`j''*`mui`k''*`si`i''-`N'*`mui`i''*`mui`j''*`mui`k''-`sigmai`j'j`k''*`si`i''+`N'*`mui`i''*`sigmai`j'j`k'''
      }
   }
   forvalues row=1/`carre' {
      forvalues col=`row'/`carre' {
         local i=`compocarre'[1,`row']
         local j=`compocarre'[2,`row']
         local k=`compocarre'[1,`col']
         local l=`compocarre'[2,`col']
         matrix `xicarreC'[`row',`col']=`si`i'j`j'k`k'l`l''-`mui`i''*`si`j'j`k'l`l''-`mui`j''*`si`i'j`k'k`l''-`mui`k''*`si`i'j`j'k`l''-`mui`l''*`si`i'j`j'k`k''+`mui`i''*`mui`j''*`si`k'j`l''+`mui`i''*`mui`k''*`si`j'j`l''+`mui`i''*`mui`l''*`si`j'j`k''+`mui`j''*`mui`k''*`si`i'j`l''+`mui`j''*`mui`l''*`si`i'j`k''+`mui`k''*`mui`l''*`si`i'j`j''-`mui`i''*`mui`j''*`mui`k''*`si`l''-`mui`i''*`mui`j''*`mui`l''*`si`k''-`mui`i''*`mui`k''*`mui`l''*`si`j''-`mui`j''*`mui`k''*`mui`l''*`si`i''-`sigmai`i'j`j''*`si`k'j`l''-`sigmai`k'j`l''*`si`i'j`j''+`sigmai`i'j`j''*`mui`k''*`si`l''+`sigmai`i'j`j''*`mui`l''*`si`k''+`sigmai`k'j`l''*`mui`i''*`si`j''+`sigmai`k'j`l''*`mui`j''*`si`i''+`N'*`mui`i''*`mui`j''*`mui`k''*`mui`l''-`N'*`sigmai`i'j`j''*`mui`k''*`mui`l''-`N'*`sigmai`k'j`l''*`mui`i''*`mui`j''+`N'*`sigmai`i'j`j''*`sigmai`k'j`l''
         matrix `xicarreC'[`col',`row']=`xicarreC'[`row',`col']
      }
   }
   matrix `xicarre'=(`xicarreA',`xicarreB' \ `xicarreB' ',`xicarreC')
   tempname A1 A2 W
   matrix `A1'=`D' '*inv(`V')*`D'
   matrix `A2'=`D' '*inv(`V')*`xicarre'*inv(`V')*`D'
   matrix `W'=1/`N'^2*inv(`A1')*`A2'*inv(`A1')
}

/*****************************DISPLAY THE RESULTS***************************************/


local compteur=`compteur'-1
di ""
di ""
if `compteur'==0 {
   noi di in red _col(8) "The algorithm does not converge"
   return scalar error=1
   exit
}
if `variat'[1,1]<=`critconv'&`compteur'>0 {
   noi di in green _col(8) "The algorithm converges at the `compteur'th iteration"
}
if `compteur'==`nbit'&`variat'[1,1]>`critconv' {
   noi di in green _col(8) "The algorithm is stopped at the `compteur'th iteration"
}
if `conv'==0&`compteur'>0 {
   noi di in green _col(8) "The algorithm no more converges after the `compteur'th iteration"
}
di ""
if "`var'"=="" {
   noi di in green _col(30) "Parameters" in green _col(43) "Standard errors"
   forvalues j=1/`nbitems' {
      noi di in green _col(20) "``j'': " in yellow _col(30) %10.6f `beta'[`j',1] in yellow _col(50) %8.6f sqrt(`W'[`j',`j'])
   }
   di ""
   noi di in green _col(20) "var1: " in yellow _col(30) %10.6f `beta'[`nbitems'+1,1] in yellow _col(50) %8.6f sqrt(`W'[`nbitems'+1,`nbitems'+1])
   if `Q'==2 {
       noi di in green _col(20) "var2: " in yellow _col(30) %10.6f `beta'[`nbitems'+2,1] in yellow _col(50) %8.6f sqrt(`W'[`nbitems'+2,`nbitems'+2])
       tempname rho
       scalar `rho'=`beta'[`nbitems'+3,1]/sqrt(`beta'[`nbitems'+1,1]*`beta'[`nbitems'+2,1])
       noi di in green _col(20) "covar: " in yellow _col(30) %10.6f `beta'[`nbitems'+3,1] in yellow _col(50) %8.6f sqrt(`W'[`nbitems'+3,`nbitems'+3]) " (rho=" %5.4f `rho' ")"
   }
}
else {
   noi di in green _col(30) "Parameters"
   forvalues j=1/`nbitems' {
      noi di in green _col(20) "``j'': " in yellow _col(30) %10.6f `beta'[`j',1]
   }
   di ""
   noi di in green _col(20) "var1: " in yellow _col(30) %10.6f `beta'[`nbitems'+1,1]
   if `Q'==2 {
      noi di in green _col(20) "var2: " in yellow _col(30) %10.6f `beta'[`nbitems'+2,1]
      tempname rho
      scalar  `rho'=`beta'[`nbitems'+3,1]/sqrt(`beta'[`nbitems'+1,1]*`beta'[`nbitems'+2,1])
      noi di in green _col(20) "covar: " in yellow _col(30) %10.6f `beta'[`nbitems'+3,1]
   }
}
di ""
if "`ll'"!="" {
   tempname noeuds poids
   ghquadm `quad' `noeuds' `poids'
   tempvar vrais logvrais P
   qui gen `P'=0
   qui gen `vrais'=0
   if `Q'==1 {
      forvalues u=1/`quad'{
         tempvar vrais`u'
         qui gen `vrais`u''=1/sqrt(_pi)
         forvalues j=1/`nbitems' {
            qui replace `P'=exp(`B'[`j',1]*sqrt(2*`beta'[`nbitems'+1,1])*`noeuds'[1,`u']-`beta'[`j',1])/(1+exp(`B'[`j',1]*sqrt(2*`beta'[`nbitems'+1,1])*`noeuds'[1,`u']-`beta'[`j',1]))
            qui replace `P'=1-`P' if ``j''==0
            qui replace `vrais`u''=`vrais`u''*`P'
         }
         qui replace `vrais'=`vrais'+`poids'[1,`u']*`vrais`u''
      }
      gen `logvrais'=log(`vrais')
      qui su `logvrais'
      local ll=r(N)*r(mean)
      noi di in green _col(20) "ll: " in yellow _col(30) %12.4f `ll'
      local AIC=-2*`ll'+2*(`nbitems'+1)
      noi di in green _col(20) "AIC: " in yellow _col(30) %12.4f `AIC'
   }

   if `Q'==2 {
      tempname sigma
      matrix `sigma'=(`beta'[`nbitems'+1,1],`beta'[`nbitems'+3,1] \ `beta'[`nbitems'+3,1],`beta'[`nbitems'+2,1])
      forvalues u=1/`quad'{
         forvalues v=1/`quad'{
            tempvar vraisu`u'v`v'
            qui gen `vraisu`u'v`v''=1/_pi
            forvalues j=1/`nbitems' {
               local A1`u'tilde=sqrt(`beta'[`nbitems'+2,1]/(2*det(`sigma')))*`noeuds'[1,`u']
               local A2`v'tilde=(`noeuds'[1,`v']-`beta'[`nbitems'+3,1]/sqrt(det(`sigma'))*`noeuds'[1,`u'])/(2*`beta'[`nbitems'+2,1])
               qui replace `P'=exp(`B'[`j',1]*`A1`u'tilde'+`B'[`j',2]*`A2`v'tilde'-`beta'[`j',1])/(1+exp(`B'[`j',1]*`A1`u'tilde'+`B'[`j',2]*`A2`v'tilde'-`beta'[`j',1]))
               qui replace `P'=1-`P' if ``j''==0
               qui replace `vraisu`u'v`v''=`vraisu`u'v`v''*`P'
            }
            qui replace `vrais'=`vrais'+`poids'[1,`u']*`poids'[1,`v']*`vraisu`u'v`v''
         }
      }
      qui gen `logvrais'=log(`vrais')
      qui su `logvrais'
      local ll=r(N)*r(mean)
      noi di in green _col(20) "ll: " in yellow _col(27) %12.4f `ll'
      local AIC=-2*`ll'+2*(`nbitems'+3)
      noi di in green _col(20) "AIC: " in yellow _col(27) %12.4f `AIC'
   }
}
if "`var'"=="" {
   return matrix V  `W'
}
matrix `beta'=`beta''
return matrix b= `beta'

if "`ll'"!="" {
   return scalar ll= `ll'
   return scalar AIC= `AIC'
}

return scalar J= `nbitems'
return scalar N= `N'
return scalar error=0

restore
end


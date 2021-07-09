*! Version 1.3 24 May 2013
*! Jean-Benoit Hardouin
************************************************************************************************************
* Stata program : sf36fr
* computes score of the French SF36 questionnnaire
* Release 1 : May 2, 2013 [Jean-benoit Hardouin]
* Release 1.1 : May 14, 2013 [Jean-Benoit Hardouin] /*correction of a bug on BP*/
* Release 1.2 : May 21, 2013 [Jean-Benoit Hardouin] /*saveimp option*/
* Release 1.3 : May 24, 2013 [Jean-Benoit Hardouin] /*correction of a bug on BP*/
*
*
* Historic :
* Version 1 (May 2, 2013) [Jean-Benoit Hardouin]
*
* Faire sauvegarde des items imputés
*
* Jean-benoit Hardouin, phD, Assistant Professor
* Team of Biostatistics, Pharmacoepidemiology and Subjective Measures in Health Sciences  (UPRES EA 4275 SPHERE)
* University of Nantes - Faculty of Pharmaceutical Sciences
* France
* jean-benoit.hardouin@anaqol.org
*
* News about this program :http://www.anaqol.org
*
* Copyright 2013 Jean-Benoit Hardouin
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
program define sf36fr , rclass
version 8.2
syntax varlist(min=36 max=36 numeric) [,v2 save(string) REPlace age(varname) SEXe(varname) saveref(string) DETails saveimp(string)]

local nbitems : word count `varlist'
if `nbitems'!=36 {
   di in red "There is `nbitems' items defined instead of 36" 
}

tokenize `varlist'
local varlistsav `varlist'
local sf gh1 ht pf1 pf2 pf3 pf4 pf5 pf6 pf7 pf8 pf9 pf10 rp1 rp2 rp3 rp4 re1 re2 re3 sf1 bp1 bp2 vt1 mh1 mh2 mh3 vt2 mh4 vt3 mh5 vt4 sf2 gh2 gh3 gh4 gh5
local sf2
local varlist2
forvalues i=1/36 {
   local j:word `i' of `sf'
   tempname `j'
   *di " qui gen `j'=``i''"
   qui gen ``j''=``i''
   local varlist2 "`varlist2' ``j''"
}
local varlist "`varlist2'"
tokenize `varlist'
*di "`varlist'"


if "`v2'"=="" {
   local modamax 5 5 3 3 3 3 3 3 3 3 3 3 2 2 2 2 2 2 2 5 6 5 6 6 6 6 6 6 6 6 6 5 5 5 5 5 
}
else {
   local modamax 5 5 3 3 3 3 3 3 3 3 3 3 2 2 2 2 2 2 2 4 4 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 
}
forvalues i=1/36 {
   local mod`i':word `i' of `modamax'
}
local error=0
local inf
local sup
local c=1
foreach i of varlist `varlist' {
   qui count if `i'<1
   if `r(N)'>0 {
       local error=1
       local inf "`inf' `i'"
   }
   local tmp: word `c' of `modamax'
   qui count if `i'>`c'
   if `r(N)'>0 {
       local error=1
       local inf "`sup' `i'"
   }
   local ++c
}
forvalues i=1/15 {
   tempname inc`i'
}
local liste1 11 12 11 12 11 12 11 12 30 24 27 23 1 20 21
local liste2 3 3 4 4 6 6 9 9 25 26 29 31 36 32 22
*tab `11' `3'
qui gen `inc1'=`11'==1&`3'>1 if `11'!=.&`3'!=.
*   tab `inc`i''
qui gen `inc2'=`12'==1&`3'>1 if `12'!=.&`3'!=.
qui gen `inc3'=`11'==1&`4'>1 if `11'!=.&`4'!=.
qui gen `inc4'=`12'==1&`4'>1 if `12'!=.&`4'!=.
qui gen `inc5'=`11'==1&`6'>1 if `11'!=.&`6'!=.
qui gen `inc6'=`12'==1&`6'>1 if `12'!=.&`6'!=.
qui gen `inc7'=`11'==1&`9'>1 if `11'!=.&`9'!=.
qui gen `inc8'=`12'==1&`9'>1 if `12'!=.&`9'!=.
qui gen `inc9'=(`30'==1&`25'==1)|(`30'==`mod30'&`25'==`mod25') if `30'!=.&`25'!=.
qui gen `inc10'=(`24'==1&`26'==1)|(`24'==`mod24'&`26'==`mod26') if `24'!=.&`26'!=.
qui gen `inc11'=(`27'==1&`29'==1)|(`27'==`mod27'&`29'==`mod29') if `27'!=.&`29'!=.
qui gen `inc12'=(`23'==1&`31'==1)|(`23'==`mod23'&`31'==`mod31') if `23'!=.&`31'!=.
qui gen `inc13'=(`1'==1&`36'==`mod36')|(`1'==`mod1'&`36'==1) if `1'!=.&`36'!=.
qui gen `inc14'=(`20'==1&`32'==1)|(`20'==`mod20'&`32'==`mod32') if `20'!=.&`32'!=.
qui gen `inc15'=(`21'==1&`22'==`mod22')|(`21'==`mod21'&`22'==1) if `21'!=.&`22'!=.
tempname scoreinc
genscore `inc1'-`inc15',score(`scoreinc')
if "`details'" !="" {
	di "{hline 80}"
	di in gr "Incoherences" _col(20) "item 1" _col(40) "item 2" _col(60) "# individuals"
	di "{hline 80}"
	*di "varlist:`varlistsav'"
	forvalues i=1/15 {
	   local i1:word `i' of `liste1'
	   local i2:word `i' of `liste2'
	   local ni1:word `i1' of `varlistsav'
	   local ni2:word `i2' of `varlistsav'
	   qui count if `inc`i''==1
	   
	   di in gr "`i'" in ye _col(20) abbrev("`ni1'",19) _col(40) abbrev("`ni2'",19) %6.0f _col(67) `r(N)'
	}
	di "{hline 80}"
}

forvalues i=1/15 {
   local i1:word `i' of `liste1'
   local i2:word `i' of `liste2'
   qui replace ``i1''=. if `inc`i''==1
   qui replace ``i2''=. if `inc`i''==1
}

tempname imp scorepf scorerp scorebp scoregh scorevt scoresf scorere scoremh

	/*PF*/
	imputeitems `3' `4' `5' `6' `7' `8' `9' `10' `11' `12',max(4) noround prefix(`imp')
	genscore `imp'`3' `imp'`4' `imp'`5' `imp'`6' `imp'`7' `imp'`8' `imp'`9' `imp'`10' `imp'`11' `imp'`12',score(`scorepf')
	qui replace `scorepf'=(`scorepf'-10)/20*100
	/*RP*/
	imputeitems `13' `14' `15' `16',max(1) noround prefix(`imp')
	genscore `imp'`13' `imp'`14' `imp'`15' `imp'`16',score(`scorerp')
	qui replace `scorerp'=(`scorerp'-4)/4*100
	/*BP*/
	tempvar jb
	qui gen `jb'=.
	qui replace `jb'=6 if `21'==1&`22'==1
	qui replace `jb'=5 if `21'>=2&`21'<=6&`22'==1
	qui replace `jb'=4 if `22'==2&`21'!=.
	qui replace `jb'=3 if `22'==3&`21'!=.
	qui replace `jb'=2 if `22'==4&`21'!=.
	qui replace `jb'=1 if `22'==5&`21'!=.
	qui replace `jb'=6    if `22'==1&`21'==.
	qui replace `jb'=4.75 if `22'==2&`21'==.
	qui replace `jb'=3.5  if `22'==3&`21'==.
	qui replace `jb'=2.25 if `22'==4&`21'==.
	qui replace `jb'=1    if `22'==5&`21'==.
	qui replace `22'=`jb'
	if "`v2'"=="" {
	   qui recode `21' 1=6 2=5.4 3=4.2 4=3.1 5=2.2 6=1
	}
	else {
	   qui recode `21' 1=6 2=4.8 3=2.65 4=1
	}
	imputeitems `21' `22',max(0) noround prefix(`imp')
*	replace `imp'`21'=`21'
*	replace `imp'`22'=`22'
	qui genscore `imp'`21' `imp'`22',score(`scorebp')
*	list sf36_7q_intensite_douleurs sf36_8q_douleurs_physiques `21' `22' `imp'`21' `imp'`22' `scorebp'
	qui replace `scorebp'=(`scorebp'-2)/10*100
*tab `scorebp'
	/*GH*/
	qui recode `1' 1=5 2=4.4 3=3.4 4=2 5=1
	qui recode `34' 1=5 2=4 3=3 4=2 5=1
	qui recode `36' 1=5 2=4 3=3 4=2 5=1
	imputeitems `1' `33' `34' `35' `36',max(2) noround prefix(`imp')
	genscore `imp'`1' `imp'`33' `imp'`34' `imp'`35' `imp'`36',score(`scoregh')
	qui replace `scoregh'=(`scoregh'-5)/20*100
	/*VT*/
	if "`v2'"=="" {
	   qui recode `23' 1=6 2=5 3=4 4=3 5=2 6=1
	   qui recode `27' 1=6 2=5 3=4 4=3 5=2 6=1
	}
	else {
	   qui recode `23' 1=6 2=4.5 3=3.5 4=2 5=1
	   qui recode `27' 1=6 2=4.5 3=3.5 4=2 5=1
	   qui recode `29' 1=1 2=2 3=3.5 4=4.5 5=6
	   qui recode `31' 1=1 2=2 3=3.5 4=4.5 5=6
	}
	imputeitems `23' `27' `29' `31',max(1) noround prefix(`imp')
	genscore `imp'`23' `imp'`27' `imp'`29' `imp'`31',score(`scorevt')
	qui replace `scorevt'=(`scorevt'-4)/20*100
	/*SF*/
	if "`v2'"=="" {
	   qui recode `20' 1=5 2=4 3=3 4=2 5=1
	}
	else {
	   qui recode `20' 1=5 2=4 3=2.5 4=1
	}
	imputeitems `20' `32',max(0) noround prefix(`imp')
	genscore `imp'`20' `imp'`32',score(`scoresf')
	qui replace `scoresf'=(`scoresf'-2)/8*100
	/*RE*/
	imputeitems `17' `18' `19',max(1) noround prefix(`imp')
	genscore `imp'`17' `imp'`18' `imp'`19',score(`scorere')
	qui replace `scorere'=(`scorere'-3)/3*100
	/*MH*/
	if "`v2'"=="" {
	   qui recode `26' 1=6 2=5 3=4 4=3 5=2 6=1
	   qui recode `30' 1=6 2=5 3=4 4=3 5=2 6=1
	}
	else {
	   qui recode `26' 1=6 2=4.5 3=3.5 4=2 5=1
	   qui recode `30' 1=6 2=4.5 3=3.5 4=2 5=1
	   qui recode `24' 1=1 2=2 3=3.5 4=4.5 5=6
	   qui recode `25' 1=1 2=2 3=3.5 4=4.5 5=6
	   qui recode `28' 1=1 2=2 3=3.5 4=4.5 5=6
	}
	imputeitems `24' `25' `26' `28' `30',max(2) noround prefix(`imp')
	genscore `imp'`24' `imp'`25' `imp'`26' `imp'`28' `imp'`30',score(`scoremh')
	qui replace `scoremh'=(`scoremh'-5)/25*100
    tempname scorepfz scorerpz scorebpz scoreghz scorevtz scoresfz scorerez scoremhz scorepcs scoremcs

	/*scores composites*/
	qui gen `scorepfz'=(`scorepf'-84.52404)/22.89490
	qui gen `scorerpz'=(`scorerp'-81.19907)/33.79729
	qui gen `scorebpz'=(`scorebp'-75.49196)/23.55879
	qui gen `scoreghz'=(`scoregh'-72.21316)/20.16964
	qui gen `scorevtz'=(`scorevt'-61.05453)/20.86942
	qui gen `scoresfz'=(`scoresf'-83.59753)/22.37649
	qui gen `scorerez'=(`scorere'-81.29467)/33.02717
	qui gen `scoremhz'=(`scoremh'-74.84212)/18.01189
	qui gen `scorepcs'=(`scorepfz'*0.42402+`scorerpz'*0.35119+`scorebpz'*0.31754+`scoreghz'*0.24954+`scorevtz'*0.02877-`scoresfz'*0.0753-`scorerez'*0.19206-`scoremhz'*0.22069)*10+50
	qui gen `scoremcs'=(-`scorepfz'*0.22999-`scorerpz'*0.12329-`scorebpz'*0.09731-`scoreghz'*0.01571+`scorevtz'*0.23534+`scoresfz'*0.26876+`scorerez'*0.43407+`scoremhz'*0.48581)*10+50


/*scores composites SF12*/
tempname scoresf12p sf12p_1 sf12p_2a sf12p_2b sf12p_3a sf12p_3b sf12p_4a sf12p_4b sf12p_5 sf12p_6 sf12p_7a sf12p_7b sf12p_7c
tempname scoresf12m sf12m_1 sf12m_2a sf12m_2b sf12m_3a sf12m_3b sf12m_4a sf12m_4b sf12m_5 sf12m_6 sf12m_7a sf12m_7b sf12m_7c
	qui gen `sf12p_1'=`1'
	qui gen `sf12p_2a'=`4'
	qui gen `sf12p_2b'=`6'
	qui gen `sf12p_3a'=`14'
	qui gen `sf12p_3b'=`15'
	qui gen `sf12p_4a'=`18'
	qui gen `sf12p_4b'=`19'
	qui gen `sf12p_5'=`20'
	qui gen `sf12p_6'=`32'
	qui gen `sf12p_7a'=`26'
	qui gen `sf12p_7b'=`27'
	qui gen `sf12p_7c'=`28'
	qui gen `sf12m_1'=`1'
	qui gen `sf12m_2a'=`4'
	qui gen `sf12m_2b'=`6'
	qui gen `sf12m_3a'=`14'
	qui gen `sf12m_3b'=`15'
	qui gen `sf12m_4a'=`18'
	qui gen `sf12m_4b'=`19'
	qui gen `sf12m_5'=`20'
	qui gen `sf12m_6'=`32'
	qui gen `sf12m_7a'=`26'
	qui gen `sf12m_7b'=`27'
	qui gen `sf12m_7c'=`28'
    qui recode `sf12p_1' 5=0 4.4=-1.31872 3.4=-3.02396 2=-5.56461 1=-8.37399
    qui recode `sf12m_1' 5=0 4.4=-0.06064 3.4=0.03482 2=-0.16891 1=-1.71175
    qui recode `sf12p_2a' 1=-7.23216 2=-3.45555 3=0
    qui recode `sf12m_2a' 1=3.93115 2=1.86840 3=0
    qui recode `sf12p_2b' 1=-6.24397 2=-2.73557 3=0
    qui recode `sf12m_2b' 1=2.68282 2=1.43103 3=0
    qui recode `sf12p_3a' 1=-4.61617 2=0
    qui recode `sf12m_3a' 1=1.44060 2=0
    qui recode `sf12p_3b' 1=-5.51747 2=0
    qui recode `sf12m_3b' 1=1.66968 2=0
    qui recode `sf12p_4a' 1=3.04365 2=0
    qui recode `sf12m_4a' 1=-6.82672 2=0
    qui recode `sf12p_4b' 1=2.32091 2=0
    qui recode `sf12m_4b' 1=-5.69921 2=0
    qui recode `sf12p_6' 1=-0.33682 2=-0.94342 3=-0.18043 4=-0.11038 5=0
    qui recode `sf12m_6' 1=-6.29724 2=-8.26066 3=-5.63286 4=-3.13896 5=0
	if "`v2'"=="" {
	   qui recode `sf12p_5' 5=0 4=-3.83130 3=-6.50522 2=-8.38063 1=-11.25544
	   qui recode `sf12m_5' 5=0 4=0.90384 3=1.49384 2=1.76691 1=1.48619
	   qui recode `sf12p_7a' 6=0 5=0.66514 4=1.36689 3=2.37241 2=2.90426 1=3.46638
	   qui recode `sf12m_7a' 6=0 5=-1.94949 4=-4.09842 3=-6.31121 2=-7.92717 1=-10.19085
	   qui recode `sf12p_7b' 6=0 5=-0.42251 4=-1.14387 3=-1.61850 2=-2.02168 1=-2.44706
	   qui recode `sf12m_7b' 6=0 5=-0.92057 4=-1.65178 3=-3.29805 2=-4.88962 1=-6.02409
       qui recode `sf12p_7c' 1=4.61446 2=3.41593 3=2.34247 4=1.28044 5=0.41188 6=0
       qui recode `sf12m_7c' 1=-16.15395 2=-10.77911 3=-8.09914 4=-4.59055 5=-1.95934 6=0
  }
   else  {
	   qui recode `sf12p_5' 5=0 4=-3.83130 2.5=-7.442925 1=-11.25544
	   qui recode `sf12m_5' 5=0 4=0.90384 2.5=1.630375 1=1.48619
	   qui recode `sf12p_7a' 6=0 4.5=1.016015 3.5=1.86965 2=2.90426 1=3.46638
	   qui recode `sf12m_7a' 6=0 4.5=-3.023955 3.5=-5.204815 2=-7.92717 1=-10.19085
	   qui recode `sf12p_7b' 6=0 4.5=-0.78319 3.5=-1.381185 2=-2.02168 1=-2.44706
	   qui recode `sf12m_7b' 6=0 4.5=-1.286175 3.5=-2.474915 2=-4.88962 1=-6.02409
       qui recode `sf12p_7c' 1=4.61446 2=3.41593 3.5=1.811455 4.5=0.84616 6=0
       qui recode `sf12m_7c' 1=-16.15395 2=-10.77911 3.5=-6.344845 4.5=-3.274945 6=0
  }
  qui gen `scoresf12p'=`sf12p_1'+`sf12p_2a'+`sf12p_2b'+`sf12p_3a'+`sf12p_3b'+`sf12p_4a'+`sf12p_4b'+`sf12p_5'+`sf12p_6'+`sf12p_7a'+`sf12p_7b'+`sf12p_7c'+56.57706
  qui gen `scoresf12m'=`sf12m_1'+`sf12m_2a'+`sf12m_2b'+`sf12m_3a'+`sf12m_3b'+`sf12m_4a'+`sf12m_4b'+`sf12m_5'+`sf12m_6'+`sf12m_7a'+`sf12m_7b'+`sf12m_7c'+60.75781

if "`save'"!="" {
   local listmin pf rp bp gh vt sf re mh pcs mcs
   local listmaj PF RP BP GH VT SF RE MH PCS MCS
   local error=0
   local list
   local c=1
   foreach i in `listmin' {
       local j:word `c' of `listmaj'
	   capture confirm variable `save'`i'
	   if _rc==0&"`replace'"=="" {
	      local ++error
		  local list "`list' `save'`j'"
	   }
	   local ++c
   }
   local c=1
   if `error'==0 {
      foreach i in `listmin' {
		   local j:word `c' of `listmaj'
		   capture confirm variable `save'`i'
		   if _rc==0 {
			  qui replace `save'`i'=`score`i''
		   }
		   else {
			  qui gen `save'`i'=`score`i''
		   }
		   local ++c
      }
   }
   else {
      di in red "The variable(s) `list' already exist(s)"
   }
}
tempname scoreref1 scoreref0 scoreref01 scoreref scorerefv1 scorerefv0 scorerefv01 scorerefv
matrix `scoreref1'=(96.65,95.80,86.82,82.36,67.86,89.76,93.14,72.85\95.75,91.16,83.60,76.07,64.50,86.50,90.64,72.08\94.41,90.76,81.03,73.13,64.32,86.37,89.07,71.01\92.27,88.64,79.02,72.27,66.06,86.69,90.00,71.53\82.32,79.81,70.21,65.97,60.19,83.33,83.00,71.10\76.58,74.74,67.10,62.37,58.21,79.74,80.04,71.16\67.16,61.28,63.99,58.61,53.93,76.16,66.67,70.24)
matrix `scoreref0'=(94.92,89.54,79.37,71.81,60.32,79.65,81.65,64.92\92.42,85.98,80.19,75.10,60.57,82.83,86.13,68.18\91.04,88.87,78.27,74.64,61.94,84.14,85.48,67.59\86.23,85.54,71.97,69.14,58.90,79.80,83.42,64.84\77.88,77.85,66.23,65.10,58.18,78.29,77.61,66.17\71.60,68.74,62.40,61.23,55.08,76.47,73.24,65.45\58.20,52.46,59.68,59.73,47.94,71.68,62.21,60.63)
matrix `scoreref01'=(95.65,92.18,82.51,76.26,63.52,83.93,86.47,68.29\93.93,88.34,81.75,75.54,62.35,84.51,88.19,69.94\92.71,89.80,79.63,73.89,63.12,85.24,87.26,69.28\89.25,87.09,75.50,70.70,62.48,83.24,86.71,68.19\79.99,78.78,68.12,65.51,59.14,80.69,80.19,68.52\73.69,71.24,64.37,61.71,56.39,77.84,76.05,67.84\62.40,56.67,61.72,59.20,50.86,73.80,64.38,65.29)
matrix `scoreref'=(84.45,81.21,73.39,69.13,59.96,81.55,82.13,68.47\87.07,83.86,75.98,70.07,62.23,84.08,85.41,71.42\82.22,78.96,71.18,68.33,58.03,79.41,79.34,65.96)
matrix `scorerefv1'=(11.78,15.33,17.21,13.93,14.16,14.43,20.73,15.28\9.64,21.30,19.63,15.89,16.72,19.05,24.18,15.83\11.08,23.63,21.00,16.20,16.65,18.97,26.12,16.70\14.92,26.35,22.09,17.41,16.24,17.01,23.15,16.23\20.48,32.67,22.24,17.93,16.89,20.35,32.04,17.40\22.78,36.05,24.06,19.08,18.03,21.94,33.89,16.60\27.44,40.86,24.38,17.61,18.86,24.08,41.43,20.03)
matrix `scorerefv0'=(9.10,21.65,21.66,17.69,18.10,22.35,29.58,17.32\14.19,28.28,21.28,16.66,18.28,20.57,28.19,18.06\14.81,25.19,21.25,17.64,18.55,20.97,29.37,17.92\19.11,29.40,23.90,18.60,17.84,21.44,31.24,16.66\21.49,33.02,24.10,18.78,18.22,23.46,34.89,18.03\23.42,38.17,23.94,17.67,17.59,22.46,37.41,18.21\25.70,39.18,23.40,18.08,17.98,24.06,39.97,18.98)
matrix `scorerefv01'=(10.33,19.46,20.21,17.00,16.94,20.00,26.80,16.83\12.44,25.45,20.60,16.31,17.69,19.96,16.51,17.18\13.19,24.43,21.15,16.95,17.66,20.02,27.85,17.40\17.39,27.92,23.25,18.06,17.41,19.64,27.65,16.76\21.11,32.83,23.29,18.37,17.61,22.16,33.63,17.88\23.27,37.40,24.09,18.28,17.83,22.29,36.13,17.77\26.85,40.16,23.92,17.83,18.62,24.13,40.67,20.04)
matrix `scorerefv'=(21.19,32.20,23.73,18.57,18.05,21.41,32.15,17.62\19.85,30.48,23.03,18.39,17.36,20.08,29.89,16.70\22.02,33.43,24.10,18.69,18.40,22.26,33.71,17.99)

tempname scorerefpf scorerefrp scorerefbp scorerefgh scorerefvt scorerefsf scorerefre scorerefmh
tempname scorerefpfv scorerefrpv scorerefbpv scorerefghv scorerefvtv scorerefsfv scorerefrev scorerefmhv
if "`age'"!=""&"`sexe'"!="" {
	local c=1
	foreach i in pf rp bp gh vt sf re mh  {
		qui gen `scoreref`i''=`scoreref0'[1,`c'] if `sexe'==0&`age'>=18&`age'<25
		qui replace `scoreref`i''=`scoreref0'[2,`c'] if `sexe'==0&`age'>=25&`age'<35
		qui replace `scoreref`i''=`scoreref0'[3,`c'] if `sexe'==0&`age'>=35&`age'<45
		qui replace `scoreref`i''=`scoreref0'[4,`c'] if `sexe'==0&`age'>=45&`age'<55
		qui replace `scoreref`i''=`scoreref0'[5,`c'] if `sexe'==0&`age'>=55&`age'<65
		qui replace `scoreref`i''=`scoreref0'[6,`c'] if `sexe'==0&`age'>=65&`age'<75
		qui replace `scoreref`i''=`scoreref0'[7,`c'] if `sexe'==0&`age'>=75
		qui replace `scoreref`i''=`scoreref1'[1,`c'] if `sexe'==1&`age'>=18&`age'<25
		qui replace `scoreref`i''=`scoreref1'[2,`c'] if `sexe'==1&`age'>=25&`age'<35
		qui replace `scoreref`i''=`scoreref1'[3,`c'] if `sexe'==1&`age'>=35&`age'<45
		qui replace `scoreref`i''=`scoreref1'[4,`c'] if `sexe'==1&`age'>=45&`age'<55
		qui replace `scoreref`i''=`scoreref1'[5,`c'] if `sexe'==1&`age'>=55&`age'<65
		qui replace `scoreref`i''=`scoreref1'[6,`c'] if `sexe'==1&`age'>=65&`age'<75
		qui replace `scoreref`i''=`scoreref1'[7,`c'] if `sexe'==1&`age'>=75
		qui gen `scoreref`i'v'=(`scorerefv0'[1,`c'])^2 if `sexe'==0&`age'>=18&`age'<25
		qui replace `scoreref`i'v'=(`scorerefv0'[2,`c'])^2 if `sexe'==0&`age'>=25&`age'<35
		qui replace `scoreref`i'v'=(`scorerefv0'[3,`c'])^2 if `sexe'==0&`age'>=35&`age'<45
		qui replace `scoreref`i'v'=(`scorerefv0'[4,`c'])^2 if `sexe'==0&`age'>=45&`age'<55
		qui replace `scoreref`i'v'=(`scorerefv0'[5,`c'])^2 if `sexe'==0&`age'>=55&`age'<65
		qui replace `scoreref`i'v'=(`scorerefv0'[6,`c'])^2 if `sexe'==0&`age'>=65&`age'<75
		qui replace `scoreref`i'v'=(`scorerefv0'[7,`c'])^2 if `sexe'==0&`age'>=75
		qui replace `scoreref`i'v'=(`scorerefv1'[1,`c'])^2 if `sexe'==1&`age'>=18&`age'<25
		qui replace `scoreref`i'v'=(`scorerefv1'[2,`c'])^2 if `sexe'==1&`age'>=25&`age'<35
		qui replace `scoreref`i'v'=(`scorerefv1'[3,`c'])^2 if `sexe'==1&`age'>=35&`age'<45
		qui replace `scoreref`i'v'=(`scorerefv1'[4,`c'])^2 if `sexe'==1&`age'>=45&`age'<55
		qui replace `scoreref`i'v'=(`scorerefv1'[5,`c'])^2 if `sexe'==1&`age'>=55&`age'<65
		qui replace `scoreref`i'v'=(`scorerefv1'[6,`c'])^2 if `sexe'==1&`age'>=65&`age'<75
		qui replace `scoreref`i'v'=(`scorerefv1'[7,`c'])^2 if `sexe'==1&`age'>=75
		local ++c
    }
}
else if "`age'"!=""&"`sexe'"=="" {
	local c=1
	foreach i in pf rp bp gh vt sf re mh  {
    	qui gen `scoreref`i''=`scoreref01'[1,`c'] if `age'>=18&`age'<25
    	qui replace `scoreref`i''=`scoreref01'[2,`c'] if `age'>=25&`age'<35
    	qui replace `scoreref`i''=`scoreref01'[3,`c'] if `age'>=35&`age'<45
    	qui replace `scoreref`i''=`scoreref01'[4,`c'] if `age'>=45&`age'<55
    	qui replace `scoreref`i''=`scoreref01'[5,`c'] if `age'>=55&`age'<65
    	qui replace `scoreref`i''=`scoreref01'[6,`c'] if `age'>=65&`age'<75
    	qui replace `scoreref`i''=`scoreref01'[7,`c'] if `age'>=75
    	qui gen `scoreref`i'v'=(`scorerefv01'[1,`c'])^2 if `age'>=18&`age'<25
    	qui replace `scoreref`i'v'=(`scorerefv01'[2,`c'])^2 if `age'>=25&`age'<35
    	qui replace `scoreref`i'v'=(`scorerefv01'[3,`c'])^2 if `age'>=35&`age'<45
    	qui replace `scoreref`i'v'=(`scorerefv01'[4,`c'])^2 if `age'>=45&`age'<55
    	qui replace `scoreref`i'v'=(`scorerefv01'[5,`c'])^2 if `age'>=55&`age'<65
    	qui replace `scoreref`i'v'=(`scorerefv01'[6,`c'])^2 if `age'>=65&`age'<75
    	qui replace `scoreref`i'v'=(`scorerefv01'[7,`c'])^2 if `age'>=75
		local ++c
    }
}
else if "`age'"==""&"`sexe'"!="" {
	local c=1
	foreach i in pf rp bp gh vt sf re mh  {
    	qui gen `scoreref`i''=`scoreref'[2,`c'] if `sexe'==1
    	qui replace `scoreref`i''=`scoreref'[3,`c'] if `sexe'==0
    	qui gen `scoreref`i'v'=(`scorerefv'[2,`c'])^2 if `sexe'==1
    	qui replace `scoreref`i'v'=(`scorerefv'[3,`c'])^2 if `sexe'==0
 		local ++c
   }
}
else if "`age'"==""&"`sexe'"=="" {
	local c=1
	foreach i in pf rp bp gh vt sf re mh  {
    	gen `scoreref`i''=`scoreref'[1,`c']
    	gen `scoreref`i'v'=(`scorerefv'[1,`c'])^2
		local ++c
    }
}
tempname scorerefpfz scorerefrpz scorerefbpz scorerefghz scorerefvtz scorerefsfz scorerefrez scorerefmhz scorerefpcs scorerefmcs
tempname scorerefpfvz scorerefrpvz scorerefbpvz scorerefghvz scorerefvtvz scorerefsfvz scorerefrevz scorerefmhvz scorerefpcsv scorerefmcsv

qui gen `scorerefpfz'=(`scorerefpf'-84.52404)/22.89490
qui gen `scorerefrpz'=(`scorerefrp'-81.19907)/33.79729
qui gen `scorerefbpz'=(`scorerefbp'-75.49196)/23.55879
qui gen `scorerefghz'=(`scorerefgh'-72.21316)/20.16964
qui gen `scorerefvtz'=(`scorerefvt'-61.05453)/20.86942
qui gen `scorerefsfz'=(`scorerefsf'-83.59753)/22.37649
qui gen `scorerefrez'=(`scorerefre'-81.29467)/33.02717
qui gen `scorerefmhz'=(`scorerefmh'-74.84212)/18.01189
qui gen `scorerefpcs'=(`scorerefpfz'*0.42402+`scorerefrpz'*0.35119+`scorerefbpz'*0.31754+`scorerefghz'*0.24954+`scorerefvtz'*0.02877-`scorerefsfz'*0.0753-`scorerefrez'*0.19206-`scorerefmhz'*0.22069)*10+50
qui gen `scorerefmcs'=(-`scorerefpfz'*0.22999-`scorerefrpz'*0.12329-`scorerefbpz'*0.09731-`scorerefghz'*0.01571+`scorerefvtz'*0.23534+`scorerefsfz'*0.26876+`scorerefrez'*0.43407+`scorerefmhz'*0.48581)*10+50

qui gen `scorerefpfvz'=(`scorerefpfv')/22.89490^2
qui gen `scorerefrpvz'=(`scorerefrpv')/33.79729^2
qui gen `scorerefbpvz'=(`scorerefbpv')/23.55879^2
qui gen `scorerefghvz'=(`scorerefghv')/20.16964^2
qui gen `scorerefvtvz'=(`scorerefvtv')/20.86942^2
qui gen `scorerefsfvz'=(`scorerefsfv')/22.37649^2
qui gen `scorerefrevz'=(`scorerefrev')/33.02717^2
qui gen `scorerefmhvz'=(`scorerefmhv')/18.01189^2
qui gen `scorerefpcsv'=(`scorerefpfvz'*0.42402^2+`scorerefrpvz'*0.35119^2+`scorerefbpvz'*0.31754^2+`scorerefghvz'*0.24954^2+`scorerefvtvz'*0.02877^2-`scorerefsfvz'*0.0753^2-`scorerefrevz'*0.19206^2-`scorerefmhvz'*0.22069^2)*10^2
qui gen `scorerefmcsv'=(-`scorerefpfvz'*0.22999^2-`scorerefrpvz'*0.12329^2-`scorerefbpvz'*0.09731^2-`scorerefghvz'*0.01571^2+`scorerefvtvz'*0.23534^2+`scorerefsfvz'*0.26876^2+`scorerefrevz'*0.43407^2+`scorerefmhvz'*0.48581^2)*10^2





if "`saveref'"!="" {
   local listmin pf rp bp gh vt sf re mh pcs mcs
   local listmaj PF RP BP GH VT SF RE MH PCS MCS
   local error=0
   local list
   local c=1
   foreach i in `listmin' {
       local j:word `c' of `listmaj'
	   capture confirm variable `saveref'`i'
	   if _rc==0&"`replace'"=="" {
	      local ++error
		  local list "`list' `saveref'`j'"
	   }
	   local ++c
   }
   local c=1
   if `error'==0 {
      foreach i in `listmin' {
		   local j:word `c' of `listmaj'
		   capture confirm variable `saveref'`i'
		   if _rc==0 {
			  qui replace `saveref'`i'=`scoreref`i''
		   }
		   else {
			  qui gen `saveref'`i'=`scoreref`i''
		   }
		   local ++c
      }
   }
   else {
      di in red "The variable(s) `list' already exist(s)"
   }
}

if "`details'"!="" {
	di "{hline 80}"
	di in gr _col(12) "Sample" _col(51) "Reference"
	di in gr "Dimension" _col(16) "N" _col(21) "Mean" _col(29) "s.d." _col(40) "Min-Max" _col(52) "Mean" _col(60) "s.d." _col(72) "p"
	di "{hline 80}"
    local listmin pf rp bp gh vt sf re mh pcs mcs sf12p sf12m
    local listmaj PF RP BP GH VT SF RE MH PCS MCS SF12P SF12M
    local c=1
	foreach i in `listmin' {
	   local j:word `c' of `listmaj'
	   qui su `score`i''
	   local means`i'=r(mean)
	   local sds`i'=r(sd)
	   local mins`i'=r(min)
	   local maxs`i'=r(max)
	   local n`i'=r(N)
	   if "`i'"!="sf12p"&"`i'"!="sf12m" {
		   qui su `scoreref`i'' if `score`i''!=.
		   local meanr`i'=r(mean)
		   local sdr`i'=r(sd)
		   local vr`i'=(`sdr`i'')^2
		   qui su `scoreref`i'v' if `score`i''!=.
		   local meanvr`i'=r(mean)
		   local sdr`i'=sqrt(`vr`i''+`meanvr`i'')
		   *local minr`i'=r(min)
		   *local maxr`i'=r(max)
		   qui ttest `score`i''=`meanr`i''
		   local p`i'=r(p)
	   }
	   di in gr "`j'" in ye _col(12) %5.0f `n`i'' _col(20) %5.2f `means`i'' _col(28) %5.2f `sds`i'' _col(34) %6.2f `mins`i'' "-" %6.2f `maxs`i'' _col(51) %5.2f `meanr`i'' _col(59) %5.2f `sdr`i''  _col(67) %6.4f `p`i''
	   local ++c
   }
   di "{hline 80}"
   *corr `scorepcs' `scoremcs' `scoresf12p' `scoresf12m'
   *scatter `scorepcs' `scoresf12p' ,name(p)
   *scatter `scoremcs' `scoresf12m' ,name(m)
   *su  `scoresf12p' `sf12p_1' `sf12p_2a' `sf12p_2b' `sf12p_3a' `sf12p_3b' `sf12p_4a' `sf12p_4b' `sf12p_5' `sf12p_6' `sf12p_7a' `sf12p_7b' `sf12p_7c'
   *su  `scoresf12m' `sf12m_1' `sf12m_2a' `sf12m_2b' `sf12m_3a' `sf12m_3b' `sf12m_4a' `sf12m_4b' `sf12m_5' `sf12m_6' `sf12m_7a' `sf12m_7b' `sf12m_7c'

}
if "`saveimp'"!="" {
*su
    foreach i of numlist 1 3/36 {
        local j:word `i' of `varlistsav'
        *di "gen `saveimp'`j'=`imp'``i''"
        capture confirm variable `saveimp'`j'
                   if _rc==0&"`replace'"=="" {
                          di in ye "The variable `saveimp'`j' already exists and cannot be replaced."
                   }
                   else if _rc==0&"`replace'"!="" {
			  qui replace `saveimp'`j'=`imp'``i''
		   }
		   else {
                          qui gen `saveimp'`j'=`imp'``i''
		   }
    }
}
end

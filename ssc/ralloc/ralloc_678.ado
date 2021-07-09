*! version 3.2.5   Philip Ryan   September 2, 2000
*! this is the version to be used with Stata release 6, 7 or 8. 
*! development on this has ceased.
*! random allocation in blocks
* since STB-54:
* fixed delimiting errors in lines 150 (3.2.4)
* allows 5 treatments (3.2.4)
* allows current date to be specified as the seed (3.2.5)
* automatically writes ralloc version number to notes (3.2.5)
* since STB-50:
* optionally stratify;
* optionally use 2x2, 2x3, ...., 3x4, 4x3 factorial designs;
* specify 1:2 ratio in 2, 1 or neither axis of a 2x2 factorial trial;
* 2x2 crossover design with or without switchback or last Rx carried forward
*!
*!  Syntax:
*!    ralloc_678 <Block ID varname > <Block Size varname> <Treatment varname stub>,
*!                         saving(filename1) 
*!                      [  multif|nomultif    seed(#|"date")
*!                         nsubj(int 100)     ntreat(2|3|4|5)
*!                         ratio(1|2|3)       osize(1|2|3|4|5|6|7)
*!                         init(#)            equal|noequal
*!                         strata(#)          using(filename2)
*!                         countv(varname)    tables|notables
*!                         trtlab(label1 [label2] .....)
*!                         factor(2*2|2*3|3*2|3*3|2*4|4*2|3*4|4*3)
*!                         fratio(1 1|2 1|1 2|2 2)
*!                         xover(stand|switch|extra)
*!                         shape(long|wide)    matsiz(#)  ]
*!
*!    ralloc_678 ?

***********************************************************************
********************** begin program ralloc.ado ***********************
***********************************************************************

program define ralloc_678

version 6

local versn "3.2.5"

if "`1'" == "?" {
      which ralloc_678
      exit
}

clear
set more 1
#delimit ;
syntax newvarlist(gen min=3 max=3) , SAVing(string)
                                   [ MULTIF         SEed(string)
                                     NSubj(int 100) NTreat(string)
                                     RAtio(string)  OSize(int 5)
                                     INIT(int 0)    EQual
                                     STRATa(int 1)  USing(string)
                                     COUNTv(string) TRTLAB(string)
                                     TABles         FACTor(string)
                                     FRAtio(string) XOVer(string)
                                     TR1lab(string) TR2lab(string)
                                     TR3lab(string) TR4lab(string)
                                     SHAPe(string)  MATSIZ(int 40) ];

#delimit cr

**** 1 = BlockID         2 = BlockSize         3 = Treat



tokenize `varlist'
local bz `1'
local sz `2'
local tz `3'
local ntmax = 5




*************************************************************
*****Check for some errors in syntax*************************
*************************************************************

#delimit ;
if "`xover'" != "" & "`xover'" != "stand" & "`xover'" != "switch"
 & "`xover'" != "extra" {
di in r "xover must be 'stand', 'switch' or 'extra'";
clear;
#delimit cr
exit
}

#delimit cr

if "`factor'" != "" & "`xover'" != "" {
di in r "cannot specify both factor() and xover()"
clear
exit
}

if "`factor'" !="" & length("`3'") >7 {
di in r "<Treatmentvar> must be 7 characters or less in a factorial design"
clear
exit
}


if "`factor'" != "" {
 if "`ntreat'" != "" {
 di in r "do not specify ntreat() in a factorial design"
 clear
 exit
 }
}
else {
 if "`ntreat'" == "" {
  local ntreat = 2
 }
 else {
  if "`ntreat'" =="2" | "`ntreat'" =="3" | "`ntreat'" =="4" | "`ntreat'" =="5" {
   local ntreat = `ntreat'
  }
  else {
    di in r "number of treatments given by ntreat() must be no more than `ntmax'"
    clear
    exit
  }
 }
}

if "`xover'" != "" {
 if `ntreat' !=2 {
di in r "number of treatments must be 2 for a crossover design"
clear
exit
 }
}

if (`strata' < 1 ) | (`strata' > 800) {
di in r "The number of strata specified must be between 1 and 800"
clear
exit
}


#delimit ;
if "`factor'" != "" {;
 if "`factor'" != "2*2" & "`factor'" != "2*3" & "`factor'" != "3*2"
  & "`factor'" != "3*3" & "`factor'" != "2*4" & "`factor'" != "4*2"
  & "`factor'" != "3*4" & "`factor'" != "4*3" {;
 di in r "factorial design must be specified as 2*2, 2*3, 3*2, 3*3,
2*4, 4*2, 3*4 or 4*3";
 clear;
 exit;
};
};
#delimit cr


if (("`factor'" == "")|("`factor'" != "2*2")) & ("`fratio'" != "") {
 di in r "fratio() may only be specified for a 2x2 factorial design"
 clear
 exit
}

#delimit ;
if "`fratio'" != "" & "`fratio'" != "1 1" & "`fratio'" != "2 1" &
 "`fratio'" != "1 2" & "`fratio'" != "2 2"  {;
di in r "if specified, arguments of fratio must be (1 1), (1 2), (2 1), or (2 2)";
clear;
exit;
};
#delimit cr

if "`factor'" == "2*2" & "`fratio'" == "" {
local fratio "1 1"
}

*******
if "`factor'" != "" {
tokenize `factor', parse("*")
local rx1fac = real("`1'")
local rx2fac = real("`3'")
local ntreat = `rx1fac'*`rx2fac'
}

if "`fratio'" != "" {
tokenize `fratio'
local frat1 = `1'
local frat2 = `2'
local rx1fac = `rx1fac' + (`frat1' - 1)
local rx2fac = `rx2fac' + (`frat2' - 1)
local ntreat = `rx1fac'*`rx2fac'
local tfactor "`rx1fac'*`rx2fac'"
}

*******

if ("`factor'" != "" | "`xover'" != "") & "`ratio'" != "" {
 dis in r "do not specify ratio() for a factorial or crossover design"
 clear
 exit
}


if ("`factor'" != ""  | "`xover'" != "") & "`shape'" == "wide" {
 dis in r "shape of data must be long for factorial or crossover design"
 clear
 exit
}


if (`osize' <1 | `osize' > 7) {
 #delimit ;
 display in r "The number of different block sizes must be"
              " 1, 2, 3, 4, 5, 6 or 7";
 #delimit cr
 clear
 exit
}

if ("`shape'" =="") {
local shape = "long"
}

else {
if ("`shape'" != "long" & "`shape'" != "wide") {
di in r "-shape- must be either " in ye "wide " in re "or " in ye "long"
clear
exit
}
}

if "`ratio'" != "" & "`ratio'" != "1" & "`ratio'" != "2" & "`ratio'" != "3" {
di in r "ratio() must be unspecified or specified as 1, 2, or 3"
clear
exit
}

if "`ratio'" == "" {
local ratio = 1
}
else {
local ratio = `ratio'
}

if (`ratio' != 1) {
  if (`ntreat' != 2){
   #delimit ;
   display in r "The number of treatments must be 2"
                " if" in y " ratio " in r "> 1 is specified";
   #delimit cr
   clear
   exit
   }
 if (`ratio' != 2) & (`ratio' != 3){
   display in r "ratio must be 2 or 3"
   clear
   exit
   }
}

if `init'==0 {
 local init = (`ntreat'+(`ratio'==2)+(2*(`ratio'==3)))
}

if "`factor'" == "" {
if mod(`init',(`ntreat'+(`ratio'==2)+(2*(`ratio'==3)))) != 0 {
 #delimit ;
 display in r "The " in y "init" in r "iating block size"
              " must be a multiple of the number of treatments,";
 display in r "or, in the case of a " in y "ratio " in
                r "> 1 specified for a 2 treatment trial, a";
 display in r "multiple of (" in y "ratio " in r "+ 1).";
 #delimit cr
 clear
 exit
}
}


/*
di "factor is `factor'"
di "fratio is `fratio'"
di "frat1 is `frat1'"
di "frat2 is `frat2'"
di "ntreat is `ntreat'"
di "ratio is `ratio'"
*/

* exit

if "`factor'" != "" {
 if "`fratio'" == "1 1" | "`fratio'" == "" {
  if mod(`init',`ntreat') != 0 {
#delimit ;
  display in r "For a factorial design with balanced allocation, the ";
  display in y "init" in r "iating block size must be a multiple of the number";
  display in r "of treatment combinations";
#delimit cr
  clear
  exit
  }
 }
 else {
  if mod(`init',((`frat1'+1)*(`frat2'+1)) ) != 0 {
#delimit ;
  display in r "For a factorial design with unbalanced allocation, the ";
  display in y "init" in r "iating block size must be a multiple of:";
  display in r "((1st arg of " in y "fratio" in r ") + 1) x ((2nd arg of "
                  in y "fratio" in r ") + 1)";
#delimit cr
  clear
  exit
  }
 }
}  /* end if factor */



if "`countv'" != ""  & "`using'" == "" {
di in r "You must specify a filename in -using()- if -countv()- is specified"
clear
exit
}

if "`countv'" =="" & "`using'" != "" {
di in r "You must specify the name of the count variable in file  -`using'-"
di in r " using the option  -countv()-"
clear
exit
}



*************************************************************
*****Set the Seed********************************************
*************************************************************

qui {

if "`seed'" == "" {
local seed = 123456789
}

else if "`seed'" == "date" {
local seed = date("$S_DATE", "dmy")
}

else if real("`seed'") == . {
local seed = 123456789
}

else {
if int(real("`seed'")) != real("`seed'") {
noi di " "
noi di in re "Warning: non-integer seed will be truncated to integer"
}
local seed = int(real("`seed'"))
}

set seed `seed'
set obs 1
}


*************************************************************
*****Set up Variable Labels**********************************
*************************************************************
lab var `bz' "Block ID"
lab var `sz' "Block size"
/* treatment label is set after the reshape command, see below */
*************************************************************


*************************************************************
*****Set up Treatment Labels*********************************
*************************************************************

if "`trtlab'" == "" {
 if "`tr1lab'" == "" {
 local tr1lab = "A"
 }
 if "`tr2lab'" == "" {
 local tr2lab = "B"
 }
 if "`tr3lab'" == "" {
 local tr3lab = "C"
 }
 if "`tr4lab'" == "" {
 local tr4lab = "D"
 }
 local tr5lab = "E"
 local tr6lab = "F"
 local tr7lab = "G"
}

if "`trtlab'" != "" {
local ntlab: word count `trtlab'

if "`factor'" == "" & `ntlab' > `ntmax' {
di in r "Max of `ntmax' treatment labels may be specified for non-factorial design"
clear
exit
}

if "`factor'" != "" & `ntlab' > 7 {
di in r "Max of 7 treatment labels may be specified for a `factor' design"
clear
exit
}

local strlab "ABCDEFGHIJK"
local i = 1
while `i' <= `ntmax' {
local tr`i'lab = substr("`strlab'",`i',1)
local i= `i' + 1
}

if "`factor'" != "" & "`combo'" == "8" | "`combo'" == "9" {
local tr6lab = "F"
}

if "`factor'" != "" & "`combo'" == "12" {
local tr6lab = "F"
local tr7lab = "G"
}

local d=1
while `d' <= `ntlab' {
local tr`d'lab: word `d' of `trtlab'
local tr`d'lab = substr("`tr`d'lab'",1,8)
local d = `d'+1
}
}
*************************************************************


*************************************************************
*****Set up matrix that holds info about stratification******
************case of no using file specified******************
*************************************************************

tempname mystrat A


if"`using'" == "" {

di " "
* di in g "Number of strata specified is " in y "`strata'"
if `matsiz' == 40 {
local mtz = min(max(40,`strata'),800)
set matsize `mtz'
}
else {
set matsize `matsiz'
}

local c = 1
matrix def `mystrat' = [`c',`nsubj']
local vcount = 2
local c = 2
while `c' <= `strata' {
mat `A' = (`c',`nsubj')
matrix `mystrat' = `mystrat' \ `A'
local c = `c' + 1
}  /* end while */

}  /* end if using =="" */
***************************


*************************************************************
*****Set up matrix that holds info about stratification******
************case of using file specified*********************
*************************************************************

if "`using'" != "" {
if `nsubj' == 100 {
#delimit ;
di " ";
di in g "Counts defined in variable " in y /*
*/"`countv'" in g " in file " in y "`using'"
in g " will override the";
di in g " default number of subjects, n = 100";
#delimit cr
}

if `nsubj' != 100 {
#delimit ;
di " ";
di in g "Counts defined in variable " in y "`countv'" in g /*
*/" in file " in y "`using'"
in g " will override the ";
di in g " number of subjects specified in option " in y "nsubj(`nsubj')" ;
#delimit cr
}

preserve  /* keeps BlockID BlockSiz and Trt vars in dummy 1st obs */
use `using'
qui capture conf v `countv'
if _rc != 0 {
di in r "Your specified count variable -`countv'- is not in file -`using'-"
restore
clear
exit
}
qui describe
local strata = r(N)
di " "
di in g "Number of strata read from file " in y /*
*/"`using'" in g " is " in y "`strata'"
if `matsiz' == 40 {
local mtz = min(max(40,`strata'),800)
set matsize `mtz'
}
else {
set matsize `matsiz'
}

**********
*make sure countv() variable will be in final column of matrix
**********
qui {
tempvar tempc
gen `tempc' = `countv'
drop `countv'
ren `tempc' `countv'
}

unab allvar: _all
local vcount: word count `allvar'
local nstvars = `vcount' - 1
di " "
di in g "number of stratum variables is " in y "`nstvars'"
di " "

tokenize `allvar'
local a=1
local b =1
while `a' <= `nstvars' {
di in w "stratum variable `a' is " in y "``a''"
qui sum ``a''
local numin`a' = r(max)
local min`a' = r(min)
if abs(`min`a'' - 1) > 0.000001 {
di in r "levels of stratum variable -``a''- do not begin at 1"
restore
clear
exit
}
qui tab ``a''
local lev`a' = r(r)
if  abs(`lev`a'' - `numin`a'') > 0.000001 {
di in r "levels of stratum var ``a'' do not progress by integer increments"
restore
clear
exit
}
di in w "number of levels in " in y "``a''" in w " is " in y "`numin`a''"
di " "
local b=`b'*(`numin`a'')
local a=`a'+1
}                               /* end while*/

if  abs((`strata') - (`b')) > 0.00001 {
#delimit ;
di in r "Number of rows (strata) in using file (" in w "`strata'" in r ")
does not match the product of levels";
di in r " over all stratum variables (" in w "`b'" in r "). Check the file!";
#delimit cr
restore
clear
exit
}

sort `allvar'
mkmat `allvar', matrix(`mystrat')
di in w "the stratum design and allocation numbers are:"
mat li `mystrat', noheader

tempvar sumcv
qui gen `sumcv' = sum(`countv')
local reqsubj = `sumcv'[_N]

di " "
restore
unab orig: _all
tokenize `orig'  /* puts orig vars from ralstrat back in posit macros */
}                             /* end if using() */

*********
*finished defining matrix with stratification info
*********




*************************************************************
*****Declare and initialise temporary variables**************
*************************************************************

tempvar propn shuffle numt ratx crit schem low high currid

qui {
gen `propn' = .
gen `schem' = .
gen `low' = .
gen `high' = .
gen `shuffle' = .
gen `currid' = .
}


*************************************************************
*****Declare and initialise permanent variables**************
*************************************************************

qui {
gen SeqInBlk = .
lab var SeqInBlk "order of allocation within block"
gen StratID = .
lab var StratID "stratum identifier"
}


*************************************************************
*****Start work of random allocations************************
*************************************************************

/* Maximum number of blocks required is if all blocks are
   minimum size. Initially, number of obs will be the number
   of blocks required, not the number of subjects.  Also,
   if a ratio of 1:2 or 1:3 is required the number of treatments
   is effectively 3 or 4 respectively.
*/

*****Set number of treatments*****************
quietly {

  gen `numt'=`ntreat'
  gen `ratx' = `ratio'

  if (`ratio' != 1) {
   replace `numt'=`ratx' + 1
  }
}
**********************************************


**********************************************
** not a whole lot of sense using Pascal's triangle on only 1 or 2
** block sizes, so force frequency to be equal

if ((`osize' == 1) | (`osize' == 2)) & ("`equal'" == "") {
local equal = "equal"
}
**********************************************

***Set starting obs number for 1st stratum****
local here=1
**********************************************

***Begin loop through strata using index "h"**
set seed `seed'
local h = 1
while `h' <= `strata' {
tempvar touse
qui gen `touse'= .
local nsubj = `mystrat'[`h',`vcount']
qui {
d
local nb = r(N)
}
local nb = `nb' + int((`nsubj'/`ntreat') + 1)
qui set obs `nb'
qui replace StratID = `h' if _n >= `here'

qui {
d
local there = r(N)
}
qui {
replace `numt' = `numt'[1]
replace `touse' = 1 if _n>= `here'  & _n <= `there'
replace `currid' = _n

if `h' == 1 {
replace `bz' = _n if `touse'==1
}
else {
replace `bz' = `bz'[_n-1] + 1 if `touse' == 1
}

replace StratID = `h' if `touse'==1
}


if "`equal'" != "" | `osize' ==1 | `osize' == 2 {
*****Set up block sizes with equal probability***************

quietly {
 replace `propn'=int((uniform()*100)+1) if `touse' ==1
 replace `schem'=autocode(`propn',`osize',1,100)  if `touse' ==1
 tempvar k
 egen `k' = group(`schem') if `touse' ==1
 sort `currid'
 replace `sz'=(`numt'*(`k'-1))+`init' if `touse' ==1
 }
}

else {
*****Set up block sizes in random order with unequal prob****
*****Probabilities are based on Pascal's triangle************
*****This segment is open to change at user's discretion*****

quietly {
 replace `propn'=int((uniform()*256)+1) if `touse' ==1
}

local scal=`osize'-1

quietly {
 local i=1
 replace `high' = 0 if `touse' ==1
 replace `low' = 0 if `touse' ==1
 while `i' <= `scal' {
  replace `high' = 256*(1-Binomial(`scal',`i',0.5)) if `touse' ==1
  #delimit ;
  replace `sz' = (`numt'*(`i'-1)) + `init' if
                 `propn' >`low' & `propn' <= `high' & `touse' ==1;
  #delimit cr
  replace `low'=`high'  if `touse' ==1
  local i=`i'+1
  }
  #delimit ;
  replace `sz'= (`numt'*(`osize'-1))+`init'
                if `propn' >=`low' & `propn' <=256 & `touse';
  #delimit cr
 }
 }
*************************************************************


*************************************************************
*****Expand block size var to give nsubjs at least***********
*************************************************************
quietly expand `sz' if `touse'==1
*************************************************************



*************************************************************
*****Fill block with equal numbers of treats then shuffle****
*************************************************************
sort `bz'
quietly {
 by `bz': replace `tz' = (autocode(_n,`numt',0,_N))*(`numt'/_N) /*
*/  if `touse' ==1
 by `bz': replace `shuffle' = uniform()  if `touse' ==1
 sort StratID
 sort `shuffle' in `here'/l
}

*************************************************************

tempvar tempseq      /*kill*/
gen `tempseq' = _n   /*kill*/
sort `bz' `tempseq'  /*kill*/
qui by `bz':replace SeqInBlk = _n if `touse' == 1
sort StratID `bz' SeqInBlk


*************************
* drop excess allocations
*************************
local xx = `here' + `nsubj' - 1
local crit = `bz'[`xx']
quietly drop if (_n >= `xx') & (`bz'[_n] > `crit')
*************************





******************************************************
*****Useful tables************************************
******************************************************
if "`tables'" != ""  & `strata' > 1 {
preserve
qui keep if StratID == `h'
sort `bz'
quietly by `bz':keep if _n==1
display
display in b "Frequency of block sizes in stratum `h':"
tab `sz'
restore
}
******************************************************


******************************************************
********** iterate in loop****************************
******************************************************
qui {
d
local here = r(N) + 1
}

local h = `h' + 1
}
******************************************************


******************************************************
*****Useful tables continued**************************
******************************************************
if "`tables'" != "" {
preserve
sort `bz'
quietly by `bz':keep if _n==1
display
if `strata' > 1 {
display in b "Frequency of block sizes over ALL data:"
}
else {
display in b "Frequency of block sizes:"
}
tab `sz'
restore
}
******************************************************


******************************************************
******** Final Issuing of Notes***********************
******************************************************


*****
note: Randomisation schema created on TS using ralloc_678.ado (ralloc version `versn')
*****

*****
note: Seed used = `seed'
*****

*****
if "`using'" != "" {
note: Stratum definitions and numbers of allocations were defined /*
*/in file '`using'.dta'
}
*****

*****
note: Number of strata requested = `strata'
*****

if "`xover'" != "" {
note: This is a 2 treatment, 2 period crossover design
 if "`xover'" == "switch" {
note: There is a supplementary 3rd period for a switchback design
 }
 if "`xover'" == "extra" {
note: There is a supplementary 3rd period for an extra period design
 }
}

*****
if "`factor'" == "" & "`xover'" == "" {
note: This is a non-factorial, non-crossover trial with `ntreat' treatments
}
else {
if "`factor'" !="" {
note: This is a `factor' factorial design
}
}
*****


*****
#delimit ;
if `ntreat' == 5 {;
note: Treatments are labelled:  '`tr1lab''   '`tr2lab''  
 '`tr3lab''    '`tr4lab''    '`tr5lab'';
};

if `ntreat' == 4 & "`factor'" == "" {;
note: Treatments are labelled:  '`tr1lab''   '`tr2lab''  
 '`tr3lab''    '`tr4lab'';
};

#delimit cr

if "`factor'" == "2*2" {
note: Treatments are labelled:  '`tr1lab'' &  '`tr2lab'' for/*
*/ the first factor
note: Treatments are labelled:  '`tr3lab'' &  '`tr4lab'' for/*
*/ the second factor
}


#delimit ;
if "`factor'" == "2*3" {;
note: Treatments are labelled:  '`tr1lab'' &  '`tr2lab'' for
 the first factor;
note: Treatments are labelled:  '`tr3lab'' &  '`tr4lab'' &  '`tr5lab''
 for the second factor;
};

if "`factor'" == "3*2" {;
note: Treatments are labelled:  '`tr1lab'' &  '`tr2lab'' &  '`tr3lab''
 for the first factor;
note: Treatments are labelled:  '`tr4lab'' &  '`tr5lab'' for/*
*/ the second factor;
};

if "`factor'" == "3*3" {;
note: Treatments are labelled:  '`tr1lab'' &  '`tr2lab'' &  '`tr3lab''
 for the first factor;
note: Treatments are labelled:  '`tr4lab'' &  '`tr5lab'' &  '`tr6lab''
 for the second factor;
};


if "`factor'" == "4*2" {;
note: Treatments are labelled:  '`tr1lab'' &  '`tr2lab'' &  '`tr3lab'' &
  '`tr4lab'' for the first factor;
note: Treatments are labelled:  '`tr5lab'' &  '`tr6lab''
 for the second factor;
};

if "`factor'" == "2*4" {;
note: Treatments are labelled:  '`tr1lab'' &  '`tr2lab'' for
 the first factor;
note: Treatments are labelled:  '`tr3lab'' &  '`tr4lab'' &
  '`tr5lab'' &  '`tr6lab'' for the second factor;
};

if "`factor'" == "4*3" {;
note: Treatments are labelled:  '`tr1lab'' &  '`tr2lab'' &  '`tr3lab'' &
  '`tr4lab'' for the first factor;
note: Treatments are labelled:  '`tr5lab'' &  '`tr6lab'' &  '`tr7lab''
 for the second factor;
};

if "`factor'" == "3*4" {;
note: Treatments are labelled:  '`tr1lab'' &  '`tr2lab'' &  '`tr3lab''
 for the first factor;
note: Treatments are labelled:  '`tr4lab'' &  '`tr5lab'' &
  '`tr6lab'' &  '`tr7lab'' for the second factor;
};

#delimit cr

if `ntreat' == 3 {
note: Treatments are labelled:  '`tr1lab''   '`tr2lab''    '`tr3lab'' 
}

if `ntreat' == 2 {
note: Treatments are labelled:  '`tr1lab''   '`tr2lab'' 
}
*****


*****
if `ntreat' ==2 {
note: The treatments were allocated in the ratio 1 : `ratio'
 }
if `ntreat'==3 {
note: The treatments were allocated in the ratio 1:1:1
 }
if `ntreat'==4 & "`factor'" == "" {
note: The treatments were allocated in the ratio 1:1:1:1
 }
*****


*****
if "`using'" == "" {
local reqsubj = `strata'*`nsubj'
}
note: Total number of allocations requested over all strata = `reqsubj'
*****

*****
qui d
local final = r(N)
note: Total number of allocations provided = `final'
*****

*****
if (`reqsubj' != `final') {
local extra = `final'-`reqsubj'
#delimit ;
note: `extra' extra allocations were provided to
         maintain integrity of final block in each stratum;
#delimit cr
}
*****


*****
qui summ(`sz')
local osminp = r(min)
local osmaxp = r(max)
qui tab `sz'
local osnump = r(r)
local osmaxr =`init'+(`numt'*(`osize'-1))

note: `osize' block sizes were requested: minimum size = `init', /*
*/maximum = `osmaxr'
note: `osnump' block sizes were provided: minimum size = `osminp', /*
*/maximum = `osmaxp'
*****


*****
if (`osize' > 1) {

if ("`equal'" != "") {
note: Block sizes were allocated in equal proportions
}

else {
 #delimit ;
 note: Block sizes were allocated proportional to
        elements of Pascal's triangle;
};
 #delimit cr
}
*****


*****
if `strata' > 1 {
note: Stratum identifier (1...`strata') is stored in variable 'StratID'
}
*****

*****
note: Sequence within block is stored in the variable 'SeqInBlk'
*****

*****
if "`shape'" == "wide" {
note: Data saved in wide form:
note: ....recover 'SeqInBlk' by issuing  <<reshape long>>  command
note: ....then issue <<drop if `tz' == .>> without losing any allocations
}
*****



*************************************************************
*****If allocation ratio not 1:1, fix up treatment names*****
*************************************************************
quietly {
if (`numt' - `ntreat' == 1) {recode `tz' 3=2}
if (`numt' - `ntreat' == 2) {recode `tz' 3=2 4=2}
}


label val `tz' treat


*************************************************************


*************************************************************
*****reshape to wide if specified****************************
*************************************************************

order StratID `bz' `sz' Seq `tz'
keep StratID `bz' `sz' Seq `tz'

qui reshape wide `tz', i(`bz') j(SeqInBlk)
order StratID `bz' `sz'
if ("`shape'" == "wide") {
qui reshape wide
order StratID `bz' `sz'
}
else {
qui reshape long
qui drop if `tz'==.
lab var `tz' treatment
order StratID `bz' `sz' Seq `tz'
}

*************************************************************
*************************************************************



*************************************************************
**** Assign value labels to treatment************************
*************************************************************
if "`factor'" != "" {
label define treat 1 "`tr1lab'" 2 "`tr2lab'" 3 "`tr3lab'" 4 "`tr4lab'"
if "`factor'" == "2*3" | "`factor'" == "3*2"  {
label define treat 5 "`tr5lab'", modify
}
if "`factor'" == "3*3" | "`factor'" == "2*4" | "`factor'" == "4*2" {
label define treat 5 "`tr5lab'" 6 "`tr6lab'" , modify
}
if "`factor'" == "4*3" | "`factor'" == "3*4"  {
label define treat 5 "`tr5lab'" 6 "`tr6lab'" 7 "`tr7lab'" , modify
}
}
else {
if `ntreat' == 5 {
lab def treat 1 "`tr1lab'" 2 "`tr2lab'" 3 "`tr3lab'" 4 "`tr4lab'" 5 "`tr5lab'"
}
if `ntreat' == 4 {
label define treat 1 "`tr1lab'" 2 "`tr2lab'" 3 "`tr3lab'" 4 "`tr4lab'"
}
if `ntreat' == 3 {
label define treat 1 "`tr1lab'" 2 "`tr2lab'" 3 "`tr3lab'"
}
if `ntreat' == 2 {
label define treat 1 "`tr1lab'" 2 "`tr2lab'"
}
}
*************************************************************

*************************************************************
**** Assign 2nd treatment in a factorial design *************
*************************************************************

qui {
if ("`factor'" != ""  | "`xover'" != "") {
gen `tz'1 = .
gen `tz'2 = .
}

if ("`xover'" == "switch" | "`xover'" == "extra") {
gen `tz'3 = .
}

if "`factor'" != "" {
if "`factor'" == "2*2" {
 if "`fratio'" == "1 1" {
replace `tz'1 = 1 if `tz'==1 | `tz' ==2
replace `tz'1 = 2 if `tz'==3 | `tz' ==4
replace `tz'2 = 3 if `tz'==1 | `tz' ==3
replace `tz'2 = 4 if `tz'==2 | `tz' ==4
 }
 if "`fratio'" == "2 1" {
replace `tz'1 = 1 if `tz'==1 | `tz' ==2
replace `tz'1 = 2 if `tz'==3 | `tz' ==4
replace `tz'1 = 2 if `tz'==5 | `tz' ==6
replace `tz'2 = 3 if `tz'==1 | `tz' ==3 | `tz' ==5
replace `tz'2 = 4 if `tz'==2 | `tz' ==4 | `tz'==6
 }
 if "`fratio'" == "1 2" {
replace `tz'1 = 1 if `tz'==1 | `tz' ==2 | `tz' ==3
replace `tz'1 = 2 if `tz'==4 | `tz' ==5 | `tz' ==6
replace `tz'2 = 3 if `tz'==1 | `tz' ==4
replace `tz'2 = 4 if `tz'==2 | `tz' ==5
replace `tz'2 = 4 if `tz'==3 | `tz' ==6
}
 if "`fratio'" == "2 2" {
replace `tz'1 = 1 if `tz'==1 | `tz' ==2 | `tz' ==3
replace `tz'1 = 2 if `tz'>=4 & `tz' <=9
replace `tz'2 = 3 if `tz'==1 | `tz' ==4 | `tz' ==7
replace `tz'2 = 4 if `tz'==2 | `tz' ==5 | `tz' ==8
replace `tz'2 = 4 if `tz'==3 | `tz' ==6 | `tz' ==9
 }
}

if "`factor'" == "2*3" {
replace `tz'1 = 1 if `tz'==1 | `tz' ==2 | `tz' ==3
replace `tz'1 = 2 if `tz'==4 | `tz' ==5 | `tz' ==6
replace `tz'2 = 3 if `tz'==1 | `tz' ==4
replace `tz'2 = 4 if `tz'==2 | `tz' ==5
replace `tz'2 = 5 if `tz'==3 | `tz' ==6
}

if "`factor'" == "3*2" {
replace `tz'1 = 1 if `tz'==1 | `tz' ==2
replace `tz'1 = 2 if `tz'==3 | `tz' ==4
replace `tz'1 = 3 if `tz'==5 | `tz' ==6
replace `tz'2 = 4 if `tz'==1 | `tz' ==3 | `tz' ==5
replace `tz'2 = 5 if `tz'==2 | `tz' ==4 | `tz'==6
}


if "`factor'" == "3*3" {
replace `tz'1 = 1 if `tz'==1 | `tz' ==2 | `tz' ==3
replace `tz'1 = 2 if `tz'==4 | `tz' ==5 | `tz' ==6
replace `tz'1 = 3 if `tz'==7 | `tz' ==8 | `tz' ==9
replace `tz'2 = 4 if `tz'==1 | `tz' ==4 | `tz' ==7
replace `tz'2 = 5 if `tz'==2 | `tz' ==5 | `tz' ==8
replace `tz'2 = 6 if `tz'==3 | `tz' ==6 | `tz' ==9
}


if "`factor'" == "2*4" {
replace `tz'1 = 1 if `tz'==1 | `tz' ==2 | `tz' ==3 | `tz' ==4
replace `tz'1 = 2 if `tz'==5 | `tz' ==6 | `tz' ==7 | `tz' ==8
replace `tz'2 = 3 if `tz'==1 | `tz' ==5
replace `tz'2 = 4 if `tz'==2 | `tz' ==6
replace `tz'2 = 5 if `tz'==3 | `tz' ==7
replace `tz'2 = 6 if `tz'==4 | `tz' ==8
}


if "`factor'" == "4*2" {
replace `tz'1 = 1 if `tz'==1 | `tz' ==2
replace `tz'1 = 2 if `tz'==3 | `tz' ==4
replace `tz'1 = 3 if `tz'==5 | `tz' ==6
replace `tz'1 = 4 if `tz'==7 | `tz' ==8
replace `tz'2 = 5 if `tz'==1 | `tz' ==3 | `tz' ==5 | `tz' ==7
replace `tz'2 = 6 if `tz'==2 | `tz' ==4 | `tz'==6  | `tz' ==8
}


if "`factor'" == "3*4" {
replace `tz'1 = 1 if `tz'==1 | `tz' ==2 | `tz' ==3 | `tz' ==4
replace `tz'1 = 2 if `tz'==5 | `tz' ==6 | `tz' ==7 | `tz' ==8
replace `tz'1 = 3 if `tz'==9 | `tz' ==10 | `tz' ==11 | `tz' ==12
replace `tz'2 = 4 if `tz'==1 | `tz' ==5 | `tz' ==9
replace `tz'2 = 5 if `tz'==2 | `tz' ==6 | `tz' ==10
replace `tz'2 = 6 if `tz'==3 | `tz' ==7 | `tz' ==11
replace `tz'2 = 7 if `tz'==4 | `tz' ==8 | `tz' ==12
}


if "`factor'" == "4*3" {
replace `tz'1 = 1 if `tz'==1 | `tz' ==2 | `tz' ==3
replace `tz'1 = 2 if `tz'==4 | `tz' ==5 | `tz' ==6
replace `tz'1 = 3 if `tz'==7 | `tz' ==8 | `tz' ==9
replace `tz'1 = 4 if `tz'==10 | `tz' ==11 | `tz' ==12
replace `tz'2 = 5 if `tz'==1 | `tz' ==4 | `tz' ==7 | `tz' ==10
replace `tz'2 = 6 if `tz'==2 | `tz' ==5 | `tz' ==8 | `tz' ==11
replace `tz'2 = 7 if `tz'==3 | `tz' ==6 | `tz' ==9 | `tz' ==12
}
} / *end if factor present */

if "`xover'" != "" {
replace `tz'1 = 1 if `tz' == 1
replace `tz'2 = 2 if `tz' == 1
replace `tz'1 = 2 if `tz' == 2
replace `tz'2 = 1 if `tz' == 2
 if "`xover'" == "switch" {
 replace `tz'3 = `tz'1
 }
 if "`xover'" == "extra" {
 replace `tz'3 = `tz'2
 }
} /* end xover */


if "`factor'" != "" {
lab val `tz'1 treat
lab val `tz'2 treat
}

if "`xover'" != "" {
lab var `tz'1 "treatment in period 1"
lab var `tz'2 "treatment in period 2"
lab val `tz'1 treat
lab val `tz'2 treat
if "`xover'" == "extra" | "`xover'" == "switch" {
lab var `tz'3 "treatment in period 3"
lab val `tz'3 treat
 }
}


if ("`factor'" != ""  | "`xover'" != "") {
drop `tz'       /* drop original treatment variable */
}

} / *end quietly */
*************************************************************



*************************************************************
*****saving routines*****************************************
*************************************************************

if `strata' > 1 {
label data "all strata combined"

****************************************
*** regenerate stratifications vars*****
****************************************

if "`using'" != "" {
local p=1
while `p' < `vcount' {
local this: word `p' of `allvar'
qui gen `this' = .
local hh =1
while `hh' <= `strata' {
qui replace `this' = `mystrat'[`hh',`p'] if StratID == `hh'
local hh = `hh' + 1
} /* end hh */
local p=`p'+1
} /* end while  p */
tempname G
matrix `G' = `mystrat'[1,1..`vcount'-1]
local cnam1: colnames(`G')
mat drop `G'
} /* end if using */

} /* end if strata */



order StratID `cnam1'
qui save `saving', replace
di " "
if `strata' > 1 {
di "Allocations over all strata saved to file " in wh "`saving'"
}
else {
di "Allocations saved to file " in wh "`saving'"
}
di " "

if "`multif'" != ""  & `strata' > 1 {

qui {
local hh = 1
while `hh' <= `strata' {
preserve
keep if StratID == `hh'
label data "data for stratum `hh'"
notes drop _dta in 7/l
note: See notes for parent file '`saving'.dta'

note: This is stratum `hh' of `strata' strata requested

if "`using'" != "" {
local p=1

while `p' < `vcount' {
local this: word `p' of `allvar'


local m = `mystrat'[`hh',`p']
note: ...level `m' of stratum variable -`this'-"
local p=`p'+1
} /* end while  p */

} /* end using */


*****
if "`shape'" == "wide" {
note: Data saved to wide form:
note: ...recover 'SeqInBlk' by issuing  <<reshape long>>  command
note: ...then you may issue <<drop if `tz' == .>> without*/
*/ losing any allocations
}
*****


label data "allocations for stratum `hh'"
tempname F
local k=1
local sfn "`saving'"


/*
if "`using'" != "" {
matrix `G' = `mystrat'[1,1..`vcount'-1]

local cnam1: colnames(`G')
mat drop `G'
}  /* end using */
*/



while `k' < `vcount' {
local S "Z_Q_a"
matrix `F' = `mystrat'[.,`k'..`k']
local currsiz = _N
local nobs = max(`strata', `currsiz')
qui set obs `nobs'
svmat `F', names(`S')
qui summ `S'1
local L = length(string(r(max)))
drop `S'1
local cp1=`currsiz'+1
capture drop in `cp1'/l
local mac = `mystrat'[`hh',`k']
local M = length(string(`mac'))
local D = `L' - `M'
local cc=1

while `cc' <= `D' {
local mac = "0`mac'"
local cc=`cc'+1
}  /* end while cc */

local sfn  = "`sfn'_`mac'"
local k = `k'+1
}  /* end while k */

mat drop `F'
order StratID `cnam1'
noi di "....saving data from stratum " in w "`hh'" in y/*
*/ " to file " in w "`sfn'"
quietly capture save `sfn', replace

*************************************************************

restore
local hh = `hh' + 1
} /* end while hh */
}
di " "
di "Data file " in w "`saving'" in y " (all allocations) is now in memory"
di "Issue the " in w "-notes-" in y " command to review your specifications"
} /* end if multif" */

qui {
if "`factor'" != "" | "`xover'" != "" {
reshape clear
}
}

mat drop `mystrat'
set matsize 40
exit
end

*! -ralloc- version 3.7.6   Philip Ryan  January 28 2018
*! random allocation in blocks
* since STB-50:
* optionally stratify;
* optionally use 2x2, 2x3, ...., 3x4, 4x3 factorial designs;
* specify 1:2 ratio in 2, 1 or neither axis of a 2x2 factorial trial;
* 2x2 crossover design with or without switchback or last Rx carried forward
* since STB-54:
* fixed delimiting errors in lines 150 (3.2.4)
* allows 5 treatments (3.2.4)
* allows current date to be specified as the seed (3.2.5)
* automatically writes ralloc version number to notes (3.2.5)
* optionally create unique study ID (3.3)
* save full command syntax as a note (3.3)
* tolerate extra spaces between numeric arguments (3.3)
* extra error traps (3.3)
* smcl help file (3.3)
* fix minor treatment labelling bugs (3.3)
* fix treatment label output in notes after Stata Release 10 (3.3.1)
* allow 6 treatments (3.3.2)
* allow 10 treatments (3.3.3)
* allow 2*2*2 factorial design (3.4.0)
* allow 2*2*3 factorial design and extra examples in help file(3.4.1)
* allow 2*3*3 and 3*3*3 factorial designs and extra examples in help file(3.4.2)
* allow 4*4 factorial design and new error traps for labels  (3.4.3)
* syntax changes: use of args; exit with error code; drop -clear- with exit; use inlist/inrange (3.5.0)
* auto detect Stata flavour; delete matsiz option (3.5.0) 
* allow treatment labels to have 12 (was 8) characters (3.5.1)
* bug fix for flavor detection (3.5.2)
* fix saving() and using() filename specs by adding compound double quotes (3.6.1)
* unabbreviate var names in case a user has -set varabbrev off- as part of their usual Stata environment (3.6.2)
* correct irritating feral punctuation chars in certain of the notes (3.6.2)
* add option for stratum labels; trap strata with 0 counts specified (3.7.4)
* fix filename suffix when using() option is specified (3.7.6)
* update old display directives [in <colour>} to modern [as <style>] form. eg "in yellow" to "as result" (3.7.6)

* 
*!
*!  Syntax:
*!    ralloc <Block ID varname > <Block Size varname> <Treatment varname stub>,
*!         saving(filename1) 
*!         [  multif|nomultif    seed(#|"date")
*!            nsubj(int 100)     ntreat(2|3|4|5|6|7|8|9|10)
*!            ratio(1|2|3)       osize(1|2|3|4|5|6|7)
*!            init(#)            equal|noequal
*!            strata(#)          stratlab(label1 label2 ...)   
*!            using(filename2)   vallab|novallab
*!            countv(varname)    tables|notables
*!            trtlab(label1 [label2] .....)
*!            factor(2*2|2*3|3*2|3*3|2*4|4*2|3*4|4*3|4*4|2*2*2|2*2*3|2*3*3|3*3*3)
*!            fratio(1 1|2 1|1 2|2 2)
*!            xover(stand|switch|extra)
*!            shape(long|wide)   idvar(string) ]
*!
*!    ralloc ?

***********************************************************************
********************** begin program ralloc.ado ***********************
***********************************************************************

program define ralloc

version 9

local versn "3.7.6"

if "`1'" == "?" {
      which ralloc
      exit
}



clear
set more 1
syntax newvarlist(gen min=3 max=3) , SAVing(string)                   ///
                                   [ MULTIF         SEed(string)      ///
                                     NSubj(int 100) NTreat(string)    ///
                                     RAtio(string)  OSize(int 5)      ///
                                     INIT(int 0)    EQual             ///
                                     STRATa(int 1)  STRATLAb(string)  ///
									 USing(string)  VALLAB            ///
                                     COUNTv(string) TRTLAB(string)    ///
                                     TABles         FACTor(string)    ///
                                     FRAtio(string) XOVer(string)     ///
                                     TR1lab(string) TR2lab(string)    ///
                                     TR3lab(string) TR4lab(string)    ///
                                     SHAPe(string)  IDVAR(string) ]




**** 1 = BlockID         2 = BlockSize         3 = Treat



tokenize `varlist'
args  bz  sz  tz  
local ntmax = 10
local flav `=cond(`c(MP)',"MP",cond(`c(SE)',"SE","IC"))'

* set trace on

*************************************************************
*****Check for some errors in syntax*************************
*************************************************************

if `nsubj' <=0 {
di as error "number of subjects specified must be greater than 0"
exit=499
}

if !inlist("`xover'", "" , "stand" , "switch" , "extra")  {
di as result "xover" as error " must be 'stand', 'switch' or 'extra'"
exit = 499
}


if "`factor'" != "" & "`xover'" != "" {
di as error "cannot specify both factor() and xover()"
exit=499
}

if "`factor'" !="" & length("`3'") > 31 {
di as error "<Treatmentvar> must be 31 characters or less in a factorial design"
exit=499
}


if "`factor'" != "" {
 if "`ntreat'" != "" {
 di as error "do not specify ntreat() in a factorial design"
 exit=499
 }
}
else {
 if "`ntreat'" == "" {
  local ntreat = 2
 }
 else {
  if (inrange(`ntreat',1,`ntmax')) {
   local ntreat = `ntreat'
  }
  else {
    di as error "number of treatments given by ntreat() must be no more than " as result "`ntmax'"
        exit=499
  }
 }
}

if "`xover'" != "" {
 if `ntreat' !=2 {
di as error "number of treatments must be 2 for a crossover design"
exit=499
 }
}


if "`flav'" == "IC" {
 if !inrange(`strata', 1, 800) {
 di as error "For Stata I/C the number of strata specified must not exceed 800"
 exit=499
}
}
else {
 if !inrange(`strata', 1, 11000) {
 di as error "For Stata S/E or M/P the number of strata specified must not exceed 11,000"
 exit=499
}
}

if "`factor'" != "" { 
local factor = subinstr("`factor'"," ","",.)
 if "`factor'" != "2*2" & "`factor'" != "2*3" & "`factor'" != "3*2"   ///
  & "`factor'" != "3*3" & "`factor'" != "2*4" & "`factor'" != "4*2"   ///
  & "`factor'" != "3*4" & "`factor'" != "4*3"  & "`factor'" != "4*4"  ///  
  & "`factor'" != "2*2*2"  & "`factor'" != "2*2*3"                    ///
  & "`factor'" != "2*3*3"  & "`factor'" != "3*3*3" {
di as error "factorial design must be specified as 2*2, 2*3, 3*2, 3*3, "  ///
         "2*4, 4*2, 3*4, 4*3, 4*4, 2*2*2, 2*2*3, 2*3*3 or 3*3*3"
exit=499
}
}


if (("`factor'" == "")|("`factor'" != "2*2")) & ("`fratio'" != "") {
di as error "fratio() may only be specified for a 2x2 factorial design"
exit=499
}


if "`fratio'" != "" {
 if wordcount("`fratio'") != 2 { 
di as error "fratio() must have two numeric arguments"
exit=499 
}
 
tokenize `fratio'
args  frat1  frat2
  if (("`frat1'" !="1" & "`frat1'" !="2" ) | ("`frat2'" !="1" & "`frat2'" !="2" )) {
di as error "if specified, arguments of fratio must be (1 1), (1 2), (2 1), or (2 2)"
exit=499
}
}

if "`factor'" == "2*2" & "`fratio'" == "" {
local fratio "1 1"
}

if "`factor'" != "" {
local rx_num = 2 + length(trim("`factor'")) > 3
local combo = 1
local maxtlab = 0
tokenize `factor', parse("*")

forvalues i = 1(2)`=length(trim("`factor'"))' {
local rx`i'fac = real("``i''")

local combo = `combo'*`rx`i'fac'
local maxtlab = `maxtlab' + `rx`i'fac'
}
local ntreat = `combo'
}
else {
local maxtlab = `ntreat'
}


if "`fratio'" != "" {
tokenize `fratio'
args frat1  frat2
local rx1fac = `rx1fac' + (`frat1' - 1)
local rx2fac = `rx3fac' + (`frat2' - 1)
local ntreat = `rx1fac'*`rx2fac'
local tfactor "`rx1fac'*`rx2fac'"
}


*******

if ("`factor'" != "" | "`xover'" != "") & "`ratio'" != "" {
dis as error "do not specify ratio() for a factorial or crossover design"
exit=499
}


if ("`factor'" != ""  | "`xover'" != "") & "`shape'" == "wide" {
dis as error "shape of data must be long for factorial or crossover design"
exit=499
}


if !inrange(`osize', 1,7) {
display as error "The number of different block sizes (" as result "osize" as error ") must be 1, 2, 3, 4, 5, 6 or 7"
exit=499
}

if ("`shape'" =="") {
local shape = "long"
}
else {
 if ("`shape'" != "long" & "`shape'" != "wide") {
di as error "-shape- must be either " as result "wide " as err "or " as result "long"
exit=499
}
}

if  !inlist("`ratio'", "", "1" , "2" , "3")  {
di as error "ratio() must be unspecified or specified as 1, 2, or 3"
exit=499
}

if "`ratio'" == "" {
local ratio = 1
}
else {
local ratio = `ratio'
}

if (`ratio' != 1) {
 if (`ntreat' != 2){
  display as error "The number of treatments must be 2 if" as result " ratio " as error "> 1 is specified"
  exit=499
  }
 if (`ratio' != 2) & (`ratio' != 3){
  display as error "ratio must be 2 or 3"
  exit=499
 }
}

if `init'==0 {
 local init = (`ntreat'+(`ratio'==2)+(2*(`ratio'==3)))
}

if "`factor'" == "" {
 if mod(`init',(`ntreat'+(`ratio'==2)+(2*(`ratio'==3)))) != 0 {
 display as error "The " as result "init" as error "iating block size"         ///
              " must be a multiple of the number of treatments,"
 display as error "or, in the case of a " as result "ratio " as            ///
                err "> 1 specified for a 2 treatment trial, a"
 display as error "multiple of (" as result "ratio " as error "+ 1)."
 exit=499
 }
}


if "`factor'" != "" {
 if "`fratio'" == "1 1" | "`fratio'" == "" {
  if mod(`init',`ntreat') != 0 {
  display as error "For a factorial design with balanced allocation, the "
  display as result "init" as error "iating block size must be a multiple of the number"
  display as error "of treatment combinations"
  exit=499
  }
 }
 else {
  if mod(`init',((`frat1'+1)*(`frat2'+1)) ) != 0 {
  display as error "For a factorial design with unbalanced allocation, the "
  display as result "init" as error "iating block size must be a multiple of:
  display as error "((1st arg of " as result "fratio" as error ") + 1) x ((2nd arg of " ///
                  as result "fratio" as error ") + 1)"
  exit=499
  }
 }
}  
/* end if factor */



if "`countv'" != ""  & "`using'" == "" {
di as error "You must specify a filename in -using()- if -countv()- is specified"
exit=499
}

if "`countv'" =="" & "`using'" != "" {
di as error "You must specify the name of the count variable in file  -`using'-"
di as error " using the option  -countv()-"
exit=499
}

if "`using'" != "" & "`stratlab'" != "" {
di as error "You may not specify stratum labels in option <stratlab> if a <using> file is specified"
exit=499
}

** &&&
if "`stratlab'" !="" & "`vallab'" != "" {
* di "stratum labels are `stratlab'"
qui capture assert `strata' == `: word count `stratlab''
if _rc !=0 {
di as error "number of stratum labels must equal number of strata"
exit=499
}
}

if "`stratlab'" == "" & "`vallab'" != "" & "`using'" == "" {
di _new as text "no stratum value labels are specified in either option " as result "stratlab" as text " or in a " as result "using" ///
as text " file: option " as result "vallab" as text " will be ignored"
}

if "`stratlab'" !="" & "`vallab'" == "" {
di _new as text "stratum value labels specified in option " as result "stratlab" as text " will be ignored as option " ///
as result "vallab" as text " was not specified"
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
noi di as error "Warning: non-integer seed will be truncated to integer"
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

* take care of old style labels for first four treatments****
* and add on extras******************************************

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
 local tr8lab = "H"
 local tr9lab = "I"
 local tr10lab = "J"
}
**************************************************************

if "`trtlab'" != "" {
local ntlab: word count `trtlab'

if `ntlab' > `maxtlab' {
di as error "Max of `maxtlab' treatment labels may be specified for this design"
exit=499
}

*** make default labels

local strlab "ABCDEFGHIJKLMNOP"
local i = 1
while `i' <= `ntmax' {
local tr`i'lab = substr("`strlab'",`i',1)
local i= `i' + 1
}

*** overwrite defaults with any labels specified

local d=1
while `d' <= `ntlab' {
local tr`d'lab: word `d' of `trtlab'
local tr`d'lab = substr("`tr`d'lab'",1,12)
local d = `d'+1
}
}
*************************************************************

local matdef `=cond(("`flav'" == "MP" | "`flav'"=="SE"), 400 , 200)'

* di "matdef is `matdef' and max is `c(max_matsize)'"

*************************************************************
*****Set up matrix that holds info about stratification******
************case of no using file specified******************
*************************************************************

tempname mystrat A


if"`using'" == "" {

di " "
qui set matsize `= max(`c(min_matsize)',`strata')'
local c = 1
matrix def `mystrat' = [`c',`nsubj']
local vcount = 2
local c = 2
while `c' <= `strata' {
mat `A' = (`c',`nsubj')
matrix `mystrat' = `mystrat' \ `A'
local c = `c' + 1
}  
/* end while */


}  
/* end if using =="" */
***************************




*************************************************************
*****Set up matrix that holds info about stratification******
************case of using file specified*********************
*************************************************************


if "`using'" != "" {
 if `nsubj' == 100 {
di " "
di as text "Counts defined in variable " as result "`countv'" as text " in file " as result "`using'" 
di as text "will override the" as text " default number of subjects, n = 100"
}

if `nsubj' != 100 {
di " "
di as text "Counts defined in variable " as result "`countv'" as text " in file " as result "`using'"
di as text "will override the number of subjects specified in option " as result "nsubj(`nsubj')" 
}

preserve  /* keeps BlockID BlockSiz and Trt vars in dummy 1st obs */
use `"`using'"'
tempname USL
qui describe
local strata = r(N)
qui capture conf v `countv'
if _rc != 0 {
di as error "Your specified count variable -`countv'- is not in file -`using'-"
restore
clear
exit=499
}

qui capture assert (`countv' >= 1) & ((`countv' -int(`countv'))   < 0.000000001 )
if _rc != 0 {
di _new as error "all values of " as text "`countv'" as error " in the stratum definition file " as text "`using'" as error " must be positive integers (1 and above)"
restore
clear
exit=499
}

local strat_sing_plural "strata"
if `strata' == 1 {
local strat_sing_plural "stratum"
}


di _new  as result "`strata' " as text "`strat_sing_plural'" as text " read from file " as result "`using'" 



/*
qui summ `countv'
if r(min) < 1 {
di as error "all specified stratum allocations must exceed 0"
exit=499
}
*/

qui set matsize `= max(`c(min_matsize)',`strata')'


**********
*make sure countv() variable will be in final column of matrix
**********


qui {
tempvar tempc tempj
gen `tempc' = `countv'
drop `countv'
ren `tempc' `countv'
}

unab allvar: _all
local vcount: word count `allvar'
local nstvars = `vcount' - 1
di " "
di as text "number of stratum variables is " as result "`nstvars'"
di " "

tokenize `allvar'

gen str5 `tempj' = ""

local a = 1
local b = 1


while `a' <= `nstvars' {

replace `tempj' = `tempj'+ string(``a'')
*****

di as text "stratum variable " as result `a' as text " is " as result "``a''"
local str_ass : type ``a''
capture assert substr("`str_ass'",1,3) != "str"
if _rc != 0 {
di as error "stratum variable ``a'' is string, not numeric!"
restore
clear
exit=999
}
summ ``a'', meanonly
local numin`a' = r(max)
local min`a' = r(min)
if abs(`min`a'' - 1) > 0.000001 {
di as error "levels of stratum variable -``a''- do not begin at 1"
restore
clear
exit=499
}
qui tab ``a''
local lev`a' = r(r)
if  abs(`lev`a'' - `numin`a'') > 0.000001 {
di as error "levels of stratum var ``a'' do not progress by integer increments"
restore
clear
exit=499
}
*********
di as text "number of levels in " as result "``a''" as text " is " as result "`numin`a''"
di " "
local b=`b'*(`numin`a'')

*******************
*fix value labels
*******************

if "`using'" !="" & "`vallab'" != "" {
* di "stratum vars + countv var are `allvar'"
* macro list
local stratval : list local(allvar) - local(countv)
* di "stratum vars - countv var are `stratval'" 
local vlv : value label ``a''
if "`vlv'" == "" {
local vspec ""
local vlv "_``a''_lab"
forvalues c = 1/`=`numin`a''' {
local vspec `vspec' `c' "`c'"
}
lab def `vlv'  `vspec'
lab val ``a'' `vlv'
}

*di as text "value label for variable ``a'' is `vlv'"
qui label save `vlv' using `USL'`a' , replace
local allvlv  `allvlv'  `vlv'
*di "allvlv is `allvlv'"
* type `USL'`a'.do
}
*******************

                             
local a=`a'+1
} 


/* end while*/

**
* li
qui tab `tempj'
* di "r(r) = " r(r)
* di " number of strata is "`strata'
if r(r) != `strata' {
di as error "Strata defined in using file " as result "`using'" as error " are not unique"
di "number of strata is " as result "`strata'" as error "; number of unique strata is " as result "`r(r)'"
restore
clear
exit=499
}
**


if  abs((`strata') - (`b')) > 0.00001 {
di as text "Caution: " as text "number of rows (strata) in using file (" as result "`strata'" as text ") does not match the product of levels"
di as text "over all stratum variables (" as result "`b'" as text "). You may wish to check completeness of stratum specifications."
*restore
*clear
*exit=499
}


sort `allvar'
mkmat `allvar', matrix(`mystrat')
di _new as text "the stratum design and allocation numbers are:"
mat li `mystrat', noheader
local ncolm = colsof(`mystrat')
local cnn ""
forvalues i= 1/`ncolm' {
local cnn = "`cnn'"+ " c`i'"
}

matrix colnames `mystrat' = `cnn'

tempvar sumcv
qui gen `sumcv' = sum(`countv')
local reqsubj = `sumcv'[_N]

di " "
restore
unab orig: _all
tokenize `orig'  /* puts orig vars from ralstrat back in posit macros */


}   


                          
/* end if using() */

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
    replace `sz' = (`numt'*(`i'-1)) + `init' if                 ///
                 `propn' >`low' & `propn' <= `high' & `touse' ==1
  replace `low'=`high'  if `touse' ==1
  local i=`i'+1
  }
  replace `sz'= (`numt'*(`osize'-1))+`init'                    ///
                if `propn' >=`low' & `propn' <=256 & `touse'
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

** &&&
if "`stratlab'" != ""  & "`vallab'" != "" {
forvalues k = 1/`strata' {
label define stratlabel `k' "`: word `k' of `stratlab''", add
}
label values StratID stratlabel
}
** &&&

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
gettoken my_cmd :0
note: command issued was: ralloc `0'
*****

*****
note: Randomisation schema created on TS using ralloc.ado version `versn' in Stata version ///
 `c(stata_version)' born `c(born_date)'
*****

*****
note: Seed used = `seed'
*****

*****
if "`using'" != "" {
note: Stratum definitions and numbers of allocations were defined /*
*/in file '`using''
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

if `ntreat' == 10 {
note: Treatments are labelled:  '`tr1lab''   '`tr2lab''  '`tr3lab''    '`tr4lab'' ///   
 '`tr5lab''    '`tr6lab''   '`tr7lab''  '`tr8lab''  '`tr9lab''  '`tr10lab''
}

if `ntreat' == 9 & "`factor'" == "" {
note: Treatments are labelled:  '`tr1lab''   '`tr2lab''  '`tr3lab''    '`tr4lab'' ///  
 '`tr5lab''    '`tr6lab''   '`tr7lab''  '`tr8lab''  '`tr9lab''
}

if `ntreat' == 8 & "`factor'" == "" {
note: Treatments are labelled:  '`tr1lab''   '`tr2lab''   /// 
 '`tr3lab''    '`tr4lab''    '`tr5lab''    '`tr6lab''   '`tr7lab''  '`tr8lab''
}


if `ntreat' == 7 & "`factor'" == "" {
note: Treatments are labelled:  '`tr1lab''   '`tr2lab''  ///
 '`tr3lab''    '`tr4lab''    '`tr5lab''    '`tr6lab''    '`tr7lab''
}

if `ntreat' == 6 & "`factor'" == "" {
note: Treatments are labelled:  '`tr1lab''   '`tr2lab'' /// 
 '`tr3lab''    '`tr4lab''    '`tr5lab''    '`tr6lab''
}

if `ntreat' == 5 {
note: Treatments are labelled:  '`tr1lab''   '`tr2lab''  ///
 '`tr3lab''    '`tr4lab''    '`tr5lab''
}

if `ntreat' == 4 & "`factor'" == "" {
note: Treatments are labelled:  '`tr1lab''   '`tr2lab''  /// 
 '`tr3lab''    '`tr4lab''
}



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
  `tr4lab'' for the first factor;
note: Treatments are labelled:  '`tr5lab'' &  '`tr6lab''
 for the second factor;
};

if "`factor'" == "2*4" {;
note: Treatments are labelled:  '`tr1lab'' &  '`tr2lab'' for
 the first factor;
note: Treatments are labelled:  '`tr3lab'' &  '`tr4lab'' &
  `tr5lab'' &  '`tr6lab'' for the second factor;
};

if "`factor'" == "4*3" {;
note: Treatments are labelled:  '`tr1lab'' &  '`tr2lab'' &  '`tr3lab'' &
  `tr4lab'' for the first factor;
note: Treatments are labelled:  '`tr5lab'' &  '`tr6lab'' &  '`tr7lab''
 for the second factor;
};

if "`factor'" == "3*4" {;
note: Treatments are labelled:  '`tr1lab'' &  '`tr2lab'' &  '`tr3lab''
 for the first factor;
note: Treatments are labelled:  '`tr4lab'' &  '`tr5lab'' &
  `tr6lab'' &  '`tr7lab'' for the second factor;
};

if "`factor'" == "4*4" {;
note: Treatments are labelled:  '`tr1lab'' &  '`tr2lab'' &  '`tr3lab'' &
 '`tr4lab'' for the first factor;
note: Treatments are labelled:  '`tr5lab'' &  '`tr6lab'' &
  `tr7lab'' &  '`tr8lab'' for the second factor;
};

if "`factor'" == "2*2*2" {;
note: Treatments are labelled:  '`tr1lab'' &  '`tr2lab''
 for the first factor;
note: Treatments are labelled:  '`tr3lab'' &  '`tr4lab'' 
 for the second factor;
note: Treatments are labelled:  '`tr5lab'' &  '`tr6lab'' 
 for the third factor;
};

if "`factor'" == "2*2*3" {;
note: Treatments are labelled:  '`tr1lab'' &  '`tr2lab''
 for the first factor;
note: Treatments are labelled:  '`tr3lab'' &  '`tr4lab'' 
 for the second factor;
note: Treatments are labelled:  '`tr5lab'' &  '`tr6lab''  &  '`tr7lab'' 
 for the third factor;
};


if "`factor'" == "2*3*3" {;
note: Treatments are labelled:  '`tr1lab'' &  '`tr2lab''
 for the first factor;
note: Treatments are labelled:  '`tr3lab'' &  '`tr4lab'' & '`tr5lab'' 
 for the second factor;
note: Treatments are labelled:  '`tr6lab'' &  '`tr7lab'' & '`tr8lab'' 
 for the third factor;
};

if "`factor'" == "3*3*3" {;
note: Treatments are labelled:  '`tr1lab'' &  '`tr2lab'' &  '`tr3lab''
 for the first factor;
note: Treatments are labelled:  '`tr4lab'' &  '`tr5lab'' &  '`tr6lab'' 
 for the second factor;
note: Treatments are labelled:  '`tr7lab'' &  '`tr8lab'' &  '`tr9lab'' 
 for the third factor;
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
note: `extra' extra allocations were provided to  ///
         maintain integrity of final block in each stratum
}
*****


*****
summ `sz', meanonly
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
 note: Block sizes were allocated proportional to  ///
        elements of Pascal's triangle
}
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
if (`numt' - `ntreat' == 1) {
recode `tz' 3=2
}
if (`numt' - `ntreat' == 2) {
recode `tz' 3=2 4=2
}
}


label val `tz' treat

*************************************************************
*****making Study ID ****************************************
*************************************************************
if "`idvar'" != "" {
local n_rnd = _N
tempvar _svorig _sv2 r_len
gen long `_svorig' = _n
gen double `_sv2'= uniform()
sort `_sv2'
local k = length("`n_rnd'") + 1
gen str`k' `idvar' = string(`n_rnd' + round(sqrt(`n_rnd'),1)+_n)
isid `idvar'
lab var `idvar' "unique subject identifier"
gen int `r_len' = length(`idvar')
sort `r_len'
local r_max = `r_len'[_N]
qui count
forvalues i = 1/`r(N)' {
local diff = `r_max' - `r_len'[`i']
while `diff' > 0 {
qui replace `idvar' =  "0" + `idvar' in `i' 
local diff = `diff'-1 
}
}
sort `_svorig'
if "`shape'" == "wide" {
local stub "(stub)"
}
note: unique study subject identifier is variable `stub' '`idvar''

order `idvar'
} 
/* end making Study ID */
**************************************************************
*************************************************************

*************************************************************
*****reshape to wide if specified****************************
*************************************************************

order StratID `bz' `sz' SeqInBlk `tz'*
* li `idvar' StratID `bz' `sz' SeqInBlk `tz'* in 1/10
keep `idvar' StratID `bz' `sz' SeqInBlk `tz'* `stvname'
qui reshape wide  `idvar' `tz'*, i(`bz') j(SeqInBlk)
order StratID `stvname' `bz' `sz'
if ("`shape'" == "wide") {
qui reshape wide
order StratID `stvname' `bz' `sz'
* li StratID `stvname' `bz' `sz' in 1/10
if "`idvar'" != "" {
forvalues k = 1/`osmaxp' {
move `idvar'`k'  `tz'`k'
}
}
}
else {
qui reshape long
qui drop if `tz' ==.
* lab var `tz' treatment
order `idvar' StratID `stvname' `bz' `sz' SeqInBlk `tz'*
}

*************************************************************
*************************************************************




*************************************************************
**** Assign value labels to treatment************************
*************************************************************
if "`factor'" != "" {
label define treat 1 "`tr1lab'" 2 "`tr2lab'" 3 "`tr3lab'" 4 "`tr4lab'"
if  inlist("`factor'", "2*3", "3*2")  {
label define treat 5 "`tr5lab'", modify
}
if inlist("`factor'", "3*3", "2*4", "4*2", "2*2*2") {
label define treat 5 "`tr5lab'" 6 "`tr6lab'" , modify
}
if inlist("`factor'","4*3", "3*4", "2*2*3")  {
label define treat 5 "`tr5lab'" 6 "`tr6lab'" 7 "`tr7lab'" , modify
}
if inlist("`factor'", "4*4", "2*3*3")  {
label define treat 5 "`tr5lab'" 6 "`tr6lab'" 7 "`tr7lab'" 8 "`tr8lab'" , modify
}
if "`factor'" == "3*3*3"  {
label define treat 5 "`tr5lab'" 6 "`tr6lab'" 7 "`tr7lab'" 8 "`tr8lab'" 9 "`tr9lab'" , modify
}
}

else {
forvalues i = 1/`ntreat' {
lab def treat `i' "`tr`i'lab'", modify add
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


*set trace on 


if ("`xover'" == "switch" | "`xover'" == "extra" | "`factor'" == "2*2*2" |    ///
"`factor'" == "2*2*3" | "`factor'" == "2*3*3" | "`factor'" == "3*3*3"   ) { 
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

if "`factor'" == "4*4" {
replace `tz'1 = 1 if inrange(`tz', 1, 4)
replace `tz'1 = 2 if inrange(`tz', 5, 8)
replace `tz'1 = 3 if inrange(`tz', 9, 12)
replace `tz'1 = 4 if inrange(`tz', 13, 16)
replace `tz'2 = 5 if inlist(`tz',1,5,9,13)
replace `tz'2 = 6 if inlist(`tz',2,6,10,14)
replace `tz'2 = 7 if inlist(`tz',3,7,11,15)
replace `tz'2 = 8 if inlist(`tz',4,8,12,16)
}

if "`factor'" == "2*2*2" {
replace `tz'1 = 1 if `tz' == 1 | `tz' ==2 |`tz'==3 |`tz' ==4
replace `tz'1 = 2 if `tz' == 5 | `tz' ==6 |`tz'==7 |`tz' ==8
replace `tz'2 = 3 if `tz' == 1 | `tz' ==2 |`tz'==5 |`tz' ==6
replace `tz'2 = 4 if `tz' == 3 | `tz' ==4 |`tz'==7 |`tz' ==8
replace `tz'3 = 5 if `tz' == 1 | `tz' ==3 |`tz'==5 |`tz' ==7
replace `tz'3 = 6 if `tz' == 2 | `tz' ==4 |`tz'==6 |`tz' ==8
}

if "`factor'" == "2*2*3" {
replace `tz'1 = 1 if `tz' == 1 | `tz' ==2 |`tz'==3 |`tz' ==4 |`tz'==5 |`tz' ==6
replace `tz'1 = 2 if `tz' == 7 | `tz' ==8 |`tz'==9 |`tz' ==10 |`tz'==11 |`tz' ==12
replace `tz'2 = 3 if `tz' == 1 | `tz' ==2 |`tz'==3 |`tz' ==7 |`tz'==8 |`tz' ==9
replace `tz'2 = 4 if `tz' == 4 | `tz' ==5 |`tz'==6 |`tz' ==10 |`tz'==11 |`tz' ==12
replace `tz'3 = 5 if `tz' == 1 | `tz' ==4 |`tz'==7 |`tz' ==10
replace `tz'3 = 6 if `tz' == 2 | `tz' ==5 |`tz'==8 |`tz' ==11
replace `tz'3 = 7 if `tz' == 3 | `tz' ==6 |`tz'==9 |`tz' ==12
}

if "`factor'" == "2*3*3" {
replace `tz'1 = 1 if inrange(`tz', 1, 9)
replace `tz'1 = 2 if inrange(`tz', 10, 18)
replace `tz'2 = 3 if inlist(`tz',1,2,3,10,11,12)
replace `tz'2 = 4 if inlist(`tz',4,5,6,13,14,15)
replace `tz'2 = 5 if inlist(`tz',7,8,9,16,17,18)
replace `tz'3 = 6 if inlist(`tz',1,4,7,10,13,16)
replace `tz'3 = 7 if inlist(`tz',2,5,8,11,14,17)
replace `tz'3 = 8 if inlist(`tz',3,6,9,12,15,18)
}

if "`factor'" == "3*3*3" {
replace `tz'1 = 1 if inrange(`tz', 1, 9)
replace `tz'1 = 2 if inrange(`tz', 10, 18)
replace `tz'1 = 3 if inrange(`tz', 19, 27)
replace `tz'2 = 4 if inlist(`tz',1,2,3,10,11,12,19,20,21)
replace `tz'2 = 5 if inlist(`tz',4,5,6,13,14,15,22,23,24)
replace `tz'2 = 6 if inlist(`tz',7,8,9,16,17,18,25,26,27)
replace `tz'3 = 7 if inlist(`tz',1,4,7,10,13,16,19,22,25)
replace `tz'3 = 8 if inlist(`tz',2,5,8,11,14,17,20,23,26)
replace `tz'3 = 9 if inlist(`tz',3,6,9,12,15,18,21,24,27)
}

} 
/* end if factor present */

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
} 
/* end xover */


if "`factor'" != "" {
lab val `tz'1 treat
lab val `tz'2 treat
if  inlist("`factor'", "2*2*2" , "2*2*3" , "2*3*3" , "3*3*3")  {
lab val `tz'3 treat
}
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

} 
/* end quietly */
*************************************************************


*************************************************************
*****saving routines*****************************************
*************************************************************

*noi di "saving #2 is `saving'"
local saving :subinstr local saving ".dta" ""
*noi di "saving #3 is `saving'"

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
} 
/* end hh */

local stvname = "`stvname'" + " `:word `p' of `allvar''"
local p=`p'+1
} 


/* end while  p */
tempname G
matrix `G' = `mystrat'[1,1..`vcount'-1]
local cnam1: colnames(`G')
* noi di "colnames are `cnam1'"
mat drop `G'
} 
/* end if using */

} 
/* end if strata */


** order StratID `cnam1'
order StratID


************************************************************
*********fix value labels of stratification variables*******
************************************************************
if "`using'" != "" & "`vallab'" != "" {
forvalues i=1/`=`nstvars'' {
local uvar : word `i' of `stratval'
local ulab : word `i' of `allvlv'
qui do "`USL'`i'.do"
lab val `uvar' `ulab'
}
}
**************************************
**************************************

qui save `"`saving'"', replace


di " "
if `strata' > 1 {
di as text "Allocations over all strata saved to file " as result "`saving'.dta"
}
else {
di as text "Allocations saved to file " as result "`saving'.dta"
}
di " "



if "`multif'" != ""  & `strata' > 1 {

qui {

local hh = 1
while `hh' <= `strata' {
preserve
keep if StratID == `hh'

if "`stratlab'" != "" & "`vallab'" != "" {
local stlab :word `hh' of `stratlab'
local delimst [`stlab']
}

* label data "allocations for stratum `hh' `delimst'"
notes drop _dta in 7/l
note: See notes for parent file '`saving'.dta'

note: This is stratum `hh' of `strata' strata requested
note: This stratum is labelled: `stlab' 

if "`using'" != "" {
local p=1

while `p' < `vcount' {
local this: word `p' of `allvar'


local m = `mystrat'[`hh',`p']
note: ...level `m' of stratum variable -`this'-
local p=`p'+1
} 


/* end while  p */

} 
/* end using */


*****
if "`shape'" == "wide" {
note: Data saved to wide form:
note: ...recover 'SeqInBlk' by issuing  <<reshape long>>  command
note: ...then you may issue <<drop if `tz' == .>> without*/
*/ losing any allocations
}
*****


* label data "allocations for stratum `hh' `delimst'"
tempname F
local k=1
local sfn "`saving'"


* if ("`stratlab'" == "")  | (("`using'" != "") & ("`vallab'" == "" )) {
if "`vallab'" == "" {
while `k' < `vcount' {
local S "Z_Q_a"
matrix `F' = `mystrat'[.,`k'..`k']
* noi mat li `mystrat'
* noi mat li `F'
local currsiz = _N
local nobs = max(`strata', `currsiz')
qui set obs `nobs'
svmat `F', names(`S')
summ `S'1, meanonly
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
}  
/* end while cc */

local sfn  = "`sfn'_`mac'"
local k = `k'+1
}  
/* end while k */
}
else if "`vallab'" != ""  &  "`stratlab'" != "" {
* noi di "sfn is `sfn'"
local sfn = "`sfn'_`: word `hh' of `stratlab''"
* noi di "sfn is `sfn'"
}

*********************************
*********************************
else if "`vallab'" != "" & "`using'" != "" {
local vlf ""
forvalues i = 1/`=`nstvars'' {
* noi di "`:word `i' of `allvlv''"
local vlf `vlf' `: label `:word `i' of `allvlv'' `=`mystrat'[`hh',`i']''
}
local laby = subinstr(trim("`vlf'")," ","_",.)
local sfn = "`sfn'_`laby'"
local delimst [`vlf']
lab def SID_lab `hh' "`vlf'", modify 
lab val StratID SID_lab
local fullSIDlab `fullSIDlab' `hh' "`vlf'"
}
*********************************
*********************************


capture mat drop `F'
order  StratID 
noi di as text "....saving data from stratum " as result "`hh' `delimst'" as text /*
*/ " to file " as result "`sfn'.dta"

if "`shape'" == "wide" {
local stub "(stub)"
}
if "`idvar'" != "" {
note: unique study subject identifier is variable `stub' '`idvar''
}

label data "allocations for stratum `hh' `delimst'"

quietly capture save `"`sfn'"', replace

*************************************************************

restore
local hh = `hh' + 1
} 
/* end while hh */
}
/* end qui */

* di "fullSIDlab is " `"`fullSIDlab'"'

if "`vallab'" != "" & "`using'" != "" {
lab def StratID_lab `fullSIDlab'
lab val StratID StratID_lab
qui save `"`saving'"', replace
}

noi di " "
noi di as text "Data file " as result "`saving'.dta" as text " (all allocations) is now in memory"
noi di as text "Issue the " as result "-notes-" as text " command to review your specifications"
} 
/* end if multif" */

qui {
if "`factor'" != "" | "`xover'" != "" {
reshape clear
}
}

mat drop `mystrat'
qui set matsize `matdef'
qui capture erase "`USL'.do"
exit=0
end


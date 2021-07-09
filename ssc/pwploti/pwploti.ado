*! version 1.1.1 ZWANG & Jan Brogger 05dec2000
*! version 1.1.0 ZWANG 14may1999
* version 1.0.0 ZWANG 7may1999
program define pwploti, nclass
version 6.0
gettoken m1 0 : 0, parse(", ")
capture confirm number `m1'
if _rc!=0 {
  di in g "syntax: "  
  # delimit ;
    di in w "pwploti #1_mean or proportion, d" in g "list" in w "(numlist) nf" 
    in g "rom" in w "(#) nt" in g "o" in w "(#) i" in g "nc" in w "(#)" 
    in g " [" in w "l" in g "ist " in w "sa" in g "ving" in w "(graph_file) " 
    in g "sampsi_opts graph_opts]" ;
  exit;
};
  syntax [, NFrom(real 10) NTo(real 20) Inc(real 1) Dlist(numlist) 
  List Yline(numlist) Symbol(string) XLAB(str) YLAB(str) B2(str) B1(str) KEY(str)
  XLine(string) SAving(string)  *]; 
# delimit cr
local num=int((`nto'-`nfrom')/`inc'+1) 
cap as "`dlist'"!=""
if _rc==9 {
    di in g "Define difference list: " in w "dlist"
  exit
}  
token "`dlist'"
local i=0
while "`1'"!="" {
  local i=`i'+1
  mac shift
}

local kp=0  /* indicator of using -keyplot- */
capture which keyplot 
if _rc!=0 | `i'<=4 | `i'>10 {local kp=1}
if _rc!=0 & ((`i'>4 & `i'<=10) | "`key'"~="" ) {
  di in r "If need  more than 4 labels or key specified.
  di in r "Please install -keyplot- by Nick Cox"
  di in g "from: " in w "http://ideas.uqam.ca/ideas/data/bocbocode.html" 
}
preserve
clear
qui{
  set obs `num'
  token "`dlist'"
  local gr=1
  gen N=.
  gen N2=.
  capture assert `nfrom'>0 
  if _rc!=0 {
    noi di in r "Number can not be zero, change 'from' option."
    exit
  }
  while "`1'"!=""{
    gen D_`gr'=. 
    local i=1
    local start=`nfrom'
    local end=`nto' 
    while `start'<=`end'{
      local m2 = `m1'+ `1'
      sampsi `m1' `m2', n(`start') `options'
      replace D_`gr'=r(power) if `i'==_n
      lab var D_`gr' "D=`1'"
      replace N=r(N_1) if `i'==_n
      replace N2=r(N_2) if `i'==_n
      local start=`start' + `inc'
      local i = `i'+1
    }
    mac shift
    local gr=`gr'+1 
    local connect "l`connect'"
  } 
  format D_* %6.2f
  local yline1 "yline(`yline')"
  if "`yline'"=="" {local yline1=""}
  gen M1=`m1'
}
if "`list'"!=""{
  di
  di in g _col(10) "Powers by sample size and difference"
  list N* D_*, noob
}
if "`ylab'"==""{local ylab1 "ylab(0,.2,.4,.6,.8,1)"}
else local ylab1 "ylab(`ylab')"
if "`xlab'"==""{local xlab1 "xlab"}
else local xlab1 "xlab(`xlab')"
if "`symbol'"!=""{local symb1 "s(`symbol')"}
if "`xline'"!="" {local xline1 "xline(`xline')"}

if "`b1'"=="" {
	local subt1 "Power vs Sample size by" 
	local subt2 "differences between two groups"
	local b1 "b1(`subt1' `subt2')"
}
else {
	local b1 "b1(`b1')"
}

if "`b2'"~="" { local b2 "b2("`b2'")" }

if "`saving'" != "" {local saving "saving(`saving')" }

capture which keyplot 
if _rc !=0 | `kp'==1 {
    gr D_* N, c(`connect') `xlab1' `ylab1' `yline1' `symb1' /*
  */`xline1' `b1' `b2' l2("Power (1-beta)") gap(6) `saving' 
}

if `kp'==0 { 
  if "`key'"~="" { local key "key(`key')" }
  keyplot D_* N, c(`connect') `xlab1' `ylab1'  `yline1'   /*
  */ `symb1' `xline1' `b1' `b2' l2("Power (1-beta)") gap(6) `key' `saving'
end




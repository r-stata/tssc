* 1.1 29 May 2012
program tryem
version 7.0

syntax varlist  [if] [in] , k(integer) [cmd(string) stat(string) best(string) cmdoptions(string)]
if "`cmd'"=="" {
   local cmd "reg"
   }
if "`stat'"=="" {
   local stat "r2"
   }

if "`best'"!="min" {
   local best "max"
   }


tokenize `varlist'
local n1: word count `varlist'
local n=`n1'-1
//di "n =  `n';    k = `k'"
local y: word 1 of `varlist'
local vlist " "
forv j=2(1)`n1'{
local a:  word `j' of `varlist'
local vlist `vlist' `a'
}

//di "dep. var = `y'"
//di "indepvars = `vlist'  "
scalar maxstat=-1.0e305
scalar minstat= .
local lkf=-1
while `lkf' <1  {
mktime `n' `k' `lkf'
if scalar(kf)< 1 {


   local i=0
   local xvec=" "
   while `i' < `k' {
   local i=`i'+1
   local li=L[1,`i']+1
   local xvec="`xvec'" + " "+"``li''"
   }
  qui  `cmd' `1' `xvec' `if' `in' ,`cmdoptions'

/*-------------------------- update maximum -------*/
   local update=0
   if "`best'"=="max" & e(`stat') > scalar(maxstat) {
   scalar maxstat=e(`stat')
   local update=1
   }
   if "`best'"=="min" & e(`stat') < scalar(minstat) {
   scalar minstat=e(`stat')
   local update=1
   }
   if `update'==1 {
   matrix M1=J(1,1,0)
   matrix M1[1,1]=e(`stat')
   matrix M = L
   local mvec="`xvec'"
   }
*/ -----------------------------------------------*/

}
   local lkf=scalar(kf)
}
   di in yellow " --------------------------------------------"
   di " "
   if "`best'"=="max" {
      di " Largest `stat' is ", %10.5g scalar(maxstat) ".  Best subset of size `k' is: "
   }
   if "`best'"=="min" {
      di " Smallest `stat' is ", %10.5g scalar(minstat) ".  Best subset of size `k' is: "
   }



   di " "
   di " `mvec'"
   di " "
   di " Variable numbers for best subset are:
   matrix list M,nonames nohead format(%4.0f)
   di " --------------------------------------------"
   qui  `cmd' `1' `mvec' `if' `in' ,`cmdoptions'
   end

program mktime
version 8.0
args n k kf
scal kf=`kf'

if scalar(kf)==1 {
exit
}

if scalar(kf) < 0  {
matrix L = J(1,`2',0)
local i=0
   while `i' < `k' {
   local i=`i'+1
   matrix L[1,`i']=`i'
   }
scal kf=0
exit 
 }

if  L[1,1] == `n'-`k'+1 {
   scal kf=1
   exit
 }

if  L[1,`k']<`n' {
    matrix L[1,`k']= L[1,`k']+1
   exit
 }


   local i=`k'
   while `i' > 1 {
   local i = `i'-1
      if  L[1,`i'] < `n'-`k'+`i'  {
          matrix L[1,`i'] =  L[1,`i']+1
          local j = `i'
            while `j' < `k'  {
            local j=`j'+1
            matrix L[1,`j']= L[1,`j'-1]+1
            }
   local i = 1  /* stop the i-loop  */   
      }



      }
      
      exit
}
end


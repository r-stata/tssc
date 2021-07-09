program define probcalc
*!Calculates binomial, Poisson, and normal probabilities
/*
Date: 9/21/11  
Author: Leif Peterson, TMHRI, Houston 

Format:
probcalc typedist param1 param2 param3 param4 param5

Stata Version 11																																																																																																																																																																																																																																																													 
*/

version 11
set trace off
set more off
args typedist param1 param2 param3 param4 param5

if "`typedist'"=="N" |  "`typedist'"=="n" {  //normal
  local dist="normal"
  local mean=`param1'
  local sigma=`param2'
  local calculate="`param3'"
   if "`param4'"!=""{  
    local xl=`param4'
  }
  if "`param5'"!=""{  
    local xu=`param5'
  }
  di "Distribution: Normal"
  di "mean:" "`mean'"
  di "s.d.:" "`sigma'"
  di "option:" "`calculate'"
  if "`param4'"!=""{  
    di "x=" "`xl'"
  }
  if "`param5'"!=""{  
    di "`xu'"
  }
} 
if "`typedist'"=="B" | "`typedist'"=="b" {  //binomial
  local dist="binom"
  local n=`param1'
  local p=`param2'
  local calculate="`param3'"
  if "`param4'"!=""{  
    local x=`param4'
  }
  di "Distribution: Binomial"
  di "n=" "`n'"
  di "p= " "`p'"
  di "option:" "`calculate'"
  if "`param4'"!=""{  
    di "x=" "`x'"
  }
} 
if "`typedist'"=="P" |  "`typedist'"=="p" {  //binomial
  local dist="poisson"
  local mu=`param1'
  local calculate="`param2'"
  if "`param3'"!=""{   
    local x=`param3'
  }
  di "Distribution: Poisson"
  di "mu=" "`mu'"
  di "option:" "`calculate'"
  if "`param3'"!=""{   
    di "x=" "`x'"
  }
} 

 //*****NORMAL********
if "`dist'"=="normal" {
  //local calculate="P(X<=x)"  //at most  
  //local calculate="P(X>=x)"  //at least
  //local calculate="P(X=x)"   //exactly, e.g., P(X=5)

  if "`calculate'"=="between"{
   	local zl=(`xl'-`mean')/`sigma'
    local zu=(`xu'-`mean')/`sigma'
    local cumprobl=normal(`zl')
    local cumprobu=normal(`zu')
    di " "  
    di "cdf Method: P(" `xl'  "<=X<"  `xu' ")=" `cumprobu' - `cumprobl'  
    di " "  
  }
  if "`calculate'"=="dist"{
   	local xl= `mean' - 4 * `sigma'
    local xu= `mean' + 4 * `sigma'
   	local zl=-4
    local zu=4
	local delta=( `zu'-`zl' )/30
    forv k=1(1)30{
	  local currz= `zl' + ( `k' -1) * `delta'
      local prob=normalden(`currz')
      if `prob'>0.01{
	     local x= `currz' * `sigma' + `mean'
	     di "P(X=" round(`x',0.1) ")=" `prob'
      }
    }
  }
  if "`calculate'"=="atmost"{
    local z=(`xl'-`mean')/`sigma'
    local cumprob=normal(`z')
    di " "  
    di "cdf Method: P(X<=" `xl' ")=" `cumprob'  
    di " "  
   }
  if "`calculate'"=="atleast"{
    local cumprob=0
    local z=(`xl'-`mean')/`sigma'
    local cumprob=normal(`z')
    di " "  
    di "cdf Method: P(X>=" `xl' ")=" 1 - `cumprob'  
    di " "  
  }
}

 //*****BINOMIAL********
if "`dist'"=="binom" {
  //local calculate="P(X<=x)"  //at most  
  //local calculate="P(X>=x)"  //at least
  //local calculate="P(X=x)"   //exactly, e.g., P(X=5)
  if "`calculate'"=="exactly"{
    local prob=binomialp(`n',`x',`p')
    di "P(X=" `x' ")=" `prob'
  }
  if "`calculate'"=="dist"{
    local kstart=0
    local kstop=`n'
    forv k=`kstart'(1)`kstop'{
      local prob=binomialp(`n',`k',`p')
      if `prob'>0.01{
	     di "P(X=" `k' ")=" `prob'
      }
    }
  }
  if "`calculate'"=="atmost"{
    local cumprob=0
    local kstart=0
    local kstop=`x'
    forv k=`kstart'(1)`kstop'{
      local prob=binomialp(`n',`k',`p')
      local cumprob = `cumprob' + `prob'
      di "P(X=" `k' ")=" `prob'
    }
    di " "  
    di "pmf Method 1: P(X<=" `x' ")=" `cumprob'  
    di " "  
    local cumprob=binomial(`n',`x',`p')
    di " "  
    di "cdf Method 2: P(X<=" `x' ")=" `cumprob'  
    di " "  
  }
  if "`calculate'"=="atleast"{
    local cumprob=0
    local kstart=`x'
    local kstop=`n'
    forv k=`kstart'(1)`kstop'{
      local prob=binomialp(`n',`k',`p')
      local cumprob = `cumprob' + `prob'
      di "P(X=" `k' ")=" `prob'
    }
    di " "  
    di "pmf Method 1: P(X>=" `x' ")=" `cumprob'  
    di " "  
    local cumprob=binomial(`n',`x'-1,`p')
    di " "  
    di "cdf Method 2: P(X>=" `x' ")=" 1 - `cumprob'  
    di " "  
  }
}
 
//*****POISSON********
if "`dist'"=="poisson" {
//local calculate="P(X<=x)"  //at most  
//local calculate="P(X>=x)"  //at least
//local calculate="P(X=x)"   //exactly, e.g., P(X=5)

  if "`calculate'"=="exactly"{
    local prob=poissonp(`mu',`x')
    di "P(X=" `x' ")=" `prob'
  }
  if "`calculate'"=="dist"{
    local kstart=0
    local kstop=`mu'*5
    forv k=`kstart'(1)`kstop'{
      local prob=poissonp(`mu',`k')
      if `prob'>0.01{
	  	  di "P(X=" `k' ")=" `prob'
      }
	}
  }
  if "`calculate'"=="atmost"{
    local cumprob=0
    local kstart=0
    local kstop=`x'
    forv k=`kstart'(1)`kstop'{
      local prob=poissonp(`mu',`k')
      local cumprob = `cumprob' + `prob'
      di "P(X=" `k' ")=" `prob'
    }
    di " "  
    di "pmf Method 1: P(X<=" `x' ")=" `cumprob'  
    di " "  
    local cumprob=poisson(`mu',`x')
    di " "  
    di "cdf Method 2: P(X<=" `x' ")=" `cumprob'  
    di " "  
  }
  if "`calculate'"=="atleast"{
    di "Note: For Poisson ''at least'' questions, the sum of the lower tail pmf's is subtracted from one.  "
	di "So only variates less than x are reported below."
    local cumprob=0
    local kstart=0
    local kstop=`x'-1
    forv k=`kstart'(1)`kstop'{
      local prob=poissonp(`mu',`k')
      local cumprob = `cumprob' + `prob'
      di "P(X=" `k' ")=" `prob'
    }
    di " "  
    di "pmf Method 1: P(X>=" `x' ")=" 1 - `cumprob'  
    di " "  
    local cumprob=poisson(`mu',`x'-1)
    di " "  
    di "cdf Method 2: P(X>=" `x' ")=" 1 - `cumprob'  
    di " "  
  }
}
 

end
 
 

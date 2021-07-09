capture program drop mkonfound
program define mkonfound
version 13.1
syntax varlist, [if] [in] [ sig(real 0.05) nu(real 0) onetail(real 0) rep_0(real 0) esti_(real 0) z_tran(real 0)]


local obst: word 1 of `varlist'
local df: word 2 of `varlist'

tempvar r_obs criticalt r_crit itcv r_con nr_con


if `onetail'==1 {
gen `r_obs'= `obst'/sqrt((`obst')^2+`df'-1)
gen `criticalt' =sign(`r_obs') *  invttail(`df',`sig')
gen `r_crit' = `criticalt'/sqrt((`criticalt')^2+`df'-1)

if `nu'==0 {

quietly  gen `itcv' = (`r_obs' - `r_crit')/(1-`r_crit')
quietly  replace `itcv' = (`r_obs' - `r_crit')/(1 +`r_crit')  if (`r_obs' - `r_crit') < 0
  
 gen `r_con' = round(sqrt(abs(`itcv')),.001)
 gen `nr_con' = -1 * `r_con'
 quietly gen itcv_=`itcv'
 quietly gen r_cv_y = `r_con'
quietly gen r_cv_x = `r_con'
quietly replace r_cv_x = `nr_con' if `itcv' < 0
quietly gen stat_sig_ = 1
quietly replace stat_sig_ = 0 if abs(`r_obs') < abs(`r_crit')

}

else {
tempvar crit_z z_obs z_nu thres_z thres_r
  gen `crit_z' =sign(`r_obs'-`nu') *  invttail(10000,`sig')
  gen `z_nu' = 0.5*(ln(1+`nu')-ln(1-`nu'))
  gen `z_obs' = 0.5*(ln(1+`r_obs')-ln(1-`r_obs'))
  gen `thres_z' = (1/sqrt(`df'-1) * `crit_z') + `z_nu'
  gen `thres_r' = (exp(2*`thres_z')-1)/(exp(2*`thres_z')+1)
quietly  gen `itcv' = (`r_obs' - `thres_r')/(1-`thres_r')
quietly  replace `itcv' = (`r_obs' - `thres_r')/(1 +`thres_r')  if (`r_obs' - `thres_r') < 0

 gen `r_con' = round(sqrt(abs(`itcv')),.001)
 gen `nr_con' = -1 * `r_con'
  quietly gen itcv_=`itcv'
 quietly gen r_cv_y = `r_con'
quietly gen r_cv_x = `r_con'
quietly replace r_cv_x = `nr_con' if `itcv' < 0
quietly gen stat_sig_ = 1
quietly replace stat_sig_ = 0 if abs((`z_obs'-`z_nu')*sqrt(`df'-1)) < abs(`crit_z')
}

}

else {
gen `r_obs'= `obst'/sqrt((`obst')^2+`df'-1)
gen `criticalt' =sign(`r_obs') *  invttail(`df',`sig'/2)
gen `r_crit' = `criticalt'/sqrt((`criticalt')^2+`df'-1)

if `nu'==0 {

quietly  gen `itcv' = (`r_obs' - `r_crit')/(1-`r_crit')
quietly  replace `itcv' = (`r_obs' - `r_crit')/(1 +`r_crit')  if (`r_obs' - `r_crit') < 0
  
 gen `r_con' = round(sqrt(abs(`itcv')),.001)
 gen `nr_con' = -1 * `r_con'
 quietly gen itcv_=`itcv'
 quietly gen r_cv_y = `r_con'
quietly gen r_cv_x = `r_con'
quietly replace r_cv_x = `nr_con' if `itcv' < 0
quietly gen stat_sig_ = 1
quietly replace stat_sig_ = 0 if abs(`r_obs') < abs(`r_crit')

}

else {
tempvar crit_z z_obs z_nu thres_z thres_r
  gen `crit_z' =sign(`r_obs'-`nu') *  invttail(10000,`sig'/2)
  gen `z_nu' = 0.5*(ln(1+`nu')-ln(1-`nu'))
  gen `z_obs' = 0.5*(ln(1+`r_obs')-ln(1-`r_obs'))
  gen `thres_z' = (1/sqrt(`df'-1) * `crit_z') + `z_nu'
  gen `thres_r' = (exp(2*`thres_z')-1)/(exp(2*`thres_z')+1)
  
quietly  gen `itcv' = (`r_obs' - `thres_r')/(1-`thres_r')
quietly  replace `itcv' = (`r_obs' - `thres_r')/(1 +`thres_r')  if (`r_obs' - `thres_r') < 0

 gen `r_con' = round(sqrt(abs(`itcv')),.001)
 gen `nr_con' = -1 * `r_con'
  quietly gen itcv_=`itcv'
 quietly gen r_cv_y = `r_con'
quietly gen r_cv_x = `r_con'
quietly replace r_cv_x = `nr_con' if `itcv' < 0
quietly gen stat_sig_ = 1
quietly replace stat_sig_ = 0 if abs((`z_obs'-`z_nu')*sqrt(`df'-1)) < abs(`crit_z')
}


}




if `esti_'==1 {
local coef: word 1 of `varlist'
local sd: word 2 of `varlist'
local N: word 3 of `varlist'
local Ncov: word 4 of `varlist'

tempvar criticalt threshold bias sustain

if `onetail'==1 {
gen `criticalt' =sign(`coef' - `nu') *  invttail(`N'-`Ncov'-1,`sig')
gen `threshold' = `criticalt' * `sd'
  if `rep_0'==1 {
  gen `bias' = round(100*(1- ((`threshold'+`nu')/`coef')),.01)
  }
  else {
  gen `bias' = round(100*(1- (`threshold'/(`coef'-`nu'))),.01)
  }
    gen `sustain' = round(100*(1- ((`coef')/((`threshold'+`nu')))),.01)
	replace `sustain' = round(100*(1- ((`threshold'+`nu')/(`coef'))),.01) if abs(`coef') > abs(`threshold'+`nu')
  
gen valid_ = (abs(`coef' - `nu')- abs(`threshold'))
gen percent_replace=`bias'
replace percent_replace =. if  valid_ < 0
gen percent_sustain = `sustain'
replace percent_sustain =. if  valid_ > 0
  drop valid_ 
  
}

else {
  gen `criticalt' = sign(`coef' - `nu') * invttail(`N'-`Ncov'-1,`sig'/2)
  gen `threshold' = `criticalt' * `sd'
  if `rep_0'==1 {
  gen `bias' = round(100*(1- ((`threshold'+`nu')/`coef')),.01)
  }
  else {
  gen `bias' = round(100*(1- (`threshold'/(`coef'-`nu'))),.01)
  }
  gen `sustain' = round(100*(1- ((`coef')/(`threshold'+(`nu')))),.01)
  replace `sustain' = round(100*(1- ((`threshold'+`nu')/(`coef'))),.01) if abs(`coef') > abs(`threshold'+`nu')
  
gen valid_ = (abs(`coef' - `nu')- abs(`threshold'))  
gen percent_replace=`bias'
replace percent_replace =. if  valid_ < 0
gen percent_sustain = `sustain'
replace percent_sustain =. if  valid_ > 0
 drop valid_ 
  
  
  }
}
if `esti_'==0 { 
  
local obst: word 1 of `varlist'
local df: word 2 of `varlist'


tempvar obsr criticalt threshold bias sustain bias2 sustain2

if `onetail'==1 {
gen `obsr'= `obst'/sqrt(`obst'^2+`df')
gen `criticalt' =sign(`obsr'-`nu') *  invttail(`df',`sig')
gen `threshold' = `criticalt'/sqrt(`criticalt'^2+`df')
  
  if `nu'==0 {
  
  gen `bias' = round(100*(1- ((`threshold')/`obsr')),.01)
  
      gen `sustain' = round(100*(1- ((`obsr')/((`threshold'+`nu')))),.01)
  replace `sustain' = round(100*(1- ((`threshold'+`nu')/(`obsr'))),.01) if abs(`obsr') > abs(`threshold'+`nu')
gen valid_ = (abs(`obsr' - `nu')- abs(`threshold')) 
gen percent_replace=`bias'
replace percent_replace =. if  valid_ <0
gen percent_sustain = `sustain'
replace percent_sustain =. if  valid_ >0
 drop valid_ 
  }
  
  else {
  if `rep_0'==1 {
  gen `bias2' = round(100*(1- ((`threshold'+`nu')/`obsr')),.01)
  }
  else {
  gen `bias2' = round(100*(1- (`threshold'/(`obsr'-`nu'))),.01)
  }
  gen `sustain2' = round(100*(1- ((`obsr')/(`threshold'+(`nu')))),.01)
  replace `sustain2' = round(100*(1- ((`threshold'+`nu')/(`obsr'))),.01) if abs(`obsr') > abs(`threshold'+`nu')
gen valid_2 = (abs(`obsr' - `nu')- abs(`threshold')) 
gen percent_replace=`bias2'
replace percent_replace =. if  valid_2 <0
gen percent_sustain = `sustain2'
replace percent_sustain =. if  valid_2 >0
 drop valid_2 
  
  
  tempvar crit_z thres_z z_nu thres_r thres_z1 z_obs
  gen `crit_z' =sign(`obsr'-`nu') *  invttail(10000,`sig')
  gen `z_nu' = 0.5*(ln(1+`nu')-ln(1-`nu'))
    gen `z_obs' = 0.5*(ln(1+`obsr')-ln(1-`obsr'))
  gen `thres_z1' = 1/sqrt(`df'-1)* `crit_z'
  gen `thres_z' = (1/sqrt(`df'-1) * `crit_z') + `z_nu'
  gen `thres_r' = (exp(2*`thres_z')-1)/(exp(2*`thres_z')+1)
    if `rep_0'==1 {
  gen `bias' = round(100*(1- ((`thres_r')/`obsr')),.01)
  }
  else {
  gen `bias' = round(100*(1- ((`thres_r'-`nu')/(`obsr'-`nu'))),.01)
  }
  
  gen `sustain' = round(100*(1- ((`obsr')/((`thres_r')))),.01)
  replace `sustain' = round(100*(1- ((`thres_r')/(`obsr'))),.01) if abs(`obsr') > abs(`thres_r')
  
  if `z_tran' ==1 {
gen valid_ = (abs(`z_obs'-`z_nu')- abs(`thres_z1'))  
gen percent_replace_z=`bias'
replace percent_replace_z =. if  valid_ <0
gen percent_sustain_z = `sustain'
replace percent_sustain_z =. if  valid_ >0
    drop valid_ 
	}
  }
  
 
  
}

else {
gen `obsr'= `obst'/sqrt(`obst'^2+`df')
  gen `criticalt' = sign(`obsr' - `nu') * invttail(`df',`sig'/2)
  gen `threshold' = `criticalt'/sqrt(`criticalt'^2+`df')
  
  
  if `nu'==0 {
  
  gen `bias' = round(100*(1- ((`threshold')/`obsr')),.01)
  
      gen `sustain' = round(100*(1- ((`obsr')/((`threshold'+`nu')))),.01)
  replace `sustain' = round(100*(1- ((`threshold'+`nu')/(`obsr'))),.01) if abs(`obsr') > abs(`threshold'+`nu')
gen valid_ = (abs(`obsr' - `nu')- abs(`threshold')) 
gen percent_replace=`bias'
replace percent_replace =. if  valid_ <0
gen percent_sustain = `sustain'
replace percent_sustain =. if  valid_ >0
 drop valid_ 
  }
  else {
    if `rep_0'==1 {
  gen `bias2' = round(100*(1- ((`threshold'+`nu')/`obsr')),.01)
  }
  else {
  gen `bias2' = round(100*(1- (`threshold'/(`obsr'-`nu'))),.01)
  }
  gen `sustain2' = round(100*(1- ((`obsr')/(`threshold'+(`nu')))),.01)
  replace `sustain2' = round(100*(1- ((`threshold'+`nu')/(`obsr'))),.01) if abs(`obsr') > abs(`threshold'+`nu')
gen valid_2 = (abs(`obsr' - `nu')- abs(`threshold')) 
gen percent_replace=`bias2'
replace percent_replace =. if  valid_2 <0
gen percent_sustain = `sustain2'
replace percent_sustain =. if  valid_2 >0
 drop valid_2 
 
  tempvar crit_z thres_z z_nu thres_r z_obs thres_z1
  gen `crit_z' =sign(`obsr'-`nu') *  invttail(10000,`sig'/2)
  gen `z_nu' = 0.5*(ln(1+`nu')-ln(1-`nu'))
  gen `z_obs' = 0.5*(ln(1+`obsr')-ln(1-`obsr'))
  gen `thres_z1' = 1/sqrt(`df'-1)* `crit_z'
  gen `thres_z' = 1/sqrt(`df'-1)* `crit_z' + `z_nu'
  gen `thres_r' = (exp(2*`thres_z')-1)/(exp(2*`thres_z')+1)
    if `rep_0'==1 {
  gen `bias' = round(100*(1- ((`thres_r')/`obsr')),.01)
  }
  else {
  gen `bias' = round(100*(1- ((`thres_r'-`nu')/(`obsr'-`nu'))),.01)
  }
  
  gen `sustain' = round(100*(1- ((`obsr')/((`thres_r')))),.01)
  replace `sustain' = round(100*(1- ((`thres_r')/(`obsr'))),.01) if abs(`obsr') > abs(`thres_r')
  
  if `z_tran' ==1 {
  
gen valid_ = (abs(`z_obs'-`z_nu')- abs(`thres_z1')) 
gen percent_replace_z=`bias'
replace percent_replace_z =. if  valid_ <0
gen percent_sustain_z = `sustain'
replace percent_sustain_z =. if  valid_ >0
    drop valid_ 
	}
  } 
  
  }
  }
  
  end




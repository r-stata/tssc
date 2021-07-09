capture program drop kernel
*! version 1.0 21jul14 F. Chavez Juarez 
program define kernel , rclass 
version 9.2
syntax varlist(min=1 max=1) [if] [in], Value(real) Bw(real) [Out(string) Type(string)]
marksample touse

tempvar z kernel

// COMPUTE THE VALUE OF Z
gen `z' = (`varlist'-`value')/`bw'


// Compute the kernel itself
gen `kernel' = 0 if `touse'
quietly{
if(inlist("`type'","normal","gaussian")){
	local kname="Normal"
	replace `kernel' = normalden(`z') if `touse'
}
else if("`type'"=="triangle"){
	local kname="Triangle"
	replace `kernel' = 1-abs(`z') if abs(`z')<=1 & `touse'
	local max = 1
}
else if("`type'"=="beta"){
	local kname="Beta"
	replace `kernel' = 0.75*(1-`z')*(1+`z') if abs(`z')<=1 & `touse'
	local max = 1
}
else if("`type'"=="logit"){
	local kname="Logit"
	tempvar logit
	gen `logit' = exp(`z')/(1+exp(`z')) if `touse'
	replace `kernel' = `logit'*(1-`logit') if `touse'
}
else if("`type'"=="uniform"){
	local kname="Uniform"
	replace `kernel' = 0.5 if abs(`z')<=1  & `touse'
	local max = 1
}
else if("`type'"=="cosine"){
	local kname="Cosine"
	replace `kernel' = 1+cos(2*_pi*`z') if abs(`z')<=0.5 & `touse'
	local max = 0.5
}
else if("`type'"=="parzen"){
	local kname="Parzen"
	replace `kernel' = 4/3-8*`z'^2+8*abs(`z')^3 if abs(`z')<=0.5 & `touse'
	replace `kernel' = 8/3*(1-abs(`z'))^3 if inrange(abs(`z'),0.5,1) & `touse'
	local max = 1
}
else{
	if("`type'"!=""){
		noisily di as error "Kernel type '`type'' is not supported. I used the epanechnikov kernel instead"
	}
	local type = "epanechnikov"
	local kname="Epanechnikov"
	replace `kernel' = 0.75*(1-0.2*`z'^2)/sqrt(5) if abs(`z')<=sqrt(5) & `touse' // epanechnikov
	local max = sqrt(5)
}

}

// find min/max values
if("`max'"!=""){
	local min = `value'-`max'*`bw'
	local max = `value'+`max'*`bw'
	}
else{
	local min =.
	local max =.
	}

if("`out'"==""){
	local out = "_kernel_`type'"
	}
gen `out' = `kernel'
la var `out' "`kname' kernel of `varlist' around `value'"

// Observations with positive kernel
count if `touse'
local N=r(N)
count if `touse' & `out'>0
local Npos=r(N)
	

// OUTPUT
local colres=20
di as text "Used kernel:" as result _col(`colres') "`kname'"	
di as text "Kernel saved as:" as result  _col(`colres') "`out'"
if(`min'!=. & `max'!=.){
	di as text "Range of kernel:" as result  _col(`colres') "[" %8.0g `min' " | " %8.0g `max' "]"
	}
di as text "Observations:" as result _col(`colres') "`N'"
di as text "Obs. with K(z)>0:" as result _col(`colres') "`Npos'"



// Return values
return scalar min=`min'
return scalar max=`max'
return local kernel `type'
return scalar bw = `bw'




end



// VERSION HISTORY
*! Version 1.0		First release

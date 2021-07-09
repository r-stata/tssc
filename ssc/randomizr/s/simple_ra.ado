****Randomizr Stata Port*************
****Module 0:************************ 
****Simple Random Assignment*********
*************************************
****John Ternovski*******************
****Alex Coppock*********************
****Yale University******************
*************************************
****17sep2017************************
*****version 1.5********************
***john.ternovski@yale.edu***********

program define simple_ra
	version 15
	syntax [namelist(max=1 name=assignment)] [if] [in], [prob(numlist max=1 >=0 <=1)] [prob_each(numlist >=0 <=1)] [num_arms(numlist max=1 >0)] [condition_names(string)] [check_inputs] [replace]

//determine if condition names are strings or numbers
//if strings, then use strings as numbers
//if numbers, use as treatment values
if !missing(`"`condition_names'"') {
	tempname stringparse
	local `stringparse'=subinstr(`"`condition_names'"'," ","",.)
	cap confirm num ``stringparse''
	if _rc {
		local withlabel=1
	}
}

//get condition number
if missing(`"`prob'"') & missing(`"`prob_each'"') & missing(`"`num_arms'"') {
	local num_arms=2
}
if !missing(`"`prob'"') {
	local num_arms=2
}
if !missing(`"`prob_each'"') {
	local num_arms=wordcount(`"`prob_each'"')
}
if !missing(`"`condition_names'"') & missing(`"`num_arms'"') {
	local num_arms=wordcount(`"`condition_names'"')
}
	
//set indexing
if `num_arms'==2 & (!missing(`"`withlabel'"') | missing(`"`condition_names'"')) {
	local index0=1
}

//replace assignment variable and label if replace is specified
if `"`replace'"'!="" {
	cap drop `assignment'
	cap label drop `assignment'
}

//get N
qui count `if' `in'
local N=`r(N)'



//get prob vector
if !missing(`"`prob'"') & missing(`"`prob_each'"') {
	local num_arms = 2
	local prob_miss = 1 - `prob'
	local prob_vector `"`prob_miss' `prob'"'
}

if missing(`"`prob'"') & missing(`"`prob_each'"') {
	local prob_arm = 1/`num_arms'
	forval i=1/`num_arms' {
		local prob_vector `"`prob_vector' `prob_arm'"'
	}
}

if !missing(`"`prob_each'"') {
	local num_arms = wordcount(`"`prob_each'"')
	local prob_vector `prob_each'
}

//setting defaults 
//set default condition names
if missing(`"`assignment'"') { 
	local assignment "assignment"
}

//replace assignment variable and label if replace is specified
if `"`replace'"'!="" {
	cap drop `assignment'
	if _N==0 {
		qui set obs `N'
	}
	cap label drop `assignment'

}

//set up for mata input
tempname p id 
matrix input `p'=(`prob_vector')
gen `id'=_n 
qui putmata `id' `if' `in', replace

//randomize
mata: treat = rdiscrete(strtoreal(st_local("N")),1,st_matrix(st_local("p")))
getmata `assignment'=treat, id(`id') 

//change values to correspond to custom condition_names values
if missing(`"`withlabel'"') & !missing(`"`condition_names'"') {
	tempvar assignment_old
	rename `assignment' `assignment_old'
	qui gen `assignment'=.
	forval i=1/`num_arms' {
		local cname`i' : word `i' of `condition_names'
		qui replace `assignment'=`cname`i'' if `assignment_old'==`i'
	}
}

//reindex if necessary
if `"`index0'"'=="1" {
	qui replace `assignment'=`assignment'-1
}


//label treatment conditions if necessary
if `"`withlabel'"'=="1" {
	tokenize `"`condition_names'"'
	if `"`index0'"'=="1" {
		local start=0
	}
	else {
		local start=1
	}
	label define `assignment' `start' `"`1'"'
	macro shift
	local startplusone=`start'+1
	forval i=`startplusone'/`num_arms' {
		label define `assignment' `i' `"`1'"', add
		macro shift
	}
	label val `assignment' `assignment'
}

end












*Age quod agis

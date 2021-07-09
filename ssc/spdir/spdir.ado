* Creates directed dyad contagion spatial effect variable from a directed dyadic dataset
* 6.0 Eric Neumayer and Thomas Plümper 22may2013

* Change to version 5.0: replaced user-written mmerge.ado commands with Stata's official merge command
* Change to version 4.1: fixed bug that affected row-standardization and spatial effect with additive link functions

program spdir, sortpreserve

version 11.2

syntax varlist(min=1 max=1)[if][in], link(string) Weightvar(name) Source(name) Target(name) ///
		[time(name) EXCLusive ///
		noMerge noRowst SEname(name) FILEname(name) LABELname(name)]
	

if "`link'"=="" {
	di as err "User must specify a link function."
	exit 198
}
if "`link'"=="ik" | "`link'"=="ki" | "`link'"=="jm" | "`link'"=="mj" | "`link'"=="im" | "`link'"=="mi" | "`link'"=="jk" | "`link'"=="kj" | ///
		"`link'"=="ik+ki" | "`link'"=="ki+ik" | "`link'"=="ik*ki" | "`link'"=="ki*ik" | ///
		"`link'"=="ik+im" | "`link'"=="im+ik" | "`link'"=="ik*im" | "`link'"=="im*ik" | ///
		"`link'"=="ik+mi" | "`link'"=="mi+ik" | "`link'"=="ik*mi" | "`link'"=="mi*ik" | ///
		"`link'"=="ik+jm" | "`link'"=="jm+ik" | "`link'"=="ik*jm" | "`link'"=="jm*ik" | ///
		"`link'"=="ik+mj" | "`link'"=="mj+ik" | "`link'"=="ik*mj" | "`link'"=="mj*ik" | ///
		"`link'"=="ik+jk" | "`link'"=="jk+ik" | "`link'"=="ik*jk" | "`link'"=="jk*ik" | ///
		"`link'"=="ik+kj" | "`link'"=="kj+ik" | "`link'"=="ik*kj" | "`link'"=="kj*ik" | ///
		"`link'"=="ki+im" | "`link'"=="im+ki" | "`link'"=="ki*im" | "`link'"=="im*ki" | ///
		"`link'"=="ki+mi" | "`link'"=="mi+ki" | "`link'"=="ki*mi" | "`link'"=="mi*ki" | ///
		"`link'"=="ki+jm" | "`link'"=="jm+ki" | "`link'"=="ki*jm" | "`link'"=="jm*ki" | ///
		"`link'"=="ki+mj" | "`link'"=="mj+ki" | "`link'"=="ki*mj" | "`link'"=="mj*ki" | ///
		"`link'"=="ki+jk" | "`link'"=="jk+ki" | "`link'"=="ki*jk" | "`link'"=="jk*ki" | ///
		"`link'"=="ki+kj" | "`link'"=="kj+ki" | "`link'"=="ki*kj" | "`link'"=="kj*ki" | ///
		"`link'"=="im+mi" | "`link'"=="mi+im" | "`link'"=="im*mi" | "`link'"=="mi*im" | ///
		"`link'"=="im+jm" | "`link'"=="jm+im" | "`link'"=="im*jm" | "`link'"=="jm*im" | ///
		"`link'"=="im+mj" | "`link'"=="mj+im" | "`link'"=="im*mj" | "`link'"=="mj*im" | ///
		"`link'"=="im+jk" | "`link'"=="jk+im" | "`link'"=="im*jk" | "`link'"=="jk*im" | ///
		"`link'"=="im+kj" | "`link'"=="kj+im" | "`link'"=="im*kj" | "`link'"=="kj*im" | ///
		"`link'"=="mi+jm" | "`link'"=="jm+mi" | "`link'"=="mi*jm" | "`link'"=="jm*mi" {
}
else {
	if	"`link'"=="mi+mj" | "`link'"=="mj+mi" | "`link'"=="mi*mj" | "`link'"=="mj*mi" | ///
		"`link'"=="mi+jk" | "`link'"=="jk+mi" | "`link'"=="mi*jk" | "`link'"=="jk*mi" | ///
		"`link'"=="mi+kj" | "`link'"=="kj+mi" | "`link'"=="mi*kj" | "`link'"=="kj*mi" | ///
		"`link'"=="jm+mj" | "`link'"=="mj+jm" | "`link'"=="jm*mj" | "`link'"=="mj*jm" | ///
		"`link'"=="jm+jk" | "`link'"=="jk+jm" | "`link'"=="jm*jk" | "`link'"=="jk*jm" | ///
		"`link'"=="jm+kj" | "`link'"=="kj+jm" | "`link'"=="jm*kj" | "`link'"=="kj*jm" | ///
		"`link'"=="mj+jk" | "`link'"=="jk+mj" | "`link'"=="mj*jk" | "`link'"=="jk*mj" | ///
		"`link'"=="mj+kj" | "`link'"=="kj+mj" | "`link'"=="mj*kj" | "`link'"=="kj*mj" | ///
		"`link'"=="jk+kj" | "`link'"=="kj+jk" | "`link'"=="jk*kj" | "`link'"=="kj*jk" {
	}
	else {
		di as err "Link(`link') not allowed. See help file for allowed link options."
	exit 198
	}
}
	
marksample touse, novarlist strok
tokenize `varlist'
local spatialvar "`1'"
capture confirm numeric "`spatialvar'"
capture confirm numeric "`weightvar'"
quietly su `weightvar'
local W_min=r(min)
if `W_min'<0 {
	di as err _newline "The weighting variable must not contain negative values."
	exit 601
}
local sourcetype : type `source'
local targettype : type `target'
capture confirm numeric "`time'"


di _newline "User has specified that:"
di _newline "   {bf}`spatialvar'{sf} is the variable to be spatially lagged."
di _newline "   {bf}`source'{sf} is the identifying variable of source unit {it}i{sf}."
di _newline "   {bf}`target'{sf} is the identifying variable of target unit {it}j{sf}."

if "`link'"=="ik" {
	di _newline "   {bf}`weightvar'{sf} will link source unit {it}i{sf} to source units {it}k{sf}."
}
if "`link'"=="jm" {
	di _newline "   {bf}`weightvar'{sf} will link target unit {it}j{sf} to target units {it}m{sf}."
}
if "`link'"=="ki" {
	di _newline "   {bf}`weightvar'{sf} will link source units {it}k{sf} to source unit {it}i{sf}."
}
if "`link'"=="mj" {
	di _newline "   {bf}`weightvar'{sf} will link target units {it}m{sf} to target unit {it}j{sf}."
}
if "`link'"=="im" {
	di _newline "   {bf}`weightvar'{sf} will link source unit {it}i{sf} to target units {it}m{sf}."
}
if "`link'"=="mi" {
	di _newline "   {bf}`weightvar'{sf} will link target units {it}m{sf} to source unit {it}i{sf}."
}
if "`link'"=="jk" {
	di _newline "   {bf}`weightvar'{sf} will link target unit {it}j{sf} to source units {it}k{sf}."
}
if "`link'"=="kj" {
	di _newline "   {bf}`weightvar'{sf} will link source units {it}k{sf} to target unit {it}j{sf}."
}

if  "`link'"=="ik+ki" | "`link'"=="ki+ik"  {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of source unit {it}i{sf} to source units {it}k{sf} and link of source units {it}k{sf} to source unit {it}i{sf}."
}
if	"`link'"=="ik+im" | "`link'"=="im+ik"  {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of source unit {it}i{sf} to target units {it}k{sf} and link of source unit {it}i{sf} to target units {it}m{sf}."
}
if	"`link'"=="ik+mi" | "`link'"=="mi+ik"  {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of source unit {it}i{sf} to source units {it}k{sf} and link of target units {it}m{sf} to source unit {it}i{sf}."
}
if	"`link'"=="ik+jm" | "`link'"=="jm+ik"  {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of source unit {it}i{sf} to source units {it}k{sf} and link of target unit {it}j{sf} to target units {it}m{sf}."
}
if	"`link'"=="ik+mj" | "`link'"=="mj+ik"  {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of source unit {it}i{sf} to source units {it}k{sf} and link of target units {it}m{sf} to target unit {it}j{sf}."
}
if	"`link'"=="ik+jk" | "`link'"=="jk+ik"  {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of source unit {it}i{sf} to source units {it}k{sf} and link of target unit {it}j{sf} to source units {it}k{sf}."
}
if	"`link'"=="ik+kj" | "`link'"=="kj+ik"  {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of source unit {it}i{sf} to source units {it}k{sf} and link of source units {it}k{sf} to target unit {it}j{sf}."
}
if	"`link'"=="ki+im" | "`link'"=="im+ki"  {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of source units {it}k{sf} to source unit {it}i{sf} and link of source unit {it}i{sf} to target units {it}m{sf}."
}
if	"`link'"=="ki+mi" | "`link'"=="mi+ki"  {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of source units {it}k{sf} to source unit {it}i{sf} and link of target units {it}m{sf} to source unit {it}i{sf}."
}
if	"`link'"=="ki+jm" | "`link'"=="jm+ki"  {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of source units {it}k{sf} to source unit {it}i{sf} and link of target unit {it}j{sf} to target units {it}m{sf}."
}
if	"`link'"=="ki+mj" | "`link'"=="mj+ki"  {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of source units {it}k{sf} to source unit {it}i{sf} and link of target units {it}m{sf} to target unit {it}j{sf}."
}
if	"`link'"=="ki+jk" | "`link'"=="jk+ki"  {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of source units {it}k{sf} to source unit {it}i{sf} and link of target unit {it}j{sf} to source units {it}k{sf}."
}
if	"`link'"=="ki+kj" | "`link'"=="kj+ki"  {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of source units {it}k{sf} to source unit {it}i{sf} and link of source units {it}k{sf} to target unit {it}j{sf}."
}
if	"`link'"=="im+mi" | "`link'"=="mi+im"  {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of source unit {it}i{sf} to target units {it}m{sf} and link of target units {it}m{sf} to source unit {it}i{sf}."
}
if	"`link'"=="im+jm" | "`link'"=="jm+im"  {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of source unit {it}i{sf} to target units {it}m{sf} and link of target unit {it}j{sf} to target units {it}m{sf}."
}
if	"`link'"=="im+mj" | "`link'"=="mj+im"  {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of source unit {it}i{sf} to target units {it}m{sf} and link of target units {it}m{sf} to target unit {it}j{sf}."
}
if	"`link'"=="im+jk" | "`link'"=="jk+im"  {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of source unit {it}i{sf} to target units {it}m{sf} and link of target unit {it}j{sf} to source units {it}k{sf}."
}
if	"`link'"=="im+kj" | "`link'"=="kj+im"  {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of source unit {it}i{sf} to target units {it}m{sf} and link of source units {it}k{sf} to target unit {it}j{sf}."
}
if	"`link'"=="mi+jm" | "`link'"=="jm+mi"  {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of target units {it}m{sf} to source unit {it}i{sf} and link of target unit {it}j{sf} to target units {it}m{sf}."
}
if	"`link'"=="mi+mj" | "`link'"=="mj+mi"  {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of target units {it}m{sf} to source unit {it}i{sf} and link of target units {it}m{sf} to target unit {it}j{sf}."
}
if	"`link'"=="mi+jk" | "`link'"=="jk+mi"  {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of target units {it}m{sf} to source unit {it}i{sf} and link of target unit {it}j{sf} to source units {it}k{sf}."
}
if	"`link'"=="mi+kj" | "`link'"=="kj+mi"  {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of target units {it}m{sf} to source unit {it}i{sf} and link of target unit {it}j{sf} to target units {it}m{sf}."
}
if	"`link'"=="jm+mj" | "`link'"=="mj+jm"  {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of target unit {it}j{sf} to target units {it}m{sf} and link of target units {it}m{sf} to target unit {it}j{sf}."
}
if	"`link'"=="jm+jk" | "`link'"=="jk+jm" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of target unit {it}j{sf} to target units {it}m{sf} and link of target unit {it}j{sf} to source units {it}k{sf}."
}
if	"`link'"=="jm+kj" | "`link'"=="kj+jm"  {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of target unit {it}j{sf} to target units {it}m{sf} and link of source units {it}k{sf} to target unit {it}j{sf}."
}
if	"`link'"=="mj+jk" | "`link'"=="jk+mj"  {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of target units {it}m{sf} to target unit {it}j{sf} and link of target unit {it}j{sf} to source units {it}k{sf}."
}
if	"`link'"=="mj+kj" | "`link'"=="kj+mj"  {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of target units {it}m{sf} to target unit {it}j{sf} and link of source units {it}k{sf} to target unit {it}j{sf}."
}
if	"`link'"=="jk+kj" | "`link'"=="kj+jk"  {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}sum{sf} of two links:
	di _newline "      link of target unit {it}j{sf} to source units {it}k{sf} and link of source units {it}k{sf} to target unit {it}j{sf}."
}


if  "`link'"=="ik*ki" | "`link'"=="ki*ik" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of source unit {it}i{sf} to source units {it}k{sf} and link of source units {it}k{sf} to source unit {it}i{sf}."
}
if	"`link'"=="ik*im" | "`link'"=="im*ik" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of source unit {it}i{sf} to target units {it}k{sf} and link of source unit {it}i{sf} to target units {it}m{sf}."
}
if	"`link'"=="ik*mi" | "`link'"=="mi*ik" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of source unit {it}i{sf} to source units {it}k{sf} and link of target units {it}m{sf} to source unit {it}i{sf}."
}
if	"`link'"=="ik*jm" | "`link'"=="jm*ik" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of source unit {it}i{sf} to source units {it}k{sf} and link of target unit {it}j{sf} to target units {it}m{sf}."
}
if	"`link'"=="ik*mj" | "`link'"=="mj*ik" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of source unit {it}i{sf} to source units {it}k{sf} and link of target units {it}m{sf} to target unit {it}j{sf}."
}
if	"`link'"=="ik*jk" | "`link'"=="jk*ik" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of source unit {it}i{sf} to source units {it}k{sf} and link of target unit {it}j{sf} to source units {it}k{sf}."
}
if	"`link'"=="ik*kj" | "`link'"=="kj*ik" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of source unit {it}i{sf} to source units {it}k{sf} and link of source units {it}k{sf} to target unit {it}j{sf}."
}
if	"`link'"=="ki*im" | "`link'"=="im*ki" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of source units {it}k{sf} to source unit {it}i{sf} and link of source unit {it}i{sf} to target units {it}m{sf}."
}
if	"`link'"=="ki*mi" | "`link'"=="mi*ki" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of source units {it}k{sf} to source unit {it}i{sf} and link of target units {it}m{sf} to source unit {it}i{sf}."
}
if	"`link'"=="ki*jm" | "`link'"=="jm*ki" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of source units {it}k{sf} to source unit {it}i{sf} and link of target unit {it}j{sf} to target units {it}m{sf}."
}
if	"`link'"=="ki*mj" | "`link'"=="mj*ki" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of source units {it}k{sf} to source unit {it}i{sf} and link of target units {it}m{sf} to target unit {it}j{sf}."
}
if	"`link'"=="ki*jk" | "`link'"=="jk*ki" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of source units {it}k{sf} to source unit {it}i{sf} and link of target unit {it}j{sf} to source units {it}k{sf}."
}
if	"`link'"=="ki*kj" | "`link'"=="kj*ki" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of source units {it}k{sf} to source unit {it}i{sf} and link of source units {it}k{sf} to target unit {it}j{sf}."
}
if	"`link'"=="im*mi" | "`link'"=="mi*im" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of source unit {it}i{sf} to target units {it}m{sf} and link of target units {it}m{sf} to source unit {it}i{sf}."
}
if	"`link'"=="im*jm" | "`link'"=="jm*im" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of source unit {it}i{sf} to target units {it}m{sf} and link of target unit {it}j{sf} to target units {it}m{sf}."
}
if	"`link'"=="im*mj" | "`link'"=="mj*im" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of source unit {it}i{sf} to target units {it}m{sf} and link of target units {it}m{sf} to target unit {it}j{sf}."
}
if	"`link'"=="im*jk" | "`link'"=="jk*im" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of source unit {it}i{sf} to target units {it}m{sf} and link of target unit {it}j{sf} to source units {it}k{sf}."
}
if	"`link'"=="im*kj" | "`link'"=="kj*im" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of source unit {it}i{sf} to target units {it}m{sf} and link of source units {it}k{sf} to target unit {it}j{sf}."
}
if	"`link'"=="mi*jm" | "`link'"=="jm*mi" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of target units {it}m{sf} to source unit {it}i{sf} and link of target unit {it}j{sf} to target units {it}m{sf}."
}
if	"`link'"=="mi*mj" | "`link'"=="mj*mi" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of target units {it}m{sf} to source unit {it}i{sf} and link of target units {it}m{sf} to target unit {it}j{sf}."
}
if	"`link'"=="mi*jk" | "`link'"=="jk*mi" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of target units {it}m{sf} to source unit {it}i{sf} and link of target unit {it}j{sf} to source units {it}k{sf}."
}
if	"`link'"=="mi*kj" | "`link'"=="kj*mi" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of target units {it}m{sf} to source unit {it}i{sf} and link of target unit {it}j{sf} to target units {it}m{sf}."
}
if	"`link'"=="jm*mj" | "`link'"=="mj*jm" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of target unit {it}j{sf} to target units {it}m{sf} and link of target units {it}m{sf} to target unit {it}j{sf}."
}
if	"`link'"=="jm*jk" | "`link'"=="jk*jm" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of target unit {it}j{sf} to target units {it}m{sf} and link of target unit {it}j{sf} to source units {it}k{sf}."
}
if	"`link'"=="jm*kj" | "`link'"=="kj*jm" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of target unit {it}j{sf} to target units {it}m{sf} and link of source units {it}k{sf} to target unit {it}j{sf}."
}
if	"`link'"=="mj*jk" | "`link'"=="jk*mj" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of target units {it}m{sf} to target unit {it}j{sf} and link of target unit {it}j{sf} to source units {it}k{sf}."
}
if	"`link'"=="mj*kj" | "`link'"=="kj*mj" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of target units {it}m{sf} to target unit {it}j{sf} and link of source units {it}k{sf} to target unit {it}j{sf}."
}
if	"`link'"=="jk*kj" | "`link'"=="kj*jk" {
	di _newline "   {bf}`weightvar'{sf} will represent the {bf}product{sf} of two links:
	di _newline "      link of target unit {it}j{sf} to source units {it}k{sf} and link of source units {it}k{sf} to target unit {it}j{sf}."
}



if "`time'"=="" {
	di _newline "   the spatial effect variable is {bf}time-invariant{sf}."
}
else {
	di _newline "   {bf}`time'{sf} is the numeric time variable."
}
if "`exclusive'"=="exclusive" { 
	di _newline "   Dyads containing either {it}i{sf} or {it}j{sf} as either source or target are {bf}excluded{sf} from having a spatial effect on dyad {it}ij{sf}."
}
if "`rowst'"=="norowst" { 
	di _newline "   the spatial effect is {bf}not{sf} to be {bf}row-standardized{sf}."
}
else {
	di _newline "   the spatial effect is to be {bf}row-standardized{sf}."
	local rowst "rowst"
}
di _newline "If these assumptions are incorrect, the generated spatial effect variable will be incorrect."

if "`merge'"=="nomerge" { 
	di _newline "User must {bf}merge{sf} the created spatial effect variable into the estimation dataset {bf}by hand{sf}."
	if "`filename'"=="" {
		di _newline "   Warning: file {bf}SE_file_dir_`rowst'{sf} will be replaced in current working directory, if already existant."
	}
	else {
		di _newline "   Warning: file {bf}`filename'{sf} will be replaced in current working directory, if already existant."
	}
}
else {
	di _newline "The created spatial effect variable will be {bf}automatically merged{sf} into the original dataset."
	if "`sename'"=="" {
		di _newline "   Warning: variable {bf}SE_var_dir_`rowst'{sf} will be dropped from dataset before merging, if already existant."
		capture drop SE_var_dir_`rowst'
	}
	else {
		di _newline "   Warning: variable {bf}`sename'{sf} will be dropped from dataset before merging, if already existant."
		capture drop `sename'
	}
	if "`filename'"!="" {
		di _newline "   Warning: file {bf}`filename'{sf} will be replaced in current working directory, if already existant."
	}
}

set more on
di _newline(2) "{bf}*** Check the above. ***{sf}  --  Press q to break, press any other button to continue."
more

preserve
quietly keep if `touse'

quietly {
	tempfile datasample holder addeddyads
	tempvar sourceidinf
	ge `sourceidinf'=.
	tempvar targetidinf
	ge `targetidinf'=.
	quietly compress
	save "`datasample'", replace
	keep `spatialvar' `weightvar' `sourceidinf' `targetidinf' `time' `source' `target' 
	save "`holder'", replace
	tempvar varholder
	ren `source' `varholder'
	ren `target' `source'
	ren `varholder' `target'
	keep `time' `source' `target' 
	save "`addeddyads'", replace
	use "`holder'", replace
	append using "`addeddyads'"
	capture drop _merge
	capture drop _fillin
	fillin `source' `target' `time'
	collapse `spatialvar' `weightvar' `sourceidinf' `targetidinf', by(`source' `target' `time')
	save "`holder'", replace
}

if "`sourcetype'"=="int" | "`sourcetype'"=="long" | "`sourcetype'"=="float" | "`sourcetype'"=="double"  | "`sourcetype'"=="byte" {
	tempvar sourceid
	quietly egen `sourceid'=group(`source')
}
else {
	tempvar sourceid
	quietly encode `source', ge(`sourceid')
}
if "`targettype'"=="int" | "`targettype'"=="long" | "`targettype'"=="float" | "`targettype'"=="double"  | "`targettype'"=="byte" {
	tempvar targetid
	quietly egen `targetid'=group(`target')
}
else {
	tempvar targetid
	quietly encode `target', ge(`targetid')
}
quietly su `sourceid'
local source_max=r(max)
quietly su `targetid'
local target_max=r(max)
if `source_max'<2 & `target_max'<2 {
		di as err "Generation of spatial effect variable not possible with fewer than 2 source and 2 target units."
		exit 198
}
else {
	if ("`link'"=="jm" | "`link'"=="jk" | "`link'"=="mj" | "`link'"=="kj") {
		di _newline "Generating spatial effect components for dyads involving `target_max' target units in total - please wait."
	}
	else {
		di _newline "Generating spatial effect components for dyads involving `source_max' source units in total - please wait."
	}	
}

quietly {
	tempfile spatialvarempty Wempty 
	tempvar sourceidinf
	ge `sourceidinf'=.
	tempvar targetidinf
	ge `targetidinf'=.
	quietly compress
	save "`datasample'", replace
	keep `spatialvar' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' `time' 
	save "`holder'", replace
	use "`holder'", replace
	keep if `sourceidinf'==0
	keep `spatialvar' `sourceidinf' `targetidinf' `sourceid' `targetid' `time' 
	save "`spatialvarempty'", replace
	use "`holder'", replace
	keep if `sourceidinf'==0
	keep `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' `time' 
	save "`Wempty'", replace
}


if ("`link'"=="jm" | "`link'"=="jk" | "`link'"=="mj" | "`link'"=="kj") {
	forvalues i = 1(1)`target_max' {
		if `i'/10==int(`i'/10) {
			di "."
		}
		else {
			di "." _continue
		}
		quietly {	
			use "`spatialvarempty'", replace
			tempfile spatialvardirdyad_`i'
			save "`spatialvardirdyad_`i''", replace
			use "`Wempty'", replace
			tempfile Wsource_`i'
			save "`Wsource_`i''", replace
			tempfile Wtarget_`i'
			save "`Wtarget_`i''", replace
			use "`holder'", replace
			replace `targetidinf'=`i'
			save "`holder'", replace
			forvalues j = 1(1)`source_max' {
				use "`holder'", replace
				replace `sourceidinf'=`j'
				if "`exclusive'"=="" {
					keep if  (`targetidinf'!=`targetid' | `sourceidinf'!=`sourceid')
				}
				if "`exclusive'"=="exclusive" {
					keep if  `targetidinf'!=`targetid'
					keep if  `sourceidinf'!=`sourceid'
				}
				keep `time' `spatialvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 
				append using "`spatialvardirdyad_`i''",
				save "`spatialvardirdyad_`i''", replace
			}
			if "`exclusive'"=="" & ("`link'"=="jm" | "`link'"=="jk") {
				use "`holder'", replace
				keep if  `targetidinf'==`sourceid'
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wtarget_`i''"
				save "`Wtarget_`i''", replace
			}		
			if "`exclusive'"=="" & ("`link'"=="mj" | "`link'"=="kj") {
				use "`holder'", replace
				keep if  `targetidinf'==`targetid'
				tempvar varholder
				ge `varholder'=`sourceid' 
				drop `sourceid'
				ren `targetid' `sourceid'
				ren `varholder' `targetid'
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wtarget_`i''"
				save "`Wtarget_`i''", replace
			}
			if "`exclusive'"=="exclusive" & "`link'"=="jm" {
				use "`holder'", replace
				keep if  `targetidinf'==`sourceid'
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wtarget_`i''"
				save "`Wtarget_`i''", replace
			}		
			if "`exclusive'"=="exclusive" & "`link'"=="mj" {
				use "`holder'", replace
				keep if  `targetidinf'==`targetid'
				tempvar varholder
				ge `varholder'=`sourceid' 
				drop `sourceid'
				ren `targetid' `sourceid'
				ren `varholder' `targetid'
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wtarget_`i''"
				save "`Wtarget_`i''", replace
			}
			if "`exclusive'"=="exclusive" & "`link'"=="jk" {
				use "`holder'", replace
				keep if  `targetidinf'==`sourceid'
				tempvar varholder
				ge `varholder'=`sourceid' 
				drop `sourceid'
				ren `targetid' `sourceid'
				ren `varholder' `targetid'
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wtarget_`i''"
				save "`Wtarget_`i''", replace
			}		
			if "`exclusive'"=="exclusive" & "`link'"=="kj" {
				use "`holder'", replace
				keep if  `targetidinf'==`targetid'
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wtarget_`i''"
				save "`Wtarget_`i''", replace
			}
		}
	}		
}
else {
	forvalues i = 1(1)`source_max' {
		if `i'/10==int(`i'/10) {
			di "."
		}
		else {
			di "." _continue
		}
		quietly {	
			use "`spatialvarempty'", replace
			tempfile spatialvardirdyad_`i'
			save "`spatialvardirdyad_`i''", replace
			use "`Wempty'", replace
			tempfile Wsource_`i'
			save "`Wsource_`i''", replace
			tempfile Wtarget_`i'
			save "`Wtarget_`i''", replace
			use "`holder'", replace
			replace `sourceidinf'=`i'
			save "`holder'", replace
			forvalues j = 1(1)`target_max' {
				use "`holder'", replace
				replace `targetidinf'=`j'
				if "`exclusive'"=="" {
					keep if  (`targetidinf'!=`targetid' | `sourceidinf'!=`sourceid')
				}
				if "`exclusive'"=="exclusive" {
					keep if  `targetidinf'!=`targetid'
					keep if  `sourceidinf'!=`sourceid'
				}
				keep `time' `spatialvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 
				append using "`spatialvardirdyad_`i''",
				save "`spatialvardirdyad_`i''", replace

				if "`exclusive'"=="" & ("`link'"=="ik+ki" | "`link'"=="ki+ik" | "`link'"=="ik*ki" | "`link'"=="ki*ik" | ///
										"`link'"=="ik+mi" | "`link'"=="mi+ik" | "`link'"=="ik*mi" | "`link'"=="mi*ik") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`sourceid'			
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`targetid'			
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
				if "`exclusive'"=="" & ("`link'"=="ik+im" | "`link'"=="im+ik" | "`link'"=="ik*im" | "`link'"=="im*ik") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`sourceid'			
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`sourceid'			
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
				if "`exclusive'"=="" & ("`link'"=="ik+mj" | "`link'"=="mj+ik" | "`link'"=="ik*mj" | "`link'"=="mj*ik" | ///
										"`link'"=="ik+kj" | "`link'"=="kj+ik" | "`link'"=="ik*kj" | "`link'"=="kj*ik" | ///
										"`link'"=="im+mj" | "`link'"=="mj+im" | "`link'"=="im*mj" | "`link'"=="mj*im" | ///
										"`link'"=="im+kj" | "`link'"=="kj+im" | "`link'"=="im*kj" | "`link'"=="kj*im") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`sourceid'			
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`targetid'
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
				if "`exclusive'"=="" & ("`link'"=="ik+jm" | "`link'"=="jm+ik" | "`link'"=="ik*jm" | "`link'"=="jm*ik" | ///
										"`link'"=="ik+jk" | "`link'"=="jk+ik" | "`link'"=="ik*jk" | "`link'"=="jk*ik" | ///
										"`link'"=="im+jm" | "`link'"=="jm+im" | "`link'"=="im*jm" | "`link'"=="jm*im" | ///
										"`link'"=="im+jk" | "`link'"=="jk+im" | "`link'"=="im*jk" | "`link'"=="jk*im") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`sourceid'			
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`sourceid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
				if "`exclusive'"=="" & ("`link'"=="ki+im" | "`link'"=="im+ki" | "`link'"=="ki*im" | "`link'"=="im*ki") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`targetid'			
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`sourceid'			
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
				if "`exclusive'"=="" & ("`link'"=="ki+mi" | "`link'"=="mi+ki" | "`link'"=="ki*mi" | "`link'"=="mi*ki") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`targetid'			
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`targetid'			
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
				if "`exclusive'"=="" & ("`link'"=="ki+jm" | "`link'"=="jm+ki" | "`link'"=="ki*jm" | "`link'"=="jm*ki" | ///
										"`link'"=="ki+jk" | "`link'"=="jk+ki" | "`link'"=="ki*jk" | "`link'"=="jk*ki" | ///
										"`link'"=="mi+jm" | "`link'"=="jm+mi" | "`link'"=="mi*jm" | "`link'"=="jm*mi" | ///
										"`link'"=="mi+jk" | "`link'"=="jk+mi" | "`link'"=="mi*jk" | "`link'"=="jk*mi") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`targetid'			
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`sourceid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
				if "`exclusive'"=="" & ("`link'"=="ki+mj" | "`link'"=="mj+ki" | "`link'"=="ki*mj" | "`link'"=="mj*ki" | ///
										"`link'"=="ki+kj" | "`link'"=="kj+ki" | "`link'"=="ki*kj" | "`link'"=="kj*ki" | ///
										"`link'"=="mi+mj" | "`link'"=="mj+mi" | "`link'"=="mi*mj" | "`link'"=="mj*mi" | ///
										"`link'"=="mi+kj" | "`link'"=="kj+mi" | "`link'"=="mi*kj" | "`link'"=="kj*mi") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`targetid'			
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`targetid'
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
				if "`exclusive'"=="" & ("`link'"=="im+mi" | "`link'"=="mi+im" | "`link'"=="im*mi" | "`link'"=="mi*im" ) {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`sourceid'			
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 	
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`targetid'
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 						
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
				if "`exclusive'"=="" & ("`link'"=="jm+mj" | "`link'"=="mj+jm" | "`link'"=="jm*mj" | "`link'"=="mj*jm" | ///
										"`link'"=="jm+kj" | "`link'"=="kj+jm" | "`link'"=="jm*kj" | "`link'"=="kj*jm" | ///
										"`link'"=="jk+kj" | "`link'"=="kj+jk" | "`link'"=="jk*kj" | "`link'"=="kj*jk") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`sourceid'			
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 	
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`targetid'
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
				if "`exclusive'"=="" & ("`link'"=="jm+jk" | "`link'"=="jk+jm" | "`link'"=="jm*jk" | "`link'"=="jk*jm") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`sourceid'			
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 	
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`sourceid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 				
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
				if "`exclusive'"=="" & ("`link'"=="mj+jk" | "`link'"=="jk+mj" | "`link'"=="mj*jk" | "`link'"=="jk*mj") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`targetid'
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 	
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`sourceid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 				
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
				if "`exclusive'"=="" & ("`link'"=="mj+kj" | "`link'"=="kj+mj" | "`link'"=="mj*kj" | "`link'"=="kj*mj") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`targetid'
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 	
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`targetid'
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}

				
				
*1
				if "`exclusive'"=="exclusive" & ("`link'"=="ik+ki" | "`link'"=="ki+ik" | "`link'"=="ik*ki" | "`link'"=="ki*ik") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'!=`targetid'
					keep if  `sourceidinf'==`sourceid'		
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`targetid'
					keep if  `sourceidinf'!=`sourceid'			
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 			
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}	
*2
				if "`exclusive'"=="exclusive" & ("`link'"=="ik+im" | "`link'"=="im+ik" | "`link'"=="ik*im" | "`link'"=="im*ik") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'!=`targetid'
					keep if  `sourceidinf'==`sourceid'		
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 				
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`sourceid'
					keep if  `targetidinf'!=`targetid'		
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}	
*3
				if "`exclusive'"=="exclusive" & ("`link'"=="ik+mi" | "`link'"=="mi+ik" | "`link'"=="ik*mi" | "`link'"=="mi*ik") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'!=`targetid'
					keep if  `sourceidinf'==`sourceid'		
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`targetid'
					keep if  `targetidinf'!=`sourceid'
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 	
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}	
*4				
				if "`exclusive'"=="exclusive" & ("`link'"=="ik+jm" | "`link'"=="jm+ik" | "`link'"=="ik*jm" | "`link'"=="jm*ik") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'!=`targetid'
					keep if  `sourceidinf'==`sourceid'			
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`sourceid'
					keep if  `targetidinf'!=`targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
				
*5				
				if "`exclusive'"=="exclusive" & ("`link'"=="ik+mj" | "`link'"=="mj+ik" | "`link'"=="ik*mj" | "`link'"=="mj*ik") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'!=`targetid'
					keep if  `sourceidinf'==`sourceid'			
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`targetid'
					keep if  `targetidinf'!=`sourceid'			
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
				
*6				
				if "`exclusive'"=="exclusive" & ("`link'"=="ik+jk" | "`link'"=="jk+ik" | "`link'"=="ik*jk" | "`link'"=="jk*ik") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'!=`targetid'
					keep if  `sourceidinf'==`sourceid'			
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`sourceid'
					keep if  `sourceidinf'!=`targetid'
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 			
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
				
*7				
				if "`exclusive'"=="exclusive" & ("`link'"=="ik+kj" | "`link'"=="kj+ik" | "`link'"=="ik*kj" | "`link'"=="kj*ik") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'!=`targetid'
					keep if  `sourceidinf'==`sourceid'			
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`targetid'
					keep if  `sourceidinf'!=`sourceid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 			
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
				
*8
				if "`exclusive'"=="exclusive" & ("`link'"=="ki+im" | "`link'"=="im+ki" | "`link'"=="ki*im" | "`link'"=="im*ki") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`targetid'
					keep if  `sourceidinf'!=`sourceid'			
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`sourceid'
					keep if  `targetidinf'!=`targetid'		
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}	
*9
				if "`exclusive'"=="exclusive" & ("`link'"=="ki+mi" | "`link'"=="mi+ki" | "`link'"=="ki*mi" | "`link'"=="mi*ki") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`targetid'
					keep if  `sourceidinf'!=`sourceid'			
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`targetid'
					keep if  `targetidinf'!=`sourceid'
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 			
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}	

*10
				if "`exclusive'"=="exclusive" & ("`link'"=="ki+jm" | "`link'"=="jm+ki" | "`link'"=="ki*jm" | "`link'"=="jm*ki") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`targetid'
					keep if  `sourceidinf'!=`sourceid'			
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`sourceid'
					keep if  `targetidinf'!=`targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 			
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}	
*11
				if "`exclusive'"=="exclusive" & ("`link'"=="ki+mj" | "`link'"=="mj+ki" | "`link'"=="ki*mj" | "`link'"=="mj*ki") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`targetid'
					keep if  `sourceidinf'!=`sourceid'			
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`targetid'
					keep if  `targetidinf'!=`sourceid'			
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}	
*12
				if "`exclusive'"=="exclusive" & ("`link'"=="ki+jk" | "`link'"=="jk+ki" | "`link'"=="ki*jk" | "`link'"=="jk*ki") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`targetid'
					keep if  `sourceidinf'!=`sourceid'			
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`sourceid'
					keep if  `sourceidinf'!=`targetid'
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 						
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}	

*13
				if "`exclusive'"=="exclusive" & ("`link'"=="ki+kj" | "`link'"=="kj+ki" | "`link'"=="ki*kj" | "`link'"=="kj*ki") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`targetid'
					keep if  `sourceidinf'!=`sourceid'			
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`targetid'
					keep if  `sourceidinf'!=`sourceid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 						
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}	
*14
				if "`exclusive'"=="exclusive" & ("`link'"=="im+mi" | "`link'"=="mi+im" | "`link'"=="im*mi" | "`link'"=="mi*im") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`sourceid'
					keep if  `targetidinf'!=`targetid'		
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`targetid'
					keep if  `targetidinf'!=`sourceid'
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 						
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
				
*15
				if "`exclusive'"=="exclusive" & ("`link'"=="im+jm" | "`link'"=="jm+im" | "`link'"=="im*jm" | "`link'"=="jm*im") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`sourceid'
					keep if  `targetidinf'!=`targetid'		
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`sourceid'
					keep if  `targetidinf'!=`targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
				
*16
				if "`exclusive'"=="exclusive" & ("`link'"=="im+mj" | "`link'"=="mj+im" | "`link'"=="im*mj" | "`link'"=="mj*im") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`sourceid'
					keep if  `targetidinf'!=`targetid'		
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`targetid'
					keep if  `targetidinf'!=`sourceid'			
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 				
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
				
*17
				if "`exclusive'"=="exclusive" & ("`link'"=="im+jk" | "`link'"=="jk+im" | "`link'"=="im*jk" | "`link'"=="jk*im") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`sourceid'
					keep if  `targetidinf'!=`targetid'		
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`sourceid'
					keep if  `sourceidinf'!=`targetid'
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
				
*18
				if "`exclusive'"=="exclusive" & ("`link'"=="im+kj" | "`link'"=="kj+im" | "`link'"=="im*kj" | "`link'"=="kj*im") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`sourceid'
					keep if  `targetidinf'!=`targetid'		
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`targetid'
					keep if  `sourceidinf'!=`sourceid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 			
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
*19
				if "`exclusive'"=="exclusive" & ("`link'"=="mi+jm" | "`link'"=="jm+mi" | "`link'"=="mi*jm" | "`link'"=="jm*mi") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`targetid'
					keep if  `targetidinf'!=`sourceid'
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`sourceid'
					keep if  `targetidinf'!=`targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 	
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
				
*20
				if "`exclusive'"=="exclusive" & ("`link'"=="mi+mj" | "`link'"=="mj+mi" |"`link'"=="mi*mj" |"`link'"=="mj*mi") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`targetid'
					keep if  `targetidinf'!=`sourceid'
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`targetid'
					keep if  `targetidinf'!=`sourceid'			
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 	
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
				
*21
				if "`exclusive'"=="exclusive" & ("`link'"=="mi+jk" | "`link'"=="jk+mi" | "`link'"=="mi*jk" | "`link'"=="jk*mi") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`targetid'
					keep if  `targetidinf'!=`sourceid'
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`sourceid'
					keep if  `sourceidinf'!=`targetid'
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 		
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
				
*22
				if "`exclusive'"=="exclusive" & ("`link'"=="mi+kj" | "`link'"=="kj+mi" | "`link'"=="mi*kj" | "`link'"=="kj*mi") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `sourceidinf'==`targetid'
					keep if  `targetidinf'!=`sourceid'
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`targetid'
					keep if  `sourceidinf'!=`sourceid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
				
*23
				if "`exclusive'"=="exclusive" & ("`link'"=="jm+mj" | "`link'"=="mj+jm" | "`link'"=="jm*mj" | "`link'"=="mj*jm") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`sourceid'
					keep if  `targetidinf'!=`targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 		
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`targetid'
					keep if  `targetidinf'!=`sourceid'			
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 	
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
				
*24
				if "`exclusive'"=="exclusive" & ("`link'"=="jm+jk" | "`link'"=="jk+jm" | "`link'"=="jm*jk" | "`link'"=="jk*jm") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`sourceid'
					keep if  `targetidinf'!=`targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 		
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`sourceid'
					keep if  `sourceidinf'!=`targetid'
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
					
*25
				if "`exclusive'"=="exclusive" & ("`link'"=="jm+kj" | "`link'"=="kj+jm" | "`link'"=="jm*kj" | "`link'"=="kj*jm") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`sourceid'
					keep if  `targetidinf'!=`targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 		
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`targetid'
					keep if  `sourceidinf'!=`sourceid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 	
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
					
*26
				if "`exclusive'"=="exclusive" & ("`link'"=="mj+jk" | "`link'"=="jk+mj" | "`link'"=="mj*jk" | "`link'"=="jk*mj") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`targetid'
					keep if  `targetidinf'!=`sourceid'			
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 		
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`sourceid'
					keep if  `sourceidinf'!=`targetid'
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
					
*27
				if "`exclusive'"=="exclusive" & ("`link'"=="mj+kj" | "`link'"=="kj+mj" | "`link'"=="mj*kj" | "`link'"=="kj*mj") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`targetid'
					keep if  `targetidinf'!=`sourceid'			
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 		
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`targetid'
					keep if  `sourceidinf'!=`sourceid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 		
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
	
*28
				if "`exclusive'"=="exclusive" & ("`link'"=="jk+kj" | "`link'"=="kj+jk" | "`link'"=="jk*kj" | "`link'"=="kj*jk") {
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`sourceid'
					keep if  `sourceidinf'!=`targetid'
					tempvar varholder
					ge `varholder'=`sourceid' 
					drop `sourceid'
					ren `targetid' `sourceid'
					ren `varholder' `targetid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 			
					append using "`Wsource_`i''"
					save "`Wsource_`i''", replace
					use "`holder'", replace
					replace `targetidinf'=`j'
					keep if  `targetidinf'==`targetid'
					keep if  `sourceidinf'!=`sourceid'
					keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 		
					append using "`Wtarget_`i''"
					save "`Wtarget_`i''", replace
				}
			}

			
			if "`exclusive'"=="" & ("`link'"=="ik" | "`link'"=="im") { 
				use "`holder'", replace
				keep if  `sourceidinf'==`sourceid'			
				tempvar varholder
				ge `varholder'=`sourceid' 
				drop `sourceid'
				ren `targetid' `sourceid'
				ren `varholder' `targetid'
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wsource_`i''"
				save "`Wsource_`i''", replace
			}
			if "`exclusive'"=="" & ("`link'"=="ki"  | "`link'"=="mi") {
				use "`holder'", replace
				keep if  `sourceidinf'==`targetid'			
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wsource_`i''"
				save "`Wsource_`i''", replace
			}
			
			
			if "`exclusive'"=="exclusive" & "`link'"=="ik" { 
				use "`holder'", replace
				keep if  `sourceidinf'==`sourceid'			
				tempvar varholder
				ge `varholder'=`sourceid' 
				drop `sourceid'
				ren `targetid' `sourceid'
				ren `varholder' `targetid'
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wsource_`i''"
				save "`Wsource_`i''", replace
			}
			if "`exclusive'"=="exclusive" & "`link'"=="ki" {
				use "`holder'", replace
				keep if  `sourceidinf'==`targetid'			
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wsource_`i''"
				save "`Wsource_`i''", replace
			}
			if "`exclusive'"=="exclusive" & "`link'"=="im" { 
				use "`holder'", replace
				keep if  `sourceidinf'==`sourceid'			
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wsource_`i''"
				save "`Wsource_`i''", replace
			}
			if "`exclusive'"=="exclusive" & "`link'"=="mi" {
				use "`holder'", replace
				keep if  `sourceidinf'==`targetid'
				tempvar varholder
				ge `varholder'=`sourceid' 
				drop `sourceid'
				ren `targetid' `sourceid'
				ren `varholder' `targetid'
				keep `time' `weightvar' `sourceidinf' `targetidinf' `sourceid' `targetid' 					
				append using "`Wsource_`i''"
				save "`Wsource_`i''", replace
			}
		}
	}
}

		
di _newline(2) "Combining spatial effect components for dyads involving `source_max' source units in total - please wait."
forvalues i = 1(1)`source_max'{
	if `i'/10==int(`i'/10) {
		di "."
	}
	else {
		di "." _continue
	}
	quietly {	
		use "`spatialvardirdyad_`i''", replace
		if "`exclusive'"=="" &  ("`link'"=="ik" | "`link'"=="ki" | "`link'"=="im" | "`link'"=="mi") {
			merge m:m `sourceidinf' `sourceid' `time' using `Wsource_`i'', nogenerate
		}
		if "`exclusive'"=="" &  ("`link'"=="jm" | "`link'"=="mj" | "`link'"=="jk" | "`link'"=="kj") {
			merge m:m `targetidinf' `targetid' `time' using `Wtarget_`i'', nogenerate
		}

		if "`exclusive'"=="" & ("`link'"=="ik+ki" | "`link'"=="ki+ik" | "`link'"=="ik*ki" | "`link'"=="ki*ik" | ///
								"`link'"=="ik+mi" | "`link'"=="mi+ik" | "`link'"=="ik*mi" | "`link'"=="mi*ik" | ///
								"`link'"=="ik+im" | "`link'"=="im+ik" | "`link'"=="ik*im" | "`link'"=="im*ik" | ///
								"`link'"=="ki+im" | "`link'"=="im+ki" | "`link'"=="ki*im" | "`link'"=="im*ki" | ///
								"`link'"=="ki+mi" | "`link'"=="mi+ki" | "`link'"=="ki*mi" | "`link'"=="mi*ki" | ///
								"`link'"=="im+mi" | "`link'"=="mi+im" | "`link'"=="im*mi" | "`link'"=="mi*im") {
			merge m:m `targetidinf' `sourceidinf' `sourceid'  `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `sourceid'  `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if  "`link'"=="ik+ki" | "`link'"=="ki+ik" | "`link'"=="ik+mi" | "`link'"=="mi+ik" | ///
				"`link'"=="ik+im" | "`link'"=="im+ik" | "`link'"=="ki+im" | "`link'"=="im+ki" | ///
				"`link'"=="ki+mi" | "`link'"=="mi+ki" | "`link'"=="im+mi" | "`link'"=="mi+im" {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if  "`link'"=="ik*ki" | "`link'"=="ki*ik" | "`link'"=="ik*mi" | "`link'"=="mi*ik" | ///
				"`link'"=="ik*im" | "`link'"=="im*ik" | "`link'"=="ki*im" | "`link'"=="im*ki" | ///
				"`link'"=="ki*mi" | "`link'"=="mi*ki" | "`link'"=="im*mi" | "`link'"=="mi*im" {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}
		if "`exclusive'"=="" & ("`link'"=="ik+mj" | "`link'"=="mj+ik" | "`link'"=="ik*mj" | "`link'"=="mj*ik" | ///
								"`link'"=="ik+kj" | "`link'"=="kj+ik" | "`link'"=="ik*kj" | "`link'"=="kj*ik" | ///
								"`link'"=="im+mj" | "`link'"=="mj+im" | "`link'"=="im*mj" | "`link'"=="mj*im" | ///
								"`link'"=="im+kj" | "`link'"=="kj+im" | "`link'"=="im*kj" | "`link'"=="kj*im" | ///
								"`link'"=="ik+jm" | "`link'"=="jm+ik" | "`link'"=="ik*jm" | "`link'"=="jm*ik" | ///
								"`link'"=="ik+jk" | "`link'"=="jk+ik" | "`link'"=="ik*jk" | "`link'"=="jk*ik" | ///
								"`link'"=="im+jm" | "`link'"=="jm+im" | "`link'"=="im*jm" | "`link'"=="jm*im" | ///
								"`link'"=="im+jk" | "`link'"=="jk+im" | "`link'"=="im*jk" | "`link'"=="jk*im" | ///
								"`link'"=="ki+jm" | "`link'"=="jm+ki" | "`link'"=="ki*jm" | "`link'"=="jm*ki" | ///
								"`link'"=="ki+jk" | "`link'"=="jk+ki" | "`link'"=="ki*jk" | "`link'"=="jk*ki" | ///
								"`link'"=="mi+jm" | "`link'"=="jm+mi" | "`link'"=="mi*jm" | "`link'"=="jm*mi" | ///
								"`link'"=="mi+jk" | "`link'"=="jk+mi" | "`link'"=="mi*jk" | "`link'"=="jk*mi" | ///
								"`link'"=="ki+mj" | "`link'"=="mj+ki" | "`link'"=="ki*mj" | "`link'"=="mj*ki" | ///
								"`link'"=="ki+kj" | "`link'"=="kj+ki" | "`link'"=="ki*kj" | "`link'"=="kj*ki" | ///
								"`link'"=="mi+mj" | "`link'"=="mj+mi" | "`link'"=="mi*mj" | "`link'"=="mj*mi" | ///
								"`link'"=="mi+kj" | "`link'"=="kj+mi" | "`link'"=="mi*kj" | "`link'"=="kj*mi") {
			merge m:m `targetidinf' `sourceidinf' `sourceid'  `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `targetid'  `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if  "`link'"=="ik+mj" | "`link'"=="mj+ik" | "`link'"=="ik+kj" | "`link'"=="kj+ik" | ///
				"`link'"=="im+mj" | "`link'"=="mj+im" | "`link'"=="im+kj" | "`link'"=="kj+im" | ///
				"`link'"=="ik+jm" | "`link'"=="jm+ik" | "`link'"=="ik+jk" | "`link'"=="jk+ik" | ///
				"`link'"=="im+jm" | "`link'"=="jm+im" | "`link'"=="im+jk" | "`link'"=="jk+im" | ///
				"`link'"=="ki+jm" | "`link'"=="jm+ki" | "`link'"=="ki+jk" | "`link'"=="jk+ki" | ///
				"`link'"=="mi+jm" | "`link'"=="jm+mi" | "`link'"=="mi+jk" | "`link'"=="jk+mi" | ///
				"`link'"=="ki+mj" | "`link'"=="mj+ki" | "`link'"=="ki+kj" | "`link'"=="kj+ki" | ///
				"`link'"=="mi+mj" | "`link'"=="mj+mi" | "`link'"=="mi+kj" | "`link'"=="kj+mi" {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if  "`link'"=="ik*mj" | "`link'"=="mj*ik" | "`link'"=="ik*kj" | "`link'"=="kj*ik" | ///
				"`link'"=="im*mj" | "`link'"=="mj*im" | "`link'"=="im*kj" | "`link'"=="kj*im" | ///
				"`link'"=="ik*jm" | "`link'"=="jm*ik" | "`link'"=="ik*jk" | "`link'"=="jk*ik" | ///
				"`link'"=="im*jm" | "`link'"=="jm*im" | "`link'"=="im*jk" | "`link'"=="jk*im" | ///
				"`link'"=="ki*jm" | "`link'"=="jm*ki" | "`link'"=="ki*jk" | "`link'"=="jk*ki" | ///
				"`link'"=="mi*jm" | "`link'"=="jm*mi" | "`link'"=="mi*jk" | "`link'"=="jk*mi" | ///
				"`link'"=="ki*mj" | "`link'"=="mj*ki" | "`link'"=="ki*kj" | "`link'"=="kj*ki" | ///
				"`link'"=="mi*mj" | "`link'"=="mj*mi" | "`link'"=="mi*kj" | "`link'"=="kj*mi" {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}
		if "`exclusive'"=="" & ("`link'"=="jm+mj" | "`link'"=="mj+jm" | "`link'"=="jm*mj" | "`link'"=="mj*jm" | ///
								"`link'"=="jm+kj" | "`link'"=="kj+jm" | "`link'"=="jm*kj" | "`link'"=="kj*jm" | ///
								"`link'"=="jk+kj" | "`link'"=="kj+jk" | "`link'"=="jk*kj" | "`link'"=="kj*jk" | ///
								"`link'"=="jm+jk" | "`link'"=="jk+jm" | "`link'"=="jm*jk" | "`link'"=="jk*jm" | ///
								"`link'"=="mj+jk" | "`link'"=="jk+mj" | "`link'"=="mj*jk" | "`link'"=="jk*mj" | ///
								"`link'"=="mj+kj" | "`link'"=="kj+mj" | "`link'"=="mj*kj" | "`link'"=="kj*mj") {
			merge m:m `targetidinf' `sourceidinf' `targetid'  `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `targetid'  `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if  "`link'"=="jm+mj" | "`link'"=="mj+jm" | "`link'"=="jm+kj" | "`link'"=="kj+jm" | ///
				"`link'"=="jk+kj" | "`link'"=="kj+jk" | "`link'"=="jm+jk" | "`link'"=="jk+jm" | ///
				"`link'"=="mj+jk" | "`link'"=="jk+mj" | "`link'"=="mj+kj" | "`link'"=="kj+mj" {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if  "`link'"=="jm*mj" | "`link'"=="mj*jm" | "`link'"=="jm*kj" | "`link'"=="kj*jm" | ///
				"`link'"=="jk*kj" | "`link'"=="kj*jk" | "`link'"=="jm*jk" | "`link'"=="jk*jm" | ///
				"`link'"=="mj*jk" | "`link'"=="jk*mj" | "`link'"=="mj*kj" | "`link'"=="kj*mj" {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}
		

		
		if "`exclusive'"=="exclusive" &  ("`link'"=="ik" | "`link'"=="ki") {
			merge m:m `sourceidinf' `sourceid' `time' using `Wsource_`i'', nogenerate
		}
		if "`exclusive'"=="exclusive" &  ("`link'"=="im" | "`link'"=="mi") {
			merge m:m `sourceidinf'  `targetid' `time' using `Wsource_`i'', nogenerate
		}
		if "`exclusive'"=="exclusive" &  ("`link'"=="jm" | "`link'"=="mj") {
			merge m:m `targetidinf' `targetid' `time' using `Wtarget_`i'', nogenerate
		}
		if "`exclusive'"=="exclusive" &  ("`link'"=="jk" | "`link'"=="kj") {
			merge m:m `targetidinf' `sourceid' `time' using `Wtarget_`i'', nogenerate
		}

		
*1
		if "`exclusive'"=="exclusive" & ("`link'"=="ik+ki" | "`link'"=="ki+ik" | "`link'"=="ik*ki" | "`link'"=="ki*ik") {
			merge m:m `targetidinf' `sourceidinf' `sourceid' `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `sourceid' `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="ik+ki" | "`link'"=="ki+ik"  {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="ik*ki" | "`link'"=="ki*ik" {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}	
*2
		if "`exclusive'"=="exclusive" & ("`link'"=="ik+im" | "`link'"=="im+ik" | "`link'"=="ik*im" | "`link'"=="im*ik" ) {
			merge m:m `targetidinf' `sourceidinf' `sourceid' `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `targetid'  `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="ik+im" | "`link'"=="im+ik"  {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="ik*im" | "`link'"=="im*ik" {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}	

*3
		if "`exclusive'"=="exclusive" & ("`link'"=="ik+mi" | "`link'"=="mi+ik" | "`link'"=="ik*mi" | "`link'"=="mi*ik") {
			merge m:m `targetidinf' `sourceidinf' `sourceid' `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `targetid'  `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="ik+mi" | "`link'"=="mi+ik"  {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="ik*mi" | "`link'"=="mi*ik" {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}	

*4
		if "`exclusive'"=="exclusive" & ("`link'"=="ik+jm" | "`link'"=="jm+ik" | "`link'"=="ik*jm" | "`link'"=="jm*ik") {
			merge m:m `targetidinf' `sourceidinf' `sourceid' `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `targetid'  `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="ik+jm" | "`link'"=="jm+ik"  {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="ik*jm" | "`link'"=="jm*ik" {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}	

*5
		if "`exclusive'"=="exclusive" & ("`link'"=="ik+mj" | "`link'"=="mj+ik" | "`link'"=="ik*mj" | "`link'"=="mj*ik") {
			merge m:m `targetidinf' `sourceidinf' `sourceid' `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `targetid'  `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="ik+mj" | "`link'"=="mj+ik"  {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="ik*mj" | "`link'"=="mj*ik" {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}	

*6
		if "`exclusive'"=="exclusive" & ("`link'"=="ik+jk" | "`link'"=="jk+ik" | "`link'"=="ik*jk" | "`link'"=="jk*ik") {
			merge m:m `targetidinf' `sourceidinf' `sourceid' `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `sourceid'  `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="ik+jk" | "`link'"=="jk+ik"  {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="ik*jk" | "`link'"=="jk*ik" {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}	

*7
		if "`exclusive'"=="exclusive" & ("`link'"=="ik+kj" | "`link'"=="kj+ik" | "`link'"=="ik*kj" | "`link'"=="kj*ik") {
			merge m:m `targetidinf' `sourceidinf' `sourceid' `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `sourceid'  `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="ik+kj" | "`link'"=="kj+ik"  {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="ik*kj" | "`link'"=="kj*ik" {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}	

*8
		if "`exclusive'"=="exclusive" & ("`link'"=="ki+im" | "`link'"=="im+ki" | "`link'"=="ki*im" | "`link'"=="im*ki") {
			merge m:m `targetidinf' `sourceidinf' `sourceid' `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `targetid'  `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="ki+im" | "`link'"=="im+ki"  {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="ki*im" | "`link'"=="im*ki"  {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}	

*9
		if "`exclusive'"=="exclusive" & ("`link'"=="ki+mi" | "`link'"=="mi+ki" | "`link'"=="ki*mi" | "`link'"=="mi*ki") {
			merge m:m `targetidinf' `sourceidinf' `sourceid' `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `targetid'  `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="ki+mi" | "`link'"=="mi+ki"  {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="ki*mi" | "`link'"=="mi*ki"  {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}	

*10
		if "`exclusive'"=="exclusive" & ("`link'"=="ki+jm" | "`link'"=="jm+ki" | "`link'"=="ki*jm" | "`link'"=="jm*ki") {
			merge m:m `targetidinf' `sourceidinf' `sourceid' `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `targetid'  `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="ki+jm" | "`link'"=="jm+ki"  {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="ki*jm" | "`link'"=="jm*ki"  {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}	

*11
		if "`exclusive'"=="exclusive" & ("`link'"=="ki+mj" | "`link'"=="mj+ki" | "`link'"=="ki*mj" | "`link'"=="mj*ki") {
			merge m:m `targetidinf' `sourceidinf' `sourceid' `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `targetid'  `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="ki+mj" | "`link'"=="mj+ki"  {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="ki*mj" | "`link'"=="mj*ki"  {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}	

*12
		if "`exclusive'"=="exclusive" & ("`link'"=="ki+jk" | "`link'"=="jk+ki" | "`link'"=="ki*jk" | "`link'"=="jk*ki") {
			merge m:m `targetidinf' `sourceidinf' `sourceid' `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `sourceid' `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="ki+jk" | "`link'"=="jk+ki"  {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="ki*jk" | "`link'"=="jk*ki"  {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}	

*13
		if "`exclusive'"=="exclusive" & ("`link'"=="ki+kj" | "`link'"=="kj+ki" | "`link'"=="ki*kj" | "`link'"=="kj*ki") {
			merge m:m `targetidinf' `sourceidinf' `sourceid' `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `sourceid' `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="ki+kj" | "`link'"=="kj+ki"  {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="ki*kj" | "`link'"=="kj*ki"  {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}	

*14
		if "`exclusive'"=="exclusive" & ("`link'"=="im+mi" | "`link'"=="mi+im" | "`link'"=="im*mi" | "`link'"=="mi*im") {
			merge m:m `targetidinf' `sourceidinf' `targetid' `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `targetid' `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="im+mi"  | "`link'"=="mi+im" {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="im*mi"  | "`link'"=="mi*im" {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}	

*15
		if "`exclusive'"=="exclusive" & ("`link'"=="im+jm" | "`link'"=="jm+im" | "`link'"=="im*jm" | "`link'"=="jm*im") {
			merge m:m `targetidinf' `sourceidinf' `targetid' `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `targetid' `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="im+jm"  | "`link'"=="jm+im" {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="im*jm"  | "`link'"=="jm*im" {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}	

*16
		if "`exclusive'"=="exclusive" & ("`link'"=="im+mj" | "`link'"=="mj+im" | "`link'"=="im*mj" | "`link'"=="mj*im") {
			merge m:m `targetidinf' `sourceidinf' `targetid' `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `targetid' `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="im+mj"  | "`link'"=="mj+im" {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="im*mj"  | "`link'"=="mj*im" {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}	

*17
		if "`exclusive'"=="exclusive" & ("`link'"=="im+jk" | "`link'"=="jk+im" | "`link'"=="im*jk" | "`link'"=="jk*im") {
			merge m:m `targetidinf' `sourceidinf' `targetid' `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `sourceid' `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="im+jk"  | "`link'"=="jk+im" {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="im*jk"  | "`link'"=="jk*im" {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}	

*18
		if "`exclusive'"=="exclusive" & ("`link'"=="im+kj" | "`link'"=="kj+im" | "`link'"=="im*kj" | "`link'"=="kj*im") {
			merge m:m `targetidinf' `sourceidinf' `targetid' `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `sourceid' `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="im+kj"  | "`link'"=="kj+im" {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="im*kj"  | "`link'"=="kj*im" {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}	

*19
		if "`exclusive'"=="exclusive" & ("`link'"=="mi+jm" | "`link'"=="jm+mi" | "`link'"=="mi*jm" | "`link'"=="jm*mi") {
			merge m:m `targetidinf' `sourceidinf' `targetid' `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `targetid' `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="mi+jm"  | "`link'"=="jm+mi" {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="mi*jm"  | "`link'"=="jm*mi" {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}	

*20
		if "`exclusive'"=="exclusive" & ("`link'"=="mi+mj" | "`link'"=="mj+mi" | "`link'"=="mi*mj" | "`link'"=="mj*mi") {
			merge m:m `targetidinf' `sourceidinf' `targetid' `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `targetid' `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="mi+mj"  | "`link'"=="mj+mi" {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="mi*mj"  | "`link'"=="mj*mi" {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}	

*21
		if "`exclusive'"=="exclusive" & ("`link'"=="mi+jk" | "`link'"=="jk+mi" | "`link'"=="mi*jk" | "`link'"=="jk*mi") {
			merge m:m `targetidinf' `sourceidinf' `targetid' `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `sourceid' `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="mi+jk"  | "`link'"=="jk+mi" {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="mi*jk"  | "`link'"=="jk*mi" {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}	

*22
		if "`exclusive'"=="exclusive" & ("`link'"=="mi+kj" | "`link'"=="kj+mi" | "`link'"=="mi*kj" | "`link'"=="kj*mi") {
			merge m:m `targetidinf' `sourceidinf' `targetid' `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `sourceid' `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="mi+kj"  | "`link'"=="kj+mi" {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="mi*kj"  | "`link'"=="kj*mi" {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}	

*23
		if "`exclusive'"=="exclusive" & ("`link'"=="jm+mj" | "`link'"=="mj+jm" | "`link'"=="jm*mj" | "`link'"=="mj*jm") {
			merge m:m `targetidinf' `sourceidinf' `targetid' `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `targetid' `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="jm+mj"  | "`link'"=="mj+jm" {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="jm*mj"  | "`link'"=="mj*jm" {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}	

*24
		if "`exclusive'"=="exclusive" & ("`link'"=="jm+jk" | "`link'"=="jk+jm" | "`link'"=="jm*jk" | "`link'"=="jk*jm") {
			merge m:m `targetidinf' `sourceidinf' `targetid' `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `sourceid' `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="jm+jk"  | "`link'"=="jk+jm" {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="jm*jk"  | "`link'"=="jk*jm" {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}	

*25
		if "`exclusive'"=="exclusive" & ("`link'"=="jm+kj" | "`link'"=="kj+jm" | "`link'"=="jm*kj" | "`link'"=="kj*jm") {
			merge m:m `targetidinf' `sourceidinf' `targetid' `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `sourceid' `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="jm+kj"  | "`link'"=="kj+jm" {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="jm*kj"  | "`link'"=="kj*jm" {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}	

*26
		if "`exclusive'"=="exclusive" & ("`link'"=="mj+jk" | "`link'"=="jk+mj" | "`link'"=="mj*jk" | "`link'"=="jk*mj") {
			merge m:m `targetidinf' `sourceidinf' `targetid' `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `sourceid' `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="mj+jk"  | "`link'"=="jk+mj" {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="mj*jk"  | "`link'"=="jk*mj" {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}	

*27
		if "`exclusive'"=="exclusive" & ("`link'"=="mj+kj" | "`link'"=="kj+mj" | "`link'"=="mj*kj" | "`link'"=="kj*mj") {
			merge m:m `targetidinf' `sourceidinf' `targetid' `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `sourceid' `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="mj+kj"  | "`link'"=="kj+mj" {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="mj*kj"  | "`link'"=="kj*mj" {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}	

*28
		if "`exclusive'"=="exclusive" & ("`link'"=="jk+kj" | "`link'"=="kj+jk" | "`link'"=="jk*kj" | "`link'"=="kj*jk") {
			merge m:m `targetidinf' `sourceidinf' `sourceid' `time' using `Wsource_`i'', nogenerate
			tempvar Wsource
			ren `weightvar' `Wsource'
			merge m:m `targetidinf' `sourceidinf' `sourceid' `time' using `Wtarget_`i'', nogenerate
			tempvar Wtarget
			ren `weightvar' `Wtarget'
			if "`link'"=="jk+kj"  | "`link'"=="kj+jk" {
				replace `Wsource'=0 if `Wsource'==.
				replace `Wtarget'=0 if `Wtarget'==.
				gen `weightvar'=`Wsource'+`Wtarget'
			}
			if "`link'"=="jk*kj"  | "`link'"=="kj*jk" {
				gen `weightvar'=`Wsource'*`Wtarget'
			}
		}	

		tempvar dirdyadcont
		replace `weightvar'=. if `spatialvar'==.
		ge `dirdyadcont'=`spatialvar'*`weightvar' 
		tempvar allmissing
		gen `allmissing'=`dirdyadcont'
		collapse (sum) `dirdyadcont' `weightvar' (mean) `allmissing', by(`sourceidinf' `targetidinf' `time')
		replace `dirdyadcont'=. if `allmissing'==.
		if "`rowst'"=="norowst" { 
			ge SE_var_dir_`rowst'= `dirdyadcont'
			replace SE_var_dir_`rowst'=. if `weightvar'==0
		}
		else {
			ge SE_var_dir_`rowst'= `dirdyadcont'/`weightvar'
		}
		keep `sourceidinf' `targetidinf' SE_var_dir_`rowst' `time'
		tempfile SE_file_dir_`rowst'_`i'
		save "`SE_file_dir_`rowst'_`i''", replace
	}
}
local appendnumber = `source_max'-1
di _newline(2) "Appending spatial effects for `appendnumber' times in total - please wait."
quietly use "`SE_file_dir_`rowst'_1'", replace
forvalues i = 2(1)`source_max'{
	quietly append using "`SE_file_dir_`rowst'_`i''"
	if `i'/10==int(`i'/10) {
		di "."
	}
	else {
		di "." _continue
	}
} 		
ren `sourceidinf' `sourceid'
ren `targetidinf' `targetid'
if "`sename'"=="" {
	local sename "SE_var_dir_`rowst'"
}
else {
	ren SE_var_dir_`rowst' `sename'
}
if "`filename'"=="" {
	local filename "SE_file_dir_`rowst'"
}
sort `sourceid' `targetid' `time'
quietly save "`holder'", replace

quietly {
	use "`datasample'", replace
	merge m:m `sourceid' `targetid' `time' using `holder', nogenerate
	keep `source' `target' `time' `sename'
	collapse `sename', by(`source' `target' `time')
	if "`sourcetype'"=="int" | "`sourcetype'"=="long" | "`sourcetype'"=="float" | "`sourcetype'"=="double"  | "`sourcetype'"=="byte" {
		drop if `source'==.
	}
	else {
		drop if `source'==""
	}
	save `filename', replace
	restore
	preserve
	merge m:m `source' `target' `time' using `filename', keep(match) nogenerate
	keep `source' `target' `time' `sename'
	if "`labelname'"=="" {
		label var `sename' "Directed dyad contagion spatial effect variable" 
	}
	else {
		label var `sename' "`labelname'"
	}
	save `filename', replace
}

di _newline(2) "File {bf}`filename'{sf}"
di _newline(1) "  with variables {bf}`source'{sf}, {bf}`target'{sf}, {bf}`time'{sf}"
di _newline(1) "  and SE variable {bf}`sename'{sf} saved in current working directory"
if "`merge'"=="nomerge" { 
	restore
}
else {
	restore
	capture drop _merge
	quietly merge m:m `source' `target' `time' using `filename', keep(match master)
	di _newline(2) "Spatial lag variable {bf}`sename'{sf} merged into the original dataset."
}

end

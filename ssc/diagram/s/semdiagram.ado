/*** DO NOT EDIT THIS LINE -----------------------------------------------------
Version:
Title: semdiagram
Description: executes {help sem} one-factor measurement model and produces
 dynamic path diagram for 
 [diagram](www.haghish.com/diagram/diagram.php) package
----------------------------------------------------- DO NOT EDIT THIS LINE ***/


/***
Syntax
======

{p 8 16 2}
{cmd: semdiagram} [:] _{help sem} or {help gsem} command_ 
{p_end}

Description
===========

The __semdiagram__ provides an "example" for generating dynamic path diagram, using 
Stata __sem__ command. It takes a Stata __sem__ or __gsem__ command and 
produces a dynamic path diagram. Currently, it is only supporting a 
_one-factor measurement model_. Similar to __sem__ and __gsem__ commands, 
the path direction can be from right to left or left to write (see the example). 
__semdiagram__ produces a dynamic path diagram named _semdiagram.gv_ that can be rendered 
and exported to a graphical file using {help diagram} package. 

This program was meant to be used as an example for automating path diagrams 
from Stata. If you wish to improve the program to support more sophisticated 
__sem__ models, [fork diagram package on GitHub](https://github.com/haghish/diagram).

Example(s)
=================

    Setup
        . webuse sem_1fmm

    A one-factor measurement model
        . semdiagram sem (X->x1) (X->x2) (X->x3) (X->x4)
		
    Or alternatively
        . semdiagram sem (x1<-X) (x2<-X) (x3<-X) (x4<-X)	
		
    semdiagram creates {it:semdiagram.gv} file which can be exported to a graphical image
        . diagram using semdiagram.gv, export(semdiagram.png)
		
Stored results
=================

__semdiagram__ stores the SEM output in a matrix:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrix}{p_end}
{synopt:{cmd:r(table)}}results of the SEM command{p_end}

Author
======

__E. F. Haghish__     
Center for Medical Biometry and Medical Informatics     
University of Freiburg, Germany     
_and_        
Department of Mathematics and Computer Science       
University of Southern Denmark     
haghish@imbi.uni-freiburg.de     
      
[http://www.haghish.com/markdoc](http://www.haghish.com/statistics/stata-blog/reproducible-research/markdoc.php)         
Package Updates on [Twitter](http://www.twitter.com/Haghish)    

- - -

_This help file was dynamically produced by[MarkDoc Literate Programming package](http://www.haghish.com/markdoc/)_ 
***/




*cap prog drop semdiagram
program define semdiagram, rclass
  *version 8
   
   // -------------------------------------------------------------------------
	// Syntax processing
	// =========================================================================

	// Check if the command includes Colon in the beginning
	if substr(trim(`"`macval(0)'"'),1,1) == ":" {
		local 0 : subinstr local 0 ":" ""
	}
	
	local command `"`macval(0)'"'
	
	if substr(trim("`0'"),1,3) == "sem" {
		local 0 : subinstr local 0 "sem" ""
	}
	else if substr(trim("`0'"),1,4) == "gsem" {
		local 0 : subinstr local 0 "gsem" ""
	}
	
	// Execute the code
	`command'
	mat define R = r(table)
	
	scalar ncols = colsof(R)
	

	// Export the filename! 
	tempfile edited
	tempname knot
	qui file open `knot' using "`edited'", write text replace
	file write `knot' "digraph G {" _n  ///
		`"fontname="sans-serif";splines="line";penwidth="0.1";"' _n ///
		`"edge [arrowsize="0.7", fontname="sans-serif", fontsize=10, colorscheme="greys5", color="2", fontcolor="5"];"' _n ///
		`"node [fontname="serif", fontsize=12,fillcolor="1",colorscheme="greys3",color="2", fontcolor="4",style="filled"];"' _n 
	
	
	

	local i 0		// for variable numbers
	local j 0 		// for columns of the matrix
	local k : di 2*((ncols-1)/3)
	
	local latentvar
	
	while "`0'" ~= "" {
		gettoken open 0 : 0, parse("(") 
		if `"`open'"' != "(" {
			error 198
		}
		gettoken next 0 : 0, parse(")")

		while `"`next'"' != ")" {
			if `"`next'"'=="" { 
				error 198
			}
		  local list `next'
		  gettoken next 0 : 0, parse(")")
		}
	
		// Memorize the list of latent variables. The graph is developed in a loop 
		// and information about the same latent variable should not be rewritten.
		// ---------------------------------------------------------------------
		

		local i `++i'
		local jump 								//reset
		file write `knot' _n					// add an empty line
			
		local j `++j'
		local b = R[1,`j']
		local b : di round(R[1,`j'],.1)
			
		local j `++j'
		local con : di %2.1g R[1,`j']
		local con : di trim("`con'")
			
		local k `++k'
		local e : di round(R[1,`k'])
			
		// REPLACE THE DIRECTION
		if strpos("`list'","<-") != 0 {
			local br = strpos("`list'","<-")
			local l1 = trim(substr("`list'",1, `br'-1))
			local l2 = trim(substr("`list'",`br'+2,.))
			local list = `"    `macval(l2)' -> `macval(l1)' [label="`b'"];"'
		}
		else if strpos("`list'","->") != 0 {
			local br = strpos("`list'","->")
			local l2 = trim(substr("`list'",1, `br'-1))
			local l1 = trim(substr("`list'",`br'+2,.))
			local list = `"    `macval(l2)' -> `macval(l1)' [label="`b'"];"'
		}
		
		
		if missing("`latentvar'") {
				local lat : di %2.1g R[1,ncols]
				local lat : di trim("`lat'")
				file write `knot' `"    `l2' [width="1.05", height="0.7", label="`l2'\n`lat'"];"' _n(2)
				local latentvar = "`l2'"
				local jump 1
			}
			else {
				local latentvar "`latentvar' `l2'"		
				tokenize "`latentvar'"
				while "`1'" != "" {
					if "`1'" == "`l2'" {
						local jump 1
						break
					}
					macro shift
				}
			}
		
			// Write the additional latent variables
			if missing("`jump'") {
				file write `knot' `"    `l2' [width="1.05", height="0.7", label="`l2'\n`lat'"];"' _n
			}
			
			// Write the Node
			file write `knot' `"    `l1' [width="1.05", shape="plain", height="0.6", label="`l1'\n`con'"];"' _n
			
			// Write the error Node
			file write `knot' `"    e`i' [width="0.3", shape="circle",fontsize="8",label="e`i'\n`e'"];"' _n
		
			* di as err `"First Group:`i':`list'"'
			
			file write `knot' `"`macval(list)'"' _n
			
			// Adding the errors
			file write `knot' `"    `l1' -> e`i'  [dir="back"];"' _n

	}
	
	file write `knot' "}" 
	qui file close `knot'
	copy "`edited'" semdiagram.gv, replace
	
	return matrix table = R
	
	// report the results
	cap confirm file "semdiagram.gv"
	if _rc == 0 {
		di as txt "(sempdiagram created "`"{bf:{browse "semdiagram.gv"}})"' _n
	}
	else display as err "sempdiagram could not produce semdiagram.gv" _n
	
	
end

/*
*use "http://www.ats.ucla.edu/stat/data/hsb2", clear
*pathreg2 (read write[dir="both"])(math read[] write[])(science math[] read[] write[])

*semdiagram : sem (x1<-X) (x2 <- X) (x3<-X) (x4<-X) 


markdoc semdiagram.ado, export(sthlp) replace

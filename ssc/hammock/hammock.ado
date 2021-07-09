program define hammock
*! 1.0.5	4 Nov 2008: added samescale option, fixed bug related to >8 colors

	version 7 
	syntax varlist [if] [in], [ OUTline Missing THIckness(real 0.2) /* 
*/ hivar(str) HIVALues(numlist) SPAce(real 0.3) LABel SAMEscale COnnect(str) Symbol(str)  Gap(int 5) * ]
	* trap -connect()-, -symbol()- 
	foreach opt in connect symbol {
		if "``opt''" != "" { 
			di as err "`opt'() not supported: please see help" 
			exit 198 
		}	
	} 
	confirm numeric variable `varlist'

	local missing = "`missing'" != ""
	local addlabel= "`label'" != ""
	local same = "`samescale'" !=""
	local fill = "`outline'" == "" /* user typed -outline- or not => fill is 0 or 1 */

	local varnamewidth=`space' /*=percentage of space given to text as oppposed to the graph*/
	if `addlabel'==0 {
		local varnamewidth=0
	}

	* observations to use 
	marksample touse , novarlist
	qui count if `touse' 
	if r(N) == 0 { error 2000 } 

	preserve 
	qui keep if `touse' 
	tempvar id std_ylag width graphxlag colorgroup
	tempname label_coord 
	gen long `id'  = _n 
	local N = _N
	local separator "@"  /*one letter only */
	local aspectratio=1.5  /*how much longer is the x axis relative to the y axis*/
	* doesn't work 32000/23063 may be compute location of points (0,0) and (k,100 or range limit) 


	if `addlabel'==1 {
		list_labels `varlist', separator(`separator')
		matrix `label_coord'= r(label_coord)
		local label_text  "`r(label_text)'"
	}

	
	local k : word count `varlist' 
	local max=`k'
	tokenize `varlist' 

	* compute max,min values over a range of variables
	globalminmax `varlist'
	local globalmax=r(globalmax)
	local globalmin=r(globalmin)
	local globalrange=`globalmax'-`globalmin'

	* create new variables that have a range between 0 and 100.
	local i=0
	foreach v of var `varlist' { 
		local i = `i' + 1   /*needed to find the right variables of label_coord */
		* new tempvar for each loop iteration 
		quietly sum `v'
		if (r(min)!=r(max)) {
			local range=r(max)-r(min)
		}
		else { * var has only one value
			local range=1	
		}
		local min=r(min)
		if (`same') {
			* override calculations with global values
			local range=`globalrange'
			local min=`globalmin'
		}
		if (`missing'==0) {
			qui drop if `v'==.
		}
		else {
			* missing option specified 
			local yline "yline(4)" /* number should depend on range expansion*/
			local rangeexpansion=0.1  /*fraction space reserved for missing values*/
			local missval=`min'-`rangeexpansion'*`range'
			qui replace `v'=`missval' if `v'==.
			local min=`missval'  /* redefine minimum value and range */
			local range=`range'*(1+`rangeexpansion')
		}	
		local my_y  "std_y`i'"
		gen `my_y' = (`v'-`min')/ `range' * 100
		
		if `addlabel'==1 {
			local n_labels = rowsof(`label_coord') 
			forval ii = 1 / `n_labels' {
				if (`label_coord'[`ii',2]==`i') { /* label belongs to variable `v' */
					matrix `label_coord'[`ii',1]= (`label_coord'[`ii',1] -`min')/ `range' * 100
				}
			}
		}
		
	} 	 

	* construct xlabel
	local i=1
	foreach v of var `varlist' {
		if mod(`i', 2) { local xl "`xl',`i'" }
      	else { local tl "`tl', `i'" }
      	local xlabel "`xlabel' `i' ``i''"
      	local i = `i' + 1
   	}
   	local xl = substr("`xl'", 2, .)
   	local xlab_num "`xl'"
   	if `k' > 10 { local tlab = "tlab(" + substr("`tl'", 2, .) + ")"}
   	else { local xlab_num "`xl'`tl'" }

	/*generate colorgroup variable for highlighting*/
	/*gen_colorgroup overwrites 'varlist' and mustn't come earlier*/
	if "`hivar'"!="" { gen_colorgroup `hivar' , hivalues(`hivalues') }
	else {  gen colorgroup=1}

	* transform the data from one obs per data point to one obs per graphbox 
	* 	using reshape and contract

	* variables yvar need be listed std_y1 std_y2 std_y3 etc.   
	qui reshape long std_y, i(`id') 
	keep std_y `id' _j colorgroup 

	* graphx is the variable index of std_y
	local graphx "_j"

	qui { 
		bysort `id' (`graphx') : gen `std_ylag' = std_y[_n+1] 
		drop if `std_ylag' == .  /*last variable doesn't connect to variable after it*/
	} 	

	* graphx is important for unique identification 
	contract std_y `std_ylag' `graphx' colorgroup

	*** preparation for graph 
      
       * make room for labels in between rectangles
	gen `graphxlag'= `graphx'+ (1-`varnamewidth'/2)
	if (`varnamewidth'>0)	{ 
		qui replace `graphx'= `graphx' + `varnamewidth'/2 
	}

	* `width' refers to a percentage of `range'
	summarize `std_ylag', meanonly 
	local range = r(max) - r(min)
	gen `width' =_freq / `N' * `range' * `thickness' 
	
 	local yrange= 100
	local xrange= max(3,`k')-1   /* number of x variables-1==xrange */
		/*Exception:when there are only 2 x-variables, Stata allocates space as if there were 3 */
	tempvar width_y
	qui gen `width_y'=.
 	rightangle_width `graphx' `graphxlag'  std_y `std_ylag'  `width' `width_y' /*
			*/	`xrange' `yrange' `aspectratio'
	qui replace `width'=`width_y' 
	*list `graphx' `graphxlag'  std_y `std_ylag'  `width' `width_y' 
	*di as res "xrange `xrange' yrange `yrange' " 



	/* computation of ylabmin and ylabmax */
	/* needed to avoid that some coordinates are off the graph screen*/
	/* since def of width changes later this is only approximate */	
	Computeylablimit std_y `std_ylag' `width' 
	local ylabmax=r(ylabmax)
	local ylabmin=r(ylabmin) 
 
      keep  `width' colorgroup `graphx' `graphxlag' std_y `std_ylag' 
      qui reshape wide `width', j(colorgroup) i(`graphx' `graphxlag' std_y `std_ylag')

	label var `graphx' " "
	label var std_y " "
	lab def myylab `ylabmin' "|" `ylabmax' "|"
	if (`missing'==1) {
		lab def myylab 0 "missing" 100 "|", modify
	}
	lab values std_y myylab
	lab define myxlab `xlabel'
	lab values  `graphx' myxlab
	graph std_y `graphx' , /* 
	*/ s(.) ylab(`ylabmin' `ylabmax') xlab(`xlab_num')  gap(`gap') `options' `tlab' /*
	*/ noaxis `yline' 


	gph open

	*preparation for graph labels
	if `addlabel'==1 {
		*tokenize `label_text', parse(`separator')
		tokenize `label_text', parse(`separator')
    		forval j=1/`n_labels' { 
			if (`label_coord'[`j',2] !=0) { /*crucial if matrix has empty rows, otherwise graph disappears*/
				local pos=`j'*2-1  /* positions 1,3,5,7, ...  */
				graphword  "``pos''"  `label_coord'[`j',1] `label_coord'[`j',2] 0 0  
			}
		}
	}
	
	GraphBoxColor , xstart(`graphx') xend(`graphxlag') ystart(std_y) yend(`std_ylag') width(`width') fill(`fill') range(`range') 
	gph close
end

/**********************************************************************************/
program define list_labels, rclass
   version 7
   * put labels for one variable onto the graph (graph must exist already)
   syntax varlist , separator(string)

   tempname one_ylabel label_coord

   n_level_program `varlist'
   local n_level= r(n_level)
      
   matrix `label_coord'=J(`n_level',2,0)
   local label_text ""
   local i=0   /* the ith variable (for x-axis) */
   local offset=0  /* sum of the number of levels in previous x-variables */
   
   foreach v of var `varlist' { 
      local i= `i'+1
   	qui tab `v', matrow(`one_ylabel')
	local n_one_ylabel=r(r)

	local g : value label `v'
	forval  j = 1/`n_one_ylabel' {
		local w=`one_ylabel'[`j',1]
      	matrix `label_coord'[`offset'+`j',2]=`i'
		matrix `label_coord'[`offset'+`j',1]=`w'
		if "`g'"!="" {
			local l : label `g' `w'
			local label_text "`label_text'`l'`separator'"
		}
		else {	/* format numbers to display */
			local format_w=string(`w',"%6.0g") 
			local label_text "`label_text'`format_w'`separator'"
		}
      }
      local offset=`offset'+`n_one_ylabel'
   }
   * matrix rownames `label_coord'= `label_text' * doesn't work

   return matrix label_coord `label_coord'
   return local label_text `"`label_text'"' 

end 

/**********************************************************************************/
program define n_level_program, rclass
   version 7
   * compute the sum of the number of levels of all variables
   * each level later corresponds to a label
   syntax varlist 

   * calc the sum of number of levels of all vars
   local n_level=0
   foreach v of var `varlist' { 
	qui tab `v'
      local temp= r(r)
	local n_level=`n_level' + `temp'
   }
   if (`n_level'>40) {
	if (`n_level'<=800) {
	   	set matsize `n_level'
      }
	else {
		di as error "Error: Attempting to display more than 800 labels"
		error 2000
      }
   }
  return local n_level `n_level'

end 
/**********************************************************************************/
program define globalminmax, rclass
   version 7
	* compute min and max values over all variables
	syntax varlist

	local globalmax=-9999999
	local globalmin=9999999
	foreach v of var `varlist' { 
		qui sum `v'
		if (r(max)>`globalmax') {
			local globalmax=r(max)
		}
		if (r(min)<`globalmin') {
			local globalmin=r(min)
		}
	}
	return local globalmin `globalmin'
	return local globalmax `globalmax'

end 
/**********************************************************************************/
program define rightangle_width
   version 7
   * compute the difference of the y coordinates needed when width is taken to 
   * mean right-angle width (distance between two parallel lines)
   * aspectratio: how much longer is the x axis relative to the y axis
   * on input : width_y has already been "generate"d 
   * width_y is computed as a result 
   args xstart xend ystart yend width width_y xrange yrange aspectratio

   tempvar xdiff ydiff
   qui gen `xdiff'= .
   qui gen `ydiff'= .
   qui replace `xdiff'= (`xend'-`xstart')/`xrange' * `aspectratio'
   qui replace `ydiff'= (`yend'-`ystart')/ `yrange'
   qui replace `width_y'=`width' / `xdiff' * sqrt(`xdiff'*`xdiff'+`ydiff'*`ydiff') 

*list `xdiff' `ydiff' `width_y'

end 
/**********************************************************************************/
* generate the colorgroup variable
* all values not mentioned in hivalues get color=1
* colors are generated in sequence of hivalues
* if value in hivalues not contained in hivar, then the corresponding color is just skipped
* if hivar does not exist will give error message "variable `hivar' not found
* if the same value is contained multiple times, only the last one is used and colors 
     *corresponding to earlier ones are skipped
* if hivalues contains more than 8 values earlier pens are being reused
* if hivalues contains all values of hivar, then the default color is never used
* hivalues does not accept labels at this point
* if hivalues not specified will give appropriate error
program define gen_colorgroup
   version 7
   syntax  varlist(max=1 numeric),  HIVALues(numlist)  
   *tokenize `varlist' 
   rename `1' hivar

   local pen=1
   gen colorgroup=`pen'
   foreach v of numlist `hivalues' {
   	local pen=mod(`pen',8)+1
   	qui replace colorgroup=`pen' if hivar==`v'
   }
   * list  hivar colorgroup

end
/**********************************************************************************/

program define graphword
   version 7
   *put one string on the graph
   args mytext ycoord xcoord rot align

   *gph open
   graph 
   local ay = r(ay)
   local by = r(by)
   local ax = r(ax)
   local bx = r(bx)
   local x1 = `ax' * `xcoord' + `bx'
   local y1 = `ay' * `ycoord' + `by'
   gph text `y1' `x1' `rot' `align' `mytext'
	
   *gph close
	
end
/**********************************************************************************/
program define Computeylablimit, rclass
	version 7
* compute maximum and minimum values for y to define graph region ylab
* If I attempt to draw beyond the graph region the graph may draw triangles instead of parallelograms
	args ystart yend width 

	local ylabmin =0 

	tempvar endmax startmax
	gen `endmax' = `yend'+`width'/2
	gen `startmax'= `ystart' +`width'/2
	qui sum `endmax'
	local ylabmax= r(max)
	qui sum `startmax'
	local max2=r(max)
	if (`max2'>`ylabmax') {
		local ylabmax=`max2'
	} 
	local ylabmax=round(`ylabmax',1)
	
	return local ylabmax `ylabmax'
	return local ylabmin `ylabmin'

end

/**********************************************************************************/
* make the parallelogram appear solid by densely plotting parallel lines 
* Arguments : `ylow' `ylaglow' `x1' `x2' `w_k'
program define fillbox
			version 7
			args ylow ylaglow x1 x2 w_k ay range
			* epsilon determines how densely each box is plotted
			local epsilon = .001 * `range'
			local N = _N
			forval i = 1 / `N' {
  			      * for all line segments 
		   		local add = 0
				if (`w_k'[`i'] !=.) { 
   					while (`add' < `w_k'[`i']) {
						local y5 = (`ylow'[`i'] + `ay' *  `add') 
						local y6 = (`ylaglow'[`i'] + `ay' * `add') 
						local startx1 = `x1'[`i'] 
						local endx1 = `x2'[`i']
						gph line `y5' `startx1' `y6' `endx1'
						local add = `add' + `epsilon'
					}
	   			}
			}
end
/**********************************************************************************/
* draw a parallelogram (graph must exist already)
* each obs has a unique combination of "xstart xend ystart yend". 
*If more than one width`i' have non missing values then the box has more than one colors
* the variables are all passed as options (strings) because using tokenize `varlist' interferes with gph
*Parameters
* xstart xend ystart yend 	(vectors determinoing 2 midpoints of parallelogram)
* 		start and end of the line segments for the center of the parallelogram
* width 	width`i' contain the width of the parallelogram for color i in 1/9
*		The width of a box is the sum of all the color segements width`i'
* fill 	(scalar) if fill>0 then the parallelogram is filled with lines 
* 		to make it appear solid
* range	scalar 

program define GraphBoxColor
	version 7 
      syntax  , xstart(str) xend(str) ystart(str) yend(str) width(str) fill(integer) range(real) 
 
	tempvar x1 x2 yhigh ylaghigh ylaglow ylow w increment
	graph

	local ay = r(ay)
	local by = r(by)
	local ax = r(ax)
	local bx = r(bx)
	egen `w'= rsum(`width'*)
	gen `x1' = `ax' * `xstart' + `bx'
	gen `x2' = `ax' * `xend' + `bx'
	gen `yhigh' = `ay' * (`ystart' + `w' /2 ) + `by'
	gen `ylaghigh' = `ay' * (`yend'   + `w' /2 ) + `by'
	gen `ylaglow' = `ay' * (`yend'   -   `w' / 2) + `by'
	gen `ylow' = `ay' * (`ystart' -  `w' / 2) + `by'
	gen `increment'=0

	foreach k of numlist 1/9 { 
		local w_k="`width'`k'"
		capture confirm variable `w_k'
		if !_rc{ /* variable w_k exists*/
		  quietly {
 		  	replace `ylaglow' = `ay' * (`yend'   -   `w' / 2) + `by'
		  	replace `ylow' = `ay' * (`ystart' -  `w' / 2) + `by'
		  }
		  local k1=`k'-1

		  quietly {
		  	replace `ylaglow' = `ylaglow' + `increment' * `ay' 
		  	replace `ylow' = `ylow'+ `increment' *`ay'
		  	replace `ylaglow'=. if `w_k'==.
		  	replace `ylow'=. if `w_k'==.
		 	replace `ylaghigh' = `ylaglow' + `ay' * `w_k'
		  	replace `yhigh' = `ylow' + `ay' * `w_k'
		  }
		  gph pen `k'
		  gph vpoly `yhigh' `x1' `ylaghigh' `x2' `ylaglow' `x2' `ylow' `x1' `yhigh' `x1' 
 		  * list `yhigh' `ylaghigh' `ylaglow' `ylow' `w_k' `increment'
		  
		  if `fill' {
			fillbox `ylow' `ylaglow' `x1' `x2' `w_k' `ay' `range' 
		  }

		  qui replace `increment' = `increment'+ `w_k' if `w_k'!=.   /* for the next round*/
		}
	}
	
end 
/*
Version history:
*! 1.0.0   21 February 2003 Matthias Schonlau 
*! 1.0.1   2 March 2003: Allow variables with one value, Bug fixed when thickness was too large \ 
*! 1.0.2   13 March 2003: width changed to right-angle-width  \
*! 1.0.3   20 Nov 2003: hivar and hival options implemented \
*! 1.0.4	no changes \

*/

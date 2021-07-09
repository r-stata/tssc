*! Version 8.1 19 December 2012
*! Jean-Benoit Hardouin
************************************************************************************************************
* Stata program : msp
* Mokken Scale Procedure
* Release 8.1: (December 19, 2012) [Jean-Benoit Hardouin] /*correction of a bug with the notest option*/
*
* Historic :
* Version 1 - lose version (August 20, 2002) [Jean-Benoit Hardouin]
* Version 2 (September 25, 2002) [Jean-Benoit Hardouin]
* Version 3 (December 1, 2003) [Jean-Benoit Hardouin]
* Version 4 (January 20, 2004) [Jean-Benoit Hardouin]
* Version 5 (March 22, 2004) [Jean-Benoit Hardouin]
* Version 5.1 (May 1st, 2004) [Jean-Benoit Hardouin]
* Version 6 : (July 5, 2004) [Jean-Benoit Hardouin]
* Version 6.1 : (September 5, 2004) [Jean-Benoit Hardouin]
* Version 6.2 : (January 22, 2006) [Jean-Benoit Hardouin] /*English improvements*/
* Release 6.3 : (March 20, 2006) [Jean-Benoit Hardouin]  /*A bug with temporary files */
* Release 6.6:  (Februar 16, 2007) [Jean-Benoit Hardouin] /*Tests of the loevinger H indices, adaptation for loevH 6.6, noadjust option, improvements*/
* Release 8: (December 8, 2010) [Jean-Benoit Hardouin] /*Adaptation for loevh version 8*/
* Release 8.1: (December 19, 2012) [Jean-Benoit Hardouin] /*correction of a bug with the notest option*/
*
* Jean-benoit Hardouin, University of Nantes - Faculty of Pharmaceutical Sciences
* Department of Biostatistics - France
* jean-benoit.hardouin@anaqol.org
*
* The Stata program loevh is needed. It can be downloaded on http://www.anaqol.org
* News about this program :http://www.anaqol.org
* FreeIRT Project website : http://www.freeirt.org
*
* Copyright 2002-2007, 2010, 2012 Jean-Benoit Hardouin
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 2 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*
************************************************************************************************************

program define msp , rclass
version 7.0
syntax varlist(min=2 numeric) [,c(real 0.3) noDETails KERnel(integer 0) noTEst p(real 0.05) PAIRWise MINValue(real 0) noBon noADJust]
local nbitems : word count `varlist'
tokenize `varlist'
tempfile mspfile
qui save "`mspfile'"

if "`pairwise'"=="" {
    forvalues j=1/`nbitems' {
        qui drop if ``j''==.
    }
}
if "`test'"!="" {
	local p=1
	local minvalue=-99
	local bon nobon
}



qui loevh `varlist',`pairwise' pair `adjust'
tempname pvalHjk loevHjk loevHjks loevHj loevH Hjk stopscale stop dim  plusitems Hjkmax Hjmax Hmax nbitemsel
matrix `loevHjk'=r(loevHjk)
matrix `loevHjks'=r(loevHjk)
matrix `pvalHjk'=r(pvalHjk)
matrix `loevHj'=r(loevHj)
scalar `loevH'=r(loevH)
matrix `Hjk'=`loevHjk'

matrix define `dim'=J(1,`nbitems',0)

global scale=0
scalar `stopscale'=0

while `stopscale'!=1  { /*WHILE IT IS POSSIBLE TO CONSTRUCT SCALES*/
	global scale=$scale+1
	local dimension=$scale
	local scaletmp="scale$scale"
	local scaletmpnum="scalenum$scale"
	global `scaletmp'
	global `scaletmpnum'
	if "`details'"=="" {
		di
		di in yellow "Scale: $scale"
		di "{hline 10}"
	}


/**********************************************************************************************************
BEGINING OF THE INITIAL STEP
**********************************************************************************************************/

/****NONE KERNEL OR NOT THE FIRST SCALE****/
	if $scale>1|`kernel'==0 {
		scalar `plusitems'=0
		scalar `Hjkmax'=-99
		local nbitemsbon=0
		forvalues j1=1/`nbitems' {
       	      		  if `dim'[1,`j1']==0 {
	           	     	local nbitemsbon=`nbitemsbon'+1
      	        	  }
		}
		if `nbitemsbon'<=1 {
		   	  local nbitemsbon=2
		}
		local kbon=`nbitemsbon'*(`nbitemsbon'-1)/2
		if "`bon'"==""&"`test'"=="" {
		          local pbon=`p'/`kbon'
	        }
	        else {
	              	  local pbon=`p'
	        }
	        if "`test'"!="" {
	              	  local pbon=1
	              	  local p=1
	        }
		if "`details'"==""&"`test'"=="" {
	   	        di in green "Significance level: " in yellow %8.6f `pbon'
		}
		forvalues j1=1/`nbitems' { /*WE SEARCH THE BEST PAIR OF ITEMS*/
			if `dim'[1,`j1']==0 {
				scalar `plusitems'=1
				forvalues j2=`=`j1'+1'/`nbitems' {
					if `dim'[1,`j2']==0 {
						if `Hjk'[`j1',`j2']>`Hjkmax'&`pvalHjk'[`j1',`j2']<=`pbon' {
							scalar `Hjkmax'=`Hjk'[`j1',`j2']
							global j1max=`j1'
							global j2max=`j2'
						}
						 	       		 							}
				}
			}
		}

		if `Hjkmax'==-99 { /*IF NONE PAIR OF ITEM VERIFY Hjk>0*/
			if `plusitems'==0 {
				if "`details'"=="" {
					di in green "{p}There is no more items remaining.{p_end}"
				}
			}
			else {
				if "`details'"=="" {
					di as green "{p}None pair of items has a significantly positive Hjk coefficient.{p_end}"
				}
			}
		continue, break
		}

		if `Hjkmax'<=`c' { /*IF NONE PAIR OF ITEM VERIFY Hjk>c*/
			if $scale==1 {
				if "`details'"=="" {
					di as green "{p}None pair of items verifies Hjk>`c', the maximum value of these coefficients is " %6.4f `Hjkmax' ". None scale can be constructed.{p_end}"
				}
			}
			else {
				if "`details'"=="" {
					di as green  "{p}None new scale can be constructed because none pair of items, among the remaining items, verifies Hjk>`c'{p_end}"
				}
			}
			scalar `stop'=1
			scalar `stopscale'=1
			continue, break
		}
		else { /*IF THERE IS AT LEAST ONE PAIR OF ITEM WHO VERIFY Hjk>c*/
			matrix `dim'[1,$j1max]=$scale
			matrix `dim'[1,$j2max]=$scale
			local scaletmp="scale$scale"
			local scaletmpnum="scalenum$scale"
			global `scaletmp' "`$j1max' `$j2max'"
			global `scaletmpnum' "$j1max $j2max"
			if "`details'"=="" {
				di in green "{p}The two first items selected in the scale " in yellow "$scale " in green "are " in yellow "`$j1max' " in green "and " in yellow "`$j2max'" in green " (Hjk=" in yellow %6.4f `Hjkmax' in green "){p_end}"
			}
			scalar `nbitemsel'=2
		}
		forvalues i=1/`nbitems' { /*WE EXCLUDE THE ITEMS WHICH VERIFY Hjk<0 WITH THE TWO SELECTED ITEMS*/
			if (`loevHjks'[`i',$j1max]<`minvalue'|`pvalHjk'[`i',$j1max]>`p'&`dim'[1,`i']==0) {
			       matrix `dim'[1,`i']=-1
			}
			if (`loevHjks'[`i',$j2max]<`minvalue'|`pvalHjk'[`i',$j2max]>`p'&`dim'[1,`i']==0) {
			       matrix `dim'[1,`i']=-1
			}
		}
	}
/****FIRST SCALE, KERNEL OF ONE ITEM****/
	if $scale==1&`kernel'==1 {
		global j1max=1
		scalar `plusitems'=0
		scalar `Hjkmax'=-99
		if "`details'"=="" {
			di in green "The item " in yellow "`1'" in green " is the kernel of the first scale"
		}
		local nbitemsbon=0
		forvalues i=2/`nbitems' {  /*WE EXCLUDE THE ITEM WHICH VERIFY Hjk<0 WITH THE ITEM OF THE KERNEL*/
			if (`loevHjks'[`i',$j1max]<`minvalue'|`pvalHjk'[`i',$j1max]>`p')&`dim'[1,`i']==0) {
			       matrix `dim'[1,`i']=-1
			}
			if `dim'[1,`i']==0 {
			       local nbitemsbon=`nbitemsbon'+1
			}
		}
		local kbon=`nbitemsbon'
		if "`bon'"==""&"`test'"=="" {
		          local pbon=`p'/`kbon'
	        }
	        else {
	              	  local pbon=`p'
	        }
		if "`details'"==""&"`test'"=="" {
	   	        di in green "Significance level: " in yellow %8.6f `pbon'
		}
		forvalues j2=2/`nbitems' {/*WE SEARCH THE BEST ITEM TO SELECT WITH THE KERNEL*/
			if `Hjk'[`j2',1]>`Hjkmax'&`pvalHjk'[`j2',1]<`pbon' {
				scalar `Hjkmax'=`Hjk'[`j2',1]
				global j2max=`j2'
			}
		}

		if `Hjkmax'==-99 {/*IF NONE ITEM CAN BE SELECTED WITH THE KERNEL Hjk<*/
			if "`details'"=="" {
				di as green "{p}None item associated to the item " in yellow "$j1 " in green "allows obtaining a significantly positive value for the Hjk coefficient.{p_end}"
			}
			continue, break
		}

		if `Hjkmax'<=`c' { /*IF NONE ITEM CAN BE SELECTED WITH THE KERNEL Hjk<c*/
			if "`details'"=="" {
				di as green "{p}None index Hjk associated to the item "  in yellow "$j1 " in green "verifies Hjk>`c', the maximum value of these coefficients is " %6.4f `Hjkmax' ". None scale can be constructed.{p_end}"
			}
			scalar `stop'=1
			scalar `stopscale'=1
			continue, break
		}
		else { /* IF AT LEAST ONE ITEM CAN BE SELECTED WITH THE KERNEL Hjk>c*/
			matrix `dim'[1,$j1max]=$scale
			matrix `dim'[1,$j2max]=$scale
			local scaletmp="scale$scale"
			local scaletmpnum="scalenum$scale"
			global `scaletmp' "`$j2max' `$j1max'"
			global `scaletmpnum' "$j2max $j1max"
			if "`details'"=="" {
				di in green "The second item selected in the first scale is " in yellow "`$j2max' " in green "(Hjk=" in yellow %6.4f `Hjkmax' in green")"
			}
			scalar `nbitemsel'=2
		}
		forvalues i=1/`nbitems' {  /*WE EXCLUDE THE ITEM WHICH VERIFY Hjk<0 WITH THE NEW SELECTED ITEM*/
                        if (`loevHjks'[`i',$j2max]<`minvalue'|`pvalHjk'[`i',$j2max]>`p')&`dim'[1,`i']==0 {
			       matrix `dim'[1,`i']=-1
			}
		}
	}
/****FIRST SCALE, KERNEL OF SEVERAL ITEMS****/
	if $scale==1&`kernel'>=2 {
		global scale1
		local scalenum1
		local kbon=1
		local pbon=`p'
		if "`details'"==""&"`test'"=="" {
	   	        di in green "Significance level: " in yellow %8.6f `pbon'
		}
		forvalues j2=1/`kernel' {
			global scale1 ``j2'' $scale1
			global scalenum1 $scalenum1 `j2'
			matrix `dim'[1,`j2']=1
		}
		if "`details'"=="" {
			di in green "{p}The kernel of the first scale is composed of the items " in yellow "$scale1{p_end}"
		}
		scalar `nbitemsel'=`kernel'
		forvalues j=1/`kernel' {
			forvalues i=1/`nbitems' { /* WE EXCLUDE THE ITEMS WHICH VERIFY Hjk<0 WITH THE ITEMS OF THE KERNEL*/
				if (`loevHjks'[`i',`j']<`minvalue'|`pvalHjk'[`i',`j']>`p')&`dim'[1,`i']==0 {
				       matrix `dim'[1,`i']=-1
				}
			}
		}
	}
	local excluded
	forvalues i=1/`nbitems' {
		  if `dim'[1,`i']==-1 {
		        local excluded `excluded' ``i''
		        matrix `dim'[1,`i']=-2
		  }
	}
	if "`excluded'"!=""&"`details'"=="" {
	   	 di in green "The following items are excluded at this step: " in yellow "`excluded'"
	}
	scalar `stop'=0

/**********************************************************************************************************
END OF THE INITIAL STEP
**********************************************************************************************************/

	while `stop'!=1 { /*WHILE THE PROCEDURE TO CONSTRUCT THE ACTUAL SCALE IS NOT STOPPED*/

		scalar `Hjmax'=-99
		scalar `Hmax'=-99
		global jmax=0

		global stopmax=0
		local nbitemsbon=0
		forvalues i=1/`nbitems' {
			if `dim'[1,`i']==0 {
				local nbitemsbon=`nbitemsbon'+1
			}
		}
                local kbon=`kbon'+`nbitemsbon'
		if "`bon'"=="" {
		          local pbon=`p'/`kbon'
	        }
	        else {
	              	  local pbon=`p'
	        }
                if "`details'"==""&"`test'"=="" {
	   	          di in green "Significance level: " in yellow %8.6f `pbon'
	  	}


		forvalues j0=1/`nbitems' {
			if `dim'[1,`j0']==0 {/*IF THE ITEM J0 IS UNSELECTED*/
				global stopmax=1
				local scaletmp="scale$scale"
				local scaletmpnum="scalenum$scale"
				qui loevh  ``j0'' $`scaletmp'  ,`pairwise' pair `adjust'
				tempname pvalHj0
			        matrix `pvalHj0'=r(pvalHj)
  			        scalar `pvalHj0'=`pvalHj0'[1,1]
				matrix `loevHjk'=r(loevHjk)
				matrix `loevHj'=r(loevHj)
				scalar `loevH'=r(loevH)

				local nbitsc : word count $`scaletmp'
				local nbitsc=`nbitsc'+1
				if `loevHj'[1,1]>`c'&`pvalHj0'<`pbon' {/*IF THE ITEM J0 CAN BE SELECTED*/
					if `loevH'>`Hmax' {/*AND IF IT IS THE BEST ITEM (COMPARED TO THE PRECEEDING ITEMS)*/
						scalar `Hjmax'=`loevHj'[1,1]
						scalar `Hmax'=`loevH'
						global j="``j0''"
						global j0=`j0'
					}
				}
			}
		}

		if $stopmax==1&`Hjmax'==-99 { /*IF THERE IS ITEMS REMAINING BUT NONE OF THEM CAN BE SELECTED*/

			if "`details'"=="" {
				di in green "{p}None new item can be selected in the scale $scale because all the Hj are lesser than `c' or none new item has all the related Hjk coefficients significantly greater than 0{p_end}."
			}
			scalar `stop'=1
			continue,break
		}
		if $stopmax==0 {  /*IF THERE IS NO MORE ITEM REMAINING*/
			if "`details'"=="" {
				di in green "{p}There is no more items remaining.{p_end}"
			}
			scalar `stopscale'=1
			scalar `stop'=1
			forvalues i=1/`nbitems' {
			   if `dim'[1,`i']<0 {
		              scalar `stopscale'=0
			   }
                        }
			*global scale=$scale-1
			continue,break
		}


		if `stop'!=1 {  /*IF THE PROCEDURE IS NOT STOPPED*/
			matrix `dim'[1,$j0]=$scale
			local `scaletmp'="scale$scale"
			local `scaletmpnum'="scalenum$scale"
			global `scaletmp' $j $`scaletmp'
			global `scaletmpnum' $j0 $`scaletmpnum'
			if "`details'"=="" {
				di in green "The item " in yellow  "`$j0' " in green "is selected in the scale " in yellow "$scale" _col(50) in green "Hj=" in yellow %6.4f `Hjmax' _col(65) in green "H=" in yellow %6.4f `Hmax' ""
			}
			local excluded
			forvalues i=1/`nbitems' {
		  	    if `dim'[1,`i']==-1 {
		                matrix `dim'[1,`i']=-2
		            }
		            if `dim'[1,`i']==0 {  /*WE EXCLUDE ITEMS WHO HAVE A NEGATIVE Hjk WITH THE NEW SELECTED ITEM*/
		                if `loevHjks'[`i',$j0]<`minvalue'|`pvalHjk'[`i',$j0]>`p' {
		                     matrix `dim'[1,`i']=-1
		                     local excluded `excluded' ``i''
		                }
			    }
	                }
			if "`excluded'"!=""&"`details'"=="" {
	   	 	    di in green "The following items are excluded at this step: " in yellow "`excluded'"
			}
		}
	}
	di
	local scaleencours="scale$scale"
	local scalenumencours="scalenum$scale"
	local nbitemscale : word count $`scaleencours'
	return scalar nbitems`dimension'=`nbitemscale'
	if `nbitemscale'>0 {   /* IF AT LEAST TWO ITEMS HAVE BEEN SELECTED*/
        	if "`details'"!="" {
		   di
		   di in yellow "Scale: $scale"
		   di "{hline 10}"
		}
                loevh $`scaleencours',`pairwise' `adjust'
		matrix `loevHjk'=r(loevHjk)
		matrix `loevHj'=r(loevHj)
		scalar `loevH'=r(loevH)

		return scalar H`dimension'=`loevH'
		return local scale`dimension' $`scaleencours'
		return local scalenum`dimension' $`scalenumencours'
		local j=`nbitemscale'
		di
	}
        forvalues i=1/`nbitems' {
		if `dim'[1,`i']<0 {
		   	matrix `dim'[1,`i']=0
		}
	}

	local restnbitems=0
	forvalues j0=1/`nbitems' {
		if `dim'[1,`j0']==0 {
			local restnbitems=`restnbitems'+1
			local restitem ``j0''
		}
	}

	if `restnbitems'==1 { /*IF THERE IS ONLY ONE ITEM REMAINING*/
		di
		di in green "{p}There is only one item remaining (" in yellow "`restitem'" in green ").{p_end}"
		local stopscale=1
		return local lastitem "`restitem'"
	}

}

return scalar dim=$scale
matrix colnames `dim'=`varlist'
return matrix selection=`dim'

qui use "`mspfile'",clear
end

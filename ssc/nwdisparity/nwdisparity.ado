*! Date        : 25oct2016
*! Version     : 1.0.0
*! Author      : Charlie Joyez, Paris-Dauphine University
*! Email	   : contact@nwcommands.org

* Calculates node's disparity 
* See Barthélemy, M., Barrat, A., Pastor-Satorras, R., & Vespignani, A. (2005). Characterization and modeling of weighted networks. Physica a: Statistical mechanics and its applications, 346(1), 34-43.

capture program drop nwdisparity
program nwdisparity, rclass
	version 9
	syntax [anything(name=netname)] [, DIRection(string)]
	_nwsyntax `netname', max(9999)
	
	
foreach v in _degree _strength _in_degree _out_degree _in_strength _out_strength{
	capture confirm variable `v'
if !_rc {
                      
					   rename `v' alr_`v'
               }
}
			   
			
	if `networks' > 1 {
		local k = 1
	}
	_nwsetobs `netname'
	
	
	quietly nwdegree `netname'
	quietly nwdegree `netname',valued
    *noi di "`directed'"
	if "`directed'"=="false" {
	quietly gen weight = 0 if _degree==_strength
	quietly replace weight = 1 if _degree!=_strength
	}
	if "`directed'" == "true"{
	if "`direction'"=="inward" {
	quietly gen weight = 0 if _in_degree==_in_strength
	quietly replace weight = 1 if _in_degree!=_in_strength
	}
	if "`direction'"!="inward" {
	quietly gen weight = 0 if _out_degree==_out_strength
	quietly replace weight = 1 if _out_degree!=_out_strength
	}
	}
	
	quietly egen Weight=total(weight)
	quietly gen valued = 1 if Weight!=0
	quietly replace valued=0 if Weight==0
	

		  if valued == 0{
		  noi display as error "{txt} Network is not weighted, cannot compute disparity." 
		}
		
		if valued == 1{
		
	set more off
	capture drop _strength
	capture drop _out_strength
	capture drop _in_strength
	capture drop _invstrength

	qui foreach netname_temp in `netname' {
	 nwtomata `netname_temp', mat(mymat)

	_nwsyntax `netname_temp' 
	local nodes_temp `nodes' 
	local directed `directed' 
	noi di "`direction'"
	
	quietly nwdegree `netname_temp',valued 
	mata: neighbor = mymat:>0
	if "`directed'"=="false" {
	gen _invstrength=1/_strength
	replace _invstrength=0 if _invstrength==.
	}
	if "`directed'"=="true"{
	if "`direction'"=="inward" {
	gen _invstrength=1/_in_strength
	replace _invstrength=0 if _invstrength==.
	}
	if "`direction'"!="inward"{
	gen _invstrength=1/_out_strength
	replace _invstrength=0 if _invstrength==.
	}
	}
	mata : invS=st_data(.,"_invstrength")
	mata : invS2=invS:^2
	mata : Weight2=mymat:^2
	mata : Y2=Weight2*invS2

	

	
	mata: st_matrix("disparity", Y2)
	capture drop _disparity
	mata: resindex = st_addvar("float","_disparity")
	mata: st_store((1,rows(Y2)),resindex,Y2)
	qui count if _disparity!=.
	noi di "{hline 40}"
	noi di "{txt}Network {res}`netname_temp' {txt} "
	if "`directed'"=="false" {
	noi di "{res}  `r(N)' {txt} real values of {res}`direction' {res}_disparity created"
	}
	if "`directed'"=="true" {
		if "`direction'"=="inward" {
		noi di "{res}  `r(N)' {txt} real values of {res}`direction' {res}_disparity created"
		}
		if "`direction'"!="inward" {
		noi di "{res}  `r(N)' {txt} real values of {res}outward {res}_disparity created"
		}	
	}
	noi su _disparity
	local Nb=r(N)
	local avg_disparity=r(mean)
	
	}
foreach v in _degree _strength _in_degree _out_degree _in_strength _out_strength{
	capture confirm variable alr_`v'
if !_rc {
          capture drop  `v'           
					  rename alr_`v' `v'

               }

			   else {

					capture drop `v'
			  
			   }
	}	
	return scalar N=`Nb'
	return scalar avg_disparity=`avg_disparity'
	}

	
	capture drop valued
	capture drop weight
	capture drop Weight
	capture drop _invstrength
	end

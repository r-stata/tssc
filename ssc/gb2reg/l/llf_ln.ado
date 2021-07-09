/*This ado file gives the log likelihood function for the LN distribution.
It works with gb2reg.ado

Author--Jacob Orchard
Update--5/3/2016*/

program llf_ln
version 13
		args lnf delta sigma 
		tempvar x y z w 
		qui gen double `x' = -(log($ML_y1)-`delta')^2/(`sigma'^2) 
		qui gen double `y' = log(`sigma')
		qui gen double `z' = log($ML_y1)
		qui gen double `w' = .5*(log(2*_pi)) 
		qui replace `lnf' = `x' - `y' - `z' - `w'  
end		

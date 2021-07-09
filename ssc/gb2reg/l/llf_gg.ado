/*This ado file gives the log likelihood function for the GG distribution.
It works with gb2reg.ado

Author--Jacob Orchard
Update--5/3/2016*/

program llf_gg
version 13
		args lnf delta sigma p 
		tempvar x y z w v
		qui gen double `x' = `p'*((log($ML_y1) - `delta')/`sigma' )
		qui gen double `y' = log(`sigma')
		qui gen double `z' = log($ML_y1)
		qui gen double `w' = lngamma(`p') 
		qui gen double `v' = exp((log($ML_y1 )-`delta')/`sigma')
		qui replace `lnf' = `x' - `y' - `z' - `w' - `v'
end		

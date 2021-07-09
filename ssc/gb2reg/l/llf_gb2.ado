/*This ado file gives the log likelihood function for the GB2 distribution.
It works with gb2reg.ado

Author--Jacob Orchard
Update--5/3/2016*/

program llf_gb2
version 13
		args lnf delta sigma p q
		tempvar x y z w v
		qui gen double `x' = `p'*((log($ML_y1) - `delta')/`sigma' )
		qui gen double `y' = log(`sigma')
		qui gen double `z' = log($ML_y1)
		qui gen double `w' = lngamma(`p') + lngamma(`q') - lngamma(`p' + `q')
		qui gen double `v' = (`p'+`q')*log(1+ exp(((log($ML_y1)-`delta')/`sigma')))
		qui replace `lnf' = `x' - `y' - `z' - `w' - `v'
end		

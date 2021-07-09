

* Version: June 2011
* Alejandro Lopez-Feldman
* Division de Economia
* Centro de Investigacion y docencia economicas, CIDE
* lopezfeldman@gmail.com
* This is called by singleb.ado

program singleb_ll
	version 10.1
	args lnf xb sig
	tempvar bid resp
	gen double `bid'= $ML_y1 
	gen  `resp' = $ML_y2   

	qui replace `lnf' = ln(normal(((`xb'-`bid')/(`sig')))) if `resp' ==1
	qui replace `lnf' = ln(normal(((-`xb'+`bid')/(`sig')))) if `resp' ==0

end


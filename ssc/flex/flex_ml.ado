* Version 1.0 - 6 Aug 2013
* By J.M.C. Santos Silva, S. Tenreyro, and K. Wei
* Please email jmcss@essex.ac.uk for help and support

	**********************************
	* This file is called by flex.ado*
	**********************************

* The software is provided as is, without warranty of any kind, express or implied, including 
* but not limited to the warranties of merchantability, fitness for a particular purpose and 
* noninfringement. In no event shall the author be liable for any claim, damages or other 
* liability, whether in an action of contract, tort or otherwise, arising from, out of or in 
* connection with the software or the use or other dealings in the software.


program flex_ml
    version 11.0
	args lnf fit omega 
	tempvar _p
	quietly gen double `_p' = 1 - (1 + `omega'*exp(`fit'))^(-1/`omega') if $ML_samp==1
	quietly replace `lnf' = ($ML_y1*ln(`_p') + (1-$ML_y1)*ln(1-`_p'))   if $ML_samp==1
	end

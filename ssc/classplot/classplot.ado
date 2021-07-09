* LEK  30.06.2005
capture program drop classplot
program classplot , sortpreserve
   version 8
   syntax [, XCATegories(integer 25) YCATegories(integer 20) PLOTALL * ]
// Definition No of x/y categories
   capture {
		error !(`xcategories'>=.|inrange(`xcategories',2,100))
		error !(`ycategories'>=.|inrange(`ycategories',2,100))
		}
	if _rc!=0 {
		di as error "invalid input: Use integer values from 2 to 100"
		exit
		}
	quietly predict _yhat , p
	local nq = `xcategories'
   global ycatnumber  = `ycategories'
// Quantile Variable
	quietly gen _quantile = .
	foreach value of numlist 1(1)`nq' {
      quietly replace _quantile = `value' if _yhat<=((`value'*(100/`nq'))*0.01) & ///
		                               _yhat>(((`value'-1)*(100/`nq'))*0.01)
		}
   quietly replace _quantile = _quantile*(100/`nq')
   sort _quantile $S_E_depv

// Generate Plot Symbols
   gen _Fquantile = 0
	quietly  by _quantile , sort: gen _fquantile = _n
	quietly  by _quantile       : replace _Fquantile = _N if _n==1

// Correction for large Datasets
	sort _Fquantile 
	global maxynumber = _Fquantile[_N]
	global stepsize   = round($maxynumber/$ycatnumber)+1
	global stepsend   = $ycatnumber * $stepsize
   global typos      = ($stepsend/2)+5

	if $stepsize>1 & "`plotall'"=="" {
		quietly 	gen _newfquantile = .
		foreach value of numlist 1(1)`nq' {
			foreach yvalue of numlist 1(1)$ycatnumber {
					quietly replace _newfquantile = `yvalue' *$stepsize  if ///
					  inrange(_fquantile,((`yvalue'-1)*$stepsize),((`yvalue')*$stepsize))
					local durchgang = $durchgang+1
				}
			}
		quietly by _quantile _newfquantile $S_E_depv , sort : gen _marker = _N
		quietly by _quantile _newfquantile                  : replace _marker = -1 if _marker != _N
      quietly by _quantile _newfquantile $S_E_depv : replace _newfquantile = . if _n>1
		}
// Output
	capture {
		if $stepsize==1 | "`plotall'"!="" {
			twoway  ///
			  (scatter _fq _quantile if $S_E_depv == 0) ///
			  (scatter _fq _quantile if $S_E_depv != 0), ///
			  xtitle("Predicted Probability (%)") ytitle("Count") ///
			  legend(pos(6) cols(2) order(1 "Not $S_E_depv " 2 " $S_E_depv ")) ///
			  title("BRM") subtitle("Classification Plot") xlabel(0(10)100) ///
			  `options' 
		}
	if $stepsize>1 & "`plotall'"=="" {
		twoway  ///
			  (scatter _newfquantile _quantile if $S_E_depv == 0 & _marker!=-1 ) ///
			  (scatter _newfquantile _quantile if $S_E_depv != 0 & _marker!=-1 ) ///
			  (scatter _newfquantile _quantile if _marker==-1 ),  ///
			  xtitle("Predicted Probability (%)") ytitle("Count") ///
			  legend(pos(6) cols(3) ///
			  order(1 "Not $S_E_depv " 2 "$S_E_depv " 3 " $S_E_depv & not $S_E_depv"  ))  ///
			  title("BRM") subtitle("Classification Plot")  ///
			  note("NOTE: Each symbol represents 1 to $stepsize cases") xlabel(0(10)100) ///
			  `options'
			}
		}
if _rc!=0 {
		di as error "wrong twoway_option: No output generated"
		}	
// CLEAN UP Everything
	capture drop _yhat - _fquantile
	capture drop _newfquantile - _marker
     macro drop nq stepsend stepsize maxynumber ycatnumber catnumber
end

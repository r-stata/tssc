/* To run this dofile:
	qui findfile batcher.ado
	global examplePath = r(fn)
	global examplePath = subinstr("$examplePath", "batcher.ado", "exampleDofile.do", .)
	batcher $examplePath, i(1/2)
*/

sleep 200
global thread = `1'			// Not required, but conceptually clearer to use $thread than `1'

* Some examples
** Simple display of iteration number
if "$thread" == "1" di _newline _newline _newline "I was asked to display 1" _newline _newline _newline
if "$thread" == "2" di _newline _newline _newline "I was asked to display two" _newline _newline _newline
sleep 3000

** Run different regression specs
if "$thread" == "3" global indepvars "mpg trunk weight"
if "$thread" == "4" global indepvars "gear_ratio i.foreign length"

if inlist($thread, 3, 4) {
	sysuse auto
	di "reg price $indepvars"
	reg price $indepvars
	sleep 3000
}

** Collapse categories
if "$thread" == "5" global category 0
if "$thread" == "6" global category 1
if "$thread" == "7" global category 999

if inlist($thread, 5, 6, 7) {
	sysuse auto
	keep if foreign == $category
	collapse (mean) price
	sleep 3000
}



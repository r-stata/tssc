*! version 1.0.0 MALF 7.October.2017
*! cmatch: Stata module for tabulation of matched pairs in 1:1 case control study by exposure status
*! by Miguel Angel Luque-Fernandez [cre,aut]
*! Bug reports:
*! miguel-angel.luque at lshtm.ac.uk

/*
Copyright (c) 2017  <Miguel Angel Luque-Fernandez>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

program define cmatch
cap program drop cmatch

version 13.2
syntax varlist(min=3 max=3) [if] [in]

preserve

if "`if'"!="" | "`in'"!="" {
        qui keep `if' `in'
}
collapse (sum) "`2'" , by("`1'" "`3'") cw

qui reshape wide `2', i(`3') j(`1')
qui gen Controls = `2'0
qui gen Cases = `2'1
di in gr "1:1 matched pairs (case-control) by levels of the exposure variable: `2'"
tab Controls Cases
qui count if Controls==Cases
di in gr "Matched pairs by `2':  " as result `r(N)'
end


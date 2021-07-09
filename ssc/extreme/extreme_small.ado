*! extreme 1.1.0 20 January 2015
*! Copyright (C) 2015 David Roodman

* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.

* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.

* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.

cap program drop extreme_small
program define extreme_small, eclass
	version 11.0
	syntax, small(string) [smallreps(string) xivars(string)]
	if "`small'"=="cs" {
		cap local t = [xi]_cons<=-.2
		if "`xivars'"=="" & 0`t' {
			di _n as txt "Estimated xi parameter below -0.2. Small-sample correction not applied."
			ereturn local esttype ML
			exit
		}
	}
	tempname b b_bs V bsmall Vsmall
	mat `b' = e(b)
	mat `V' = e(V)
	mata extreme_small($ML_M, `=cond("`small'"=="cs", 0, 0`smallreps')')
	ereturn local esttype corrected
	local k = colsof(`b')
	ereturn matrix b_ML = `b'
	ereturn matrix V_ML = `V'
	ereturn repost b=`bsmall' `=cond("`small'"=="bs","V=`Vsmall'", "")'
	if "`small'"=="bs" {
		mat colnames `b_bs' = `:colfullnames e(b)'
		ereturn matrix b_bs = `b_bs'
	}
end

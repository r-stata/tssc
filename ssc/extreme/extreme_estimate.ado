*! extreme 1.2.0 17 May 2017
*! Copyright (C) 2015-17 David Roodman

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

cap program drop extreme_estimate
program define extreme_estimate, eclass
	version 11.0
	syntax, init(string) [xivars(passthru) depvarname(string) small(passthru) smallreps(passthru)]
	ml init `init'
	mata moptimize_init_search($ML_M, "off")
	mata st_view(_extremeDepVar, ., "`depvarname'")
	mata moptimize_init_userinfo($ML_M, 3, extreme_est_prep(_extremeDepVar))
	mata moptimize_init_userinfo($ML_M, 2, _extremeDepVar)
	mata moptimize($ML_M)
	mata moptimize_result_post($ML_M)
	if "`small'"!="" extreme_small, `xivars' `small' `smallreps'
end


*! version 1.2  18-Oct-2011
*! adapted from saveold ado file
*! Thanks to Nick Cox for highlighting the redundancy of the line indetifying Stata7 or lower.
program define save9
  version 8
  local 0 `"using `0'"'
  syntax using/ [, noLabel REPLACE ALL ]
	if "`replace'"=="" {
		confirm new file `"`using'"'
	}
  preserve
  ** line above is needed to preserve the dataset.
  display as text "This is Stata " c(stata_version) " software:"
  if c(stata_version)>=13                       display as text "Stata " c(stata_version) " cannot save in Stata 9 format."
  if c(stata_version)>=10 & c(stata_version)<13 save `"`using'"', oldformat `label' `replace' `all'
  if c(stata_version)>=10 & c(stata_version)<13 display as text "in Stata 9 format by using the option: oldformat."
  if c(stata_version)>= 8 & c(stata_version)<10 save `"`using'"',           `label' `replace' `all'
  if c(stata_version)>= 8 & c(stata_version)<10 display as text "in Stata 9 (or 8) format without using the option: oldformat."
end
** end of program
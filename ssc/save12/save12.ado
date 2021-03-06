*! version 1.0.0  9oct2016  Michael Stepner, stepner@mit.edu

/*** Unlicense (abridged):
This is free and unencumbered software released into the public domain.
It is provided "AS IS", without warranty of any kind.

For the full legal text of the Unlicense, see <http://unlicense.org>
*/

* Why did I include a formal license? Jeff Atwood gives good reasons:
*  https://blog.codinghorror.com/pick-a-license-any-license/

program define save12
	version 12
	
	syntax [anything], [noLabel replace all]

	if c(stata_version)>=12 & c(stata_version)<13 {
		save `anything', `label' `replace' `all'
	}
	else if c(stata_version)>=13 & c(stata_version)<14 {
		saveold `anything', `label' `replace' `all'
	}
	else if c(stata_version)>=14 {
		saveold `anything', `label' `replace' `all' version(12)
	}
	else {
		di as error "Must have Stata version 12 or higher to save in Stata 12 format."
		error 499
	}

end

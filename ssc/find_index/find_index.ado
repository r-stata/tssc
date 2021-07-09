/*
find_index.ado  2019mar25
Originally part of gen_lifecycle_matrices.ado, from the life_science_1 project.
Changing the syntax, though.

(gen_lifecycle_matrices.ado should be moving to ado now.)

2020jun02: return a scalar, rather than a local. Hopefully, this will not break
older uses of this. Also obtain index value as a scalar, rather than a local.

*/


prog def find_index, rclass

version 14
*! version 1.0.1 2020jun02

syntax if , [low high debug verbose]
/*
Note that -if- is required

low: if multiple indices exist, take the lowest;
high: if multiple indices exist, take the highst.
Otherwise, require that it be unique.

verbose is a synonym for debug. Added later, as a more appropriate word for what
debug does. Concievably, they could be made to have differing effects; as of
2019mar26, they are the same.

*/

if "`verbose'" ~= "" {
	local debug "debug"
}

if "`low'" ~= "" & "`high'" ~= "" {
	disp as err "you may not specify both low and high"
	exit 198
}



tempvar n1
gen long `n1' = _n
sum `n1' `if' , meanonly
capture assert ~mi(r(min))
if _rc {
	disp as err `"cannot find index for condition `if'"'
	exit 459
}
capture assert ~mi(r(max))
if _rc {
	/* should not get here */
	disp as err `"cannot find index for condition `if'"'
	exit 459
}

tempname index

scalar `index' = r(min)
if "`high'" ~= "" {
	scalar `index' = r(max)
}

if "`low'" == "" & "`high'" == "" {
	capture assert r(min) == r(max)
	if _rc {
		disp as err `"cannot find unique index for condition `if'"'
		exit 459
	}
}
return scalar index = scalar(`index')
if "`debug'" ~= "" {
	disp `"index for `if': "' scalar(`index')
}
end /* find_index*/

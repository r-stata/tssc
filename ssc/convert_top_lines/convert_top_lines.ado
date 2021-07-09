/*
ado\convert_top_lines.ado  5-11-2005

David Kantor
Institute for Policy Studies
Johns Hopkins University


This is adapted from code orininally in census2000\readcen01
(or a subdirectory), now apparently deleted, but which was retained as reserve
code in census2000\county\readcen04.do.
That code became unnecessary as later downloads of Census data were done
without the "descriptive data elements", but the situation does show up
occasionally.  Thus, the code it is being made into an ado.

*/


prog def convert_top_lines
/*

Sometimes csv (comma-separated-value) files have the variable names in line 1.
If the data follow, starting on line 2, then -insheet- knows what to do, and
uses that first line as the variable names.

Other times, the first line has the variable names, and the second line has
descriptive information -- suitable as variable labels.

-insheet- is not savvy enough to handle that situation, and will...
 a, use default names, v1, v2, v3, etc. (Even though the names are present
  in line 1, the data on line 2 prevents it from being used.)
 b, use long string datatypes, such as str51 and the like -- to be able to
  store those descriptions, though it is only that one line that has such
  data.  Often, the real content data is numeric, even byte.

This program is meant to partly remedy that situation.
It will first check that all the variables are names v1, v2, etc..
It will rename the variables, and, optinally, use line 2 as labels.
It will optionally drop those lines.

Aferwards, it is your job to fix the types (maybe -destring-).


See convert_top_lines.hlp (or -help convert_top_lines-) for more information
on this.

*/
*! version 1.2  5-12-2005
version 8.2

syntax, [line2labels drop list]

/*
This will always take variable names from line 1.
The taking of labels from line 2 is optional -- invoked by the
-line2labels- option.


This always operates on all the variables.
*/


/*
First, check that all the variables are named v1, v2, etc..
*/

qui des
local numvars= r(k)

forvalues j=1/ `numvars' {
 capture confirm var v`j'
 if _rc {
   disp as error "var v`j' not found"
   exit 459
 }
}

/* disp "convert_top_lines point 1" */

/*

Note that, though line 2 has info suitable as labels, some
are >80 chars long.  They get truncated; oh well; there may be some ambiguity
in the resulting labels; yoy may need to consult data documentation for an
explanation.

Note that if this were to run under Stata/SE, then these values would not get
truncated as data -- BUT they would get truncated as var labels, since that
is still at a max of 80 even for Stata/SE.

A -note- is generated if 

*/

local maxlabellength "80"
/* I would prefer a c() value, but none exists.  c(maxstrvarlen) is close, and
possibly relevant, but not exactly right.
*/


forvalues j=1/ `numvars' {
 if "`line2labels'" ~= "" {
  local label "`=v`j'[2]'"
  label var v`j' "`label'"
  if length("`label'") >= `maxlabellength' {
   notes v`j': var label may be truncated
  }
 }
 ren v`j'  `=lower(v`j'[1])'
}

/* disp "convert_top_lines point 2" */


if "`list'" ~= "" {
 forvalues j = 1/3 {
  disp _new "`j'."
  list in `j', noobs
 }
}

if "`drop'" ~= "" {
 local linestodrop = cond("`line2labels'" ~= "", 2, 1)

 /* disp  "linestodrop: `linestodrop'" */
 drop in 1 / `linestodrop'  // remove header lines

}


end  // convert_top_lines


/* End of convert_top_lines.ado */

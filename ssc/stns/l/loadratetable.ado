*! version 1.2 17févnov2014
program loadratetable
version 12.1, missing
syntax using/ [, rate(name) age(name) period(name) strata(namelist) origin(string) interpolate(integer 0) ///
               interpage(integer 1) interpdate(integer 1) ///
               strictage strictdate ///
               name(string) save  replace]
/* read a rate table in file "using" and put it in a ratetable object */
/*

if rate age and period are diven, using must be a dta file,
       - rate is the name of the variable containing the survival rate
       - age  is the name of the variable containing age class
       - period is the name of the variable containing time class
       - strata  is the list of stratifying variables (one table per straum)
       - origin is the origin date of the period variable (format DMY)
       - if save is TRUE, the table is saved in compiled mata file
*/


if `"`name'"' == "" {
  local name = "`using'"
}

if `"`strictage'"' == "" {
  local strictage = "nostrictage"
}

if `"`strictdate'"' == "" {
  local strictdate = "nostrictdate"
}


if "`rate'" == "" {
/* load a ratetable class object */


        loadratetableobject using `using', `replace' name(`name') 
}
else {
/* load a dta in a ratetable class object */

if `"`origin'"' == "" {
  local origin = "01jan1960"
}
preserve 


  qui use `"`using'"', clear 	/* Use ratetable dta */
		
  loadratetabledta , rate(`rate') age(`age') period(`period') strata(`strata') origin(`origin') ///
    interpolate(`interpolate')  ///
      interpage(`interpage') interpdate(`interpdate') ///
        `strictage' `strictdate' ///
          name(`name') `save' `replace'
  
  restore, preserve
}

  
end


program  loadratetableobject
syntax  using/ [, replace name(string)]
/* à voir selon l'option save de loadratetabledta */
if `"`name'"' == "" {
  local name = "`using'"
}

mata:  `name' = load_ratetable("`using'")
* di "`using' lifetable loaded in object `name'"

end

program loadratetabledta
syntax [using/] , rate(varname numeric) age(varname numeric) period(varname numeric) [agefactor(real 1) datefactor(real 1)          ///
                                                                                      strata(varlist) origin(string) 				///
                                                                                      interpolate(integer 0) 						///
                                                                                      interpage(integer 1) interpdate(integer 1) 	///
                                                                                      strictage strictdate 							///
                                                                                      name(string) save  replace]                   ///
/* load a stata table in file `using' and put it in a ratetable object */
/* input
using : name of the dta file
rate  : name of the variable containing rate
age   : name of the variable contain age (in days)
period : name of the variable containig the rate
agefactor  : factor so that factor*age is in days
datefactor : factor so that factor*period is in days
strata : list of variables defining stratas (factor variable)
origin : origin for the coding of period
interpolate : 0 no interpolation, 1 linear interpolation
interpage  : 1 no interpolation, else number of subclasses
interpdate : 1 no interpolation, else number of subclasses
strictage  : !=1 if rates before first age is rate of first age class
strictdate : !=1 if rates before first date is rate of first date class
name  : name of the mata object where to save the rate
save  : if the ratetable should be saved in a file
replace : replace mata object if necessary
*/

if `"`using'"' != "" {
  preserve
  qui use `"`using'"', clear 	/* Use ratetable dta */
}
  if `"`origin'"' ==""  local origin = "01jan1960"
  if `"`agefactor'"' ==""  local agefactor = 1
  if `"`datefactor'"' ==""  local datefactor = 1

  local strtage = 0
  if `"`strictage'"' == "strictage"  local strtage = 1

  local strtdate = 0
  if `"`strictdate'"' == "strictdate"  local strtdate = 1

 
capture mata: `name'=convertratetable("`rate'", "`age'", "`period'", "`strata'", "`origin'", `agefactor', `datefactor', `interpolate', `interpage', `interpdate', `strtage', `strtdate', "`name'")
*di "`using' lifetable datafile saved in object `name'"



if `"`save'"'!= "" {
/* save in a file as a structure  */
tempfile saveclass
mata: `name'.save("`saveclass'", "w")
copy "`saveclass'"  "`name'" , `replace'
di "`name' lifetable object saved in file `name'"

}
 
if `"`using'"' != "" {
  restore
}

end



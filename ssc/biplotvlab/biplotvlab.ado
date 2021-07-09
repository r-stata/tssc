*! version 1.0.1  30sep2005
*! The first version of this module has been wroten by Ken Higbee (StataCorp)
*! Improvements by Jean-Benoit Hardouin

program biplotvlab

       version 9

       syntax varlist(numeric min=2) [if] [in] [, LABdes(string) stretch(int 1) *]

    // run biplot quietly (and nograph) so we can get r(V)
       qui biplot `varlist' `if' `in' , `options' nograph
       tempname V
       mat `V' = r(V)
       local nbvar:word count `varlist'
       tokenize `varlist'

    // build the -text()- option
       local topt "text("
       local i 0
       local miny=`V'[1,2]
       local maxy=`V'[1,2]
       local minx=`V'[1,1]
       local maxx=`V'[1,1]
       forvalues i=1/`nbvar' {
          local miny=min(`V'[`i',2],`miny')
          local maxy=max(`V'[`i',2],`maxy')
          local minx=min(`V'[`i',1],`minx')
          local maxx=max(`V'[`i',1],`maxx')
       }
       if `maxx'*`minx'>0 {
          local coefx=max(abs(`maxx'),abs(`minx'))
          local coefx=`coefx'/20
       }
       else {
          local coefx=abs(`maxx'-`minx')/20
       }
       if `maxx'*`minx'>0 {
          local coefy=max(abs(`maxy'),abs(`miny'))
          local coefy=`coefy'/20
       }
       else {
          local coefy=abs(`maxy'-`miny')/20
       }
       forvalues i=1/`nbvar' {
        // y value
               if `V'[`i',2]>0 {
                  local topt `"`topt' `= (`V'[`i',2]+`coefy')*`stretch''"'
               }
               else {
                  local topt `"`topt' `= (`V'[`i',2]-`coefy')*`stretch''"'
               }
               // x value
               if `V'[`i',1]<0 {
                  local topt `"`topt' `= (`V'[`i',1]-`coefx')*`stretch''"'
               }
               else {
                  local topt `"`topt' `= (`V'[`i',1]+`coefx')*`stretch''"'
               }
               // variable label
               local lab: var label ``i''
               if "`lab'"=="" {
                  local lab ``i''
               }
               local topt `"`topt' `"`lab'"' "'
       }
       if "`labdes'"=="" {
          local labdes size(vsmall)
       }
       local topt `"`topt',`labdes')"'

    // call with -colopts(nolabel)- and -text()- just built
       biplot `varlist' `if' `in', `options' colopts(nolabel) `topt' stretch(`stretch')
end

*! version 1.0.0 20031022                                      (SJ4-2: st0060)

*  J. Levinsohn, A. Petrin, and B. Poi
*  Created: 20030520
*  predict after -levpet-
*  based on xtfront_p.ado and prais_p.ado

program define levpet_p

   version 7.0
   
   /* Command-specific options -- We'll ignore most of these */
   local myopts "OMEGA Cooksd Hat RSTAndard RSTUdent STDR STDF STDP"
   local myopts "`myopts' XB Index RESIDuals"
   
   /* Call _pred_se */
   _pred_se "`myopts'" `0'
   
   if `s(done)' == 1 {
      exit  /* Shouldn't happen since we're only allowing omega */
   }
   local vtyp `s(typ)'
   local varn `s(varn)'
   local 0 `"`s(rest)'"'
   
   /* Parse syntax */
   syntax [if] [in] [, `myopts']
   
   /* Now reject options we don't allow */
   local type "`cooksd'`hat'`rstandard'`rstudent'`stdr'`stdf'`stdp'"
   local type "`type'`xb'`index'`residuals'"
   
   if "`type'" != "" {
      di as error "option `type' not allowed"
      exit 198
   }
   
   /* At this point omega should be the only possibility left. */
   if "`omega'" == "" {
      noi di as error "You shouldn't see this.  wtf?"
      exit 2000
   }
   
   if "`omega'" != "" {
      tempname beta
      mat `beta' = e(b)
      tempvar rhs 
      mat score double `rhs' = `beta'
      loc lhs `e(depvar)'
      gen `vtyp' `varn' = exp(`lhs' - `rhs')
   }

end
   

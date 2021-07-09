*! NJC 1.0.0 6 Sept 2011
program xtpatternvar, sort
       version 9.2
       syntax [if] [in] , GENerate(name)

       confirm new var `generate'
       local g `generate'

       quietly {
               xtset
               local t `r(timevar)'
               local id `r(panelvar)'

               marksample touse
               count if `touse'
               if r(N) == 0 error 2000

               su `t' if `touse', meanonly
               local max = r(max)
               local min = r(min)
               local range = r(max) - r(min) + 1

               if `range' > 244 {
                       di as err "no go; patterns too long for str244"
                       exit 498
               }

               local miss : di _dup(`range') "."

               bysort `touse' `id' (`t') : ///
               gen `g' = substr("`miss'", 1, `t'[1]-`min') + "1" if _n == 1

               by `touse' `id' : replace `g' = ///
               substr("`miss'", 1, `t'- `t'[_n-1] - 1) + "1" if _n > 1

               by `touse' `id': replace `g' = ///
               `g' + substr("`miss'", 1, `max'-`t'[_N]) if _n == _N

               by `touse' `id' : replace `g' = `g'[_n-1] + `g' if _n > 1

               by `touse' `id' : replace `g' = cond(`touse', `g'[_N], "")

               compress `g'
       }
end


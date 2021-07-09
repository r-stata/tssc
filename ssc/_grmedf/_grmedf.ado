program define _grmedf
      gettoken type 0 : 0
      gettoken vn   0 : 0
      gettoken eqs  0 : 0    /* known to be = */
      syntax varlist(numeric) [if] [in]

      quietly{
         tokenize `varlist'
         marksample touse, novarlist
         tempvar index temp res nm
         g long `index'=_n
         g `type' `temp'=.
         local howmany : word count `varlist'
         expand `howmany'
         sort `index'
         local k=1
         while "``k''"~="" {
            by `index': replace `temp'=``k'' if _n==`k' & `touse'
            local k=`k'+1
         }
         sort `index' `temp'
         by `index': g byte `nm'=(`temp' < .)
         by `index': replace `nm'=sum(`nm')
         by `index': replace `nm'=`nm'[_N]
         #delimit ;
         by `index':
           g `type' `res'=(`temp'[`nm'/2]+`temp'[`nm'/2+1])/2
           if abs(mod(`nm',2))<0.1 & `touse';
           * dealing with an even number
           ;
         by `index':
           replace `res' =`temp'[(`nm'+1)/2]
           if abs(mod(`nm',2))>0.1 & `touse' ;
           * now, an odd number
           ;
         #delimit cr
         by `index': keep if _n==1
         g `type' `vn'=`res'
         lab var `vn' "The row median of `varlist'"
      }
end

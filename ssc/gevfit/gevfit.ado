*! version 2.0 September 15, 2014 David Roodman
*! version 1.0.3   February 21 2009 Scott Merryman
*! Based on on -betafit- by Cox, Jenkins, and Buis
* version 1.0.2   December 28, 2007 Maarten L. Buis
* version 1.0.1   November 02, 2007 Scott Merryman    

* changed to lf2 for speed by David Roodman, 9/8/14
cap program drop gevfit
program gevfit, eclass byable(recall)
        version 11.0
        syntax varlist(max=1)  [if] [in] [fw aw iw pw]  , [SCalevar(varlist numeric) SHapevar(varlist numeric) LOcationvar(varlist numeric) /// 
					Robust Cluster(varname) Level(integer $S_level) noLOG * ] 
        marksample touse 
        local y `varlist'
				
				global gev_scale_scalar = cond("`scalevar'"   =="", "scalar", "")
				global gev_shape_scalar = cond("`shapevar'"   =="", "scalar", "")
				global gev_loc_scalar   = cond("`locationvar'"=="", "scalar", "")
        
        local title "ML fit of GEV "
        local wtype `weight'
        local wtexp `"`exp'"'
        if "`weight'" != "" local wgt `"[`weight'`exp']"'  
                
        if "`cluster'" != "" { 
                local robust "robust"
                local clopt "cluster(`cluster')" 
        }
        
        if "`level'" != "" local level "level(`level')"
        local log = cond("`log'" == "", "noisily", "quietly") 
        
        mlopts mlopts, `options'
        global S_MLy `y'

				qui sum `y' if `touse', detail
				tempname b
				mat `b' = `=cond("`scalevar'"     =="", "`r(sd)'      ", "J(1,`:word count `scalevar'   ', 0), `r(sd)'      ")', ///
				          `=cond("`shapevar'"     =="", "`r(skewness)'", "J(1,`:word count `shapevar'   ', 0), `r(skewness)'")', ///
				          `=cond("`locationvar'"  =="", "`r(mean)'    ", "J(1,`:word count `locationvar'', 0), `r(mean)'    ")'

				`log' ml model lf2 gevfit_lf2 (scale:`scalevar') (shape:`shapevar') (location:`locationvar') `wgt' if `touse' , /// 
                maximize collinear title(`title') ///
                `robust'  search(on) init(`b', copy) `clopt' `level' `mlopts' `modopts' nopreserve

				global gev_scale_scalar 
				global gev_shape_scalar 
				global gev_loc_scalar

        eret local cmd "gevfit"
        eret local depvar "`y'"
	
        tempname b bscale bshape bloc
        mat `b' = e(b)
        mat `bscale' = `b'[1,"scale:"] 
        local nscale = colsof(`bscale')
        
        mat `bshape' = `b'[1,"shape:"]
        local nshape = colsof(`bshape')
        
        mat `bloc' = `b'[1,"location:"]
	local nloc = colsof(`bloc')
	
        eret matrix b_scale = `bscale'
        eret matrix b_shape = `bshape'
        eret matrix b_location = `bloc'
        eret scalar length_b_scale = `nscale'
        eret scalar length_b_shape = `nshape'
        eret scalar length_b_location = `nloc'
	
        if ("`scalevar'`shapevar'`locationvar'"!="" ) {
                eret scalar nocov = 0
        }
	
        if "`scalevar'`shapevar'`locationvar'"=="" {
                tempname e              

                mat `e' = e(b)
                local scale = `e'[1,1]
                local shape = `e'[1,2]
                local location = `e'[1,3]
	
                eret scalar bscale = `scale'
                eret scalar bshape = `shape'
                eret scalar blocation = `location'
        
                eret scalar nocov = 1
	}

        Display, `level' `diopts'
        
end

cap program drop Display
program Display
        syntax [, Level(int $S_level) *]
        local diopts "`options'"
        ml display, level(`level') `diopts'
        if `level' < 10 | `level' > 99 local level = 95
end


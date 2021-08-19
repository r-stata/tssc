/*

    mimpt -- Impute missing values, persist in case of non-convergence
    
    Syntax
    
        mimpt <mi_impute_cmdline> , add(#) skipnonconvergence(#) [ <options> ]
    
        where <mi_impute_cmdline> is the same as with -mi impute-
        
    
    Description
    
        mimpt is a wrapper for -mi impute- that persits in case of 
        non-convergence of the imputation model.
    
    
    Options
    
        add(#)                is required and it is the same option used  
                              with -mi impute-.
        
        skipnonconvergence(#) specifies how many errors due to 
                              non-convergence are ignored.
                              
        blocksize(#)          specifies how many imputations are added 
                              at a time. The default is blocksize(1).
                              
        rseed(#)              is implemeted in terms of -set seed-.
                              
        <options>             are any options for -mi impute-.

*/

*! version 0.0.2 03mar2021 daniel klein
program mimpt
    version 12.1
    
    syntax anything(everything equalok) [ fw aw pw iw ] ///
    ,                                                   ///
        ADD(numlist integer max=1 >0 <=1000)            ///
        SKIPNONCONVERGENCE(numlist integer max=1 >=0)   ///
    [                                                   ///
        BLOCKSIZE(numlist integer max=1 >0)             ///
        RSEED(string asis)                              ///
        *       /// any -mi impute- options are passed thru
    ]
    
    if (`"`weight'"' != "") local weight [`weight' `exp']
    
    if ( mi("`blocksize'") ) local blocksize 1
    else {
        if ( !inrange(`blocksize', 1, `add') ) {
            display as err "blocksize() invalid --" _continue
            error 125
        }
        if ( mod(`add', `blocksize') ) {
            display as err "add() must be a multiple of blocksize()"
            exit 125
        }
    }
    
    if (`"`rseed'"' != "") version `= _caller()' : set seed `rseed'
    
    local M    0
    local fail 0
    
    preserve
    
    while ( (`M'<`add') & (`fail'<=`skipnonconvergence') ) {
        
        version `= _caller()' : capture noisily ///
            mi impute `anything' `weight' , add(`blocksize') `options'
        
        if ( _rc ) {
            if (_rc != 430) exit _rc
            local ++fail
        }
        else local M = `M' + `blocksize'
        
    }
    
    if ( `fail' ) {
        if (`fail' > `skipnonconvergence') exit 430
        display as txt _newline "Warning: the imputation model failed " ///
            "to converge " as res `fail' as txt " " plural(`fail', "time")
    }
    
    restore , not
end
exit

/* --------------------------------------
0.0.2 03mar2021 respect caller version
0.0.1 26feb2021 first release on SSC
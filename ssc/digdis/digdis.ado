*! version 1.0.0  28jun2007  Ben Jann

program define digdis, rclass byable(recall)
    version 9.2
    syntax varlist [if] [in] [fw] [,    ///
        Replace                         /// replace existing variables
        Generate(namelist)              /// generate variable containing digits
        Position(passthru)              /// digit position
        Base(passthru)                  /// base of number system
        Decimalplaces(passthru)         /// number of decimal places of varname
        BENford UNIform                 /// reference dist.
        Matrix(passthru)                /// custom reference dist.
        by(passthru)                    /// by-groups
        nofreq                          /// suppress frequency table
        noTESt TESt2(str asis)          /// goodness-of-fit test
        ci CI2(str asis)                /// pointwise confidence intervals
        Level(passthru)                 /// confidence level
        GRaph                           /// display graph
        PERcent FRACtion count          /// graph scale
        CIOPTs(passthru)                /// graph options for ci
        noref REFOPTs(passthru)         /// graph options for reference dist.
        plot(passthru)                  /// add plot
        BYOPTs(passthru)                /// by() graph options
        *                               /// twoway_options (also twoway_bar)
        ]
    if `"`ci2'"'!="" local ci ci
    if "`graph'"=="" & `"`options'"'!="" {
        di as err `"`options' not allowed"'
        exit 198
    }
    local nvar: list sizeof varlist
    if `nvar'>1 & "`by'"!="" {
        di as err "only one variable allowed if by() is specified"
        exit 198
    }

/// mark sample
    marksample touse

/// extract
    if "`generate'"=="" {
        forv i=1/`nvar' {
            tempvar tmp
            local generate `generate' `tmp'
        }
    }
    _digdis extract `varlist' if `touse' ,  ///
        generate(`generate') `replace'      ///
        `position' `base' `decimalplaces'

/// tabulate
    local qui = cond("`freq'"=="", "", "quietly")
    `qui' _digdis tabulate `generate' if `touse' [`weight'`exp'] ,    ///
        `position' `base' `benford' `uniform' `matrix' `by'           ///
        origvarnames(`varlist')

/// goodness-of-fit test
    if "`test'"=="" {
        if "`freq'"=="" {
            di as txt ""
            if `"`by'"'!="" di as txt "{hline}"
        }
        _digdis test , `test2'
    }

/// compute confidence intervals
    if "`ci'"!="" {
        _digdis ci , `level' `ci2'
    }

/// display graph
    if "`graph'"!="" {
        tempvar tmp1 tmp2 tmp3 tmp4 tmp5 tmp6
        _digdis save `tmp1' `tmp2' `tmp3' `tmp4' `tmp5' `tmp6', ///
            `percent' `fraction' `count'
        _digdis graph, ///
            `ciopts' `ref' `refopts' `plot' `byopts' `options'
    }

/// returns
    return add
    ret local savenames ""
    ret local savescale ""
end

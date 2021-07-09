*! mpi
*! version 1.0.3 16jun2017
*! Author: Daniele Pacifico, daniele.pacifico@oecd.org
*! Author: Felix Pöge, felix.poege@ip.mpg.de

/* ---------------------------------------------------------------------------

Computing Main Indicators

    - If the by-option is specified, ONLY the by-version is returned.
    - Do not call independently.

--------------------------------------------------------------------------- */

program define _mpi_main, sortpreserve rclass

    syntax anything(equalok)

    quietly {

        // Read in all the to-be-used locals supplied to the program.
        foreach pair in `*' {
            local eq_pos = strpos("`pair'", "=")
            local before = substr("`pair'", 1, `eq_pos'-1)
            local after = substr("`pair'", `eq_pos'+1, .)
            local `before' = "`after'"
        }

        tempname res resV res_add resV_add

        /*
            If a by-option was specified, prepare the respective statements.
        */
        if "`by'" != "" {
            local over_statement = ", over(`by', nolabel)"
        }
        else {
            local over_statement = ""
        }

        /*
            Check if all individuals are non-poor, as this requires additional
            messages below.
        */
        cap assert `_H' == 0
        if _rc == 9 {
            local warn_no_poor = 0
        }
        else {
            error _rc
            local warn_no_poor = 1
        }

        local main_eval = "`_H' `_M0'"
        // "Average Deprivation Share Among Poor"
        local add_eval = "(`_M0' / `_H')"

        // If possible, compute poverty gaps
        if `use_thresholds' {
            // `gap_1': "Adjusted Multidimensional Deprivation Gap"
            // G = |g1|/|g0|
            // `gap_2' "Adjusted Squared Multidimensional Deprivation Gap"

            local add_eval = "`add_eval' (`gap_1' / `_M0') (`gap_2' / `_M0')"

            // M1 = H*A*G = M0*G (gap 1)
            // M2 = H*A*S(2) = M0*S(2) (gap 2)
            local main_eval = "`main_eval' `gap_1' `gap_2'"

            // Computing M_alpha
            foreach a of local alpha {
                if inlist(`a', 1, 2) {
                    continue
                }
                local a_name = subinstr("`a'", ".", "p", .)
                local a_name = subinstr("`a_name'", "-", "m", .)

                // `gap_`a_name'' "Adjusted Multidimensional Deprivation Gap with transformation alpha"
                local main_eval = "`main_eval' `gap_`a_name''"
                local add_eval = "`add_eval' (`gap_`a_name'' / `_M0')"
            } // end alpha iteration
        } // end use_thresholds

        /*
            Perform the evaluation
        */
        `svy' mean `main_eval' `weight_exp' `l_if' `over_statement'
        matrix `res' = e(b)
        matrix `resV' = e(V)
        local N = e(N)

        // The additional variables (A, G, S, ...) will not be by-decomposed.
        if "`by'" == "" {
            `svy' ratio `add_eval' `weight_exp' `l_if'
            matrix `res_add' = e(b)
            matrix `resV_add' = e(V)

            /*
                There (used to?) exist a bug in Stata where a ratio of (x / y) with y=0 returns invalid
                values in e(V). This code here will detect the invalid entries and replace them
                with zero.
                Then, the behavior is equivalent to a zero-variation entry.
                See:
                http://www.statalist.org/forums/forum/general-stata-discussion/general/1348095-create-or-test-for-1-ind-in-a-matrix
            */
            local cols = colsof(`resV_add')
            forvalues i = 1/`cols' {
                forvalues j = 1/`cols' {
                    // The entry is not missing if unmodified, but if
                    // used in a formula, it becomes missing.
                    if missing(1 * `resV_add'[`i', `j']) & !missing(`resV_add'[`i', `j']) {
                        matrix `resV_add'[`i', `j'] = 0
                    }
                }
            }

            // Checking the computation: M0 = H*A
            local H = `res'[1, 1]
            local M0 = `res'[1, 2]
            local A = `res_add'[1, 1]
            capture assert abs(`M0' - `H'*`A') < `assertion_sensitivity' | ///
                           (missing(`M0') | missing(`H'*`A'))
            if _rc == 9 {
                noi di as error "Computation M0 failed. M0=`M0' H=`H' A=`A'."
            }
            else {
                error _rc
            }

            if `use_thresholds' {
                local G = `res_add'[1, 2]
                local S = `res_add'[1, 3]
                local M1 = `res'[1, 3]
                local M2 = `res'[1, 4]
                local alt_M1 = `M0'*`G'
                cap assert abs(`M1' - `alt_M1') < `assertion_sensitivity' | ///
                           (missing(`alt_M1') | missing(`M1'))
                if _rc != 0 {
                    noi display as error "Computation M1 failed (`alt_M1' vs. " `M1' ")"
                }

                local alt_M2 = `M0'*`S'
                cap assert abs(`M2' - `alt_M2') < `assertion_sensitivity' | ///
                           (missing(`M2') | missing(`alt_M2'))
                if _rc != 0 {
                    noi display as error "Computation M2 failed (`alt_M2' vs. " `M2' ")"
                }
            }
        }


        /*
            Calculating proportional results in the case of there being a by-variable.
        */

        if "`by'" != "" {

            // Naming the matrix (for later)
            local levelnames = e(over_namelist)

            // Estimate the proportional contribution
            tempname res_perc res_percV

            // Ratios to evaluate in the end.
            local ratios = ""

            local lvl_idx = 0
            foreach i of local levelnames {
                local lvl_idx = `lvl_idx' + 1
                tempvar l_H_`lvl_idx'
                gen `l_H_`lvl_idx'' = `_H' * (`by' == `i')
                local ratios = "`ratios' (`l_H_`lvl_idx''/`_H')"
            }

            foreach i of local levelnames {
                local lvl_idx = `lvl_idx' + 1
                tempvar l_M0_`lvl_idx'
                gen `l_M0_`lvl_idx'' = `_M0' * (`by' == `i')
                local ratios = "`ratios' (`l_M0_`lvl_idx''/`_M0')"
            }

            // M_alpha
            if `use_thresholds' {
                foreach a of local alpha {
                    local a_name = subinstr("`a'", ".", "p", .)
                    local a_name = subinstr("`a_name'", "-", "m", .)
                    foreach i of local levelnames {
                        local lvl_idx = `lvl_idx' + 1
                        tempvar l_M`a_name'_`lvl_idx'
                        gen `l_M`a_name'_`lvl_idx'' = `gap_`a_name'' * (`by' == `i')
                        local ratios = "`ratios' (`l_M`a_name'_`lvl_idx'' / `gap_`a_name'')"
                    }
                }
            }

            `svy' ratio `ratios' `weight_exp' `l_if'
            matrix `res_perc' = e(b)
            matrix `res_percV' = e(V)

            /*
                There (used to?) exist a bug where a ratio of (x / y) with y=0 returns invalid
                values in e(V). This code here will detect the invalid entries and replace them
                with zero.
                Then, the behavior is equivalent to a zero-variation entry.
                See:
                http://www.statalist.org/forums/forum/general-stata-discussion/general/1348095-create-or-test-for-1-ind-in-a-matrix
            */
            local cols = colsof(`res_percV')
            forvalues i = 1/`cols' {
                forvalues j = 1/`cols' {
                    // The entry is not missing if unmodified, but if
                    // used in a formula, it becomes missing.
                    if missing(1 * `res_percV'[`i', `j']) & !missing(`res_percV'[`i', `j']) {
                        matrix `res_percV'[`i', `j'] = 0
                    }
                }
            }

        } // End by exists?

        /*
            Name the absolute results created above.
        */
        local name_main = ""
        local name_add = ""
        if "`by'" == "" {
            // Labels and output of estimate matrix.
            local by_n_1 = `"Main"'
            local by_n_2 = `"Additional"'
            if `use_thresholds' == 0 {
                local name_main = `"`name_main' "Main:H" "Main:M0""'
                local name_add = `"`name_add' "Additional:A""'
            }
            else {
                local name_main = `"`name_main' "Main:H" "Main:M0" "Main:M1" "Main:M(2)""'
                local name_add = `"`name_add' "Additional:A" "Additional:G" "Additional:S(2)""'

                foreach a of local alpha {
                    if inlist(`a', 1, 2) {
                        continue
                    }
                    local a_name = subinstr("`a'", ".", "p", .)
                    local a_name = subinstr("`a_name'", "-", "m", .)

                    // `gap_`a_name'' "Adjusted Multidimensional Deprivation Gap with transformation alpha"
                    local main_eval = "`main_eval' `gap_`a_name''"
                    local add_eval = "`add_eval' (`gap_`a_name'' / `_M0')"

                    local a_name = subinstr("`a'", ".", ",", .)
                    local name_main = `"`name_main' "Main:M(`a_name')""'
                    local name_add = `"`name_add' "Additional:S(`a_name')""'
                } // end alpha iteration
            }
        } // End no by.
        else {
            local levels = `"`levelnames'"'

            if `use_thresholds' == 0 {
                foreach by_level of local levels {
                    local name_main = `"`name_main' "H:`by'_`by_level'" "M0:`by'_`by_level'""'
                }
            }
            else {
                local names = "H M0"
                foreach a of local alpha {
                    local a_name = subinstr("`a'", ".", "p", .)
                    local a_name = subinstr("`a_name'", "-", "m", .)
                    local names = "`names' M(`a_name')"
                } // end alpha iteration

                foreach name of local names {
                    foreach by_level of local levels {
                        local name_main = `"`name_main' "`name':`by'_`by_level'""'
                    }
                }
            }
        }

        /*
            Apply the naming for the standard results.
        */
        matrix rownames `res' = "Estimate"
        matrix colnames `res' = `name_main'
        matrix colnames `resV' = `name_main'
        matrix rownames `resV' = `name_main'

        // Additional results are only computed in the no-by case.
        if "`by'" == "" {
            matrix rownames `res_add' = "Estimate"
            matrix colnames `res_add' = `name_add'
            matrix colnames `resV_add' = `name_add'
            matrix rownames `resV_add' = `name_add'
        }
        // Proportional contributions only matter in the by-case.
        else {
            matrix rownames `res_perc' = "Estimate"
            matrix colnames `res_perc' = `name_main'
            matrix colnames `res_percV' = `name_main'
            matrix rownames `res_percV' = `name_main'
        }

        /*
            Return results.
        */

        return matrix mpi_main = `res'
        return matrix mpi_main_V = `resV'
        if "`by'" == "" {
            return matrix mpi_add = `res_add'
            return matrix mpi_add_V = `resV_add'
        }
        else {
            return matrix mpi_perc = `res_perc'
            return matrix mpi_perc_V = `res_percV'
            return local over_namelist `levelnames'
        }
        return scalar N = `N'

        // Remove the ereturn results that this program created.
        ereturn clear
    } // End quietly

end

/* ---------------------------------------------------------------------------

Decomposition of M_alpha by Indicator

    - If the by-option is specified, ONLY the by-version is returned.
    - Do not call independently.
--------------------------------------------------------------------------- */

program define _mpi_domains, sortpreserve rclass

    syntax anything(equalok)

    quietly {
        // Read in all the to-be-used locals supplied to the program.
        foreach pair in `*' {
            local eq_pos = strpos("`pair'", "=")
            local before = substr("`pair'", 1, `eq_pos'-1)
            local after = substr("`pair'", `eq_pos'+1, .)
            local `before' = "`after'"
        }

        /*
            If a by-option was specified, prepare the respective statements.
        */
        if "`by'" != "" {
            local over_statement = ", over(`by', nolabel)"
        }
        else {
            local over_statement = ""
        }

        tempname m m_V

        local tot_m0_shares = 0
        foreach a of local alpha {
            local a_name = subinstr("`a'", ".", "p", .)
            local a_name = subinstr("`a_name'", "-", "m", .)
            local tot_m`a_name'_shares = 0
        }
        local prev_ind = 0

        // The ratios to finally evaluate.
        local eval_ratio = ""

        // Iterate over domains
        forvalues j = 1 / `ndom' {
            local nind`j' = wordcount("`d`j''")

            /*
                Iterate over indicators, create the to-be-estimated variables.
            */
            forvalues i = 1 / `nind`j'' {
                local w = word("`w`j''", `i')
                local ind = word("`d`j''", `i')

                tempname m_`j'_`i'
                generate `m_`j'_`i'' = `ispoor_`j'_`i'' * `_H'

                // Generate the M_alpha as a share of total M0 for this indicator
                local eval_ratio = "`eval_ratio' (`m_`j'_`i'' / `_M0')"

                if `use_thresholds' {
                    tempname gap_poor
                    local a_idx = 1
                    foreach a of local alpha {
                        local a_idx = `a_idx' + 1
                        local a_name = subinstr("`a'", ".", "p", .)
                        local a_name = subinstr("`a_name'", "-", "m", .)
                        // Generate Malpha as share of total Malpha
                        // = (|galpha(select)|/|g0(total)|)/Malpha(total)
                        tempname gap_poor_`j'_`i'_`a_name'
                        gen `gap_poor_`j'_`i'_`a_name'' = `gap_`j'_`i'_`a_name'' * `_H'

                        if `a' == 1 {
                            local eval_ratio = "`eval_ratio' (`gap_poor_`j'_`i'_`a_name'' / `gap_1')"
                        }
                        else if `a' == 2 {
                            local eval_ratio = "`eval_ratio' (`gap_poor_`j'_`i'_`a_name'' / `gap_2')"
                        }
                        else {
                            local eval_ratio = "`eval_ratio' (`gap_poor_`j'_`i'_`a_name'' / `gap_`a_name'')"
                        }
                    }
                }
            }
        } // End iterating over domains

        // Calculating ratios.
        `svy' ratio `eval_ratio' `weight_exp' `l_if' `over_statement'
        matrix `m' = e(b)
        matrix `m_V' = e(V)

        /*
            There (used to?) exist a bug in Stata where a ratio of (x / y) with y=0 returns invalid
            values in e(V). This code here will detect the invalid entries and replace them
            with zero.
            Then, the behavior is equivalent to a zero-variation entry.
            See:
            http://www.statalist.org/forums/forum/general-stata-discussion/general/1348095-create-or-test-for-1-ind-in-a-matrix
        */
        local cols = colsof(`m')
        forvalues i = 1/`cols' {
            forvalues j = 1/`cols' {
                // The entry is not missing if unmodified, but if
                // used in a formula, it becomes missing.
                if missing(1 * `m_V'[`i', `j']) & !missing(`m_V'[`i', `j']) {
                    matrix `m_V'[`i', `j'] = 0
                }
            }
        }

        // Naming the matrix (for later)
        local levelnames = e(over_namelist)

        /*
            The problem at this point is that the results should be
            contributions. The weights need to be included to make the
            contributions add up to one.
        */
        tempname mat_weights
        local n_levels = cond("`by'" == "", 1, wordcount(`"`=e(over_namelist)'"'))
        local size = (wordcount("`alpha'") * `use_thresholds' + 1) * `ni' * `n_levels'
        matrix `mat_weights' = J(`size', `size', 0)
        local idx = 0
        forvalues j = 1 / `ndom' {
            forvalues i = 1 / `nind`j'' {
                if `use_thresholds' {
                    local iterate = "0 `alpha'"
                }
                else {
                    local iterate = "0"
                }
                foreach a of local iterate {
                    forvalues level = 1 / `n_levels' {
                        local idx = `idx' + 1
                        matrix `mat_weights'[`idx', `idx'] = `=word("`w`j''", `i')'
                    }
                }
            }
        }
        matrix `m' = `m' * `mat_weights'
        matrix `m_V' = `mat_weights'' * `m_V' * `mat_weights'

        if "`by'" == "" {
            local levels = `" "" "'
        }
        else {
            local levels = `"`levelnames'"'
        }

        // Holds the names for the estimated matrices.
        local names = ""

        /*
            Iterate over domains/indicators, create the labels.
        */
        forvalues j = 1 / `ndom' {
            forvalues i = 1 / `nind`j'' {
                local ind = word("`d`j''", `i')

                /*
                    Create the names for each indicator within each domain
                */
                if `use_thresholds' {
                    local idx = 0
                    local addlabel_alpha = ""
                    foreach a in 0 `alpha' {
                        local idx = `idx' + 1
                        local a_name = subinstr("`a'", ".", ",", .)
                        if "`a'" != "0" {
                            local a_name = "(`a_name')"
                        }
                        foreach by_level of local levels {
                            // Labels and output of estimate matrix.
                            if `"`by_level'"' != "" {
                                local by_n = `"`by'_`by_level':"'
                            }
                            else {
                                local by_n = `""'
                            }
                            local names = `"`names' "`by_n'`ind'_M`a_name'""'
                        } // Iterating over by-levels (if they exist)
                    } // Iterate over alpha levels.
                }
                else {
                    foreach by_level of local levels {
                        // Labels and output of estimate matrix.
                        if `"`by_level'"' != "" {
                            local by_n = `"`by'_`by_level':"'
                        }
                        else {
                            local by_n = `""'
                        }
                        local names = `"`names' "`by_n'`ind'_M0""'
                    } // Iterating over by-levels (if they exist)
                }
            } // Iterating over indicators
        } // Iterating over domains.

        /*
            Put the names.
        */
        matrix colnames `m' = `names'
        matrix colnames `m_V' = `names'
        matrix rownames `m_V' = `names'

        // Erase ereturn results created within this program
        ereturn clear

        return matrix mpi_decomposed = `m'
        return matrix mpi_decomposed_V = `m_V'
        if "`by'" != "" {
            return local over_namelist `levelnames'
        }
    } // End quietly

end

/*

    Full mpi program.

*/

program mpi, sortpreserve eclass

    cap syntax anything [in] [if] [pw fw], Cutoff(real) ///
        [by(varname) Alpha(numlist) ///
        Level(real -1) CATegories(integer 20) ///
        Svy SUBpop(passthru) ///
        NOSummary NODecomposition ///
        POSTMain POSTAdditional POSTIndicators POSTDomains ///
        POSTBYMain POSTBYProportion POSTBYIndicators POSTBYDomains ///
        DEPRIVEDDummy(namelist min=1 max=1) DEPRIVEDScore(namelist min=1 max=1)]

    // Take care of error messages when calling mpi through bootstrap.
    if _rc == 100 {
        local cmd = e(cmd)
        if `"`cmd'"' == "mpi" {
            noi display as text "Replaying last e(b) / e(V) results as mpi was started without options."
            noi display as text "This is normal for {help bootstrap}. Otherwise, see {help mpi} on how to specify options."
            noi cap noi ereturn display
            if _rc == 1 {
                error 1
            }
            else if _rc != 0 {
                noi _coef_table
            }
            exit
        }
        else {
            error _rc
        }
    }
    else {
        syntax anything [in] [if] [pw fw], Cutoff(real) ///
                [by(varname) Alpha(numlist) ///
                Level(real -1) CATegories(integer 20) ///
                Svy SUBpop(passthru) ///
                NOSummary NODecomposition ///
                POSTMain POSTAdditional POSTIndicators POSTDomains ///
                POSTBYMain POSTBYProportion POSTBYIndicators POSTBYDomains ///
                DEPRIVEDDummy(namelist min=1 max=1) DEPRIVEDScore(namelist min=1 max=1)]
    }

    quietly {

        version 13.0

        // Check that the correct amount of post-statements was given: zero or one.
        local cnt_list = 0
        foreach a in postmain postadditional postindicators postdomains ///
                 postbymain postbyproportion postbyindicators postbydomains {
            if "``a''" != "" {
                local cnt_list = `cnt_list'+1
            }
        }
        if `cnt_list' > 1 {
            noi display as error "Error: Supplied more than one option to list results in e(b) and e(V)." ///
                " This is not allowed, specify at maximum one."
            error 198
        }
        // Choose postmain as default option.
        else if `cnt_list' == 0 {
            local postmain = "postmain"
        }

        // Check that, if given, the deprived dummy/score variable does not exist.
        if "`depriveddummy'" != "" {
            noi confirm new var `depriveddummy'
        }
        if "`deprivedscore'" != "" {
            noi confirm new var `deprivedscore'
        }

        // Globally required names present everywhere
        tempvar sweight dscore gap_1 gap_2 _H _M0

        local var_submit = `"sweight=`sweight'"'
        local var_submit = `"`var_submit' dscore=`dscore'"'
        local var_submit = `"`var_submit' gap_1=`gap_1'"'
        local var_submit = `"`var_submit' gap_2=`gap_2'"'
        local var_submit = `"`var_submit' _H=`_H'"'
        local var_submit = `"`var_submit' _M0=`_M0'"'

        // Mark sample
        marksample touse

        // Prepare weights
        if "`exp'" != "" {
            generate `sweight' `exp'
        }
        else {
            generate `sweight' = 1
        }
        if "`weight'`exp'" != "" {
            local weight_exp = "[`weight'`exp']"
        }
        else {
            local weight_exp = ""
        }

        // Prepare svy usage
        if "`svy'" != "" {
            // Standard If and In are not allowed with svy.
            if "`if'" != "" & "`in'" != "" {
                noi display as error "Error: The svy option cannot be combined with if and in. Use the extended svy option."
                error 101
            }
            else if "`if'" != "" {
                noi display as error "Error: The svy option cannot be combined with if. Use the extended svy option."
                error 101
            }
            else if "`in'" != "" {
                noi display as error "Error: The svy option cannot be combined with in. Use the extended svy option."
                error 101
            }
            else if `"`subpop'"' != "" {
                // Get content between braces for subpop clause.
                local firstbrace = strpos(`"`subpop'"', "(")
                local lastbrace = -1
                forvalues i = 1/`=strlen(`"`subpop'"')' {
                    if substr(`"`subpop'"', `i', `i'+1) == ")" {
                        local lastbrace = `i'
                    }
                }
                // If the subpop clause is a variable, change it into an if statement.
                local subpop_clause = substr(`"`subpop'"', `firstbrace'+1, `lastbrace'-`firstbrace'-1)
                capture confirm variable `clause'
                if _rc == 0 {
                    local clause = `"if `clause'"''
                }

                local subpop_clause = substr(`"`subpop'"', 1, `firstbrace') + `"`clause'"' + substr(`"`subpop'"', `lastbrace', .)
                local svy = `"svy, `subpop': "'
            }
            else {
                local svy = "svy:"
            }
            local l_if = ""
        }
        // Standard: no svy, if as in touse
        else {
            local svy = ""
            local l_if = "if `touse'"
        }

        if `"`subpop'"' != "" & "`svy'" == "" {
            noi display as error "Error: The subpop option requires the svy option to be specified."
            error 101
        }

        // Prepare CI level
        if `level' == -1 {
            local level = c(level)
        }

        // As long as no weight information is given, assume weighting to be equal.
        local equalw = 1

        // Maximum Variable Length - to be generated later
        local max_var_length = -1

        // Sensitivity for all assumptions
        local assertion_sensitivity = 0.00001

        // To compute:
        // Number of indicators
        local ni = 0
        // Number of domains
        local ndom = 0
        // nidX: Number of indicators in each domain
        // dX: Domain X
        // wX: Weights X
        // thresX: Thresholds X
        // Whether thresholds for the indicators are given
        local use_thresholds = 0

        while strpos("`anything'", ")") > 0 {
            local entry = trim(substr("`anything'", 1, strpos("`anything'", ")")))
            local anything = substr("`anything'", strpos("`anything'", ")") + 1, .)
            // Argument type should be "w" or "d"
            local argtype = lower(substr(trim("`entry'"), 1, 1))
            if !(inlist("`argtype'", "w", "weight", "d", "dom", "domain") ///
                 | inlist("`argtype'", "t", "thres", "threshold", "p", "poor")) {
                noi display as error "Only domains (d), weights (w) or thresholds (t) can be supplied. Found: '`argtype'"
            }
            // Get the number of weight / indicator
            local brstartpos = strpos("`entry'", "(")
            local idx = trim(substr("`entry'", 2, `brstartpos'-2))
            capture confirm number `idx'
            if _rc != 0 {
                noi display as error "Argument '`entry'' did not follow the proper form, after d/w should follow the index."
                error 197
            }
            else {
                error _rc
            }
            // Get content of brackets
            local inbr = substr("`entry'", `brstartpos' + 1, strpos("`entry'", ")") - `brstartpos' - 1)
            // Check that the variables exist if it is a domain
            if "`argtype'" == "d" | "`argtype'" == "dom" | "`argtype'" == "domain" {
                local count_ind = 0
                unab inbr : `inbr'
                foreach d of varlist `inbr' {
                    confirm var `d'
                    local count_ind = `count_ind' + 1
                    local max_var_length = max(`max_var_length', strlen("`d'"))
                }
                // Save the number of indicators for this domain
                local nid`idx' = `count_ind'
                local ni = `ni' + `nid`idx''
                local argtype = "d"
            }
            if "`argtype'" == "w" | "`argtype'" == "weight" {
                foreach w of local inbr {
                    confirm number `w'
                }
                local equalw = 0
                local argtype = "w"
            }
            if "`argtype'" == "t" | "`argtype'" == "thres" | "`argtype'" == "threshold" {
                /* Threshold definitions:
                An individual is poor if the value of the indicator is below the threshold.
                A person at the threshold is always not poor.
                For this, all the threshold arguments need to be specified without
                spaces in between.                                              */
                local inbr_new = ""
                foreach t of local inbr {
                    confirm number `t'
                    local inbr_new = "`inbr_new' `t'"
                }
                local use_thresholds = 1
                local argtype = "thres"
                local inbr = "`inbr_new'"
            }

            // Set weight / indicator
            local `argtype'`idx' = "`inbr'"
            local ndom = max(`idx', `ndom')
        }

        // Make sure that at least 1 domain is specified.
        if `ndom' == 0 {
            noi display as error "No deprivation domains specified"
            error 197
        }

        // If no thresholds are in use, every threshold is, by definition, 1.
        // >0.99 is used instead of 1 since the poverty is defined as being strictly
        // lower or higher than the cutoff, which would otherwise cause problems in
        // datasets without explicit thresholds.
        if `use_thresholds' == 0 {
            forvalues i = 1 / `ndom' {
                local thres`i' = ""
                forvalues j = 1/`nid`i'' {
                    local thres`i' = "0.99 `thres`i''"
                }
            }
        }

        // Make sure that no domains or weights are missing
        forvalues idx = 1/`ndom' {
            if ("`d`idx''" == "") {
                noi display as error "Deprivation domain `idx' not specified"
                error 197
            }
            if (`equalw' == 0) & ("`w`idx''" == "") {
                noi display as error "Weight `idx' not specified."
                error 197
            }
            if (`equalw' == 0) & (wordcount("`w`idx''") != `nid`idx'') {
                noi display as error "Vector w`idx'(`w`idx'') does not have the same number of elements as the number of indicators in domain d`idx'(`d`idx'')"
                error 197
            }
            // Check that all thresholds are given, always.
            if (wordcount("`thres`idx''") != `nid`idx'') {
                noi display as error "Vector thres`idx'(`thres`idx'') does not have the same number of elements as the number of indicators in domain d`idx'(`d`idx'')"
                error 197
            }
        }

        // Make sure that alpha does not include 0, 1 and 2, they are computed by default.
        local newalpha = ""
        foreach a of local alpha {
            if !inlist(`a', 0, 1, 2) {
                local newalpha = "`newalpha' `a'"
            }
        }
        local alpha = "1 2 `newalpha'"

        // Check if any observations are left
        tempname all_missing
        gen `all_missing' = 0
        forvalues i = 1 / `ndom' {
            foreach vari of varlist `d`i'' {
                replace `all_missing' = `all_missing' | missing(`vari')
            }
        }
        if "`by'" != "" {
            replace `all_missing' = 1 if missing(`by') & `touse'
        }
        count if `all_missing' & `touse'
        if r(N) == _N {
            // No observations
            error 2000
        }

        // Exclude missing values from the estimation sample
        count if `all_missing' == 1
        if r(N)>0 {
            noi display in gr "Note: Missing values encountered, excluding them."
            recode `all_missing' 1=.
            markout `touse' `sweight' `all_missing'
        }
        drop `all_missing'

        // Make sure that all variables are ordinal or all variables are real-valued.
        // Guess the type of each variable by the number of observations
        local error_message = ""
        local t_vars = ""
        forvalues i=1/4 {
            local msg_`i'_shown = 0
        }
        tempvar dist_obs
        forvalues i = 1 / `ndom' {
            local vartype`i' = ""
            foreach vari of varlist `d`i'' {
                bys `vari': gen `dist_obs' = (_n == 1)
                count if `dist_obs'
                local n_dist_obs = r(N)
                // Likely ordinal or even binary, see syntax for the origin of
                // the local
                if `n_dist_obs' <= `categories' {
                    // Set the expected variabe type for subsequent iterations if it is not set.
                    if "`t_vars'" == "" {
                        if (`n_dist_obs' == 2) {
                            local t_vars = "Binary"
                        }
                        else {
                            local t_vars = "Ordinal"
                        }
                    }
                    // The first detected variable was real-valued but now it looks binary.
                    else if ("`t_vars'" == "Real-valued") & (`n_dist_obs' <= 2) {
                        if !`msg_1_shown' {
                            local error_message = `"`error_message' ""' + ///
                                    `"Mixing binary (`vari') and real-valued indicators is not recommended: binary indicators automatically receive a higher weight during the calculation of the normalized poverty gaps. See {help mpi} for details." _n "'
                        }
                        local msg_1_shown = 1
                    }
                    // The first detected variable was real-valued but now it looks ordinal.
                    else if ("`t_vars'" == "Real-valued") & (`n_dist_obs' != 2) {
                        if !`msg_3_shown' {
                            local error_message = `"`error_message' ""' + ///
                                    `"Variable `vari' has little variation (less than `categories' categories) whereas other variables seem real-valued. "' + ///
                                    `"The statistical properties of AF indices with alpha>0 hold when the distance from the deprivation threshold can be measured correctly. "' + ///
                                    `"With ordinal and categorical variables the use of M0 (after dichotomisation into deprived and non-deprived states) is recommended.  See {help mpi} for details." _n"'
                        }
                        local msg_4_shown = 1
                    }
                    if `use_thresholds' {
                        if (`n_dist_obs' == 2) {
                            local vartype`i' = "`vartype`i'' Binary"
                        }
                        else {
                            local vartype`i' = "`vartype`i'' Ordinal"
                        }
                    }
                    else {
                        local vartype`i' = "`vartype`i'' Binary"
                    }
                }
                // The variable is likely real-valued
                else {
                    if "`t_vars'" == "" {
                        local t_vars = "Real-valued"
                    }
                    else if "`t_vars'" != "Real-valued" {
                        if !`msg_4_shown' {
                            local error_message = `"`error_message' "Variable `vari' is likely real-valued, but previous variables had little variation (less than `categories' categories). "' + ///
                                    `"The statistical properties of AF indices with alpha>0 hold when the distance from the deprivation threshold can be measured correctly. "' + ///
                                    `"With ordinal and categorical variables the use of M0 (after dichotomisation into deprived and non-deprived states) is recommended. See {help mpi} for details." _n"'
                        }
                        local msg_4_shown = 1
                    }
                    local vartype`i' = "`vartype`i'' Real-valued"
                }
                drop `dist_obs'
            }
        }

        // If equal weighting is specified, assign equal weights for every indicator.
        if `equalw' {
            local domshare = 1 / `ndom'
            forvalues i = 1 / `ndom' {
                local w`i' = ""
                local indshare = `domshare'/`nid`i''
                forvalues j = 1/`nid`i'' {
                    local w`i' = "`indshare' `w`i''"
                }
            }
        }

        confirm number `cutoff'

        // Check that relevant variables are numeric and get the number of missing values
        // Check that each variable contains only 0, 1 and missing entries if it is the
        // non-threshold case.
        forvalues j=1/`ndom' {
            foreach ind of varlist `d`j'' {
                capture confirm numeric variable `ind'
                if _rc != 0 {
                    noi display as error "Variable `ind' is not numeric."
                    exit 459
                }
                else {
                    error _rc
                }
                // If no thresholds are used, 0 is not poor and 1 is poor. Hence,
                // check that the variable contents match to the case.
                if `use_thresholds' == 0 {
                    capture assert inlist(`ind', 0, 1) | missing(`ind') | !`touse'
                    if _rc == 9 {
                        noi display as error "Variable `ind' contains values besides " ///
                            "0, 1 and missing. Supply indicators containing 1 for poor " ///
                            "and 0 for non-poor individuals or supply poverty thresholds."
                        exit 459
                    }
                    else {
                        error _rc
                    }
                }
            }
        }

        // Check if the supplied domainal weights add up to one:
        local totwcheck = 0
        forvalues j = 1/`ndom' {
            local countw = 1
            foreach ind of varlist `d`j'' {
                local w = word("`w`j''", `countw')
                local totwcheck = `totwcheck' + `w'
                local countw = `countw' + 1
            }
        }
        if abs(`totwcheck' - 1) > .01 {
            noi display in re "Total sum of weight is " _c
            noi display in ye `totwcheck' in re ", it should be 1."
            error 9
        }
        // If the difference between the weights is close to 1, scale them and the
        // cutoff to remove even the slight differences.
        else if abs(`totwcheck' - 1) > `assertion_sensitivity' {
            noi display in ye "Note: the total sum of weight was close to 1, the weights and the cutoff were rescaled to add up to exactly 1."
            forvalues j = 1/`ndom' {
                local new_weight = ""
                local countw = 1
                foreach ind of varlist `d`j'' {
                    local w = word("`w`j''", `countw')
                    local w  = `w' / `totwcheck'
                    local new_weight = "`new_weight' `w'"
                    local countw = `countw' + 1
                }
                local w`j' = "`new_weight'"
            }
            local cutoff = `cutoff' / `totwcheck'
        }

        if `totwcheck' < `cutoff' & "`noinitialcall'" == "" {
            noi display in re "Attention, cutoff is larger than the sum of weights. " _c
            noi display in ye "(C: `cutoff' W: 1). " _c
            noi display in re "No individual could possibly be poor."
        }

        // Create matrix of deprivation domains and overall deprivation score
        foreach a of local alpha {
            local a_name = subinstr("`a'", ".", "p", .)
            local a_name = subinstr("`a_name'", "-", "m", .)
            tempname gap_`a_name'
            generate `gap_`a_name'' = 0
            local var_submit = `"`var_submit' gap_`a_name'=`gap_`a_name''"'
        }
        generate `dscore' = 0
        forvalues j = 1/`ndom' {
            tempvar wdom`j'
            foreach a of local alpha {
                local a_name = subinstr("`a'", ".", "p", .)
                local a_name = subinstr("`a_name'", "-", "m", .)
                tempvar gap`j'_`a_name'
                generate `gap`j'_`a_name'' = 0
                local var_submit = `"`var_submit' gap`j'_`a_name'=`gap`j'_`a_name''"'
            }
            generate `wdom`j'' = 0
            c_local wdom`j' "`wdom`j''"
            local nind`j' = wordcount("`d`j''")
            forvalues i = 1 / `nind`j'' {
                local w = word("`w`j''", `i')
                local ind = word("`d`j''", `i')
                local threshold = word("`thres`j''", `i')
                // Poor if indicator < Threshold.
                // If no thresholds are defined: special case, threshold is at 0.99 and
                // above is poor (as the indicators will have value 1)
                // Always: Being at the threshold is NOT poor.
                local comparison = cond(`use_thresholds' == 0, 1, -1)
                tempvar ispoor_`j'_`i'
                generate `ispoor_`j'_`i'' = (`comparison'*(`ind' - `threshold') > 0) if !missing(`ind')
                local var_submit = `"`var_submit' ispoor_`j'_`i'=`ispoor_`j'_`i''"'
                replace `wdom`j'' = `wdom`j'' + `ispoor_`j'_`i''*`w'
                // Generate poverty gaps. Absolute value is to prevent negative values, which
                // can occur if the threshold is < 0.
                tempvar gap_`j'_`i'_1
                // Gap = [Poor]*[Achievement gap]/[Threshold]
                // Assuming that an individual is poor IF the indicator is higher
                // than the threshold. If the comparison is the other way round because of binary variables,
                // multiply by -1. (Done through *`comparison')
                generate `gap_`j'_`i'_1' = abs(`ispoor_`j'_`i''*`comparison'*(`ind'-`threshold') / `threshold')
                local var_submit = `"`var_submit' gap_`j'_`i'_1=`gap_`j'_`i'_1'"'
                replace `gap`j'_1' = `gap`j'_1' + `gap_`j'_`i'_1'*`w'
                foreach a of local alpha {
                    if `a' != 1 {
                        local a_name = subinstr("`a'", ".", "p", .)
                        local a_name = subinstr("`a_name'", "-", "m", .)
                        tempvar gap_`j'_`i'_`a_name'
                        generate double `gap_`j'_`i'_`a_name'' = `gap_`j'_`i'_1' ^ `a'
                        local var_submit = `"`var_submit' gap_`j'_`i'_`a_name'=`gap_`j'_`i'_`a_name''"'
                        cap assert `gap_`j'_`i'_`a_name'' >= 0
                        if _rc == 9 {
                            noi display as error "Problem in comparison, negative gap detected."
                        }
                        else {
                            error _rc
                        }
                        replace `gap`j'_`a_name'' = `gap`j'_`a_name'' + `gap_`j'_`i'_`a_name''*`w'
                    }
                }
            }
            replace `dscore' = `dscore' + `wdom`j''
            foreach a of local alpha {
                local a_name = subinstr("`a'", ".", "p", .)
                local a_name = subinstr("`a_name'", "-", "m", .)
                replace `gap_`a_name'' = `gap_`a_name'' + `gap`j'_`a_name''
            }
        }

        foreach a of local alpha {
            local a_name = subinstr("`a'", ".", "p", .)
            local a_name = subinstr("`a_name'", "-", "m", .)
            replace `gap_`a_name'' = 0 if `dscore' < `cutoff'
        }

        // Generate Multidimensional Deprivation Headcount (H)
        generate `_H' = (`dscore' >= `cutoff') if !missing(`dscore')

        // If the user wants a _H variable to be generated, do it.
        if "`depriveddummy'" != "" {
            generate `depriveddummy' = `_H' if `touse'
            label var `depriveddummy' "mpi: Dummy multidimensionally deprived"
            label define `depriveddummy'_deprived 0 "No" 1 "Yes", modify
            label values `depriveddummy' `depriveddummy'_deprived
        }

        // If the user wants a deprivation variable to be generated, do it.
        if "`deprivedscore'" != "" {
            generate `deprivedscore' = `dscore' if `touse'
            label var `deprivedscore' "mpi: Multidimensional deprivation score"
        }


        // Generate Adjusted Multidimensional Deprivation Headcount (M0)
        generate `_M0' = cond(`_H' > 0, `dscore', 0)

        /*
            Return all locals generated over the course of the program.
        */
        foreach loc_name in weight_exp svy equalw max_var_length assertion_sensitivity ///
                            ni ndom use_thresholds alpha level touse l_if svy {
            local var_submit = `"`var_submit' "`loc_name'=``loc_name''" "'
        }
        forvalues i = 1 / `ndom' {
            local var_submit = `"`var_submit' "thres`i'=`thres`i''""'
            local var_submit = `"`var_submit' "d`i'=`d`i''""'
            local var_submit = `"`var_submit' "w`i'=`w`i''""'
            local var_submit = `"`var_submit' "nind`i'=`nind`i''""'
            local var_submit = `"`var_submit' "vartype`i'=`vartype`i''""'
        }

        // A is a local for naming mata matrices, res for temporarily saving results.
        tempname res A

    /* ---------------------------------------------------------------------------

    Create Summary Table

    --------------------------------------------------------------------------- */
        // Establish total number of individuals
        if "`nosummary'" == "" {

            noi display as result _n _n "Summary of {cmd:mpi} indicators" _n "{hline 26}"

            local table_shift = max(5 + `max_var_length', 11)
            local table_1 = `table_shift' + 13 - (1-`use_thresholds')*4
            local table_2 = `table_1' + 10
            if `use_thresholds' {
                local table_3 = `table_2' + 10
            }
            else {
                local table_3 = `table_1' + 10
            }
            local linew = `table_3' + 7

            noi display as text "Indicator" _c
            noi display as text _col(`table_shift') "Type" _c
            noi display as text _col(`table_1') "Weight" _c
            if `use_thresholds' {
                noi display as text _col(`table_2') "Threshold" _c
            }
            noi display as text _col(`table_3') "Deprived" _c
            noi display as text _n "{hline `linew'}" _c

            forvalues j = 1 / `ndom' {
                local nind`j' = wordcount("`d`j''")
                noi display as result _n "Domain `j'" _c
                forvalues i = 1 / `nind`j'' {
                    // Extract weight, indicator and thresholds from
                    // the respective locals
                    local w = round(real(word("`w`j''", `i')), 0.01)
                    local ind = word("`d`j''", `i')
                    local threshold = word("`thres`j''", `i')
                    local vartype = word("`vartype`j''", `i')

                    // Calculate how many people are deprived.
                    `svy' proportion `ispoor_`j'_`i'' `weight_exp' `l_if'
                    matrix `res' = e(b)
                    local perc_poor = `res'[1, 2] * 100
                    if missing(`perc_poor') {
                        local perc_poor = 0
                    }

                    noi display as text _n _col(3) "`ind'" _c
                    noi display as text _col(`table_shift') "`vartype'" _c
                    noi display as result _col(`table_1') "`w'" _c
                    if `use_thresholds' {
                        noi display as result _col(`table_2') "`threshold'" _c
                    }
                    noi display as result _col(`table_3') %6.3f = `perc_poor' " %" _c
                }
            }
            noi display as text _n "{hline `linew'}"
            noi display as text "Deprived: Percentage of individuals whose indicator values are"
            noi display as text "below the threshold." _n _n

            if `"`error_message'"' != "" {
                noi display as result "Note: " `error_message'
            }
        }

    /* ---------------------------------------------------------------------------

    Computing Main Indicators

    --------------------------------------------------------------------------- */

        /*
            Check if all individuals are non-poor, as this requires additional
            messages below.
        */
        cap assert `_H' == 0
        if _rc == 9 {
            local warn_no_poor = 0
        }
        else {
            error _rc
            local warn_no_poor = 1
        }

        noi _mpi_main `"`var_submit'"'

        tempname hm_1 hm_2 hm_V_1 hm_V_2

        matrix `hm_1' = r(mpi_main)
        matrix `hm_V_1' = r(mpi_main_V)
        matrix `hm_2' = r(mpi_add)
        matrix `hm_V_2' = r(mpi_add_V)
        local N = r(N)

        /*
            Intermission: Display the results.
        */
        tempname disp_b disp_V tmp

        local hm_1_col = colsof(`hm_1')
        local hm_2_col = colsof(`hm_2')
        matrix `disp_b' = `hm_1', `hm_2'
        matrix `tmp' = J(`hm_1_col', `hm_2_col', 0)
        local names : colfullnames `hm_1'
        matrix rownames `tmp' = `names'
        local names : colfullnames `hm_2'
        matrix colnames `tmp' = `names'
        matrix `disp_V' = (`hm_V_1', `tmp')
        matrix `disp_V' = `disp_V' \ (`tmp'', `hm_V_2')
        ereturn post `disp_b' `disp_V', obs(`N')

        local n_string = "N = `N'"
        local len_n_string = strlen("`n_string'")
        noi display as text "Main results" _col(`=62-`len_n_string'') "`n_string'"

        // Stata 14 and newer versions of Stata 13.
        quietly capture ereturn display, level(`level') nopvalue cformat("%9.3f")
        if _rc == 1 {
            error 1
        }
        else if _rc != 0 {
            // Older versions.
            quietly capture _coef_table, cionly level(`level') cformat("%9.3f")
            if _rc == 1 {
                error 1
            }
            else if _rc != 0 {
                // Final fallback.
                tempname hm hm_se hm_se_ci
                matrix `hm' = e(b)
                matrix `hm' = `hm''
                matrix `hm_se' = e(V)
                matrix `hm_se' = vecdiag(`hm_se'')
                mata: `A' = st_matrix("`hm_se'")
                mata: `A' = sqrt(`A')
                mata: st_matrix("`hm_se'", `A')
                matrix `hm_se' = `hm_se''
                matrix `hm_se_ci' = J(`=rowsof(`hm')', 2, .)
                forvalues i = 1/`=rowsof(`hm')' {
                    matrix `hm_se_ci'[`i', 1] = `hm'[`i', 1] - invnormal(1 - (100-`level')/200) * `hm_se'[`i', 1]
                    matrix `hm_se_ci'[`i', 2] = `hm'[`i', 1] + invnormal(1 - (100-`level')/200) * `hm_se'[`i', 1]
                }
                matrix colnames `hm' = "Estimate"
                matrix colnames `hm_se' = "Std Err"
                matrix colnames `hm_se_ci' = "[`level'% Conf"  "Interval]"
                noi: matlist (`hm', `hm_se', `hm_se_ci'), bor(all) for(%9.3f) aligncolnames(r) rowtitle("")
            }
            else {
                noisily _coef_table, cionly level(`level') cformat("%9.3f")
            }
        }
        else {
            noisily ereturn display, level(`level') nopvalue cformat("%9.3f")
        }

        local add_space = 56
        if `use_thresholds' {
            local add_space = 58
        }
        noi display as text "Note:" _col(7) "Adjusted Multidimensional Headcount" _col(53) "M0" _col(`add_space') "= H*A"
        if `use_thresholds' {
            noi display as text _col(7) "Adjusted Poverty Gap" _col(53) "M1" _col(`add_space') "= H*A*G"
            if wordcount("`alpha'") > 2 {
                noi display as text _col(7) "Adjusted Foster-Greer-Thorbecke (FGT) Measure"_col(53) "M(a)" _col(`add_space') "= H*A*S(a)"
            }
            else {
                noi display as text _col(7) "Adjusted Foster-Greer-Thorbecke (FGT) Measure"_col(53) "M(2)" _col(`add_space') "= H*A*S(2)"
            }
        }

        if `warn_no_poor' == 1 {
            error _rc
            noi di as result "Note: No individual is multidimensionally deprived."
        }
        noi display as text ""

    /* ---------------------------------------------------------------------------

    Decomposition of M_alpha by Indicator

    --------------------------------------------------------------------------- */
        if "`nodecomposition'" == "" {
            if `ni' != 1 {
                // Variables for output
                tempname decomb_ind decomb_dom decomb_ind_V decomb_dom_V mat_transform

                // Variables for display
                tempname disp decomb_ind_disp decomb_dom_disp

                noi _mpi_domains `"`var_submit'"'

                matrix `decomb_ind' = r(mpi_decomposed)
                matrix `decomb_ind_V' = r(mpi_decomposed_V)

                local ncol = `=1 + wordcount("`alpha'")*`use_thresholds''

                mata: `A' = st_matrix("r(mpi_decomposed)")
                mata: cols = strtoreal(st_local("ncol"))
                mata: `A' = colshape(`A', cols)
                mata: st_matrix("`decomb_ind_disp'", `A')

                // Transform from the all-indicator view to the only-domain view
                matrix `mat_transform' = J(`=`ncol'*`ni'', `=`ncol'*`ndom'', 0)
                local idx = 0
                local count_ind = 0
                forvalues j = 1 / `ndom' {
                    forvalues i = 1 / `nind`j'' {
                        forvalues idx = 1 / `ncol' {
                            matrix `mat_transform'[`count_ind'*`ncol' + `idx', (`j'-1)*`ncol' + `idx'] = 1
                        }
                        local count_ind = `count_ind' + 1
                    }
                }

                matrix `decomb_dom' = `decomb_ind' * `mat_transform'
                matrix `decomb_dom_V' = `mat_transform'' * `decomb_ind_V' * `mat_transform'

                mata: `A' = colshape(st_matrix("`decomb_dom'"), cols)
                mata: st_matrix("`decomb_dom_disp'", `A')

                /*
                    Create the correct names.
                */
                if `use_thresholds' {
                    local idx = 0
                    local addlabel_alpha = ""
                    foreach a of local alpha {
                        local idx = `idx' + 1
                        local a_name = subinstr("`a'", ".", ",", .)
                        local addlabel_alpha = `"`addlabel_alpha' "M(`a_name')""'
                        local a_name = subinstr("`a'", ".", "p", .)
                        local a_name = subinstr("`a_name'", "-", "m", .)
                    }
                    local names = `""M0" `addlabel_alpha'"'
                }
                else {
                    local names = `""M0""'
                }
                matrix colnames `decomb_ind_disp' = `names'
                matrix colnames `decomb_dom_disp' = `names'

                local e_names = ""
                local lb_ind =  " "
                local lb_dom = " "
                forvalues j = 1 / `ndom' {
                    local lb_dom = `"`lb_dom' "domain `j'""'
                    local nind`j' = wordcount("`d`j''")

                    /*
                        Names for the domain-ereturn.
                    */
                    if `use_thresholds' {
                        local idx = 0
                        local addlabel_alpha = ""
                        foreach a of local alpha {
                            local idx = `idx' + 1
                            local a_name = subinstr("`a'", ".", ",", .)
                            local addlabel_alpha = `"`addlabel_alpha' "d_`j':M(`a_name')""'
                            local a_name = subinstr("`a'", ".", "p", .)
                            local a_name = subinstr("`a_name'", "-", "m", .)
                        }
                        local e_names = `"`e_names' "d_`j':M0" `addlabel_alpha'"'
                    }
                    else {
                        local e_names = `"`e_names' "d_`j':M0""'
                    }

                    /*
                        Iterate over indicators, create the to-be-estimated variables and the labels.
                    */
                    forvalues i = 1 / `nind`j'' {
                        local ind = word("`d`j''", `i')
                        local lb_ind = `"`lb_ind' "domain `j':`ind'""''
                    }
                }

                matrix rownames `decomb_ind_disp' = `lb_ind'
                matrix rownames `decomb_dom_disp' = `lb_dom'

                matrix colnames `decomb_dom' = `e_names'
                matrix colnames `decomb_dom_V' = `e_names'
                matrix rownames `decomb_dom_V' = `e_names'
            }

            /*
                Prepare for display and do consistency checks.
            */
            if `ni' != 1 {
                tempname check
                mata: `A' = colsum(st_matrix("`decomb_ind_disp'"))
                mata: st_matrix("`check'", `A')

                forvalues i = 1/`=colsof(`check')' {
                    cap assert abs(`check'[1, `i'] - 1) < `assertion_sensitivity' | ///
                               missing(`check'[1, `i']) | `warn_no_poor'
                    if _rc == 9 {
                        noi di as error "Decomposition by ind/dom failed in column `i'. (`=`check'[1, `i']' vs. 1)"
                    }
                    else {
                        error _rc
                    }
                }
                matrix `disp' = (`decomb_ind_disp' \ `check')
                matrix rownames `disp' = `lb_ind' Total
                noi matlist `disp', bor(all) for(%9.3f) lines(rowtotal) rowtitle(Indicator)  twidth(15)
                noi display in gr "Contribution of each indicator (%)"
                if `warn_no_poor' {
                    noi di as result "Note: No individual is multidimensionally deprived."
                }
                noi display as text ""
            }

            if (`ni' != `ndom') & (`ndom' != 1) {
                matrix `disp' = (`decomb_dom_disp' \ `check')
                matrix rownames `disp' = `lb_dom' Total
                noi matlist `disp', bor(all) for(%9.3f) lines(rowtotal) rowtitle(Domain)
                noi display in gr "Contribution of each domain (%)"
                if `warn_no_poor' {
                    noi di as result "Note: No individual is multidimensionally deprived."
                }
                noi display as text ""
            }
        }

    /* ---------------------------------------------------------------------------

        Decomposition of M_alpha by subgroups

    --------------------------------------------------------------------------- */

        if ("`by'" != "")   {

            unab by : `by'

            noi: display as result _n _n "Decomposition by subgroups"
            noi: display as result "{hline 32}"

            noi display in gr "MPI by: " in ye "`by'"

            // Display a warning message if single groups have no deprived individuals.
            local warn_no_poor = 0
            local warn_no_poor_groups = ""

            levelsof `by' `l_if', local(by_levels)
            foreach by_level of local by_levels {
                cap assert `_H' == 0 if `by' == `by_level'
                if _rc == 0 {
                    local warn_no_poor = `warn_no_poor' + 1
                    local warn_no_poor_groups = "`warn_no_poor_groups' `by_level'"
                }
            }
            foreach by_level of local by_levels {
                cap assert `_H' == 0 if `by' == "`by_level'"
                if _rc == 0 {
                    local warn_no_poor = `warn_no_poor' + 1
                    local warn_no_poor_groups = `"`warn_no_poor_groups' "`by_level'""'
                }
            }
            if `warn_no_poor' > 0 {
                if `warn_no_poor' > 1 {
                    local s = "s"
                }
                else {
                    local s = ""
                }
                noi display as result `"Note: No deprived individuals in by-group`s' `warn_no_poor_groups'."'
                local warn_no_poor = 1
            }

            // Get estimates
            noi _mpi_main `"`var_submit' by=`by'"'

            // Retreive the results
            local levelnames = r(over_namelist)

            // Variables for storange and returning
            tempname hm_by hm_by_V hm_by_perc hm_by_perc_V

            // Variables for display
            tempname hm_by_disp hm_by_perc_disp

            matrix `hm_by' = r(mpi_main)
            matrix `hm_by_V' = r(mpi_main_V)
            matrix `hm_by_perc' = r(mpi_perc)
            matrix `hm_by_perc_V' = r(mpi_perc_V)

            local ncol = `=wordcount("`levelnames'")'
            mata: `A' = st_matrix("`hm_by'")
            mata: cols = strtoreal(st_local("ncol"))
            mata: `A' = colshape(`A', cols)
            mata: st_matrix("`hm_by_disp'", `A')

            local ncol = `=wordcount("`levelnames'")'
            mata: `A' = st_matrix("`hm_by_perc'")
            mata: cols = strtoreal(st_local("ncol"))
            mata: `A' = colshape(`A', cols)
            mata: st_matrix("`hm_by_perc_disp'", `A')

            // Prepare subpopulation labels
            local levels ""
            // Check if the by-variable has a label.
            local by_lab: value label `by'
            if "`by_lab'" != "" {
                foreach i of local levelnames {
                    local label: label `by_lab' `i'
                    local levels = `"`levels' ":`label'""''
                }
            }
            else {
                foreach i of local levelnames {
                    local levels = `"`levels' ":`by'_`i'""''
                }
            }

            /*
                Apply the labels (from above)
            */
            if `use_thresholds' {
                local addlabel_alpha = ""
                foreach a of local alpha {
                    // Malpha
                    local a_name = subinstr("`a'", ".", "p", .)
                    local a_name = subinstr("`a_name'", "-", "m", .)
                    local a_name = subinstr("`a'", ".", ",", .)
                    local addlabel_alpha = `"`addlabel_alpha' "M(`a_name')""'
                }
            }


            // Printing the absolute indices by subgroups

            // Get subpopulation count for all _valid_ subgroups.
            // The correction is only necessary in the svy-case, because
            // proportion does not exclude observations when the other
            // covariates are missing by default.
            count if `touse' == 0
            local use_touse = (r(N) != 0 & "`svy'" != "")
            if `use_touse' {
                `svy' proportion `by' `weight_exp' `l_if', over(`touse')
            }
            else {
                `svy' proportion `by' `weight_exp' `l_if'
            }

            // Cut missing values from the result vector, if they exist. This is only
            // relevant for the svy case.
            tempname proportions
            mat `proportions' = e(b)

            // Remove results which are missing (exactly =0)
            // and such that were from the touse==0 scenario.
            local i = 1
            local real_i = 1
            local max = colsof(`proportions')
            while `i' < `max' {
                if `use_touse' {
                    local condition = ((`proportions'[1, `i'] == 0) | (mod(`real_i', 2)==1))
                }
                else {
                    local condition = (`proportions'[1, `i'] == 0)
                }
                if `condition' {
                    if `i' != 1 & `i' != `max' {
                        matrix `proportions' = `proportions'[1, 1..`=`i'-1'], `proportions'[1, `=`i'+1'..`max']
                    }
                    else if `i' == 1 {
                        matrix `proportions' = `proportions'[1, 2..`max']
                    }
                    else {
                        matrix `proportions' = `proportions'[1, 1..`=`max'-1']
                    }
                    local i = `i'-1
                    local max = `max'-1
                }
                local i = `i'+1
                local real_i = `real_i'+1
            }

            matrix `hm_by_disp' = `hm_by_disp' \ (`proportions')
            matrix `hm_by_disp' = `hm_by_disp' , ( (`hm_1')' \ 1 )

            matrix colnames `hm_by_disp' = `levels' "Total"
            if `use_thresholds' {
                matrix rownames `hm_by_disp' = "H" "M0" `addlabel_alpha' "pop share"
            }
            else {
                matrix rownames `hm_by_disp' = "H" "M0" `addlabel_alpha' "pop share"
            }
            */

            // Checking that the decomposition was correct
            local ncol = colsof(`hm_by_disp')
            local nrow = rowsof(`hm_by_disp')
            forvalues col = 1/`ncol' {
                local total = 0
                forvalues row = 1/`nrow' {
                    // Values * Population share
                    if !missing(`hm_by_disp'[`row', `col']) {
                        local total = `total' + `hm_by_disp'[`row', `col']*`hm_by_disp'[`row', `ncol'+1]
                    }
                    else {
                        local total = .
                    }
                }
                cap assert abs(`total' - `hm_by_disp'[`nrow'+1, `col']) < `assertion_sensitivity' | ///
                           missing(`total')
                if _rc == 9 {
                    noi display as error "By-Decomposition failed in col `col'."
                }
                else {
                    error _rc
                }
            }

            noi matlist `hm_by_disp', bor(all) for(%9.3f) lines(rctotal)
            noi display as text "Indices by subgroup (absolute)"
            if `warn_no_poor' {
                noi di as result "Note: In at least one category, no individual is multidimensionally deprived."
            }
            noi display as text ""

            // Printing the proportional contribution of subgroups to the indices
            tempname check disp
            mata: `A' = rowsum(st_matrix("`hm_by_perc_disp'"))
            mata: st_matrix("`check'", `A')
            matrix `disp' = `hm_by_perc_disp' , `check'

            local ncol = colsof(`disp')
            local nrow = rowsof(`disp')
            forvalues row = 1/`nrow' {
                forvalues col = 1/`ncol' {
                    // If the value is zero, (if there are no
                    // poor people in the subgroup), ignore it.
                    if `disp'[`row', `col'] == 0 {
                        matrix `disp'[`row', `col'] = .
                    }
                }
                cap assert abs(`disp'[`row', `ncol'] - 1) < `assertion_sensitivity' | missing(`disp'[`row', `ncol'])
                if _rc == 9 {
                    noi di as error "Computation of row sums in proportions decomposition failed. `rowsum' vs 1 in row `row'."
                }
                else {
                    error _rc
                }
            }

            matrix colnames `disp' = `levels' "Total"
            if `use_thresholds' {
                matrix rownames `disp' = "H" "M0" `addlabel_alpha'
            }
            else {
                matrix rownames `disp' = "H" "M0"
            }

            noi matlist `disp', bor(all) for(%9.3f) lines(coltotal)
            noi display as text "Contribution of subgroups to indices (%)"
            if `warn_no_poor' {
                noi di as result "Note: In at least one category, no individual is multidimensionally deprived."
            }
            noi display as text ""

    /* ---------------------------------------------------------------------------

    Decomposition of M_alpha by Subgroup AND Indicator

    --------------------------------------------------------------------------- */

            if "`nodecomposition'" == "" {
                if (`ni' != 1) {
                    noi _mpi_domains `"`var_submit' by=`by'"'

                    // Retreive the results
                    local levelnames = r(over_namelist)

                    // Variables for returning.
                    tempname hm_by_ind hm_by_dom hm_by_ind_V hm_by_dom_V

                    // Variables for display.
                    tempname hm_by_ind_disp hm_by_dom_disp

                    matrix `hm_by_ind' = r(mpi_decomposed)
                    matrix `hm_by_ind_V' = r(mpi_decomposed_V)

                    local ncol = `=wordcount("`levelnames'")'
                    mata: `A' = st_matrix("`hm_by_ind'")
                    mata: cols = strtoreal(st_local("ncol"))
                    mata: `A' = colshape(`A', cols)
                    mata: st_matrix("`hm_by_ind_disp'", `A')

                    // Transform from the all-indicator view to the only-domain view
                    local n_alpha = wordcount("`alpha'")*`use_thresholds' + 1
                    matrix `mat_transform' = J(`=`ncol'*`ni'*`n_alpha'', `=`ncol'*`ndom'*`n_alpha'', 0)
                    local count_ind = 0
                    forvalues j = 1 / `ndom' {
                        forvalues i = 1 / `nind`j'' {
                            forvalues idx = 1 / `=`ncol'*`n_alpha'' {
                                matrix `mat_transform'[`count_ind'*`ncol'*`n_alpha' + `idx', (`j'-1)*`ncol'*`n_alpha' + `idx'] = 1
                            }
                            local count_ind = `count_ind' + 1
                        }
                    }

                    matrix `hm_by_dom' = `hm_by_ind' * `mat_transform'
                    matrix `hm_by_dom_V' = `mat_transform'' * `hm_by_ind_V' * `mat_transform'

                    mata: `A' = colshape(st_matrix("`hm_by_dom'"), cols)
                    mata: st_matrix("`hm_by_dom_disp'", `A')

                    // The resulting matrices need to be brought to the final form.
                    // Number of columns = Number of levels of `by'
                    local ind_names = ""
                    local dom_names = ""
                    local e_dom_names = ""
                    forvalues j = 1/`ndom' {
                        forvalues i = 1/`nind`j'' {
                            local ind = word("`d`j''", `i')
                            local ind_names = `"`ind_names' "M0:`ind'""'
                            if `use_thresholds' {
                                foreach a of local alpha {
                                    local a_idx = `a_idx' + 1
                                    local a_name = subinstr("`a'", ".", ",", .)
                                    local ind_names = `"`ind_names' "M(`a_name'):`ind'""'
                                }
                            }
                        }
                        local dom_names = `"`dom_names' "M0:domain `j'""'
                        foreach i of local levelnames {
                            local e_dom_names = `"`e_dom_names' "`by'_`i':d`j'_M0""'
                        }

                        if `use_thresholds' {
                            foreach a of local alpha {
                                local a_idx = `a_idx' + 1
                                local a_name = subinstr("`a'", ".", ",", .)
                                local dom_names = `"`dom_names' "M(`a_name'):domain `j'""'
                                foreach i of local levelnames {
                                    local e_dom_names = `"`e_dom_names' "`by'_`i':d`j'_M(`a_name')""'
                                }
                            }
                        }
                    }
                    matrix rownames `hm_by_ind_disp' = `ind_names'
                    matrix colnames `hm_by_ind_disp' = `levels'

                    matrix colnames `hm_by_dom' = `e_dom_names'
                    matrix colnames `hm_by_dom_V' = `e_dom_names'
                    matrix rownames `hm_by_dom_V' = `e_dom_names'

                    matrix rownames `hm_by_dom_disp' = `dom_names'
                    matrix colnames `hm_by_dom_disp' = `levels'

                    // The domains are ordered as d1:M0 d1:M1 d2:M0 d2:M1 ...
                    // Reorder them as d1:M0 d2:M0 d1:M1 d2:M1
                    tempname hm_by_ind_new hm_by_dom_new
                    * tempname hm_by_ind_se_new hm_by_dom_se_new
                    local idx_ind = 0
                    if `use_thresholds' {
                        local nindices = wordcount("0 `alpha'")
                    }
                    else {
                        local nindices = 1
                    }
                    forvalues index = 1/`nindices' {
                        local n_prev_dom = 0
                        forvalues j = 1/`ndom' {
                            matrix `hm_by_dom_new' = nullmat(`hm_by_dom_new') \ `hm_by_dom_disp'[(`j'-1)*`nindices'+`index', 1...]
                            * matrix `hm_by_dom_se_new' = nullmat(`hm_by_dom_se_new') \ `hm_by_dom_se'[(`j'-1)*`nindices'+`index', 1...]
                            local nind`j' = wordcount("`d`j''")
                            forvalues i = 1/`nind`j'' {
                                // Do the same for the indicators
                                matrix `hm_by_ind_new' = nullmat(`hm_by_ind_new') \ `hm_by_ind_disp'[(`i'-1+`n_prev_dom')*`nindices'+`index', 1...]
                                * matrix `hm_by_ind_se_new' = nullmat(`hm_by_ind_se_new') \ `hm_by_ind'[(`i'-1+`n_prev_dom')*`nindices'+`index', 1...]
                                local n_ind = `n_ind' + 1
                            }
                            local n_prev_dom = `n_prev_dom' + `nind`j''
                        }
                    }
                    matrix `hm_by_ind_disp' = `hm_by_ind_new'
                    matrix `hm_by_dom_disp' = `hm_by_dom_new'

                    // Prepare the matrix of totals and their names to add them at
                    // the proper places in the display matrix
                    tempname total c
                    matrix `total' = J(1, colsof(`hm_by_ind_disp'), .)
                    matrix rownames `total' = "Total"
                    local total_names = `" "M0:Total" "'
                    foreach a of local alpha {
                        local a_idx = `a_idx' + 1
                        local a_name = subinstr("`a'", ".", ",", .)
                        local total_names = `"`total_names' "M(`a_name'):Total""'
                    }

                    // Select the individual indicators to reorganize the display matrix
                    // and add the 'total' column
                    cap matrix drop `disp'
                    local cspec = ""
                    local rspec = ""
                    forvalues index = 1/`nindices' {
                        matrix rownames `total' = `=word(`"`total_names'"', `index')'
                        local to = (`index')*`ni'
                        local to = cond(`to' > rowsof(`hm_by_ind_disp'), ., `to')
                        local from = (`index'-1)*`ni'+1
                        matrix `c' = `decomb_ind_disp'[1..`ni', `index']
                        matrix colnames `c' = "Total"
                        matrix `disp' = nullmat(`disp') \ ((`hm_by_ind_disp'[`from'..`to', 1...], `c') \ (`total', 1))
                        local rspec = "`rspec'-"
                        forvalues i = 1/`=`ni'-1' {
                            local rspec = "`rspec'&"
                        }
                        local rspec = "`rspec'-"
                        // Check that the total is really 1, by levels
                        forvalues j = 1/`=colsof(`hm_by_ind_disp')' {
                            local total_check = 0
                            local count_zero = 0    // Count the number of exact zeros.
                            forvalues i = `from'/`to' {
                                if `hm_by_ind_disp'[`i', `j'] == 0 {
                                    local count_zero = `count_zero' + 1
                                }
                                else {
                                    local total_check = `total_check' + `hm_by_ind_disp'[`i', `j']
                                }
                            }
                            // If the number of zero-entries is equal to the number of entries,
                            // the by-groups is completely missing. Make this visible in the output matrix.
                            if `count_zero' == `to'-`from'+1 {
                                local total_check = .
                                forvalues i = 1/`count_zero' {
                                    matrix `disp'[`=rowsof(`disp')-`i'', `j'] = .
                                }
                            }
                            cap assert abs(`total_check' - 1) < `assertion_sensitivity' | ///
                                       missing(`total_check')
                            if _rc == 9 {
                                noi di as error "Decomposition by by+ind failed, index=`index', j=`j'. (`total_check' vs. 1)"
                            }
                            else {
                                error _rc
                                matrix `disp'[`=rowsof(`disp')', `j'] = `total_check'
                            }
                            if `index' == 1 {
                                local cspec = "`cspec' %9.3f"
                                if `j' != `=colsof(`hm_by_ind_disp')' {
                                    local cspec = "`cspec' &"
                                }
                            }
                        }
                    }
                    noi matlist `disp', rowtitle("") cspec(| b %16s | `cspec' | %9.3f |) rspec(-`rspec'-)
                    noi display as text "Contribution of each indicator (%)"
                    if `warn_no_poor' {
                        noi di as result "Note: In at least one category, no individual is multidimensionally deprived."
                    }
                    noi display as text ""

                    // Displaying Domain decompositions
                    if (`ni' != `ndom')  & (`ndom' != 1) {
                        matrix drop `disp'
                        local cspec = ""
                        local rspec = ""
                        forvalues index = 1/`nindices' {
                            matrix rownames `total' = `=word(`"`total_names'"', `index')'
                            local to = ((`index')*`ndom')
                            local to = cond(`to' > rowsof(`hm_by_dom_disp'), ., `to')
                            local from = ((`index'-1)*`ndom'+1)
                            matrix `c' = `decomb_dom_disp'[1..`ndom', `index']
                            matrix colnames `c' = "Total"
                            matrix `disp' = nullmat(`disp') \ ((`hm_by_dom_disp'[`from'..`to', 1...], `c') \ (`total', 1))
                            local rspec = "`rspec'-"
                            forvalues i = 1/`=`ndom'-1' {
                                local rspec = "`rspec'&"
                            }
                            local rspec = "`rspec'-"
                            // Check that the total is really 1
                            forvalues j = 1/`=colsof(`hm_by_dom_disp')' {
                                local total_check = 0
                                local count_zero = 0    // Count the number of exact zeros.
                                forvalues i = `from'/`to' {
                                    if `hm_by_dom_disp'[`i', `j'] == 0 {
                                        local count_zero = `count_zero' + 1
                                    }
                                    else {
                                        local total_check = `total_check' + `hm_by_dom_disp'[`i', `j']
                                    }
                                }
                                // If the number of zero-entries is equal to the number of entries,
                                // the by-groups is completely missing. Make this visible in the output matrix.
                                if `count_zero' == `to'-`from'+1 {
                                    local total_check = .
                                    forvalues i = 1/`count_zero' {
                                        matrix `disp'[`=rowsof(`disp')-`i'', `j'] = .
                                    }
                                }
                                cap ass
                                cap assert abs(`total_check' - 1) < `assertion_sensitivity' | ///
                                           missing(`total_check')
                                if _rc == 9 {
                                    noi di as error "Decomposition by by+dom failed, index=`index', j=`j'. (`total_check' vs. 1)"
                                }
                                else {
                                    error _rc
                                    matrix `disp'[`=rowsof(`disp')', `j'] = `total_check'
                                }
                                if `index' == 1 {
                                    local cspec = "`cspec' %9.3f"
                                    if `j' != `=colsof(`hm_by_dom_disp')' {
                                        local cspec = "`cspec' &"
                                    }
                                }
                            }
                        }
                        noi matlist `disp', rowtitle("") cspec(| b %16s | `cspec' | %9.3f |) rspec(-`rspec'-)
                        noi display as text "Contribution of each domain (%)"
                        if `warn_no_poor' {
                            noi di as result "Note: In at least one category, no individual is multidimensionally deprived."
                        }
                        noi display as text ""
                    }
                }
            } // Should the decomposition by domains/indicators be computed ?
        } // End decomposition (by)

        ereturn clear

        // Posting the correct values in e(b) and e(V).
        // At the begin of mpi, there is a check that at most one
        // post statement is present.
        tempname mat_keep_1 mat_keep_2
        if "`postmain'" != "" {
            matrix `mat_keep_1' = `hm_1'
            matrix `mat_keep_2' = `hm_V_1'
            ereturn post `hm_1' `hm_V_1' `weight_exp', esample(`touse') obs(`N')
            matrix `hm_1' = `mat_keep_1'
            matrix `hm_V_1' = `mat_keep_2'
            ereturn local type_b_return = "Main results."
        }

        if "`postadditional'" != "" {
            matrix `mat_keep_1' = `hm_2'
            matrix `mat_keep_2' = `hm_V_2'
            ereturn post `hm_2' `hm_V_2' `weight_exp', esample(`touse') obs(`N')
            matrix `hm_2' = `mat_keep_1'
            matrix `hm_V_2' = `mat_keep_2'
            ereturn local type_b_return = "Additional results."
        }

        if "`postindicators'" != "" {
            if "`nodecomposition'" == "" & `ni' != 1 {
                matrix `mat_keep_1' = `decomb_ind'
                matrix `mat_keep_2' = `decomb_ind_V'
                ereturn post `decomb_ind' `decomb_ind_V' `weight_exp', esample(`touse') obs(`N')
                matrix `decomb_ind' = `mat_keep_1'
                matrix `decomb_ind_V' = `mat_keep_2'
                ereturn local type_b_return = "Main results decomposed by indicators."
            }
            else {
                noi display as error "Error: postindicators not possible in the context."
                error 198
            }
        }

        if "`postdomains'" != "" {
            if "`nodecomposition'" == "" & (`ni' != `ndom')  & (`ndom' != 1) {
                matrix `mat_keep_1' = `decomb_dom'
                matrix `mat_keep_2' = `decomb_dom_V'
                ereturn post `decomb_dom' `decomb_dom_V' `weight_exp', esample(`touse') obs(`N')
                matrix `decomb_dom' = `mat_keep_1'
                matrix `decomb_dom_V' = `mat_keep_2'
                ereturn local type_b_return = "Main results decomposed by domains."
            }
            else {
                noi display as error "Error: postdomains not possible in the context."
                error 198
            }
        }

        if "`postbymain'" != "" {
            if "`by'" != "" {
                matrix `mat_keep_1' = `hm_by'
                matrix `mat_keep_2' = `hm_by_V'
                ereturn post `hm_by' `hm_by_V' `weight_exp', esample(`touse') obs(`N')
                matrix `hm_by' = `mat_keep_1'
                matrix `hm_by_V' = `mat_keep_2'
                ereturn local type_b_return = "Main results decomposed by by-levels."
            }
            else {
                noi display as error "Error: postbymain not possible in the context. Specify by."
                error 198
            }
        }

        if "`postbyproportion'" != "" {
            if "`by'" != "" {
                matrix `mat_keep_1' = `hm_by_perc'
                matrix `mat_keep_2' = `hm_by_perc_V'
                ereturn post `hm_by_perc' `hm_by_perc_V' `weight_exp', esample(`touse') obs(`N')
                matrix `hm_by_perc' = `mat_keep_1'
                matrix `hm_by_perc_V' = `mat_keep_2'
                ereturn local type_b_return = "by proportion"
            }
            else {
                noi display as error "Error: postbyproportion not possible in the context. Specify by."
                error 198
            }
        }

        if "`postbyindicators'" != "" {
            if "`by'" != "" & "`nodecomposition'" == "" & `ni' != 1 {
                matrix `mat_keep_1' = `hm_by_ind'
                matrix `mat_keep_2' = `hm_by_ind_V'
                ereturn post `hm_by_ind' `hm_by_ind_V' `weight_exp', esample(`touse') obs(`N')
                matrix `hm_by_ind' = `mat_keep_1'
                matrix `hm_by_ind_V' = `mat_keep_2'
                ereturn local type_b_return = "Main results decomposed by indicators and by-levels."
            }
            else {
                noi display as error "Error: postbyindicators not possible in the context."
                error 198
            }
        }

        if "`postbydomains'" != "" {
            if "`by'" != "" & "`nodecomposition'" == "" & (`ni' != `ndom') & (`ndom' != 1) {
                matrix `mat_keep_1' = `hm_by_dom'
                matrix `mat_keep_2' = `hm_by_dom_V'
                ereturn post `hm_by_dom' `hm_by_dom_V' `weight_exp', esample(`touse') obs(`N')
                matrix `hm_by_dom' = `mat_keep_1'
                matrix `hm_by_dom_V' = `mat_keep_2'
                ereturn local type_b_return = "Main results decomposed by domains and by-levels."
            }
            else {
                noi display as error "Error: postbydomains not possible in the context."
                error 198
            }
        }

        // Return by-results
        if "`by'" != "" {
            if "`nodecomposition'" == "" {
                if `ni' != 1 {
                    ereturn matrix by_ind_V = `hm_by_ind_V'
                    ereturn matrix by_ind = `hm_by_ind'
                }
                if (`ni' != `ndom') & (`ndom' != 1) {
                    ereturn matrix by_dom_V = `hm_by_dom_V'
                    ereturn matrix by_dom = `hm_by_dom'
                }
            }
            ereturn matrix by_mpi_V = `hm_by_V'
            ereturn matrix by_mpi = `hm_by'
            ereturn matrix by_mpi_pc_V = `hm_by_perc_V'
            ereturn matrix by_mpi_pc = `hm_by_perc'
        }

        if "`nodecomposition'" == "" {
            if (`ni' != `ndom')  & (`ndom' != 1) {
                ereturn matrix dom_V = `decomb_dom_V'
                ereturn matrix dom = `decomb_dom'
            }
            if `ni' != 1 {
                ereturn matrix ind_V = `decomb_ind_V'
                ereturn matrix ind = `decomb_ind'
            }
        }

        ereturn matrix mpi_add_V = `hm_V_2'
        ereturn matrix mpi_add = `hm_2'
        ereturn matrix mpi_main_V = `hm_V_1'
        ereturn matrix mpi_main = `hm_1'

        ereturn local cmd = "mpi"
        ereturn local cmdline = `"mpi `*'"'

        return clear

        noi display in smcl "Type {stata ereturn list:ereturn list} to see the list of saved results and more" _n ///
                            "information on the estimation sample."
    }

end

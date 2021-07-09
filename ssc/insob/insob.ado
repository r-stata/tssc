*! 1.1 Bas Straathof 06dec2005

// Small program that inserts i empty observations at obs j of the dataset.
// When the option "after" is specified, the empty observations are inserted
// after the observation (instead of before).
// Example: "insob 2 _N, after" inserts two empty observations at the end of
// the dataset.

program insob
    version 8.2
    gettoken i 0 : 0
    gettoken j 0 : 0, parse(" ,")
    syntax [, AFTER]

    // evaluate (e.g. to catch _N)
        local i = `i'
    local j = `j'

    // either of these commands will fail if arguments omitted or string
    if `i' < 1 {
        di as err "request to insert `i' observations: nothing to do"
        exit 0
    }
    if !inrange(`j',1,_N) {
        di as err "observation numbers out of range"
        exit 198
    }

    tempvar order
    gen double `order' = _n

    quietly {
        set obs `= _N + `i''
        local firstadded = _N - `i' + 1

        if "`after'" != "" {
            // Put i observations after obs. j
            replace `order' = `j' + .5 in `firstadded'/l
                local firstpos = `j' + 1
                local lastpos  = `i' + `j'
        }
        else {
            // Put last i observations before obs. j
            replace `order' = `j' - .5 in `firstadded'/l
            local firstpos = `j'
            local lastpos  = `i' + `j' - 1
        }
    }

        sort `order'
    if `i' == 1 di "{text}`i' empty observation inserted at `firstpos'"
    else di "{text}`i' empty observations inserted at `firstpos'-`lastpos'"
end

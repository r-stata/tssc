program def matdelrc
*! NJC 1.0.0 22 Jan 1999 after WWG Statalist 21 Jan 1999
        version 6.0
        gettoken matname 0 : 0, parse(" ,")

        syntax , [ Row(str) Col(str) ]
        if "`row'`col'" == "" {
                di in bl "nothing to do"
                exit 0
        }

        tempname A
        mat `A' = `matname' /* this will fail if `matname' not a matrix */

        if "`col'" != "" {
                local col = `col' /* evaluate any expression */
                confirm integer n `col'
                if `col' < 1 | `col' > colsof(`matname') {
                        di in r "column number out of range"
                        exit 498
                }
                if colsof(`matname') == 1 {
                        di in r "no; would delete entire column vector"
                        exit 498
                }
                if `col' == 1 { mat `A' = `A'[1..., 2...] }
                else if `col' == colsof(`A') {
                        mat `A' = `A'[1..., 1..`col'-1]
                }
                else mat `A' = `A'[1..., 1..`col'-1], `A'[1..., `col'+1...]
        }
        if "`row'" != "" {
                local row = `row' /* evaluate any expression */
                confirm integer n `row'
                if `row' < 1 | `row' > rowsof(`matname') {
                        di in r "row number out of range"
                        exit 498
                }
                if rowsof(`matname') == 1 {
                        di in r "no; would delete entire row vector"
                        exit 498
                }
                if `row' == 1 { mat `A' = `A'[2..., 1...] }
                else if `row' == rowsof(`A') {
                        mat `A' = `A'[1..`row'-1, 1...]
                }
                else mat `A' = `A'[1..`row'-1,1...] \ `A'[`row'+1..., 1...]
        }

        mat `matname' = `A'
end

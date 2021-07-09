        capture program drop mysumhtm
        program define mysumhtm
            syntax varlist using [, replace append ] 
            tempname fh
            file open `fh' `using', write `replace' `append'
            file write `fh' "<html><body><table>"
            file write `fh' _n "<thead><th>variable</th>" ///
                "<th>mean</th><th>sd</th></thead>"
            foreach v of local varlist {
                quietly summarize `v'
                file write `fh' _n "<tr><td>`v'</td><td>" ///
                     (r(mean)) "</td><td>" (r(sd)) "</td></tr>"
            }
            file write `fh' _n  "</table></body></html>"
            file close `fh'
        end
        mysumhtm * using example.html, replace
        type example.html

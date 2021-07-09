program define cpyxplot6 
*! 1.2.2 NJC 26 December 2002 
* 1.2.1 NJC 20 December 2002 
*! 1.2.0 NJC 14 January 2000 
* 1.1.0 NJC 15 January 1999
        version 6.0
        local tsize : set textsize
        gettoken yvars 0 : 0, parse("\")
	unab yvars : `yvars'
	local ny : word count `yvars'
	gettoken bs 0 : 0, parse("\") 
        syntax varlist [if] [in] [aweight fweight iweight] /* 
	*/ [ , SAving(str asis) /* 
        */ Margin(int 0) TItle(str) TEXTsize(int `tsize') * ] 
        local nx : word count `varlist'

        tempvar touse
        mark `touse' `if' `in'

        set graphics off
        set textsize `textsize'
        local i = 1
        while `i' <= `ny' {
                local y`i' : word `i' of `yvars'
                local j = 1
                while `j' <= `nx' {
                        local x`j' : word `j' of `varlist'
                        tempfile y`i'x`j'
                        graph `y`i'' `x`j'' if `touse' [`weight' `exp'] /*
                         */ , saving(`"`y`i'x`j''"') `options'
                        local files `"`files' "`y`i'x`j''""' 
                        local j = `j' + 1
                }
                local i = `i' + 1
        }
        set graphics on

        if `"`saving'"' != "" { local saving `"sa("`saving'")"' }
        if `"`title'"' != "" { local title `"ti(`title')"' }
        graph using `files', `saving' margin(`margin') `title'
        set textsize `tsize'
end

/*

The syntax is

cpyxplot yvarlist \ xvarlist [if] [in] [weight] [, options]

After the first -gettoken- `yvars'   should be   yvarlist
After the second -gettoken `bs'      should be   "\" 

The syntax is then 

xvarlist [if] [in] [weight] [, options]

*/

* Program to convert help file to html
* Date: Septmeber 25, 2010
* Author: P. Wilner Jeanty
* This command relies heavily on log2html written by Kit Baum, Nick Cox and Bill Rising
prog define hlp2html
        version 9.2
        syntax, FNames(namelist) [log ERASE replace TItle(str) INput(str) Result(str) BG(str) LINEsize(integer `c(linesize)') ///
        TExt(str) ERRor(str) PERcentsize(integer 100) BOLD CSS(str) SCHeme(str)]
		local i=1
		if "`log'" =="" {
			foreach hpf of local fnames {
                capture findfile `hpf'.sthlp
                if !_rc {
					qui return list
					local filenumb`i' "`r(fn)'"
				}	
                else {
					capture findfile `hpf'.hlp
					if !_rc {
						qui return list
						local filenumb`i' "`r(fn)'"
					}	
                    else {
						di as err "The command {bf:`hpf'} or its help file does not exist"
                        exit 601
					}
                }
				local ++i
			}
		 }
		else { 
			foreach hpf of local fnames {
                capture findfile `hpf'.smcl
                if !_rc {
					qui return list
					local filenumb`i' "`r(fn)'"
				}					
                else {
                     di as err "The smcl file {bf:`hpf'} does not exist"
                     exit 601
                }
                local ++i
			}
		}	
		local j=1
        foreach hpf of local fnames {			
			if "`log'" != "" local toconv `filenumb`j''
			else {
				qui copy `filenumb`j'' `hpf'.smcl, replace // users must be aware of the presence of replace here
				local toconv `hpf'.smcl
			}	
			qui log2html `toconv', `erase' `replace' title(`title') input(`input') result(`result') bg(`bg') linesize(`linesize') ///
			text(`text') error(`error') percentsize(`percentsize') `bold' css(`css') scheme(`scheme')
			local ++j
		}	
        di as txt _n "All .html files are saved to the current working directory `c(pwd)'"                                               
end


 
 
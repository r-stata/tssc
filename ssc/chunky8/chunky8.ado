program define chunky8, rclass
version 8.0

*! version 1.0.0  2008.04.26
*! version 1.0.1  2009.01.20
*! version 1.0.2  2009.08.27 Reissued as chunky8
*!
*! by David C. Elliott
*! Text file chunking algorithm
*!
*! syntax:
*! using filename
*! index() is starting line in file to be read
*! chunk() is the number of lines to be read
*! saving( [,replace]) is file name of chunk to be saved,
*!   defaults to chunk.txt
*! keepfirst keeps the first line of the file with the chunk
*!   useful when the first line contains variable names
*! list displays line by line listing of file to screen
*!
*! returns r(index) as the index of the last line read+1
*!         r(eof) = 1 if end of file encountered
*! note - this works on text files only

syntax using [, Index(numlist max=1 >0 integer) ///
    Chunk(numlist max=1 >0 integer) Saving(string) KEEPfirst List]
local infile `using', read

if `"`saving'"'=="" {
    local savefile  using chunk.txt, write replace
    }
	else {
		local 0 `saving'
		syntax [anything(name=savefile id="file to save")][,REPLACE]
		local savefile using `savefile', write `replace'
		}

tempname in out
file open `in' `infile'
file open `out' `savefile'

if "`index'"=="" {
    local index 1
    }
if "`chunk'"==""  {
    local chunk 5
    }
if "`list'" == "list" {
    local list
    }
    else {
        local list *
        }
if "`keepfirst'"=="keepfirst" & `index'==1 {
	local index 2 // because keepfirst will grab the first line anyway
	}
local end = `index' + `chunk'
local i 0
local gotfirst 0

while `i++'<`index' {  // Move pointer to index line
        file read `in' line
        if "`keepfirst'"=="keepfirst" & !`gotfirst' {
        	file write `out' `"`macval(line)'"' _n
        	local gotfirst 1
       	    file read `in' line
			local ++i
        	}
        if r(eof) {
            di _n "{txt:(Note:File has a total of {res:`=`i'-1'} lines.)}" _n
			return scalar eof=1
            exit
            }
	}

while r(eof) == 0 & `index' < `end' {
    file write `out' `"`macval(line)'"' _n
    `list'    di `"{txt:`index' {res:`macval(line)'}}"'
    local ++index
    file read `in' line
    }

file close `in'
file close `out'

return scalar index = `index'
return scalar eof = 0

end

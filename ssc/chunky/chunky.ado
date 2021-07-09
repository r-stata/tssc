program define chunky, sclass
version 9

*! version 1.0.0  2008.04.26
*! version 1.0.1  2009.01.20
*! version 1.2.0  2010.06.10 Changed syntax and processes, better error-handling
*! version 2.0.0  2010.08.21 Major upgrade to use Mata file I/O routines
*! version 2.0.1  2010.08.27 Version submitted to SSC
*!
*! by David C. Elliott
*! Text file chunking algorithm
*!
*! syntax:
*! using filename
*! chunksize() is is the size of the chunk to be read
*!   the size can be specified in bytes, kilobytes (k|kb), megabytes (m|mb) or gigabytes (g|gb)
*!   the power of 10 suffix is case-insensitive and can have a space after the number.  Decimals can be used.
*!   e.g. 5000Kb = 5m = .005 GB
*! stub() is file name stub for the chunks to be saved,
*!   defaults to chunk and will create chunk000#.txt...
*! replace allows overwriting of previous chunk files
*! header(include|skip|none) specifies how to handle the first line of the file
*!   useful when the first line contains variable names
*! peek(#) displays first n lines to screen
*! analyze checks using file for problem characters, etc, and provides table of chunk sizes
*! note - this routine works on text files only

syntax using/ [, ///
	Peek(numlist max=1 >0 integer) ///
	Analyze ///
	Chunksize(string) ///
	Stub(string) REPLACE ///
	Header(string)]

tempname sheader sfilelist schunksize sreplace

*set trace on
*set tracedepth 1
local infile `using'
scalar `sreplace' = cond("`replace'"=="replace",1,0)

file close _all
/* debugging !del chunk0*.txt*/

if "`peek'" != "" { // peek takes precedence over any other option
	mata: peek(`"`infile'"', `peek')
	}
if "`analyze'" != "" { // analyze takes next precedence
	_analyze `"`infile'"'
	}
if ("`peek'" != "" | "`analyze'" != "") & "`chunksize'"!="" {
	di _n "{err: Warning: peek() and analyse options overide chunking options.}" ///
	_n "{err: Chunking was not performed.}"
	}
if ("`peek'" != "" | "`analyze'" != "") {
	exit
	}

if `"`stub'"'=="" {  // check chunk stubname, default to "chunk" if none
	local stub chunk
	}

// Parse out chunksize
// use regular expression to parse out base and coefficient of chunksize
if regexm(trim("`chunksize'"),"([0-9]*[.]?[0-9]*)[ ]*([kKmMgG]?)[bB]?") != 0 {
	scalar `schunksize' = `=regexs(1)' * cond("`=regexs(2)'" !="", 1000^(strpos("KMG",upper("`=regexs(2)'"))), 1)
	}
	else {
		scalar `schunksize' = 100000000  // Default to 100MB
		}

// Determine header processing
if "`header'"=="" { 	//parse out header command
	scalar `sheader' = 1
	}
	else {
		if `: word count `header'' > 1 {
			di "{err:too many header options}" _n ///
			"{err:valid options are: header(include|skip|none)}"
			error
			}
		local 0 ,`header'
		capture syntax [,None Include Skip]
		if _rc {
			di "{err:{res:`=substr("`0'",2,.)' }is not a header option}" _n ///
			"{err:valid options are: header(include|skip|none)}"
			error
			}
		if "`none'" == "none" {
			scalar `sheader' = 1
			}
			else if "`include'" == "include" {
				scalar `sheader' = 2
				}
				else {
					scalar `sheader' = 3
					}
		}

mata: mata set matalnum on /*for debugging*/
mata: mata set matastrict on
mata: st_local("`sfilelist'",chunkfile(`"`infile'"', `=`schunksize'', "`stub'", `=`sheader'',`=`sreplace''))

sreturn local filelist = `"``sfilelist''"'

end

***************
* subroutines *
***************

program define _analyze
	args infile
	di _n `"{txt:Analyzing {res:`infile'} for chunking}"' _n
	quietly hexdump `"`infile'"' , analyze results

// set up scalars
tempname s_av_line_len s_max_line_len s_letters s_max_letters s_numbers s_remainder s_pct_char s_pct_num s_pct_other s_mem s_stata_size
local format `r(format)'
local extended 		`=cond(r(extended)>0,"{err:Extended characters are present and may cause problems.}","No extended characters present.")'
scalar `s_av_line_len' 	= round(r(filesize)/r(lnum),1)
scalar `s_max_line_len'	= r(lmax)
scalar `s_letters' 		= r(uc) + r(lc)
scalar `s_max_letters'	= round(`s_letters'*(`s_max_line_len'/`s_av_line_len'),1)
scalar `s_numbers' 		= r(digit)
scalar `s_remainder' 	= r(filesize) - (`s_letters' + `s_numbers')
scalar `s_pct_char'		= round(`s_letters'/r(filesize),.01)*100
scalar `s_pct_num'		= round(`s_numbers'/r(filesize),.01)*100
scalar `s_pct_other'		= round(`s_remainder'/r(filesize),.01)*100
scalar `s_mem' 			= c(memory)
scalar `s_stata_size'	= round(`s_max_letters' + `s_numbers'/1.5,1)

n di "{txt:{res:`format'} is the file type}"
n di "{txt:File has {res:`r(lnum)'} lines of average length {res:`=`s_av_line_len''} bytes}"
n di "{txt:Composition is {res:`=`s_pct_char''%} letters, {res:`=`s_pct_num''%} numbers and {res:`=`s_pct_other''%} other characters}"
n di "{txt:`extended'}"
 if r(extended)>0 {
	local codelist "000 \0" "001 ^A" "002 ^B" "003 ^C" "004 ^D" "005 ^E" "006 ^F" "007 ^G" "008 ^H" "009 \t" "010 \n" "011 ^K" "012 ^L" "013 \r" "014 ^N" "015 ^O" "016 ^P" "017 ^Q" "018 ^R" "019 ^S" "020 ^T" "021 ^U" "022 ^V" "023 ^W" "024 ^X" "025 ^Y" "026 ^Z" "027 Es" "028 FS" "029 GS" "030 RS" "031 US"
	n di _n "{txt:Extended characters found:}"
	n di "{txt:{c TLC}{dup 6:{c -}}{c TT}{dup 10:{c -}}{c TRC}}"
	n di "{txt:{c |}{center 6:ASCII}{c |}{center 10:count}{c |}}"
	n di "{txt:{c LT}{dup 6:{c -}}{c +}{dup 10:{c -}}{c RT}}"

	forvalues ascii = 0/31 {
		if `=r(c`ascii')' > 0 & !inlist(`ascii',10,13) {
			di "{txt:{c |}`:word `=`ascii'+1' of "`codelist'"'{c |}{res:{ralign 10:`=r(c`ascii')'}}{c |}}"
			}
		}
	forvalues ascii =  161/254 {
		if `=r(c`ascii')' > 0 & !inlist(`ascii',10,13) {
			di "{txt:{c |}{lalign 6:`=substr("000`ascii'",-3,3)'}{c |}{res:{ralign 10:`=r(c`ascii')'}}{c |}}"
			}
		}
	n di "{txt:{c BLC}{dup 6:{c -}}{c BT}{dup 10:{c -}}{c BRC}}"
 	}

n di _n"{txt:Approximate chunk sizes and memory requirements {c 10}for -{help insheet:insheet}- or -{help infile:infile}- commands}"

n di "{txt:{c TLC}{dup 3:{dup 14:{c -}}{c TT}}{dup 14:{c -}}{c TRC}}"
n di "{txt:{c |}{center 14:Chunksize (mb)}{c |}{center 14:Number of}{c |}{center 14:~Number}{c |}{center 14:Stata size*}{c |}}"
n di "{txt:{c |}{center 14:option}{c |}{center 14:Chunks}{c |}{center 14:obs/chunk}{c |}{center 14:(megabytes)}{c |}}"
n di "{txt:{c LT}{dup 3:{dup 14:{c -}}{c +}}{dup 14:{c -}}{c RT}}"
foreach s of numlist 10 30 100 300 1000 3000 {
	local num_chunks 	= ceil(r(filesize)/(`s'*1000000))
	local num_lines		= round(r(lnum)/`num_chunks',1)
	local stata_chunk	= round((`s_stata_size'/`num_chunks')/1000000,.1)
	n di "{txt:{c |}{ralign 12:`s'}  {c |}{ralign 12:{res:`num_chunks'}}  {c |}{ralign 12:{res:`num_lines'}}  {c |}{ralign 12:{res:`stata_chunk'}}  {c |}}"
	if `num_chunks' == 1 {
		continue, break
		}
	}
n di "{txt:{c BLC}{dup 3:{dup 14:{c -}}{c BT}}{dup 14:{c -}}{c BRC}}"
n di "{txt:* Stata file size is very approximate and depends on datatypes of variables}"
n di _n `"{txt:Further detail available by running {stata `"hexdump `"`infile'"', analyze results"':hexdump `"`infile'"', analyze results}}"'

end

*****************
* Mata routines *
*****************

version 9
mata:
mata clear

string function chunkfile(
	string scalar infile,
	scalar chunksize,
	string scalar stub,
	scalar header,
	scalar replace
	)
	{
	real scalar mem, bites, bitesize, stop, fh_in, fh_out
	string scalar headertext, chunk_name, chunk_list, bigbite, littlebite, bite

// determine bitesize based on requested chunksize and available memory
	mem = c("memory")
//	mem = 25000
	bites = ceil(chunksize/mem)
	bitesize = trunc(chunksize/bites)
	printf("{txt}\nChunking using the following settings:\n\nChunksize:{col 13}{res}%15.0gc\n{txt}Memory:{col 13}{res}%15.0gc\n{txt}Bites:{col 13}{res}%15.0gc\n{txt}Bitesize:{col 13}{res}%15.0gc\n\n",chunksize, mem , bites, bitesize)
	displayflush()

	fh_in = fopen(infile, "r")
	if (header != 1) {	/*1 means no header - do nothing*/
		if ( (headertext=fgetnl(fh_in))!=J(0,0,"") ) {
			printf("{txt}%s header: {res}",( (header==2) ? "Include" : "Skip" ))  /*2 and 3 means there is a header*/
			headertext
			printf("{txt}\n(for reference: EOL characters {it:0d0a} (CRLF) indicate Windows, {it:0a} (LF) Unix and {it:0d} (CR) Mac. {it:09} is the TAB character.)\n\n")

			}
			else { /*read problem*/
				errprintf("Cannot read header")
				error
				}
		}

	stop = 0 					// flag for end of file
	n_chunk = 0 			// chunk numbering
	chunk_list = ""		// to accumulate list of filenames

// loop through chunks and bites
	while (stop == 0) {
		chunk_name = stub+substr("000"+strofreal(++n_chunk),-4,4)+".txt"
		chunk_list = chunk_list + "`" + `"""' + chunk_name + `"""' + "' "
		if ( (fileexists(chunk_name)==1) & (replace==1) ) unlink(chunk_name)
		fh_out = fopen(chunk_name, "w")
		if (header == 2) fwrite(fh_out, headertext)
		for (n_bite=1; n_bite <= bites; n_bite++) {
			if ( (bigbite = fread(fh_in, bitesize))!=J(0,0,"") & (stop!=1) ) {
				if ( (littlebite=fgetnl(fh_in))!=J(0,0,"")) {
					}
					else {
						stop = 1
						}
  				bite = (bigbite != J(0,0,"") ? bigbite : "" ) + (littlebite != J(0,0,"") ? littlebite : "" )
  				fwrite(fh_out, bite)
  				if (stop==1) break
				}
				else {
					break
					}
			}
		fclose(fh_out)
printf("{txt}Chunk{res} %s {txt}saved. Now at position{res} %-16.0gc {err}%s\n", chunk_name ,  ftell(fh_in), ((stop==1) ? "End of File" : ""))
		if (fstatus(fh_in)!=0) break
	}
	fclose(fh_in)
	printf("\n")
	return(chunk_list) // send list of filenames back to caller
}

end

mata:
void function peek(
	string scalar infile,
	scalar peek
	)
{
	printf("{txt}\nPeeking at the first {res}%f {txt}lines of {res}%s\n\n", peek, infile)
	fh_in = fopen(infile, "r")
	for (n_lines=1; n_lines <= peek; n_lines++) {
		sprintf("%s",fgetnl(fh_in))
	}
	printf("{txt}\n(for reference: End of line characters {res}{it:odoa} {txt}(CRLF) indicate Windows, {res}{it:oa} {txt}(LF) Unix and {res}{it:od} {txt}(CR) Mac. {c 10}{res}{it:09} {txt}is the TAB character.)\n\n" )
}
end

exit


*! version 1.0.0, 14feb2019, Robert Picard, robertpicard@gmail.com
program chartab

    version 14

	// default target size of chunks when combining obs or splitting files
	local bchunk = 1e7

	// default target size of a UTF-8 byte stream
	local butf8  = 50000
    
    syntax [varlist(string default=none)] [if] [in], ///
        [                               ///
            Files(string asis)          ///
            SCalars(namelist)           ///
            Literals(string asis)       ///
            noAscii                     ///
            Replace                     ///
			STore                       ///
            Ucd(string)                 ///
            buf_chunk(integer `bchunk') ///
            buf_utf8( integer `butf8')  ///
        ]


	if ("`ucd'") == "" local ucd "chartab_UCD_11.0.0.csv"


	if `bchunk' != `buf_chunk' dis "using buf_chunk = " `buf_chunk'
	if `butf8'  != `buf_utf8'  dis "using buf_utf8  = " `buf_utf8'


	mata: main( )
     
        
end


version 14
mata:
mata set matastrict on


void main (

)
{

	real colvector count

	// Unicode has 17 planes of 16-bit code points
	count   = J(17 * 2^16, 1, 0)

	_do_varlist(count)
	_do_filelist(count)
	_do_scalars(count)
	_do_literals(count)

	present_tab_results(count)

	if (st_local("store") == "store") stored_results(count)
    
}


void _do_literals (
	
	real colvector N

)
{
	string rowvector items
    real   scalar    j
	string scalar    temp


	items = tokens(st_local("literals"))

	for (j = 1; j <= cols(items); j++) {

		temp = st_tempfilename()
		string2file( items[j], temp )

		if (st_local("ascii") == "") _tab_file_ascii( N, temp )
		_tab_file_multibyte_utf8( N, temp )

		unlink(temp)

	}
	
}


void _do_scalars (
	
	real colvector N

)
{
	string rowvector items
    real   scalar    j
	string scalar    temp, s


	items = tokens(st_local("scalars"))

	for (j = 1; j <= cols(items); j++) {

		s = st_strscalar(items[j])

		if ( s == J(0,0,"") ) {
			errprintf(`"error, no string scalar named: "%s"\n"', items[j])
			exit(error(198))
		}

		temp = st_tempfilename()
		string2file(s, temp )

		if (st_local("ascii") == "") _tab_file_ascii( N, temp )
		_tab_file_multibyte_utf8( N, temp )

		unlink(temp)

	}
	
}


void _do_filelist (
	
	real colvector N

)
{
	string rowvector items
    real   scalar    j


	items = tokens(st_local("files"))

	for (j = 1; j <= cols(items); j++) {

		if (st_local("ascii") == "") _tab_file_ascii( N, items[j] )
		_tab_file_multibyte_utf8( N, items[j] )

	}
	
}


void _do_varlist (
	
	real colvector N

)
{

	string rowvector items
    string scalar    touse, obs
    real   scalar    j


	if ( st_local("if") + st_local("in") == "" ) touse = ""
	else {
	    stata("marksample touse, novarlist")
		touse = st_local("touse")
	}


	obs = st_tempname()
	stata( "gen long " + obs + " = _n" )
	

	items = tokens(st_local("varlist"))

	for (j = 1; j <= cols(items); j++) {

		_tab_variable( N, items[j], obs, touse )

	}
	

	st_dropvar(obs)
	if ( touse != "" ) st_dropvar(touse)

}


/*  >>>>>>>>>>  _tab_file_multibyte_utf8() ...

(This function updates the count vector directly)

Tabulates the frequency of multi-byte UTF-8 character encodings from a file. We
read the file in chunks of bytes to reduce the demands on memory. 

See -multibyte_to_cp()- for a description of how a valid UTF-8 byte sequence is
decoded. We scan the last 3 characters in the buffer to locate the start of a
new UTF-8 sequence using our -next_utf8_start()- function. If we find one, we
trim the buffer to end on the previous byte and reposition the file pointer.

If the last 3 bytes of the buffer do not contain a UTF-8 sequence start byte,
this is a good breakpoint under all possible scenarios. 

*/

void _tab_file_multibyte_utf8 (

    real   colvector cpN,      // count vector
    string scalar    fname     // file name

)
{

    real   scalar fh, buffer, blen, splitpos
    string scalar chunk
    
    buffer = strtoreal(st_local("buf_chunk"))
    
	fh = fopen(fname, "r")
	while ( (chunk = fread(fh, buffer)) != J(0,0,"") ) {

		blen = strlen(chunk)
		
		if (blen == buffer) {
		
			splitpos = next_utf8_start(chunk, blen-2) - 1
			if (splitpos != .) {
			
				chunk = substr(chunk, 1, splitpos)
				fseek(fh, splitpos-blen, 0)
				blen = strlen(chunk)
				
			}
			
		}
				
		chunk = ustrfix(chunk)
		
		_tab_multibyte_utf8(cpN, chunk, strtoreal(st_local("buf_utf8")))
			
	}
	fclose(fh)
	
	
}   /*  ... _tab_file_multibyte_utf8()  <<<<<<<<<< */


/*  >>>>>>>>>>  _tab_variable() ...

(This function updates the count vector directly)

Tabulates the frequency of UTF-8 characters in a string variable.

With the introduction of long strings in Stata 13, a single string variable can
store an astounding about of data, up to 2,000,000,000 bytes per observation for
up to 2,147,483,647 observations even in the most basic Stata version. 

To handle efficiently all scenarios, we group observations into chunks based on
string length in bytes. String values are moved into Mata, one chunk at a time. 

*/

void _tab_variable (

    real   colvector N,        // count vector
    string scalar    vname,    // name of string variable
    string scalar    obsname,  // name of the observation identifier
    string scalar    touse     // name of sample variable

)
{

	real   colvector slen, obs
    real   matrix    ichunk
    real   scalar    k, chunk_target
    string colvector chunk
    string scalar    s, vlen
    
    
	chunk_target = strtoreal(st_local("buf_chunk"))

	vlen = st_tempname()
	stata( "gen long " + vlen + " = strlen(" + vname + ")" )

	
	slen = st_data(., vlen,    touse)
	obs  = st_data(., obsname, touse)
	
	ichunk = get_chunk_indices(obs, slen, chunk_target)

	for (k = 1; k <= rows(ichunk); k++) {
	
		chunk = st_sdata( (ichunk[k,1], ichunk[k,2]) , vname, touse )
		
		s = strcol2scalar(chunk)

		s = ustrfix(s)

		if (st_local("ascii") == "") _tab_ascii(N, s)

		_tab_multibyte_utf8(N, s, strtoreal(st_local("buf_utf8")))
			
	}
	
	st_dropvar(vlen)
	
}   /*  ... _tab_variable()  <<<<<<<<<< */


struct UCD_info {

	string scalar    filepath
	real   colvector cp
	string colvector cp_name
	
}

struct table_indices {

	real colvector n    // index to count
	real colvector u
	
}  


end

version 9.2

mata:

/*  >>>>>>>>>>  _tab_ascii() ...

(This function updates the count vector directly)

Instead of processing the UTF-8 byte stream one Unicode character at a time, it
is more efficient to simply ouput the whole string to a temp file and use
-hexdump- to calculate frequencies for char(0) to char(127).

*/

void _tab_ascii(

	real   colvector N,
	string scalar    s

)
{

    real   scalar i, n
    string scalar ftemp
    
    
	if (s == "") return
	
	ftemp = st_tempfilename()
	string2file(s,ftemp)

	stata("hexdump " + char(96) + char(34) + ftemp + char(34) + char(39) + 
			", tab res", 1)
	
	for (i = 0; i <= 127; i++) {
	
		n = st_numscalar("r(c" + strofreal(i) + ")")
		if (n != .) N[i+1] = N[i+1] + n
		
	}
		
	unlink(ftemp)

}   /*  ... _tab_ascii()  <<<<<<<<<< */


end

version 9.2

mata:

/*  >>>>>>>>>>  _tab_file_ascii() ...

(This function updates the count vector directly)

Use -hexdump- to tabulate ASCII frequency counts (fastest method by far)
and add them to the count vector.

*/

void _tab_file_ascii (

	real   colvector N, 
    string scalar    fname

)
{

    real scalar    i, n, rc
    
	rc = _stata("hexdump " + char(96) + char(34) + fname + char(34) + char(39) + 
					", tab res", 1)
	
	if (rc) {
		errprintf(`"error trying to process file: "%s"\n"', fname)
		exit(error(rc))
	}

	for (i = 0; i <= 127; i++) {

		n = st_numscalar("r(c" + strofreal(i) + ")")
		if (n != .) N[i+1] = N[i+1] + n
	
	}
	
	
}   /*  ... _tab_file_ascii()  <<<<<<<<<< */


end

version 14.0

mata:

/*  >>>>>>>>>>  _tab_multibyte_utf8() ...

(This function updates the count vector directly)

*** WARNING ***
This function expects a valid UTF-8 string, -use ustrfix()- before calling.

To process UTF-8 byte sequences, we convert a string to a byte stream using the
-ascii()- function. This requires 8 bytes to store each byte code in the string.
To reduce memory demands (which could go up to 16GB for a single strL value at
max length), we process long strings by substrings.

Single-byte UTF-8 are handled by -_tab_ascii()- and are removed from the byte
stream.

-------------------------------------------------------------------------------
*/


void _tab_multibyte_utf8(

	real   colvector count,
	string scalar    s,
	real   scalar    bufsize

)
{

	real   matrix    poslen
    real   rowvector multibyte, cp, bstream
    real   scalar    i, j
    string scalar    ss
    
    
	poslen = usubstr_setup(s, bufsize)
	
	for (i = 1; i <= rows(poslen); i++) {
	
		ss = substr(s, poslen[i,1], poslen[i,2])
		
		if ( ustrlen(ss) < strlen(ss) ) {
			
			bstream = ascii(ss)
	
			multibyte = select(bstream, bstream :>= 128)
	
			cp = multibyte_to_cp(multibyte) :+ 1

			for (j = 1; j <= cols(cp); j++) {

				count[cp[j]] = count[cp[j]] + 1

			}
			
		}
	}

}   /*  ... _tab_multibyte_utf8()  <<<<<<<<<< */


end

version 9.2

mata:

/*  >>>>>>>>>>  get_chunk_indices() ...

We group observations in the touse sample into chunks based on the accumulated
length in bytes.

We move to a new chunk if adding another observation would make the chunk larger 
than -target-. A long string value (over -target) ends up in a single-obs chunk.

Returns a matrix of observation indices for the start an end of each chunk.

*/

real matrix get_chunk_indices (

	real colvector obs,
	real colvector len,
	real scalar    target

)
{

	real matrix    irows
	real scalar    N, i, bufsize, lsum, chunk, next
	
	N = rows(len)
	if (N == 0) return( J(0,2,.) )
	
	bufsize = 1000
	irows   = J(bufsize,2,.)
	
	chunk = 1
	lsum  = len[1]
	irows[1,1] = obs[1]
	
	for (i = 2; i <= N; i++) {
	
		next = lsum + len[i]
	
		if (next > target) {
		
			irows[chunk,2] = obs[i - 1]
			chunk = chunk + 1
			if (chunk > rows(irows) ) irows = irows \ J(bufsize,2,.)
			irows[chunk,1] = obs[i]
			lsum = len[i]
			
		}
		else {
		
			lsum = next
			
		}
		
	}
	
	irows = irows[1::chunk,.]
	irows[chunk,2] = obs[N]

	return(irows)
    
}   /*  ... get_chunk_indices()  <<<<<<<<<< */


end

version 9.2

mata:

/*  >>>>>>>>>>  load_ucd() ...

The -chartab- package includes a comma-separated text file that contains UCD
data for all code points in the repertoire of the current UCD. At the moment,
this includes only the unique character name (or a "control" or "figment" name
alias if blank).

The data was extracted from the flat version of the Unicode Character Database
(UCD) in XML format, as downloaded from:

http://www.unicode.org/Public/5.2.0/ucdxml/ucd.all.flat.zip

*/


struct UCD_info scalar load_ucd (
	
	string scalar UCDfname

)
{

	struct UCD_info scalar U
    string colvector       lines
    string scalar          f
    
    
    U = UCD_info()
    
    // findfile() returns nothing if fed a valid full path
    f = ( fileexists(UCDfname) ? UCDfname : findfile(UCDfname) )

    // \uD800 is reserved for UTF-16 and is not valid UTF-8
	if ( f == "" ) {
		printf(`"{err}warning: Unicode Character Database "%s""', UCDfname)
		printf(" not found or could not be loaded{txt}\n")
		lines = "55296,<not in UCD repertoire>"
	}
	else lines = cat(f) \ "55296,<not in UCD repertoire>"
    
    U.cp      = strtoreal(substr(lines, 1, strpos(lines,",") :- 1))
    U.cp_name = strtrim(substr(lines, strpos(lines,",") :+ 1))
		
	U.filepath = f
	
	return(U)
	
}   /*  ... load_ucd()  <<<<<<<<<< */


end

version 14.0

mata:

/*  >>>>>>>>>>  multibyte_to_cp() ...

Converts a valid UTF-8 byte stream where all single-byte encodings (ASCII) have
been removed. 

The 4 most significant bits of the first byte indicate the number of bytes in
the UTF-8 sequence, i.e.:

2 chars = "1100"   decimal(11000000) = 192
3 chars = "1110"   decimal(11100000) = 224
4 chars = "1111"   decimal(11110000) = 240

The first 4 bits of the code point are stored in the rest of the byte.

Additional bytes store 6 bits of the code point, prefixed by "10" (10000000 is
128 in decimal). You can reconstruct the Unicode code point by removing the
prefix for each byte and adding values once properly shifted by 2^6. For
example, the code point for a 4 byte UTF-8 character is:

(b[1]-240)*2^6^3 + (b[2]-128)*2^6^2 + (b[3]-128)*2^6 + b[4]-128

Reference: https://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=iws-appendixa

*/

real rowvector multibyte_to_cp(

    real rowvector b

)
{

    real rowvector u
    real scalar    p, pnext, n, bcols
    
    bcols = cols(b)
    u = J(1, bcols/2, .)
    
    p = 1
    n = 0
    
    while (p < bcols) {
        
        if (b[p] < 224) {
            u[++n] = (b[p]-192)*64 + b[p+1]-128
            pnext = p + 2
        }
        else if (b[p] < 240) {
            u[++n] = (b[p]-224)*4096 + (b[p+1]-128)*64 + b[p+2]-128
            pnext = p + 3
        }
        else {
            u[++n] = (b[p]-240)*262144 + (b[p+1]-128)*4096 + (b[p+2]-128)*64 + b[p+3]-128
            pnext = p + 4
        }
        p = pnext
    }

    return(u[1..n])

}   /*  ... multibyte_to_cp()  <<<<<<<<<< */


end

version 14.0

mata:

/*  >>>>>>>>>>  next_utf8_start() ...

Starting from a given byte position (-n-), this function skips over UTF-8
continuation bytes in search of the start of the next valid UTF-8 sequence.

Since a UTF-8 sequence can span at most 4 bytes (current Unicode standard), it
does not need to look at more than 3 bytes. If all 3 bytes starting from
position -n- are continuation bytes, then the following byte is either the start
of the next UTF-8 sequence or part of an invalid sequence. Either way, it is
safe to break up the byte stream at that position.

UTF-8 continuation bytes range from 10000000 to 10111111 in binary or 128 to 191
in decimal.

-------------------------------------------------------------------------------
*/

real scalar next_utf8_start (

	string scalar s,
	real   scalar n
    
)
{
    real scalar pos, b, len
    
    len = strlen(s)
    pos = n
    
    if ( pos > len ) return(.)
    
    b = ascii(substr(s, pos, 1))
    if ( b <= 127 | b >= 192 ) return(pos)
    
    if ( ++pos > len ) return(.)
    b = ascii(substr(s, pos, 1))
    if ( b <= 127 | b >= 192 ) return(pos)
    
    if ( ++pos > len ) return(.)
    b = ascii(substr(s, pos, 1))
    if ( b <= 127 | b >= 192 ) return(pos)
    
    if ( ++pos > len ) return(.)    
    return(pos)
        
}   /*  ... next_utf8_start()  <<<<<<<<<< */


end

version 9.2

mata:

/*  >>>>>>>>>>  pair_indices() ...

Pair the index of non-zero elements of our count vector with the relevant
entry in the UCD.

The last entry of the UCD is a dummy entry with a code point that cannot be
encoded in a valid UTF-8 sequence. All code points not found in the UCD are
matched to this dummy entry.

*/

struct table_indices scalar pair_indices(
	
	real   colvector count,
    struct UCD_info  scalar U

)
{

	struct table_indices scalar    iNU
    real                 colvector iu
    
    
    iNU = table_indices()
    
    iNU.n = selectindex(count)
    
	if (rows(iNU.n) == 0) {
		printf("{txt}no characters found\n")
		return(iNU)
	}
    
    // init Unicode space to point to the dummy "<not in UCD repertoire>" entry 
    iu = J(rows(count), 1, rows(U.cp))
    
    // match the cp in the UCD to the corresponding row index of the UCD
    iu[U.cp:+1] = 1::rows(U.cp)
    
    iNU.u = iu[iNU.n]
    
    return(iNU)
	
}   /*  ... pair_indices()  <<<<<<<<<< */


end

version 9.2

mata:

/*  >>>>>>>>>>  present_tab_results() ...

Loads the UCD data and pairs code points with non-zero counts to matching
entries in the UCD. The table is by printed in the Results window (default)
or replaces the data in memory.

*/

void present_tab_results(

    real   colvector N

)
{

    struct UCD_info      scalar UCD
    struct table_indices scalar ti
    
    
	st_rclear()

	UCD = load_ucd( st_local("ucd") )

	if (rows(UCD.cp) > 1) st_numscalar("r(ucdsize)", rows(UCD.cp)-1)
	
	ti = pair_indices(N, UCD)
	
	if (rows(ti.n) > 0) {

		if ( (st_local("replace") != "") ) replace_with_tabulation(ti, N, UCD)
		else print_tabulation(ti, N, UCD)
	
	}
	
	report_tab_totals(N)

}   /*  ... present_tab_results()  <<<<<<<<<< */



/*  >>>>>>>>>>  print_tabulation() ...

Prints the table of frequencies.

*/

void print_tabulation(

	struct table_indices scalar    idx, 
	real                 colvector count,
	struct UCD_info      scalar    U
	
)
{

    real   scalar    i, cp, w, ncp
    string scalar    sc
    
    
    // the number of rows in the table
    ncp = rows(idx.n)
    
    // the max width of the character name in bytes (UCD name is pure ASCII)
	w = max(strlen(U.cp_name[idx.u]))
	
	printf("\n")
	printf("{txt}   decimal  hexadecimal   character {c |}     frequency    unique name\n")
	printf("{hline 36}{c +}{hline 18}%s\n", sprintf("{hline %f}", w))
	
    for (i = 1; i <= ncp; i++) {
        cp = idx.n[i] - 1
        printf("{txt}%10.0fc", cp)
        sc = ( cp == 0 ? ustrtohex(char(0)) : ustrtohex(uchar(cp)) )  // bug in uchar()
		printf("{col 14}{txt}%10s", sc)
        sc = (cp < 32 ? " " : uchar(cp)) 
        printf("{col 31}{txt}%1uds", sc)
        printf("{col 37}{c |}{col 39}{res}%13.0fc", count[idx.n[i]])
        printf("{col 56}{txt}%s", U.cp_name[idx.u[i]])
        printf("\n")
    }

	printf("{hline 36}{c +}{hline 18}%s\n", sprintf("{hline %f}",w))

}   /*  ... print_tabulation()  <<<<<<<<<< */


/*  >>>>>>>>>>  replace_with_tabulation() ...

Replace the data in memory with the table of frequencies.

*/

void replace_with_tabulation(

	struct table_indices scalar    idx, 
	real                 colvector count,
	struct UCD_info      scalar    U

)
{

    real   colvector cp
    real   scalar    w
    string colvector cpx, sv
    
    
    st_dropvar(.)
    st_addobs(rows(idx.n), 1)
    
    cp  = idx.n :- 1
    cpx = ustrtohex(uchar(cp))
    if (cp[1] == 0) cpx[1] = ustrtohex(char(0))  // bug in uchar()
    
    st_store(., st_addvar("long", "cp_dec", 1), cp)
    st_varlabel("cp_dec", "Unicode code point - decimal")
    
    st_sstore(., st_addvar("str10", "cp_hex", 1), cpx)
    st_varlabel("cp_hex", "Unicode code point - hex")

    st_sstore(., st_addvar("str4", "cp_char", 1), uchar(cp))
    st_varlabel("cp_char", "Unicode character")

    st_store(., st_addvar("long", "cp_freq", 1), count[idx.n])
    st_varlabel("cp_freq", "frequency")

	// bug in Mata? if there's only one row in U.cp_name, a colvector
	// of subsripts generates a rowvector
	if ( rows(U.cp_name) == 1 ) sv = U.cp_name[idx.u]'
	else sv = U.cp_name[idx.u]

    w = max(strlen(sv))
    st_sstore(., st_addvar((w), "cp_name", 1), sv)
    st_varformat("cp_name", "%-"+strofreal(w)+"s")
    st_varlabel("cp_name", "Unicode unique character name")
    
}   /*  ... replace_with_tabulation()  <<<<<<<<<< */


/*  >>>>>>>>>>  report_tab_totals() ...

Print overall counts and set stored return scalars

*/

void report_tab_totals(

	real colvector count

)
{

    real scalar nascii, ntot, nmb, distincta, distinctmb, urc, durc
	real colvector N
    

    ntot = sum(count)
 	st_numscalar("r(fc)", ntot)

	// ASCII
    nascii = sum(count[1::128])
	N = count[1::128]
	distincta = rows(select(N, N :> 0))

	// Unicode replacement character
	urc = count[65534]
	durc = ( urc > 0 ? 1 : 0)

	// Multibyte UTF-8
	N = count[|129\.|]
	nmb = sum(N) - urc
	distinctmb = rows(select(N, N :> 0)) - durc
    
    printf("{txt}\n")
	printf("{txt}{col 30}       freq. count   distinct\n")

	printf("{txt}ASCII characters{col 30} = {res}%15.0fc  %9.0fc\n", 
			nascii, distincta)
 	st_numscalar("r(fc_ascii)", nascii)
 	st_numscalar("r(dis_ascii)", distincta)

	printf("{txt}Multibyte UTF-8 characters{col 30} = {res}%15.0fc  %9.0fc\n", 
			nmb, distinctmb)
    st_numscalar("r(fc_mb_utf8)", nmb)
    st_numscalar("r(dis_mb_utf8)", distinctmb)

	printf("{txt}Unicode replacement character{col 30} = {res}%15.0fc  %9.0fc\n", 
			urc, durc)
    st_numscalar("r(urc)", urc)
    st_numscalar("r(has_urc)", durc)
    
    printf("{txt}Total Unicode characters{col 30} = {res}%15.0fc  %9.0fc\n", 
			ntot, distincta + distinctmb + durc)
	
 	st_numscalar("r(distinct)", distincta + distinctmb + durc)
        
    printf("{txt}\n")
    
}   /*  ... report_tab_totals()  <<<<<<<<<< */

end

version 9.2

mata:

/*  >>>>>>>>>>  stored_results() ...

*/

void stored_results(

	real colvector count
	
)
{

	real matrix cpN, cpNa, cpNc, cpNp, cpNmb


	// reduce to non-zero code points
	cpN = range(0,rows(count)-1,1) , count
	cpN = select(cpN, cpN[.,2] :> 0)


	// all ASCII code points
	cpNa = select(cpN, cpN[.,1] :<= 127)
	stored_c_results(cpNa)
	

	// multibyte Unicode
	cpNmb = select(cpN, cpN[.,1] :>= 128)
	st_global("r(multibyte)", invtokens(strofreal(cpNmb[.,1])'))
	stored_c_results(cpNmb)


	// ASCII control characters
	cpNc = select(cpNa, cpNa[.,1] :< 32 :| cpNa[.,1] :== 127)
	st_global("r(ascii_control)", invtokens(strofreal(cpNc[.,1])'))


	// ASCII printable characters
	cpNp = select(cpNa, cpNa[.,1] :>= 32 :& cpNa[.,1] :< 127)
	st_global("r(ascii_printable)", invtokens(strofreal(cpNp[.,1])'))


}   /*  ... stored_results()  <<<<<<<<<< */


/*  >>>>>>>>>>  stored_c_results() ...

*/

void stored_c_results(

	real matrix cpN
	
)
{

    real   scalar    i

	for (i = 1; i <= rows(cpN); i++) {

		st_numscalar("r(c"+ strofreal(cpN[i,1]) +")", cpN[i,2])

	}



}   /*  ... stored_c_results()  <<<<<<<<<< */


end


version 10.0

mata:

/*  >>>>>>>>>>  strcol2scalar() ...

Converts a string colvector to a string scalar. Adapted from -invtokens()-. This
one is faster because it it not concerned with separators and there's no need to
transpose to a rowvector.

Note that _substr() was introduced in Stata 10

*/

string scalar strcol2scalar (

	string colvector s

)
{

	real   scalar    N, i, next, lsum
	real   colvector blen
	string scalar    ss
	
	
	N = rows(s)
	
	if (N == 0) return( "" )
	if (N == 1) return( s )
	
	blen = strlen(s)
	lsum = colsum(blen)
	
	// will throw an error if lsum > (2^31-2)
	ss = lsum * " "

	_substr(ss, s[1], 1)
	next = blen[1] + 1
	
	for (i = 2; i <= N; i++) {
		_substr(ss, s[i], next)
		next = next + blen[i] 
	}
	
	return(ss)
    
}   /*  ... strcol2scalar()  <<<<<<<<<< */


end

version 9.2

mata:

/*  >>>>>>>>>>  string2file() ...

Writes a string scalar to a file

*/

void string2file (

	string scalar s,
	string scalar fname

)
{

    real   scalar fh

	fh = fopen(fname, "w")
	fwrite(fh, s)
	fclose(fh)

}   /*  ... string2file()  <<<<<<<<<< */


end

version 14.0

mata:

/*  >>>>>>>>>>  usubstr_setup() ...

To split very long UTF-8 strings into substrings, we do not want to use Stata's
Unicode string functions because they will be slow as molasses due to the fact
that they have to scan for invalid UTF-8 sequences and tally Unicode characters.

Instead, we scan the byte stream for a suitable break point that does not split
the byte stream in the middle of a valid UTF-8 byte sequence. 

The function returns a matrix where each row contains the byte position of the
start of the substring and the length in byte.

-------------------------------------------------------------------------------
*/

real matrix usubstr_setup (

	string scalar s,
	real   scalar target

)
{

	real matrix bl
	real scalar i, pos, next, slen
	
	
	slen = strlen(s)
	if (slen == 0) return( J(0,2,.) )
	
	bl = J(ceil( slen / target ), 2, .)
	
	i = 0
	pos = 1
	while (pos <= slen) {
	
    	bl[++i,1] = pos
    	next = next_utf8_start(s, pos + target)
	    bl[i,2] = next - pos
	    pos = next
	}

	return(bl[1::i,.])
    
}   /*  ... usubstr_setup()  <<<<<<<<<< */


end

exit


The -chartab- package includes a subset of the UCD (Unicode Character Database).
As requested in the license, here is a copy of the copyright and permission
notice as copied on 12feb2019 from:

	https://www.unicode.org/license.html



COPYRIGHT AND PERMISSION NOTICE

Copyright © 1991-2019 Unicode, Inc. All rights reserved.
Distributed under the Terms of Use in https://www.unicode.org/copyright.html.

Permission is hereby granted, free of charge, to any person obtaining
a copy of the Unicode data files and any associated documentation
(the "Data Files") or Unicode software and any associated documentation
(the "Software") to deal in the Data Files or Software
without restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, and/or sell copies of
the Data Files or Software, and to permit persons to whom the Data Files
or Software are furnished to do so, provided that either
(a) this copyright and permission notice appear with all copies
of the Data Files or Software, or
(b) this copyright and permission notice appear in associated
Documentation.

THE DATA FILES AND SOFTWARE ARE PROVIDED "AS IS", WITHOUT WARRANTY OF
ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT OF THIRD PARTY RIGHTS.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR HOLDERS INCLUDED IN THIS
NOTICE BE LIABLE FOR ANY CLAIM, OR ANY SPECIAL INDIRECT OR CONSEQUENTIAL
DAMAGES, OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE,
DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THE DATA FILES OR SOFTWARE.

Except as contained in this notice, the name of a copyright holder
shall not be used in advertising or otherwise to promote the sale,
use or other dealings in these Data Files or Software without prior
written authorization of the copyright holder.


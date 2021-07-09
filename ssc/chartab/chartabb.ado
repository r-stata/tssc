*! version 1.0.0, 14feb2019, Robert Picard, robertpicard@gmail.com
program chartabb

    version 10
    
	// default target size of chunks when combining obs
	local bchunk = 1e7

    syntax [varlist(string default=none)] [if] [in], ///
        [                              ///
            Files(string asis)         ///
            Scalars(namelist)          ///
            Literals(string asis)      ///
			buf_chunk(integer `bchunk') ///
       ]


	if `bchunk' != `buf_chunk' dis "using buf_chunk = " `buf_chunk'


	mata: main()
     
        
end


version 10
mata:
mata set matastrict on


void main (

)
{

	real colvector count

	count   = J(256, 1, 0)

	_do_varlist(count)
	_do_filelist(count)
	_do_scalars(count)
	_do_literals(count)

	stored_results(count)
	print_tabulation(count)

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
		_tab_file( N, temp )
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
		_tab_file( N, temp )
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

		_tab_file( N, items[j] )

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


/*  >>>>>>>>>>  _tab_variable() ...

(This function updates the count vector directly)

Tabulates the frequency of byte codes in a string variable.

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
	
		chunk = st_sdata( (ichunk[k,1], ichunk[k,2]) , vname, touse)
		
		s = strcol2scalar(chunk)

		_tab_byte_codes(N, s)
			
	}
	
	st_dropvar(vlen)

	
}   /*  ... _tab_variable()  <<<<<<<<<< */


end

version 9.2

mata:

/*  >>>>>>>>>>  _tab_byte_codes() ...

(This function updates the count vector directly)

*/

void _tab_byte_codes(

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
	
	for (i = 0; i <= 255; i++) {
	
		n = st_numscalar("r(c" + strofreal(i) + ")")
		if (n != .) N[i+1] = N[i+1] + n
		
	}
		
	unlink(ftemp)

}   /*  ... _tab_byte_codes()  <<<<<<<<<< */


end

version 9.2

mata:

/*  >>>>>>>>>>  _tab_file() ...

(This function updates the count vector directly)

Use -hexdump- to tabulate byte codes frequency counts (fastest method by far)
and add them to the count vector.

*/

void _tab_file (

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

	for (i = 0; i <= 255; i++) {

		n = st_numscalar("r(c" + strofreal(i) + ")")
		if (n != .) N[i+1] = N[i+1] + n
	
	}

	
}   /*  ... _tab_file()  <<<<<<<<<< */


end

version 9.2

mata:

/*  >>>>>>>>>>  dec2hex() ...

Converts an integer to hex, left-zero-padded to the specified length.

Returns an empty string if the input is negative or is not an integer.

*/

string scalar dec2hex(

	real scalar n,
	real scalar len

)
{

	string scalar s
	real scalar nn, r

	if ( (n - trunc(n)) != 0 | n < 0 ) return("")

	nn = n
	s = ""

	while (nn > 0) {
		r  = mod(nn, 16)
		nn = trunc(nn / 16)
		s = ( r < 10 ? char(r+48) : char(r+55) ) + s
	}

	if ( strlen(s) < len ) s = substr("0" * len + s, -len, len)

	return(s)


}   /*  ... dec2hex()  <<<<<<<<<< */


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

/*  >>>>>>>>>>  print_tabulation() ...

*/

void print_tabulation(

	real colvector count
	
)
{

    real   scalar    i, bc
    string scalar    s
    

	printf("\n")
	printf("{txt}   decimal  hexadecimal   character {c |}     frequency\n")
	printf("{hline 36}{c +}{hline 18}%s\n", sprintf("{hline %f}", 50))
	
    for (i = 1; i <= 256; i++) {

		bc = i - 1

		if (count[i] > 0) {

			st_numscalar("r(c"+ strofreal(bc) +")", count[i])

			printf("{txt}%10.0fc", bc)

			printf("{col 14}{txt}%10s", dec2hex(bc, 2))

			s = ( bc < 32 | bc == 127 ? " " : char(bc) ) 
			printf("{col 31}{txt}%1s", s)

			printf("{col 37}{c |}{col 39}{res}%13.0fc", count[i])
			printf("\n")

		}
    }

	printf("{hline 36}{c +}{hline 18}%s\n", sprintf("{hline %f}",50))


	printf("{txt}ASCII control characters{col 29} = {res}%15.0fc\n", st_numscalar("r(Ncontrol)"))
	printf("{txt}ASCII printable characters{col 29} = {res}%15.0fc\n", st_numscalar("r(Nprintable)"))
	printf("{txt}Extended characters{col 29} = {res}%15.0fc\n", st_numscalar("r(Nextended)"))
	printf("{txt}Total characters (bytes){col 29} = {res}%15.0fc\n", st_numscalar("r(Ntotal)"))
        
    printf("{txt}\n")
}   /*  ... print_tabulation()  <<<<<<<<<< */


end

version 9.2

mata:

/*  >>>>>>>>>>  stored_results() ...

*/

void stored_results(

	real colvector count
	
)
{

    real   scalar    i, bc, ntotal, ncontrol, nprintable, nextended
    string scalar    s, control, printable, extended, ascii

	st_rclear()

	control = printable = extended = ""
	ntotal = ncontrol = nprintable = nextended = 0
    	
    for (i = 1; i <= 256; i++) {

		bc = i - 1

		if (count[i] > 0) {

			st_numscalar("r(c"+ strofreal(bc) +")", count[i])

			s = strofreal(bc)

			if ( bc <= 127 ) {

				if ( bc < 32 | bc == 127 ) {

					ncontrol = ncontrol + count[i]
					control = control + " " + s

				}
				else {

					nprintable = nprintable + count[i]
					printable = printable + " " + s

				}
			}
			else {

				nextended = nextended + count[i]
				extended = extended + " " + s

			}

			ntotal = ntotal + count[i]

		}
    }

	st_global("r(extended)", strtrim(extended))
	st_global("r(control)", strtrim(control))
	st_global("r(printable)", strtrim(printable))

	st_numscalar("r(Nextended)", nextended)
	st_numscalar("r(Nprintable)", nprintable)
	st_numscalar("r(Ncontrol)", ncontrol)
	st_numscalar("r(Ntotal)", ntotal)

}   /*  ... stored_results()  <<<<<<<<<< */


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


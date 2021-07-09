program define bundle
*! bundle png images in a web page using base64 encoding <grodri@princeton.edu>
	version 11
	syntax using/ [, OUTput(string)]
	mata st_local("infile", addsuffix(`"`using'"', ".html"))
	confirm file `"`infile'"'
	capture noisily mata outfile = bundle(`"`infile'"', `"`output'"')
	local failed = _rc
	if _rc {
		forvalues i = 0/20 {
			capture mata: fclose(`i')
		}
	}
	if `failed' exit
	mata st_local("outfile", outfile)
	if `"`outfile'"' == "" display "No png's found"
	else display `"  bundled in `outfile'"'	
end

mata:
string scalar bundle(string scalar infile, string scalar outfile) {
	string vector lines, trio
	string scalar imgfile
	real vector matches, bytes
	real scalar m, fout, i
	// read html file and find images
	lines = cat(infile)
	matches = strmatch(strlower(lines), "*<img *")
	m = sum(matches)
	if(m < 1) return("")
	m = 0
	
	// open output file
	outfile = outfile == "" ? dashb(infile) : addsuffix(outfile, ".html")
	if(fileexists(outfile)) {
		unlink(outfile)
	}
	fout = fopen(outfile, "w")
	
	// bundle all png's
	for(i = 1; i <= length(lines); i++) {
		if(!matches[i]) {
			fput(fout, lines[i])
		}
		else {
			// get src
			trio = srcsplit(lines[i])
			imgfile = trio[2]
			if(substr(imgfile, 1, 10) == "data:image") continue
			printf("{txt}  %s\n", imgfile)
			// must be png
			if(strpos(strlower(imgfile),".png") < 1) {
				errprintf("Can only bundle png files\n")
				fclose(fout)
				exit(601)
			}
			// must exist
			if(!fileexists(imgfile)) {
				errprintf("file not found\n")
				fclose(fout)
				exit(601)
			}
			// fetch and encode
			bytes = getbytes(imgfile)
			fwrite(fout, trio[1])
			fwrite(fout, `""data:image/png;base64,"')			
			fwrite(fout, base64(bytes))
			fwrite(fout, `"""')
			fput(fout, trio[3])
			m++
		}
	}
	fclose(fout)
	return(m > 0 ? outfile : "")
}
//
// insert -b at end of file name
//
string scalar dashb(string scalar filename) {
	string name, extension
	extension = pathsuffix(filename)
	name = pathrmsuffix(filename)
	return(name + "-b" + extension)
}
// Extract src from tag
//
string vector srcsplit(string scalar line) {
	real scalar bot, top, m
	string scalar lc, s, quote
	lc = strlower(line)
	m = regexm(lc,"src *= *")
	assert(m > 0)
	s = regexs()
	bot = strpos(lc, s) + strlen(s)
	quote = substr(lc,bot,1)
	top = bot + 1
	while(top <= strlen(lc) & substr(lc,top,1) != quote) {
		top++
	}
	return(
		substr(line,1,bot-1) \ 
		substr(line,bot+1,top-bot-1) \ 
		substr(line,top+1)
	)	
}
//
// Read file into buffer growing by 10k
//
real vector getbytes(string scalar filename) {
	real scalar fh, p
	real vector bytes
	string scalar c
	fh = fopen(filename, "r")
	bytes = J(1, 10000, 0)
	p = 0
	while( (c=fread(fh,1)) != J(0,0,"")){
		p++
		if(p > length(bytes)) {
			bytes = bytes , J(1,10000,0)
		}
		bytes[p] = ascii(c)		
	}
	fclose(fh)
	return(bytes[1::p])
}	
//
// add suffix to file name if not there
//
string scalar addsuffix(string scalar name, string scalar suffix) {
	return(pathsuffix(name) == "" ? name + suffix : name)
}
// ---------------------------------------------------------
// Base 64 encoding 

string scalar base64(real rowvector bytes) {
	real scalar nblocks, remainder, nchars, b
	real rowvector asciis, from, to, tail, hex
	
	// split into blocks of 3 plus remainder
	nblocks = floor(length(bytes)/3)
	remainder = length(bytes) - 3*nblocks	
	nchars = 4 * nblocks
	if(remainder > 0) nchars = nchars + 4;
	asciis = J(1, nchars, 0) // must be row vector
	
	// convert each block of 3 bytes to 3 ascii codes
	from = 1..3
	to   = 1..4
	for(b=1; b <= nblocks; b++) {
		asciis[to] = b64block(bytes[from])
		//char(asciis[to])
		from = from :+ 3
		to = to :+ 4		
	}
	
	// handle lengths not multiples of 3 (padd = 3 - remainder)
	if(remainder > 0) {
		tail = J(1, 3, 0)
		tail[1..remainder] = bytes[from[1]..length(bytes)]
		hex = b64block(tail)
		hex[(remainder+2)..4] = J(1, 3 - remainder, ascii("="))
		asciis[to] = hex
	}
	
	// convert ascii codes to a string
	return(char(asciis))
}

// byte to binary bits
real vector b64bits(real scalar b) {
	real rowvector powers, digits
	real scalar d, p
	powers = (128, 64, 32, 16, 8, 4, 2)
	digits = (0, 0, 0, 0, 0, 0, 0, 0)
	for(p=1; p <= 7; p++) {
		d = floor(b/powers[p])
		if(d > 0) b = b - d * powers[p]
		digits[p] = d
	}
	digits[8] = b
	return(digits)
}
// hex encode 6 bits
real scalar b64hex(real vector bits) {
	string scalar map
	real rowvector powers
	real scalar r, p
	map = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" + 
	"abcdefghijklmnopqrstuvwxyz0123456789+/"
	powers = (32, 16, 8, 4, 2, 1)
	r = 0
	for(p=1; p <= 6; p++) {
		if(bits[p] == 1) r = r + powers[p]
	}
	return(ascii(substr(map, r+1, 1)))
}
// hex encode 3 bytes	
real vector b64block(real vector w) {
	real rowvector bits, hex
	bits = b64bits(w[1]), b64bits(w[2]), 	b64bits(w[3])
	hex = b64hex(bits[1..6]),   b64hex(bits[7..12]),
		  b64hex(bits[13..18]), b64hex(bits[19..24])
	return(hex)
}
end

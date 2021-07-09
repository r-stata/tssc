
mata
mata set matastrict on


real scalar sp_nbrace(string scalar str, string scalar type) 
{
	real scalar pos, n

	pos = 1 
	n   = 0
	while( (pos = ustrpos(str,type, pos) + 1) != 1 ) {
		n = n + 1
	}
	return(n)
}

string scalar sp_stripbraces(string scalar str) 
{
	real scalar start , finish

	if (usubstr(ustrltrim(str), 1,1) == "{" & 
	    usubstr(ustrrtrim(str),-1,1) == "}") {
		start = ustrpos(str,"{")
		finish = ustrrpos(str, "}")
		return(usubstr(str,start+1, finish-start-1))
	}
	else {
		return(str)
	}
}

string scalar sp_stripbrackets(string scalar str) 
{
	real scalar start , finish

	if (usubstr(ustrltrim(str), 1,1) == "[" & 
	    usubstr(ustrrtrim(str),-1,1) == "]") {
		start = ustrpos(str,"[")
		finish = ustrrpos(str, "]")
		return(usubstr(str,start+1, finish-start-1))
	}
	else {
		return(str)
	}
}

string scalar sp_remove_all_braces(string scalar str)
{
	str = usubinstr(str, "{", "", .)
	str = usubinstr(str, "}", "", .)
	return(str)
}

void sp_parse_authors(struct strpres scalar pres)
{
	real   scalar    i
	string rowvector key
	string matrix    parsed
	
	for(i = 1 ; i <= rows(pres.bib.keys); i++) {
		key = pres.bib.keys[i]
		parsed = sp_parse_author(pres,key)
		key = (key,"author_first")
		asarray(pres.bib.bibdb,key, parsed[.,1])
		key[2] = "author_last"
		asarray(pres.bib.bibdb,key, parsed[.,2])
	}
}

string colvector sp_split_on_and(string scalar str)
{
	string       colvector res
	string       scalar    temp, token
	transmorphic scalar    t
	
	res = J(0,1, "")
	temp = ""
	
	t = tokeninit(" ", "", "{}")	
	tokenset(t, str)
	
	while ((token= tokenget(t)) != "") {
		if (token == "and" & temp != "") {
			res = res \ temp
			temp = ""
		}
		else {
			temp = temp + " " + token
		}
	}
	res = res \ temp
	return(res)
}

string rowvector sp_parse_name(string scalar str) 
{
	string       scalar    first, last
	string       rowvector temp
	real         scalar    i, hascomma
	transmorphic scalar    t
	
	first = ""
	last = ""
	hascomma = 0
	
	t = tokeninit(" ", ",", "{}")
	tokenset(t, str)
	temp = tokengetall(t)

	for (i=1 ; i <= cols(temp); i++) {
		if (temp[i] == ",") {
			last = first
			first = ""
			hascomma = 1
		}
		else {
			if (hascomma == 1) {
				first = first + " " + temp[i]
			}
		}
		if (hascomma == 0) {
			if (i == cols(temp)) {
				last = temp[i]
			}
			else {
				first = first + " " + temp[i]
			}
		}
	}
	last = sp_stripbraces(last)
	return((ustrtrim(first), ustrtrim(last)))
	
}

string matrix sp_parse_author(struct strpres scalar pres, string scalar key)
{
	real   scalar    i
	string colvector unparsed
	string matrix    parsed
	
	parsed = J(0,2,"")
	
	unparsed = asarray(pres.bib.bibdb,(key,"author"))
	if (unparsed != "") {	
		unparsed = sp_split_on_and(unparsed)
		
		for (i = 1 ; i <= rows(unparsed) ; i++)  {
			parsed = parsed \ sp_parse_name(unparsed[i])
		}
	}
	return(parsed)	
}


void sp_set_style(struct strpres scalar pres)
{
	if (pres.bib.stylefile == "") {
		sp_base_style(pres)
	}
	else {
		sp_import_style(pres)
	}
}

void sp_base_style(struct strpres scalar pres)
{
	string rowvector style 
	
    style = ("{p 4 8 2}", "[author]", " (", "[year]", "), {it:", "[title]", "}.  ", 
    "[address]", ": ", "[publisher]", ".{p_end}")
    asarray(pres.bib.style, "book", style)
     
    style = ("{p 4 8  2}", "[author]", " (", "[year]", `"), ""', "[title]", `"", {it:"', 
    "[journal]", "}, {bf:", "[volume]", "}(", "[number]", "), pp. ", "[pages]", 
    ".{p_end}")
    asarray(pres.bib.style, "article", style)
    
      style = ("{p 4 8 2}", "[author]", " (", "[year]", `"), ""', "[title]", `"". In {it:"', 
    "[booktitle]", "}, edited by ", "[editor]", ", pp. ", "[pages]", ". ", 
    "[address]", ": ", "[publisher]", ".{p_end}")
    asarray(pres.bib.style, "incollection", style)
    
      style = ("{p 4 8 2}", "[author]", " (", "[year]", "), {it:", "[title]", "}. ", 
    "[school]", ".{p_end}")
    asarray(pres.bib.style, "phdthesis", style)
    
      style = ("{p 4 8 2}", "[author]", " (", "[year]", "), {it:", "[title]", "}. ", 
    "[note]", ".{p_end}")
    asarray(pres.bib.style, "unpublished", style)
	
}

void sp_import_style(struct strpres scalar pres)
{
	real   scalar in_entry, fh, openbraces, closebraces
	string scalar entry, line
	
	in_entry = 0
	fh = sp_fopen(pres, pres.bib.stylefile, "r")
	
	while ((line = fget(fh)) != J(0,0,"") ) {
		if ( in_entry == 0 & usubstr(ustrltrim(line),1,1) == "@") {
			in_entry = 1
			openbraces = 0
			closebraces = 0
			entry = ""
		}
		if (in_entry == 1) {
			openbraces = openbraces + sp_nbrace(line, "{")
			closebraces = closebraces + sp_nbrace(line, "}")
			entry = entry + line
			if (openbraces - closebraces == 0) {
				in_entry = 0
				sp_parse_style_entry( pres, entry )
			}
		}		
	}
	sp_fclose(pres,fh)
}

void sp_parse_style_entry(struct strpres scalar pres, string scalar entry)
{
	real         scalar    st, fi 
	string       scalar    type
	string       rowvector res
	transmorphic scalar    t
	
	st = ustrpos(entry, "@") + 1
	fi = ustrpos(entry, "{")
	type = usubstr(entry, st , fi - st)

	entry = ustrtrim(stripbraces(usubstr(entry, fi, .)))
	t = tokeninit("", (""),  ("[]"))
	tokenset(t, entry)
	res = tokengetall(t)
	asarray(pres.bib.style, type, res)
}

void sp_write_bib(struct strpres scalar pres, real scalar fh) 
{
	real scalar i

	for (i = 1 ; i <= rows(pres.bib.refs) ; i++) {
		sp_write_bib_entry(pres, pres.bib.refs[i], fh)
		if (i < rows(pres.bib.refs)) fput(fh, " ")
	}
}

void sp_write_bib_entry(struct strpres scalar pres, string scalar key, real scalar fh) 
{
	string scalar    type, res, entry
	string rowvector mask
	string colvector first, last
	real   scalar    i, j
	real   colvector slides
	
	fput(fh, "{marker " + key + "}{...}")
	type = asarray(pres.bib.bibdb,(key,"type"))
	mask = asarray(pres.bib.style, type)
	res = ""
	for (i = 1; i<=cols(mask); i++) {
		if (usubstr(mask[i],1,1) == "[") {
			entry = sp_stripbrackets(mask[i])
			if (entry == "author") {
				first = asarray(pres.bib.bibdb, (key, "author_first"))
				last = asarray(pres.bib.bibdb, (key, "author_last"))
				if (pres.bib.authorstyle == "first last") {
					for (j = 1; j < rows(first) ; j++) {
						res = res + first[j] + " " + last[j] 
						if (rows(first)>2) res = res + ","
						if (j < rows(first)-1) res = res + " "
					}
					if (j > 1) res = res + " " + pres.bib.and + " "
					res = res + first[j] + " " + last[j]
				}
				else {
					for (j = 1; j < rows(first) ; j++) {
						res = res + last[j] + ", " + first[j]
						if (rows(first)>2) res = res + ";"
						if (j < rows(first)-1) res = res + " "
					}
					if (j > 1) res = res + " " + pres.bib.and + " "
					res = res + last[j] + ", " + first[j]				
				}
			}
			else if (entry == "year") {
				res = res + asarray(pres.bib.bibdb,(key,"year")) + 
				            asarray(pres.bib.bibdb,(key,"postfix"))
			}
			else {
				res = res + asarray(pres.bib.bibdb,(key,entry))
			}
		}
		else{
			res = res + mask[i]
		}
	}
	fput(fh, res)
}

string scalar sp_write_single_ref(struct strpres scalar pres, string scalar key)
{
	string matrix authors
	string scalar res
	real   scalar i
	
	authors = asarray(pres.bib.bibdb, (key,"author_last"))

	res = ""
	for (i = 1 ; i < rows(authors); i++) {
		if (i > 1 & rows(authors) > 2) res = res + ", "
		res = res + authors[i]
	}
	if (i > 2) res = res + ","
	if (i > 1) res = res + " " + pres.bib.and + " "
	res = res + authors[i] 
	res = res + " " + asarray(pres.bib.bibdb,(key,"year")) +  
	      asarray(pres.bib.bibdb,(key,"postfix")) 
	return(res)
}

string scalar sp_write_ref(struct strpres scalar pres, string scalar str, real scalar snr)
{
	transmorphic scalar t
	string       scalar token, res, ref
	real         scalar nrefs, ncomment
	
	nrefs = 0
	ncomment = 0
	res = ""
	t = tokeninit(" ", "", "{}" )
	tokenset(t, str)
	while ( (token = tokenget(t)) != "") {
        if ( usubstr(token,1,1) != "{" ) {
			nrefs = nrefs + 1
			if (nrefs > 1 & ncomment < 2) res = res + "; "
			ncomment = 0
			ref = sp_write_single_ref(pres,token) 
			ref = "{view slide" + strofreal(pres.bib.bibslide) + ".smcl##" + token + ":" + ref + "}"
			res = res + ref

		}
		else  {
			ncomment = ncomment + 1
			if (nrefs >= 1 & ncomment == 2) res = res + "; "
			res = res + sp_stripbraces(token)
		}
    }
	res = "(" + res + ")"
	return(res)
}

string scalar sp_replaceref(struct strpres scalar pres, string scalar line, real scalar snr) {
	real   scalar    st, fi
	string scalar    rawref, ref
	
	st = 0

	while( (st = ustrpos(line, "/*cite", st) + 1 ) != 1) {
		fi = ustrpos(line, "*/", st)
		rawref = usubstr(line,st+6, fi-st-6)
		ref = sp_write_ref(pres, rawref, snr)
		line = usubstr(line,1, st-2) + ref + usubstr(line,fi+2,.)
	}
	
	return(line)
}

void sp_read_bib(struct strpres scalar pres) {
	real          scalar in_entry, fh, openbraces, closebraces
	string        scalar line, entry
	
	in_entry = 0
	fh = sp_fopen(pres, pres.bib.bibfile, "r") 

	while ( (line = fget(fh)) != J(0,0,"") ) {
		line = sp_remove_tab(pres,line) 
		if ( in_entry == 0 & usubstr(ustrltrim(line),1,1) == "@") {
			in_entry = 1
			openbraces = 0
			closebraces = 0
			entry = ""
		}
		if (in_entry == 1) {
			openbraces = openbraces + sp_nbrace(line, "{")
			closebraces = closebraces + sp_nbrace(line, "}")
			entry = entry + line
			if (openbraces - closebraces == 0) {
				in_entry = 0
				sp_parse_entry(entry, pres)
			}
		}
	}
	sp_fclose(pres,fh)
	sp_parse_authors(pres)
}

void sp_parse_entry(string scalar entry, struct strpres scalar pres) 
{

	string       scalar key, type, content, token
	real         scalar k
	transmorphic scalar t
	
	t = tokeninit(" "+char(9), (","),  ("{}"))
	tokenset(t, entry)
	type = tokenget(t)
	type = strlower(tokens(type, "@")[2])
	tokenset(t,sp_stripbraces(tokenget(t)))
	key = tokenget(t)
	pres.bib.keys = pres.bib.keys \ key
	asarray(pres.bib.bibdb,(key,"type"),type)
	while ((token= tokenget(t)) != "") {
		if (token == "," ) {
			k = -1
			if (key != "" & content != "" )  {
				if (type == "author") {
					content = sp_stripbraces(content)
				}
				else {
					content = sp_remove_all_braces(content)
				}
				asarray(pres.bib.bibdb,(key,type), content)
			}
		}
		k = k +1
		if (k == 1) {
			type = token
		}
		if (k == 2) {
			if (token != "=") {
				error(198)
			}
		}
		if (k == 3) {
			content = token
		}
		if (k >= 4) {
			content = content + " " +  token
		}
	}
	if (key != "" & content != "" )  {
		if (type == "author") {
			content = sp_stripbraces(content)
		}
		else {
			content = sp_remove_all_braces(content)
		}
		asarray(pres.bib.bibdb,(key,type), content)
	}
}

string colvector sp_extract_rawrefs(string scalar line, real scalar lnr) 
{
	real   scalar    st, fi
	string colvector res
	string scalar    err
	
	res = J(0,1, "")
	
	st = 0
	while( (st = ustrpos(line, "/*cite", st) + 1 ) != 1) {
		fi = ustrpos(line, "*/", st)
		if (fi == 0) {
			err = "{err}a /*cite was started on line {res}" + strofreal(lnr) +
			      " {err} but was not finished by a */"
			printf(err)
			exit(198)
		}
		res = res \ usubstr(line,st+6, fi-st-6)
	}
	return(res)
}

string colvector sp_extract_refs(string scalar line, real scalar lnr)
{
	string       colvector rawrefs, res
	string       scalar    token
	real         scalar    i
	transmorphic scalar    t
	
	res = J(0,1, "")
	t = tokeninit(" ", "", "{}" )
	rawrefs = sp_extract_rawrefs(line, lnr)
	for (i = 1 ; i <= rows(rawrefs) ; i++) {
		tokenset(t, rawrefs[i])
		while ( (token = tokenget(t)) != "") {
            if ( usubstr(token,1,1) != "{" ) {
				res = res \ token
			}
        }
	}
	return(res)
}

void sp_collect_refs(struct strpres scalar pres)
{
	real   scalar    source, lnr, txtopen, i
	string scalar    line
	string rowvector tline
	string colvector refs
	
	lnr      = 0
	txtopen  = 0

	source = sp_fopen(pres,pres.settings.other.source, "r")
	
	while ((line=fget(source))!=J(0,0,"")) {
		lnr = lnr + 1
		tline = tokens(line)
		if (cols(tline) > 0) {
			if (tline[1] == "/*txt") txtopen = 1
			if (tline[1] == "//txt") txtopen = 1
			if (tline[1] == "txt*/") txtopen = 0
			if (txtopen == 1 & pres.bib.write == "cited") {
				if (anyof(tline, "/*cite")) {
					refs = sp_extract_refs(line, lnr)
					for(i = 1 ; i <= rows(refs); i++) {
						if (pres.bib.refs == J(0,1,"")) {
							pres.bib.refs = refs[i]
						}
						else if (!anyof(pres.bib.refs,refs[i])) {
							pres.bib.refs = pres.bib.refs \ refs[i]
						}					
					}
				}
			}
		}
	}
	
	if (pres.bib.write == "all") {
		pres.bib.refs = asarray_keys(pres.bib.bibdb)
	}
	sp_fix_collisions(pres)
	sp_fclose(pres,source)
}

void sp_collect_bib(struct strpres scalar pres)
{
	real   scalar    source, dest, bibopen, bibslide
	real   scalar    txtopen, lnr
	string scalar    err, line
	string rowvector tline
	
	bibopen  = 0
	bibslide = 0
	lnr      = 0
	txtopen  = 0
	
	source = sp_fopen(pres,pres.settings.other.source, "r")
	dest   = sp_fopen(pres,pres.bib.bibfile, "w")
	
	while ((line=fget(source))!=J(0,0,"")) {
		lnr = lnr + 1
		tline = tokens(line)
		if (cols(tline) > 0) {
			if (tline[1] == "/*txt") txtopen = 1
			if (tline[1] == "//txt") txtopen = 1
			if (tline[1] == "txt*/") txtopen = 0
			if (tline[1] == "bib*/") {
				if (bibopen == 0) {
					err = "{err}tried to close a bibliography on line {res}" +
					    strofreal(lnr) + " {err}while none was open"
					printf(err)
					exit(198)
				}
				bibopen = 0
			}
			if (tline[1] == "/*bib") {
				if (bibopen ==  1) {
					err = "{err}tried to open bibliography on line {res}" +
					      strofreal(lnr) + " {err}while one was already open"
					printf(err)
					exit(198)
				}
				if (bibslide == 0) {
					err = "{err}tried to open a bibliography on line {res}" +
					      strofreal(lnr) + " {err}while not on a bibliography slide"
					printf(err)
					exit(198)
				}
				if (txtopen == 1) {
					err = "{err}tried to open a bibliography on line {res}" +
					      strofreal(lnr) + " {err}while a textblock was open"
					printf(err)
					exit(198)
				}
				bibopen = 1
			}
			else if (bibopen == 1) {
				fput(dest, line)
			}
			if (tline[1] == "//bib") {
				bibslide = 1
			}
			if (tline[1] == "//endbib")  { 
				bibslide = 0
				if (bibopen == 1) {
					err = "{err}tried to close the bibliography slide on " + 
					      "line {res}" + strofreal(lnr) + " {err}while a " +
						  "bibliography was still open"
					printf(err)
					exit(198)
				}
			}
		}
	}
	sp_fclose(pres,source)
	sp_fclose(pres,dest)
}

void sp_fix_collisions(struct strpres scalar pres) 
{
	string matrix     content
	string scalar     key, pf
	real   scalar     i, k, dup
	real   colvector  o
	
	k = rows(pres.bib.refs)
	if (k > 1) {
		content = J(k,4, "")
		for (i = 1 ; i <= k; i++) {
			key = pres.bib.refs[i]
			if (asarray_contains(pres.bib.bibdb, (key,"author"))) {
				content[i,1] = invtokens(asarray(pres.bib.bibdb,(key, "author_last"))')
				content[i,2] = asarray(pres.bib.bibdb,(key, "year"))
				content[i,3] = asarray(pres.bib.bibdb,(key, "title"))
				content[i,4] = key
			}
		}
		o = order(content,(1,2,3,4))
		content = content[o,.]
		pres.bib.refs = pres.bib.refs[o]
		
		dup = 0
		for (i = 2 ; i <= k; i++) {
			if ( content[|i,1 \ i, 2|] == content[|i-1,1 \ i-1, 2|] ) {
				dup = dup + 1
				if (dup == 1) {
					key = content[i-1,4]
					asarray(pres.bib.bibdb,(key, "postfix"), "a")
				}
				key = content[i,4]
				pf = strlower(numtobase26(dup+1))
				asarray(pres.bib.bibdb,(key,"postfix"),pf)
			}
			else {
				dup = 0
			}
		}
	}
}

void sp_init_bib(struct strpres scalar pres)
{
	if (pres.bib.bibslide != .) {
		if (pres.bib.bibfile == "" ) {
			pres.bib.bibfile = st_tempfilename()
			sp_collect_bib(pres)
		}
		sp_read_bib(pres)
		sp_set_style(pres)
		sp_collect_refs(pres)
	}
}

end

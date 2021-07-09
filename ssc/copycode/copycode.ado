*! version 1.0.0  14aug2012  dcs

program define copycode, rclass

version 10
syntax anything, ///
         Inputfile(string)   ///
       [ Targetfile(string)  ///
         noCopy              ///
         SImplemode          ///
         replace             ///
         force               ///
         STarbang(string)    ///
         noProgdrop ]


// OPTIONS CHECKS
capture confirm names `anything'
if _rc {
    disp as error `"`anything' invalid name."'
    exit 198
}
if `: word count `anything''>1 {  // not caught by -confirm names-
    disp as error `"You may supply only one project name at a time."'
    exit 198
}
local project = strlower(`"`anything'"')

if `"`copy'`targetfile'"'=="" {
    disp as error `"You must either use option 'targetfile' or option 'nocopy'."'
    exit 198
}

if "`copy'"!="" & `"`targetfile'"'!="" {
    disp as error `"Options 'targetfile' and 'nocopy' are mutually exclusive."'
    exit 198
}

if `"`starbang'"'!="" {
    local starbang = lower(strtrim(`"`starbang'"'))
    if !inlist(`"`starbang'"',"skip","first","all") {
        disp as error `"Input argument 'starbang' must be one of 'skip', 'first', 'all'."'
        exit 198
    }
}

// CHECKING INPUT FILE
// if path is relative, Stata automatically assumes that the working dir must be prepended
capture confirm file `"`inputfile'"'
if _rc {
    disp as error `"Input file `inputfile' not found."'
    exit 601
}

mata: inputchk(`"`inputfile'"', "`project'")  // if sth is wrong, returns local inputchkerr
if "`inputchkerr'"!="" {
    disp as error `"`inputchkerr'"'
    exit 9   // return code 9 is appropriate here
}

// DETERMINING MODE (SIMPLE / ADO)
if `"`simplemode'"'!="" {
    local mode simple
}
else {
    mata: detmode(`"`inputfile'"', "`project'")  // returns local mode : "simple" or "ado"
}

if "`mode'"== "simple" {
    if "`starbang'"=="" local starbang all
    mata: copylist_simple(`"`inputfile'"', "`project'")  // returns local copylist w/ tokens being full file paths enclosed in double quotes
}
else {
    if "`starbang'"=="" local starbang first
    mata: copylist_ado(`"`inputfile'"', "`project'")     // returns locals advfiles, adofiles, stpfiles, matafiles, otherfiles
    if "`copylist_adoerr'"!="" {
        disp as error `"`copylist_adoerr'"'
        exit 9   // return code 9 is appropriate here
    }
    local copylist `"`advfiles' `adofiles' `stpfiles' `matafiles' `otherfiles'"'  // tokens are full file paths enclosed in double quotes
}

// CHECKING FOR EXISTENCE OF FILES
if "`copy'"!="nocopy" {
    local filemiss
    foreach curfile of local copylist {
        capture confirm file `"`curfile'"'
        if _rc {
            disp as error `"file `curfile' not found"'
            local filemiss true
        }
    }
    if "`filemiss'"=="true" exit 601
}

// CHECKING FOR CORRECT COPY REGION LIMITS
if "`copy'"!="nocopy" {
    if "`force'"=="" {
        foreach curfile of local copylist {
            mata: checklimits(`"`curfile'"')
            if "`limitserr'"!="" {
                disp as error `"`curfile':  `limitserr'"'
                exit 9    // 9 is the best return code here
            }
        }
    }
}

// CHECKING OUTPUT FILE
// if path is relative, Stata automatically assumes that the working dir must be prepended
if "`copy'"!="nocopy" {
    mata: ds_pathparts(`"`targetfile'"')
    local targetroot `r(root)'
    mata: st_local("direxists",strofreal(direxists(`"`r(path)'"')))  // direxists() handles relative paths
    if `direxists'==0 {
        disp as error `"Directory of target file does not exist."'
        exit 601
    }
    if "`replace'"!="" capture erase `"`targetfile'"'
    capture confirm file `"`targetfile'"'
    if !_rc {
        disp as error `"Target file `targetfile' already exists."'
        exit 602
    }
}

// COPYING TEXT, SCREEN OUTPUT
disp as text    _n `"  make of project {hi:`project'}:"'

if "`mode'"=="simple" {
    disp as text _n `"    simple mode: only direct dependencies are included"'
}
else {
    disp as text _n `"    ado mode: direct and indirect dependencies are included"'
}
if "`copy'"!="nocopy" {
    if "`force'"!="" {
        disp as text `"    option 'force' used: copying of entire contents of files"'
    }
    else {
        disp as text `"    option 'force' not used: copying of copy regions only"'
    }

    if "`starbang'"=="all"   disp as text `"    starbang lines: included in target file"'  _n
    if "`starbang'"=="first" disp as text `"    starbang lines: only from first project file"' _n
    if "`starbang'"=="skip"  disp as text `"    starbang lines: omitted"'                      _n

}
else {
    disp as text ""
}

if "`starbang'"=="skip" local starbang_mata ""
if "`starbang'"=="all"  local starbang_mata "starbang"

foreach curfile of local copylist {
    if "`copy'"!="nocopy" {
        if "`starbang'"=="first" {
            if `"`curfile'"'==`"`:word 1 of `copylist''"' {  // 'word' extended function strips quotes around path
                local starbang_mata starbang
            }
            else {
                local starbang_mata ""
            }
        }
        mata: copylines(`"`curfile'"', `"`targetfile'"', "`force'", "`starbang_mata'")
    }
    mata: ds_pathparts(`"`curfile'"')
    disp as text `"    included:   `r(filename)'"'
}
if "`copy'"=="nocopy" {
    disp as text  _n `"  option 'nocopy' used: no target file created"'
}
else {
    disp as text  _n `"  outputfile: `targetfile'"'
}

// RETURN R-VALUES
if "`mode'"=="simple" {
    path2filelist `copylist'
    local dep_direct  `"`r(filelist)'"'
}
else {
    local space ""
    foreach curtype in adv ado stp mata other {
        path2filelist ``curtype'files'
        local dep_`curtype' `"`r(filelist)'"'
        if `"`dep_`curtype''"'!="" {
            local dep_all `"`dep_all'`space'`dep_`curtype''"'
            local space " "
        }
    }
}

if "`mode'"=="simple" {
    return local dep_direct_path `"`copylist'"'
    return local dep_direct      `"`dep_direct'"'
}
else {
    return local dep_other_path `"`: list clean otherfiles'"'
    return local dep_mata_path  `"`: list clean matafiles'"'
    return local dep_stp_path   `"`: list clean stpfiles'"'
    return local dep_ado_path   `"`: list clean adofiles'"'
    return local dep_adv_path   `"`: list clean advfiles'"'
    return local dep_all_path   `"`copylist'"'
    return local dep_other      `"`dep_other'"'
    return local dep_mata       `"`dep_mata'"'
    return local dep_ado        `"`dep_ado'"'
    return local dep_stp        `"`dep_stp'"'
    return local dep_adv        `"`dep_adv'"'
    return local dep_all        `"`dep_all'"'
}

return local project            `"`project'"'

if "`progdrop'"!="noprogdrop" | "`copy'"=="nocopy" {
    capture program drop `targetroot'
}

end

*** --------------------------------- SUBS ------------------------------------------------

program path2filelist, rclass
    local pathlist `"`0'"'
    local filelist ""
    local space ""
    foreach curpath of local pathlist {
        mata: ds_pathparts(`"`curpath'"')
        local filelist `"`filelist'`space'`"`r(filename)'"'"'
        local space " "
    }
    local filelist: list clean filelist
    return local filelist `"`filelist'"'
end

*** --------------------------------- MATA ------------------------------------------------

// copied from ds_pathparts.mata
version 10
mata:
mata set matastrict on

void ds_pathparts(string scalar origpath) {
// version 1.0.0  01jul2012  dcs
// break full path into parts: path, filename, root (of filename), extension
// store results in r() macros r(root), r(ext), r(filename), r(path)

    string scalar path,
                  filename,
                  ext,
                  jnk
    real scalar numdots
    
    pragma unset path
    pragma unset filename
    
    pathsplit(origpath, path, filename)
    ext = pathsuffix(origpath)
    if (ext == "") {     // no extension exists => last elem of path is assumed to be part of directory path and not a file name
        path = pathjoin(path, filename)
        filename = ""
    }
    
    st_rclear()
    st_global("r(path)", path)
    st_global("r(filename)", filename)
    st_global("r(ext)", ext)

    // getting root of filename: account for possibility of several dots in filename
    if (filename != "") {
        jnk = subinstr(filename, ".", "")
        numdots = strlen(filename) - strlen(jnk)
        if (numdots == 0) {
            st_global("r(root)", filename)
        }
        if (numdots == 1 & strpos(filename, ".") > 1) {
            st_global("r(root)", substr(filename, 1, strpos(filename, ".") - 1))
        }
        if (numdots > 1) {
            st_global("r(root)", substr(filename, 1, strlen(filename) - strpos(strreverse(filename), ".")))
        }
    }
}
end

version 10
mata:
mata set matastrict on
void inputchk(string scalar fname, string scalar project) {
// checks applied: 
//   - two tokens per line ( from cleaninput() )
//   - double quotes are not allowed in file paths
//   - project must exist
//   - each project in input file must be entered as a contiguous block of lines (blanks and comments are allowed)
//   - relative file paths must be used
// fname can contain a relative path

    real scalar i,
                numrows

    string rowvector tempparse
    
    string matrix   parsedfile
                    
    parsedfile = cleaninput(fname)
    if (cols(parsedfile)==1) {
        // some input line does not contain two tokens; parsedfile now contains error message
        st_local("inputchkerr",parsedfile)
        return
    }
    
    if (sum(strpos(parsedfile[.,2],`"""'))>0) {
        st_local("inputchkerr","at least one file path in input file contains a double quote.")
        return
    }
    
    numrows = rows(parsedfile)
    if (sum(parsedfile[.,1]:==project)==0) {
        st_local("inputchkerr","project " + project + " not found in input file.")
        return
    }

    // check for contiguous project block
    //      count # of changes in first col of parsedfile: count first entry plus subsequent changes
    tempparse = select(parsedfile, ( 1 \ parsedfile[(2::numrows),1] :!= parsedfile[(1::(numrows-1)),1]) ) 
    if ( rows(tempparse)!= rows(uniqrows(parsedfile[.,1])) ) {
        st_local("inputchkerr","at least one project in input file is not in a contiguous block of lines.")
        return
    }
    
    // check for occurence of relative paths which are not allowed
    for (i=1;i<=numrows;i++) {
        if (!pathisabs(parsedfile[i,2])) {
            st_local("inputchkerr","input file contains at least one relative file path.")
            return
        }
    }
}
end

version 10
mata:
mata set matastrict on
string matrix cleaninput(string scalar fname) {
// strips input file of comments and blank lines, converts to lower case
// removes (double) quotes and checks that each line with an input entry has two tokens
//   if the latter condition does not hold, a 1 x 1 string matrix with the error message is returned
    
    real scalar i,
                j,
                err_linenum,
                numrows,
                numrows_orig
    
    string rowvector tempparse
    
    string matrix   inputfile_orig,
                    inputfile,         // stripped of empty lines and comment lines; tabs replaced by spaces
                    parsedfile

    transmorphic matrix t

    inputfile_orig = strlower( strtrim( subinstr(cat(fname),char(9)," ") ) )
    inputfile = select(inputfile_orig,(substr(inputfile_orig,1,2):!="//" :& inputfile_orig:!=""))

    // check for number of tokens on each line and remove quotes
    numrows_orig = rows(inputfile_orig)
    numrows = rows(inputfile)
    t = tokeninit()
    parsedfile = J(numrows,2,"")

    for (i=1;i<=numrows;i++) {
        tokenset(t, inputfile[i])
        tempparse = tokengetall(t)
        if (cols(tempparse) != 2) {
            err_linenum = select(1::numrows_orig, (inputfile_orig:==inputfile[i]) )
            return("line " + strofreal(err_linenum) + " of inputfile does not have two tokens.")
        }
        
        // removing quotes (code snippet adapted from [M-5, 12, p.683]
        for (j=1; j<=2; j++) {
            if (substr(tempparse[j],1,1)==`"""') {
                tempparse[j] = substr(tempparse[j], 2, strlen(tempparse[j])-2)
            }
            else if (substr(tempparse[j], 1, 2)=="`" + `"""') {
                tempparse[j] = substr(tempparse[j], 3, strlen(tempparse[j])-4)
            }
        }
        parsedfile[i,.]=tempparse
    }

    return(parsedfile)
}
end

version 10
mata:
mata set matastrict on
void detmode(string scalar fname, string scalar project) {
// determines mode (simple/ado)
// 
// returns:
//   local mode: one of "ado" or "simple"
    
    real scalar     i
    
    string matrix   parsedfile

    parsedfile = cleaninput(fname)

    for (i=1;rows(parsedfile);i++) {
        if ( parsedfile[i,1] == project ) {
            if ( (pathsuffix(parsedfile[i,2])==".adv") & (pathrmsuffix(pathbasename(parsedfile[i,2]))==parsedfile[i,1] ) ) {
                    // e.g. proj_a has main adv proj_a.adv
                st_local("mode","ado")
            }
            else {
                st_local("mode","simple")
            }
            return
        }
    }
    
}
end

version 10
mata:
mata set matastrict on
void copylist_simple(string scalar fname, string scalar project) {
// compiles list of files to be copied
// 
// returns:
//   local copylist: files to be copied into targetfile, in correct order
    
    string rowvector copylist
    
    string matrix   parsedfile
    
    parsedfile = cleaninput(fname)
    copylist = select(parsedfile, (parsedfile[.,1] :== project))
    copylist = `"""' :+ copylist[.,2] :+ `"""'
    st_local("copylist",invtokens(copylist'))
}
end


version 10
mata:
mata set matastrict on
void copylist_ado(string scalar fname, string scalar project) {
// checks that all input file rules for ado mode are met
// - adv references must be found as projects in input file
// - referenced projects define the same adv file as the reference
// - circular references are not allowed
// - returns local "copylist_adoerr" if any of the above is not true
// compiles list of files to be copied
// 
// returns:
//   locals advfiles adofiles stpfiles matafiles otherfiles: 
//          files to be copied into targetfile
    
    real scalar i,
                numrows
    
    string scalar    curadv,
                     curprojname
    
    string colvector curprojmat,
                     nadvlist,     // list of n-th order adv files
                     nplusadvlist, // list of (n+1)-th order adv files
                     advlist,
                     adolist,
                     stplist,
                     matalist,
                     otherlist,
                     extlist    // vector of file extensions
    
    
    string matrix   parsedfile,
                    extparsedfile  // extended parsed input file: 3rd col has file extensions
 
    parsedfile = cleaninput(fname)
    numrows = rows(parsedfile)

    extlist = J(numrows,1,"")
    for (i=1;i<=numrows;i++) {
        extlist[i,1] = pathsuffix(parsedfile[i,2])
    }

    extparsedfile = (parsedfile , extlist)
    
    curprojmat  = J(0,3,"")
    adolist     = J(0,1,"")
    stplist     = J(0,1,"")
    matalist    = J(0,1,"")
    otherlist   = J(0,1,"")
    
    curprojmat = select(extparsedfile, (extparsedfile[.,1] :== project))
    if (rows(curprojmat)==1) {
        st_local("advfiles",   invtokens((`"""' + curprojmat[1,2] + `"""')'))
        return
    }
    
    advlist    = curprojmat[1,2]
    curprojmat = curprojmat[2::rows(curprojmat),.]

    nadvlist  = select(curprojmat, (curprojmat[.,3] :== ".adv" ) )[.,2]
    adolist   = select(curprojmat, (curprojmat[.,3] :== ".ado" ) )[.,2]
    stplist   = select(curprojmat, (curprojmat[.,3] :== ".stp" ) )[.,2]
    matalist  = select(curprojmat, (curprojmat[.,3] :== ".mata") )[.,2]
    otherlist = select(curprojmat, ( !(rowsum(J(1,4,curprojmat[.,3]) :== (".adv",".ado",".stp",".mata" ) ) ) ) )[.,2]

    while (rows(nadvlist)>0) {
        nplusadvlist = J(0,1,"")
        for (i=1;i<=rows(nadvlist);i++) {

            curadv     = nadvlist[i]
            curprojname = pathrmsuffix(pathbasename(curadv))

            // imperative that first line of ado project has an adv file whose name corresponds to the project
            curprojmat = select(extparsedfile, (extparsedfile[.,1] :== curprojname))

            if (rows(curprojmat)==0) {  // reference not in input file => error
                st_local("copylist_adoerr","project reference not found in input file: " + curprojname)
                return
            }
            else {
                if (curprojmat[1,2]!=curadv) {
                    st_local("copylist_adoerr","reference mismatch for main adv of project " + curprojname + ".")
                    return
                }
                if (rows(curprojmat)>1) {  // if equal to one, adv file is the only entry for the project
                    curprojmat = curprojmat[2::rows(curprojmat),.]

                    nplusadvlist = (nplusadvlist \ select(curprojmat, (curprojmat[.,3] :== ".adv" ) )[.,2] )
                    adolist      = (adolist      \ select(curprojmat, (curprojmat[.,3] :== ".ado" ) )[.,2] )
                    stplist      = (stplist      \ select(curprojmat, (curprojmat[.,3] :== ".stp" ) )[.,2] )
                    matalist     = (matalist     \ select(curprojmat, (curprojmat[.,3] :== ".mata") )[.,2] )
                    otherlist    = (otherlist    \ select(curprojmat, ( !(rowsum(J(1,4,curprojmat[.,3]) :== (".adv",".ado",".stp",".mata" ) ) ) ) )[.,2] )
                }
            }
        }
        advlist  = (advlist \ nadvlist)
        if (rows(advlist)>1000) {
            st_local("copylist_adoerr","limit of 1000 adv dependencies reached. likely cause is circular reference")
            return
        }
        nadvlist = ds_uniq(nplusadvlist)
    }
    
    advlist    = ds_uniq(advlist)
    adolist    = ds_uniq(adolist)
    stplist    = ds_uniq(stplist)
    matalist   = ds_uniq(matalist)
    otherlist  = ds_uniq(otherlist)

/*
"advlist: "
advlist
"adolist: "
adolist
"stplist: "
stplist
"matalist: "
matalist
"otherlist: "
otherlist
*/

    st_local("advfiles",   invtokens((`"""' :+ advlist :+ `"""')'))
    st_local("adofiles",   invtokens((`"""' :+ adolist :+ `"""')'))
    st_local("stpfiles",   invtokens((`"""' :+ stplist :+ `"""')'))
    st_local("matafiles",  invtokens((`"""' :+ matalist :+ `"""')'))
    st_local("otherfiles", invtokens((`"""' :+ otherlist :+ `"""')'))
    
}
end


version 10
mata:
mata set matastrict on
string vector ds_uniq(string vector vecin) {
// copied from ds_uniq.mata
// returns unique elements of vector; elements are in order of appearance in input vector
// if vecin contains one or more empty strings "", a "" shows up in the output vector
// if vecin is J(0,1,"") or J(1,0,"") the input arg is returned
    
    real scalar i,
                nin,
                nuniq,
                iscolvec
    
    real colvector incr,     // increment colvec (1 2 3 ...)
                   origpos,  // position of first occurence in vecin     
                   uniqorder // index to reorder unique sorted values
    
    string colvector uniqsorted
    
    if (rows(vecin)==0 | cols(vecin)==0) {
        return(vecin)
    }
    
    if (rows(vecin)>1) {
        iscolvec = 1
    }
    else {
        iscolvec = 0
        vecin = vecin'
    }
    
    // from here on everything is in terms of colvecs
    uniqsorted = uniqrows(vecin)
    nin = rows(vecin)
    nuniq = rows(uniqsorted)
    incr = 1::nin

    origpos = J(nuniq,1,.)

    for (i=1;i<=nuniq;i++) {
        origpos[i] = colmin( select(incr, (vecin:==uniqsorted[i]) ) )
    }

    uniqorder = sort( (origpos,(1::nuniq)) , 1)[.,2]

    // return to orig orgtype: row/colvec
    if (iscolvec==0) {
        uniqsorted = uniqsorted'
    }
    
    return(uniqsorted[uniqorder])
}
end


version 10
mata:
mata set matastrict on
void checklimits(string scalar fname) {
// checks whether strings "!copytextbeg=>" and "!copycodeend=>" exist in file, in the correct order
// returns Stata local:
//   limitserr, containing one of
//          "beginning line limit following beginning line limit"
//          "line limits may not be on the same line"
//          "end line limit before beginning line limit"
//          "beginning and end line limit strings missing"
//          "end line limit string missing"
//     with additional information on file name and line number if appropriate

    real scalar i,
                numbeg,
                numend
    
    string scalar curline,
                  limitserr,
                  limitserr_prefix
    
    string colvector flines
    
    numbeg = 0
    numend = 0
    limitserr = ""
    
    flines = cat(fname)
    
    // checks:
    //   line limits are alternating
    //   line limits are not on same line
    for (i=1;i<=rows(flines);i++) {
        curline = flines[i,1]
        limitserr_prefix = "copycode: " + fname + " line " + strofreal(i) + ": "
        if (strpos(curline,"!copycodebeg=>")) {
            numbeg++
            if (numbeg>numend+1) {
                limitserr = limitserr_prefix + "beginning line limit following beginning line limit"
                break
            }
            if (strpos(curline,"!copycodeend||")) {
                limitserr = limitserr_prefix + "line limits may not be on the same line"
                break
            }
        }

        if (strpos(curline,"!copycodeend||")) {
            numend++
            if (numend>numbeg) {
                limitserr = limitserr_prefix + "end line limit before beginning line limit"
                break
            }
        }
    }

    // checks:
    //   numbeg>0
    //   numbeg==numend
    if (limitserr!="") {
        st_local("limitserr", limitserr)
    }
    else {
        if (numbeg==0) {
            st_local("limitserr","copycode: " + fname + ": beginning and end line limit strings missing")
        }
        else if (numend<numbeg) {
            st_local("limitserr","copycode: " + fname + ": end line limit string missing")
        }
    }
}
end

version 10
mata:
mata set matastrict on
void copylines(string scalar sname, string scalar tname, string scalar force, string scalar starbang) {
// input args:
//   source file name
//   target file name
//   force: either "force" or empty
//   starbang: either "starbang" or empty
// files have already been checked for existence and proper structure
    
    real scalar i,
                thandle,
                flen

    string matrix slines
    
    slines = cat(sname)
    flen   = rows(slines)
    if (flen==0) {
        return
    }

    thandle = _fopen(tname, "a")  // fopen() displays message "note: file blabla not found"
                                  //   _fopen() does not do this but it does also not abort when sth goes wrong (=> neg. rc)
                                  //   I must check that manually
    if (thandle<0) {
        _error(9,"could not open file " + tname)
    }

    if (force!="") {
        for (i=1;i<=flen;i++) {
            if ( (substr(strtrim(slines[i]),1,2)!="*!") | (starbang!="") )  {
                fput(thandle, slines[i])
            }
        }
    }
    else {
        i = 1
        while (i<=flen) {
            while (!strpos(slines[i],"!copycodebeg=>")) {
                i++
                if (i>flen) {
                    break
                }
            }
            i++
            if (i>flen) {
                break
            }
            while (!strpos(slines[i],"!copycodeend||")) {
                if ( (substr(strtrim(slines[i]),1,2)!="*!") | (starbang!="") )  {
                    fput(thandle, slines[i])
                }
                i++
                if (i>flen) {
                    break
                }
            }
        }
    }
    
    // add two empty lines
    fput(thandle, "")
    fput(thandle, "")
    
    fclose(thandle)
    
}
end


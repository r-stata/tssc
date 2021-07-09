*! version 1.0.0  14aug2012  dcs

program define fastcc, rclass

version 10
syntax [ anything ] , ///
       [ ALLDepon(string) ///
         noCopy           ///
         SETtings(string) ///
         SImplemode       ///
         force            ///
         STarbang(passthru) ///
         Verbose          ///
         noProgdrop       ///
         Editadv]         //   undocumented (see copycode devdoc)

if `"`anything'"'!="" {
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
}

if `"`project'"'!="" & `"`alldepon'"'!="" {
    disp as error `"options 'project' and 'alldepon' are mutually exclusive."'
    exit 197
}

if "`editadv'"!="" {
    if `"`project'"'!="" | `"`alldepon'"'=="" {
        disp as error `"Option 'editadv' is only allowed in combination with option 'alldepon'."'
        exit 197
    }
}

if lower(`"`project'"')=="fastcc" {
    disp as error `"Argument of option 'project' not allowed; fastcc cannot make itself."'
    exit 197
}

if "`verbose'"!="" local verbose noisily

if `"`settings'"' != "" {
    if `"`project'`alldepon'`copy'`simplemode'`force'`starbang'`verbose'`progdrop'`editadv'"' != "" {
        disp as error `"Option 'settings' may not be combined with other arguments."'
        exit 197
    }
    if strpos(`"`settings'"',":") {
        local colonpos = strpos(`"`settings'"',":")
        local paraname = trim(lower(substr(`"`settings'"',1,`colonpos'-1)))
        local paraval  = trim(lower(substr(`"`settings'"',`colonpos'+1,.)))
        local paraname: list clean paraname  // get rid of double quotes if present
        local paraval : list clean paraval
        if !inlist(`"`paraname'"',"targetdir","inputfile") {
            disp as error `"Option settings: only arguments that can receive a value are 'targetdir' and 'inputfile'."'
            exit 197
        }
        if "`paraname'"=="targetdir" {    // may also be empty string; in that case an existing entry is deleted only
            mata: st_local("direxists",strofreal(direxists("`paraval'")))
            if `direxists'==0 {
                disp as error `"Option settings: target directory does not exist"'
                exit 170
            }
        }
        else if "`paraname'"=="inputfile" {
            mata: st_local("fileexists",strofreal(fileexists("`paraval'")))
            if `fileexists'==0 {
                disp as error `"Option settings: input file does not exist"'
                exit 601
            }
        }
        mata: st_local("pathisabs",strofreal(pathisabs("`paraval'")))
        if `pathisabs'==0 {
            disp as error `"Option settings: you must supply an absolute path."'
            exit 198
        }
        capture ini_delete fastcc `paraname'
        ini_write fastcc `paraname' `"`paraval'"'
    }
    else {
        if lower(`"`settings'"') != "list" {
            disp as error `"Option settings: only argument that may not receive a value is 'list'."'
            exit 198
        }
        ini_list fastcc
    }
    exit
}

if `"`project'`settings'`alldepon'"'=="" {
    disp as error `"You must either specify {it:projectname}, option 'alldepon', or option 'settings'."'
    exit 198
}

// READING SETTINGS
if `"`project'`alldepon'"'!="" {
    ini_read fastcc inputfile
    local inputfile `"`inivalue'"'
    capture confirm file `"`inputfile'"'
    if _rc {
        disp as error `"setting of ini entry 'inputfile' invalid."'
        disp as error `"file not found: `inputfile'"'
        exit 601
    }
    if "`copy'"!="nocopy" {
        ini_read fastcc targetdir
        local targetdir `"`inivalue'"'
        mata: st_local("direxists",strofreal(direxists("`targetdir'")))
        if `direxists'==0 {
            disp as error `"setting of ini entry 'targetdir' invalid."'
            disp as error `"directory not found: `targetdir'"'
            exit 170
        }
    }
}

disp as text _n `"  fastcc settings:"'
disp as text    `"    inputfile  : `inputfile'"'
if "`copy'"!="nocopy" disp as text    `"    target dir : `targetdir'"'   // targetdir not relevant if -nocopy- is used
disp ""

if `"`project'"'!="" {
    if "`copy'"!="nocopy" {
        capture `verbose' copycode `project', inputfile(`inputfile') targetfile(`targetdir'/`project'.ado) replace `simplemode' `force' `starbang' `progdrop'
    }
    else {
        capture `verbose' copycode `project', inputfile(`inputfile') nocopy                                replace `simplemode' `force' `starbang'
    }
    local rc = _rc
    if "`verbose'"=="" {
        if `rc' {
            disp as error `"  {bf:failed to process :      `project'}"'
            exit _rc
        }
        else {
            disp as text  `"  {bf:successfully processed : `project'}"'
            if "`copy'"=="nocopy" {
                disp as text _n `"  option 'nocopy' used: output file not created."'
            }
        }
    }
    if `rc' {
        exit _rc
    }
    
    return add  // return r-results from -copycode-
    
}

if `"`alldepon'"'!="" {
    local alldepon = trim(lower(`"`alldepon'"'))
    
    mata: ds_pathparts(`"`alldepon'"')
    local ext `r(ext)'
    if "`ext'"=="" {
        disp as error `"Argument to option -alldepon- must be supplied with file extension."'
        exit 198
    }

    tempname fhandle
    file open `fhandle' using `inputfile', read text
    file read `fhandle' curline
    
    local space ""
    local projlist

    if "`simplemode'"!="" {
        while !r(eof) {
            if substr(strtrim(`"`curline'"'),1,2)!="//" {
                tokenize `"`curline'"'
                mata: ds_pathparts(strlower(`"`2'"'))
                if `"`r(filename)'"'==`"`alldepon'"' {
                    local projlist `projlist'`space'`1'
                    local space " "
                }
            }
            file read `fhandle' curline
        }
    }
    else {  // higher-order dependencies must now be detected; this is also true if an .stp file or the like is passed!
        local failed_check ""
        local space ""
        local prevproj ""
        while !r(eof) {
            local curline = strtrim(subinstr(`"`curline'"',char(9)," ",.))   // translate out tabs
            if substr(`"`curline'"',1,2)!="//" {
                tokenize `"`curline'"'
                local curproj `1'
                if "`curproj'"!="`prevproj'" {
                    capture copycode `curproj', inp(`inputfile') nocopy `simplemode' noprogdrop
                    if _rc!=0 {
                        local failed_check `failed_check'`space'`curproj'
                        local space " "
                    }
                    local curdep_all `"`r(dep_all)'"'
                    local isdep: list alldepon in curdep_all
                    if `isdep' local projlist `projlist'`space'`curproj'
                    local space " "
                }
                local prevproj `curproj'
            }
            file read `fhandle' curline
        }
    }
    
    file close `fhandle'
    
    if "`failed_check'"!="" {
        disp as text _n `"  {bf:projects that could not be checked for dependencies because errors occurred:}"'
        foreach curproj of local failed_check {
            disp as text    `"    `curproj'"'
        }
    }

    if `"`projlist'"'=="" {
        disp as text _n `"  no project is dependent on `alldepon'"'
        return local failed_check `failed_check'
        exit
    }
    
    if "`editadv'"!="" {
        foreach curproj of local projlist {
            qui findfile `curproj'.adv
            local filelist `"`filelist' "`r(fn)'""'
        }
        winexec "C:\Program Files (x86)\TextPad 5\TextPad.exe" `filelist'
    }
    else {
        local space ""
        local failed_make ""
        if "`copy'"!="nocopy" {
            disp as text _n `"  {bf:`alldepon'-dependent projects processed by fastcc:}"'
        }
        else {
            disp as text _n `"  {bf:projects dependent on `alldepon':}"'
        }
        foreach curproj of local projlist {
            capture program drop `curproj'
            if "`copy'"!="nocopy" {
                capture `verbose' copycode `curproj' , inp(`inputfile') targetfile(`targetdir'/`curproj'.ado) replace `simplemode' `force' `starbang' `progdrop'
            }
            else {
                capture `verbose' copycode `curproj' , inp(`inputfile') nocopy                                        `simplemode'
            }
            local rc = _rc
            if "`verbose'"=="" {
                if `rc'==0 {
                    disp as text  `"    `curproj'"'
                }
                else {
                    disp as error `"    `curproj' (failed)"'
                }
            }
            if `rc'!=0 local failed_make `failed_make'`space'`curproj'
        }

    }
    return local failed_check `failed_check'
    return local failed_make `failed_make'
    return local projectlist `projlist'
}


end





program define ini_read

args cmdname paraname argcheck
if `"`argcheck'"' != "" | `"`paraname'"'=="" {
    disp as error `"`cmdname'.ado, ini_read: must receive exactly two arguments.  Try enclosing args in double quotes."'    
    exit 9
}

local fullfilepath `"`c(sysdir_plus)'`=substr(`"`cmdname'"',1,1)'`c(dirsep)'`cmdname'.ini"'
capture confirm file `"`fullfilepath'"'
if _rc {
    disp as error `"`cmdname'.ado, ini_read: ini file not found."'
    exit 9
}
tempname fhandle
quietly file open `fhandle' using `"`fullfilepath'"', read text
file read `fhandle' curline
while !r(eof) {
    tokenize `"`curline'"'  // tokens are enclosed in compound double quotes in file; however, tokenize strips these quotes
    if `"`1'"' == `"`paraname'"' {
        local foundvalue true
        c_local inivalue `2'
        continue, break
    }
    file read `fhandle' curline
}
file close `fhandle'
if "`foundvalue'" == "" {
    disp as error `"`cmdname'.ado, ini_read: no entry in ini file for parameter: `paraname'."'
    exit 9
}

end




program define ini_delete

args cmdname paraname argcheck
if `"`argcheck'"' != "" | `"`paraname'"'=="" {
    disp as error `"`cmdname'.ado, ini_delete: must receive exactly two arguments.  Try enclosing args in double quotes."'    
    exit 197
}

local fullfilepath `"`c(sysdir_plus)'`=substr(`"`cmdname'"',1,1)'`c(dirsep)'`cmdname'.ini"'
capture confirm file `"`fullfilepath'"'
if _rc {
    disp as error `"`cmdname'.ado, ini_delete: ini file not found."'
    exit 601
}
tempfile inicopy    
tempname copyhandle
file open `copyhandle' using `"`inicopy'"', write text
tempname orighandle
quietly file open `orighandle' using `"`fullfilepath'"', read text
file read `orighandle' curline
while !r(eof) {
    tokenize `"`curline'"'  // tokens are enclosed in compound double quotes in file; however, tokenize strips these quotes
    if `"`1'"' == `"`paraname'"' {
        local foundvalue true
    }
    else {
        file write `copyhandle' `"`curline'"' _n
    }
    file read `orighandle' curline // works if file does not exist???
}
if "`foundvalue'" == "" {
    disp as error `"`cmdname'.ado, ini_delete: no entry in ini file for parameter: `paraname'."'
    exit 197
}
file close `orighandle'
file close `copyhandle'
copy `"`inicopy'"' `"`fullfilepath'"', replace

end




program define ini_write

args cmdname paraname value argcheck
if `"`argcheck'"' != "" | `"`value'"'=="" {
    disp as error `"`cmdname'.ado, ini_write: must receive exactly three arguments.  Try enclosing args in double quotes."'
    exit 9
}

local fullfilepath `"`c(sysdir_plus)'`=substr(`"`cmdname'"',1,1)'`c(dirsep)'`cmdname'.ini"'
tempname fhandle
// check that value does not exist
quietly file open `fhandle' using `"`fullfilepath'"', read write text
local foundvalue true
file read `fhandle' curline
while !r(eof) {
    tokenize `"`curline'"'  // tokens are enclosed in compound double quotes in file; however, tokenize strips these quotes
    if `"`1'"'==`"`paraname'"' {
        if "`foundvalue'" == "true" {
            disp as error `"`cmdname'.ado, ini_write: ini file entry `paraname' already exists."'
            exit 9
        }
        local foundvalue true
    }
    file read `fhandle' curline
}

file write `fhandle' `"`"`paraname'"'   `"`value'"'"' _n

file close `fhandle'

end




program define ini_list

args cmdname argcheck
if `"`argcheck'"' != "" | `"`cmdname'"'=="" {
    disp as error `"`cmdname'.ado, ini_list: must receive exactly one argument.  Try enclosing args in double quotes."'    
    exit 9
}

local fullfilepath `"`c(sysdir_plus)'`=substr(`"`cmdname'"',1,1)'`c(dirsep)'`cmdname'.ini"'
capture confirm file `"`fullfilepath'"'
if _rc {
    disp as error `"`cmdname'.ado, ini_list: ini file not found."'
    exit 9
}
tempname fhandle

// determine longest parameter name
quietly file open `fhandle' using `"`fullfilepath'"', read text
file read `fhandle' curline
local maxlen 0
while !r(eof) {
    tokenize `"`curline'"'  // tokens are enclosed in compound double quotes in file; however, tokenize strips these quotes
    local curparalength: length local 1
    if `curparalength' > `maxlen' {
        local maxlen `curparalength'
    }
    file read `fhandle' curline
}

local maxlen = `maxlen' + 4
file seek `fhandle' tof
file read `fhandle' curline
while !r(eof) {
    tokenize `"`curline'"'
    if `"`1'"'!="//" {
        disp as text `"`1':"' as result `"{col `maxlen'}`2'"'
        local ini_paralist `"`ini_paralist' `"`1'"'"'
        local ini_valuelist `"`ini_valuelist' `"`2'"'"'
    }
    file read `fhandle' curline
}
file close `fhandle'
c_local ini_paralist `"`ini_paralist'"'
c_local ini_valuelist `"`ini_valuelist'"'

end



version 10
mata:
mata set matastrict on

void ds_pathparts(string scalar origpath) {
// version 1.0.0  01jul2012  dcs
// break full path into parts: path, filename, root (of filename), extension
// store results in r() macros r(root), r(ext), r(filename), r(path)
// 
// rules
// - to get a r(filename), r(ext), r(root), there must be a dot present in the last element of the string supplied
//   multiple dots in filename are allowed; the last one defines the extension
//   if no dot is present in the last element of the string supplied, everything is packed into r(path)
// - to get r(path), there must either be 
//     no dot in the last elem of the path or
//     if a dot is present, there must be a dir separator
// - if a colon is present, it must be preceeded by some string, otherwise the function errors out
// - the first ending directory separator is removed from r(path); so normally r(path) does not end in a dir separator
//   r(path) only contains a separator for the root dir (e.g. "c:\")
//   it also contains separators if multiple separators are passed
//     i.e. passing "mydir//a.lst" will be plit into "mydir/" and "a.lst"
// - r(ext) contains a dot as the first character
// - r-values of missing path parts are not returned (e.g. if only the filename is supplied, r(path) is missing)
// - path may contain blanks
// - dots in paths are allowed

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



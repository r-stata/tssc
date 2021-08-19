*! version 0.2  16nov2019  Diana Goldemberg, diana_goldemberg@g.harvard.edu

/*------------------------------------------------------------------------------
Freeze and unfreeze versions of user-written ado commands (dependencies)
  into an ado-path that takes top priority (most likely, C:/ado/dependencies)
------------------------------------------------------------------------------*/

cap program drop dependencies
program define   dependencies, rclass

  version 13

  * Back up system settings to be restored after program run
  local saved_pwd `"`c(pwd)'"'
  * PLACEHOLDER: what else should be added here???

  gettoken subcmd 0 : 0 , parse(" ,")

  * Check that SUBCOMMAND specified is valid
  if "`subcmd'" == "" {
    dis as error `"{bf:dependencies} must be followed by a subcommand. Valid subcommands: freeze | unfreeze | which | remove"'
    exit 198
  }
  else if inlist("`subcmd'", "freeze", "unfreeze", "which", "remove") == 0 {
    dis as error `"{bf:dependencies} {bf:`subcmd'} is unrecognized. Valid subcommands: freeze | unfreeze | which | remove"'
    exit 198
  }

  * Valid SUBCOMMAND => check if followed by options as expected
  else {
    if inlist("`subcmd'", "which", "remove") & `"`0'"' != "" {
      dis as error `"{bf:dependencies} {bf:`subcmd'} does not accept any options. Try typing only {bf:dependencies} {bf:`subcmd'}"'
      exit 198
    }
    if inlist("`subcmd'", "freeze", "unfreeze") & `"`0'"' == "" {
      dis as error `"{bf:dependencies} {bf:`subcmd'} require options. Check {bf: help dependencies} for more details"'
      exit 198
    }

    * Complement syntax to be passed with DEPENDENCIES ado-path (not needed for freeze)
    if "`subcmd'" != "freeze" local depfolder `", depfolder(`c(sysdir_oldplace)'dependencies)"'

    * Try to run the SUBCOMMAND but restores the system settings if errors
    nobreak {

      capture noisily break dependencies_`subcmd' `0' `depfolder'
      local rc = _rc

      * PLACEHOLDER: depending on `rc', restore the system settings

      * Change back to original directory
      qui cd `"`saved_pwd'"'

    }
    exit `rc'
  }

end


*-------------------------------------------------------------------------------


cap program drop dependencies_freeze
program define   dependencies_freeze
* This subprogram:
*   save a zip with dependencies specified in adolist

  syntax using/ , [adolist(string) all replace]

  * Must be able to create or replace using file
  capture confirm new file `using'
  if (_rc == 602 & "`replace'" != "replace") {
    dis as error `"Must specify -replace- or choose another filename, for `using' already exists."'
    exit 602
  }
  else if (_rc != 602 & _rc != 0)  exit _rc

  * Split using argument into r(path) r(filename) and r(extension)
  mata: split_using(`"`using'"')
  local zipdir = "`r(path)'"
  local zipfn  = "`r(filename)'"

  * Check -freze- suboptions: either -all- or -adolist- must be chosen (not both)
  if ("`adolist'" == "" & "`all'" == "") | ("`adolist'" != "" & "`all'" != "") {
    dis as error "{bf: dependencies freeze} must be used with either -all- or -adolist- options."
    exit 198
  }

  * This is the only subprogram that will manipulate data, so preserve user-data
  preserve

  * Create tempfolder within zipdir, where files will be copied then zipped
  local tempfolder `"`zipdir'/temp4dependencies"'

  * Check if the folder already exists
  mata : st_numscalar("r(dirExist)", direxists(`"`tempfolder'"'))

  * If not, create it
  if `r(dirExist)' == 0  mkdir `"`tempfolder'"'

  * If yes, erase contents to be sure it won't have conflicting versions of ados
  else dependencies_clear_dir, dir2clear(`tempfolder')

  dis as text _newline "Freezing files..."

  quietly {

    * Create file for metadata of frozen dependencies
    clear
    set obs 2
    gen v1 = `"*! dependencies frozen in $S_DATE"' in 1
    save `"`tempfolder'/dependencies.dta"', replace
    * For every file package/command, one line will be appended

    *---------------------------------------------------------------------------

    * Reads information on installed packages from stata.trk
    * most users will only have one stata.trk in their PLUS folder
    * but the code is flexible to multiple stata.trk files

    capture findfile "stata.trk", path(`"`c(adopath)'"') all
    local stata_trk_list `"`r(fn)'"'

    if _rc != 0 {
      noi dis as text "... could not find any stata.trk along the adopath, will only attempt to freeze standalone files"
    }

    else {

      * Reverse the list of all stata.trk found in adopath
      * because if a command exists in two places (ie: PLUS & PERSONAL),
      * it will be copied with replacement twice, and we want the most
      * prioritarian (which findfile lists first) to be kept (copied last)
      local n_stata_trk : list sizeof stata_trk_list
      forvalues i = `n_stata_trk'(-1)1 {
        local reversed_list "`reversed_list' `: word `i' of `stata_trk_list''"
      }

      * Loop through each stata.trk found in adopath
      foreach stata_trk_file of local reversed_list {

        * Since the paths of files in stata.trk are relative, they need this dir
        local stata_trk_dir = subinstr(`"`stata_trk_file'"', "stata.trk", "", .)

        * Each line is considered a single observation - then parsed later
        import delimited using `"`stata_trk_file'"', delimiter(`"`=char(10)'"') clear

        * First character marks: S (source) N (name) D (installation date) d (description) f (files) U(stata tracker) e(end)
        gen marker = substr(v1, 1, 1)
        drop if inlist(marker, "*", " ", "U", "d")

        * Making sense of stata.trk means tagging which lines refer to which pkg (N)
        gen pkg_name = substr(v1, 3, .) if marker == "N"
        forvalues i = 1/`=_N' {
          if marker[`i'] == "S" replace    pkg_name = pkg_name[`i' + 1] in `i'
          if marker[`i'] == "N" local last_pkg_name = pkg_name[`i']
          if inlist(marker[`i'], "e", "f", "D") replace pkg_name = "`last_pkg_name'" in `i'
        }

        *-------------------------------------------------------------------------

        * Option -all- will freeze everything found in stata.trk
        if "`all'" == "all" {
          gen byte to_freeze = 1
        }

        * Option -adolist- will only freeze the selected commands
        else {
          gen byte to_freeze = 0
          foreach command of local adolist {
            * If the command matches a package name, flag file as to_freeze
            forvalues i = 1/`=_N' {
              if "`command'.pkg" == "`= pkg_name[`i']'" replace to_freeze = 1 in `i'
            }
          }
        }

        * Now deals only with the files to freeze
        keep if to_freeze == 1
        gen f_name      = substr(v1, 3, .)                       if marker == "f"
        gen full_f_name = `"`stata_trk_dir'"' + f_name           if marker == "f"
        replace full_f_name = subinstr(full_f_name, "\", "/", .) if marker == "f"

        * Will later export this metadata file (akin to stata.trk) for documentation
        append using `"`tempfolder'/dependencies.dta"'
        save `"`tempfolder'/dependencies.dta"', replace

        * Some nice info to display
        tab pkg_name if marker == "f"
        noi dis as text `"... `r(N)' files from `r(r)' packages in `stata_trk_dir'"'

        * Local to keep track of packages and files frozen
        local frozen_pkgs  ""
        local frozen_files ""

        * Loops through all observations (each being a file)
        keep if marker == "f"
        if `r(N)' > 0 {
          forvalues i = 1/`r(N)' {
            local pkg_to_copy  = pkg_name[`i']
            local file_to_copy = full_f_name[`i']
            _getfilename "`file_to_copy'"
            local filename `"`r(filename)'"'

            * Most important line in this program: copy what needs to be frozen
            copy `"`file_to_copy'"'  `"`tempfolder'/`r(filename)'"', replace

            * Update locals with frozen file and package
            local frozen_pkgs  : list frozen_pkgs  | pkg_to_copy
            local frozen_files : list frozen_files | filename
          }
        }

      * End of section that depends on this stata.trk (goes to the next stata.trk)
      }
    }

    * Create the metadata file (akin to stata.trk)
    use `"`tempfolder'/dependencies.dta"', clear
    replace v1 = marker + " " + full_f_name if !missing(full_f_name)
    keep v1
    export delimited using `"`tempfolder'/dependencies.trk"', delimiter(`"`=char(10)'"') novarnames replace
    * The dta was only created temporarily, we don't want it saved in the zipfile
    erase `"`tempfolder'/dependencies.dta"'


    *---------------------------------------------------------------------------

    * Option -adolist- will also search for stand-alone commands
    if "`adolist'" != "" {

      * Local to keep track of stand-alone files frozen
      local n_standalone_files = 0

      foreach command of local adolist {
        foreach ending in ado dlg hlp sthlp {

          local file_to_search = "`command'.`ending'"

          * Search along the current ado-path (first instance)
          cap findfile `"`file_to_search'"'
          if _rc == 0 {
            * Is the file found the same that was already frozen from a package?
            local already_copied : list file_to_search in frozen_files
            if `already_copied' == 0 {
              copy `"`r(fn)'"' `"`tempfolder'/`command'.`ending'"', replace
              local ++n_standalone_files
            }
          }

          * It's okay to not find other endings, but command.ado displays warning
          * unless it was already found and interpreted as a package
          else {
            if "`ending'" == "ado" & strpos("`frozen_pkgs'", "`command'.pkg") == 0 {
             noi dis as error `"Warning! Could not find `command' in adopath. Skipped."'
           }
          }

        }
      }

      if `n_standalone_files' > 0 noi dis as text "... `n_standalone_files' stand-alone files"
    }

    *---------------------------------------------------------------------------

    * Zip all files copied in tempfolder into using zipfile.zip
    cd `"`tempfolder'"'
    zipfile *.*, saving(`"`zipdir'/`zipfn'"', replace)
    cd `"`zipdir'"'

  }

  * Erase the tempfolder and all its contents
  dependencies_clear_dir, dir2clear(`tempfolder') rmdir

  dis as text `"Successfully frozen dependencies in `zipdir'/`zipfn'"'

end


*-------------------------------------------------------------------------------


cap program drop dependencies_unfreeze
program define   dependencies_unfreeze
* This subprogram:
*   unzip to DEPENDENCIES ado-path the dependency ados

  syntax using/ , depfolder(string)

  * Must be able to read using file
  confirm file `using'

  * Split using argument into r(path) r(filename) and r(extension)
  mata: split_using(`"`using'"')
  local zipdir = "`r(path)'"
  local zipfn  = "`r(filename)'"

  * Check that extension is indeed a zip
  if `"`r(extension)'"' != ".zip" {
    noi dis as error `"using must specify a file ending with .zip - you provided `using'"'
    exit 198
  }

  * Check if the folder already exists
  mata : st_numscalar("r(dirExist)", direxists(`"`depfolder'"'))

  * If not, create it
  if `r(dirExist)' == 0  mkdir `"`depfolder'"'

  * If yes, erase contents to be sure it won't have conflicting versions of ados
  else qui dependencies_clear_dir, dir2clear(`depfolder')

  * Change to the dependencies ado-path (likely C:/ado/dependencies)
  qui cd `"`depfolder'"'

  * Make this folder the top priority ado-path
  * (this allows users to keep same-name ado in another ado-path)
  qui adopath ++ `"`depfolder'"'

  * Copy the specified zip with frozen version
  qui copy `"`zipdir'/`zipfn'"' `"`depfolder'/temp.zip"', replace

  * Extract the frozen version of the dependency
  qui unzipfile temp.zip, replace
  qui erase temp.zip

  * Display warning if no ado was just unfrozen
  qui local ado_files : dir "`depfolder'" files "*.ado", respectcase
  qui local n_ado_files : word count "`ado_files'"
  if `n_ado_files' == 0 {
    dis as error `"Warning! There were no ado files (*.ado) in `zipfn'."'
  }
  else {
    dis as text `"The `n_ado_files' ado files in `zipfn' were unfrozen in `depfolder'."'
  }

  cap confirm file `"`depfolder'/dependencies.trk"'
  if _rc == 0 type `"`depfolder'/dependencies.trk"', starbang

end


*-------------------------------------------------------------------------------


cap program drop dependencies_which
program define   dependencies_which
* This subprogram:
*   list whethever is currently in the DEPENDENCIES ado-path

  syntax, depfolder(string)

  * Check if the folder already exists
  mata : st_numscalar("r(dirExist)", direxists(`"`depfolder'"'))
  if `r(dirExist)' == 0  dis as result `"There is no -dependencies- ado path set up."'

  * Display info about all ados currently in DEPENDENCIES ado-path
  else {

    * Starts by displaying metadata file if it exists
    cap confirm file `"`depfolder'/dependencies.trk"'
    if _rc == 0 type `"`depfolder'/dependencies.trk"', starbang

    local ado_files : dir "`depfolder'" files "*.ado", respectcase
    if `"`ado_files'"' == "" {
      dis as result _newline `"There are no ado files (*.ado) in `depfolder'."'
    }

    else {
      dis as result _newline `"Ado files (*.ado) currently in `depfolder':"' _newline
      foreach  command of local ado_files {
        which `command'
      }
    }

  }

end


*-------------------------------------------------------------------------------


cap program drop dependencies_remove
program define   dependencies_remove
* This subprogram
*   remove the DEPENDENCIES ado-path and its contents

  syntax, depfolder(string)

  * Check if the folder already exists
  mata : st_numscalar("r(dirExist)", direxists(`"`depfolder'"'))
  if `r(dirExist)' == 0  dis as result `"There is no -dependencies- ado path set up (nothing to be removed)."'

  else {

    * Erase any possible contents in folder and the folder itself
    dependencies_clear_dir, dir2clear(`depfolder') rmdir

    * Remove it from the ado-path list
    cap adopath - `"`depfolder'"'
    * The capture prevents errors if the folder was never added to the adopath (ie: unfrozen)

    dis as text `"Successfully removed dependencies ado-path and all its contents (`depfolder')."'

  }

end


*-------------------------------------------------------------------------------


cap program drop dependencies_clear_dir
program define   dependencies_clear_dir
* This auxprogram
*   erase all contents in a folder and optionally also remove the folder

  syntax, dir2clear(string) [rmdir]

  local files2clear : dir `"`dir2clear'"' files "*"
  foreach file of local files2clear {
    erase `"`dir2clear'/`file'"'
  }

  if "`rmdir'" == "rmdir"  rmdir `"`dir2clear'"'

end


* Not terribly elegant, but does the trick
cap mata: mata drop split_using()

*------------------------------- MATA -----------------------------------------

mata:
mata set matastrict on

void split_using(string scalar using2split) {
// using2split broken into macros: r(path), r(filename), r(extension)
// if the path is not absolute, it is autocompleted with pwd

  string scalar path,
                filename,
                extension

  pragma unset path
  pragma unset filename
  pragma unset extension

  // Autocomplete to absolute path if relative path
  if (pathisabs(using2split) == 0) {
    using2split = pathjoin(pwd(), using2split)
  }

  // Attempt to extract file extension
  extension = pathsuffix(using2split)

  // If there is no extension, the whole thing is a path (filename is empty)
  if (extension == "") {
    filename = ""
    path = using2split
  }

  else {
    pathsplit(using2split, path, filename)
  }

  st_rclear()
  st_global("r(path)", path)
  st_global("r(filename)", filename)
  st_global("r(extension)", extension)

}
end

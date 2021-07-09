/*  Stata interface to n-gram counting C++ code */

program _ngram, plugin

program define ngram_core, rclass
*! 1.0.0   April 2017 
  version 13
  
  syntax varname(string) [if] [in], [DEGree(int 1) THRESHold(int 5) Prefix(str) BINarize LOcale(str) STOPwords(str) STEMmer noLower PUNCTuation non_token]
  
  // fill in defaults for the str arguments (which 'syntax' doesn't let us do)
  if("`locale'"=="") {
    // locale is read from Stata14+'s `. set locale_functions` config value.
    // if we're on an older Stata then locale will just end up empty, and this is tolerable:
    // if the wrong results come out the user can specify locale() explicitly
    local locale = "`c(locale_functions)'"
  }
  
  parse_locale "`locale'"
  local language = "`r(language)'"
  local region = "`r(region)'"
  
  // parse the stopwords argument
  if(`"`stopwords'"'=="") {
    // if not given, default to the stopwords file for the current language
    // *if this file is missing*, give a warning but continue with no stopwords
    // (but if the file is available but unreadable or something else goes wrong, error out)
    capture noisily load_stopwords "`language'"
    if(_rc == 0) {
      local stopwords = `"`r(stopwords)'"'
    }
    else {
      if(_rc == 7) {
        // missing file. load_stopwords has warned about this.
        // we need to let this be okay because most languages don't have stopwords files.
      }
      else {
        exit _rc
      }
    }
  }
  else if(`"`stopwords'"' == ".") {
    // special case: a single "." means "don't use any stopwords"
    // we cannot use "" for this case as that is the only default value Stata allows for str options, so it's taken.
    local stopwords = ""
  }
  else {
    gettoken plus : stopwords
    if("`plus'"=="+") {
      // a + token means "append the given stopwords to the default stopwords"
      gettoken plus stopwords : stopwords //shift the + off; this looks redudant but it's because the previous gettoken was like a "peek()"
      capture noisily load_stopwords "`language'"
      di as txt "Also removing stopwords:`stopwords'" // Careful: this must happen before the prepend on the next line
                                                      // Careful: the gettoken always leaves an extra space up front,
                                                      //          which is why we *don't* leave a space here.
      local stopwords = "`r(stopwords)' `stopwords'"
    }
    else {
      // stopwords is (already) an explicit list
      di as txt "Removing stopwords: `stopwords'"
    }
  }
  
  //di as txt "stopwords = `stopwords'" //DEBUG
  
  /* normalize the flags; the way the plugin detects them is by checking if the string it gets for each is empty or not, but Stata's cute way of doing default-trues (where it gives you "nopunctuation" breaks that */
  
  if("`lower'"=="nolower") {
    local lower = ""
  }
  else {
    local lower = "lower"
  }
  
  if("`prefix'"=="") {
    // default prefix is 't' for "text"
    // the point of the prefix is to avoid most naming conflicts with other Stata variables and with Stata keywords.
    // and as a side effect, to make it easy to select all the text-mined columns (or even to do a second batch of parsing)
    // we force the effort onto the end user because there is no totally reliable way to make safely quoted arbitrary variable names in Stata,
    // especially not when you're text-mining and any quoting choice you might make could just overlap the quoting of another distinct string
    // (e.g. "ba.ll" and "ba;ll" both quote to "ba_ll")
    local prefix = "t_"
  }
  
  // do the main batch of parsing, caching the results *in C*
  tempvar l
  gen int `l' = strlen(`varlist')

  plugin call _ngram `varlist' `l' `if' `in', parse "`degree'" "`locale'" "`stemmer'" `"`stopwords'"' "`lower'" "`punctuation'" "`threshold'"
  drop `l'
  
  local valid_vars = "" //list of only the variables that will survive the end of this routine
  local vars = ""       //list of all variables, including the invalid ones, because we need to pass precisely these back into the plugin a second time
  foreach word of local words {
    //di as txt "word = '`word''"
    // construct
    // and remember to sanitize to make valid Stata variables
    local var = strtoname(`"`prefix'`word'"')

    
    /* summarily get rid of `var'. If it exists we would want to update it to have the new counts instead, anyway. */
    cap drop `var'
    
    /* make a new variable for counting `word' */
    capture noisily qui generate int `var' = 0
    if(_rc == 0) {
    label variable `var' `"# of `word' in '`varlist''"'
     //(contains error; unsure what to do) label variable `var'  "# of '`word'' in '`varlist''"
      local valid_vars = "`valid_vars' `var'"
    }
    else if(_rc == 900) {
      // out of space (> c(maxvar)). give up.
      continue, break
    }
    else {
      // strtoname() *does not* detect the cases where the name is a Stata keyword,
      // and there is no way to quote a variable name to shove keywords in.
      // And the only ways we can think to detect this case are
      // - a giant list of keywords (tedious and fragile)
      // - exceptions-as-returns    (unclean)
      // Obviously, we're using the latter.
      
      di as error "Stata rejected '`var'' as a variable name. It will be dropped."
      
      // We still need to put a column in place for the C code ("_ngram, export") to work
      // (if not, the counts would all be shifted!), so we use a Stata-generated tempvar
      tempvar var
      capture noisily qui generate int `var' = 0
      // I ~believe~ how tempvar works is that at an "end" all tempvars get erased from the dataset.
      // This is perfect for our purposes: the columns will all be in the right places for "_ngram, export"
      // but the bum variable will get lost. It will mostly work but the user will just have to accept that using Stata instead of a more modern language hurts them.
      //
      // Most of the problem words will be on the Stopwords list anyway, but if the user overrides that or is, say,
      // using the Dutch stemmer but has a mixed English-Dutch corpus, keywords could slip in and we have to handle them.
    }

    /* collect the new variable */
    // note: this is only done *after* the if-else because the if-else has a break in it that means `var' is invalid
    local vars = "`vars' `var'"
  }
  local vars = trim("`vars'")
  local valid_vars = trim("`valid_vars'")
  
  if("`n_token'"!="non_token") {
    local n_token = "n_token"
    qui capture gen `n_token' = 0
    if(_rc == 0) {  // if we ran out of space above, we'll run out of space again here; tolerate this case
      label variable `n_token' "Total number of words in '`varlist''"
    }
  }
  else {
    local n_token = ""
  }
  
  // fill in those word count columns and possibly the number-of-tokens column
  plugin call _ngram `vars' `n_token' `if' `in', export
  
  // dichotomize responses, if requested
  if("`binarize'"!="" & "`vars'" != "") {
      foreach var of varlist `vars' {
          qui replace `var' = `var' > 0
      }
  }
  
  // report the newly created variables to the caller
  return clear
  return local words = "`valid_vars'"
  
  exit `__rc'
end




program define load_stopwords, rclass
  version 13
  gettoken language : 0
  
  local stopwords = ""
  
  capture qui findfile "stopwords_`language'.txt"
  if(_rc==0) {
    local using = "`r(fn)'"
  }
  else {
    di as error "Warning: Unable to find stopwords file 'stopwords_`language'.txt'. Stopwords will not be loaded."
    exit 7
  }
  
  tempname fd
  file open `fd' using "`using'", read text
  
  file read `fd' line
  while(r(eof) == 0) {
    local stopwords = `"`stopwords' `line'"'
    file read `fd' line
  }

  // BEWARE: UI creep: this subroutine shouldn't know about "Removing",
  // but it's the only place that knows about the filename
  di as txt "Removing stopwords specified in stopwords_`language'.txt"
  
  return clear
  return local stopwords = `"`stopwords'"'
end

// parse a  libicu (level 2 canonicalization) locale ID into
// as defined at http://userguide.icu-project.org/locale#TOC-Canonicalization
// ..more or less. This doesn't cover all cases.
// Beware: this is duplicated in _ngram.cpp:parse_libicu_locale_()
program define parse_locale, rclass
  version 13
  
  gettoken locale : 0
  
  plugin call _ngram, parse_libicu_locale "`locale'"
  
  return clear
  return local language = "`language'"
  return local region = "`region'"
end

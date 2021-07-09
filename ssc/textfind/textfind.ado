*------------------------------------------------------------------------------*
* textfind program                                                             *
* Author:  Andre Assumpcao                                                     *
* Contact: aassumpcao@unc.edu                                                  *
* Version: 1.0 - Jan 27, 2018                                                  *
* Version: 1.1 - Feb 02, 2018                                                  *
* Version: 1.2 - April 27, 2018                                                *
* Version: 1.3 - May 9, 2018                                                   *
* Version: 1.4 - April 15, 2019                                                *
* Version: 1.5 - October 1, 2019                                               *

/*
Textfind is a data-driven program to identify and perform statistical tests on
textual data based on flexible search criteria following regular expressions.
Textfind is useful for people who want to do more content analysis but are not
familiar with other more popular platforms to that end. Any suggestions are wel-
come and should be submitted to the author in the e-mail above. Have fun! */
*------------------------------------------------------------------------------*

capture program drop textfind
program textfind, rclass

  *** Version in which program was created
  version 15.0

  *** Program Syntax
  syntax varlist [if] [in] [, ///
    KEYword(string asis) ///
    but(string asis) ///
    nocase ///
    exact ///
    or ///
    notable ///
    tag(string) ///
    nfinds ///
    length ///
    position ///
    tfidf]

  marksample touse, strok

  *** Version required to run program: 15.0 or higher
  if c(stata_version) < 15 {
    di as err "Stata 15 or higher required."
    exit 198
  }
  di as text " "

  *** Commands by variable and keyword
  foreach i of local varlist {
    local vars: word count `varlist'

    if `vars' > 1 {
      di as err "textfind is not ready to handle multiple variables yet."
      exit 103
    }

    *** Check whether variable type was actually string
    capture confirm str variable `i'
    if _rc {
      di "{bf: `i'}" as text " is not string. No search can be performed."
      continue
    }

    *** Check for at least one keyword or exclusion
    if  `"`keyword'"' == "" & `"`but'"' == "" {
      di as err "At least one keyword or exclusion must be defined."
      exit 198
    }
    else {
      qui {
        ************************************************************************
        ***** General locals, scalars and inputs which will be used later ******
        ************************************************************************

        *** Count number of keywords
        local n: word count `keyword'

        *** Count number of exclusions
        local m: word count `but'

        *** Store number of keywords
        return scalar nkey  = `n'

        *** Store number of exclusions
        return scalar mbut  = `m'

        *** Store keywords for future display
        return local allkey = `"`keyword'"'

        *** Store exclusions for future display
        return local allbut = `"`but'"'

        *** Create temp variables for word length and count of observations
        tempvar `i'length

        *** Count words in string variable
        gen ``i'length' = ustrwordcount(stritrim(ustrtrim(`i'))) if `touse'
        sum ``i'length' , meanonly
        return scalar stringlength  = `r(max)'

        *** Count observations for use in tf-idf statistic
        count if !mi(`i')
        return scalar `i'count = `r(N)'


        ************************************************************************
        *************************** SEARCH CRITERIA ****************************
        ************************************************************************
        *** Letter case local
        if `"`case'"' != "" {
          local case = 1
        }
        else {
          local case = 0
        }

        *** "Or" and "and" search local
        if `"`or'"' != "" {
          local conc = "|"
        }
        else {
          local conc = "&"
        }

        *** Create individual search criteria
        forv z = 1 / `n' {

          *** Pull word to fill in search
          local y: word `z' of `keyword'

          *** Exact search
          if `"`exact'"' != "" {
            local gram = `"^(`y')$"'
          }
          else {
            local gram = `"`y'"'
          }

          *** One local for each keyword
          local key`z' ustrregexm(`i', `"`gram'"', `case') == 1
        }

        *** Create individual exclusion criteria
        forv z = 1 / `m' {

          *** Pull exclusion to fill in search
          local y: word `z' of `but'

          *** Exact search
          if `"`exact'"' != "" {
            local gram = `"^(`y')$"'
          }
          else {
            local gram = `"`y'"'
          }

          *** One local for each keyword
          local not`z' ustrregexm(`i', `"`gram'"', `case') == 0
        }

        *** Create compiled search criteria
        *** When there is only one keyword
        if `n' == 1 {
          local key = `"`key1'"'
        }

        *** When there are multiple keywords
        else if `n' > 1 {

          *** Define final local as equal to first local
          local key = `"`key1'"'

          *** Loop over keywords and fill in final local
          forv z = 2 / `n' {
            local key = `"`key`z'' `conc' `key'"'
            local k`z'= `"`key'"'
          }
        }

        *** When there is only one exclusion
        if `m' == 1 {
          local not = `"`not1'"'
        }

        *** When there are multiple exclusions
        else if `m' > 1 {

          *** Define final local as equal to first local
          local not = `"`not1'"'

          *** Loop over keywords and fill in final local
          forv z = 2 / `m' {
            local not = `"`not`z'' `conc' `not'"'
            local n`z'= `"`not'"'
          }
        }

        ************************************************************************
        ****************************** STATISTICS ******************************
        ************************************************************************

        ******************
        *** FIND TABLE ***
        ******************
        forv z = 1 / `n' {
          local y: word `z' of `keyword'
          noisily di as text `"Searching keyword "`y'" in variable `i' ..."'

          *** Create six temporary variables to fill in table
          tempvar `i'`z'1 `i'`z'2 `i'`z'3 `i'`z'4 `i'`z'5 `i'`z'6

          *** Create other temporary variables necessary for calculation
          tempvar `i'keylen`z' `i'keytfidf`z' `i'0

          **********************
          *** 1. Total Finds ***
          **********************
          gen ``i'`z'1' = `key`z'' if !mi(`i') & `touse'
          count if ``i'`z'1' == 1
          return scalar f`i'`z'1 = `r(N)'

          ************************
          *** 2. Average Finds ***
          ************************
          *** Fill in variable counting total length of string when keyword is
          *** found
          gen ``i'keylen`z'' = cond(`key`z'', ustrlen(`"`y'"'), ., .) if `touse'

          *** Fill in statistic 2
          gen ``i'`z'2' = ///
            cond(`key`z'', (ustrlen(`i') - ustrlen(ustrregexra(`i', `"`y'"', ///
            "", `case'))) / ``i'keylen`z'', ., .) if `touse'

          *** Run test for missing before filling variable in table
          capture assert ``i'`z'2' == .
            if _rc {
              sum ``i'`z'2' if !mi(``i'`z'2') & `touse', meanonly
              return scalar f`i'`z'2 = `r(mean)'
            }
            else {
              return scalar f`i'`z'2 = .
            }

          *************************************************
          *** 3. Average number of words in observation ***
          *************************************************
          *** Fill in statistic 3
          gen ``i'`z'3' = cond(`key`z'', ustrwordcount(`i'), ., .) ///
            if !mi(`i') & `touse'

          *** Run test for missing before filling variable in table
          capture assert ``i'`z'3' == .
            if _rc {
              sum ``i'`z'3' if `touse', meanonly
              return scalar f`i'`z'3 = `r(mean)'
            }
            else {
              return scalar f`i'`z'3 = .
            }

          ********************************
          *** 4. Average word position ***
          ********************************
          *** This variable only makes sense if the search is not exact
          if `"`exact'"' == "" {

            *** Gen empty variable
            gen int ``i'`z'4' = . if `touse'

            *** Fill in statistic 4
            forv j = 1 / `return(stringlength)' {

              replace ``i'`z'4' = cond(ustrregexm(ustrword(`i', `j'), ///
                `"`y'"', `case'), `j', ``i'`z'4', .)
            }

            *** Run test for missing or null values before filling in table
            capture assert ``i'`z'4' == .
              if _rc {
                sum ``i'`z'4' if `touse', meanonly
                return scalar f`i'`z'4 = `r(mean)'
              }
              else {
                return scalar f`i'`z'4 = .
              }
          }

          else {

            *** Return null statistic if exact is specified
            return scalar f`i'`z'4 = .
          }

          *************************
          *** 5. Average TF-IDF ***
          *************************
          *** Generate tf-idf variable
          gen ``i'keytfidf`z'' = cond(`key`z'', (``i'`z'2' / ``i'length') * ///
            ln(`return(`i'count)' / `return(f`i'`z'1)'), ., .) ///
              if !mi(`i') & `touse'

          *** Run test for missing values before filling in table
          capture assert ``i'keytfidf`z'' == .
            if _rc {
              sum ``i'keytfidf`z'' if `touse', meanonly
              return scalar f`i'`z'5 = `r(mean)'
            }
            else {
              return scalar f`i'`z'5 = .
            }

          *********************
          *** 6. Means test ***
          *********************
          *** Identify sample of observations where keyword was not found
          gen ``i'0' = cond(`key`z'', 0, 1, .) if !mi(`i') & `touse'

          *** Compare across means
          if `z' == 1 {

            *** Test whether the sample identified by keyword is different than
            *** the sample NOT identified by keyword
            ttest ``i'0' == ``i'`z'1' if `touse'
            return scalar f`i'`z'6 = .
          }

          else if `z' > 1 {
            gen ``i'`z'6' = `k`z'' if !mi(`i') & `touse'

            local q = `z' - 1
            *** Test whether the sample identified by keyword(s) z('s) + 1 is
            ***  different from sample identified earlier by z's
            if `z' == 2 {
              ttest ``i'`z'6' == ``i'`q'1' if `touse'
            }
            else {
              ttest ``i'`z'6' == ``i'`q'6' if `touse'
            }
            return scalar f`i'`z'6 = `r(p)'
          }
        }

        ***********************
        *** EXCLUSION TABLE ***
        ***********************
        forv z = 1 / `m' {
          local y: word `z' of `but'
          noisily di as text `"Searching exclusion "`y'" in variable `i' ..."'

          *** Create six temporary variables to fill in table
          tempvar `i'`z'1 `i'`z'2 `i'`z'3 `i'`z'4 `i'`z'5 `i'`z'6

          *** Create other temporary variables necessary for calculation
          tempvar `i'notlen`z' `i'sum`z' `i'nottfidf`z' `i'0

          ***************************
          *** 1. Total exclusions ***
          ***************************
          gen ``i'`z'1' = `not`z'' if !mi(`i') & `touse'
          count if ``i'`z'1' == 0
          return scalar n`i'`z'1 = `r(N)'

          *****************************
          *** 2. Average exclusions ***
          *****************************
          *** Fill in tempvar `notlength'
          gen ``i'notlen`z'' = cond(`not`z'', ., ustrlen(`"`y'"'), .) if `touse'

          *** Fill in statistic 2
          gen ``i'`z'2' = ///
            cond(`not`z'' | ``i'notlen`z'' == ., ., ///
            (ustrlen(`i') - ustrlen(ustrregexra(`i', `"`y'"', "", `case'))) ///
             / ``i'notlen`z'') if `touse'

          *** Run test for missing values before filling in table
          capture assert ``i'`z'2' == .
            if _rc {
              sum ``i'`z'2' if `touse', meanonly
              return scalar n`i'`z'2 = `r(mean)'
            }
            else {
              return scalar n`i'`z'2 = .
            }

          *****************************************************************
          *** 3. Average number of words in observation after exclusion ***
          *****************************************************************
          *** Fill in statistic 3
          gen ``i'`z'3' = cond(`not`z'', ., ustrwordcount(`i'), .) ///
            if !mi(`i') & `touse'

          *** Generate mean for table
          capture assert ``i'`z'3' == .
            if _rc {
              sum ``i'`z'3' if `touse'
              return scalar n`i'`z'3 = `r(mean)'
            }
            else {
              return scalar n`i'`z'3 = .
            }

          *************************************
          *** 4. Average exclusion position ***
          *************************************
          *** Gen empty variable
          gen int ``i'`z'4' = . if `touse'

          *** This variable only makes sense if the search is not exact
          if `"`exact'"' == "" {

            *** Fill in statistic 4
            forv j = 1 / `return(stringlength)' {

              replace ``i'`z'4' = cond(ustrregexm(ustrword(`i', `j'), ///
               `"`y'"', `case') == 1, `j', ``i'`z'4', .)
            }

            *** Run test for missing or null values before filling in table
            capture assert ``i'`z'4' == .
              if _rc {
                sum ``i'`z'4' if `touse', meanonly
                return scalar n`i'`z'4 = `r(mean)'
              }
              else {
                return scalar n`i'`z'4 = .
              }
          }

          *** If search is exact, this statistic should not be calculated
          else {
            return scalar n`i'`z'4 = .
          }

          *************************
          *** 5. Average TF-IDF ***
          *************************
          *** Generate tf-idf variable
          gen ``i'nottfidf`z'' = cond(`not`z'', ., (``i'`z'2'/``i'length') * ///
            ln(`return(`i'count)' / `return(n`i'`z'1)'), .) ///
              if !mi(`i') & `touse'


          *** Run test for missing values before filling in table
          capture assert ``i'nottfidf`z'' == .
            if _rc {
              sum ``i'nottfidf`z'' if `touse', meanonly
              return scalar n`i'`z'5 = `r(mean)'
            }
            else {
              return scalar n`i'`z'5 = .
            }

          *********************
          *** 6. Means test ***
          *********************
          *** Identify sample of observations where keyword was not found
          gen ``i'0' = cond(`not`z'', 1, 0, .) if !mi(`i') & `touse'

          *** Compare across means
          if `z' == 1 {

            *** Test whether the sample identified by keyword is different than
            *** the sample NOT identified by keyword
            ttest ``i'0' == ``i'`z'1' if `touse'
            return scalar n`i'`z'6 = .
          }

          else if `z' > 1 {
            gen ``i'`z'6' = `n`z'' if !mi(`i') & `touse'

            local q = `z' - 1
            *** Test whether the sample identified by keyword(s) z('s) + 1 is
            ***  different from sample identified earlier by z's
            if `z' == 2 {
              ttest ``i'`z'6' == ``i'`z'1' if `touse'
            }
            else {
              ttest ``i'`z'6' == ``i'`q'6' if `touse'
            }
            return scalar n`i'`z'6 = `r(p)'
          }
        }

        *************************
        *** COMPILED CRITERIA ***
        *************************

        *** Call locals and temporary vars
        local t = `n' + 1

        *** Create six temporary variables to fill in table
        tempvar `i'tot `i'`t'2 `i'len `i'`t'4 `i'keytfidf `i'nottfidf `i'ttest

        *** Create other temporary variables necessary for calculation
        tempvar `i'totlen `i'keylen

        if `"`keyword'"' != "" {

          if `"`but'"' == "" {

            ***********************************
            *** CASE 1: key == T & but == F ***
            ***********************************

            **********************
            *** 1. Total finds ***
            **********************
            gen ``i'tot' = `key' if !mi(`i') & `touse'
            count if ``i'tot' == 1
            return scalar f`i'`t'1 = `r(N)'

            ************************
            *** 2. Average Finds ***
            ************************
            if `n' == 1 {

              *** If there is just one keyword, then this is the same result as
              *** in the individual search
              return scalar f`i'`t'2 = `return(f`i'`n'2)'
            }

            else {

              *** If there is more than one keyword, then this statistic should
              *** not be calculated
              return scalar f`i'`t'2 = .
            }

            *************************************************
            *** 3. Average number of words in observation ***
            *************************************************
            *** Fill in
            gen ``i'len' = cond(`key', ustrwordcount(`i'), ., .) ///
              if !mi(`i') & `touse'

            *** Run test for missing before filling variable in table
            capture assert ``i'len' == .
              if _rc {
                sum ``i'len' if `touse', meanonly
                return scalar f`i'`t'3 = `r(mean)'
              }
              else {
                return scalar f`i'`t'3 = .
              }

            ********************************
            *** 4. Average word position ***
            ********************************
            if `"`exact'"' == "" & `n' == 1 {
              return scalar f`i'`t'4 = `return(f`i'14)'
            }
            else {

              *** This statistic doesn't make sense for the combined search
              return scalar f`i'`t'4 = .
            }

            *************************
            *** 5. Average TF-IDF ***
            *************************
            if `n' == 1 {
              return scalar f`i'`t'5 = `return(f`i'15)'
            }
            else {
              *** This statistic doesn't make sense for the combined search
              return scalar f`i'`t'5 = .
            }

            *********************
            *** 6. Means test ***
            *********************
            ttest ``i'`n'1' == ``i'tot'
            return scalar f`i'`t'6 = `r(p)'
          }

          else {

            ***********************************
            *** CASE 2: key == T & but == T ***
            ***********************************

            **********************
            *** 1. Total finds ***
            **********************
            gen ``i'tot' = (`key') & (`not') if !mi(`i') & `touse'
            count if ``i'tot' == 1
            return scalar f`i'`t'1 = `r(N)'

            ************************
            *** 2. Average Finds ***
            ************************
            if `n' == 1 {
              local y: word `n' of `keyword'

              *** Fill in temporary variable
              gen ``i'totlen' = cond(`key' & (`not'), ustrlen(`"`y'"'), ., ///
                .) if `touse'

              *** Generate var for table
              gen ``i'`t'2' = cond(`key' & (`not'), ///
                (ustrlen(`i') - ustrlen(ustrregexra(`i', `"`y'"', "", ///
                `case'))) / ``i'totlen', ., .) if `touse'

              *** Run test for missing before filling variable in table
              capture assert ``i'`t'2' == .
                if _rc {
                  sum ``i'`t'2' if `touse', meanonly
                  return scalar f`i'`t'2 = `r(mean)'
                }
                else {
                  return scalar f`i'`t'2 = .
                }
            }

            else {

              *** If there is more than one keyword, this should not be calcula-
              *** ted
              return scalar f`i'`t'2 = .
            }
            *************************************************
            *** 3. Average number of words in observation ***
            *************************************************
            *** Fill in
            gen ``i'len' = cond((`key') & (`not'), ustrwordcount(`i'), ., .) ///
              if !mi(`i') & `touse'

            *** Generate mean for table
            capture assert ``i'len' == .
              if _rc {
                sum ``i'len' if `touse', meanonly
                return scalar f`i'`t'3 = `r(mean)'
              }
              else {
                return scalar f`i'`t'3 = .
              }

            ********************************
            *** 4. Average word position ***
            ********************************
            if `"`exact'"' == "" & `n' == 1 {

              *** Fill in statistic 4
              gen int ``i'`t'4' = . if `touse'

              forv j = 1 / `return(stringlength)' {

                replace ``i'`t'4' = cond(`key' & (`not') & ///
                  ustrregexm(ustrword(`i', `j'), `"`y'"', `case') == 1, ///
                   `j', ``i'`t'4', .)
              }

              *** Run test for missing or null values before filling in table
              capture assert ``i'`t'4' == .
                if _rc {
                  sum ``i'`t'4' if `touse', meanonly
                  return scalar f`i'`t'4 = `r(mean)'
                }
                else {
                  return scalar f`i'`t'4 = .
                }
            }

            else {

              *** If there is more than one keyword, this should not be calcula-
              *** ted
              return scalar f`i'`t'4 = .
            }

            *************************
            *** 5. Average TF-IDF ***
            *************************
            if `n' == 1 {

              *** Generate tf-idf variable
              gen ``i'keytfidf' = cond(`key' & (`not'), ///
                (``i'`t'2' / ``i'length') * ///
                ln(`return(`i'count)' / `return(f`i'`t'1)'), ., .) ///
                  if !mi(`i') & `touse'

              *** Run test for missing values before filling in table
              capture assert ``i'keytfidf' == .
                if _rc {
                  sum ``i'keytfidf' if !mi(``i'keytfidf') & `touse', meanonly
                  return scalar f`i'`t'5 = `r(mean)'
                }
                else {
                  return scalar f`i'`t'5 = .
                }
            }

            else {

              *** If there is more than one keyword, this should not be calcula-
              *** ted
              return scalar f`i'`t'5 = .
            }

            *********************
            *** 6. Means test ***
            *********************
            ttest ``i'`n'1' == ``i'tot'
            return scalar f`i'`t'6 = `r(p)'
          }
        }

        else {

          ***********************************
          *** CASE 3: key == F & but == T ***
          ***********************************

          ***************************
          *** 1. Total exclusions ***
          ***************************
          gen ``i'tot' = `not' if `touse'
          count if ``i'tot' == 0
          return scalar f`i'`t'1 = `r(N)'

          ****************************
          *** 2. Average exclusion ***
          ****************************
          if `m' == 1 {

            *** Fill in temporary variable
            gen ``i'totlen' = cond(`not', ., ustrlen(`"`y'"'), .) ///
              if !mi(`i') & `touse'

            *** Generate var for table
            gen ``i'`t'2' = cond(`not' | ``i'totlen' == ., ., ///
              (ustrlen(`i') - ustrlen(ustrregexra(`i', `"`y'"', "", ///
              `case'))) / ``i'totlen', .) if !mi(`i') & `touse'

            *** Run test for missing values before filling in table
            capture assert ``i'`t'2' == .
              if _rc {
                sum ``i'`t'2' if `touse', meanonly
                return scalar f`i'`t'2 = `r(mean)'
              }
              else {
                return scalar f`i'`t'2 = .
              }
          }

          else {

            *** If there is more than one exclusion, then this should not be
            *** calculated
            return scalar f`i'`t'2 = .
          }

          *****************************************************************
          *** 3. Average number of words in observation after exclusion ***
          *****************************************************************
          *** Fill in statistic 3
          gen ``i'len' = cond(`not', ., ustrwordcount(`i'), .) ///
            if !mi(`i') & `touse'

          *** Generate mean for table
          capture assert ``i'len' == .
            if _rc {
              sum ``i'len' if `touse', meanonly
              return scalar f`i'`t'3 = `r(mean)'
            }
            else {
              return scalar f`i'`t'3 = .
            }

          *************************************
          *** 4. Average exclusion position ***
          *************************************
          if `"`exact'"' == "" & `m' == 1 {

            *** Gen empty variable
            gen int ``i'`t'4' = . if `touse'

            *** Fill in statistic 4
            forv j = 1 / `return(stringlength)' {
              replace ``i'`t'4' = cond(ustrregexm(ustrword(`i', `j'), ///
               `"`y'"', `case') == 1, `j', ``i'`t'4', .)
            }

            *** Run test for missing or null values before filling in table
            capture assert ``i'`t'4' == .
              if _rc {
                sum ``i'`t'4' if `touse', meanonly
                return scalar f`i'`t'4 = `r(mean)'
              }
              else {
                return scalar f`i'`t'4 = .
              }
          }

          else {

            *** If there is more than one exclusion, then this should not be
            *** calculated
            return scalar f`i'`t'4 = .
          }

          *************************
          *** 5. Average TF-IDF ***
          *************************
          if `m' == 1 {

            *** Generate tf-idf variable
            gen ``i'nottfidf' = cond(`not', ., (``i'`t'2'/``i'length') * ///
              ln(`return(`i'count)' / `return(f`i'`t'1)'), .) ///
                if !mi(`i') & `touse'


            *** Run test for missing values before filling in table
            capture assert ``i'nottfidf' == .
              if _rc {
                sum ``i'nottfidf' if !mi(``i'nottfidf') & `touse', meanonly
                return scalar f`i'`t'5 = `r(mean)'
              }
              else {
                return scalar f`i'`t'5 = .
              }
          }

          else {

            *** If there is more than one exclusion, then this should not be
            *** calculated
            return scalar f`i'`t'5 = .
          }

          *********************
          *** 6. Means test ***
          *********************
          ttest ``i'`m'1' == ``i'tot'
          return scalar f`i'`t'6 = `r(p)'
        }

        ************************************************************************
        ************************** r(matrix) creation **************************
        ************************************************************************
        *** Key matrix creation
        if `n' > 0 {

          *** Define the number of rows in matrix
          local w = `n' + 1

          *** Matrix dimensions
          matrix key = J(`w', 6, .)

          *** Fill matrix by row first and then by column
          forv z = 1 / `w' {
            forv j = 1 / 6 {
              matrix key[`z',`j'] = `return(f`i'`z'`j')'
            }
          }

          *** Copy to return
          return matrix key = key, copy
        }

        *** But matrix creation
        if `m' > 0 {

          *** Define the number of rows in matrix
          local w = `m'

          *** If keyword is not specified, then last row comes from exclusion
          *** matrix
          if `"`keyword'"' == "" {
            local w = `m' + 1
          }

          *** Matrix dimensions
          matrix but = J(`w', 6, .)

          *** Fill matrix by row first and then column up to last exclusion
          forv z = 1 / `m' {
            forv j = 1 / 6 {
              matrix but[`z',`j'] = `return(n`i'`z'`j')'
            }
          }

          if `"`keyword'"' == "" {
            *** Fill in last row
            forv j = 1 / 6 {
              matrix but[`w',`j'] = `return(f`i'1`j')'
            }
          }

          *** Copy to return
          return matrix but = but, copy
        }

      *** Quiet loop ends in next bracket
      }

      **************************************************************************
      *************************** REMAINING OPTIONS ****************************
      **************************************************************************

      *************
      *** Table ***
      *************
      if `"`table'"' != "" {
        *** No table (do nothing)
      }

      else if `"`table'"' == "" {

        *** Table header
        di _newline
        di as text "The following table displays the keyword(s) and " _continue
        di as text "exclusion(s) criteria used in"
        di as text "the search and returns six statistics for each " _continue
        di as text "variable specified:" _newline
        di as text "Total finds: " _skip(10) "the number of " _continue
        di as text "observations when criterion is met."
        di as text "Average finds per obs: the average occurrence of " _continue
        di as text "word when criterion is met."
        di as text "Average length: " _skip(7) "the average word " _continue
        di as text "length when criterion is met."
        di as text "Average position:" _skip(6) "the average " _continue
        di as text "position of match when criterion is met."
        di as text "Average tf-idf: " _skip(7) "the average term " _continue
        di as text "frequency-inverse document frequency"
        di as text _skip(23) "when the criterion is met."
        di as text "Means test p-value:    the p-value for a means " _continue
        di as text "comparison test across samples"
        di as text _skip(23) "identified by the different criteria." _newline
        di %~80s "{bf:Summary Table}"
        di "{hline 80}"
        di as result %-12s "variable:" as text `"`i'"'
        qui tab `i'
        di as text "n: `r(N)'" _continue
        di as text _col(28) %~44s "Average" _col(76) "Means"
        di as text _col(21) "Total" _col(29) _dup(41) "-" _col(77) "test"

        *** Filling out keywords by row
        if `"`keyword'"'!="" {

          *** Keyword == T
          di as result "keyword(s)" _continue
          di as text _col(21) "Finds"  _col(32) "Finds"    _continue
          di as text _col(42) "Length" _col(51) "Position" _continue
          di as text _col(64) "TF-IDF" _col(74) "p-value"
          di as text _dup(80) "-"

          *** Fill in table
          forv z = 1 / `n' {
            local y: word `z' of `keyword'
            di as text %-14s abbrev(`"`y'"', 13) _continue
            di as text _skip(3) %8.0g `return(f`i'`z'1)' _continue
            di as text _skip(3) %8.0g `return(f`i'`z'2)' _continue
            di as text _skip(3) %8.0g `return(f`i'`z'3)' _continue
            di as text _skip(3) %8.0g `return(f`i'`z'4)' _continue
            di as text _skip(3) %8.0g `return(f`i'`z'5)' _continue
            di as text _skip(3) %8.0g `return(f`i'`z'6)'
          }
        }
        else {
          if `"`but'"'!="" {

            *** Keyword == F & exclusions == T
            di as result "exclusion(s)" _continue
            di as text _col(21) "Excl."  _col(32) "Excl."    _continue
            di as text _col(42) "Length" _col(51) "Position" _continue
            di as text _col(64) "TF-IDF" _col(74) "p-value"
            di as text _dup(80) "-"

            *** Fill in table
            forv z = 1 / `m' {
              local y: word `z' of `but'
              di as text %-14s abbrev(`"`y'"', 13) _continue
              di as text _skip(3) %8.0g `return(n`i'`z'1)' _continue
              di as text _skip(3) %8.0g `return(n`i'`z'2)' _continue
              di as text _skip(3) %8.0g `return(n`i'`z'3)' _continue
              di as text _skip(3) %8.0g `return(n`i'`z'4)' _continue
              di as text _skip(3) %8.0g `return(n`i'`z'5)' _continue
              di as text _skip(3) %8.0g `return(n`i'`z'6)'
            }
          }
        }

        *** Fill in last row
        di as text _dup(80) "-"
        di as text %-14s abbrev("Total", 13) _continue
        di as text _skip(3) %8.0g `return(f`i'`t'1)' _continue
        di as text _skip(3) %8.0g `return(f`i'`t'2)' _continue
        di as text _skip(3) %8.0g `return(f`i'`t'3)' _continue
        di as text _skip(3) %8.0g `return(f`i'`t'4)' _continue
        di as text _skip(3) %8.0g `return(f`i'`t'5)' _continue
        di as text _skip(3) %8.0g `return(f`i'`t'6)'
        di "{hline 80}"
        di as result "exclusion(s):"
        di as text `"`return(allbut)'"'
      }

      ******************
      *** Tag option ***
      ******************
      if `"`tag'"' != "" {

        *** Tag marks observations that meet the compiled criteria.
        clonevar `tag' = ``i'tot'
      }

      ***********************
      *** Number of finds ***
      ***********************
      if `"`nfinds'"' != "" {

        *** Number of finds creates as many new variables as keywords containing
        *** the number of finds within each observation.
        if `n' != 0 {
          forv z = 1 / `n' {
            local y: word `z' of `keyword'
            clonevar `i'`z'_nfinds = ``i'`z'2'
          }
        }
        else {
          di _newline
          di as result "Number of finds" as text ///
          " variables are only created when keyword is specified."
        }
      }

      *********************
      *** Length option ***
      *********************
      if `"`length'"' != "" {

        *** Length creates a new variable with the word length of observation.
        clonevar `i'_len = ``i'len'
      }

      ***********************
      *** Position option ***
      ***********************
      if `"`position'"' != "" {

        *** Position creates as many new variables as keywords containing the
        *** position the keyword was first found.
        if `n' != 0 {
          forv z = 1 / `n' {
            local y: word `z' of `keyword'
            clonevar `i'`z'_pos = ``i'`z'4'
          }
        }
        else {
          di _newline
          di as result "Avg. position" as text ///
          " variables are only created when keyword is specified."
        }
      }

      *********************
      *** TF-IDF option ***
      *********************
      if `"`tfidf'"' != "" {

        *** TF-IDF creates the tf-idf statistic per observation when keyword is
        *** specified.
        if `n' != 0 {
          forv z = 1 / `n' {
            local y: word `z' of `keyword'
            clonevar `i'`z'_tfidf = ``i'`z'5'
          }
        }
        else {
          di _newline
          di as result "TF-IDF" as text ///
          " statistics are only created when keyword is specified."
        }
      }
    }
  }
end

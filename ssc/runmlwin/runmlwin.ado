*! runmlwin.ado, George Leckie and Chris Charlton, 17Jun2019
program runmlwin, eclass
  if c(stata_version) >= 15 local user user
  if _caller() >= 12 version 12.0, `user'
  if _caller() <= 9 version 9.0, `user'

  display " " // display an empty line between the model command and the model output
  if replay() { // replay the results
    if ("`e(cmd)'" ~= "runmlwin") error 301
    syntax [, Level(cilevel) CFORMAT(string) PFORMAT(string) SFORMAT(string) noHEADer noGRoup noCONTrast noFETable noRETable SD CORrelations OR IRr RRr MOde MEdian Zratio *]
    runmlwin_display, level(`level') cformat(`cformat') pformat(`pformat') sformat(`sformat') `header' `group' `contrast' `fetable' `retable' `sd' `correlations' `or' `irr' `rrr' `mode' `median' `zratio' // display the results
    makecns, displaycns
  }
  else { // fit the model
    syntax anything [if] [in], [Level(cilevel) CFORMAT(string) PFORMAT(string) SFORMAT(string) noHEADer noGRoup noCONTrast noFETable noRETable SD CORrelations OR IRr RRr MOde MEdian Zratio *]
    timer clear 99
    timer on 99
    Estimates `0'
    if "`e(mcmcnofit)'" == "1" { // If the user specifies the nofit option in MCMC then runmlwin needs to exit, but without error
      exit
    }
    timer off 99
    quietly timer list
    ereturn scalar time = r(t99)
    timer clear 99
    runmlwin_display, level(`level') cformat(`cformat') pformat(`pformat') sformat(`sformat') `header' `group' `contrast' `fetable' `retable' `sd' `correlations' `or' `irr' `rrr' `mode' `median' `zratio' // display the results
  }

end

program Estimates, eclass sortpreserve
  if _caller() >= 12 version 12.0
  if _caller() <= 9 version 9.0

  * Locate and record highest level
  local runmlwin_cmdline `0'
  * Separate off options
  local maxlevels 1
  gettoken comma tmpstr : 0, parse(",") bind
  while strpos("`tmpstr'", "level") != 0 {
    local tmpstr = substr("`tmpstr'", strpos("`tmpstr'", "level") + 5, .)
    local lev = substr("`tmpstr'", 1, strpos("`tmpstr'", "(") - 1)
    * Check this really is a level option
    if `=real("`lev'")' != . {
      if `lev' > `maxlevels' {
        local maxlevels `lev'
      }
    }
  }
  if ("`verbose'"~="") display as text "Highest level: `maxlevels'"

  local levargs
  forvalues l = 2/`maxlevels' {
    local levargs LEVEL`l'(string) `levargs'
  }
  #delimit ;
    syntax anything(name=eqlist id="equations" equalok) [if] [in],
      [
      `levargs' // min=2 as first var is id, second var is, e.g., cons
      ]
      LEVEL1(string) // min = 1 as in discrete response models no variables are specified at level 1. Also in multivariate response models there are no covariates with random effects at level 1.
      [
      Weights(string)
      Constraints(numlist >0 integer)
      IGLS RIGLS TOLerance(numlist >0 integer min=1 max=1) MAXIterations(numlist >0 integer min=1 max=1)
      FPSandwich RPSandwich
      INITSPrevious INITSB(namelist min=1 max=1) INITSV(namelist min=1 max=1) INITSModel(namelist min=1 max=1)            // Initial values matrix
      DISCRETE(string)
      MCMC(string)
      SEED(numlist integer min=1 max=1) SIMulate(namelist min=1 max=1)
      MLWINPATH(string) MLWINSCRIPTPATH(string)
      VIEWMacro SAVEMacro(string) SAVEWorksheet(string) SAVEStata(string)
      USEWorksheet(string)
      Level(cilevel) CFORMAT(string) PFORMAT(string) SFORMAT(string) OR IRr RRr SD CORrelations MOde MEdian Zratio noHEADer noGRoup noCONTrast noFETable noRETable
      noDrop FORCESort FORCERecast noMLWIN noPause noVERSIONCHECK BATCh noSORT
      PLUGIN Verbose VIEWFULLMacro SAVEFULLMacro(string) SAVEEQuation(string)
      MLWINSETTINGS(string)
      ] ;
  #delimit cr

  local doublevar 1

  if c(mode) == "batch" local batch = c(mode)

  if "`mlwinpath'" == "" & "`mlwinscriptpath'" ~= "" & "`batch'" ~= "" local mlwinpath `mlwinscriptpath'
  if "`mlwinpath'" == "" & "$MLwiNScript_path" ~= "" & "`batch'" ~= "" local mlwinpath $MLwiNScript_path
  if "`mlwinpath'" == "" & "$MLwiN_path" ~= "" local mlwinpath $MLwiN_path

  // will need to allow for fact that users store MLwiN in different locations. User can put global in profile.do to allow this
  // slightly unfortunate that the installation folder changes with each update from 2.20 to 2.21 etc at user has to keep on changing this to run this command
  if "`mlwin'"~="nomlwin" & "`mlwinpath'" ~= "" {
    capture confirm file "`mlwinpath'"
    if _rc == 601 {
      display as error "`mlwinpath' does not exist." _n
      exit 198
    }
    if "`versioncheck'" ~= "noversioncheck" {
      quietly capture runmlwin_verinfo `mlwinpath'
      if _rc == 198 {
        display as error "`mlwinpath' is not a valid version of MLwiN"
        exit 198
      }
      local majorver `r(ver1)'
      local minorver : display %02.0f `r(ver2)'
      local versionok = 1
      local versionold = 0
      if (`majorver' < 2) | (`majorver' == 2 & `minorver' < 36) local versionok = 0
      if (`majorver' < 3) | (`majorver' == 3 & `minorver' < 03) local versionold = 1
      if `versionok' == 0 {
        display as error "runmlwin assumes MLwiN version 2.36 or higher. You can download the latest version of MLwiN at:" _n "https://www.bristol.ac.uk/cmm/software/mlwin/download/upgrades.html." _n "If you want to ignore this warning and attempt to continue anyway you can use the noversioncheck option"
        exit 198
      }
      if `versionold' == 1 display as error "WARNING: Your version of MLwiN is out of date. You can download the latest version of MLwiN at:" _n "https://www.bristol.ac.uk/cmm/software/mlwin/download/upgrades.html"
    }
    local mlwinversion `majorver'.`minorver'
    if "`mlwinversion'" ~= "..." { // No version information found
      if `mlwinversion' < 3 {
        local doublevar 0
      }
    }
  }

  * Mark the sample (Defines a 0/1 to-use variable that records which observations are to be used in subsequent code)
  marksample touse, novarlist // This gives the full sample which is sent to MLwiN. Not a listwise delete sample.

  * Discrete syntax
  if ("`discrete'"~="") {
    local 0 , `discrete'
    syntax , Distribution(string) [Link(namelist min=1 max=1) DEnominator(varlist numeric) Extra Offset(varname numeric) Proportion(varname) Basecategory(numlist integer min=1 max=1) MQL1 MQL2 PQL1 PQL2]

    local validdistributions normal binomial poisson nbinomial multinomial
    local checkdistribution :list distribution & validdistributions
    if "`checkdistribution'"=="" {
      display as error "Invalid distribution(). Valid distributions are: normal, binomial, poisson, nbinomial, multinomial"
      exit 198
    }

    * Method of linearization
    if ("`mql2'"=="" & "`pql1'"=="" & "`pql2'"=="") local linearization MQL1
    if ("`mql2'"~="") local linearization MQL2
    if ("`pql1'"~="") local linearization PQL1
    if ("`pql2'"~="") local linearization PQL2

    * Check that the link function is correctly specified.
    if "`link'"=="" {
      if ("`distribution'"=="binomial") {
        di as error "You must specify the link() function. Valid link functions for the binomial distribution are: logit, probit and cloglog."
        exit 198
      }
      if ("`distribution'"=="multinomial") {
        di as error "You must specify the link() function. Valid link functions for the multinomial distribution are: mlogit, ologit, oprobit, ocloglog."
        exit 198
      }

      if ("`distribution'"=="poisson" | "`distribution'"=="nbinomial") local link log
    }

    if "`link'" ~= "" {
      local 0 , `link'
      syntax , [Identity Logit Probit Cloglog Mlogit OLogit OProbit OCloglog LOG]

      if ("`distribution'"=="binomial") {
        if  ~inlist("`link'","logit","probit","cloglog") {
          display as error "Invalid link() function. Valid link functions for the binomial distribution are: logit, probit and cloglog." _n
          exit 198
        }
      }
      if ("`distribution'"=="multinomial") {
        if  ~inlist("`link'","mlogit","ologit","oprobit","ocloglog") {
          display as error "Invalid link() function. Valid link functions for the multinomial distribution are: mlogit, ologit, oprobit, ocloglog." _n
          exit 198
        }
      }
      if ("`distribution'"=="poisson") {
        if  ~inlist("`link'","log") {
          display as error "Invalid link() function. Valid link functions for the poisson distribution are: log." _n
          exit 198
        }
      }
      if "`identity'" ~= "" local link identity
      if "`logit'" ~= "" local link logit
      if "`probit'" ~= "" local link probit
      if "`cloglog'" ~= "" local link cloglog
      if "`mlogit'" ~= "" local link mlogit
      if "`ologit'" ~= "" local link ologit
      if "`oprobit'" ~= "" local link oprobit
      if "`ocloglog'" ~= "" local link ocloglog
      if "`log'" ~= "" local link log
    }
  }
  else {
    local link identity
  }

  ******************************************************************************
  * (1A) PARSE RESPONSE AND FIXED PART PREDICTOR LIST
  ******************************************************************************

  tempname o
  .`o' = ._eqlist.new, eqopts(NOConstant) eqargopts(EQ) numdepvars(1) noneedvarlist // For properties of this class see C:\Program Files (x86)\Stata11\ado\base\_eqspec.class
  .`o'.parse `eqlist'

  local numstataeqns = `.`o'.eq count'
  if ("`verbose'"~="") display as text "number of eqns: `numstataeqns'"

  * Derive model type
  if (`numstataeqns'==1 & "`distribution'" ~= "multinomial") local mtype univariate
  if ("`distribution'" == "multinomial") local mtype multinomial
  if (`numstataeqns'>1 &  "`distribution'" ~= "multinomial") local mtype multivariate
  assert"`mtype'"~=""

  local response
  local fp

  if "`mtype'"=="multivariate" {
    // Count the number of responses
    local nummlwineqns = 0
    local valideqns
    forvalues e = 1/`numstataeqns' {
      local 0 , `.`o'.eq options `e''
      syntax [, EQuation(numlist integer)]
      local eq `equation'
      if `:list sizeof eq' == 1 {
        local valideqns `valideqns' `eq'
        local name`eq'       `.`o'.eq name `e''
        local response`eq'   `.`o'.eq depvars `e''
        // Add to complete list
        local response `response' `response`eq''
        local ++nummlwineqns
      }
    }

    * Reserve the first nummlwineqns for separate coefficients

    local numfpbrackets = `nummlwineqns'
    forvalues e = 1/`numstataeqns' {
      local 0 , `.`o'.eq options `e''
      syntax [, EQuation(numlist integer)]
      local eq `equation'
      if "`eq'" == "" {
        display as error "equation option not set for `e'"
        exit 198
      }

      if `:list sizeof eq' == 1 {
        if ("`verbose'"~="") display as text "Separate coefficients"
        local fp`eq'         `.`o'.eq indepvars `e''
        local numfpvars`eq'  :list sizeof fp`e'
        local dups :list dups fp`eq'
        if "`dups'" ~= "" {
          display as error "`dups' are duplicated in the fixed part equation `eq'"
          exit 198
        }

        foreach var of local fp`eq' {
          local fpname`eq' `fpname`eq'' `var'.`eq'
        }

        local pat
        forvalues a = 1/`nummlwineqns' {
          if `:list a in eq' local pat `pat' 1
          else local pat `pat' 0
        }
        local rpat`eq' `pat'
      }
      else {
        if ("`verbose'"~="") display as text "Common coefficients"

        // NOTE: This may give unnecessary errors if the common equation comes before a corresponding separate one
        if "`:list eq - valideqns'" ~= "" {
          display as error "invalid equation(s) specified"
          exit 198
        }

        local ++numfpbrackets
        local fp`numfpbrackets'         `.`o'.eq depvars `e'' `.`o'.eq indepvars `e''
        local numfpvars`numfpbrackets'  :list sizeof fp`e'
        local dups :list dups fp`numfpbrackets'
        if "`dups'" ~= "" {
          display as error "`dups' are duplicated in the fixed part equation `eq'"
          exit 198
        }

        foreach var of local fp`e' {
          local fpname`numfpbrackets' `fpname`numfpbrackets'' `var'.`=subinstr("`eq'", " ", "", .)'
        }
        local pat
        forvalues a = 1/`nummlwineqns' {
          if `:list a in eq' local pat `pat' 1
          else local pat `pat' 0
        }
        local rpat`numfpbrackets' `pat'
      }
    }

    forvalues e = 1/`numfpbrackets' {
      // Add to complete list
      local fp `fp' `fp`e''
    }

    local numfpvars :list sizeof fp
  }

  * Multinomial response
  if "`mtype'"=="multinomial" {
    local response1     `.`o'.eq depvars 1'
    capture tab `response1'
    local nummlwineqns `=`r(r)' - 1'
    local numfpbrackets = `nummlwineqns'
    local valideqns
    forvalues e = 1/`nummlwineqns' {
      local valideqns `valideqns' `e'
    }
    if ("`verbose'"~="") display as text "Valid Equations: `valideqns'"

    forvalues e = 2/`numstataeqns' {
      local 0 , `.`o'.eq options `e''
      syntax [, CONtrast(numlist integer)]
      local cat `contrast'
      if ("`verbose'"~="") display as text "`cat'"

      if "`cat'" == "" {
        display as error "cat option not set for `e'"
        exit 198
      }

      if "`:list cat - valideqns'" ~= "" {
        display as error "Invalid contrast(s) specified. The contrast(s) specified in contrasts() must tally with the contrast(s) in the model, in this case: 1,2,...,`nummlwineqns'" _n
        exit 198
      }
      if `:list sizeof cat' == 1 {
        if ("`verbose'"~="") display as text "Separate coefficients"
        local fp`cat' `.`o'.eq depvars `e'' `.`o'.eq indepvars `e''
        local dups :list dups fp`cat'
        if "`dups'" ~= "" {
          display as error "`dups' are duplicated in the fixed part contrast `contrast'"
          exit 198
        }
      }
      else {
        if ("`verbose'"~="") display as text "Common coefficients"
        local ++numfpbrackets
        local fp`numfpbrackets'         `.`o'.eq depvars `e'' `.`o'.eq indepvars `e''
        local numfpvars`numfpbrackets'  :list sizeof fp`numfpbrackets'
        local fpname`numfpbrackets'
        local dups :list dups fp`numfpbrackets'
        if "`dups'" ~= "" {
          display as error "`dups' are duplicated in the fixed part contrast `contrast'"
          exit 198
        }

        capture levelsof `response1', local(responsecats)

        local catvals
        local respnum = 1
        foreach catn of local responsecats {
          if "`catn'" ~= "`basecategory'" {
            if `:list respnum in cat' local catvals `catvals' `catn'
            local ++respnum
          }
        }

        foreach var of local fp`numfpbrackets' {
          local fpname`numfpbrackets' `fpname`numfpbrackets'' `var'.`=subinstr("`catvals'", " ", "", .)'
        }

        local pat
        forvalues a = 1/`nummlwineqns' {
          if `:list a in cat' local pat `pat' 1
          else local pat `pat' 0
        }
        local rpat`numfpbrackets' `pat'
      }
    }

    // Check there are at least nummlwineqns equations
    capture levelsof `response1', local(responsecats)
    local e = 1
    foreach cat of local responsecats {
      if "`cat'" ~= "`basecategory'" {
        // Add to complete list
        local response`e'   `response1'
        local response `response' `response`e''
        local fp`e' `.`o'.eq indepvars 1' `fp`e''
        local numfpvars`e'  :list sizeof fp`e'
        local dups :list dups fp`e'
        if "`dups'" ~= "" {
          display as error "`dups' are duplicated in the fixed part"
          exit 198
        }
        local fpname`e'
        foreach var of local fp`e' {
          local fpname`e' `fpname`e'' `var'.`cat'
        }

        local pat
        forvalues a = 1/`nummlwineqns' {
          if `:list a in e' local pat `pat' 1
          else local pat `pat' 0
        }
        local rpat`e' `pat'
        local ++e
      }
    }

    forvalues e = 1/`numfpbrackets' {
      // Add to complete list
      local fp `fp' `fp`e''
    }
    local numfpvars :list sizeof fp
  }

  if "`mtype'" == "univariate" {
    local numfpbrackets = `numstataeqns'
    local nummlwineqns = `numstataeqns'
    * Parse each equation
    forvalues e = 1/`numfpbrackets' {
      local name`e'       `.`o'.eq name `e''
      local response`e'   `.`o'.eq depvars `e''

      if _caller() >= 11 {
        local 0 `.`o'.eq indepvars `e''
        syntax varlist(fv)
        fvexpand `varlist'
        local fpname`e' `r(varlist)'
        fvrevar `r(varlist)'
        local fp`e' `r(varlist)'
        local newvars :list fp`e' - varlist
        capture _rmcoll `fp`e'', noconstant
        local fp`e' `r(varlist)'
        if "`newvars'" ~= "" {
          quietly compress `newvars'
        }
        local i = 1
        foreach x in `fp`e'' {
          local xname :word `i' of `fpname`e''
          if substr("`x'", 1, 2) == "o." {
            local fp`e' : list fp`e' - x
            local fpname`e' : list fpname`e' - xname
            display as text "note: `xname' omitted because of collinearity"
          }
          else {
            if "`:type `x''" == "double" & `:list x in newvars' & `doublevar' == 0{
              quietly recast float `x', force
              display as error "`xname' has more precision that MLwiN can handle, forcing to float"
            }
            local ++i
          }
        }
      }
      else {
        local fpname`e' `.`o'.eq indepvars `e''
        local fp`e' `.`o'.eq indepvars `e''
      }

      local dups :list dups fp`e'
      if "`dups'" ~= "" {
        display as error "`dups' are duplicated in the fixed part"
        exit 198
      }

      local numfpvars`e'  :list sizeof fp`e'

      // Add to complete list
      local response `response' `response`e''
      local fp `fp' `fp`e''
    }
    local numfpvars :list sizeof fp
  }

  local fpname
  forvalues e = 1/`numfpbrackets' {
    local fpname `fpname' `fpname`e''
  }

  forvalues e = 1/`numfpbrackets' {
    if ("`=word("`distribution'", `e')'"=="binomial") {
      if ("`extra'" ~= "") {
        capture assert (`denominator' == 1) & (`response' == 1 | `response' == 0)
        if ~_rc {
          display as error "Extra option applies to binomial responses, not binary"
          exit 198
        }
      }
    }
  }


  if ("`verbose'"~="") {
    * Check that the syntax has been parsed properly
    display _n as result "MODEL " as text "Num. of responses:  `numfpbrackets' " as text "Model type:         `mtype'" _n

    forvalues e = 1/`numfpbrackets' {
      display as result "FP EQUATION `e' " as text "Name: `name`e'', Response: `response`e'', Predictors: `fp`e'', Num. of predictors: `numfpvars`e'', Options: `opts`e''" _n
    }
  }

  ******************************************************************************
  * (1B) PARSE LEVELS
  ******************************************************************************

  * Level parsing (Level X identifier, random part covariates and options)
  local residualsall
  local factorson = 0

  * Total number of random part variables (not total number of random part parameters)
  local numrpvars = 0
  local emptylevels
  forvalues l = `maxlevels'(-1)1 {
    if "`level`l''"~="" {
      gettoken lev`l'id 0 : level`l', parse(":")        // get everything before colon and put in lev`l'id, put rest of string in 0
      if `:list sizeof lev`l'id' > 1 {            // if you have specified more than one variable before the colon then issue an error message
        display as error "Only one level `l' ID is allowed; a colon should appear after the level `l' ID and before the variable list" _n
        exit 198
      }
      gettoken colon rp`l': 0, parse(":")           // Put : in colon and the variable list and any options in rp`l'

      if strpos("`rp`l''", ",") > 0 {             // If there is a comma is the variable list and option list (i.e. options have been specified after a comma as expected) then ...
        gettoken rp`l' options : rp`l', parse(",") bind   // put the true var list in rp`l' and put the comma and the options in options
        if "`rp`l''" == "," local rp`l' ""          // No RP variables specified
        else gettoken comma options: options, parse(",")  // Put , in comma and the true option list in options
      }
      local 0 `rp`l'', lev`l'id(`lev`l'id') `options'     // Define new local called 0 which has contents in "". We can prob remove `varlist' but need to check.

      if "`l'" ~= "1" {             // If level is level 2,3,4,5,...
        // syntax interpret whatever is in `0'
        #delimit ;
        syntax [anything(name=rpeqlist id="equations" equalok)],
        [LEV`l'id(varname)]
        [Diagonal]
        [ELements(namelist min=1 max=1)]
        [DESIGN(string)]
        [RESET(namelist min=1 max=1)]
        [Residuals(string)]
        [Weightvar(varname)]
        [MMIds(varlist)]
        [MMWeights(varlist)]
        [CARIds(varlist)]
        [CARWeights(varlist)]
        [PAREXpansion]
        [FLInits(string)]
        [FLConstraints(string)]
        [FVInits(string)]
        [FVConstraints(string)]
        [FScores(string)];
        #delimit cr
      }
      else {                  // If level is level 1
        #delimit ;
        syntax [anything(name=rpeqlist id="equations" equalok)],
        LEV`l'id(varname)
        [Diagonal]
        [ELements(namelist min=1 max=1)]
        [DESIGN(string)]
        [RESET(namelist min=1 max=1)]
        [Residuals(string)]
        [Weightvar(varname)]
        [MMIds(varlist)]
        [MMWeights(varlist)]
        [CARIds(varlist)]
        [CARWeights(varlist)]
        [FLInits(string)]
        [FLConstraints(string)]
        [FVInits(string)]
        [FVConstraints(string)]
        [FScores(string)];
        #delimit cr
      }

      * Parse the random part equations and variable specification
      tempname o
      .`o' = ._eqlist.new, eqopts(NOConstant) eqargopts(EQ) numdepvars(1) noneedvarlist       // For properties of this class see C:\Program Files (x86)\Stata11\ado\base\_eqspec.class
      .`o'.parse `rpeqlist'           // capture because in some models we may choose to include no predictors in the random part at a particular level (e.g. a bivariate normal response model fitted as a univariate response model has no random part at level 1)
      local numstataeqns`l' = `.`o'.eq count'
      local numrpbrackets`l' = `nummlwineqns'

      if ("`verbose'"~="") display as text "Valid Equations: `valideqns'"

      forvalues e = 1/`numstataeqns`l'' {         // loop over the equations
        local 0 , `.`o'.eq options `e''
        syntax [, EQuation(numlist integer) CONtrast(numlist integer) *]
        if ("`contrast'" ~= "") local eq `contrast'
        else local eq `equation'
        if ("`verbose'"~="") display as text "`eq'"

        if "`mtype'" == "univariate" {
          local rp`l'_`e'     `.`o'.eq depvars `e'' `.`o'.eq indepvars `e''
          local rp`l'name`e' `rp`l'_`e''
          local dups :list dups rp`l'_`e'
          if "`dups'" ~= "" {
            display as error "`dups' are duplicated in the random part level `l' equation `e'"
            exit 198
          }
        }
        else {
          if "`eq'" == "" {
            if `e' == 1 {
              forvalues a = 1/`nummlwineqns' {
                local name`a'       `.`o'.eq name `e''
                local rp`l'_`a' `.`o'.eq depvars `e'' `.`o'.eq indepvars `e''
                local rpeq`l'_`a'   `a'
                local dups :list dups rp`l'_`a'
                if "`dups'" ~= "" {
                  display as error "`dups' are duplicated in the random part level `l' contrast `a'"
                  exit 198
                }
              }
            }
            else {
              display as error "equation option not set for `e'"
              exit 198
            }
          }
          else {
            if "`:list eq - valideqns'" ~= "" {
              display as error "invalid contrast(s) or equation(s) specified"
              exit 198
            }

            if `:list sizeof eq' == 1 {
              // Separate
              local name`eq'       `name`eq'' `.`o'.eq name `e''
              local rp`l'_`eq'     `rp`l'_`eq'' `.`o'.eq depvars `e'' `.`o'.eq indepvars `e''
              local rpeq`l'_`eq'   `eq'
              local dups :list dups rp`l'_`eq'
              if "`dups'" ~= "" {
                display as error "`dups' are duplicated in the random part level `l' equation `eq'"
                exit 198
              }
            }
            else {
              // Common
              local ++numrpbrackets`l'
              local name`numrpbrackets`l''       `.`o'.eq name `e''
              local rp`l'_`numrpbrackets`l''     `.`o'.eq depvars `e'' `.`o'.eq indepvars `e''
              local numrpvars`numrpbrackets`l''  :list sizeof rp`l'_`numrpbrackets`l''
              local rpeq`l'_`numrpbrackets`l''   `eq'
              local rp`l'name`numrpbrackets`l''

              local dups :list dups rp`l'_`numrpbrackets`l''
              if "`dups'" ~= "" {
                display as error "`dups' are duplicated in the random part level `l' equation `eq'"
                exit 198
              }

              if "`mtype'" == "multivariate" {
                foreach var of local rp`l'_`numrpbrackets`l''   {
                  local rp`l'name`numrpbrackets`l''  `rp`l'name`numrpbrackets`l'' ' `var'.`=subinstr("`eq'", " ", "", .)'
                }
              }

              if "`mtype'" == "multinomial" {
                capture levelsof `response1', local(responsecats)
                local eqvals
                local respnum = 1
                foreach cat of local responsecats {
                  if "`cat'" ~= "`basecategory'" {
                    if `:list respnum in eq' local eqvals `eqvals' `cat'
                    local ++respnum
                  }
                }
                foreach var of local rp`l'_`numrpbrackets`l''   {
                  local rp`l'name`numrpbrackets`l''  `rp`l'name`numrpbrackets`l'' ' `var'.`=subinstr("`eqvals'", " ", "", .)'
                }
              }

              local pat
              forvalues a = 1/`nummlwineqns' {
                if `:list a in eq' local pat `pat' 1
                else local pat `pat' 0
              }
              local rppat`l'_`numrpbrackets`l'' `pat'
            }
          }
        }
      }

      if "`mtype'" == "multivariate" {
        forvalues eq = 1/`nummlwineqns' {
          if `l' == 1 & "`discrete'" ~= "" & "`=word("`distribution'", `eq')'"=="binomial" local rp`l'_`eq' bcons //_`eq'
          local numrpvars`eq'  :list sizeof rp`l'_`eq'
          local rp`l'name`eq'
          foreach var of local rp`l'_`eq'  {
            local rp`l'name`eq' `rp`l'name`eq'' `var'.`=subinstr("`eq'", " ", "", .)'
          }
        }
      }

      if "`mtype'" == "multinomial" {
        capture levelsof `response1', local(responsecats)
        local eq = 1
        foreach cat of local responsecats {
          if "`cat'" ~= "`basecategory'" {
            local numrpvars`eq'  :list sizeof rp`l'_`eq'
            local rp`l'name`eq'
            foreach var of local rp`l'_`eq'  {
              local rp`l'name`eq' `rp`l'name`eq'' `var'.`=subinstr("`cat'", " ", "", .)'
            }
            local ++eq
          }
        }
      }

      if "`mtype'" == "multivariate" || "`mtype'" == "multinomial" {
        forvalues eq = 1/`nummlwineqns' {
          local pat
          forvalues a = 1/`nummlwineqns' {
            if `:list a in eq' local pat `pat' 1
            else local pat `pat' 0
          }
          local rppat`l'_`eq' `pat'
        }
      }

      local rp`l'
      forvalues e = 1/`numrpbrackets`l'' {          // loop over the equations
        local rp`l' `rp`l'' `rp`l'_`e''
        if "`mtype'" == "univariate" local rp`l'name`e' `rp`l'_`e''
      }

  //    * Add in extra binomial variation parameters etc
  //    if `l' == 1 & "`discrete'" ~= "" & "`mtype'" ~= "multivariate"{
  //      if "`distribution'" == "multinomial" & "`link'"=="mlogit" local rp`l'name1 `rp`l'name1' P -P
  //      //forvalues a = 1/`nummlwineqns' {
  //      //  if "`=word("`distribution'", `a')'" == "binomial" local rp`l'name`a' `rp`l'name`a'' bcons.`a'
  //      //  if "`=word("`distribution'", `a')'" == "poisson" local rp`l'name`a' `rp`l'name`a'' bcons.`a'
  //      //  if "`=word("`distribution'", `a')'" == "nbinomial" local rp`l'name`a' `rp`l'name`a'' bcons.`a' bcons2.`a'
  //      //}
  //      //if "`distribution'" == "multinomial" & "`link'"=="mlogit" local rp`l'name1 `rp`l'name1' P -P bcons.1
  //      //if "`distribution'" == "multinomial" & ("`link'"=="ologit" | "`link'"=="oprobit" | "`link'"=="ocloglog") local rp`l'name1 `rp`l'name1' bcons.1
  //    }

      forvalues e = 1/`numrpbrackets`l'' {          // loop over the equations
        * Ensure random part names are in the correct order
        local origrp`l'name `origrp`l'name ' `rp`l'name`e''
        local tmpname `rp`l'name`e''
        local rp`l'name `rp`l'name' `:list fpname & tmpname'
        local tmpname `:list tmpname - fpname'

        forvalues lev = `maxlevels'(-1)`=`e'+1' {
          local rp`l'name `rp`l'name' `:list rp`lev'name & tmpname'
          local tmpname `:list tmpname - rp`lev'name'
        }

        local rp`l'name `rp`l'name' `tmpname'
      }

      // NOTE: The following lines probably aren't needed
      if "`numfpbrackets'" == "1"{
        local rp`l'_1 `.`o'.eq depvars 1' `.`o'.eq indepvars 1'
        local rp`l' `rp`l'_1'
      }

      if ("`verbose'"~="") {
        display as result "LEVEL `l'"
        forvalues e = 1/`numfpbrackets' {
          display as result "RP EQUATION `e', " as text "Name: `name`e'', " as text "Predictors: `rp`l'_`e'', " as text "Num. of predictors: `numrpvars`e'', " as text "Options: `opts`e''" _n
        }
      }
      local numrp`l'vars :list sizeof rp`l'
      local numrpvars = `numrpvars' + `numrp`l'vars'

      if `numrp`l'vars' == 0 {
        if "`diagonal'"~="" | "`elements'"~="" | ("`weightvar'"~="" & `l' > 1) | "`mmids'"~="" | "`mmweights'"~="" | "`carids'"~="" | "`carweights'"~="" || "`parexpansion'"~="" {
          display as error "Cannot specify random part options at level `l' unless random part predictor variables are specified"
          exit 198
        }
        if "`reset'"~="" | "`residuals'"~="" {
          if ~(`l' == 1 & inlist("`distribution`e''","binomial","poisson","nbinomial")) {
            display as error "Cannot specify reset or residual options at level `l', as no random part predictor variables are specified"
            exit 198
          }
        }
        if `l' == 1 & "`mtype'" == "univariate" & "`discrete'" == "" {
          display as error "WARNING: In univariate continuous models, one or more variables should generally be included in the random part at level 1"
        }
      }

      * Residuals option
      local numresi`l' 0
      if ("`residuals'"~="") {
        local 0 `residuals'
        syntax name(name = residname) [, VARiances STANDardised LEVerage INFluence DELetion SAMPling REFlated noRECODE RPAdjust noAdjust SAVEChains(string)]
        if "`residname'" ~= "" {          // If a variable stub has been given for the residual options, then...
          if "`variances'" ~= "" & ("`leverage'" ~= "" | "`influence'" ~= "" | "`deletion'" ~= ""){
            display as error "variances option cannot be used with leverage, deletion or influence"
            exit 198
          }
          if "`:list residname & residualsall'"~="" {
            display as error "The new residual variables stub `residname' is defined at more than one level. Specify unique stubs at each level." _n
            exit 198
          }
          local resivars`l' `rp`l''
          if `l' == 1 & "`discrete'" ~= "" { // Note, this does not currently handle multinomial
            if "`mtype'"=="multinomial" {
              if "`link'"=="mlogit" local resivars`l' bcons.1 bcons.2
              else local resivars`l' bcons.1
            }
            else {
              forvalues a = 1/`nummlwineqns' {
                local resivars`l' `resivars`l'' bcons.`a'
                if "`=word("`distribution'", `a')'" == "nbinomial" local resivars`l' `resivars`l'' bcons2.`a'
              }
            }
          }
          local numresi`l' :list sizeof resivars`l'

          forvalues q = 0/`=`:list sizeof resivars`l''-1' {
            capture confirm variable `residname'`q', exact
            if !_rc {
              display as error "The new residual variables stub `residname' is attempting to generate a new variable `residname'`q', but this variable already exists." _n
              exit 198
            }
            capture confirm variable `residname'`q'se, exact
            if !_rc {
              display as error "The new residual variables stub `residname' is attempting to generate a new variable `residname'`q'se, but this variable already exists." _n
              exit 198
            }
          }
          if "`rpadjust'" ~= "" & "`adjust'" == "noadjust" {
            display as error "Cannot specify both RPAdjust and NOAjust at level `l'"
            exit 198
          }
          local residuals`l' `residname'
          local residstd`l' `standardised'
          local residlever`l' `leverage'
          local residinfl`l' `influence'
          local residdel`l' `deletion'
          local residsamp`l' `sampling'
          local residref`l' `reflated'
          local residvar`l' `variances'
          local residrpadj`l' `rpadjust'
          local residnoadj`l' `adjust'
          local residrecode`l' `recode'
          local residualsall :list residualsall | residname
        }
        local saveresiduals`l' `savechains'
      }

      if "`flinits'" ~= "" | "`flconstraints'" ~= "" | "" ~= "`fvinits'" | "`fvconstraints'" ~= "" | "`fscores'" ~= "" local factorson = 1

      if `factorson' == 1 {
        if "`mtype'" ~= "multivariate" | "`mcmc'" == "" | "`diagonal'" == "" {
          display as error "Factors can only be specified for multivariate MCMC models with a diagonal covariance matrix"
          exit 198
        }
        if "`flinits'" == "" | "`flconstraints'" == "" | "" == "`fvinits'" | "`fvconstraints'" == "" {
          display as error "flinits, flconstraints, fvinits and fvconstraints must all be specified for factor models"
          exit 198
        }
        if rowsof(`flinits') ~= `:list sizeof rp`l'' | rowsof(`flconstraints') ~= `:list sizeof rp`l'' | colsof(`flinits') ~= colsof(`flconstraints') | colsof(`flinits') ~= rowsof(`fvinits') | colsof(`flinits') ~= colsof(`fvinits') | colsof(`flinits') ~= rowsof(`fvconstraints') | colsof(`flinits') ~= colsof(`fvconstraints') {
          display as error "Factor matrices are wrong dimensions"
          exit 198
        }
        tempname fvtempmat
        capture mat `fvtempmat' = cholesky(`fvinits')
        if c(rc) == 506 {
          display as error "Factor variance matrix is not positive definite"
          exit 198
        }
        local flinit`l' `flinits'
        local flconstraint`l' `flconstraints'
        local fvinit`l' `fvinits'
        local fvconstraint`l' `fvconstraints'
        local fscores`l' `fscores'
      }

      if ("`weightvar'"~="") {
        if "`mtype'" ~= "univariate" | "`mcmc'" ~= "" {
          display as error "Weights are only valid for univariate models estimated using (R)IGLS"
          exit 198
        }
        local weight`l' `weightvar'
      }

      if ("`mmids'" ~= "" & "`carids'" ~= "") | ("`mmweights'" ~= "" & "`carweights'" ~= "") | ("`mmids'" ~= "" & "`carweights'" ~= "") | ("`mmweights'" ~= "" & "`carwids'" ~= ""){
        display as error "MM and CAR cannot both be specified at the same level"
        exit 198
      }

      local car
      if "`carids'" ~= "" | "`carweights'" ~= "" {
        local mmids `carids'
        local mmweights `carweights'
        local car car
      }

      if ("`mmids'" ~= "") {
        //if "`mcmc'" == "" | "`mtype'" ~= "univariate" {
        //  display as error "Multiple membership is only allowed in Univariate MCMC models"
        //  exit 198
        //}
        //else
        local mmids`l' `mmids'
      }

      if ("`mmweights'" ~= "") {
        if "`mcmc'" == "" | "`mmids`l''" == ""{
          display as error "Multiple membership weights are only allowed in MCMC models where multiple membership has been defined"
          exit 198
        }
        else {
          local mmweights`l' `mmweights'
          // This is checked later
          //if :list sizeof mmids ~= :list sizeof mmweights {
          //  display as error "Number of multiple membership weight variables does not match number of ID variables"
          //  exit 198
          //}
        }
      }

      if "`car'" ~= "" {
        if "`mmids'" == "" | "`mmweights'" == "" {
          display as error "CAR is only valid for multiple membership models"
          exit 198
        }
        else local car`l' `car'
      }

      if "`parexpansion'" ~= "" {
        if "`mcmc'" == "" {
          display as error "Parameter expansion is only valid for MCMC estimation"
          exit 198
        }
        local parexpansion`l' `parexpansion'
        local parexpansion
      }

      * Diagonal option
      if ("`diagonal'"~="" & "`elements'"~="") {            // If an on/off vector has been given for the elements options, then...
        display as error "Specify either diagonal or elements(), but not both options." _n
        exit 198
      }
      if ("`diagonal'"~="") local diagonal`l' `diagonal' // If an on/off vector has been given for the elements options, then...

      * Elements option
      if ("`elements'"~="") local elements`l' `elements' // If an on/off vector has been given for the elements options, then...

      * Reset option
      if ("`reset'"~="") {              // If reset has been specified, then ...
        local 0 , `reset'
        syntax , [ALL VARiances NONE]
        if "`all'" == "" & "`variances'" == "" & "`none'" == "" {
          display as error "The reset() option must be one of: all, variances, none." _n
          exit 198
        }
        if "`all'" ~= "" local reset`l' all
        if "`variances'" ~= "" local reset`l' variances
        if "`none'" ~= "" local reset`l' none
      }

      * Design option
      if ("`design'"~="") {
        local 0 `design'
        syntax using [, FILE(string) Keep(string)]
        preserve
          use "`using'", clear
          if "`keep'"~="" {
            keep `keep'
            order `keep' // note that we sort the variables by the order that they are specified in the keep() option.
          }
          unab vars: *

          if "`file'"=="" tempfile file
          saveold "`file'", nolabel replace
        restore
        local filedesign`l' `file'
        local design`l' `vars'
        local numdesign`l' :list sizeof vars
        if ("`verbose'"~="") display as text "Number of DESIGN vectors at level `l': `numdesign`l'' (`design`l'')"
      }
      else local numdesign`l' = 0

      if `l' > 1 & `numrp`l'vars' == 0 local emptylevels `emptylevels' `l'
    }
    else {
      local numrp`l'vars 0
      local emptylevels `emptylevels' `l'
    }
  }

  if ("`linearization'" == "MQL2" | "`linearization'" == "PQL1" | "`linearization'" == "PQL2" ) & "`emptylevels'" ~= "" {
    display as error "Only MQL1 can be specified if there are empty higher levels"
    exit 198
  }

  * Generate an indicator for whether any design matrices have been specified at any levels
  forvalues l = 1/`maxlevels' {
    if ("`design`l''"~="")  local anydesign yes
  }

  * Total number of variables (not total number of parameters) (not total number of columns used in MLwiN either as we have denom columns for example)
  local numvars = `numfpvars' + `numrpvars'

  * Level order
  local levelorder
  forvalues l = 1/`maxlevels' {
    if "`lev`l'id'"~="" local levelorder `lev`l'id' `levelorder'
  }

  * Number of levels
  local numlevels :list sizeof levelorder

  ******************************************************************************
  * (1C) PARSE GENERAL OPTIONS
  ******************************************************************************
  local hasweights = 0
  forvalues l = 1/`maxlevels' {
    if "`weight`l''" ~= "" local hasweights = 1
  }
  if "`weights'" ~= "" {
    if `hasweights' == 0 {
      display as error "weights options specified but no weights defined"
      exit 198
    }
    local 0, `weights'
    syntax , [noStandardisation noFPSandwich noRPSandwich]
    if "`standardisation'" == "" local weighttype standardised
    else local weighttype raw
  }

  // Default weight type is standardised
  if "`weighttype'" == "" & `hasweights' == 1 local weighttype standardised

  // Is this check correct?
  if "`weighttype'" == "standardised" {
    forvalues l = 2/`maxlevels' {
      if "`weight`l''" ~= "" & "`weight`=`l'-1''" == ""{
        display as error "Standardised weights have been requested for level `l', this requires non-equal standardised weights for all levels below `l'. Please define weights for these levels"
        exit 198
      }
    }
  }

  * Assert that tolerance is integer
  local iglstolerance `tolerance'

  * If special option plugin  is specified then do macro quietly (i.e. without pauses)
  if ("`plugin'"~="") local pause no

  * If savemacro option is specified then check the file extension
  if ("`savemacro'"~="") {
    local 0 `savemacro'
    syntax anything(name=savemacro), [REPLACE]
    if "`replace'"=="" confirm new file "`savemacro'"
  }

  * If savefullmacro option is specified then check the file extension
  if ("`savefullmacro'"~="") {
    local 0 `savefullmacro'
    syntax anything(name=savefullmacro), [REPLACE]
    if "`replace'"=="" confirm new file "`savefullmacro'"
  }

  if ("`saveequation'"~="") {
    if ("`plugin'" ~= "") {
      display as error "Cannot capture equation image in plugin mode"
      exit 198
    }
    local 0 `saveequation'
    syntax anything(name=saveequation), [REPLACE]
    if "`replace'"=="" confirm new file "`saveequation'"
  }

  * If saveworksheet option is specified then check the file extension
  if ("`saveworksheet'"~="") {
    local 0 `saveworksheet'
    syntax anything(name=saveworksheet), [REPLACE]
    if length("`saveworksheet'") < 5 local saveworksheet `saveworksheet'.wsz
    else if lower(substr("`saveworksheet'", -4, .)) ~= ".wsz" local saveworksheet `saveworksheet'.wsz
    if "`replace'"=="" confirm new file "`saveworksheet'"
  }

  if "`initsmodel'" ~= "" {
    quietly estimates dir
    local savedmodels `r(names)'
    if `:list initsmodel in savedmodels' {
      tempname currentmodel
      // NOTE: capture in case there is no current model (is there a better check?)
      quietly capture estimates store `currentmodel', nocopy
      quietly estimates restore `initsmodel'
      tempname matPREVIOUS_b
      matrix `matPREVIOUS_b' = e(b)
      local inits `matPREVIOUS_b'
      tempname matPREVIOUS_V
      matrix `matPREVIOUS_V' = e(V)
      local initsV `matPREVIOUS_V'
      quietly capture estimates restore `currentmodel'
      quietly capture estimates drop `currentmodel'
    }
    else {
      display as error "saved model `initsmodel' not found"
      exit 198
    }
  }

  if "`initsv'"~="" & "`initsb'" == "" {
    display as error "initsb must be specified if initsv is used"
    exit 198
  }

  * Parse initial values
  if ("`initsprevious'"~="" & "`initsb'"~="")  {
    display as error "Specify either initsprevious or initsb() and/or initsv(), but not both options." _n
    exit 198
  }

  if ("`initsprevious'"~="") {
    tempname matPREVIOUS_b
    matrix `matPREVIOUS_b' = e(b)
    local inits `matPREVIOUS_b'
    tempname matPREVIOUS_V
    matrix `matPREVIOUS_V' = e(V)
    local initsV `matPREVIOUS_V'
  }

  if ("`initsb'"~="")  {
    local inits `initsb'
    if rowsof(`inits')~=1 {
      display as error "The initsb() option expects a row vector as the first argument." _n
      exit 198
    }
  }

  if ("`initsv'"~="") local initsV `initsv'

  if ("`seed'"~="") local standardseed = `seed'

  if "`mlwinsettings'" ~= "" {
    local 0, `mlwinsettings'
    syntax , [Size(numlist >0 integer min=1 max=1) Levels(numlist >=3 integer min=1 max=1) Columns(numlist >=1500 integer min=1 max=1) Variables(numlist >=1 integer min=1 max=1) TEMPMAT OPTIMAT RNGVersion(integer 10)]
    if "`verbose'" ~= "" display "Worksheet size (KCells): `size', Maximum number of levels: `levels', Number of columns: `columns', Maximum number of modelled variables: `variables'"

    if "`levels'" ~= "" local toplevel `levels'
    if "`columns'" ~= "" local numwscolumns `columns'
    if "`variables'" ~= "" local maxexpl `variables'
    if "`size'" ~= "" local worksize `size'
  }

  ******************************************************************************
  * (1D) PARSE DISCRETE SUBOPTIONS
  ******************************************************************************
  * Response type
  if ("`discrete'"=="") {
    local distribution
    forvalues e = 1/`nummlwineqns' {
      local distribution `distribution' normal
    }
  }
  else {
    if ("`nummlwineqns'" == "1" & "`distribution'" == "normal") {
       display as error "The discrete option is unnecessary for univariate normal models"
       exit 198
    }
  }

  * Discrete moved higher from here
  if ("`verbose'"~="") {
    if ("`mtype'" == "multinomial") {
      // NOTE: This assumes that the values coming out of levelsof is in the same order as the value labels, is this always true?
      capture levelsof `response1', local(responsecats)
      display as text "Response names:"
      local count = 1
      foreach cat of local responsecats {
        if "`count'" ~= "`basecategory'" display as text "`:label (`response1') `cat''"
        local ++count
      }
    }

    if ("`mtype'" == "multivariate") {
      display as text "Response names:"
      forvalues a = 1/`nummlwineqns' {
        display as text "`response`a''"
      }
    }
  }

  if ("`discrete'"~="") {
    local tmpbin = "binomial"
    * Check that the denom function is correctly specified.
    if "`denominator'"=="" {
      if `:list tmpbin in distribution' {
        di as error "You must specify the denominator() function for the binomial distribution."
        exit 198
      }
      if inlist("`distribution'","multinomial") {
        di as error "You must specify the denominator() function for the multinomial distribution."
        exit 198
      }
    }
    else {
      if ~`:list tmpbin in distribution' & "`distribution'" ~= "multinomial" {
        display as error "Remove denominator(). denominator() is only valid for the binomial and multinomial distributions." _n
        exit 198
      }
    }

    * Check that the offset function is correctly specified.
    if "`offset'" ~= "" {
      local tmppois "poisson nbinomial"
      if "`:list tmppois & distribution'" == "" {
        display as error "Remove offset(). offset() is only valid for the Poisson or negative binomial distribution." _n
        exit 198
      }
    }
  }

  if ("`mtype'" ~= "multinomial") {
    if (`:list sizeof distribution' != `nummlwineqns') {
      display as error "Incorrect number of distributions specified." _n
      exit 198
    }

    local tmpbin = "binomial"
    if ((`:list tmpbin in distribution') & (`:list sizeof denominator' != `nummlwineqns')) {
      display as error "Incorrect number of denominators specified." _n
      exit 198
    }

    local e = 0
    foreach var of local distribution {
      local ++e
      local distribution`e' `var'
    }

    local e = 0
    foreach var of local denominator {
      local ++e
      local denominator`e' `var'
    }

    * Assert that the response is well behaved
    forvalues e = 1/`nummlwineqns' {
      if  ("`distribution`e''"=="binomial") {
        capture assert (`response`e''>=0 & `response`e''<=1) | `response`e''>=.
        if _rc~=0 {
          di as error "Binary response variables must take the value 0 or 1. If you have a proportion response variable, then it must lie between 0 and 1."
          exit 198
        }
      }

      if  ("`distribution`e''"=="poisson") {
        capture assert `response`e''>=0
        if _rc~=0 {
          di as error "The count response variable must be 0 or a positive integer."
          exit 198
        }
      }

      if  ("`distribution`e''"=="nbinomial") {
        capture assert `response`e''>=0
        if _rc~=0 {
          di as error "The count response variable must be 0 or a positive integer."
          exit 198
        }
      }

      if  ~inlist("`distribution`e''","normal","binomial","poisson","nbinomial") {
        display as error "The `distribution`e'' response distribution is not recognised by MLwiN." _n
        exit 198
      }
    }

    * Check that no level 1 variables have been specified
    if inlist("`distribution`e''","binomial","poisson","nbinomial") & "`rp1'"~="" {
      display as error "You cannot make covariates random at level 1 when using the `distribution`e'' response distribution." _n
      exit 198
    }

    * Check that the denominator has been specified
    if inlist("`distribution`e''","binomial") & "`denominator`e''"=="" {
      display as error "You must specify a denominator variable when using the `distribution`e'' response distribution. See the denom() option." _n
      exit 198
    }
  }
  else {
    qui inspect `response1'
    if r(N_unique)<=1 {
      display as error "In multinomial response models, the response must have two or more categories" _n
      exit 198
    }

    * Check that no level 1 variables have been specified
    if "`rp1'" ~= "" {
      display as error "You cannot make covariates random at level 1 when using the multinomial response distribution." _n
      exit 198
    }

    * Check that the denominator has been specified
    if "`denominator'"=="" {
      display as error "You must specify a denominator variable when using the multinomial response distribution. See the denom() option." _n
      exit 198
    }

    * Check that the base category has been specified
    if "`basecategory'"=="" {
      display as error "You must specify a (numeric) base category when using the multinomial response distribution. See the basecategory() option." _n
      exit 198
    }

    * Check that a valid base category has been specified for models with unordered response variables
    qui levelsof `response1', local(responsevalues)
    local responsevalues = subinstr("`responsevalues'"," ",",",.)
    if ~inlist(`basecategory',`responsevalues') {
      display as error "The base category `basecategory' does not exist for the response variable `response1'. See the basecategory() option." _n
      exit 198
    }
  }

  ******************************************************************************
  * (1E) PARSE MCMC SUBOPTIONS
  ******************************************************************************

  * Estimation model
  if ("`mcmc'"=="" & "`rigls'"=="") local emode IGLS
  if ("`mcmc'"=="" & "`rigls'"~="") local emode RIGLS
  if ("`mcmc'"~="") local emode MCMC


  if ("`mcmc'"~="") {
    if "`initsprevious'"=="" & "`initsb'"=="" & "`initsmodel'" == "" {
      display as error "When fitting models using MCMC, initial values must be specified; see initsprevious, initsmodel and initsb()/initsv() options."
      exit 198
    }
  * The syntax for the burn-in is as follows:
  *
  * MCMC 0
  *   burn in for <value 1> iterations,
  *   use adaptation method <value 2>,
  *   scale factor <value 3>,
  *   %acceptance <value 4>,
  *   tolerance <value 5>
  *   {residual starting values in C1,
  *   s.e. residual starting values) in C2}
  *   {priors in C3}
  *   fixed effect method <value 6>
  *   residual method <value 7>
  *   level 1 variance method <value 8>
  *   other levels variance method <value 9>
  *   default prior <value 10>
  *   model type <value 11>.

    local 0 , `mcmc'

    #delimit ;
    syntax , [
      ON
      LOGformulation
      CC
      MSUBScripts
      CORResiduals(namelist min=1 max=1)
      ME(string)
      PRIORMatrix(namelist min=1 max=1)
      RPPriors(string)
      SAVEWinbugs(string)
      Burnin(integer 500)
      Chain(integer 5000)
      Thinning(integer 1)
      Refresh(integer 50)
      SCALE(real 5.8)
      noADAPTation
      ACCEPTance(real 0.5)
      TOLerance(real 0.1)
      CYCLES(integer 1)
      FEMethod(namelist min=1 max=1)
      REMethod(namelist min=1 max=1)
      LEVELONEVARMETHOD(namelist min=1 max=1)
      HIGHERLEVELSVARMETHOD(namelist min=1 max=1)
      SMCMC
      SMVN
      ORTHogonal
      HCentring(numlist min=1 max=1 >0 integer)
      CARCentre
      SEED(integer 1)
      noDIAGnostics
      SAVEChains(string)
      SIMRESiduals /* Undocumented option. The default is to calculate starting values for higher level residuals using the residuals window. This is a potential alternative which simulates residual starting values from the MVN residual differences (i.e. a drawnorm). */
      IMPUTEIterations(numlist >0 integer ascending)
      IMPUTESummaries
      ];
      #delimit cr

    if `thinning' > 0.5*`chain' {
          display as error "Thinning must be less than half the chain length."
          exit 198
    }

    if ("`fpsandwich'"=="fpsandwich" | ("`weighttype'"~="" & "`fpsandwich'"=="")) | ("`rpsandwich'"=="rpsandwich" | ("`weighttype'"~="" & "`rpsandwich'"=="")){
      display as error "Sandwich estimates are not available for MCMC"
      exit 198
    }

    if "`hcentring'" ~= "" {
      if `:list hcentring in emptylevels' {
        display as error "Hierarchical centring cannot be specified for empty levels"
        exit 198
      }
      if `hcentring' < 2 | `hcentring' > `maxlevels' {
        display as error "Hierarchical centring must be at one of levels 2 to `maxlevels'"
        exit 198
      }
      if ("`mtype'"=="multivariate" | "`mtype'"=="multinomial") local ++hcentring
    }

    if "`imputeiterations'" ~= "" {
      foreach val of local imputeiterations {
        if mod(`val', `refresh') ~= 0 {
          display as error "`val' is not a valid iteration to impute at"
          exit 198
        }
      }
    }

    if ("`me'"~="") {
      if "`mtype'" == "multivariate" {
        display as error "Measurement error not implemented for multivariate in MLwiN." _n
        exit 198
      }
      local 0 `me'
      syntax varlist(min=1), variances(numlist min=1 >=0)
      if `:list sizeof varlist' != `:list sizeof variances' {
        display as error "incorrect number of measurement error variances"
        exit 198
      }
      local mevars `varlist'
    }

    if ("`discrete'"=="")       local temp gibbs
    if ("`discrete'"~="")       local temp univariatemh // univariate MH  // NOTE SOMETIMES THIS WILL NEET TO BE MULTIVARITE MH
    if ("`femethod'"=="")       local femethod `temp'
    if ("`remethod'"=="")       local remethod `temp'
    if ("`levelonevarmethod'"=="")    local levelonevarmethod `remethod' // Looks like the GUI does this as well
    if ("`higherlevelsvarmethod'"=="")    local higherlevelsvarmethod gibbs
    macro drop temp

    if ("`savechains'"~="") {
      local 0 `savechains'
      syntax anything(name=savechains), [REPLACE]
      // Add .dta extension if this has been omitted
      if lower(substr("`savechains'", -4, .)) ~= ".dta" {
        local savechains `savechains'.dta
      }
      if "`replace'" == "" confirm new file "`savechains'"
    }
    else {
      tempfile savechains
      //tempname fh
      //file open `fh' using "`savechains'", write
      //file close `fh'
    }

    forvalues l = 1/`maxlevels' {
      if "`saveresiduals`l''" ~= "" {
        local 0 `saveresiduals`l''
        syntax anything(name=saveresiduals`l'), [REPLACE]
        // Add .dta extension if this has been omitted
        if lower(substr("`saveresiduals`l''", -4, .)) ~= ".dta" {
          local saveresiduals`l' `saveresiduals`l''.dta
        }
        if "`replace'" == "" confirm new file "`saveresiduals`l''"
      }
    }

    local defaultprior 1
    local gama 0.001
    local gamb 0.001
    if "`rppriors'" ~= "" {
      local 0 , `rppriors'
      syntax , [Uniform Gamma(numlist min=2 max=2 >=0)]
      if "`uniform'" ~= "" & "`gamma'" ~= "" {
        display as error "Cannot specify both uniform and gamma prior"
        exit 198
      }
      if "`uniform'" == "" & "`gamma'" == "" {
        display as error "You must specify uniform or gamma(a b) for priors"
        exit 198
      }
      if "`uniform'" ~= "" local defaultprior 0
      if "`gamma'" ~= "" {
          local defaultprior 1
          local gama :word 1 of `gamma'
          local gamb :word 2 of `gamma'
      }
    }

    if "`corresiduals'" ~= "" {
      local 0 , `corresiduals'
      syntax , [UNstructured EXchangeable AREQvars EQCORRSINDEPvars ARINDEPvars]
      if "`unstructured'"=="" & "`exchangeable'"=="" & "`areqvars'"=="" & "`eqcorrsindepvars'"=="" & "`arindepvars'"=="" {
        display as error "Invalid level 1 residual correlation structure specified."
        exit 198
      }
    }

    // really we want method(femethod(string) remethod(string) scale(real 5.8) adaptive(acceptance(integer 50) tolerance(integer 10)) cycles(integer 1))
    local mcmc_burnin = `burnin'          // MLwiN MCMC command option 1
    if "`adaptation'" == "noadaptation" local mcmc_adaptation = 0 // MLwiN MCMC command option 2
    else local mcmc_adaptation = 1
    local mcmc_scale = `scale'          // MLwiN MCMC command option 3
    if `acceptance' < 0 | `acceptance' > 1 {
      display as error "Acceptance rate must be between zero and one inclusive"
      exit 198
    }
    local mcmc_acceptance = ceil(`acceptance'*100)        // MLwiN MCMC command option 4
    if `tolerance' < 0 | `tolerance' > 1 {
      display as error "Tolerance rate must be between zero and one inclusive"
      exit 198
    }
    local mcmc_tolerance = ceil(`tolerance'* 100)         // MLwiN MCMC command option 5

    local 0 , `femethod'
    syntax , [GIBBS UNIvariatemh MULTIvariatemh]
    if "`gibbs'" ~= "" local mcmc_femethod = 1      // 1 = gibbs
    if "`univariatemh'" ~= "" local mcmc_femethod = 2     // 2 = univariate MH
    if "`multivariatemh'" ~= "" local mcmc_femethod = 3     // 3 = multivariate MH
    if "`gibbs'" == "" & "`univariatemh'" == "" & "`multivariatemh'" == "" {
      display as error "`femethod' is not valid"
      exit 198
    }

    local 0 , `remethod'
    syntax , [GIBBS UNIvariatemh MULTIvariatemh]
    if "`gibbs'" ~= "" local mcmc_remethod = 1      // 1 = gibbs
    if "`univariatemh'" ~= "" local mcmc_remethod = 2     // 2 = univariate MH
    if "`multivariatemh'" ~= "" local mcmc_remethod = 3     // 3 = multivariate MH
    if "`gibbs'" == "" & "`univariatemh'" == "" & "`multivariatemh'" == "" {
      display as error "`remethod' is not valid"
      exit 198
    }

    * Looks like you can't set this through the GUI
    local 0 , `levelonevarmethod'
    syntax , [GIBBS UNIvariatemh MULTIvariatemh]
    if "`gibbs'" ~= "" local mcmc_levelonevarmethod = 1     // 1 = gibbs
    if "`univariatemh'" ~= "" local mcmc_levelonevarmethod = 2    // 2 = univariate MH
    if "`multivariatemh'" ~= "" local mcmc_levelonevarmethod = 3    // 3 = multivariate MH
    if "`gibbs'" == "" & "`univariatemh'" == "" & "`multivariatemh'" == "" {
      display as error "`levelonevarmethod' is not valid"
      exit 198
    }

    local 0 , `higherlevelsvarmethod'
    syntax , [GIBBS UNIvariatemh MULTIvariatemh]
    if "`gibbs'" ~= "" local mcmc_higherlevelsvarmethod = 1     // 1 = gibbs
    if "`univariatemh'" ~= "" local mcmc_higherlevelsvarmethod = 2    // 2 = univariate MH
    if "`multivariatemh'" ~= "" local mcmc_higherlevelsvarmethod = 3    // 3 = multivariate MH
    if "`gibbs'" == "" & "`univariatemh'" == "" & "`multivariatemh'" == "" {
      display as error "`higherlevelsvarmethod' is not valid"
      exit 198
    }

    local mcmc_defaultprior = `defaultprior'      // MLwiN MCMC command option 10

    // MCMC doesn't allow neg binomial
    if "`mtype'" == "univariate" & "`distribution'"=="normal"   local mcmc_modeltype = 1 // Normal models
    if "`mtype'" == "univariate" & "`distribution'"=="binomial" local mcmc_modeltype = 2 // Binomial models
    if "`mtype'" == "univariate" & "`distribution'"=="poisson"  local mcmc_modeltype = 3 // Poisson models
    if "`mtype'" == "univariate" & "`distribution'"=="nbinomial"  local mcmc_modeltype = 8 // Poisson models
    if "`mtype'" == "multivariate" & "`discrete'" == ""         local mcmc_modeltype = 4 // Multivariate normal models
    if "`mtype'" == "multivariate" & "`discrete'" ~= ""         local mcmc_modeltype = 5 // Multivariate mixed models (must be normal/binomial with probit link)
    if "`mtype'" == "multinomial" & "`link'"=="mlogit"          local mcmc_modeltype = 6 // Unordered multinomial models
    if "`mtype'" == "multinomial" & ("`link'"=="ologit"|"`link'"=="oprobit"|"`link'"=="ocloglog") local mcmc_modeltype = 7 // Ordered multinomial models
    capture assert inlist(`mcmc_modeltype',1,2,3,4,5,6,7,8)
    if _rc {
      display as error "The selected distribution is not available for MCMC"
      exit 198
    }
    if "`verbose'"~="" {
      local i = 1
      foreach option in mcmc_burnin mcmc_adaptation mcmc_scale mcmc_acceptance mcmc_tolerance mcmc_femethod mcmc_remethod mcmc_levelonevarmethod mcmc_higherlevelsvarmethod mcmc_defaultprior mcmc_modeltype {
        di "MLwiN MCMC command option `i': ``option''" _col(50) "(`option')"
        local ++i
      }
    }

    local resptype
    local mixed 0
    if "`distribution'" == "binomial" local resptype 0
    if "`distribution'" == "poisson" local resptype 1
    if "`distribution'" == "nbinomial" local resptype 2
    if "`distribution'" == "normal" local resptype 3
    if "`mtype'" == "multinomial" & "`link'"=="mlogit" local resptype 4
    if "`mtype'" == "multinomial" & ("`link'"=="ologit"|"`link'"=="oprobit"|"`link'"=="ocloglog") local resptype 5
    if "`mtype'" == "multivariate" {
      local resptype 3
      local firstdist :word 1 of `distribution'
      foreach dist in `distribution' { // If one of the response is nonlinear set response type to this
        if "`dist'" ~= "`firstdist'" local mixed 1
        if "`dist'" == "binomial" {
          local resptype 0
          if "`link'" ~= "probit" {
            display as error "Only the probit link is allowed for binomial responses in multivariate models for MCMC estimation"
            exit 198
          }
        }
        if "`dist'" == "poisson" {
          local resptype 1
          display as error "Poisson is currently unavailable in multivariate models for MCMC estimation"
          exit 198
        }
        if "`dist'" == "nbinomial" {
          local resptype 2
          display as error "Poisson is currently unavailable in multivariate models for MCMC estimation"
          exit 198
        }
      }
    }

    //if "`resptype'" == "2" {
    //  display as error "Negative binomial is currently unavailable for MCMC estimation"
    //  exit 198
    //}

    local allnormal 1
    local resptypes `distribution'
    forvalues n = 1/`:list sizeof resptypes' {
      if "`=word("`resptypes'", `n')'" != "normal" local allnormal 0
    }

    local mcmc_chain = `chain'
    local mcmc_thinning = `thinning'
    local mcmc_refresh = `refresh'
    local mcmc_seed = `seed'

    forvalues l = 2/`maxlevels' {
      if "`mmids`l''"~="" |"`mmweights`l''"~="" {
        if `:list sizeof mmweights`l'' ~= `:list sizeof mmids`l'' {
          display as error "Number of variables in mmids`l'() must equal number of variables in mmweights`l'()."
          exit 198
        }

        mata: checkmm("`mmids`l''", "`mmweights`l''")
        local numweights`l' = `:list sizeof mmwewights`l''
        local cc on
        local mm on
      }
    }

    /*
    Valid MCMC options:

    smcmc   smvn    orth    hcen    parexpansion
    1     0     0     0     0
    0     1     0     0     0
    0     0     1     1     1

    */

    local anyparexpansion = 0
    forvalues l = 2/`maxlevels' {
      if "`parexpansion`l''" ~= "" local anyparexpansion = 1
    }

    if "`smcmc'" ~= "" & ("`smvn'" ~= "" | "`orthogonal'" ~= "" | "`hcentring'" ~= "" | `anyparexpansion' > 0) {
      display as error "SMCMC is exclusive to SMVN, ORTHogonal, HCEN and PAREXpansion"
      exit 198
    }

    if "`smvn'" ~= "" & ("`smcmc'" ~= "" | "`orthogonal'" ~= "" | "`hcentring'" ~= "" | `anyparexpansion' > 0) {
      display as error "SMVN is exclusive to SMCMC, ORTHogonal, HCEN and PAREXpansion"
      exit 198
    }

    if "`smcmc'" ~= "" & ("`mtype'" ~= "univariate" | "`discrete'" ~= "" | "`numrp1vars'" ~= "1" | "`maxlevels'" ~= "2") {
      display as error "SMCMC is only valid for two-level normal response models with no complex level 1."
      exit 198
    }

  }

  local carlev = 0
  forvalues l = 1/`maxlevels' {
    if ("`car`l''"~="" & "`carcentre'"=="") {
      if `carlev' ~= 0 {
        display as error "CAR can only be specified at one level"
        exit 198
      }
      else local carlev = `l'
    }
  }

  ******************************************************************************
  * (2) GENERATE THE EMPTY VECTOR OF PARAMETER ESTIMATES
  ******************************************************************************

  * Fixed part parameter vector(s)

  forvalues r = 1/`numfpbrackets' {
    tempname FP_b`r'
    mat `FP_b`r'' = J(1,`numfpvars`r'',.)
    mat coleq `FP_b`r'' = FP`r'
    local fname
    foreach name of local fpname`r' {
      if _caller() >= 11 {
        local fname `fname' `=strtoname("`name'")'
      }
      else {
        mata: st_local("name", validname("`name'"))
        local fname `fname' `=abbrev("`name'", 32)'
      }
    }
    mat colnames `FP_b`r'' = `fname' //`fp`r''
  }
  tempname matFP_b
  forvalues r = 1/`numfpbrackets' {
    mat `matFP_b' = (nullmat(`matFP_b'),`FP_b`r'')
  }

  * Random part parameter vector (some terms may still need to be deleted)
  forvalues l = `maxlevels'(-1)1 {
    tempname RP`l'_b // define matrix names as locals
    if `:list sizeof rp`l'name'>=1 {
      runmlwin_rplpars , rpname(`rp`l'name')
      local rp`l'pars `r(rplong)'

      runmlwin_rplpars , rpname(`origrp`l'name')
      local origrp`l'pars `r(rplong)'

    //  if "`mtype'"=="multinomial" & "`link'"=="mlogit" {
    //    * Remove non-existant parameter from multinomial model
    //  //  local tmpname var(P) var(_P) // cov(P\bcons_1) cov(_P\bcons_1)
    //  //  //if "`mcmc'" ~= "" local tmpname `tmpname' var(bcons_1) // This isn't included for MCMC models
    //  //  if "`mcmc'" ~= "" local tmpname `tmpname' cov(P\_P) // This isn't included for MCMC models
    //    if "`mcmc'" ~= "" local tmpname OD:bcons_2
    //    local rp`l'pars `:list rp`l'pars - tmpname'
    //  }

      * Remove non-existant parameter from negative-binomial model
      // local tmpname cov(bcons_1\bcons2_1)
      // if "`distribution'"=="nbinomial" local rp`l'pars `:list rp`l'pars - tmpname'

      local numrp`l'pars: word count `rp`l'pars'
      if `numrp`l'pars' > 0 {
        mat `RP`l'_b' = J(1,`numrp`l'pars',.)
        mat coleq `RP`l'_b' = RP`l'
        mat colnames `RP`l'_b' = `rp`l'pars'
      }

      * Remove parameters from the variance-covariance matrices
      if "`elements`l''"~="" {
        * Assert that length of `elements`l'' is same as length of `rp`l'pars'
        if colsof(`elements`l'')~=`numrp`l'pars' {
          display as error "The matrix `elements`l'' should contain `numrp`l'pars' elements (i.e. one for each parameter in the level `l' var-cov matrix)" _n
          exit 198
        }

        * Assert that the elements of `elements`l'' are 0 or 1
        local names : colfullnames `elements`l''
        local c = 1
        foreach p of local names {
          if ~inlist(`elements`l''[1,`c'],0,1) {
            display as error "All elements in matrix `elements`l'' should be 0 (= remove parameter from model) or 1 (= retain parameter in model)" _n
            exit 198
          }
          local ++c
        }

        * Remove elements from RP_b
        tempname matTEMP
        local names : colnames `RP`l'_b'

        local keepnames
        forvalues i = 1/`=colsof(`elements`l'')' {
          if (`elements`l''[1,`i']==1) local keepnames `keepnames' `:word `i' of `origrp`l'pars''
        }

        foreach p of local names {
          if `:list p in keepnames' matrix `matTEMP' = (nullmat(`matTEMP'), `RP`l'_b'[1,"RP`l':`p'"])
        }
        mat `RP`l'_b' = `matTEMP'
      }
      if "`diagonal`l''"~="" {
        * Work out what the diagonal matrix will look like, then convert the lower diagonal to a vector
        tempname matTEMP1 matTEMP2
        mat `matTEMP1' = I(`numrp`l'vars')
        local C = `numrp`l'vars'
        local R = `numrp`l'vars'
        forvalues r=1/`R' {
          forvalues c=1/`C' {
            if `c'<=`r' mat `matTEMP2' = (nullmat(`matTEMP2'), `matTEMP1'[`r',`c'])
          }
        }

        * Remove elements from RP_b
        // This code is same as that in the elements`l' statement above. Code could be made more efficient
        tempname matTEMP3
        local c = 1
        local names : colfullnames `RP`l'_b'
        foreach p of local names {
          if (`matTEMP2'[1,`c']==1) matrix `matTEMP3' = (nullmat(`matTEMP3'), `RP`l'_b'[1,"`p'"])
          local ++c
        }
        mat `RP`l'_b' = `matTEMP3'
      }
    }
  }
  tempname matRP_b

  forvalues l = `maxlevels'(-1)1 {
    if `:list sizeof rp`l'name'>=1 {
      if `numrp`l'pars' > 0 {
        mat `matRP_b' = (nullmat(`matRP_b'), `RP`l'_b')
      }
    }
  }

  if "`distribution'" == "binomial" | "`distribution'" == "poisson" | "`distribution'" == "nbinomial" | "`distribution'" == "multinomial"{
    tempname mat_OD
    if "`distribution'" == "nbinomial" local odvars bcons_1 bcons2_1
    else local odvars bcons_1
    if "`distribution'" == "multinomial" & "`link'"=="mlogit" & "`mcmc'" == "" local odvars `odvars' bcons_2

    mat `mat_OD' = J(1, `:list sizeof odvars', .)
    mat colnames `mat_OD' = `odvars'
    mat coleq `mat_OD' = OD
    mat `matRP_b' = (nullmat(`matRP_b'), `mat_OD')
  }

  * Random part design
  forvalues l = `maxlevels'(-1)1 {
    if "`design`l''"~="" {
      mat `RP`l'_b'design = J(1,`numdesign`l'',.)
      mat coleq `RP`l'_b'design = RP`l'D
      mat colnames `RP`l'_b'design = `design`l''
      mat `matRP_b' = (nullmat(`matRP_b'),  `RP`l'_b'design)
    }
  }

  * Factors
  tempname mat_RP_b_fact
  forvalues l = `maxlevels'(-1)1 {
    if "`flinit`l''"~="" {
      tempname matTEMP
      forvalues fact = 1/`=colsof(`flinit`l'')' {
        local factnames
        forvalues resp = 1/`=rowsof(`flinit`l'')' {
          local factnames `factnames' f`fact'_`resp'
        }
        mat `matTEMP' = J(1, rowsof(`flinit`l''), .)
        mat coleq `matTEMP' = RP`l'FL
        mat colnames `matTEMP' = `factnames'
        mat `mat_RP_b_fact' = (nullmat(`mat_RP_b_fact'),  `matTEMP')
      }
    }
  }

  tempname mat_RP_b_factvar
  forvalues l = 1/`maxlevels' {
    if "`flinit`l''" ~= "" {
      tempname matTEMP
      local factvarnames
      forvalues fact1 = 1/`=colsof(`flinit`l'')' {
        forvalues fact2 = 1/`fact1' {
          if `fact1' == `fact2' local factvarnames `factvarnames' var(f`fact1')
          else local factvarnames `factvarnames' cov(f`fact1'\f`fact2')
        }
      }
      mat `matTEMP' = J(1, `:list sizeof factvarnames', .)
      mat coleq `matTEMP' = RP`l'FV
      mat colnames `matTEMP' = `factvarnames'
      mat `mat_RP_b_factvar' = (nullmat(`mat_RP_b_factvar'), `matTEMP')
    }
  }

  local C = colsof(`matFP_b')
  local namesV : colfullnames `matFP_b'
  tempname matFP_V
  mat `matFP_V' = J(`C',`C',0)
  matrix rownames `matFP_V' = `namesV'
  matrix colnames `matFP_V' = `namesV'

  * Put MLwiN values back into RP_V
  local C = colsof(`matRP_b')
  local namesV : colfullnames `matRP_b'
  tempname matRP_V
  mat `matRP_V' = J(`C',`C',0)
  matrix rownames `matRP_V' = `namesV'
  matrix colnames `matRP_V' = `namesV'

  * Full parameter matrix (this is what Stata expects MLwiN to return)

  * Create matb with the correct dimensions

  tempname matb
  mat `matb' = (`matFP_b',`matRP_b', nullmat(`mat_RP_b_fact'), nullmat(`mat_RP_b_factvar'))
  mat rowname `matb' = `response1'
  local names : colfullnames `matb'

  tempname matV
  mat `matV' = J(colsof(`matb'), colsof(`matb'), 0)
  local namesV : colfullnames `matb'
  mat rownames `matV' = `namesV'
  mat colnames `matV' = `namesV'

  if ("`constraints'"~="") {
    * Parse contraint(s)
    local C = colsof(`matb')
    forvalues c=1/`C' {
      mat `matb'[1,`c'] = 0
    }

    ereturn post `matb' // Need to create e(b) for the current model in order to set constraints
    tempname matb
    mat `matb' = e(b)
    if ("`verbose'"~="") mat list e(b)
    forvalues c=1/`C' {
      mat `matb'[1,`c'] = .
    }

    tempname consT
    tempname consa
    tempname consC
    makecns `constraints', displaycns
    matcproc `consT' `consa' `consC'

    if "`verbose'" ~= "" display "Constraints:"
    if "`verbose'" ~= "" mat list `consC'

    * Extract the fixed part constraint submatrix (note that some rows will refer to random part constraints, we delete these below)
    tempname FPCtemp
    mat `FPCtemp' = (`consC'[.,1..`numfpvars'],`consC'[.,`=colsof(`consC')'..`=colsof(`consC')'])

    * Extract the random part constraint submatrix (note that some rows will refer to fixed part constraints, we delete these below)
    local temp = `numfpvars' + 1
    tempname RPCtemp
    mat `RPCtemp' = (`consC'[.,`temp'...])

    if "`verbose'" ~= "" display "FPCtemp"
    if "`verbose'" ~= "" mat list `FPCtemp'
    if "`verbose'" ~= "" display "RPCtemp"
    if "`verbose'" ~= "" mat list `RPCtemp'

    local numconstraints = rowsof(`consC')

    * Work out which constraints and how many constraints are FP constraints
    tempname isFPconstraint
    mat `isFPconstraint' = J(`numconstraints',1,.)
    forvalues r=1/`=rowsof(`FPCtemp')'{
      local flag = 0
      forvalues c=1/`=colsof(`FPCtemp')-1' {
        if `FPCtemp'[`r',`c'] ~= 0 local flag = 1
      }
      mat `isFPconstraint'[`r',1]==`flag'
    }
    tempname mat_sum
    mat `mat_sum' = J(1,`numconstraints',1)*`isFPconstraint'
    local numFPconstraints = `mat_sum'[1,1]

    * Work out which constraints and how many constraints are RP constraints
    tempname isRPconstraint
    mat `isRPconstraint' = J(`numconstraints',1,.)
    forvalues r=1/`=rowsof(`RPCtemp')'  {
      local flag = 0
      forvalues c=1/`=colsof(`RPCtemp')-1' {
        if `RPCtemp'[`r',`c'] ~= 0 local flag = 1
      }
      mat `isRPconstraint'[`r',1]==`flag'
    }
    mat `mat_sum' = J(1,`numconstraints',1)*`isRPconstraint'
    local numRPconstraints = `mat_sum'[1,1]

    if "`verbose'" ~= "" display "num fp vars: `numfpvars', num rp vars: `numrpvars'"
    if "`verbose'" ~= "" display "isFPconstraint:"
    if "`verbose'" ~= "" mat list `isFPconstraint'
    if "`verbose'" ~= "" display "isRPconstraint:"
    if "`verbose'" ~= "" mat list `isRPconstraint'
    if "`verbose'" ~= "" display "num constraints: `numconstraints', num FP constraints: `numFPconstraints', num RP constraints: `numRPconstraints'"

    * Check that each constraint relates to only the fixed part or only the random part
    tempname matTEMP
    mat `matTEMP' = `isFPconstraint' + `isRPconstraint'
    forvalues r=1/`numconstraints' {
      if (`matTEMP'[`r',1]>1) {
        mat list `consC'
        display as error "Row `r' of the constraint matrix is invalid as it involves both fixed part and random part parameters." _n
        exit 198
      }
    }

    * Strip out redundant rows of the fixed part constraint matrix (these relate to the random part)
    tempname FPC
    if `numFPconstraints'>0 {
      forvalues r=1/`numconstraints' {
        if (`isFPconstraint'[`r',1]==1) mat `FPC' = (nullmat(`FPC') \ `FPCtemp'[`r',1...])
      }
      local fpconstraints `FPC'
    }

    * Strip out redundant rows of the random part constraint matrix (these relate to the fixed part)
    tempname RPC
    if `numRPconstraints'>0 {
      forvalues r=1/`numconstraints' {
        if (`isRPconstraint'[`r',1]==1) mat `RPC' = (nullmat(`RPC') \ `RPCtemp'[`r',1...])
      }
      local rpconstraints `RPC'
    }
    ereturn clear // As we don't want an e(b) kicking around
  }

  * Store the fixed part constraint(s) as strings in locals ready to insert into MLwiN macro
  if ("`fpconstraints'"~="") {
    local numfpconstraints = rowsof(`fpconstraints')
    forvalues r = 1/`numfpconstraints' {
      local C = colsof(`fpconstraints')
      local fpconstraint`r' = `fpconstraints'[`r',1] // put first element of constraint into the string
      forvalues c=2/`C' {
        local temp = `fpconstraints'[`r',`c']
        local fpconstraint`r' `fpconstraint`r'' `temp' // put second, third,... elements of constraint into the string
      }
    }

    if "`verbose'" ~= "" display("Fixed part constraints:")
    if "`verbose'" ~= "" mat list `fpconstraints'
  }

  * Store the random part constraint(s) as strings in locals ready to insert into MLwiN macro
  if "`rpconstraints'"~="" {
    local numrpconstraints = rowsof(`rpconstraints')
    forvalues r = 1/`numrpconstraints' {
      local C = colsof(`rpconstraints')
      local rpconstraint`r' = `rpconstraints'[`r',1] // put first element of constraint into the string
      forvalues c=2/`C' {
        local temp = `rpconstraints'[`r',`c']
        local rpconstraint`r' `rpconstraint`r'' `temp' // put second, third,... elements of constraint into the string
      }
    }
    if "`verbose'" ~= "" display("Random part constraints:")
    if "`verbose'" ~= "" mat list `rpconstraints'
  }

  * Substitute initial values into the parameter vector
  if "`inits'"~="" | "`initsmodel'" ~= "" {
    if "`initsprevious'"~="" | "`initsmodel'" ~= "" {
      tempname srcrowidx
      tempname srccolidx
      tempname destrowidx
      tempname destcolidx

      matrix `srcrowidx' = J(1,1,1)
      matrix `destrowidx' = J(1,1,1)
      local match 0
      foreach p of local names {
        local idx = colnumb(`inits',"`p'")
        if "`idx'" ~= "." {
          local match 1
          matrix `srccolidx' = (nullmat(`srccolidx'), `idx')
          matrix `destcolidx' = (nullmat(`destcolidx'), `=colnumb(`matb',"`p'")')
        }
      }

      if `match' == 1 {
        mata: copymatrix("`inits'", "`srcrowidx'", "`srccolidx'", "`matb'", "`destrowidx'", "`destcolidx'");
      }
      else {
        if "`initsprevious'"~="" display as error "The initsprevious option is invalid: No parameters in the previous model match those specified in the current model"
        if "`initsmodel'" ~= "" display as error "The initsmodel option is invalid: No parameters in the stored model match those specified in the current model"
        exit 198
      }

      matrix drop `srcrowidx'
      matrix drop `destrowidx'
      matrix drop `srccolidx'
      matrix drop `destcolidx'

      local match 0
      foreach p1 of local namesV {
        local cidx = colnumb(`initsV',"`p1'")
        local ridx = rownumb(`initsV',"`p1'")
        if "`ridx'" ~= "." && "`cinx'" ~= "." {
          local match 1
          matrix `srcrowidx' = (nullmat(`srcrowidx'), `ridx')
          matrix `destrowidx' = (nullmat(`destrowidx'), `=rownumb(`matV', "`p1'")')
          matrix `srccolidx' = (nullmat(`srccolidx'), `cidx')
          matrix `destcolidx' = (nullmat(`destcolidx'), `=colnumb(`matV', "`p1'")')
        }
      }

      if `match' == 1 {
        mata: copymatrix("`initsV'", "`srcrowidx'", "`srccolidx'", "`matV'", "`destrowidx'", "`destcolidx'");
      }
      else {
        if "`initsprevious'"~="" display as error "The initsprevious option is invalid: No parameters in the previous model match those specified in the current model"
        if "`initsmodel'" ~= "" display as error "The initsmodel option is invalid: No parameters in the stored model match those specified in the current model"
        exit 198
      }

      matrix drop `srcrowidx'
      matrix drop `destrowidx'
      matrix drop `srccolidx'
      matrix drop `destcolidx'
    }
    if "`initsb'"~="" {
      if colsof(`inits') ~= `=colsof(`matFP_b')+colsof(`matRP_b')' {
        display as error "The row vector `inits' of initial values in initsb() is of length `=colsof(`inits')', but -runmlwin- expects the row vector to be of length `=colsof(`matFP_b')+colsof(`matRP_b')'."
        exit 198
      }

      matrix `matb'[1,1] = `inits'
      * Note this is not currently used as we always check there are two inits matrices
      if "`initsV'" == "" {
        forvalues i = 1/`=colsof(`matb')' {
          matrix `matV'[`i', `i'] = (`inits'[1,`i']/2)*(`inits'[1,`i']/2)
        }
      }
    }
    if "`initsv'"~="" {
      if colsof(`initsV') ~= `=colsof(`matFP_b')+colsof(`matRP_b')' | rowsof(`initsV') ~= `=colsof(`matFP_b')+colsof(`matRP_b')' {
        display as error "The matrix of initial variance values in initsv() is of a different length to that expected by -runmlwin-."
        exit 198
      }

      matrix `matV'[1,1] = `initsV'
    }
  }

  if "`mlwin'" == "nomlwin" {
    ereturn clear
    ereturn matrix matb = `matb'
    ereturn matrix matV = `matV'
    //ereturn post `matb' `matV'
  }

  ******************************************************************************
  * (3) PREPARE DATA FOR MLWIN
  ******************************************************************************

  * Preserve the data
  preserve

  * Remove data label
  label data

  * Generate unique identifier variable
  label var `_sortindex' "Observation number in the current Stata data set"


  * Keep the estimation sample
  qui keep if `touse'
  local _nobs = _N

  * List of values of the response variable
  if ("`mtype'"=="multinomial") {
    qui levelsof `response1', local(responsecats)

    if "`proportion'" ~= "" {

      capture assert `proportion' >= 0 & `proportion' <= 1
      if _rc {
        display as error "Values in the multinomial proportion variable should lie between zero and one"
        exit 198
      }
      tempvar propsum

      if ("`cc'"~="") local hier `lev1id'
      else {
        local hier
        local levelused = 0
        forvalues l = `maxlevels'(-1)2 {
          if `numrp`l'vars' > 0 local levelused = 1
          if `levelused' == 1 local hier `hier' `lev`l'id'
        }
        local hier `hier' `lev1id'
      }

      bysort `hier': egen `propsum' = total(`proportion')
      capture assert inrange(`propsum',0.995,1.005) // >= 0 & `propsum' <= 1
      if _rc {
        display as error "The sum of multinomial proportions for each unit should equal one"
        exit 198
      }
      drop `propsum'
      sort `_sortindex'
      drop `_sortindex'
      quietly reshape wide `proportion', i(`lev1id') j(`response1')
      gen `_sortindex' = _n
      gen `response1' = 1
      local propvars
      local propvarnames
      local i = 1
      foreach r of local responsecats {
        if `r' ~= `basecategory' local propvars `propvars' `proportion'`r'
        if `r' ~= `basecategory' local propvarnames `propvarnames' '`proportion'`r''
        quietly replace `response1' = `r' in `i'
        local ++i
      }
    }

    tempname newvaluelabel
    foreach r of local responsecats {
      label define `newvaluelabel' `r' "`: label (`response1') `r''", add
    }
    label values `response1' `newvaluelabel'

    if "`link'"=="ologit"|"`link'"=="oprobit"|"`link'"=="ocloglog" {
      local firstvalue = real(word("`responsecats'",1))
      local lastvalue = real(word("`responsecats'",-1))
      if ~inlist(`basecategory', `firstvalue',`lastvalue') {
        di as error "The basecategory must be either the first value (`response1' = `firstvalue') or last value (`response1' = `lastvalue') of the ordered response variable."  _n
        exit 198
      }
    }
  }

  * List of ID variables
  local idvars
  forvalues l = `maxlevels'(-1)1 {
    local idvars `idvars' `lev`l'id'

    // MM IDs are added consecutively in case MM IDs share variables with level IDs (what if ID is used in more than one level?)
    if "`mmids`l''" ~= "" local idvars `idvars' `mmids`l''
  }

  * List of variables which appear in the random part of the model
  local rp
  forvalues l = `maxlevels'(-1)1 {
    local rp `rp' `rp`l''
  }

  * List of variable which appear as denominators in discrete response models
  local denomvars
  if "`mtype'" == "multivariate" {
    forvalues e = 1/`nummlwineqns' {
      local denomvars `denomvars' `denominator`e''
    }
  }
  else {
    local denomvars `denominator'
  }

  * List of multiple membership weight variables
  local mmweightvars
  forvalues l = 2/`maxlevels' {
    if "`mmweights`l''" ~= "" local mmweightvars `mmweightvars' `mmweights`l''
  }

  * List of multiple membership ID variables
  //local mmweightids
  //forvalues l = 2/`maxlevels' {
  //  if "`mmids`l''" ~= "" {
  //    local mmweightids `mmweightids' `mmids`l''
  //  }
  //}

  * List of (R)IGLS sampling weight variables
  local weightvars
  forvalues l = 1/`maxlevels' {
    if "`weight`l''" ~= "" local weightvars `weightvars' `weight`l''
  }

  * Keep variables that appear in model
  local allvarsformlwin ///
    `idvars' ///
    `response' ///
    `fp' ///
    `rp' ///
    `denomvars' `offset' `fpconst' `rpconst' `mmweightvars' `mmweightids' `weightvars' `_sortindex' `propvars'

  local data_has_missing_values = 0

  foreach var of local allvarsformlwin {
    if "`var'" ~= "bcons" {
      quietly count if missing(`var')
      if r(N) > 0 {
        if "`mtype'" == "multinomial" {
          display as error "For multinomial response models (i.e. ordered and unordered categorical responses), the data must be manually listwise deleted (i.e. cases with missing values for one or more variables included in the model must be dropped) prior to calling runmlwin."
          exit 198
        }
        local data_has_missing_values = 1
      }
    }
  }

  * If a multivariate response model, create and add bcons variable to the list of variables sent to MLwiN
  if "`mtype'" == "multivariate" gen byte bcons = 1

  * Keep variables
  if "`drop'"=="" keep `allvarsformlwin'
  order `allvarsformlwin'

  * Strip off the value labels of all fixed or random part covariates
  local temp `fp' `rp'
  foreach var of local temp {
    label values `var'
  }

  * Calculate number of columns that will be used in the worksheet
  qui describe
  local numcolumns = r(k)
  local N = r(N)

  local explvars

  forvalues e = 1/`numfpbrackets' {
    local explvars `:list explvars | fpname`e''
  }

  forvalues l = `maxlevels'(-1)1 {
    forvalues e = 1/`numrpbrackets`l'' {
      local explvars `:list explvars | rp`l'name`e''
    }
  }

  local numrpparam = colsof(`matRP_b')
  if "`mtype'" == "multivariate" & "`discrete'" ~= "" { // Account for adding bcons parameters with SETV in multivariate (i.e. add off-diagonal)
    local numrpparam = `numrpparam' + (((`nummlwineqns' * (`nummlwineqns'+1)) /2) - `nummlwineqns')
  }
  local numexpl = max(`:list sizeof explvars', `numrpparam')

  * Allow for bcons.1
  if "`distribution'" == "binomial" | "`distribution'" == "poisson" | "`distribution'" == "nbinomial" | "`mtype'" == "multinomial" local ++numexpl

  * Allow for bcons2.1
  if "`distribution'" == "nbinomial" local ++numexpl

  * Allow for P parameter
  if "`mtype'" == "multinomial" local ++numexpl

  if "`maxexpl'" == "" local maxexpl = `numexpl' + 1 // MLwiN appears to allow one fewer than specified

  if "`toplevel'" == "" {
    local toplevel `maxlevels'
    if ("`mtype'"=="multivariate" | "`mtype'"=="multinomial") local ++toplevel
    local ++toplevel // Add an extra level, as NLEV command gives the wrong answer if all available levels are in use and this can cause the discrete/multicat macros to give the wrong answers
    if `toplevel' < 3 local toplevel = 3
  }
  if "`numwscolumns'" == "" local numwscolumns 1500

  * Attempt to estimate how large the data will be after expansion
  if "`worksize'" == "" {
    local worksize = 10000
  }

  if ("`verbose'"~="") display as text "Expanded variables: Count: `numexpand', Length: `longN' Estimated sheet size: `sheetsize'"

  qui compress

  * Assert that the data is sorted according to the model hierarchy
  if "`cc'"=="" && "`sort'" == "" {
    if "`mtype'" == "univariate" local bottomlev 1
    else local bottomlev 0
    if `maxlevels'>`bottomlev' {
      local idvars2andhigher
      local levelused = 0
      forvalues l = `maxlevels'(-1)`=`bottomlev' + 1' {
        if `numrp`l'vars' > 0 local levelused = 1
        if `levelused' == 1 local idvars2andhigher `idvars2andhigher' `lev`l'id'
      }
      * Check whether correct sort order is set, otherwise examine the data
      if `=strpos("`:sortedby'", "`idvars2andhigher'")' ~= 1 {
        tempvar sortorder1
        tempvar sortorder2
        quietly gen `sortorder1' = _n
        sort `idvars2andhigher' `sortorder1'
        quietly gen `sortorder2' = _n
        capture assert `sortorder2'==`sortorder1'
        if _rc {
          if "`forcesort'" ~= "" {
            display as error "Warning: The data have been resorted in the order of the model hierarchy: `idvars2andhigher' `lev1id'." _n
          }
          else {
            display as error "The data must be sorted according to the order of the model hierarchy: `idvars2andhigher' `lev1id'." _n
            exit 198
          }
        }
        drop `sortorder1' `sortorder2'
      }
    }
  }

  foreach var of varlist * {
    if "`:type `var''" == "double" & `doublevar' == 0 {
      if "`forcerecast'" ~= "" {
        recast float `var', force
        display as error "Warning: `var' has been recast to float, this has reduced precision"
      }
      else {
        display as error in smcl "`var' is held to more precision than MLwiN can handle, to reduce the precision use {stata recast float `var', force}"
        exit 198
      }
    }
    if "`:type `var''" == "long" {
      if `doublevar' == 0 {
        capture recast float `var'
      }
      else {
        capture recast double `var'
      }
      if `r(N)' > 0 {
        if "`forcerecast'" ~= "" {
          if `doublevar' == 0 {
            recast float `var', force
            display as error "Warning: `var' has been recast to float, if this is an ID variable its meaning may have changed"
          }
          else {
            recast double `var', force
            display as error "Warning: `var' has been recast to double, if this is an ID variable its meaning may have changed"
          }
        }
        else {
          display as error "`var' is held to more precision than MLwiN can handle, it must be recoded so that values lie in the range +/- 16,777,215"
          exit 198
        }
      }
    }
  }

  tempfile filedata

  qui saveold "`filedata'", replace

  ******************************************************************************
  * (4) WRITE MLWIN SUB MACRO TO FIT MODEL
  ******************************************************************************
  tempname macro1
  if "`savemacro'" ~= "" local filemacro1 `savemacro'
  else tempfile filemacro1

  if "`batch'" ~= "" local pause nopause

  qui file open `macro1' using "`filemacro1'", write replace

    if ("`pause'"=="nopause" | "`plugin'" ~= "") file write `macro1' "ECHO 0" _n

    * Give details about runmlwin and date and time stamp the macro
    file write `macro1' "NOTE   ***********************************************************************" _n
    file write `macro1' "NOTE   MLwiN macro created by runmlwin Stata command: `c(current_date)', `c(current_time)'" _n
    file write `macro1' "NOTE   See: www.bristol.ac.uk/cmm/runmlwin for help" _n
    file write `macro1' "NOTE   ***********************************************************************" _n(2)

    if "`verbose'" ~= "" display as text "Estimated worksheet size: `worksize'"
    if "`verbose'" ~= "" display as text "Number of levels: `toplevel'"
    if "`verbose'" ~= "" display as text "Number of explanatory variables/random parameters: `maxexpl' (`explvars')"

    if "`verbose'" ~= "" file write `macro1' "ECHO 1" _n
    file write `macro1' "NOTE   Initialise MLwiN storage" _n "INIT `toplevel' `worksize' `numwscolumns' `maxexpl' 30" _n(2)
    if "`optimat'" == "" file write `macro1' "OPTS 0" _n
    else file write `macro1' "OPTS 1" _n
    if "`tempmat'" == "" file write `macro1' "NOTE   Don't use worksheet for matrix storage" _n "MEMS 1" _n(2)
    else file write `macro1' "NOTE   Use worksheet for matrix storage" _n "MEMS 0" _n(2)

    file write `macro1' "MONI 0" _n
    file write `macro1' "MARK 0" _n
    if "`batch'" ~= "" {
      file write `macro1' "NOTE divert error messages to a file" _n "ERRO 0" _n
      tempfile errlog
      //tempname fh
      //file open `fh' using "`errlog'", write
      //file close `fh'
      file write `macro1' "LOGO '`errlog'' 1" _n(2)
    }

    * Open the equations window
    if ("`pause'"=="") {
      file write `macro1' "NOTE   Open the equations window" _n
      file write `macro1' "WSET 15 1" _n    // open the equations window
      file write `macro1' "EXPA 2" _n     // expand from response equation to include first model equation then random effects equations
      file write `macro1' "ESTM 1" _n(2)  // switch from black symbols to coloured symbols (but not point estimates)
    }

    if "`useworksheet'" ~= "" {
      file write `macro1' "NOTE   Load previously saved model state into MLwiN" _n "ZRET   '`useworksheet''" _n(2)
    }
    else {
      * Load the data set
      file write `macro1' "NOTE   Import the Stata data set into MLwiN" _n "RSTA   '`filedata''" _n(2)

      if "`rngversion'" ~= "" file write `macro1' "NOTE   Set the random number generator version" _n "RNGV `rngversion'" _n

      * Load design vectors if specified
      forvalues l = `maxlevels'(-1)1 {
        if "`design`l''"~="" {
          file write `macro1' "NOTE   Load the design matrix for the random part at level `l'" _n
          file write `macro1' "LINK `numdesign`l'' G21" _n "GSTA '`filedesign`l''' G21" _n "LINK 0 G21" _n(2)
        }
      }

      * Convergence tolerance
      if "`iglstolerance'" ~= "" file write `macro1' "NOTE   Specify the (R)IGLS convergence tolerance" _n "TOLE `iglstolerance'" _n(2)

      * Specify the univariate response variable
      file write `macro1' "NOTE   Specify the response variable(s)" _n
      if ("`mtype'"~="multivariate" & "`mtype'"~="multinomial") file write `macro1' "RESP   '`response1''" _n

      * Specify the multivariate response variable
      local responsenames
      forvalues e = `nummlwineqns'(-1)1 {
        if "response`e'"~="" local responsenames '`response`e''' `responsenames'
      }
      if ("`mtype'"=="multivariate") file write `macro1' "MVAR 1 `responsenames'" _n


      * Specify the multinomial response variable
      // assert that response is categorical
      if ("`distribution'"=="multinomial") {
        local cresp = `numcolumns' + 1
        local cresp_indicator = `numcolumns' + 2

        * Expand the data
        file write `macro1' "NAME   c`cresp' 'resp' c`cresp_indicator' 'resp_indicator'" _n
        if "`link'" == "mlogit" file write `macro1' "MNOM 0 '`response1'' 'resp' 'resp_indicator'  `basecategory'" _n
        else file write `macro1' "MNOM 1 '`response1'' 'resp' 'resp_indicator'  `basecategory'" _n
        file write `macro1' "RESP   'resp'" _n
        if ("`link'"=="mlogit") file write `macro1' "RDIS 1 4" _n
        if ("`link'"=="ologit"|"`link'"=="oprobit"|"`link'"=="ocloglog") file write `macro1' "RDIS 1 5" _n
        if "`link'"=="ologit" | "`link'"=="mlogit" file write `macro1' "LFUN 0" _n
        if "`link'"=="oprobit" file write `macro1' "LFUN 1" _n
        if "`link'"=="ocloglog" file write `macro1' "LFUN 2" _n
        file write `macro1' "DOFF 1 '`denominator''" _n
        if ("`extra'" ~= "") file write `macro1' "EXTR 1" _n
      }

      if "`proportion'" ~= "" file write `macro1' "VECT `=`:list sizeof responsecats'-1' `propvarnames' 'resp'" _n

      if ("`pause'"=="") file write `macro1' "PAUS 1" _n
      file write `macro1' _n

      * Loop over responses (equations)
      forvalues e = 1/`numfpbrackets' {

        * Binary response
        // assert that response lies in the interval [0,1]
        if ("`distribution`e''"=="binomial") {
          file write `macro1' "NOTE   Response distribution, link function and denominator" _n
          file write `macro1' "RDIS `e' 0" _n
          if ("`link'"=="probit") file write `macro1' "LFUN 1" _n
          if ("`link'"=="cloglog") file write `macro1' "LFUN 2" _n
          if ("`link'"=="logit" | "`link'"=="") file write `macro1' "LFUN 0" _n
          file write `macro1' "DOFF `e' '`denominator`e'''" _n
          if ("`extra'" ~= "") file write `macro1' "EXTR 1" _n
          if ("`pause'"=="") file write `macro1' "PAUS 1" _n
          file write `macro1' _n
        }

        * Poison response
        // assert that response is positive integer?
        if ("`distribution'"=="poisson") {
          file write `macro1' "NOTE   Response distribution, link function and denominator" _n
          file write `macro1' "RDIS `e' 1" _n "LFUN 3" _n
          if ("`extra'" ~= "") file write `macro1' "EXTR 1" _n
          if ("`offset'"~="") file write `macro1' "DOFF `e' '`offset''" _n
          if ("`pause'"=="") file write `macro1' "PAUS 1" _n
          file write `macro1' _n
        }

        * Negative binomial response
        // assert that response is positive integer?
        if ("`distribution'"=="nbinomial") {
          file write `macro1' "NOTE   Response distribution, link function and denominator" _n
          file write `macro1' "RDIS `e' 2" _n "LFUN 3" _n
          if ("`extra'" ~= "") file write `macro1' "EXTR 1" _n
          if ("`offset'"~="") file write `macro1' "DOFF `e' '`offset''" _n
          if ("`pause'"=="") file write `macro1' "PAUS 1" _n
          file write `macro1' _n
        }
      }

      * Levels/Classification identifiers
      file write `macro1' "NOTE   Specify the level identifier(s)" _n
      forvalues l = `maxlevels'(-1)1 {
        local ll = `l'
        if ("`mtype'"=="multivariate" | "`mtype'"=="multinomial") local ++ll
        if ("`lev`l'id'"~="") file write `macro1' "IDEN `ll' '`lev`l'id''" _n
      }
      if ("`mtype'"=="multivariate" | "`mtype'"=="multinomial") file write `macro1' "IDEN 1 'resp_indicator'" _n
      if ("`pause'"=="")  file write `macro1' "PAUS 1" _n
      file write `macro1' _n

      * Specify covariate(s) used anywhere in the model
      file write `macro1' "NOTE   Specify covariate(s) used anywhere in the model" _n

      local allvars :list uniq fp

      forvalues l = `maxlevels'(-1)1 {
        local allvars :list allvars|rp`l'
      }

      * Remove duplicates (for example in Multivariate)
      local allvars :list uniq allvars

      if ("`mtype'"=="multinomial" | "`mtype'"=="multivariate") {
        forvalues e = 1/`numfpbrackets' {
          if "`mtype'"=="multivariate" & "`=word("`distribution'", `e')'" == "binomial" {
            // Take out and put back in bcons.* so they appear in the correct position in the terms
            file write `macro1' "NOTE     Ensure bcons is in the correct place for output" _n "NEXP 0   'bcons.`e''" _n "ERAS 'bcons.`e''" _n
          }
          if "`fp`e''" ~= "" {
            file write `macro1' "RPAT `rpat`e''" _n
            foreach var of varlist `fp`e''{
              file write `macro1' "ADDT   '`var''" _n
            }
            file write `macro1' "RPAT" _n
          }

          if `e' <= `nummlwineqns' {
            forvalues l = `maxlevels'(-1)1 {
              if "`rp`l'_`e''" ~= "" {
                file write `macro1' "RPAT `rppat`l'_`e'' " _n
                forvalues n = 1/`:list sizeof rp`l'name`e'' {
                  if `:list posof "`=word("`rp`l'name`e''", `n')'" in fpname' == 0 {
                    file write `macro1' "ADDT   '`=word("`rp`l'_`e''", `n')''" _n "FPAR 0  '`=word("`rp`l'name`e''", `n')''" _n
                  }
                }
                file write `macro1' "RPAT" _n
              }
            }
          }
        }

        forvalues l = `maxlevels'(-1)1 {
          forvalues e = `=`nummlwineqns'+1'/`numrpbrackets`l'' {
            if "`rp`l'_`e''" ~= "" {
              file write `macro1' "RPAT `rppat`l'_`e'' " _n
              forvalues n = 1/`:list sizeof rp`l'name`e'' {
                if `:list posof "`=word("`rp`l'name`e''", `n')'" in fpname' == 0 {
                  file write `macro1' "ADDT   '`=word("`rp`l'_`e''", `n')''" _n "FPAR 0  '`=word("`rp`l'name`e''", `n')''" _n
                }
              }
              file write `macro1' "RPAT" _n
            }
          }
        }
      }

      if ("`mtype'"=="univariate") {
        forvalues e = 1/`numfpbrackets' {
          foreach var of varlist `fp`e''{
            file write `macro1' "ADDT   '`var''" _n
          }
        }

        * Add to the model any variables in the random part which are not in the fixed part
        * Then remove from the fixed part of the model (but not entirely from the model itself!) any variables which are only in the random part
        local nonfp :list allvars - fp
        if "`nonfp'"~="" {
          foreach var of varlist `nonfp' {
            file write `macro1' "ADDT   '`var''" _n
          }
          foreach var of varlist `nonfp' {
            file write `macro1' "FPAR 0 '`var''" _n
          }
        }
      }

      if ("`pause'"=="") file write `macro1' "PAUS 1" _n
      file write `macro1' _n

      forvalues l = `maxlevels'(-1)1 {
        local ll = `l'
        if ("`mtype'"=="multivariate" | "`mtype'"=="multinomial") local ++ll
        * Level `l' random part covariates
        if "`rp`l''"~="" {
          file write `macro1' "NOTE   Specify level `l' random part covariate(s)" _n
          forvalues e = 1/`numrpbrackets`l'' {
            if "`rp`l'_`e''" != "" {
              foreach var of local rp`l'name`e' {
                if ("`diagonal`l''"=="" & "`elements`l''"=="") {
                  file write `macro1' "SETV `ll' '`var''" _n
                }
                if ("`diagonal`l''"~="") {
                  file write `macro1' "SETE `ll' '`var'' '`var''" _n
                }
              }
            }
          }

          * Add/Remove terms from variance covariance matrices
          if "`elements`l''"~="" {
            local elenames :colnames `RP`l'_b'
            foreach p of local rp`l'pars  { // for each var specified as random at level `l'
              if regexm("`p'", "(cov)[\(]([a-zA-Z0-9_~]+)[\\]([a-zA-Z0-9_~]+)[\)]") == 1 {
                local partype `=regexs(1)'
                local rowvar `=regexs(2)'
                local colvar `=regexs(3)'
                capture unab rowvar:  `rowvar'
                capture unab colvar:  `colvar'
              }
              if regexm("`p'", "(var)[\(]([a-zA-Z0-9_]+)[\)]") == 1 {
                local partype `=regexs(1)'
                local rowvar `=regexs(2)'
                local colvar `=regexs(2)'
                capture unab rowvar:  `rowvar'
                capture unab colvar:  `colvar'
              }

              assert inlist("`partype'","var","cov")
              if `:list p in elenames' {
                if "`mtype'" == "multivariate" {
                  local rowvar = reverse(subinstr(reverse("`rowvar'"), "_", ".", 1))
                  local colvar = reverse(subinstr(reverse("`colvar'"), "_", ".", 1))
                }
                file write `macro1' "SETE `ll' '`rowvar'' '`colvar''" _n
              }
            }
          }
          if ("`pause'"=="") file write `macro1' "PAUS 1" _n
          file write `macro1' _n
        }
      }

      * Apply random part design matrix if set
      forvalues l = `maxlevels'(-1)1 {
        if "`design`l''"~="" {
          file write `macro1' "NOTE   Apply the design matrix for the random part at level `l'" _n
          foreach alphaname of local design`l' {
            file write `macro1' "SETD `l' '`alphaname''" _n
          }
          file write `macro1' _n
        }
      }

      * Need to fit the ordered model for at least two iterations before we can impose starting values
      //if ("`mcmc'"~="" & "`cc'" == "") | ("`inits'"~="" & ("`link'"=="ologit" | "`link'"=="oprobit" | "`link'"=="ocloglog" | "`link'"=="mlogit")) { // CMJC added check for mlogit to get model in the correct state for lowest level residuals (e.g. adds P/-P parameter which will then be removed later)
      if ("`mcmc'"~="" & "`cc'" == "") | ("`link'"=="ologit" | "`link'"=="oprobit" | "`link'"=="ocloglog" | "`link'"=="mlogit") { // CMJC added check for mlogit to get model in the correct state for lowest level residuals (e.g. adds P/-P parameter which will then be removed later)
        file write `macro1' "NOTE   Fit model for two iterations to correctly setup the model (this is only required for the multilevel ordered multinomial model)" _n
        if "`linearization'"=="MQL1" file write `macro1' "LINE 0 1" _n
        if "`linearization'"=="MQL2" file write `macro1' "LINE 0 2" _n
        if "`linearization'"=="PQL1" file write `macro1' "LINE 1 1" _n
        if "`linearization'"=="PQL2" file write `macro1' "LINE 1 2" _n

        //file write `macro1' "MAXI 2" _n "BATCH 1" _n "STAR" _n "ITNU 0" _n(2)
        file write `macro1' "MAXI 2" _n "BATCH 1" _n "STAR" _n(2)

        // set the maximum iterations back to the default if not set
        if "`maxiterations'" == "" local maxiterations 20
        local modelstarted 1
      }

      * Fixed part constraint(s)
      if "`fpconstraints'"~="" {
        file write `macro1' "NOTE   Specify fixed part constraint(s)" _n
        file write `macro1' "FCON b1001" _n
        forvalues r = 1/`numfpconstraints' {
          file write `macro1' "JOIN   cb1001 `fpconstraint`r'' cb1001" _n
          //file write `macro1' "JOIN   c1001 `fpconstraint`r'' c1001" _n
        }
        //file write `macro1' "FCON   c1001" _n(2) // note that this column will not be free if multinomial or multivariate has been specified
      }

      * Random part constraint(s)
      if "`rpconstraints'"~="" {
        file write `macro1' "NOTE   Specify random part constraint(s)" _n
        file write `macro1' "RCON b1002" _n
        forvalues r = 1/`numrpconstraints' {
          file write `macro1' "JOIN   cb1002 `rpconstraint`r'' cb1002" _n
          //file write `macro1' "JOIN   c1002 `rpconstraint`r'' c1002" _n
        }
        //file write `macro1' "RCON   c1002" _n(2) // note that this column will not be free if multinomial or multivariate has been specified
      }
    }

    * Edit vector of initial values
    if "`inits'"~="" {
      runmlwin_setinit, fpb(`matFP_b') fpv(`matFP_V') rpb(`matRP_b') rpv(`matRP_V') initb(`matb') initv(`matV') mtype(`mtype') link(`link') mcmc(`mcmc') macro1(`macro1')
    }
    if "`inits'"~="" | "`useworksheet'" ~= "" {
      file write `macro1' "ESTM 2" _n // switch from coloured symbols to point estimates
      if ("`pause'"=="") file write `macro1' "PAUS 1" _n  // update equations window
      file write `macro1' _n
    }

    *************************
    * Fit model using (R)IGLS
    *************************
    if "`mcmc'"=="" { // i.e. (R)IGLS
      if "`useworksheet'" == "" {
        * Specify estimation method (R)IGLS
        if "`rigls'"~="" {
          file write `macro1' "NOTE   Set estimation method to be RIGLS" _n "METH 0" _n(2)
        }
        else {
          file write `macro1' "NOTE   Set estimation method to be IGLS" _n "METH 1" _n(2)
        }

        * Specify maximum number of iterations
        if "`maxiterations'"~="" {
          file write `macro1' "NOTE   Set maximum number of (R)IGLS iterations" _n "MAXI `maxiterations'" _n(2)
        }

        // Why is MQL2 the default in MLwiN for poisson models?
        // What about negbin is there the same problem?
        if "`distribution'"=="poisson" & "`linearization'"=="MQL1" file write `macro1' "NOTE   Set estimation method to be MQL1" _n "LINE 0 1" _n(2)
        if "`linearization'"=="MQL2" file write `macro1' "NOTE   Set estimation method to be MQL2" _n "LINE 0 2" _n(2)
        if "`linearization'"=="PQL1" file write `macro1' "NOTE   Set estimation method to be PQL1" _n "LINE 1 1" _n(2)
        if "`linearization'"=="PQL2" file write `macro1' "NOTE   Set estimation method to be PQL2" _n "LINE 1 2" _n(2)

        * Allow negative variances
        local reseton = 0
        forvalues l = `maxlevels'(-1)1 {
          if "`reset`l''"~="" local reseton = 1
        }
        if `reseton' == 1 {
          file write `macro1' "NOTE   Specify element reset options for variance-covariance matrices" _n
          forvalues l = `maxlevels'(-1)1 {
            if "`reset`l''"=="all" file write `macro1' "RESE `l' 0" _n
            if "`reset`l''"=="variances" file write `macro1' "RESE `l' 1" _n
            if "`reset`l''"=="none" file write `macro1' "RESE `l' 2" _n
          }
          file write `macro1' "" _n
        }

        * Weights
        forvalues l = `maxlevels'(-1)1 {
          if "`weight`l''" ~= "" | "`weighttype'" ~= "" {

            if "`weight`l''" ~= "" {
              file write `macro1' "NOTE   Specify sampling weights at level `l'" _n "WEIG `l' 1 '`weight`l'''" _n(2)
            }
            else {
              file write `macro1' "NOTE   Specify equal weights at level `l'" _n "WEIG `l' 1" _n(2)
            }
            if "`weighttype'" == "standardised" {
              file write `macro1' "NOTE   Standardised weighting" _n
              file write `macro1' "LINK 1 G21" _n
              file write `macro1' "FILL G21" _n
              file write `macro1' "WEIG `l' 2 G21[1]" _n
              file write `macro1' "LINK 0 G21" _n
              file write `macro1' "WEIG 2" _n(2)
            }
            if "`weighttype'" == "raw" {
              file write `macro1' "NOTE   Raw weighting" _n
              // MLwiN appears to require this to be set, even if raw weights are used (I think this is a bug)
              file write `macro1' "LINK 1 G21" _n
              file write `macro1' "FILL G21" _n
              file write `macro1' "WEIG `l' 2 G21[1]" _n
              file write `macro1' "LINK 0 G21" _n
              file write `macro1' "WEIG 1" _n(2)
            }
          }
        }
        if "`weighttype'"~="" { // if weights have been specified
          if "`weighttype'"=="standardised" {
            file write `macro1' "NOTE   Create the standardised weights" _n "WEIG" _n(2)
          }
        }
        if "`fpsandwich'"=="fpsandwich" | ("`weighttype'"~="" & "`fpsandwich'"==""){
          file write `macro1' "NOTE   Turn on sandwich estimators for the fixed part parameter standard errors" _n "FSDE 2" _n(2)
        }

        if "`rpsandwich'"=="rpsandwich" | ("`weighttype'"~="" & "`rpsandwich'"==""){
          file write `macro1' "NOTE   Turn on sandwich estimators for the random part parameter standard errors" _n "RSDE 2" _n(2)
        }
      }

      * Pause
      if ("`pause'"=="") {
        file write `macro1' "NOTE   Pause the macro to allow the user to examine the model specification" _n "PAUS" _n(2)
      }

      * Fit the model
      file write `macro1' "NOTE   Fit the model" _n
      if "`inits'"=="" & "`useworksheet'" == "" & "`modelstarted'" == "" file write `macro1' "STAR" _n // do one iteration as batch 1 not yet set (this is to get sensible numbers for the equations window)
      else {
        if ("`initsprevious'"~="") display as text "Model fitted using initial values specified as parameter estimates from previous model" _n
        if ("`initsmodel'"~="") display as text "Model fitted using initial values specified as parameter estimates from saved estimates in `initsmodel'" _n
        if ("`initsb'"~=""|"`initsv'"~="") display as text "Model fitted using initial values specified in matrices: " as result "`initsb' `initsv'" _n
        if ("`useworksheet'"~="") display as text "Model fitted using state from previously saved worksheet" _n
      }

      if ("`pause'"=="") {
        file write `macro1' "ESTM 2" _n // switch from coloured symbols to point estimates
        file write `macro1' "PAUS 1" _n // update equations window
      }
      file write `macro1' "BATC 1" _n
      if ("`inits'"~="" & ("`link'"=="ologit"|"`link'"=="oprobit"|"`link'"=="ocloglog")) file write `macro1' "SUMM" _n // This is a fix as the ordered model forgets its structure when initial values have been specified
      file write `macro1' "NEXT" _n
      file write `macro1' "MONI 1" _n
      file write `macro1' "ITNU 0 b21" _n
      file write `macro1' "CONV b22" _n

      if ("`pause'"=="") file write `macro1' "PAUS 1" _n
      file write `macro1' _n
    }

    **********************
    * Fit model using MCMC
    **********************
    if ("`mcmc'"~="") { // i.e. MCMC

      if "`useworksheet'" == "" {
        * Model specification: Cross-classifications
        file write `macro1' "NOTE   Set estimation method to MCMC" _n
        file write `macro1' "EMODe 3" _n
        if ("`pause'"=="") file write `macro1' "EXPA 3" _n // Expand to show priors
        file write `macro1' _n

        * MM Weights
        if "`carcentre'" ~= "" file write `macro1' "CARC 1" _n
        forvalues l = 2/`maxlevels' {
          local ll = `l'
          if ("`mtype'"=="multivariate" | "`mtype'"=="multinomial") local ++ll

          if "`mmweights`l''" ~= "" {
            file write `macro1' "NOTE   Declare weights at level `l'" _n
            if "`car`l''"~="" {
              file write `macro1' "MULM `ll' `:list sizeof mmweights`l'' '`=word("`mmweights`l''", 1)'' '`=word("`mmids`l''", 1)''" _n "CARP `ll' 1" _n
            }
            else {
              if "`=word("`mmids`l''", 1)'" ~= "`lev`l'id'" {
                display as error "The first var in mmids`l'() must match the level `l' ID specified in level`l'()."
                exit 198
              }
              if "`mtype'"~="multivariate" {
                file write `macro1' "MULM `ll' `:list sizeof mmweights`l'' '`=word("`mmweights`l''", 1)''" _n
              }
              else {
                file write `macro1' "MULM `ll' `:list sizeof mmweights`l'' '`=word("`mmweights`l''", 1)'' '`=word("`mmids`l''", 1)''" _n
              }
            }
          }
        }

        * Cross-classified models
        if ("`cc'"~="") {
          file write `macro1' "NOTE   Declare model to be a cross-classifed model and switch to classification notation" _n "XCLA 1" _n /* switch on cross-classifications */ "INDE 1" _n(2) /* switch on classification notation */
        }

        * Define measurement error if defined
        if "`me'"~="" {
          * measurement error
          file write `macro1' "NOTE   Specify measurement error" _n
          local mecols
          local i = 1
          foreach p of local mevars {
            local mecols `mecols' '`p'' `:word `i' of `variances''
            local ++i
          }
          file write `macro1' "MERR `:list sizeof mevars' `mecols'" _n
          file write `macro1' _n
        }

        * Correlated residuals
        if "`corresiduals'" ~= "" {
          file write `macro1' "NOTE   Set up correlated residuals" _n
          //if "`corresiduals'" == "full" { // default
          //  file write `macro1' "NOTE   full covariance matrix" _n
          //  file write `macro1' "MCCO 0" _n
          //}
          if "`corresiduals'" == "exchangeable" file write `macro1' "NOTE   all correlations equal and all variances equal" _n "MCCO 1" _n
          if "`corresiduals'" == "areqvars" file write `macro1' "NOTE   an AR1 structure with all variances equal" _n "MCCO 2" _n
          if "`corresiduals'" == "eqcorrsindepvars" file write `macro1' "NOTE   all correlations equal but independent variances" _n "MCCO 3" _n
          if "`corresiduals'" == "arindepvars" file write `macro1' "NOTE   an AR1 structure with independent variances" _n "MCCO 4" _n
        }

        * Use multiple subscripts notation
        if ("`msubscripts'"~="") {
          file write `macro1' "NOTE   Use multiple subscripts notation" _n
          file write `macro1' "INDE 1" _n(2)
        }

        * Set MCMC seed
        file write `macro1' "NOTE   Set MCMC seed" _n "MCRS `mcmc_seed'" _n(2)

        if "`smcmc'" ~= "" {
          file write `macro1' "NOTE   Turn on structured MCMC" _n
          file write `macro1' "SMCM 1" _n(2)
        }

        if "`smvn'" ~= "" {
          file write `macro1' "NOTE   Turn on structured MVN" _n
          file write `macro1' "SMVN 1" _n(2)
        }

        if "`orthogonal'" ~= "" {
          file write `macro1' "NOTE   Turn on orthogonal parameterisation" _n
          file write `macro1' "ORTH 1" _n(2)
        }

        if "`hcentring'" ~= "" {
          file write `macro1' "NOTE   Turn on hierarchical centring" _n
          file write `macro1' "HCEN 1 `hcentring'" _n(2)
        }

        if "`logformulation'" ~= "" {
          file write `macro1' "NOTE   Use log formulation" _n
          file write `macro1' "LCLO 1" _n(2)
        }

        if `defaultprior' == 1 {
          file write `macro1' "NOTE   Set prior distribution parameters" _n
          file write `macro1' "GAMP `gama' `gamb'" _n(2)
        }

        forvalues l = 2/`maxlevels' {
          local ll = `l'
          if ("`mtype'"=="multivariate" | "`mtype'"=="multinomial") local ++ll

          if "`parexpansion`l''" ~= "" {
            file write `macro1' "NOTE   Turn on parameter expansion at level `l'" _n
            file write `macro1' "PAEX `ll' 1" _n(2)
          }
        }

        * Informative priors
        if "`priormatrix'" ~= "" {
          local priorcol c1092
          runmlwin_writepriors, maxlevels(`maxlevels') priormat(`priormatrix') fpb(`matFP_b') rpb(`matRP_b') macro1(`macro1') priorcol(`priorcol')
        }

        * Add factors if specified
        local numfact = 0
        local numcorr = 0
        forvalues l = 1/`maxlevels' {
          if "`flinit`l''" ~= "" {
            local numfact = `numfact' + colsof(`flinit`l'')
            forvalues i = 1/`=colsof(`flinit`l'')' {
              forvalues j = 1/`=`i'-1' {
                if `fvinit`l''[`i',`j'] ~= . {
                  local ++numcorr
                }
              }
            }
          }
        }
        local factstr ""
        forvalues l = 1/`maxlevels' {
          if "`flinit`l''" ~= "" {
            forvalues fact = 1/`=colsof(`flinit`l'')' {
              local factstr `factstr' `=`l'+1'
              forvalues resp = 1/`=rowsof(`flinit`l'')' {
                local factstr `factstr' `=`flinit`l''[`resp',`fact']' `=`flconstraint`l''[`resp', `fact']'
              }
              local factstr `factstr' `=`fvinit`l''[`fact', `fact']' `=`fvconstraint`l''[`fact', `fact']'
            }
          }
        }
        forvalues l = 1/`maxlevels' {
          if "`flinit`l''" ~= "" {
            forvalues fact1 = 1/`=colsof(`flinit`l'')' {
              forvalues fact2 = 1/`=`fact1'-1' {
                if `fvinit`l''[`fact1', `fact2'] ~= . {
                  local factstr `factstr' `fact1' `fact2' `=`fvinit`l''[`fact1', `fact2']' `=`fvconstraint`l''[`fact1', `fact2']'
                }
              }
            }
          }
        }

        if "`factstr'" ~= "" {
          file write `macro1' "NOTE set up factors" _n
          file write `macro1' "FACT `nummlwineqns' `numfact' `numcorr' `factstr'" _n
        }

        local useresid "1" // Use IGLS residuals as starting values

        local residcol
        local residsecol

        // Simulate residuals from the covariance matrix
        if "`simresiduals'" ~= "" {
          file write `macro1' "LINK 2 G27" _n // Starting residuals columns
          file write `macro1' "FILL G27" _n
          local hasres = 0
          local residcol G27[1]
          local residsecol G27[2]

          local useresid = ""
          forvalues l = 1/`maxlevels' {
            local ll = `l'
            if ("`mtype'"=="multivariate" | "`mtype'"=="multinomial") local ++ll

            file write `macro1' "LINK 1 G22" _n
            file write `macro1' "LINK `numresi`l'' G23" _n

            if "`numrp`l'pars'" ~= "" {
              file write `macro1' "OMEGa `ll' G22[1]" _n
              file write `macro1' "CALC G22[1] = HSYM(G22[1])" _n
              file write `macro1' "NOBS `ll' b31 b32" _n
              file write `macro1' "MRAN b31 G22[1] G23" _n
              forvalues i = 1/`numresi`l'' {
                if `hasres' == 0 { // remove zero that fill command has put into this column
                  file write `macro1' "ERAS G27" _n
                  local hasres = 1
                }
                file write `macro1' "JOIN G27[1] G23 G27[1]" _n
              }
            }
            file write `macro1' "ERASe G22" _n
            file write `macro1' "ERASe G23" _n
            file write `macro1' "LINK 0 G22" _n "LINK 0 G23" _n

          }
          file write `macro1' "CALC G27[2] = G27[1] * 0" _n
        }

        if "`useresid'" ~= "" & "`cc'" == "" & (`maxlevels' > 1 | "`mtype'" == "multivariate" | ("`mtype'" == "multinomial" & "`link'"=="mlogit")){
          * Calculate MCMC starting values for level `l' residuals

          // set up PRE and POST file
          if `allnormal' == 1 {
            file write `macro1' "PREF 0" _n
            file write `macro1' "POST 0" _n
          }
          else {
            local path `mlwinpath'
            local revpath `=reverse("`path'")'
            local revpath `=substr("`revpath'", `=strpos("`revpath'", "\")+1' , .)'
            local path `=reverse("`revpath'")'

            if "`mtype'"=="multinomial" {
              capture confirm file `"`path'\multicat\PRE"'
              if !_rc file write `macro1' "FPAT '`path'\multicat'" _n
              else {
                local revpath `=reverse("`path'")'
                local revpath `=substr("`revpath'", `=strpos("`revpath'", "\")+1' , .)'
                local path `=reverse("`revpath'")'
                capture confirm file `"`path'\multicat\PRE"'
                if !_rc file write `macro1' "FPAT '`path'\multicat'" _n
              }
            }
            else{
              capture confirm file `"`path'\discrete\PRE"'
              if !_rc file write `macro1' "FPAT '`path'\discrete'" _n
              else {
                local revpath `=reverse("`path'")'
                local revpath `=substr("`revpath'", `=strpos("`revpath'", "\")+1' , .)'
                local path `=reverse("`revpath'")'
                capture confirm file `"`path'\discrete\PRE"'
                if !_rc file write `macro1' "FPAT '`path'\discrete'" _n
              }
            }
            file write `macro1' "PREF 'PRE'" _n
            file write `macro1' "POST 'POST'" _n
            file write `macro1' "PREF 1" _n
            file write `macro1' "POST 1" _n

            if "`mtype'" == "multinomial" {
              file write `macro1' "SETV 1 'bcons.1'" _n
            }

            if "`linearization'" == "PQL2" & "`maxlevels'" == "1" {
              forvalues lev = `maxlevels'/5 {
                file write `macro1' "OFFS `lev'" _n
              }
              display as error "can not apply PQL or 2nd order to single level models, switching to MQL/1"
              local linearization MQL1
            }

            // NOTE at this point MLwiN sets EXTR 0, LINE 0 1 if these are not set
            if "`linearization'" == "" | "`linearization'" == "MQL1" file write `macro1' "LINE 0 1" _n // cmjc added for poisson
            if "`linearization'"=="MQL2" file write `macro1' "LINE 0 2" _n
            if "`linearization'"=="PQL1" file write `macro1' "LINE 1 1" _n
            if "`linearization'"=="PQL2" file write `macro1' "LINE 1 2" _n

            // Extra is not valid for MCMC estimation
            file write `macro1' "EXTR 0" _n // cmjc added for poisson

            local llev = 1
            if "`mtype'"=="multivariate" | "`mtype'"=="multinomial" local ++llev

            forvalues lev = `llev'/`maxlevels' {
              file write `macro1' "OFFS `lev'" _n
            }

            if "`mtype'" ~= "multivariate" { // i.e. univariate response models
              local b

              foreach var of local rp1name {
                if "`var'" ~= "P" & "`var'" ~= "-P" local b `b' '`var''
              }

              if "`distribution'" == "nbinomial" local b 'bcons.1' 'bcons2.1'
              else local b 'bcons.1'

              if `:list sizeof b' == 0 & "`mtype'" ~= "multinomial" display as error "Level 1 random structure must be specified for discrete response models"
              if `:list sizeof b' ~= 0 file write `macro1' "LINK `b' g9" _n

              if  "`mtype'"=="multinomial" & ~inlist("`link'","mlogit","ologit","oprobit","ocloglog")  {
                display as error "link function must be mlogit, ologit, oprobit or ocloglog"
                exit 198
              }

              if "`mtype'"=="multinomial"  {
                if "`link'"=="mlogit" file write `macro1' "SET b10 0" _n
                if "`link'"=="ologit"|"`link'"=="oprobit"|"`link'"=="ocloglog" file write `macro1' "SET b10 1" _n
              }
              else file write `macro1' "SET b10 `resptype'" _n // i.e. a univariate response which is not multinomial

              file write `macro1' "SET b15 1" _n
              file write `macro1' "SET b16 0" _n
            }
            else { // i.e. multivariate response models
              local b
              local c
              forvalues eq = 1/`nummlwineqns' {
                foreach var of local rp1name`eq' {
                  if "`=word("`distribution'", `eq')'" ~= "normal" local b `b' '`var''
                  else local c `c' '`var''
                }
                foreach var of local fpname`eq' {
                  if "`=word("`distribution'", `eq')'" == "normal" local c `c' '`var''
                }
              }
              if "`b'" == "" display as error Level 2 random structure must be specified for discrete responses"
              file write `macro1' "LINK `b' g9" _n
              file write `macro1' "SET b10 `resptype'" _n
              file write `macro1' "SET b15 2" _n
              if `mixed' == 0 file write `macro1' "SET b16 0" _n
              else {
                file write `macro1' "SET b16 1" _n
                file write `macro1' "LINK `c' g11" _n
              }
            }
            // LINK
            file write `macro1' "LINK -5 g19 1" _n
            file write `macro1' "LINK 0 g18" _n
            file write `macro1' "CALC g18=g19" _n

            file write `macro1' "ITNU 1 2" _n // Set R(IGLS) iteration to 2 so that residuals are calculated correctly
          }

          file write `macro1' "MISR 0" _n // Don't set small residuals to system missing
          file write `macro1' "LINK 2 G27" _n // Starting residuals columns
          file write `macro1' "FILL G27" _n
          local hasres = 0
          local residcol G27[1]
          local residsecol G27[2]

          forvalues l = 1/`maxlevels' {
            local ll = `l'
            if "`mtype'"=="multivariate" | "`mtype'"=="multinomial" local ++ll
            local numresi = `numrp`l'vars'
            if "`mtype'"=="multinomial" & "`link'"=="mlogit" & `l' == 1 local numresi = `numresi' + 2
            if (`numresi'>=1 & `ll' != 1) {
              file write `macro1' "LINK `numresi' G22" _n
              file write `macro1' "FILL G22" _n
              file write `macro1' "LINK 1 G23" _n
              file write `macro1' "FILL G23" _n

              file write `macro1' "NOTE   Calculate MCMC starting values for level `l' residuals" _n
              file write `macro1' "RLEV `ll'" _n
              file write `macro1' "RFUN" _n
              file write `macro1' "RCOV 2" _n
              file write `macro1' "ROUT   G22 G23" _n
              file write `macro1' "RESI" _n
              if `hasres' == 0 { // remove zero that fill command has put into this column
                file write `macro1' "ERAS G27" _n
                local hasres 1
              }
              file write `macro1' "JOIN   G27[1] G22 G27[1]" _n
              file write `macro1' "JOIN   G27[2] G23 G27[2]" _n
              file write `macro1' "ERAS   G22 G23" _n
              file write `macro1' "LINK 0 G22" _n "LINK 0 G23" _n(2)
            }
          }

          file write `macro1' "MISR 1" _n

          if `allnormal' != 1 {
            // UNLINK
            file write `macro1' "CALC g19=g18" _n
            file write `macro1' "ERASe g18" _n
            file write `macro1' "LINK 0 g18" _n
          }
        }
      }

      * Pause
      // AT THIS POINT THE MULTIVARIATE WISHART DATA INFORMED PRIOR FOR THE LEVEL 2 MATRIX OF A TWO-LEVEL RANDOM SLOPES MODEL HAS NOT BEEN SET
      if ("`pause'"=="") {
        file write `macro1' "NOTE   Pause the macro to allow the user to examine the model specification" _n
        file write `macro1' "PAUS" _n(2)
      }

      * MCMC Estimation algorithm
      if ("`distribution'"=="normal") file write `macro1' "NOTE   Fit the model in MCMC using Gibbs algorithm (response is normal)" _n // But probit is fit with GIBBS
      if ("`distribution'"~="normal") file write `macro1' "NOTE   Fit the model in MCMC using Metropolis Hastings algorithm (response is discrete)" _n

      if ("`savewinbugs'"~="") {
        local 0 , `savewinbugs'
        syntax , Model(string) Inits(string) Data(string) [noFit]

        local 0 `inits'
        syntax anything(name=inits), [REPLACE]
        if "`replace'" == "" confirm new file "`inits'"
        local 0 `data'
        syntax anything(name=data), [REPLACE]
        if "`replace'" == "" confirm new file "`data'"
        local 0 `model'
        syntax anything(name=model), [REPLACE]
        if "`replace'" == "" confirm new file "`model'"
        local linkcode 0 // needs to be set (0 for logit, 1 for probit, 2 for complementary log-log and 3 for log link)
        if "`link'" == "logit" local linkcode 0
        if "`link'" == "probit" local linkcode 1
        if "`link'" == "cloglog" local linkcode 2
        if "`link'" == "log" local linkcode 3
        if "`mtype'" == "multivariate" local linkcode 0
        if "`mcmc_modeltype'" == "5"{
          display as error "WinBUGS in unable to estimate multivariate models with responses other than normal"
          exit 198
        }

        file write `macro1' "BUGO 6 `mcmc_modeltype' `linkcode' `residcol' `priorcol' '`model'' '`inits'' '`data''" _n // MCMC chains
      }

      local chaincols 0
      forvalues l = 1/`maxlevels' {
        if "`saveresiduals`l''" ~= "" local ++chaincols
      }
      if "`factstr'" ~= "" local chaincols = `chaincols' + 2

      if `chaincols' > 0 file write `macro1' "LINK `chaincols' G22" _n

      local i = 1
      forvalues l = 1/`maxlevels' {
        local ll = `l'
        if ("`mtype'"=="multivariate" | "`mtype'"=="multinomial") local ++ll

        if "`saveresiduals`l''" ~= "" {
          file write `macro1' "NOTE   store residual chain for level `l'" _n
          file write `macro1' "NAME G22[`i'] 'RESID_CHAIN_LEVEL`l''" _n
          file write `macro1' "DESC G22[`i'] '\Value'" _n
          file write `macro1' "SMRE `ll' 'RESID_CHAIN_LEVEL`l''" _n(2)
          local ++i
        }
      }

      if "`factstr'" ~= "" {
        file write `macro1' "NAME G22[`i'] '_FACT_LOAD_CHAIN'" _n
        local ++i
        file write `macro1' "NAME G22[`i'] '_FACT_VAR_CHAIN'" _n
        local ++i
        file write `macro1' "SMFA 1 '_FACT_LOAD_CHAIN'" _n
        file write `macro1' "SMFA 2 '_FACT_VAR_CHAIN'" _n
        file write `macro1' "LINK 0 G22" _n(2)
      }

      if "`fit'" ~= "nofit" {
        if "`useworksheet'" == "" {
          if "`mtype'" == "multinomial" file write `macro1' "CLRV 2" _n // I'm not sure why this is needed
          file write `macro1' "MTOT `mcmc_chain'" _n
          file write `macro1' "MCMC 0 `mcmc_burnin' `mcmc_adaptation' `mcmc_scale' `mcmc_acceptance' `mcmc_tolerance' `residcol' `residsecol' `priorcol' `mcmc_femethod' `mcmc_remethod' `mcmc_levelonevarmethod' `mcmc_higherlevelsvarmethod' `mcmc_defaultprior' `mcmc_modeltype'" _n
          if "`residcol'" ~= "" file write `macro1' "ERAS G27" _n
          if "`residcol'" ~= "" file write `macro1' "LINK 0 G27" _n
        }
        local total_stored = ceil(`mcmc_chain' / `mcmc_thinning')
        if ("`batch'"=="") {    // split MCMC chain into 50 (stored) iterations at a time then update
          file write `macro1' _n
          local curriter 0 // Unthinned iterations
          if "`imputeiterations'" ~= "" {
            local nextimpute `:word 1 of `imputeiterations''
            local imputeiterations `:list imputeiterations - nextimpute'
          }
          while `curriter' + (`mcmc_refresh' * `mcmc_thinning') <= `mcmc_chain' {
            local curriter = `curriter' + (`mcmc_refresh' * `mcmc_thinning')
            if "`nextimpute'" ~= "" {
              local impiter = `curriter' - (`mcmc_refresh' * `mcmc_thinning')
              while (`nextimpute' > `curriter' - (`mcmc_refresh' * `mcmc_thinning')) & (`nextimpute' <= `curriter') {
                local nextstop = (`nextimpute' / `mcmc_thinning') - ceil(`impiter' / `mcmc_thinning')
                local impiter = `impiter' + (`nextstop' * `mcmc_thinning')
                file write `macro1' "MCMC 1 `nextstop' `mcmc_thinning' c1090 c1091 c1003 c1004 1 `mcmc_modeltype'" _n
                file write `macro1' "LINK 1 G21" _n
                file write `macro1' "DAMI 0 G21[1]" _n // Impute
                file write `macro1' "LINK `nummlwineqns' G22" _n
                file write `macro1' "SPLI G21[1] 'resp_indicator' G22" _n
                forvalues e = 1/`nummlwineqns' {
                  file write `macro1' "NAME G22[`e'] '_mi_`response`e'''" _n
                }
                tempfile impfile
                //tempname fh
                //file open `fh' using "`impfile'", write
                //file close `fh'

                file write `macro1' "PSTA '`impfile'' '`_sortindex'' G22" _n
                local imputefiles `" `imputefiles' "`impfile'" "'
                file write `macro1' "ERAS G21 G22" _n
                file write `macro1' "LINK 0 G21" _n "LINK 0 G22" _n
                file write `macro1' "PUPN c1003 c1004" _n
                file write `macro1' "AVER c1091 b99 b100" _n
                file write `macro1' "PAUS 1" _n(2)
                local nextimpute `:word 1 of `imputeiterations''
                local imputeiterations `:list imputeiterations - nextimpute'
                if "`nextimpute'" == "" continue, break
              }
              local nextstop = ceil((`curriter' - `impiter') / `mcmc_thinning')
              if `nextstop' ~= 0 {
                file write `macro1' "MCMC 1 `nextstop' `mcmc_thinning' c1090 c1091 c1003 c1004 1 `mcmc_modeltype'" _n
                file write `macro1' "PUPN c1003 c1004" _n "AVER c1091 b99 b100" _n "PAUS 1" _n(2)
              }
            }
            else {
              file write `macro1' "MCMC 1 `mcmc_refresh' `mcmc_thinning' c1090 c1091 c1003 c1004 1 `mcmc_modeltype'" _n
              file write `macro1' "PUPN c1003 c1004" _n "AVER c1091 b99 b100" _n "PAUS 1" _n(2)
            }
          }
          if `mcmc_chain' - `curriter' ~= 0 {
            local remainder = ceil((`mcmc_chain' - `curriter') / `mcmc_thinning')
            file write `macro1' "MCMC 1 `remainder' `mcmc_thinning' c1090 c1091 c1003 c1004 1 `mcmc_modeltype'" _n
            file write `macro1' "PUPN c1003 c1004" _n "AVER c1091 b99 b100" _n "PAUS 1" _n(2)
          }
        }
        else {
          if "`imputeiterations'" ~= "" {
            local curriter 0 // Thinned iterations
            while "`imputeiterations'" ~= "" {
              local nextimpute `:word 1 of `imputeiterations''
              local imputeiterations `:list imputeiterations - nextimpute'
              local nextstop = (`nextimpute' / `mcmc_thinning') - `curriter'
              local curriter = `curriter' + `nextstop'
              file write `macro1' "MCMC 1 `nextstop' `mcmc_thinning' c1090 c1091 c1003 c1004 1 `mcmc_modeltype'" _n(2)
              file write `macro1' "LINK 1 G21" _n
              file write `macro1' "DAMI 0 G21[1]" _n // Impute
              file write `macro1' "LINK `nummlwineqns' G22" _n
              file write `macro1' "SPLI G21[1] 'resp_indicator' G22" _n
              forvalues e = 1/`nummlwineqns' {
                file write `macro1' "NAME G22[`e'] 'imp`response`e'''" _n
              }
              tempfile impfile
              //tempname fh
              //file open `fh' using "`impfile'", write
              //file close `fh'

              file write `macro1' "PSTA '`impfile'' '`_sortindex'' G22" _n
              local imputefiles `" `imputefiles' "`impfile'" "'
              file write `macro1' "ERAS G21 G22" _n
              file write `macro1' "LINK 0 G21" _n "LINK 0 G22" _n
              file write `macro1' "PUPN c1003 c1004" _n
              file write `macro1' "AVER c1091 b99 b100" _n(2)
            }
            local nextstop = `total_stored' - `curriter'
            if `nextstop' ~= 0 {
              file write `macro1' "MCMC 1 `nextstop' `mcmc_thinning' c1090 c1091 c1003 c1004 1 `mcmc_modeltype'" _n(2)
              file write `macro1' "PUPN c1003 c1004" _n
              file write `macro1' "AVER c1091 b99 b100" _n(2)
            }
          }
          else {
            file write `macro1' "MCMC 1 `total_stored' `mcmc_thinning' c1090 c1091 c1003 c1004 1 `mcmc_modeltype'" _n(2)
            file write `macro1' "PUPN c1003 c1004" _n
            file write `macro1' "AVER c1091 b99 b100" _n(2)
          }
        }
        if ("`pause'"=="") file write `macro1' "PAUS 1" _n(2)
      }
    }

    if "`fit'" ~= "nofit" {
      if "`imputesummaries'" ~= "" {
        file write `macro1' "LINK 2 G21" _n
        file write `macro1' "DAMI 2 G21[1] G21[2]" _n // Impute
        file write `macro1' "LINK `nummlwineqns' G22" _n
        file write `macro1' "SPLI G21[1] 'resp_indicator' G22" _n
        forvalues e = 1/`nummlwineqns' {
          file write `macro1' "NAME G22[`e'] '_simean_`response`e'''" _n
        }
        file write `macro1' "LINK `nummlwineqns' G23" _n
        file write `macro1' "SPLI G21[2] 'resp_indicator' G23" _n
        forvalues e = 1/`nummlwineqns' {
          file write `macro1' "NAME G23[`e'] '_sisd_`response`e'''" _n
        }

        tempfile imputesummaries
        //tempname fh
        //file open `fh' using "`imputesummaries'", write
        //file close `fh'

        file write `macro1' "PSTA '`imputesummaries'' '`_sortindex'' G22 G23" _n
        file write `macro1' "ERAS G21 G22 G23" _n
        file write `macro1' "LINK 0 G21" _n "LINK 0 G22" _n "LINK 0 G23" _n
      }

      if "`batch'" == "" {
        * Open the equations window
        if ("`pause'"=="nopause") {
          file write `macro1' "NOTE   Open the equations window" _n
          file write `macro1' "WSET 15 1" _n    // open the equations window to indicate that the model has finished iterating but don't display anything
          file write `macro1' "EXPA 3" _n
          file write `macro1' "ESTM 2" _n
        }

        * If any random part design matrices have been specified then open the output window and display the random part parameters
        if "`anydesign'"=="yes"{
          file write `macro1' "WSET 20 1" _n
          file write `macro1' "ECHO 1" _n
          file write `macro1' "FIXE" _n
          file write `macro1' "RAND" _n
          file write `macro1' "ECHO 0" _n
        }
      }

      *******************
      * Calculate Residuals
      *******************
      forvalues l = `maxlevels'(-1)1 {
        if ("`residuals`l''"~=""){
          tempfile residfile`l'
          //tempname fh
          //file open `fh' using "`residfile`l''", write
          //file close `fh'
          local lids
          forvalues lev = `maxlevels'(-1)1 {
            local lids `lids' lev`lev'id(`lev`lev'id')
          }
          runmlwin_calcresiduals , level(`l') levxid(`lev`l'id') numrpxvars(`numresi`l'') rpxvars(`resivars`l'') residualsx(`residuals`l'') mtype(`mtype') `residstd`l'' `residlever`l'' `residinfl`l'' `residdel`l'' `residsamp`l'' `residref`l'' `residvar`l'' `residrecode`l'' `residrpadj`l'' `residnoadj`l'' macro(`macro1') mcmc(`mcmc') residfile(`residfile`l'') cc(`cc') maxlevels(`maxlevels') mmid(`mmids`l'') `lids'
        }
      }

      *******************
      * Calculate Factor values
      *******************
      if `factorson' == 1 {
        file write `macro1' "LINK 3 G21" _n
        file write `macro1' "JOIN 1 G21[3] G21[3]" _n
        file write `macro1' "NOBS 2 b33 b34" _n
        file write `macro1' "DAFA G21[1] G21[2]" _n
        file write `macro1' "SET b35 1" _n
        forvalues l = 1/`maxlevels' {
          if ("`fscores`l''"~=""){
            tempfile fscoresfile`l'
            //tempname fh
            //file open `fh' using "`fscoresfile`l''", write
            //file close `fh'
            local count = `=colsof(`flinit`l'')' * 2
            file write `macro1' "LINK `count' G22" _n

          }

          local i = 1
          forvalues fact = 1/`=colsof(`flinit`l'')' { {
            if ("`fscores`l''"~=""){
              file write `macro1' "NOBS `=`l'+1' b31 b32" _n
              file write `macro1' "NAME G22[`i'] '`fscores`l''`fact''" _n
              file write `macro1' "CALC b36 = b35 + b31 - 1" _n
              file write `macro1' "PICK b35 b36 G21[1] G22[`i']" _n
              local ++i
              file write `macro1' "NAME G22[`i'] '`fscores`l''`fact'sd'" _n
              file write `macro1' "PICK b35 b36 G21[2] G22[`i']" _n
              local ++i
            }
            file write `macro1' "CALC b35=b35+b33" _n
          }
          if ("`fscores`l''"~=""){
            file write `macro1' "GENErate 1 b31 1 G21[3]" _n
            file write `macro1' "NAME G21[3] '_fscoreid'" _n
            file write `macro1' "PSTA '`fscoresfile`l''' '_fscoreid' G22" _n
            file write `macro1' "ERASE '_fscoreid' G22" _n
            file write `macro1' "LINK 0 G22" _n
          }
        }
        file write `macro1' "ERASE G21" _n
        file write `macro1' "LINK 0 G21" _n
      }

      **********************
      * Set Seed
      **********************
      if ("`standardseed'"~="") {
        // Note if user does not specify seed option then seed is set to zero and runmlwin does not write the seed command to the macro
        // If the user specifies the seed option then runmlwin will write the seed command to the macro (unless that is if the user specifies the seed to be 0!)
        file write `macro1' "NOTE   Set seed" _n
        file write `macro1' "SEED `standardseed'" _n(2)
      }

      **********************
      * Simulate new response variable
      **********************
      if ("`simulate'"~="") {
        tempfile simfile
        runmlwin_simresp, simfile(`simfile') simulate(`simulate') simfile(`simfile') macro1(`macro1')
      }

      ****************
      * Save the model
      ****************

      if "`saveworksheet'" ~= "" {
        file write `macro1' "NOTE   Save the MLwiN worksheet" _n
        file write `macro1' "ZSAV  '`saveworksheet''" _n(2)
      }

      * Pause
      if ("`pause'"=="") {
        file write `macro1' "NOTE   Pause the macro to allow the user to examine the model results" _n
        file write `macro1' "PAUS" _n(2)
      }

      if "`saveequation'" ~= "" {
        file write `macro1' "NOTE   Save an image of the equations window" _n
        file write `macro1' "WCAP 15 0 '`saveequation''" _n
      }
    }

    file write `macro1' "NOTE   ***********************************************************************" _n(2)
    file close `macro1'

    if ("`viewmacro'"~="") view "`filemacro1'"

    ******************************************************************************
    ******************************************************************************
    * MLwiN sub macro to export model results
    ******************************************************************************
    ******************************************************************************
    // GENERATE COLUMNS TO HOLD MCMC CHAINS AND STATISTICS
    // MCMC chains for parameters can be stored here
    // MCMC chains for residuals can be stored here

    tempname macro2
    tempfile filemacro2
    qui file open `macro2' using "`filemacro2'", write replace

    * Export the model results and exit
    file write `macro2' "NOTE   ***********************************************************************" _n
    file write `macro2' "NOTE   Export the model results to Stata" _n
    file write `macro2' "NOTE   ***********************************************************************" _n

    if "`fit'" ~= "nofit" {
      file write `macro2' "LINK 1 G30" _n

      * Store number of cases and number in use
      //file write `macro2' "NOBS 1 b31 b32" _n
      //file write `macro2' "EDIT 1 G30[1] b31" _n  // Total Cases
      //file write `macro2' "EDIT 2 G30[1] b32" _n  // Cases in use

      * Put deviance in c1300

      file write `macro2' "NAME   G30[1] '_Stats'" _n
      if ("`discrete'"=="" & "`mcmc'"=="") {
      //if ("`mcmc'"=="") {
        file write `macro2' "LIKE   b100" _n
        file write `macro2' "EDIT 3 G30[1] b100" _n // Deviance
      }
      if ("`mcmc'"~="" & "`me'"=="" & `factorson' == 0 & ("`mtype'" ~= "multivariate" | "`discrete'" == "")) { // BDIC doesn't work for models with measurement error or mixed responses
        file write `macro2' "BDIC b1 b2 b3 b4" _n
        file write `macro2' "EDIT 3 G30[1] b1" _n     // DIC
        file write `macro2' "EDIT 4 G30[1] b2" _n     // pD - effective number of parameters
        file write `macro2' "EDIT 5 G30[1] b3" _n     // Mean deviance Dbar
        file write `macro2' "EDIT 6 G30[1] b4" _n     // Deviance at mean parameter values D(thetabar)
      }
      file write `macro2' "EDIT 7 G30[1] b21" _n  // Number of iterations
      file write `macro2' "EDIT 8 G30[1] b22" _n  // Converged

      * Store number of units in higher levels
      //local nextrownum = 9
      //forvalues l = `maxlevels'(-1)2 {
      //  file write `macro2' "NOBS `l' b33 b34" _n
      //  file write `macro2' "EDIT `nextrownum' G30[1] b33" _n // Total Cases
      //  local ++nextrownum
      //  file write `macro2' "EDIT `nextrownum' G30[1] b34" _n // Cases in use
      //  local ++nextrownum
      //}

      file write `macro2' "NAME   c1098 '_FP_b'" _n
      file write `macro2' "NAME   c1099 '_FP_v'" _n
      file write `macro2' "NAME   c1096 '_RP_b'" _n
      file write `macro2' "NAME   c1097 '_RP_v'" _n

      file write `macro2' "NAME   c1094 '_esample'" _n
      file write `macro2' "SUM '_esample' b1" _n
      file write `macro2' "EDIT 9 G30[1] b1" _n // Number of missing rows

      if `factorson' == 1 {
        file write `macro2' "LINK 4 G29" _n
        file write `macro2' "NAME   G29[1] '_FACT_b'" _n
        file write `macro2' "NAME   G29[2] '_FACT_v'" _n
        file write `macro2' "DAFL   G29[1] G29[2]" _n
        file write `macro2' "NAME   G29[3] '_FACTVAR_b'" _n
        file write `macro2' "NAME   G29[4] '_FACTVAR_v'" _n
        file write `macro2' "DAFV   G29[3] G29[4]" _n
      }

      if "`savestata'" == "" {
        tempfile fileresults
        //tempname fh
        //file open `fh' using "`fileresults'", write
        //file close `fh'
      }
      else {
        local 0 `savestata'
        syntax anything(name=savestata), [REPLACE]
        if "`replace'" == "" confirm new file "`savestata'"
        local fileresults `savestata'
      }

      if `factorson' == 1 {
        file write `macro2' "PSTA  '`fileresults'' '_FP_b' '_FP_v' '_RP_b' '_RP_v' '_Stats' '_FACT_b' '_FACT_v' '_FACTVAR_b' '_FACTVAR_v'" _n
        file write `macro2' "ERAS '_Stats' '_FACT_b' '_FACT_v' '_FACTVAR_b' '_FACTVAR_v'" _n
        file write `macro2' "LINK 0 G29" _n
      }
      else {
        file write `macro2' "PSTA  '`fileresults'' '_FP_b' '_FP_v' '_RP_b' '_RP_v' '_Stats'" _n
        file write `macro2' "ERAS '_Stats'" _n
      }
      file write `macro2' "LINK 0 G30" _n

      tempfile fileesample
      runmlwin_saveesample, fileesample(`fileesample') nummlwineqns(`nummlwineqns') sortindex(`_sortindex') macro2(`macro2')

      if "`mcmc'" ~= "" {
        file write `macro2' "LINK 0 G21" _n /* Residuals */ "LINK 0 G22" _n /* Factors */ "LINK 0 G23" _n /* Factor variances */
        local paramlength = colsof(`matFP_b') + colsof(`matRP_b') // numvars is 4 here
        //local chainlength =`mcmc_chain'/`mcmc_thinning'
        local chainnames `:colfullnames `matFP_b'' `:colfullnames `matRP_b''
        if "`mtype'"=="multinomial" & ("`link'"=="ologit"|"`link'"=="oprobit"|"`link'"=="ocloglog") {
          local paramlength = `paramlength' - 1
          //local tmp RP1:var(bcons_1)
          //display "`chainnames'"
          local tmp OD:bcons_1
          local chainnames `:list chainnames - tmp'
        }
        // Export parameter chains
        file write `macro2' "NOTE   export parameter chain" _n

        file write `macro2' "NAME   c1091 'deviance'" _n
        file write `macro2' "NAME   c1090 'mcmcchains'" _n

        file write `macro2' "COUNt 'deviance' b40" _n   // Thinned iterations
        file write `macro2' "CALC b41 = b40 * `thinning'" _n // Unthinned iterations

        local i = 1
        file write `macro2' "LINK `:list sizeof chainnames' G21" _n
        file write `macro2' "FILL G21" _n
        foreach var of local chainnames {
          if _caller() >= 11 {
            file write `macro2' "NAME   G21[`i'] '`=strtoname("`var'")''" _n
          }
          else {
            mata: st_local("tmpname", validname("`var'"))
            file write `macro2' "NAME   G21[`i'] '`=abbrev("`tmpname'", 32)''" _n
          }
          file write `macro2' "DESC   G21[`i'] '`var''" _n
          local ++i
        }

        file write `macro2' "LINK 2 G25" _n
        file write `macro2' "NAME   G25[1] 'parnum'" _n
        file write `macro2' "NAME   G25[2] 'iteration'" _n
        file write `macro2' "DESC   G25[2] '\Iteration'" _n
        file write `macro2' "LINK 0 G25" _n

        file write `macro2' "CODE   `paramlength' 1 b40 'parnum'" _n
        file write `macro2' "GENE   1 b41 `thinning' 'iteration'" _n
        file write `macro2' "SPLIt 'mcmcchains' 'parnum' G21" _n
        if "`mtype'"=="multinomial" & ("`link'"=="ologit"|"`link'"=="oprobit"|"`link'"=="ocloglog") {
          file write `macro2' "LINK 1 G25" _n
          file write `macro2' "PUT   b40 1  G25[1]'" _n
          if _caller() >= 11 {
            //file write `macro2' "NAME   G25[1] '`=strtoname("RP1:var(bcons_1)")''" _n
            file write `macro2' "NAME   G25[1] '`=strtoname("OD:bcons_1")''" _n
          }
          else {
            //mata: st_local("tmpname", validname("RP1:var(bcons_1)"))
            mata: st_local("tmpname", validname("OD:bcons_1"))
            file write `macro2' "NAME  G25[1] '`tmpname''" _n
          }
          //file write `macro2' "DESC   G25[1] ' 'RP1:var(bcons_1)'" _n
          file write `macro2' "DESC   G25[1] ' 'OD:bcons_1'" _n
          file write `macro2' "GSET 2 G21 G25 G21" _n
          file write `macro2' "LINK 0 G25" _n
        }

        if `factorson' == 1 {
          file write `macro2' "LINK 2 G25" _n
          file write `macro2' "NAME   G25[1] 'factnum'" _n
          file write `macro2' "NAME   G25[2] 'factvarnum'" _n
          file write `macro2' "CODE `=`numfact'*`nummlwineqns'' 1 b40 'factnum'" _n
          file write `macro2' "CODE `=(`numfact'*(`numfact'+1))/2' 1 b40 'factvarnum'" _n
          file write `macro2' "LINK 0 G25" _n

          local count = 0
          forvalues l = 1/`maxlevels' {
            if "`flinit`l''" ~= "" {
              local count = `count' + (`=colsof(`flinit`l'')' * `=rowsof(`flinit`l'')')
            }
          }

          file write `macro2' "LINK `count' G25" _n

          local i = 1
          forvalues l = 1/`maxlevels' {
            if "`flinit`l''" ~= "" {
              forvalues fact = 1/`=colsof(`flinit`l'')' {
                forvalues resp = 1/`=rowsof(`flinit`l'')' {
                  file write `macro2' "NAME G25[`i'] 'RP`l'FL_f`fact'_`resp''" _n
                  file write `macro2' "DESC G25[`i'] 'RP`l'FL:f`fact'_`resp''" _n
                  local ++i
                }
              }
            }
          }
          file write `macro2' "SPLIt '_FACT_LOAD_CHAIN' 'factnum' G25" _n
          file write `macro2' "GSET 2 G21 G25 G21" _n
          file write `macro2' "LINK 0 G25" _n

          local count = 0
          local basefact = 0
          forvalues l = 1/`maxlevels' {
            if "`flinit`l''" ~= "" {
              forvalues fact1 = 1/`=colsof(`flinit`l'')' {
                local count = `count' + `basefact' + `fact1'
              }
              local basefact = `basefact' + colsof(`flinit`l'')
            }
          }

          file write `macro2' "LINK `count' G25" _n

          local i = 1
          local basefact = 0
          forvalues l = 1/`maxlevels' {
            if "`flinit`l''" ~= "" {
              forvalues fact1 = 1/`=colsof(`flinit`l'')' {
                local i = `i' + `basefact'
                forvalues fact2 = 1/`fact1' {
                  if `fact1' == `fact2' {
                    file write `macro2' "NAME G25[`i'] 'RP`l'FV_var_f`fact1'_'" _n
                    file write `macro2' "DESC G25[`i'] 'RP`l'FV:var(f`fact1')'" _n
                  }
                  else {
                    file write `macro2' "NAME G25[`i'] 'RP`l'FV_cov_f`fact1'_f`fact2'_'" _n
                    file write `macro2' "DESC G25[`i'] 'RP`l'FV:cov(f`fact1',f`fact2')'" _n
                  }
                  local ++i
                }
              }
              local basefact = `basefact' + colsof(`flinit`l'')
            }
          }
          file write `macro2' "SPLIt '_FACT_VAR_CHAIN' 'factvarnum' G25" _n
          file write `macro2' "GSET 2 G21 G25 G21" _n
          file write `macro2' "LINK 0 G25" _n

          file write `macro2' "ERAS 'factnum' 'factvarnum'" _n
        }

        if ("`savechains'"=="") {
          tempfile savechains
          //tempname fh
          //file open `fh' using "`savechains'", write
          //file close `fh'
        }

        file write `macro2' "PSTA '`savechains'' 'iteration' 'deviance' G21" _n
        file write `macro2' "ERAS 'parnum' 'iteration' G21" _n
        file write `macro2' "LINK 0 G21" _n

        // Export residual chains
        forvalues l = 1/`maxlevels' {
          if "`saveresiduals`l''" ~= "" {
            file write `macro2' "NOTE   export residual chain for level `l'" _n

            local ll = `l'
            if ("`mtype'"=="multivariate" | "`mtype'"=="multinomial") local ++ll
            //local numresi = `numrp`l'vars'
            //if `numresi' == 0 local numresi = 1
            file write `macro2' "NOBS `ll' b31 b32" _n
            file write `macro2' "CALC b33 = b31 * `numresi`l''" _n
            file write `macro2' "CALC b34 = b31 * b40" _n

            file write `macro2' "LINK 4 G25" _n

            // Generate ID column the same length as the residuals
            if ("`cc'"=="") {
              local hier
              forvalues lev = `l'/`maxlevels' {
                local hier '`lev`l'id'' `hier'
              }
              file write `macro2' "COMB `hier' G25[4]" _n
              file write `macro2' "TAKE G25[4] '`lev`l'id'' G25[3] G25[2]" _n
              file write `macro2' "ERAS G25[3] G25[4]" _n
            }
            if "`mmids`l''" ~= "" {
              file write `macro2' "ERAS G25[1]" _n
              foreach varname of varlist `mmids`l'' {
                file write `macro2' "APPE G25[1] '`varname'' G25[1]" _n
              }
              file write `macro2' "UNIQ G25[1] G25[2]" _n
              file write `macro2' "OMIT 0 G25[2] G25[2]" _n
            }
            else file write `macro2' "UNIQ '`lev`l'id'' G25[2]" _n

            file write `macro2' "ERAS G25[1]" _n
            file write `macro2' "REPE `numresi`l'' G25[2] G25[3]" _n
            file write `macro2' "ERAS G25[2]" _n
            file write `macro2' "LOOP b42 1 b40" _n
            //forvalues i = 1/`=`chainlength'' {
              file write `macro2' "APPE G25[1] G25[3] G25[1]" _n
            //}
            file write `macro2' "ENDL" _n
            file write `macro2' "ERAS G25[3]" _n
            // Temporary rename level ID column so there isn't a duplicate
            file write `macro2' "NAME '`lev`l'id'' '_`lev`l'id''" _n
            file write `macro2' "NAME G25[1] '`lev`l'id''" _n
            file write `macro2' "DESC G25[1] '\\`:variable label `lev`l'id'''" _n
            file write `macro2' "CODE b40 b33  1 G25[2]" _n // iteration number
            file write `macro2' "CALC G25[2] = ((G25[2] - 1) * `thinning') + 1" _n
            file write `macro2' "NAME G25[2] 'iteration'" _n
            file write `macro2' "DESC G25[2] '\Iteration'" _n
            file write `macro2' "CODE `numresi`l'' 1 b34 G25[3]" _n // residual number
            file write `macro2' "CALC G25[3] = G25[3] - 1" _n // Renumber to start at zero
            file write `macro2' "NAME G25[3] 'residual'" _n
            file write `macro2' "DESC G25[3] '\Residual'" _n
            file write `macro2' "CODE b31 `numresi`l'' b40 G25[4]" _n // id number
            file write `macro2' "NAME G25[4] 'idnum'" _n
            file write `macro2' "DESC G25[4] 'Unit number'" _n
            file write `macro2' "NAME 'RESID_CHAIN_LEVEL`l'' 'value'" _n
            file write `macro2' "PSTA '`saveresiduals`l''' 'iteration' 'residual' 'idnum' '`lev`l'id'' 'value'" _n
            file write `macro2' "ERAS 'iteration' 'residual' 'idnum' '`lev`l'id'' 'value'" _n
            file write `macro2' "LINK 0 G25" _n
            // Restore level ID column name
            file write `macro2' "NAME '_`lev`l'id'' '`lev`l'id''" _n
          }
        }
      }
    }

  if ("`plugin'"=="") file write `macro2' "EXIT" _n
  file close `macro2'

  * MLwiN macro (appends macro1 and macro2 together)
  tempname macro3
  if "`savefullmacro'" ~= "" local filemacro3 `savefullmacro'
  else tempfile filemacro3

  qui file open `macro3' using "`filemacro3'", write replace
  file open `macro1' using "`filemacro1'", read
  file open `macro2' using "`filemacro2'", read

  file read `macro1' temp
  file write `macro3' "`temp'" _n
  while r(eof)==0 {
    file read `macro1' temp
    file write `macro3' "`temp'" _n
  }
  file read `macro2' temp
  file write `macro3' "`temp'"  _n
  while r(eof)==0 {
    file read `macro2' temp
    file write `macro3' "`temp'" _n
  }

  file close `macro1'
  file close `macro2'
  file close `macro3'

  if ("`viewfullmacro'"~="") view "`filemacro3'"

  if "`mlwin'"=="nomlwin" {
    di as error "The nomlwin option caused runmlwin to end prematurely"
    exit 198
  }

  * Call either MLwiN.exe or MLwiN.plugin
  if "`plugin'"~="" quietly mlncommand OBEY '`filemacro3''
  else {
    if "`mlwinpath'"=="" {
      di as error "You must specify the file address for MLwiN.exe using either:" _n(2)
      di as error "(1) the mlwinpath() option; for example mlwinpath(C:\Program Files\MLwiN v3.03\mlwin.exe)" _n
      di as error "(2) a global called MLwiN_path; for example: . global MLwiN_path C:\Program Files\MLwiN v3.03\mlwin.exe" _n(2)
      di as error "We recommend (2) and that the user places this global macro command in profile.do, see help profile." _n(2)
      di as error "IMPORTANT: Make sure that you are using the latest version of MLwiN. This is available at: http://www.bristol.ac.uk/cmm/MLwiN/index.shtml" _n

      exit 198
    }
    if "`batch'" == "" quietly runmlwin_qshell "`mlwinpath'" /run "`filemacro3'"
    else {
      quietly runmlwin_qshell "`mlwinpath'" /nogui /run "`filemacro3'"
      display as text " --- Begin MLwiN error log --- "
      type `errlog'
      display as text " --- End MLwiN error log --- " _n
    }
  }

  if "`fit'" == "nofit" {
    di as txt "The savewinbugs nofit option caused runmlwin to end prematurely."
    ereturn scalar mcmcnofit = 1
    exit
  }

  ******************************************************************************
  * IMPORT MLWIN MODEL RESULTS BACK INTO STATA
  ******************************************************************************

  capture use "`fileresults'", clear

  if _rc {
    if ("`pause'"=="") display as error "The model did not run properly in MLwiN. You most likely clicked the 'Abort Macro' button in MLwiN, rather than the 'Resume Macro' button." _n
    if ("`pause'"=="nopause") display as error "The model did not run properly in MLwiN. Re-run the model without the nopause option to debug the model in MLwiN." _n
    exit 198
  }

  local missrows = _Stats[9]

  qui gen _FP_name = ""
  qui gen _RP_name = ""
  order _FP_name _FP_b _FP_v _RP_name _RP_b _RP_v

  * Check the MLwiN columns are the expected length
  qui sum _FP_b
  capture assert r(N)==colsof(`matFP_b')
  if _rc~=0 {
    di as error "runmlwin has encountered an error importing the model results from MLwiN. Check that the model has run properly in MLwiN." _n
    exit 198
  }
  qui sum _RP_b
  capture assert r(N)==colsof(`matRP_b')
  if _rc~=0 {
    di as error "runmlwin has encountered an error importing the model results from MLwiN. Check that the model has run properly in MLwiN." _n
    exit 198
  }

  * Put MLwiN values back into FP_b
  forvalues c = 1/`=colsof(`matFP_b')' {
    mat `matb'[1,`c'] = _FP_b[`c']
  }

  local startrow = colsof(`matFP_b')
  * Put MLwiN values back into RP_b
  forvalues c = 1/`=colsof(`matRP_b')' {
    mat `matb'[1,`=`startrow'+`c''] = _RP_b[`c']
  }

  if `factorson' == 1 {
    local startrow = `startrow' + colsof(`matRP_b')
    forvalues c = 1/`=`numfact'*`nummlwineqns'' {
      mat `matb'[1,`=`startrow'+`c''] = _FACT_b[`c']
    }

    local i = 1
    local startrow = `startrow' + `=`numfact'*`nummlwineqns''
    local basefact = 0
    forvalues l = 1/`maxlevels' {
      if "`flinit`l''" ~= "" {
        forvalues fact1 = 1/`=colsof(`flinit`l'')' {
          forvalues fact2 = 1/`fact1' {
            mat `matb'[1,`=`startrow'+`i''] = _FACTVAR_b[`=((`basefact'+`fact1' - 1) * `basefact'+`fact1' / 2) + `basefact'+`fact2'']
            local ++i
          }
        }
        local basefact = `basefact' + colsof(`flinit`l'')
      }
    }
  }

  * Stack b

  // MLwiN has precision problems with constraints so round covariance matrix to 6s.f
  local sf = 6

  * Put MLwiN values back into FP_V
  local i = 1
  forvalues r = 1/`=colsof(`matFP_b')' {
    forvalues c = 1/`r' {
      if ("`constraints'"=="") local val = _FP_v[`i']
      else local val = round(_FP_v[`i'], 1/10^(`sf'-trunc(log10(abs(_FP_v[`i'])))))
      if `val' == . local val = 0
      mat `matV'[`r',`c'] = `val'
      mat `matV'[`c',`r'] = `val'
      local ++i
    }
  }

  local startrow = colsof(`matFP_b')

  * Put MLwiN values back into RP_V
  local i = 1
  forvalues r = 1/`=colsof(`matRP_b')' {
    forvalues c = 1/`r' {
      if ("`constraints'"=="") local val = _RP_v[`i']
      else local val = round(_RP_v[`i'], 1/10^(`sf'-trunc(log10(abs(_RP_v[`i'])))))
      if `val' == . local val = 0
      mat `matV'[`=`startrow'+`r'',`=`startrow'+`c''] = `val'
      mat `matV'[`=`startrow'+`c'',`=`startrow'+`r''] = `val'
      local ++i
    }
  }

  if `factorson' == 1 {
    local startrow = `startrow' + colsof(`matRP_b')
    forvalues c = 1/`=`numfact'*`nummlwineqns'' {
      mat `matV'[`=`startrow'+`c'',`=`startrow'+`c''] = (_FACT_v[`c'])^2
    }

    local i = 1
    local startrow = `startrow' + `=`numfact'*`nummlwineqns''
    local basefact = 0
    forvalues l = 1/`maxlevels' {
      if "`flinit`l''" ~= "" {
        forvalues fact1 = 1/`=colsof(`flinit`l'')' {
          forvalues fact2 = 1/`fact1' {
            mat `matV'[`=`startrow'+`i'',`=`startrow'+`i''] = (_FACTVAR_v[`=((`basefact'+`fact1' - 1) * `basefact'+`fact1' / 2) + `basefact'+`fact2''])^2
            local ++i
          }
        }
        local basefact = `basefact' + colsof(`flinit`l'')
      }
    }
  }

  * Stack V

  * List MLwiN model results
  ereturn clear

  if ("`verbose'"~="") display "b and V matrices imported from MLwiN:"
  if ("`verbose'"~="") mat list `matb'
  if ("`verbose'"~="") mat list `matV'

  if "`consC'" == "" capture noisily ereturn post `matb' `matV'
  else capture noisily ereturn post `matb' `matV' `consC'

  if ("`verbose'"~="") display "ereturn error code was: " _rc

  if _rc {
    display as error "Warning - runmlwin has experienced difficulties importing the standard errors, all standard errors have been set to zero"
    tempname zeromat
    mat `zeromat' = J(rowsof(`matV'), rowsof(`matV'), 0)
    mat rowname `zeromat' = `:rowfullnames `matV''
    mat colname `zeromat' = `:colfullnames `matV''
    if "`consC'" == "" ereturn post `matb' `zeromat'
    else ereturn post `matb' `zeromat' `consC'
  }

  tempname rptmp
  mat `rptmp' = e(b)
  forvalues l = `maxlevels'(-1)1 {
    if `:list sizeof rp`l'name' > 0 {
      mat RP`l' = J(`:list sizeof rp`l'name', `:list sizeof rp`l'name', 0)
      local matnames = subinstr("`rp`l'name'", ".", "_", .)
      mat rownames RP`l' = `matnames'
      mat colnames RP`l' = `matnames'

      local r = 1
      local c = 1
      foreach row of local rp`l'name {
        if _caller() < 11 mata: st_local("row", validname("`row'"))
        foreach col of local rp`l'name {
          if _caller() < 11 {
            mata: st_local("col", validname("`col'"))
          }
          if `c' < `r' {
            if _caller() >= 11 {
              local pname RP`l':cov(`=abbrev(strtoname("`col'"),13)'\\`=abbrev(strtoname("`row'"),13)')
            }
            else {
              local pname RP`l':cov(`=abbrev("`col'",13)'\\`=abbrev("`row'",13)')
            }
            if `:list pname in names' {
              mat RP`l'[`r', `c'] = `rptmp'[1, "`pname'"]
              mat RP`l'[`c', `r'] = `rptmp'[1, "`pname'"]
            }
          }
          if `c'==`r' {
            if _caller() >= 11 {
              local pname RP`l':var(`=abbrev(strtoname("`row'"), 27)')
            }
            else {
              local pname RP`l':var(`=abbrev("`row'", 27)')
            }
            if `:list pname in names' mat RP`l'[`r', `c'] = `rptmp'[1, "`pname'"]
          }
          local ++c
        }
        local ++r
        local c = 1
      }
      ereturn matrix RP`l' = RP`l'
    }
  }

  ereturn scalar numlevels        = `maxlevels'
  ereturn scalar k_f = colsof(`matFP_b')
  ereturn scalar k_r = colsof(`matRP_b')
  ereturn scalar k = colsof(`matFP_b') + colsof(`matRP_b')

  ereturn local cmd           runmlwin
  ereturn local cmdline `e(cmd)' `runmlwin_cmdline'
  ereturn local version `mlwinversion'
  ereturn scalar size = `worksize'
  ereturn scalar maxlevels = `toplevel'
  ereturn scalar columns = `numwscolumns'
  ereturn scalar variables = `maxexpl'
  if "`tempmat'" == "" ereturn scalar tempmat = 0
  else ereturn scalar tempmat = 1

  if ("`distribution'"~="multinomial") ereturn local depvars `response'
  if ("`distribution'"=="multinomial") ereturn local depvars :list uniq response

  ereturn local distribution        =rtrim(ltrim("`distribution'"))
  ereturn local link          `link'
  ereturn local denominators `denominator'
  ereturn local offsets `offset'
  ereturn local properties b V

  ereturn local method          `emode'
  ereturn local linearization       `linearization'
  if "`extra'" ~= "" ereturn scalar extrabinomial = 1
  else ereturn scalar extrabinomial = 0

  if "`mtype'" == "multinomial" {
    ereturn local basecategory `basecategory'
    ereturn local respcategories `responsecats'
  }

  if ("`e(distribution)'"=="normal")                  ereturn local title Normal response model
  if ("`e(distribution)'"=="binomial")                ereturn local title Binomial `e(link)' response model
  if ("`e(distribution)'"=="multinomial" & ("`e(link)'"=="mlogit"))   ereturn local title Unordered multinomial logit response model
  if ("`e(distribution)'"=="multinomial" & ("`e(link)'"=="ologit"))   ereturn local title Ordered multinomial logit response model
  if ("`e(distribution)'"=="multinomial" & ("`e(link)'"=="oprobit"))  ereturn local title Ordered multinomial probit response model
  if ("`e(distribution)'"=="multinomial" & ("`e(link)'"=="ocloglog")) ereturn local title Ordered multinomial cloglog response model
  if ("`e(distribution)'"=="poisson")                 ereturn local title Poisson response model
  if ("`e(distribution)'"=="nbinomial")                 ereturn local title Negative binomial response model
  if (wordcount("`e(distribution)'")>1)                 ereturn local title Multivariate response model

  * Level IDs
  ereturn local level1var `lev1id'
  local ivars
  forvalues l = `maxlevels'(-1)2 {
    local ivars `ivars' `lev`l'id'
  }
  ereturn local ivars `ivars'

//  * Number of units at each level
//  if `maxlevels'>1 {
//    matrix N_g = J(1, `=`maxlevels'-1', .)
//    local nextrownum = 9
//    forvalues l = `maxlevels'(-1)2 {
//      matrix N_g[1, `=`maxlevels' -`l'+1'] = _Stats[`nextrownum']
//      local nextrownum = `nextrownum' + 2
//    }
//    ereturn matrix N_g = N_g
//  }

  * (R)IGLS Weighting options
  local weightvar
  local weighttype
  forvalues l = `maxlevels'(-1)1 {
    if "`weight`l''" ~= "" local weightvar `weightvar' `weight`l''
    else local weightvar `weightvar' .
    if "`weighttype`l''" ~= "" local weighttype `weighttype' `weighttype`l''
    else local weighttype `weighttype' standardised
  }
  ereturn local weightvar `weightvar'
  ereturn local weighttype `weighttype'

  * Model fit
  //if ("`mcmc'"=="") ereturn scalar ll     = -_Stats[3]/2
  //if ("`mcmc'"=="") ereturn scalar deviance   = _Stats[3]
  if ("`discrete'"=="" & "`mcmc'"=="") ereturn scalar ll    = -_Stats[3]/2
  if ("`discrete'"=="" & "`mcmc'"=="") ereturn scalar deviance  = _Stats[3]
  ereturn scalar iterations         = _Stats[7]
  if ("`mcmc'"=="") {
    ereturn scalar converged          = (_Stats[8]==1)
  }

  * Save MCMC chains and calculate 95% credible interval and ESS and store as matrices
  if ("`mcmc'" ~= "") {
      ereturn scalar burnin           = `mcmc_burnin'
    ereturn scalar chain          = `mcmc_chain'
    ereturn scalar thinning         = `mcmc_thinning'
    ereturn scalar dic          = _Stats[3]   // DIC
    ereturn scalar pd           = _Stats[4]   // pD - effective number of parameters
    ereturn scalar dbar           = _Stats[5]   // Dbar - Mean deviance
    ereturn scalar dthetabar        = _Stats[6] // D(thetabar) - Deviance at mean parameter values

    ereturn scalar converged = 1
    ereturn scalar mcmcdiagnostics = ("`diagnostics'"~="nodiagnostics")
    if ("`diagnostics'"~="nodiagnostics") {

      local chainnames `:colfullnames `matFP_b'' `:colfullnames `matRP_b''
      if `factorson' == 1 {
        local chainnames `chainnames' `:colfullnames `mat_RP_b_fact'' `:colfullnames `mat_RP_b_factvar''
      }
      //ereturn local parnames "`chainnames'"
      local temp = `:list sizeof chainnames'
      runmlwin_savechains, parnames(`chainnames') chainresults(`savechains')

      local savechainnames
      foreach parname of local chainnames {
        if _caller() >= 11 {
          local savechainnames `savechainnames' `=strtoname("`parname'")'
        }
        else {
          mata: st_local("tmpname", validname("`parname'"))
          local savechainnames `savechainnames' `=abbrev("`tmpname'", 32)'
        }
      }

      use `savechainnames' using "`savechains'", clear
      foreach stat in meanmcse sd mode ess lb ub rl1 rl2 bd pvalmean pvalmedian pvalmode {
        mat `stat' = e(b)
      }

      local acfpoints = 100
      local pacfpoints = 10
      local mcsepoints = 1000
      local kdpoints = 1000

      matrix ACF = J(`acfpoints', `=1 + `temp'', .)
      matrix colnames ACF = point `chainnames'
      tempname tmpacf

      matrix PACF = J(`pacfpoints', `=1 + `temp'', .)
      matrix colnames PACF = point `chainnames'
      tempname tmppacf

      matrix quantiles = J(9, `=1 + `temp'', .)
      matrix colnames quantiles = quant `chainnames'
      tempname tmpquantiles

      tempname mataMCSE
      mata: `mataMCSE' = J(`mcsepoints',`=1 + `temp'',.)

      tempname mataKD1
      mata: `mataKD1' = J(`kdpoints',`temp',.)
      tempname mataKD2
      mata: `mataKD2' = J(`kdpoints',`temp',.)

      local i = 1
      foreach par of local savechainnames {

        // set posit(1) for the variance parameters
        local posit = 0
        if regexm("`par'", "RP[0-9]+_var_([a-zA-Z0-9_]+)_") == 1 local posit = 1

        quietly runmlwin_mcmcdiag `par', level(`level') thinning(`thinning') posit(`posit') acfpoints(`acfpoints') pacfpoints(`pacfpoints') mcsepoints(`mcsepoints') kernalpoints(`kdpoints') `eform' // Need to add prior option

        matrix meanmcse[1,`i'] = r(meanmcse)
        matrix sd[1,`i'] = r(sd)
        matrix mode[1,`i'] = r(mode)
        matrix ess[1,`i'] = r(ESS)
        matrix lb[1,`i'] = r(lb)
        matrix ub[1,`i'] = r(ub)
        matrix rl1[1,`i'] = r(RL1)
        matrix rl2[1,`i'] = r(RL2)
        matrix bd[1,`i'] = r(BD)
        matrix pvalmean[1,`i'] = r(pvalmean)
        matrix pvalmedian[1,`i'] = r(pvalmedian)
        matrix pvalmode[1,`i'] = r(pvalmode)

        matrix `tmpacf' = r(ACF)
        if `i' == 1 matrix ACF[1, 1] = `tmpacf'[1..., 2]
        matrix ACF[1, `=1 + `i''] = `tmpacf'[1..., 1]

        matrix `tmppacf' = r(PACF)
        if `i' == 1 matrix PACF[1, 1] = `tmppacf'[1..., 2]
        matrix PACF[1, `=1 + `i''] = `tmppacf'[1..., 1]

        matrix `tmpquantiles' = r(quantiles)
        if `i' == 1 matrix quantiles[1, 1] = `tmpquantiles'[1..., 1]
        matrix quantiles[1, `=1 + `i''] = `tmpquantiles'[1..., 2]

        if `i' == 1 mata: `mataMCSE'[1..., 1] = st_matrix("r(MCSE)")[1..., 2]
        mata: `mataMCSE'[1..., `=1 + `i''] = st_matrix("r(MCSE)")[1..., 1]

        mata: `mataKD1'[1..., `i'] = st_matrix("r(KD)")[1..., 1]
        mata: `mataKD2'[1..., `i'] = st_matrix("r(KD)")[1..., 2]

        local ++i
      }

      ereturn scalar level        = `level'

      mata: st_matrix("MCSE", `mataMCSE')
      mata: mata drop `mataMCSE'
      matrix colnames MCSE = point `chainnames'
      mata: st_matrix("KD1", `mataKD1')
      mata: mata drop `mataKD1'
      matrix colnames KD1 = `chainnames'
      mata: st_matrix("KD2", `mataKD2')
      mata: mata drop `mataKD2'
      matrix colnames KD2 = `chainnames'

      ereturn local chains "runmlwin_chains"
      foreach stat in meanmcse sd mode ess lb ub rl1 rl2 bd pvalmean pvalmedian pvalmode {
        ereturn matrix `stat' = `stat'
      }
      ereturn matrix ACF = ACF
      ereturn matrix PACF = PACF
      ereturn matrix quantiles = quantiles
      ereturn matrix MCSE = MCSE
      ereturn matrix KD1 = KD1
      ereturn matrix KD2 = KD2
    }
  }

  * Multiple Imputation - remove _mi_ prefix from response
  if `:list sizeof imputefiles' ~= 0 {
    foreach impfile of local imputefiles {
      use "`impfile'", clear
      if _caller() >= 12 rename _mi_* *
      else renpfix "_mi_"
      quietly saveold "`impfile'", replace
    }
  }

  * Restore the original data set
  restore

  * Merge in esample
  if `missrows' > 0 {
    if _caller() >= 11 quietly merge m:1 `_sortindex' using "`fileesample'", assert(master match) nogenerate
    else {
      quietly merge `_sortindex' using "`fileesample'", uniqusing sort
      assert inlist(_merge,1,3)
      drop _merge
    }
    qui recode _esample (.=0)
  }
  else qui gen _esample = `touse'

  ereturn repost, esample(_esample)

  * Calculate the sample size
  qui count if e(sample)
  ereturn scalar N = r(N)

  * Calculate the min, mean and max number of units at each level
  if `maxlevels' > 1 & "`sort'" == "" {
    matrix N_g = J(1, `=`maxlevels'-1', .)
    matrix g_min = J(1, `=`maxlevels'-1', .)
    matrix g_avg = J(1, `=`maxlevels'-1', .)
    matrix g_max = J(1, `=`maxlevels'-1', .)

    local hier
    forvalues l = `maxlevels'(-1)2 {
      if ("`cc'"=="") local hier `hier' `lev`l'id'
      if ("`cc'"~="") local hier `lev`l'id'

      tempvar esample temp1 temp2
      quietly gen `esample' = (e(sample)==1)
      qui bysort `hier' `esample': gen byte `temp1' = 1 if _n==1 & `esample'==1
      qui bysort `hier' `esample': gen `temp2' = _N if `esample'==1
      qui sum `temp2' if `temp1'==1 & `esample'==1
      drop `esample' `temp1' `temp2'
      matrix N_g[1, `=`maxlevels' -`l'+1'] = r(N)
      matrix g_min[1, `=`maxlevels' -`l'+1'] = r(min)
      matrix g_avg[1, `=`maxlevels' -`l'+1'] = r(mean)
      matrix g_max[1, `=`maxlevels' -`l'+1'] = r(max)
    }
    sort `_sortindex'

    ereturn matrix N_g = N_g
    ereturn matrix g_min = g_min
    ereturn matrix g_avg = g_avg
    ereturn matrix g_max = g_max
  }

  * Merge residuals at each level into the original data set
  forvalues l = `maxlevels'(-1)1 {
    local hier
    forvalues t = `maxlevels'(-1)`l' {
      local hier `hier' `lev`t'id'
    }
    local ll = `l'
    if ("`mtype'"=="multivariate" | "`mtype'"=="multinomial") local ++ll
    if ("`residuals`l''"~="") runmlwin_mergeresiduals , numlevels(`ll') touse(`touse') hier(`hier') cc(`cc') levelid(`lev`l'id') residfile(`residfile`l'') sort(`sort') mmid(`mmids`l'')
    if ("`fscores`l''"~="") runmlwin_mergefscores , numlevels(`ll') touse(`touse') hier(`hier') cc(`cc') levelid(`lev`l'id') fscoresfile(`fscoresfile`l'') sort(`sort')
  }

  * Merge simulated response into the original data set
  if ("`simulate'"~="") runmlwin_mergesimresp, simfile(`simfile')

  if "`imputesummaries'" ~= "" {
    if _caller() >= 11 qui merge m:1 `_sortindex' using "`imputesummaries'", assert(match) nogenerate
    else {
      quietly merge `_sortindex' using "`imputesummaries'", uniqusing sort
      assert inlist(_merge,3)
      drop _merge
    }
  }

  * Append multiple imputed data sets
  if `:list sizeof imputefiles' ~= 0 {
    if _caller() >= 11 {
      mi import flongsep tmpimpfile, using(`imputefiles') id(`_sortindex') imputed(`response') clear
      mi convert mlong
      quietly mi erase tmpimpfile
    }
    else {
      tempvar tag
      gen `tag' = 1 if missing(`=subinstr("`response'"," ",",",.)')

      foreach resp of local response {
        rename `resp' `resp'_mi_m0
      }

      local i = 1
      foreach imputedfile of local imputefiles {
        merge `_sortindex' using `imputedfile', unique sort
        drop _merge

        foreach resp of local response {
          rename `resp' `resp'_mi_m`i'
        }
        local ++i
      }

      quietly reshape long `=subinstr("`response' "," ","_mi_m ",.)', i(`_sortindex') j(_mi_m)

      foreach resp of local response {
        rename `resp'_mi_m `resp'
      }

      quietly drop if `tag'~=1 & _mi_m>0
      drop `tag'

      gen _mi_id = `_sortindex'
      quietly gen _mi_miss = 1 if missing(`=subinstr("`response'"," ",",",.)')

      unab vars : *
      local mivar _mi_m
      local vars `:list vars - mivar'
      local vars `vars' _mi_m
      order `vars'
    }
  }

  * Sort the data by original sort order
  if `: list sizeof imputefiles' ~= 0 { // Because data set has extra rows!
    sort `_sortindex' _mi_m
    quietly replace `_sortindex' = _n // :sortorder should still be okay, as the data is sorted the same as before, but expanded upwards by the imputed data sets
  }
end

******************************************************************************
* CREATES PARAMETER NAMES FOR RP_B (I.E. SIGMA2_U0, SIGMA_U01, SIGMA2_U1, SIGMA2_E)
******************************************************************************
// Note we can't use "," in for example c(cons,standlrt). Doing so causes problems with estimates table when you try to display more than one model
// The "(" and ")" will prob also be problematic
// What we need is to display c(cons,standlrt) in the output window but to store the parameter with different notation without the ",", "(" and ")"
// A separate problem is that instead of c(cons,standlrt) we have c(standlrt,cons)
capture program drop runmlwin_rplpars
program define runmlwin_rplpars, rclass
  if _caller() >= 12 version 12.0
  if _caller() <= 9 version 9.0
  syntax , RPName(string)
  local rplong
  local r = 1
  local c = 1
  foreach row of local rpname  {
    if _caller() < 11 {
      mata: st_local("row", validname("`row'"))
    }
    foreach col of local rpname {
      if _caller() < 11 {
        mata: st_local("col", validname("`col'"))
      }
      if `c' < `r' {
        if _caller() >= 11 {
          local rplong `rplong' cov(`=abbrev(strtoname("`col'"),13)'\\`=abbrev(strtoname("`row'"),13)') // Note that `col' and `row' are deliberately the wrong way around in order to follow MLwiN convention
        }
        else {
          local rplong `rplong' cov(`=abbrev("`col'",13)'\\`=abbrev("`row'",13)') // Note that `col' and `row' are deliberately the wrong way around in order to follow MLwiN convention
        }
        local ++c
      }
      if `c'==`r' {
        if _caller() >= 11 {
          local rplong `rplong' var(`=abbrev(strtoname("`row'"), 27)')
        }
        else {
          local rplong `rplong' var(`=abbrev("`row'", 27)')
        }
        local ++c
      }
    }
    local ++r
    local c = 1
  }

  return local rplong `rplong'
end

capture program drop runmlwin_saveesample
program define runmlwin_saveesample
  if _caller() >= 12 version 12.0
  if _caller() <= 9 version 9.0

  syntax, FILEESAMPLE(string) NUMMLWINEQNS(string) SORTINDEX(string) MACRO2(string)

  local _sortindex `sortindex'

  tempname fh
  file open `fh' using "`fileesample'", write
  file close `fh'

  file write `macro2' "NOTE generate esample for Stata if there a missing values" _n
  file write `macro2' "SWIT b1" _n
  file write `macro2' "CASE 0:" _n
  file write `macro2' "LEAVE" _n
  file write `macro2' "CASE:" _n
  file write `macro2' "CALC '_esample' = abso('_esample' - 1)" _n // Because in MLwiN 1 = not in estimation sample
  if `nummlwineqns'>1 {
    file write `macro2' "NOTE unexpand esample for multinomial/multivariate" _n
    file write `macro2' "LINK 1 G21" _n
    file write `macro2' "COUNT '`_sortindex'' b1" _n
    file write `macro2' "CODE b1 `nummlwineqns' 1 G21[1]" _n
    file write `macro2' "MLAV G21[1] '_esample' '_esample'" _n
    file write `macro2' "TAKE G21[1] '_esample' G21[1] '_esample'" _n
    file write `macro2' "CALC '_esample' = '_esample' > 0" _n
    file write `macro2' "ERAS G21[1]" _n
    file write `macro2' "LINK 0 G21" _n
  }
  file write `macro2' "PSTA  '`fileesample'' '`_sortindex'' '_esample'" _n
  file write `macro2' "ENDS" _n
end

capture program drop runmlwin_simresp
program define runmlwin_simresp
  if _caller() >= 12 version 12.0
  if _caller() <= 9 version 9.0

  syntax, SIMFILE(string) SIMULATE(string) SIMFILE(string) MACRO1(string)

  tempname fh
  file open `fh' using "`simfile'", write
  file close `fh'

  file write `macro1' "NOTE   Simulate new response variable" _n
  file write `macro1' "LINK 2 G21" _n
  file write `macro1' "SIMU G21[1]" _n
  file write `macro1' "NAME G21[1] '`simulate''" _n
  file write `macro1' "COUN G21[1] b30" _n
  file write `macro1' "GENE 1 b30 1 G21[2]" _n
  file write `macro1' "NAME G21[2] '_simprespid'" _n
  file write `macro1' "PSTA '`simfile'' '`simulate'' '_simprespid'" _n
  file write `macro1' "ERAS '`simulate'' '_simprespid'" _n
  file write `macro1' "LINK 0 G21" _n
end

capture program drop runmlwin_setinit
program define runmlwin_setinit
  if _caller() >= 12 version 12.0
  if _caller() <= 9 version 9.0
  syntax , FPB(string) FPV(string) RPB(string) RPV(string) INITB(string) INITV(string) MTYPE(string) LINK(string) [MCMC(string)] MACRO1(string)
  local matFP_b `fpb'
  local matFP_V `fpv'
  local matRP_b `rpb'
  local matRP_V `rpv'
  local matb `initb'
  local matV `initv'

  tempname matINIT

  * Fixed part initial values
  file write `macro1' "NOTE   Specify fixed part initial values" _n
  local names : colfullnames `matFP_b'
  local i = 1
  foreach p of local names {
    file write `macro1' "NOTE   `p'" _n
    mat `matINIT' = `matb'[1,"`p'"]
    file write `macro1' "EDIT `i' c1098  `=`matINIT'[1,1]'" _n
    local ++i
  }
  file write `macro1' _n

  * Fixed part initial values sampling (co)variances
  file write `macro1' "NOTE   Specify fixed part initial sampling (co)variances values" _n
  local names : colfullnames `matFP_V'
  local i = 1
  local e = 1

  file write `macro1' "PUT `=(`=rowsof(`matFP_V')'*(`=rowsof(`matFP_V')' + 1))/2' 0 c1099" _n

  foreach p1 of local names {
    local j = 1
    foreach p2 of local names {
      if `i' >= `j' {
        file write `macro1' "NOTE   `p1', `p2'" _n
        mat `matINIT' = `matV'["`p1'","`p2'"]
        file write `macro1' "EDIT `e' c1099  `=`matINIT'[1,1]'" _n
        local ++e
      }
      local ++j
    }
    local ++i
  }

  file write `macro1' _n

  * Random part initial values
  // Need to check that the correct number of initial values have been specified
  // what if no random part e.g. single level logit
  file write `macro1' "NOTE   Specify random part initial values" _n
  local names : colfullnames `matRP_b'
  local P = colsof(`matRP_b')
  local i = 1
  foreach p of local names {
    if `i'<=`P' {
      file write `macro1' "NOTE   `p'" _n
      mat `matINIT' = `matb'[1,"`p'"]
      file write `macro1' "EDIT `i' c1096  `=`matINIT'[1,1]'" _n
      local ++i
    }
  }
  //if "`mtype'"=="multinomial" & "`link'"=="mlogit" file write `macro1' "EDIT `i' c1096  1" _n
  file write `macro1' _n

  * Random part initial values standard errors
  // Need to check that the correct number of initial values have been specified
  // what if no random part e.g. single level logit
  file write `macro1' "NOTE   Specify random part initial sampling (co)variances values" _n
  local names : colfullnames `matRP_V'
  local P = colsof(`matRP_V')
  if ("`mtype'"=="multinomial" & "`link'"=="mlogit") local P = `P' - 1 // Note we might have to add unordered to the if statement as I think ordered models do not have this problem
  local i = 1
  local e = 1

  file write `macro1' "PUT `=(`=rowsof(`matRP_V')'*(`=rowsof(`matRP_V')' + 1))/2' 0 c1097" _n

  foreach p1 of local names {
    local j = 1
    foreach p2 of local names {
      if `i' >= `j' & `i'<=`P' & `j' <= `P' {
        file write `macro1' "NOTE   `p1', `p2'" _n
        mat `matINIT' = `matV'["`p1'","`p2'"]
        file write `macro1' "EDIT `e' c1097  `=`matINIT'[1,1]'" _n
        local ++e
      }
      local ++j
    }
    local ++i
  }

  if "`mtype'"=="multinomial" & "`link'"=="mlogit" & "`mcmc'" ~= "" file write `macro1' "EDIT `e' c1097  0" _n
end

capture program drop runmlwin_writepriors
program define runmlwin_writepriors
  if _caller() >= 12 version 12.0
  if _caller() <= 9 version 9.0
  syntax , MAXLevels(integer) PRIORMAT(string) FPB(string) RPB(string) MACRO1(string) PRIORCOL(string)

  local priormatrix `priormat'
  local matFP_b `fpb'
  local matRP_b `rpb'

  tempname matprior
  tempname matpriorSD
  tempname mateq

  if rowsof(`priormatrix')~=2 {
    display "The prior matrix must have two rows. The 1st row is for the means. The 2nd row is for the SDs."
    exit 198
  }

  local r = 1

  local names :colfullnames `matFP_b'
  foreach var of local names  {
    mat `matprior' = `priormatrix'[1, "`var'"]
    mat `matpriorSD' = `priormatrix'[2, "`var'"]
    local prior = `matprior'[1,1]
    local priorsd = `matpriorSD'[1,1]
    file write `macro1' "NOTE fixed part prior for `var'" _n
    if `prior' ~= . {
      file write `macro1' "EDIT `r' `priorcol' 1" _n
      local ++r
      file write `macro1' "EDIT `r' `priorcol' `prior'" _n
      local ++r
      file write `macro1' "EDIT `r' `priorcol' `priorsd'" _n
      local ++r
    }
    else {
      file write `macro1' "EDIT `r' `priorcol' 0" _n
      local ++r
    }
  }

  forvalues l = `maxlevels'(-1)1 {
    local hasprior = 0
    local eqnames : coleq  `matRP_b'
    local levname "RP`l'"
    local match : list levname in eqnames

    if `l' == 1 & `match' == 0 {
      local levname "OD"
      local match : list levname in eqnames
    }

    if `match' == 1 {
      matrix `mateq' = `matRP_b'[1, "`levname':"]
      local names :colfullnames `mateq'
      local first = 1
      foreach var of local names {
        mat `matprior' = `priormatrix'[1, "`var'"]
        mat `matpriorSD' = `priormatrix'[2, "`var'"]
        if (`matprior'[1,1] == . & `matpriorSD'[1,1] ~= .) | (`matprior'[1,1] ~= . & `matpriorSD'[1,1] == .) {
          display as error "Either both mean and SD have to be specified, nor neither"
          exit 198
        }
        if `first' ~= 1 {
          if (`hasprior' == 1 & `matprior'[1,1] == .) | (`hasprior' == 0 & `matprior'[1,1] ~= .) {
            display as error "Whole matrix must be specified for random part priors"
            exit 198
          }
          if `priorsd' ~= `matpriorSD'[1,1] {
            display as error "Inconsistent sample size"
            exit 198
          }
        }
        else {
          local priorsd = `matpriorSD'[1,1]
        }
        if `matprior'[1,1] ~= . local hasprior = 1
        local first = 0
      }
      file write `macro1' "NOTE random part prior for level `l'" _n
      if `hasprior' == 1 {
        file write `macro1' "EDIT `r' `priorcol' 1" _n
        local ++r
        foreach var of local names {
          mat `matprior' = `priormatrix'[1, "`var'"]
          local prior = `matprior'[1,1]
          file write `macro1' "EDIT `r' `priorcol' `prior'" _n
          local ++r
        }
        // Check this is a positive integer
        if floor(`priorsd') ~= `priorsd' | `priorsd' < 0 {
          display as error "Sample size must be a positive integer"
          exit 198
        }
        file write `macro1' "EDIT `r' `priorcol' `priorsd'" _n
        local ++r
      }
      else {
        file write `macro1' "EDIT `r' `priorcol' 0" _n
        local ++r
      }
    }
  }
  file write `macro1' "PRIO `priorcol'" _n
end

******************************************************************************
* CALCULATE RESIDUALS IN MLWIN
******************************************************************************
capture program drop runmlwin_calcresiduals
program define runmlwin_calcresiduals
  if _caller() >= 12 version 12.0
  if _caller() <= 9 version 9.0

  syntax , LEVEL(integer) LEVXID(string) NUMRPXVARS(string) RPXVARS(string) RESIDUALSX(string) MTYPE(string) [STANDardised LEVerage INFluence DELetion SAMPling REFlated VARiances noRECode RPAdjust noAdjust MCMC(string) CC(string) MMID(string) *] MACRO1(string) RESIDFile(string) MAXLEVELS(integer)

  local lids
  forvalues lev = `maxlevels'(-1)1 {
    local lids `lids' lev`lev'id(string)
  }

  local 0 ,`options'
  syntax, `lids'

  //if "`numrpxvars'" == "0" | "`mcmc'" ~= "" local numrpxvars "1"
  if "`numrpxvars'" == "0" local numrpxvars "1"

  file write `macro1' "NOTE   Store level `level' residuals" _n
  if "`recode'" ~= "" {
    file write `macro1' "MISR 0" _n
  }

  file write `macro1' "LINK 0 G21" _n // Residual Estimates
  file write `macro1' "LINK 0 G22" _n // Residual Standard Errors/Variance
  file write `macro1' "LINK 0 G23" _n // Standardised Residual Estimates
  file write `macro1' "LINK 0 G24" _n // Leverage Residuals
  file write `macro1' "LINK 0 G25" _n // Reflated Residuals
  file write `macro1' "LINK 0 G26" _n // Deletion Residuals
  file write `macro1' "LINK 0 G27" _n // Influence Residuals
  file write `macro1' "LINK 0 G28" _n // Sampling Residuals
  file write `macro1' "LINK 0 G29" _n // Temp
  file write `macro1' "LINK 0 G30" _n // Temp

  file write `macro1' "LINK `numrpxvars' G21" _n
  file write `macro1' "FILL G21" _n
  file write `macro1' "LINK `numrpxvars' G22" _n
  file write `macro1' "FILL G22" _n

  forvalues i = 1/`numrpxvars' {
    * Name the columns of residual estimates
    file write `macro1' "NAME  G21[`i'] '`residualsx'`=`i' - 1''" _n
    file write `macro1' "DESC  G21[`i'] '`residualsx'`=`i' - 1' residual estimate'" _n
  }

  if "`variances'" == "" {
    forvalues i = 1/`numrpxvars' {
      * Name the columns of residual standard errors
      file write `macro1' "NAME  G22[`i'] '`residualsx'`=`i' - 1'se'" _n
      file write `macro1' "DESC  G22[`i'] '`residualsx'`=`i' - 1'se residual standard error'" _n
    }
  }
  else {
    local residual_var
    forvalues i = 1/`numrpxvars' {
      * Name the columns of residual standard errors
      file write `macro1' "NAME  G22[`i'] '`residualsx'`=`i' - 1'var'" _n
      file write `macro1' "DESC  G22[`i'] '`residualsx'`=`i' - 1'var residual variance'" _n
    }
  }

  file write `macro1' "RFUN" _n
  if "`variances'" == "" file write `macro1' "ROUT G21 G22" _n      // Designate column c300 for residuals and column C301 for their associated variances
  else file write `macro1' "ROUT G21 G22" _n      // Designate column c300 for residuals and column C301 for their associated variances

  local ll = `level'
  if ("`mtype'"=="multivariate" | "`mtype'"=="multinomial") local ++ll
  file write `macro1' "RLEV `ll'" _n              // Specify the level at which variances are to be calculated
  file write `macro1' "RCOV 1" _n               // Output residuals and their variances

  if "`standardised'" ~= "" | "`deletion'" ~= "" | "`leverage'" ~= ""{      // deletion requires standardised to be calculated, leverage requires standard error calculated here
    file write `macro1' "LINK `numrpxvars' G23" _n
    file write `macro1' "FILL G23" _n
    forvalues i = 1/`numrpxvars' {
      * Name the columns of standardised residual estimates
      file write `macro1' "NAME  G23[`i'] '`residualsx'`=`i' - 1'std'" _n
      file write `macro1' "DESC  G23[`i'] '`residualsx'`=`i' - 1'std standardised residual'" _n
    }
    file write `macro1' "RTYP 0" _n               // Compute diagnostic variances
    if "`mcmc'" ~= "" {
      file write `macro1' "MCRE" _n               // Save the residuals and the variances
    }
    else {
      file write `macro1' "RESI" _n               // Save the residuals and the variances
    }
    local ccount = 1
    //if "`standardised'" ~= "" {
    forvalues i = 1/`numrpxvars' {
      file write `macro1' "CALC  G23[`i'] = G21[`i']/sqrt(G22[`i'])" _n         // Convert the variances to standard errors
    }
    //}
  }

  // NOTE leverage depends on residuals with rtype 0
  if "`leverage'" ~= "" | "`influence'" ~= "" { // influence requires leverage to be calculated
    file write `macro1' "LINK `numrpxvars' G24" _n
    file write `macro1' "FILL G24" _n

    forvalues i = 1/`numrpxvars' {
      * Name the columns of leverage residual estimates
      file write `macro1' "NAME  G24[`i'] '`residualsx'`=`i' - 1'lev'" _n
      file write `macro1' "DESC  G24[`i'] '`residualsx'`=`i' - 1'lev leverage residual'" _n
    }

    forvalues i = 1/`numrpxvars' {
      file write `macro1' "LINK 1 G30" _n
      file write `macro1' "OMEGa `ll' '`=word("`rpxvars'", `i')'' G30[1]" _n // retrieve variance for corresponding random parameter
      file write `macro1' "PICK 1 G30[1] b50" _n
      file write `macro1' "ERASe G30[1]" _n
      file write `macro1' "LINK 0 G30" _n
      file write `macro1' "CALC G24[`i'] = 1 - sqrt(G22[`i']) / sqrt(b50)" _n
    }
    if "`standardised'" == "" & "`deletion'" == "" {
      file write `macro1' "ERASE G23" _n
      file write `macro1' "LINK 0 G23" _n
    }
  }

  if "`adjust'" == "noadjust" {
    file write `macro1' "RTYP 3" _n                 // No adjustment
  }
  else if "`rpadjust'" ~= "" {
    file write `macro1' "RTYP 2" _n                 // Fixed and Random part adjustment
  }
  else {
    file write `macro1' "RTYP 1" _n                 // Fixed part adjustment
  }

  if "`mcmc'" ~= "" {
    file write `macro1' "MCRE" _n                 // Save the residuals and the variances
  }
  else {
    file write `macro1' "RESI" _n                 // Save the residuals and the variances
  }

  if "`reflated'" ~= "" {
    file write `macro1' "LINK `numrpxvars' G25" _n
    file write `macro1' "FILL G25" _n
    forvalues i = 1/`numrpxvars' {
      * Name the columns of reflated residual estimates
      file write `macro1' "NAME G25[`i'] '`residualsx'`=`i' - 1'ref'" _n
      file write `macro1' "DESC G25[`i'] '`residualsx'`=`i' - 1' reflated residual estimate'" _n
    }
  }

  if "`reflated'" ~= "" {
    file write `macro1' "REFLate G21 G25" _n
  }

  if "`variances'" == "" {
    forvalues i = 1/`numrpxvars' {
      file write `macro1' "CALC G22[`i'] = sqrt(G22[`i'])" _n         // Convert the variances to standard errors
    }
  }

  if "`deletion'" ~= "" | "`influence'" ~= "" { // influence requires deletion to be calculated
    forvalues i = 1/`numrpxvars' {
      file write `macro1' "LINK `numrpxvars' G26" _n
      file write `macro1' "FILL G26" _n
      * Name the columns of deletion residual estimates
      file write `macro1' "NAME  G26[`i'] '`residualsx'`=`i' - 1'del'" _n
      file write `macro1' "DESC  G26[`i'] '`residualsx'`=`i' - 1'del deletion residual'" _n
    }

    file write `macro1' "NOBS `ll' b31 b32" _n
    forvalues i = 1/`numrpxvars' {
      file write `macro1' "CALC  G26[`i'] = G23[`i'] / sqrt((b31 - 1 - G23[`i'] ^2)/(b31 - 2))" _n
    }

    if "`standardised'" == "" & "`leverage'" == ""{
      file write `macro1' "ERASE G23" _n
      file write `macro1' "LINK 0 G23" _n
    }
  }

  if "`influence'" ~= "" {
    forvalues i = 1/`numrpxvars' {
      file write `macro1' "LINK `numrpxvars' G27" _n
      file write `macro1' "FILL G27" _n
      * Name the columns of influence residual estimates
      file write `macro1' "NAME  G27[`i'] '`residualsx'`=`i' - 1'inf'" _n
      file write `macro1' "DESC  G27[`i'] '`residualsx'`=`i' - 1'inf influence residual'" _n
    }

    forvalues i = 1/`numrpxvars' {
      file write `macro1' "SUM G24[`i'] b50" _n
      file write `macro1' "CALC G27[`i'] = G24[`i'] / b50" _n
      file write `macro1' "CALC G27[`i'] = sqrt(G27[`i'] / (1 - G27[`i'])) * abso(G26[`i'])" _n
    }

    if "`deletion'" == "" {
      file write `macro1' "ERASE G26" _n
      file write `macro1' "LINK 0 G26" _n
    }
    if "`leverage'" == "" {
      file write `macro1' "ERASE G24" _n
      file write `macro1' "LINK 0 G24" _n
    }
  }

  if "`sampling'" ~= "" {
    file write `macro1' "LINK `=(`numrpxvars'*(`numrpxvars'+1))/2' G28" _n

    local numcombs = 0
    forvalues i = 1/`numrpxvars' {
      forvalues j = 1/`i' {
        local ++numcombs
        if `i' == `j' {
          file write `macro1' "NAME  G28[`numcombs'] '`residualsx'`=`j'-1'var'" _n
          file write `macro1' "DESC  G28[`numcombs'] '`residualsx'`=`j'-1'var sampling variance'" _n
        }
        else {
          file write `macro1' "NAME  G28[`numcombs'] '`residualsx'`=`j'-1'`residualsx'`=`i'-1'cov'" _n
          file write `macro1' "DESC  G28[`numcombs'] '`residualsx'`=`j'-1'`residualsx'`=`i'-1'cov sampling covariance'" _n
        }
      }
    }

    file write `macro1' "LINK `numrpxvars' G29" _n
    file write `macro1' "FILL G29" _n

    file write `macro1' "LINK 2 G30" _n
    file write `macro1' "FILL G30" _n

    file write `macro1' "RFUN " _n
    file write `macro1' "ROUT G29 G30[2]" _n
    file write `macro1' "RCOV 2" _n
    file write `macro1' "RESI" _n

    // NOTE: This is square rooted, as the residual covariances are sometimes negative
    file write `macro1' "NOBS `ll' b31 b32" _n
    file write `macro1' "CODE `numcombs' 1 b31 G30[1]" _n
    file write `macro1' "SPLIt G30[2] G30[1] G28" _n
    file write `macro1' "ERAS G30" _n
    file write `macro1' "LINK 0 G30" _n
    file write `macro1' "ERAS G29" _n
    file write `macro1' "LINK 0 G29" _n
  }

  file write `macro1' _n

  file write `macro1' "LINK 1 G30" _n
  file write `macro1' "NOBS `ll' b30 b31" _n
  file write `macro1' "GENE 1 b30 1 G30[1]" _n
  file write `macro1' "NAME G30[1] '_residualid'" _n

  file write `macro1' "LINK 4 G29" _n
  // Generate ID column the same length as the residuals
  if ("`cc'"=="") {
    local hier
    forvalues lev = `level'/`maxlevels' {
      local hier '`lev`level'id'' `hier'
    }
    file write `macro1' "COMB `hier' G29[4]" _n
    file write `macro1' "TAKE G29[4] '`lev`level'id'' G29[3] G29[2]" _n
    file write `macro1' "ERAS G29[3] G29[4]" _n
  }
  if "`mmid'" ~= "" {
    file write `macro1' "ERAS G29[1]" _n
    foreach varname of varlist `mmid' {
      file write `macro1' "APPE G29[1] '`varname'' G29[1]" _n
    }
    file write `macro1' "UNIQ G29[1] G29[2]" _n
    file write `macro1' "OMIT 0 G29[2] G29[2]" _n
  }
  else file write `macro1' "UNIQ '`lev`level'id'' G29[2]" _n
  // Temporary rename level ID column so there isn't a duplicate
  file write `macro1' "NAME '`lev`level'id'' '_`lev`level'id''" _n
  file write `macro1' "NAME G29[2] '`lev`level'id''" _n
  file write `macro1' "DESC G29[2] '\\`:variable label `lev`level'id'''" _n

  if ("`cc'"~="") { // Ensure the data is sorted by ID variable, as the residual ID is based on it this should already be the case
    file write `macro1' "SORT 1 '`lev`level'id'' '_residualid' G21 G22 G23 G24 G25 G26 G27 G28 '`lev`level'id'' '_residualid' G21 G22 G23 G24 G25 G26 G27 G28" _n
  }
  file write `macro1' "PSTA '`residfile'' '_residualid' '`lev`level'id'' G21 G22 G23 G24 G25 G26 G27 G28" _n
  file write `macro1' "ERAS '_residualid' G21 G22 G23 G24 G25 G26 G27 G28 G29" _n
  file write `macro1' "LINK 0 G21" _n
  file write `macro1' "LINK 0 G22" _n
  file write `macro1' "LINK 0 G23" _n
  file write `macro1' "LINK 0 G24" _n
  file write `macro1' "LINK 0 G25" _n
  file write `macro1' "LINK 0 G26" _n
  file write `macro1' "LINK 0 G27" _n
  file write `macro1' "LINK 0 G28" _n
  file write `macro1' "LINK 0 G29" _n

  // Restore level ID column name
  file write `macro1' "NAME '_`lev`level'id'' '`lev`level'id''" _n

  if "`recode'" ~= "" {
    file write `macro1' "MISR 1" _n
  }
end

******************************************************************************
* MERGE THE SAVED MLWIN RESIDUALS BACK TO THE ORIGINAL STATA DATA SET
******************************************************************************
capture program drop runmlwin_mergeresiduals
program define runmlwin_mergeresiduals, sortpreserve
  if _caller() >= 12 version 12.0
  if _caller() <= 9 version 9.0
  syntax , NUMLevels(int) TOUSE(string) HIER(string) [CC(string) LEVELID(string) SORT(string) MMID(string)] RESIDFile(string)

  if "`sort'" ~= "" & "`cc'" == "" & `numlevels' > 1 {
    display as error "Residuals cannot be reliably merged back when nosort is specified"
    exit 198
  }

  local levXid_and_higher_levels `hier' // use this if hierarchical model
  local levXid `levelid'      // Use this if XC model

  if `numlevels'==1 {     // In single level models the observation/row number is the unique ID
    quietly gen _residualid = _n if `touse' == 1
    if _caller() >= 11 {
      qui merge m:1 _residualid using "`residfile'", assert(master match) nogenerate noreport
    }
    else {
      mata: setsortorder("`residfile'", "_residualid")
      sort _residualid
      quietly merge _residualid using "`residfile'", uniqusing //sort
      assert inlist(_merge,1,3)
      drop _merge
    }
    drop _residualid
  }
  else {
    if ("`cc'"~="") {       // cross-classified models in MCMC can have non-nested IDs in which case user must specify unique IDs
      //tempvar temp
      //gen `temp' = `levXid'
      //replace `temp' = `c(minfloat)' if `levXid'==.
      //quietly egen _residualid = group(`temp') if `touse' == 1, missing
      if "`mmid'" ~= "" {
        local mmnum 1
        foreach var of varlist `mmid' {
          rename `levelid' _`levelid'
          if "`levelid'" == "`var'" {
            gen `levelid' = _`levelid'
          }
          else {
            gen `levelid' = `var'
          }
          unab oldvars: *
          if _caller() >= 11 {
            qui merge m:1 `levelid' using "`residfile'", keep(master match) nogenerate noreport
          }
          else {
            mata: setsortorder("`residfile'", "`levelid'")
            sort `levelid'
            quietly merge `levelid' using "`residfile'", uniqusing nokeep //sort
            drop _merge
          }
          drop _residualid
          unab allvars: *
          local newvars :list allvars - oldvars
          if _caller() >= 12 {
            rename (`newvars') (=_`mmnum')
          }
          else {
            foreach newvar of varlist `newvars' {
              rename `newvar' `newvar'_`mmnum'
            }
          }
          local ++mmnum
          drop `levelid'
          rename _`levelid' `levelid'
        }
      }
      else {
        if _caller() >= 11 {
          qui merge m:1 `levelid' using "`residfile'", assert(master match) nogenerate noreport
        }
        else {
          //mata: setsortorder("`residfile'", "`levelid'")
          sort `levelid'
          preserve
            use "`residfile'", clear
            quietly sort `levelid' // Make sure using data set is sorted
            quietly compress
            quietly save, replace
          restore
          quietly merge `levelid' using "`residfile'", uniqusing
          assert inlist(_merge,1,3)
          drop _merge
        }
        drop _residualid
      }
    }
    else {          // hierarchical models
      quietly egen _residualid = group(`levXid_and_higher_levels') if `touse' == 1, missing
      if _caller() >= 11 {
        qui merge m:1 _residualid using "`residfile'", assert(master match) nogenerate noreport
      }
      else {
        mata: setsortorder("`residfile'", "_residualid")
        sort _residualid
        quietly merge _residualid using "`residfile'", uniqusing //sort
        assert inlist(_merge,1,3)
        drop _merge
      }
      drop _residualid
    }
  }


end

******************************************************************************
* MERGE THE SAVED MLWIN FACTOR VALUES BACK TO THE ORIGINAL STATA DATA SET
******************************************************************************
capture program drop runmlwin_mergefscores
program define runmlwin_mergefscores, sortpreserve
  if _caller() >= 12 version 12.0
  if _caller() <= 9 version 9.0
  syntax , NUMLevels(int) TOUSE(string) HIER(string) [CC(string) LEVELID(string) SORT(string)] FSCORESFile(string)

  if "`sort'" ~= "" & "`cc'" == "" & `numlevels' > 1 {
    display as error "Factor scores cannot be reliably merged back when nosort is specified"
    exit 198
  }

  local levXid_and_higher_levels `hier' // use this if hierarchical model
  local levXid `levelid'      // Use this if XC model

  if `numlevels'==1 {     // In single level models the observation/row number is the unique ID
    quietly gen _fscoreid = _n if `touse' == 1
  }
  else {
    if ("`cc'"~="") {       // cross-classified models in MCMC can have non-nested IDs in which case user must specify unique IDs
      quietly egen _fscoreid = group(`levXid') if `touse' == 1, missing
    }
    else {          // hierarchical models
      quietly egen _fscoreid = group(`levXid_and_higher_levels') if `touse' == 1, missing
    }
  }

  if _caller() >= 11 {
    qui merge m:1 _fscoreid using "`fscoresfile'", assert(master match) nogenerate
  }
  else {
    mata: setsortorder("`fscoresfile'", "_fscoreid")

    sort _fscoreid
    quietly merge _fscoreid using "`fscoresfile'", uniqusing //sort
    assert inlist(_merge,1,3)
    drop _merge
  }
  drop _fscoreid
end

******************************************************************************
* MERGE THE SAVED MLWIN SIMULATED RESPONSE BACK TO THE ORIGINAL STATA DATA SET
******************************************************************************
capture program drop runmlwin_mergesimresp
program define runmlwin_mergesimresp
  if _caller() >= 12 version 12.0
  if _caller() <= 9 version 9.0
  syntax , SIMFile(string)
  quietly gen _simprespid = _n

  if _caller() >= 11 {
    qui merge m:1 _simprespid using "`simfile'", assert(match) nogenerate
  }
  else {
    quietly merge _simprespid using "`simfile'", uniqusing sort
    assert inlist(_merge,3)
    drop _merge
  }
  drop _simprespid
end

******************************************************************************
* SAVE THE MCMC CHAIN RESIDUALS AT EACH LEVEL TO STATA DATA SETS
******************************************************************************
capture program drop runmlwin_savechains
program define runmlwin_savechains
  if _caller() >= 12 version 12.0
  if _caller() <= 9 version 9.0
  syntax , PARNames(string) CHAINResults(string)

  use "`chainresults'", clear

  local colnames
  foreach var of local parnames  {
    if _caller() >= 11.1 {
      local colnames `colnames' `=strtoname("`var'")'
    }
    else {
      mata: st_local("tmpname", validname("`var'"))
      local colnames `colnames', "`=abbrev("`tmpname'", 32)'"
    }
  }
  if _caller() >= 11.1 {
    qui putmata runmlwin_chains = (iteration `colnames' deviance), replace
  }
  else {
    mata: runmlwin_chains = st_data(., ("iteration" `colnames', "deviance"))
  }

end

******************************************************************************
* DISPLAY MODEL RESULTS
******************************************************************************
capture program drop runmlwin_display
program runmlwin_display
  if _caller() >= 12 version 12.0
  if _caller() <= 9 version 9.0
  syntax [, OR IRr RRr SD CORrelations level(cilevel) CFORMAT(string) PFORMAT(string) SFORMAT(string) noHEADer noGRoup noCONTrast noFETable noRETable MOde MEdian ZRatio * ]

  if "`or'" ~= "" & !inlist("`e(link)'", "logit", "ologit") {
    display as error "Odds ratio options is only valid for univariate logit models"
    exit 198
  }

  if "`rrr'" ~= "" & "`e(link)'" ~= "mlogit" {
    display as error "Relative-rate ratio options is only valid for univariate unordered multinomial logit models"
    exit 198
  }

  local tmppois "poisson"
  local tmpnbin "nbinomial"
  local distribution `e(distribution)'
  if "`irr'" ~= "" & ~`:list tmppois in distribution' & ~`:list tmpnbin in distribution' {
    display as error "Incidence-rate ratio options is only valid for univariate poisson or negative binomial models"
    exit 198
  }

  if "`mode'" ~= "" & "`median'" ~= "" {
    display as error "Only specify one of mode or median"
    exit 198
  }

  if "`mode'" ~= "" {
    local esttype mode
  }
  else if "`median'" ~= "" {
    local esttype median
  }
  else {
    local esttype mean
  }

  local eform = 0
  if "`or'" ~= "" | "`irr'" ~= "" | "`rrr'" ~= "" local eform = 1

  * Univariate or Multinomial model
  local mtype univariate
  if "`e(distribution)'" == "multinomial" {
    local mtype multinomial
    local respcats `e(respcategories)'
  }
  local responses `e(depvars)'
  if `:list sizeof responses' > 1 local mtype multivariate

  * Check whether all the responses in a multivariate response model are normal or not
  local allnormal 1
  local resptypes `e(distribution)'
  forvalues n = 1/`:list sizeof resptypes' {
    if "`=word("`resptypes'", `n')'" != "normal" {
      local allnormal 0
    }
  }

  * Info required for both the FP and RP tables
  local multiplier = invnormal(1 - ((100 - `level')/2)/100) // returns 1.96 if 95% confidence intervals are requested
  local kk = length("`level'") // as in 95 is two characters but 7 is only 1 character

  * Numeric formatting
  if `"`cformat'"' == "" {
    local cformat `c(cformat)'
  }
  if `"`cformat'"' == "" {
    local cformat %9.0g
  }
  if fmtwidth(`"`cformat'"') > 9 {
    local cformat %9.0g
    display as text "note: invalid cformat(), using default"
  }
  if `"`pformat'"' == "" {
    local pformat `c(pformat)'
  }
  if `"`pformat'"' == "" {
    local pformat %5.3f
  }
  if fmtwidth(`"`pformat'"') > 5 {
    local pformat %5.3f
    display as text "note: invalid pformat(), using default"
  }
  if `"`sformat'"' == "" {
    local sformat `c(sformat)'
  }
  if `"`sformat'"' == "" {
    local sformat %8.2f
  }
  if fmtwidth(`"`sformat'"') > 8 {
    local sformat %8.2f
    display as text "note: invalid sformat(), using default"
  }

  * Header
  if "`header'" == "" {
    * Display estimation algorithm
    quietly runmlwin_verinfo $MLwiN_path // This may be inaccurate if the user changes version between estimation and display (or uses the plugin)
    display as text "MLwiN `e(version)' multilevel model" _c
    display _col(49) as text "Number of obs" _col(68) "=" _col(70) as result %9.0g e(N)
    di as txt "`e(title)'"
    display as text "Estimation algorithm: " as result "`e(method)'" _c
    if ("`e(linearization)'"~="" & "`e(method)'"~="MCMC") display as text ", " as result "`e(linearization)'" _c

    if "`group'" == "" {
      display ""
      * Display number of units at each level of the model hierarchy
      if e(numlevels)>1 {
        if "`e(N_g)'" == "" | "`e(g_min)'" == "" | "`e(g_avg)'" == "" | "`e(g_max)'" == "" {
          display as error "Grouping information is not available when nosort option is specified"
        }
        else {
          local ivars `e(ivars)'
          local levels : list uniq ivars
          tempname Ng min avg max
          mat `Ng' = e(N_g)
          mat `min' = e(g_min)
          mat `avg' = e(g_avg)
          mat `max' = e(g_max)

          di
          di as txt "{hline 16}{c TT}{hline 42}
          di as txt _col(17) "{c |}" _col(21) "No. of" _continue
          di as txt _col(34) "Observations per Group"
          di as txt _col(2) "Level Variable" _col(17) "{c |}" _continue
          di as txt _col(21) "Groups" _col(31) "Minimum" _continue
          di as txt _col(42) "Average" _col(53) "Maximum"
          di as txt "{hline 16}{c +}{hline 42}"
          local i 1
          foreach k of local levels {
            local lev = abbrev("`k'",12)
            local p = 16 - length("`lev'")
            di as res _col(`p') "`lev'" _continue
            di as txt _col(17) "{c |}" _continue
            di as res _col(19) %8.0g `Ng'[1,`i'] _continue
            di as res _col(29) %9.0g `min'[1,`i'] _continue
            di as res _col(40) %9.1f `avg'[1,`i'] _continue
            di as res _col(51) %9.0g `max'[1,`i']
            local ++i
          }
          di as txt "{hline 16}{c BT}{hline 42}"
        }
      }
    }

    * Weights
    //         1         2         3         4         5         6         7
    //123456789012345678901234567890123456789012345678901234567890123456789012345678
    //-------------------------------------------
    //                |           Weights
    // Level Variable |     Variable         Type
    //----------------+--------------------------
    //        Unit ID | ############ standardised
    //-------------------------------------------

    local maxlevels = e(numlevels)
    local hasweights = 0
    forvalues l = `maxlevels'(-1)1 {
      if "`e(weighttype`l')'" ~= "" {
        local hasweights = 1
      }
    }

    if "`hasweights'" == "1" {
      local ivars `e(ivars)'
      local levels : list uniq ivars
      di
      di as txt "{hline 16}{c TT}{hline 26}
      di as txt _col(17) "{c |}" _col(29) "Weights"
      di as txt _col(2) "Level Variable" _col(17) "{c |}" _col(23) "Variable" _col(40) "Type"
      di as txt "{hline 16}{c +}{hline 26}"
      forvalues l = `maxlevels'(-1)1 {
        if "`e(weighttype`l')'" ~= "" {
          if "`l'" ~= "1" {
            local lev = abbrev(word("`levels'", `=`l'-1') ,12)
          }
          else {
            local lev `e(level1var)'
          }

          local weightvar = abbrev("`e(weightvar`l')'",12)
          local p1 = 16 - length("`lev'")
          local p2 = 31 - length("`weightvar'")
          local p3 = 44 - length("`e(weighttype`l')'")
          di as res _col(`p1') "`lev'" as txt _col(17) "{c |}"  as txt _col(`p2') "`weightvar'" _col(`p3') "`e(weighttype`l')'"
        }
      }
      di as txt "{hline 16}{c BT}{hline 26}"
    }

    * Key for the contrasts in multinomial models
    if "`contrast'" == "" {
      if "`e(distribution)'"=="multinomial" {
        display ""
        local respcategories `e(respcategories)'
        local basecategory `e(basecategory)'
        local num_respcategories = wordcount("`respcategories'")
        tokenize "`respcategories'"

        local p = length("`respcategories'") + 4
        if (`p'<20) local p = 20

        di as txt "{hline 13}{c TT}{hline `p'}
        di as txt _col(5) "Contrast" _col(14) "{c |}" ///
          _col(16) "Log-odds"
        di as txt "{hline 13}{c +}{hline 20}"

        * Unordered
        if "`e(link)'"=="mlogit" {
          local contrast_denom = `basecategory'
          local contrast_numers : list respcategories - contrast_denom
          forvalues contrast = 1/`=`num_respcategories' - 1' {
            local respcategory : word `contrast' of `contrast_numers' //= word("`contrast_numers'",`contrast')
            local p = 13 - length("`contrast'")

            di as res  _col(`p') "`contrast'" as txt _col(14) "{c |}" _c
            di as res " `respcategory'" as txt " vs. " as res "`basecategory'"
          }
        }

        * Ordered
        if "`e(link)'"=="ologit"|"`e(link)'"=="oprobit"|"`e(link)'"=="ocloglog" {
          local first ""
          forvalues contrast = 1/`=`num_respcategories' - 1' {
            local first `first' `1'
            macro shift
            local rest `*'

            * Lowest response value is basecategory
            if (`basecategory'==real(word("`respcategories'",1))) {
              local contrast_numer `rest'
              local contrast_denom `first'
            }

            * Highest response value is basecategory
            if (`basecategory'==real(word("`respcategories'",-1))) {
              local contrast_numer `first'
              local contrast_denom `rest'

            }
            local p = 13 - length("`contrast'")
            di as res  _col(`p') "`contrast'"  as txt _col(14) "{c |}" _c
              di as res " `contrast_numer'" as txt " vs. " as res "`contrast_denom'"

          }

        }
        di as txt "{hline 13}{c BT}{hline 20}"
      }
    }

    * Display model fit statistics
    if e(method)=="IGLS" | e(method)=="RIGLS" {
      display ""
      if e(method)=="IGLS" & `allnormal'==1 {
        display as text "Run time (seconds)"    _col(22) "= " as result %10.2f e(time)
        display as text "Number of iterations"  _col(22) "= " as result %10.0f e(iterations)
        if `e(ll)' == . {
          display as error "Caution. MLwiN was unable to calculate the log likelihood, there may be a problem with your model"
        }
        display as text "Log likelihood"  _col(22) "= " as result %10.0g e(ll)
        display as text "Deviance"    _col(22) "= " as result %10.0g -2*e(ll)
      }
      if e(method)=="RIGLS" & `allnormal'==1 {
        display as text "Run time (seconds)"      _col(27) "= " as result %10.2f e(time)
        display as text "Number of iterations"    _col(27) "= " as result %10.0f e(iterations)
        if `e(ll)' == . {
          display as error "Caution. MLwiN was unable to calculate the log likelihood, there may be a problem with your model"
        }
        display as text "Log restricted-likelihood"   _col(27) "= " as result %10.0g e(ll)
        display as text "Restricted-deviance"     _col(27) "= " as result %10.0g -2*e(ll)
      }
      if `allnormal'==0 {
        display as text "Run time (seconds)"      _col(22) "= " as result %10.2f e(time)
        display as text "Number of iterations"    _col(22) "= " as result %10.0f e(iterations)
      }
    }

    if e(method)=="MCMC" {
      display ""
      display as text "Burnin"      _col(28) "= " as result %10.0f e(burnin)
      display as text "Chain"       _col(28) "= " as result %10.0f e(chain)
      display as text "Thinning"        _col(28) "= " as result %10.0f e(thinning)
      display as text "Run time (seconds)"            _col(28) "= " as result %10.3g e(time)
      display as text "Deviance (dbar)"     _col(28) "= " as result %10.2f e(dbar)
      display as text "Deviance (thetabar)"     _col(28) "= " as result %10.2f e(dthetabar)
      display as text "Effective no. of pars (pd)"  _col(28) "= " as result %10.2f e(pd)
      display as text "Bayesian DIC"      _col(28) "= " as result %10.2f e(dic)
    }
  }

  * FE table
  // IGLS FP
  //         1         2         3         4         5         6         7
  //123456789012345678901234567890123456789012345678901234567890123456789012345678
  //------------------------------------------------------------------------------
  //    normexam |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
  //-------------+----------------------------------------------------------------
  //        cons |  #########  #########  ########  ######   #########   #########
  //------------------------------------------------------------------------------
  // MCMC FP
  //         1         2         3         4         5         6         7
  //123456789012345678901234567890123456789012345678901234567890123456789012345678
  //------------------------------------------------------------------------------
  //    normexam |      Mean    Std. Dev.      z      ESS     [95% Cred. Interval]
  //-------------+----------------------------------------------------------------
  //        cons |  #########  #########  ########  ######   #########   #########
  //------------------------------------------------------------------------------
  if "`fetable'" == "" {
    * Display fixed part of the model
    display as txt "{hline 13}{c TT}{hline 64}

    if ("`mtype'"=="univariate") {
      local p = 13 - length("`=abbrev("`e(depvars)'", 12)'")
      if e(method)~="MCMC" {
        display as txt _col(`p') "`=abbrev("`e(depvars)'", 12)'" _continue
        display as txt _col(14) "{c |}" _continue
        if "`or'" ~= "" display as txt _col(16) "Odds Ratio" _continue
        if "`irr'" ~= "" display as txt _col(23) "IRR" _continue
        if "`rrr'" ~= "" display as txt _col(23) "RRR" _continue
        if "`or'" == "" & "`irr'" == "" & "`rrr'" == "" display as txt _col(21) "Coef." _continue
        display as txt _col(29) "Std. Err." _continue
        display as txt _col(44) "z" _continue
        display as txt _col(49) "P>|z|" _continue
        display as txt _col(`=61 -`kk'') `"[`=strsubdp("`level'")'% Conf. Interval]"'
      }
      if e(method)=="MCMC" {
        display as txt _col(`p') "`=abbrev("`e(depvars)'", 12)'" _continue
        display as txt _col(14) "{c |}" _continue
        if "`or'" ~= "" display as txt _col(16) "Odds Ratio" _continue
        if "`irr'" ~= "" display as txt _col(23) "IRR" _continue
        if "`rrr'" ~= "" display as txt _col(23) "RRR" _continue
        if "`or'" == "" & "`irr'" == "" & "`rrr'" == "" {
          if "`esttype'" == "mode" {
            display as txt _col(21) "Mode" _continue
          }
          else if "`esttype'" == "median" {
            display as txt _col(19) "Median" _continue
          }
          else {
            display as txt _col(21) "Mean" _continue
          }
        }
        display as txt _col(29) "Std. Dev." _continue
        if "`zratio'" ~= "" {
          display as txt _col(44) "z" _continue
          display as txt _col(49) "P>|z|" _continue
        }
        else {
          display as txt _col(43) "ESS" _continue
          display as txt _col(51) "P" _continue
        }
        display as txt _col(`=61 -`kk'') `"[`=strsubdp("`level'")'% Cred. Interval]"'
      }
    }
    else {
      if e(method)~="MCMC" {
        display as txt _col(14) "{c |}" _continue
        if "`or'" ~= "" display as txt _col(16) "Odds Ratio" _continue
        if "`irr'" ~= "" display as txt _col(23) "IRR" _continue
        if "`rrr'" ~= "" display as txt _col(23) "RRR" _continue
        if "`or'" == "" & "`irr'" == "" & "`rrr'" == "" display as txt _col(21) "Coef." _continue
        display as txt _col(29) "Std. Err." _continue
        display as txt _col(44) "z" _continue
        display as txt _col(49) "P>|z|" _continue
        display as txt _col(`=61 -`kk'') `"[`=strsubdp("`level'")'% Conf. Interval]"'
      }
      if e(method)=="MCMC" {
        display as txt _col(14) "{c |}" _continue
        if "`or'" ~= "" display as txt _col(16) "Odds Ratio" _continue
        if "`irr'" ~= "" display as txt _col(23) "IRR" _continue
        if "`rrr'" ~= "" display as txt _col(23) "RRR" _continue
        if "`or'" == "" & "`irr'" == "" & "`rrr'" == "" {
          if "`esttype'" == "mode" {
            display as txt _col(21) "Mode" _continue
          }
          else if "`esttype'" == "median" {
            display as txt _col(19) "Median" _continue
          }
          else {
            display as txt _col(21) "Mean" _continue
          }
        }
        display as txt _col(29) "Std. Dev." _continue
        if "`zratio'" ~= "" {
          display as txt _col(44) "z" _continue
          display as txt _col(49) "P>|z|" _continue
        }
        else {
          display as txt _col(43) "ESS" _continue
          display as txt _col(51) "P" _continue
        }
        display as txt _col(`=61 -`kk'') `"[`=strsubdp("`level'")'% Cred. Interval]"'
      }
    }

    local eqlist :coleq e(b)
    local eqlist :list uniq eqlist
    local fpeqlist
    foreach eq of local eqlist {
      if (substr("`eq'",1,2)=="FP") local fpeqlist `fpeqlist' `eq'
    }

    local eqnum 0
    foreach eq in `fpeqlist' {
      local ++eqnum
      display as txt "{hline 13}{c +}{hline 64}"
      if "`mtype'" == "multivariate" && `:list sizeof responses' >= `eqnum'{
        display as res "`=word("`responses'", `eqnum')'" as txt _col(14) "{c |}"
      }

      if "`mtype'" == "multinomial" && `:list sizeof respcats' > `eqnum'{
        display as res "Contrast `eqnum'" as txt _col(14) "{c |}"
      }

      local r = 1
      tempname matb matV matb_eq matV_eq
      matrix `matb' = e(b)
      matrix `matV' = e(V)
      matrix `matb_eq' = `matb'[1, "`eq':"]
      matrix `matV_eq' = `matV'["`eq':", "`eq':"]

      if e(method)=="MCMC" & e(mcmcdiagnostics)==1 {
        tempname matress matrlb matrub matrmode matrmedian matp matess_eq matlb_eq matub_eq matmode_eq matmedian_eq matp_eq
        matrix `matress' = e(ess)
        matrix `matrlb' = e(lb)
        matrix `matrub' = e(ub)
        matrix `matrmode' = e(mode)
        matrix `matrmedian' = e(quantiles)
        if "`esttype'" == "mode" {
          matrix `matp' = e(pvalmode)
        }
        else if "`esttype'" == "median" {
          matrix `matp' = e(pvalmedian)
        }
        else {
          matrix `matp' = e(pvalmean)
        }
        matrix `matess_eq' = `matress'[1, "`eq':"]
        matrix `matlb_eq' = `matrlb'[1, "`eq':"]
        matrix `matub_eq' = `matrub'[1, "`eq':"]
        matrix `matmode_eq' = `matrmode'[1, "`eq':"]
        * NOTE: This assumes that the median is always the fifth row
        matrix `matmedian_eq' = `matrmedian'[5, "`eq':"]
        matrix `matp_eq' = `matp'[1, "`eq':"]
      }


      local names :colnames `matb_eq'

      tempname matest matse matess matub matlb matmode matmedian
      foreach par of local names {
        * Exponential form
        if `eform' == 1 {
          * MCMC
          if e(method)=="MCMC" & e(mcmcdiagnostics)==1 {
            tempname expchain
            local colnames :colfullnames e(b)
            mata: `expchain' = exp(runmlwin_chains[ , `=`:list posof "`eq':`par'" in colnames' + 1'])
            preserve
            drop _all
            label drop _all
            if _caller() >= 11.1 {
              getmata (`expchain') = `expchain'
            }
            else {
              mata: (void) st_addvar("double", "`expchain'")
              mata: st_addobs(length(`expchain'))
              mata: st_store(., "`expchain'", `expchain')
            }
            mata: mata drop `expchain'
            local posit = 0
            if regexm("`par'", "(var)[\(]([a-zA-Z0-9_]+)[\)]") == 1 {
              local posit = 1
            }
            quietly runmlwin_mcmcdiag `expchain', level(`level') thinning(e(thinning)) posit(`posit') `eform'
            mat `matest' = r(mean)
            mat `matse' = r(sd)*r(sd)
            mat `matess' = r(ESS)
            mat `matlb' = r(lb)
            mat `matub' = r(ub)
            mat `matmode' = r(mode)
            mat `matmedian' = r(quantiles)
            * NOTE: This assumes that the median is always the fifth row
            mat `matmedian' = `matmedian'[5, 2]
            restore
          }
          * (R)IGLS
          else {
            capture quietly nlcom (eform: exp([`eq']`par'))
            if !_rc {
              mat `matlb' = exp(`matb_eq'[1, `r'] - `multiplier'*sqrt(`matV_eq'[`r',`r']))
              mat `matub' = exp(`matb_eq'[1, `r'] + `multiplier'*sqrt(`matV_eq'[`r',`r']))
              mat `matest' = r(b)
              mat `matse' = r(V)
              mat `matest' = `matest'[1,1]
              mat `matse' = `matse'[1,1]
            }
            else {
              mat `matest' = J(1, 1, .)
              mat `matse' = J(1, 1, .)
              mat `matlb' = J(1, 1, .)
              mat `matub' = J(1, 1, .)
            }
          }
        }
        * Original estimation metric
        else {
          matrix `matest' = `matb_eq'[1, `r']
          matrix `matse' = `matV_eq'[`r',`r']
          matrix `matlb' = `matest'[1, 1] - `multiplier'*sqrt(`matse'[1, 1])
          matrix `matub' = `matest'[1, 1] + `multiplier'*sqrt(`matse'[1, 1])

          * MCMC
          if e(method)=="MCMC" & e(mcmcdiagnostics)==1 {
            if e(level) == `level' {
              mat `matess' = `matess_eq'[1, `r']
              mat `matlb' = `matlb_eq'[1, `r']
              mat `matub' = `matub_eq'[1, `r']
              mat `matmode' = `matmode_eq'[1, `r']
              mat `matmedian' = `matmedian_eq'[1, `r']
            }
            else {
              tempname estchain
              local colnames :colfullnames e(b)
              mata: `estchain' = runmlwin_chains[ , `=`:list posof "`eq':`par'" in colnames' + 1']
              preserve
              drop _all
              label drop _all
              if _caller() >= 11.1 {
                getmata (`estchain') = `estchain'
              }
              else {
                mata: (void) st_addvar("double", "`estchain'")
                mata: st_addobs(length(`estchain'))
                mata: st_store(., "`estchain'", `estchain')
              }
              mata: mata drop `estchain'
              local posit = 0
              if regexm("`par'", "(var)[\(]([a-zA-Z0-9_]+)[\)]") == 1 {
                local posit = 1
              }
              quietly runmlwin_mcmcdiag `estchain', level(`level') thinning(e(thinning)) posit(`posit') `eform'
              mat `matlb' = r(lb)
              mat `matub' = r(ub)

              restore
            }
          }
        }

        local varname `=abbrev("`par'", 12)'
        local k = length("`varname'")
        local p = 13 - `k'
        if e(method)~="MCMC" {
          display as txt _col(`p') "`varname'" _continue
          display as txt _col(14) "{c |}" _continue
          display as res _col(17) `cformat' `matest'[1, 1] _continue
          display as res _col(28) `cformat' sqrt(`matse'[1, 1]) _continue
          display as res _col(36) `sformat' `matb_eq'[1, `r']/sqrt(`matV_eq'[`r',`r']) _continue
          display as res _col(49) `pformat' 2*normal(-abs(`matb_eq'[1, `r']/sqrt(`matV_eq'[`r',`r']))) _continue
          display as res _col(58) `cformat' `matlb'[1, 1] _continue
          display as res _col(70) `cformat' `matub'[1, 1]
          local ++r
        }
        if e(method)=="MCMC" {
          display as txt _col(`p') "`varname'" _continue
          display as txt _col(14) "{c |}" _continue
          if "`esttype'" == "mode" {
            display as res _col(17) `cformat' `matmode'[1, 1] _continue
          }
          else if "`esttype'" == "median" {
            display as res _col(17) `cformat' `matmedian'[1, 1] _continue
          }
          else {
            display as res _col(17) `cformat' `matest'[1, 1] _continue
          }
          display as res _col(28) `cformat' sqrt(`matse'[1, 1]) _continue
          if "`zratio'" == "" {
            if e(mcmcdiagnostics)==1 {
              display as res _col(36) %9.0f `matess'[1, 1] _continue
              display as res _col(49) `pformat' `matp_eq'[1, `r'] _continue
            }
          }
          else {
            display as res _col(36) `sformat' `matb_eq'[1, `r']/sqrt(`matV_eq'[`r',`r']) _continue
            display as res _col(49) `pformat' 2*normal(-abs(`matb_eq'[1, `r']/sqrt(`matV_eq'[`r',`r']))) _continue
          }
          if e(mcmcdiagnostics)==1 {
            display as res _col(58) `cformat' `matlb'[1, 1] _continue
            display as res _col(70) `cformat' `matub'[1, 1] _continue
          }
          display
          local ++r
        }
      }
    }
    display as txt "{hline 13}{c BT}{hline 64}"
    display ""
  }

  * RE Table
  // IGLS RP
  //         1         2         3         4         5         6         7
  //123456789012345678901234567890123456789012345678901234567890123456789012345678
  //------------------------------------------------------------------------------
  //   Random-effects Parameters |   Estimate   Std. Err.     [95% Conf. Interval]
  //-----------------------------+------------------------------------------------
  //Level 1:                     |
  //                   var(cons) |  #########  #########     #########   #########
  //------------------------------------------------------------------------------
  //
  // MCMC RP
  //         1         2         3         4         5         6         7
  //123456789012345678901234567890123456789012345678901234567890123456789012345678
  //------------------------------------------------------------------------------
  //   Random-effects Parameters |     Mean   Std. Dev.  ESS     [95% Cred. Int.]
  //-----------------------------+------------------------------------------------
  //Level 1:                     |
  //                   var(cons) | ######### ######### ######  ######### #########
  //------------------------------------------------------------------------------
  if "`retable'" == "" {
    * Display random part of the model
    // Need to allow the display at level 1 if we allow for extra binomial variation
    //if ~(`e(numlevels)'==1 & ~regexm("`e(distribution)'","normal")==1) {
    //if regexm("`e(distribution)'","normal")==1 | regexm("`e(distribution)'","nbinomial")==1 | `e(extrabinomial)' == 1 {

      local eqlist :coleq e(b)
      local eqlist :list uniq eqlist

      * Random part design
      * Change display order so parameter estimates are reported at their appropriate level
      local ordlist
      local i = 1
      local maxlevels = e(numlevels)
      forvalues l = `maxlevels'(-1)1 {
        if `:list posof "RP`l'" in eqlist' > 0 {
          local ordlist     `ordlist' RP`l'
          local ordlist`i'des  Level `l': `e(level`l')'
          if `l' == 1 {
            local ordlist`i'des `ordlist`i'des' `e(level1var)'
          }
          else {
            local levnames `e(ivars)'
            local namepos = `:list sizeof levnames' - `=`l' - 2'
            local ordlist`i'des `ordlist`i'des' `:word `namepos' of `e(ivars)''
          }
          local ++i
        }

        //if `:list posof "OD" in eqlist' > 0 {
        //  local ordlist `ordlist' OD
        //  local ordlist`i'des  Overdispersion Parameters
        //  local ++i
        //}

        if `:list posof "RP`l'D" in eqlist' > 0 {
          local ordlist `ordlist' RP`l'D
          local ordlist`i'des  Level `l': `e(level`l')' (Design)
          local ++i
        }

        if `:list posof "RP`l'FL" in eqlist' > 0 {
          local ordlist `ordlist' RP`l'FL
          local ordlist`i'des  Level `l' factors:
          local ++i
        }

        if `:list posof "RP`l'FV" in eqlist' > 0 {
          local ordlist `ordlist' RP`l'FV
          local ordlist`i'des  Level `l' factor covariances:
          local ++i
        }
      }

      local i = 1
      local iLAST = wordcount("`ordlist'")

      // Here we want to display the random part only if variables have been specified
      if `:list sizeof ordlist' > 0 {
        //if ~(`i'==`iLAST' & regexm("`e(distribution)'","normal")==0) {
        //if `:list sizeof ordlist' > 1 { // | regexm("`e(distribution)'","normal")==1 | regexm("`e(distribution)'","nbinomial")==1 | "`e(extrabinomial)'" == "1" {
          display as txt "{hline 29}{c TT}{hline 48}"
          if e(method)~="MCMC" {
            display as txt _col(4) "Random-effects Parameters" _continue
            display as txt _col(30) "{c |}" _continue
            display as txt _col(34) "Estimate" _continue
            display as txt _col(45) "Std. Err." _continue
            display as txt _col(`=61 -`kk'') `"[`=strsubdp("`level'")'% Conf. Interval]"'
          }
          if e(method)=="MCMC" {
            display as txt _col(4) "Random-effects Parameters" _continue
            display as txt _col(30) "{c |}" _continue
            if "`esttype'" == "mode" {
              display as txt _col(36) "Mode" _continue
            }
            else if "`esttype'" == "median" {
              display as txt _col(34) "Median" _continue
            }
            else {
              display as txt _col(36) "Mean" _continue
            }
            display as txt _col(43) "Std. Dev." _continue
            display as txt _col(55) "ESS" _continue
            display as txt _col(`=65 -`kk'') `"[`=strsubdp("`level'")'% Cred. Int]"'
          }

          foreach eq in `ordlist' {
            //if "`eq'"~="RP1" | wordcount("`e(distribution)'") ~= 1 | "`e(distribution)'"=="normal" | "`e(extrabinomial)'" == "1" {
            //if "`eq'"~="RP1" | regexm("`e(distribution)'","normal")==1 | regexm("`e(distribution)'","nbinomial")==1 | "`e(extrabinomial)'" == "1" {
              local r = 1
              display as txt "{hline 29}{c +}{hline 48}"
              display as res "`ordlist`i'des'" _continue
              display as txt _col(30) "{c |}"

              tempname matb matv matb_eq matV_eq
              matrix `matb' = e(b)
              matrix `matV' = e(V)
              matrix `matb_eq' = `matb'[1, "`eq':"]
              matrix `matV_eq' = `matV'["`eq':", "`eq':"]
              if e(method)=="MCMC" & e(mcmcdiagnostics)==1 {
                tempname matress matrlb matrub matrmode matrmedian matess_eq matlb_eq matub_eq matmode_eq matmedian_eq
                matrix `matress' = e(ess)
                matrix `matrlb' = e(lb)
                matrix `matrub' = e(ub)
                matrix `matrmode' = e(mode)
                matrix `matrmedian' = e(quantiles)
                matrix `matess_eq' = `matress'[1, "`eq':"]
                matrix `matlb_eq' = `matrlb'[1, "`eq':"]
                matrix `matub_eq' = `matrub'[1, "`eq':"]
                matrix `matmode_eq' = `matrmode'[1, "`eq':"]
                * NOTE: This assumes that the median is always the fifth row
                matrix `matmedian_eq' = `matrmedian'[5, "`eq':"]
              }

              tempname matest matse matess matlb matub matmode matmedian

              local names :colnames `matb_eq'
              foreach par of local names {

                // Don't display when constrained to one
                //if "`eq'" == "RP1" & "`e(distribution)'"~="normal" & "`par'" == "var(bcons_1)" & "`e(extrabinomial)'" == "0" {
                //  local ++r
                //  continue
                //}

                local partype
                if regexm("`par'", "(var)[\(]([a-zA-Z0-9_]+)[\)]") == 1 {
                  local partype `=regexs(1)'
                  local par1 `=regexs(2)'
                  local par2 `=regexs(2)'
                }

                if regexm("`par'", "(cov)[\(]([a-zA-Z0-9_~]+)[\\]([a-zA-Z0-9_~]+)[\)]") == 1 {
                  local partype `=regexs(1)'
                  local par1 `=regexs(2)'
                  local par2 `=regexs(3)'
                }

                * SD specified and parameter is a variance
                if "`sd'" ~= "" & "`partype'" == "var" {

                  * MCMC
                  if e(method)=="MCMC" & e(mcmcdiagnostics)==1 {
                    tempname sdchain
                    local colnames :colfullnames e(b)
                    mata: `sdchain' = sqrt(runmlwin_chains[ , `=`:list posof "`eq':`par'" in colnames' + 1'])
                    preserve
                    drop _all
                    label drop _all
                    if _caller() >= 11.1 {
                      getmata (`sdchain') = `sdchain'
                    }
                    else {
                      mata: (void) st_addvar("double", "`sdchain'")
                      mata: st_addobs(length(`sdchain'))
                      mata: st_store(., "`sdchain'", `sdchain')
                    }
                    mata: mata drop `sdchain'
                    quietly runmlwin_mcmcdiag `sdchain', level(`level') thinning(e(thinning)) posit(1) `eform'
                    mat `matest' = r(mean)
                    mat `matse' = r(sd)*r(sd)
                    mat `matess' = r(ESS)
                    mat `matlb' = r(lb)
                    mat `matub' = r(ub)
                    mat `matmode' = r(mode)
                    mat `matmedian' = r(quantiles)
                    * NOTE: This assumes that the median is always the fifth row
                    mat `matmedian' = `matmedian'[5, 2]
                    restore
                  }
                  * (R)IGLS
                  else {
                    capture quietly nlcom (sd: sqrt([`eq']`par'))
                    if !_rc {
                      mat `matlb' = sqrt(`matb_eq'[1, `r'] - `multiplier'*sqrt(`matV_eq'[`r',`r']))
                      mat `matub' = sqrt(`matb_eq'[1, `r'] + `multiplier'*sqrt(`matV_eq'[`r',`r']))
                      mat `matest' = r(b)
                      mat `matse' = r(V)
                      mat `matest' = `matest'[1,1]
                      mat `matse' = `matse'[1,1]
                    }
                    else {
                      mat `matest' = J(1, 1, .)
                      mat `matse' = J(1, 1, .)
                      mat `matlb' = J(1, 1, .)
                      mat `matub' = J(1, 1, .)
                    }
                  }
                  local par sd(`=abbrev("`par1'", 24)')
                }
                * CORR specified and parameter is a covariance
                else if "`correlations'" ~= "" & "`partype'" == "cov" {
                  // Search for corresponding variances
                  local possnames :colnames `matb_eq'
                  local posspar1
                  local posspar2
                  foreach poss of local possnames {
                    if regexm("`poss'", "(var)[\(]([a-zA-Z0-9_]+)[\)]") == 1 {
                      local poss `=regexs(2)'
                      if "`=abbrev("`poss'", 12)'" == "`par1'" local posspar1 `posspar1' "`poss'"
                      if "`=abbrev("`poss'", 12)'" == "`par2'" local posspar2 `posspar2' "`poss'"
                    }
                  }

                  if `:list sizeof posspar1' != 1 | `:list sizeof posspar2' != 1 {
                    display as error "Unable to identify unique variance parameters for `par'. Don't use the corr option."
                    exit 198
                  }
                  else {
                    local par1 `posspar1'
                    local par2 `posspar2'
                  }
                  * MCMC
                  if e(method)=="MCMC" & e(mcmcdiagnostics)==1 {
                    // Recalculate correlations from chain (There is an argument that the estimates and covariance should always be estimated from chains on display too, otherwise there is potential for wasted calculations)
                    tempname corrchain
                    local colnames :colfullnames e(b)
                    mata: `corrchain' = runmlwin_chains[ , `=`:list posof "`eq':`par'" in colnames' + 1'] :/ sqrt(runmlwin_chains[ , `=`:list posof "`eq':var(`=abbrev("`par1'", 24)')" in colnames' + 1'] :* runmlwin_chains[ , `=`:list posof "`eq':var(`=abbrev("`par2'", 24)')" in colnames' + 1'])
                    preserve
                    drop _all
                    label drop _all
                    if _caller() >= 11.1 {
                      getmata (`corrchain') = `corrchain'
                    }
                    else {
                      mata: (void) st_addvar("double", "`corrchain'")
                      mata: st_addobs(length(`corrchain'))
                      mata: st_store(., "`corrchain'", `corrchain')
                    }
                    mata: mata drop `corrchain'
                    quietly runmlwin_mcmcdiag `corrchain', level(`level') thinning(e(thinning)) posit(0) `eform'
                    mat `matest' = r(mean)
                    mat `matse' = r(sd)*r(sd)
                    mat `matess' = r(ESS)
                    mat `matlb' = r(lb)
                    mat `matub' = r(ub)
                    mat `matmode' = r(mode)
                    mat `matmedian' = r(quantiles)
                    * NOTE: This assumes that the median is always the fifth row
                    mat `matmedian' = `matmedian'[5, 2]
                    restore
                  }
                  * (R)IGLS
                  else {
                    capture quietly nlcom (corr: [`eq']`par' / sqrt([`eq']var(`=abbrev("`par1'", 24)') * [`eq']var(`=abbrev("`par2'", 24)')))
                    if !_rc {
                      mat `matest' = r(b)
                      mat `matse' = r(V)
                      mat `matest' = `matest'[1,1]
                      mat `matse' = `matse'[1,1]
                      mat `matlb' = `matest'[1, 1] - `multiplier'*sqrt(`matse'[1, 1]) // This is correct! This is what xtmixed does when reporting covariance parameters (as opposed to the default of correlation parameters)
                      mat `matub' = `matest'[1, 1] + `multiplier'*sqrt(`matse'[1, 1]) // So we can't simply transform the lb and up of the correlation parameter on the original estimation metric because the correlation is a non-linear combination of several other parameters.
                    }
                    else {
                      mat `matest' = J(1, 1, .)
                      mat `matse' = J(1, 1, .)
                      mat `matlb' = J(1, 1, .)
                      mat `matub' = J(1, 1, .)
                    }
                  }
                  local par corr(`=abbrev("`par1'", 12)',`=abbrev("`par2'", 12)')
                }
                * All other cases
                else {
                  if "`partype'" == "var" {
                    local par var(`=abbrev("`par1'", 24)')
                  }
                  if "`partype'" == "cov" {
                    local par cov(`=abbrev("`par1'", 12)',`=abbrev("`par2'", 12)')
                  }
                  mat `matest' = `matb_eq'[1, `r']
                  mat `matse' = `matV_eq'[`r',`r']
                  mat `matlb' = `matest'[1, 1] - `multiplier'*sqrt(`matse'[1, 1])
                  mat `matub' = `matest'[1, 1] + `multiplier'*sqrt(`matse'[1, 1])
                  if e(method)=="MCMC" & e(mcmcdiagnostics)==1 {
                    mat `matess' = `matess_eq'[1, `r']
                    mat `matmode' = `matmode_eq'[1, `r']
                    mat `matmedian' = `matmedian_eq'[1, `r']
                    if e(level) == `level' {
                      mat `matlb' = `matlb_eq'[1, `r']
                      mat `matub' = `matub_eq'[1, `r']
                    }
                    else {
                      tempname estchain
                      local colnames :colfullnames e(b)
                      mata: `estchain' = runmlwin_chains[ , `=`:list posof "`eq':`par'" in colnames' + 1']
                      preserve
                      drop _all
                      label drop _all
                      if _caller() >= 11.1 {
                        getmata (`estchain') = `estchain'
                      }
                      else {
                        mata: (void) st_addvar("double", "`estchain'")
                        mata: st_addobs(length(`estchain'))
                        mata: st_store(., "`estchain'", `estchain')
                      }
                      mata: mata drop `estchain'
                      local posit = 0
                      if "`partype'" == "var" {
                        local posit = 1
                      }
                      quietly runmlwin_mcmcdiag `estchain', level(`level') thinning(e(thinning)) posit(`posit') `eform'
                      mat `matlb' = r(lb)
                      mat `matub' = r(ub)
                      restore
                    }
                  }
                }

                local k = length("`par'")
                local p = 29 - `k'
                if e(method)~="MCMC" {
                  display as txt _col(`p') "`par'" _continue
                  display as txt _col(30) "{c |}" _continue
                  display as res _col(33) `cformat' `matest'[1, 1] _continue
                  display as res _col(44) `cformat' sqrt(`matse'[1,1]) _continue
                  display as res _col(58) `cformat' `matlb'[1, 1] _continue
                  display as res _col(70) `cformat' `matub'[1, 1]
                  local ++r
                }
                if e(method)=="MCMC" {
                  display as txt _col(`p') "`par'" _continue
                  display as txt _col(30) "{c |}" _continue
                  if "`esttype'" == "mode" {
                    display as res _col(32) `cformat' `matmode'[1, 1] _continue
                  }
                  else if "`esttype'" == "median" {
                    display as res _col(32) `cformat' `matmedian'[1, 1] _continue
                  }
                  else {
                    display as res _col(32) `cformat' `matest'[1, 1] _continue
                  }
                  display as res _col(42) `cformat' sqrt(`matse'[1, 1]) _continue
                  if e(mcmcdiagnostics)==1 {
                    display as res _col(52) %6.0f `matess'[1, 1] _continue
                    display as res _col(60) `cformat' `matlb'[1, 1] _continue
                    display as res _col(70) `cformat' `matub'[1, 1] _continue
                  }
                  display
                  local ++r
                }
              }
              local ++i
            //}
          }
          * Horizontal line
          display as txt "{hline 29}{c BT}{hline 48}

        }
      //}
    //}
  }

  local eqlist :coleq e(b)
  local eqlist :list uniq eqlist

  if `:list posof "OD" in eqlist' > 0 & ("`e(extrabinomial)'" == "1" | "`e(distribution)'" == "nbinomial") {
    tempname matodb_eq
    tempname matodV_eq
    matrix `matodb_eq' = `matb'[1, "OD:"]
    matrix `matodV_eq' = `matV'["OD:", "OD:"]

    if e(method)=="MCMC" & e(mcmcdiagnostics)==1 {
      tempname matress matrlb matrub matrmode matrmedian matodess_eq matodlb_eq matodub_eq matodmode_eq matodmedian_eq
      matrix `matress' = e(ess)
      matrix `matrlb' = e(lb)
      matrix `matrub' = e(ub)
      matrix `matrmode' = e(mode)
      matrix `matrmedian' = e(quantiles)
      matrix `matodess_eq' = `matress'[1, "OD:"]
      matrix `matodlb_eq' = `matrlb'[1, "OD:"]
      matrix `matodub_eq' = `matrub'[1, "OD:"]
      matrix `matodmode_eq' = `matrmode'[1, "OD:"]
      * NOTE: This assumes that the median is always the fifth row
      matrix `matodmedian_eq' = `matrmedian'[5, "OD:"]
    }

    local names :colnames `matodb_eq'
    display as txt "{hline 29}{c TT}{hline 48}"

    if e(method)~="MCMC" {
      display as txt _col(4) "Overdispersion Parameters" _continue
      display as txt _col(30) "{c |}" _continue
      display as txt _col(34) "Estimate" _continue
      display as txt _col(45) "Std. Err." _continue
      display as txt _col(`=61 -`kk'') `"[`=strsubdp("`level'")'% Conf. Interval]"'
    }
    if e(method)=="MCMC" {
      display as txt _col(4) "Overdispersion Parameters" _continue
      display as txt _col(30) "{c |}" _continue
      if "`esttype'" == "mode" {
        display as txt _col(36) "Mode" _continue
      }
      else if "`esttype'" == "median" {
        display as txt _col(34) "Median" _continue
      }
      else {
        display as txt _col(36) "Mean" _continue
      }
      display as txt _col(43) "Std. Dev." _continue
      display as txt _col(55) "ESS" _continue
      display as txt _col(`=65 -`kk'') `"[`=strsubdp("`level'")'% Cred. Int]"'
    }

    * Horizontal line
    display as txt "{hline 29}{c +}{hline 48}

    local r = 1
    foreach par of local names {
      if "`r'" == "1" && "`e(distribution)'" == "nbinomial" && "`e(extrabinomial)'" == "0"  {
        local ++r
        continue
      }

      mat `matest' = `matodb_eq'[1, `r']
      mat `matse' = `matodV_eq'[`r',`r']
      mat `matlb' = `matest'[1, 1] - `multiplier'*sqrt(`matse'[1, 1])
      mat `matub' = `matest'[1, 1] + `multiplier'*sqrt(`matse'[1, 1])

      if e(method)=="MCMC" & e(mcmcdiagnostics)==1 {
        mat `matess' = `matodess_eq'[1, `r']
        mat `matmode' = `matodmode_eq'[1, `r']
        mat `matmedian' = `matodmedian_eq'[1, `r']
        if e(level) == `level' {
          mat `matlb' = `matodlb_eq'[1, `r']
          mat `matub' = `matodub_eq'[1, `r']
        }
        else {
          tempname estchain
          local colnames :colfullnames e(b)
          mata: `estchain' = runmlwin_chains[ , `=`:list posof "`eq':`par'" in colnames' + 1']
          preserve
          drop _all
          label drop _all
          if _caller() >= 11.1 {
            getmata (`estchain') = `estchain'
          }
          else {
            mata: (void) st_addvar("double", "`estchain'")
            mata: st_addobs(length(`estchain'))
            mata: st_store(., "`estchain'", `estchain')
          }
          mata: mata drop `estchain'
          local posit = 0
          if "`partype'" == "var" {
            local posit = 1
          }
          quietly runmlwin_mcmcdiag `estchain', level(`level') thinning(e(thinning)) posit(`posit') `eform'
          mat `matlb' = r(lb)
          mat `matub' = r(ub)
          restore
        }
      }

      local k = length("`par'")
      local p = 29 - `k'

      if e(method)~="MCMC" {
        display as txt _col(`p') "`par'" _continue
        display as txt _col(30) "{c |}" _continue
        display as res _col(33) `cformat' `matest'[1, 1] _continue
        display as res _col(44) `cformat' sqrt(`matse'[1,1]) _continue
        display as res _col(58) `cformat' `matlb'[1, 1] _continue
        display as res _col(70) `cformat' `matub'[1, 1]
        local ++r
      }
      if e(method)=="MCMC" {
        display as txt _col(`p') "`par'" _continue
        display as txt _col(30) "{c |}" _continue
        if "`esttype'" == "mode" {
          display as res _col(32) `cformat' `matmode'[1, 1] _continue
        }
        else if "`esttype'" == "median" {
          display as res _col(32) `cformat' `matmedian'[1, 1] _continue
        }
        else {
          display as res _col(32) `cformat' `matest'[1, 1] _continue
        }
        display as res _col(42) `cformat' sqrt(`matse'[1, 1]) _continue
        if e(mcmcdiagnostics)==1 {
          display as res _col(52) %6.0f `matess'[1, 1] _continue
          display as res _col(60) `cformat' `matlb'[1, 1] _continue
          display as res _col(70) `cformat' `matub'[1, 1] _continue
        }
        display
        local ++r
      }
    }
    * Horizontal line
    display as txt "{hline 29}{c BT}{hline 48}
  }

  * Notes
  if e(method)=="IGLS" & e(converged)==0 display _n as error "WARNING: IGLS algorithm failed to converge. Increase the number of iterations. See the maxiterations() option."
  if e(method)=="RIGLS" & e(converged)==0 display _n as error "WARNING: RIGLS algorithm failed to converge. Increase the number of iterations. See the maxiterations() option."
end

mata:

  void copymatrix(string scalar srcmat, string scalar srcrowidxmat, string scalar srccolidxmat, string scalar destmat, string scalar destrowidxmat, string scalar destcolidxmat) {

    real colvector srcrowidx;
    real colvector srccolidx;
    real colvector destrowidx;
    real colvector destcolidx;
    real matrix temp;

    src = st_matrix(srcmat);
    srcrowidx = st_matrix(srcrowidxmat);
    srccolidx = st_matrix(srccolidxmat);
    destrowidx = st_matrix(destrowidxmat);
    destcolidx = st_matrix(destcolidxmat);

    temp = st_matrix(destmat);
    temp[destrowidx, destcolidx] = src[srcrowidx, srccolidx];
    _editmissing(temp, 0);
    st_replacematrix(destmat, temp);
  }

  void checkmm(string scalar mmids, string scalar mmweights) {
    real matrix idmat;
    real matrix weightmat;
    real scalar i;
    real scalar j;

    if (callersversion() >= 11) {
      st_view(idmat, ., mmids);
      st_view(weightmat, ., mmweights);
    }
    else {
      st_view(idmat, ., tokens(mmids));
      st_view(weightmat, ., tokens(mmweights));
    }

    for (i = 1; i <= rows(idmat); i++) {
      for (j = 1; j <= cols(idmat); j++) {
        if (idmat[i, j] != 0 && weightmat[i, j] == 0) {
          errprintf("Error, the MM ID variable %g for observation %g is present but a zero MM weight has been specified for it\n", j, i);
          exit(198);
        }
        if (idmat[i, j] == 0 && weightmat[i, j] != 0) {
          errprintf("Error, the MM ID variable %g for observation %g is absent but a positive MM weight has been specified for it\n", j, i);
          exit(198);
        }
        for (k = 1; k < j; k++) {
          if (idmat[i, j] == idmat[i, k] & idmat[i, j] != 0 ) {
            errprintf("Error, the MM ID variable %g for observation %g is duplicated in ID variable %g\n", j, i, k);
            exit(198)
          }
        }
      }
    }
  }

  string scalar validname(string scalar name) {
    real rowvector codes;
    real rowvector valid;

    codes = ascii(name);
    if (codes[1] >=48 && codes[1] <= 57) {
      codes = 95,codes;
    }
    valid = ((codes:<65 :| codes:>90) :& (codes:<97 :| codes:>122) :& (codes:<48 :| codes:>57))
    for (i = 1; i <= length(codes); i++) {
      if (valid[i] == 1) {
        codes[i] = 95;
      }
    }
    // The following code would truncate to 32 characters
    /*
    if (length(codes) > 32) {
      codes = codes[|1\32|];
    }
    */
    name = char(codes);
    return(name);
  }

  void setsortorder(string scalar filename, string scalar sortorder) {
    string rowvector order;
    colvector C;
    real scalar fh;
    real scalar ver;
    real scalar byteorder;
    real scalar filetype;
    real scalar reserved;
    real scalar nvar;
    real scalar nobs;
    real scalar varlablen;
    real scalar colnamelen;
    real scalar recsize;
    real scalar fmtlen;
    string scalar data_label;
    string scalar time_stamp;
    real matrix typlist;
    string matrix varlist;
    real matrix srtlist;

    order = tokens(sortorder);
    if (length(order) ~= length(uniqrows(order))) {
      printf("variables in sort order are not unique");
      exit(error(198));
    }

    C = bufio()
    fh = fopen(filename, "rw");

    ver = fbufget(C, fh, "%1bu");
    byteorder = fbufget(C, fh, "%1bu");
    filetype = fbufget(C, fh, "%1bu");
    reserved = fbufget(C, fh, "%1bu");
    bufbyteorder(C, byteorder);

    if (filetype != 1)
    {
      display("Invalid file");
      exit();
    }

    nvar = fbufget(C, fh, "%2bu");
    nobs = fbufget(C, fh, "%4bu");

    if (ver == 105) {
      varlablen = 32;
      colnamelen = 9;
      recsize = 16;
      fmtlen = 12;
    }
    else if (ver == 108) {
      varlablen = 81;
      colnamelen = 9;
      recsize = 16;
      fmtlen = 12;
    }
    else if (ver == 110 || ver == 111 || ver == 113) {
      varlablen = 81;
      colnamelen = 33;
      recsize = 32;
      fmtlen = 12;
    }
    else if (ver == 114 || ver == 115) {
      varlablen = 81;
      colnamelen = 33;
      recsize = 32;
      fmtlen = 49;
    }
    else {
      printf("unrecognised version: %f", ver);
      exit(error(198));
    }

    data_label = fbufget(C, fh, "%" + strofreal(varlablen) + "s");
    time_stamp = fbufget(C, fh, "%18s");

    typlist = J(1, nvar, .);
    for (i = 1; i <= nvar; i++) {
      typlist[1, i] = fbufget(C, fh, "%1bu");
    }
    varlist = J(1, nvar, "");
    for (i = 1; i <= nvar; i++) {
      varlist[1, i] = fbufget(C, fh, "%" + strofreal(colnamelen) + "s");
    }
    srtlist = J(1, nvar + 1, 0);
    for (i = 1; i <= length(order); i++) {
      found = 0;
      for (j = 1; j <= nvar; j++) {
        if (order[i] == varlist[1, j]) {
          found = 1;
          srtlist[1, i] = j
          break;
        }
      }
      if (found == 0) {
        printf("variable %s not found", order[i]);
        exit(error(198));
      }
    }
    for (i = 1; i <= nvar + 1; i++) {
      fbufput(C, fh, "%2bu", srtlist[1, i]);
    }

    fclose(fh);
  }

end

******************************************************************************
exit

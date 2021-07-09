*! version 1.0.0 14Feb2017 Malte Kaukal
*************************************************************************************************************
* Title: explorelabs.ado                                                *
* Description: Ado to explore the use of value labels in the dataset         *
* Author: Malte Kaukal, GESIS - Leibniz Institute for the Social Sciences                  *
* Version: 1.0.1
* Version history
*                 v1-0-1 (20170214): built in of notification of too long variable names
                                             *
*************************************************************************************************************

program explorelabs
  version 9.2
  syntax varlist, [LASTvalues(real 0)] [NEGative] [List] [FREquency] [LABeltext(string asis)]

  capture which labellist
  if _rc == 111 {
    display as error "Ado {it:labellist} not found which is necessary to execute {it:explorelabs}."
    display as error "Type {input: ssc install labellist} to get the ado"
    exit
  }

  if `lastvalues' != 0 & "`negative'" != "" {
    display as error "Option {it:lastvalues()} and {it:negative} cannot be called together"
    exit
  }

  *Setting tempnames
  tempname c check crash exp_begin exp_end explore_lc help id id_help in in1 ///
           input k l l1 lab_container label_length lab_values lab lab_help ///
           lc loop_type real_values t t_all t_sort val value var_count varlab y

  *Set Explore modus
  if "`negative'" == "" {
    local `lc' = `lastvalues'
  }

  *Gather value information
  local `var_count' = 0
  foreach var of varlist `varlist' {
    local `check' = 0
    capture confirm numeric variable `var'
    if _rc != 0 {
      continue
    }
    if strlen("`var'") > 29 {
      local length_var = "`length_var' `var'"
      continue
    }

    local `var_count' = ``var_count'' + 1

    qui labellist `var'              // Ado by Daniel Klein
    local `lab_values' = `"`r(values)'"'

    if "``lc''" != "" {
      if "``lab_values''" != "" {
        local `exp_end' = `:word count ``lab_values'''  // Explore option
        if ``lc'' != 0 & (``exp_end'' > ``lc'') {
          local `exp_begin' = ``exp_end'' - ``lc'' + 1
        }
        else {
          local `exp_begin' = 1
        }
        forvalue x = ``exp_begin''/``exp_end'' {
          if `"`labeltext'"' != "" & strmatch(`"`:label (`var') `:word `x' of ``lab_values''''"', `"`labeltext'"') == 1 {
            local `explore_lc' =  `"``explore_lc''"' + `"*`:word `x' of ``lab_values''' "`:label (`var') `:word `x' of ``lab_values''''":"'
            local `check' = 1
          }
          else {
            local `explore_lc' = `"``explore_lc''"' + `"+`:word `x' of ``lab_values''' "`:label (`var') `:word `x' of ``lab_values''''":"'
          }
        }
        if ``check'' == 1 {
          local `explore_lc' = `"``explore_lc''"' + "%*`var'%;"
        }
        else {
          local `explore_lc' = `"``explore_lc''"' + "%+`var'%;"
        }
      }
    }
    else {
      if `"``lab_values''"' != "" {
        local `exp_end' = `: word count ``lab_values'''  // Explore option negative values
        forvalue x = 1/``exp_end'' {
          if `:word `x' of ``lab_values''' >= 0 {
            continue, break
          }
          if `"`labeltext'"' != "" & strmatch(`"`:label (`var') `:word `x' of ``lab_values''''"',`"`labeltext'"') == 1 {
            local `explore_lc' = `"``explore_lc''"' + `"*`:word `x' of ``lab_values''' "`:label (`var') `:word `x' of ``lab_values''''":"'
            local `check' = 1
          }
          else {
            local `explore_lc' = `"``explore_lc''"' + `"+`:word `x' of ``lab_values''' "`:label (`var') `:word `x' of ``lab_values''''":"'
          }
        }
        if ``check'' == 1 {
          local `explore_lc' = `"``explore_lc''"' + "%*`var'%;"
        }
        else {
          local `explore_lc' = `"``explore_lc''"' + "%+`var'%;"
        }
      }
    }
    capture qui tab1 `var', matcell(matval) matrow(act_values)
    if _rc == 134 {
      local `crash' = `"``crash'' `var'"'
    }
    else {
      local `varlab' = `r(r)'
      local `real_values' = ""
      if ``varlab'' == 1 {
        local `y' = el(act_values,1,1)
        if int(``y'') == ``y'' {
          local `real_values' = `"``real_values'' ``y''"'
        }
      }
      else {
        forvalue z = 1/``varlab'' {
          local `y' = el(act_values,`z',1)
          if int(``y'') == ``y'' {
            local `real_values' = `"``real_values'' ``y''"'
          }
        }
      }
      local rv_`var' = `"``real_values''"'
    }
  }

  *Exit for non-results
  if `"``explore_lc''"' == "" {
    display as result "No labels of specificed range in varlist"
    exit
  }

  *Output List
  if "`list'" != "" | ("`list'" == "" & "`frequency'" == "")   {
    if "``lc''" != "" {
      if ``lc'' == 0 {
        local `input' = "all"
      }
      else {
        local `input' = "the last ``lc''"
      }
    }
    else {
      local `input' = "the negative"
    }
    if `"`labeltext'"' != "" {
      display `"{text}{ul:Value labels of ``input'' values containing {result:"`labeltext'"} in label}"'
    }
    else {
      display "{text}{ul:Value labels of ``input'' values of variable}"
    }
    local `c' = 0
    tokenize `"``explore_lc''"', parse(";")
    while 1 == 1 {
      if `"`1'"' == ";" {
        macro shift
        continue
      }
      if `"`1'"' == "" {
        continue, break
      }
      local `c' = ``c'' + 1
      tempname expl``c''
      local `expl``c''' `1'
      macro shift
    }

    forvalue x = 1/``c'' {
      tokenize `"``expl`x'''"', parse("%")
      if `"`3'"' == `"%"' {
        continue
      }
      if `"`labeltext'"' != "" & regexm(`"`3'"',"^\*") != 1 {
        continue
      }
      display as text substr(`"`3'"',2,.)
      local var = substr(`"`3'"',2,.)
      tokenize `"``expl`x'''"', parse(":")
      while 1 == 1 {
        if `"`1'"' == ":" {
          macro shift
          continue
        }
        else if regexm(`"`1'"',"^%") == 1 {
          continue, break
        }
        else if `"`1'"' != ":" {
          if  `"`labeltext'"' != "" & regexm(`"`1'"',"^\*") != 1 {
            macro shift
            continue
          }
          if regexm(`"`1'"',`"^[*+]([-0-9a-z.]+)"') == 1 {
            local `val'=regexs(1)
          }
          local `in1'=substr(`"`1'"',2,.)
          if `"`: list `val' in rv_`var''"'==`"1"' {
            local `in' = substr(`"`1'"',2,.)
            local `in1' = `"{ul:``in''}"'
          }
          display as result `"{col 3}``in1''"'
          macro shift
        }
      }
      display ""
    }
  }

  *Output Frequency
  if "`frequency'" != "" | ("`list'" == "" & "`frequency'" == "") {
    local `help' = `"``explore_lc''"'
    local `t' = 0
    local `k' = 0
    local `label_length' = 20
    local `lab_container' = ""
    while 1 == 1 {
      if regexm(`"``help''"',`"([-0-9a-z.]+) ("[^"]+")(.*)"') == 1 {
        local `value' = regexs(1)
        local `lab' = regexs(2)
        local `help' = regexs(3)
        if strmatch(`"``lab_container''"',`"*``lab''*"') != 1 {
          local `lab_container' = `"``lab_container''"' + `"``lab''"'
          local `k' = ``k'' + 1
          tempname label_``k'' value_``k''
          local `label_``k''' = `"``lab''"'
          local `value_``k''' = `"``value''"'
          if strlen(`"``lab''"') > ``label_length'' {
            local `label_length' = strlen(`"``lab''"')
          }
          tempname t``k''
          local `t``k''' = 1
          local `t_all' = `"``t_all'' t``k''"'
        }
        else {
          forvalue z = 1/``k'' {
            if strmatch(`"``label_`z'''"',`"``lab''"') == 1 {
              local `t`z'' = ``t`z''' + 1
              local `value_`z'' = `"``value_`z''' "' + `"``value''"'
            }
          }
        }
        if regexm(`"``help''"',`"".+":"') != 1 {
          continue, break
        }
      }
    }

    local `l' = ``label_length'' + 5
    local `l1' = ``label_length'' + 15
    if `"``lc''"' != "" {
      if ``lc'' > 0 {
        local `input' = "the last ``lc''"
      }
      else {
        local `input' = "all"
      }
    }
    else {
      local `input' = "negative"
    }
    display ""
    display as text "{bind:*** FREQUENCY OF LABELS ***}" _newline
    display as text "There are `:word count ``t_all''' different labels concerning ``input'' value(s) of ``var_count'' numeric variable(s) named in varlist" _newline
    if `"`labeltext'"' != "" {
      display `"Only labels containing "{result:`labeltext'}" are shown:"' _newline
    }
    display as text " Label/Values" _continue
    display as text "{col ``l''}Frequency"
    display as text " {hline ``l1''}"
    foreach loc1 of local `t_all' {
      local `id' = substr("`loc1'",2,.)
      local `lab_help' = subinstr(`"``label_``id''''"',`"""',"",.)
      local `t_sort' = `"``t_sort''"' + `""``lab_help'' `loc1'""'
    }
    local `t_sort': list sort `t_sort'
    foreach loc of local `t_sort' {
      local `id_help' = subinstr(`"`loc'"',`"""',"",.)
      local `id_help' = regexr(`"``id_help''"',`"^.*[t]"',"t")
      local `id' = substr("``id_help''",2,.)
      local `value_``id''': list uniq `value_``id'''
      local `value_``id''': list sort `value_``id'''
      if `"`labeltext'"' != "" & strmatch(`"``label_``id''''"',`""`labeltext'""') != 1 {
        continue
      }
      display as result `" ``label_``id''''"' _continue
      display as result `"{col ``l''} ````id_help''''"'
      display as input `"{p 1 8 20 30}{result:Values:} ``value_``id''''{p_end}"' _newline
    }
  }

  if "`length_var'"!="" {
    display as error "{bind:Following variable names are too long to process (max. 28 characters) and have been skipped:}"
    display as error "{hline 92}"
    display as result "`length_var'"
  }

end

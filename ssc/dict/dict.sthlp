{smcl}
{* *! version 1.2.0  15nov2020}{...}

{title:Dict}

{pstd}
{hi:dict} {hline 2} loop over multiple arguments.


{marker description}{...}
{title:Description}

{pstd}
{it:dict} offers the tools to define and loop over dictionaries. A dictionary puts together several lists. It indexes their items according to their position on their respective list.
The {it:dict} prefix iterates over this index, allowing items of multiple lists to be passed to a loop command at the same time.

{pstd}
Note that the dict prefix can loop over any frame, not just those created by the function {bf:dict define}.


{marker functions}{...}
{title:Dict functions}

{pstd}
Define a new dictionary:

{pstd}
{bf:dict define} {help frame:newframe}, {bf:[{ul:f}rom(}{it:{help filename:file}}{bf:)]} {bf:[{ul:c}ols(}{it:{help newvarlist}}{bf:)]} {bf:[replace]}


{pstd}
Display an existing dictionary:

{pstd}
{bf:dict list} {help frame} [{it:{help if}}] [{it:{help in}}], {bf:[{ul:c}ols(}{it:{help varlist}}{bf:)]}


{pstd}
Return the number of observations in an existing dictionary:

{pstd}
{bf:dict count} {help frame}


{pstd}
Return the index of the observations that match a specified criteria in the dictionary frame:

{pstd}
{bf:dict getindex} {help frame} [{it:{help if}}] [{it:{help in}}], {bf:[{ul:m}atch(}{it:type}{bf:)]}


{pstd}
Return the variable values in the observation that matches a specified criteria in the dictionary frame:

{pstd}
{bf:dict getvalues} {help frame} [{it:{help if}}] [{it:{help in}}], {bf:[{ul:m}atch(}{it:type}{bf:)]}


{marker prefix}{...}
{title:Dict prefix}

{pstd}
Loop over a dictionary:

{pstd}
{bf: dict} {help frame}{cmd:,} {bf:[code]} {bf:[arg(}{it:char}{bf:)]}: {it:commands referring to %arguments}


{pstd}
Refer to a specific index in a dictionary:

{pstd}
{bf: dict} {help frame}{cmd:,} {bf:{ul:i}ndex(}{it:index}{bf:)} {bf:[code]} {bf:[arg(}{it:char}{bf:)]}: {it:commands referring to %arguments}


{marker options}{...}
{title:Options}

{bf:dict define}

{pstd}
{bf:{ul:f}rom(}{it:{help filename:file}}{bf:)}: imports a dictionary from an external file. It accepts both .csv and .dta files.

{pstd}
{bf:{ul:c}ols(}{it:{help newvarlist}}{bf:)}: Input the dictionary directly from the console. The names in {help newvarlist} define the columns to be created in the dictionary frame.{break}

{pstd}
- If individual elements should include spaces, enclose them with quotation marks.{break}
- Type {it:end} to finish imputing the dictionary.

{pstd}
{bf:replace}: specifies that it is okay to replace the data in memory, even though the current data have not been saved to disk.


{bf: dict list}

{pstd}
{bf:{ul:c}ols(}{it:{help varlist}}{bf:)}: specifies the columns of the dictionary frame that should be displayed.


{bf: dict getindex}

{pstd}
{bf:{ul:m}atch(}{it:type}{bf:)}: four matching types. The function defaults to {it:unique} if this option is not specified.

{pstd}
- {it:unique}: retrieves the index number of the observation that matches with the specified criteria. It returns an error if there are more than one matching observations.{break}
- {it:first}: retrieves the index number of the first observation that matches with the specified criteria.{break}
- {it:last}: retrieves the index number of the last observation that matches with the specified criteria.{break}
- {it:all}: retrieves the index numbers of all the observations that match with the specified criteria.


{bf: dict getvalues}

{pstd}
{bf:{ul:m}atch(}{it:type}{bf:)}: four matching types. The function defaults to {it:unique} if this option is not specified.

{pstd}
- {it:unique}: retrieves the index number of the observation that matches with the specified criteria. It returns an error if there are more than one matching observations. This is the default behaviour, if {bf:match()} is not specified{break}
- {it:first}: retrieves the index number of the first observation that matches with the specified criteria.{break}
- {it:last}: retrieves the index number of the last observation that matches with the specified criteria.


{bf:dict prefix}

{pstd}
{bf:{ul:i}ndex(}{it:index}{bf:)}: tells the dict prefix not to loop over the entire dictionary but rather to refer only the {it:nth} observation of specified dictionary.

{pstd}
{bf:code}: displays the line code used in each iteration of the loop. {it:Rarely used}.

{pstd}
{bf:arg(}{it:char}{bf:)}: changes the character used to call an argument in the command. The default character is {bf:%}. {it:Rarely used}.


{title:Example}

{pstd}
Consider the database:

      id    geo     time    value
    {hline 32}
       1     AT     2017     0.72
       2     AT     2018     0.73
       3     AT     2019     0.74
       4     BE     2017     0.63
       5     BE     2018     0.65
       6     BE     2019     0.65
       7     DE     2017     0.75
       8     DE     2018     0.76
       9     DE     2019     0.77
       .      .        .        .
      45     UK     2019     0.75
    {hline 32}

{pstd}
And the .csv file:

     acronym                  name
    {hline 32}
          AT               Austria
          BE               Belgium
          DE               Germany
           .                     .
          UK        United Kingdom
    {hline 32}


   {cmd: dict define map, from(countries.csv)}
   {cmd: gen country = "", after(geo)}
   {cmd: dict map: replace country = "%name" if (geo == "%acronym")}

      id    geo          country     time    value
    {hline 49}
       1     AT          Austria     2017     0.72
       2     AT          Austria     2018     0.73
       3     AT          Austria     2019     0.74
       4     BE          Belgium     2017     0.63
       5     BE          Belgium     2018     0.65
       6     BE          Belgium     2019     0.65
       7     DE          Germany     2017     0.75
       8     DE          Germany     2018     0.76
       9     DE          Germany     2019     0.77
       .      .                .        .        .
      45     UK   United Kingdom     2019     0.75
    {hline 49}


   {cmd: dict define mylabels, cols(varname label)}
     {cmd: id       "ID"}
     {cmd: geo      "Country code"}
     {cmd: country  "Country name"}
     {cmd: time     "Year"}
     {cmd: value    "Employment rates"}
   {cmd: end}

   {cmd: dict mylabels: label variable %varname "%label"}
   {cmd: describe}

   {c TLC}{hline 10}{c TT}{hline 17}{c TRC}
   {c |} Variable {c |} Label           {c |}
   {c LT}{hline 10}{c +}{hline 17}{c RT}
   {c |} id       {c |} ID              {c |}
   {c |} geo      {c |} Country code    {c |}
   {c |} country  {c |} Country name    {c |}
   {c |} time     {c |} Year            {c |}
   {c |} value    {c |} Employment rate {c |}
   {c BLC}{hline 10}{c BT}{hline 17}{c BRC}


{title:Author}

{pstd}
{it:Daniel Alves Fernandes}{break}
European University Institute

{pstd}
daniel.fernandes@eui.eu

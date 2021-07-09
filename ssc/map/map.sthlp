{smcl}
{* *! version 2.0.0  05jun2020}{...}

{title:Map}

{pstd}

{p 5 5 5}
  {hi:map} {hline 2} maps variables with an external dictionary file.

{marker syntax}{...}
{title:Syntax}

{p 5 5 5}
  {cmd:map} {help varlist:{it:varlist}} {bf:using} {help filename:filename} {ifin}{cmd:,}
  {bf:{ul:v}alues(}name{bf:)} [{bf:{ul:gen}erate({help varname:{it:varname}})}]

{title:Description}

{p 5 5 5}
This command maps all the unique levels of a variable or a list of variables (the keys) to their associated values (the values).
The command matches the keys between the dataset in memory and an external file.
The external file acts as a dictionary or hash map, pairing each keys with a string or numeric value.

{p 5 5 5}
The command accepts {bf:.csv} or a {bf:.dta} files for mapping.
All keys must be unique in the external file but multiple keys can be paired with the same values.

{title:Options}

{p 5 5 5}
{bf:{ul:v}alues}: defines the variable in the external file containing the values to be returned.

{p 5 5 5}
{bf:{ul:gen}erate}: defines the name of the variable to be created. If this option is not specified, the command returns the variable name used in the external file.

{title:Author}

{p 5 5 5}
{it:Daniel Alves Fernandes}{break}
European University Institute

{p 5 5 5}
daniel.fernandes@eui.eu


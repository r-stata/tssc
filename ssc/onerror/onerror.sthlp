{smcl}
{* *! version 1.0.0  09jul2020}{...}

{title:onerror}

{pstd}
{hi:onerror} {hline 2} is a useful tool for streamlining error checking in Stata programs.
  It allows the user to check for errors in an argument (with {help confirm:confirm})
  or expression (with {help assert:assert}, {help display:display}, or {help if:exp}),
  display an error message and exit the program, all in one line.



{marker syntax}{...}
{title:Syntax}

{pstd}
  {cmd:onerror} [{cmd:confirm}|{cmd:assert}|{cmd:display}|{cmd:exp}] {it:argument or expression},
  [{bf:{ul:d}isplay}(string) {bf:{ul:e}rror}(integer)]

{title:Options}

{pstd}
{bf:{ul:d}isplay}: defines the message to be displayed in case the command returns an error.
If this option is not specified, onerror displays "program interrupted".

{pstd}
{bf:{ul:e}rror}: this option is only available for {help confirm} and {help assert} commands.
It specifies which errors should cause the program to break.
If not specified, the program breaks with any error.



{title:Example with confirm}

{pstd}
Without onerror:

    {cmd:. confirm integer number 3.14}
    {cmd:. if (_rc == 7){c -(}}
    {cmd:.   display as error "the number is not an integer"}
    {cmd:.   exit}
    {cmd:. {c )-}}

{pstd}
With onerror:

    {cmd:. onError confirm integer number 3.14, display(the number is not an integer) error(7)}


{title:Example with assert}

{pstd}
Without onerror:

    {cmd:. assert inlist(var1,0,1,.)}
    {cmd:. if (_rc != 0){c -(}}
    {cmd:.   display as error "var1 is not a binary variable"}
    {cmd:.   exit}
    {cmd:. {c )-}}

{pstd}
With onerror:

    {cmd:. onerror assert inlist(var1,0,1,.), display(var1 is not a binary variable)}

{title:Example with display}

{pstd}
Without onerror:

    {cmd:. display "string" * "string"}
    {cmd:. if (_rc != 0){c -(}}
    {cmd:.   display as error "program interrupted"}
    {cmd:.   exit}
    {cmd:. {c )-}}

{pstd}
With onerror:

    {cmd:. onerror display "string" * "string"}

{title:Example with exp}

{pstd}
Without onerror:

    {cmd:. if ("`quietly'" == "quietly" & "`table'" == "table"){c -(}}
    {cmd:.   display as error "-quietly- cannot be used alongside -table-"}
    {cmd:.   exit}
    {cmd:. {c )-}}

{pstd}
With onerror:

    {cmd:. onerror exp ("`quietly'" == "quietly" & "`table'" == "table"), d(-quietly- cannot be used alongside -table-)}


{title:Author}

{pstd}
{it:Daniel Alves Fernandes}{break}
European University Institute

{pstd}
daniel.fernandes@eui.eu

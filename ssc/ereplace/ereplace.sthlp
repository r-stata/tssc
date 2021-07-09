{smcl}
{* *! version 1.0.1 XXoct2017}{...}
{cmd:help ereplace}
{p}Version: 1.0.2 (XX October, 2017){p_end}
{hline}


{title:Title}

{phang}
{bf:ereplace -- A program that extends egen and egenmore (SSC) to permit replacing}

{title:Syntax}

{p 8 17 2}{cmd:ereplace}
[{it:type}]
{it:varname}
{cmd:=}
{it:fcn}{cmd:(}{it:arguments}{cmd:)}
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}]
[{cmd:,} {it:options}]

{synoptline}

{title:Description}

{p 4 4 2}
{cmd: ereplace} extends the popular {help egen} and {help egenmore} (if installed) modules
to permit replacing. {cmd: ereplace} replaces {it:varname} of the optionally specified storage type [type]
equal to {it:fcn}{cmd:(}{it:arguments}{cmd:)}.  Depending on
{it:fcn}{cmd:()}, {it:arguments} refers to an expression, a
{help varlist}, a {help numlist}, or an empty string. The options are
similarly function dependent.

{synoptline}

{title:Example}

    {stata sysuse e_example}

    {stata ereplace percent = cut(percent), at(0(20)100)} //using cut() function from {cmd:egen}
    {stata ereplace strvar = sieve(strvar), char(.0123456789)} //using sieve() function from {cmd:egenmore}

{title:Maintainer}

{p 4 4 2}Chris Larkin, The Behavioural Insights Team{break}
         chris.larkin@bi.team

{title:Acknowledgements}

    Nicholas J. Cox (n.j.cox@durham.ac.uk) is the first author of {cmd:ereplace}.

{smcl}
{* version 1.0.1 05aug2010}
{cmd:help dep4asm, indep4asm}
{hline}

{title:Title}

{p 5 21}
{cmd:[in]dep4asm} {hline 2} Create [in]dependent variable for alternative-specific 
models 

{title:Syntax}

{p 5 5}
Create dependent variable for alternative-specific models

{p 8}
{cmd:dep4asm} {varname} [{cmd:,} {it:dep_options}]


{p 5 5}
Create independent variable for alternative-specific model

{p 8 16}
{cmd:indep4asm} {varlist} {cmd:,} {opt alt:ernatives(varname)} 
{opt gen:erate(newvarlist)}


{synoptset 21 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :{it:dep_options}}
{synopt:{opt dep:endent(varlbl)}}use {it:varlbl} as label for dependent 
variable{p_end}
{synopt:{opt case(varlbl)}}create id for each observation and use {it:varlbl} as 
variable label{p_end}
{synopt:{opt alt:ernatives(varlbl)}}create variable containing alternatives and use
{it:varlbl} as variable label{p_end}
{synoptline}
{syntab :{it:indep_options}}
{synopt:{opt alt:ernatives(vname)}} use {it:vname} to identify alternatives{p_end}
{synopt:{opt gen:erate(newvarlist)}} create {it:newvariables} as independent 
variable/s in an alternative-specific model{p_end}
{synoptline}

{title:Description}

{pstd}
{cmd:dep4asm} creates a new variable that can be used as the dependent variable in an
alternative-specific model. The variable containing the alternatives is identified by 
{varname}. Each observation will be duplicated as many times as there are 
alternatives, that may be chosen. The created new variable (labeled {it:choice} by 
default) indicates which alternative has actually been chosen.

{pstd}
{cmd:indep4asm} creates variables that can be used as independent (alternative-
specific) variables in alternative-specific models. The {opt alternatives(varname)} 
option must be specified, indicating the variable that contains the alternatives. The 
user also has to specify the {opt generate(newvarlist)} option which creates new 
variables containing combined information of the variables specified in {varlist}. The 
variables given in {it:varlist} must be in the same order as the alternatives. 

{pstd}
{bf:Note:} In order to work properly {cmd:[in]dep4asm} requires the alternatives given 
in {varname} to be integers. The values must start at 1 and must be incremented by 
one. 

{title:Options}

{dlgtab:dep_options}

{phang}
{opt dependent(varlbl)} uses {it:varlbl} as label for the created (dependent) 
variable. The default label is {it:choice} and is used if {opt dependent()} is not 
specified.

{phang}
{opt case(varlbl)} creates variable {it:varlbl} that contains _n for each observation 
in the original data. Each case can then be identified referring to {it:varlbl}. 
Probably there is already a variable in your data set (e.g. id, respnr) that uniquely 
identifies each case. If there is none, you should however specify the {opt case()} 
option since programs that fit alternative-specific models require a variable to 
identify each case.

{phang}
{opt alternatives(varlbl)} leaves the variable specified in {varname} unchanged. Since 
each observation (row) needs to represent a different alternative using commands like 
{help asclogit}, the variable indicating the alternatives (and specified in 
{it:varname}) will be changed. It will contain each alternative for each case. If you 
want the original variable to remain unchanged, specify {opt alternatives()} and the 
new variable {it:varlbl} will contain each alternative for each case.

{dlgtab:indep_options}

{phang}
{opt alternatives(varname)} uses {varname} to identify alternatives

{phang}
{opt generate(newvarlist)} creates {it:newvariables} containing combined information 
of variables specified in {it:varlist}. The variables in {it:varlist} must be give in 
the same order as the alternatives (see example).

{title:Example}

{pstd}
Suppose you want to model the choice between using a car (1), a bus (2) or the tram (3)
to travel to work. One important variable to explain this choice might be the time 
needed using each alternative, another might be costs per month. Before you can 
estimate an alternative-specific model you have to change the structure of your data, 
which looks something like this:

	. list

	   +-------------------------------------------------------+
	   | id   mode   tcar   tbus   ttram   ccar   cbus   ctram |
	   |-------------------------------------------------------|
	1. |  1    car     13     18      15     25     30      24 |
	2. |  2    bus     24     22      27     32   27.5    25.5 |
	3. |  3   tram     35     33      31   38.5   24.5    25.5 |	
	4. |  4    bus     44     42      43   42.5     46      44 |
	   +-------------------------------------------------------+

{pstd}
Using {cmd:dep4asm} changes the data structure and creates the dependent variable.

     {cmd:. dep4asm mode}

     . list ,sep(3)

          +----------------------------------------------------------------+
          | id   mode   tcar   tbus   ttram   ccar   cbus   ctram   choice |
          |----------------------------------------------------------------|
       1. |  1    car     13     18      15     25     30      24        1 |
       2. |  1    bus     13     18      15     25     30      24        0 |
       3. |  1   tram     13     18      15     25     30      24        0 |
          |----------------------------------------------------------------|
       4. |  2    car     24     22      27     32   27.5    25.5        0 |
       5. |  2    bus     24     22      27     32   27.5    25.5        1 |
       6. |  2   tram     24     22      27     32   27.5    25.5        0 |
          |----------------------------------------------------------------|
       7. |  3    car     35     33      31   38.5   24.5    25.5        0 |
       8. |  3    bus     35     33      31   38.5   24.5    25.5        0 |
       9. |  3   tram     35     33      31   38.5   24.5    25.5        1 |
          |----------------------------------------------------------------|
      10. |  4    car     44     42      43   42.5     46      44        0 |
      11. |  4    bus     44     42      43   42.5     46      44        1 |
      12. |  4   tram     44     42      43   42.5     46      44        0 | 
          +----------------------------------------------------------------+

{pstd}
Now that your data has the required structure and the dependent variable {it:choice}
is created, you can go on creating the independent variables "travelling time" and 
"costs". In order to do so type:

	{cmd:. indep4asm tcar tbus ttram ccar cbus ctram ///}
	{cmd:,alternatives(mode) generate(trtime trcosts)}

	. list id choice trtime trcost ,sep(3)

	     +--------------------------------+
	     | id   choice   trtime   trcosts |
	     |--------------------------------|
	  1. |  1        1       13        25 |
	  2. |  1        0       18        30 |
	  3. |  1        0       15        24 |
	     |--------------------------------|
	  4. |  2        0       24        32 |
	  5. |  2        1       22      27.5 |
	  6. |  2        0       27      25.5 |
	     |--------------------------------|
	  7. |  3        0       35      38.5 |
	  8. |  3        0       33      24.5 |
	  9. |  3        1       31      25.5 |
	     |--------------------------------|
	 10. |  4        0       44      42.5 |
	 11. |  4        1       42        46 |
	 12. |  4        0       43        44 |
	     +--------------------------------+

{title:Author}

{pstd}D. Klein, University of Bamberg, daniel1.klein@gmx.de

{title:Also see}

{psee}
Online: {helpb asclogit}, {helpb asmprobit}, {help expand}
{p_end}
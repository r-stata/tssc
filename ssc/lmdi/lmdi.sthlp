{smcl}
{* *! version 3.2.3  31 Dec 2017}{...}
{cmd:help lmdi}
{hline}

{title:Title}

{phang}
{bf:lmdi} {hline 2} Logarithmic Mean Divisia Index (LMDI) Decomposition

{title:Syntax}

{p 8 21 2}
{cmd:lmdi} {it:{help varname:decomposed_var}} {cmd:=} {it:{help varlist:component_vars}} {cmd:,} {it:t({help varname:varname}) over({help varlist:varlist})} [ {it:options}]

{p 8 21 2}
{cmd:lmdi} {it:{help varname:decomposed_var}} {cmd:=} ({it:{help varlist:component[k]_vars}}) {it:{help varlist:component[j]_vars}} {cmd:,} {it:t({help varname:varname}) over({help varlist:varlist})} [ {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}

{synopt:{opt t:(varname)}} specifies the time variable. 
{p_end}
{synopt:{opt over:(varlist)}} specifies variables for the decomposition structure, indicating summing over the specific variables. 
{p_end}
{synopt:{opt add:}} indicates additive LMDI; the default is multiplicative form.
{p_end}
{synopt:{opt zero:(real)}} handles the zero value problem, indicating replacing zero values (and missing values) with a very small real number; default is 1e-20.
{p_end}
{synopt:{opt tol:erance(real)}} specifies the tolerance; default is 0.01. The value is first used to check whether the specified variables can form an identity. Then it is used to check the difference between the real change and the total of the
 decomposed effects.
{p_end}
{synopt:{opt sav:ing(filename)}} specifies that the results be saved in {it:filename}.dta.
{p_end}
{synopt:{opt replace:}} specifies saving the results with {it: replace} option.
{p_end}


{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}
{cmd:lmdi} attributes the total change of the decomposed variable into several predefined components using logarithmic mean divisia index (LMDI) approach. 

{phang}
    The command is very flexiable. It can be used for multi-level decomposition. For example, suppose an economy consists of N sectors, and sector i is composed of n_{i} subsectors, subsector j in sector i consumes four types of energy 
    (E_{ijk}, k=1,2,3,4) and generates output Y_{ij}. The total energy consumption change can be written as:

                                          E=sum_{i,j,k}(E_{ijk})=sum_{i,j,k}(F_{ijk}I_{ij}S2_{ij}S1_{i}Y)

    where Y=sum_{i}(Y_{i}); Y_{i}=sum_{j}(Y_{ij}); F_{ijk}=E_{ijk}/E_{ij}; E_{ij}=sum_{k}(E_{ijk}); I_{ij}=E_{ij}/Y_{ij}; S2_{ij}=Y_{ij}/Y_{i}; S1_{i}=Y_{i}/Y.

    LMDI attributes the change of E into 5 components: effect of energy composition (change in F_{ijk}), intensity effect (change in I_{ij}), structural effect at the level 2 (change in S2_{ij}), 
    structural effect at the level 1 (change in S1_{i}), and the activity effect (change in Y). 

    The data can be organized in a long panel, e,g.,

				year sector subsector E  F1  F2  F3  F4  I  S2 S1  Y
				----------------------------------------------------
				   .     i       j    .   .   .   .   .  .   .  .  .

    The decomposed effects can be obtain through the following command

                          lmdi E= (F1 F2 F3 F4) I S2 S1 Y, t(t) over(sector subsector)
    
    or equivalently, 

    if the data is organized as

                                year sector subsector  type  E   F   I  S2   S1   Y
                                ---------------------------------------------------- 
                                   .     i       j      k    .   .   .   .   .    .  
    
    The decomposed effects can be obtain through

                          lmdi E= F I S2 S1 Y, t(t) over(sector subsector type)


{title:Examples}

{phang}{cmd:. import excel using "https://gitee.com/kerrydu/Stata/raw/master/lmdi1.xlsx", first}

{phang}{cmd:. lmdi E =  I S Y, t(year) over(sector)}

{phang}{cmd:. lmdi E = (F1 F2) I S Y, t(year) over(sector)}

{phang}{cmd:. lmdi E = (F1 F2) I S Y, t(year) over(sector) add}

{phang}{cmd:. import excel using "https://gitee.com/kerrydu/Stata/raw/master/lmdi2.xlsx", first}

{phang}{cmd:. lmdi E= (I1 I2 I3 I4 I5 I6 I7 I8) (S1 S2 S3 S4 S5 S6 S7 S8) Y, t(year) over(id) sav(res) replace add}

{p2colreset}{...}

{marker references}{...}
{title:References}

{phang}
Ang, B.W., 2004. Decomposition analysis for policymaking in energy: which is the preferred method? Energy Policy 32, 1131–1139.
{p_end}
{phang}
Ang, B.W., 2005. The LMDI approach to decomposition analysis: a practical guide. Energy Policy 33, 867–871.
{p_end}



{title:Author}

{psee}
Kerry Du

{psee}
Shandong University

{psee}
China

{psee}
E-mail: kerrydu@sdu.edu.cn {p_end}

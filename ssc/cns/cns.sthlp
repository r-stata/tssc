{smcl}
{cmd:help cns}
{hline}

{title:Title}

{cmd:cns} -- Calculate the Consensus Measure (Cns) for Ordinal Scales


{title:Syntax}

     {cmd:cns} {varname}  {ifin} , {opt min()} {opt max()}


{title:Description}

{p}{cmd:cns} computes the consensus measure (Cns) presented in Tastle {it:et al}. (2005, 98) for ordinal survey scales (Likert scales). To use the command, specify the variable of interest and the required options for the (theoretical) minimum and maximum values of the scale (min < max). Currently, the program supports only one variable at a time. 


{title:Examples}

        . {cmd:cns} var1 , min(1) max(5)
        . {cmd:cns} var2 , min(0) max(4)


{title:References}

{phang}Tastle, William J., Mark J. Wierman, and U. Rex Dumdum (2005) "Ranking ordinal scales using the consensus measure," {it:Issues in Information Systems} vol. VI no. 2, 96-102.


{title:Author}

        Matthew S. Openshaw, The University of Texas at Dallas, USA
        openshaw@utdallas.edu

    {p}Please send comments, suggestions or constructive criticism to the above email address.
    
    cns
    v1.0
    Update 21 Feb 2010

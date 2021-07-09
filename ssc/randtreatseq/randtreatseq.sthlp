{smcl}
{* *! version 1.0.0 2April2015}{...}

{title:Title}

{p2colset 5 21 25 2}{...}
{p2col:{hi:randtreatseq} {hline 2}} Random sequencing of treatments  {p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}


{p 8 17 2}
{cmd:randtreatseq}
{cmd:,} 
{opt s:ample}{it:(#)} 
[
{c -(}
{opt tr:eatments}{it:(#)} 
{c |}
{opt val:ues}{it:(string)}
{c )-} 
{opt seed:}{it:(#)}
{opt repl:ace}
]


{synoptset 19 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt:{opt s:ample(#)}}sample size{p_end}

{syntab:Optional}
{synopt:{opt tr:eatments(#)}}number of treatments that an individual
will be exposed to. Either {cmd:treatments} or {cmd:values} must be
provided, but not both{p_end}
{synopt:{opt val:ues(string)}}any set of values to represent the
treatments. Either {cmd:treatments} or {cmd:values} must be provided,
but not both{p_end}
{synopt:{opt seed:(#)}}set random-number seed to #{p_end}
{synopt:{opt repl:ace}}replaces data in memory{p_end}
{synoptline}
{p 4 6 2}
{p2colreset}{...}				

	
{title:Description}

{pstd}
{cmd:randtreatseq} generates treatments in a random sequence for each
individual in the sample, thereby reducing the potential for order
effects of multiple treatments. 

{pstd}
As an example, let's assume that we want to conduct a study in which
each subject will be exposed to three treatments, sequentially.  First,
we use {helpb power repeated} to perform a sample size calculation for a
one-way repeated-measures model and determine that a sample size of 100
subjects is required. Next, we use {cmd:randtreatseq} to generate the
three treatments in random order for each of the 100 subjects. 


{title:Options}

{p 4 8 2}
{cmd:sample(}{it:#}{cmd:)} sample size; {cmd:required}.

{p 4 8 2}
{cmd:treatments(}{it:#}{cmd:)} number of treatments that an 
		individual will be exposed to.  

{p 4 8 2}
{cmd:values(}{it:string}{cmd:)} any set of values to represent the treatments. 

{p 8 8 2} 
Either {cmd:treatments} or {cmd:values} must be provided, but not both.
		
{p 4 8 2}
{cmd:seed(}{it:#}{cmd:)} set random-number seed to #.
		
{p 4 8 2}
{opt replace} replaces data in memory. An error message will be
generated if there is existing data in memory that has not been 
{help save}d and {cmd:replace} is not invoked.

	
{title:Remarks}

{pstd}
When a very large sample size has been specified, the user may encounter
an error message indicating that the maximum number of variables
allowed has been reached. In such instances, the user could reset the
maximum using {helpb set maxvar}.  


{title:Examples}

{hline}

{pstd}
Generates 3 randomly sequenced treatments for a sample of 100
individuals, using a specified seed:{p_end}
{phang2}{cmd:. randtreatseq, sample(100) treat(3) seed(12345678)}

{pstd}
Same as above, but now specifying the desired values representing the 3
treatments, and replacing the data in memory: {p_end}
{phang2}{cmd:. randtreatseq, sample(100) values(A B C) seed(12345678) replace}

{pstd}
Run {cmd:tabulate} on the sequence variable to view the frequency and
type of treatment sequences generated: {p_end}
{phang2}{cmd:. tab sequence}

{hline}

{marker output_tables}{...}
{title:Output tables}

{pstd}
{cmd:randtreatseq} produces several variables in a new dataset:

{synoptset 20 tabbed}{...}
{p2col 5 25 19 2:}{p_end}
{synopt:{cmd:Variable}}{cmd:Description}{p_end}

{synopt:{cmd:sequence}}a grouping of the treatment sequence{p_end}
{synopt:{cmd:id}}an identifier for individuals in the sample{p_end}
{synopt:{cmd:treat#}}the treatments {p_end}
	
	
	
{title:Stored results}

{pstd}
{cmd:randtreatseq} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}Sample size {p_end}
{synopt:{cmd:r(Nseq)}}Number of unique sequences. In sufficiently large
samples, this value should equal the number of all possible permutations = [n! / (n-k)!] {p_end}



{title:References}

{p 4 8 2}
Smeeton N, Cox NJ. Do-it-yourself shuffling and the number of runs under randomness. {it:Stata Journal} 2003;3(3):270-277.{p_end}



{marker citation}{title:Citation of {cmd:randtreatseq}}

{p 4 8 2}{cmd:randtreatseq} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{p 4 8 2}
Linden, Ariel (2015). randtreatseq: Stata module for generating random sequencing of treatments {p_end}



{title:Author}

{p 4 8 2}	Ariel Linden{p_end}
{p 4 8 2}	President, Linden Consulting Group, LLC{p_end}
{p 4 8 2}	Ann Arbor, MI, USA{p_end}
{p 4 8 2}{browse "mailto:alinden@lindenconsulting.org":alinden@lindenconsulting.org}{p_end}
{p 4 8 2}{browse "http://www.lindenconsulting.org"}{p_end}

         
{title:Acknowledgments} 

{p 4 4 2} I would like to thank Nicholas J. Cox for his support while developing {cmd:randtreatseq}


{title:Also see}

{p 4 8 2} Online: {helpb pkshape}, {helpb power repeated}, {helpb ralloc} (if installed), {helpb permin} (if installed), {helpb nruns} (if installed){p_end}


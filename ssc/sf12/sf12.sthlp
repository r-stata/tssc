{smcl}
{* *! version 0.11  9 Dec 2015}{...}

{viewerjumpto "Syntax" "sf12##syntax"}{...}
{viewerjumpto "Description" "sf12##description"}{...}
{viewerjumpto "Examples" "sf12##examples"}{...}
{viewerjumpto "References" "sf12##references"}{...}
{viewerjumpto "Author" "sf12##author"}{...}

{title:Title}
{phang}
{bf:sf12} {hline 2} Validate sf12 input and calculate sf12 version 2 t scores

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:sf12} {it:varlist(min=12 max=12)}

{marker description}{...}
{title:Description}
{pstd}
{cmd:sf12} takes 12 variables in correct order (i1 i2a i2b i3a i3b i4a i4b i5 
i6a i6b i6c i7), validate the variables with respect to sf12 requirements.
Only rows that are correct are used for calculating the sf12 t scores.{break}
The underlying z-scores are based on US general population means and sd's 
(They are not age/gender based).
{p_end}
{pstd}{red:It is important} for users to understand that the scaling should be 
the exact same as indicated by the sf12 version 2 questionaire.{break}
Also it is important to know that answers for i1, i5, i6a,i6b and i6c will be 
reversed when using the command.
{p_end}
{pstd}The code is based on {browse "http://gim.med.ucla.edu/FacultyPages/Hays/utils/":Ronald D Hays webpage},
especially the {browse "http://gim.med.ucla.edu/FacultyPages/Hays/utils/sf12v2-1.sas":SAS code version}.
{p_end}

{marker examples}{...}
{title:Examples}

{cmd:. input} id i1 i2a i2b i3a i3b i4a i4b i5 i6a i6b i6c i7
1 1 1 1 1 1 1 1 1 1 1 1 1
2 1 1 3 3 3 3 3 3 3 3 3 3 
3 1 1 . 3 3 3 3 3 3 3 3 3
4 5 5 1 1 1 . . . . . . .
end

{cmd:. list}, noobs
  +-------------------------------------------------------------------------+
  | id   i1   i2a   i2b   i3a   i3b   i4a   i4b   i5   i6a   i6b   i6c   i7 |
  |-------------------------------------------------------------------------|
  |  1    1     1     1     1     1     1     1    1     1     1     1    1 |
  |  2    2     1     1     3     3     3     3    3     3     3     3    3 |
  |  3    3     1     1     .     3     3     3    3     3     3     3    3 |
  |  4    4     5     5     1     1     1     .    .     .     .     .    . |
  +-------------------------------------------------------------------------+
  
{cmd:. sf12} i1 i2a i2b i3a i3b i4a i4b i5 i6a i6b i6c i7
{cmd:. format} pf-agg_ment %6.2f
{cmd:. list} id pf rp bp gh vt sf re mh agg_phys agg_ment, noobs
  +------------------------------------------------------------------------------------------+
  | id      pf      rp      bp      gh      vt      sf      re      mh   agg_phys   agg_ment |
  |------------------------------------------------------------------------------------------|
  |  1   22.11   20.32   57.44   61.99   67.88   16.18   11.35   40.16      43.47      32.72 |
  |  2   39.29   38.75   37.06   61.99   47.75   36.37   33.71   40.16      45.73      38.88 |
  |  3       .   38.75   37.06   61.99   47.75   36.37   33.71   40.16          .          . |
  |  4       .   20.32       .   18.87       .       .       .       .          .          . |
  +------------------------------------------------------------------------------------------+
{pstd}Input and output can be refound {browse "http://gim.med.ucla.edu/FacultyPages/Hays/utils/sf12v2-1.sas":here} 
and {browse "http://gim.med.ucla.edu/FacultyPages/Hays/utils/sf12v2-1.lst":here}, respectively.{break}
Compare eg pf (Stata) with pf_t (SAS).
{p_end}

  
{cmd:. describe} pf-agg_ment

              storage   display    value
variable name   type    format     label      variable label
--------------------------------------------------------------------------------------------------------------------------------------------------------------
pf              double  %6.2f               * NEMC physical functioning t-score
rp              double  %6.2f               * NEMC role limitation physical t-score
bp              double  %6.2f               * NEMC pain t-score
gh              double  %6.2f               * NEMC general health t-score
vt              double  %6.2f               * NEMC vitality t-score
sf              double  %6.2f               * NEMC social functioning t-score
re              double  %6.2f               * NEMC role limitation emotional t-score
mh              double  %6.2f               * NEMC mental health t-score
agg_phys        double  %6.2f               * NEMC physical health t-score - sf12
agg_ment        double  %6.2f               * NEMC mental health t-score - sf12



{marker references}{...}
{title:References}

{phang}
	Hays RD, Sherbourne CD, Spritzer KL, & Dixon W J. (1996){break}
	{browse "http://gim.med.ucla.edu/FacultyPages/Hays/utils/SF36/sf36.doc":A Microcomputer Program (sf36.exe) that Generates SAS Code for Scoring the SF-36 Health Survey.}{break}  
	Proceedings of the 22nd Annual SAS Users Group International Conference, 1128-1132.
{p_end}
{phang}
	Ron D. Hays, Leo S. Morales (2001){break}
	{browse "http://www.rand.org/content/dam/rand/pubs/reprints/2005/RAND_RP971.pdf":The RAND-36 Measure of Health-Related Quality of Life}{break}
	Annals of Medicine, v. 33, 2001, pp. 350-357
{p_end}
{phang}
	Sepideh S Farivar, William E Cunningham and Ron D Hays (2007)
	{browse "http://www.rand.org/content/dam/rand/pubs/reprints/2008/RAND_RP1309.pdf":Correlated physical and mental health summary scores for the SF-36 and SF-12 Health Survey, V.1}
	Health and Quality of Life Outcomes 2007, 5:54
{p_end}
	
{marker author}{...}
{title:Author}
{p}

Niels Henrik Bruun,{break}Section for General Practice{break}Dept. Of Public Health{break}Aarhus University.

Email {browse "mailto:nhbr@ph.au.dk":nhbr@ph.au.dk}

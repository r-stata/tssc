{smcl}
{* August 10, 2011 @ 11:45:03 UK}{...}

{hline}
{center:{yellow:Sequence analysis using Stata -- software demonstration}}
{hline}

{cmd:Ulrich Kohler, University of Potsdam}
{browse "mailto:ulrich.kohler@uni-potsdam.de":ulrich.kohler@uni-potsdam.de}

{cmd:Christian Brzinsky-Fay, WZB}
{browse "mailto:brzinsky-fay@wz-berlin.de":brzinsky-fay@wzb.eu}

{cmd:Magdalena Luniak, WZB}

{hline}
{center:{yellow:Contents}}
{hline}

{hi:Preliminaries}

o {help sqdemo##datastructure:Long versus wide}
o {help sqdemo##sqset:sqset the data}

{hi:The egen functions}

o {help sqdemo##egen:Generate variables with descriptive information on sequences}
o {help sqdemo##sqstat:Display contents of e-generated variables}

{hi:Descriptive tables}

o {help sqdemo##sqtab:Tabulate sequences}
o {help sqdemo##sqdes:Describe sequences}

{hi:Graph sequences}

o {help sqdemo##sqparcoord:Parallel-coordinates plot}
o {help sqdemo##sqindexplot:Sequence index plots}

{hi:Optimal matching}
	
o {help sqdemo##sqom:The sqom command}
o {help sqdemo##sqom_results:Accessing the results}
o {help sqdemo##sqom_speed:On speed}


{hline}{marker datastructure}
{center:{yellow:Long versus Wide}}
{hline}

{p 0 0 0} Sequences are entities of their own; i.e., one thinks about
sequences in "wide" form, and that is how datasets are usually
structured. {p_end}

{p 0 4 0}. {stata "use http://www.uni-potsdam.de/soziologie-methoden/dokumente/kohler/data/youthemp.dta , clear"}{p_end}

{p 0 4 0}. {stata "list id st1-st10 in 1/10"}

{p 0 0 0}
Many Stata users prefer sequences in "long" form. The programs are
therefore written for data in long form. Hence, to use the programs,
one has to reshape from wide to long.  {p_end}

{p 0 4 0}. {stata "reshape long st, i(id) j(order)"}{p_end}

{p 0 4 0}. {stata "list id st in 1/10"}


{hline}{marker sqset}
{center:{yellow:sqset the data}}
{hline}

{p 0 0 0} To work with the SQ-Ados, one has to {cmd:sqset} the data. This
command works similar to {help tsset}, {help stset}, or {help xtset}.
{p_end}


{title:Syntax}

{phang2}
{cmd:sqset}
{it:elementvar} {it:idvar} {it:ordervar} [{cmd:,} {cmd:trim} {cmd:rtrim}
             {cmd:ltrim} {cmd:keeplongest}]

{phang2}
{cmd:sqset} [{cmd:,} clear]


{title:Example}
	
{p 0 4 0}. {stata sqset st id order }{p_end}

{p 0 0 0}Among other things, {cmd:sqset} checks for gaps, confirms integer
order and uniqueness of sequence-IDs, and confirms order.  {p_end}


{hline}{marker sqset}
{center:{yellow:Generate variables with summary descriptions}}
{hline}

{p 0 0 0}The SQ-egen functions are used to generate variables that
hold a summary description of each sequence.  {p_end}


{title:General usage}

{phang2}
{cmd:egen} [{it:type}] {newvar} = {it:sqfcn}{cmd:()} [{cmd:,} {it:options}] 


{title:Examples}
	
. {stata egen seqlen = sqlength()}             <-  Overall length of sequence 
. {stata egen dur1 = sqlength(), element(1)}   <-  Overall length of sequence of element 1
. {stata egen gaplen = sqgaplength()}          <-  Length of gaps
. {stata egen gapcount = sqgapcount()}         <-  Number of episodes with gaps
. {stata egen elemnum = sqelemcount()}         <-  Number of different elements in sequence 
. {stata egen chnum = sqepicount()}            <-  Number of episodes 
. {stata egen epi1 = sqepicount(), element(1)} <-  Number of episodes of element 1

. {stata describe}  


{p 0 0 0} Stata keeps track of all variable names that are generated
with the SQ-egen functions. Other SQ-commands automatically use the
e-generated variables. The names of the e-generated variables are
stored as together with the dataset.  {p_end}

{hline}{marker sqstat}
{center:{yellow:Display contents of e-generated variables}}
{hline}

{p 0 0 0} The {hi:sqstat} bundle provides convenient displays for
the variables generated with the SQ-egen functions.  {p_end}


{title:List features of sequences}

. {stata sqstatlist if sex }
. {stata sqstatlist dur1 elemnum chnum, ranks(1/10)}

. {stata preserve}
. {stata sqstatlist sex dur1, replace}
. {stata describe}
. {stata tab sex, sum(dur1)}
. {stata restore}


{title:Summarize features of sequences}

. {stata sqstatsum}
. {stata sqstatsum dur1 epi1 if sex} 


{title:Tabulate features of sequences}

. {stata sqstattab1}
. {stata sqstattab1 dur1 gaplen}

. {stata sqstattab2 elemnum sex}

. {stata sqstattabsum sex}
. {stata sqstattabsum sex, sum(dur1)}

{hline}{marker sqtab}
{center:{yellow:Tabulate sequences}}
{hline}

{p 0 0 0} {hi:sqtab} is used to produce a frequency table of the
sequences in the dataset.  {p_end}


{title:Syntax}

{phang2}
{cmd:sqtab} [{varname}] {ifin} [{cmd:,} {opth ranks(numlist)}
	{cmd:se} {cmd:so} {cmd:nosort} {cmd:gapinclude} 
	{it:tabulate_options}]

{title:Example}

. {stata sqtab}         
. {stata sqtab, ranks(1/10)}         

{title:"Same order" and "Same elements"}

{p 0 0 0} {hi:sqtab} allows a simple definition of similarity of
sequences. With the option {cmd: so}, all sequences that have the same
order of elements are collapsed together. The option {cmd: se}
collapses sequences that consist of the same elements.  {p_end}

. {stata sqtab, so}         
. {stata sqtab, se}         

{hline}{marker sqdes}
{center:{yellow:Describe sequences}}
{hline}

{p 0 0 0} {hi:sqdes} produces a descriptive overview of the sequences
in the dataset. More specifically, it shows {p_end}

{p 10 12 10} o the number of elements observable over all sequences
(k), {p_end}

{p 10 12 10}  o the maximum length of the sequences (l), {p_end}

{p 10 12 10}  o the number of possible sequences that might be formed with k 
	elements of length l, {p_end}

{p 10 12 10}  o the number of different sequences in the dataset, and {p_end}

{p 10 12 10}  o the number of sequences that are shared by ... persons {p_end}


{title:Syntax}

{phang2}
{cmd:sqdes} {ifin} [{cmd:,} {cmd:so} {cmd:se} {cmd:graph} {opt gap:include}]


{title:Examples}

. {stata sqdes}
. {stata sqdes, so}
. {stata sqdes, se graph}

{hline}{marker sqparcoord}
{center:{yellow:Graph sequences as parallel-coordinates plot}}
{hline}

{p 0 0 0} {hi:sqparcoord} produces parallel-coordinates plots of the
sequences in the dataset. In its simplest form, such plots are useful
only for very small numbers of sequences. Therefore, {hi:sqparcoord}
provides several options to produce meaningful displays even with larger 
numbers of sequences.{p_end}


{title:Syntax}

{phang2}
{cmd:sqparcoord} {ifin} [{cmd:,} {opth ranks(numlist)} {cmd:so}
      {opt offset(#)} {opt wlines(#)} {cmd:gapinclude} {it:twoway_options}]


{title:Examples}

. {stata sqparcoord}                            <- All sequences (useless) 
. {stata sqparcoord, ranks(1/10) offset(.5)}    <- 10 most frequent sequences, with offset
. {stata sqparcoord, wlines(7)}                 <- Plot frequent sequences much thicker 

. {stata sqparcoord, so ranks(1/10) offset(.5)} <- Using "same order" sequences
. {stata sqparcoord, so wlines(7)}              <- Plot frequent sequences much thicker 


{hline}{marker sqindexplot}
{center:{yellow:Graph sequences as sequence index plot}}
{hline}

{p 0 0 0} {hi:sqparcoord} produces a sequence index plot (Brüderl
and Scherer 2006).  In these plots, the episodes of the sequences are
plotted as stacked horizontal bars with colors to separate the
different elements.  {p_end}

{p 0 0 0} As stressed elsewhere, the results of sequence index plots
depend on the order the sequences in the graph. A simple algorithm
is used to order of the sequences in the plot, but results of more
sophisticated algorithms can also be used (for example, results from
{help sqom}).  {p_end}


{title:Syntax}

{phang2}
{cmd:sqindexplot} {ifin} [{cmd:,} {opth ranks(numlist)} {cmd:se} {cmd:so}
      {opth order(varname)} {opth by(varname)} {opth color(colorstyle)}
      {cmd:gapinclude} {it:twoway_options}]


{title:Examples}

. {stata sqindexplot, color(blue green black yellow red)}
. {stata sqindexplot, ranks(1/10)}
. {stata sqindexplot, so}
. {stata sqindexplot, se}


{title:Note}

{p 0 0 0} With sequence index plots, one might overstate the frequency
of elements on "high" levels. This can be minimized by (a) decent
ordering and (b) tuning the aspect ratio. {p_end}

{hline}{marker sqom}
{center:{yellow:Perform optimal matching}}
{hline}

{p 0 0 0} {hi:sqom} performs a cluster analysis of sequences on the basis of 
a distance matrix produced by the Needleman-Wunsch algorithm. It
allows free specification of "Indel" and "substitution" cost, as well
as different kinds of standardizations. Results are stored for
later use.


{title:Syntax}

{phang2}
{cmd:sqom} {ifin} [{cmd:,} {cmdab:indel:cost(#)}
          {cmdab:sub:cost(}{it:#}|{cmd:rawdistance}|{it:matexp}|{it:matname})}
	  {opt name(varname)}
	  {opt ref:seqid(spec)}
          {opt full}
          {opt k(#)}
          {cmdab:st:andard(}{it:#}|{cmd:cut}|{cmd:longer}|{cmd:longest}|{cmd:none}{cmd:)}


{title:Examples}

. {stata sqom}                       <- Default: Indel = 1, subcost = 2
. {stata sqom, indelcost(3)}         <- Indel = 3, subcost = indelcost*2
. {stata sqom, subcost(rawdistance)} <- Indel = 1, subcost = abs(value1-value2)

. {stata matrix sub = 0,8,7,3,2\8,0,8,7,3\7,8,0,8,7\3,7,8,0,7\2,3,7,7,0}
. {stata sqom, subcost(sub) }        <- subcosts from matrix "sub"

. {stata sqom, standard(cut) }        <- cut at length of shortest    
. {stata sqom, standard(6) }          <- cut at length of 6
. {stata sqom, standard(longer) }     <- divide by the longer of two

. {stata sqom, full k(2) }            <- full dissimilarity matrix

	
{hline}{marker sqom_results}
{center:{yellow:Accessing results of optimal matching}}
{hline}

{p 0 0 0} Results from {hi:sqom} can be accessed for further
analysis. Distances are either saved as a variable or as a Stata
matrix named {hi:SQdist}. The convenience programs {hi:sqclusterdat}
and {hi:mdsadd} helps adding results of cluster analyses and/or multidimensional
scaling to the sequence data. 


{title:Examples}

. {stata sqom, name(om1)}
. {stata describe om1} 
. {stata sqindexplot, order(om1)}

. {stata sqom, full k(2)}
. {stata matrix dir}
. {stata sqclusterdat}
. {stata clustermat wardslinkage SQdist, name(myname) add}
. {stata cluster tree myname, cutnumber(20)}
. {stata sqclusterdat, return}

. {stata mdsmat SQdist}
. {stata predict mdsdim1, saving(mds)}
. {stata sqmdsadd using mds}



{smcl}
{* *! version 0.1 30Dec2017}{...}
{cmd:help msboxes} 
{right:also see:  {help msset} {help predictms}}

{title:Title}

{p2colset 5 16 19 2}{...}
{p2col :{hi:msboxes} {hline 2}}Simple plot to summarise states and transitions in a multi-state model{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 16 2}{cmd:msboxes} [{cmd:,} {it:options}]

{marker options}{...}
{synoptset 29 tabbed}{...}
{synoptline}

{synopt :{opt boxh:eight(#)}}height of boxes{p_end}
{synopt :{opt boxw:idth(#)}}width of boxes{p_end}
{synopt :{opt id(varname)}}name of subject ID variable{p_end}
{synopt :{opt grid}}add a grid to the plot{p_end}
{synopt :{opt staten:ames(string)}}List of names of states{p_end}
{synopt :{opt transm:at}}name of transition matrix{p_end}
{synopt :{opt yran:ge(numlist)}}range of y-axis{p_end}
{synopt :{opt xran:ge(numlist)}}range of x-axis{p_end}
{synopt :{opt ysize(#)}}y size of plot{p_end}
{synopt :{opt xsize(#)}}x size of plot{p_end}
{synopt :{opt yval:ues(numlist)}}y values of the centre of each box{p_end}
{synopt :{opt xval:ues(numlist)}}x values of the centre of each box{p_end}

{synoptline}
{p 4 6 2}

{title:Description}

{pstd}
{cmd:msboxes} is a simple descriptive tool to summarise data to be used in a multistate model. It will plot boxes for each state andsummarise the number at risk at the start and end of follow-up. 
Transitions are denoted by arrows between the boxes and show the number of subjects that transition between the different states. Before using {cmd:msboxes} you should use {cmd:msset} and then {cmd:stset}. See the examples below.{p_end}

{pstd}
By default the boxes are plotted on a (0,1) (0,1) grid and the user must give sensible values for the centre of each box. There are simple rules on how to join the boxes with arrows and where to place the text.{p_end}


{title:Options}

{phang}
{opt boxheight(#)} Height of the boxes to denote states. Default is 0.3{it:varname}. 

{phang}
{opt boxwidth(#)} Width of the boxes to denote states. Default is 0.2{it:varname}. 

{phang}
{opt grid} Add a grid to the plot. Useful when trying to get the plot to look nice by showing where it my be a good 
idea to move the boxes. 

{phang}
{opt id(varname)} Name of id variable.{it:varname}. 

{phang}
{opt statenames(string)} The names of each state. These should be given as a list of names, for example
{cmfd:statenames("Healthy" "Diseased" "Dead before disease" "Dead with disease")}

{phang}
{opt transmat(matrix)}  specifies the transition matrix used in the multi-state model that was fitted. This must be an upper triangular matrix (with diagonal and lower triangle elements coded missing). Transitions must be numbered as an increasing sequence of integers from 1,...,K. This transition matrix should be the same as that used/produced by {cmd:msset}.

{phang}
{opt yrange(numlist)} gives the range of the y-axis. By default this is (0 1).

{phang}
{opt xrange(numlist)} gives the range of the x-axis. By default this is (0 1).

{phang}
{opt ysize(#)} gives the ysize of the plot. Default taken from the default scheme.(0 1).

{phang}
{opt xsize(#)} gives the xsize of the plot. Default taken from the default scheme.(0 1).

{phang}
{opt yvalues(numlist)} gives the y locaion of the centre of each box for each state. It should be a {it:numlist} of length {it:K}, where {it:K} is the number of states. 

{phang}
{opt xvalues(numlist)} gives the x locaion of the centre of each box for each state. It should be a {it:numlist} of length {it:K}, where {it:K} is the number of states. 

{title:Remarks}

{pstd}
This is a fairly basic implementation and aims to give a quick summary of the data that feeds into the multi-state model. 
It is not aimed to give publication quality figures. 
You may need some trial and error of the location and size of the boxes.
{p_end}

{title:Examples}

 This dataset contains information on 2982 patients with breast cancer. Baseline is defined as time of surgery, and patients can experience relapse, 
 relapse then death, or death with no relapse. Time of relapse is stored in rf, with event indicator rfi, and time of death is stored in os, with event indicator osi.



{pstd} {bf: Illness death model.} A simple three state illness-deda


{cmd:. use http://fmwww.bc.edu/repec/bocode/m/multistate_example}
{cmd:. msset, id(pid) states(rfi osi) times(rf os)}
{cmd:. matrix tmat = r(transmatrix)}
{cmd:. msboxes, transmat(tmat) id(pid) xvalues(0.2 0.7 0.45) yvalues(0.7 0.7 0.2) ///}
{cmd:>    statenames("Surgery" "Relapse" "Dead")}
		{it:({stata msboxes_examples 1:click to run})}	

{pstd} {bf: Extended illness death model. Separate deaths before/after recurrence.}

{cmd:. use http://fmwww.bc.edu/repec/bocode/m/multistate_example}
{cmd:. matrix tmat = (.,1,2,. \ .,.,.,3 \ .,.,.,. \ .,.,.,.)}
{cmd:. matrix list tmat}
{cmd:. msset, id(pid) states(rfi osi osi) times(rf os os) transmatrix(tmat)}
{cmd:. msboxes, transmatrix(tmat) id(pid)}
{cmd:>   xvalues(0.2 0.7 0.2 0.7) ///}
{cmd:>   yvalues(0.7 0.7 0.2 0.2) ///}
{cmd:>   statenames(Surgery Relapse Dead Dead) ///}
{cmd:>   boxheight(0.2) yrange(0.09 0.81) ysize(3)}
		{it:({stata msboxes_examples 2:click to run})}	


{title:Author}	

{pstd}
Paul Lambert, University of Leicester, UK.
({browse "mailto:paul.lambert@leicester.ac.uk":paul.lambert@leicester.ac.uk})

{title:Acknowledgement}

{phang}
This is based on the R command boxes written by Bendix Carstensen.
{p_end}

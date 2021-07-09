{smcl}
{* Sally R. Hinchliffe & David A. Scott & Paul C. Lambert 17July2012 }{...}
{cmd:help illdprep} 
{right:also see:  {helpb stpm2{space 2}}{helpb stpm2illd{space 2}}{helpb stpm2_postestimation{space 2}}}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{cmd:illdprep} {hline 2}}Sets the data up in the format required for illness death models using {cmd:stpm2} and {cmd:stpm2illd}. {p_end}
{p2colreset}{...}


{title:Syntax}

{phang2}
{cmd: illdprep} [{cmd:,} {it:options}]

{synoptset 34}{...}
{synopthdr}
{synoptline}
{synopt:{opt id}} specifies the name of the ID variables in your data set. {p_end}
{synopt:{opt statevar}} specifies the names of the two event indicator variables e.g. relapse and dead. {p_end}
{synopt:{opt statetime}} specifies the names of the two event time variables e.g. relapsetime and survtime. {p_end}
{synopt:{opt status}} allows user to specify the name of the newly generated status variable. {p_end}
{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}{cmd:illdprep} is used to set up the data in the required format for illness death models using {cmd:stpm2} and {cmd:stpm2illd}. 

The command will expand the data so that each individual will have up to 3 rows of data. Six new variables will be created. The variables {it:trans1}, {it:trans2} 
and {it:trans3} are variables that indicate whether an individual has passed through that particular transition. The transition numbers correspond to those in the 
diagram below. The {it:status} variable is an additional event indicator that summarizes the information from {it:trans1}, {it:trans2} and {it:trans3}. Finally, 
the variables {it:start} and {it:stop} give the times at which each individual enters and leaves each transition.


                                      -------------                            -------------
                                      |           |                            |           |
                                      |   Alive   |         Transition 2       |    Ill    |
                                      |           |-------------->-------------|           |
                                      |  State 1  |                            |  State 2  |
                                      |           |                            |           |
                                      -------------                            -------------
                                            |                                        |                         
                                            |                                        |                        
                                            |                                        |                            
                               Transition 1 |                                        | Transition 3
                                            |                                        |                          
                                            |                                        |                      
                                            |                                        |                       
                                            |                                        |                          
                                      -------------                            -------------
                                      |           |                            |           |
                                      |   Dead    |                            |   Dead    |
                                      |           |                            |           |
                                      |  State 3  |                            |  State 4  |
                                      |           |                            |           |
                                      -------------                            -------------		 
{title:Options}

{phang}
{opt id} specifies the name of the id variable in the data set. Before the command is used each id number should have just 1 row of data. 
The command will expand the data so that each id number will have up to 3 rows of data. {p_end}

{phang}
{opt statevar(varlist)} specifies the names of the two event indicator variables needed to split the data. Looking at the diagram above,
an indicator variable will be needed to specify whether a patient has become ill and whether a patient has died. As death is a final absorbing state 
this must come last in the varlist. So for example if we were interested in relapse and death and our event indicator variables were relapse and dead 
then we would specify {opt statevar(relapse dead)} in that order. {p_end}

{phang}
{opt statetime(varlist)} specifies the names of the two event time variables. The variables should be inputted in the order that corresponds to {opt statevar(varlist)}.
So if our event time variables were relapsetime and survtime then we would specify {opt statetime(relapsetime survtime)} in that order to correspond with the 
example given for {opt statevar(varlist)}. {p_end}		 


{title:Example}

{phang}

The Rotterdam breast cancer data used in this example is taken from the book "Flexible Parametric Survival Analysis Using Stata: Beyond the Cox Model"
by Patrick Royston and Paul C. Lambert (2011). The data can be downloaded from http://www.stata-press.com/data/fpsaus.html. 
The data contains information on 2,982 with primary breast cancer. Both time to relapse and time to death are recorded.

{phang}

Open the data and run the {cmd:illdprep} command to set the data up in the format required for illness death models using {helpb stpm2} and {cmd:stpm2illd}. 
The ID variable in the data set is called {cmd:pid}. There are two event indicators; {cmd:rfi} indicates whether a patient has suffered a relapse, and {cmd:osi}
indicates whether a patient has died or not. There are also two event time variables that correspond with these; {cmd:rf} and {cmd:os}.

{phang2} use rott2, clear {p_end}
{phang2} illdprep, id(pid) statevar(rfi osi) statetime(rf os) {p_end}

{phang}

The command has expanded the data so that each individual has up to 3 rows of data. As described above, six new variables have been generated. We can now {helpb stset} 
the data using the newly generated {cmd:status} variable as the failure indicator. The newly generated {cmd:start} and {cmd:stop} times need to be included in the
{helpb stset} command to indicate when an individual enters and leaves a transition.

{phang2} stset stop, enter(start) failure(status==1) scale(12) exit(time start+(10*12)) {p_end}

{phang}

Once the data is {helpb stset} we can run the {helpb stpm2} and {helpb stpm2illd} commands to fit an illness death model.



{title:Also see}

{psee}
Online:  {manhelp stpm2 ST} {manhelp stpm2_postestimation ST}; 
{p_end}
		 

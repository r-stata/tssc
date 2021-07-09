{smcl}
{* Sally R. Hinchliffe & David A. Scott & Paul C. Lambert 17July2012 }{...}
{cmd:help stpm2illd} 
{right:also see:  {helpb illdprep{space 2}}{helpb stpm2{space 2}}{helpb stpm2_postestimation{space 2}}}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{cmd:stpm2illd} {hline 2}}Illness death model post-estimation tool to estimate transition hazards and probabilities after stpm2{p_end}
{p2colreset}{...}


{title:Syntax}

{phang2}
{cmd: stpm2illd} {it:newvarlist} [{cmd:,} {it:options}]

{synoptset 34}{...}
{synopthdr}
{synoptline}
{synopt:{opt trans1}{it:...}{opt trans3}} covariates specified by listed varname(s) be set to # when predicting hazards for each transition. {p_end}
{synopt:{opt obs}} specifies the number of observations (of time) to predict for. {p_end}
{synopt:{opt ci}} calculates confidence intervals for probabilities. {p_end}
{synopt:{opt mint}} the minimum value of follow up time. {p_end}
{synopt:{opt maxt}} the maximum value of follow up time. {p_end}
{synopt:{opt time:name}} name of new time variable generated in command. {p_end}
{synopt:{opt haz:ard}} predicts hazard function for each transition. {p_end}
{synopt:{opt hazname}} name given for transition hazards if {opt haz:ard} specified. {p_end}
{synopt:{opt combine}} combines the probabilities of being in states 3 and 4 to give overall probability of death. {p_end}
{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}{cmd:stpm2illd} can be used after {helpb stpm2} to obtain transition hazards and probabilities in an illness death model. 


Four names should be specified in the {it:newvarlist}. The new variables names should be specified in the order according to the diagram below. 
So for example, if we write "alive ill dead illdead" in the newvarlist then the probability of being in each state as a function of time will be stored as
{cmd:prob_}{it:alive}, {cmd:prob_}{it:ill}, {cmd:prob_}{it:dead} and {cmd:prob_}{it:illdead}. 

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
Note: in the table below, {it:vn} is an abbreviation for {it:varname}.

{dlgtab:Main}

{phang}
{opt trans1(vn # [vn # ..])}{it:..}{opt trans3(vn # [vn # ..])} requests that the covariates specified by 
the listed {it:varname(s)} be set to # when predicting the hazards for each transition. 
It is complusory to specify all of these. The transition numbers correspond to those in the diagram above. 
Therefore, {opt trans1} relates to the transition from alive to dead, {opt trans2} relates to the transition from alive to ill, and
{opt trans3} relates to the transition from ill to dead. {p_end}

{phang}
{opt obs(integer)} specifies the number of observations (of time) to predict for (default 1000). Observations are evenly 
spread between the minimum and maximum value of follow-up time. {p_end}

{phang}
{opt ci} calculates a 95% confidence interval for the probabilities and
stores the confidence limits in {cmd:prob_}{it:newvar}{cmd:_lci} and {cmd:prob_}{it:newvar}{cmd:_uci}. {p_end}

{phang}
{opt mint(#)} the minimum value of follow up time. The default is set as the minimum event time from {helpb stset}. {p_end}

{phang}
{opt maxt(#)} the maximum value of follow up time. The default is set as the maximum event time from {helpb stset}. {p_end}

{phang}
{opt timename(varname)} is the name given to time variable used for predictions (default {\it \_newt}). 
Note that this is the variable for time that needs to be used when plotting curves for the transition hazards and probabiltiies. {p_end}

{phang}
{opt hazard} predicts the hazard function for each transition. {p_end}

{phang}
{opt hazname(varlist)} if the {opt hazard} is specified then this allows the user to specify the names for the transition hazards. 
These will then be stored in variables called {cmd:h_}{it:var}. If nothing is specified then the default names are
{cmd:h_trans1}, {cmd:h_trans2} and {cmd:h_trans3}. {p_end}

{phang}
{opt combine} allows the user to combine the probabilities of being in states 3 and 4 to give the overall probability of death. 
If this option is specified then the user only needs to give three names in {it:newvarlist}. The last name given in the list should
correspond to the combined probability of states 3 and 4. So for example, if we write "alive ill dead" in the newvarlist then the 
probability of being in each state as a function of time will be stored as {cmd:prob_}{it:alive}, {cmd:prob_}{it:ill} and {cmd:prob_}{it:dead}.{p_end}

{title:Example}

{phang}

The Rotterdam breast cancer data used in this example is taken from the book "Flexible Parametric Survival Analysis Using Stata: Beyond the Cox Model"
by Patrick Royston and Paul C. Lambert (2011). The data can be downloaded from http://www.stata-press.com/data/fpsaus.html. 
The data contains information on 2,982 with primary breast cancer. Both time to relapse and time to death are recorded.

{phang}

Open the data and run the {helpb illdprep} command to set the data up in the format required for illness death models using {helpb stpm2} and {cmd:stpm2illd}. 
The ID variable in the data set is called {cmd:pid}. There are two event indicators; {cmd:rfi} indicates whether a patient has suffered a relapse, and {cmd:osi}
indicates whether a patient has died or not. There are also two event time variables that correspond with these; {cmd:rf} and {cmd:os}.

{phang2} use rott2, clear {p_end}
{phang2} illdprep, id(pid) statevar(rfi osi) statetime(rf os) {p_end}

{phang}

The command has expanded the data so that each individual has up to 3 rows of data. As described above, six new variables have been generated. We can now {helpb stset} 
the data using the newly generated {cmd:status} variable as the failure indicator. The newly generated {cmd:start} and {cmd:stop} times need to be included in the
{cmd:stset} command to indicate when an individual enters and leaves a transition.

{phang2} stset stop, enter(start) failure(status==1) scale(12) exit(time start+(10*12)) {p_end}

{phang}

We can now run {helpb stpm2} including each of the three transitions in the model.

{phang2} stpm2 trans1 trans2 trans3, scale(hazard) rcsbaseoff nocons dftvc(3) tvc(trans1 trans2 trans3) initstrata(trans) {p_end}

{phang}

Note that by including the three transition variables {cmd:trans1}, {cmd:trans2} and {cmd:trans3}) as both main effects and
time-dependent effects (using {cmd:tvc} option) we have fitted a stratified model with three separate baselines, one for each transition. 
For this reason we have used the {cmd:rcsbaseoff} option together with the {cmd:nocons} option which excludes the baseline hazard from the model. 

{phang}

The {cmd:stpm2illd} postestimation command can now be run to obtain the probability of being in each of the four states, 
as demonstrated in the above diagram, as a function of time. By specifying the {cmd:hazard} option the command will also
predict the hazard function for each of the three transitions.

{phang2} stpm2illd alive ill death illdeath, trans1(trans1 1) trans2(trans2 1) trans3(trans3 1) hazard {p_end}

{phang}

The variables {cmd:prob_alive}, {cmd:prob_ill}, {cmd:prob_death} and {cmd:prob_illdeath} have been generated for the probabilities 
of being in each of the four states. As we have specified the {cmd:hazard} option the variables {cmd:h_trans1}, {cmd:h_trans2} and 
{cmd:h_trans3} have also been generated.


{title:Also see}

{psee}
Online:  {manhelp stpm2 ST} {manhelp stpm2_postestimation ST}; 
{p_end}









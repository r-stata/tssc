{title:Output}

{phang}
This command is implemented as an r-class command, which leaves behind the
following results saved in r(): {p_end}

{phang}
{opt r(maxinfect)} - maximum size of the infected subpopulation throughout 
the simulation timeframe. This will be measured in percent if the 
option {opt percent} was specified, otherwise it is an absolute number 
of infected.{p_end}

{phang}
{opt r(d_maxinfect)} - this is the step of simulation on which the maximum 
infected size was reached, and can take values 0, 1, 2, .... If number of steps of simulation per day is 1, then this is also the day-number when the maximum infected size was reached. {p_end}

{phang}
{opt r(t_maxinfext)} - this is the same as {it:r(d_maxinfect)} if no option 
{opt day0()} was specified and simulation steps per day is 1. But if the 
{opt day0()} option was specified, then it takes the calendar date 
(in Stata's date) format for the date where the maximum infected size 
was reached. For example, a value {it:22025} will correspond to 
{it:April 20, 2020}. If the number of steps of simulation in more than 1 per day, expect this value to be non-integer.{p_end}

{phang}
{opt r(o_maxinfext)} - this is the observation number, in which maximum 
infected size was reached.{p_end}

{pstd}
The simulation of the model steps is also saved into a matrix with the name 
of the model: {it:r(sir)} or {it:r(seir)}. The columns of this 
matrix area the components of the model (time, susceptible, etc), and each 
row corresponds to one day of the simulation. The number of rows will be 1 
plus the value of the option {opt days()}. The time variable in the matrix 
is always the day of the model simulation, not the date, even when the 
option {opt day0()} was specified. {p_end}

{pstd}
The command also produces output in the data area in memory (which can be 
cleared with the option {opt clear} if it already contains anything). The 
generated variables will have names corresponding to the model components 
(for example {it:S} for {it:Susceptible}, {it:I} for {it:Infected}, etc). 
Model components will be named in upper case if they represent absolute 
numbers, and lower case if they represent shares (if option {opt percent} 
was specified). The time variable {it:t} is always lower case.{p_end}

{pstd}
The model simulation command will build a graph plotting the 
trajectories of all the model componets over the simulation time frame. 
This graph can be suppressed by specifying an option {opt nograph} or it 
can be adjusted by specifying common twoway graphing options.{p_end}

{pstd}
Finally, a report can be created as a file if the {opt pdfreport()} is specified.
The report file is always replaced.
{p_end}

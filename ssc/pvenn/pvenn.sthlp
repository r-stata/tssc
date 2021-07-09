{smcl}
{* 23 Nov 2011}{...}
{cmd:help pvenn}
{hline}

{title:Title}

    {hi: Proportional Venn Diagrams}

{title:Syntax}

{p 8 17 2}
{cmdab:pvenn} [{it:var1 }[{it:... var3}]] 
[{cmd:,} [{it:{help pvenn##manual_mode_opts:manual_mode_opts}}] {it:{help pvenn##options:options}}]

{synoptset 30 tabbed}{...}
{marker manual_mode_opts}{...}
{synopthdr :manual_mode_opts}
{synoptline}
{syntab:Main}
{synopt:{opt plabel}(lblname [lblname ...])} specifies a list of label names for the populations.{p_end}
{synopt:{opt pA}(#)} specifies the size of population A.{p_end}
{synopt:{opt pB}(#)} specifies the size of population B.{p_end}
{synopt:{opt pC}(#)} specifies the size of population C.{p_end}
{synopt:{opt pAB}(#)} specifies the size of overlap between population A & B.{p_end}
{synopt:{opt pAC}(#)} specifies the size of overlap between population A & C.{p_end}
{synopt:{opt pBC}(#)} specifies the size of overlap between population B & C.{p_end}
{synopt:{opt ptotal}(#)} specifies the size of total population.{p_end}
{synoptline}

{marker options}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt ang}(#)} specifies the angle between the connecting lines of circle A/B center and the X axis, that is the relative location of circle B to circle A; default is 0.{p_end}
{synopt:{opt pos}(#)} specifies the relative location of circle C to circle A & B; default is 1.{p_end}
{synopt:{opt drawtotal}(#)} draw a rectangle outside all circles to represent the total population size; default is 1.{p_end}
{synopt:{opt drawlabel}(#)} draw labels in circles indicating names of the populations; default is 1.{p_end}
{synopt:{opt lc}({help colorstyle}list)} specifies a line color for each circle and rectangle; default is "cranberry emerald brown lavender".{p_end}
{synopt:{opt lp}({help linepatternstyle}list)} specifies a line pattern for each circle and rectangle; default is "solid solid solid solid".{p_end}
{synopt:{opt lw}({help linewidthstyle}list)} specifies a line widths for each circle and rectangle; default is "0.8 0.8 0.8 0.8".{p_end}
{synopt:{opt n}(#)} specify the points (#*2) used to draw a circle; default is 20000.{p_end}
{synopt:{help twoway_options} } specifies additional twoway options (not all of them area allowed), for example titles() and notes().{p_end}
{synoptline}

{p2colreset}{...}

{title:Description}

{pstd}
{cmd:pvenn} produces proportioned and positioned Venn diagrams, 
supporting 2-circle and 3-circle Venn diagrams, as well as 1-circle diagram. {cmd:pvenn} can also draw a rectangle 
outside all circles to proportionally represent the total population size, when it is possible. 
Proportional Venn diagrams attempts to make each of the zones (the circles, the outside rectangle, and the set intersections) proportional
 to the population (value) assigned to the zone. Note that, the overlap regions 
of 3-circle Venn diagrams are not always to scale, because an 
ideal solution is generally not possible using circles. 

{pstd}
There are two ways to use {cmd:pvenn}:

{pstd}
{cmd:1. Generating Venn diagrams from dataset:} {cmd:pvenn} can draw Venn diagrams from one, two, or three variables. 
The variables must only have value of 0 and 1, where 1 means positive observation and 0 means negative observation. 
With one variable specified, a 1-circle diagram will be created to show the size of positive observations, and if drawtotal(1) is specified, 
an outside rectangle would be drawn to propotionally represent the relative size of total population to the size of positive ones. 
With two or three variables specified, 2-circle or 3-circle proportional Venn diagrams can be created. For example in the dataset below,

  . list popA popB popC
     +-----------------------+
     |   popA   popB   popC  |
     |-----------------------|
  1. |      1      0      0  |
  2. |      1      1      1  |
  3. |      0      1      1  |
  4. |      0      0      0  |
  5. |      1      0      1  |
     +-----------------------+
	 
{pstd}
Observation 1 belongs to population A but not population B or C; {p_end}
{phang}
Observation 5 belongs to population A and C but not population B;{p_end}
{phang}
total population = 5;{p_end}
{phang}
population A = 3;{p_end}
{phang}
population B = 2;{p_end}
{phang}
population C = 3;{p_end}
{phang}
overlap population A/B = 1;{p_end}
{phang}
overlap population A/C = 2;{p_end}
{phang}
overlap population B/C = 2;{p_end}

{pstd}
Observations with missing values are dropped.

{pstd}
{cmd:2. Generating Venn diagrams from manual inputs:} When no variable is specified, {cmd:pvenn} can draw Venn diagrams using {it:manual_mode_opts}.
In the above example,

{pstd}
. pvenn popA popB popC {p_end}
{phang}
is equivalent to {p_end}
{phang}
. pvenn, plabel(popA popB popC) pA(3) pB(2) pC(3) pAB(1) pAC(2) pBC(2) ptotal(5)

{title:Options Generating Venn diagrams from manual inputs}

{dlgtab:Main}

{phang}
The {it:manual_mode_opts} options are functional only when no variable is specified.

{phang}
{opt plabel}(lblname [lblname ...]) specifies a list of label names for the populations. Minimum 1 and maximum 3 labelnames should be specified.

{phang}
{opt pA}(#) specifies the size of population A; default is 0. If pA(0), circle A is not drawn.

{phang}
{opt pB}(#) specifies the size of population B; default is 0. If pB(0), circle B is not drawn.

{phang}
{opt pC}(#) specifies the size of population C; default is 0. If pC(0), circle C is not drawn.

{phang}
{opt pAB}(#) specifies the size of overlap between population A & B; default is 0.

{phang}
{opt pAC}(#) specifies the size of overlap between population A & C; default is 0.

{phang}
{opt pBC}(#) specifies the size of overlap between population B & C; default is 0.

{phang}
{opt ptotal}(#) specifies the size of total population; default is 0. If {opt ptotal(0)} is specified, outside rectangle is not drawn.

{title:Options}

{dlgtab:Main}

{phang}
{opt ang}(#) specifies the angle between the connecting lines of circle A/B center and the X axis, that is the relative location of circle B to circle A; default is 0.

{phang}
{opt pos}(#) specifies the relative location of circle C to circle A & B; default is 1. 
{opt pos(1)} circle C is drawn clockwise to the circle A & B; {opt pos(-1)} circle C is drawn counterclockwise to the circle A & B.

{phang}
{opt lc}({help colorstyle}list) specifies a line color for each circle and rectangle; default is "cranberry emerald brown lavender". 
The sequence is circleA, circleB, circleC, and outside rectangle. Use . to skip an item in the list.

{phang}
{opt lp}({help linepatternstyle}list) specifies a line pattern for each circle and rectangle; default is "solid solid solid solid".
The sequence is circleA, circleB, circleC, and outside rectangle. Use . to skip an item in the list.

{phang}
{opt lw}({help linewidthstyle}list) specifies a line widths for each circle and rectangle; default is "0.8 0.8 0.8 0.8".
The sequence is circleA, circleB, circleC, and outside rectangle. Use . to skip an item in the list.

{phang}
{opt drawtotal(1)} draw a rectangle outside all circles to represent the total population size; default is 1. {opt drawtotal(0)} suppress the draw.

{phang}
{opt drawlabel(1)} draw labels in circles indicating names of the populations; default is 1. {opt drawlabel(0)} suppress the display of labels.

{phang}
{opt n}(#) specify the points (#*2) used to draw a circle; default is 20000. Refer to help {help twoway_function}.

{phang}
{opt {help twoway_options}} specifies additional twoway options (not all of them area allowed), for example titles() and notes().


{title:Examples}

{pstd}
{cmd:1. Generating Venn diagrams from dataset:}

{pstd}
The examples below highlight the use of the {hi: pvenn} plot on the nlsw88 dataset, which is pre-installed with Stata software. 

{pstd}
Click below to load dataset 

{phang} 
{stata sysuse nlsw88}

{pstd}
Click below (after the dataset is loaded) to see the intersections among "never married" "college graduate" and "lives in south".

{phang}
{stata pvenn never_married collgrad south} {p_end}
{phang}
{stata pvenn never_married collgrad south, ang(30) drawtotal(0) pos(-1)} {p_end}
{phang}
{stata pvenn never_married collgrad south, drawtotal(1) lc("black" "red") lw(0.1 0.3 0.5 0.8) lp("_" "." "dash_dot" "-")} {p_end}

{pstd}
Click below to see the intersections among "married" "lives in south" and "lives in central city".

{phang}
{stata pvenn married south c_city} {p_end}
{phang}
In this case, total population cannot be represented as an outside rectangle. {p_end}

{pstd}
{cmd:2. Generating Venn diagrams from manual inputs:}

{phang}
1-circle diagram: {p_end}
{phang}
{stata pvenn, pA(10) pB(0) pC(0) pAB(0) pAC(0) pBC(0) ang(30) ptotal (30) drawtotal(1) pos(-1) plabel("Max" "Jan" "Winston")} {p_end}
{phang}
2-circle Venn diagram: {p_end}
{phang}
{stata pvenn, pA(10) pB(0) pC(30) pAB(0) pAC(3) pBC(0) ang(30) drawtotal(1) pos(-1) plabel("Max" "Jan" "Winston")} {p_end}
{phang}
{stata pvenn, pA(10) pB(30) pC(0) pAB(0) pAC(0) pBC(3) ang(30) drawtotal(1) pos(-1) plabel("Max" "Jan" "Winston")} {p_end}
{phang}
3-circle Venn diagram: {p_end}
{phang}
{stata pvenn, pA(10) pB(30) pC(20) pAB(4) pAC(5) pBC(3) ang(30) ptotal(90) drawtotal(0) pos(1) plabel("Max" "Jan" "Winston") title(Example)} {p_end}
{phang}
{stata pvenn, pA(45) pB(25) pC(50) pAB(18) pAC(5) pBC(3) ang(120) drawtotal(1) pos(-1) drawlabel(0) plabel("Max" "Jan" "Winston") title(Example)} {p_end}
{phang}
{stata pvenn, pA(10) pB(30) pC(20) pAB(0) pAC(0) pBC(3) ang(30) drawtotal(1) pos(-1)  plabel("Max" "Jan" "Winston") title(Example)} {p_end}

{title:Authors}

{pstd}
Wenfeng (Winston) Gong & Jan Osterman; {p_end}
{phang}
Center for Health Policy and Inequity Research at Duke University, Durham, NC.

{pstd}
Email {browse "mailto:gongwenf@gmail.com":gongwenf@gmail.com}




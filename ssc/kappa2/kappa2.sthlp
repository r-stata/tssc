{smcl}
{* *! version 1.0.0  15sep2008}{...}
{cmd:help kappa2}
{hline}

{title:Title}

{p 4 8 2}
{bf: kappa2 --  Generalizations of weighted kappa for incomplete designs}


{title:Syntax}

{phang}
Interrater agreement, nonunique raters, variables record ratings for each rater

{p 8 14 2}
{cmd:kappa2} {it:{help varname:varname1}} {it:varname2}
{it:varname3} [{it:...}] {ifin} [{cmd:,} {it:{help kappa2##options:options}}]


{synoptset 14 tabbed}{...}
{marker options}{...}
{synopthdr}
{synoptline}
{syntab :Main}
{synopt :{opt t:ab}}display table of assessments (available for two raters only) {p_end}
{synopt :{opt w:gt(wgtid)}}specify how to weight disagreements; see 
          {help kappa2##Options:Options} for alternatives{p_end}
{synopt :{opt a:bsolute}}treat rating categories as absolute{p_end}
{synopt :{opt m:ajority}}the agreement is defined as majority or consensus{p_end}
{synopt :{opt j:ackknife}}compute jackknifed standard errors and display additional statistics{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}


{title:Dialog box}

{pstd}
There is a graphical dialog box from which this command may be used. It can be accessed with the {cmd:db kappa2} command.

{title:Add this command to the Stata user menu}

{pstd}
If you wish to add the command to the Stata menu, please execute the following command (you might add it to you user profile.do that it gets executed every time you start Stata):
{cmd:window menu append item "stUserStatistics" "&Weighted kappa for incomplete designs" "db kappa2"}.
Then you must execute 
{cmd:window menu refresh}.
This will add the Kappa2 option to the User > Statistics

{title:Description}

{pstd}
{cmd:kappa2} is a generalization of the kappa coefficient to allow using weights and an explicit agreement 
definition for multiple raters and incomplete designs. Computations are done using formulae proposed by 
{browse "http://www.idescat.cat/sort/questiio/questiiopdf/23.3.8.Abraira.pdf":Abraira V.} In the particular 
case of unweighted kappa, {cmd: kappa2} would reduce to the standard {help kappa:kappa} Stata command, 
although slight differences could appear because the standard {help kappa:kappa} Stata command uses 
approximated formulae (see [R] kappa).

{pstd}
{cmd:kappa2}  calculates the kappa-statistic measure of interrater agreement when
there are two ore more unique raters and two or more ratings. It assumes that each 
observation is a subject. {it:{help varname:varname1}} contains the ratings 
by the first rater, {it:varname2} by the second rater, and so on.

{pstd}
To facilitate the use of this command, its syntax is an extension of the standard {help kappa:kappa} command, and hence {cmd:kappa2} 
has the same options than {help kappa:kappa} but it includes some new ones. This help document copies the standard {help kappa:kappa} help 
and introduces the novelties.


{marker Options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt tab} displays a tabulation of the assessments by the two raters.

{phang}
{opt wgt(wgtid)} specifies that {it:wgtid} be used to weight disagreements.
You can define your own weights by using {help kapwgt:kapwgt}; {opt wgt()} then
specifies the name of the user-defined matrix.  For instance, you might define

{phang3}
{cmd:. kapwgt mine 1 \ .8 1 \ 0 .8 1 \ 0 0 .8 1}

{pmore}
and then 

{phang3}
{cmd:. kappa2 rata ratb, wgt(mine)}

{pmore}
Also two prerecorded weights are available.

{pmore}
{cmd:wgt(w)} specifies weights 1-|i-j|/(k-1),
  where i and j index the rows and columns of the ratings by the two
  raters and k is the maximum number of possible ratings.

{pmore}
{cmd:wgt(w2)} specifies weights 1 - {c -(}(i-j)/(k-1){c )-}^2.

{phang}
{cmd:absolute} is relevant only if {opt wgt()} is also specified.  Option 
{opt absolute} modifies how i, j, and k are defined and how corresponding
entries are found in a user-defined weighting matrix.  When {opt absolute} is
not specified, i and j refer to the row and column index, not to the ratings
themselves.  Say that the ratings are recorded as {c -(}0,1,3,4{c )-}.  There
are four ratings; k=4, and i and j are still 1, 2, 3, 4 in the formulas above.
Index 2, for instance, corresponds to rating=1.  This system is convenient
but can, with some data, lead to difficulties.

{pmore}
When {opt absolute} is specified, all ratings must be integers, and they
  must be coded from the set {c -(}1,2,3,...{c )-}.  Not all values need be
  used; integer values that do not occur are simply assumed to be unobserved.


{phang}
{cmd:majority} displays majority agreement. In a study with multiple raters,
agreement among raters can be alternatively defined as majority; there is
agreement at an observation if a predefined majority of observers agree; e.g., if there are
seven observers, it is possible to define agreement when at least five (or six) of them agree.
{browse "http://www.idescat.cat/sort/questiio/questiiopdf/23.3.8.Abraira.pdf":Abraira V, Pérez de Vargas A. {it: Qüestiió} (1999) 23: 561-571.}


{phang}
{cmd:jackknife} displays additional statistics. With this option, the program calculates
the jackknife estimate of kappa index, its jackknife standard error and the 95% confidence
interval.


{title:Remarks}

{pstd}
You have data on individual patients.  There are two raters, and the possible 
ratings are 1, 2, 3, and 4, but neither rater ever used rating 3
Here {cmd:kappa2} would determine that the ratings
are from the set {c -(}1,2,4{c )-} because those were the only values
observed.  {cmd:kappa2} would expect a user-defined weighting matrix would be 3x3
and, if it were not, {cmd:kappa2} would issue an error message.  In the
formula-based weights, {cmd:wgt(w)} and {cmd:wgt(w2)}, the calculation would be
based on i,j = 1,2,3 corresponding to the three observed ratings 
{c -(}1,2,4{c )-}.

{pstd}
Specifying the {cmd:absolute} option would make it clear that the ratings are
1, 2, 3, and 4; it just so happens that rating==3 was never assigned.  If a 
user-defined weighting matrix were also specified, {cmd:kappa2} would expect it
to be 4x4 or larger (larger because one can think of the ratings being 1, 2,
3, 4, 5, ... and it just so happens that ratings 5, 6, ... were never
observed, just as rating==3 was not observed).  In the formula-based weights,
the calculation would be based on i,j = 1,2,4.

{pstd}
If all conceivable ratings are observed in the data, specifying
{cmd:absolute} makes no difference.


{title:Example: weighted kappa in an incomplete design with multiple raters}

{pstd}
Agreement among 6 dermatologists assessing scleroderma using 4 ordinal categories (no scleroderma, 
slight scleroderma, moderate scleroderma, atrophic skin).
{browse "http://www.idescat.cat/sort/questiio/questiiopdf/23.3.8.Abraira.pdf":Abraira V, Pérez de Vargas A. {it: Qüestiió} (1999) 23: 561-571.}

{center:      {c |}  med1     med2     med3     med4     med5     med6}
{center:{hline 5}{c +}{hline 50}}
{center: obs1 {c |}    4        .       .        4        .        4  }
{center: obs2 {c |}    .        .        4       4        2        .  }
{center: obs3 {c |}    .        .        3       3        .        3  }
{center: obs4 {c |}    3        .        3       .        2        .  }
{center: obs5 {c |}    1        .        .       .        1        1  }
{center: obs6 {c |}    1        1        1       .        .        .  }
{center: obs7 {c |}    .        3        4       .        .        3  } 
{center: obs8 {c |}    .        1        .       .        1        1  } 
{center: obs9 {c |}    2        2        .       3        .        .  } 
{center: obs10{c |}    .        1        .       1        2        .  }


{phang2}{cmd:. kappa2 med1-med6} {space 25} (Pairwise agreement){p_end}
{phang2}{cmd:. kappa2 med1-med6, jackknife} {space 14} (Pairwise agreement with jackknifed estimates){p_end}
{phang2}{cmd:. kappa2 med1-med6, majority(3) } {space 12} (Majority agreement of 3){p_end}
{phang2}{cmd:. kappa2 med1-med6, wgt(w) jackknife }	 {space 7} (weighted agreement with jackknifed estimates){p_end}


{title:Saved results}

{pstd}
{cmd:kappa2} save the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of subjects{p_end}
{synopt:{cmd:r(prop_o)}}observed proportion of agreement {p_end}
{synopt:{cmd:r(prop_e)}}expected proportion of agreement {p_end}
{synopt:{cmd:r(kappa)}}kappa{p_end}
{p2colreset}{...}

In addition, when {opt majority} is specified,{cmd:kappa2} save estimation results in {cmd:e()}


{title:References}

{pstd}
Abraira V, Pérez de Vargas A. Generalization of the kappa coefficient for ordinal categorical data, 
multiple observers and incomplete designs. {it: Qüestiió} (1999) 23: 561-571). {browse "http://www.idescat.cat/sort/questiio/questiiopdf/23.3.8.Abraira.pdf": http://www.idescat.cat/sort/questiio/questiiopdf/23.3.8.Abraira.pdf}

{pstd}
Abraira V. Precisión de las clasificaciones clínicas. Doctoral Thesis. Complutense University of Madrid. Spain. {browse "http://www.ucm.es/eprints/4168/": http://www.ucm.es/eprints/4168/}

{pstd}
J Lázaro, J Zamora, V Abraira. Implementación de dos generalizaciones del índice kappa. 3ª Reunión Española de Usuarios de Stata Sep 2010: Madrid

{title:Acknowledgment}

{pstd}
The development of this macro has been funded by a specific funding action from CIBER 
de Edidemiología y Salud Pública (CIBERESP) Spain (PM08/008).

{pstd}
We want to thank Dr. Emparanza and Dr. Pijoan for their valuable comments and for testing the final macro.


{title:Authors}

{pstd}
Javier Lázaro, Javier Zamora & Víctor Abraira.
Clinical Biostatistics Unit, Hospital Ramón y Cajal. Madrid. Spain.
CIBER de Edidemiología y Salud Pública (CIBERESP). Spain. 

{pstd} Alexander Zlotnik (GUI, dialog box and minor changes to kappaAux.do)
Department of Electronic Engineering. Universidad Politécnica de Madrid. Spain.

{title:Also see}

{psee}
Manual:  {bf:[R] kappa}



{smcl}
{* *! version 1.0.2 11 July 2019}{...}
{* *! version 1.0.1 2 April 2019}{...}

{title:Title}
{phang}
{bf:bcss} {hline 2}  a command to create graphs to show how baseline data (prospective or retrospective) affect sample size for a cluster randomised trial.

{marker syntax}{...}
{title:Syntax}
{phang}
Prospective data collection:

{p 8 17 2}
{cmdab:bcss},
{opt pi:list(numlist)}
{opt r:ho(#)} 
{opt pro:spective}
{opt t:otal(#)}
[{it:other_options}]

{phang}
Retrospective data collection:

{p 8 17 2}
{cmdab:bcss},
{opt pi:list(numlist)}
{opt r:ho(#)} 
{opt ret:rospective}
{opt e:ndline(#)}
[{it:other_options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt pi:list(numlist)}}  specifies the ranges of pi (cluster autocorrelation): the correlation between the underlying cluster population means at baseline and endline.

{pstd}
{p_end}
{synopt:{opt r:ho(#)}}  the intra-cluster correlation (ICC).

{pstd}
{p_end}
{synopt:{opt pro:spective}}  specified when prospective baseline data collection is required.

{pstd}
{p_end}
{synopt:{opt t:otal(#)}}  the cluster size (n_b+n_e) when prospective data collection is selected, where n_b is the number of baseline measurements and n_e is the number of endline measurements from each cluster.

{pstd}
{p_end}
{synopt:{opt ret:rospective}}  specified when retrospective baseline data collection is required.

{pstd}
{p_end}
{synopt:{opt e:ndline(#)}}  the cluster size (n_e) when retrospective data collection is selected (the baseline data of size n_b is already collected before the trial).

{syntab:Prospective options}
{pstd}
{p_end}
{synopt:{opt propx:axis(numlist min=2  max=2)}}  the min and max ranges of the x axis for prospective baseline data graphs (proportions).

{pstd}
{p_end}
{synopt:{opt propy:axis(numlist min=2  max=2)}}  the min and max ranges of the y axis for prospective baseline data graphs.

{pstd}
{p_end}
{synopt:{opt propys:tep(numlist max=1)}}  the step on the y axis for prospective baseline data graphs.

{syntab:Retrospective options}
{pstd}
{p_end}
{synopt:{opt retx:axis(numlist min=2  max=2)}}  the min and max ranges of the x axis for retrospective baseline data graphs (ratios).

{pstd}
{p_end}
{synopt:{opt rety:axis(numlist min=2  max=2)}}  the min and max ranges of the y axis for retrospective baseline data graphs.

{pstd}
{p_end}
{synopt:{opt retys:tep(numlist max=1)}}  the step on the y axis for retrospective baseline data graphs.

{syntab:General options}
{pstd}
{p_end}
{synopt:{opt leg:endoptions(string)}}  user defined legend options, such as position and size.

{pstd}
{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
 {cmd:bcss} displays graphs examining the impact of varying the amount of prospective/retrospective baseline data collection on the number of clusters required in a cluster randomised trial 
 with different cluster autocorrelation and intra-cluster correlation values.
 See {help bcss##CopasHooper:Copas and Hooper} for details.
 
{pstd}
 The user must specify either prospective (and total) or retrospective (and endline) in the syntax for prospective or retrospective baseline data collection respectively.
 
{pstd}
Prospective baseline data are measurements taken as part of the trial, retrospective baseline data are measurements already taken which are not included therefore in the sample size for the trial.

{pstd}
 The x axes values on the prospective data graphs are proportions.

{pstd}
 The x axes values on the retrospective data graphs are ratios.

{pstd}
 The user can choose to change the graph axes, however if one axis range is specified then the corresponding axis must also be specified (e.g. if the user selects certain x axis values, then they must also select the corresponding y axis values).
Either all or none of the axis options must be specified.

{pstd}
The legend position and size can be changed by the user, using standard legend syntax within legendoptions().

{pstd}
 Theta opt is the optimum proportion of baseline measurements to maximise power, shown on the prospective data graphs as θ_opt=(mρπ+ρ-1)/[ρm(1+π)] where m = "total cluster size" = n_b+n_e
 
{pstd}
 Please note that it is not advisable to set pi or rho at the boundary values (e.g. 1) for these graphical representations.



{marker examples}{...}
{title:Examples}
{pstd}

{pstd}
  bcss, pi(0.5 0.6 0.7) rho(0.01) pro total(200) propxaxis(0 0.5) propyaxis(1 1.25) propystep(0.05)

{pstd}
   bcss, pi(0.5 0.6 0.7) rho(0.01) ret endline(200) retxaxis(0 2) retyaxis(0 1) retystep(0.1)
    
{pstd}
   with user defined legend options:
      
{pstd}
   bcss, pi(0.5 0.6 0.7) rho(0.01) pro total(200) propxaxis(0 0.5) propyaxis(1 1.25) propystep(0.05) leg(pos(5) size(small))


{title:References}
{pstd}

{pstd}{marker CopasHooper}
Copas AJ and Hooper R. Cluster randomised trials with different numbers of measurements at baseline and endline: Sample size and optimal allocation. Clinical Trials {browse "https://journals.sagepub.com/doi/full/10.1177/1740774519873888"}


{title:Author}
{pstd}

Ella Marley-Zagar, MRC Clinical Trials Unit, University College London.

Email {browse "mailto:e.marley-zagar@ucl.ac.uk":e.marley-zagar@ucl.ac.uk}


{title:Further note: installation from Github}
{pstd}

Please note the latest version of bcss can be found at {browse "https://github.com/UCL/bcss/"}

The bcss.ado file can be installed within Stata directly from github by typing:

net install github, from("https://haghish.github.io/github/")
github install UCL/bcss



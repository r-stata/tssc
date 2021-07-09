{smcl}
{* Copyright 2007-2012 Brendan Halpin brendan.halpin@ul.ie }
{* Distribution is permitted under the terms of the GNU General Public Licence }
{* 17June2012}{...}
{cmd:help sadi}
{hline}

{title:Title}

{p2colset 5 17 23 2}{...}
{p2col:{hi:sadi} {hline 2}}Sequence analysis distance measures and utilities{p_end}
{p2colreset}{...}

{title:Description}

{pstd}{cmd:sadi} is a package of tools for sequence analysis. It
provides a range of distance measures, including Hamming, standard OM,
Hollister's localised OM, Halpin's duration-adjusted OM, Time-Warp Edit
Distance, and a duration-weighted version of Elzinga's Number of Common
Subsequences measure. It also provides a number of utilities.

{pstd}Several of the distance measures are coded using C plugins, for
speed. These are faster than Mata but less portable. On some platforms
the plugins will not work. Please let me know if you have problems in
this regard. 

{pstd}Some of the distance measures deal with duplicates efficiently
(i.e., by not re-estimating the distances redundantly). This facility
requires the mata function {cmd:mm_expand()} from Ben Jann's
{cmd:moremata} package. You can install this by doing {cmd:ssc install
moremata}.

{title:Author}

{pstd}Brendan Halpin, brendan.halpin@ul.ie{p_end}


{title:Also see}

{psee}Distance measures: {p_end}
{col 5}{bf:{help hamming}}{...}
{col 20}Hamming distance
{col 5}{bf:{help oma}}{...}
{col 20}Optimal Matching Algorithm
{col 5}{bf:{help omav}}{...}
{col 20}Halpin's duration-adjusted OM
{col 5}{bf:{help hollister}}{...}
{col 20}Hollister's "Localised OM"
{col 5}{bf:{help dynhamming}}{...}
{col 20}An implementation of Lesnard's Dynamic Hamming measure
{col 5}{bf:{help twed}}{...}
{col 20}Time-Warp Edit Distance
{col 5}{bf:{help combinadd}}{...}
{col 20}Elzinga's number of common subsequences measure, duration-weighted

{psee}Utilities: {p_end}
{col 5}{bf:{help combinprep}}{...}
{col 20}Change data from wide calendar to wide spell format (needed for {cmd:combinadd})
{col 5}{bf:{help trans2subs}}{...}
{col 20}Generate substitution costs for OM and related distances based on observed transition rates
{col 5}{bf:{help maketrpr}}{...}
{col 20}Calculate smoothed time-dependent transition rates (needed for {cmd:dynhamming})
{col 5}{bf:{help stripe}}{...}
{col 20}Generates a string representation of the sequence
{col 5}{bf:{help metricp}}{...}
{col 20}Tests distance matrices for the triangle inequality
{col 5}{bf:{help permtab}}{...}
{col 20}Compare two cluster solutions by permuting one to maximise the agreement (very slow for >10 class solutions)
{col 5}{bf:{help permtabga}}{...}
{col 20}A version of {cmd:permtab} appropriate for larger cluster solutions (uses genetic algorithm)
{col 5}{bf:{help ari}}{...}
{col 20}Calculate the Adjusted Rand Index of agreement between two cluster solutions
{col 5}{bf:{help corrsqm}}{...}
{col 20}Calculate the correlation between two distance matrices
{col 5}{bf:{help nspells}}{...}
{col 20}Calculate the number of spells in a sequence
{col 5}{bf:{help cumuldur}}{...}
{col 20}Calculate the cumulative duration in each state
{col 5}{bf:{help entropy}}{...}
{col 20}Calculate the Shannon entropy of a sequence 

{psee}Visualisation: {p_end}
{col 5}{bf:{help chronogram}}{...}
{col 20}Graph the time-dependent state distribution
{col 5}{bf:{help trprgr}}{...}
{col 20}Graph the time-dependent structure of transitions
{col 5}{bf:{help sqindexplot}}{...}
{col 20}SADI doesn't do indexplots, since it is hard to beat {help sqindexplot} from {search SQOM}

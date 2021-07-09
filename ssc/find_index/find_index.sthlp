{smcl}
{*2019may19; 2020jun02}
{hline}
help for {hi:find_index}
{hline}

{title:Determine the index (observation number) of an observation that satisfies a specified condition.}

{title:Syntax}

{p 8 10 2}
{cmd:find_index if} {help exp}, [{opt low} {opt high} {opt verbose} {opt debug}]

{synoptset 20 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt:{opt low}}Return the lowest index value, if there are a multitude.{p_end}
{synopt:{opt high}}Return the highest index value, if there are a multitude.{p_end}
{synopt:{opt verbose}}Display the resulting value.{p_end}
{synopt:{opt debug}}A synonym for verbose.{p_end}

{title:Remarks}

{p 4 4 2}
Note that the {cmd:if} {it:exp} qualifier is required.

{p 4 4 2}
This command returns the observation number (the index) of the observation that
satisfies {it:exp}. By default, it requires that there be a unique observation that
satisfies {it:exp}, but the {cmd:low} and {cmd:high} options loosen this requirement.

{p 4 4 2}
If there are more than one observations that satisfy {it:exp}, then...{p_end}
{p 6 6 2}with the {cmd:low} option, the lowest observation number is returned;{p_end}
{p 6 6 2}with the {cmd:high} option, the highest observation number is returned;{p_end}
{p 6 6 2}in the absence of the {cmd:low} or {cmd:high} options, an error condition will occur.{p_end}

{p 4 4 2}
If there are no observations that satisfy {it:exp}, then an error condition will occur,
regardless of any options.

{p 4 4 2}
The resulting value is returned in r(index).

{title:Examples}

{col 5}{hline}
{phang2}{cmd:. find_index if `age'== `age_low'}{p_end}
{phang2}{cmd:. local age_low_index = r(index)}{p_end}
{phang2}{cmd:. find_index if `age'== `age_high', `debug'}{p_end}
{phang2}{cmd:. local age_high_index = r(index)}{p_end}
{phang2}  ...{p_end}
{phang2}{cmd:. assert `age' == (_n + `age_low' - `age_low_index') in `age_low_index' / `age_high_index'}{p_end}
{phang2}  ...{p_end}
{phang2}{cmd:. gen double `U' = sum(`intergrandU') in `age_low_index' / `age_high_index'}{p_end}
{phang2}{cmd:. return scalar utility = `U'[`age_high_index']}{p_end}
{col 5}{hline}
{phang2}{cmd:. find_index if emplid == 3015987}{p_end}
{phang2}{cmd:. local emplid_index_3015987 = r(index)}{p_end}
{phang2}{cmd:. disp "emplid 3015987 name: " name[`emplid_index_3015987']}{p_end}
{col 5}{hline}


{title:Author}
{p 4 4 2}
David Kantor
Email {browse "mailto:kantor.d@att.net":kantor.d@att.net}

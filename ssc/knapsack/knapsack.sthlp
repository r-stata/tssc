{smcl}
{* Dec 31st 2018}
{hline}
Help for {hi:knapsack}
{hline}

{title:Description}

{p}{cmd:knapsack} implements a solution for the 0/1 Knapsack Problem as described {browse "http://www.es.ele.tue.nl/education/5MC10/Solutions/knapsack.pdf":here}.
Given a total budget as input, with data containing each potential item's cost and value, {cmd:knapsack} returns the maximum possible total value that can be purchased using the budget.
If {opt gen:erate()} is specified, a new variable is created containing 1 if the item is in the optimal set and 0 if it is not.

{title:Syntax}

{p}{cmd:knapsack} {it:budget} , {opt p:rice(varname)} {opt v:alue(varname)} [{opt gen:erate(newvarname)}]

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{title:Contributing}

{p}{bf: knapsack} is open for development on {browse "https://bbdaniels.github.io/stata-code/knapsack/":GitHub}.
Submit bugs and feature requests {browse "https://github.com/bbdaniels/knapsack/issues":here}.
If you like {bf:knapsack}, be sure to visit my {browse "http://bbdaniels.github.io":homepage}
and {browse "https://gist.github.com/bbdaniels/a3c9f9416f1d16d6f3c6e8cf371f1d89":Stata boilerplate code}.{p_end}

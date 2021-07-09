{smcl}
{* 17sep2017}{...}
{cmd:help block_ra}{right:Version 1.8}
{hline}

{title:Title}

{pstd}
{hi:block_ra} {hline 2} implements a random assignment procedure in which units that are 
grouped into blocks defined by pre-treatment covariates are assigned using complete random assignment within block. 
{p_end}

{marker syntax}{title:Syntax}

{pstd} 
{cmd:block_ra} [{it:treatvar}] {cmd:, }
{opt block_var:(var)}
[{opt block_m:(numlist)}
{opt block_m_each:(matrix)}
{opt block_prob_each:(matrix)}
{opt block_prob:(numlist)}
{opt m:(num)}
{opt prob:(num)}
{opt prob_each:(numlist)}
{opt num_arms:(num)}
{opt condition_names:(string)}
{opt replace}
{opt skip_check_inputs}]

{marker desc}{title:Description}

{pstd} {cmd:block_ra} implements a random assignment procedure in which units that are grouped into blocks defined by pre-treatment covariates are assigned using complete 
random assignment within block. For example, imagine that 50 of 100 men are assigned to treatment and 75 of 200 women are assigned to treatment.

{marker opt}{title:Options}

{pstd} {it: treatvar} The name of the treatment variable, you want this command to generate. If left unspecified the resulting variable is called "assignment" by default. {p_end}

{pstd} {opt block_var:(var)} An existing variable that indicates which block each unit belongs to. Can be a string or numeric variable. {p_end} 

{pstd} {opt m:(num)} Use for a two-arm design in which the scalar m describes the fixed number of units to assign in each block. This number does not vary across blocks. {p_end} 

{pstd} {opt block_m:(numlist)} Use for a two-arm design in which the numlist block_m describes the number of units to assign to treatment within each block. block_m must be a numeric list 
that is as long as the number of blocks. {p_end} 

{pstd} {opt block_m_each:(matrix)} Use for a multi-arm design in which the values of block_m_each determine the number of units assigned to each condition. 
block_m_each must be a matrix with the same number of rows as blocks and the same number of columns as treatment arms. Cell entries are the number of units to be 
assigned to each treatment arm within each block. The rows should respect the ordering of the blocks as determined by a tabulate command. The columns should 
be in the order of condition_names, if specified. {p_end} 

{pstd} {opt block_prob_each:(matrix)} Use for a multi-arm design in which the values of block_prob_each determine the probabilties of assignment to each treatment condition. 
block_prob_each must be a matrix with the same number of rows as blocks and the same number of columns as treatment arms. Cell entries are the probabilites of assignment to treatment 
within each block. The rows should respect the ordering of the blocks as determined by a tabulate command. 
Use only if the probabilities of assignment should vary by block, otherwise use prob_each. Each row of block_prob_each must sum to 1.
{p_end} 

{pstd} {opt block_prob:(numlist)} Use for a two-arm design in which block_prob describes the probability of assignment to treatment within each block. 
Differs from prob in that the probability of assignment can vary across blocks.{p_end} 

{pstd} {opt prob:(num)}  Use for a two-arm design in which either floor(N_block*prob) or ceiling(N_block*prob) units are assigned to treatment within each block. 
The probability of assignment to treatment is exactly prob because with probability 1-prob, floor(N_block*prob) units will be assigned to treatment and with probability prob, 
ceiling(N_block*prob) units will be assigned to treatment. prob must be a real number between 0 and 1 inclusive. {p_end} 

{pstd} {opt prob_each:(numlist)}  Use for a multi-arm design in which the values of prob_each determine the probabilties of assignment to each treatment condition. 
prob_each must be a list of numbers giving the probability of assignment to each condition. All entries must be nonnegative real numbers between 0 and 1 inclusive and 
the total must sum to 1. Because of integer issues, the exact number of units assigned to each condition may 
differ (slightly) from assignment to assignment, but the overall probability of assignment is exactly prob_each.{p_end}
 
{pstd} {opt num_arms:(num)} The number of treatment arms. If unspecified, num_arms will be determined from the other arguments.{p_end} 
{pstd} {opt condition_names:(string)} A string list giving the names of the treatment groups. If unspecified, the treatment groups will be named 0 (for control) and 1 (for treatment) 
in a two-arm trial and 1, 2, 3, in a multi-arm trial. 
An execption is a two-group design in which num_arms is set to 2, in which case the condition names are 1 and 2, as in a multi-arm trial with two arms.{p_end} 
{pstd} {opt replace} If treatvar exists in dataset, the command replaces it.{p_end}

{pstd} {opt skip_check_inputs} Suppress error checking.{p_end}


{marker ex}{title:Examples}

{pstd} {inp:. set obs 350 }{p_end}
{pstd} {inp:. gen block="A" in 1/50 }{p_end}
{pstd} {inp:. replace block="B" in 51/150 }{p_end}
{pstd} {inp:. replace block="C" if block=="" }{p_end}
{pstd} {inp:. block_ra, block_var(block) }{p_end}
{pstd} {inp:. block_ra, block_var(block) prob(.3) replace }{p_end}
{pstd} {inp:. block_ra, block_var(block) block_prob(.1 .2 .3) replace }{p_end}
{pstd} {inp:. block_ra, block_var(block) m(20) replace }{p_end}
{pstd} {inp:. block_ra, block_var(block) block_m(20 30 40) replace }{p_end}
{pstd} {inp:. block_ra, block_var(block) block_m_each(25, 25\50,50\100,100) replace }{p_end}
{pstd} {inp:. matrix define block_m_each=(10, 40\30,70\50,150) }{p_end}
{pstd} {inp:. block_ra, block_var(block) block_m_each(block_m_each) replace condition_names(control treatment) }{p_end}
{pstd} {inp:. block_ra, block_var(block) block_m_each(10, 20, 20\30,50,20\50,75,75) replace }{p_end}
{pstd} {inp:. block_ra, block_var(block) block_m_each(10, 20, 20\30,50,20\50,75,75) condition_names(control placebo treatment) replace }{p_end}
{pstd} {inp:. block_ra, block_var(block) prob_each(.1 .1 .8) replace }{p_end}


{title:Authors}

{pstd}John Ternovski{p_end}
{pstd} Alex Coppock {p_end}
{pstd} Yale University{p_end}
{pstd} {browse "mailto:john.ternovski@yale.edu":john.ternovski@yale.edu}{p_end}

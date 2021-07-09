[D] expand_n -- Duplicate and tag observations
              (View complete PDF manual entry)


Syntax

        expand_n exp [if] [in] , generate(newvar)


Description

    expand_n replaces each observation in the dataset with x copies of the observation, where x is equal to the required expression. If the expression is not a positive non-zero integer an error occurs.


Option

    generate(newvar) creates new variable newvar containing 1 if the observation originally appeared in the dataset and counts from there. For instance, after an expand_n, you could revert to the original observations by typing keep if newvar==1.


Examples

    ---------------------------------------------------------------------------------------------------------------------------------
    Setup
        . sysuse auto, clear

    List the original data
        . list

    Replace each observation with 2 copies of the observation (original observation is retained and 2 new observations are created, "dups" will be numbered 1-2 for each original observation)
        . expand_n 2, generate(dups)

    List the results
        . list

    ---------------------------------------------------------------------------------------------------------------------------------
    Setup
        . sysuse auto, clear

    List the original data
        . list

    Replace each observation with x copies of that observation, where x is the value of b for that observation and "dups" will be numbered 1-x for each original observation.
        . expand_n b, generate(dups)

    List the results
        . list

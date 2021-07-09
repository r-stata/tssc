// ngram has a lot of options, but not all are very useful.  For many uses "ngram varname" will suffice.
// This example demonstrates the more likely customizations.
//
// Stata isn't used too commonly for text-mining so this example is contrived.

// Setup
sysuse auto

// Set the locale to set the language of the dataset
set locale_functions en

// Extract unigrams through trigrams, *without* normalizing the tokens
ngram make, deg(3) nolower thresh(1)

// Inspect the results
desc
list make if t_VW

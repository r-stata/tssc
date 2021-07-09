// Setup
sysuse auto
set locale_functions en

// Extract n-grams, culling sparse parts with threshold()
ngram make, deg(3) thresh(5)

// Inspect the results
desc
list make if t_buick

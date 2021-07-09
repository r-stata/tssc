use german-pre-election-polls.dta, replace
qui surveybiasseries, samplevariables(cducsu spd linke gruene fdp other) ///
  nvar(n) popvalues(41.5 25.7 8.6 8.4 4.8 10.9) generate(g) desc 
save all-german-surveys , replace

* loading functions to do the ML estimation
	program define GGmixtureLEandUC_loglik     /* GG mixture model */
		args lnlik logitpi beta1 logsigma1 kappa1 beta2 logsigma2 kappa2 /*logitpi= log (pi/(1-pi)) logsigma1=log(sigma1) logsigma2=log(sigma2) */
		/* Parameters in args list the first is the output, the others are the inputs of the GGs 
		 the order of the parameters of the GGs should match to those defined in ml model */
		tempvar pi kappa1tom2 x1entry x1exit x1upperexit kappa2tom2 x2entry x2exit x2upperexit logf1exit logf2exit S1entry S1exit S2entry S2exit S1upperexit S2upperexit /*temporary variables*/
		quietly {
			 gen double `pi' = exp(`logitpi')/(1+exp(`logitpi'))
			 gen double `kappa1tom2' = (`kappa1')^(-2)
			 gen double `x1entry' = `kappa1tom2'*(exp(-(`beta1'))*$entrytime)^(`kappa1'/exp(`logsigma1'))
			 gen double `x1exit' = `kappa1tom2'*(exp(-(`beta1'))*$exittime)^(`kappa1'/exp(`logsigma1'))
			 gen double `x1upperexit' = `kappa1tom2'*(exp(-(`beta1'))*$upperexittime)^(`kappa1'/exp(`logsigma1'))
			 gen double `kappa2tom2' = (`kappa2')^(-2)
			 gen double `x2entry' = `kappa2tom2'*(exp(-(`beta2'))*$entrytime)^(`kappa2'/exp(`logsigma2'))
			 gen double `x2exit' = `kappa2tom2'*(exp(-(`beta2'))*$exittime)^(`kappa2'/exp(`logsigma2'))
			 gen double `x2upperexit' = `kappa2tom2'*(exp(-(`beta2'))*$upperexittime)^(`kappa2'/exp(`logsigma2')) 
			 
			 gen double `S1entry' = ( 1 - gammaptail(`kappa1tom2',`x1entry') ) if `kappa1'<0
			 replace    `S1entry' = ( gammaptail(`kappa1tom2',`x1entry') )     if `kappa1'>0
			 replace 	`S1entry' = (1-normal((log($entrytime)-`beta1')/exp(`logsigma1'))) if `kappa1'==0 & $entrytime>0
			 replace 	`S1entry'=1 if $entrytime==0
			 *replace 	`S1entry'=1 if `kappa1'==0 & $entrytime==0
			 gen double `S2entry' = ( 1 - gammaptail(`kappa2tom2',`x2entry') ) if `kappa2'<0
			 replace    `S2entry' = ( gammaptail(`kappa2tom2',`x2entry') )     if `kappa2'>0
			 replace 	`S2entry' = (1-normal((log($entrytime)-`beta2')/exp(`logsigma2'))) if `kappa2'==0 & $entrytime>0
			 *replace 	`S2entry'=1 if `kappa2'==0 & $entrytime==0
			 replace 	`S2entry'=1 if $entrytime==0
			 gen double `logf1exit' = log(abs(`kappa1'))-`logsigma1'-log($exittime)-lngamma(`kappa1tom2')+`kappa1tom2'*log(`x1exit')-`x1exit' if (($upperexittime==$exittime) & ($failureglobe==$comp1 | $failureglobe==$compu) & `kappa1'!=0)
			 replace 	`logf1exit' = -`logsigma1'-log($exittime)-0.5*log(2*3.1416)-0.5*(((log($exittime)-`beta1')/exp(`logsigma1'))^2) if (($upperexittime==$exittime) & ($failureglobe==$comp1 | $failureglobe==$compu) & `kappa1'==0)
			 gen double `logf2exit' = log(abs(`kappa2'))-`logsigma2'-log($exittime)-lngamma(`kappa2tom2')+`kappa2tom2'*log(`x2exit')-`x2exit' if (($upperexittime==$exittime) & ($failureglobe==$comp2 | $failureglobe==$compu) & `kappa2'!=0)
			 replace 	`logf2exit' = -`logsigma2'-log($exittime)-0.5*log(2*3.1416)-0.5*(((log($exittime)-`beta2')/exp(`logsigma2'))^2) if (($upperexittime==$exittime) & ($failureglobe==$comp2 | $failureglobe==$compu) & `kappa2'==0)
			 gen double `S1exit' = ( 1 - gammaptail(`kappa1tom2',`x1exit') ) if $upperexittime>$exittime & ($failureglobe==$comp1 | $failureglobe==$compu) & `kappa1'<0
			 replace    `S1exit' = ( gammaptail(`kappa1tom2',`x1exit') )     if $upperexittime>$exittime & ($failureglobe==$comp1 | $failureglobe==$compu) & `kappa1'>0
			 replace 	`S1exit' = (1-normal((log($exittime)-`beta1')/exp(`logsigma1'))) if $upperexittime>$exittime & ($failureglobe==$comp1 | $failureglobe==$compu) & `kappa1'==0
			 gen double `S2exit' = ( 1 - gammaptail(`kappa2tom2',`x2exit') ) if $upperexittime>$exittime & ($failureglobe==$comp2 | $failureglobe==$compu) & `kappa2'<0
			 replace    `S2exit' = ( gammaptail(`kappa2tom2',`x2exit') )     if $upperexittime>$exittime & ($failureglobe==$comp2 | $failureglobe==$compu) & `kappa2'>0
			 replace 	`S2exit' = (1-normal((log($exittime)-`beta2')/exp(`logsigma2'))) if $upperexittime>$exittime & ($failureglobe==$comp2 | $failureglobe==$compu) & `kappa2'==0
			 gen double `S1upperexit' = ( 1 - gammaptail(`kappa1tom2',`x1upperexit') ) if $upperexittime>$exittime & ($failureglobe==$comp1 | $failureglobe==$compu) & `kappa1'<0
			 replace    `S1upperexit' = ( gammaptail(`kappa1tom2',`x1upperexit') )     if $upperexittime>$exittime & ($failureglobe==$comp1 | $failureglobe==$compu) & `kappa1'>0
			 replace 	`S1upperexit' = (1-normal((log($upperexittime)-`beta1')/exp(`logsigma1'))) if $upperexittime>$exittime & ($failureglobe==$comp1 | $failureglobe==$compu) & `kappa1'==0
			 gen double `S2upperexit' = ( 1 - gammaptail(`kappa2tom2',`x2upperexit') ) if $upperexittime>$exittime & ($failureglobe==$comp2 | $failureglobe==$compu) & `kappa2'<0
			 replace    `S2upperexit' = ( gammaptail(`kappa2tom2',`x2upperexit') )     if $upperexittime>$exittime & ($failureglobe==$comp2 | $failureglobe==$compu) & `kappa2'>0
			 replace 	`S2upperexit' = (1-normal((log($upperexittime)-`beta2')/exp(`logsigma2'))) if $upperexittime>$exittime & ($failureglobe==$comp2 | $failureglobe==$compu) & `kappa2'==0
			 
			 replace `lnlik'   = ln( (`pi'*exp(`logf1exit')/(`pi'*`S1entry'+(1-`pi')*`S2entry')) )           if $upperexittime==$exittime & $failureglobe==$comp1
			 replace `lnlik'   = ln( ((1-`pi')*exp(`logf2exit')/(`pi'*`S1entry'+(1-`pi')*`S2entry')) )       if $upperexittime==$exittime & $failureglobe==$comp2
			 replace `lnlik'   = ln( ((`pi'*exp(`logf1exit')+(1-`pi')*exp(`logf2exit'))/(`pi'*`S1entry'+(1-`pi')*`S2entry')) ) if $upperexittime==$exittime & $failureglobe==$compu
			 replace `lnlik'   = ln( ((`pi'*(`S1exit'-`S1upperexit'))/(`pi'*`S1entry'+(1-`pi')*`S2entry')) )     if $upperexittime>$exittime & $failureglobe==$comp1
			 replace `lnlik'   = ln( (((1-`pi')*(`S2exit'-`S2upperexit'))/(`pi'*`S1entry'+(1-`pi')*`S2entry')) ) if $upperexittime>$exittime & $failureglobe==$comp2
			 replace `lnlik'   = ln( ((`pi'*(`S1exit'-`S1upperexit')+(1-`pi')*(`S2exit'-`S2upperexit'))/(`pi'*`S1entry'+(1-`pi')*`S2entry')) ) if $upperexittime>$exittime & $failureglobe==$compu
			 replace `lnlik'   = `lnlik'*$stweight	
			 }
	end

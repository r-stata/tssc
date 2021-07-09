program LNmixtureLEandUC_loglik     /* LN mixture model */
		args lnlik logitpi beta1 logsigma1 beta2 logsigma2 /*logitpi= log (pi/(1-pi)) logsigma1=log(sigma1) logsigma2=log(sigma2) */
		/* Parameters in args list the first is the output, the others are the inputs of the GGs 
		 the order of the parameters of the GGs should match to those defined in ml model */
		tempvar pi logf1exit logf2exit S1entry S1exit S1upperexit S2entry S2exit S2upperexit /*temporary variables*/
		quietly {
			 gen double `pi' = exp(`logitpi')/(1+exp(`logitpi'))
			 gen double `S1entry' = (1-normal((log($entrytime)-`beta1')/exp(`logsigma1'))) if $entrytime > 0
			 replace	`S1entry' = 1 if $entrytime==0
			 gen double `S2entry' = (1-normal((log($entrytime)-`beta2')/exp(`logsigma2'))) if $entrytime > 0
			 replace	`S2entry' = 1 if $entrytime==0
			 gen double `logf1exit' = -`logsigma1'-log($exittime)-0.5*log(2*3.1416)-0.5*(((log($exittime)-`beta1')/exp(`logsigma1'))^2)
			 gen double `logf2exit' = -`logsigma2'-log($exittime)-0.5*log(2*3.1416)-0.5*(((log($exittime)-`beta2')/exp(`logsigma2'))^2)
			 gen double `S1exit' = (1-normal((log($exittime)-`beta1')/exp(`logsigma1'))) 
			 gen double `S2exit' = (1-normal((log($exittime)-`beta2')/exp(`logsigma2')))
			 gen double	`S1upperexit' = (1-normal((log($upperexittime)-`beta1')/exp(`logsigma1')))
			 gen double	`S2upperexit' = (1-normal((log($upperexittime)-`beta2')/exp(`logsigma2')))
			 
			 replace `lnlik'   = ln( (`pi'*exp(`logf1exit')/(`pi'*`S1entry'+(1-`pi')*`S2entry')) )           if $upperexittime==$exittime & $failureglobe==$comp1
			 replace `lnlik'   = ln( ((1-`pi')*exp(`logf2exit')/(`pi'*`S1entry'+(1-`pi')*`S2entry')) )       if $upperexittime==$exittime & $failureglobe==$comp2
			 replace `lnlik'   = ln( ((`pi'*exp(`logf1exit')+(1-`pi')*exp(`logf2exit'))/(`pi'*`S1entry'+(1-`pi')*`S2entry')) ) if $upperexittime==$exittime & $failureglobe==$compu
			 replace `lnlik'   = ln( ((`pi'*(`S1exit'-`S1upperexit'))/(`pi'*`S1entry'+(1-`pi')*`S2entry')) )     if $upperexittime>$exittime & $failureglobe==$comp1
			 replace `lnlik'   = ln( (((1-`pi')*(`S2exit'-`S2upperexit'))/(`pi'*`S1entry'+(1-`pi')*`S2entry')) ) if $upperexittime>$exittime & $failureglobe==$comp2
			 replace `lnlik'   = ln( ((`pi'*(`S1exit'-`S1upperexit')+(1-`pi')*(`S2exit'-`S2upperexit'))/(`pi'*`S1entry'+(1-`pi')*`S2entry')) ) if $upperexittime>$exittime & $failureglobe==$compu
			 replace `lnlik'   = `lnlik'*$stweight	
			 }
	end

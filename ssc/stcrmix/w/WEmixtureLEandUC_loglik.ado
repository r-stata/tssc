program WEmixtureLEandUC_loglik     /* Weibull mixture model */
		args lnlik logitpi beta1 logsigma1 beta2 logsigma2 /*logitpi= log (pi/(1-pi)) logsigma1=log(sigma1) logsigma2=log(sigma2) */
		/* Parameters in args list the first is the output, the others are the inputs of the GGs 
		 the order of the parameters of the GGs should match to those defined in ml model */
		tempvar pi x1entry x1exit x1upperexit x2entry x2exit x2upperexit logf1exit logf2exit S1entry S1exit S2entry S2exit S1upperexit S2upperexit /*temporary variables*/
		quietly {
			 gen double `pi' = exp(`logitpi')/(1+exp(`logitpi'))
			 gen double `x1entry' = (exp(-(`beta1'))*$entrytime)^(1/exp(`logsigma1'))
			 gen double `x1exit' =  (exp(-(`beta1'))*$exittime)^(1/exp(`logsigma1'))
			 gen double `x1upperexit' = (exp(-(`beta1'))*$upperexittime)^(1/exp(`logsigma1'))
			 gen double `x2entry' = (exp(-(`beta2'))*$entrytime)^(1/exp(`logsigma2'))
			 gen double `x2exit' =  (exp(-(`beta2'))*$exittime)^(1/exp(`logsigma2'))
			 gen double `x2upperexit' = (exp(-(`beta2'))*$upperexittime)^(1/exp(`logsigma2'))
			 
			 gen double `S1entry' = exp(-`x1entry') 
			 gen double `S2entry' = exp(-`x2entry')
			 gen double `logf1exit' = -`logsigma1'-log($exittime)+log(`x1exit')-`x1exit' 
			 gen double `logf2exit' = -`logsigma2'-log($exittime)+log(`x2exit')-`x2exit'
			 gen double `S1exit' = exp(-`x1exit') 
			 gen double `S2exit' = exp(-`x2exit')
			 gen double `S1upperexit' = exp(-`x1upperexit') 
			 gen double `S2upperexit' = exp(-`x2upperexit')
			 
			 replace `lnlik'   = ln( (`pi'*exp(`logf1exit')/(`pi'*`S1entry'+(1-`pi')*`S2entry')) )           if $upperexittime==$exittime & $failureglobe==$comp1
			 replace `lnlik'   = ln( ((1-`pi')*exp(`logf2exit')/(`pi'*`S1entry'+(1-`pi')*`S2entry')) )       if $upperexittime==$exittime & $failureglobe==$comp2
			 replace `lnlik'   = ln( ((`pi'*exp(`logf1exit')+(1-`pi')*exp(`logf2exit'))/(`pi'*`S1entry'+(1-`pi')*`S2entry')) ) if $upperexittime==$exittime & $failureglobe==$compu
			 replace `lnlik'   = ln( ((`pi'*(`S1exit'-`S1upperexit'))/(`pi'*`S1entry'+(1-`pi')*`S2entry')) )     if $upperexittime>$exittime & $failureglobe==$comp1
			 replace `lnlik'   = ln( (((1-`pi')*(`S2exit'-`S2upperexit'))/(`pi'*`S1entry'+(1-`pi')*`S2entry')) ) if $upperexittime>$exittime & $failureglobe==$comp2
			 replace `lnlik'   = ln( ((`pi'*(`S1exit'-`S1upperexit')+(1-`pi')*(`S2exit'-`S2upperexit'))/(`pi'*`S1entry'+(1-`pi')*`S2entry')) ) if $upperexittime>$exittime & $failureglobe==$compu
			 replace `lnlik'   = `lnlik'*$stweight	
			 }
	end

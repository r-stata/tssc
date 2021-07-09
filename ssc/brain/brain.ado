cap program drop brain
program define brain, rclass
	version 9.0
	syntax anything(id="command") [if] [in], [Hidden(numlist)] [INput(varlist)] [Output(varlist)] [ITer(integer 0)] [Eta(real 0.25)] [Spread(real 0.5)] [RAW] [NOSort]
	token `"`anything'"'
	if length(`"`1'"') < 2 {
		di as error "invalid brain command"
		error 999
	}
	if `"`1'"' == substr("define",1,length(`"`1'"')) {
		if `"`input'"' == "" {
			di as error "no input variables specified"
			error 999
		}
		if `"`output'"' == "" {
			di as error "no output variables specified"
			error 999
		}
		local inp = wordcount(`"`input'"')
		local out = wordcount(`"`output'"')
		local hidden = `"`inp' `hidden' `out'"'
		token `"`hidden'"'
		local layer = ""
		local i = 1
		while "``i''" != "" {
			cap confirm integer number ``i''
			if _rc > 0 {
				di as error "invalid layer number"
				error 999
			}
			if ``i'' <= 0 {
				di as error "invalid layer definition"
				error 999
			}
			local layer = `"`layer',``i''"'
			local i = `i' + 1 
		}
		local layer = "("+substr(`"`layer'"',2,.)+")"
		matrix layer = `layer'
		if wordcount(`"`input'"') != layer[1,1] {
			di as error "invalid number of input variables, " layer[1,1] " required"
			matrix drop layer
			error 999
		}
		if wordcount(`"`output'"') != layer[1,colsof(layer)] {
			di as error "invalid number of output variables, " layer[1,colsof(layer)] " required"
			matrix drop layer
			error 999
		}
		matrix input = J(4,layer[1,1],0)
		local i = 1
		foreach v of varlist `input' {
			qui sum `v' `if' `in'
			matrix input[1,`i'] = r(min)
			matrix input[2,`i'] = 1 / (r(max) - r(min))
			if input[2,`i'] == . {
				matrix input[2,`i'] = 1
			}
			local i = `i'+1
		}
		matrix colnames input = `input'
		matrix rownames input = min norm value signal
		matrix output = J(4,layer[1,colsof(layer)],0)
		local i = 1
		foreach v of varlist `output' {
			qui sum `v' `if' `in'
			matrix output[1,`i'] = r(min)
			matrix output[2,`i'] = 1 / (r(max) - r(min))
			if output[2,`i'] == . {
				matrix output[2,`i'] = 1
			}
			local i = `i'+1
		}
		matrix colnames output = `output'
		matrix rownames output = min norm value signal
		braincreate
		braininit `spread'
		di as text "Defined matrices:"
		braindir
		exit
	}
	if `"`1'"' == substr("save",1,length("`1'")) {
		if `"`2'"' == "" {
			di as error "no file specified"
			error 999
		}
		local using = `"`2'"'
		tempname save
		cap local layer = colsof(layer)
		if _rc > 0 {
			di as error "no network defined"
			error 999
		}
		cap local size = colsof(brain)
		if _rc > 0 {
			di as error "no network defined"
			error 999
		}
		cap local isize = colsof(input)
		if _rc > 0 {
			di as error "no network defined"
			error 999
		}
		cap local osize = colsof(output)
		if _rc > 0 {
			di as error "no network defined"
			error 999
		}
		local using = subinstr(trim(`"`using'"'),"\","/",.)
		if regex(`"`using'?"',"\.[^/]*\?") == 0 {
			local using = `"`using'.brn"'
		}
		qui file open `save' using `"`using'"', write binary replace
		file write `save' %9s `"braindead"'
		file write `save' %4bu (`layer')
		forvalue i = 1/`layer' {
			file write `save' %4bu (layer[1,`i'])
		}
		local names : colnames input
		local len = length(`"`names'"')
		file write `save' %4bu (`len')
		file write `save' %`len's `"`names'"'
		local isize = layer[1,1]
		forvalue i = 1/`isize' {
			file write `save' %8z (input[1,`i'])
			file write `save' %8z (input[2,`i'])
		}
		local names : colnames output
		local len = length(`"`names'"')
		file write `save' %4bu (`len')
		file write `save' %`len's `"`names'"'
		local osize = layer[1,colsof(layer)]
		forvalue i = 1/`osize' {
			file write `save' %8z (output[1,`i'])
			file write `save' %8z (output[2,`i'])
		}
		forvalue i = 1/`size' {
			file write `save' %8z (brain[1,`i'])
		}
		file close `save'
		exit
	}
	if "`1'" == substr("load",1,length("`1'")) {
		if `"`2'"' == "" {
			di as error "no file specified"
			error 999
		}
		local using = `"`2'"'
		tempname load bin
		local using = subinstr(trim(`"`using'"'),"\","/",.)
		if regex(`"`using'?"',"\.[^/]*\?") == 0 {
			local using = "`using'.brn"
		}
		file open `load' using `"`using'"', read binary
		file read `load' %9s str
		if `"`str'"' != "braindead" {
			di as error "invalid file format"
			file close `load'
			error 999
		}		
		file read `load' %4bu `bin'
		local layer = `bin'
		matrix layer = J(1,`layer',0)
		forvalue i = 1/`layer' {
			file read `load' %4bu `bin'
			if r(eof) {
				di as error "invalid file format"
				file close `load'
				error 999
			}
			matrix layer[1,`i'] = `bin'
		}
		file read `load' %4bu `bin'
		local len = `bin'
		file read `load' %`len's str
		local layer = layer[1,1]
		matrix input = J(4,`layer',0)
		matrix colnames input = `str'
		matrix rownames input = min norm value signal
		forvalue i = 1/`layer' {
			file read `load' %8z `bin'
			matrix input[1,`i'] = `bin'
			file read `load' %8z `bin'
			matrix input[2,`i'] = `bin'
		}
		file read `load' %4bu `bin'
		local len = `bin'
		file read `load' %`len's str
		local layer = layer[1,colsof(layer)]
		matrix output = J(4,`layer',0)
		matrix colnames output = `str'
		matrix rownames output = min norm value signal
		forvalue i = 1/`layer' {
			file read `load' %8z `bin'
			matrix output[1,`i'] = `bin'
			file read `load' %8z `bin'
			matrix output[2,`i'] = `bin'
		}
		braincreate
		local size = colsof(brain)
		local i = 0
		while 1 {
			file read `load' %8z `bin'
			if r(eof) {
				continue, break
			}
			local i = `i'+1
			if `i' > `size' {
				di as error "invalid file format"
				file close `load'
				error 999
			}
			matrix brain[1,`i'] = `bin'
		}
		if `i' < `size' {
			di as error "invalid file format"
			file close `load'
			error 999
		}
		file close `load'
		di as text "Loaded matrices:"
		braindir
		exit
	}
	if `"`1'"' == substr("feed",1,length("`1'")) {
		macro shift
		tempname output
		local isize = colsof(input)
		local osize = colsof(output)
		local ostart = colsof(neuron)-`osize'+1
		local wc = wordcount(`"`*'"')
		if `wc' != `isize' {
			di as error "number of values does not match input neurons (`wc' <> `isize')"
			error 999
		}
		foreach v in `*' {
			cap confirm number `v'
			if _rc != 0 {
				di as error "invalid value: `v'"
				error 999
			}
		}
		local i = 1
		if `"`raw'"' == "" {
			while `"``i''"' != "" {
				matrix input[3,`i'] = ``i''
				local i = `i'+1
			}
			forvalue i = 1/`isize' {
				matrix input[4,`i'] = max(min((input[3,`i']-input[1,`i']) * input[2,`i'],1),0)
				matrix neuron[1,`i'] = input[4,`i']
			}
		}
		else {
			while `"``i''"' != "" {
				matrix input[4,`i'] = max(min(``i'',1),0)
				local i = `i'+1
			}
			forvalue i = 1/`isize' {
				matrix input[3,`i'] = input[4,`i'] / input[2,`i'] + input[1,`i']
				matrix neuron[1,`i'] = input[4,`i']
			}
		}
		mata: brainforward()
		mata: brainoutputget(0)
		matrix `output' = output[3..4,1...]
		matrix list `output', noheader format(%18.9f)
		return matrix output = `output'
		exit
	}
	if `"`1'"' == substr("signal",1,length("`1'")) {
		macro shift
		tempname signal
		local isize = colsof(input)
		local osize = colsof(output)
		local ostart = colsof(neuron)-`osize'+1
		local nsize = colsof(neuron)
		local inames : colnames input
		local onames : colnames output
		matrix `signal' = J(`isize'+1, `osize', 0)
		matrix colnames `signal' = `onames'
		matrix rownames `signal' = `inames' flatline
		matrix neuron[1, 1] = J(1,`isize', 0)
		mata: brainforward()
		mata: brainoutputget(0)
		if "`raw'" == "" {
			matrix `signal'[`isize'+1,1] = output[3,1...]
		}
		else {
			matrix `signal'[`isize'+1,1] = output[4,1...]
		}
		forvalue i = 1/`isize' {
			matrix neuron[1, 1] = J(1,`isize', 0)
			matrix neuron[1, `i'] = 1
			mata: brainforward()
			if `"`raw'"' == "" {
				forvalue j = 1/`osize' {
					local k = `ostart'+`j'-1
					matrix `signal'[`i',`j'] = neuron[1,`k'] / output[2,`j'] + output[1,`j']
					matrix `signal'[`i',`j'] = `signal'[`i',`j'] - output[3,`j']
				}
			}
			else {
				forvalue j = 1/`osize' {
					local k = `ostart'+`j'-1
					matrix `signal'[`i',`j'] = neuron[1,`k'] - output[4,`j']
				}
			}
		}
		matrix list `signal', noheader format(%18.9f)
		return matrix signal = `signal'
		exit
	}
	if `"`1'"' == substr("margin",1,length("`1'")) {
		tempname signal 
		tempvar delta nouse
		macro shift
		local inames : colnames input
		local onames : colnames output
		local mnames = "`inames'"
		local osize = colsof(output)
		local isize = colsof(input)
		local msize = `isize'
		if `"`*'"' != "" {
			local mnames = ""
			local msize = 0
			foreach v of varlist `*' {
				if index(" `inames' ", " `v' ") == 0 {
					di as error "invalid input variable `v'"
					error 999
				}
				if index(" `mnames' "," `v' ") > 0 {
					di as error "input variable `v' already defined"
					error 999
				}
				local mnames = "`mnames' `v'"
				local msize = `msize'+1
			}
		}
		qui des, varlist
		local names = r(varlist)
		qui gen byte `nouse' = 1
		qui replace `nouse' = 0 `in' `if'
		local snames = subinstr(`"`inames',`onames'"'," ",",",.)
		qui replace `nouse' = 1 `in' if `nouse' == 0 & missing(`snames')
		local snames = ""
		local bnames = ""
		forvalue o = 1/`osize' {
			tempvar signal`o' base`o'
			qui gen double `signal`o'' = .
			qui gen double `base`o'' = .
			local snames = "`snames' `signal`o''"
			local bnames = "`bnames' `base`o''"
		}
		qui gen double `delta' = .
		matrix `signal' = J(`msize',`osize',0)
		matrix rownames `signal' = `mnames'
		local cnames = ""
		forvalue o = 1/`osize' {
			local oname = word("`onames'", `o')
			local cnames = "`cnames' `oname'"
		}
		di as text "unrestricted " _continue
		matrix colnames `signal' = `cnames'
		order `inames' `bnames' `nouse'
		mata: brainsignal(0)
		order `inames' `snames' `nouse'
		local ind = 0
		foreach v of varlist `mnames' {
			forvalue i = 1/`isize' {
				local iname = word("`inames'", `i')
				if "`v'" == "`iname'" {
					di as result "`iname' " _continue
					mata: brainsignal(`i')
					local ind = `ind' + 1
					forvalue o = 1/`osize' {
						local oname = word("`onames'", `o')
						qui replace `delta' = `base`o''-`signal`o'' if `nouse' == 0
						qui sum `delta' if `nouse' == 0
						matrix `signal'[`ind',`o'] = r(mean)
					}
					continue, break
				}
			}
		}
		order `names'
		di ""
		matrix list `signal', noheader format(%18.9f)
		return matrix margin = `signal'
		exit
	}
	if `"`1'"' == substr("think",1,length("`1'")) {
		tempvar nouse
		macro shift
		local wc = wordcount(`"`*'"')
		local osize = colsof(output)
		if `wc' != `osize' {
			di as error "number of target variables does not match output neurons (`wc' <> `osize')"
			error 999
		}
		foreach v in `*' {
			cap drop `v'
			qui gen double `v' = .
		}
		qui des, varlist
		local names = r(varlist)
		qui gen byte `nouse' = 1
		qui replace `nouse' = 0 `in' `if'
		local inames : colnames input
		local mnames = subinstr(`"`inames'"'," ",",",.)
		qui replace `nouse' = 1 `in' if `nouse' == 0 & missing(`mnames')
		local mnames = ""
		order `inames' `*' `nouse'
		mata: brainthink()
		order `names'
		exit
	}
	if `"`1'"' == substr("train",1,length("`1'")) {
		tempvar nouse rnd
		if `eta' < 0 {
			di as error "eta has to be a number larger equal zero"
			error 999
		}
		if `iter' < 0 {
			di as error "number of iterations has to be larger equal zero"
			error 999
		}
		qui des, varlist
		local names = r(varlist)
		qui gen byte `nouse' = 1
		qui replace `nouse' = 0 `in' `if'
		local inames : colnames input
		local onames : colnames output
		local mnames = subinstr(`"`inames',`onames'"'," ",",",.)
		qui replace `nouse' = 1 `in' if `nouse' == 0 & missing(`mnames')
		local mnames = ""
		if `"`nosort'"' != "" {
			sort `nouse'
		}
		else {
			qui gen double `rnd' = uniform()
			sort `nouse' `rnd'
		}
		qui count if `nouse' == 0
		local N = r(N)
		order `inames' `onames'
		local err = 0
		local prev = .
		di as text "{hline 40}" 
		di as text "Brain{dup 7: }Number of obs = " as result %12.0fc `N'
		di as text "Train{dup 17: }eta = " as result %12.6f `eta'
		di as text "{hline 10}{c TT}{hline 14}{c TT}{hline 14}
		di as text "Iteration {c |}        Error {c |}        Delta"
		di as text "{hline 10}{c +}{hline 14}{c +}{hline 14}"
		forvalue i = 1/`iter' {
			mata: braintrain(`eta', `N')
			local err = r(error)/`N'/colsof(output)
			local delta = `err'-`prev'
			local prev = `err'
			di as result %9.0f `i' as text " {c |} " as result %12.9f `err' as text " {c |} " as result %12.9f `delta'
		}
		mata: braintrain(0, `N')
		local err = r(error)/`N'/colsof(output)
		local delta = `err'-`prev'
		if `iter' == 0 {
			di as result "  current" as text " {c |} " as result %12.9f `err' as text " {c |} " as result %12.9f `delta'
		}
		else {
			di as text "{hline 10}{c +}{hline 14}{c +}{hline 14}"
			di as result "    final" as text " {c |} " as result %12.9f `err' as text " {c |} " as result %12.9f `delta'
		}
		order `names'
		di as text "{hline 10}{c BT}{hline 14}{c BT}{hline 14}"
		return scalar N = `N'
		return scalar err = `err'
		exit
	}
	di as error "invalid brain command"
	error 999
end

cap program drop braindir
program define braindir
	di as result "   input[" rowsof(input) ","  colsof(input) "]"
	di as result "  output[" rowsof(output) "," colsof(output) "]"
	di as result "  neuron[" rowsof(neuron) "," colsof(neuron) "]"
	di as result "   layer[" rowsof(layer) "," colsof(layer) "]"
	di as result "   brain[" rowsof(brain) "," colsof(brain) "]"
end

cap program drop braincreate
program define braincreate
	local names = ""
	local size = 0
	local layer = colsof(layer)
	forvalue l = 2/`layer' {
		local p = `l'-1
		local neurons = layer[1,`l']
		local weights = layer[1,`p']
		local size = `size' + `neurons' * (`weights'+1)
		if `l' < `layer' {
			local prefix = "h`p'n"
		}
		else {
			local prefix = "o"
		}
		forvalue n = 1/`neurons' {
			forvalue w = 1/`weights' {
				local names = "`names' `prefix'`n'w`w'"
			}
			local names = "`names' `prefix'`n'b"
		}
	}
	cap matrix brain = J(1,`size',0)
	if _rc > 0 {
		local matsize = int(`size'*1.1)
		set matsize `matsize'
		matrix brain = J(1,`size',0)
	}
	matrix colnames brain = `names'
	matrix rownames brain = weight
	local names = "in"
	local layer = `layer'-2
	forvalue l = 1/`layer' {
		local names = "`names' hid`l'"
	}
	local names = "`names' out"
	matrix colnames layer = `names'
	matrix rownames layer = neurons
	local layer = colsof(layer)
	local names = ""
	local size = 0
	forvalue i = 1/`layer' {
		local neurons = layer[1,`i']
		local size = `size'+`neurons'
		if `i' == 1 {
			local prefix = "in"
		}
		else if `i' == `layer' {
			local prefix = "out"
		}
		else {
			local j = `i'-1
			local prefix = "h`j'n"
		}
		forvalue j = 1/`neurons' {
			local names = "`names' `prefix'`j'"
		}
	}
	matrix neuron = J(1,`size',0)
	matrix colnames neuron = `names'
	matrix rownames neuron = signal
end	

cap program drop braininit
program define braininit
	local spread = abs(`1')
	local range = `spread'*2
	local size = colsof(brain)
	forvalue i = 1/`size' {
		matrix brain[1,`i'] = uniform()*`range'-`spread'
	}
end	

mata:

void braininp(real scalar obs, real matrix input, real matrix neuron)
{	real matrix inp3, inp4, mm
	real scalar i, icnt, ncnt
	icnt = cols(input)
	ncnt = cols(neuron)
	inp3 = st_data(obs, 1..icnt)
	inp4 = (inp3[1, .] - input[1, .]) :* input[2, .]
	mm = minmax(inp4)
	if (mm[1,1] < 0 | mm[1,2] > 1)
	{	for (i = 1; i <= icnt; i++)
		{	if (inp4[1, i] < 0) inp4[1, i] = 0
			if (inp4[1, i] > 1) inp4[1, i] = 1
		}
	} 
	neuron = inp4[1,.], neuron[1,icnt+1..ncnt]
	input = input[1::2,.] \ inp3 \ inp4
}

void brainoutputget(real scalar obs)
{	real matrix output
	output = st_matrix("output")
	brainoutget(obs, cols(st_matrix("input")), st_matrix("neuron"), output)
	st_replacematrix("output", output)
}

void brainoutputset(real scalar obs)
{	real matrix output
	output = st_matrix("output")
	brainoutset(obs, cols(st_matrix("input")), output)
	st_replacematrix("output", output)
}

void brainoutset(real scalar obs, real scalar icnt, real matrix output)
{	real matrix out3, out4, mm
	real scalar i, ocnt
	ocnt = cols(output)
	out3 = st_data(obs, icnt+1..icnt+ocnt)
	out4 = (out3[1, .] - output[1, .]) :* output[2, .]
	mm = minmax(out4)
	if (mm[1,1] < 0 | mm[1,2] > 1)
	{	for (i = 1; i <= ocnt; i++)
		{	if (out4[1, i] < 0) out4[1, i] = 0
			if (out4[1, i] > 1) out4[1, i] = 1
		}
	}
	output = output[1::2,.] \ out3 \ out4
}

void brainoutget(real scalar obs, real scalar icnt, real matrix neuron, real matrix output)
{	real matrix out3, out4
	real scalar i, ocnt, ostart
	ocnt = cols(output)
	ostart = cols(neuron) - ocnt + 1
	out4 = neuron[1, ostart..ostart+ocnt-1]
	out3 = out4[1, .] :/ output[2, .] + output[1, .]
	output = output[1::2,.] \ out3 \ out4
	if (obs > 0) st_store(obs, icnt+1..icnt+ocnt, out3)
}

void brainforward()
{	real matrix neuron
	neuron = st_matrix("neuron")
	brainforw(st_matrix("layer"), neuron, st_matrix("brain"))
	st_replacematrix("neuron", neuron)
}

void brainforw(layer, neuron, brain)
{	real scalar layers, neurons, npos, wpos
	real scalar l, n, start, weights, net
	real matrix feed
	layers = cols(layer)
	npos = layer[1,1]+1
	wpos = 1
	start = 1
	for (l = 2; l <= layers; l++)
	{	neurons = layer[1,l]
		weights = layer[1,l-1]
		feed = neuron[1, start..start+weights-1], 1
		start = start+weights
		for (n = 1; n <= neurons; n++)
		{	net = sum(feed :* brain[1,wpos..wpos+weights])
			neuron[1,npos] = 1/(1+exp(-net))
			wpos = wpos + weights + 1
			npos++
		}
	}
}

void brainbackward(real scalar eta)
{	real matrix brain
	real scalar error
	brain = st_matrix("brain")
	error = brainbackw(eta, st_matrix("output"), st_matrix("layer"), st_matrix("neuron"), brain)
	st_replacematrix("brain",brain)
	st_rclear()
	st_numscalar("r(error)", error)
}

void brainsignal(real scalar inp)
{	real matrix neuron, layer, brain, input, output
	real scalar obs, icnt, ocnt, N
	layer = st_matrix("layer")
	neuron = st_matrix("neuron")
	brain = st_matrix("brain")
	output = st_matrix("output")
	input = st_matrix("input")
	icnt = cols(input)
	ocnt = cols(output)
	ncnt = cols(neuron)
	nouse = icnt+ocnt+1
	N = st_nobs()
	for (obs = 1; obs <= N; obs++)
	{	if (st_data(obs, nouse) == 1)
		{	continue
		}
		braininp(obs, input, neuron)
		if (inp >= 1 & inp <= icnt)
		{	neuron[1,inp] = 0
		}
		brainforw(layer, neuron, brain)
		brainoutget(obs, icnt, neuron, output)
	}
}

void brainthink()
{	brainsignal(0)
}

real scalar brainbackw(real scalar eta, real matrix output, real matrix layer, real matrix neuron, real matrix brain)
{	real matrix delta, err, diff, sub
	real scalar dpos, wpos, npos, lay, error
	real scalar n, l
	real scalar ncol, ocol, dcol
	ncol = cols(neuron)
	ocol = cols(output)
	diff = (J(1, ncol-layer[1,1],1) :- neuron[1, layer[1,1]+1..ncol]) :* neuron[1, layer[1,1]+1..ncol]
	err = output[4, .] :- neuron[1, ncol-ocol+1..ncol]
	error = 0
	for (n = 1; n <= ocol; n++)	error = error + abs(err[1, n])
	if (eta <= 0) 
	{	return(error)
	}
	dcol = cols(diff)
	delta = err :* diff[1, dcol-ocol+1..dcol]
	wpos = cols(brain)+1
	dpos = dcol-ocol+1
	for (l = cols(layer)-1; l >= 2; l--)
	{	lay = layer[1, l]
		err = J(1, lay, 0)
		dcol = dpos-1
		dpos = dpos-lay
		sub = diff[1, dpos..dcol]
		for (n = layer[1, l+1]; n >= 1; n--)
		{	wpos = wpos - lay - 1
			err = err :+ delta[1, n] :* brain[1, wpos..wpos+lay-1] :* sub
		}
		delta = err, delta
	}
	npos = 1
	dpos = 1
	for (l = 2; l <= cols(layer); l++)
	{	lay = layer[1, l-1]
		sub = eta * (neuron[1, npos..npos+lay-1], 1)
		if (l == 2)
		{	err = delta[1, dpos] :* sub
			dpos++
			for (n = 2; n <= layer[1, l]; n++)
			{	err = err, (delta[1, dpos] :* sub)
				dpos++	
			}
		}
		else
		{	for (n = 1; n <= layer[1, l]; n++)
			{	err = err, (delta[1, dpos] :* sub)
				dpos++
			}
		}
		npos = npos + lay
	}
	brain = brain :+ err
	return(error)
}

void braintrain(real scalar eta, real scalar N)
{	real matrix neuron, layer, brain, input, output
	real scalar obs, icnt, error
	layer = st_matrix("layer")
	neuron = st_matrix("neuron")
	brain = st_matrix("brain")
	output = st_matrix("output")
	input = st_matrix("input")
	icnt = cols(input)
	error = 0
	for (obs = 1; obs <= N; obs++)
	{	braininp(obs, input, neuron)
		brainoutset(obs, icnt, output)
		brainforw(layer, neuron, brain)
		error = error + brainbackw(eta, output, layer, neuron, brain)
	}
	if (eta > 0)
	{	st_replacematrix("brain",brain)
	}
	st_rclear()
	st_numscalar("r(error)", error)
}
end	

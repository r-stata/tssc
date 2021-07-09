cap program drop ceq
program define ceq
	local dit display as text in smcl
	`dit' `"There is no {cmd:ceq} command; to see what commands are included in the {cmd:ceq} package, {stata help ceq:help ceq}"'
end

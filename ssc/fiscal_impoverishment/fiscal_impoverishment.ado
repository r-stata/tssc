cap program drop fiscal_impoverishment
program define fiscal_impoverishment
	local dit display as text in smcl
	`dit' `"There is no {cmd:fiscal_impoverishment} command; to see what commands are included in the {cmd:fiscal_impoverishment} package, {stata help fiscal_impoverishment:help fiscal_impoverishment}"'
end

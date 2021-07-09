# delimit ;
cap prog drop reweight2;
prog define reweight2;
version 10.0;
syntax using , newweight(string) [oldweight(string)] ;
preserve;
if "`oldweight'" == "" {;
    gen _constant = 1;
    local oldweight "_constant";
    };
global oldweight "`oldweight'";
global newweight "`newweight'";
save _temp, replace;
clear;
insheet `using';

# delimit cr;
clear mata
mata: reweight()
# delimit;

gen `newweight' = `oldweight' * exp(_tempweight-1);
cap drop _constant;
drop _tempweight;
erase _temp.dta;
restore, not;
end;

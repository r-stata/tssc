#delimit;

program cnsprobit;
	version 8.1;
	args todo b lnf;
	tempvar xb lj;
	mleval `xb' = `b';
	quietly {;
		gen double `lj' = norm(`xb') if $ML_y1 == 1;
		replace  `lj' = norm(-`xb') if $ML_y1 == 0;
		mlsum `lnf' = ln(`lj');
	};
end;
*Written for Stata 8.0 by Kerry L. Papps (klp27@cornell.edu)
*25 October 2004, updated 17 October 2005

*This ado-file calculates the amount of Earned Income Tax Credit (EITC) receipts received by a married couple filing jointly with a specified income and number of children in any year between 1975 and 2005
*The syntax is:
*eitc inc invinc child year, gen(varname)
*inc is the family's total income in current dollars
*invinc is the family's investment income in current dollars (used as an eligibility criterion since 1996)
*child is the number of dependent children that are present (the EITC requires that children be under 19 at end of year or under 24 and full-time students)
*varname is the name of the variable created containing the amount of EITC receipts
*The year refers to the actual calendar year (questions in the CPS and Census refer to the previous year)


program define eitc
  version 8.0
  syntax varlist, GENerate(name)
  tokenize `varlist'
  local inc "`1'"
  local invinc "`2'"
  local child "`3'"
  local year "`4'"

  foreach let in A B C M IR OR {
    forvalues num=0/2 {
      tempvar `let'`num'
      gen ``let'`num''=.
    }
  }

  replace `A1'=4000 if `year'>=1975 & `year'<=1978
  replace `B1'=4000 if `year'>=1975 & `year'<=1978
  replace `C1'=8000 if `year'>=1975 & `year'<=1978
  replace `M1'=400 if `year'>=1975 & `year'<=1978
  replace `IR1'=0.1 if `year'>=1975 & `year'<=1984
  replace `OR1'=0.1 if `year'>=1975 & `year'<=1978

  replace `A1'=5000 if `year'>=1979 & `year'<=1986
  replace `B1'=6000 if `year'>=1979 & `year'<=1984
  replace `C1'=10000 if `year'>=1979 & `year'<=1984
  replace `M1'=500 if `year'>=1979 & `year'<=1984
  replace `OR1'=0.125 if `year'>=1979 & `year'<=1984

  replace `B1'=6500 if `year'>=1985 & `year'<=1986
  replace `C1'=11000 if `year'>=1985 & `year'<=1986
  replace `M1'=550 if `year'>=1985 & `year'<=1986
  replace `IR1'=0.11 if `year'>=1985 & `year'<=1986
  replace `OR1'=0.1222 if `year'>=1985 & `year'<=1986

  replace `A1'=6080 if `year'==1987
  replace `B1'=6920 if `year'==1987
  replace `C1'=15432 if `year'==1987
  replace `M1'=851 if `year'==1987
  replace `IR1'=0.14 if `year'>=1987 & `year'<=1990
  replace `OR1'=0.1 if `year'>=1987 & `year'<=1990

  replace `A1'=6240 if `year'==1988
  replace `B1'=9840 if `year'==1988
  replace `C1'=18576 if `year'==1988
  replace `M1'=874 if `year'==1988

  replace `A1'=6500 if `year'==1989
  replace `B1'=10240 if `year'==1989
  replace `C1'=19340 if `year'==1989
  replace `M1'=910 if `year'==1989

  replace `A1'=6810 if `year'==1990
  replace `B1'=10730 if `year'==1990
  replace `C1'=20264 if `year'==1990
  replace `M1'=953 if `year'==1990

  replace `A2'=`A1' if `year'>=1975 & `year'<=1990
  replace `B2'=`B1' if `year'>=1975 & `year'<=1990
  replace `C2'=`C1' if `year'>=1975 & `year'<=1990
  replace `M2'=`M1' if `year'>=1975 & `year'<=1990
  replace `IR2'=`IR1' if `year'>=1975 & `year'<=1990
  replace `OR2'=`IR1' if `year'>=1975 & `year'<=1990

  replace `A0'=0 if `year'>=1975 & `year'<=1993
  replace `B0'=0 if `year'>=1975 & `year'<=1993
  replace `C0'=0 if `year'>=1975 & `year'<=1993
  replace `M0'=0 if `year'>=1975 & `year'<=1993
  replace `IR0'=0 if `year'>=1975 & `year'<=1993
  replace `OR0'=0 if `year'>=1975 & `year'<=1993

  replace `A1'=7140 if `year'==1991
  replace `B1'=11250 if `year'==1991
  replace `C1'=21250 if `year'==1991
  replace `M1'=1192 if `year'==1991
  replace `IR1'=0.167 if `year'==1991
  replace `OR1'=0.1193 if `year'==1991

  replace `A2'=7140 if `year'==1991
  replace `B2'=11250 if `year'==1991
  replace `C2'=21250 if `year'==1991
  replace `M2'=1235 if `year'==1991
  replace `IR2'=0.173 if `year'==1991
  replace `OR2'=0.1236 if `year'==1991

  replace `A1'=7520 if `year'==1992
  replace `B1'=11840 if `year'==1992
  replace `C1'=22370 if `year'==1992
  replace `M1'=1324 if `year'==1992
  replace `IR1'=0.176 if `year'==1992
  replace `OR1'=0.1314 if `year'==1992

  replace `A2'=7520 if `year'==1992
  replace `B2'=11840 if `year'==1992
  replace `C2'=22370 if `year'==1992
  replace `M2'=1384 if `year'==1992
  replace `IR2'=0.184 if `year'==1992
  replace `OR2'=0.1384 if `year'==1992

  replace `A1'=7750 if `year'==1993
  replace `B1'=12200 if `year'==1993
  replace `C1'=23050 if `year'==1993
  replace `M1'=1434 if `year'==1993
  replace `IR1'=0.185 if `year'==1993
  replace `OR1'=0.1321 if `year'==1993

  replace `A2'=7750 if `year'==1993
  replace `B2'=12200 if `year'==1993
  replace `C2'=23050 if `year'==1993
  replace `M2'=1511 if `year'==1993
  replace `IR2'=0.195 if `year'==1993
  replace `OR2'=0.1393 if `year'==1993

  replace `A1'=7750 if `year'==1994
  replace `B1'=11000 if `year'==1994
  replace `C1'=23755 if `year'==1994
  replace `M1'=2038 if `year'==1994
  replace `IR1'=0.263 if `year'==1994
  replace `OR1'=0.1598 if `year'>=1994 & `year'<=2005

  replace `A2'=8425 if `year'==1994
  replace `B2'=11000 if `year'==1994
  replace `C2'=25296 if `year'==1994
  replace `M2'=2528 if `year'==1994
  replace `IR2'=0.3 if `year'==1994
  replace `OR2'=0.1768 if `year'==1994

  replace `A0'=4000 if `year'==1994
  replace `B0'=5000 if `year'==1994
  replace `C0'=9000 if `year'==1994
  replace `M0'=306 if `year'==1994
  replace `IR0'=0.0765 if `year'>=1994 & `year'<=2005
  replace `OR0'=0.0765 if `year'>=1994 & `year'<=2005

  replace `A1'=6160 if `year'==1995
  replace `B1'=11290 if `year'==1995
  replace `C1'=24396 if `year'==1995
  replace `M1'=2094 if `year'==1995
  replace `IR1'=0.34 if `year'>=1995 & `year'<=2005

  replace `A2'=8640 if `year'==1995
  replace `B2'=11290 if `year'==1995
  replace `C2'=26673 if `year'==1995
  replace `M2'=3110 if `year'==1995
  replace `IR2'=0.36 if `year'==1995
  replace `OR2'=0.2022 if `year'==1995

  replace `A0'=4100 if `year'==1995
  replace `B0'=5130 if `year'==1995
  replace `C0'=9230 if `year'==1995
  replace `M0'=314 if `year'==1995

  replace `A1'=6330 if `year'==1996
  replace `B1'=11650 if `year'==1996
  replace `C1'=25078 if `year'==1996
  replace `M1'=2152 if `year'==1996

  replace `A2'=8890 if `year'==1996
  replace `B2'=11650 if `year'==1996
  replace `C2'=28495 if `year'==1996
  replace `M2'=3556 if `year'==1996
  replace `IR2'=0.4 if `year'>=1996 & `year'<=2005
  replace `OR2'=0.2106 if `year'>=1996 & `year'<=2005

  replace `A0'=4220 if `year'==1996
  replace `B0'=5280 if `year'==1996
  replace `C0'=9500 if `year'==1996
  replace `M0'=323 if `year'==1996

  replace `A1'=6510 if `year'==1997
  replace `B1'=11930 if `year'==1997
  replace `C1'=25760 if `year'==1997
  replace `M1'=2210 if `year'==1997
  replace `A2'=9140 if `year'==1997
  replace `B2'=11930 if `year'==1997
  replace `C2'=29290 if `year'==1997
  replace `M2'=3656 if `year'==1997

  replace `A0'=4340 if `year'==1997
  replace `B0'=5430 if `year'==1997
  replace `C0'=9770 if `year'==1997
  replace `M0'=332 if `year'==1997

  replace `A1'=6680 if `year'==1998
  replace `B1'=12260 if `year'==1998
  replace `C1'=26473 if `year'==1998
  replace `M1'=2271 if `year'==1998

  replace `A2'=9390 if `year'==1998
  replace `B2'=12260 if `year'==1998
  replace `C2'=30095 if `year'==1998
  replace `M2'=3756 if `year'==1998

  replace `A0'=4460 if `year'==1998
  replace `B0'=5570 if `year'==1998
  replace `C0'=10030 if `year'==1998
  replace `M0'=341 if `year'==1998

  replace `A1'=6800 if `year'==1999
  replace `B1'=12460 if `year'==1999
  replace `C1'=26928 if `year'==1999
  replace `M1'=2312 if `year'==1999

  replace `A2'=9540 if `year'==1999
  replace `B2'=12460 if `year'==1999
  replace `C2'=30580 if `year'==1999
  replace `M2'=3816 if `year'==1999

  replace `A0'=4530 if `year'==1999
  replace `B0'=5670 if `year'==1999
  replace `C0'=10200 if `year'==1999
  replace `M0'=347 if `year'==1999

  replace `A1'=6920 if `year'==2000
  replace `B1'=12690 if `year'==2000
  replace `C1'=27413 if `year'==2000
  replace `M1'=2353 if `year'==2000

  replace `A2'=9720 if `year'==2000
  replace `B2'=12690 if `year'==2000
  replace `C2'=31152 if `year'==2000
  replace `M2'=3888 if `year'==2000

  replace `A0'=4610 if `year'==2000
  replace `B0'=5770 if `year'==2000
  replace `C0'=10380 if `year'==2000
  replace `M0'=353 if `year'==2000

  replace `A1'=7140 if `year'==2001
  replace `B1'=13090 if `year'==2001
  replace `C1'=28281 if `year'==2001
  replace `M1'=2428 if `year'==2001

  replace `A2'=10020 if `year'==2001
  replace `B2'=13090 if `year'==2001
  replace `C2'=32121 if `year'==2001
  replace `M2'=4008 if `year'==2001

  replace `A0'=4760 if `year'==2001
  replace `B0'=5950 if `year'==2001
  replace `C0'=10708 if `year'==2001
  replace `M0'=364 if `year'==2001

  replace `A1'=7370 if `year'==2002
  replace `B1'=14520 if `year'==2002
  replace `C1'=30201 if `year'==2002
  replace `M1'=2506 if `year'==2002

  replace `A2'=10350 if `year'==2002
  replace `B2'=14520 if `year'==2002
  replace `C2'=34178 if `year'==2002
  replace `M2'=4140 if `year'==2002

  replace `A0'=4910 if `year'==2002
  replace `B0'=6150 if `year'==2002
  replace `C0'=11060 if `year'==2002
  replace `M0'=376 if `year'==2002

  replace `A1'=7490 if `year'==2003
  replace `B1'=14730 if `year'==2003
  replace `C1'=30666 if `year'==2003
  replace `M1'=2547 if `year'==2003

  replace `A2'=10510 if `year'==2003
  replace `B2'=14730 if `year'==2003
  replace `C2'=34692 if `year'==2003
  replace `M2'=4204 if `year'==2003

  replace `A0'=4990 if `year'==2003
  replace `B0'=7240 if `year'==2003
  replace `C0'=12230 if `year'==2003
  replace `M0'=382 if `year'==2003

  replace `A1'=7660 if `year'==2004
  replace `B1'=15040 if `year'==2004
  replace `C1'=31338 if `year'==2004
  replace `M1'=2604 if `year'==2004

  replace `A2'=10750 if `year'==2004
  replace `B2'=15040 if `year'==2004
  replace `C2'=35458 if `year'==2004
  replace `M2'=4300 if `year'==2004

  replace `A0'=5100 if `year'==2004
  replace `B0'=6390 if `year'==2004
  replace `C0'=12490 if `year'==2004
  replace `M0'=390 if `year'==2004

  replace `A1'=7660 if `year'==2005
  replace `B1'=16040 if `year'==2005
  replace `C1'=33030 if `year'==2005
  replace `M1'=2604 if `year'==2005

  replace `A2'=10750 if `year'==2005
  replace `B2'=16040 if `year'==2005
  replace `C2'=33030 if `year'==2005
  replace `M2'=4300 if `year'==2005

  replace `A0'=5100 if `year'==2005
  replace `B0'=8390 if `year'==2005
  replace `C0'=13750 if `year'==2005
  replace `M0'=390 if `year'==2005

  gen `generate'=.
  replace `generate'=`IR0'*`inc' if `inc'>0 & `inc'<=`A0' & `child'==0
  replace `generate'=`M0' if `inc'>`A0' & `inc'<=`B0' & `child'==0
  replace `generate'=`M0'-`OR0'*(`inc'-`B0') if `inc'>`B0' & `inc'<=`C0' & `child'==0
  replace `generate'=`IR1'*`inc' if `inc'>0 & `inc'<=`A1' & `child'==1
  replace `generate'=`M1' if `inc'>`A1' & `inc'<=`B1' & `child'==1
  replace `generate'=`M1'-`OR1'*(`inc'-`B1') if `inc'>`B1' & `inc'<=`C1' & `child'==1
  replace `generate'=`IR2'*`inc' if `inc'>0 & `inc'<=`A2' & `child'>1 & `child'~=.
  replace `generate'=`M2' if `inc'>`A2' & `inc'<=`B2' & `child'>1 & `child'~=.
  replace `generate'=`M2'-`OR2'*(`inc'-`B2') if `inc'>`B2' & `inc'<=`C2' & `child'>1 & `child'~=.
  replace `generate'=0 if `generate'==. & `year'>=1975 & `year'<=2005 & `child'~=. & `inc'~=. & `invinc'~=.

  *The next line is needed because those near the kinks get small negative values
  replace `generate'=0 if `generate'<0

  *The investment income test for the EITC was introduced in the Welfare Reform Act of 1996
  replace `generate'=0 if `invinc'>2200 & `year'==1996
  replace `generate'=0 if `invinc'>2250 & `year'==1997
  replace `generate'=0 if `invinc'>2300 & `year'==1998
  replace `generate'=0 if `invinc'>2350 & `year'==1999
  replace `generate'=0 if `invinc'>2400 & `year'==2000
  replace `generate'=0 if `invinc'>2450 & `year'==2001
  replace `generate'=0 if `invinc'>2550 & `year'==2002
  replace `generate'=0 if `invinc'>2600 & `year'==2003
  replace `generate'=0 if `invinc'>2650 & `year'==2004
  replace `generate'=0 if `invinc'>2700 & `year'==2005
end


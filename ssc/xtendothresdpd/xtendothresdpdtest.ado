*! version 1.0.1
*! Simulation Finder 
*! for the Command xtendothresdpd 
*! Diallo Ibrahima Amadou
*! All comments are welcome, 15Apr2020



capture program drop xtendothresdpdtest
program xtendothresdpdtest, eclass 
        version 16.0
        if "`e(cmd)'" != "xtendothresdpd" {
										error 301
		}		
		syntax , comdline(string asis) [ Reps(integer 50) simulopts(string asis) bstatopts(string asis) ]
		xtendothresdpdboot, comdline(`comdline')
		local supwstarbtlcm = r(supwstarboots) 
		local ntotalbtlcm   = r(ntotalboots)
		simulate SupWStar=r(supwstarboots), reps(`reps') `simulopts' : xtendothresdpdboot, comdline(`comdline')
		bstat, stat(`supwstarbtlcm') n(`ntotalbtlcm') `bstatopts'
		
end


		
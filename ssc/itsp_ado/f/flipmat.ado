

*! flipmat 1.0.0  CFBaum 11aug2008
program flipmat
	version 10.1
	syntax name, [HORIZ]
	confirm matrix `namelist'
	mata: mf_flipmat("`namelist'", "`horiz'")
end

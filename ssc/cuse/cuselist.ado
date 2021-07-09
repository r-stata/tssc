*! 显示数据库中的所有数据集
cap prog drop cuselist
prog define cuselist
	copy "https://tidyfriday.cn/cuse/cuselist_temp.ado" cuselist_temp.ado, replace
	cuselist_temp
	cap erase cuselist_temp.ado
end

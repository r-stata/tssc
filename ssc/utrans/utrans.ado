*! utf-8中文转码
*! utrans 文件名.后缀名
*! 示例：utrans temp.do
cap prog drop utrans
prog define utrans
	version 12.0
	syntax anything
	cap preserve
	clear
	cap qui{
		unicode encoding set gb18030
		unicode translate "`anything'"
		unicode erasebackups, badidea
		unicode analyze "`anything'"
		unicode erasebackups, badidea
	}
	if r(N_needed) == 0 di in yellow "转码完成"
	if r(N_needed) != 0 di in red "转码失败"
end

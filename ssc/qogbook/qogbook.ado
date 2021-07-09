version 10
program qogbook
capture confirm variable version

if !_rc {
	if version == "QoG_c_s_v6Apr11" | version == "QoG_t_s_v6Apr11" {
	capture ! explorer "http://www.qogdata.pol.gu.se/codebook/codebook_standard_20110406.pdf"
	capture ! open "http://www.qogdata.pol.gu.se/codebook/codebook_standard_20110406.pdf"
}
	else if version == "QoG_c_s_v28Mar11" | version == "QoG_t_s_v28Mar11" {
	capture ! explorer "http://www.qogdata.pol.gu.se/codebook/codebook_basic_20120608.pdf"
	capture ! open "http://www.qogdata.pol.gu.se/codebook/codebook_basic_20120608.pdf"
}
	else if version == "StdCS15May13" | version == "StdTS15May13" {
	capture ! explorer "http://www.qogdata.pol.gu.se/codebook/codebook_standard_15may13.pdf"
	capture ! open "http://www.qogdata.pol.gu.se/codebook/codebook_standard_15may13.pdf"
}
	else if version == "SocCS4Apr12" | version == "SocTSL4Apr12" | version == "SocTSW4Apr12" {
	capture ! explorer "http://www.qogdata.pol.gu.se/codebook/codebook_social_4apr12.pdf"
	capture ! open "http://www.qogdata.pol.gu.se/codebook/codebook_social_4apr12.pdf"
}
	else if version == "ExpIND3Sep12" | version == "ExpAGG6Sep12" {
	capture ! explorer "http://www.qogdata.pol.gu.se/codebook/codebook_expert_31aug12.pdf"
	capture ! open "http://www.qogdata.pol.gu.se/codebook/codebook_expert_31aug12.pdf"
}
	else if version == "BasCS30Aug13" | version == "BasTS30Aug13" {
	capture ! explorer "http://www.qogdata.pol.gu.se/codebook/codebook_basic_30aug13.pdf"
	capture ! open "http://www.qogdata.pol.gu.se/codebook/codebook_basic_30aug13.pdf"
}
	else {
	display in red "Not correct data in memory!"
	display in red "QoG data with a version variable needed."
}
}
end

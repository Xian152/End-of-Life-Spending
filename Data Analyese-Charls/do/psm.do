cd "C:\Users\KEMOSABE\Desktop\psm-did"

*- 设置图片输出样式

graph set window fontface     "Times New Roman"
graph set window fontfacesans "宋体"
set scheme s1color  

use 行业数据.dta, clear

*- 定义全局暂元

global xlist  "ADM PPE ADV RD HHI INDSIZE NFIRMS FCFIRM MARGIN LEVDISP SIZEDISP ENTRYR EXITR"
global regopt "absorb(city ind3) cluster(city#ind3 city#year) keepsing"

*- 生成处理组虚拟变量

gen treated = ( city == 5101 | city == 5000 | city == 2102 | city == 3501    ///
              | city == 4401 | city == 3701 | city == 3201 | city == 3702    ///
              | city == 3101 | city == 4403 | city == 1200 | city == 4201    ///
              | city == 4404 | prov ==   44 | prov ==   45 | prov ==   43    ///
              | prov ==   32 | prov ==   33 | city == 1100 | city == 5301    ///
              | city == 2101 | city == 3502 | city == 6101 | city == 2201    ///
              | city == 2301 | city == 6201 | city == 6401 )

save psmdata.dta, replace


**# 一、截面匹配

use psmdata.dta, clear

**# 1.1 卡尺最近邻匹配（1:2）

set  seed 0000
gen  norvar_1 = rnormal()
sort norvar_1

psmatch2 treated $xlist , outcome(TFPQD_OP) logit neighbor(2) ties common    ///
                          ate caliper(0.05)

save csdata.dta, replace

**# 1.2 平衡性检验

pstest, both graph saving(balancing_assumption, replace)
graph export "balancing_assumption.emf", replace

psgraph, saving(common_support, replace)
graph export "common_support.emf", replace

**# 1.3 倾向得分值的核密度图

sum _pscore if treated == 1, detail  // 处理组的倾向得分均值为0.5632

*- 匹配前

sum _pscore if treated == 0, detail

twoway(kdensity _pscore if treated == 1, lpattern(solid)                     ///
              lcolor(black)                                                  ///
              lwidth(thin)                                                   ///
              scheme(qleanmono)                                              ///
              ytitle("{stSans:核}""{stSans:密}""{stSans:度}",                ///
                     size(medlarge) orientation(h))                          ///
              xtitle("{stSans:匹配前的倾向得分值}",                          ///
                     size(medlarge))                                         ///
              xline(0.5632   , lpattern(solid) lcolor(black))                ///
              xline(`r(mean)', lpattern(dash)  lcolor(black))                ///
              saving(kensity_cs_before, replace))                            ///
      (kdensity _pscore if treated == 0, lpattern(dash)),                    ///
      xlabel(     , labsize(medlarge) format(%02.1f))                        ///
      ylabel(0(1)4, labsize(medlarge))                                       ///
      legend(label(1 "{stSans:处理组}")                                      ///
             label(2 "{stSans:控制组}")                                      ///
             size(medlarge) position(1) symxsize(10))

graph export "kensity_cs_before.emf", replace

discard

*- 匹配后

sum _pscore if treated == 0 & _weight != ., detail

twoway(kdensity _pscore if treated == 1, lpattern(solid)                     ///
              lcolor(black)                                                  ///
              lwidth(thin)                                                   ///
              scheme(qleanmono)                                              ///
              ytitle("{stSans:核}""{stSans:密}""{stSans:度}",                ///
                     size(medlarge) orientation(h))                          ///
              xtitle("{stSans:匹配后的倾向得分值}",                          ///
                     size(medlarge))                                         ///
              xline(0.5632   , lpattern(solid) lcolor(black))                ///
              xline(`r(mean)', lpattern(dash)  lcolor(black))                ///
              saving(kensity_cs_after, replace))                             ///
      (kdensity _pscore if treated == 0 & _weight != ., lpattern(dash)),     ///
      xlabel(     , labsize(medlarge) format(%02.1f))                        ///
      ylabel(0(1)4, labsize(medlarge))                                       ///
      legend(label(1 "{stSans:处理组}")                                      ///
             label(2 "{stSans:控制组}")                                      ///
             size(medlarge) position(1) symxsize(10))

graph export "kensity_cs_after.emf", replace

discard


**# 1.4 回归结果对比

use csdata.dta, clear

*- 基准回归1（混合OLS）

qui: reg TFPQD_OP FB $xlist , cluster(city)
est store m1

*- 基准回归2（固定效应模型）

qui: reghdfe TFPQD_OP FB $xlist , $regopt
est store m2

*- PSM-DID1（使用权重不为空的样本）

qui: reghdfe TFPQD_OP FB $xlist if _weight != ., $regopt
est store m3

*- PSM-DID2（使用满足共同支撑假设的样本）

qui: reghdfe TFPQD_OP FB $xlist if _support == 1, $regopt
est store m4

*- PSM-DID3（使用频数加权回归）

gen     weight = _weight * 2
replace weight = 1 if treated == 1 & _weight != .
qui: reghdfe TFPQD_OP FB $xlist [fweight = weight], $regopt
est store m5

*- 回归结果输出

local mlist_1 "m1 m2 m3 m4 m5"
reg2docx `mlist_1' using 截面匹配回归结果对比.docx, b(%6.4f) t(%6.4f)        ///
         scalars(N r2_a(%6.4f)) noconstant  replace                          ///
         mtitles("OLS" "FE" "Weight!=." "On_Support" "Weight_Reg")           ///
         title("基准回归及截面PSM-DID结果")

		 
gen     weight  = _weight * 2
replace weight  = 1 if treated == 1 & _weight != .
keep if weight != .
expand  weight
reghdfe TFPQD_OP FB $xlist , $regopt
est store m5
		 
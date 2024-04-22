
clear all
// 使用您的数据文件
. use"/Users/JACKSON/Library/CloudStorage/Box-Box/HALSA-Healthy Aging - CLHLS/P24 End-of-life care expenditure patterns and causes of death/Data Analyses/output/analyses.dta"

//table
//table1, by(wave) vars(age contn\ gender cat\ iadl cat\ adl cat\ dage contn\ coresidence cat\ residence cat\ hexpFampaid conts\  hexpFampaidOP conts\  hexpFampaidIP  conts\  hexpIndpaid conts\  hexpIndpaidOP  conts\ hexpIndpaidIP conts\ hexpFampaid contn\  hexpFampaidOP contn\  hexpFampaidIP  contn\  hexpIndpaid contn\  hexpIndpaidOP  contn\ hexpIndpaidIP contn\  )  one mis saving("/Users/JACKSON/Desktop/EOL Graph/Table1 hexp.xls", replace) 

//Xian's adjustment
foreach k in iadl coresidence ciBi residence {
	replace `k' = 99999 if deathstatus == 1
}

sort id wave
bysort id (wave): replace residence = residence[_n-1] if deathstatus == 1

//baseline情况template
preserve
	keep if id wave 
restore


// 保存需要的值
keep if agebase >= 65
// 提取年份和月份
gen intdate_year = year(intdate)
gen intdate_month = month(intdate)
gen dthdate_year = year(dthdate)
gen dthdate_month = month(dthdate)
gen months_between = (dthdate_year - intdate_year) * 12 + (dthdate_month - intdate_month)


//adjust for inflation
merge m:1 dthdate_year using "路径\CPI_death.dta"
drop _merge
merge m:1 intdate_year using "路径\CPI.dta"




//drop things
drop if missing(adl)
drop if missing(iadl)
drop if missing(ciBi) 
//srhealth跟DcarehexpM,DOOPhexp,phys完全挂钩,
// 活人没有ciBi
//drop if missing(srhealth)
//drop if missing(phys)
drop if missing(gender)
drop if missing(dage)
drop if missing(coresidence)

preserve
//画图，Carecost的
drop if missing(DcarehexpM)
gen DcarehexpM_adjusted = (DcarehexpM / cpi2) * 100
graph bar (median) DcarehexpM_adjusted, over(dthdate_year) title("Bar Chart of Care cost vs. year")
graph export "/Users/JACKSON/Desktop/EOL Graph/Carecost.jpg", replace
restore

//画图，Out-of-Pocket Cost
preserve
drop if missing(DOOPhexp)
gen DOOPhexp_adjusted = (DOOPhexp/ cpi2) * 100
graph bar (median) DOOPhexp_adjusted, over(dthdate_year) title("Bar Chart of Out-of-Pocket cost vs. year")

graph export "/Users/JACKSON/Desktop/EOL Graph/Out-of-Pocket Cost.jpg", replace
restore

//死亡间隔的图
preserve

drop if missing(intdate)
drop if missing(dthdate)
drop if missing(hexpFampaid)
drop if missing(hexpIndpaid)
gen hexpFampaid_adjusted = (hexpFampaid/ cpi) * 100
gen hexpIndpaid_adjusted = (hexpIndpaid/ cpi) * 100
//轨迹图
traj, var(hexpIndpaid_adjusted) indep(months_between) model(cnorm) min(0) max(200000) order(3 3 2)
 traj, var(hexpFampaid_adjusted) indep(months_between) model(cnorm) min(0) max(200000) order(3 3 2)
//查变量有多少
gen new_variable = 1
bysort months_between: egen count_variable = sum(new_variable)
tabulate months_between, summarize(count_variable)
graph bar count_variable, over(months_between) title("Number count for the variables")
graph export "/Users/JACKSON/Desktop/EOL Graph/Number count for the variables.jpg", replace
bysort months_between: egen count_variable_sum = total(count_variable)
drop if count_variable_sum < 3


// 按ID和intdate升序排序数据
sort id intdate
// 按ID分组，计算每个ID的第一次常规问卷与死亡日期的间隔
by id: gen time_diff = dthdate - intdate[1]
// 保留那些第一次常规问卷与死亡日期间隔大于1年的ID的所有相关记录
keep if time_diff > 365
//删除大于60months的
drop if months_between >60
// 删除创建的临时变量
drop time_diff
bysort months_between :egen hexpFampaid_median = median(hexpFampaid_adjusted)
bysort months_between :egen hexpIndpaid_median = median(hexpIndpaid_adjusted)
bysort months_between adl:egen hexpFampaid_median_adl = median(hexpFampaid_adjusted)
bysort months_between adl:egen hexpIndpaid_median_adl = median(hexpIndpaid_adjusted)
bysort months_between iadl:egen hexpFampaid_median_iadl = median(hexpFampaid_adjusted)
bysort months_between iadl:egen hexpIndpaid_median_iadl = median(hexpIndpaid_adjusted)
bysort months_between ciBi:egen hexpFampaid_median_ciBi = median(hexpFampaid_adjusted)
bysort months_between ciBi:egen hexpIndpaid_median_ciBi = median(hexpIndpaid_adjusted)
bysort months_between coresidence:egen hexpFampaid_median_coresidence = median(hexpFampaid_adjusted)
bysort months_between coresidence: egen hexpIndpaid_median_coresidence = median(hexpIndpaid_adjusted)
bysort months_between gender: egen hexpFampaid_median_gender = median(hexpFampaid_adjusted)
bysort months_between gender: egen hexpIndpaid_median_gender = median(hexpIndpaid_adjusted)
bysort months_between dage: egen hexpFampaid_median_dage = median(hexpFampaid_adjusted)
bysort months_between dage: egen hexpIndpaid_median_dage = median(hexpIndpaid_adjusted)

// 总图
twoway line hexpFampaid_median hexpIndpaid_median months_between, 
graph export "/Users/JACKSON/Desktop/EOL Graph/Total graph.jpg", replace
// ADL分图 Fam
twoway (line hexpFampaid_median_adl months_between if adl == 1, sort) ///
       (line hexpFampaid_median_adl months_between if adl == 0, sort), ///
       title("Family Cost Comparison by ADL Status") ///
       xtitle("Months") ytitle("Cost") ///
       legend(order(1 "adl = 1" 2 "adl = 0"))
graph export "/Users/JACKSON/Desktop/EOL Graph/Family ADL graph.jpg", replace

twoway (line hexpIndpaid_median_adl months_between if adl == 1, sort) ///
       (line hexpIndpaid_median_adl months_between if adl == 0, sort), ///
       title("Individual Cost Comparison by ADL Status") ///
       xtitle("Months") ytitle("Cost") ///
	   legend(order(1 "adl = 1" 2 "adl = 0"))
graph export "/Users/JACKSON/Desktop/EOL Graph/Individual ADL graph.jpg", replace
// IADL Fam分图
twoway (line hexpFampaid_median_iadl months_between if iadl == 1, sort) ///
       (line hexpFampaid_median_iadl months_between if iadl == 0, sort), ///
	   title("Family Cost Comparison by IADL Status") ///
       xtitle("Months") ytitle("Cost") ///
	   legend(order(1 "iadl = 1" 2 "iadl = 0" ))
	   graph export "/Users/JACKSON/Desktop/EOL Graph/Family IADL graph.jpg", replace
/// IADL IND分图
twoway (line hexpIndpaid_median_iadl months_between if iadl == 1, sort) ///
       (line hexpIndpaid_median_iadl months_between if iadl == 0, sort), ///
       title("Individual Cost Comparison by IADL Status") ///
       xtitle("Months") ytitle("Cost") ///
	   legend(order(1 "iadl = 1" 2 "iadl = 0" ))
	   graph export "/Users/JACKSON/Desktop/EOL Graph/Individual IADL graph.jpg", replace
// ciBi FAM分图
twoway (line hexpFampaid_median_ciBi months_between if ciBi == 1, sort) ///
       (line hexpFampaid_median_ciBi months_between if ciBi == 0, sort), ///
	   title("Family Cost Comparison by ciBi Status") ///
       xtitle("Months") ytitle("Cost") ///
	   legend(order(1 "ciBi = 1" 2 "ciBi = 0" ))
	   graph export "/Users/JACKSON/Desktop/EOL Graph/Family ciBi graph.jpg", replace
// ciBi IND分图  
twoway (line hexpIndpaid_median_ciBi months_between if ciBi == 1, sort) ///
       (line hexpIndpaid_median_ciBi months_between if ciBi == 0, sort), ///
       title("Individual Cost Comparison by ciBi Status") ///
       xtitle("Months") ytitle("Cost") ///
	   legend(order(1 "ciBi = 1" 2 "ciBi = 0" ))
	   graph export "/Users/JACKSON/Desktop/EOL Graph/Individual ciBi graph.jpg", replace
// Coresidence FAM分图  
 twoway (line hexpFampaid_median_coresidence months_between if coresidence == 1, sort) ///
       (line hexpFampaid_median_coresidence months_between if coresidence == 2, sort) ///
	   (line hexpFampaid_median months_between if coresidence == 3, sort), ///
       title("Family Cost Comparison by Coresidence Status") ///
       xtitle("Months") ytitle("Cost") ///
	   legend(order(1 "coresidence = 1" 2 "coresidence = 2"  3 "coresidence = 3"))
		graph export "/Users/JACKSON/Desktop/EOL Graph/Family Coresidence graph.jpg", replace
// Coresidence IND分图
twoway (line hexpIndpaid_median_coresidence months_between if coresidence == 1, sort) ///
       (line hexpIndpaid_median_coresidence months_between if coresidence == 2, sort) ///
	   (line hexpIndpaid_median_coresidence months_between if coresidence == 3, sort), ///
	   title("Individual Cost Comparison by Coresidence Status") ///
       xtitle("Months") ytitle("Cost") ///
	   legend(order(1 "coresidence = 1" 2 "coresidence = 2"  3 "coresidence = 3"))
graph export "/Users/JACKSON/Desktop/EOL Graph/Individual Coresidence graph.jpg", replace
// Gender FAM分图
twoway (line hexpFampaid_median_gender months_between if gender == 1, sort) ///
       (line hexpFampaid_median_gender months_between if gender == 0, sort), ///
       title("Family Cost Comparison by Gender") ///
       xtitle("Months") ytitle("Cost") ///
	   legend(order(1 "gender = 1" 2 "gender = 0"))
	   graph export "/Users/JACKSON/Desktop/EOL Graph/Family Gender graph.jpg", replace
// Gender IND分图twoway
twoway (line hexpIndpaid_median_gender months_between if gender == 1 , sort) ///
       (line hexpIndpaid_median_gender months_between if gender == 0, sort), ///
       title("Individual Cost Comparison by Gender") ///
       xtitle("Months") ytitle("Cost") ///
	   legend(order(1 "gender = 1" 2 "gender = 0"))
	   graph export "/Users/JACKSON/Desktop/EOL Graph/Individual Gender graph.jpg", replace
	   
twoway (line hexpIndpaid_median_dage months_between if 65 < dage & dage <= 85, sort) ///
       (line hexpIndpaid_median_dage months_between if 85 < dage & dage <= 105, sort) ///
       (line hexpIndpaid_median_dage months_between if 105 < dage & dage <= 125, sort), ///
       title("Individual Cost Comparison by Age") ///
       xtitle("Months") ytitle("Cost") ///
       legend(order(1 "65-85" 2 "85-105" 3 "105-125" ))
graph export "/Users/JACKSON/Desktop/EOL Graph/Individual Death Age graph.jpg", replace

twoway (line hexpFampaid_median_dage months_between if 65 < dage & dage <= 85, sort) ///
       (line hexpFampaid_median_dage months_between if 85 < dage & dage <= 105, sort) ///
       (line hexpFampaid_median_dage months_between if 105 < dage & dage <= 125, sort), ///
        title("Family Cost Comparison by death age") ///
       xtitle("Months") ytitle("Cost") ///
	   legend(order(1 "65-85" 2 "85-105" 3 "105-125"))
	   graph export "/Users/JACKSON/Desktop/EOL Graph/Family Death Age graph.jpg", replace
restore
preserve

// Retired 与死亡间隔分图
drop if missing(dthdate)
drop if missing(retiredYear)
drop if missing(hexpFampaid)
drop if missing(hexpIndpaid)
gen hexpFampaid_adjusted = (hexpFampaid/ cpi) * 100
gen hexpIndpaid_adjusted = (hexpIndpaid/ cpi) * 100
gen retiredYear_year = year(retiredYear)
gen retire_year_gap = (dthdate_year - retiredYear_year) 
graph bar (median)hexpFampaid_adjusted, over(retire_year_gap) title("Family cost vs. Years between retired and death")
graph export "/Users/JACKSON/Desktop/EOL Graph/Retired graph Family cost.jpg", replace
graph bar (median)hexpIndpaid_adjusted, over(retire_year_gap) title("Individual cost vs. Years between retired and death")
graph export "/Users/JACKSON/Desktop/EOL Graph/Retired graph Individual cost.jpg", replace




  
  
  

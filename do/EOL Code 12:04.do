clear all

// 使用您的数据文件
use"/Users/JACKSON/Library/CloudStorage/Box-Box/HALSA-Healthy Aging - CLHLS/P24 End-of-life care expenditure patterns and causes of death/Data Analyses/output/analyses.dta"

set scheme cleanplots, perm

//Xian's adjustment
foreach k in iadl coresidence ciBi srhealth phys residence{
	replace `k' = 99999 if deathstatus == 1
}
// 保存需要的值
keep if agebase >= 65
// 提取年份和月份
gen intdate_year = year(intdate)
gen intdate_month = month(intdate)
gen dthdate_year = year(dthdate)
gen dthdate_month = month(dthdate)
gen months_between = (dthdate_year - intdate_year) * 12 + (dthdate_month - intdate_month)


//adjust for inflation
merge m:1 dthdate_year using "/Users/JACKSON/Desktop/DKU/Research/Output/路径\CPI_death.dta"
drop _merge
merge m:1 intdate_year using  "/Users/JACKSON/Desktop/DKU/Research/Output/路径\CPI.dta"

//Generate ratio
gen costratio = (hexpFampaid/ hexpIndpaid)



//drop things
drop if missing(adl)
drop if missing(iadl)
drop if missing(ciBi) 
drop if missing(srhealth)
drop if missing(phys)
drop if missing(gender)
drop if missing(dage)
drop if missing(coresidence)
drop if missing(residence)

gen hexpFampaid_adjusted = (hexpFampaid/ cpi) * 100
gen hexpIndpaid_adjusted = (hexpIndpaid/ cpi) * 100

//查变量有多少
gen new_variable = 1
bysort months_between: egen count_variable = sum(new_variable)
bysort months_between: egen count_variable_sum = total(count_variable)
drop if count_variable_sum < 3


// 按ID和intdate升序排序数据
sort id intdate
// 按ID分组，计算每个ID的第一次常规问卷与死亡日期的间隔
by id: gen time_diff = dthdate - intdate[1]
// 保留那些第一次常规问卷与死亡日期间隔大于1年的ID的所有相关记录
keep if time_diff > 365
//删除大于60months的
//drop if months_between >60
// 删除创建的临时变量
drop time_diff
bysort months_between :egen hexpFampaid_median = median(hexpFampaid_adjusted)
bysort months_between :egen hexpIndpaid_median = median(hexpIndpaid_adjusted)
//ciBi
sort id wave
bysort id: gen ciBi_change = ciBi - ciBi[_n-1]
gen change_1 = .
gen change_2 = .
gen change_3 = .
replace change_1 = 1 if ciBi_change == 1
replace change_2 = 1 if ciBi_change == -1
replace change_3 = 1 if ciBi_change == 0
// Dcargiv
by id: egen max_Dcargiv = max(Dcargiv)
replace Dcargiv = max_Dcargiv
drop max_Dcargiv

gen Dspouse = .
replace Dspouse = 0 if Dcargiv == 2
replace Dspouse = 0 if Dcargiv == 3
replace Dspouse = 0 if Dcargiv == 4
replace Dspouse = 0 if Dcargiv == 5
replace Dspouse = 0 if Dcargiv == 6
replace Dspouse = 0 if Dcargiv == 7
replace Dspouse = 1 if Dcargiv == 1


drop if months_between >60

graph  bar (count) change_1, over(months_between) stack blabel(bar) 
graph export "/Users/JACKSON/Desktop/DKU/Research/Output/EOLGraph1204/ 没有到有.jpg", replace
graph  bar (count) change_2, over(months_between) stack blabel(bar) 
graph export "/Users/JACKSON/Desktop/DKU/Research/Output/EOLGraph1204/ 有到没有.jpg", replace
graph  bar (count) change_3, over(months_between) stack blabel(bar) 
graph export "/Users/JACKSON/Desktop/DKU/Research/Output/EOLGraph1204/ 稳定.jpg", replace


bysort months_between Dspouse: egen hexpFampaid_median_Dspouse = median(hexpFampaid_adjusted)
bysort months_between Dspouse: egen hexpIndpaid_median_Dspouse = median(hexpIndpaid_adjusted)

// Dspouse IND分图
twoway (line hexpIndpaid_median_Dspouse months_between if Dspouse == 0, sort) ///
       (line hexpIndpaid_median_Dspouse months_between if Dspouse == 1, sort), ///
       title("Individual Cost Comparison by Caregiver") ///
       xtitle("Months") ytitle("Cost") ///
	   xlabel(0(6)60) ///
       legend(order(1 "Non-spouse" 2 "Spouse" ))
graph export "/Users/JACKSON/Desktop/DKU/Research/Output/EOLGraph1204/ Caregiver individual.jpg", replace
// Dspouse FAM分图
twoway (line hexpFampaid_median_Dspouse months_between if Dspouse == 0, sort) ///
       (line hexpFampaid_median_Dspouse months_between if Dspouse == 1, sort), ///
        title("Family Cost Comparison by Caregiver") ///
       xtitle("Months") ytitle("Cost") ///
	   xlabel(0(6)60) ///
	   legend(order(1 "Non-spouse" 2 "Spouse"))
graph export "/Users/JACKSON/Desktop/DKU/Research/Output/EOLGraph1204/ Caregiver Family.jpg", replace




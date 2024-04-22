
clear all
// 使用您的数据文件
. use"/Users/JACKSON/Library/CloudStorage/Box-Box/HALSA-Healthy Aging - CLHLS/P24 End-of-life care expenditure patterns and causes of death/Data Analyses/output/analyses.dta"

set scheme cleanplots, perm

//Xian's adjustment
foreach k in iadl coresidence ciBi srhealth phys{
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
// Generate Age group variables
gen agegroup=.
replace agegroup = 1 if dage >=65 & dage <= 84
replace agegroup = 2 if dage >=85 & dage <= 104
replace agegroup = 3 if dage >=105 & dage <= 125
// Generate Income group variables
gen incomegroup=.
replace incomegroup= 1 if hhIncome >= 0 & hhIncome <= 20000
replace incomegroup= 2 if hhIncome >20000
// Generate Income group  Per Capita variables
gen incomegrouppercap=.
replace incomegrouppercap= 1 if hhIncomepercap <=3000 
replace incomegrouppercap= 2 if hhIncomepercap >3000

gen agegroup1=.
replace agegroup1 = 1 if dage >=65 & dage <= 91
replace agegroup1 = 2 if dage >91 



//adjust for inflation
merge m:1 dthdate_year using "路径\CPI_death.dta"
drop _merge
merge m:1 intdate_year using "路径\CPI.dta"




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

//table
table1, by(wave) vars( age contn\ gender cat\ iadl cat\ adl cat\ hhIncome contn\ hhIncomepercap contn\ dage contn\ coresidence cat\ residence cat\ hexpFampaid conts\  hexpFampaidOP conts\  hexpFampaidIP  conts\  hexpIndpaid conts\  hexpIndpaidOP  conts\ hexpIndpaidIP conts\ hexpFampaid contn\  hexpFampaidOP contn\  hexpFampaidIP  contn\  hexpIndpaid contn\  hexpIndpaidOP  contn\ hexpIndpaidIP contn\  )  one mis saving(       "/Users/JACKSON/Desktop/EOL Graph/Table1 Total.xls", replace)
preserve
///
drop if deathstatus==0
table1, by(wave) vars( age contn\ gender cat\ iadl cat\ adl cat\ hhIncome contn\ hhIncomepercap contn\ dage contn\  coresidence cat\ residence cat\ hexpFampaid conts\  hexpFampaidOP conts\  hexpFampaidIP  conts\  hexpIndpaid conts\  hexpIndpaidOP  conts\ hexpIndpaidIP conts\ hexpFampaid contn\  hexpFampaidOP contn\  hexpFampaidIP  contn\  hexpIndpaid contn\  hexpIndpaidOP  contn\ hexpIndpaidIP contn\  )  one mis saving(       "/Users/JACKSON/Desktop/EOL Graph/Table1 Dead.xls", replace)
restore

preserve
drop if deathstatus==1
table1, by(wave) vars(age contn\ gender cat\ iadl cat\ adl cat\ hhIncome contn\ hhIncomepercap contn\ dage contn\ coresidence cat\ residence cat\ hexpFampaid conts\  hexpFampaidOP conts\  hexpFampaidIP  conts\  hexpIndpaid conts\  hexpIndpaidOP  conts\ hexpIndpaidIP conts\ hexpFampaid contn\  hexpFampaidOP contn\  hexpFampaidIP  contn\  hexpIndpaid contn\  hexpIndpaidOP  contn\ hexpIndpaidIP contn\  )  one mis saving(       "/Users/JACKSON/Desktop/EOL Graph/Table1 Alive.xls", replace)
restore



preserve
//画图，Carecost的
drop if missing(DcarehexpM)
gen DcarehexpM_adjusted = (DcarehexpM / cpi2) * 100
graph bar (median) DcarehexpM_adjusted, over(dthdate_year) title("Bar Chart of Care cost vs. year")
graph export "/Users/JACKSON/Desktop/EOL Graph/17 Carecost.jpg", replace
restore 

//画图，Out-of-Pocket Cost
preserve
drop if missing(DOOPhexp)
gen DOOPhexp_adjusted = (DOOPhexp/ cpi2) * 100
graph bar (median) DOOPhexp_adjusted, over(dthdate_year) title("Bar Chart of Out-of-Pocket cost vs. year")

graph export "/Users/JACKSON/Desktop/EOL Graph/18 Out-of-Pocket Cost.jpg", replace
restore

//死亡间隔的图
preserve

drop if missing(intdate)
drop if missing(dthdate)
drop if missing(hexpFampaid)
drop if missing(hexpIndpaid)
gen hexpFampaid_adjusted = (hexpFampaid/ cpi) * 100
gen hexpIndpaid_adjusted = (hexpIndpaid/ cpi) * 100

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

bysort months_between agegroup: egen hexpFampaid_median_dage = median(hexpFampaid_adjusted)
bysort months_between agegroup: egen hexpIndpaid_median_dage = median(hexpIndpaid_adjusted)
//Dementia
bysort months_between dementia: egen hexpFampaid_median_dementia = median(hexpFampaid_adjusted)
bysort months_between dementia: egen hexpIndpaid_median_dementia = median(hexpIndpaid_adjusted)

bysort months_between phys: egen hexpFampaid_median_phys = median(hexpFampaid_adjusted)
bysort months_between phys: egen hexpIndpaid_median_phys = median(hexpIndpaid_adjusted)

bysort months_between residence: egen hexpFampaid_median_residence = median(hexpFampaid_adjusted)
bysort months_between residence: egen hexpIndpaid_median_residence = median(hexpIndpaid_adjusted)

bysort months_between incomegroup: egen hexpFampaid_median_incomegroup = median(hexpFampaid_adjusted)
bysort months_between incomegroup: egen hexpIndpaid_median_incomegroup = median(hexpIndpaid_adjusted)

bysort months_between incomegrouppercap: egen hexpFampaid_median_incomegroup2 = median(hexpFampaid_adjusted)
bysort months_between incomegrouppercap: egen hexpIndpaid_median_incomegroup2 = median(hexpIndpaid_adjusted)


bysort months_between agegroup1: egen hexpFampaid_median_dage1 = median(hexpFampaid_adjusted)
bysort months_between agegroup1: egen hexpIndpaid_median_dage1 = median(hexpIndpaid_adjusted)
//轨迹图

//traj, var(hexpFampaid_adjusted) indep(months_between) model(cnorm) min(0) max(200000) order(3 3 2)
//trajplot, xtitle(Months) ytitle(hexpFampaid) xlabel(0(6)60) ci
//graph export "/Users/JACKSON/Desktop/EOL Graph/31 Traj Family", replace
//traj, var(hexpIndpaid_adjusted) indep(months_between) model(cnorm) min(0) max(200000) order(3 3 2)
//trajplot, xtitle(Months) ytitle(hexpIndpaid) xlabel(0(6)60) ci
//graph export "/Users/JACKSON/Desktop/EOL Graph/32 Traj Ind.jpg", replace
// 总图
twoway line hexpFampaid_median hexpIndpaid_median months_between, ///
       xlabel(0(6)60)
graph export "/Users/JACKSON/Desktop/EOL Graph/1 Total graph.jpg", replace
// ADL分图 Fam
twoway (line hexpFampaid_median_adl months_between if adl == 1, sort) ///
       (line hexpFampaid_median_adl months_between if adl == 0, sort), ///
       title("Family Cost Comparison by ADL Status") ///
       xtitle("Months") ytitle("Cost") ///
	   xlabel(0(6)60) ///
       legend(order(1 "adl = 1" 2 "adl = 0"))
	   
graph export "/Users/JACKSON/Desktop/EOL Graph/2 Family ADL graph.jpg", replace

twoway (line hexpIndpaid_median_adl months_between if adl == 1, sort) ///
       (line hexpIndpaid_median_adl months_between if adl == 0, sort), ///
       title("Individual Cost Comparison by ADL Status") ///
       xtitle("Months") ytitle("Cost") ///
	   xlabel(0(6)60) ///
	   legend(order(1 "adl = 1" 2 "adl = 0"))
graph export "/Users/JACKSON/Desktop/EOL Graph/3 Individual ADL graph.jpg", replace
// IADL Fam分图
twoway (line hexpFampaid_median_iadl months_between if iadl == 1, sort) ///
       (line hexpFampaid_median_iadl months_between if iadl == 0, sort), ///
	   title("Family Cost Comparison by IADL Status") ///
       xtitle("Months") ytitle("Cost") ///
	   xlabel(0(6)60) ///
	   legend(order(1 "iadl = 1" 2 "iadl = 0" ))
	   graph export "/Users/JACKSON/Desktop/EOL Graph/4 Family IADL graph.jpg", replace
/// IADL IND分图
twoway (line hexpIndpaid_median_iadl months_between if iadl == 1, sort) ///
       (line hexpIndpaid_median_iadl months_between if iadl == 0, sort), ///
       title("Individual Cost Comparison by IADL Status") ///
       xtitle("Months") ytitle("Cost") ///
	   xlabel(0(6)60) ///
	   legend(order(1 "iadl = 1" 2 "iadl = 0" ))
	   graph export "/Users/JACKSON/Desktop/EOL Graph/5 Individual IADL graph.jpg", replace
// ciBi FAM分图
twoway (line hexpFampaid_median_ciBi months_between if ciBi == 1, sort) ///
       (line hexpFampaid_median_ciBi months_between if ciBi == 0, sort), ///
	   title("Family Cost Comparison by ciBi Status") ///
       xtitle("Months") ytitle("Cost") ///
	   xlabel(0(6)60) ///
	   legend(order(1 "ciBi = 1" 2 "ciBi = 0" ))
	   graph export "/Users/JACKSON/Desktop/EOL Graph/6 Family ciBi graph.jpg", replace
// ciBi IND分图  
twoway (line hexpIndpaid_median_ciBi months_between if ciBi == 1, sort) ///
       (line hexpIndpaid_median_ciBi months_between if ciBi == 0, sort), ///
       title("Individual Cost Comparison by ciBi Status") ///
       xtitle("Months") ytitle("Cost") ///
	   xlabel(0(6)60) ///
	   legend(order(1 "ciBi = 1" 2 "ciBi = 0" ))
	   graph export "/Users/JACKSON/Desktop/EOL Graph/7 Individual ciBi graph.jpg", replace
// Coresidence FAM分图  
 twoway (line hexpFampaid_median_coresidence months_between if coresidence == 1, sort) ///
       (line hexpFampaid_median_coresidence months_between if coresidence == 2, sort), ///
       title("Family Cost Comparison by Coresidence Status") ///
       xtitle("Months") ytitle("Cost") ///
	   xlabel(0(6)60) ///
	   legend(order(1 "with household members" 2 "alone"))
		graph export "/Users/JACKSON/Desktop/EOL Graph/8 Family Coresidence graph.jpg", replace
// Coresidence IND分图
twoway (line hexpIndpaid_median_coresidence months_between if coresidence == 1, sort) ///
       (line hexpIndpaid_median_coresidence months_between if coresidence == 2, sort), ///
	   title("Individual Cost Comparison by Coresidence Status") ///
       xtitle("Months") ytitle("Cost") ///
	   xlabel(0(6)60) ///
	   legend(order(1 " with household members" 2 "alone"))
graph export "/Users/JACKSON/Desktop/EOL Graph/9 Individual Coresidence graph.jpg", replace
// Gender FAM分图
twoway (line hexpFampaid_median_gender months_between if gender == 1, sort) ///
       (line hexpFampaid_median_gender months_between if gender == 0, sort), ///
       title("Family Cost Comparison by Gender") ///
       xtitle("Months") ytitle("Cost") ///
	   xlabel(0(6)60) ///
	   legend(order(1 "gender = 1" 2 "gender = 0"))
	   graph export "/Users/JACKSON/Desktop/EOL Graph/10 Family Gender graph.jpg", replace
// Gender IND分图twoway
twoway (line hexpIndpaid_median_gender months_between if gender == 1 , sort) ///
       (line hexpIndpaid_median_gender months_between if gender == 0 , sort), ///
       title("Individual Cost Comparison by Gender") ///
       xtitle("Months") ytitle("Cost") ///
	   xlabel(0(6)60) ///
	   legend(order(1 "gender = 1" 2 "gender = 0"))
	   graph export "/Users/JACKSON/Desktop/EOL Graph/11 Individual Gender graph.jpg", replace
// Dementia FAM分图
twoway (line hexpFampaid_median_dementia months_between if dementia == 1 | dementia ==2 , sort) ///
       (line hexpFampaid_median_dementia months_between if dementia == 0 , sort), ///
       title("Family Cost Comparison by Dementia") ///
       xtitle("Months") ytitle("Cost") ///
	   xlabel(0(6)60) ///
	   legend(order(1 "Dementia = 1 or 2" 2 "Dementia = 0"))
	   graph export "/Users/JACKSON/Desktop/EOL Graph/12 Family Dementia graph.jpg", replace
// Dementia IND分图
twoway (line hexpIndpaid_median_dementia months_between if dementia == 1| dementia == 2, sort) ///
       (line hexpIndpaid_median_dementia months_between if dementia == 0 , sort), ///
       title("Individual Cost Comparison by Dementia") ///
       xtitle("Months") ytitle("Cost") ///
	   xlabel(0(6)60) ///
	   legend(order(1 "Dementia = 1 or 2" 2 "Dementia = 0"))
	   graph export "/Users/JACKSON/Desktop/EOL Graph/13 Individual Dementia graph.jpg", replace
	   
	   
	   // Age IND分图
twoway (line hexpIndpaid_median_dage1 months_between if agegroup1==1, sort) ///
       (line hexpIndpaid_median_dage1 months_between if agegroup1==2, sort), ///
       title("Individual Cost Comparison by Age") ///
       xtitle("Months") ytitle("Cost") ///
	   xlabel(0(6)60) ///
       legend(order(1 "65-91" 2 "91-125" ))
graph export "/Users/JACKSON/Desktop/EOL Graph/27 Individual Death Age graph.jpg", replace
// Age FAM分图
twoway (line hexpFampaid_median_dage1 months_between if agegroup1==1, sort) ///
       (line hexpFampaid_median_dage1 months_between if agegroup1==2, sort), ///
        title("Family Cost Comparison by death age") ///
       xtitle("Months") ytitle("Cost") ///
	   xlabel(0(6)60) ///
	   legend(order(1 "65-91" 2 "91-125"))
	   graph export "/Users/JACKSON/Desktop/EOL Graph/28 Family Death Age graph.jpg", replace


// Age IND分图
twoway (line hexpIndpaid_median_dage months_between if agegroup==1, sort) ///
       (line hexpIndpaid_median_dage months_between if agegroup==2, sort) ///
       (line hexpIndpaid_median_dage months_between if agegroup==3, sort), ///
       title("Individual Cost Comparison by Age") ///
       xtitle("Months") ytitle("Cost") ///
	   xlabel(0(6)60) ///
       legend(order(1 "65-84" 2 "85-104" 3 "105-125" ))
graph export "/Users/JACKSON/Desktop/EOL Graph/14 Individual Death Age graph.jpg", replace

// Age FAM分图
twoway (line hexpFampaid_median_dage months_between if agegroup==1, sort) ///
       (line hexpFampaid_median_dage months_between if agegroup==2, sort) ///
       (line hexpFampaid_median_dage months_between if agegroup==3, sort), ///
        title("Family Cost Comparison by death age") ///
       xtitle("Months") ytitle("Cost") ///
	   xlabel(0(6)60) ///
	   legend(order(1 "65-84" 2 "85-104" 3 "105-125"))
	   graph export "/Users/JACKSON/Desktop/EOL Graph/15 Family Death Age graph.jpg", replace
// Residence FAM分图
twoway (line hexpFampaid_median_residence months_between if residence == 1, sort) ///
       (line hexpFampaid_median_residence months_between if residence == 2, sort), ///
       title("Family Cost Comparison by Residence") ///
       xtitle("Months") ytitle("Cost") ///
	   xlabel(0(6)60) ///
	   legend(order(1 "urban (city or town)" 2 "rural"))
	   graph export "/Users/JACKSON/Desktop/EOL Graph/19 Family Residence graph.jpg", replace
// Residence IND分图twoway
twoway (line hexpIndpaid_median_residence months_between if residence == 1 , sort) ///
       (line hexpIndpaid_median_residence months_between if residence == 2, sort), ///
       title("Individual Cost Comparison by Residence") ///
       xtitle("Months") ytitle("Cost") ///
	   xlabel(0(6)60) ///
	   legend(order(1 "urban (city or town) " 2 "rural"))
	   graph export "/Users/JACKSON/Desktop/EOL Graph/20 Individual Residence graph.jpg", replace
// Phys FAM分图
twoway (line hexpFampaid_median_phys months_between if phys == 0, sort) ///
       (line hexpFampaid_median_phys months_between if phys == 1, sort), ///
       title("Family Cost Comparison by Phys") ///
       xtitle("Months") ytitle("Cost") ///
	   xlabel(0(6)60) ///
	   legend(order(1 "Phys = 0" 2 "Phys = 1"))
	   graph export "/Users/JACKSON/Desktop/EOL Graph/21 Family Phys graph.jpg", replace
// Phys IND分图twoway
twoway (line hexpIndpaid_median_phys months_between if phys == 0, sort) ///
       (line hexpIndpaid_median_phys months_between if phys == 1, sort), ///
       title("Individual Cost Comparison by Phys") ///
       xtitle("Months") ytitle("Cost") ///
	   xlabel(0(6)60) ///
	   legend(order(1 "Phys = 0 " 2 "Phys = 1"))
	   graph export "/Users/JACKSON/Desktop/EOL Graph/22 Individual Phys graph.jpg", replace
	   // Incomegroup IND分图
twoway (line hexpIndpaid_median_incomegroup months_between if incomegroup==1, sort) ///
       (line hexpIndpaid_median_incomegroup months_between if incomegroup==2, sort), ///
       title("Individual Cost Comparison by Income") ///
       xtitle("Months") ytitle("Cost") ///
	   xlabel(0(6)60) ///
       legend(order(1 "Income <=20000" 2 "Income >20000" ))
graph export "/Users/JACKSON/Desktop/EOL Graph/23 Individual Income graph.jpg", replace
// Incomegroup FAM分图
twoway (line hexpFampaid_median_incomegroup months_between if incomegroup==1, sort) ///
       (line hexpFampaid_median_incomegroup months_between if incomegroup==2, sort), ///
        title("Family Cost Comparison by Income") ///
       xtitle("Months") ytitle("Cost") ///
	   xlabel(0(6)60) ///
	   legend(order(1 "Income <=20000" 2 "Income >20000"))
	   graph export "/Users/JACKSON/Desktop/EOL Graph/24 Family Income graph.jpg", replace
// Incomegrouppercap IND分图
twoway (line hexpIndpaid_median_incomegroup2 months_between if incomegrouppercap==1, sort) ///
       (line hexpIndpaid_median_incomegroup2 months_between if incomegrouppercap==2, sort), ///
       title("Individual Cost Comparison by Income") ///
       xtitle("Months") ytitle("Cost") ///
	   xlabel(0(6)60) ///
       legend(order(1 "Incomepercap <=3000" 2 "Incomepercap >3000" ))
graph export "/Users/JACKSON/Desktop/EOL Graph/25Individual Income Per capita graph.jpg", replace
// Incomegrouppercap FAM分图
twoway (line hexpFampaid_median_incomegroup2 months_between if incomegrouppercap==1, sort) ///
       (line hexpFampaid_median_incomegroup2 months_between if incomegrouppercap==2, sort), ///
        title("Family Cost Comparison by Income") ///
       xtitle("Months") ytitle("Cost") ///
	   xlabel(0(6)60) ///
	   legend(order(1 "Income Percap <=3000" 2 "Income Percap >3000"))
	   graph export "/Users/JACKSON/Desktop/EOL Graph/26 Family Income Per capita graph.jpg", replace
	   
restore
preserve

// Retired 与死亡间隔分图
drop if missing(dthdate)
drop if missing(retiredYear)
drop if missing(hexpFampaid)
drop if missing(hexpIndpaid)
gen retiredYear_year = year(retiredYear)
gen retire_year_gap = (dthdate_year - retiredYear_year) 
histogram retire_year_gap, title("Frequency of Years between retired and death")
graph export "/Users/JACKSON/Desktop/EOL Graph/16 Retired graph.jpg", replace




  
  
  

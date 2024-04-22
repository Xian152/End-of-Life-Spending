*** traj
* edit based on the latest dataset
use "${OUT}/analyses.dta",clear
	

	drop if deathstatus == 1
	
	keep id wave  frailID frailmissingver1 intdate

	replace frailID = . if frailmissingver1  >=10
	
	drop frailmissingver1
	
	drop if frailID== .
	
	bysort id:gen count = _N
	
	drop if count == 1 
	
	sort id wave
	
	bysort id : gen order = _n
	
	drop wave
	
	reshape wide frailID intdate,i(id) j(order)
	
	gen t1 = intdate2-intdate1
	gen t2 = intdate3-intdate2
	gen t3 = intdate4-intdate3
	gen t4 = intdate5-intdate4
	gen t5 = intdate6-intdate5
	gen t6 = intdate7-intdate6
	gen t7 = intdate8-intdate7
	
	
	replace t2=t1+t2
	replace t3=t2+t3
	replace t4=t3+t4
	replace t5=t4+t5
	replace t6=t5+t6
	replace t7=t6+t7
	
	
	
save "${OUT}/analyses_frailty.dta",replace	

export delimited using "/Users/x152/Library/CloudStorage/Box-Box/HALSA-Healthy Aging - CLHLS/P24 End-of-life care expenditure patterns and causes of death/Data Analyses/output/analyses_frailty_1105.csv", replace


********************** prepare data for traj ******************
use "${OUT}/analyses.dta",clear
	* test 差值
	preserve
		gen intdate_year = year(intdate)
		gen intdate_month = month(intdate)
		gen dthdate_year = year(dthdate)
		gen dthdate_month = month(dthdate)
		gen months_between = (dthdate_year - intdate_year) * 12 + (dthdate_month - intdate_month)

		bysort id: egen select = min(months_between)
		keep if select == 0
		
		keep id hexpTotalpaid wave months_between deathstatus
		keep if deathstatus == 1 | months_between ==0
		sort id wave
		bysort id: gen order = _n
		keep id order hexp
		reshape wide hexp,i(id) j(order)
		
		ttest hexpTotalpaid1 = hexpTotalpaid2
	restore
	
	* month== 0
	gen intdate_year = year(intdate)
	gen intdate_month = month(intdate)
	gen dthdate_year = year(dthdate)
	gen dthdate_month = month(dthdate)
	gen months_between = (dthdate_year - intdate_year) * 12 + (dthdate_month - intdate_month)

	bysort id: egen select = min(months_between)
	
	gen wave_alt = wave if deathstatus !=1 
	
	bysort id : egen maxwave_alt=max(wave_alt)
	
	replace hexpTotalpaid = . if select==0 & maxwave_alt== wave_alt
	
	drop wave_alt maxwave_alt select
	
	gen year = dthyear
	replace year =yearin if year ==.
	
	* CPI 
	merge m:1 year using "${SOURCE}/CPI.dta"
	drop if _m == 2
	drop _m
	
	foreach k in hhIncomepercap hhIncome hexpFinanceissue DcarehexpD hexpFampaidIP hexpTotalpaidIP hexpFampaidOP hexpTotalpaidOP hexpTotalpaid DOOPhexp hexpFampaid ADLhexpcare{
		replace  `k' = (`k' / cpi) * 100
	}

	*保留死亡样本
	keep if deathsample == 1 

	* 区分死亡和无回答的缺失
	foreach k in iadl coresidence ciBi residence {
		replace `k' = 99999 if deathstatus == 1
	}	
	* 填补死亡期的urban rural
	sort id wave
	bysort id (wave): replace residence = residence[_n-1] if deathstatus == 1

	* 取log
	foreach k in  hexpTotalpaidOP hexpTotalpaidIP hexpTotalpaid  {
		replace `k' = 1 if `k' == 0 
		
	}
	foreach k in  hexpTotalpaidOP hexpTotalpaidIP hexpTotalpaid   {
		gen log_`k' = log(`k')
		
	}

	* 准备traj
	keep id wave deathstatus log_*  intdate dthdate age dage gender 
	
	replace age = dage if age == .

	replace intdate =  dthdate if deathstatus == 1 
	
	bysort id:gen count = _N
	drop if count == 1 
	
	gsort id -wave
	bysort id : gen order = _n
	
	drop wave deathstatus  dthdate 
	
	reshape wide log_hexpTotalpaidOP log_hexpTotalpaidIP log_hexpTotalpaid  age intdate,i(id) j(order)		
	
	drop *7* 
	drop *6* 
	drop *8
	
	
	* 变量名加上_做区分
	foreach k in 1 2 3 4 5 {
		foreach var of varlist *`k'{
			local b = subinstr("`var'","`k'","",.)
			ren `b'`k' `b'_`k'
		}
	}

	* 处理date
	gen month_1 = 0
	gen month_2 = round(-(intdate_2 - intdate_1)/30)
	gen month_3 = round(-(intdate_3 - intdate_1)/30)
	gen month_4 = round(-(intdate_4 - intdate_1)/30)
	gen month_5 = round(-(intdate_5 - intdate_1)/30)

	
save "${OUT}/analyses_traj.dta",replace	

********************** construct traj ******************
/*
use "${OUT}/analyses_traj.dta",clear
********************** hexpFampaid ******************
	putexcel set "${OUT}/analyses_traj_log_hexpFampaid.xls" ,replace
	putexcel A1 = "group"
	putexcel B1 = "e(BIC_N_data)"
	putexcel C1 = "e(BIC_n_subjects)"
	putexcel D1 = "e(AIC)"
	putexcel E1 = "e(ll)"
	putexcel F1 = "AvePP-1"
	putexcel G1 = "AvePP-2"
	putexcel H1 = "AvePP-3"
	local i = 2
	
	gen temp = ""
	log using "${OUT}/analyses_traj_log_hexpFampaid.log",replace
	foreach k in  "2 2 2" "2 2 3"  "2 3 2" "3 2 2"  "3 2 3" "3 3 3" {
	qui replace temp = "------------------`k'"
	tab temp
	traj, var(log_hexpFampaid_1 log_hexpFampaid_2 log_hexpFampaid_3 log_hexpFampaid_4 log_hexpFampaid_5)  indep(month_1 month_2 month_3 month_4 month_5) model(cnorm) min(0) max(13) risk(gender dage) tcov(age_1 age_2 age_3 age_4 age_5)  order(`k') 
	local a = e(BIC_N_data)
	local b = e(BIC_n_subjects)
	local c = e(AIC)
	local d = e(ll)
	
	trajplot,xtitle("hexpFampaid—`k'")   ylabel(0(2)13) xlabel(0(20)130)
	graph save "${OUT}/analyses_traj_log_hexpFampaid—`k'.gph",replace

	sum _traj_ProbG1 
	local ave1 = r(mean)
	sum _traj_ProbG2
	local ave2 = r(mean)
	sum _traj_ProbG3
	local ave3 = r(mean)
		
	putexcel A`i' = "`k'"
	putexcel B`i' = "`a'"
	putexcel C`i' = "`b'"
	putexcel D`i' = "`c'"
	putexcel E`i' = "`d'"
	putexcel F`i' = "`ave1'"
	putexcel G`i' = "`ave2'"
	putexcel H`i' = "`ave3'"
	
	local i = `i' + 1
	}
	log close
		
********************** hexpFampaidIP ******************
use "${OUT}/analyses_traj.dta",clear
	
	putexcel set "${OUT}/analyses_traj_log_hexpFampaidIP.xls" ,replace
	putexcel A1 = "group"
	putexcel B1 = "e(BIC_N_data)"
	putexcel C1 = "e(BIC_n_subjects)"
	putexcel D1 = "e(AIC)"
	putexcel E1 = "e(ll)"
	putexcel F1 = "AvePP-1"
	putexcel G1 = "AvePP-2"
	putexcel H1 = "AvePP-3"
	gen temp = ""
	local i = 2
	log using "${OUT}/analyses_traj_log_hexpFampaidIP.log",replace
	foreach k in  "2 2 2" "2 2 3"  "2 3 2" "3 2 2"  "3 2 3" "3 3 3" {
	qui replace temp = "------------------`k'"
	tab temp
	traj, var(log_hexpFampaid_1 log_hexpFampaid_2 log_hexpFampaid_3 )  indep(month_1 month_2 month_3 ) model(cnorm) min(0) max(13) risk(gender dage) tcov(age_1 age_2 age_3 )  order(`k') 
	local a = e(BIC_N_data)
	local b = e(BIC_n_subjects)
	local c = e(AIC)
	local d = e(ll)
	
	
	trajplot,xtitle("hexpFampaidIP—`k'")   ylabel(0(2)13) xlabel(0(10)60)
	graph save "${OUT}/analyses_traj_log_hexpFampaidIP—`k'.gph",replace

	sum _traj_ProbG1 
	local ave1 = r(mean)
	sum _traj_ProbG2
	local ave2 = r(mean)
	sum _traj_ProbG3
	local ave3 = r(mean)
		
	putexcel A`i' = "`k'"
	putexcel B`i' = "`a'"
	putexcel C`i' = "`b'"
	putexcel D`i' = "`c'"
	putexcel E`i' = "`d'"
	putexcel F`i' = "`ave1'"
	putexcel G`i' = "`ave2'"
	putexcel H`i' = "`ave3'"
	
	local i = `i' + 1
	}
	log close
	
********************** hexpFampaidOP ******************	
use "${OUT}/analyses_traj.dta",clear

	putexcel set "${OUT}/analyses_traj_log_hexpFampaidOP.xls" ,replace
	putexcel A1 = "group"
	putexcel B1 = "e(BIC_N_data)"
	putexcel C1 = "e(BIC_n_subjects)"
	putexcel D1 = "e(AIC)"
	putexcel E1 = "e(ll)"
	putexcel F1 = "AvePP-1"
	putexcel G1 = "AvePP-2"
	putexcel H1 = "AvePP-3"
	gen temp = ""
	local i = 2
	log using "${OUT}/analyses_traj_log_hexpFampaidOP.log",replace
	foreach k in  "2 2 2" "2 2 3"  "2 3 2" "3 2 2"  "3 2 3" "3 3 3" {
	qui replace temp = "------------------`k'"
	tab temp
	traj, var(log_hexpFampaid_1 log_hexpFampaid_2 log_hexpFampaid_3 )  indep(month_1 month_2 month_3 ) model(cnorm) min(0) max(13) risk(gender dage) tcov(age_1 age_2 age_3 )  order(`k') 
	local a = e(BIC_N_data)
	local b = e(BIC_n_subjects)
	local c = e(AIC)
	local d = e(ll)
	
	
	trajplot,xtitle("hexpFampaidOP—`k'")   ylabel(0(2)13) xlabel(0(10)60)
	graph save "${OUT}/analyses_traj_log_hexpFampaidOP—`k'.gph",replace

	sum _traj_ProbG1 
	local ave1 = r(mean)
	sum _traj_ProbG2
	local ave2 = r(mean)
	sum _traj_ProbG3
	local ave3 = r(mean)
		
	putexcel A`i' = "`k'"
	putexcel B`i' = "`a'"
	putexcel C`i' = "`b'"
	putexcel D`i' = "`c'"
	putexcel E`i' = "`d'"
	putexcel F`i' = "`ave1'"
	putexcel G`i' = "`ave2'"
	putexcel H`i' = "`ave3'"
	putexcel E`i' = "`d'"
	
	local i = `i' + 1
	}
	log close
*/		
********************** hexpTotalpaid ******************	
use "${OUT}/analyses_traj.dta",clear

	putexcel set "${OUT}/analyses_traj_log_hexpTotalpaid.xls" ,replace
	putexcel A1 = "group"
	putexcel B1 = "e(BIC_N_data)"
	putexcel C1 = "e(BIC_n_subjects)"
	putexcel D1 = "e(AIC)"
	putexcel E1 = "e(ll)"
	putexcel F1 = "AvePP-1"
	putexcel G1 = "AvePP-2"
	putexcel H1 = "AvePP-3"
	putexcel I1 = "group share1"
	putexcel J1 = "group share2"
	putexcel K1 = "group share3"	

	
	gen temp = ""
	local i = 2
	log using "${OUT}/三组/analyses_traj_log_hexpTotalpaid.log",replace
	foreach k in  "2 2 2" "2 2 1" "2 1 2" "1 2 2" "1 2 1" "2 1 1" "1 1 2" "1 1 1" {
	preserve
	qui replace temp = "------------------`k'"
	tab temp
	traj, var(log_hexpTotalpaid_1 log_hexpTotalpaid_2 log_hexpTotalpaid_3 log_hexpTotalpaid_4 log_hexpTotalpaid_5)  indep(month_1 month_2 month_3 month_4 month_5) model(cnorm) min(0) max(13) risk(gender dage) tcov(age_1 age_2 age_3 age_4 age_5)  order(`k') 
	local a = e(BIC_N_data)
	local b = e(BIC_n_subjects)
	local c = e(AIC)
	local d = e(ll)
	
	trajplot,xtitle("hexpTotalpaid—`k'")   ylabel(0(2)13) xlabel(0(20)130)
	graph save "${OUT}/三组/analyses_traj_log_hexpTotalpaid—`k'.gph",replace

	* seperately calculate 每组占比，小于5%的要在未来删除掉
	count 
	local gnumber = r(N) 
	foreach groupnumb in 1 2 3 {
		count if _traj_Group == `groupnumb'
		local g`groupnumb' = r(N) 
		gen share`groupnumb' = `g`groupnumb'' /`gnumber'
	}
	sum share1 
	local output = r(mean)
	putexcel I`i' = "`output'"
	sum share2
	local output = r(mean)
	putexcel J`i' = "`output'"
	sum share3 
	local output = r(mean)
	putexcel K`i' = "`output'"	
	
    *updating code to drop missing assigned observations
    drop if missing(_traj_Group)
    *now lets look at the average posterior probability
	gen Mp = 0
	foreach mm of varlist _traj_ProbG* {
	    replace Mp = `mm' if `mm' > Mp 
	}
    sort _traj_Group
    *and the odds of correct classification
    by _traj_Group: gen countG = _N
    by _traj_Group: egen groupAPP = mean(Mp)
    by _traj_Group: gen counter = _n
    gen n = groupAPP/(1 - groupAPP)
    gen p = countG/ _N
    gen d = p/(1-p)
    gen occ = n/d
    *Estimated proportion for each group
    scalar c = 0
    gen TotProb = 0
    foreach tt of varlist _traj_ProbG* {
       scalar c = c + 1
       quietly summarize `tt'
       replace TotProb = r(sum)/ _N if _traj_Group == c 
    }
	gen d_pp = TotProb/(1 - TotProb)
	gen occ_pp = n/d_pp
    *This displays the group number [_traj_~p], 
    *the count per group (based on the max post prob), [countG]
    *the average posterior probability for each group, [groupAPP]
    *the odds of correct classification (based on the max post prob group assignment), [occ] 
    *the odds of correct classification (based on the weighted post. prob), [occ_pp]
    *and the observed probability of groups versus the probability [p]
    *based on the posterior probabilities [TotProb]
	keep if counter == 1
	sum groupAPP if  _traj_Group == 1
	local ave1 = r(mean)
	sum groupAPP if  _traj_Group == 2
	local ave2 = r(mean)
	sum groupAPP if  _traj_Group == 3
	local ave3 = r(mean)	
	
	
/*	sum _traj_ProbG1 
	local ave1 = r(mean)
	sum _traj_ProbG2
	local ave2 = r(mean)
	sum _traj_ProbG3
	local ave3 = r(mean)
*/		
	putexcel A`i' = "`k'"
	putexcel B`i' = "`a'"
	putexcel C`i' = "`b'"
	putexcel D`i' = "`c'"
	putexcel E`i' = "`d'"
	putexcel F`i' = "`ave1'"
	putexcel G`i' = "`ave2'"
	putexcel H`i' = "`ave3'"
	
	restore
	
	local i = `i' + 1
	}
	log close
	
********************** hexpTotalpaidIP ******************	
use "${OUT}/analyses_traj.dta",clear

	putexcel set "${OUT}/analyses_traj_log_hexpTotalpaidIP.xls" ,replace
	putexcel A1 = "group"
	putexcel B1 = "e(BIC_N_data)"
	putexcel C1 = "e(BIC_n_subjects)"
	putexcel D1 = "e(AIC)"
	putexcel E1 = "e(ll)"
	putexcel F1 = "AvePP-1"
	putexcel G1 = "AvePP-2"
	putexcel H1 = "AvePP-3"
	putexcel I1 = "group share1"
	putexcel J1 = "group share2"
	putexcel K1 = "group share3"	

	gen temp = ""
	local i = 2
	log using "${OUT}/三组/analyses_traj_log_hexpTotalpaidIP.log",replace
	foreach k in  "2 2 2" "2 2 1" "2 1 2" "1 2 2" "1 2 1" "2 1 1" "1 1 2" "1 1 1" {
	preserve
	qui replace temp = "------------------`k'"
	tab temp
	traj, var(log_hexpTotalpaidIP_2 log_hexpTotalpaidIP_3 )  indep(month_2 month_3 ) model(cnorm) min(-10) max(13) risk(gender dage) tcov(age_2 age_3 )  order(`k') 
	local a = e(BIC_N_data)
	local b = e(BIC_n_subjects)
	local c = e(AIC)
	local d = e(ll)
	
	
	trajplot,xtitle("hexpTotalpaidIP—`k'")   ylabel(0(2)13) xlabel(0(10)60)
	graph save "${OUT}/三组/analyses_traj_log_hexpTotalpaidIP—`k'.gph",replace

 	* seperately calculate 每组占比，小于5%的要在未来删除掉
	count 
	local gnumber = r(N) 
	foreach groupnumb in 1 2 3 {
		count if _traj_Group == `groupnumb'
		local g`groupnumb' = r(N) 
		gen share`groupnumb' = `g`groupnumb'' /`gnumber'
	}
	sum share1 
	local output = r(mean)
	putexcel I`i' = "`output'"
	sum share2
	local output = r(mean)
	putexcel J`i' = "`output'"
	sum share3 
	local output = r(mean)
	putexcel K`i' = "`output'"	
	
	*updating code to drop missing assigned observations
    drop if missing(_traj_Group)
    *now lets look at the average posterior probability
	gen Mp = 0
	foreach mm of varlist _traj_ProbG* {
	    replace Mp = `mm' if `mm' > Mp 
	}
    sort _traj_Group
    *and the odds of correct classification
    by _traj_Group: gen countG = _N
    by _traj_Group: egen groupAPP = mean(Mp)
    by _traj_Group: gen counter = _n
    gen n = groupAPP/(1 - groupAPP)
    gen p = countG/ _N
    gen d = p/(1-p)
    gen occ = n/d
    *Estimated proportion for each group
    scalar c = 0
    gen TotProb = 0
    foreach tt of varlist _traj_ProbG* {
       scalar c = c + 1
       quietly summarize `tt'
       replace TotProb = r(sum)/ _N if _traj_Group == c 
    }
	gen d_pp = TotProb/(1 - TotProb)
	gen occ_pp = n/d_pp
    *This displays the group number [_traj_~p], 
    *the count per group (based on the max post prob), [countG]
    *the average posterior probability for each group, [groupAPP]
    *the odds of correct classification (based on the max post prob group assignment), [occ] 
    *the odds of correct classification (based on the weighted post. prob), [occ_pp]
    *and the observed probability of groups versus the probability [p]
    *based on the posterior probabilities [TotProb]
	keep if counter == 1
	sum groupAPP if  _traj_Group == 1
	local ave1 = r(mean)
	sum groupAPP if  _traj_Group == 2
	local ave2 = r(mean)
	sum groupAPP if  _traj_Group == 3
	local ave3 = r(mean)	
		
	putexcel A`i' = "`k'"
	putexcel B`i' = "`a'"
	putexcel C`i' = "`b'"
	putexcel D`i' = "`c'"
	putexcel E`i' = "`d'"
	putexcel F`i' = "`ave1'"
	putexcel G`i' = "`ave2'"
	putexcel H`i' = "`ave3'"
	
	restore
	local i = `i' + 1
	}
	log close
	
********************** hexpTotalpaidOP ******************	
use "${OUT}/analyses_traj.dta",clear

	putexcel set "${OUT}/analyses_traj_log_hexpTotalpaidOP.xls" ,replace
	putexcel A1 = "group"
	putexcel B1 = "e(BIC_N_data)"
	putexcel C1 = "e(BIC_n_subjects)"
	putexcel D1 = "e(AIC)"
	putexcel E1 = "e(ll)"
	putexcel F1 = "AvePP-1"
	putexcel G1 = "AvePP-2"
	putexcel H1 = "AvePP-3"
	putexcel I1 = "group share1"
	putexcel J1 = "group share2"
	putexcel K1 = "group share3"	

	gen temp = ""
	local i = 2
	log using "${OUT}/三组/analyses_traj_log_hexpTotalpaidOP.log",replace
	foreach k in  "2 2 2" "2 2 1" "2 1 2" "1 2 2" "1 2 1" "2 1 1" "1 1 2" "1 1 1" {
	preserve
	qui replace temp = "------------------`k'"
	tab temp
	traj, var(log_hexpTotalpaidOP_2 log_hexpTotalpaidOP_3 )  indep( month_2 month_3 ) model(cnorm) min(-1) max(13) risk(gender dage) tcov(age_2 age_3 )  order(`k') 
	local a = e(BIC_N_data)
	local b = e(BIC_n_subjects)
	local c = e(AIC)
	local d = e(ll)
	
	
	trajplot,xtitle("hexpTotalpaidOP—`k'")   ylabel(0(2)13) xlabel(0(10)60)
	graph save "${OUT}/三组/analyses_traj_log_hexpTotalpaidOP—`k'.gph",replace
	
	* seperately calculate 每组占比，小于5%的要在未来删除掉
	count 
	local gnumber = r(N) 
	foreach groupnumb in 1 2 3 {
		count if _traj_Group == `groupnumb'
		local g`groupnumb' = r(N) 
		gen share`groupnumb' = `g`groupnumb'' /`gnumber'
	}
	sum share1 
	local output = r(mean)
	putexcel I`i' = "`output'"
	sum share2
	local output = r(mean)
	putexcel J`i' = "`output'"
	sum share3 
	local output = r(mean)
	putexcel K`i' = "`output'"	
	
    *updating code to drop missing assigned observations
    drop if missing(_traj_Group)
    *now lets look at the average posterior probability
	gen Mp = 0
	foreach mm of varlist _traj_ProbG* {
	    replace Mp = `mm' if `mm' > Mp 
	}
    sort _traj_Group
    *and the odds of correct classification
    by _traj_Group: gen countG = _N
    by _traj_Group: egen groupAPP = mean(Mp)
    by _traj_Group: gen counter = _n
    gen n = groupAPP/(1 - groupAPP)
    gen p = countG/ _N
    gen d = p/(1-p)
    gen occ = n/d
    *Estimated proportion for each group
    scalar c = 0
    gen TotProb = 0
    foreach tt of varlist _traj_ProbG* {
       scalar c = c + 1
       quietly summarize `tt'
       replace TotProb = r(sum)/ _N if _traj_Group == c 
    }
	gen d_pp = TotProb/(1 - TotProb)
	gen occ_pp = n/d_pp
    *This displays the group number [_traj_~p], 
    *the count per group (based on the max post prob), [countG]
    *the average posterior probability for each group, [groupAPP]
    *the odds of correct classification (based on the max post prob group assignment), [occ] 
    *the odds of correct classification (based on the weighted post. prob), [occ_pp]
    *and the observed probability of groups versus the probability [p]
    *based on the posterior probabilities [TotProb]
	keep if counter == 1
	sum groupAPP if  _traj_Group == 1
	local ave1 = r(mean)
	sum groupAPP if  _traj_Group == 2
	local ave2 = r(mean)
	sum groupAPP if  _traj_Group == 3
	local ave3 = r(mean)	
		
	putexcel A`i' = "`k'"
	putexcel B`i' = "`a'"
	putexcel C`i' = "`b'"
	putexcel D`i' = "`c'"
	putexcel E`i' = "`d'"
	putexcel F`i' = "`ave1'"
	putexcel G`i' = "`ave2'"
	putexcel H`i' = "`ave3'"
	
	restore
	
	local i = `i' + 1
	}
	log close
	 
	 
	
	foreach k in hexpTotalpaidOP hexpTotalpaidIP hexpTotalpaid {
		graph combine "${OUT}/三组/analyses_traj_log_`k'—2 2 2.gph" "${OUT}/三组/analyses_traj_log_`k'—2 2 3.gph" "${OUT}/三组/analyses_traj_log_`k'—2 3 2.gph" "${OUT}/三组/analyses_traj_log_`k'—3 2 2.gph" "${OUT}/三组/analyses_traj_log_`k'—3 2 3.gph" "${OUT}/三组/analyses_traj_log_`k'—3 3 3.gph"
		graph export "${OUT}/三组/traj_`k'.png",replace
	}
	
	xx
export delimited using "/Users/x152/Library/CloudStorage/Box-Box/HALSA-Healthy Aging - CLHLS/P24 End-of-life care expenditure patterns and causes of death/Data Analyses/output/analyses_frailty_1105.csv", replace



	traj, var(log_hexpTotalpaid_1 log_hexpTotalpaid_2 log_hexpTotalpaid_3 log_hexpTotalpaid_4 log_hexpTotalpaid_5)  indep(month_1 month_2 month_3 month_4 month_5) model(cnorm) min(0) max(13) risk(gender dage) tcov(age_1 age_2 age_3 age_4 age_5)  order(2 2 2) 
	keep if  _traj_Group==1
	
	keep id
	duplicates drop
	
save "${OUT}/problem group 1.dta",replace

use "${OUT}/analyses.dta",clear
	merge m:1 id using "${OUT}/problem group 1.dta"
	gen problem = _m==3
	
	keep if deathstatus == 1 
	
	table1,by(problem)  vars(gender cat\ edug cat\  occu cat\  marital cat\  hhsize contn\ residence cat\   hhIncomeper contn\ adl cat\   ) 	format(%2.1f) one mis saving("${OUT}/Table1_DS1base.xls",replace) 	

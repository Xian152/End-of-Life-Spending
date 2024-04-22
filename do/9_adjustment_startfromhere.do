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

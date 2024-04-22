  use "/Volumes/expand/Data/HRS 系列/CHARLS/2015/Demographic_Background.dta",clear
	keep communityID ID ba000_w2_3
	gen wave = 2015
	tempfile t1
	save `t1',replace
 
  use "/Volumes/expand/Data/HRS 系列/CHARLS/CHARLS2018r/Demographic_Background.dta",clear
	keep communityID ID ba000_w2_3
	gen wave = 2018
	tempfile t2
	save `t2',replace
	
  use "/Volumes/expand/Data/HRS 系列/CHARLS/2013/Demographic_Background.dta"
	keep communityID ID ba000_w2_3 
	gen wave = 2013
	tempfile t3
	save `t3',replace	
	
	append using `t1'	`t2'  
	merge m:1 communityID using "/Volumes/expand/Data/HRS 系列/CHARLS/城市分类码(PSU).dta"
	drop _m
	
	tempfile t4
	
save `t4',replace 	

	merge 1:1 ID wave using "/Users/x152/Desktop/IV charls/charls_harmS.dta"

	keep if _m==3
	drop _m
	
	merge 1:1 ID wave using "/Users/x152/Desktop/charls_insurance.dta"
	keep if _m==3
	drop _m	
	codebook ID //24,172
	append using "/Users/x152/Desktop/charls_2020.dta"
	
	codebook ID //24,344
	
	gen treated = .
	replace treated = 1 if inlist(city,"承德市","齐齐哈尔市","宁波市","安庆市","上饶市","广州市","重庆市","成都市") & inlist(insurancePubMed,1,5)
	replace treated = 1 if inlist(city,"长春市","石河子市") & inlist(insurancePubMed,1,2,5)
	replace treated = 1 if inlist(city,"上海市","南通市","苏州市","青岛市","荆门市") & inlist(insurancePubMed,1,2,3,5)
	replace treated = 1 if inlist(province,"山东省") 

	replace treated = 1 if inlist(city,"承德市","齐齐哈尔市","宁波市","安庆市","上饶市","广州市","重庆市","成都市") & wave ==2020
	replace treated = 1 if inlist(city,"长春市","石河子市") & wave ==2020
	replace treated = 1 if inlist(city,"上海市","南通市","苏州市","青岛市","荆门市") & wave ==2020
	replace treated = 1 if inlist(province,"山东省") &	 wave ==2020
	
	recode treated (.=0) 
	
	gen year_id = .
	format interviewdate_ %tdYMD
	replace year_id = 1 if interviewdate_>=mdy(11,1,2016) & inlist(city,"承德市")
	replace year_id = 1 if interviewdate_>=mdy(5,1,2015) & inlist(city,"长春市")
	replace year_id = 1 if interviewdate_>=mdy(10,1,2017) & inlist(city,"齐齐哈尔市")
	replace year_id = 1 if interviewdate_>=mdy(1,1,2017) & inlist(city,"上海市")
	replace year_id = 1 if interviewdate_>=mdy(1,1,2016) & inlist(city,"南通市")
	replace year_id = 1 if interviewdate_>=mdy(6,1,2017) & inlist(city,"苏州市")
	replace year_id = 1 if interviewdate_>=mdy(12,1,2017) & inlist(city,"宁波市")
	replace year_id = 1 if interviewdate_>=mdy(1,1,2017) & inlist(city,"安庆市")
	replace year_id = 1 if interviewdate_>=mdy(1,1,2017) & inlist(city,"上饶市")
	replace year_id = 1 if interviewdate_>=mdy(7,1,2012) & inlist(city,"青岛市")
	replace year_id = 1 if interviewdate_>=mdy(11,1,2016) & inlist(city,"荆门市")
	replace year_id = 1 if interviewdate_>=mdy(8,1,2017) & inlist(city,"广州市")
	replace year_id = 1 if interviewdate_>=mdy(11,1,2017) & inlist(city,"重庆市")
	replace year_id = 1 if interviewdate_>=mdy(7,1,2017) & inlist(city,"成都市")
	replace year_id = 1 if interviewdate_>=mdy(1,1,2017) & inlist(city,"石河子市")
	
	recode  year_id (.=0)
	
	//replace treated = 0 if  adl_sum_==0
	
	keep if age_>=60
	codebook ID // 21,097 
	
	
	cap drop count
	bysort ID: gen count = _N
	
/*
      count |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |      9,467       20.31       20.31
          2 |      6,556       14.06       34.37
          3 |      8,445       18.12       52.49
          4 |     22,148       47.51      100.00
------------+-----------------------------------
      Total |     46,616      100.00
*/

	keep if count ==4
	codebook ID  //  11,630
	
	gen adl_sum_pre = adl_sum_ ==0	& year_id ==0 if adl_sum_ !=.
	bysort ID: egen meanadl_sum_pre=max(adl_sum_pre)
	replace treated= 0 if adl_sum_pre ==1
	
	gen treated_id = treated * year_id
destring ID_w1,replace
	destring ID ,replace
	codebook ID 
	
	xx
cls	
	reg ADLCare_ treated_id i.wave i.treated age gender coresidence_ residence_ marital_ educ, r cluster(city)
	outreg2 using "${OUT}/charls_adl_base.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) 
	foreach k in ADLcaregiverChild_ ADLcaregiverNonRela_ ADLcaregiverSpouse_ ADLcaregiverRelative_ ADLformalCare_ ADLinformalCare_ {
	reg `k' treated_id i.wave i.treated age gender  coresidence_ residence_ marital_ educ, r cluster(city) // [aw = ID_w1] expperca_ urban_nbs marital_
	outreg2 using "${OUT}/charls_adl_base.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  
	}	


cls	
	reg adl_sum_ treated_id i.wave i.treated age gender  coresidence_ residence_ marital_ educ, r cluster(city)
	outreg2 using "${OUT}/charls_outcome_base.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) 
	foreach k in iadl_sum_ srh_ bathing_ beding_ eating_ tolite_ urin_{
	reg `k' treated_id i.wave i.treated age gender coresidence_ residence_ marital_ educ, r cluster(city) // [aw = ID_w1] expperca_ urban_nbs marital_
	outreg2 using "${OUT}/charls_outcome_base.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  
	}	
	
cls	
		reg HexpOPInd_ treated_id i.wave i.treated age gender coresidence_ residence_ marital_ educ, r cluster(city)
		outreg2 using "${OUT}/charls_hexp_base.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) 
	foreach k in HexpIPInd_  HexpOOPIPInd_ HexpOOPOPInd_ {
		reg `k' treated_id i.wave i.treated age gender  coresidence_ residence_ marital_ educ, cluster(city) r
		outreg2 using "${OUT}/charls_hexp_base.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  
	}	
	xx
		
cls
	preserve
		drop if HexpOPInd_== .
		cap drop count
		bysort ID: gen count = _N
		keep if count ==3
		codebook ID  //   5,540
	 
		reghdfe HexpOPInd_ treated_id i.wave i.treated age gender , cluster(city) r
		outreg2 using "${OUT}/charls_hexp_base.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) 
	restore
	
	foreach k in HexpIPInd_  HexpOOPIPInd_ HexpOOPOPInd_ {
		reghdfe `k' treated_id i.wave i.treated age gender , cluster(city) r
		outreg2 using "${OUT}/charls_hexp_base.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  
	}			

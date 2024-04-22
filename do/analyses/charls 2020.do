//2020 data
use "/Volumes/expand/Data/HRS 系列/CHARLS/2020/Weights.dta",clear
	keep ID INDV_weight INDV_weight_ad2
	ren  (INDV_weight INDV_weight_ad2) (wtresp wtrespb)
	tempfile t1
save `t1'	
	
	
use "/Volumes/expand/Data/HRS 系列/CHARLS/2020/Sample_Infor.dta",clear
	keep ID  imonth iyear communityID
	merge m:1 communityID using "/Volumes/expand/Data/HRS 系列/CHARLS/城市分类码(PSU).dta"
	keep if _m ==3
	drop _m
	destring imonth iyear,replace
	gen double interviewdate_ = mdy(imonth,1, iyear)
	format  interviewdate_ %tdYMD
	keep ID province city interviewdate
	tempfile t2
save `t2'	
	
	
use "/Volumes/expand/Data/HRS 系列/CHARLS/2020/Demographic_Background.dta",clear
	ren xrage age_
	recode  ba008 (1 2 4 = 1 ) ( 3=0),gen(residence_)
	recode ba010 (1 2 3 4  = 1 ) ( 5 6 7 = 2) (8 9 10 11 =3 ),gen(educ_)
	recode ba011 (6=1 "never married") (1  = 2 "married/partnered") (2 3 4 5 = 3 "SDW"),gen(marital_)
	ren ba009 hukou
	
	keep ID  age_  residence_ educ_ marital_
	tempfile t3 
save `t3'	
	// coresidence
	
	
use "/Volumes/expand/Data/HRS 系列/CHARLS/2020/Health_Status_and_Functioning.dta",clear	
	recode da001 (997=.) ,gen(srh)
	
	// hexp??
	
	* ADL
	recode 	db001 db003 db005 db007 db009 db011 (2 3 4=1) (1=0),gen(dressing bathing  eating beding tolite urin)
	egen adl_sum = rowtotal(dressing bathing  eating beding tolite urin),mi
	gen adl = adl_sum >0 if adl_sum !=.
	
	* ADL care giver
	/*	ren (r`k'rcaany r`k'rcany r`k'rfaany) (ADLinformalCare_`k' ADLCare_`k' ADLformalCare_`k') 
		ren (r`k'rccare r`k'rccaredpm r`k'rccarehr r`k'rccaren ) (ADLcaregiverChild_`k'  ADLcaregiverChildDays_`k'  ADLcaregiverChildHours_`k'  ADLcaregiverChildNum_`k' )
		
		ren (r`k'rrcare  r`k'rrcaren ) (ADLcaregiverRelative_`k'  ADLcaregiverRelativeNum_`k' )
		
		ren (r`k'rfcare )  ( ADLcaregiverNonRela_`k' )
		ren (r`k'rrcaredpm r`k'rrcarehr)  (ADLcaregiverRelativeDays_`k'  ADLcaregiverRelativeHours_`k')
		ren (r`k'rscaredpm  ) (ADLcaregiverSpouseDays_`k')
		ren (r`k'rscarehr      ) (ADLcaregiverSpouseHours_`k'    )
	*/
		egen ADLcaregiverMiss = rowmiss( db024_s9 db024_s8 db024_s7 db024_s6 db024_s5 db024_s4 db024_s3 db024_s2 db024_s11 db024_s10 db024_s1)
		
		keep ID ADLcaregiverMiss
		
		merge 1:1 ID using `t1'
		keep if _m ==3
		drop _m
		merge 1:1 ID using `t2'
		keep if _m ==3
		drop _m		
		merge 1:1 ID using `t3'
		keep if _m ==3
		drop _m		
		gen wave = 2020
save "/Users/x152/Desktop/charls_2020.dta",replace
		
		
		
		ren db024_s1  ADLcaregiverSpouse     
		ren db024_s2  ADLcaregiverParents
		ren db024_s3  ADLcaregiverChild
	
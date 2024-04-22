use "/Volumes/expand/Data/HRS 系列/CHARLS/H_CHARLS_D_Data.dta",clear
* demograph
	foreach k in 1 2 3 4{
		ren r`k'agey age_`k'
	}
	ren ragender gender
* interview //r1iwy r2iwy r3iwy r4iwy s1iwy s2iwy s3iwy s4iwy r1iwm r2iwm r3iwm r4iwm s1iwm s2iwm s3iwm s4iwm
	foreach k in 1 2 3 4{
		ren r`k'iwy yearin_`k'
		ren r`k'iwm monthin_`k'
	}
* social economics
	ren raeducl educ
	foreach k in 1 2 3 4{
		recode r`k'mstat (8=1 "never married") (1 3 = 2 "married/partnered") (4 5 7 = 3 "SDW"),gen(marital_`k') label(marital_`k')
		
	}
	
	foreach k in 1 2 3 4{
		ren r`k'hukou hukou_`k'
	}
	foreach k in 1 2 3 4{ //h1rural h2rural h3rural h4rural
		recode r`k'rural2 (1=0) (0=1),gen(residence_`k')
	}		
	foreach k in 2 3 4{ //
		recode r`k'nhmliv (.=.),gen(coresidence_`k')
	}		
* SRH
	foreach k in 1 2 3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		recode r`k'shlta (.=.),gen(srh_`k')
	}		
*health expenditure
 	foreach k in 1 2 3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		gen HexpOOPOPInd_`k' = r`k'oopdoc1m * 12
		gen HexpOPInd_`k' = r`k'totdoc1m * 12
	} 	
 	foreach k in 1 2 3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		gen HexpOOPIPInd_`k' = r`k'oophos1y 
		gen HexpIPInd_`k' = r`k'tothos1y
	} 		
 	foreach k in 2 3 { //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		gen HexpOOPDentInd_`k' = r`k'oopden1y
		gen HexpDentInd_`k' = r`k'totden1y	
	} 
*insurance
 	foreach k in 1 2 3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		ren r`k'itearn InsurancePubMed_`k'	
		ren r`k'hipriv InsuranceComMed_`k'	
		ren r`k'hiothp InsuranceOthMed_`k'	
	}
	
* caregiver 
  	foreach k in  2 3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		ren (r`k'rcaany r`k'rcany r`k'rfaany) (ADLinformalCare_`k' ADLCare_`k' ADLformalCare_`k') 
		ren (r`k'rccare r`k'rccaredpm r`k'rccarehr r`k'rccaren ) (ADLcaregiverChild_`k'  ADLcaregiverChildDays_`k'  ADLcaregiverChildHours_`k'  ADLcaregiverChildNum_`k' )
		
		ren (r`k'rrcare  r`k'rrcaren ) (ADLcaregiverRelative_`k'  ADLcaregiverRelativeNum_`k' )
		ren (r`k'rscare ) (ADLcaregiverSpouse_`k'      )
} 

  	foreach k in  3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		ren (r`k'rfcare )  ( ADLcaregiverNonRela_`k' )
		ren (r`k'rrcaredpm r`k'rrcarehr)  (ADLcaregiverRelativeDays_`k'  ADLcaregiverRelativeHours_`k')
		ren (r`k'rscaredpm  ) (ADLcaregiverSpouseDays_`k')
		ren (r`k'rscarehr      ) (ADLcaregiverSpouseHours_`k'    )

} 	
* ADL
	foreach k in 1 2 3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		ren r`k'adlab_c adl_sum_`k'
		replace adl_sum_`k' = . if r`k'adlabm_c >=1
	}	  
	foreach k in 1 2 3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		ren r`k'dressa dressing_`k'
		ren r`k'batha bathing_`k'
		ren r`k'eata eating_`k'
		ren r`k'beda beding_`k'
		ren r`k'toilta tolite_`k'
		ren r`k'urina urin_`k'
	}	 
	
	
*IADL 
	foreach k in 2 3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		ren r`k'iadlza iadl_sum_`k'
		replace iadl_sum_`k' = . if r`k'iadlzam >=1
	}

//  r2phonea r3phonea r4phonea s2phonea s3phonea s4phonea 
//  r1moneya r2moneya r3moneya r4moneya s1moneya s2moneya s3moneya s4moneya 
//  r1medsa r2medsa r3medsa r4medsa s1medsa s2medsa s3medsa s4medsa 
//  r1housewka r2housewka r3housewka r4housewka s1housewka s2housewka s3housewka s4housewka 
//  r1joga r2joga r3joga r4joga s1joga s2joga s3joga s4joga 
//  r1walk100a r2walk100a r3walk100a r4walk100a s1walk100a s2walk100a s3walk100a s4walk100a 
//  r1chaira r2chaira r3chaira r4chaira s1chaira s2chaira s3chaira s4chaira 
//  r1climsa r2climsa r3climsa r4climsa s1climsa s2climsa s3climsa s4climsa 
//  r1stoopa r2stoopa r3stoopa r4stoopa s1stoopa s2stoopa s3stoopa s4stoopa 
//  r1dimea r2dimea r3dimea r4dimea s1dimea s2dimea s3dimea s4dimea 
//  r1armsa r2armsa r3armsa r4armsa s1armsa s2armsa s3armsa s4armsa


  	foreach k in 1 2  3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		gen double interviewdate_`k' = mdy(monthin_`k',1, yearin_`k')
} 

* weight
  	foreach k in 1 2  3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		ren (r`k'wtresp   r`k'wtrespb) (wtresp_`k'   wtrespb_`k')
} 
	keep ID communityID *_* gender  ID_w1 educ
	drop *_c
	
	reshape long HexpDentInd_ HexpIPInd_ HexpOOPDentInd_ HexpOOPIPInd_ HexpOOPOPInd_ HexpOPInd_ InsuranceComMed_ InsuranceOthMed_ InsurancePubMed_ adl_sum_ age_ bathing_ beding_ coresidence_ dressing_ eating_ expfoodhh_ exphh_ expnonfoodhh_ expperca_ hhincome_ hukou_ marital_ monthin_ numdaughter_ numson_ residence_ srh_ tolite_ urin_ yearin_ ADLCare_ ADLcaregiverChildDays_ ADLcaregiverChildHours_ ADLcaregiverChildNum_ ADLcaregiverChild_ ADLcaregiverNonRela_ ADLcaregiverRelativeDays_ ADLcaregiverRelativeHours_ ADLcaregiverRelativeNum_ ADLcaregiverRelative_ ADLcaregiverSpouseDays_ ADLcaregiverSpouseHours_ ADLcaregiverSpouse_ ADLformalCare_ ADLinformalCare_ SADLCare_ SADLcaregiverChildDays_ SADLcaregiverChildHours_ SADLcaregiverChildNum_ SADLcaregiverChild_ SADLcaregiverNonRela_ SADLcaregiverRelativeDays_ SADLcaregiverRelativeHours_ SADLcaregiverRelativeNum_ SADLcaregiverRelative_ SADLcaregiverSpouseDays_ SADLcaregiverSpouseHours_ SADLcaregiverSpouse_ SADLformalCare_ SADLinformalCare_ iadl_sum_ interviewdate_ wtresp_  wtrespb_ ,i(ID) j(wave)
	
	recode wave (1=2011) (2=2013) (3=2015) (4=2018)
	gen ID_alt = ID
	replace ID = ID_w1 if wave == 2011
	
	gen ID_new = ID
	replace ID_new = "S"+ID_new
	drop if ID ==""
	
	gen temp1 = substr(ID,11,1) 
	gen temp2 = substr(ID,1,10) 
	gen temp3 = substr(ID,12,1) 
	gen tempID = temp2 + "0"+temp1 
	replace ID = tempID  if temp3==""
	drop temp*
	
save "/Users/x152/Desktop/IV charls/charls_harmS.dta",replace


use "/Volumes/expand/Data/HRS 系列/CHARLS/2020/Demographic_Background.dta",clear
	ren ba009 hukou
	ren ba008 residence_
	ren ba011 marital_
	ren ba015 insurance_
	keep ID hukou residence_  marital_ insurance_
	
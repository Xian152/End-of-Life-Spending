*****************************************************************
*************** 1. Data Cleaning ********
*****************************************************************
use "${OUT}/append_covariances.dta",clear
	drop occupation 
	replace id = 21009398 if id == 21009300
	
********************** demographic & socialeconomic ******************	
	* marital
	foreach k in 0 2 5 8 11 14 18 {
			recode f41_`k' (-9/-1  8 9 -9/-1 =. ) (1=1) (2 3 5=2) (4=3),gen(marital_`k')
			label value marital_`k' marital_lb	
	}			
	
	* hhsize
	foreach k in 0 2 5 8 11 14 18 {
		recode a52_`k' (-1 -1 -9 -6 -7 -8 99 = .),gen(hhsize_`k')
		replace hhsize_`k' = 0 if a51_`k' == 2 
		replace  hhsize_`k' = hhsize_`k' + 1 	
	}	
	
	foreach k in 0 2 5 8 11 14 18{
		generate coresidence_`k'=a51_`k'  if !inlist(a51_`k',8,9,.,-1,-9,-8,-7,-6)
		cap ren resid_`k' residenc_`k'
		cap ren resic_`k' residenc_`k'
		generate residence_`k'=residenc_`k'  if !inlist(residenc_`k',8,9,.,-1,-9,-8,-7,-6)
		replace residence_`k'=2 if residenc_`k'==3	
	}
	
********************** income等 ******************
	foreach k in 2 5 8 11 14 18{
			recode f35_`k'  (-1 -9 -6 -7 -8 99999 88888 = .) (99998=100000),gen(hhIncome_`k') 
			foreach t in 9 99 999 9999 9998  8 88 888 8888  {
				count if f35_`k'!=.
				local N r(N)
				count if hhIncome_`k' == `t'
				local n r(N)
				recode hhIncome_`k' (`t' = .) if `n'/`N' >= 0.01  
		}		
	}	

	foreach k in 8 11 14 18{
		gen hhIncomepercap_`k' = hhIncome_`k' / hhsize_`k'
		replace hhIncome_`k' = hhIncome_`k' * hhsize_`k' 
	}
	
	foreach k in 2 5{
		ren hhIncome_`k'   hhIncomepercap_`k'
		gen hhIncome_`k' = hhIncomepercap_`k' * hhsize_`k'
	}
	
	* Insurance
	foreach k in 11{
		ren (f64e1_`k' f64f1_`k' f64g1_`k' f64h1_`k' f6521_`k') (f64e_`k' f64f_`k' f64g_`k' f64h_`k' f652_`k')
	}
	foreach k in 14{
		ren (f6521_`k') (f652_`k')
	}
	
	foreach k in 18{
			recode f64i_`k' f64h_`k' f64g_`k' f64e_`k' f64d_`k' f64c_`k' f64b_`k' f64a_`k' ( 9 8 = .)
			* 医疗保险
			egen insurancetest_`k'  = rowtotal(f64e_`k'  f64g_`k') // 11: 47个有重复 城职工，城居保,新农合
			gen insurancePubMed_`k' = 1 if  f64g_`k' ==1
			replace insurancePubMed_`k' = 5 if  f64e_`k' ==1
			replace insurancePubMed_`k' = 0 if insurancetest_`k' == 0 
			replace insurancePubMed_`k' = 3 if insurancetest_`k' >=1 & residence_`k' == 2 //重复的转新农合
			replace insurancePubMed_`k' = 1 if insurancetest_`k' >=1 & residence_`k' == 1 & f64g_`k' == 1 //城职工
			replace insurancePubMed_`k' = 4 if f64d_`k' == 1  & !inlist(insurancePubMed_`k',1,2,3)
			drop  insurancetest_`k' 
			label define insurancePubMed_`k'  1"城职工" 2"城居保" 3"新农合" 4"其他公费医疗" 5"城职/居保（2018限定）" 0"无公共医保" 
			label values insurancePubMed_`k' insurancePubMed_`k'
		
			recode 	f64h_`k' (8 9 -9/-1 = .), gen(insuranceCommMed_`k')	 
			
			gen insuranceMed_`k'  = (insuranceCommMed_`k'>=1 | insurancePubMed_`k'>=1) if insuranceCommMed_`k'!=. | insurancePubMed_`k'==.			
		
			* 养老保险
			egen insurancetest_`k'  = rowtotal(f64a_`k' f64b_`k') // 11: 47个有重复 退休金 养老金
			gen insurancePubRetire_`k' = 1 if  f64a_`k' ==1 
			replace insurancePubRetire_`k' = 2 if f64b_`k' ==1  
			replace insurancePubRetire_`k' = 1 if  insurancetest_`k' == 2 & occu< 7 
			replace insurancePubRetire_`k' = 2 if  insurancetest_`k' == 2 & occu== 7 
			replace insurancePubRetire_`k' = 0 if insurancetest_`k' ==0 
			drop  insurancetest_`k' 
			label define insurancePubRetire_`k'  1"退休金" 2"养老金" 0"无退休金或养老金"
			label values insurancePubRetire_`k' insurancePubRetire_`k'
					
			recode 	f64c_`k' (8 9 -9/-1 = .), gen(insuranceCommRetire_`k')	
			
			gen insuranceRetire_`k'  = insuranceCommRetire_`k'>=1 | insurancePubRetire_`k'>=1 if insurancePubRetire_`k'!=. | insuranceCommRetire_`k'==.
			
			recode 	f64i_`k' (8 9 -9/-1 = .), gen(insuranceOther_`k')	
	}
	
	
	* 18年不一样
	foreach k in 5 8 11 14{
			recode f64i_`k' f64h_`k' f64g_`k' f64f_`k' f64e_`k' f64d_`k' f64c_`k' f64b_`k' f64a_`k' ( 9 8 = .)
			
			* 医疗保险
			egen insurancetest_`k'  = rowtotal(f64e_`k' f64f_`k' f64g_`k') // 11: 47个有重复 城职工，城居保,新农合
			gen insurancePubMed_`k' = 1 if  f64e_`k' ==1
			replace insurancePubMed_`k' = 2 if  f64f_`k' ==1
			replace insurancePubMed_`k' = 3 if  f64g_`k' ==1
			replace insurancePubMed_`k' = 0 if insurancetest_`k' == 0 
			replace insurancePubMed_`k' = 3 if insurancetest_`k' >=2 & residence_`k' == 2 //重复的转新农合
			replace insurancePubMed_`k' = 1 if insurancetest_`k' >=2 & residence_`k' == 1 & f64e_`k' == 1 & f64g_`k' == 1 //城职工
			replace insurancePubMed_`k' = 2 if insurancetest_`k' >=2 & residence_`k' == 1 & f64f_`k' == 1 & f64g_`k' == 1 //城职工
			replace insurancePubMed_`k' = 4 if f64d_`k' == 1  & !inlist(insurancePubMed_`k',1,2,3)
			drop  insurancetest_`k' 
			label define insurancePubMed_`k'  1"城职工" 2"城居保" 3"新农合" 4"其他公费医疗" 5"城职/居保（2018限定）" 0"无公共医保" 
			label values insurancePubMed_`k' insurancePubMed_`k'
		
			recode 	f64h_`k' (8 9 -9/-1 -9/-1 = .), gen(insuranceCommMed_`k')	 
			
			gen insuranceMed_`k'  = (insuranceCommMed_`k'>=1 | insurancePubMed_`k'>=1) if insuranceCommMed_`k'!=. | insurancePubMed_`k'==.	
		
			* 养老保险
			egen insurancetest_`k'  = rowtotal(f64a_`k' f64b_`k') // 11: 47个有重复 退休金 养老金
			gen insurancePubRetire_`k' = 1 if  f64a_`k' ==1 
			replace insurancePubRetire_`k' = 2 if f64b_`k' ==1  
			replace insurancePubRetire_`k' = 1 if  insurancetest_`k' == 2 & occu< 7 
			replace insurancePubRetire_`k' = 2 if  insurancetest_`k' == 2 & occu== 7 
			replace insurancePubRetire_`k' = 0 if insurancetest_`k' ==0 
			drop  insurancetest_`k' 
			label define insurancePubRetire_`k'  1"退休金" 2"养老金" 0"无退休金或养老金"
			label values insurancePubRetire_`k' insurancePubRetire_`k'
					
			recode 	f64c_`k' (8 9 -9/-1 -9/-1 = .), gen(insuranceCommRetire_`k')	
			
			gen insuranceRetire_`k'  = insuranceCommRetire_`k'>=1 | insurancePubRetire_`k'>=1 if insurancePubRetire_`k'!=. | insuranceCommRetire_`k'==.
			
			recode 	f64i_`k' (8 9 -9/-1 -9/-1 = .), gen(insuranceOther_`k')	
	}

	* Health Expense 
	foreach k in 5 8 11 14 18{
		recode f652_`k' (99 -1 = .) (8 = 0 "no secure") (5 6 = 1 "self/spouse") (7 9 = 2 "children/others") ( 1 2 3 4 = 3 "insurance/health services"),gen(hexpPayer_`k') label(hexpPayer_`k')		
		gen hexpFinanceissue_`k' = 0 if f61_`k' !=.
		replace hexpFinanceissue_`k' = 1 if f610_`k' == 1 
	}
	
	foreach k in 5 8 {
		recode f651b_`k' f651a_`k' (99998 = 100000) (888 99 198 88 99999 88888 = .),gen(hexpFampaid_`k' hexpIndpaid_`k' )
	}
	foreach k in 11 14 18 {
		recode f651b1_`k' f651a1_`k' f651b2_`k' f651a2_`k' (99998 = 100000) (88888 888 99 198 88 99999 = .)
		
		recode f651b1_`k' f651b2_`k' (88888 888 99 198 88 99999 = .) (99998=100000),gen(hexpFampaidOP_`k' hexpFampaidIP_`k')
		recode f651a1_`k' f651a2_`k' (88888 888 99 198 88 99999  = .) (99998=100000) ,gen(hexpIndpaidOP_`k' hexpIndpaidIP_`k')

		egen hexpFampaid_`k' = rowtotal(f651b1_`k' f651b2_`k' ),mi
		egen hexpIndpaid_`k' = rowtotal(f651a1_`k' f651a2_`k' ),mi		
		
	}
	* health check
	foreach k in  11 14 18 {
		recode f652b_`k' ( 2=0) (8 9 -1 =.),gen(healthcheck_`k')
	}

	* distance to hospital
	foreach k in 18 {
		replace f652a_`k' = subinstr(f652a_`k',"-",".",.)
		replace f652a_`k' = subinstr(f652a_`k',"/",".",.)
		replace f652a_`k' = subinstr(f652a_`k',">","",.)
		replace f652a_`k' = subinstr(f652a_`k'," ","",.)
		replace f652a_`k' = "100" if strmatch(f652a_`k',"100*")
		replace f652a_`k' = "300" if strmatch(f652a_`k',"300*")
		replace f652a_`k' = "0.5" if strmatch(f652a_`k',"*0.5")
		replace f652a_`k' = "50" if strmatch(f652a_`k',"50*") & f652a_`k'!="500"
		destring f652a_`k',replace
		recode f652a_`k' (88.00 98.00 99.00 88.80 99.90 88 99 -1 =.),gen(distanceHosp_`k')
	}	
	foreach k in  11 14  {
		destring f652a_`k',replace
		recode f652a_`k' (88.00 98.00 99.00 -1 888 999 998 =.),gen(distanceHosp_`k')
	}

	
	* 养老院
	foreach k in 0 2 5 8 11 14 18 {
		gen nursingLiving_`k'=1 if  a51_`k' == 3
		replace nursingLiving_`k'=0 if inlist(a51_`k',1,2)
		
		recode a54a_`k' a54b_`k' (8888 9999 -1 88 99 = .)
	}
	foreach k in 0 2  {
		gen nurisngYear_`k' = 200`k' - a54a_`k'
		replace nurisngYear_`k' = nurisngYear_`k' - 1 if (a54b_`k' > monthin_`k' | (a54b_`k' == monthin_`k'& dayin_`k' <15))  & a54b_`k'!=. & a54a_`k' !=.
	}	
	foreach k in 5  {
		gen nurisngYear_`k' = 2005 - a54a_`k'
		replace nurisngYear_`k' = nurisngYear_`k' - 1 if (a54b_`k' > monthin_`k' | ( a54b_`k' == monthin_`k' & dayin_`k' <15))  & a54b_`k'!=. & a54a_`k' !=.
	}	
	foreach k in 8  {
		gen nurisngYear_`k' = yearin_`k' - a54a_`k' 
		replace nurisngYear_`k' = nurisngYear_`k' - 1 if (a54b_`k' > monthin_`k' | ( a54b_`k' == monthin_`k' & dayin_`k' <15))  & a54b_`k'!=. & a54a_`k' !=.
	}	
	
	foreach k in 11 14 18 {
		gen nurisngYear_`k' = yearin_`k' - a54a_`k' 
		replace nurisngYear_`k' = nurisngYear_`k' - 1 if (a54b_`k' > monthin_`k' | ( a54b_`k' == monthin_`k' & dayin_`k' <15))  & a54b_`k'!=. & a54a_`k' !=.
	}	
	foreach k in 0 2 5 8 11 14 18 {
		replace nurisngYear_`k'  = . if nursingLiving_`k'!=1 
	}
	foreach k in 5 8 11 14 18 {
		gen nursingCost_`k' = a541_`k' if a541_`k'>=0 & a541_`k'<8888
		recode a542_`k' (1=0 "self") (3 4 = 1 "children") (5 6 = 2 "public/collection/others") (-1 8 9 -9/-1 = .) , gen(nursingCover_`k') label(nursingCover_`k') 
	}			
	
	* you want to live like 
	foreach k in 5 8 11 14 18 {
		recode 	f16_`k' (8 9 5 = .),gen(nursingLivingExpect_`k')
	}
	
	* retirment 
	foreach k in 2 5 8 11 14 18 {
		recode f211_`k' (8=. ) (1 2 = 1 "Yes") (3 = 0 "No") (-1 = 2 "no pension for retirement"),gen(retiredWPension_`k') label(retired_`k')
		recode f22_`k' (-9/1900 8888 9999 = .),gen(retiredYear_`k')	
	}
	
	foreach k in 11 14 18 {
		destring f26_`k' ,replace
		recode f26_`k' (9999 8888 = .),gen(pensionYearly_`k')
		replace pensionYearly_`k' = pensionYearly_`k'*12  // 居然有0 怎么办？
	}		
	

**********************self-rated health******************
	foreach k in 0 2 5 8 11 14 18 {
			generate srhealth_`k'=b12_`k' 
			replace srhealth_`k'=. if inlist(srhealth_`k',8,9) | srhealth_`k' < 0
			recode srhealth_`k' (5=4)
			label define srhealth_`k' 1 "Very good" 2 "good" 3 "fair" 4"Bad/Very bad"
			label value srhealth_`k' srhealth_`k'		
	}	
	
	foreach k in   11 14 18 {
		recode f47_`k' (8 9 = . ) (5=4),gen(srhealthSopuse_`k')
		label value srhealthSopuse_`k' srhealth_`k'
	}		
**********************lifestyle******************
	*smoking
	foreach k in 0 2 5 8 11 14 18 {
			replace d71_`k' = . if d71_`k' < 0
			replace d75_`k' = . if d75_`k' < 0
						
			generate smkl_`k'=.
			replace smkl_`k' = 1 if d71_`k' == 2
			replace smkl_`k' = 2 if d71_`k' == 2
			replace smkl_`k' = 3 if d71_`k' == 1 & d75_`k' < 20
			replace smkl_`k' = 4 if d71_`k' == 1 & d75_`k' >=20 & d75_`k' <88
			label define smkl_`k' 1 "never" 2 "former" 3 "light current" 4 "heavy current"
			label value smkl_`k' smkl_`k'								
	}
	*Drinking
	replace d86_18 = "" if d86_18>"99"
	destring d86_18,replace

	foreach k in 0 2 5 8 11 14 18 {
			replace d86_`k' = . if d86_`k' < 0 | inlist(d86_`k',9)
			replace d85_`k' = . if d85_`k' < 0 | inlist(d86_`k',99,88) 
			replace d81_`k' = . if d81_`k' < 0 | inlist(d81_`k',8,9)
			
			generate alcohol_`k'=. //genrate amount in drinking
			replace alcohol_`k'=d86_`k'*50*0.53 if d85_`k'==1
			replace alcohol_`k'=d86_`k'*50*0.37 if d85_`k'==2
			replace alcohol_`k'=d86_`k'*50*0.12 if d85_`k'==3
			replace alcohol_`k'=d86_`k'*50*0.15 if d85_`k'==4
			replace alcohol_`k'=d86_`k'*50*0.04 if d85_`k'==5
			replace alcohol_`k'=d86_`k'*50*0.244 if d85_`k'==6
			
			generate dril_`k'=.
			replace dril_`k'=2 if d81_`k' == 2 
			replace dril_`k'=3 if gender==1 & d81_`k'==1 & alcohol_`k' <=25
			replace dril_`k'=3 if gender==0 & d81_`k'==1 & alcohol_`k' <=15
			replace dril_`k'=4 if gender==1 & d81_`k'==1 & (alcohol_`k' >25 & alcohol_`k' != . ) 
			replace dril_`k'=4 if gender==0 & d81_`k'==1 & (alcohol_`k' > 15 & alcohol_`k' != . )	
			label value dril_`k' dril
			
	}	

**# Bookmark #1
	*Physical Activity
	foreach k in 0 {
			recode d91_`k'  (-1 -9 -6 -7 -8 8 9 -9/-1 = .)
			gen pa_`k' = 2 if d91_`k' == 1 
	}	
	
	foreach k in 2 {
			recode d91_`k'  (-1 -9 -6 -7 -8 8 9 -9/-1 = .)
			gen pa_`k' = 2 if d91_`k' == 1 
			replace pa_`k' = 3 if inrange(d91_`k' ,10,120)
	}		
	
	foreach k in 5 8 11 14 18 {
			recode d91_`k' d92_`k' (-1 -9 -6 -7 -8 8 9 -9/-1 = .)
			recode d93_`k' (-1 -9 -6 -7 -8 888 999 = .)
			gen pa_`k' = 1 if d91_`k' == 1 & d93_`k' < 50
			replace pa_`k' = 2 if d91_`k' == 1 & d93_`k' >= 50 & d93_`k' < . // choose to code pa missing if r_pa_pres is missing
			replace pa_`k' = 3 if d91_`k' != 1 & d92_`k' == 1 
			replace pa_`k' = 4 if d91_`k' == 2 & d92_`k' == 2 
			label define pa_`k' 1 "current & start < 50" 2 "current & start >=50" 3 "former" 4 "never"
			label values pa_`k' pa_`k' 		
	}
	
	*leisure Activity  //   d11 in 18 wave special !!!!!!!!!!!!!!!!!!!!!!!
	ren d11b1_18 d11b_18 
	
	foreach k in 0 2 5 8 11 14 18 {
			ren (d11a_`k' d11b_`k' d11c_`k' d11d_`k' d11e_`k' d11f_`k' d11g_`k' d11h_`k') 	(housework_`k' fieldwork_`k' gardenwork_`k' reading_`k' pets_`k' majong_`k' tv_`k' socialactivity_`k')	
	}
	
	foreach k in 0 {
			recode housework_`k' fieldwork_`k' gardenwork_`k' reading_`k' pets_`k' majong_`k' tv_`k' socialactivity_`k' (-1 -9 -6 -7 -8 8 9 -9/-1 = .) (3 = 1) (2 = 2) (1 = 3)
			egen    leisureMiss_`k' = rowmiss(housework_`k' fieldwork_`k' gardenwork_`k' reading_`k' pets_`k' majong_`k' tv_`k' socialactivity_`k')
			egen    leisure_`k' = rowtotal(housework_`k' fieldwork_`k' gardenwork_`k' reading_`k' pets_`k' majong_`k' tv_`k' socialactivity_`k')
			replace leisure_`k' = . if leisureMiss_`k' > 2
			label define leisure_`k' 1 "never" 2 "sometimes" 3 "almost everyday"
			label values housework_`k' fieldwork_`k' gardenwork_`k' reading_`k' pets_`k' majong_`k' tv_`k' socialactivity_`k' leisure_`k' 	
	}	
	
	foreach k in 2 5 8 11 14 18 {
			recode housework_`k' fieldwork_`k' gardenwork_`k' reading_`k' pets_`k' majong_`k' tv_`k' socialactivity_`k' (-1 -9 -6 -7 -8 8 9 -9/-1 = .) (5 = 1) (2 3 4 = 2) (1 = 3)
			egen    leisureMiss_`k' = rowmiss(housework_`k' fieldwork_`k' gardenwork_`k' reading_`k' pets_`k' majong_`k' tv_`k' socialactivity_`k')
			egen    leisure_`k' = rowtotal(housework_`k' fieldwork_`k' gardenwork_`k' reading_`k' pets_`k' majong_`k' tv_`k' socialactivity_`k')
			replace leisure_`k' = . if leisureMiss_`k' > 2
			label define leisure_`k' 1 "never" 2 "sometimes" 3 "almost everyday"
			label values housework_`k' fieldwork_`k' gardenwork_`k' reading_`k' pets_`k' majong_`k' tv_`k' socialactivity_`k' leisure_`k' 
	}	

*********************Activity of daily living******************
	*adl
	foreach k in 0 2 5 8 11 14 18 {
				recode e1_`k' e2_`k' e3_`k' e4_`k' e5_`k' e6_`k' (1 = 0 unimpaired) (2 3 = 1 impaired) (-1 -9 -6 -7 -8 8 9 -9/-1 = .),gen(bathing_`k' dressing_`k' toileting_`k' transferring_`k' continence_`k' feeding_`k') label(newadl)
				egen    adlMiss_`k'=rowmiss(bathing_`k' dressing_`k' toileting_`k' transferring_`k' continence_`k' feeding_`k')  
				egen    adlSum_`k'=rowtotal(bathing_`k' dressing_`k' toileting_`k' transferring_`k' continence_`k' feeding_`k')
				gen     adl_`k'=0 if adlSum_`k' == 0
				replace adl_`k'=1 if adlSum_`k' > 0 & adlSum_`k' != .
				replace adl_`k'=. if adlSum_`k' == .
				label value adl_`k' adl	
	}		
	
	*IADL:
	foreach k in 2 5 8 11 14 18 {
		recode e7_`k' e8_`k'  e9_`k' e10_`k' e11_`k' e12_`k' e13_`k' e14_`k' (1 = 0 "do not need help") (2 3 = 1 "need help") (-9/-1 8 9 = .),gen(visit_`k' shopping_`k' cook_`k' washcloth_`k' walk1km_`k' lift_`k' standup_`k' publictrans_`k') label(iadl_row_`k')
	
		egen iadlMiss_`k'= rowmiss(visit_`k' shopping_`k' cook_`k' washcloth_`k' walk1km_`k' lift_`k' standup_`k' publictrans_`k')
		egen iadlSum_`k' = rowtotal(visit_`k' shopping_`k' cook_`k' washcloth_`k' walk1km_`k' lift_`k' standup_`k' publictrans_`k')
		
		gen iadl_`k' = (iadlSum_`k' > 0) if iadlSum_`k' != .
		label define iadl_`k' 0"0:withSOURCE ADL" 1"1:with ADL"
		label value iadl_`k' iadl_`k'	
	}	
	
	*diet
	foreach k in 0 2 5 {
			recode d31_`k' d32_`k' (1/2 = 1 "everyday or except winter")(3=2 occasionally) (4=3 "rarely or never")(-9 -8 -1 -6 -7 8 9 -9/-1 6 7 = .),gen(fruit_`k' veg_`k') label(fruitf)
			recode d4mt2_`k' d4fsh2_`k' d4egg2_`k' d4ben2_`k' d4veg2_`k' d4sug2_`k' d4tea2_`k' d4gar2_`k' (1 = 1 everyday)(2/4=2 occasionally)(5=3 "rarely or never")(-9 -8 -1 -6 -7 8 9 -9/-1 7 6 = .),gen(meat_`k' fish_`k' egg_`k' bean_`k' saltveg_`k' sugar_`k' tea_`k' garlic_`k') label(meatf)

	}
	
	foreach k in 8 11 14 18 {
			recode d31_`k' d32_`k' (1/2 = 1 "everyday or except wier")(3=2 occasionally) (4=3 "rarely or never")(-9 -8 -1 -6 -7 8 9 -9/-1 6 7 = .),gen(fruit_`k' veg_`k') label(fruitf)
			recode d4meat2_`k' d4fish2_`k' d4egg2_`k' d4bean2_`k' d4veg2_`k' d4suga2_`k' d4tea2_`k' d4garl2_`k' (1 = 1 everyday)(2/4=2 occasionally)(5=3 "rarely or never")(-9 -8 -1 -6 -7 8 9 -9/-1 7 6 = .),gen(meat_`k' fish_`k' egg_`k' bean_`k' saltveg_`k' sugar_`k' tea_`k' garlic_`k') label(meatf)
				
	}		
	foreach k in 8 11 14 18 {
		recode d33_`k'  (-9/-1 8 9 6 7 = .),gen(grease_`k' ) label(grease_`k')
	}	
	foreach k in 0 2 5 8 11 14 18 {
		recode d1_`k' (-9/-1 8 9 6 7 = .),gen(staple_`k' ) label(staple_`k') 
	}	
********************** caring related ******************
	* care giver for ADL
	foreach k in 5 8 11 14 18{
		gen ADLcaregiverSpouse_`k' = e610_`k' == 1 if e610_`k'!=.
		gen ADLcaregiverSon_`k' = e610_`k' == 2 if e610_`k'!=.
		gen ADLcaregiverDinL_`k' = e610_`k' == 3  if e610_`k'!=.
		gen ADLcaregiverDaughter_`k' = e610_`k' == 4   if e610_`k'!=.
		gen ADLcaregiverSinL_`k' = e610_`k' == 5 if e610_`k'!=.
		gen ADLcaregiverChild_`k' = e610_`k' == 6   if e610_`k'!=.
		gen ADLcaregiverGrandC_`k' = e610_`k' == 7 if e610_`k'!=.
		gen ADLcaregiverOthFamily_`k' = e610_`k' == 8 if e610_`k'!=.
		gen ADLcaregiverFriend_`k' = e610_`k' == 9 if e610_`k'!=.
		gen ADLcaregiverSocial_`k' = e610_`k' == 10 if e610_`k'!=.
		gen ADLcaregiverhousekeeper_`k' = e610_`k' == 11 if e610_`k'!=.
		gen ADLcaregiverNobody_`k' = e610_`k' == 12 if e610_`k'!=.
	}		
	
	foreach k in 5 8 11 14 18 {
		recode e62_`k' (-9/-1 99 98 88 9 8 = .) ,gen(ADLcaregiverWilling_`k')
	}		
	foreach k in 5 8 11 14 18 {
		recode e63_`k' (-9/-2  888 99 88  99999 88888 = .) (-1 =0) (99998 = 100000),gen(ADLhexpcare_`k')
		replace ADLhexpcare_`k' = ADLhexpcare_`k'* 4 * 12
		replace ADLhexpcare_`k' = 0 if adlSum_`k' == 0 
	}
	
	* payer for ADL 
	foreach k in 5 8 11 14 18 {
		gen ADLcarepaierSelf_`k' = e64_`k' == 1 if e64_`k'!=.
		gen ADLcarepaierSpose_`k' = e64_`k' == 2 if e64_`k'!=.
		gen ADLcarepaierChild_`k' = e64_`k' == 3 if e64_`k'!=.
		gen ADLcarepaierGrandC_`k' = e64_`k' == 4 if e64_`k'!=.
		gen ADLcarepaierSocial_`k' = e64_`k' == 5 if e64_`k' !=.
		gen ADLcarepaierOthers_`k' = e64_`k' == 6 if e64_`k'!=.
	}		
	
	* care for ADL is enough
	foreach k in 5 8 11 14 18 {
		recode e65_`k' (-9/-1 8 9  = .),gen(ADLmeet_`k')
	}		
	
	* time care 
	foreach k in 5 8 11 14 18 {
		recode e67_`k' (-9/-1 999 888 998 = .) ,gen(ADLcaregtime_`k')
	}	
	
	* enough to pay
	foreach k in 2 5 8 11 14 18 {
		recode f33_`k' (-9/-1 8 9 =.) (2=0),gen(enoughpay_`k')
	}
	
	* accessibility
	foreach k in 0 2 5 8 11 14 18 {
		recode f61_`k' (-9/-1 8 9 =.) (2=0),gen(accessCare_`k')
	}
	* why not visit 
	foreach k in 5 8 11 14 18 {
		recode f610_`k' (-9/-2 8 9 =.) (-1=0),gen(accessIssue_`k')		
	}			
	
	* care giver for sicker
	foreach k in 0 {
		recode f5_`k' (-9/-1 9 = .) 
	}	
	foreach k in 2 5 8 11 14 18 {
		recode f5_`k' (-9/-1 99 88 = .) 
	}	
	foreach k in 0{
		gen caregiverSpouse_`k' = f5_`k' == 1 if f5_`k'!=.
		gen caregiverChild_`k' = f5_`k' == 2  if f5_`k'!=.
		gen caregiverGrandC_`k' = f5_`k' == 3 if f5_`k'!=.
		gen caregiverOthFamily_`k' = f5_`k' == 4 if f5_`k'!=.
		gen caregiverFriend_`k' = f5_`k' == 5 if f5_`k'!=.
		gen caregiverSocial_`k' = f5_`k' == 6 if f5_`k'!=.
		gen caregiverCaregiver_`k' = f5_`k' == 7 if f5_`k'!=.
		gen caregiverNobody_`k' = f5_`k' == 8 if f5_`k'!=.
	}	
	foreach k in 2{
		gen caregiverSpouse_`k' = f5_`k' == 0 if f5_`k'!=.
		gen caregiverSon_`k' = f5_`k' == 1  if f5_`k'!=.
		gen caregiverDaughter_`k' = f5_`k' == 2  if f5_`k'!=.
		gen caregiverChild_`k' = f5_`k' == 3  if f5_`k'!=.
		gen caregiverGrandC_`k' = f5_`k' == 4 if f5_`k'!=.
		gen caregiverOthFamily_`k' = f5_`k' == 5 if f5_`k'!=.
		gen caregiverFriend_`k' = f5_`k' == 6 if f5_`k'!=.
		gen caregiverSocial_`k' = f5_`k' == 7 if f5_`k'!=.
		gen caregiverCaregiver_`k' = f5_`k' == 8 if f5_`k'!=.
		gen caregiverNobody_`k' = f5_`k' == 9 if f5_`k'!=.
	}	
	foreach k in 5{
		gen caregiverSpouse_`k' = f5_`k' == 1 if f5_`k'!=.
		gen caregiverSon_`k' = f5_`k' == 2 if f5_`k'!=.
		gen caregiverDinL_`k' = f5_`k' == 3  if f5_`k'!=.
		gen caregiverDaughter_`k' = f5_`k' == 4   if f5_`k'!=.
		gen caregiverSinL_`k' = f5_`k' == 5 if f5_`k'!=.
		gen caregiverChild_`k' = f5_`k' == 6   if f5_`k'!=.
		gen caregiverGrandC_`k' = f5_`k' == 7 if f5_`k'!=.
		gen caregiverOthFamily_`k' = f5_`k' == 8 if f5_`k'!=.
		gen caregiverFriend_`k' = f5_`k' == 9 if f5_`k'!=.
		gen caregiverSocial_`k' = f5_`k' == 10 if f5_`k'!=.
		gen caregiverCaregiver_`k' = f5_`k' == 11 if f5_`k'!=.
		gen caregiverNobody_`k' = f5_`k' == 12 if f5_`k'!=.
	}	
	foreach k in 8{
		gen caregiverSpouse_`k' = f5_`k' == 1 if f5_`k'!=.
		gen caregiverSon_`k' = f5_`k' == 2 if f5_`k'!=.
		gen caregiverDinL_`k' = f5_`k' == 3  if f5_`k'!=.
		gen caregiverDaughter_`k' = f5_`k' == 4   if f5_`k'!=.
		gen caregiverSinL_`k' = f5_`k' == 5 if f5_`k'!=.
		gen caregiverChild_`k' = f5_`k' == 6   if f5_`k'!=.
		gen caregiverGrandC_`k' = f5_`k' == 7 if f5_`k'!=.
		gen caregiverOthFamily_`k' = f5_`k' == 8 if f5_`k'!=.
		gen caregiverFriend_`k' = f5_`k' == 9 if f5_`k'!=.
		gen caregiverSocial_`k' = f5_`k' == 10 if f5_`k'!=.
		gen caregiverCaregiver_`k' = f5_`k' == 11 if f5_`k'!=.
		gen caregiverNobody_`k' = f5_`k' == 12 if f5_`k'!=.
	}	
	foreach k in 11{
		gen caregiverSpouse_`k' = f5_`k' == 1 if f5_`k'!=.
		gen caregiverSon_`k' = f5_`k' == 2 if f5_`k'!=.
		gen caregiverDinL_`k' = f5_`k' == 3  if f5_`k'!=.
		gen caregiverDaughter_`k' = f5_`k' == 4   if f5_`k'!=.
		gen caregiverSinL_`k' = f5_`k' == 5 if f5_`k'!=.
		gen caregiverChild_`k' = f5_`k' == 6   if f5_`k'!=.
		gen caregiverGrandC_`k' = f5_`k' == 7 if f5_`k'!=.
		gen caregiverOthFamily_`k' = f5_`k' == 8 if f5_`k'!=.
		gen caregiverFriend_`k' = f5_`k' == 9 if f5_`k'!=.
		gen caregiverSocial_`k' = f5_`k' == 10 if f5_`k'!=.
		gen caregiverCaregiver_`k' = f5_`k' == 11 if f5_`k'!=.
		gen caregiverNobody_`k' = f5_`k' == 12 if f5_`k'!=.
	}
	
	foreach k in 14{
		gen caregiverSpouse_`k' = 	f5_`k' == 1 	if f5_`k'!=.
		gen caregiverSon_`k' = 		f5_`k' == 2 	if f5_`k'!=.
		gen caregiverDinL_`k' = 	f5_`k' == 3  	if f5_`k'!=.
		gen caregiverDaughter_`k' = f5_`k' == 4   	if f5_`k'!=.
		gen caregiverSinL_`k' = 	f5_`k' == 5 	if f5_`k'!=.
		gen caregiverChild_`k' = 	f5_`k' == 6   	if f5_`k'!=.
		gen caregiverGrandC_`k' = 	f5_`k' == 7 	if f5_`k'!=.
		gen caregiverOthFamily_`k' = f5_`k' == 8 	if f5_`k'!=.
		gen caregiverFriend_`k' = 	f5_`k' == 9 	if f5_`k'!=.
		gen caregiverSocial_`k' = 	f5_`k' == 10 	if f5_`k'!=.
		gen caregiverCaregiver_`k' = f5_`k' == 11 	if f5_`k'!=.
		gen caregiverNobody_`k' = 	f5_`k' == 12 	if f5_`k'!=.
	}		
	foreach k in 18{
		gen caregiverSpouse_`k' = f5_`k' == 1 if f5_`k'!=.
		gen caregiverSon_`k' = f5_`k' == 2 if f5_`k'!=.
		gen caregiverDinL_`k' = f5_`k' == 3  if f5_`k'!=.
		gen caregiverDaughter_`k' = f5_`k' == 4   if f5_`k'!=.
		gen caregiverSinL_`k' = f5_`k' == 5 if f5_`k'!=.
		gen caregiverChild_`k' = f5_`k' == 6   if f5_`k'!=.
		gen caregiverGrandC_`k' = f5_`k' == 7 if f5_`k'!=.
		gen caregiverOthFamily_`k' = f5_`k' == 8 if f5_`k'!=.
		gen caregiverFriend_`k' = f5_`k' == 9 if f5_`k'!=.
		gen caregiverSocial_`k' = f5_`k' == 10 if f5_`k'!=.
		gen caregiverCaregiver_`k' = f5_`k' == 11 if f5_`k'!=.
		gen caregiverNobody_`k' = f5_`k' == 12 if f5_`k'!=.
	}	

****************** Weight Height BMI *********************
	*weight
	foreach k in 0  {
		recode g10_`k' (-9 -8 -1 -6 -7 888 999 = .),gen(weight_`k')
	foreach k in 2 5 8 11 14 18 {
		recode g101_`k' (-9 -8 -1 -6 -7 888 999 = .),gen(weight_`k')	
	}
	
	*height-armlength & kneelength & hunchbacked
	cap ren g102a_18 meaheight_18
	ren g1021_18 meaheight_18
	cap ren g102b_11 reportheight_11
	cap ren g102_5 youngheight_5
	
	foreach var of varlist g102a_*{
		cap local a = subinstr("`var'","g102a","armlength",.)
		cap ren `var' `a'
	}
	foreach var of varlist g102b_*{
		cap local a = subinstr("`var'","g102b","kneelength",.)
		cap ren `var' `a'		
	}

	foreach var of varlist g122_*{
		cap local a = subinstr("`var'","g122","armlength",.)
		cap ren `var' `a'
	}	
	foreach var of varlist g123_*{
		cap local a = subinstr("`var'","g123","kneelength",.)
		cap ren `var' `a'
	}	
		
	foreach k in 8 11 14 18  {	
			recode armlength_`k' kneelength_`k' (-9 -8 -1 -6 -7  88 888 99 999 = .), gen(armlength1_`k' kneelength1_`k') // note: code g101 = 99 to . b/c the frequenct of 88 & 99 is abnormal for this variables
			drop armlength_`k' kneelength_`k'		
			ren (armlength1_`k' kneelength1_`k') (armlength_`k' kneelength_`k')
	}

	foreach k in 8 11 14 18  {	
			recode armlength_`k' kneelength_`k' (-9 -8 -1 -6 -7  88 888 99 999 = .), gen(armlength1_`k' kneelength1_`k') // note: code g101 = 99 to . b/c the frequenct of 88 & 99 is abnormal for this variables
			drop armlength_`k' kneelength_`k'
			ren (armlength1_`k' kneelength1_`k') (armlength_`k' kneelength_`k')
		}		
	}

	*height-meaheight  
	foreach var of varlist g1021_*{
		cap local a = subinstr("`var'","g1021","meaheight",.)
		cap ren `var' `a'
	}		
		
	foreach k in 8 11 14 18  {	
			recode meaheight_`k' (-9 -8 -1 -6 -7 888 999 = .), gen(meaheight1_`k') 
			drop meaheight_`k'
			ren meaheight1_`k' meaheight_`k'
			gen height_`k' = round(meaheight_`k'/100, .01)
			
			gen bmi_`k'=weight_`k'/(height_`k'*height_`k') 
			replace bmi_`k'=. if bmi_`k' < 12 | bmi_`k' >= 40
					
			gen bmiCat_`k'=.
			replace bmiCat_`k'=1 if bmi_`k'<18.5
			replace bmiCat_`k'=2 if bmi_`k'>=18.5 & bmi_`k'<24
			replace bmiCat_`k'=3 if bmi_`k'>=24 & bmi_`k'<.
			label value bmiCat_`k' bmi			
	}

	* hunchbacked
	foreach k in 11 14 18  {	
			recode g102_`k' (-9 -8 -1 -6 -7 8 9 -9/-1 = .) (2=0), gen(hunchbacked_`k') 	
	}	
	
*************** Biomarker **************
	* Heart Rate // wave 08 lack this value 
	foreach k in 0 2 5 11 14 18 {
			recode g7_`k' (-9 -1 -6 -7 -8 888 999 0 = . ),gen(hr_`k')		
	}
	
	
	foreach k in 8{
			recode g71_`k' g72_`k' (-9 -1 -6 -7 -8 888 999 0 = . )
			egen hr_`k' = rowmean(g71_`k' g72_`k')	
	}		

/*	
	* Heart rhythm
	if !inlist(wave,05,14){
		recode g6_`i1' (1 = 0 "irregular") (2 = 1 "regular") (-9 -1 -6 -7 -8 8 9 -9/-1 = .),gen(hr_irr_f1) label(rhythm_f1)
	}
	if !inlist(wave,02,11,14){
		recode g6_`i2' (1 = 0 "irregular") (2 = 1 "regular") (-9 -1 -6 -7 -8 8 9 -9/-1 = .),gen(hr_irr_f2) label(rhythm_f2)
	}
	if !inlist(wave,00,08,11,14){
		recode g6_`i3' (1 = 0 "irregular") (2 = 1 "regular") (-9 -1 -6 -7 -8 8 9 -9/-1 = .),gen(hr_irr_f3) label(rhythm_f3)
	}
	if !inlist(wave,98,05,08,11,14){
		recode g6_`i4' (1 = 0 "irregular") (2 = 1 "regular") (-9 -1 -6 -7 -8 8 9 -9/-1 = .),gen(hr_irr_f4) label(rhythm_f4)
	}	
	if inlist(wave,98,00){
		recode g6_`i5' (1 = 0 "irregular") (2 = 1 "regular") (-9 -1 -6 -7 -8 8 9 -9/-1 = .),gen(hr_irr_f5_`k'_`k') label(rhythm_f5_`k'_`k')
	}	
*/	
	* blood pressure
	foreach k in 0 2 5 {
			recode g51_`k' g52_`k' (-9 -1 -6 -7 -8 888 999 = .), gen(SBP_`k' DBP_`k')
	}
	foreach k in 8 11 14 18{
			recode g511_`k' g512_`k' g521_`k' g522_`k'(-9 -1 -6 -7 -8  888 999 = .)
			egen SBP_`k' = rowmean(g511_`k' g512_`k')
			egen DBP_`k' = rowmean(g521_`k' g522_`k')
			recode SBP_`k' DBP_`k' (0 = .)	
	}			


	foreach k in 0 2 5 8 11 14 18 {
			gen bpl_`k' = 1 	if (SBP_`k'>0 & SBP_`k'<90) 	& (DBP_`k'>0 & DBP_`k'<60)
			replace bpl_`k' = 2 if (SBP_`k'>=90 & SBP_`k'<=120) & (DBP_`k'>=60 & DBP_`k'<=80)	
			replace bpl_`k' = 3 if (SBP_`k'>120 & SBP_`k'<140) 	& (DBP_`k'>80 & DBP_`k'<90)
			replace bpl_`k' = 4 if (SBP_`k'>=140 & SBP_`k'<160) | (DBP_`k'>=90 & DBP_`k'<100)
			replace bpl_`k' = 5 if (SBP_`k'>=160 & SBP_`k'<.) 	| (DBP_`k'>=100 & SBP_`k'<.)
			label values bpl_`k' bpl				
	}		

********************** community ******************
	foreach k in 5 8 11 14 18 {
		recode f141_`k' (-9/-2 8 9 = .) (2=0) ,gen(CommunityCare_`k')
		recode f147_`k' (-9/-2 8 9 = .) (2=0) ,gen(CommunityEducationCare_`k')
	}	
	
**********************Self-reported disease******************
	foreach t in 0 2 5 8 11 14 18 {
			foreach k in a b c d e f g h i j k l m n o {
				gen disease_`k'_`t' = 0 		if g15`k'1_`t'==1
				replace disease_`k'_`t' = 1  if g15`k'1_`t'==1 & g15`k'3_`t' == 1
				replace disease_`k'_`t' = 2  if g15`k'1_`t'==1 & g15`k'3_`t' != 1 & g15`k'3_`t' >= 0	// here Yaxi did deduction for missing value "8" "9"
				replace disease_`k'_`t' = 3  if g15`k'1_`t'==2 
					//replace disease_`k' = . if inlist(g15`k'3,8,9)
				label value  disease_`k'_`t' disease
			}	
	}	
	foreach k in 0 2 5 8 11 14 18 {
			ren disease_a_`k' hypertension_`k'
			ren disease_b_`k' diabetes_`k'
			ren disease_c_`k' heartdisea_`k'
			ren disease_d_`k' strokecvd_`k'
			ren disease_e_`k' copd_`k'
			ren disease_f_`k' tb_`k'
			ren disease_g_`k' cataract_`k'
			ren disease_h_`k' glaucoma_`k'
			ren disease_i_`k' cancer_`k'
			ren disease_j_`k' prostatetumor_`k'
			ren disease_k_`k' ulcer_`k'
			ren disease_l_`k' parkinson_`k'
			ren disease_m_`k' bedsore_`k'
			ren disease_n_`k' arthritis_`k'
			ren disease_o_`k' dementia_`k'	
	}
	
	foreach k in 0 2 5 8 11 14 18 {
			egen diseaseSum_`k'  = rowtotal(hypertension_`k' diabetes_`k' heartdisea_`k' strokecvd_`k' copd_`k' tb_`k' cataract_`k' glaucoma_`k' cancer_`k' prostatetumor_`k' ulcer_`k' parkinson_`k' bedsore_`k' arthritis_`k'),mi
			
			gen disease_`k' = 3 if diseaseSum_`k' == 42
			foreach t in hypertension_`k' diabetes_`k' heartdisea_`k' strokecvd_`k' copd_`k' tb_`k' cataract_`k' glaucoma_`k' cancer_`k' prostatetumor_`k' ulcer_`k' parkinson_`k' bedsore_`k' arthritis_`k' {
					replace disease_`k' = 1 if  `t' == 1
			}
				
			replace disease_`k' = 2 if disease_`k' == .
			replace disease_`k' = . if diseaseSum_`k' == .		
	}		

******************CI & MMSE ******************
	foreach k in 0 2 5 8 11 14 18 {		
		*****cognition
			*orientation section
			recode c11_`k' c12_`k' c13_`k' c14_`k' c15_`k' (0 8 = 0 "unable to answer or wrong") (1 = 1 "correct") (-9 -6 -1 -7 -8 9 -9/-1 = .), gen(time_orientation1_`k' time_orientation2_`k' time_orientation3_`k' time_orientation4_`k' place_orientation_`k') label(ciorientation_`k')

			*naming foods
			recode c16_`k' (88 = 0 "unable to answer") (-9 -6 -1 -7 -8 99 = .), gen(namefo_`k') label(cinamefo_`k')
			replace namefo_`k'=7 if namefo_`k'>=7 & namefo_`k'<. 									
				
			*registration
			recode c21a_`k' c21b_`k' c21c_`k' (8 = 0 "wrong or unable to answer") (1 = 1 "correct") (-9 -6 -1 -7 -8 9 -9/-1 2 = .),gen(registration1_`k' registration2_`k' registration3_`k') label(ciregistration_`k')

			*attention and calculation--attempts to repeat the names of three objects correctly
			recode c31a_`k' c31b_`k' c31c_`k' c31d_`k' c31e_`k' (8 = 0 "wrong or unable to answer") (1 = 1 "correct") (-9 -6 -1 -7 -8  9 = .),gen(calculation1_`k' calculation2_`k' calculation3_`k' calculation4_`k' calculation5_`k') label(ciattention_`k')

			*recall
			recode c41a_`k' c41b_`k' c41c_`k' (8 = 0 "wrong or unable to answer") (1 = 1 "correct")  (-9 -6 -1 -7 -8 9 -9/-1 = .), gen(delayed_recall1_`k' delayed_recall2_`k' delayed_recall3_`k') label(cirecall)

			*language
			recode c51a_`k' c51b_`k' c52_`k' c53a_`k' c53b_`k' c53c_`k' (8 = 0) (-9 -6 -1 -7 -8 9 -9/-1 = .), gen(naming_objects1_`k' naming_objects2_`k' repeating_sentence_`k' listening_obeying1_`k' listening_obeying2_`k' listening_obeying3_`k') label(cilanguage_`k')
				
			*copy a figure
			recode c32_`k' (8 = 0 "wrong or unable to answer") (1 = 1 "correct") (-9 -6 -1 -7 -8 9 -9/-1 = .),gen(copyf_`k') label(cifigure_`k')
				 
			*CI missing
			egen ciMissing_`k' = rowmiss(time_orientation1_`k' time_orientation2_`k' time_orientation3_`k' time_orientation4_`k' place_orientation_`k' namefo_`k' registration1_`k' registration2_`k' registration3_`k' calculation1_`k' calculation2_`k' calculation3_`k' calculation4_`k' calculation5_`k' copyf_`k' delayed_recall1_`k' delayed_recall2_`k' delayed_recall3_`k' naming_objects1_`k' naming_objects2_`k' repeating_sentence_`k' listening_obeying1_`k' listening_obeying2_`k' listening_obeying3_`k')
				
			egen ci_`k' = rowtotal(time_orientation1_`k' time_orientation2_`k' time_orientation3_`k' time_orientation4_`k' place_orientation_`k' namefo_`k' registration1_`k' registration2_`k' registration3_`k' calculation1_`k' calculation2_`k' calculation3_`k' calculation4_`k' calculation5_`k' copyf_`k' delayed_recall1_`k' delayed_recall2_`k' delayed_recall3_`k' naming_objects1_`k' naming_objects2_`k' repeating_sentence_`k' listening_obeying1_`k' listening_obeying2_`k' listening_obeying3_`k')
				
			replace ci_`k' = . if ciMissing_`k' > 3  

			egen time_orientation_`k'	= rowtotal(time_orientation1_`k' time_orientation2_`k' time_orientation3_`k' time_orientation4_`k')
			egen orientation_`k'		= rowtotal(time_orientation_`k'  place_orientation_`k')
			egen registration_`k'		= rowtotal(registration1_`k' registration2_`k' registration3_`k')
			egen calculation_`k'		= rowtotal(calculation1_`k' calculation2_`k' calculation3_`k' calculation4_`k' calculation5_`k')
			egen delayed_recall_`k'		= rowtotal(delayed_recall1_`k' delayed_recall2_`k' delayed_recall3_`k')
			egen naming_objects_`k'		= rowtotal(naming_objects1_`k' naming_objects2_`k')
			egen listening_obeying_`k'	= rowtotal(listening_obeying1_`k' listening_obeying2_`k' listening_obeying3_`k')
			egen Language_`k'			= rowtotal(naming_objects_`k' repeating_sentence_`k' listening_obeying_`k')
				
			gen orientation_full_`k' 	= (orientation_`k' == 5)
			gen namefo_full_`k' 			= (namefo_`k' == 7)
			gen registration_full_`k' 	= (registration_`k' == 3)
			gen calculation_full_`k' 	= (calculation_`k' == 5)
			gen copyf_full_`k' 			= (copyf_`k' == 1)
			gen delayed_recall_full_`k' 	= (delayed_recall_`k' == 3)
			gen Language_full_`k'		= (Language_`k' == 6)

			* MMSE
			egen mmse_`k' =	rowtotal(orientation_`k' namefo_`k' registration_`k' calculation_`k' copyf_`k' delayed_recall_`k' Language_`k'),mi 
				
			gen ciCat_`k'=.
			replace ciCat_`k'=3 if mmse_`k'>=0 & mmse_`k'<=9
			replace ciCat_`k'=2 if mmse_`k'>=10 & mmse_`k'<=17
			replace ciCat_`k'=1 if mmse_`k'>=18 & mmse_`k'<=24
			replace ciCat_`k'=0 if mmse_`k'>=25 & mmse_`k'<=30
				
			gen ciBi_`k'=.
			replace ciBi_`k'=0 if mmse_`k'>25
			replace ciBi_`k'=1 if mmse_`k'<=25

			label value ciCat_`k' y
			label value ciBi_`k' u
	}	
******************* Frailty  **************
	* Self-reported Health Ordinal 
	foreach k in 0 2 5 8 11 14 18 {
		recode b12_`k'  (1 = 0) (2=0.25) (3 = 0.5) (4 5 = 1) (-9/-1 8 9 = . ) ,gen(FRAsrh_`k') // 4"Bad" 5 "Very bad"		

		* ADL: activity of daily living  Ordinal 
		recode e1_`k' e2_`k' e3_`k' e4_`k' e5_`k' e6_`k' (1 = 0 ) (2 = 0.5) (3 = 1 ) (-9/-1 8 9 = .),gen(FRAbathing_`k' FRAdressing_`k' FRAtoileting_`k' FRAtransferring_`k' FRAcontinence_`k' FRAfeeding_`k')  // 2:one part assistance 3: more than one part assistance
	}
	foreach k in 2 5 8 11 14 18 {	
		recode b121_`k' (1 = 0) (2=0.25) (3 = 0.5) (4 5 = 1) (-9/-1 8 9 = . ) ,gen(FRAhworse_`k') 
		recode e7_`k' e8_`k'  e9_`k' e10_`k' e11_`k' e12_`k' e13_`k' e14_`k' (1 = 0 ) (2 = 0.5) (3 = 1 ) (-9/-1 8 9 = .),gen(FRAvisit_`k' FRAshopping_`k' FRAcook_`k' FRAwashcloth_`k' FRAwalk1km_`k' FRAlift_`k' FRAstandup_`k' FRApublictrans_`k') 
	}
	* Visual function Ordinal 	
	foreach k in 11 14 18 {		
	recode g1_`k' (1 = 0) (2 = 0.5) (3 4 = 1) (-9/-1 8 9 = .),gen(FRAvisual_`k') // 3:  can't see 4: blind ??2  can see but can't distinguish the break in the circle 		
	}
	
	* sleep
	foreach k in 5 8 11 14 {		
		recode g01_`k' (1 = 0) (2 =0.25) (3 =0.5)  (4 5  = 1 ) (-9/-1 8 9 = .),gen(FRAsleep_`k') // 4: bad 5: very bad	
	}			

	foreach k in 18 {		
		recode b310a_`k' (1 = 0) (2 =0.25) (3 =0.5)  (4 5  = 1 ) (-9/-1 8 9 = .),gen(FRAsleep_`k') // 4: bad 5: very bad		
		
	}	
	
	* Functional: 
	* Hand behind neck & Hand behind lower back Ordinal 
	foreach k in 0  {		
		recode g81_`k' g82_`k'   (1 2 =0.5) (4 = 1) (3 = 0) (-9/-1 8 9 = .),gen(FRAneck_`k'  FRAlowerback_`k'    ) // 1  right hand, 	2  left hand, 4  neither hand			
	}		
	foreach k in 2 5 8 11 14 18 {		
		recode g81_`k' g82_`k' g83_`k' (1 2 =0.5) (4 = 1) (3 = 0) (-9/-1 8 9 = .),gen(FRAneck_`k'  FRAlowerback_`k'  FRAraisehands_`k' ) // 1  right hand, 	2  left hand, 4  neither hand			
	}		
	
	* Able to stand up from sitting, Able to pick up a book from the floor
	foreach k in 0 2 5 8 11 14 18 {		
			recode g9_`k' g11_`k'(1 = 0) (2 = 0.5)  (3 = 1) (-9/-1 8 9 = .),gen(FRAstand_`k' FRAbook_`k' ) // 2  yes, using hands, 3  no ??? 2  yes, using hands //2  yes, sitting, 3  no ??? 2  yes, sitting				
	}		
	
	* Number of times suffering from serious illness in the past two years	Ordinal 	
	foreach k in 8 11 14 18 {		
		recode g131_`k' (0=0) (1 2 = 0.5) (3/88 = 1) (-9/-1 99  = . ),gen(FRAseriousillness_`k')							
	}		
	* Self-reported Health Ordinal 
	foreach k in 0 2 5 8 11 14 18 {		
			gen FRAci_`k' = 1 if mmse_`k' >=23 & mmse_`k' !=.
			replace FRAci_`k' = 0 if mmse_`k' <23 	
			replace FRAci_`k' = . if mmse_`k' ==.					
	}		

	
******** Self-reported Disease History **********
//Hypertension,Diabetes,Heart disease,Stroke or CVD,COPD,Tuberculosis,Cancer,Gastric or duodenal ulcer,Parkinsons,Bedsore,Cataract,Glaucoma,Other chronic disease	Categorical ?????????, Prostate Tumor cancer
	foreach k in 0 2 5 8 11 14 18 {		
		foreach disease in a b c d e f g h i j k l m n  {
			gen disease_`disease'_`k' = 1 if g15`disease'1_`k'==1
			replace disease_`disease'_`k' = 0  if g15`disease'1_`k'==2 
		}

		ren disease_a_`k' FRAhypertension_`k'
		ren disease_b_`k' FRAdiabetes_`k'
		ren disease_c_`k' FRAhtdisea_`k'
		ren disease_d_`k' FRAstrokecvd_`k'
		ren disease_e_`k' FRAcopd_`k'
		ren disease_f_`k' FRAtb_`k'
		ren disease_g_`k' FRAcataract_`k'
		ren disease_h_`k' FRAglaucoma_`k'
		ren disease_i_`k' FRAcancer_`k'
		ren disease_j_`k' FRAprostatetumor_`k'
		ren disease_k_`k' FRAulcer_`k'
		ren disease_l_`k' FRAparkinson_`k'
		ren disease_m_`k' FRAbedsore_`k'

		replace FRAhypertension_`k' = 1 if (SBP_`k'>=140 & SBP_`k'!=.) | (DBP_`k'>=90 & DBP_`k'!=.)
					
	}

	* Able to hear
	foreach k in 0 2 5 8 11 14 18 {		
		recode h1_`k' (1=0) (2 =0.25) (3 =0.5) (4 = 1)  (-9/-1 8 9 = .),gen(FRAhear_`k') //  2: yes, but needs hearing aid, 3: partly, despite hearing aid, 4: no ????		
	}
	* Interviewer rated health	
	foreach k in 0 2 5 8 11 14 18 {		
		recode h3_`k' (1 = 0) (2=0.25)  (3=0.5) (3 4 = 1) (-9/-1 8 9= .),gen(FRAirh_`k')				
	}	
	
	
	* psychol
 	/*Look on the bright side of things 
 	Keep my belongings neat and clean !!
 	Make own decisions	 ?????
 	Feel fearful or anxious	  ?????/
 	Feel useless with age	?????? */ 
		
	foreach k in 0 2 5 8 11 14 18 {		
		recode b21_`k'  b22_`k' (1=0)  (2 = 0.25) (3 = 0.5 ) (4 5 = 1) (-9/-1 8 9 = . ), gen(FRApsy1_`k' FRApsy2_`k')  //positive  1  always,2  often,3  sometimes,4  seldom,5  never		
	}

	foreach k in  18 {		
		recode b36_`k'  b34_`k'  (1 2 =1)  (3 = 0.5 ) (4 =0.25) (5 = 0) (-9/-1 8 9 = . ), gen(FRApsy3_`k' FRApsy6_`k') // negative 1  always,2  often,3  sometimes,4  seldom,5  never	
	}	
	
	* Housework at present	
	foreach k in 0 2 5 8 11 14 18 {		
		recode  housework_`k' (1 2 =0) (3 4=0.5 ) (5=1) (-9/-1 8 9 = . ),gen(FRAhousework_`k') // 3: never		
	}		
	
	
	* Able to use chopsticks to eat
	foreach k in 0 2 5 8 11 14 18 {		
		recode g3_`k' (2=1) (1=0) (-9/-1 8 9 = . ),gen(FRAchopsticks_`k') 	
	}	
	
	
	* Number of steps used to turn around a 360 degree turn without help
	foreach k in 0 2 5 8 11 14 18 {		
		recode g12_`k' (20/88 = 1) (10/19 = 0.5) (5/9 = 0.25) (1/4 = 0) (-9/-1 0 89/888 = .) ,gen(FRAturn_`k')		
	}	
		
	* physical 
	* BMI
	foreach k in   8 11 14 18 {		
		gen FRAbmi_`k'= 1 if weight_`k'/(height_`k'*height_`k')<18.5 | weight_`k'/(height_`k'*height_`k')>=28
		replace FRAbmi_`k'= 0.5 if weight_`k'/(height_`k'*height_`k')<28 & weight_`k'/(height_`k'*height_`k')>=24
		replace FRAbmi_`k'= 0 if weight_`k'/(height_`k'*height_`k')<24 & weight_`k'/(height_`k'*height_`k')>=18.5
		replace FRAbmi_`k'= . if weight_`k'/(height_`k'*height_`k') == .		
	}	

	* heart rate
	foreach k in 0 2 5 11 14 18 {		
			recode g7_`k'  (-1 888 999 = . ),gen(FRAhr_`k')
			foreach m in FRAhr_`k' {
				sum `m' 
				replace FRAhr_`k' = . if !inrange(FRAhr_`k',r(mean)-3*r(sd),r(mean)+3*r(sd)) 
			}		
		recode FRAhr_`k' (0/60 = 0) (60.5/80 =0.25) (80.5/90 = 0.5) (90.5/115 = 0.75) (115.5/200 = 1) (-9/-1 0 888 999 =.)	
	}	
	foreach k in 8 {		
			recode g71_`k'  (-1 888 999 = . ),gen(FRAhr_`k')
			foreach m in FRAhr_`k' {
				sum `m' 
				replace FRAhr_`k' = . if !inrange(FRAhr_`k',r(mean)-3*r(sd),r(mean)+3*r(sd)) 
			}		
		recode FRAhr_`k' (0/60 = 0) (60.5/80 =0.25) (80.5/90 = 0.5) (90.5/115 = 0.75) (115.5/200 = 1) (-9/-1 0 888 999 =.)	
	}	
	
********************** Psychology ******************
	foreach k in 0 2 5 8 11 14 {
			recode b21_`k' b22_`k' b25_`k' b27_`k' (1 = 5) (2 = 4) (4 = 2) (5 = 1) (-9 -6 -1 -7 -8  8 9 -9/-1 = . ), gen(psy1_`k' psy2_`k' psy5_`k' psy7_`k') 
			recode b23_`k' b24_`k' b26_`k' (-9 -6 -1 -7 -8  8 9 -9/-1 = .), gen(psy3_`k' psy4_`k' psy6_`k') 
			egen psycho_`k' = rowtotal(psy1_`k' psy2_`k' psy3_`k' psy4_`k' psy5_`k' psy6_`k' psy7_`k')
			egen psyMiss_`k' = rowmiss(psy1_`k' psy2_`k' psy3_`k' psy4_`k' psy5_`k' psy6_`k' psy7_`k')
			
			replace psycho_`k' = . if psyMiss_`k' > 2 			
	}	
	foreach k in 18 {
		forvalues t = 1/7{
			gen psy`t'_`k' = . 
		}	
			gen psycho_`k' = .
			gen psyMiss_`k' =.
	}		
	
******************* Realiability of the answers  *****************************
	foreach k in 0 2 5 8 11 14 18 {
			recode h21_`k' (1 3 = 1 "able/patrically able") (2= 0 "no") (-9 -6 -1 -7 -8  8 9 -9/-1 = .),gen(ablephy_`k') label(ablephy)
			recode h22_`k'  (-9 -6 -1 -7 -8 9 -9/-1 = .),gen(ablephyreas_`k') label(ablephyreason)	
	}		

/*
********************** Disablility ******************
	if inlist(wave,98,0,2,5){
		foreach z in 1 2 3{
			recode g15*3_`k' (9 8 = .) (1 = 2 ) (2 = 1) (-1 3 = 0)
			replace g15*3_`k' = 0 if 
			label define disability_`k' 2 "rather serious" 1"more or less" 0 "no"
			label values g15*3_`k' disability_`k'
			egen disability_`k' = rowtotal(g17*2`k'),mi
			egen disabilityMiss_`k' = rowmiss(g17*2`k')		
			//replace disability_`k' = . if  disabilityMiss_`k' 
		}
	}
	if inlist(wave,8){
		foreach z in 1 2 {
			recode g15*3_`k' (9 8 = .) (1 = 2 ) (2 = 1) (-1 3 = 0)
			replace g15*3_`k' = 0 if 
			label define disability_`k' 2 "rather serious" 1"more or less" 0 "no"
			label values g15*3_`k' disability_`k'
			egen disability_`k' = rowtotal(g17*2`k'),mi
			egen disabilityMiss_`k' = rowmiss(g17*2`k')		
			//replace disability_`k' = . if  disabilityMiss_`k' 
		}
	}	
	if inlist(wave,11,14){
		foreach z in 1 2 {
			recode g15*3_`k' (9 8 = .) (1 = 2 ) (2 = 1) (-1 3 = 0)
			replace g15*3_`k' = 0 if 
			label define disability_`k' 2 "rather serious" 1"more or less" 0 "no"
			label values g15*3_`k' disability_`k'
			egen disability_`k' = rowtotal(g17*2`k'),mi
			egen disabilityMiss_`k' = rowmiss(g17*2`k')		
			//replace disability_`k' = . if  disabilityMiss_`k' 
		}
	}	
*/
	* hearingloss
	foreach k in  11 14 18 {
			recode  g106_`k' g1061_`k' g1062_`k' g1063_`k' (8 9 -9/-1 = .)
			gen hearingloss_`k' = 1 if g106_`k' == 1 
			replace hearingloss_`k' = 2 if g106_`k' == 1  & g1061_`k' ==3 
			replace hearingloss_`k' = 0 if g106_`k' == 2 		
	}			
	
* Interview date & season 
	* rename interview date and prepare for panel
	replace id_year =8 if id_year ==9
	replace id_year =11 if id_year ==12
		
	ren wave wave_baseline 
	
	foreach k in 0 2 5 8 11 14 18 {
			gen wave_`k' = `k'	
	}
	
* dth & censor 
	foreach k in 0 2 5 8 11 14 18 {
			ren dth`k' dth_`k'		
	}
	
	
save "${OUT}/append covariance followup.dta",replace

use "${OUT}/append covariance followup.dta",clear
* proper sample size	
	bysort id: gen n= _N
	gen a = 1  if (id_year ==wave_baseline) | (inlist(id_year,8,9) & wave_baseline==8) |(id_year == 12 & wave_baseline ==11)|(wave_baseline ==18 & n==1 )
	replace a = 1 if id == 22005502 & wave_baseline == 5
	replace a = 1 if id == 32056002 & wave_baseline == 8
	replace a = 1 if id == 32073900 & wave_baseline == 5
	replace a = 1 if id == 44026502 & wave_baseline == 5
	replace a = 1 if id == 44026505 & wave_baseline == 8
	replace a = 1 if id == 44052100 & wave_baseline == 8
	replace a = 1 if id == 44058602 & wave_baseline == 5
	
	codebook id // 44,619   individual

	keep if a == 1
	duplicates drop	

	keep marital*  hhsize* coresidence* residence* hh* insurance* hexp* nursing*   retiredYear* pension* srhealth* smkl* dril* pa* housework* fieldwork* gardenwork* reading* pets* majong* tv* socialactivity* leisure* adl* bathing* dressing* toileting* transferring* continence* feeding* meat* fish* egg* bean* saltveg* veg* fruit* sugar* tea* garlic* *weight* *height* armlength* kneelength* bmi* hunchbacked* hr* SBP*  DBP* bpl* disease* hypertension* diabetes* heartdisea* strokecvd* copd* tb* cataract* glaucoma* cancer* prostatetumor* ulcer* parkinson* bedsore* arthritis* ci* psy*  hearingloss* id_year wave* *month* *day* *year* *age* id dth*  dthdate dthday dthmonth dthyear residenc* prov* gender* ethnicity* coresidence* occu* marital* edug* residence* mmse* *_b*  id_year yearin_* monthin_* dayin_* lost* occu FRA*   ADL* iadl* caregiver* enoughpay* staple* grease* distanceHosp* healthcheck* CommunityCare* CommunityEducationCare* srhealthSopuse* accessCare* accessIssue* dementia*

	drop smkl_year* hr_irr_* agefirstbirth* agelastbirth* yearfirstbirth_* yearlastbirth_* yeargapbir* yearavebirth_*  residenc_* vage_* Language_* reportheight* v_*    
	drop  disease_n_0 disease_n_11 disease_n_14 disease_n_18 disease_n_2 disease_n_5 disease_n_8 
	duplicates drop
	drop d0* d2* d5* d8* d11* d14* d18*
	drop survival_bas* survival_bth* 
	drop psy*_18
	ren lost_18  lost 
	foreach var of varlist *_2{
		local b = subinstr("`var'","_2","",.)
		ren `b'_2   `b'__3
	}	
	foreach var of varlist *_0{
		local b = subinstr("`var'","_0","",.)
		ren `b'_0   `b'__2
	}

	foreach var of varlist *_5{
		local b = subinstr("`var'","_5","",.)
		ren `b'_5   `b'__4
	}
	foreach var of varlist *_8{
		local b = subinstr("`var'","_8","",.)
		ren `b'_8   `b'__5
	}
	foreach var of varlist *_11{
		local b = subinstr("`var'","_11","",.)
		ren `b'_11   `b'__6
	}
	foreach var of varlist *_14{
		local b = subinstr("`var'","_14","",.)
		ren `b'_14   `b'__7
	}
	foreach var of varlist *_18{
		local b = subinstr("`var'","_18","",.)
		ren `b'_18   `b'__8
	}	
	
	foreach var of varlist *_b98{
		local b = subinstr("`var'","_b98","",.)
		ren `b'_b98   `b'__b1
	}	
	foreach var of varlist *_b2{
		local b = subinstr("`var'","_b2","",.)
		ren `b'_b2   `b'__b3
	}	
	foreach var of varlist *_b0{
		local b = subinstr("`var'","_b0","",.)
		ren `b'_b0   `b'__b2
	}

	foreach var of varlist *_b5{
		local b = subinstr("`var'","_b5","",.)
		ren `b'_b5   `b'__b4
	}
	foreach var of varlist *_b8{
		local b = subinstr("`var'","_b8","",.)
		ren `b'_b8   `b'__b5
	}
	foreach var of varlist *_b11{
		local b = subinstr("`var'","_b11","",.)
		ren `b'_b11   `b'__b6
	}
	foreach var of varlist *_b14{
		local b = subinstr("`var'","_b14","",.)
		ren `b'_b14   `b'__b7
	}
	foreach var of varlist *_b18{
		local b = subinstr("`var'","_b18","",.)
		ren `b'_b18   `b'__b8
	}		
	
	foreach k in 2 3 4 5 6 7 8 { //
		foreach var of varlist *__`k'{
			local b = subinstr("`var'","__`k'","",.)
			replace `b'__`k' =  . if inlist(dth__`k',-9,-8,1)
		}
	}
	foreach k in 2 3 4 5 6 7 8 { //
		gen dth__b`k' = dth__`k'
		gen wave__b`k' = wave__`k'
	}
	
	foreach k in 2 3 4 5 6 7 8 { //
		foreach var of varlist *__`k'{
			local b = subinstr("`var'","__`k'","",.)
			replace `b'__`k' =  `b'__b`k' if  `b'__b`k'!=.
		}
	}
	
	drop *_b2* *_b3* *_b4* *_b5* *_b6* *_b7* *_b8*
	
	foreach var of varlist *__b1{
		local a = subinstr("`var'","__b1","__",.)
		ren `a'b1 `a'1
	}
	
	drop trueage_*   arthritis__1  
	
	global namenew
	foreach t in 1 2 3 4 5 6 7 8  {	
		foreach var of varlist *__`t'{
			local e = subinstr("`var'","__`t'","__",.)
			global namenew $namenew `e'
		}
	}

	duplicates drop
	
	reshape long 	ablephy__	ablephyreas__	adl__	adlMiss__	adlSum__	armlength__	arthritis__	bathing__	bean__	bedsore__	bmi__	bmiCat__	bpl__	cancer__	cataract__	ci_	ci__	ciBi__	ciCat__	ciMissing__	continence__	copd__	coresidence__		DBP__	diabetes__	disease__	diseaseSum__	dressing__	dril__	dth__	egg__	feeding__	fieldwork__	fish__	fruit__	gardenwork__	garlic__		glaucoma__	hearingloss__	heartdisea__	height__	hexpFinanceissue__	hexpPayer__	hexpFampaid__	hexpFampaidIP__	hexpFampaidOP__	hexpIndpaid__	hexpIndpaidIP__	hexpIndpaidOP__	hhIncome__	hhIncomepercap__	hhsize__	housework__	hr__	hunchbacked__	hypertension__	insuranceCommMed__	insuranceCommRetire__	insuranceMed__	insuranceOther__	insurancePubMed__	insurancePubRetire__	insuranceRetire__	intdate__	kneelength__	leisure__	leisureMiss__	majong__	marital__	meaheight__	meat__		mmse__	numchild__	nurisngYear__	nursingCost__	nursingCover__	nursingLiving__	pa__	parkinson__	pensionYearly__	pets__	prostatetumor__	psyMiss__	psy1__	psy2__	psy3__	psy4__	psy5__	psy6__	psy7__	psycho__	reading__	residence__	retiredYear__	saltveg__		SBP__	 	smkl__	socialactivity__	srhealth__	strokecvd__	sugar__		tb__	tea__		toileting__	transferring__	tv__	ulcer__	veg__	wave__	weight__	 youngheight__ dayin__ monthin__ yearin__ FRAbathing__ FRAbedsore__ FRAbmi__ FRAbook__ FRAcancer__ FRAcataract__ FRAchopsticks__ FRAci__ FRAcontinence__ FRAcook__ FRAcopd__ FRAdiabetes__ FRAdressing__ FRAfeeding__ FRAglaucoma__ FRAhear__ FRAhousework__ FRAhr__ FRAhtdisea__ FRAhworse__ FRAhypertension__ FRAirh__ FRAlift__ FRAlowerback__ FRAneck__ FRAotherchronic__ FRAparkinson__ FRAprostatetumor__ FRApsy1__ FRApsy2__ FRApsy3__ FRApsy5__ FRApsy6__ FRApublictrans__ FRAraisehands__ FRAseriousillness__ FRAshopping__ FRAsleep__ FRAsrh__ FRAstand__ FRAstandup__ FRAstrokecvd__ FRAtb__ FRAtoileting__ FRAtransferring__ FRAturn__ FRAulcer__ FRAvisit__ FRAvisual__ FRAwalk1km__ FRAwashcloth__ ADLcaregiverWilling__  ADLhexpcare__ iadlMiss__ iadlSum__ iadl__  caregiverSpouse__ caregiverSon__ caregiverSocial__ caregiverSinL__ caregiverOthFamily__ caregiverNobody__ caregiverGrandC__ caregiverFriend__ caregiverDinL__ caregiverDaughter__   caregiverChild__ caregiverCaregiver__ ADLcaregiverSpouse__ ADLcaregiverSon__ ADLcaregiverDinL__ ADLcaregiverDaughter__ ADLcaregiverSinL__ ADLcaregiverChild__ ADLcaregiverGrandC__ ADLcaregiverOthFamily__ ADLcaregiverFriend__ ADLcaregiverSocial__ ADLcaregiverhousekeeper__ ADLcaregiverNobody__ nursingLivingExpect__  ADLcarepaierSelf__ ADLcarepaierSpose__ ADLcarepaierChild__ ADLcarepaierGrandC__ ADLcarepaierSocial__ ADLcarepaierOthers__ ADLmeet__ ADLcaregtime__ enoughpay__  staple__ grease__ distanceHosp__ healthcheck__ CommunityCare__ CommunityEducationCare__ srhealthSopuse__ accessCare__ accessIssue__ dementia__,  i(id) j(followup) 
	
	drop midmonth* midyear* midday*
	drop Language  residenc 
		
		
	replace wave__ = 1998 if wave__ == .
	replace wave__ = 2000 if wave__ == 0
	replace wave__ = 2002 if wave__ == 2
	replace wave__ = 2005 if wave__ == 5
	replace wave__ = 2008 if wave__ == 8
	replace wave__ = 2011 if wave__ == 11
	replace wave__ = 2014 if wave__ == 14
	replace wave__ = 2018 if wave__ == 18	
	
	format interview_baseline dthdate lostdate %tdYMD
	
	drop intdate__ 
	gen double intdate__  = mdy(monthin__,dayin__,yearin__)
	format intdate__ %tdYMD 
	
	drop if intdate__==.
	
	drop ci_  lostdate lost
	
save "${OUT}/append covariance followup_fin.dta",replace

use "${OUT}/append covariance followup_fin.dta",clear
	foreach var of varlist *__{
		local a = subinstr("`var'","__","",.)
		ren `a'__ `a'
	}
	gen death = 0
	append using "${OUT}/append_covariances_tempdeath.dta"
	
	/* wave
	replace wave = 2000 if death == 1 &  dthdate<=mdy(6,1,2000)
	replace wave = 2002 if death == 1 &  inrange(dthdate,mdy(12,20,2000),mdy(3,3,2002))
	replace wave = 2005 if death == 1 &  inrange(dthdate,mdy(10,6,2002),mdy(2,29,2005))
	replace wave = 2008 if death == 1 &  inrange(dthdate,mdy(10,26,2005),mdy(12,31,2007))
	replace wave = 2011 if death == 1 &  inrange(dthdate,mdy(7,10,2009),mdy(1,10,2011))
	replace wave = 2014 if death == 1 &  inrange(dthdate,mdy(9,26,2012),mdy(1,22,2014))
	replace wave = 2018 if death == 1 &  dthdate>=mdy(11,30,2014)
	*/
	* age at death
	drop dage
	gen dage = agebase + year(dthdate)-year(interview_baseline)
	replace dage = agebase - 1 if month(dthdate)<month(interview_baseline)
	
	bysort id  (wave): replace dage = dage[_n-1] if dage== .
	
	drop followup dth 
	ren death deathstatus
	bysort id: egen deathsample = max(deathstatus)
	
	gen lostsample =  deathsample == 0 & dthdate == . 
	order id wave intdate lostsample deathstatus deathsample dthdate 
	sort id wave
	
	recode  wave (0 =2)(2 =3)(5 =4)(8 =5)(11 =6)(14 =7)(18 =8),gen(wave_temp)
	
	replace wave = 2018 if year(dthdate) >=2015 & wave == .
	
	bysort id: egen wave_baseline1 = mean(wave_baseline)
	drop wave_baseline
	ren wave_baseline1 wave_baseline
	
	* 192个intdate >dthdate
	drop if intdate >dthdate & intdate !=.
	
	drop insuranceOther

	drop Dcause
	
	gen caregivermale = caregiverSon==1| caregiverSinL==1 if caregiverSon!= . &  caregiverSinL!=.
	gen caregiverfemale = caregiverDaughter==1| caregiverDinL==1 if caregiverDaughter!= . &  caregiverDinL!=.
	gen ADLcaregivermale = ADLcaregiverSon==1| ADLcaregiverSinL==1 if ADLcaregiverSon!= . &  ADLcaregiverSinL!=.
	gen ADLcaregiverfemale = ADLcaregiverDaughter==1| ADLcaregiverDinL==1 if ADLcaregiverDaughter!= . &  ADLcaregiverDinL!=.
	
	* small adjustment on the death wave
	replace wave = 2014 if intdate ==. & inlist(id,32151908,32160308,32176802,32170908,32167708,32166908,32165108)
	
	recode hypertension diabetes heartdisea strokecvd copd tb cataract glaucoma cancer prostatetumor ulcer parkinson bedsore arthritis  dementia (3=0)
save "${OUT}/append all_fin.dta",replace

use  "${OUT}/append all_fin.dta",clear
	merge 1:1 id wave using "${INT}/weight.dta"
	drop if _m== 2
	drop _m
save "${OUT}/append all_fin.dta",replace
	
	
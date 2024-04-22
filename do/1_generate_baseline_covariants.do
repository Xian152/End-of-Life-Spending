/*******Purpose: Covariants Generation
1. lifestyle: smoking, drinking, activity, dietary behaviors
2. leisure
3. daily activity 
4. disease
5. self reported health
6. psychological health
7. cognition: MMSE 
8. height & weight, bmi
9. demographic 
10. biomarker: blood pressure 
11. socia leconomic: household annual average per capital income
*/

*****************************************************************
*************** 1. Standardize the name of raw variables ********
*****************************************************************
use "${SOURCE}/dat98_18F",clear	
	foreach k in d61 d62 d63 d64 d65 d71 d72 d73 d74 d75 d76 d81 d82 d83 d84{
		clonevar `k'_c = `k'
	}
******************* Lifestyle ******************
	*smoking
	ren	(d61_c d62_c d63_c d64_c d65_c) (r_smkl_pres r_smkl_past r_smkl_start r_smkl_quit r_smkl_freq)

	*drinking	
	ren (d71_c d72_c d73_c d74_c d75_c d76_c) (r_dril_pres r_dril_past r_dril_start r_dril_quit r_dril_type r_dril_freq)
	
	*pa
	ren (d81_c d82_c d83_c d84_c) (r_pa_pres r_pa_past r_pa_start r_pa_quit)

****************** Leisure *********************
	ren (d10a d10b d10c d10d d10e d10f d10g d10h) (housework_b98 fieldwork_b98 gardenwork_b98 reading_b98 pets_b98 majong_b98 tv_b98 socialactivity_b98) // socialactivity
	
*************** Blood Pressure Level **************
	recode g51 g52 (-1 888 999 = .),gen(SBP_b98 DBP_b98)
	
save "${INT}/dat98_18_renamed.dta",replace


foreach year in 00 02 05 08 11 14 18{
use "${SOURCE}/dat`year'_18F.dta",clear
	foreach k in  d71 d72 d73 d74 d75 d81 d82 d83 d84 d85 d86 d91 d92 d93 d94{
		clonevar `k'_c = `k'
	}
**********************Lifestyle******************
	* smoking
	ren	(d71_c d72_c d73_c d74_c d75_c) (r_smkl_pres r_smkl_past r_smkl_start r_smkl_quit r_smkl_freq)

	* drinking	
	ren (d81_c d82_c d83_c d84_c d85_c d86_c) (r_dril_pres r_dril_past r_dril_start r_dril_quit r_dril_type r_dril_freq)
		
	* pa
	ren (d91_c d92_c d93_c d94_c) (r_pa_pres r_pa_past r_pa_start r_pa_quit)

****************** Leisure *********************
	if inlist(wave,00){
		rename (d11a d11b d11c d11d d11e d11f d11g d11h) 	(housework_b`year' fieldwork_b`year' gardenwork_b`year' reading_b`year' pets_b`year' majong_b`year' tv_b`year' socialactivity_b`year' ) // religiousactivity
	}
	if inlist(wave,02){
		rename (d11a d11b d11c d11d d11e d11f d11g d11h) 	(housework_b`year' fieldwork_b`year' gardenwork_b`year' reading_b`year' pets_b`year' majong_b`year' tv_b`year' socialactivity_b`year' ) // socialactivity religiousactivity religiousactivity
	}
	if inlist(wave,05,08,11,14){
		rename (d11a d11b d11c d11d d11e d11f d11g d11h) 	(housework_b`year' fieldwork_b`year' gardenwork_b`year' reading_b`year' pets_b`year' majong_b`year' tv_b`year' socialactivity_b`year' ) // socialactivity
	}
	if inlist(wave,18){
		rename (d11a d11b1 d11c d11d d11e d11f d11g d11h) 	(housework_b`year' fieldwork_b`year' gardenwork_b`year' reading_b`year' pets_b`year' majong_b`year' tv_b`year' socialactivity_b`year' ) // socialactivity
	}	
*************** Blood Pressure Level **************
	if inlist(wave,00,02,05){
		recode g51 g52 (-1 888 999 = .), gen(SBP_b`year' DBP_b`year')
	}
	if inlist(wave,08,11,14,18){
		recode g511 g512 g521 g522(-1 888 999 = .)
		foreach k in g511 g512 g521 g522{
			replace `k' = . if `k' >300
		}
		egen SBP_b`year' = rowmean(g511 g512)
		egen DBP_b`year' = rowmean(g521 g522)
		recode SBP_b`year' DBP_b`year' (0 = .)
	}	
save "${INT}/dat`year'_18_renamed.dta",replace
}

*****************************************************************
*************** 2. Generate the variables **********************
*****************************************************************
foreach year in 98 00 02 05 08 11 14 18 {  //00 02 05 08 11 14 18
use "${INT}/dat`year'_18_renamed.dta",clear

drop 	coresidence  marital residence
	* ethnicity, fix the missing from repeated measure	
	gen coresidence_b`year'=a51 if !inlist(a51,9,.)
	label define coresidence_lb_b`year' 1 "with household members" 2"alone" 3"In an institution" 
	label value coresidence_b`year' coresidence_lb_b`year'
	
	
	gen marital_b`year'=.
	replace marital_b`year'=1 if f41==1
	replace marital_b`year'=2 if f41==2|f41==3|f41==5
	replace marital_b`year'=3 if f41==4
	label define marital_lb_b`year' 1 "currently married and living with spouse" 2"separted, divorced or never married" 3"widowed"
	label value marital_b`year' marital_lb
	
	* generate residenc and fix residenc from repeated measure
	if inlist(wave,98){
		gen residence_b`year'=residenc
	}
	if inlist(wave,00,02,05,08,11,14,18){
		gen residence_b`year'=1
		replace residence_b`year'=2 if residenc==3
	}
	label define residence_lb_b`year' 1 "urban (city or town)" 2"rural"
	label value residence_b`year' residence_lb_b`year'
	
	ren trueage trueage_b`year' 

******************* Demographic Recode ***********
	* Education 
	recode edu (-1 88 99 = . ) (0 = 1 "none") (1/5 = 2 "Primary School") (6/87 = 3 "Middle school or higher"), gen(edug)
	
	* Occupation
	recode f2 (9=.),gen(occu)
	
	* Marital
//	recode marital (3 = 2)  
//	label define marital 2 "separted, divorced, widowed or never married", modify
	
******************* Socialeconomic ***********
	* Annual household Income 
	recode a52 (-1 99 = .),gen(hhsize_b`year')
	replace hhsize_b`year' = 0 if a51 == 2 
	replace  hhsize_b`year' = hhsize_b`year' + 1 
	
	if inlist(wave,02,05,08,11,14,18){
		recode f35 (99999 88888 = .) (99998=100000),gen(hhIncome_b`year') 
		foreach k in 9 99 999 9999 9998 99999  8 88 888 8888 88888 {
			count if f35!=.
			local N r(N)
			count if hhIncome_b`year' == `k'
			local n r(N)
			recode hhIncome_b`year' (`k' = .) if `n'/`N' >= 0.01  
		}
	}
	
	if inlist(wave,08,11,14,18){
		gen hhIncomepercap_b`year' = hhIncome_b`year' / hhsize_b`year'
		replace hhIncome_b`year' =  hhIncome_b`year' * hhsize_b`year'
	}
	if inlist(wave,02,05){
		ren hhIncome_b`year'   hhIncomepercap_b`year'
		gen hhIncome_b`year' = hhIncomepercap_b`year' * hhsize_b`year'
	}	 
	
	* Social Security Insurnace （养老保险）
	if inlist(wave,11){
		ren (f64e1 f64f1 f64g1 f64h1 f6521) (f64e f64f f64g f64h f652) // 城职工，城居保,新农合，商业, payer
	}
	if inlist(wave,14){
		ren (f6521) (f652) //payer
	}
	
	if inlist(wave,18){
		recode f64i f64h f64g f64e f64d f64c f64b f64a ( 9 8 = .)
		* 医疗保险
		egen insurancetest_b`year'  = rowtotal(f64e  f64g) // 11: 47个有重复 城职工，城居保,新农合
		gen insurancePubMed_b`year' = 1 if  f64g ==1
		replace insurancePubMed_b`year' = 5 if  f64e ==1
		replace insurancePubMed_b`year' = 0 if insurancetest_b`year' == 0 
		replace insurancePubMed_b`year' = 3 if insurancetest_b`year' >=1 & residence_b`year' == 2 //重复的转新农合
		replace insurancePubMed_b`year' = 1 if insurancetest_b`year' >=1 & residence_b`year' == 1 & f64g == 1 //城职工
		replace insurancePubMed_b`year' = 4 if f64d == 1  & !inlist(insurancePubMed_b`year',1,2,3)
		drop  insurancetest_b`year' 
		label define insurancePubMed_b`year'  1"城职工" 2"城居保" 3"新农合" 4"其他公费医疗" 5"城职/居保（2018限定）" 0"无公共医保" 
		label values insurancePubMed_b`year' insurancePubMed_b`year'
	
		recode 	f64h (8 9 = .), gen(insuranceCommMed_b`year')	 
		
		gen insuranceMed_b`year'  = (insuranceCommMed_b`year'>=1 | insurancePubMed_b`year'>=1) if insuranceCommMed_b`year'!=. & insurancePubMed_b`year'==.			
	}
	
	if inlist(wave,05,08,11,14){
		recode f64i f64h f64g f64f f64e f64d f64c f64b f64a ( 9 8 = .)
		* 医疗保险
		egen insurancetest_b`year'  = rowtotal(f64e f64f f64g) // 11: 47个有重复 城职工，城居保,新农合
		gen insurancePubMed_b`year' = 1 if  f64e ==1
		replace insurancePubMed_b`year' = 2 if  f64f ==1
		replace insurancePubMed_b`year' = 3 if  f64g ==1
		replace insurancePubMed_b`year' = 0 if insurancetest_b`year' == 0 
		replace insurancePubMed_b`year' = 3 if insurancetest_b`year' >=2 & residence_b`year' == 2 //重复的转新农合
		replace insurancePubMed_b`year' = 1 if insurancetest_b`year' >=2 & residence_b`year' == 1 & f64e == 1 & f64g == 1 //城职工
		replace insurancePubMed_b`year' = 2 if insurancetest_b`year' >=2 & residence_b`year' == 1 & f64f == 1 & f64g == 1 //城职工
		replace insurancePubMed_b`year' = 4 if f64d == 1  & !inlist(insurancePubMed_b`year',1,2,3)
		drop  insurancetest_b`year' 
		label define insurancePubMed_b`year'  1"城职工" 2"城居保" 3"新农合" 4"其他公费医疗" 5"城职/居保（2018限定）" 0"无公共医保" 
		label values insurancePubMed_b`year' insurancePubMed_b`year'
	
		recode 	f64h (8 9 = .), gen(insuranceCommMed_b`year')	 
		
		gen insuranceMed_b`year'  = (insuranceCommMed_b`year'>=1 | insurancePubMed_b`year'>=1) if insuranceCommMed_b`year'!=. & insurancePubMed_b`year'==.	
	}	
	
	if inlist(wave,05,08,11,14,18){	
		* 养老保险
		egen insurancetest_b`year'  = rowtotal(f64a f64b) // 11: 47个有重复 退休金 养老金
		gen insurancePubRetire_b`year' = 1 if  f64a ==1 
		replace insurancePubRetire_b`year' = 2 if f64b ==1  
		replace insurancePubRetire_b`year' = 1 if  insurancetest_b`year' == 2 & occu < 7 
		replace insurancePubRetire_b`year' = 2 if  insurancetest_b`year' == 2 & occu == 7 
		replace insurancePubRetire_b`year' = 0 if insurancetest_b`year' ==0 
		drop  insurancetest_b`year' 
		label define insurancePubRetire_b`year'  1"退休金" 2"养老金" 0"无退休金或养老金"
		label values insurancePubRetire_b`year' insurancePubRetire_b`year'
				
		recode 	f64c (8 9 = .), gen(insuranceCommRetire_b`year')	
		
		gen insuranceRetire_b`year'  = insuranceCommRetire_b`year'>=1 | insurancePubRetire_b`year'>=1 if insurancePubRetire_b`year'!=. & insuranceCommRetire_b`year'==.
		
		recode 	f64i (8 9 = .), gen(insuranceOther_b`year')	
				
	}

	* Health Expense 
	if inlist(wave,05,08,11,14,18){
		recode f652 (99 -1 = .) (8 = 0 "no secure") (5 6 = 1 "self/spouse") (7 9 = 2 "children/others") ( 1 2 3 4 = 3 "insurance/health services"),gen(hexpPayer_b`year') label(hexpPayer)		
		gen hexpFinanceissue_b`year' = 0 if f61 !=.
		replace hexpFinanceissue_b`year' = 1 if f610 == 1 
	}
	
	if inlist(wave,05,08){
		recode f651b f651a (99998 = 100000) (888 99 198 88 99999 88888 = .),gen(hexpFampaid_b`year' hexpIndpaid_b`year' )
	}
	if inlist(wave,11,14,18){
		recode f651b1 f651a1 f651b2 f651a2 (99998 = 100000) (888 99 198 88 99999 88888 = .)
		
		recode f651b1 f651b2 (99998 = 100000)  (888 99 198 88 99 88888= .) ,gen(hexpFampaidOP_b`year' hexpFampaidIP_b`year')
		recode f651a1 f651a2 (99998 = 100000)  (888 99 198 88 99 88888= .) ,gen(hexpIndpaidOP_b`year' hexpIndpaidIP_b`year')

		egen hexpFampaid_b`year' = rowtotal(f651b1 f651b2 ),mi
		egen hexpIndpaid_b`year' = rowtotal(f651a1 f651a2 ),mi		
		
	}
	
	* health check
	if inlist(wave,11,14,18){
		recode f652b ( 2=0) (8 9 -1 =.),gen(healthcheck_b`year')
	}

	* distance to hospital
	if inlist(wave,18){
		replace f652a = subinstr(f652a,"-",".",.)
		replace f652a = subinstr(f652a,"/",".",.)
		replace f652a = subinstr(f652a,">","",.)
		replace f652a = subinstr(f652a," ","",.)
		replace f652a = "100" if strmatch(f652a,"100*")
		replace f652a = "300" if strmatch(f652a,"300*")
		replace f652a = "0.5" if strmatch(f652a,"*0.5")
		replace f652a = "50" if strmatch(f652a,"50*") & f652a!="500"
		destring f652a,replace
		recode f652a (88.00 98.00 99.00 -1 =.),gen(distanceHosp_b`year')
	}	
	if inlist(wave,11,14){
		recode f652a (88.00 98.00 99.00 -1 888 999 998 =.),gen(distanceHosp_b`year')
	}
	
	* 养老院
	gen nursingLiving_b`year'=1 if  a51 == 3
	replace nursingLiving_b`year'=0 if inlist(a51,1,2)
	
	recode a54a a54b (8888 9999 -1 88 99 = .)
	
	if inlist(wave,98){
		gen nurisngYear_b`year' = year9899 - a54a 
		replace nurisngYear_b`year' = nurisngYear_b`year' - 1 if (a54b > month98 | (a54b == month98 & date98 <15 )) & a54b!=. & a54a !=.
	}
	if inlist(wave,00,02){
		gen nurisngYear_b`year' = 20`year' - a54a
		replace nurisngYear_b`year' = nurisngYear - 1 if (a54b > month`year' | (a54b == month`year'& day`year' <15))  & a54b!=. & a54a !=.
	}	
	if inlist(wave,05){
		gen nurisngYear_b`year' = 2005 - a54a
		replace nurisngYear_b`year' = nurisngYear_b`year' - 1 if (a54b > monthin | ( a54b == monthin & dayin <15))  & a54b!=. & a54a !=.
	}	
	if inlist(wave,08,11,14,18){
		gen nurisngYear_b`year' = yearin - a54a 
		replace nurisngYear_b`year' = nurisngYear_b`year' - 1 if (a54b > monthin | ( a54b == monthin & dayin <15))  & a54b!=. & a54a !=.
	}	
	replace nurisngYear_b`year'  = . if nursingLiving_b`year'!=1 
	
	if inlist(wave,05,08,11,14,18){
		gen nursingCost_b`year' = a541 if a541>=0 & a541<8888
		recode a542 (1=0 "self") (3 4 = 1 "children") (5 6 = 2 "public/collection/others") (-1 8 9 = .) , gen(nursingCover_b`year') label(nursingCover_b`year') 
	}	
	
	* you want to live like 
	if inlist(wave,05,08,11,14,18){
		recode 	f16 (8 9 5 = .),gen(nursingLivingExpect_b`year')
	}
		
	* care giver when sick
	if inlist(wave,98,00,02,05,08,11){
		ren f5_11_14 f5_14
	}	
	if inlist(wave,14){
		ren f5_11 f5
	}	
	if inlist(wave,98,00){
		recode f5 (9 = .) 
	}	
	if inlist(wave,02,05,08,11,14,18){
		recode f5 (99 88 = .) 
	}	
	if inlist(wave,98){
		gen caregiverSpouse_b`year' = f5 == 1 if f5!=.
		gen caregiverOthFamily_b`year' = f5 == 3 if f5!=.
		gen caregiverFriend_b`year' = f5 == 4 if f5!=.
		gen caregiverSocial_b`year' = f5 == 5 if f5!=.
		gen caregiverCaregiver_b`year' = f5 == 6 if f5!=.
		gen caregiverNobody_b`year' = f5 == 7 if f5!=.
	}	
	if inlist(wave,00){
		gen caregiverSpouse_b`year' = f5 == 1 if f5!=.
		gen caregiverChild_b`year' = f5 == 2  if f5!=.
		gen caregiverGrandC_b`year' = f5 == 3 if f5!=.
		gen caregiverOthFamily_b`year' = f5 == 4 if f5!=.
		gen caregiverFriend_b`year' = f5 == 5 if f5!=.
		gen caregiverSocial_b`year' = f5 == 6 if f5!=.
		gen caregiverCaregiver_b`year' = f5 == 7 if f5!=.
		gen caregiverNobody_b`year' = f5 == 8 if f5!=.
	}	
	if inlist(wave,02){
		gen caregiverSpouse_b`year' = f5 == 0 if f5!=.
		gen caregiverSon_b`year' = f5 == 1  if f5!=.
		gen caregiverDaughter_b`year' = f5 == 2  if f5!=.
		gen caregiverChild_b`year' = f5 == 3  if f5!=.
		gen caregiverGrandC_b`year' = f5 == 4 if f5!=.
		gen caregiverOthFamily_b`year' = f5 == 5 if f5!=.
		gen caregiverFriend_b`year' = f5 == 6 if f5!=.
		gen caregiverSocial_b`year' = f5 == 7 if f5!=.
		gen caregiverCaregiver_b`year' = f5 == 8 if f5!=.
		gen caregiverNobody_b`year' = f5 == 9 if f5!=.
	}	
	if inlist(wave,05){
		gen caregiverSpouse_b`year' = f5 == 1 if f5!=.
		gen caregiverSon_b`year' = f5 == 2 if f5!=.
		gen caregiverDinL_b`year' = f5 == 3  if f5!=.
		gen caregiverDaughter_b`year' = f5 == 4   if f5!=.
		gen caregiverSinL_b`year' = f5 == 5 if f5!=.
		gen caregiverChild_b`year' = f5 == 6   if f5!=.
		gen caregiverGrandC_b`year' = f5 == 7 if f5!=.
		gen caregiverOthFamily_b`year' = f5 == 8 if f5!=.
		gen caregiverFriend_b`year' = f5 == 9 if f5!=.
		gen caregiverSocial_b`year' = f5 == 10 if f5!=.
		gen caregiverCaregiver_b`year' = f5 == 11 if f5!=.
		gen caregiverNobody_b`year' = f5 == 12 if f5!=.
	}	
	if inlist(wave,08){
		gen caregiverSpouse_b`year' = f5 == 1 if f5!=.
		gen caregiverSon_b`year' = f5 == 2 if f5!=.
		gen caregiverDinL_b`year' = f5 == 3  if f5!=.
		gen caregiverDaughter_b`year' = f5 == 4   if f5!=.
		gen caregiverSinL_b`year' = f5 == 5 if f5!=.
		gen caregiverChild_b`year' = f5 == 6   if f5!=.
		gen caregiverGrandC_b`year' = f5 == 7 if f5!=.
		gen caregiverOthFamily_b`year' = f5 == 8 if f5!=.
		gen caregiverFriend_b`year' = f5 == 9 if f5!=.
		gen caregiverSocial_b`year' = f5 == 10 if f5!=.
		gen caregiverCaregiver_b`year' = f5 == 11 if f5!=.
		gen caregiverNobody_b`year' = f5 == 12 if f5!=.
	}	
	if inlist(wave,11){
		gen caregiverSpouse_b`year' = f5 == 1 if f5!=.
		gen caregiverSon_b`year' = f5 == 2 if f5!=.
		gen caregiverDinL_b`year' = f5 == 3  if f5!=.
		gen caregiverDaughter_b`year' = f5 == 4   if f5!=.
		gen caregiverSinL_b`year' = f5 == 5 if f5!=.
		gen caregiverChild_b`year' = f5 == 6   if f5!=.
		gen caregiverGrandC_b`year' = f5 == 7 if f5!=.
		gen caregiverOthFamily_b`year' = f5 == 8 if f5!=.
		gen caregiverFriend_b`year' = f5 == 9 if f5!=.
		gen caregiverSocial_b`year' = f5 == 10 if f5!=.
		gen caregiverCaregiver_b`year' = f5 == 11 if f5!=.
		gen caregiverNobody_b`year' = f5 == 12 if f5!=.
	}
	if inlist(wave,14){
		gen caregiverSpouse_b`year' = f5 == 1 if f5!=.
		gen caregiverSon_b`year' = f5 == 2 if f5!=.
		gen caregiverDinL_b`year' = f5 == 3  if f5!=.
		gen caregiverDaughter_b`year' = f5 == 4   if f5!=.
		gen caregiverSinL_b`year' = f5 == 5 if f5!=.
		gen caregiverChild_b`year' = f5 == 6   if f5!=.
		gen caregiverGrandC_b`year' = f5 == 7 if f5!=.
		gen caregiverOthFamily_b`year' = f5 == 8 if f5!=.
		gen caregiverFriend_b`year' = f5 == 9 if f5!=.
		gen caregiverSocial_b`year' = f5 == 10 if f5!=.
		gen caregiverCaregiver_b`year' = f5 == 11 if f5!=.
		gen caregiverNobody_b`year' = f5 == 12 if f5!=.
	}		
	if inlist(wave,18){
		gen caregiverSpouse_b`year' = f5 == 1 if f5!=.
		gen caregiverSon_b`year' = f5 == 2 if f5!=.
		gen caregiverDinL_b`year' = f5 == 3  if f5!=.
		gen caregiverDaughter_b`year' = f5 == 4   if f5!=.
		gen caregiverSinL_b`year' = f5 == 5 if f5!=.
		gen caregiverChild_b`year' = f5 == 6   if f5!=.
		gen caregiverGrandC_b`year' = f5 == 7 if f5!=.
		gen caregiverOthFamily_b`year' = f5 == 8 if f5!=.
		gen caregiverFriend_b`year' = f5 == 9 if f5!=.
		gen caregiverSocial_b`year' = f5 == 10 if f5!=.
		gen caregiverCaregiver_b`year' = f5 == 11 if f5!=.
		gen caregiverNobody_b`year' = f5 == 12 if f5!=.
	}	
	
	* retirment 
	if inlist(wave,02,05,08,11,14,18){
		recode f211 (8=. ) (1 2 = 1 "Yes") (3 = 0 "No") (-1 = 2 "no pension for retirement"),gen(retiredWPension_b`year') label(retired_b`year')
		recode f22 (-1/1900 8888 9999 = .),gen(retiredYear_b`year')	
	}
	
	if inlist(wave,11,14,18){
		destring f26 ,replace
		recode f26 (9999 8888 = .),gen(pensionYearly_b`year')
		replace pensionYearly_b`year' = pensionYearly_b`year'*12  // 居然有0 怎么办？
	}
	* enough to pay
	if inlist(wave,02,05,08,11,14,18){
		recode f33 (8 9 =.) (2=0),gen(enoughpay_b`year')
	}
	
	* accessibility
	recode f61 (8 9 =.) (2=0),gen(accessCare_b`year')
	
	* why not visit 
	if inlist(wave,5,8,11,14,18){
		recode f610 (8 9 =.) (-1=0),gen(accessIssue_b`year')		
	}
********************** community ******************
	if inlist(wave,05,08,11,14,18){
		recode f141 (-9/-2 8 9 = .) (2=0) ,gen(CommunityCare_b`year')
		recode f147 (-9/-2 8 9 = .) (2=0) ,gen(CommunityEducationCare_b`year')
	}

********************** Lifestyle ******************
	* Smoking
	recode r_smkl_pres r_smkl_past  (-1 8 9 = .)
	recode r_smkl_freq (-1 88 99 = .)
	recode r_smkl_start r_smkl_quit (-1 888 999 = .)
	gen smkl_b`year' = 1 if r_smkl_pres == 2 & r_smkl_past == 2
	replace smkl_b`year' = 2 if !inlist(r_smkl_pres,1,.) & r_smkl_past == 1				// choose to code smk missing if r_smkl_pres is missing
	replace smkl_b`year' = 3 if r_smkl_pres == 1 & (r_smkl_freq * 1.4) >= 0 & (r_smkl_freq * 1.4) < 20
	replace smkl_b`year' = 4 if r_smkl_pres == 1 & (r_smkl_freq * 1.4) >= 20 & (r_smkl_freq * 1.4) <= 50
	label define smkl_b`year' 1 "never" 2 "former" 3 "light current" 4 "heavy current"
	label value smkl_b`year' smkl_b`year' 

	gen smkl_year_b`year' = r_smkl_quit - r_smkl_start
	
	* Drinking alchol
	if inlist(wave,18){
		replace r_dril_freq = "" if r_dril_freq > "999" 
		destring r_dril_freq,replace 
	}
	recode r_dril_freq (-1 88 99 = .)
	recode r_dril_pres r_dril_past r_dril_type (-1 8 9 = .)  
	gen alcohol = . 

	if inlist(wave,98){
		replace alcohol = r_dril_freq * 50 * 0.455 if r_dril_type == 1
		replace alcohol = r_dril_freq * 50 * 0.12 if r_dril_type == 2
		replace alcohol = r_dril_freq * 50 * 0.15 if r_dril_type == 3
	}
	if inlist(wave,00,02,05,08,11,14,18){
		replace alcohol = r_dril_freq * 50 * 0.53 if r_dril_type == 1
		replace alcohol = r_dril_freq * 50 * 0.38 if r_dril_type == 2
		replace alcohol = r_dril_freq * 50 * 0.12 if r_dril_type == 3
		replace alcohol = r_dril_freq * 50 * 0.15 if r_dril_type == 4
		replace alcohol = r_dril_freq * 50 * 0.04 if r_dril_type == 5
		replace alcohol = r_dril_freq * 50 * 0.244 if r_dril_type == 6
	}
	
	generate dril_b`year'=.
	replace dril_b`year'=1 if r_dril_pres==2 & r_dril_past==2
	replace dril_b`year'=2 if !inlist(r_dril_pres,1) & r_dril_past==1  				// choose to code dril missing if r_dril_pres is missing
	replace dril_b`year'=3 if gender==1 & r_dril_pres==1 & inrange(alcohol,0, 25)
	replace dril_b`year'=3 if gender==0 & r_dril_pres==1 & inrange(alcohol,0, 15)
	replace dril_b`year'=4 if gender==1 & r_dril_pres==1 & (alcohol > 25 & alcohol < . )  // & not |
	replace dril_b`year'=4 if gender==0 & r_dril_pres==1 & (alcohol > 15 & alcohol < . )
	label define dril_b`year' 1 "never" 2 "former" 3 "current & light" 4 "current & heavy"
	label value dril_b`year' dril_b`year'
	
	* Physical Activity
	recode r_pa_pres r_pa_past (-1 8 9 = .)
	recode r_pa_start (-1 888 999 = .)
	gen pa_b`year' = 1 if r_pa_pres == 1 & r_pa_start < 50
	replace pa_b`year' = 2 if r_pa_pres == 1 & r_pa_start >= 50 & r_pa_start < . // choose to code pa missing if r_pa_pres is missing
	replace pa_b`year' = 3 if r_pa_pres != 1 & r_pa_past == 1 
	replace pa_b`year' = 4 if r_pa_pres == 2 & r_pa_past == 2 
	label define pa_b`year' 1 "current & start < 50" 2 "current & start >=50" 3 "former" 4 "never"
	label value pa_b`year' pa_b`year' 
/*	
	recode r_pa_pres (2 = 0) (9 = .),gen(pa_alt)
	label define pa_b 1 "regular PA" 0 "no regular PA"
	label value pa_alt pa_b
*/		
	
	*Dietary Behavior 
	if inlist(wave,98,00,02,05){	
		* dietary: 1 2 3
		recode d31 d32 (1 2 = 1 "everday or excepte winter") (3 = 2 "occasionally") (4 = 3 "rarely or never") (-1 8 9 = .),gen(fruit_b`year' veg_b`year') label(dietfruit_b`year')
		
		recode d4bean2 d4egg2 d4fish2 d4garl2 d4meat2 d4suga2 d4tea2 d4veg2(1 = 1 "everyday") (2 = 2 "occasionally") (3 = 3 "rarely or never") (-1 8 9 6 7 = .),gen(bean_b`year' egg_b`year' fish_b`year' garlic_b`year' meat_b`year' sugar_b`year' tea_b`year' saltveg_b`year') label(dietbean_b`year')
		
	}
	if inlist(wave,08,11,14,18){	
		* dietary: 1 2 3	
		recode d31 d32 (1 2 = 1 "everday or excepte winter") (3 = 2 "occasionally") (4 = 3 "rarely or never") (-1 8 9 6 7 = .),gen(fruit_b`year' veg_b`year') label(dietfruit_b`year')
		recode d4bean2 d4egg2 d4fish2 d4garl2 d4meat2 d4suga2 d4tea2 d4veg2(1 = 1 "everyday") (2 3 4= 2 "occasionally") (5 = 3 "rarely or never") (-1 8 9 6 7 = .),gen(bean_b`year' egg_b`year' fish_b`year' garlic_b`year' meat_b`year' sugar_b`year' tea_b`year' saltveg_b`year') label(dietbean_b`year')
	}
	if inlist(wave,08,11,14,18){	
		recode d33  (-1 8 9 6 7 = .),gen(grease_b`year' ) label(grease_b`year')
	}	
	recode d1 (-1 8 9 6 7 = .),gen(staple_b`year' ) label(staple_b`year') 
	
	
********* ADL: activity of daily living *********
	*ADL
	recode e1 e2 e3 e4 e5 e6  (-1 8 9 = .),gen(bathing_b`year' dressing_b`year' toileting_b`year' transferring_b`year' continence_b`year' feeding_b`year') label(adl_row_b`year')
	
	egen adlMiss_b`year'= rowmiss(bathing_b`year' dressing_b`year' toileting_b`year' transferring_b`year' continence_b`year' feeding_b`year')
	egen adlSum_b`year' = rowtotal(bathing_b`year' dressing_b`year' toileting_b`year' transferring_b`year' continence_b`year' feeding_b`year')
		
	gen adl_b`year' = (adlSum_b`year' > 0) if adlSum_b`year' != .
	label define adl_b`year' 0"0:withSOURCE ADL" 1"1:with ADL"
	label value adl_b`year' adl_b`year'

	*IADL:
	if inlist(wave,02,05,08,11,14,18){	
		recode e7 e8  e9 e10 e11 e12 e13 e14 (-1 8 9 = .),gen(visit_b`year' shopping_b`year' cook_b`year' washcloth_b`year' walk1km_b`year' lift_b`year' standup_b`year' publictrans_b`year') label(iadl_row_b`year')
	
		egen iadlMiss_b`year'= rowmiss(visit_b`year' shopping_b`year' cook_b`year' washcloth_b`year' walk1km_b`year' lift_b`year' standup_b`year' publictrans_b`year')
		egen iadlSum_b`year' = rowtotal(visit_b`year' shopping_b`year' cook_b`year' washcloth_b`year' walk1km_b`year' lift_b`year' standup_b`year' publictrans_b`year')
				
		gen iadl_b`year' = (iadlSum_b`year' > 0) if iadlSum_b`year' != .
		label define iadl_b`year' 0"0:withSOURCE ADL" 1"1:with ADL"
		label value iadl_b`year' iadl_b`year'
	}
	
	
********************** caring related ******************	
	* care giver when ADL
	if inlist(wave,05,08,11,14,18){
		recode e610 (-1 88 99 98 = .)
	}		
	if inlist(wave,05,08,11,14,18){
		gen ADLcaregiverSpouse_b`year' = e610 == 1 if e610!=.
		gen ADLcaregiverSon_b`year' = e610 == 2 if e610!=.
		gen ADLcaregiverDinL_b`year' = e610 == 3  if e610!=.
		gen ADLcaregiverDaughter_b`year' = e610 == 4   if e610!=.
		gen ADLcaregiverSinL_b`year' = e610 == 5 if e610!=.
		gen ADLcaregiverChild_b`year' = e610 == 6   if e610!=.
		gen ADLcaregiverGrandC_b`year' = e610 == 7 if e610!=.
		gen ADLcaregiverOthFamily_b`year' = e610 == 8 if e610!=.
		gen ADLcaregiverFriend_b`year' = e610 == 9 if e610!=.
		gen ADLcaregiverSocial_b`year' = e610 == 10 if e610 !=.
		gen ADLcaregiverhousekeeper_b`year' = e610 == 11 if e610!=.
		gen ADLcaregiverNobody_b`year' = e610 == 12 if e610!=.
	}		
	
	
	if inlist(wave,05,08,11,14,18){
		recode e62 (-9/-1 99 98 88 9 8 = .) ,gen(ADLcaregiverWilling_b`year')
	}		
	if inlist(wave,05,08,11,14,18){
		recode e63 ( 999 888 99 88 99999 88888 99998 = .) (-1 =0) ,gen(ADLhexpcare_b`year')
		replace ADLhexpcare_b`year' = ADLhexpcare_b`year'* 4 * 12
		replace ADLhexpcare_b`year' = 0 if adlSum_b`year' == 0 
	}
	
	* payer for ADL 
	if inlist(wave,05,08,11,14,18){
		gen ADLcarepaierSelf_b`year' = e64 == 1 if e64!=.
		gen ADLcarepaierSpose_b`year' = e64 == 2 if e64!=.
		gen ADLcarepaierChild_b`year' = e64 == 3 if e64!=.
		gen ADLcarepaierGrandC_b`year' = e64 == 4 if e64!=.
		gen ADLcarepaierSocial_b`year' = e64 == 5 if e64 !=.
		gen ADLcarepaierOthers_b`year' = e64 == 6 if e64!=.
	}		
	
	* care for ADL is enough
	if inlist(wave,05,08,11,14,18){
		recode e65 (-9/-1 8 9  = .),gen(ADLmeet_b`year')
	}		

	* time care 
	if inlist(wave,05,08,11,14,18){
		recode e67 (-9/-1 999 888 998 = .) ,gen(ADLcaregtime_b`year')
	}	
********************** Leisure ******************
	cap gen fieldwork_b`year' = 0
	//cap gen religiousactivity = 0
	cap gen socialactivity_b`year' = 0 
	if inlist(wave,98,00){
		recode housework_b`year' fieldwork_b`year' gardenwork_b`year' reading_b`year' pets_b`year' majong_b`year' tv_b`year' socialactivity_b`year' (3 = 1) (2 = 2) (1 = 3) (-1 8 9 = .) // SOURCEdoor  religiousactivity 
	}

	if inlist(wave,02,05,08,11,14,18){
		recode housework_b`year' fieldwork_b`year' gardenwork_b`year' reading_b`year' pets_b`year' majong_b`year' tv_b`year' socialactivity_b`year' (5 = 1) (2 3 4 = 2) (1 = 3) (-1 8 9 = .) //  SOURCEdoor 
	}
	
	label define leisure_b`year' 1 "never" 2 "sometimes" 3 "almost everyday"
	label values housework_b`year' fieldwork_b`year' gardenwork_b`year' reading_b`year' pets_b`year' majong_b`year' tv_b`year' socialactivity_b`year' leisure_b`year' 

	egen leisureMiss_b`year' 	= rowmiss(housework_b`year' fieldwork_b`year' gardenwork_b`year' reading_b`year' pets_b`year' majong_b`year' tv_b`year' socialactivity_b`year')
	egen leisure_b`year' 		= rowtotal(housework_b`year' fieldwork_b`year' gardenwork_b`year' reading_b`year' pets_b`year' majong_b`year' tv_b`year' socialactivity_b`year')
	
	replace leisure_b`year' = . if leisureMiss_b`year' > 2 
	
******** Self-reported Disease History **********
	if inlist(wave,98){
		foreach k in a b c d e f g h i j k l m {
			gen disease_`k' = 0 if g17`k'1==1
			replace disease_`k' = 1  if g17`k'1==1 & g17`k'2==1
			replace disease_`k' = 2  if g17`k'1==1 & g17`k'2 != 1			// here Yaxi did deduction for missing value "8" "9"
			replace disease_`k' = 3  if g17`k'1==2 
			//replace disease_`k' = . if inlist(g17`k'1,8,9)
		}
		
		ren disease_a hypertension_b`year'
		ren disease_b diabetes_b`year'
		ren disease_c heartdisea_b`year'
		ren disease_d strokecvd_b`year'
		ren disease_e copd_b`year'
		ren disease_f tb_b`year'
		ren disease_g cataract_b`year'
		ren disease_h glaucoma_b`year'
		ren disease_i cancer_b`year'
		ren disease_j prostatetumor_b`year'
		ren disease_k ulcer_b`year'
		ren disease_l parkinson_b`year'
		ren disease_m bedsore_b`year'

		gen arthritis_b`year' = . 
	}
	
		label define disease 1"yes, cause disability" 2"yes,but no disability" 3"no"
	
	if inlist(wave,00,02,05,08,11,14,18){
		foreach k in a b c d e f g h i j k l m n o {
			gen disease_`k' = 0 if g15`k'1==1
			replace disease_`k' = 1  if g15`k'1==1 & g15`k'3 == 1
			replace disease_`k' = 2  if g15`k'1==1 & g15`k'3 != 1	// here Yaxi did deduction for missing value "8" "9"
			replace disease_`k' = 3  if g15`k'1==2 
			//replace disease_`k' = . if inlist(g15`k'3,8,9)
			label value  disease_`k' disease
		}

		ren disease_a hypertension_b`year'
		ren disease_b diabetes_b`year'
		ren disease_c heartdisea_b`year'
		ren disease_d strokecvd_b`year'
		ren disease_e copd_b`year'
		ren disease_f tb_b`year'
		ren disease_g cataract_b`year'
		ren disease_h glaucoma_b`year'
		ren disease_i cancer_b`year'
		ren disease_j prostatetumor_b`year'
		ren disease_k ulcer_b`year'
		ren disease_l parkinson_b`year'
		ren disease_m bedsore_b`year'
		ren disease_n arthritis_b`year' 
		ren disease_o dementia_b`year'
	}

	egen diseaseSum_b`year'  = rowtotal(hypertension_b`year' diabetes_b`year' heartdisea_b`year' strokecvd_b`year' copd_b`year' tb_b`year' cataract_b`year' glaucoma_b`year' cancer_b`year' prostatetumor_b`year' ulcer_b`year' parkinson_b`year' bedsore_b`year' arthritis_b`year'),mi
	
	gen disease_b`year' = 3 if diseaseSum_b`year' == 42
	foreach k in hypertension_b`year' diabetes_b`year' heartdisea_b`year' strokecvd_b`year' copd_b`year' tb_b`year' cataract_b`year' glaucoma_b`year' cancer_b`year' prostatetumor_b`year' ulcer_b`year' parkinson_b`year' bedsore_b`year' arthritis_b`year' {
		replace disease_b`year' = 1 if  `k' == 1
	}
	
	replace disease_b`year' = 2 if disease_b`year' == .
	replace disease_b`year' = . if diseaseSum_b`year' == .
	
*************** Self-reported Health **************
	recode b12 (8 9 = . ) (5=4),gen(srhealth_b`year')
	label define srhealth_b`year' 1 "Very good" 2 "good" 3 "fair" 4"Bad/Very bad"
	label value srhealth_b`year' srhealth_b`year'
	
	if inlist(wave,11,14,18){
		recode f47 (8 9 = . ) (5=4),gen(srhealthSopuse_b`year')
		label value srhealthSopuse_b`year' srhealth_b`year'
	}	
	
*************** Blood Pressure Level **************
	gen bpl_b`year' = 1 	if (SBP_b`year'>0 & SBP_b`year'<90) 	& (DBP_b`year'>0 & DBP_b`year'<60)
	replace bpl_b`year' = 2 if (SBP_b`year'>=90 & SBP_b`year'<=120) & (DBP_b`year'>=60 & DBP_b`year'<=80)	
	replace bpl_b`year' = 3 if (SBP_b`year'>120 & SBP_b`year'<140) 	& (DBP_b`year'>80 & DBP_b`year'<90)
	replace bpl_b`year' = 4 if (SBP_b`year'>=140 & SBP_b`year'<160) | (DBP_b`year'>=90 & DBP_b`year'<100)
	replace bpl_b`year' = 5 if (SBP_b`year'>=160 & SBP_b`year'<.) 	| (DBP_b`year'>=100 & DBP_b`year'<.)
	label variable bpl_b`year' "Hypertension condition"
	label define bpl_b`year' 1 "hypotension" 2 "Normal" 3 "Prehypertension" 4 "Stage I Hypertesnion" 5 "Stage II Hypertension" 
	label value bpl_b`year' bpl_b`year'

*************** Height, weight, BMI **************
	if inlist(wave,98){
		recode g12 g81 g82 (-1 888 999 = .), gen(weight_b`year' armlength_b`year' kneelength_b`year')
	}
	if inlist(wave,00){
		recode g10 (-1 888 999 = .), gen(weight_b`year') label(weight_b`year')
	}	
	if inlist(wave,02){
		recode g101 g102a g102b (-1 88 888 99 999 = .), gen(weight_b`year' armlength_b`year' kneelength_b`year') // note: code g101 = 99 to . b/c the frequenct of 88 & 99 is abnormal for this variables
	}
	if inlist(wave,05){
		recode g101 g102 (-1 999 = .), gen(weight_b`year' youngheight_b`year') 
	}
	if inlist(wave,08,11,14,18){
		recode g101 g1021 (-1 888 999 = .), gen(weight_b`year' meaheight_b`year') 
		recode g122 g123 (-1 88 99 888 999 = .), gen(armlength_b`year' kneelength_b`year')  // note: code (g122 g123 = 88 99) to . b/c the frequenct of 88 & 99 is abnormal for this variables
		gen height_b`year' = round(meaheight_b`year'/100, .01)
	}	
	* hunchbacked
	if inlist(wave,11,14,18){
		recode g102 (2=0) (9 8 -1 =.) ,gen(hunchbacked_b`year') 
	}		
	
		* Data cleaning for SW: HeartRate*BMI
		//replace weight = . if !inrange(weight,35,90) & gender == 1 
		//replace weight = . if !inrange(weight,25,80) & gender == 0 

	capture confirm variable height_b`year'
	if _rc == 0 {
			* Data cleaning for SW: HeartRate*BMI
			//replace height = . if !inrange(height,1.35,1.86) & gender == 1 
			//replace height = . if !inrange(height,1.20,1.78) & gender == 0

		* BMI 
		gen bmi_b`year'=weight_b`year'/(height_b`year'*height_b`year') 
		replace bmi_b`year'=. if bmi_b`year' < 12 | bmi_b`year' >= 40
		
			* Data cleaning for SW: HeartRate*BMI
			//replace height = . if !inrange(bmi,10,60)
	
		gen bmiCat_b`year'=.
		replace bmiCat_b`year'=1 if bmi_b`year'<18.5
		replace bmiCat_b`year'=2 if bmi_b`year'>=18.5 & bmi_b`year'<24
		replace bmiCat_b`year'=3 if bmi_b`year'>=24 & bmi_b`year'<.
		label define bmi_b`year' 1"underweight" 2"normal" 3"overweight"
		label value bmiCat_b`year' bmi_b`year'
	}	

*************** Biomarker **************
	* Heart Rate & rhythm
	if !inlist(wave,08,18){
		recode g7 (-1 888 999 = . ),gen(hr_b`year')
		recode g6 (1 = 0 "irregular") (2 = 1 "regular") (-1 8 9 = .),gen(hr_irr_b`year') label(rhythm_b`year')
	}
	if inlist(wave,08){
		recode g71 g72 (-1 888 999 = . )
		egen hr_b`year' = rowmean(g71 g72)
	}	
	if inlist(wave,18){
		recode g7 (-1 888 999 = . ),gen(hr_b`year')
	}	
	* Data cleaning for SW: HeartRate*BMI
	replace hr_b`year' = . if hr_b`year' >= 200 | hr_b`year' <= 30

********************** Psychology ******************
	if !inlist(wave,18){	
		recode b21 b22 b25 b27 (1 = 5 ) (2 = 4 ) (4 = 2) (5 = 1) (-1 8 9 = . ), gen(psy1_b`year' psy2_b`year' psy5_b`year' psy7_b`year')  //positive 
		recode b23 b24 b26 (-1 8 9 = .), gen(psy3_b`year' psy4_b`year' psy6_b`year') // negative 
	}
	if inlist(wave,18){	
		recode b21 b22 b23 (1 = 5 ) (2 = 4 ) (4 = 2) (5 = 1) (-1 8 9 = . ), gen(psy1_b`year' psy2_b`year' psy5_b`year' )  //positive 
		recode b24 b25 b27 (-1 8 9 = .), gen(psy3_b`year' psy4_b`year' psy6_b`year') // negative 
		gen psy7_b`year' = .
	}	
	egen psycho_b`year' = rowtotal(psy1_b`year' psy2_b`year' psy3_b`year' psy4_b`year' psy5_b`year' psy6_b`year' psy7_b`year')
	egen psyMiss_b`year' = rowmiss(psy1_b`year' psy2_b`year' psy3_b`year' psy4_b`year' psy5_b`year' psy6_b`year' psy7_b`year')
	
	replace psycho_b`year' = . if psyMiss_b`year' > 2 
	
	if inlist(wave,18){	
		replace psycho_b`year' = .
		replace psyMiss_b`year' = .
	}		



	
******************CI & MMSE ******************
*****cognition
	*orientation section
	recode c11 c12 c13 c14 c15 (0 8 = 0 "unable to answer or wrong") (1 = 1 "correct") (-1 9 = .), gen(time_orientation1 time_orientation2 time_orientation3 time_orientation4 place_orientation) label(ciorientation)

	*naming foods
	recode c16 (88 = 0 "unable to answer") (-1 99 = .), gen(namefo) label(cinamefo)
	replace namefo=7 if namefo>=7 & namefo<. 									
	
	*registration
	recode c21a c21b c21c (8 = 0 "wrong or unable to answer") (1 = 1 "correct") (-1 9 2 = .),gen(registration1 registration2 registration3) label(ciregistration)

	*attention and calculation--attempts to repeat the names of three objects correctly
	recode c31a c31b c31c c31d c31e (8 = 0 "wrong or unable to answer") (1 = 1 "correct") (-1 9 = .),gen(calculation1 calculation2 calculation3 calculation4 calculation5) label(ciattention)

	*recall
	recode c41a c41b c41c (8 = 0 "wrong or unable to answer") (1 = 1 "correct")  (-1 9 = .), gen(delayed_recall1 delayed_recall2 delayed_recall3) label(cirecall)

	*language
	recode c51a c51b c52 c53a c53b c53c(8 = 0) (-1 9 = .), gen(naming_objects1 naming_objects2 repeating_sentence listening_obeying1 listening_obeying2 listening_obeying3) label(cilanguage)
	
	*copy a figure
	recode c32 (8 = 0 "wrong or unable to answer") (1 = 1 "correct") (-1 9 = .),gen(copyf) label(cifigure)
	 
	*CI missing
	egen ciMissing_b`year' = rowmiss(time_orientation1 time_orientation2 time_orientation3 time_orientation4 place_orientation namefo registration1 registration2 registration3 calculation1 calculation2 calculation3 calculation4 calculation5 copyf delayed_recall1 delayed_recall2 delayed_recall3 naming_objects1 naming_objects2 repeating_sentence listening_obeying1 listening_obeying2 listening_obeying3)
	egen ci_b`year' = rowtotal(time_orientation1 time_orientation2 time_orientation3 time_orientation4 place_orientation namefo registration1 registration2 registration3 calculation1 calculation2 calculation3 calculation4 calculation5 copyf delayed_recall1 delayed_recall2 delayed_recall3 naming_objects1 naming_objects2 repeating_sentence listening_obeying1 listening_obeying2 listening_obeying3)
	
	replace ci_b`year' = . if ciMissing_b`year' > 3  

	egen time_orientation	= rowtotal(time_orientation1 time_orientation2 time_orientation3 time_orientation4)
	egen orientation		= rowtotal(time_orientation  place_orientation)
	egen registration		= rowtotal(registration1  registration2  registration3)
	egen calculation		= rowtotal(calculation1  calculation2  calculation3  calculation4  calculation5)
	egen delayed_recall		= rowtotal(delayed_recall1  delayed_recall2  delayed_recall3)
	egen naming_objects		= rowtotal(naming_objects1  naming_objects2)
	egen listening_obeying	= rowtotal(listening_obeying1  listening_obeying2  listening_obeying3)
	egen Language			= rowtotal(naming_objects  repeating_sentence  listening_obeying)
	
	gen orientation_full 	= (orientation == 5)
	gen namefo_full 		= (namefo == 7)
	gen registration_full 	= (registration == 3)
	gen calculation_full 	= (calculation == 5)
	gen copyf_full 			= (copyf == 1)
	gen delayed_recall_full = (delayed_recall == 3)
	gen Language_full		= (Language == 6)

	* MMSE
	egen mmse_b`year' =	rowtotal(orientation namefo registration calculation copyf delayed_recall Language),mi 
	
	gen ciCat_b`year'=.
	replace ciCat_b`year'=3 if mmse_b`year'>=0 & mmse_b`year'<=9
	replace ciCat_b`year'=2 if mmse_b`year'>=10 & mmse_b`year'<=17
	replace ciCat_b`year'=1 if mmse_b`year'>=18 & mmse_b`year'<=24
	replace ciCat_b`year'=0 if mmse_b`year'>=25 & mmse_b`year'<=30
	
	gen ciBi_b`year'=.
	replace ciBi_b`year'=0 if mmse_b`year'>25
	replace ciBi_b`year'=1 if mmse_b`year'<=25

	label define y 0"0:No CI"1"1:Mild CI"2"2:Moderate CI"3"3:Severe CI"
	label define u 0"0:No CI"1"1:CI BY 25MMSE"
	label value ciCat_b`year' y
	label value ciBi_b`year' u
	
/*
********************** Disablility ******************
	if inlist(wave,98){
		recode g17*2 (9 8 = .) (1 = 2 ) (2 = 1) (-1 3 = 0)
		replace g17*2 = 0 if 
		label define disability 2 "rather serious" 1"more or less" 0 "no"
		label values g17*2 disability
		egen disability = rowtotal(g17*2),mi
		egen disabilityMiss = rowmiss(g17*2)
		
		//replace disability = . if  disabilityMiss 
	}
	if inlist(wave,0,2,5,8,11,14){
		recode g15*3 (9 8 = .) (1 = 2 ) (2 = 1) (-1 3 = 0)
		label define disability 2 "rather serious" 1"more or less" 0 "no"
		label values g15*3 disability
		egen disability = rowtotal(g15*3),mi
		egen disabilityMiss = rowmiss(g15*3)
		
		//replace disability = . if  disabilityMiss 
	}
*/
	* hearing lost
	if inlist(wave,11,14,18){
		recode  g106 g1061 g1062 g1063(8 9 = .)
		gen hearingloss_b`year' = 1 if g106 == 1 
		replace hearingloss_b`year' = 2 if g106 == 1  & g1061 ==3 
		replace hearingloss_b`year' = 0 if g106 == 2 
	}	
******************* Realiability of the answers  *****************************
	*able to participate physical check?
	recode h21 (1 3 = 1 "able/patrically able") (2= 0 "no") (8 9 = .),gen(ablephy_b`year') label(ablephy_b`year')
	
	* reason
	recode h22 (-1 9 = .),gen(ablephyreas_b`year') label(ablephyreas_b`year')
	
******************* Frailty  **************
	* Self-reported Health Ordinal 
	recode b12 (1 = 0) (2=0.25) (3 = 0.5) (4 5 = 1) (-9/-1 8 9 = . ) ,gen(FRAsrh_b`year') // 4"Bad" 5 "Very bad"
	
	* health change
	if inlist(wave,02,05,08,11,14,18){
		recode b121 (1 = 0) (2=0.25) (3 = 0.5) (4 5 = 1) (-9/-1 8 9 = . ) ,gen(FRAhworse_b`year') 
	}
	
    * ADL: activity of daily living  Ordinal 
	recode e1 e2 e3 e4 e5 e6  (1 = 0 ) (2 = 0.5) (3 = 1 ) (-9/-1 8 9 = .),gen(FRAbathing_b`year' FRAdressing_b`year' FRAtoileting_b`year' FRAtransferring_b`year' FRAcontinence_b`year' FRAfeeding_b`year')  // 2:one part assistance 3: more than one part assistance
	
	*IADL:
	if inlist(wave,02,05,08,11,14,18){	
		recode e7 e8  e9 e10 e11 e12 e13 e14 (1 = 0 ) (2 = 0.5) (3 = 1 ) (-9/-1 8 9 = .),gen(FRAvisit_b`year' FRAshopping_b`year' FRAcook_b`year' FRAwashcloth_b`year' FRAwalk1km_b`year' FRAlift_b`year' FRAstandup_b`year' FRApublictrans_b`year') 
	}
	* Visual function Ordinal 
	if inlist(wave,98,02,05,08,11,14,18){
	recode g1 (1 = 0) (2 = 0.5) (3 4 = 1) (-9/-1 8 9 = .),gen(FRAvisual_b`year') // 3:  can't see 4: blind ??2  can see but can't distinguish the break in the circle 
	}

	* Functional: 
		*Hand behind neck & Hand behind lower back Ordinal & raise hands
		if inlist(wave,98){
			recode g101 g102 (1 2 =0.5) (4 = 1) (3 = 0) (-9/-1 8 9 = .),gen(FRAneck_b`year' FRAlowerback_b`year') // 1  right hand, 	2  left hand, 4  neither hand
		}	
		if inlist(wave,00){
			recode g81 g82 (1 2 =0.5) (4 = 1) (3 = 0) (-9/-1 8 9 = .),gen(FRAneck_b`year' FRAlowerback_b`year' ) // 1  right hand, 	2  left hand, 4  neither hand
		}		
		if inlist(wave,02,05,08,11,14,18){
			recode g81 g82 g83 (1 2 =0.5) (4 = 1) (3 = 0) (-9/-1 8 9 = .),gen(FRAneck_b`year' FRAlowerback_b`year' FRAraisehands_b`year') // 1  right hand, 	2  left hand, 4  neither hand
		}		
			
		* Able to stand up from sitting, Able to pick up a book from the floor
		if inlist(wave,98){
			recode g11 g13 (1 = 0) (2 = 0.5)  (3 = 1) (-9/-1 8 9 = .),gen(FRAstand_b`year' FRAbook_b`year' ) // 2  yes, using hands, 3  no ??? 2  yes, using hands //2  yes, sitting, 3  no ??? 2  yes, sitting
		}	
		if !inlist(wave,98){
			recode g9 g11 (1 = 0) (2 = 0.5)  (3 = 1) (-9/-1 8 9 = .),gen(FRAstand_b`year' FRAbook_b`year' ) // 2  yes, using hands, 3  no ??? 2  yes, using hands //2  yes, sitting, 3  no ??? 2  yes, sitting
		}		
		
	* Number of times suffering from serious illness in the past two years	Ordinal 
	if inlist(wave,98){
		recode g16 (0=0) (1 2 = 0.5) (3/88 = 1) (-9/-1 99  = . ),gen(FRAseriousillness_b`year')	
	}	
	if inlist(wave,00,02,05){
		recode g13 (0=0) (1 2 = 0.5) (3/88 = 1) (-9/-1 99  = . ),gen(FRAseriousillness_b`year')		
	}		
	if inlist(wave,08,11,14,18){
		recode g131 (0=0) (1 2 = 0.5) (3/88 = 1) (-9/-1 99  = . ),gen(FRAseriousillness_b`year')		
	}		
	
	* Self-reported Health Ordinal 
	gen FRAci_b`year' = 1 if mmse >=23 & mmse !=.
	replace FRAci_b`year' = 0 if mmse <23 
	replace FRAci_b`year' = . if mmse ==.

******** Self-reported Disease History **********
//Hypertension,Diabetes,Heart disease,Stroke or CVD,COPD,Tuberculosis,Cancer,Gastric or duodenal ulcer,Parkinsons,Bedsore,Cataract,Glaucoma,Other chronic disease	Categorical ?????????, Prostate Tumor cancer
	if inlist(wave,98){
		foreach k in a b c d e f g h i j k l m {
			gen disease_`k' = 1 if g17`k'1==1
			replace disease_`k' = 0  if g17`k'1==2 
		}
		
		ren disease_a FRAhypertension_b`year'
		ren disease_b FRAdiabetes_b`year'
		ren disease_c FRAhtdisea_b`year'
		ren disease_d FRAstrokecvd_b`year'
		ren disease_e FRAcopd_b`year'
		ren disease_f FRAtb_b`year'
		ren disease_g FRAcataract_b`year'
		ren disease_h FRAglaucoma_b`year'
		ren disease_i FRAcancer_b`year'
		ren disease_j FRAprostatetumor_b`year'
		ren disease_k FRAulcer_b`year'
		ren disease_l FRAparkinson_b`year'
		ren disease_m FRAbedsore_b`year'
		recode g17n1 (-9/-1 3 88 99 = .) (2 = 0) (1 4/20 = 1) ,gen(FRAotherchronic_b`year')	
	}
		
	if inlist(wave,00,02,05,08,11,14,18){
		foreach k in a b c d e f g h i j k l m n o  {
			gen disease_`k' = 1 if g15`k'1==1
			replace disease_`k' = 0  if g15`k'1==2 
		}
		
		foreach k in n {
			gen disease_`k'a = 1 if g15`k'1==1
			replace disease_`k'a = 0  if g15`k'1==2 
		}		

		ren disease_a FRAhypertension_b`year'
		ren disease_b FRAdiabetes_b`year'
		ren disease_c FRAhtdisea_b`year'
		ren disease_d FRAstrokecvd_b`year'
		ren disease_e FRAcopd_b`year'
		ren disease_f FRAtb_b`year'
		ren disease_g FRAcataract_b`year'
		ren disease_h FRAglaucoma_b`year'
		ren disease_i FRAcancer_b`year'
		ren disease_j FRAprostatetumor_b`year'
		ren disease_k FRAulcer_b`year'
		ren disease_l FRAparkinson_b`year'
		ren disease_m FRAbedsore_b`year'
 		ren disease_n FRAarthritis_b`year'
		ren disease_o FRAdementia_b`year'

		gen FRArheumatism_b`year' = 1 if disease_n==1 | disease_na==1
		replace FRArheumatism_b`year' = 0 if disease_n==0 & disease_na==0
		
		replace FRAhypertension_b`year' = 1 if (SBP_b`year'>=140 & SBP_b`year'!=.) | (DBP_b`year'>=90 & DBP_b`year'!=.)
	}
	
	* sleep
	if inlist(wave,18){	
		recode b310a (1 = 0) (2 =0.25) (3 =0.5)  (4 5  = 1 ) (-9/-1 8 9 = .),gen(FRAsleep_b`year') // 4: bad 5: very bad
	}	
	if inlist(wave,05,08,11,14){
		recode g01 (1 = 0) (2 =0.25) (3 =0.5)  (4 5  = 1 ) (-9/-1 8 9 = .),gen(FRAsleep_b`year') // 4: bad 5: very bad
	}		
		
	* Able to hear
	if inlist(wave,98){	
		recode h1a (1=0) (2 =0.25) (3 =0.5) (4 = 1)  (-9/-1 8 9 = .),gen(FRAhear_b`year') //  2: yes, but needs hearing aid, 3: partly, despite hearing aid, 4: no ???? 
	}
	if inlist(wave,00,02,05,08,11,14,18){
		recode h1 (1=0) (2 =0.25) (3 =0.5) (4 = 1)  (-9/-1 8 9 = .),gen(FRAhear_b`year') //  2: yes, but needs hearing aid, 3: partly, despite hearing aid, 4: no ????
	}	
	* Interviewer rated health	
	recode h3 (1 = 0) (2=0.25)  (3=0.5) (3 4 = 1) (-9/-1 8 9= .),gen(FRAirh_b`year')
	
	* psychol
 	/*Look on the bright side of things 
 	Keep my belongings neat and clean	 
 	Make own decisions	 
 	Feel fearful or anxious	 
 	Feel useless with age	*/ 
	if !inlist(wave,18){	
		recode b21 b22 b25  (1=0)  (2 = 0.25) (3 = 0.5 ) (4 5 = 1) (-9/-1 8 9 = . ), gen(FRApsy1_b`year' FRApsy2_b`year' FRApsy5_b`year' )  //positive  1  always,2  often,3  sometimes,4  seldom,5  never
		recode b23 b26 (1 2 =1)  (3 = 0.5 ) (4 =0.25) (5 = 0) (-9/-1 8 9 = . ), gen(FRApsy3_b`year' FRApsy6_b`year') // negative 1  always,2  often,3  sometimes,4  seldom,5  never
	}
	if inlist(wave,18){	
		recode b21 b22 b23 (1 = 5 ) (2 = 4 ) (4 = 2) (5 = 1) (-9/-1 8 9 = . ), gen(FRApsy1_b`year' FRApsy2_b`year' FRApsy5_b`year' )  //positive 
		recode b25 b27 (-1 8 9 = .), gen(FRApsy3_b`year' FRApsy6_b`year') // negative 
	}	

	* Housework at present	
	recode  housework (1 2 =0) (3 4=0.5 ) (5=1) (-9/-1 8 9 = . ),gen(FRAhousework_b`year') // 3: never
	
	* Able to use chopsticks to eat
	recode g3 (1=0) (2=1) (-9/-1 8 9 = . ),gen(FRAchopsticks_b`year') 
	
	* Number of steps used to turn around a 360 degree turn without help
	if inlist(wave,98){	
		recode g14 (20/88 = 1) (10/19 = 0.5) (5/9 = 0.25) (1/4 = 0) (-9/-1 0 89/888 = .) ,gen(FRAturn_b`year')
	}		
	if inlist(wave,00,02,05,08,11,14,18){
		recode g12 (20/88 = 1) (10/19 = 0.5) (5/9 = 0.25) (1/4 = 0) (-9/-1 0 89/888 = .) ,gen(FRAturn_b`year')
	}	
	* Heart Rate & rhythm
	if !inlist(wave,08,18){
		recode g7 (-1 888 999 = . ),gen(FRAhr_b`year')
		foreach k in FRAhr_b`year' {
			sum `k' 
			replace `k' = . if !inrange(`k',r(mean)-3*r(sd),r(mean)+3*r(sd)) 
		}		
		recode FRAhr_b`year' (0/60 = 0) (60.5/80 =0.25) (80.5/90 = 0.5) (90.5/115 = 0.75) (115.5/200 = 1) (888 999 =.)
		recode g6 (1 = 0 "irregular") (2 = 1 "regular") (-1 8 9 = .),gen(hr_irr) label(rhythm)
	}
	if inlist(wave,08){
		recode g71 g72 (-9/-1 888 999 = . )
		egen FRAhr_b`year' = rowmean(g71 g72)
		foreach k in FRAhr_b`year' {
			sum `k' 
			replace `k' = . if !inrange(`k',r(mean)-3*r(sd),r(mean)+3*r(sd)) 
		}	
		recode FRAhr_b`year' (0/60 = 0) (60.5/80 =0.25) (80.5/90 = 0.5) (90.5/115 = 0.75) (115.5/200 = 1) (888 999 =.)
	}	
	if inlist(wave,18){
		recode g7 (-1 888 999 = . ),gen(FRAhr_b`year')
		foreach k in FRAhr_b`year' {
			sum `k' 
			replace `k' = . if !inrange(`k',r(mean)-3*r(sd),r(mean)+3*r(sd)) 
		}		
		recode FRAhr_b`year' (0/60 = 0) (60.5/80 =0.25) (80.5/90 = 0.5) (90.5/115 = 0.75) (115.5/200 = 1) (888 999 =.)
	}		
	
	* physical 
	* BMI
	if inlist(wave,08,11,14,18){	
		gen FRAbmi_b`year'= 1 if weight_b`year'/(height_b`year'*height_b`year')<18.5 | weight_b`year'/(height_b`year'*height_b`year')>=28
		replace FRAbmi_b`year'= 0.5 if weight_b`year'/(height_b`year'*height_b`year')<28 & weight_b`year'/(height_b`year'*height_b`year')>=24
		replace FRAbmi_b`year'= 0 if weight_b`year'/(height_b`year'*height_b`year')<24 & weight_b`year'/(height_b`year'*height_b`year')>=18.5
		replace FRAbmi_b`year'= . if weight_b`year'/(height_b`year'*height_b`year')==.
		 
	}		
	
	
******************* children and fertility  **************
	* number of children ever born
	if inlist(wave,98,0,2,5,8,14,18){
		recode f10 (-1 88 99 =.),gen(numchild_b`year')
	}
	
	* age of birth
	if inlist(wave,0,2,5,8,14,18){
		recode f101 f102 (-1 88 99 = .),gen(agefirstbirth_b`year' agelastbirth_b`year')
	}
	
	* year of birth 
	if inlist(wave,0,2,5,8,14,18){
		gen yearfirstbirth_b`year' = year(interview_baseline)-(trueage_b`year' - agefirstbirth_b`year') if agefirstbirth_b`year' !=.  
		gen yearlastbirth_b`year' = year(interview_baseline)-(trueage_b`year' - agelastbirth_b`year') if agelastbirth_b`year'!=.  
		replace yearfirstbirth_b`year' = . if agefirstbirth_b`year' > agelastbirth_b`year' & agefirstbirth_b`year'!=.
		replace yearlastbirth_b`year' = . if agefirstbirth_b`year' > agelastbirth_b`year' & agefirstbirth_b`year'!=. 
		gen yeargapbirth_b`year'= yearlastbirth_b`year' - yearfirstbirth_b`year'	

		gen yearavebirth_b`year' = round(yeargapbirth_b`year' / numchild_b`year')
	}

	*by gender 
	if inlist(wave,11){
		recode f1030 ( 8 9 -1 = .),gen(sonnumalive_b`year')
		recode f1031 ( 8 9 -1 = .),gen(dautnumalive_b`year')
	}
	
	*child visit
	if inlist(wave,11){
		gen childvisit_b`year' = 1 if f1032==1 |f1033 ==1 
		replace childvisit_b`year' = 0 if inlist(f1032,0,3) & inlist(f1033,0,3)
	}	
	
* fix dth
	if !inlist(wave,18){
		recode dth18 (.=-8)
	}
	
	foreach k in 0 2 5 8{
	if inlist(wave,`k'){	
			foreach var of varlist *_b0`k'{
				local b = subinstr("`var'","_b0`k'","",.)
				ren `b'_b0`k' `b'_b`k'
			}
		}
	}
******************* interview date  **************
	if inlist(wave,98){
		ren date98 dayin_b98
		ren day_0  dayin_0
		ren day_2  dayin_2
		ren day_5  dayin_5
		ren day_8  dayin_8
		
		ren month98 monthin_b98
		ren month_0 monthin_0
		ren month_2 monthin_2
		ren month_5 monthin_5
		ren month_8 monthin_8
		
		ren year9899 yearin_b98
		gen yearin_0 = 2000
		gen yearin_2 = 2002
		gen yearin_5 = 2005
		ren year_8 yearin_8
	}
	
	if inlist(wave,00){
		ren day00  dayin_b0
		ren day_2  dayin_2
		ren day_5  dayin_5
		ren day_8  dayin_8

		ren month00 monthin_b0
		ren month_2 monthin_2
		ren month_5 monthin_5
		ren month_8 monthin_8

		gen yearin_b0 = 2000
		gen yearin_2 = 2002
		gen yearin_5 = 2005
		ren year_8 yearin_8
	}	
	
	if inlist(wave,02){
		ren day02  dayin_b2
		ren day_5  dayin_5
		ren day_8  dayin_8

		ren month02 monthin_b2
		ren month_5 monthin_5
		ren month_8 monthin_8

		
		gen yearin_b2 = 2002
		gen yearin_5 = 2005
		ren year_8 yearin_8

	}	
	
	if inlist(wave,05){
		ren dayin  dayin_b5
		ren day_8  dayin_8
		
		ren monthin monthin_b5
		ren month_8 monthin_8

		
		gen yearin_b5 = 2005
		ren year_8 yearin_8
	}
	
	if inlist(wave,08){
		ren dayin  dayin_b8
		ren monthin monthin_b8
		ren yearin yearin_b8
	}	
	
	
	if inlist(wave,11){
		ren dayin  dayin_b11
		ren monthin monthin_b11
		ren yearin yearin_b11
	}		
	
	if inlist(wave,14){
		ren dayin  dayin_b14
		ren monthin monthin_b14
		ren yearin yearin_b14
	}	
	
	if inlist(wave,18){
		ren dayin  dayin_b18
		ren monthin monthin_b18
		ren yearin yearin_b18
	}	
save "${OUT}/Full_dat`year'_18_covariances.dta",replace   	
}

/*
use "${OUT}/Full_dat14_18_covariances.dta",clear
	keep id
	duplicates drop
	tempfile t1
save `t1',replace

use "${OUT}/Full_dat18_18_covariances.dta",clear
	merge 1:1 id using `t1'
	keep if _m ==1 
save "${OUT}/Base_dat18_18_covariances.dta",replace
*/

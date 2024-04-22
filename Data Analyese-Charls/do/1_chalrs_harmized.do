use "${raw}/H_CHARLS_D_Data.dta",clear
* demograph
	foreach k in 1 2 3 4{
		ren r`k'agey age_r_`k'
		ren s`k'agey age_s_`k'
	}
	ren ragender gender_r
	foreach k in 1 2 3 4{
		ren s`k'gender gender_s_`k'
	}	
* interview //r1iwy r2iwy r3iwy r4iwy s1iwy s2iwy s3iwy s4iwy r1iwm r2iwm r3iwm r4iwm s1iwm s2iwm s3iwm s4iwm
	foreach k in 1 2 3 4{
		ren r`k'iwy yearin_r_`k'
		ren s`k'iwy yearin_s_`k'
		ren r`k'iwm monthin_r_`k'
		ren s`k'iwm monthin_s_`k'
	}
	
  	foreach k in 1 2  3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		gen double interviewdate_r_`k' = mdy(monthin_r_`k',1, yearin_r_`k')
		gen double interviewdate_s_`k' = mdy(monthin_s_`k',1, yearin_s_`k')
} 	
* social economics
	ren raeducl educ
	foreach k in 1 2 3 4{
		recode r`k'mstat s`k'mstat(8=1 "never married") (1 3 = 2 "married/partnered") (4 5 7 = 3 "SDW"),gen(marital_r_`k' marital_s_`k') label(marital_`k')
	}
	
	foreach k in 1 2 3 4{
		ren r`k'hukou hukou_r_`k'
		ren s`k'hukou hukou_s_`k'
	}
	foreach k in 1 2 3 4{ //h1rural h2rural h3rural h4rural
		recode r`k'rural2  s`k'rural2 (1=0) (0=1),gen(residence_r_`k' residence_s_`k')
	}		
	foreach k in 2 3 4{ //
		recode r`k'nhmliv s`k'nhmliv (.=.),gen(coresidence_r_`k' coresidence_s_`k')
	}		
* SRH
	foreach k in 1 2 3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		recode r`k'shlta s`k'shlta (.=.),gen(srh_r_`k' srh_s_`k')
	}		
*health expenditure
 	foreach k in 1 2 3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		gen HexpOOPOP_r_`k' = r`k'oopdoc1m * 12
		gen HexpOP_r_`k' = r`k'totdoc1m * 12
		gen HexpOOPOP_s_`k' = s`k'oopdoc1m * 12
		gen HexpOP_s_`k' = s`k'totdoc1m * 12
	} 	
 	foreach k in 1 2 3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		gen HexpOOPIP_r_`k' = r`k'oophos1y 
		gen HexpIP_r_`k' = r`k'tothos1y
		gen HexpOOPIP_s_`k' = s`k'oophos1y 
		gen HexpIP_s_`k' = s`k'tothos1y
	} 		
 	foreach k in 2 3 { //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		gen HexpOOPDent_r_`k' = r`k'oopden1y
		gen HexpDent_r_`k' = r`k'totden1y	
		gen HexpOOPDent_s_`k' = s`k'oopden1y
		gen HexpDent_s_`k' = s`k'totden1y	
	} 
*Insurance & income
 	foreach k in 1 2 3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		ren r`k'itearn Income_r_`k'	
		ren r`k'higov InsurancePubMed_r_`k'	
		ren r`k'hipriv InsuranceComMed_r_`k'	
		ren r`k'hiothp InsuranceOthMed_r_`k'	
		
		ren s`k'itearn Income_s_`k'	
		ren s`k'higov InsurancePubMed_s_`k'	
		ren s`k'hipriv InsuranceComMed_s_`k'	
		ren s`k'hiothp InsuranceOthMed_s_`k'	
	}	

* ADL  
	foreach k in 1 2 3 4{ 
		ren r`k'dressa ADLdressing_r_`k'
		ren r`k'batha ADLbathing_r_`k'
		ren r`k'eata ADLeating_r_`k'
		ren r`k'beda ADLbeding_r_`k'
		ren r`k'toilta ADLtolite_r_`k'
		ren r`k'urina ADLurin_r_`k'
		ren r`k'medsa ADLmedic_r_`k'
		ren r`k'mealsa ADLcook_r_`k'
		ren r`k'shopa ADLshop_r_`k'
		ren r`k'moneya ADLmanagemoney_r_`k'
		ren r`k'housewka ADLcleanhouse_r_`k'

		ren s`k'dressa ADLdressing_s_`k'
		ren s`k'batha ADLbathing_s_`k'
		ren s`k'eata ADLeating_s_`k'
		ren s`k'beda ADLbeding_s_`k'
		ren s`k'toilta ADLtolite_s_`k'
		ren s`k'urina ADLurin_s_`k'
		ren s`k'medsa ADLmedic_s_`k'
		ren s`k'mealsa ADLcook_s_`k'
		ren s`k'shopa ADLshop_s_`k'
		ren s`k'moneya ADLmanagemoney_s_`k'
		ren s`k'housewka ADLcleanhouse_s_`k'	
	}
	foreach k in 2 3 4{ 
		ren r`k'phonea ADLphone_r_`k'
		ren s`k'phonea ADLphone_s_`k'
	}		
	
	foreach k in 1 2 3 4{ 
		egen ADLsum_r_`k' = rowtotal(ADL*_r_`k')
		gen adlbi_r_`k' = ADLsum_r_`k'==0 if ADLsum_r_`k'!=.

		egen ADLsum_s_`k' = rowtotal(ADL*_s_`k')
		gen adlbi_s_`k' = ADLsum_s_`k'==0 if ADLsum_s_`k'!=.
	}		
	
*IADL 
	foreach k in 1 2 3 4{ // 
		ren r`k'joga IADLjogging_r_`k'
		ren r`k'walk1kma IADLwalk1km_r_`k'
		ren r`k'walk100a IADLwalk100m_r_`k'
		ren r`k'chaira IADLstandchair_r_`k'
		ren r`k'climsa IADLclimbflight_r_`k'
		ren r`k'stoopa IADLstoopkneelcrouch_r_`k'
		ren r`k'armsa IADLarmup_r_`k'
		ren r`k'lifta IADLlift10jin_r_`k'
		ren r`k'dimea IADLpickdim_r_`k'
		
		ren s`k'joga IADLjogging_s_`k'
		ren s`k'walk1kma IADLwalk1km_s_`k'
		ren s`k'walk100a IADLwalk100m_s_`k'
		ren s`k'chaira IADLstandchair_s_`k'
		ren s`k'climsa IADLclimbflight_s_`k'
		ren s`k'stoopa IADLstoopkneelcrouch_s_`k'
		ren s`k'armsa IADLarmup_s_`k'
		ren s`k'lifta IADLlift10jin_s_`k'
		ren s`k'dimea IADLpickdim_s_`k'
	}
	
	foreach k in 1 2 3 4{ //  
		egen IADLsum_r_`k' = rowtotal(IADL*_r_`k')
		gen iadlbi_r_`k' = IADLsum_r_`k'==0 if IADLsum_r_`k'!=.

		egen IADLsum_s_`k' = rowtotal(IADL*_s_`k')
		gen iadlbi_s_`k' = IADLsum_s_`k'==0 if IADLsum_s_`k'!=.
	}	
	
	
* caregiver 
  	foreach k in  2 3 4{ 
		ren (r`k'rcaany r`k'rcany r`k'rfaany) (ADLinformalCare_r_`k' ADLCare_r_`k' ADLformalCare_r_`k') 
		ren (r`k'rccare r`k'rccaredpm r`k'rccarehr r`k'rccaren ) (ADLcaregiverChild_r_`k'  ADLcaregiverChildDays_r_`k'  ADLcaregiverChildHours_r_`k'  ADLcaregiverChildNum_r_`k' )
		
		ren (r`k'rrcare  r`k'rrcaren ) (ADLcaregiverRelative_r_`k'  ADLcaregiverRelativeNum_r_`k' )
		ren (r`k'rscare ) (ADLcaregiverSpouse_r_`k'      )
} 

  	foreach k in  3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		ren (r`k'rfcare )  ( ADLcaregiverNonRela_r_`k' )
		ren (r`k'rrcaredpm r`k'rrcarehr)  (ADLcaregiverRelativeDays_r_`k'  ADLcaregiverRelativeHours_r_`k')
		ren (r`k'rscaredpm  ) (ADLcaregiverSpouseDays_r_`k')
		ren (r`k'rscarehr      ) (ADLcaregiverSpouseHours_r_`k'    )

} 	

  	foreach k in  2 3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		ren (s`k'rcaany s`k'rcany s`k'rfaany) (ADLinformalCare_s_`k' ADLCare_s_`k' ADLformalCare_s_`k') 
		ren (s`k'rccare s`k'rccaredpm s`k'rccarehr s`k'rccaren ) (ADLcaregiverChild_s_`k'  ADLcaregiverChildDays_s_`k'  ADLcaregiverChildHours_s_`k'  ADLcaregiverChildNum_s_`k' )
		
		ren (s`k'rrcare  s`k'rrcaren ) (ADLcaregiverRelative_s_`k'  ADLcaregiverRelativeNum_s_`k' )
		ren (s`k'rscare ) (ADLcaregiverSpouse_s_`k'      )
} 

  	foreach k in  3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		ren (s`k'rfcare )  ( ADLcaregiverNonRela_s_`k' )
		ren (s`k'rrcaredpm s`k'rrcarehr)  (ADLcaregiverRelativeDays_s_`k'  ADLcaregiverRelativeHours_s_`k')
		ren (s`k'rscaredpm  ) (ADLcaregiverSpouseDays_s_`k')
		ren (s`k'rscarehr      ) (ADLcaregiverSpouseHours_s_`k'    )

}	
	
* Social Activites
	foreach k in 1 2 3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		ren r`k'socwk activities_r_`k'
		ren s`k'socwk activities_s_`k'
		
	}		

* weight
  	foreach k in 1 2  3 4{ //  r1shlt r2shlt r3shlt     r1shlta r2shlta r3shlta r4shlta
		ren (r`k'wtresp   r`k'wtrespb) (wtresp_`k'   wtrespb_`k')
} 
	keep ID communityID *_* gender*  ID_w1 educ
	
	reshape long wtresp_ wtrespb_ yearin_r_ yearin_s_ monthin_r_ monthin_s_ age_r_ age_s_ gender_s_ hukou_r_ hukou_s_ ADLdressing_r_ ADLdressing_s_ ADLbathing_r_ ADLbathing_s_ ADLeating_r_ ADLeating_s_ ADLbeding_r_ ADLbeding_s_ ADLtolite_r_ ADLtolite_s_ ADLurin_r_ ADLurin_s_ ADLphone_r_ ADLphone_s_ ADLmanagemoney_r_ ADLmanagemoney_s_ ADLmedic_r_ ADLmedic_s_ ADLshop_r_ ADLshop_s_ ADLcook_r_ ADLcook_s_ ADLcleanhouse_r_ ADLcleanhouse_s_ IADLjogging_r_ IADLjogging_s_ IADLwalk1km_r_ IADLwalk1km_s_ IADLwalk100m_r_ IADLwalk100m_s_ IADLstandchair_r_ IADLstandchair_s_ IADLclimbflight_r_ IADLclimbflight_s_ IADLstoopkneelcrouch_r_ IADLstoopkneelcrouch_s_ IADLlift10jin_r_ IADLlift10jin_s_ IADLpickdim_r_ IADLpickdim_s_ IADLarmup_r_ IADLarmup_s_ InsurancePubMed_r_ InsurancePubMed_s_ InsuranceComMed_r_ InsuranceComMed_s_ InsuranceOthMed_r_ InsuranceOthMed_s_ Income_r_ Income_s_ activities_r_ activities_s_ ADLCare_r_ ADLCare_s_ ADLinformalCare_r_ ADLinformalCare_s_ ADLcaregiverSpouse_r_ ADLcaregiverSpouse_s_ ADLcaregiverSpouseDays_r_ ADLcaregiverSpouseDays_s_ ADLcaregiverSpouseHours_r_ ADLcaregiverSpouseHours_s_ ADLcaregiverChild_r_ ADLcaregiverChild_s_ ADLcaregiverChildNum_r_ ADLcaregiverChildNum_s_ ADLcaregiverChildDays_r_ ADLcaregiverChildDays_s_ ADLcaregiverChildHours_r_ ADLcaregiverChildHours_s_ ADLcaregiverRelative_r_ ADLcaregiverRelative_s_ ADLcaregiverRelativeNum_r_ ADLcaregiverRelativeNum_s_ ADLcaregiverRelativeDays_r_ ADLcaregiverRelativeDays_s_ ADLcaregiverRelativeHours_r_ ADLcaregiverRelativeHours_s_ ADLcaregiverNonRela_r_ ADLcaregiverNonRela_s_ ADLformalCare_r_ ADLformalCare_s_ interviewdate_r_ interviewdate_s_ marital_r_ marital_s_ residence_r_ residence_s_ coresidence_r_ coresidence_s_ srh_r_ srh_s_ HexpOOPOP_r_ HexpOP_r_ HexpOOPOP_s_ HexpOP_s_ HexpOOPIP_r_ HexpIP_r_ HexpOOPIP_s_ HexpIP_s_ ADLsum_r_ adlbi_r_ ADLsum_s_ adlbi_s_ IADLsum_r_ iadlbi_r_ IADLsum_s_ iadlbi_s_  ,i(ID) j(wave)
	
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
	
save "${int}/charls_harmS.dta",replace


use "${raw}/2020/Demographic_Background.dta",clear
	ren ba009 hukou
	ren ba008 residence_
	ren ba011 marital_
	ren ba015 insurance_
	keep ID hukou residence_  marital_ insurance_
	
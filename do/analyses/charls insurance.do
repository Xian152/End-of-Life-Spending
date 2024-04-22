** 其他数据
use "${raw}/2011/health_care_and_insurance.dta",clear
	keep ea001s9 ea001s8 ea001s7 ea001s6 ea001s5 ea001s4 ea001s3 ea001s2 ea001s10 ea001s1 ID
	gen wave=2011
		
	gen insurancePubMed = 4 if 	ea001s5 == 5 | ea001s6==6  |ea001s9 == 9

	replace insurancePubMed = 1 if ea001s1 == 1
	replace insurancePubMed = 2 if 	ea001s2==2
	replace insurancePubMed = 3 if 	ea001s3==3
	replace insurancePubMed = 5 if 	ea001s4== 4
	replace insurancePubMed = 0 if  ea001s10==10
	keep wave ID insurancePubMed
	tempfile t1
save `t1'	
use "${raw}/2013/health_care_and_insurance.dta",clear
	keep ea001s9 ea001s8 ea001s7 ea001s6 ea001s5 ea001s4 ea001s3 ea001s2 ea001s10 ea001s1 ID
	gen wave=2013
		
	gen insurancePubMed = 4 if 	ea001s5 == 5 | ea001s6==6  |ea001s9 == 9

	replace insurancePubMed = 1 if ea001s1 == 1
	replace insurancePubMed = 2 if 	ea001s2==2
	replace insurancePubMed = 3 if 	ea001s3==3
	replace insurancePubMed = 5 if 	ea001s4== 4
	replace insurancePubMed = 0 if  ea001s10==10
	keep wave ID insurancePubMed
	tempfile t2
save `t2'	
		
use "${raw}/2015/health_care_and_insurance.dta",clear
	keep ef005_1_s9 ef005_1_s8 ef005_1_s7 ef005_1_s6 ef005_1_s5 ef005_1_s4 ef005_1_s3 ef005_1_s2 ef005_1_s13 ef005_1_s12 ef005_1_s11 ef005_1_s10 ef005_1_s1 ID ea001_w3_1_9_ ea001_w3_1_8_ ea001_w3_1_7_ ea001_w3_1_6_ ea001_w3_1_5_ ea001_w3_1_4_ ea001_w3_1_3_ ea001_w3_1_2_ ea001_w3_1_1_ ea001_w3_1_10_
	gen wave=2015
		
	gen insurancePubMed = 4 if 	ef005_1_s5 == 5 | ef005_1_s6==6  |ef005_1_s10 == 10 |ef005_1_s9==9
	replace insurancePubMed = 4 if 	ea001_w3_1_5_== 1 | ea001_w3_1_6_==1  |ea001_w3_1_10_== 1 |ea001_w3_1_9_==1
	replace insurancePubMed = 1 if ef005_1_s1 == 1
	replace insurancePubMed = 2 if 	ef005_1_s2==2
	replace insurancePubMed = 3 if 	ef005_1_s3==3
	replace insurancePubMed = 5 if 	ef005_1_s4== 4
	replace insurancePubMed = 0 if  ef005_1_s12==12
	
	replace insurancePubMed = 1 if ea001_w3_1_1_== 1
	replace insurancePubMed = 2 if 	ea001_w3_1_2_== 1
	replace insurancePubMed = 3 if 	ea001_w3_1_3_==1
	replace insurancePubMed = 5 if 	ea001_w3_1_4_== 1
	
	keep wave ID insurancePubMed

	tempfile t3
save `t3'	
				
		
use "${raw}/CHARLS2018r/health_care_and_insurance.dta",clear
	keep ea001_w4_s9 ea001_w4_s8 ea001_w4_s7 ea001_w4_s5 ea001_w4_s4 ea001_w4_s3 ea001_w4_s2 ea001_w4_s12 ea001_w4_s11 ea001_w4_s10 ea001_w4_s1 ID
	gen wave=2018
		
	gen insurancePubMed = 4 if 	ea001_w4_s5 == 5  |ea001_w4_s9 == 9|ea001_w4_s11 == 11

	replace insurancePubMed = 1 if ea001_w4_s1 == 1
	replace insurancePubMed = 2 if 	ea001_w4_s3==3
	replace insurancePubMed = 3 if 	ea001_w4_s4==4
	replace insurancePubMed = 5 if 	ea001_w4_s2== 2
	replace insurancePubMed = 0 if  ea001_w4_s12==12
	
	keep wave ID insurancePubMed
	
	append using `t1' `t2' `t3'
	label define insurancePubMed  1"城职工" 2"城居保" 3"新农合" 4"其他公费医疗" 5"城职/居保（2018限定）" 0"无公共医保" 
	label values insurancePubMed insurancePubMed
	
save "/Users/x152/Desktop/charls_insurance.dta",replace	
	
	
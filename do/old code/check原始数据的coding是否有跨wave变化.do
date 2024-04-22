** 每次跑一个新变量都可以考虑从头跑别担心

* Define path for general output data: 
global OUT "/Users/x152/Library/CloudStorage/Box-Box/HALSA-Healthy Aging - CLHLS/P24 End-of-life care expenditure patterns and causes of death/Data Analyses/raw"        	//记得改路径

cls
foreach year in 98  00 02 05 08 11 14{ //
use "${OUT}/dat`year'_18F.dta",clear
* first wave
qui gen a = .
qui replace a = 0 if `year' == 98
qui replace a = 2 if `year' == 00
qui replace a = 5 if `year' == 02
qui replace a = 8 if `year' == 05
qui replace a = 11 if `year' == 08
qui replace a = 14 if `year' == 11
qui replace a = 18 if `year' == 14

qui local i1 = a
* second wave
qui gen b = .
qui replace b = 2 if `year' == 98
qui replace b = 5 if `year' == 00
qui replace b = 8 if `year' == 02
qui replace b = 11 if `year' == 05
qui replace b = 14 if `year' == 08
qui replace b = 18 if `year' == 11

qui local i2 = b

* Third wave
qui gen c = .
qui replace c = 5 if `year' == 98
qui replace c = 8 if `year' == 00
qui replace c = 11 if `year' == 02
qui replace c = 14 if `year' == 05
qui replace c = 18 if `year' == 08

qui local i3 = c
* Forth wave
qui gen d = .
qui replace d = 8 if `year' == 98
qui replace d = 11 if `year' == 00
qui replace d = 14 if `year' == 02
qui replace d = 18 if `year' == 05

qui local i4 = d
* Fifth wave
qui gen e = .
qui replace e = 11 if `year' == 98
qui replace e = 14 if `year' == 00
qui replace e = 18 if `year' == 02

qui local i5 = e
* Sixth wave
qui gen f = .
qui replace f = 14 if `year' == 98
qui replace f = 18 if `year' == 00

qui local i6 = f
* Seventh wave
qui gen g = .
qui replace g = 18 if `year' == 98

qui local i7 = g

*setup for loop
qui gen wave_alt =7 if wave ==98
qui replace wave_alt =6 if wave ==0
qui replace wave_alt =5 if wave ==2
qui replace wave_alt =4 if wave ==5
qui replace wave_alt =3 if wave ==8
qui replace wave_alt =2 if wave ==11
qui replace wave_alt =1 if wave ==14
		
qui gen report = ""		
********************** deal with string in d14 ******************
	if inlist(wave_alt,2,3,4,5,6,7){
			foreach var in d14income d14wpayot d14fullda d14medcos d14pcgday d14bedday d14drkmch d14pocket d14carcst{
				qui replace `var' = "" if !regexm(`var',"^[0-9]*$")		
			}
		qui destring d14*,replace
	}	
	
********************** 你真正需要改的部分 ******************
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			foreach variable in cause    {    //这里一个变量一改在这个in后面加你要检查的变量的关键词： e.g d18pocket,那么pocket是关键词
				qui replace  report = "`year'" + "---" + "`am'"
				tab report
				capture confirm variable d`i`z''`variable'
				if !_rc {
					codebook d`i`z''`variable' if d`i`z''`variable' >=0    &   d`i`z''`variable' <=  6
				}	
			}
		}		
	}	
	
	
	
	
	
	
	
	
}	
xx

*如果出现了多于6个的情况，就逐步替换范围
	if inlist(wave_alt,1,2,3,4,5,6,7){
		local am = wave_alt
		forvalues z = 1/`am'{
			foreach variable in  pocket    {    //这里一个变量一改在这个in后面加你要检查的变量的关键词： e.g d18pocket,那么pocket是关键词
				qui replace  report = "`year'" + "---" + "`am'"
				tab report
				capture confirm variable d`i`z''`variable'
				if !_rc {
					codebook d`i`z''`variable' if d`i`z''`variable' >=5    //如果出现了多于6个的情况，，就逐步替换范围
				}	

		}		
	}	


/* 比如这种结果就是一看就知道在6个class以内

     report |      Freq.     Percent        Cum.
------------+-----------------------------------
     14---1 |      7,192      100.00      100.00 		// 发现问题就把前面这个信息也记录在内
------------+-----------------------------------
      Total |      7,192      100.00



--------------------------------------------------------------------------------------------------------------------------------
d5marry                                                                            marital status of the deceased elder at death
--------------------------------------------------------------------------------------------------------------------------------

                  Type: Numeric (byte)
                 Label: labels1334

                 Range: [1,9]                         Units: 1
         Unique values: 6                         Missing .: 0/5,874

            Tabulation: Freq.   Numeric  Label
                          715         1  married  living with the spouse
                           64         2  married but not living with the
                                         spouse
                           22         3  divorce
                        4,984         4  widowed
                           49         5  never married
                           40         9  missing
*/

/* 出现这种情况就小心检查，可能不只6个class但是它只能呈现6个
--------------------------------------------------------------------------------------------------------------------------------
d5marry                                                                            marital status of the deceased elder at death
--------------------------------------------------------------------------------------------------------------------------------

                  Type: Numeric (byte)
                 Label: labels1334

                 Range: [1,9]                         Units: 1
         Unique values: 6                         Missing .: 0/5,874

            Tabulation: Freq.   Numeric  Label
                          715         1  married  living with the spouse
                           64         2  married but not living with the
                                         spouse
                           22         3  divorce
                        4,984         4  widowed
                           49         5  never married
						   78		  6  
*/

/*


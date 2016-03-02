1034  ds9 -scale mode zscale NL_OBJ_A16N.fits NL_OBJ_A01N.fits &
 1035  q_list_stat NL_OBJ_A16N.fits 1 87:88 - - | awk '{print $3,$5}' > A16_TEST.TXT
 1036  q_list_stat NL_OBJ_A01N.fits 1 87:88 - - | awk '{print $3,$5}' > A01_TEST.TXT
 1037  gnuplot
 1038  nano A16_TEST.TXT 
 1039  q_list_stat NL_OBJ_A01N.fits 87:88 - - | awk '{print $3,$5}' > A01_TEST.TXT
 1040  nano A01_TEST.TXT 
 1041  q_list_stat NL_OBJ_A01N.fits 1 87:88 - | awk '{print $3,$5}' > A01_TEST.TXT
 1042  nano A01_TEST.TXT 
 1043  q_chgaxis
 1044  q_chgaxis 4 NL_OBJ_A01N.fits A01N_chgaxis.fits
 1045  q_list_stat A01N_chgaxis.fits 1 87:88 - - | awk '{print $3,$5}' > A01_TEST.TXT
 1046  nano A01_TEST.TXT 
 1047  ds9 A01N_chgaxis.fits &
 1048  q_list_stat A01N_chgaxis.fits 1 87:88 1-240 1 | awk '{print $3,$5}' > A01_TEST.TXT
 1049  nano A01_TEST.TXT 
 1050  q_list_stat NL_OBJ_A01N.fits 1 87:88 1-240 1 | awk '{print $3,$5}' > A01_TEST.TXT
 1051  nano A01_TEST.TXT 
 1052  q_list_stat NL_OBJ_A16N.fits 1 87:88 1-240 1 | awk '{print $3,$5}' > A16_TEST.TXT
 1053  gnuplot
 1054  q_list_stat NL_OBJ_A08N.fits 1 87:88 1-240 1 | awk '{print $3,$5}' > A08_TEST.TXT
 1055  gnuplot
 1056  q_fcombine NL_OBJ_A01N.fits NL_OBJ_A02N.fits NL_OBJ_A03N.fits NL_OBJ_A04N.fits NL_OBJ_A05N.fits NL_OBJ_A06N.fits NL_OBJ_A07N.fits NL_OBJ_A08N.fits NL_OBJ_A09N.fits NL_OBJ_A10N.fits NL_OBJ_A11N.fits NL_OBJ_A12N.fits NL_OBJ_A13N.fits NL_OBJ_A14N.fits NL_OBJ_A15N.fits NL_OBJ_A16N.fits ave=NL_SLIT1.fits
 1057  ds9 NL_SLIT1.fits &
 1058  q_list_stat NL_OBJ_B16N.fits 1 87:88 1-240 1 | awk '{print $3,$5}' > B16_TEST.TXT
 1059  q_list_stat NL_OBJ_B01N.fits 1 87:88 1-240 1 | awk '{print $3,$5}' > B01_TEST.TXT
 1060  gnuplot
 1061  q_fcombine NL_OBJ_B01N.fits NL_OBJ_B02N.fits NL_OBJ_B03N.fits NL_OBJ_B04N.fits NL_OBJ_B05N.fits NL_OBJ_B06N.fits NL_OBJ_B08N.fits NL_OBJ_B09N.fits NL_OBJ_B10N.fits NL_OBJ_B11N.fits NL_OBJ_B12N.fits NL_OBJ_B13N.fits NL_OBJ_B14N.fits NL_OBJ_B15N.fits NL_OBJ_B16N.fits ave=NL_SLIT2.fits
 1062  ds9 -scale mode zscale NL_SLIT2.fits &
 1063  ds9 -scale mode zscale NL_STD_A01N.fits &
 1064  ds9 -scale mode zscale NL_STD_A01N.fits NL_SLIT1.fits NL_SLIT2.fits &
 1065  q_list_stat NL_SLIT1.fits 1 1-320 186-190 1 TEST1.fits
 1066  q_list_stat NL_SLIT1.fits 1 1-320 191-195 1 TEST2.fits
 1067  q_list_stat NL_SLIT1.fits 1 1-320 196-200 1 TEST3.fits
 1068  q_list_stat NL_SLIT1.fits 1 1-320 201-205 1 TEST4.fits
 1069  q_list_stat NL_SLIT1.fits 1 1-320 206-210 1 TEST5.fits
 1070  q_list_stat NL_SLIT1.fits 1 1-320 211-215 1 TEST6.fits
 1071  q_list_stat NL_SLIT1.fits 1 1-320 216-220 1 TEST7.fits
 1072  q_list_stat NL_SLIT1.fits 1 1-320 221-225 1 TEST8.fits
 1073  q_list_stat NL_SLIT1.fits 1 1-320 226-230 1 TEST9.fits
 1074  q_fcombine TEST1.fits TEST2.fits TEST3.fits TEST4.fits TEST5.fits TEST6.fits TEST7.fits TEST8.fits TEST9.fits med=TEST_MED.fits
 1075  ds9 TEST_MED.fits &
 1076  q_list_stat TEST_MED.fits 1 1-320 1:5 1 | awk'{print $2,$5}' > SKY_RES.TXT
 1077  q_list_stat TEST_MED.fits 1 1-320 1:5 1 | awk '{print $2,$5}' > SKY_RES.TXT
 1078  nano SKY_RES.TXT 
 1079  gnuplot
 1080  nano SKY_RES.f
 1081  g77 -o test SKY_RES.f
 1082  ./test
 1083  ls SKY*
 1084  q_mkimg SKY_RES_MAP.TXT SKY_RES_MAP.fits 320 240
 1085  ds9 SKY_RES_MAP.fits &
 1086  q_arith NL_SLIT1.fits - SKY_RES_MAP.fits NL_SLIT1_skysub.fits
 1087  ds9 NL_SLIT1_skysub.fits &
 1088  q_list_stat NL_SLIT1_skysub.fits 1 1-320 1-240 1 | awk '{print $2,$3,$5}' > NL_SLIT1_skysub.TXT

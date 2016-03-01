plot "A01.DAT" u 1:($2-1700) w l, "A02.DAT" u 1:($2*0.8) w l , "A01.DAT" u ($1-116):(($2-1750)*(-1.16)) w l
set term postscript
set output "posA_test.ps"
replot
set term x11

plot "B01.DAT" u 1:($2-1700) w l, "B02.DAT" u 1:($2*0.8) w l , "B01.DAT" u ($1-116):(($2-1750)*(-1.16)) w l
set term postscript
set output "posB_test.ps"
replot
set term x11
#ps2pdf posA_test.ps posA_test.pdf
#ps2pdf posB_test.ps posB_test.pdf

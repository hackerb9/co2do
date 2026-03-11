200 GOTO 40000
1000 rem
2000 a$=inkey$
2100 m=0:n=0
2200 if a$="a" or a$="A" then if di<> 1 then di=3
2300 if a$="z" or a$="Z" then if di<> 3 then di=1
2400 if a$="k" or a$="K" then if di<> 0 then di=2
2500 if a$="l" or a$="L" then if di<> 2 then di=0
2600 if a$=" " then ln=ln+1:ic=ln:gosub 30000
3000 x1=x+m(di):y1=y+n(di)
4000 if x1<10 or x1>=xx then x1=x:dd=1
4100 if y1<0 or y1>=yy then y1=y:dd=1
4200 z=x1+y1*xx
4500 if z%(z)=10 then dd=1
5000 if ln=0 then 6000
5100 pt=pt+1
5200 if pt>=ln then pt=0
5250 u=u%(pt)
5300 print @u," ";:z%(u)=0
5400 u=x+y*xx
5500 print @u,ld$(pd*4+di);:z%(u)=1
5600 u%(pt)=u
5900 goto 7000
6000 print @x+y*xx," ";:z%(x+y*xx)=0
7000 if z%(z)=20 then ln=ln+1:ic=int(ln*(6-tt)/5):gosub 30000:tt=tt-1
7100 'print @280,z%(z);
7200 if z%(z) and z%(z)<5 then dd=1
7500 print @z,"";:z%(z)=2
7600 x=x1:y=y1
7700 pd=di
8000 if tt>=5 then 8900
8050 ty=ty+1
8100 if ty<30 then 8900
8200 ty=0
8300 a1=int(rnd(1)*28)+11
8400 a2=int(rnd(1)*6)+1
8500 a3=a1+a2*xx
8600 if z%(a3) then 8300
8700 print @a3,"$";
8750 tt=tt+1
8800 z%(a3)=20
8900 if dd then 20000
9000 goto 2000
20000 if ln=0 then 21000
20100 for i=0 to ln
20200 if u%(i) then print @u%(i),"X";
20300 next
21000 for i=0 to 1000:next
21100 cls:?
22000 print"Game over"
22200 print
22400 print"Score:"sc
23000 gosub 50000
24000 line input "Press [Enter]:";a$
28000 run
30000 sc=sc+ic
31000 print @ 40,"Score:"
31100 print @ 82,sc
31500 print @120,"Length:"
31600 print @162,ln
34900 return
40000 clear1000:MAXFILES=1
40100 xx=40:yy=8:dim ld$(15)
40200 dim z%(xx*yy),u%(xx*yy)
40300 m(0)=1:n(1)=1:m(2)=-1:n(3)=-1
40400 sh$="snhis"
40500 a=rnd(-(val(time$)*3600+val(mid$(time$,4))*60+val(right$(time$,2))))
40600 for i=0 to 15
40700 read ld$(i)
40800 next i
41000 CLS
41100 PRINT "Snake:  for TRS-80 Model 100"
41200 PRINT "Written by Kurt W. Dekker on 06/25/91"
41300 PRINT "Enter your name to start:"
41400 LINE INPUT NM$
41450 if len(nm$)=0 then lm$="Anonymous"
41500 nm$=left$(nm$,20)
41600 if len(nm$)<20 then nm$=nm$+" ":goto 41600
42000 sc=0:tt=0
42100 ln=0
42200 x=15
42300 y=4:di=0
42400 'for i=0 to xx*yy:u%(i)=0:z%(i)=0:next i
42500 pt=0
42600 dd=0
43000 cls
43100 for i=0 to 7
43200 print @i*40+9,"|";
43300 next
43500 ic=0:gosub 30000
44900 goto 1000
45000 data "ñ","ò","%","÷", "ö","õ","÷","%", "%","ð","ñ","ö", "ð","%","ò","õ"
50000 'if sl=0 then gosub 55000
50100 if sc<=100 then 52000
50150 print
50160 print"Your score qualifies for the high score	list!"
50200 open sh$ for append as 1
50300 print #1,using"#####";sc;:?#1,",";
50400 print #1,using"###";ln;:?#1,",";
50500 print #1,nm$;date$
51000 close 1
52000 return
55000 open sh$ for append as 1:close 1
55100 open sh$ for input as 1
55200 if eof(1) then 56000
55300 input #1,i1,i2
55400 line input #1,i1$
55500 goto 55200
56000 sl=1
56100 close 1
57000 return

'*************************************************************************
'
' Author:       Kurt W. Dekker
' Started:      11/10/99 @ 10:30
' Updated:      11/10/99
' Filename:     ANGBAN.BAS
'
' Description:  Tiny Angband for the Model 100 - god help us all
'
' Run this source through BAS100 to convert it to run on Vanessa2.
'
'*************************************************************************

	WIDTH 40

	a = RND(-(3600 * VAL(TIME$) + 60 * VAL(MID$(TIME$, 4)) + VAL(MID$(TIME$, 7))))

newgame:
	CLS

	CLEAR 2000

	xx = 20: yy = 8         ' dungeon dimensions

	DIM dn$(yy)             ' strings that hold the dungeon contents

	DIM ch$(40)
	ch$(0) = ":"            ' open space
	ch$(1) = "@"            ' you
	ch$(2) = CHR$(178)      ' solid wall
	ch$(3) = ">"            ' downstairs
	ch$(4) = "$"            ' money/treasure
	ch$(5) = "+"            ' door
	ch$(6) = ")"            ' shield

	' "22" is the magic start of monster char types...
	ch$(22) = "J"           ' snake
				 
	mm = 10
	DIM mt(mm)              ' monster type
	DIM mx(mm)              ' monster X
	DIM my(mm)              ' monster Y
	DIM ms(mm)              ' monster speed
	DIM mv(mm)              ' how far monster has moved (time to move yet?)

	au = 0
	ac = 1
	cl = 1

	dl = 1  ' dungeon level
	dm = 0  ' dungeon max level
      

newlevel:
	GOSUB createlevel

	GOSUB drawworld

	IF dl > dm THEN dm = dl: m$ = "Depth:" + MID$(STR$(50 * dl), 2) + " ft": GOSUB printmessage

mainloop:
	GOSUB handleyou
	GOSUB showstats
	IF nl THEN GOTO newlevel
	GOSUB handlemonsters
       
	GOTO mainloop

handleyou:
youinputloop:
	a$ = INPUT$(1)
       
	'm$ = "": GOSUB printmessage

	'IF a$ > "A" AND a$ < "Z" THEN a$ = CHR$(ASC(a$) + 32)

	xm = 0: ym = 0

	IF a$ = "i" THEN ym = -1: GOTO moveyou
	IF a$ = "j" THEN xm = -1: GOTO moveyou
	IF a$ = "l" THEN xm = 1: GOTO moveyou
	IF a$ = "k" THEN ym = 1: GOTO moveyou

	IF a$ = "Q" THEN END

	IF a$ <> "q" THEN GOTO noquit
	CLS
	PRINT : PRINT : PRINT "Quit?(Y/N)";
	a$ = INPUT$(1)
	IF a$ = "y" THEN END

	GOSUB drawworld

	GOTO youinputloop

noquit:

invalidmove:
	m$ = "**INVALID**": GOSUB printmessage

	GOTO youinputloop

moveyou:
	x1 = ux + xm
	y1 = uy + ym

	c$ = MID$(dn$(y1), x1, 1)

	IF c$ = ch$(0) THEN GOTO yourmoveisvalid

	' picking up gold?
	IF c$ = ch$(4) THEN GOSUB pickupgold: GOTO yourmoveisvalid

	' going down deeper into the dungeon
	IF c$ = ch$(3) THEN nl = 1: dl = dl + 1: RETURN

	' simply going into another room
	IF c$ = ch$(5) THEN nl = 1: RETURN

	x1 = ux: y1 = uy


	GOTO invalidmove

yourmoveisvalid:
	LOCATE uy, ux
	PRINT ch$(0); : MID$(dn$(uy), ux) = ch$(0)

	LOCATE y1, x1
	PRINT ch$(1); : MID$(dn$(y1), x1) = ch$(1)

	ux = x1: uy = y1

	RETURN

pickupgold:
	a = INT(RND(1) * (dl) * 5) + 10
	m$ = "You find " + MID$(STR$(a), 2) + " gold!": GOSUB printmessage
	au = au + a
	RETURN

showstats:
	LOCATE 1, xx + 1
	PRINT "AU:$"; MID$(STR$(au), 2); " ";

	LOCATE 2, xx + 1
	PRINT "HP:"; MID$(STR$(ht), 2); "/"; MID$(STR$(hp), 2); " (LV:"; MID$(STR$(dl), 2); ") ";

	LOCATE 3, xx + 1
	PRINT "Depth:"; MID$(STR$(50 * dl), 2); " ft ";

	RETURN

handlemonsters:
	' first all the "alive" monsters get their movement points added
	FOR mi = 1 TO mm
		mv(mi) = mv(mi) + ms(mi)
	NEXT mi

	' all monsters that have more than 10 movement points accumulated
	' can move now, and will continue to move until all have fewer
	' than 10 movement points
keepmovingmonsters:
	FOR mi = 1 TO mm
		IF mv(mi) >= 10 THEN mv(mi) = mv(mi) - 10: GOSUB movemonsterMi
	NEXT mi

	RETURN

movemonsterMi:
	' <WIP> monsters just move randomly for now...

	xm = INT(RND(1) * 3) - 1
	ym = INT(RND(1) * 3) - 1
	x1 = mx(mi) + xm
	y1 = my(mi) + ym

	IF MID$(dn$(y1), x1, 1) = ch$(0) THEN GOTO monstermoveisvalid

	RETURN

monstermoveisvalid:
	LOCATE my(mi), mx(mi)
	PRINT ch$(0);
	LOCATE y1, x1
	PRINT ch$(22 + mt(mi));

	mx(mi) = x1: my(mi) = y1

	RETURN

createlevel:
	CLS
	PRINT "Generating level..."
	nl = 0

	GOSUB clearmessages

	FOR y = 1 TO yy
		dn$(y) = STRING$(xx, "X")

		FOR x = 1 TO xx

			c$ = ch$(0)
			IF y = 1 OR x = 1 OR y = yy OR x = xx THEN c$ = ch$(2)

			MID$(dn$(y), x) = c$
		NEXT x
	NEXT y

	feature = INT(RND(1) * 5) + 1
	ON feature GOSUB featurerandblocks, featurelotsamoney

	GOSUB placeyou
	GOSUB placedownstairs
	GOSUB placemonsters

	RETURN

placeyou:
	ux = INT(RND(1) * xx) + 1
	uy = INT(RND(1) * yy) + 1
	IF MID$(dn$(uy), ux, 1) <> ch$(0) THEN GOTO placeyou
	MID$(dn$(uy), ux) = ch$(1)
	RETURN

placedownstairs:
	x0 = INT(RND(1) * xx) + 1
	y0 = INT(RND(1) * yy) + 1
	IF MID$(dn$(y0), x0, 1) <> ch$(0) THEN GOTO placedownstairs
	MID$(dn$(y0), x0) = ch$(3)
	RETURN

placemonsters:
	nm = 1 + INT(RND(1) * dl * 2)
	IF nm > mm THEN nm = mm
	FOR mi = 1 TO nm
choosenewmonsterpos:
		x0 = INT(RND(1) * xx) + 1
		y0 = INT(RND(1) * yy) + 1
		IF MID$(dn$(y0), x0, 1) <> ch$(0) THEN GOTO choosenewmonsterpos
		mt(mi) = 0
		mx(mi) = x0
		my(mi) = y0
		ms(mi) = 10             ' speed
		mv(mi) = 0

		' slam the monster to the dungeon array
		MID$(dn$(my(mi)), mx(mi)) = ch$(22 + mt(mi))
	NEXT mi

	RETURN

featurerandblocks:
	j = INT(RND(1) * 10) + 2
	FOR i = 1 TO j
repickrandblocks:
		x = INT(RND(1) * (xx - 2)) + 2
		y = INT(RND(1) * (yy - 2)) + 2
		IF MID$(dn$(y), x, 1) <> ch$(0) THEN GOTO repickrandblocks
		IF MID$(dn$(y - 1), x, 1) <> ch$(0) THEN GOTO repickrandblocks
		IF MID$(dn$(y + 1), x, 1) <> ch$(0) THEN GOTO repickrandblocks
		IF MID$(dn$(y), x - 1, 1) <> ch$(0) THEN GOTO repickrandblocks
		IF MID$(dn$(y), x + 1, 1) <> ch$(0) THEN GOTO repickrandblocks
		MID$(dn$(y), x) = ch$(2)
	NEXT i
	RETURN

featurelotsamoney:
	j = INT(RND(1) * 5) + 4
	FOR i = 1 TO j
repickmoney:
		x = INT(RND(1) * (xx - 2)) + 2
		y = INT(RND(1) * (yy - 2)) + 2
		IF MID$(dn$(y), x, 1) <> ch$(0) THEN GOTO repickmoney
		MID$(dn$(y), x) = ch$(4)
	NEXT i
	RETURN

drawallmonsters:
	FOR i = 1 TO mm
		IF mt(i) = 0 THEN GOTO nextmonster
		LOCATE my(i), mx(i)
		PRINT ms$(i);
nextmonster:
	NEXT i

	RETURN

drawworld:
	CLS
	FOR i = 1 TO yy
		LOCATE i, 1
		PRINT dn$(i);
	NEXT i

	GOSUB drawallmonsters

	GOSUB showstats

	RETURN

printmessage:
	m1$ = m0$
	m0$ = m$

	LOCATE yy - 1, xx + 1
	PRINT m1$;
	IF m1 > LEN(m1$) THEN PRINT STRING$(m1 - LEN(m1$), "_");
	m1 = LEN(m1$)

	LOCATE yy - 0, xx + 1
	PRINT m0$;
	IF m0 > LEN(m0$) THEN PRINT STRING$(m0 - LEN(m0$), "_");
	m0 = LEN(m0$)
	 
	RETURN
clearmessages:
	m0$ = ""
	m1$ = ""
	m$ = ""
	GOSUB printmessage
	RETURN

	END


	DATA "W","Dagger","1d6"
	DATA "W","Shortsword","2d4"
	DATA "W","Broadsword","2d6"
	DATA "W","WarHammer","3d4"

	DATA "X"

	DATA "M","k","small kobold",10,10,"1d10"
	DATA "M","K","large kobold",20,20,"2d8"

	DATA "X"



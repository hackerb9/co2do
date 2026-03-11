/*
;
;  Copyright (C) 2004, Kurt W Dekker, PLBM Games, kwd@plbm.com, www.plbm.com
;
;  This program is free software; you can redistribute it and/or modify
;  it under the terms of the GNU General Public License as published by
;  the Free Software Foundation; either version 2 of the License, or
;  (at your option) any later version.
;
;  This program is distributed in the hope that it will be useful,
;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;  GNU General Public License for more details.
;
;  You should have received a copy of the GNU General Public License
;  along with this program; if not, write to the Free Software
;  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
;
*/

/* I compiled this with Borland C++ V3.0 */

/****************************************************************************/
/*
 * Author:		Kurt W. Dekker
 * Started: 	07/22/90
 * Updated: 	04/06/92
 *				11/18/94
 *				08/26/98
 * Filename:	A85.C
 *
 *
 * Description: Cross-assembler for TRS-80 Model 100 (8085 CPU)
 *
 * Quick and dirty!!!  As many variables as possible are local!!!
 *
 * Options supported:
 *
 *	-B	: specify non-standard .DEC file blocksize (default = 15)
 *	-L	: specify listout file (defaults to *.X_LST)
 *	-O	: specify origin value (overrides statement in program)
 *	-X	: specify cross reference and listing options (see below)
 *				1 - generate symbol table?
 *				2 - generate expanded program listing?
 *				4 - generate cross reference?
 *	-W	: warnings are fatal (stops assembly)
 *	-Z	: cross-assemble to IBM PC assembly language.
 *				1 - include original source code (commented)
 *
 * Macros supported:
 *
 *		ldir			call 27611; 	(very model 100 ROM oriented!)
 *		lddr			call 27622;
 *
 * Macros to support later on:
 *
 *		djnz			dec b; jp nz,label;
 *		getch			call 29250;
 *		strout			call 10161;
 *		cout			rst 32;
 *		cmp hl,de		rst 24;
 *
 * Files tested out okay with: (byte-for-byte perfect)
 *
 *		TA.ASM			- tests all possible opcodes and addressing modes
 *		MISILE.ASM
 *		SPIN.ASM
 *		ASMASM.ASM
 *
 * Version 1.0 notes: (fully functional on 08/28/90)
 *
 * Multiple files at link stage are NOT supported.
 *
 * Error:  if ';' was in quotes as an operand (m_data), it would be processed
 *		   as a comma.	Must protect both quotes and single quotes...
 *
 * Version 2.0 notes: (started 12/04/90)
 *
 * Version two will ultimately support cross-translation, 8085 assembly
 * to 8086 assembly.  (NOTE! THIS WAS NOT COMPLETED! - Kurt Dekker)
 *
 * Register cross-mapping is as follows:
 *
 *		HL - BX
 *		BC - CX
 *		DE - DX
 *		AF - AX
 *
 * 04/06/92:	Need to support digestion of HEXADECIMAL numbers!
 */


/*#define VERSION "v2.1, 04/06/92"*/
#define VERSION "v2.1a, 04/06/98"
#define INFORMATION "Copyright (C) 1990-1998, Kurt W. Dekker"

#include "a85.h"


/****************************************************************** PROGRAM */
/* Name:		main( argc, argv);
 * Started: 	07/22/90
 * Updated: 	12/04/90
 * Arguments:	argc, argv:  standard C command line arguments
 *
 * Purpose: 	It's the main() function for the A85 cross assembler!!
 */

main( argc, argv)
  int  argc;
  char *argv[];
{
  char	*cptr;
  int	i, arg1, count, fna;					/* for processing command line */

  fprintf( stderr, "\n\nA85 %s\n%s\n", VERSION, INFORMATION);

  init();

/* perform a scan of the command line options/arguments */
  fna = 0; arg1 = argc; count = 1;
  while (--arg1) {
	if ( *argv[ count] != '-' && *argv[ count] != '/') {
	  if (fna == 0) fna = count;
	  else crash(2);					/* duplicate filename args */
	}
	if ( *argv[ count] == '-' || *argv[ count] == '/') {
	  fprintf( stderr, "\nA85:  ");
	  switch( toupper( *(argv[count]+1) ) ) {
		case 'B' :
		  dec_block_size = atoi( argv[count]+2);
		  if (dec_block_size < 3) crash(6); 													/* blocksize too small */
		  fprintf( stderr, "selecting dec_block_size = %d bytes per line", dec_block_size);
		  break;
		case 'L' :
		  strcpy( fn_l, argv[ count] + 2);
		  if ( strchr( fn_l, '.') == NULL) strcat( fn_l, "." X_LST);
		  fprintf( stderr, "selecting '%s' for list file", fn_l);
		  list_file_specified = TRUE;
		  break;
		case 'O' :
		  orig_override = atoi( argv[count]+2);
		  fprintf( stderr, "selecting origin = %u (%4xh)", orig_override, orig_override);
		  break;
		case 'X' :
		  generate_listing = atoi(argv[count]+2);
		  fprintf( stderr, "list file options (*." X_LST "):");
		  if( generate_listing & 1) fprintf( stderr, "\n\t- symbol table");
		  if( generate_listing & 2) fprintf( stderr, "\n\t- program listing");
		  if( generate_listing & 4) fprintf( stderr, "\n\t- cross-reference table");
		  if( generate_listing ==0) fprintf( stderr, "\n\t- none selected");
		  break;
		case 'W' :
		  warning_fatal = TRUE;
		  fprintf( stderr, "selecting warnings as fatal");
		  break;
		case 'Z' :
		  translate = TRUE;
		  translate_flags = atoi( argv[ count] + 2);
		  fprintf( stderr, "selecting 8085->8086 cross-assembly");
		  if (translate_flags & 1) fprintf( stderr, "\n\t- include original source (commented)");
		  break;
		case '?' :
		  printf( "Available switches (help):\n\n");
		  printf( ":\t -B       : specify non-standard .DEC file blocksize (default = 15)\n");
		  printf( ":\t -L       : specify listout file (defaults to *.X_LST)\n");
		  printf( ":\t -O       : specify origin value (overrides statement in program)\n");
		  printf( ":\t -X       : specify cross reference and listing options (see below)\n");
		  printf( ":\t             1 - generate symbol table?\n");
		  printf( ":\t             2 - generate expanded program listing?\n");
		  printf( ":\t             4 - generate cross reference?\n");
		  printf( ":\t -W       : warnings are fatal (stops assembly)\n");
		  printf( ":\t -Z  : cross-assemble to IBM PC assembly language.\n");
		  printf( ":\t             1 - include original source code (commented)\n");
		  exit(9);
		  break;
		default :
		  fprintf( stderr, "option '%s' ignored (unknown)", argv[count]);
		  break;
	  }
	}
	count++;
  }

  if (fna == 0) {
	fprintf( stderr, "\n\nEnter source filename:  ");
	*fn_i = NULL; gets( fn_i);
	if ( strlen( fn_i) == 0)
	  crash(1);
  } else
	strcpy( fn_i, argv[ fna]);

  if ( strchr( fn_i, '.') == NULL) strcat( fn_i, "." X_ASM);
  if ( (fp_i = fopen( fn_i, "r")) == NULL) crash(3);			/* quick test open */
  fclose_1( fp_i);

  if (!list_file_specified) {									/* figure listing filename */
	strcpy( fn_l, fn_i);
	cptr = (char *) strchr( fn_l, '.');
	cptr++;
	strcpy( cptr, X_LST);
  }

  if (translate) {								/* figure the translator output (*.INC) file */
	strcpy( fn_z, fn_i);
	cptr = (char *) strchr( fn_z, '.');
	cptr++;
	strcpy( cptr, X_INC);
  }

  strcpy( fn_o, fn_i);											/* figure object filename */
  cptr = (char *) strchr( fn_o, '.');
  cptr++;
  strcpy( cptr, X_OBJ);

  strcpy( fn_x, fn_i);											/* figure executable filename */
  cptr = (char *) strchr( fn_x, '.');
  cptr++;
  strcpy( cptr, X_DEC);

  passno = 1;
  assemble();

  fprintf( stderr, "\nSymbols defined:  %u/%u", label_max+1, MAXLBL);

  passno = 2;
  assemble();

  fprintf( stderr, "\n\nAny additional files for linking?");
  /* put input here */

  passno = 1;
  link();

  passno = 2;
  link();

  crash(0); 	/* normal termination of program */

  return 0;
}







/***************************************************************** ASSEMBLE */
/* Name:		assemble();
 * Started: 	07/23/90
 * Updated: 	12/08/90
 * Arguments:	None.
 *
 * Purpose: 	Assembles one pass (based on passno variable)
 */

void	assemble()
{
char	*c1, *c2;
uint	u, u1, multip;
symbol	*sp1;
int 	i;

  if (passno == 1) {
	getdate( &date_s); gettime( &time_s);
	sprintf( dbuf, "%02u/%02u/%02u", date_s.da_mon, 	date_s.da_day,	date_s.da_year % 100);
	sprintf( tbuf, "%02u:%02u:%02u", time_s.ti_hour,	time_s.ti_min,	time_s.ti_sec);
	strcpy( dtbuf, dbuf); strcat( dtbuf, " - "); strcat( dtbuf, tbuf);
  }

  fprintf( stderr, "\n\nPass #%d:", passno);
  lineno = 0;

  orig_specified = FALSE;
  address = 0;
  end_reached = FALSE;

/**** COMBINED PASS 1 & 2 INITIALIZATIONS ****/

  if (generate_listing) {						/* open listing file here (only if some kind of listing specified) */
	switch( passno) {
	  case	1 :
		if ( (fp_l = fopen( fn_l, "w")) == NULL)
		  crash(4); 							/* cannot open *.X_LST file */
		fprintf( fp_l, "\nAssembler %s, %s\n", VERSION, INFORMATION);
		fprintf( fp_l, "\nListing File for '%s'\n", fn_i);
		fprintf( fp_l, "\nDated:  %s\n", dtbuf);
		if (orig_override) {
		  fprintf( fp_l, "\n\nOrigin override specified:  %u (%x)", orig_override, orig_override);
		}
		break;
	  default :
	  case	2 :
		if ( (fp_l = fopen( fn_l, "a")) == NULL)
		  crash(4); 							/* cannot open *.X_LST file (for append) */
		break;
	}
	fprintf( fp_l, "\n\n****  Pass %d  ****\n", passno);
  }

  if ( (fp_i = fopen( fn_i, "r")) == NULL)
	crash(3);									/* can't find source file */

  if (passno == 1) {							/* PASS #1 INITIALIZATIONS */
	st_init();
  }

  if (passno == 2) {							/* PASS #2 INITIALIZATIONS */
	if ( (fp_o = fopen( fn_o, "w")) == NULL)
	  crash(5);
	write_obj( OT_10, 0, dtbuf);
	write_obj( OT_11, 0, fn_i);
  }

  transwrite = (passno == 2) && translate;
  if (transwrite) {
	if ( (fp_z = fopen( fn_z, "w")) == NULL)
	  crash(12);								/* cannot open *.X_INC file (for output) */
  }


/***************************************
 * MAIN PLACE WHERE WE ASSEMBLE 1 LINE *
 ***************************************/

  while (!feof( fp_i) && !end_reached) {
	read_1line();
	defs_request = FALSE;
	if (feof( fp_i))
	  break;

	if ( (passno == 2) && (generate_listing & 2) ) {
	  fprintf( fp_l, "\n%5u: ", lineno);
	}

	if (transwrite && (translate_flags & 1) ) {
	  strcpy( zzztemp, ";");
	  strcat( zzztemp, m_currline);
	  write_zzz( zzztemp);
	}

	if ( (passno == 2) && (generate_listing & 2) ) {
	  sprintf( buffer1, "%5u (%4xh)", address, address);
	}

	if (strcmpi( m_opcode, "org") == 0) {
	  if (orig_override) {
		if (orig_specified) crash(55);											/* only allows 1 org statement per program */
		orig_specified = TRUE;
		write_obj( OT_15, orig_override, NULL);
	  } else {
		clrbuffer1();													/* removes address listing */
		if (strlen(m_label)) crash(54); 								/* origin statement may not have a label */

		if (orig_specified) crash(55);									/* only allows 1 org statement per program */
		orig_specified = TRUE;
		origin = atoi( m_data); 										/* orig must be specified in decimal right now */
		address = 0;
		addr_top = address; addr_exe = address; 						/* not really functional at this time */
		write_obj( OT_15, origin, NULL);
	  } 				/* else */
	  write_obj( OT_16, NULL, NULL);									/* mark this as the execution point */
	  if (transwrite) {
		write_zzz( "zzz_entry:");
	  }
	  strcpy( buffer2, "entry_");						/* "entry_" + filename is always a public reference */
	  strcat( buffer2, fn_i);
	  write_obj( OT_6, 0, buffer2); 			/* write the public reference for the entry point of this module */
	  goto next_line;
	}

	if ( strcmpi( m_opcode, "lst") == 0)				/* ignore listing directives for now */
	  goto next_line;

	if ( (passno == 1) && strlen( m_label) ) {
	  c1 = m_label;
	  while(*c1) c1++;
	  c1--;
	  if (*c1 == ':') {
		*c1 = NULL;
		if (strlen(m_label) == 0) {
		  warning(2);
		} else
		  st_add( m_label, address);
	  } else {
		if (strlen( m_opcode) == 0) warning(1);
		st_add( m_label, address);
	  }
	}

	if ( strlen( m_opcode) == 0) {
	  if (!strlen( m_label))
		clrbuffer1();
	  goto next_line;
	}

	if ( (strcmpi(m_opcode,"equ")==0) || (strcmpi(m_opcode,"=")==0) ) {
	  if ( passno == 1) {
		if (strlen( m_data) == 0)
		  crash(53);											/* missing operand/data */
		u = *(eval( m_data));
		sp1 = st_add( m_label, u);								/* modify existing label */
		if (sp1)
		  sp1->equ = TRUE;										/* this is an equated label - do not relocate at link! */
	  }
	  if (passno == 2) {
		u = *(eval( m_label));									/* refetch label value (equate) */
		sprintf( buffer1, "%5u (%4xh)", u, u);
	  }
	  if (transwrite) {
		strcpy( zzztemp, m_label);
		strcat( zzztemp, "\tequ\t");
		strcat( zzztemp, m_data);
		write_zzz( zzztemp);			/* equates written out pretty much unchanged */
	  }

	  goto next_line;
	}

/* All statements after this REQUIRE AN ORIGIN TO BE IN EFFECT!!! */

	if ( (orig_specified==FALSE) && (orig_override==FALSE) ) crash(56); /* must specify origin first */


/* ASSEMBLER DIRECTIVES */

	if (strcmpi( m_opcode, "extrn") == 0) {

/* modify the .extn field of the specified labels (can be a list) to be external */

	  goto next_line;
	}


/* ASSEMBLER DATA STORAGE DIRECTIVES */

	if ( (strcmpi(m_opcode,"dm")==0) || (strcmpi(m_opcode,"dfm")==0) ) {
	  c1 = m_data;
	  while (*c1) {
		write_obj( OT_1, (int)*c1, NULL);
		c1++;
	  }
	  if (transwrite) {
		strcpy( zzztemp, m_label);
		strcat( zzztemp, "\tdb\t'");
		strcat( zzztemp, m_data);
		strcat( zzztemp, "'");
		write_zzz( zzztemp);			/* messages must be bracketed */
	  }
	  goto next_line;
	}

	if ( (strcmpi(m_opcode,"db")==0) || (strcmpi(m_opcode,"dfb")==0) ) {
	  if (strlen( m_data)==0)
		crash(87);								/* no arguments! */
	  c1 = m_data;
	  do {
		c1 = break_param( c1, ',');
		if (c1) {
		  data1 = *(eval(param_buffer));
		  write_obj( OT_1, data1, NULL);
		}
	  } while (c1 != NULL);
	  data1 = *(eval(param_buffer));
	  write_obj( OT_1, data1, NULL);
	  if (transwrite) {
		strcpy( zzztemp, m_label);
		strcat( zzztemp, "\tdb\t");
		strcat( zzztemp, m_data);
		write_zzz( zzztemp);			/* define bytes pretty much go out as is */
	  }
	  goto next_line;
	}

	if ( (strcmpi(m_opcode,"dw")==0) || (strcmpi(m_opcode,"dfw")==0) ) {
	  if (strlen( m_data)==0)
		crash(88);								/* no arguments! */
	  c1 = m_data;
	  do {
		c1 = break_param( c1, ',');
		if (c1) {
		  data1 = *(eval(param_buffer));
		  write_obj( OT_2, data1, NULL);
		}
	  } while (c1 != NULL);
	  data1 = *(eval(param_buffer));
	  write_obj( OT_2, data1, NULL);
	  if (transwrite) {
		strcpy( zzztemp, m_label);
		strcat( zzztemp, "\tdw\t");
		strcat( zzztemp, m_data);
		write_zzz( zzztemp);			/* byte messages pretty much go out as is */
	  }
	  goto next_line;
	}

	if ( (strcmpi(m_opcode,"ds")==0) || (strcmpi(m_opcode,"dfs")==0) ) {
	  if (strlen( m_data)==0)
		crash(89);								/* no arguments */
	  if (strchr( m_data, ','))
		crash(91);								/* illegal comma */
	  defs_request = TRUE;
	  data2 = *(eval(m_data));
	  for (i=1; i<=data2; i++)
		write_obj( OT_1, 0, NULL);
	  if (transwrite) {
		strcpy( zzztemp, m_label);
		strcat( zzztemp, "\tdb\t");
		strcat( zzztemp, m_data);
		strcat( zzztemp, " dup (?)");
		write_zzz( zzztemp);			/* storage messages converted to 'db x dup (?)' */
	  }
	  goto next_line;
	}

/* REGULAR 8085 ASSEMBLER OPCODES */

	if (strlen( m_label) && transwrite) {
	  strcpy( zzztemp, m_label);
	  strcat( zzztemp, ":");
	  write_zzz( zzztemp);
	}

	if ( (strcmpi(m_opcode,"ld")==0) || (strcmpi(m_opcode,"mov")==0) ) {
	  if (strlen( m_data) == 0)
		crash(63);								/* no arguments */
	  c1 = strchr( m_data, ',');
	  if (c1 == NULL)
		crash(61);								/* missing comma in LD command */
	  c2 = c1 + sizeof( char);			/* point after first argument and comma */
	  if (strchr( c2, ','))
		crash(62);								/* extra commas */

	  /* NOW WE KNOW WE HAVE EXACTLY TWO ARGUMENTS */

	  data1 = decide_reg8( m_data); data2 = decide_reg8( c2);

	  if (data1 == 6 && data2 == 6)
		crash(64);								/* ld (hl),(hl) is equivalent of a halt instruction */

	  if (data1 == 8 && data2 == 7) {			/* ld (bc),a */
		write_obj( OT_1, 0x02, NULL);
		if (transwrite) {
		  write_zzz( "\tmov\tdi,cx");
		  write_zzz( "\tmov\tbyte ptr [di],al");
		}
		goto next_line;
	  }

	  if (data1 == 9 && data2 == 7) {			/* ld (de),a */
		write_obj( OT_1, 0x12, NULL);
		if (transwrite) {
		  write_zzz( "\tmov\tdi,dx");
		  write_zzz( "\tmov\tbyte ptr [di],al");
		}
		goto next_line;
	  }

	  if (data1 == 7 && data2 == 8) {			/* ld a,(bc) */
		write_obj( OT_1, 0x0a, NULL);
		if (transwrite) {
		  write_zzz( "\tmov\tdi,cx");
		  write_zzz( "\tmov\tal,byte ptr [di]");
		}
		goto next_line;
	  }

	  if (data1 == 7 && data2 == 9) {			/* ld a,(de) */
		write_obj( OT_1, 0x1a, NULL);
		if (transwrite) {
		  write_zzz( "\tmov\tdi,dx");
		  write_zzz( "\tmov\tal,byte ptr [di]");
		}
		goto next_line;
	  }

	  if ( data1 >= 0 && (*c2 == '(' || *c2 == '[') && (data2 != 6) ) { 				/* ld ???,( ??? */
		data2 = eval_paren( c2);
		if (data1 == 7) {						/* ld a,(nn) */
		  write_obj( OT_1, 0x3a, NULL);
		  write_obj( OT_2, data2, NULL);
		  if (transwrite) {
			while (strchr( c2, '('))
			  *strchr( c2, '(') = '[';
			while (strchr( c2, ')'))
			  *strchr( c2, ')') = ']';
			strcpy( zzztemp, "\tmov\tal,byte ptr ");
			strcat( zzztemp, c2);
			write_zzz( zzztemp);
		  }
		  goto next_line;
		}
		crash(78);								/* can only load a,(nn) */
	  }

	  if ( (data1 >= 0 && data1 <= 7) && data2 == -1) { /* could be an immediate load */
		data2 = *(eval(c2));
		write_obj( OT_1, (data1 & 7) * 8 + 0x06, NULL); /* 8 bit immediate */
		write_obj( OT_1, (int)data2, NULL);
		if (transwrite) {
		  strcpy( zzztemp, "\tmov\t");
		  strcat( zzztemp, reg8map[ data1 & 7] );
		  strcat( zzztemp, ",offset ");
		  strcat( zzztemp, c2);
		  write_zzz( zzztemp);
		}
		goto next_line;
	  }

	  if ( (data2 >= 0) && (*m_data == '(' || *m_data == '[') && (data1 != 6) ) {				/* ld ( ??? */
		data2 = eval_paren( m_data);
		if (decide_reg8( c2) == 7) {							/* ld (nn),a */
		  write_obj( OT_1, 0x32, NULL);
		  write_obj( OT_2, data2, NULL);
		  if (transwrite) {
			strcpy( zzztemp1, m_data);
			while (strchr( zzztemp1, '('))
			  *strchr( zzztemp1, '(') = '[';
			while (strchr( zzztemp1, ')'))
			  *strchr( zzztemp1, ')') = ']';
			if (strchr( zzztemp1, ','))
			  *strchr( zzztemp1, ',') = '\0';
			strcpy( zzztemp, "\tmov\tbyte ptr ");
			strcat( zzztemp, zzztemp1);
			strcat( zzztemp, ",al");
			write_zzz( zzztemp);
		  }
		  goto next_line;
		}
		crash(79);												/* can only load (nn),a */
	  }

	  if ( (data1 >= 8) || (data2 >= 8) )
		crash(80);										/* something illegal with (bc) or (de) */
	  if ( (data1 >= 0) && (data2 >= 0) ) {
		write_obj( OT_1, (data1 & 7) * 8 + data2 + 0x40, NULL);
		if (transwrite) {
		  strcpy( zzztemp, "\tmov\t");
		  strcat( zzztemp, reg8map[ data1 & 7] );
		  strcat( zzztemp, ",");
		  strcat( zzztemp, reg8map[ data2 & 7] );
		  write_zzz( zzztemp);
		}
		goto next_line;
	  }

	  data1 = decide_reg16( m_data); data2 = decide_reg16( c2);
	  if (data1 == 3 && data2 == 2) {			/* ld sp,hl */
		write_obj( OT_1, 0xf9, NULL);
		if (transwrite) {
		  write_zzz( "\tmov\tsp,bx\t; ZZZWARN:  may not work as expected");
		  transwarn++;
		}
		goto next_line;
	  }

	  if ( (*m_data == '(') || (*m_data == '[') ) { 			/* ld ( ??? */
		data2 = eval_paren( m_data);
		if (decide_reg16( c2) == 2) {							/* ld (nn),hl */
		  write_obj( OT_1, 0x22, NULL);
		  write_obj( OT_2, data2, NULL);
		  if (transwrite) {
			strcpy( zzztemp1, m_data);
			while (strchr( zzztemp1, '('))
			  *strchr( zzztemp1, '(') = '[';
			while (strchr( zzztemp1, ')'))
			  *strchr( zzztemp1, ')') = ']';
			if (strchr( zzztemp1, ','))
			  *strchr( zzztemp1, ',') = '\0';
			strcpy( zzztemp, "\tmov\tword ptr ");
			strcat( zzztemp, zzztemp1);
			strcat( zzztemp, ",bx");
			write_zzz( zzztemp);
		  }
		  goto next_line;
		}
		crash(79);
	  }

	  if ( (*c2 == '(') || (*c2 == '[') ) { 					/* ld ???,( ??? */
		data2 = eval_paren( c2);
		if (decide_reg16( m_data) == 2) {						/* ld hl,(nn) */
		  write_obj( OT_1, 0x2a, NULL);
		  write_obj( OT_2, data2, NULL);
		  if (transwrite) {
			strcpy( zzztemp1, c2);
			while (strchr( zzztemp1, '('))
			  *strchr( zzztemp1, '(') = '[';
			while (strchr( zzztemp1, ')'))
			  *strchr( zzztemp1, ')') = ']';
			if (strchr( zzztemp1, ','))
			  *strchr( zzztemp1, ',') = '\0';
			strcpy( zzztemp, "\tmov\tbx,word ptr ");
			strcat( zzztemp, zzztemp1);
			write_zzz( zzztemp);
		  }
		  goto next_line;
		}
		crash(78);
	  }

	  data3 = *(eval( c2));
	  if (data1 >= 0 && data1 <= 3) {			/* load BC, DE, HL, or SP with immed ext */
		write_obj( OT_1, 0x01 + 0x10 * data1, NULL);
		write_obj( OT_2, data3, NULL);
		if (transwrite) {
		  sprintf( zzztemp, "\tmov\t%s,offset ", reg16map[ data1] );
		  strcat( zzztemp, c2);
		  write_zzz( zzztemp);
		}
		goto next_line;
	  }

	  crash(64);								/* unrecognized LD/MOV instruction */
	}

	if ( strcmpi( m_opcode, "push") == 0) {
	  if (strlen( m_data) == 0)
		crash(65);								/* need to specify argument */
	  c1 = strchr( m_data, ',');
	  if (c1 != NULL)
		crash(66);								/* extra information (comma) */
	  data1 = decide_reg16( m_data);
	  if (data1 < 0 || data1 == 3 || data1 > 4)
		crash(67);								/* invalid register */
	  if (data1 == 4)
		data1 = 3;
	  write_obj( OT_1, 0x10 * data1 + 0xc5, NULL);		/* push */
	  if (transwrite) {
		if (data1 == 3) {
		  write_zzz( "\tlahf");
		}
		strcpy( zzztemp, "\tpush\t");
		strcat( zzztemp, reg16map[ data1] );
		write_zzz( zzztemp);
		if (data1 == 3) {
		  write_zzz( "\tsahf");
		}
	  }
	  goto next_line;
	}

	if ( strcmpi( m_opcode, "pop") == 0) {
	  if (strlen( m_data) == 0)
		crash(65);								/* need to specify argument */
	  c1 = strchr( m_data, ',');
	  if (c1 != NULL)
		crash(66);								/* extra information (comma) */
	  data1 = decide_reg16( m_data);
	  if (data1 < 0 || data1 == 3 || data1 > 4)
		crash(67);								/* invalid register */
	  if (data1 == 4)
		data1 = 3;
	  write_obj( OT_1, 0x10 * data1 + 0xc1, NULL);		/* pop */
	  if (transwrite) {
		strcpy( zzztemp, "\tpop\t");
		strcat( zzztemp, reg16map[ data1] );
		write_zzz( zzztemp);
	  }
	  goto next_line;
	}

	if ( strcmpi( m_opcode, "ret") == 0) {
	  if (strlen( m_data) == 0) {
		data1 = 0xc9;							/* unconditional return */
		if (transwrite) {
		  write_zzz( "\tret");
		}
	  } else {
		data1 = decide_condition( m_data);
		if (data1 < 0)
		  crash(59);							/* unknown/illegal condition */
		if (transwrite) {
		  sprintf( zzztemp, "\t%s\t", revcond[ data1]);
		  sprintf( zzztemp1, "ret%04u", translabel);
		  strcat( zzztemp, zzztemp1);
		  write_zzz( zzztemp);			/* conditional jump around regular return */
		  write_zzz( "\tret");
		  sprintf( zzztemp, "ret%04u:", translabel);
		  write_zzz( zzztemp);
		  translabel++;
		}
		data1 = data1 * 8 + 0xc0;				/* conditional return */
	  }
	  write_obj( OT_1, data1, NULL);
	  goto next_line;
	}

	if ( (strcmpi(m_opcode,"call")==0) || (strcmpi(m_opcode,"do")==0) ) {
	  c1 = strchr( m_data, ',');
	  if (c1)
		c2 = c1 + sizeof( char);				/* point after condition and comma */
	  else
		c2 = m_data;
	  strcpy( zzzcondit, "");
	  if (c1 == NULL) {
		data1 = 0xcd;							/* unconditional call */
		if (transwrite) {
		  strcpy( zzztemp, "\tcall\t");
		}
	  } else {
		data1 = decide_condition( m_data);
		if (data1 < 0)
		  crash(60);							/* unknown/illegal condition */
		if (transwrite) {
		  sprintf( zzztemp, "\t%s\t", revcond[ data1]);
		  sprintf( zzztemp1, "call%04u", translabel);
		  strcat( zzztemp, zzztemp1);
		  write_zzz( zzztemp);			/* conditional jump around regular return */
		  strcpy( zzztemp, "\tcall\t"); /* start building the CALL statement */
		  sprintf( zzzcondit, "call%04u:", translabel);
		  translabel++;
		}
		data1 = data1 * 8 + 0xc4;				/* conditional call */
	  }
	  u = *(eval( c2));
	  write_obj( OT_1, data1, NULL);
	  write_obj( OT_2, u, NULL);
entry_complete_jumpcall:
	  if (transwrite) {
		switch(u) {
		  case 62750 :
			strcat( zzztemp, "[update_routine]");
			break;
		  case 0 :
		  case 32 :
		  case 10160 :
		  case 10161 :
		  case 14804 :
		  case 14808 :
		  case 29250 :
		  case 30326 :
			sprintf( zzztemp1, "m100rom_%u:", u);
			strcat( zzztemp, zzztemp1);
			break;
		  case 24 :
			write_zzz( "\tcmp\tbx,dx\t; cmp hl,de");
			break;
		  case 27611 :					/* LDIR */
			write_zzz_macro(0);
			break;
		  case 27622 :
			write_zzz_macro(1); 		/* LDDR */
			break;
		  default :
			if (u < 32768) {			/* unrecognized ROM/lomem access */
			  write_zzz( ";\n;\t\t\t; ZZZERR:  unrecognized ROM/lomem access" );
			  sprintf( zzztemp, ";\t\t\t(%s %s)\n;", m_opcode, m_data);
			  write_zzz( zzztemp);
			  transerror++;
			  write_zzz( "");
			  break;
			}
			if (u > 60672) {			/* access above usual video ram location */
			  write_zzz( ";\n;\t\t\t; ZZZERR:  unrecognized system ram/himem access" );
			  sprintf( zzztemp, ";\t\t\t; (%s %s)\n;", m_opcode, m_data);
			  write_zzz( zzztemp);
			  transerror++;
			  write_zzz( "");
			  break;
			}
			strcat( zzztemp, c2);		/* stick in the original label */
			break;
		}
		write_zzz( zzztemp);			/* write the completed CALL statement out */
		if (strlen( zzzcondit) ) {
		  write_zzz( zzzcondit);
		}
	  }
	  goto next_line;
	}

	if ( (strcmpi(m_opcode,"jmp")==0) || (strcmpi(m_opcode,"jp")==0) ) {
	  if ( (strcmpi(m_data,"(hl)")==0) || (strcmpi(m_data,"hl")==0) ) {
		write_obj( OT_1, 0xe9, NULL);									/* jmp (hl) or jmp hl (same command here) */
		if (transwrite) {
		  write_zzz( "\tjmp\t[bx]\t; ZZZWARN:  may not work as expected");
		  transwarn++;
		}
		goto next_line;
	  }
	  c1 = strchr( m_data, ',');
	  if (c1)
		c2 = c1 + sizeof( char);				/* point after condition and comma */
	  else
		c2 = m_data;
	  strcpy( zzzcondit, "");
	  if (c1 == NULL) {
		data1 = 0xc3;							/* unconditional jump */
		if (transwrite) {
		  strcpy( zzztemp, "\tjmp\t");
		}
		u = *(eval( c2));
		write_obj( OT_1, data1, NULL);
		write_obj( OT_2, u, NULL);
	  } else {
		data1 = decide_condition( m_data);
		if (data1 < 0)
		  crash(60);							/* unknown/illegal condition */
		if (transwrite) {
		  sprintf( zzztemp, "\t%s\t", revcond[ data1]);
		  sprintf( zzztemp1, "jmp%04u", translabel);
		  strcat( zzztemp, zzztemp1);
		  write_zzz( zzztemp);			/* conditional jump around regular call */
		  strcpy( zzztemp, "\tjmp\t");	/* start building the JMP statement */
		  sprintf( zzzcondit, "jmp%04u:", translabel);
		  translabel++;
		}
		data1 = data1 * 8 + 0xc2;				/* conditional jump */
		u = *(eval( c2));
		if ( passno == 1)
		  u = address;
		write_obj( OT_1, data1, NULL);
		write_obj( OT_2, u, NULL);
	  } 										/* end of else conditional jump */
	  goto entry_complete_jumpcall; 			/* finish up transwrite stuff */
	}

												/* only handles ADD HL,? statements */
	if ( strcmpi( m_opcode, "add") == 0) {
	  if (strlen( m_data) == 0)
		crash(69);								/* no arguments */
	  data1 = decide_reg16( m_data);
	  if (data1 == 2) { 						/* must be add hl,? */
		c1 = strchr( m_data, ',');
		if (c1 == NULL)
		  crash(71);							/* must be an add hl with no other args */
		c2 = c1 + sizeof( char);				/* point after first argument and comma */
		if (strlen( c2) == 0)
		  crash(71);
		if (strchr( c2, ','))
		  crash(70);							/* extra commas */
		data2 = decide_reg16( c2);
		if (data2 < 0 || data2 > 3)
		  crash(72);
		write_obj( OT_1, 0x09 + 0x10 * data2, NULL);
		if (transwrite) {
		  sprintf( zzztemp, "\tadd\tbx,%s", reg16map[ data2] );
		  write_zzz( zzztemp);
		}
		goto next_line;
	  }
	}

	data1 = decide_math8( m_opcode);
	zzzhold = data1;
	if (data1 == 8 || data1 == 9) { 			/* check if 16 bit inc/dec oper */
	  if (strchr( m_data, ','))
		crash(81);								/* comma in data field of an INC/DEC operation */
	  data2 = decide_reg16( m_data);
	  if (data2 >= 0 && data2 <= 3) {
		data1 = (data1 - 8) * 8 + 0x03 + 16 * data2;
		write_obj( OT_1, data1, NULL);			/* inc or dec 16 bit */
		if (transwrite) {
		  sprintf( zzztemp, "\t%s\t%s", m_opcode, reg16map[data2] );
		  write_zzz( zzztemp);
		}
		goto next_line;
	  }
	}
	if (data1 >= 0) {							/* musta been a math command */
	  switch (data1) {
		case 8 :
		  u1 = 0x04;							/* inc */
		  multip = 8;							/* multiplier for which register */
		  break;
		case 9 :
		  u1 = 0x05;							/* dec */
		  multip = 8;							/* multiplier for which register */
		  break;
		default :
		  u1 = 0x08 * data1 + 0x80; 			/* all other math */
		  multip = 1;							/* multiplier for which register */
		  break;
	  }
	  if (strlen( m_data) == 0)
		crash(82);
	  c1 = m_data;
	  c2 = strchr( m_data, ',');
	  if (c2) {
		data1 = decide_reg8( m_data);
		if (data1 != 7)
		  crash(73);							/* other register than A in 8-bit math opcode */
		c1 = c2 + strlen( "a,");				/* point past optional A, */
	  }
	  data2 = decide_reg8( c1);
	  if (data2 <0 || data2 > 7) {
		if (strchr( c1, '(') || strchr( c1, '[') )
		  crash(93);							/* can't say add (data) (indirect) */
		u = *(eval( c1));
		write_obj( OT_1, u1 + 0x46, NULL);		/* math immediate */
		write_obj( OT_1, u, NULL);				/* the immediate amount/value */
		if (transwrite) {
		  sprintf( zzztemp, "\t%s\tal,offset %s", math8map[ zzzhold], c1);
		  write_zzz( zzztemp);
		}
		goto next_line;
	  }
	  if (transwrite) {
		sprintf( zzztemp, "\t%s\tal,%s", math8map[ zzzhold], reg8map[ data2]);
		write_zzz( zzztemp);
	  }
	  data1 = data2 * multip + u1;
	  write_obj( OT_1, data1, NULL);
	  goto next_line;
	}											/* end of math commands */

	if ( strcmpi( m_opcode, "in") == 0) {
	  data2 = *(eval(m_data));
	  if (data2<0 || data2 > 255)
		crash(85);
	  write_obj( OT_1, 0xdb, NULL);
	  write_obj( OT_1, data2, NULL);
	  if (transwrite) {
		sprintf( zzztemp, "\tmov\tal,%s", m_data);
		write_zzz( zzztemp);					/* mov al,portaddr */
		strcpy( zzztemp, "\tcall\tm100_inport");
		write_zzz( zzztemp);					/* call m100_inport */
	  }
	  goto next_line;
	}

	if ( strcmpi( m_opcode, "out") == 0) {
	  data2 = *(eval(m_data));
	  if (data2<0 || data2 > 255)
		crash(86);
	  write_obj( OT_1, 0xd3, NULL);
	  write_obj( OT_1, data2, NULL);
	  if (transwrite) {
		write_zzz( "\tpush\tax");				/* push ax */
		sprintf( zzztemp, "\tmov\tah,%s", m_data);
		write_zzz( zzztemp);					/* mov ah,portaddr */
		strcpy( zzztemp, "\tcall\tm100_outport");
		write_zzz( zzztemp);					/* call m100_outport */
		write_zzz( "\tpop\tax");				/* pop ax */
	  }
	  goto next_line;
	}

	if ( strcmpi( m_opcode, "rst") == 0) {
	  data2 = *(eval(m_data));
	  if (data2 & 7 || (data2 < 0) || (data2 > 56) )
		crash(84);
	  write_obj( OT_1, 0xc7 + data2, NULL);
	  if (transwrite) {
		switch( data2) {
		  case 0 :
		  case 32 :
			sprintf( zzztemp, "\tcall\tm100rom_%u", data2);
			write_zzz( zzztemp);
			break;
		  case 24 :
			write_zzz( "\tcmp\tbx,dx\t; RST 24 = cmp hl,de");
			break;
		  default : 							/* unimplemented RST vector */
			write_zzz( ";\n;\t\t\t; ZZZERR:  unimplemented RST vector");
			sprintf( zzztemp, ";\t\t\t(%s %s)\n;", m_opcode, m_data);
			write_zzz( zzztemp);
			transerror++;
			break;
		}
	  }
	  goto next_line;
	}

	if ( (strcmpi(m_opcode,"ex")==0) || (strcmpi(m_opcode,"xchg")==0)) {
	  if ( (strcmpi(m_data,"de,hl")==0) || (strcmpi(m_data,"hl,de")==0) ) {
		write_obj( OT_1, 0xeb, NULL);
		if (transwrite) {
		  write_zzz( "\txchg\tbx,dx");
		}
		goto next_line;
	  }
	  if ( (strcmpi(m_data,"(sp),hl")==0) || (strcmpi(m_data,"hl,(sp)")==0) ) {
		write_obj( OT_1, 0xe3, NULL);
		if (transwrite) {
		  write_zzz( "\txchg\tbx,dx\t; ZZZWARN:  may not work as expected");
		  transwarn++;
		}
		goto next_line;
	  }
	  crash(83);						/* can't swap the specified registers */
	}

	if ( (strcmpi(m_opcode,"rlca")==0) || (strcmpi(m_opcode,"rlc")==0)) {
	  write_obj( OT_1, 0x07, NULL);
	  if (transwrite) {
		write_zzz( "\trcl");
	  }
	  goto next_line;
	}

	if ( (strcmpi(m_opcode,"rrca")==0) || (strcmpi(m_opcode,"rrc")==0)) {
	  write_obj( OT_1, 0x0f, NULL);
	  if (transwrite) {
		write_zzz( "\trcr");
	  }
	  goto next_line;
	}

	if ( strcmpi(m_opcode,"rla")==0) {
	  write_obj( OT_1, 0x17, NULL);
	  if (transwrite) {
		write_zzz( "\trol");
	  }
	  goto next_line;
	}

	if ( strcmpi(m_opcode,"rra")==0) {
	  write_obj( OT_1, 0x1f, NULL);
	  if (transwrite) {
		write_zzz( "\tror");
	  }
	  goto next_line;
	}

	if ( strcmpi( m_opcode, "nop") == 0) {
	  write_obj( OT_1, 0x00, NULL);
	  if (transwrite) {
		write_zzz( "\tnop");
	  }
	  goto next_line;
	}

	if ( (strcmpi(m_opcode,"halt")==0) || (strcmpi(m_opcode,"hlt")==0) ){
	  write_obj( OT_1, 0x76, NULL);
	  if (transwrite) {
		write_zzz( "\tjmp\tm100rom_0\t; HALT instruction");
	  }
	  goto next_line;
	}

	if ( strcmpi( m_opcode, "di") == 0){
	  write_obj( OT_1, 0xf3, NULL);
	  if (transwrite) {
		write_zzz( ";\n;\t\t\t; ZZZWARN:  DI not implemented - no effect");
	  }
	  goto next_line;
	}

	if ( strcmpi( m_opcode, "ei") == 0){
	  write_obj( OT_1, 0xfb, NULL);
	  if (transwrite) {
		write_zzz( ";\n;\t\t\t; ZZZWARN:  EI not implemented - no effect\n;");
	  }
	  goto next_line;
	}

	if ( strcmpi( m_opcode, "daa") == 0){
	  write_obj( OT_1, 0x27, NULL);
	  if (transwrite) {
		write_zzz( "\tdaa");
	  }
	  goto next_line;
	}

	if ( strcmpi( m_opcode, "cpl") == 0){
	  write_obj( OT_1, 0x2f, NULL);
	  if (transwrite) {
		write_zzz( "\txor\tal,255\t; cpl");
	  }
	  goto next_line;
	}

	if ( strcmpi( m_opcode, "ccf") == 0){
	  write_obj( OT_1, 0x3f, NULL);
	  if (transwrite) {
		write_zzz( "\tcmc");
	  }
	  goto next_line;
	}

	if ( strcmpi( m_opcode, "scf") == 0){
	  write_obj( OT_1, 0x37, NULL);
	  if (transwrite) {
		write_zzz( "\tstc");
	  }
	  goto next_line;
	}

/* ZZZ:  continue translator stuff here */


/* SPECIAL MODEL-100 MACRO OPCODES */

	if ( strcmpi( m_opcode, "ldir") == 0){
	  write_obj( OT_1, 0xcd, NULL); 			/* call */
	  write_obj( OT_1, 27611 & 255, NULL);
	  write_obj( OT_1, 27611 / 256, NULL);
	  if (transwrite) {
		write_zzz_macro( 0);
	  }
	  goto next_line;
	}

	if ( strcmpi( m_opcode, "lddr") == 0){
	  write_obj( OT_1, 0xcd, NULL); 			/* call */
	  write_obj( OT_1, 27622 & 255, NULL);
	  write_obj( OT_1, 27622 / 256, NULL);
	  if (transwrite) {
		write_zzz_macro( 1);
	  }
	  goto next_line;
	}

	if ( (strcmpi(m_opcode,"end")==0) || (strcmpi(m_opcode,"!")==0) ) {
	  end_reached = TRUE;
	  goto next_line;
	}

	crash(58);													/* unknown opcode */

/* testing only
	if ( (passno == 2) && (generate_listing) ) {
	  fprintf( fp_l, "\n\n*** %s ***\n[%s]\n'%s'\n'%s'\n'%s'",
				m_currline, m_dissline, m_label, m_opcode, m_data);
	}
*/


next_line:; 									/* done with line, get on with next one! */

	if ( (passno == 2) && (generate_listing & 2) ) {
	  fprintf( fp_l, "%-13s :\t%s", buffer1, m_currline);
	}
  } 															/* MAIN PROCESSING LOOP END */

  fclose_1( fp_i);										/* close source */
  if (fp_o) {
	write_obj( OT_99, NULL, NULL);				/* write end of file marker */
	fclose_1( fp_o);					/* close object (if open - only open on 2nd pass) */
  }

  if (fp_l) {
	if ( (passno == 2) && (generate_listing & 2) )
	  fprintf( fp_l, "\n\n****  END OF PROGRAM  ****\n");
	fclose_1( fp_l);									/* close listing (for now) */
  }
  return;
}







/******************************************************  MACRO MAKER ********/
/* Name:		write_zzz_macro( int type);
 * Started: 	12/08/90
 * Updated: 	12/08/90
 * Arguments:	None.
 *
 * Purpose: 	Writes various types of macros out to the write_zzz function.
 *
 *				0 - ldir
 *				1 - lddr
 */

write_zzz_macro( int type)
{
	switch( type) {
		case 0 :						/* LDIR */
		case 1 :						/* LDDR */
			write_zzz( "\tpush\tax");
			write_zzz( "\tmov\tdi,dx");
			sprintf( zzztemp1, "macro%4u", translabel);
			sprintf( zzztemp, "%s:", zzztemp1);
			write_zzz( zzztemp);
			write_zzz( "\tmov\tal,byte ptr [bx]");
			write_zzz( "\tmov\tbyte ptr [di],al");
			if (type) {
				write_zzz( "\tdec\tdx\n\tdec\tdi");
			} else {
				write_zzz( "\tinc\tdx\n\tinc\tdi");
			}
			sprintf( zzztemp, "\tloop\t%s", zzztemp1);
			write_zzz( zzztemp);
			write_zzz( "\tmov\tdx,di");
			write_zzz( "\tpop\tax");
			translabel++;
			break;
		default :
			sprintf( zzztemp, ";\t\t\t; ZZZERR:  internal unknown macro request: %u", type);
			write_zzz( zzztemp);
			transerror++;
			break;
	}
	return 0;
}






/**************************************************** PARSES 1 LINE OF ASSY */
/* Name:		read_1line( );
 * Started: 	07/23/90
 * Updated: 	10/14/90
 * Arguments:	None.
 *
 * Purpose: 	Brings in one line of assembly and breaks it down.
 *
 */

void read_1line()
{
char *c1, *c2;
int 	inquotes;						/* used to parse quotes in the data field, and avoid comments */

  fgets( m_currline, MAXLINE, fp_i);

  if ( feof( fp_i)) return;

  c1 = strchr( m_currline, '\n');
  if (c1) *c1 = NULL;					/* strip out ending newline character */

  lineno++;
  if (!(lineno % 100))
	fprintf( stderr, ".");

										/* condense the line's whitespaces */
  c1 = m_currline; c2 = m_dissline;
  while (*c1) {
	if (whitespace( *c1)) {
	  *c2 = ' ';
	  c2++;
	}
	while (whitespace( *c1) && (*c1) )
	  c1++;
	if (*c1 == NULL)
	  break;
	while (!whitespace( *c1) && (*c1) )
	  *c2++ = *c1++;
	if (*c1 == NULL)
	  break;
  }
  *c2 = NULL;

										/* break out the various items from the incoming line */
  c1 = m_dissline;

  m_label = nullstr;					/* assume all are nulls */
  m_opcode = nullstr;
  m_data = nullstr;

  m_label = c1; 						/* break out the label field */
  if ( iscomment(*m_label)) {
	m_label = nullstr;
	return;
  }
  while (!whitespace(*c1) && !iscomment(*c1))
	c1++;
  if (iscomment(*c1))
	*c1 = NULL;
  if (*c1 == NULL)
	return;
  *c1 = NULL;
  c1++;

  m_opcode = c1;						/* assume first field after first whitespace is the opcode field */
  if ( iscomment(*m_opcode)) {
	m_opcode = nullstr;
	return;
  }
  while (!whitespace(*c1) && !iscomment(*c1))
	c1++;
  if (iscomment(*c1))
	*c1 = NULL;
  if (*c1 == NULL)
	return;
  *c1 = NULL;
  c1++;

  m_data = c1;							/* assume field after second whitespace is data field */
  if ( (strcmpi(m_opcode,"dm")==0) || (strcmpi(m_opcode,"dfm")==0) ) {
	/* on a DM or DFM, use ENTIRE MESSAGE (no comments allowed) as m_data */
	return;
  }
  if ( iscomment(*m_opcode)) {
	m_opcode = nullstr;
	m_data = nullstr;
	return;
  }
  inquotes = FALSE;
  while (!whitespace(*c1) && (!iscomment(*c1) || inquotes) ) {
	if (*c1 == '\'' || *c1 == '\"')
	  inquotes = !inquotes;
	c1++;
  }
  if (iscomment(*c1))
	*c1 = NULL;
  *c1 = NULL;

  return;
}






/********************************************* ADD A SYMBOL TO SYMBOL TABLE */
/* Name:		st_add( label, value);
 * Started: 	07/23/90
 * Updated: 	08/27/90
 * Arguments:	label:	pointer to string to add to table.
 *				value:	unsigned int value of this label
 *
 * Purpose: 	Adds (or modifies the value of) the label in the symbol table.
 *
 * Returns: 	pointer to symbol structure that it just added or modified
 *
 * Symbol Tables:		symtab[x].lbl	- string containing label (malloc-ed)
 *						symtab[x].val	- uint value of label
 *						symtab[x].tipe	- not defined yet
 */

symbol	*st_add( label, value)
  char *label;
  uint value;
{
register int i;
int found = -1;

#ifdef DB_1
  fprintf( stderr, "\nst_add( %s, %u)", label, value);
#endif

  if (label_max >= 0)
	for (i=0; i <= label_max; i++)
	  if (strcmpi( symtab[i].lbl, label) == 0)
		found = i;

  if (found >= 0) {
	if (passno == 2)
	  crash(51);																/* duplicate label */
#ifdef DB_1
	fprintf( stderr, "\nChanging '%s' (%u)", symtab[found].lbl, value);
#endif
	symtab[found].val	= value;
	symtab[found].defd	= TRUE;
	symtab[found].equ	= FALSE;
	return &(symtab[found]);
  }

  if (passno == 1) {
#ifdef DB_1
	fprintf( stderr, "\nAdding '%s' (%u)", label, value);
#endif
	label_max++;
	if (label_max >= MAXLBL) crash(8);											/* out of storage for labels */
	symtab[label_max].lbl = (char *)malloc( strlen( label) + 5);
	if (symtab[label_max].lbl == NULL)
	  crash(21);																/* unable to allocate memory for symbol */
	strcpy( symtab[label_max].lbl, label);
	symtab[label_max].val		= value;
	symtab[label_max].tipe		= 0;
	symtab[label_max].extn		= FALSE;
	symtab[label_max].defd		= TRUE;
	symtab[label_max].equ		= FALSE;
	return &(symtab[label_max]);
  }

  return NULL;
}









/************************************************** INITIALIZE SYMBOL TABLE */
/* Name:		st_init( );
 * Started: 	07/23/90
 * Arguments:	None.
 *
 * Purpose: 	Clears the symbol table and associated variables.
 *
 *				Better to use a separate symbol table (smaller) to resolve
 *				externals at the multi-file link stage (next version).
 */

void st_init()
{
  label_max 			=		-1;
  return;
}







/**************************************************** EVALUATE A LABEL/EXPR */
/* Name:		eval( expr);
 * Started: 	07/23/90
 * Updated: 	08/05/90
 *				08/28/90
 *				04/06/92		(handles HEXADECIMAL numbers)
 *
 * Arguments:	expr:  the expression to evaluate.
 *
 *				Also, set defs_request = TRUE if you're calling this on passno==1
 *				and need to know a label's value for storage space allocation purposes.
 *
 * Returns: 	int *:	pointer to word containing value.
 *				if NULL, then pointer not defined
 *				if 1, then pointer is EXTERNAL!
 *
 * Purpose: 	Calculates the value of the argument/expression.
 */

int *eval( expr)
  char *expr;
{
  static int data;
  register int i;

  abs_ref = TRUE;

  if (*expr == '\'' || *expr == '"') {
	data = (uint)*(expr + sizeof(char));
	return (&data);
  }

  if (isdigit( *expr)) {
	data = atoi(expr);
	return (&data);
  }

  abs_ref = FALSE;

  if (*expr == '$') {
	expr++;
	data = 0;
	while( *expr) {
	  data *= 16;
	  if (*expr >= 'a' && *expr <= 'f') {
		data += *expr - 'a' + 10;
		goto next_hex_char;
	  }
	  if (*expr >= 'A' && *expr <= 'F') {
		data += *expr - 'A' + 10;
		goto next_hex_char;
	  }
	  if (*expr >= '0' && *expr <= '9') {
		data += *expr - '0';
		goto next_hex_char;
	  }
	  crash(95);				/* Invalid hex number */
next_hex_char:
	  expr++;
	}
	return &data;
  }

  /* if the argument is a $ sign ('$' alone), then return address */

  if (passno == 1 && (!defs_request))
	return NULL;
  if (label_max < 0)
	if (defs_request)
	  crash(94);								/* undefined storage argument */
	else
	  crash(52);								/* undefined label */
  for (i = 0; i<=label_max; i++) {
	if (strcmpi( symtab[i].lbl, expr) == 0) {
	  if (symtab[i].equ)
		abs_ref = TRUE; 						/* it's an equate! (do not relocate) */
	  if (symtab[i].defd)
		return (int *)&(symtab[i].val);
	  else {
		if (defs_request)
		  crash(94);							/* must be defined! */
		else
		  return (NULL);
	  }
	}
  } 			/* for */

  if (defs_request)
	crash(94);							/* undefined storage argument */
  else
	crash(52);							/* undefined label */

  return 0;
}








/************************************************* ASSEMBLER INITIALIZATION */
/* Name:		init();
 * Started: 	07/22/90
 * Updated: 	08/28/90
 * Arguments:	None.
 *
 * Purpose: 	Initialize everything for the assembler.
 */

void init()
{
  orig_override 		=		0;
  generate_listing		=		0;
  label_max 			=		-1;
  dec_block_size		=		15;
  warningno 			=		0;
  warning_fatal 		=		FALSE;
  list_file_specified	=		FALSE;
  end_reached			=		FALSE;

  decfile_header_written =		FALSE;

  return;
}






/****************************************************** LINK INITIALIZATION */
/* Name:		init_link();
 * Started: 	08/22/90
 * Arguments:	None.
 *
 * Purpose: 	Initialize everything for the linker.
 */

void	init_link()
{
  decfile_header_written =		FALSE;
  orig_specified		=		FALSE;
  origin				=		0;

  decfile_checksum		=		0;
  decfile_linepos		=		0;

  return;
}







/********************************************************************* LINK */
/* Name:		link();
 * Started: 	08/22/90
 * Updated: 	08/27/90
 * Arguments:	None.
 *
 * Purpose: 	Links the file to produce a *.DEC uploadable file.
 */

void link()
{
char	buf[ MAXWORD], *str;
uint	temp;
uint	link_eof = FALSE;

/* must re-use the symbol table, this time to resolve externals.  Not necessary
   until we give this linker the ability to do more than one module.  At that
   point it will ALSO BE NECESSARY TO BE A TWO-PASS LINKER!!!
*/

/* Must make a pre-pass through this to find out the origin and ending !!!
	MAKE SURE TO CHANGE THE DEFAULT BELOW WHERE IT MAKES EACH FILE 100 BYTES LONG!
*/

  fprintf( stderr, "\n\nLink Pass #%d:", passno);
  if (passno == 2)
	if ( (fp_x = fopen( fn_x, "w")) == NULL)
	  crash(9); 										/* unable to open X_DEC file for output (only on passno == 2) */
  if ( (fp_o = fopen( fn_o, "r")) == NULL)
	crash(10);											/* unable to open X_OBJ file for input */

  if (passno == 1)
	init_link();												/* reinitialize variables for linking */
  origin = 0;

  while (!feof( fp_o) && !link_eof) {
	fgets( buf, MAXWORD-2, fp_o);
	if (feof( fp_o))
	  break;
	str = buf+sizeof(char);
	switch( *buf) {
	  case OT_1 :						/* absolute BYTE - copy through */
		if (!orig_specified)
		  crash(11);
		write_dec( atoi( str));
		break;
	  case OT_2 :						/* relative word - must calculate correct address, send 2 bytes */
		if (!orig_specified)
		  crash(11);
		temp = atoi( str) + origin;
		write_dec( temp & 255); 		/* write low byte */
		write_dec( temp / 256); 		/* write high byte */
		break;
	  case OT_5 :						/* external reference - word size - must resolve - similar to OT_2 */
		if (!orig_specified)
		  crash(11);
		break;
	  case OT_6 :						/* public declaration - must add to symbol table */
		if (!orig_specified)
		  crash(11);
		break;
	  case OT_10 :						/* date assembled (info only) */
	  case OT_11 :						/* source file (info only) */
		break;							/* just discard these two */
	  case OT_15 :						/* origin value */
		origin = atoi( str);
		address = origin;
		addr_top = origin;
		if (origin < 32768)
		  warning(4);					/* suspect origin address is in ROM! */
		orig_specified = TRUE;
		break;
	  case OT_16 :						/* execution point */
		addr_exe = address;
		if (passno == 2 && addr_end)
		  fprintf( fp_x, "%u,%u,%u,%d\n", addr_top, addr_end, addr_exe, dec_block_size);
		decfile_header_written = TRUE;
		break;
	  case OT_99 :						/* end of object file marker */
		link_eof = TRUE;
		break;
	  default :
		/* bad object record at link stage */
		crash(24);						/* unknown object type */
		break;
	}									/* main while() loop */
  } 			/* while (!feof) */

  addr_end = address + 1;				/* mark end of code */

  if (passno == 2) {
	write_dec( -1);
	fprintf( fp_x, "\n\n\n");							/* tells FTU.BAS to stop! */
  }
  fclose_1( fp_o);
  if (passno == 2)
	fclose_1( fp_x);
  return;
}








/******************************************************** DECIDE REGISTER 8 */
/* Name:		decide_reg8( str);
 * Started: 	08/23/90
 * Arguments:	str:  string containing pointer to argument.
 *
 * Purpose: 	Decides which 8-bit register is specified in the argument
 *				string.
 *
 * Possibilities:  B,  C,  D,  E,  H,  L,(HL), A, (BC), (DE)
 *				   0,  1,  2,  3,  4,  5,  6,  7,	 8,    9
 *
 *				Returns a -1 if it cannot find the 8-bit register.
 */

decide_reg8( str)
  char *str;
{
char	temp[ MAXWORD];
register char	*cptr = temp;
register int	i;
static	char *registers[] = { "b", "c", "d", "e", "h", "l", "(hl)", "a", "(bc)", "(de)" };
#define max_reg8 10

  strcpy( temp, str);							/* don't modify original string, obviously */
  while (!delimiter(*cptr))
	cptr++;
  *cptr = NULL;
  for (i=0; i<max_reg8; i++)
	if (strcmpi( temp, registers[i]) == 0)
	  return i;

  return -1;
}







/******************************************************* DECIDE REGISTER 16 */
/* Name:		decide_reg16( str);
 * Started: 	08/23/90
 * Arguments:	str:  string containing pointer to argument.
 *
 * Purpose: 	Decides which 16-bit register is specified in the argument
 *				string.
 *
 * Possibilities:  BC, DE, HL, SP, AF, (SP)
 *				   0,  1,  2,  3,  4,	5
 *
 *				Returns a -1 if it cannot find the 16-bit register.
 */

decide_reg16( str)
  char *str;
{
char	temp[ MAXWORD];
register char	*cptr = temp;
register int	i;
static	char *registers[] = { "bc", "de", "hl", "sp", "af", "(sp)" };
#define max_reg16 6

  strcpy( temp, str);							/* don't modify original string, obviously */
  while (!delimiter(*cptr))
	cptr++;
  *cptr = NULL;
  for (i=0; i<max_reg16; i++)
	if (strcmpi( temp, registers[i]) == 0)
	  return i;

  return -1;
}








/***************************************** EVALUATE PARENTHESIZED ARGUMENTS */
/* Name:		eval_paren( str);
 * Started: 	08/26/90
 * Arguments:	str:  string containing parenthesized argument.
 *
 * Purpose: 	uses eval() to evaluate the expression inside the parentheses.
 *
 */

eval_paren( str)
  char *str;
{
char	temp[ MAXWORD];
char	*c1, *c2;
char	sc, ec;
register int	i;

  strcpy( temp, str);
  sc = *temp;
  switch( *temp) {
	case '(' :	ec=')'; break;
	case '[' :	ec=']'; break;
	default  :	crash(75);						/* don't recognize delimiter */
  }
  c1 = strchr( temp, sc) + sizeof( char);
  c2 = strchr( temp, ec);  *c2 = NULL;			/* mark the end */
  if (strlen( c1) == 0)
	crash(76);									/* no string inside ! */
  if (strchr( c1, ','))
	crash(77);
  return *(eval(c1));
}








/********************************************* PARSE PARAMETERS FROM A LIST */
/* Name:		break_param( data, delim);
 * Started: 	08/27/90
 * Arguments:	data:  string containing list of arguments
 *				delim:	delimiter separating each argument
 *
 * Purpose: 	breaks out each argument in a string.
 *
 */

char	*break_param( data, delim)
  char *data, delim;
{
char	*c1;

  strcpy( param_buffer, data);
  c1 = strchr( param_buffer, delim);
  if (c1) {
	*c1 = NULL;
	return c1 + sizeof( char);
  }
  return NULL;
}








/****************************************************** DECIDE MATHS/LOGICS */
/* Name:		decide_math8( str);
 * Started: 	08/26/90
 * Updated: 	12/08/90
 * Arguments:	str:  string containing pointer to opcode.
 *
 * Purpose: 	Decides which 8-bit math or logic is specified.
 *
 * Possibilities:  add, adc, etc.
 *
 *				Returns a -1 if it cannot find the math/logic opcode.
 */

decide_math8( str)
  char *str;
{
register int	i;
static	char *maths[] = { "add", "adc", "sub", "sbb", "sbc", "and", "eor", "xor", "or", "cp", "cmp", "inc", "dec" };
static	int mathret[] = {	  0,	 1, 	2,	   3,	  3,	 4, 	5,	   5,	 6,    7,	  7,	 8, 	9 };
#define max_math 13

  for (i=0; i<max_math; i++)
	if (strcmpi( str, maths[i]) == 0)
	  return mathret[i];

  return -1;
}








/********************************************************* DECIDE CONDITION */
/* Name:		decide_condition( str);
 * Started: 	08/22/90
 * Updated: 	08/22/90
 * Arguments:	None.
 *
 * Purpose: 	Decides what kind of condition is specified in the argument
 *				string.
 *
 * Possibilities: NZ,  Z, NC,  C, PO, PE,  P,  N
 *				   0,  1,  2,  3,  4,  5,  6,  7
 *
 *				Returns a -1 if it cannot find the condition.
 */

decide_condition( str)
  char *str;
{
char	temp[ MAXWORD];
register char	*cptr = temp;
register int	i;
static	char *conditions[] = { "nz", "z", "nc", "c", "po", "pe", "p", "n" };
#define max_conditions 8

  strcpy( temp, str);							/* don't modify original string, obviously */
  while (!delimiter(*cptr))
	cptr++;
  *cptr = NULL;
  for (i=0; i<max_conditions; i++)
	if (strcmpi( temp, conditions[i]) == 0)
	  return i;

  return -1;
}







/********************************************************* WRITE TO DECFILE */
/* Name:		write_dec( data);
 * Started: 	08/22/90
 * Arguments:	None.
 *
 * Purpose: 	writes the data (1 byte) to the decfile.
 *
 *				Also prepares checksums, etc.
 *
 *				Call this with (-1) to finish current line with zeros.
 *
 * Possibilities:  -1 with some spaces remaining (fewer than dec_block_size)
 *				   -1 with none written yet.
 *				   data with some spaces remaining (at last write, write checksum)
 */

void	write_dec( data)
  int data;
{
  if (data >= 0)
	address ++;
  if (passno != 2)
	return;
  if (data == -1 && decfile_linepos == 0)
	return; 									/* don't write anything if line is not yet started and file is ended */
  if (data == -1)
	for ( ; decfile_linepos < dec_block_size; decfile_linepos++) {
	  fprintf( fp_x, ",0");
	}
  if (decfile_linepos == dec_block_size) {
	fprintf( fp_x, ",%u\n", decfile_checksum);
	decfile_linepos 	= 0;
	decfile_checksum	= 0;
  } else {
	if (decfile_linepos > 0)
	  fprintf( fp_x, ",");
	fprintf( fp_x, "%u", data);
	decfile_linepos++;
	decfile_checksum	+= data;
	if (decfile_linepos == dec_block_size) {
	  fprintf( fp_x, ",%u\n", decfile_checksum);
	  decfile_linepos	= 0;
	  decfile_checksum	= 0;
	}
  }
  return;
}







/************************************************** EXPLANATION OF WARNINGS */
/* Name:		explain_warning( file_p, warnno);
 * Started: 	07/25/90
 * Arguments:	file_p:  file pointer to send output to
 *				warnno:  the warning that occurred
 *
 * Purpose: 	Explain the particular warning to the file stream file_p
 */

void explain_warning( file_p, warnno)
  FILE *file_p;
  int warnno;
{
  fprintf( file_p, "\nWarning %u: ", warnno);
  switch( warnno) {
	case  1 :
	  fprintf( file_p, "label alone on a line, no opcode (or colon) specified");
	  break;
	case  2 :
	  fprintf( file_p, "null label (only a colon on the line)");
	  break;
	case  3 :
	  fprintf( file_p, "extra info in data field - ignored");
	  break;
	case  4 :
	  fprintf( file_p, "suspected origin address:  in ROM - continuing to link");
	  break;
	default :
	  fprintf( file_p, "number %d", warnno);
	  break;
  }
  fprintf( file_p, "\n%s(%d):\t%s", fn_i, lineno, m_currline);
  fprintf( file_p, "\n");
  return;
}







/***************************************************************** WARNINGS */
/* Name:		warning( warnno);
 * Started: 	07/25/90
 * Arguments:	warnno:  the warning that occurred
 *
 * Purpose: 	Handle warnings appropriately.
 */

void warning( warnno)
  int warnno;
{
  warningno++;
  explain_warning( stderr, warnno);
  if (generate_listing && fp_l)
	explain_warning( fp_l, warnno);
  if (warning_fatal) crash(7);
  return;
}







/**************************************************** EXPLANATION OF ERRORS */
/* Name:		explain_crash( file_p, errno);
 * Started: 	07/25/90
 * Arguments:	file_p:  file pointer to send output to
 *				errno:	the error that occurred
 *
 * Purpose: 	Explain the particular error to the file stream file_p
 */

void explain_crash( file_p, errno)
  FILE *file_p;
  int errno;
{
  if (errno)
	fprintf( file_p, "\n\nError %u: ", errno);
  switch( errno) {

/* no error - hunky dory assembly */
	case   0 :
	  fprintf( file_p, "\n\nAssembly completed");
	  break;

/* errors pertaining to user interface/options specified */
	case   1 :
	  fprintf( file_p, "Must specify filename to assemble");
	  break;
	case   2 :
	  fprintf( file_p, "Must specify only ONE filename to assemble");
	  break;
	case   3 :
	  fprintf( file_p, "Unable to open source file '%s'", fn_i);
	  break;
	case   4 :
	  fprintf( file_p, "Unable to open *." X_LST " file '%s'", fn_l);
	  break;
	case   5 :
	  fprintf( file_p, "Unable to open output (object) file '%s'", fn_o);
	  break;
	case   6 :
	  fprintf( file_p, "Blocksize too small:  minimum 3 bytes");
	  break;
	case   7 :
	  fprintf( file_p, "User specified warnings to be considered fatal");
	  break;
	case   8 :
	  fprintf( file_p, "No more label space - need to define more!  (MAXLBL = %u)", MAXLBL);
	  break;
	case   9 :
	  fprintf( file_p, "Unable to open output (executable) file '%s'", fn_x);
	  break;
	case  10 :
	  fprintf( file_p, "Unable to reopen input (object) file '%s'", fn_o);
	  break;
	case  11 :
	  fprintf( file_p, "Linker:  origin not specifed before data written (objfile = '%s')", fn_o);
	  break;
	case  12 :
	  fprintf( file_p, "Unable to open output (translation) file '%s'", fn_z);
	  break;

/* Internal errors - memory, intermediate files, etc. */
	case  21 :
	  fprintf( file_p, "Unable to allocate memory for label storage '%s'", m_label);
	  break;
	case  22 :
	  fprintf( file_p, "Unknown object record type attempted to be written.");
	  break;
	case  23 :
	  fprintf( file_p, "Error writing to OBJECT OUTPUT file '%s'", fn_o);
	  break;
	case  24 :
	  fprintf( file_p, "Unknown object record type attempted to be linked.");
	  break;

/* Errors pertaining to problems with source code */
	case  51 :
	  fprintf( file_p, "Duplicate Label");
	  break;
	case  52 :
	  fprintf( file_p, "Undeclared Identifier");
	  break;
	case  53 :
	  fprintf( file_p, "Missing Operand/Data");
	  break;
	case  54 :
	  fprintf( file_p, "ORG statement may not have a label");
	  break;
	case  55 :
	  fprintf( file_p, "Duplicate ORG statements not allowed");
	  break;
	case  56 :
	  fprintf( file_p, "Must specify ORG before this statement");
	  break;
	case  57 :
	  fprintf( file_p, "Invalid ORG address");			/* not currently called */
	  break;
	case  58 :
	  fprintf( file_p, "Bad opcode - unknown");
	  break;
	case  59 :
	  fprintf( file_p, "Unknown/illegal condition specified (RET)");
	  break;
	case  60 :
	  fprintf( file_p, "Unknown/illegal condition specified (JMP)");
	  break;
	case  61 :
	  fprintf( file_p, "LD/MOV:  missing comma in arguments");
	  break;
	case  62 :
	  fprintf( file_p, "LD/MOV:  extra comma(s) in arguments");
	  break;
	case  63 :
	  fprintf( file_p, "LD/MOV:  missing arguments");
	  break;
	case  64 :
	  fprintf( file_p, "LD/MOV:  unrecognized/illegal argument combination");
	  break;
	case  65 :
	  fprintf( file_p, "PUSH/POP:  need valid 16-bit argument - missing");
	  break;
	case  66 :
	  fprintf( file_p, "PUSH/POP:  extra information in argument");
	  break;
	case  67 :
	  fprintf( file_p, "PUSH/POP:  must specify AF, BC, DE, or HL argument");
	  break;
	case  68 :
	  fprintf( file_p, "JMP:  address out of range for conditional (jump backward)");
	  break;
	case  69 :
	  fprintf( file_p, "ADD:  missing arguments");
	  break;
	case  70 :
	  fprintf( file_p, "ADD:  extra comma(s) in arguments");
	  break;
	case  71 :
	  fprintf( file_p, "ADD:  need to specify register to add to HL");
	  break;
	case  72 :
	  fprintf( file_p, "ADD:  only BC, DE, HL, and SP may be added to HL");
	  break;
	case  73 :
	  fprintf( file_p, "8-bit math implies the A register as destination");
	  break;
	case  74 :
	  fprintf( file_p, "LD/MOV:  missing closing parentheses or brackets");
	  break;
	case  75 :
	  fprintf( file_p, "eval_paren:  invalid/missing starting parentheses/brackets");
	  break;
	case  76 :
	  fprintf( file_p, "eval_paren:  zero length string inside parentheses/brackets");
	  break;
	case  77 :
	  fprintf( file_p, "eval_paren:  commas inside paren argument");
	  break;
	case  78 :
	  fprintf( file_p, "LD/MOV:  cannot load indirect with specified register");
	  break;
	case  79 :
	  fprintf( file_p, "LD/MOV:  cannot store indirect with specified register");
	  break;
	case  80 :
	  fprintf( file_p, "LD/MOV:  cannot address with (BC) or (DE) this way");
	  break;
	case  81 :
	  fprintf( file_p, "INC/DEC:  too many arguments (extra comma?)");
	  break;
	case  82 :
	  fprintf( file_p, "8-bit math: missing argument(s)");
	  break;
	case  83 :
	  fprintf( file_p, "EX/XCHG:  invalid registers specified for exchange");
	  break;
	case  84 :
	  fprintf( file_p, "RST:  bad restart vector (must be 0, 8, 16 ... 56)");
	  break;
	case  85 :
	  fprintf( file_p, "IN:  invalid port address (must be 0 - 255)");
	  break;
	case  86 :
	  fprintf( file_p, "OUT:  invalid port address (must be 0 - 255)");
	  break;
	case  87 :
	  fprintf( file_p, "DB/DFB:  missing argument data");
	  break;
	case  88 :
	  fprintf( file_p, "DW/DFW:  missing argument data");
	  break;
	case  89 :
	  fprintf( file_p, "DS/DFS:  missing argument data");
	  break;																			/* skip error 90 - too hard to search! */
	case  91 :
	  fprintf( file_p, "DS/DFS:  extra comma(s) in argument data");
	  break;
	case  92 :
	  fprintf( file_p, "JMP:  address out of range for conditional (jump forward)");
	  break;
	case  93 :
	  fprintf( file_p, "math:  cannot address indirect immediate");
	  break;
	case  94 :
	  fprintf( file_p, "DS/DFS:  must previously define storage space identifiers");
	  break;
	case  95 :
	  fprintf( file_p, "eval: bad hexadecimal expression");
	  break;

/* Undefined/undeclared errors */
	default :
	  fprintf( file_p, "#%d", errno);
	  break;
  }
  if (errno>=51)
	fprintf( file_p, "\n%s(%d):\t%s", fn_i, lineno, m_currline);
  fprintf( file_p, "\n");

  return;
}






/******************************************************************* ERRORS */
/* Name:		crash( errno);
 * Started: 	07/22/90
 * Updated: 	08/28/90
 * Arguments:	errno:	the error that occurred
 *
 * Purpose: 	Handle all error events.  Calls explain_crash() so that a
 *				tee may be inserted in the outgoing pipe (stream).
 */

void crash( errno)
  int errno;
{
  int i;

  explain_crash( stderr, errno);

  if (fp_l) {
	explain_crash( fp_l, errno);
  }

  if (fp_l) { fclose_1(fp_l) }

  if (fp_z) {
	if (transwrite) {
	  sprintf( zzztemp, "; ZZZ translator reported %u warnings and %u errors", transwarn, transerror);
	  write_zzz( zzztemp);
	}
	fclose_1(fp_z);
  }

  if (fp_o) {
	for (i=0; i<=label_max; i++)
	  write_obj( OT_6, symtab[i].val, NULL);							/* publish all publics! */
  }

  if ( ((errno == 0) || (errno > 20)) && (passno == 2) && (generate_listing & 1) )
	if ( (fp_l = fopen( fn_l, "a")) != NULL) {
	  fprintf( fp_l, "\n\n\n****  Symbol Table  **** (%u used/%u total)\n", label_max + 1, MAXLBL);
	  if (label_max >= 0)
		for (i=0; i<=label_max; i++)
		  fprintf( fp_l, "\n%-32s = %5u (%4xh)", symtab[i].lbl, symtab[i].val, symtab[i].val);
	  fprintf( fp_l, "\n");
	}

/* print the cross-reference listing here, just like above symbol table */
/* Maybe I can interleave the cross-reference into the symbol table  */


  if (label_max >= 0)
	for (i = 0; i <= label_max; i++) {			/* free up allocated label space */
#ifdef DB_1
	  fprintf( stderr, "\nDeleting '%s' (%u)", symtab[i].lbl, symtab[i].val);
#endif
	  free( symtab[i].lbl);
	}

  if (fp_i) { fclose_1( fp_i) }
  if (fp_o) { fclose_1( fp_o) }
  if (fp_l) { fclose_1( fp_l) }

  exit( errno);
}

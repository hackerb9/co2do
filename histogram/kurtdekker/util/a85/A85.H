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


/****************************************************************************/
/*
 * Author:	Kurt W. Dekker
 * Started: 	12/08/90
 * Updated:	12/08/90
 *		11/18/94
 * Filename:	A85.H
 *
 *
 * Description:	Header file for Cross-assembler for
 *		TRS-80 Model 100 (8085 CPU), A85.C
 *
 */


/**************************************************************** #INCLUDES */
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <dos.h>


/************************************* OBJECT RECORD TYPES (see OBJECT.DOC) */
#define OT_1	'B'	/* absolute byte */
#define OT_2	'R'	/* relative word */

#define OT_5	'E'	/* external reference */
#define	OT_6	'P'	/* public declaration */

#define OT_10	'D'	/* date/time assembled */
#define OT_11	'S'	/* source filename (info only) */

#define OT_15	'O'	/* origin value */
#define OT_16	'X'	/* execution point */

#define OT_99	'Z'	/* end of object file */


/***************************************************************** #DEFINES */
#define FALSE	NULL
#define TRUE	1
#define MAXWORD 200
#define MAXLINE 400
#define uint unsigned int
#define MAXLBL 500

/* list of possible extensions */
#define X_LST "L85"
#define X_OBJ "O85"
#define X_ASM "ASM"
#define X_DEC "DEC"
#define	X_INC "INC"


/****************************************************************** #MACROS */
#define whitespace(a) ( (a)==' ' || (a)=='\t' || (a)=='\n' || (a)=='\r' || (a)=='\0')
#define delimiter(a) ( whitespace(a) || (a) == ',' || (a) == '-' || (a) == '+' )
#define iscomment(a) ( (a)==';' || (a)=='*')
#define fclose_1(a) fclose(a);(a)=NULL;


/****************************************************************** GLOBALS */
/* Filename processing */
char	fn_i[ MAXWORD];		FILE *fp_i = NULL;	/* source file */
char	fn_o[ MAXWORD];		FILE *fp_o = NULL;	/* object file */
char	fn_x[ MAXWORD];		FILE *fp_x = NULL;	/* *.DEC (exe) file */
char	fn_l[ MAXWORD];		FILE *fp_l = NULL;	/* listing file */
char	fn_z[ MAXWORD];		FILE *fp_z = NULL;	/* translate file */

char	*cptr, c;

int arg1;

struct	time	time_s;
struct	date	date_s;


/*********************************************************** DATA TYPES *****/
#define SYMTAB struct tag1
typedef SYMTAB {
  char	*lbl;		/* string equal to the label */
  uint	val;		/* value of this label */
  uint	tipe;		/* not used just yet... */
  uint	extn;		/* nonzero, this label must be resolved external */
  uint	defd;		/* nonzero, then this label has been defined */
  uint	equ;		/* this is an equate - do not relocate! */
} symbol;

/*
#define MIXER union tag2
typedef MIXER {
  int	number;
  char	*string;
} mixer;
*/


/* Assembling and ongoing status information */
int	lineno,	passno,	warningno;
char	m_currline[ MAXLINE];	/* line as it is read in from file */
char	m_dissline[ MAXLINE];	/* line after it is broken down */
char	zzztemp[ MAXLINE];	/* used for building translator lines */
char	zzztemp1[ MAXLINE];	/* used for building translator lines */
char	zzzcondit[ MAXLINE];	/* used for buliding conditional translator lines */
unsigned int	zzzhold;	/* temporary use */
char	*m_label;
char	*m_opcode;
char	*m_data;
uint	address;			/* current memory location */
uint	origin;				/* origin for this file */
uint	addr_top, addr_end, addr_exe;	/* header info for linking */

int	data1, data2, data3;

char	param_buffer[ MAXWORD];		/* for breaking strings of parameters */

int	abs_ref = FALSE;		/* current reference is not to be resolved */
int	defs_request = FALSE;		/* is current call to eval() for storage space? */

/* Label and data processing */
int	label_max;			/* which label we have used */

symbol	symtab[ MAXLBL];

char	*nullstr = "\0";

char	*reg8map[] = { "ch", "cl", "dh", "dl", "bh", "bl", "byte ptr [bx]", "al" };
char	*reg16map[] ={ "cx", "dx", "bx", "ax"};
char	*revcond[] = { "jz", "jnz", "jc", "jnc", "jpe", "jpo", "js", "jns" };
char	*math8map[] ={ "add", "adc", "sub", "sbb", "and", "xor", "or", "cmp", "inc", "dec" };

/* Assembler options/switches */
int	generate_listing;	/* Options for *X_LST file: (bit-wise) */
int	orig_override;		/* explicit definition of origin? (on the cmd line) */
int	orig_specified;		/* has an origin statement been made yet? (used both by assy and by link) */
int	list_file_specified = FALSE;
int	warning_fatal = FALSE;
int	end_reached = FALSE;
int	dec_block_size;		/* blocksize on final *.DEC output */
int	translate = FALSE;	/* are we doing 8085-->8086 translation? */
int	transwrite = FALSE;	/* translate && (passno == 2) */
int	translate_flags = 0;	/* flags to say what things we do in translation */
int	translabel = 0;		/* for building temporary labels */
int	transerror = 0;		/* number of translator errors */
int	transwarn = 0;		/* number of translator warnings */

char	buffer1[ MAXWORD];
#define	clrbuffer1() strcpy(buffer1, nullstr)
char	buffer2[ MAXWORD];
char	dbuf[ 50], tbuf[ 50], dtbuf[ MAXWORD];		/* holds the date/time */

/* Linker variables */
int	decfile_header_written;
int	decfile_checksum;
int	decfile_linepos;


/*************************************************************** PROTOTYPES */
int	main		( int,	char **);
void	assemble	( void);
void	read_1line	( void);
symbol	*st_add		( char *, uint);
void	st_init		( void);
int	*eval		( char *);
void	init		( void);
void	init_link	( void);
void	write_obj( char type, int data_i, char *data_s);
void	write_zzz	( char *line);
void	link		( void );
int	decide_reg8	( char *);
int	decide_reg16	( char *);
int	eval_paren	( char *);
char	*break_param	( char *, char);
int	decide_math8	( char *);
int	decide_condition ( char *);
void	write_dec	( int);
void	explain_warning	( FILE *, int);
void	warning		( int);
void	explain_crash	( FILE *, int);
void	crash		( int);




/* 12/08/90:  A few routines were placed in this file because A85.C got too
 * big to edit with the Turbo C IDE editor.
 */

/*********************************************** SEND OUTPUT TO OBJECT FILE */
/* Name:	write_obj( type, data_i, data_s);
 * Started:	08/05/90
 * Updated:	08/27/90
 * Arguments:	type:  character type of object record to write
 *		data_i:  integer data
 *		data_s:  string data
 *
 * Purpose:	Creates an object file record of the specified type.
 */

void	write_obj( char type, int data_i, char *data_s)
{
  switch (toupper(type) ) {
    case OT_1 :			/* byte record, no relocating needed */
      if (passno == 2) {
	fprintf (fp_o, "%c%u\n", type, (data_i & 255) );
	if (ferror( fp_o)) crash(23);		/* error writing object file */
      }
      address++;		/* 1-byte length */
      break;
    case OT_2 :			/* relative word record, to be relocated at link */
      if (abs_ref) {
	write_obj( OT_1, (uint)data_i & 255, NULL);
	write_obj( OT_1, (uint)data_i / 256, NULL);
	abs_ref = FALSE;
	break;
      }
      if (passno == 2) {
	fprintf (fp_o, "%c%u\n", type, data_i );
	if (ferror( fp_o)) crash(23);		/* error writing object file */
      }
      address+=2;		/* 2-byte (word) length */
      break;
    case OT_5 :			/* external reference (2-byte) to be resolved */
      if (passno == 2) {
	fprintf (fp_o, "%c%s\n", type, data_s );
	if (ferror( fp_o)) crash(23);		/* error writing object file */
      }
      address+=2;		/* 2-byte (word) length */
      break;
    case OT_6 :			/* public reference declaration */
      if (passno == 2) {
	fprintf (fp_o, "%c%s\n", type, data_s );
	if (ferror( fp_o)) crash(23);		/* error writing object file */
      }
				/* do not increment address counter */
      break;
    case OT_10 :		/* date record */
      if (passno == 2) {
	fprintf (fp_o, "%c%s\n", type, data_s );
	if (ferror( fp_o)) crash(23);		/* error writing object file */
      }
      break;
    case OT_11 :		/* source filename record */
      if (passno == 2) {
	fprintf (fp_o, "%c%s\n", type, data_s );
	if (ferror( fp_o)) crash(23);		/* error writing object file */
      }
      break;
    case OT_15 :		/* origin specifier */
      if (passno == 2) {
	fprintf( fp_o, "%c%u\n", type, data_i);
	if (ferror( fp_o)) crash(23);		/* error writing object file */
      }
      break;
    case OT_16 :		/* execution point */
    case OT_99 :		/* end of file marker */
      if (passno == 2) {
	fprintf( fp_o, "%c\n", type);
	if (ferror( fp_o)) crash(23);		/* error writing object file */
      }
      break;
    default :
      crash(22);				/* unknown object record type */
      break;
  }
  return;
}








/******************************************** SEND OUTPUT TO TRANSLATE FILE */
/* Name:	write_zzz( char *line);
 * Started:	12/04/90
 * Updated:	12/04/90
 * Arguments:	line:  the line of ascii text to send to the file.
 *
 * Purpose:	Writes one line of translator information to the *.X_INC file.
 *
 * If the file isn't open, translate isn't ON, or passno != 2, then this does
 * nothing but return to the caller.
 */

void	write_zzz	( char *line)
{
	if (fp_z == NULL || passno != 2 || !translate)
	    return;
	fprintf( fp_z, "%s\n", line);
	return;
}








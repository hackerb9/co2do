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

/* I compiled this with Borland's Turbo C v2.01 */

/****************************************************************************************/
/*
 * Author:		Kurt W. Dekker
 * Started:		11/09/99 @ 10:58
 * Updated:		11/10/99
 *				07/03/2004 - removing personal library includes
 * Filename:	BAS100.C
 *
 * Description:	Converts QBASIC programs into M100 BASIC programs.
 *
 * Assumptions:
 *
 *	- labels appear at left edge, colon at end of line, no other code
 *	- labels are never the last line of the program
 *	- one statement per line for now, at least for:
 *		- locate statements
 *		- labels
 *	- THEN statements are followed by a GOTO before the label
 *
 * Issues to convert:
 *
 *	+ catch all label references, change to line numbers
 *		+ restart line numbering at LINENUM_LABEL at labels
 *	+ convert LOCATE x, y statements to PRINT@(y-1)*40+(x),;
 *	- remove all comments (have this be an option?)
 *	- convert chr$() values over (178->255, 248->168, etc.)
 *	- at final write:
 *		- output the label line, in a comment
 *		- remove ALL unquoted whitespace
 *		- prepend line numbers
 *		- append Ctrl-Z to file
 */


/************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


/************************************************************************/
/* _abort.h: */
#define	AB_ESC		0
#define	AB_END		0
#define	AB_NOMEM	1
#define	AB_NOFILE	2
#define	AB_ERROR	3
#define	AB_BADFILE	4
void abortabort( int x)
{
	exit(x);
}
void abortaddstringclue( char *s)
{
	printf( "Clue: %s\n", s);
}

/* _kbint.h: */
#define	ESC		27
int 	getkb( void)
{
int 			c;

#ifdef	KBINT_USE_BIOS
	c = bioskey( 0) & 0xff;
	if (c == 0 || c == 0xe0) {
		if (kbhit()) {
			c = (bioskey( 0) & 0xff) + 256;
		}
	}
#else
	c = getch();
	if (c == 0 || c == 0xe0) {
		if (kbhit()) {
			c = 256 + getch();
		}
	}
#endif
	return	c;
}


/************************************************************************/
#define	LINENUM_FIRST	 100
#define	LINENUM_STEP	  10
#define	LINENUM_LABEL	 100


/************************************************************************/
/* this stores the actual program here... */
int		prog_numlines;
int		*prog_linenums;
char	**prog_strings;
char	**prog_labels;


/************************************************************************/
char	filename_bas[100];
char	filename_100[100];


/************************************************************************/
void	create_filenames( char *argname)
{
	strcpy( filename_bas, argname);

	{char *cptr;
		cptr = strchr( filename_bas, '.');
		if (cptr == 0) {
			strcat( filename_bas, ".bas");
		}
	}

	{char *cptr;
		strcpy( filename_100, filename_bas);

		cptr = strchr( filename_100, '.');
		if (cptr) {
			*cptr = 0;
		}
		strcat( filename_100, ".100");
	}
}


/************************************************************************/
void	free_prog( void)
{
	if (prog_numlines) {
		if (prog_linenums) {
			free( prog_linenums);
			prog_linenums = 0;
		}

		if (prog_strings) {
		int i;

			for (i = 0; i < prog_numlines; i++) {
				if (prog_strings[i]) {
					free( prog_strings[i]);
					prog_strings[i] = 0;
				}
			}
			free( prog_strings);
			prog_strings = 0;
		}

		if (prog_labels) {
		int i;

			for (i = 0; i < prog_numlines; i++) {
				if (prog_labels[i]) {
					free( prog_labels[i]);
					prog_labels[i] = 0;
				}
			}
			free( prog_labels);
			prog_labels = 0;
		}

        prog_numlines = 0;
	}
}


/************************************************************************/
void	load_prog( void)
{
FILE			*fpi;

	free_prog();

	fpi = fopen( filename_bas, "rt");
	if (fpi) {

		{int passno;

			prog_numlines = 0;

			for (passno = 1; passno <= 2; passno++) {
			char tmp[256];
			int currline;

				rewind( fpi);

				currline = 0;

				do {
				char *cptr;

					tmp[0] = 0;
					fgets( tmp, 255, fpi);
					if (tmp[0]) {
						cptr = strchr( tmp, '\n');
						if (cptr) *cptr = 0;


						if (passno == 1) {
							prog_numlines++;
						}
						if (passno == 2) {
							prog_strings[currline] = strdup( tmp);
							if (!prog_strings[currline]) {
								abortaddstringclue( "prog_strings[]");
								abortabort( AB_NOMEM);
							}

							currline++;
						}
					}

				} while( !feof( fpi));

				if (passno == 1) {
					prog_strings = calloc( sizeof( char *), prog_numlines);
					prog_linenums = calloc( sizeof( int), prog_numlines);

					if (!prog_strings || !prog_linenums) {
						abortaddstringclue( "!prog_strings || !prog_linenums");
						abortabort( AB_NOMEM);
					}
				}
			}
		}

		fclose( fpi);
	} else {
		abortaddstringclue( filename_bas);
		abortabort( AB_NOFILE);
	}
}


/************************************************************************/
void	uppercase_unquoted_string( char *s)
{
char			*cptr;
int				inquotes;

	inquotes = 0;
	cptr = s;
	while( *cptr) {
		if (*cptr == '\"') {
			inquotes = !inquotes;
		} else {
			if (inquotes) {
			} else {
				*cptr = toupper( *cptr);
			}
		}
		cptr++;
	}
}


/************************************************************************/
void	uppercase_all_unquoted( void)
{
int				i;

	for (i = 0; i < prog_numlines; i++) {
		uppercase_unquoted_string( prog_strings[i]);
	}
}


/************************************************************************/
void	remove_all_comments( void)
{
int				i, n;
char			quotes[256];
char			*cptr, *cptr1, *cptr2;
int				inquotes;

	for (i = 0; i < prog_numlines; i++) {
		cptr1 = strstr( prog_strings[i], "REM");
		cptr2 = strstr( prog_strings[i], "'");
		if (cptr1 || cptr2) {

			/* figure out what characters are in quotes */
			cptr = prog_strings[i];
			inquotes = 0;
			n = 0;
			while( *cptr) {
				if (*cptr == '\"') {
					inquotes = !inquotes;
				}
				quotes[n++] = inquotes;
				cptr++;
			}

			/* handle REM and :REM */
			if (cptr1) {
				/* back up over preceeding colon? */
				if (cptr1 > prog_strings[i]) {
					if (*(cptr1 - 1) == ':') cptr1--;
				}

				if (!quotes[cptr1 - prog_strings[i]]) {
					*cptr1 = 0;
					continue;
				}
			}

			if (cptr2) {
				if (!quotes[cptr2 - prog_strings[i]]) {
					*cptr2 = 0;
					continue;
				}
			}
		}
	}
}


/************************************************************************/
int		test_isalldigits( char *s)
{
	while( *s) {
		if (*s >= 'A' && *s <= 'Z') return 0;
		switch( *s) {
			case '+' :
			case '-' :
			case '*' :
			case '/' :
			case '^' :
				return 0;
		}
		s++;
	}
	return 1;
}


/************************************************************************/
void	convert_locates( void)
{
int				i;
char			*cptr, *cptr2, *cptr3;
char			tmp[100];

	for (i = 0; i < prog_numlines; i++) {
		cptr = strstr( prog_strings[i], "LOCATE");
		if (cptr) {
			if (strchr( prog_strings[i], ':')) {
				abortaddstringclue( "all LOCATE statements must be appear alone on a line!");
				abortabort( AB_ERROR);
			}

			cptr2 = cptr + 6;
			cptr3 = strchr( cptr2, ',');
			if (cptr3) {
				*cptr3++ = 0;

				if (test_isalldigits(cptr2)) {
				int value;
					if (test_isalldigits(cptr3)) {
						value = (atoi( cptr2) - 1) * 40 + atoi(cptr3);
						sprintf( tmp, "PRINT@%u,;", value);
					} else {
						value = (atoi( cptr2) - 1) * 40;
						sprintf( tmp, "PRINT@%u+%s,;", value, cptr3);
					}
				} else {
					sprintf( tmp, "PRINT@(%s-1)*40+%s,;", cptr2, cptr3);
				}

				free(prog_strings[i]);
				prog_strings[i] = strdup( tmp);
			} else {
				abortaddstringclue( "LOCATE statement without comma (,)");
				abortabort( AB_ERROR);
			}
		}
	}
}


/************************************************************************/
void	convert_language1( void)
{
	convert_locates();
}


/************************************************************************/
void	remove_whitespace_string( char *s)
{
char			*cptr;
int				inquotes;

	inquotes = 0;
	cptr = s;
	while( *cptr) {
		if (*cptr == '\"') {
			inquotes = !inquotes;
		} else {
			if (inquotes) {
			} else {
				if (*cptr == ' ' || *cptr == '\t') {
					strcpy( cptr, cptr + 1);
					cptr--;
				}
			}
		}
		cptr++;
	}
}


/************************************************************************/
void	remove_all_whitespace( void)
{
int				i;

	for (i = 0; i < prog_numlines; i++) {
		remove_whitespace_string( prog_strings[i]);
	}
}


/************************************************************************/
void	cull_blank_lines( void)
{
int				i, j;

	for (i = 0; i < prog_numlines; i++) {
		if (strlen( prog_strings[i]) == 0) {
			free( prog_strings[i]);
			prog_strings[i] = 0;
			for (j = i; j < prog_numlines - 1; j++) {
				prog_strings[j] = prog_strings[j + 1];
				prog_strings[j + 1] = 0;
			}
			prog_numlines--;
			i--;
		}
	}
}


/************************************************************************/
void	generate_labels( void)
{
int				i;
char			*cptr;

	if (prog_labels == 0) {
		prog_labels = calloc( sizeof( char *), prog_numlines);
		if (!prog_labels) {
			abortaddstringclue( "prog_labels[]");
			abortabort( AB_NOMEM);
		}
	}

	for (i = 0; i < prog_numlines; i++) {
		cptr = prog_strings[i] + strlen( prog_strings[i]) - 1;
		if (*cptr == ':') {			/* it's a label! */
			/* copy the label to our label array, zap off the colon */
			prog_labels[i] = strdup(prog_strings[i]);
			if (!prog_labels[i]) {
				abortaddstringclue( "prog_labels[i]");
				abortabort( AB_NOMEM);
			}
			cptr = strchr( prog_labels[i], ':');
			if (cptr) *cptr = 0;

			{char tmp[100];

				/* convert the actual label to a comment... */
				sprintf( tmp, "'%s", prog_strings[i]);

				/* strcpy( tmp, "'");		/* <WIP> uncomment this line to remove labels */

				free( prog_strings[i]);
				prog_strings[i] = strdup( tmp);
				if (!prog_strings[i]) {
					abortaddstringclue( "prog_strings[i] (label to comment)");
					abortabort( AB_NOMEM);
				}
			}
		}
	}
}


/************************************************************************/
void	assign_line_numbers( void)
{
int				i, lineno;

	lineno = LINENUM_FIRST;

	for (i = 0; i < prog_numlines; i++) {
		/* if this is a label line, align the number upwards! */
		if (prog_labels[i]) {
			lineno = LINENUM_LABEL * (lineno / LINENUM_LABEL + 1);
		}

		prog_linenums[i] = lineno;

		lineno += LINENUM_STEP;
	}
}


/************************************************************************/
void	check_and_dereference( int i, int j, char *gotype)
{
char			*cptr, *cptr2;
char			tmp[256];
int				charcount;

	/* i points to the labels[] array (and the linenums[] array) */
	/* j points to the strings[] source code array */

	charcount = 0;
	do {
		cptr = strstr( prog_strings[j] + charcount, gotype);
		if (cptr) {
			cptr += strlen( gotype);

			charcount = cptr - prog_strings[j];

			if (strncmp( cptr, prog_labels[i], strlen( prog_labels[i])) == 0) {
				*cptr = 0;
				cptr2 = cptr + strlen( prog_labels[i]);

				/* fabricate new line, pointing to the line AFTER the label!! */
				sprintf( tmp, "%s%u%s", prog_strings[j], prog_linenums[i + 1], cptr2);

				free( prog_strings[j]);
				prog_strings[j] = strdup( tmp);

				if (!prog_strings[j]) {
					abortaddstringclue( "!prog_strings[j] (line number dereferencing)");
					abortabort( AB_NOMEM);
				}
			}
		}
	} while( cptr);
}


/************************************************************************/
void	convert_labels_to_linenums( void)
{
int				i, j;

	/* spin through all lines with labels on them */
	for (i = 0; i < prog_numlines; i++) {
		if (prog_labels[i]) {
			/* spin through entire program looking for this label */
			for (j = 0; j < prog_numlines; j++) {
				check_and_dereference( i, j, "GOTO");
				check_and_dereference( i, j, "GOSUB");
			}
		}
	}
}


/************************************************************************/
void	convert_chr_strings( void)
{
int				i;
char			*cptr, *cptr2;
char			tmp[256];
int				charcount;
char			*gotype = "CHR$(";
int				orgval, val, n;
static	int		lookup[] =	{
								176, 255,		/* sparse-hatched block */
								177, 255,		/* hatched block */
								178, 255,		/* dense-hatched block */
								248, 168,		/* degrees */
								0, 0
							};

	for (i = 0; i < prog_numlines; i++) {
		charcount = 0;
		do {
			cptr = strstr( prog_strings[i] + charcount, gotype);
			if (cptr) {
				cptr += strlen( gotype);

				charcount = cptr - prog_strings[i];

				orgval =
				val = atoi( cptr);
				n = 0;
				while( lookup[n * 2 + 0]) {
					if (lookup[n * 2 + 0] == val) {
						val = lookup[n * 2 + 1];
						break;
					}
					n++;
				}

				if (val != orgval) {
					*cptr = 0;
					cptr2 = strchr( cptr + 1, ')');
					if (!cptr2) {
						abortaddstringclue( "error converting a CHR$() value");
						abortabort( AB_ERROR);
					}

					/* fabricate new line, with the new value inside it!! */
					sprintf( tmp, "%s%u%s", prog_strings[i], val, cptr2);

					free( prog_strings[i]);
					prog_strings[i] = strdup( tmp);

					if (!prog_strings[i]) {
						abortaddstringclue( "!prog_strings[i] (CHR$() changing)");
						abortabort( AB_NOMEM);
					}
				}
			}
		} while( cptr);
	}
}


/************************************************************************/
void	convert_language2( void)
{
	convert_chr_strings();
}


/************************************************************************/
void	emit_final( void)
{
int				i;
FILE			*fpo;

#if 1
	fpo = fopen( filename_100, "rt");
	if (fpo) {
		fclose( fpo);

		printf( "Warning!  File '%s' exists.  Overwrite? (Y/N):", filename_100);

		{int c;

			do {
				c = getkb();
				if (c == 'n' || c == 'N' || c == ESC) {
					abortabort( AB_ESC);
				}
			} while( c != 'y' && c != 'Y');
		}
	}

	fpo = fopen( filename_100, "wt");
#else
	fpo = stdout;
#endif

	if (fpo) {
		for (i = 0; i < prog_numlines; i++) {
			fprintf( fpo, "%u%s\n", prog_linenums[i], prog_strings[i]);
		}

		fputc( 26, fpo);

		fclose( fpo);
	} else {
		abortaddstringclue( filename_100);
		abortabort( AB_BADFILE);
	}
}


/************************************************************************/
void	show_usage_quit( int exitcode)
{
	printf( "Usage: BAS100 QBASFILE[.BAS]\n");
	printf( "Converts QBASIC .BAS files into Model 100 files.\n");
	exit(exitcode);
}


/************************************************************************/
int		main( int argc, char **argv)
{
	if (argc == 2) {
		create_filenames( argv[1]);

		load_prog();

		uppercase_all_unquoted();

		remove_all_comments();

		convert_language1();

		remove_all_whitespace();

		cull_blank_lines();

		generate_labels();

		assign_line_numbers();

		convert_labels_to_linenums();

		convert_language2();

		clrscr();

		printf( "Total of %u lines.\n\n", prog_numlines);

		emit_final();
	} else {
		show_usage_quit(-1);
	}
}

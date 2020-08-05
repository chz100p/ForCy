//
//	ForCy - Super Light-weight Language
//
//	(c)2004 Osamu Tamura @ Recursion Co., Ltd.
//				All rights reserved.
//
//
//	compiler.c:	compile to intermediate code
//

#include <stdio.h>
#include "forcy.h"
#include "lint.h"

enum {
	LINT_MSG_LOOP = 0,
	LINT_MSG_BLOCK,
	LINT_MSG_IFELSE,
	LINT_MSG_SWOF
};

static int		lint_return( int *total );
static int		lint_mark( void );
static int		lint_compare( int *n );
static void		lint_close( void );
static void		lint_clear( void );
static void		lint_errmsg( int errid );


static const int	sysStack[]	= {
	0, 0, 0, 0, 0, -1, -1, -1, -1, -1, -1, 0, -1, 0, 0, 0,
	-1, -2, -1, 0, 1, 1, 0, -2,
	0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -1, 0,
	-1, -1, -1, -1, -1, 0, -1, -1, 0, -1, -1, 1,
	1, 1,
	1, 1, -1, 0, -1, -1,
	0, -2, 0, -2, 0, -2, -1, 0, 1, 1
};

static const char	*errstr[]	= {
	"?stack level is changed in if/for/do block.",
	"!stack levels are not balanced in block.",
	"!stack levels are not matched between ifelse blocks.",
	"!stack levels are not equal in switch/of phrase."
};


static int		lv, cptr, sptr, lptr, rptr, wptr, line;
static int		pLP[LINT_STMAX], pRP[LINT_STMAX], pMark[LINT_STMAX], bReturn[LINT_STMAX];
static char		list[LINT_WDMAX];
static int		updown[LINT_WDMAX], userStack[LINT_IDMAX];



void lint_init( int level )
{

	lv		= level;
	cptr	=
	sptr	=
	lptr	=
	rptr	=
	wptr	=
	line	= 0;
}


void lint_char( int c )
{

	if( c&0xff00 )
		list[cptr++]	= (char)( c >> 8 );
	list[cptr++]	= (char)( c & 0xff );

	if( c==0x0a )
		line++;
}


void lint_updown( int n )
{

	updown[sptr++]	= n;

	if( lv>1 )
		fprintf( stdout, "(%d)", n );
}


void lint_register( void )
{
	int			i, sum;


#if 0
	printf( "\n updown:" );
	for( i=0; i<sptr; i++ )
		printf( " %d", updown[i] );
	printf( "\n\t{ %d,  } %d\n", lptr, rptr );
#endif

	sum	= 0;
	for( i=0; i<sptr; i++ )
		sum	+= updown[i];
	userStack[wptr++]	= sum;
	sptr	= 0;

	if( lv>0 )
		printf( " (%d)\n", sum );
//	printf( " (%d) - #%d\n", sum, cptr );

	cptr	= 0;
}


void lint_parse( int id )
{
	int		s, s1, s2, t, t1, t2;


	if( id!=iLP && id!=iRP )
		lint_updown( id<iEND? sysStack[id-iSTR_]:userStack[id-iEND] );

	switch( id ) {
		case iLP:
					pLP[lptr]	= pMark[lptr]	= sptr;
					bReturn[lptr]	= 0;
					lptr++;
					break;
		case iRP:
					pRP[rptr++]	= sptr;
					break;

		case iRTN:
					bReturn[lptr-1]	= 1;
					break;
		case iDO:
		case iFOR:
		case iIF:
					s	= lint_return( &t );
					lint_updown( s );

					if( t )
						lint_errmsg( LINT_MSG_LOOP );
					break;
		case iELS:
					s1	= lint_return( &t1 );
					s2	= lint_return( &t2 );
					lint_updown( s1 );

					if( s1!=t1 || s2!=t2 )
						lint_errmsg( LINT_MSG_BLOCK );
					if( s1!=s2 )
						lint_errmsg( LINT_MSG_IFELSE );
					break;
		case iCAS:
					s	= lint_return( &t );
					lint_updown( s );
		case iBRK:
		case iWHL:
		case iCNT:
					lint_mark();
					break;
		case iSWT:
					lint_close();
		case iOF:
					if( lint_compare( &s ) )
						lint_updown( s );
					else
						lint_errmsg( LINT_MSG_SWOF );

		case iINTR:
					lint_clear();
					break;
	}
}


static int lint_return( int *total )
{
	int		i, end, sum;


	lint_close();

	*total	= 0;
	if( bReturn[lptr-1] )
		sum	= 0;
	else {
		//	keep return value
		sum	= updown[pLP[lptr-1]];

		//	count total
		for( i=pLP[lptr-1],end=pRP[rptr-1]; i<end; i++ )
			*total	+= updown[i];
	}

	//	dispose block
	lint_clear();

	return sum;
}


static int lint_mark( void )
{
	int		i, start, sum;


#if 0
	printf( "\n A:[" );
	for( i=pLP[lptr-1]; i<sptr; i++ )
		printf( " %d", updown[i] );
	printf( " ]\n" );
#endif

	sum	= 0;
	for( i=start=pMark[lptr-1]; i<sptr; i++ )
		sum	+= updown[i];
	updown[start++]	= sum;
	pMark[lptr-1]	= sptr	= start;

#if 0
	printf( " B:[" );
	for( i=pLP[lptr-1]; i<sptr; i++ )
		printf( " %d", updown[i] );
	printf( " ]\n" );
#endif

	return sum;
}


static int lint_compare( int *n )
{
	int		i, end;


	i	= pLP[lptr-1];
	*n	= updown[i];
	for( end=pRP[rptr-1]; i<end; i++ )
		if( *n!=updown[i] )
			return 0;

	return 1;
}


static void lint_close( void )
{
	int		i, j, start, end, sum;


#if 0
	printf( "\n 1:[" );
	for( i=start=pLP[lptr-1],end=pRP[rptr-1]; i<end; i++ )
		printf( " %d", updown[i] );
	printf( " ]\n" );
#endif

	//	close block
	sum	= 0;
	for( i=start=pMark[lptr-1],end=pRP[rptr-1]; i<end; )
		sum	+= updown[i++];
	updown[start++]	= sum;

	for( i=start,j=pRP[rptr-1]; j<sptr; )
		updown[i++]	= updown[j++];
	pRP[rptr-1]	= start;
	sptr	= i;

#if 0
	printf( " 2:[" );
	for( i=start=pLP[lptr-1],end=pRP[rptr-1]; i<end; i++ )
		printf( " %d", updown[i] );
	printf( " ]\n\n" );
#endif
}


static void lint_clear( void )
{
	int		i, j;


	for( i=pLP[lptr-1],j=pRP[rptr-1]; j<sptr; )
		updown[i++]	= updown[j++];
	sptr	= i;
	lptr--;
	rptr--;
}


static void lint_errmsg( int errid )
{
	int		i;


	if( !lv )
		return;

	fputc( '\n', stdout );
	for( i=0; i<cptr; i++ )
		fputc( list[i], stdout );
	fputc( '\n', stdout );

	fprintf( stdout, "\n\tline:%d  %s: %s\n\n",
			line,
			*errstr[errid]=='?'? "warning":"error",
			errstr[errid]+1 );
}


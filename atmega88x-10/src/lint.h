//
//	ForCy - Simplified Language for Embedded System
//
//	(c)2004 Osamu Tamura @ Recursion Co., Ltd.
//				All rights reserved.
//
//
//	lint.h:	header
//

#define	LINT_WDMAX	4092
#define	LINT_IDMAX	256
#define	LINT_STMAX	32

//	prototypes
extern void		lint_init( int level );
extern void		lint_char( int c );
extern void		lint_updown( int n );
extern void		lint_parse( int id );
extern void		lint_register( void );



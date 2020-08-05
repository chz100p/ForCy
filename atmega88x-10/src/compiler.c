//
//	ForCy - Super Light-weight Language
//
//	(c)2004 Osamu Tamura @ Recursion Co., Ltd.
//				All rights reserved.
//
//
//	compiler.c:	compile to intermediate code
//

#include <ctype.h>
//#include <mbctype.h>
#include <stdio.h>
#include <stdlib.h>
#include "forcy.h"
#include "lint.h"


//	system defined words
static const char	*sysdic	= "\
@s { } do for break while continue if ifelse case switch of self return interrupt \
. .. nip swap dup over @ = \
== != < > <= >= ++ -- + - * / % div \
<< >> & | ^ ~ && || ! min max rand \
clk sec \
@c? @c %c %s %d %x \
sfr =sfr ep =ep ed =ed _epg _strf _rs _ds ";


//	local prototypes
static unsigned short	lex_get( unsigned short *token, FILE *fp );

static unsigned short	dic_add( unsigned short type, unsigned short *key, unsigned short offset );
static unsigned short	dic_find( unsigned short *key, unsigned short *id );
static unsigned short	dic_search_s( char *list, unsigned short *key, unsigned short *id );
static unsigned short	dic_search_u( unsigned short *list, unsigned short *key, unsigned short *id );

static unsigned short	dic_count, dic_uword;
static unsigned short	dic_entry[DIC_MAX];
static unsigned short	*dic_last, dic_name[DIC_SIZE];

static unsigned short	_atoi( unsigned short *ptr );
static unsigned short	_atoh( unsigned short *ptr );
static void				_puts( unsigned short *str );


int compiler( unsigned char *code, FILE *fp, int debug )
{
	unsigned short		i, cptr, cstart, vptr, len, id, eq, err;
	unsigned short		iptr, istack[16];
	unsigned short		*tptr, token[256];


	lint_init( debug );

	//	init dictionary
	dic_last	= dic_name;
	dic_count	= 0;
	dic_uword	= 0;

	//	header offset
	cptr		= cstart	= 8;
	vptr		= 0;

	//	compile
	err		= 0xff;
	iptr	= 0;
	while( err==0xff && (len=lex_get( token, fp ))!=0 ) {

#if 1
		if( debug>1 ) {
			putchar( ' ' );
			_puts( token );
		}
#endif
		//	parse
		switch( *token ) {
			case ':':	//	register defined word
						code[cptr++]	= iRET;
						err	= dic_add( iWRD, token+1, cstart );
						if( err<iEND ) {
							cptr	= cstart;		//	cancel current word
							err	= 0xff;
						}
						else
							cstart	= cptr;			//	keep next entry

						putchar( ' ' );
						_puts( token+1 );

						lint_register();
						break;
			case '\'':
						id	= *(token+1);
						if( id & 0xf0 ) {
							code[cptr++]	= iNUM;
							code[cptr++]	= (unsigned char)id;
						}
						else
							//	shortened form
							code[cptr++]	= (unsigned char)(sNUM|id);

						lint_updown( 1 );
						break;
			case ';':
						err	= dic_add( iVAR, token+1, vptr );
						vptr++;
						break;
			case '[':
						for( tptr=token+1; *tptr!=']'; tptr++ )
						;
						tptr++;
						err	= dic_add( iARY, tptr, vptr );
						vptr	= vptr + _atoi( token+1 );
						break;
			case '"':
						code[cptr++]	= iSTR;
						i	= cptr++;
						for( tptr=token+1; len; len-- ) {
							if( *tptr>0xff )
								code[cptr++]	= (unsigned char)( *tptr >> 8 );
							code[cptr++]	= (unsigned char)*tptr++;
						}
						code[i]	= (unsigned char)( cptr - i - 1 );

						lint_updown( 0 );
						break;
			default:
						eq	= *token=='='? 1:0;
						switch( dic_find( token, &id ) ) {
							case iWRD:
										switch( id ) {
											case iLP:
														code[cptr++]	= (unsigned char)id;
														istack[iptr++]	= cptr++;
														break;
											case iRP:
														code[cptr++]	= iRET;
														i	= istack[--iptr];
														len	= cptr - i - 1;		//	{ } length
														if( len>=256 )
															err	= 0xfc;
														else if( len>=32 )
															code[i]	= (unsigned char)len;
														else {
															//	shortened form
															code[i-1]	= (unsigned char)(sLP|len);
															for( cptr--; i<cptr; i++ )
																code[i]	= code[i+1];
														}
														break;
											case iSLF:
														code[cptr++]	= (unsigned char)(iEND+dic_uword);
														break;
											case iDO:	//	optimize speed
														if( code[cptr-1]==iRET )
															code[cptr-1]	= iDO_;
											default:
														code[cptr++]	= (unsigned char)id;
										}

										lint_parse( id );
										break;
							case iVAR:
										if( id & 0xf0 ) {
											code[cptr++]	= (unsigned char)(iVAR+eq);
											code[cptr++]	= (unsigned char)id;
										}
										else
											//	shortened form
											code[cptr++]	= (unsigned char)((sVAR+(eq<<4))|id);

										lint_updown( eq? -1:1 );
										break;
							case iARY:
										if( id & 0xf0 ) {
											code[cptr++]	= (unsigned char)(iARY+eq);
											code[cptr++]	= (unsigned char)id;
										}
										else
											//	shortened form
											code[cptr++]	= (unsigned char)((sARY+(eq<<4))|id);

										lint_updown( eq? -2:0 );
										break;
							default:
										//	number
										if( !isdigit( *token ) ) {
											err	= 0xfe;
											break;
										}
										id	= _atoi( token );
										if( id & 0xff00 ) {
											code[cptr++]	= iNUM2;
											code[cptr++]	= (unsigned char)(id>>8);
											code[cptr++]	= (unsigned char)id;
										}
										else if( id & 0xf0 ) {
											code[cptr++]	= iNUM;
											code[cptr++]	= (unsigned char)id;
										}
										else
											//	shortened form
											code[cptr++]	= (unsigned char)(sNUM|id);

										lint_updown( 1 );
						}
		}
	}

	if( err!=0xff ) {
		printf( "\n error: \"" );
		_puts( token );
		switch( err ) {
			case 0xfc:	puts( "{ } length exceeds 255." );	break;
			case 0xfe:	puts( "\" is not defined." );		break;
			default:	puts( "\" is already defined." );
		}
		return 0;
	}



	{
		int		code2, data2;

		code[cptr-1]	= iSLF;		//	terminate

		code2	= cptr >= 256;
		data2	= vptr >= 256;

		//	set header
		code[0]	= 0xfc;
		code[1]	= (code2? 0x10:0)|(data2? 1:0);

		//	set word entry table
		code[4]	= (unsigned char)(cptr>>8);
		code[5]	= (unsigned char)cptr;
		for( i=0; i<dic_count; i++ ) {
			if( !(dic_entry[i] & 0x8000) ) {
				if( code2 )
					code[cptr++]	= (unsigned char)(dic_entry[i]>>8);
				code[cptr++]	= (unsigned char)dic_entry[i];
			}
		}
		//	set data entry table
		code[6]	= (unsigned char)(cptr>>8);
		code[7]	= (unsigned char)cptr;
		for( i=0; i<dic_count; i++ ) {
			if( dic_entry[i] & 0x8000 ) {
				if( data2 )
					code[cptr++]	= (unsigned char)((dic_entry[i]>>8)&0x7f);
				code[cptr++]	= (unsigned char)dic_entry[i];
			}
		}
		//	stack offset
		if( data2 )
			code[cptr++]	= (unsigned char)(vptr>>8);
		code[cptr++]	= (unsigned char)vptr;

		//	total size	
		code[2]	= (unsigned char)(cptr>>8);
		code[3]	= (unsigned char)cptr;

//		printf( "\tdictionary count:%d, size:%d\n", dic_count, (int)(dic_last-dic_name) );

		return (int)cptr;
	}
}

//
//	Dictionary Manager
//		dic_add:	append new key & type(word,variable,array) to user dictionary
//		dic_find:	find key type(word,variable,array, or number) & id
//		dic_search:	search registered key type and id from dictionary
//		
static unsigned short dic_add( unsigned short type, unsigned short *key, unsigned short offset )
{
	unsigned short	id;


	//	defined previously ?
	if( dic_find( key, &id )!=0xff )	//	(err)
		return id;

	//	add key to user dictionary
	while( *key )
		*dic_last++	= *key++;
	*dic_last++	= type | 0x10;
	*dic_last	= 0;

	//	add entry address
	if( type==iWRD )
		dic_uword++;
	else
		offset	|= 0x8000;
	dic_entry[dic_count++]	= offset;

	return 0xff;
}

static unsigned short dic_find( unsigned short *key, unsigned short *id )
{
	unsigned short	type, xid;


	//	search system dictionary
	type	= dic_search_s( (char *)sysdic, key, &xid );
	if( type!=0xff ) {
		*id	= (unsigned short)( xid + iSTR_ );
		return type;
	}

	if( *key=='=' )
		key++;

	//	search user dictionary
	type	= dic_search_u( dic_name, key, &xid );
	if( type!=0xff ) {
		*id	= xid;
		if( type==iWRD )
			*id	= (unsigned short)( xid + iEND );
		return type;
	}

	return 0xff;
}

static unsigned short dic_search_s( char *list, unsigned short *key, unsigned short *id )
{
	char			*ptr;
	unsigned short	*kptr, wc;


	//	search dictionary
	wc	= 0;
	for( ptr=list; *ptr; ptr++ ) {
		for( kptr=key; *kptr==(unsigned short)*ptr; kptr++,ptr++ )
		;
		if( *kptr==0 && *ptr<=' ' )		//	matched
			break;
		while( *ptr>' ' )
			ptr++;
		wc++;
	}
	if( *ptr ) {
		*id	= wc;
		return 0;
	}

	return 0xff;
}

static unsigned short dic_search_u( unsigned short *list, unsigned short *key, unsigned short *id )
{
	unsigned short	*ptr, *kptr, wc, vc, c;


	//	search dictionary
	wc	= vc	= 0;
	for( ptr=list; *ptr; ptr++ ) {
		for( kptr=key; *kptr==(unsigned short)*ptr; kptr++,ptr++ )
		;
		if( *kptr==0 && *ptr<=' ' )		//	matched
			break;
		while( *ptr>' ' )
			ptr++;
		if( *ptr & 0x0f )	//	item type
			vc++;
		else
			wc++;
	}
	if( *ptr ) {
		c	= *ptr & 0x0f;
		*id	= c? vc:wc;
		return c;
	}

	return 0xff;
}

//
//	Lexical Analyzer
//		lex_get:	obtain token from the input stream
//
static unsigned short lex_get( unsigned short *token, FILE *fp )
{
	unsigned short		*ptr;
	int					prev, c, state;


	state	= 0;
	prev	= 0;
	ptr		= token;
	for( ;; ) {

		c	= getc( fp );
		if( c==EOF || c==0x1b )
			break;

		//if( _ismbblead(c) )
		//	c	= (c << 8) | getc( fp );
		//////
		// UTF-8
		if((c&0x80)==0x00){
		}else if((c&0xe0)==0xc0){
		  int c1;
		  c1 = getc( fp );
		  if((c1&0xc0)!=0x80)
		    break;
		  c = ((c&0x1f)<<6)|(c1&0x3f);
		}else if((c&0xf0)==0xe0){
		  int c1,c2;
		  c1 = getc( fp );
		  if((c1&0xc0)!=0x80)
		    break;
		  c2 = getc( fp );
		  if((c2&0xc0)!=0x80)
		    break;
		  c = ((c&0x0f)<<12)|((c1&0x3f)<<6)|(c2&0x3f);
		}else if((c&0xf8)==0xf0){
		  int c1,c2,c3;
		  c1 = getc( fp );
		  if((c1&0xc0)!=0x80)
		    break;
		  c2 = getc( fp );
		  if((c2&0xc0)!=0x80)
		    break;
		  c3 = getc( fp );
		  if((c3&0xc0)!=0x80)
		    break;
		  c = ((c&0x07)<<18)|((c1&0x3f)<<12)|((c2&0x3f)<<6)|(c3&0x3f);
		}else{
		  break;
		}

		lint_char( c );

		*ptr	= (unsigned short)c;

		switch( state ) {
			case 0:
					switch( c ) {
						case '/':
						case '*':
									if( prev=='/' ) {
										prev	= 0;
										state	= c=='*'? 1:2;
										ptr--;
									}
									else {
										prev	= c;
										ptr++;
									}
									break;
						case '\'':
						case '"':
									if( ptr==token ) {
										prev	= c;
										state	= 3;
									}
									ptr++;
									break;
						default:	//	terminater
									if( c<=0x20 ) {
										if( ptr>token ) {
											if( *(ptr-1)==',' ) {
												prev	= 0;
												ptr		= token;
											}
											else
												state	= 9;
										}
									}
									else
										ptr++;
					}
					break;
			case 1:		//	comment c
					if( prev=='*' && c=='/' )
						state	= 0;
					else
						prev	= c;
					break;
			case 2:		//	comment c++
					if( c=='\r' || c=='\n' )
						state	= 0;
					break;

			case 3:		//	constant
					if( c=='\\' )
						state++;
					else if( c==prev )
						state	= 9;
					else
						ptr++;
					break;
			case 4:		//	escape sequence
					if( c=='x' )
						state++;
					else {
						const char	*k = "abfnrtv", *m = "\a\b\f\n\r\t\v";

						for( ; *k && *k!=c; k++,m++ )
						;
						if( *k )
							*ptr	= (unsigned short)*m;
						ptr++;
						state	= 3;
					}
					break;
			case 5:		//	hex1
					ptr++;
					state++;
					break;
			case 6:		//	hex2
					*(ptr+1)	= 0;
					ptr--;
					*ptr	= _atoh( ptr ); ptr++; //*ptr++	= _atoh( ptr );
					state	= 3;
					break;
		
		}

		if( state>6 )
			break;
	}

	*ptr	= 0;

	return (unsigned short)( ptr - token );
}


//---------------------------------------------------
//	Utility Routines
//		substitute standard library
//
static unsigned short _atoi( unsigned short *ptr )
{

	if( *ptr=='0' && *(ptr+1)=='x' )
		return _atoh( ptr+2 );
	else {
		unsigned short	n = 0;

		while( isdigit( (int)*ptr ) )
			n	= ( ((n<<2)+n)<<1 ) + *ptr++ - '0';
		return n;
	}
}

static unsigned short _atoh( unsigned short *ptr )
{
	unsigned short	n, c;


	n	= 0;
	while( isxdigit( (int)*ptr ) ) {
		c	= *ptr++;
		if( c & 0x40 )
			c	+= 9;
		n	= ( n << 4 ) + ( c & 0x0f );
	}
	return n;
}

static void _puts( unsigned short *str )
{

	while( *str ) {
		if( *str>0xff )
			putchar( (int)(*str >> 8) );
		putchar( (int)*str++ );
	}
}


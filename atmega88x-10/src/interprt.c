//
//	ForCy - Super Light-weight Language
//
//	(c)2004 Osamu Tamura @ Recursion Co., Ltd.
//				All rights reserved.
//
//
//	interprt.c:	interpret forcy intermediate code
//

//#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "forcy.h"

#define	DEBUG			1


#define	RTNFLAG			0x8000


size_t			epsiz;
unsigned char	progmem[PROG_SIZE];
unsigned char	datamem[DATA_SIZE];


static unsigned short	offset( unsigned char	*table, unsigned char index, int wsize );
static void				_puts( const char *str, int stdio );

static unsigned short	stack[MEM_SIZE];

static unsigned short	epadr;
static unsigned char	epuse[4], epbuf[4];


int interpreter( unsigned char *code, int stdio )
{
	unsigned char		i, c;
	unsigned short		*dp, *rp;
	unsigned short		up, vp;
	unsigned char		*upt, *vpt;
	int					code2, data2;
	unsigned short		t, tp, bp, cp, np, strp, intr, strp2;
	int					ssz = 0;
	clock_t				clk, sec;


	//	prase header
	if( code[0]!=0xfc )
		return 0;

	epadr	= 0;
	for( epsiz=0; epsiz<4; epsiz++ ) {
		epuse[epsiz]	= 0;
		epbuf[epsiz]	= 0xff;
	}
	for( epsiz=0; epsiz<PROG_SIZE; epsiz++ )
		progmem[epsiz]	= 0xff;
	epsiz	= 0;

	for( t=0; t<DATA_SIZE; t++ )
		datamem[t]	= 0xff;

	intr	= 0;
	strp	= strp2	= 0;
	srand( (unsigned int)time( NULL ) );
	clk	= sec	= 0;


	code2	= code[1] & 0x10;
	data2	= code[1] & 1;

	tp	= (code[2]<<8) | code[3];
	bp	= code[tp-1];
	if( data2 )
		bp	|= (code[tp-2]<<8);
	dp	= stack + bp;
	up	= (code[4]<<8) | code[5];
	vp	= (code[6]<<8) | code[7];
	cp	= code[vp-1];
	if( code2 )
		cp	|= (code[vp-2]<<8);

	upt	= code + up;
	vpt	= code + vp;

	rp	= stack + MEM_SIZE;


	for( ;; ) {
		if( intr && !strp2 ) {
			int			ix;
			clock_t		now;

			now	= clock() / (CLOCKS_PER_SEC/100);
			if( now!=clk ) {
				ix	= 0;
				clk	= now;
				now	/= 100;
				if( now!=sec ) {
					ix++;
					sec	= now;
				}

				np	= code[intr+ix];
				if( np<sNUM ) {
					strp2	= strp;
					*--rp	= cp | RTNFLAG;
					cp	= offset( upt, (unsigned char)(np - iEND), code2 );
				}
			}
		}

		i	= code[cp++];
		if( i<iEND ) {
			//	system words
			switch( i ) {
				case iRTN:
							while( !(*rp & RTNFLAG) )
								rp++;
				case iRET:
							cp	= *rp++ & (RTNFLAG-1);
							if( strp2 ) {
								strp	= strp2;
								strp2	= 0;
							}
							break;
				case iSLF:					//	end of main
							return ssz;

				case iNUM:
							*dp++	= code[cp++];
							break;
				case iNUM2:
							*dp		= code[cp++]<<8;
							*dp	= *dp + code[cp++]; dp++; //*dp++	= *dp + code[cp++];
							break;
				case iVAR:
							*dp++	= stack[ offset( vpt, code[cp++], data2 ) ];
							break;
				case iVAR_:
							stack[ offset( vpt, code[cp++], data2 ) ]	= *--dp;
							break;
				case iARY:
							dp--;
							*dp	= stack[ offset( vpt, code[cp++], data2 ) + *dp ]; dp++; //*dp++	= stack[ offset( vpt, code[cp++], data2 ) + *dp ];
							break;
				case iARY_:
							t	= *--dp;
							stack[ offset( vpt, code[cp++], data2 ) + t ]	= *--dp;
							break;
				case iSTR:
							c	= code[cp++];
							strp	= cp;
							cp	+= c + 0;
							break;
				case iSTR_:
							dp--;
							*dp	= code[ strp + *dp ]; dp++; //*dp++	= code[ strp + *dp ];
							break;

				case iLP:
							c	= code[cp++];
							*--rp	= cp;
							cp	+= c + 0;
							break;
				case iFOR:
							if( *(dp-1)==*(dp-2) ) {
								rp++;
								break;
							}
				case iDO:
							*--rp	= cp - 1;
				case iDO_:
							cp	= *(rp+1);
							break;
				case iBRK:
							if( *--dp ) {
								cp	= *rp++ + 1;
								rp++;
							}
							break;
				case iWHL:
							if( !*--dp ) {
								cp	= *rp++ + 1;
								rp++;
							}
							break;
				case iCNT:
							if( *--dp )
								cp	= *rp++;
							break;
				case iIF:
							if( !*--dp ) {
								rp++;
								break;
							}
				case iSWT:
							np	= *rp++;
							*--rp	= cp;
							cp	= np;
							break;
				case iELS:
							if( *--dp ) {
								rp++;
								np	= *rp++;
							}
							else {
								np	= *rp++;
								rp++;
							}
							*--rp	= cp;
							cp	= np;
							break;
				case iCAS:
							dp--;
							if( *dp==*(dp-1) )
								cp	= *rp++;
							else
								rp++;
							break;
				case iOF:
							np	= code[ *rp++ + *--dp ];
							*--rp	= cp | RTNFLAG;
							cp	= offset( upt, (unsigned char)(np - iEND), code2 );
							break;
				case iINTR:
							intr	= *rp++;		//	keep interrupt vector table
							break;

				case iDRP:	dp--;						break;
				case i2DRP:	dp	-= 2;					break;
				case iNIP:	--dp; *(dp-1)	= *dp;			break;
				case iSWP:
							dp-=2;
							t	= *dp;
							*dp	= *(dp+1); dp++; //*dp++	= *(dp+1);
							*dp++	= t;
							break;
				case iDUP:	*dp	= *(dp-1); dp++; /* *dp++	= *(dp-1); */			break;
				case iOVR:	*dp	= *(dp-2); dp++; /* *dp++	= *(dp-2); */			break;
				case iPICK:
							t		= *--dp + 1;
							*dp	= *(dp-t); dp++; //*dp++	= *(dp-t);
							break;
				case iPOKE:
							t		= *--dp + 1;
							--dp; *(dp-t)	= *dp;
							break;

				case iEQU:	dp--;	*dp	= *(dp-1)==*dp? 1:0; dp++;	break;
				case iNEQ:	dp--;	*dp	= *(dp-1)!=*dp? 1:0; dp++;	break;
				case iLT:	dp--;	*dp	= *(dp-1)<*dp? 1:0; dp++;		break;
				case iGT:	dp--;	*dp	= *(dp-1)>*dp? 1:0; dp++;		break;
				case iLE:	dp--;	*dp	= *(dp-1)<=*dp? 1:0; dp++;	break;
				case iGE:	dp--;	*dp	= *(dp-1)>=*dp? 1:0; dp++;	break;

				case iINC:	dp--;	*dp	= *dp + 1; dp++;				break;
				case iDEC:	dp--;	*dp	= *dp - 1; dp++;				break;

				case iADD:	dp-=2;	*dp	= *dp + *(dp+1); dp++;		break;
				case iSUB:	dp-=2;	*dp	= *dp - *(dp+1); dp++;		break;
				case iMUL:	dp-=2;	*dp	= *dp * *(dp+1); dp++;		break;
				case iDIV:	dp-=2;	*dp	= *dp / *(dp+1); dp++;		break;
				case iMOD:	dp-=2;	*dp	= *dp % *(dp+1); dp++;		break;
				case iDVMD:	dp-=2;	t		= *dp % *(dp+1);
									*dp	= *dp / *(dp+1); dp++;
									*dp++	= t;					break;

				case iLSFT:	dp-=2;	*dp	= *dp << *(dp+1); dp++;		break;
				case iRSFT:	dp-=2;	*dp	= *dp >> *(dp+1); dp++;		break;

				case iAND:	dp-=2;	*dp	= *dp & *(dp+1); dp++;		break;
				case iOR:
				case iLOR:	dp-=2;	*dp	= *dp | *(dp+1); dp++;		break;
				case iXOR:	dp-=2;	*dp	= *dp ^ *(dp+1); dp++;		break;
				case iCMP:	dp--;	*dp	= ~*dp; dp++;					break;
				case iLAND:	dp-=2;	*dp	= (*dp && *(dp+1))? 1:0; dp++;	break;
				case iNOT:	dp--;	*dp	= *dp? 0:1; dp++;				break;
				case iMIN:	dp--;	if( *dp<*(dp-1) )
										*(dp-1)	= *dp;
									break;
				case iMAX:	dp--;	if( *dp>*(dp-1) )
										*(dp-1)	= *dp;
									break;
				case iRND:	*dp++	= (unsigned short)rand();		break;

				case iCLK:
							*dp++	= (unsigned short)( clock() / (CLOCKS_PER_SEC/100) );
							break;
				case iSEC:
							*dp++	= (unsigned short)( clock() / CLOCKS_PER_SEC );
							break;

				//	stdio / console routine
				case iKEY:
							*dp++	= (unsigned short)( stdio? 0:_kbhit() );
							break;
				case iGETC:
							*dp++	= (unsigned short)( ( stdio? getchar():_getch() ) & 0xff );
							break;
				case iPUTC:
							t	= *--dp;
							if( t>0xff ) {
								if( stdio )
									putchar( t>>8 );
								else
									_putch( t>>8 );
							}
							if( stdio )
								putchar( t );
							else
								_putch( t );
							break;
				case iPUTS:
							_puts( (char *)(code+strp), stdio );
							break;
				case iPUTN:
							{
								char	buf[8];

								sprintf( buf, "%d", *--dp );
								_puts( buf, stdio );
							}
							break;
				case iPUTH:
							{
								char	buf[8];

								sprintf( buf, "%x", *--dp );
								_puts( buf, stdio );
							}
							break;

				case iSFR:
				  			--dp; *dp	= stack[ *dp ]; dp++;		//	provisional
							break;
				case iSFR_:
							t	= *--dp;					//	provisional
							stack[ t ]	= *--dp;
							break;

				case iEP:
							dp--;
							*dp	= (unsigned short)progmem[ *dp ]; dp++;
							break;
				case iEP_:
							t	= *--dp;
							progmem[ t ]	&= (unsigned char)*--dp;
							if( epsiz<t )
								epsiz	= t;
							break;
				case iED:
							dp--;
							*dp	= (unsigned short)datamem[ *dp ]; dp++;
							break;

				case iED_:
							t	= *--dp;
							datamem[ t ]	= (unsigned char)*--dp;
							break;

				case iEPG:
							interpreter( progmem+*--dp, 1 );
							break;

				case iSTRF:
							{
								char			*ptr;
								unsigned short	*kptr, *key;
								unsigned int	cnt;

								//	search dictionary
								key	= stack + 1 + *--dp;
								cnt	= 0;
								ptr	= (char *)(code+strp);
								for( ; *ptr; ptr++,cnt++ ) {
									for( kptr=key; *kptr==*ptr; kptr++,ptr++ )
									;
									if( *kptr==0 && *ptr<=' ' )		//	matched
										break;
									while( *ptr>' ' )
										ptr++;
								}
								*dp++	= (unsigned short)( *ptr? cnt:0xff );
							}
							break;

				case iRS:
							*dp++	= (unsigned short)( MEM_SIZE - ( rp - stack ) );
							break;
				case iDS:
							*dp	= (unsigned short)( dp - stack - bp ); dp++;
							break;

			}
		}
		else if( i < sNUM ) {
			//	user words
			if( code[cp]==iRET ) {
				do
					cp	= *rp++ & (RTNFLAG-1);
				while( code[cp]==iRET );
				--rp;
			}
			else
				*--rp	= cp | RTNFLAG;
			cp	= offset( upt, (unsigned char)(i - iEND), code2 );
		}
		else {
			//	short cut
			unsigned char		j = i & 0x0f;

			switch( i & 0xf0 ) {
				case sNUM:
							*dp++	= j;
							break;
				case sVAR:
							*dp++	= stack[ offset( vpt, j, data2 ) ];
							break;
				case sVAR_:
							stack[ offset( vpt, j, data2 ) ]	= *--dp;
							break;
				case sARY:
							dp--;
							*dp	= stack[ offset( vpt, j, data2 ) + *dp ]; dp++;
							break;
				case sARY_:
							t	= *--dp;
							stack[ offset( vpt, j, data2 ) + t ]	= *--dp;
							break;
				case sLP:
				case sLP_:
							*--rp	= cp;
							cp	+= i & 0x1f;
							break;
			}
		}

#if DEBUG
		{
			int			sz;

			sz	= MEM_SIZE - bp + (dp -rp);
			if( ssz < sz )
				ssz = sz;
		}
#endif
	}
}


static unsigned short offset( unsigned char	*table, unsigned char index, int wsize )
{

	if( wsize ) {
		table	+= index << 1;

		return (*table<<8) | *(table+1);
	}
	else
		return (unsigned short)*( table + index );
}


static void _puts( const char *str, int stdio )
{

	if( stdio ) {
		while( *str )
			putchar( *str++ );
	}
	else {
		while( *str )
			_putch( *str++ );
	}
}


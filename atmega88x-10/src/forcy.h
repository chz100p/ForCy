//
//	ForCy - Super Light-weight Language
//
//	(c)2004 Osamu Tamura @ Recursion Co., Ltd.
//				All rights reserved.
//
//
//	forcy.h:	header
//

#define	DIC_MAX			256
#define	DIC_SIZE		1024
#define	CODE_SIZE		32768		//	byte
#define	MEM_SIZE		32768		//	word
#define	PROG_SIZE		8192
#define	DATA_SIZE		512

//	system defined words
enum {
	iRET	= 0,
	iWRD	= 0,
	iDO_,

	iNUM,
	iNUM2,
	iVAR,
	iVAR_,
	iARY,
	iARY_,
	iSTR,
	iSTR_,

	iLP,		//	10
	iRP,

	iDO,
	iFOR,
	iBRK,
	iWHL,
	iCNT,
	iIF,
	iELS,
	iCAS,
	iSWT,		//	20
	iOF,
	iSLF,
	iRTN,
	iINTR,

	iDRP,
	i2DRP,
	iNIP,
	iSWP,
	iDUP,
	iOVR,		//	30
	iPICK,
	iPOKE,

	iEQU,
	iNEQ,
	iLT,
	iGT,
	iLE,
	iGE,

	iINC,
	iDEC,		//	40
	iADD,
	iSUB,
	iMUL,
	iDIV,
	iMOD,
	iDVMD,
	iLSFT,
	iRSFT,
	iAND,
	iOR,		//	50
	iXOR,
	iCMP,
	iLAND,
	iLOR,
	iNOT,
	iMIN,
	iMAX,
	iRND,

	iCLK,
	iSEC,		//	60

	iKEY,
	iGETC,
	iPUTC,
	iPUTS,
	iPUTN,
	iPUTH,

	iSFR,
	iSFR_,

	iEP,
	iEP_,		//	70
	iED,
	iED_,
	iEPG,

	iSTRF,
	iRS,
	iDS,

	iEND
};

//	shortened style
enum {
	sNUM	= 0x90,
	sVAR	= 0xa0,
	sVAR_	= 0xb0,
	sARY	= 0xc0,
	sARY_	= 0xd0,
	sLP		= 0xe0,
	sLP_	= 0xf0
};

//	prototypes
extern int	compiler( unsigned char *code, FILE *fp, int debug );
extern int	interpreter( unsigned char *code, int stdio );



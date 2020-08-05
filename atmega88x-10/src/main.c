//
// main.c :
//

#include <stdio.h>
#include <string.h>
#include <fcntl.h>
//#include <io.h>
#include "forcy.h"


static char	*usage	= "\n  usage: %s [-cse] [-d0,1] filename\n";

static const char	*outfile = "usrprg.f";


extern size_t			epsiz;
extern unsigned char	progmem[];


static	unsigned char	code[CODE_SIZE];


int main( int argc, char *argv[] )
{
	FILE			*fp;
	char			*infile = NULL, *ext;
	int				cnt, stdio = 0, stdmem = 0, cc = 0, dbg = 0;
	size_t			size;


	if( argc<2 ) {
		fprintf( stderr, usage, argv[0] );
		return 1;
	}

	for( cnt=1; cnt<argc; cnt++ ) {
		if( *argv[cnt]=='-' ) {
			switch( argv[cnt][1] ) {
				case 's':	stdio	= 1;	break;
				case 'e':	stdmem	= stdio	= 1;	break;
				case 'c':	cc	= 1;	break;
				case 'd':	dbg	= argv[cnt][2]? (argv[cnt][2]-'0'):0;	break;
				default:	fprintf( stderr, usage, argv[0] );
							return 1;
			}
		}
		else
			infile	= argv[cnt];
	}
	if( infile==NULL )
		return 2;

	ext	= strrchr( infile, '.' );
	if( ext==NULL )
		return 2;
	ext++;

#if 1
	//	source
	if( !strcmp( ext, "fc" ) || !strcmp( ext, "txt" ) ) {
		if( (fp=fopen( infile, "r" ))!=NULL ) {
			size	= (size_t)compiler( code, fp, dbg );
			fclose( fp );

			strcpy( ext, "f" );
			if( (fp=fopen( infile, "wb" ))!=NULL ) {
				fwrite( code, sizeof(char), size, fp );
				fclose( fp );
			}

			fprintf( stderr, "\n compiled: %d byte.\n", size );
		}
	}
#endif

	//	object
	if( !cc ) {
		size	= 0;
		if( !strcmp( ext, "f" ) ) {
			if( (fp=fopen( infile, "rb" ))!=NULL ) {
				size	= fread( code, sizeof(char), CODE_SIZE, fp );
				fclose( fp );
			}
		}
		if( !size )
			return 3;

		//_setmode( _fileno( stdout ), _O_BINARY );

		size	= (size_t)interpreter( code, stdio );

		if( size )
			fprintf( stderr, "\n	stack %d level used.\n", size );
#if 1
		//	progmem
		if( stdmem && epsiz ) {

			if( (fp=fopen( outfile, "wb" ))!=NULL ) {
				fwrite( progmem, sizeof(char), ++epsiz, fp );
				fclose( fp );
			}

			fprintf( stderr, "\n compiled: %d byte.\n", epsiz );
		}
#endif
	}

	return 0;
}

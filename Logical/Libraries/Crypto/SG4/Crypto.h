/* Automation Studio generated header file */
/* Do not edit ! */
/* Crypto 2.0.0 */

#ifndef _CRYPTO_
#define _CRYPTO_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _Crypto_VERSION
#define _Crypto_VERSION 2.0.0
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG3
		#include "AsBrStr.h"
#endif
#ifdef _SG4
		#include "AsBrStr.h"
#endif
#ifdef _SGC
		#include "AsBrStr.h"
#endif


/* Datatypes and datatypes of function blocks */
typedef struct px32Md5_t
{	unsigned long aulBuf[4];
	unsigned long aulBits[2];
	unsigned long aulIn[16];
} px32Md5_t;

typedef struct ExtrDelStr
{
	/* VAR_INPUT (analog) */
	unsigned long pStrDest;
	unsigned long StrDestDim;
	unsigned long pStrTotal;
	unsigned long pStrLeft;
	unsigned long pStrRight;
	unsigned long StartSearchIdx;
	/* VAR_OUTPUT (analog) */
	unsigned long StartIdx;
	unsigned long EndIdx;
} ExtrDelStr_typ;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC void ExtrDelStr(struct ExtrDelStr* inst);
_BUR_PUBLIC unsigned short px32Md5Calc(unsigned long ulDataLen, unsigned char* pucDataIn, unsigned char* pucHashKeyOut);
_BUR_PUBLIC plcbit hex2str(unsigned char hashCode[16], unsigned long adr_md5Code);
_BUR_PUBLIC plcbit newNonce(plcstring** adrNonce);
_BUR_PUBLIC unsigned long Real2Str(float RealVar, unsigned long pString);


/* Constants */
#ifdef _REPLACE_CONST
 #define SF_MAX_SIZE 50000U
#else
 _GLOBAL_CONST unsigned long SF_MAX_SIZE;
#endif




#ifdef __cplusplus
};
#endif
#endif /* _CRYPTO_ */


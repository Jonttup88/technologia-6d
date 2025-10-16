/********************************************************************
 * COPYRIGHT -- Bernecker + Rainer
 ********************************************************************
 * Library: RandLib
 * File: RandValue.c
 * Author: manentiv
 * Created: December 20, 2011
 ********************************************************************
 * Implementation of library RandLib
 ********************************************************************/

#include <bur/plctypes.h>
#ifdef __cplusplus
	extern "C"
	{
#endif

	#include "RandLib.h"
	#include <stdlib.h>

#ifdef __cplusplus
	};
#endif

/* TODO: Add your comment here */
signed long RandValueDINT(signed long min, signed long max)
{
	DINT x;
	TIME t;      
	t = clock_ms();
	/* Intializes random number generator */
	srand((unsigned) t);
	
	x = rand()%(max-min+1)+min;

	return x;
}

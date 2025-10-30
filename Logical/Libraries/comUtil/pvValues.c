
#include <bur/plctypes.h>
#ifdef __cplusplus
	extern "C"
	{
#endif

#include "comUtil.h"
#include "stdio.h"
#ifdef __cplusplus
	};
#endif
/* TODO: Add your comment here */
plcbit pvValues(unsigned long pPvName, unsigned long pBuffer, unsigned long BufferLen)
{
	/*TODO: Add your code here*/
	UINT status;
	UDINT pvAddress;
	USINT pvItemName[20];
	UINT pvDimension;
	UDINT pvLen;
	UDINT pvDataTyp;
	BOOL valueBOOL;
	SINT valueSINT;
	INT valueINT;
	DINT valueDINT;
	USINT valueUSINT;
	UINT valueUINT;
	UDINT valueUDINT;
	REAL valueREAL;
	unsigned char valueSTRING[80];
	DATE_AND_TIME valueDT;
	TIME valueTIME;
	DATE valueDATE;
	LREAL valueLREAL;
	TIME_OF_DAY valueTOD;
	BYTE valueBYTE;
	WORD valueWORD;
	DWORD valueDWORD;
	WSTRING valueWSTRING[80];
	REAL tempREAL;
	DINT tempDINT;
	UDINT tempUDINT;
	unsigned char tempSTRING[80];
	status = PV_ninfo(pPvName,&pvDataTyp,&pvLen,&pvDimension);
	status = PV_xgetadr(pPvName,&pvAddress,&pvLen);
	brsmemset(pBuffer,0,BufferLen);
	if( status == 0)
	{
		switch(pvDataTyp)
		{
			case 1:
				{
					tempUDINT = sizeof(valueBOOL);
					brsmemcpy(&valueBOOL,pvAddress,sizeof(valueBOOL));
					if(valueBOOL)
					{
						brsstrcpy(pBuffer,"true");
					}
					else
					{
						brsstrcpy(pBuffer,"false");
					}
				}
				break;
			
			case 2:
				{
					tempUDINT = sizeof(valueSINT);
					brsmemcpy(&valueSINT,pvAddress,sizeof(valueSINT));
					tempDINT = (DINT)(valueSINT);
					brsitoa(tempDINT,(pBuffer));
					break;	
				}
			case 3:
				{
					tempUDINT = sizeof(valueINT);
					brsmemcpy(&valueINT,pvAddress,sizeof(valueINT));
					tempDINT = (DINT)(valueINT);
					brsitoa(tempDINT,(pBuffer));
					break;	
				}
			case 4:
				{
					tempUDINT = sizeof(valueDINT);
					brsmemcpy(&valueDINT,pvAddress,sizeof(valueDINT));
					brsitoa(valueDINT,(pBuffer));
					break;
				}
			case 5:
				{
					tempUDINT = sizeof(valueUSINT);
					brsmemcpy(&valueUSINT,pvAddress,sizeof(valueUSINT));
					tempDINT = (DINT)(valueUSINT);
					brsitoa(tempDINT,(pBuffer));
					break;
				}
			case 6:
				{
					tempUDINT = sizeof(valueUINT);
					brsmemcpy(&valueUINT,pvAddress,sizeof(valueUINT));
					tempDINT = (DINT)(valueUINT);
					brsitoa(tempDINT,(pBuffer));
					break;
				}
			case 7:
				{
					tempUDINT = sizeof(valueUDINT);
					brsmemcpy(&valueUDINT,pvAddress,sizeof(valueUDINT));
					tempDINT = (DINT)(valueUDINT);
					brsitoa(tempDINT,(pBuffer));
					break;	
				}
			case 8:
				{
					brsmemcpy(&valueREAL,pvAddress,sizeof(valueREAL));
					brsmemset(&tempSTRING,0,sizeof(tempSTRING));
					//brsftoa(valueREAL,&(tempSTRING));
					gcvt((float)valueREAL, 10, tempSTRING);
					if(pBuffer != 0)
					{
						brsstrcpy(pBuffer,&tempSTRING);
					}
					break;
				}
			case 9:
				{

					brsstrcpy(pBuffer,pvAddress);
					break;	
				}
			case 10:
				{
					/* lint */
					break;
				}
			case 11:
				{
					brsmemcpy(&valueDT,pvAddress,sizeof(valueDT));
					ascDT(valueDT,pBuffer,BufferLen);
					break;
				}
			case 12:
				{
					brsmemcpy(&valueTIME,pvAddress,sizeof(valueTIME));
					ascTIME(valueTIME,pvAddress,sizeof(valueTIME));
					break;
				}
			case 13:
				{
					brsmemcpy(&valueDATE,pvAddress,sizeof(valueDATE));
					break;
				}
			case 14:
				{
					brsmemcpy(&valueLREAL,pvAddress,sizeof(valueLREAL));
					tempREAL = (REAL)(valueLREAL);
					brsftoa(valueREAL,(pBuffer));
					break;
				}
			case 15:
				{
					/* null */
					break;
				}
			case 16:
				{
				
				
					brsmemcpy(&valueTOD,pvAddress,sizeof(valueTOD));
					break;
				}
			case 17:
				{
					break;
				}
			case 18:
				{
					break;
				}
			case 19:
				{
					break;
				}

			default:
				{
					break;
				}
		}		
	}	
}

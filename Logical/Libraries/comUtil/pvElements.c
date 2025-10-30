
#include <bur/plctypes.h>
#ifdef __cplusplus
	extern "C"
	{
#endif

#include "comUtil.h"
#ifdef __cplusplus
	};
#endif

#define TRUE 1
#define FALSE 0


/* TODO: Add your comment here */
plcbit pvElements(unsigned long pPvName, unsigned long pBuffer, unsigned long pParent, plcbit last, plcbit first)
{
	/*TODO: Add your code here*/
	UINT status;
	UDINT pvAddress;
	USINT pvItemName[20];
	UINT pvDimension;
	UDINT pvLen;
	UDINT pvDataTyp;
	UINT index = 0;
	unsigned char pvName[256];
	unsigned char tempPvName[256];
	unsigned char numStr[10];
	DINT loopVar = 0;
	UINT dim = 0;
	DINT tempDINT = 0;
	DINT i = 0;
	BOOL structMember = FALSE;
	BOOL written = FALSE;
	unsigned char valueString[1080];
	brsmemset(&numStr,0,sizeof(numStr));
	brsmemset(&pvName,0,sizeof(pvName));
	brsmemset(&tempPvName,0,sizeof(tempPvName));
	brsmemset(&pvLen,0,sizeof(pvLen));
	brsmemset(&pvDimension,0,sizeof(pvDimension));
	brsstrcpy(&pvName,pPvName);
	status = PV_ninfo(pPvName,&pvDataTyp,&pvLen,&pvDimension);
	
	if(status == 0)
	{
		brsmemset(&pvName,0,sizeof(pvName));
		brsstrcpy(&pvName,pPvName);
		if ((pvDataTyp != 0) && (pvDimension == 1))
		{		
			if(!first)
			{
				UDINT tempLen = strlen(pBuffer);
				if(tempLen > 0)
				{
					USINT lastChar = 0;
					brsmemcpy((UDINT)&lastChar,pBuffer+(tempLen-1),1);
					if(lastChar != 123)
					{
						brsstrcat(pBuffer,",");
					}
				}
				else
				{
					brsstrcat(pBuffer,",");
				}
			}
			brsstrcat(pBuffer,"\"");
			brsstrcat(pBuffer,pParent);
			pvValues(pPvName,&(valueString),sizeof(valueString));
			brsstrcat(pBuffer,("\":\""));
			brsstrcat(pBuffer,&(valueString));
			brsstrcat(pBuffer,"\"");
			written = TRUE;
		}
		else if(pvDataTyp == 0)
		{
			if (strlen(pBuffer) > 0 )
			{
				UDINT tempLen = strlen(pBuffer);
				if(tempLen > 0)
				{
					USINT lastChar = 0;
					brsmemcpy((UDINT)&lastChar,pBuffer+(tempLen-1),1);
					if(lastChar != 123)
					{
						brsstrcat(pBuffer,",");
					}
				}
				else
				{
					brsstrcat(pBuffer,",");
				}
			}
			brsstrcat(pBuffer,("\""));
			brsstrcat(pBuffer,pParent);
			brsstrcat(pBuffer,"\"");
			brsstrcat(pBuffer,":{");
			
			structMember = TRUE;
		}
	
		if (pvDimension > 0 && !written) 
		{
			if(pvDataTyp == 0) 
			{
				index = 0;
				brsstrcpy(&tempPvName,&pvName);
				while (index < pvDimension)
				{
					status = PV_item(pPvName,index,&pvItemName);
					brsstrcpy(&pvName,tempPvName);
					brsstrcat(&pvName,".");
					brsstrcat(&pvName,&pvItemName);
					
					/*
					brsstrcat(pBuffer,ADR('{'));
					brsstrcat(pBuffer,pParent);
					brsstrcat(pBuffer,ADR(': {'));
					brsstrcat(pBuffer,ADR(pvItemName));
					brsstrcpy(ADR(pvName),pPvName);
					*/
					
					pvElements(&pvName,pBuffer,&pvItemName,(index == (pvDimension-1)),((index == 0)));
					
					brsmemset(&pvName,0,sizeof(pvName));
					brsstrcpy(&pvName,pPvName);
					index = index + 1;
				}
			}
			else
			{
				dim = pvDimension;
				index = 0;
				do
				{
					brsmemset(&pvName,0,sizeof(pvName));
					brsstrcpy(&pvName,pPvName);
					brsstrcat(&pvName,"[");
					brsitoa((DINT)index,&numStr);
					brsstrcat(&pvName,&numStr);
					brsstrcat(&pvName,"]");
					status = PV_ninfo(&pvName,&pvDataTyp,&pvLen,&pvDimension);
					index = index + 1;
				}
				while(status == 0);
					
				index = index - 1;
				if (!first)
				{
					UDINT tempLen = strlen(pBuffer);
					if(tempLen > 0)
					{
						USINT lastChar = 0;
						brsmemcpy((UDINT)&lastChar,pBuffer+(tempLen-1),1);
						if(lastChar != 123)
						{
							brsstrcat(pBuffer,",");
						}
					}
					else
					{
						brsstrcat(pBuffer,",");
					}
				}
				
				brsstrcat(pBuffer,"\"");
				brsstrcat(pBuffer,pParent);			
				brsstrcat(pBuffer,"\"");
				brsstrcat(pBuffer,":[");
					
				for(i = 0; i < dim; ++i)
				{
					brsstrcpy(&pvName,pPvName);
					brsstrcat(&pvName,"[");
					tempDINT = i;
					brsitoa(tempDINT,&numStr);
					brsstrcat(&pvName,numStr);
					brsstrcat(&pvName,"]");
					
					status = PV_ninfo(&pvName,&pvDataTyp,&pvLen,&pvDimension);
					if( status == 0)
					{
						
						if( i > 0)
						{
							UDINT tempLen = strlen(pBuffer);
							if(tempLen > 0)
							{
								USINT lastChar = 0;
								brsmemcpy((UDINT)&lastChar,pBuffer+(tempLen-1),1);
								if(lastChar != 123)
								{
									brsstrcat(pBuffer,",");
								}
							}
							else
							{
								brsstrcat(pBuffer,",");
							}
						}
						if(pvDataTyp == 0)
						{
							index = 0;
							brsstrcpy(&tempPvName,&pvName);
							brsstrcat(pBuffer,"{");
							while (index < pvDimension)
							{
								status = PV_item(pPvName,index,&pvItemName);
								brsstrcpy(&pvName,tempPvName);
								brsstrcat(&pvName,".");
								brsstrcat(&pvName,&pvItemName);
					
									/*
									brsstrcat(pBuffer,ADR('{'));
									brsstrcat(pBuffer,pParent);
									brsstrcat(pBuffer,ADR(': {'));
									brsstrcat(pBuffer,ADR(pvItemName));
									brsstrcpy(ADR(pvName),pPvName);
									*/
					
								pvElements(&pvName,pBuffer,&pvItemName,(index == (pvDimension-1)),(index == 0));
								if(index == (pvDimension-1))
								{
									brsstrcat(pBuffer,"}");
								}
								brsmemset(&pvName,0,sizeof(pvName));
								brsstrcpy(&pvName,pPvName);
								index = index + 1;
							}
						}
						else
						{
							pvValues(&pvName,&valueString,sizeof(valueString));
							brsstrcat(pBuffer,&valueString);
						}
						//brsstrcat(pBuffer,ADR(numStr));
						if(i == (dim-1))
						{
							brsstrcat(pBuffer,"]");
						}
					}	
				}
				
			}
		}
		if(structMember )
		{
			structMember = FALSE;
			brsstrcat(pBuffer,"}");
		}
	}
}

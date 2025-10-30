
#include <bur/plctypes.h>
#ifdef _DEFAULT_INCLUDES
	#include <AsDefault.h>
#endif
#include <cosyWriteApi.h>
#include <cosyReadApi.h>
#include <stdint.h>
#include <stdio.h>
#include <parson.h>
#include <moApi.h>

#define TRUE 1
#define FALSE 0
#define booltoa(x) ((x)?"true":"false")

void cosyExample_ReadConfig(UDINT);
void cosyExample_WriteConfig(UDINT);
int json_get_array_memberStr(UDINT,UDINT,UDINT,int,UDINT);
int json_get_array_memberNumber(UDINT,UDINT,UDINT,int,UDINT);
int json_get_array_memberBool(UDINT,UDINT,UDINT,int,UDINT);
int json_dotget_number(UDINT,UDINT,UDINT);
unsigned long bur_heap_size = 0xffff;

void _INIT ProgramInit(void)
{
	webservice.enable = TRUE;
	webservice.pRequestHeader = (UDINT)&requestHeader;
	webservice.pRequestData = (UDINT)&request;
	webservice.requestDataSize = sizeof(request);
	webservice.pServiceName 	= (UDINT)&"conf6d.cgi"; //
	webservice.option 		= httpOPTION_HTTP_11 + httpOPTION_SERVICE_TYPE_NAME;
	
	webservice.pUri = (UDINT)&uri;
	webservice.uriSize = sizeof(uri);
	cosyExample_ReadConfig((UDINT)&layout);
}

void _CYCLIC ProgramCyclic(void)
{
	if(webservice.send)
	{
		webservice.send = FALSE;
	}
	else if(webservice.status == ERR_OK && webservice.phase == httpPHASE_RECEIVED && !webservice.send)
	{
		httpGetParamUrl_0.pSrc = (UDINT)&uri;
		httpGetParamUrl_0.enable = TRUE;
		httpGetParamUrl_0.pParam = (UDINT)&"cmd";
		httpGetParamUrl_0.pValue = (UDINT)&cmd;
		httpGetParamUrl_0.valueSize = sizeof(cmd);
		httpGetParamUrl(&httpGetParamUrl_0);
		
		if(httpGetParamUrl_0.status == ERR_OK)
		{
			httpGetParamUrl_0.enable = FALSE;
			httpGetParamUrl(&httpGetParamUrl_0);	
		}
		
		if(brsstrcmp((UDINT)&cmd,(UDINT)&"read") == 0)
		{
			brsstrcpy((UDINT)&responseHeader.contentType,(UDINT)&"application/json");
			brsstrcpy((UDINT)&response,(UDINT)&"{\"status\":\"ok\",\"layout\":{\"x\":");
			sprintf(response,"%s%i,\"y\":%i,\"segments\":[",response,layout.Xcount,layout.Ycount);
			for(int i = 0; i < layout.SegmentCount; ++i)
			{
				sprintf(response,"%s{\"x\":%i,\"y\":%i,\"name\":\"%s\",\"IsMaster\":%s}",response,layout.Segments[i].x,layout.Segments[i].y,layout.Segments[i].Name,booltoa(layout.Segments[i].IsMaster));
				if(i != (layout.SegmentCount-1))
				{
					brsstrcat((UDINT)&response,(UDINT)&",");
				}
			}
			brsstrcat((UDINT)&response,(UDINT)&"]}}");
		}
		else if(brsstrcmp((UDINT)&cmd,(UDINT)&"write") == 0)
		{
			brsstrcpy((UDINT)&responseHeader.contentType,(UDINT)&"application/json");
			brsmemset((UDINT)&layout,0,sizeof(layout));
			json_dotget_number((UDINT)&request,(UDINT)&"x",(UDINT)&tmpREAL);
			layout.Xcount = (USINT)tmpREAL;
			json_dotget_number((UDINT)&request,(UDINT)&"y",(UDINT)&tmpREAL);
			layout.Ycount = (USINT)tmpREAL;
			layout.SegmentCount = 0;
			for(int i = 0; i < 255; ++i)
			{
				if(json_get_array_memberNumber((UDINT)&request,(UDINT)&"segments",(UDINT)&"x",i,(UDINT)&tmpREAL) >= 0)
				{
					layout.Segments[i].x = (INT)tmpREAL;
					json_get_array_memberNumber((UDINT)&request,(UDINT)&"segments",(UDINT)&"y",i,(UDINT)&tmpREAL);
					layout.Segments[i].y = (INT)tmpREAL;
					json_get_array_memberBool((UDINT)&request,(UDINT)&"segments",(UDINT)&"IsMaster",i,(UDINT)&layout.Segments[i].IsMaster);
					layout.SegmentCount++; 
				}
				else
				{
					break;	
				}
			}
			cosyExample_WriteConfig((UDINT)&layout);
			brsstrcpy((UDINT)&response,(UDINT)&"{\"status\":\"ok\"}");
		}
		else	
		{
			brsstrcpy((UDINT)&responseHeader.contentType,(UDINT)&"image/svg+xml"); //
			httpDecodeBase64_0.enable = TRUE;
			httpDecodeBase64_0.destSize = sizeof(response);
			httpDecodeBase64_0.pDest = (UDINT)&response;
			httpDecodeBase64_0.pSrc = (UDINT)&svgResource;
			httpDecodeBase64_0.srcLen = brsstrlen((UDINT)&svgResource);
			httpDecodeBase64(&httpDecodeBase64_0);
		}
		brsstrcpy((UDINT)&responseHeader.userLine[0].name,(UDINT)&"Cross-Origin-Resource-Policy");
		brsstrcpy((UDINT)&responseHeader.userLine[0].value,(UDINT)&"cross-origin");
		brsstrcpy((UDINT)&responseHeader.userLine[1].name,(UDINT)&"Access-Control-Allow-Origin");
		brsstrcpy((UDINT)&responseHeader.userLine[1].value,(UDINT)&"*");
		webservice.pResponseHeader = (UDINT)&responseHeader;
		webservice.pResponseData = (UDINT)&response;
		webservice.responseDataLen 	= brsstrlen((UDINT)&response); 
		webservice.send = TRUE;
	}
	httpService(&webservice);
	
}



/* In the example code, error handling was deliberately omitted. */
void cosyExample_ReadConfig(UDINT context)
{
	Layout_typ myLayout;
	brsmemcpy((UDINT)&myLayout,context,sizeof(myLayout));
	uint32_t intValue = 0;
	BOOL boolValue = FALSE;
	char strValue[130];
	char tempID[60];
	COSY_H hCosy = cosyOpenElement("System/mapp6D/LayoutConfiguration", "Layout6D_1");
	cosyGetPropertyValue(hCosy, "Segments/SegRow", "USINT", sizeof(intValue),&intValue, NULL);
	myLayout.Ycount = (USINT)intValue;
	cosyGetPropertyValue(hCosy, "Segments/SegCol", "USINT", sizeof(intValue),&intValue, NULL);
	myLayout.Xcount = (USINT)intValue;
	myLayout.SegmentCount = 0;
	for(int i = 0; i < 255; ++i)
	{
		sprintf(tempID,"Segments/Segment[%i]/X",(i+1));
		if(cosyGetPropertyValue(hCosy,tempID, "INT", sizeof(intValue),&intValue, NULL))
		{
			myLayout.Segments[i].x = (INT)intValue;
			sprintf(tempID,"Segments/Segment[%i]/Y",(i+1));
			cosyGetPropertyValue(hCosy,tempID, "INT", sizeof(intValue),&intValue, NULL);
			myLayout.Segments[i].y = (INT)intValue;
			sprintf(tempID,"Segments/Segment[%i]/Name",(i+1));
			cosyGetPropertyValue(hCosy,tempID, "STRING", sizeof(strValue),&strValue, NULL);
			brsstrcpy((UDINT)&myLayout.Segments[i].Name,(UDINT)&strValue);
			sprintf(tempID,"Segments/Segment[%i]/IsMaster",(i+1));
			cosyGetPropertyValue(hCosy,tempID, "BOOL", sizeof(intValue),&intValue, NULL);
			myLayout.Segments[i].IsMaster = (BOOL)intValue;
			myLayout.SegmentCount++;
		}
		else
		{
			break;	
		}
	}
	cosyCloseElement(hCosy);
	brsmemcpy(context,(UDINT)&myLayout,sizeof(myLayout));
}
void cosyExample_WriteConfig(UDINT context)
{
	Layout_typ myLayout;
	uint32_t intValue = 0;
	BOOL boolValue = FALSE;
	USINT usintValue = 0;
	USINT i = 0;
	INT tempINT = 0;
	DINT tempDINT = 0;
	char segmentName[60];
	brsmemcpy((UDINT)&myLayout,context,sizeof(myLayout));
	COSY_H hCosy = cosyOpenElement("System/mapp6D/LayoutConfiguration", "Layout6D_1");
	if(hCosy != NULL)
	{
		cosySetProperty(hCosy, "Segments/SegCol", "USINT", &myLayout.Xcount, sizeof(myLayout.Xcount));
		cosySetProperty(hCosy, "Segments/SegRow", "USINT", &myLayout.Ycount, sizeof(myLayout.Ycount));
		for(i = 0; i < 255; ++i)
		{
			sprintf(segmentName,"Segments/Segment[%i]",(i+1));
			if(!cosyDeleteMember(hCosy,segmentName,COSY_TIMEOUT_NO_WAIT))
			{
				break;
			}
		}
		for(i = 0; i < myLayout.SegmentCount; ++i)
		{
			sprintf(segmentName,"Segments/Segment[%i]",(i+1));
			cosyAddGroup(hCosy, segmentName, NULL);
			
			sprintf(segmentName,"Segments/Segment[%i]/Y",(i+1));
			cosySetProperty(hCosy, segmentName, "INT", &myLayout.Segments[i].y, sizeof(myLayout.Segments[i].y));
			sprintf(segmentName,"Segments/Segment[%i]/X",(i+1));
			cosySetProperty(hCosy, segmentName, "INT", &myLayout.Segments[i].x, sizeof(myLayout.Segments[i].x));
			sprintf(segmentName,"Segments/Segment[%i]/Name",(i+1));
			cosySetProperty(hCosy, segmentName, "STRING", &myLayout.Segments[i].Name, sizeof(myLayout.Segments[i].Name));
			sprintf(segmentName,"Segments/Segment[%i]/IsMaster",(i+1));

			cosySetProperty(hCosy, segmentName, "BOOL", &myLayout.Segments[i].IsMaster, 0);
			
			sprintf(segmentName,"Segments/Segment[%i]/PowerSectorName",(i+1));
			cosySetProperty(hCosy, segmentName, "STRING", "", 0);
			sprintf(segmentName,"Segments/Segment[%i]/Gaps",(i+1));
			cosyAddGroup(hCosy, segmentName, NULL);
			tempDINT = 0; 
			sprintf(segmentName,"Segments/Segment[%i]/Gaps/Left",(i+1));
			cosySetProperty(hCosy, segmentName, "DINT", &tempDINT,sizeof(tempDINT));
			sprintf(segmentName,"Segments/Segment[%i]/Gaps/Bottom",(i+1));
			cosySetProperty(hCosy, segmentName, "DINT", &tempDINT,sizeof(tempDINT));
			sprintf(segmentName,"Segments/Segment[%i]/Gaps/Right",(i+1));
			cosySetProperty(hCosy, segmentName, "DINT", &tempDINT,sizeof(tempDINT));
			sprintf(segmentName,"Segments/Segment[%i]/Gaps/Top",(i+1));
			cosySetProperty(hCosy, segmentName, "DINT", &tempDINT,sizeof(tempDINT));
		}
		cosySaveElement(hCosy);
		cosyCloseElement(hCosy);
	}
}

int json_get_array_memberStr(UDINT data,UDINT arraystr,UDINT target,int index,UDINT result)
{
	/*TODO: Add your code here*/
	char buf[8000];
	char member[32];
	char memberValue[256];
	brsstrcpy((UDINT)&buf,data);
	
	JSON_Value *jsonRoot = json_parse_string(buf);
	brsstrcpy((UDINT)&member,arraystr);
	int retVal = 0;
	if(jsonRoot != NULL)
	{
		JSON_Array *arr = json_object_dotget_array(json_object(jsonRoot), member);
		if(arr != NULL)
		{
			JSON_Object *arrValue = json_array_get_object(arr,(size_t)index);
			if(arrValue != NULL)
			{
				const char *tempStr = NULL;
				char test[30];
				brsstrcpy((UDINT)&test,target);
				tempStr = json_object_dotget_string(arrValue,test);
				if(tempStr != NULL)
				{
					brsstrcpy(result,(UDINT)tempStr);	
					retVal = 0;
				}
				else
				{
					retVal = -1;	
				}
			}
			else
			{
				retVal = -1;	
			}
		}
		else
		{
			retVal = -1;	
		}
	}
	else
	{
		retVal = -1;	
	}

	json_value_free(jsonRoot);
	return retVal;
}

int json_get_array_memberNumber(UDINT data,UDINT arraystr,UDINT target,int index,UDINT result)
{
	/*TODO: Add your code here*/
	char buf[8000];
	char member[32];
	char memberValue[256];
	brsstrcpy((UDINT)&buf,data);
	
	JSON_Value *jsonRoot = json_parse_string(buf);
	brsstrcpy((UDINT)&member,arraystr);
	int retVal = 0;
	if(jsonRoot != NULL)
	{
		JSON_Array *arr = json_object_dotget_array(json_object(jsonRoot), member);
		if(arr != NULL)
		{
			JSON_Object *arrValue = json_array_get_object(arr,(size_t)index);
			if(arrValue != NULL)
			{
				char test[30];
				brsstrcpy((UDINT)&test,target);
				double number = json_object_dotget_number(arrValue,test);
				REAL tempREAL = (REAL)number;
				brsmemcpy(result,(UDINT)&tempREAL,sizeof(tempREAL));
				//brsstrcpy(result,(UDINT)tempStr);	
				retVal = 0;
			}
			else
			{
				retVal = -1;	
			}
		}
		else
		{
			retVal = -1;	
		}
	}
	else
	{
		retVal = -1;	
	}


	json_value_free(jsonRoot);
	return retVal;
}

int json_get_array_memberBool(UDINT data,UDINT arraystr,UDINT target,int index,UDINT result)
{
	/*TODO: Add your code here*/
	char buf[8000];
	char member[32];
	char memberValue[256];
	brsstrcpy((UDINT)&buf,data);
	
	JSON_Value *jsonRoot = json_parse_string(buf);
	brsstrcpy((UDINT)&member,arraystr);
	int retVal = 0;
	if(jsonRoot != NULL)
	{
		JSON_Array *arr = json_object_dotget_array(json_object(jsonRoot), member);
		if(arr != NULL)
		{
			JSON_Object *arrValue = json_array_get_object(arr,(size_t)index);
			if(arrValue != NULL)
			{
				char test[30];
				brsstrcpy((UDINT)&test,target);
				int number = json_object_dotget_boolean(arrValue,test);
				BOOL tempBOOL = (BOOL)number;
				brsmemcpy(result,(UDINT)&tempBOOL,sizeof(tempBOOL));
				//brsstrcpy(result,(UDINT)tempStr);	
				retVal = 0;
			}
			else
			{
				retVal = -1;	
			}
		}
		else
		{
			retVal = -1;	
		}
	}
	else
	{
		retVal = -1;	
	}
	json_value_free(jsonRoot);
	return retVal;
}

int json_dotget_number(UDINT data,UDINT memberstr,UDINT result)
{
	/*TODO: Add your code here*/
	char buf[8000];
	char member[32];
	char memberValue[256];
	brsstrcpy((UDINT)&buf,data);
	
	JSON_Value *jsonRoot = json_parse_string(buf);
	brsstrcpy((UDINT)&member,memberstr);
	int retVal = -1;
	if(jsonRoot != NULL)
	{
		double temp = 0;
		temp = json_object_dotget_number(json_object(jsonRoot), member);
		REAL tempREAL = (REAL)temp;
		brsmemcpy(result,(UDINT)&tempREAL,sizeof(tempREAL));
		retVal = 0;
		//memcpy(result,(UDINT)&temp,4);	
		
	}
	
	json_value_free(jsonRoot);
	return retVal;
}

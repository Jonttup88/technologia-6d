#include <bur/plctypes.h>
#include <stdio.h>
#include "targetModelInfo.h"
#include "rtkTask.h"
#include "bootModeApi.h"

#include "comUtil.h"

#ifdef __cplusplus
	extern "C"
	{
#endif


#ifdef __cplusplus
	};
#endif



static RTK_TASK_H myHidLibTask;

typedef struct
{
	ws_server_typ ws_server_0;
} internal_data;


/*
	{},                       \
	{},                       \
	*/
#define CFG_INTERNAL_DEFAULT \
	{                            \
	{}                       \
	}


static void myBackgroundTask(void *context)
{
	internal_data* tempData = (internal_data *)context;
	tempData->ws_server_0.Enable = 1;
	tempData->ws_server_0.ServerPort = 8889;
	for(;;)
	{
		ws_server(&tempData->ws_server_0);
		RtkSleepTaskUsec(10000);
	}
}


UINT _INIT util_INIT(unsigned long phase)
{
	if((phase == 5) && bootModeIsRun())
	{
		static internal_data data = CFG_INTERNAL_DEFAULT;
		RtkCreateTask("BRFIMON",200,0x80000, 0x80000,RTK_TASK_RESUMED,myBackgroundTask,&data,&myHidLibTask);
	}
	return 0;
}


UINT _EXIT util_EXIT(unsigned long phase)
{
	RtkDeleteTask(myHidLibTask);
	return 0;
}
/*
*/
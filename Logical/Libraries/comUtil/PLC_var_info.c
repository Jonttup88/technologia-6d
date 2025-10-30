
#include <bur/plctypes.h>
#ifdef __cplusplus
	extern "C"
	{
#endif
	#include "comUtil.h"
	#include "sys_lib.h"
#ifdef __cplusplus
	};
#endif
/* TODO: Add your comment here */
void PLC_var_info(struct PLC_var_info* inst)
{
	/*TODO: Add your code here*/
	
	if(inst->enable)
	{
		
		if(inst->browse && !inst->Internal.browse)
		{
			inst->Internal.browse = 1;	
		}
		
		
		if(inst->Internal.browse)
		{
			switch (inst->Internal.browse_module_state)
			{
				case 0:
					inst->Internal.prev_index = 0xffff;
					inst->Internal.browse_module_state++;
					memset(&inst->data,0,sizeof(inst->data));
					break;

				
				case 1:
					
					inst->Internal.status = MO_list(inst->Internal.prev_index,&inst->Internal.index,&inst->Internal.module_typ);
					
					if(inst->Internal.status == 0)
					{
						if(inst->Internal.module_typ.type == 17)
						{
							inst->Internal.browse_module_state++;
						}
						inst->Internal.prev_index++;
					}
					else
					{
						inst->Internal.browse_module_state = 10;
						inst->Internal.prev_index = 0xffff;
					}
					break;
				
				case 2:
					strcpy(&inst->data.Tasks[inst->data.TaskCount].Name,&inst->Internal.module_typ.name);
					inst->Internal.MO_info_0.enable = 1;
					inst->Internal.MO_info_0.pName = &inst->data.Tasks[inst->data.TaskCount].Name;
					MO_info(&inst->Internal.MO_info_0);
					
					if(inst->Internal.MO_info_0.status == ERR_OK)
					{
						inst->data.Tasks[inst->data.TaskCount].StartAddress = inst->Internal.module_typ.adress;
						inst->data.Tasks[inst->data.TaskCount].Size = inst->Internal.MO_info_0.size;
						strcpy(&inst->data.Tasks[inst->data.TaskCount].Version,&inst->Internal.MO_info_0.version);
						memcpy(&inst->data.Tasks[inst->data.TaskCount].Date,&inst->Internal.MO_info_0.date,sizeof(&inst->Internal.MO_info_0.date));
						inst->Internal.MO_info_0.enable = 0;
						MO_info(&inst->Internal.MO_info_0);
						inst->Internal.browse_module_state = 1;
						inst->data.TaskCount++;
					}
					
					break;
				
				
				case 10:
					inst->Internal.status = PV_xlist(inst->Internal.prev_index,&inst->Internal.index,&inst->Internal.var_typ);
					
					if(inst->Internal.status == 0)
					{
						inst->Internal.prev_index++;
						inst->Internal.browse_module_state++;
					}
					else
					{
						inst->Internal.browse_module_state = 20;
					}
					
					break;
				
				case 11:
					
					inst->Internal.found = 0;
					for(int i = 0; i <= inst->data.TaskCount; ++i)
					{
						if( i == 0)
						{
							strcpy(&inst->Internal.tempSTRING,&inst->Internal.var_typ.name);
							inst->Internal.status = PV_ninfo(&inst->Internal.tempSTRING,&inst->Internal.datatype,&inst->Internal.datalen,&inst->Internal.datadim);
							if(inst->Internal.status == 0)
							{
								// global var
								break;	
							}
						}
						else
						{
							inst->Internal.found = 1;
							inst->Internal.localVarFound = 0;
							if(inst->data.Tasks[i-1].VariableCount > 0)
							{
								for(int j = 0; j < inst->data.Tasks[i-1].VariableCount; ++j)
								{
									if(strcmp(&inst->data.Tasks[i-1].Variables[j].Name,&inst->Internal.var_typ.name) == 0)
									{
										inst->Internal.localVarFound = 1;
										break;
									}
								}							
							}
							
							if(!inst->Internal.localVarFound)
							{
								strcpy(&inst->Internal.tempSTRING,&inst->data.Tasks[i-1].Name);
								strcat(&inst->Internal.tempSTRING,&":");
								strcat(&inst->Internal.tempSTRING,&inst->Internal.var_typ.name);
								inst->Internal.status = PV_ninfo(&inst->Internal.tempSTRING,&inst->Internal.datatype,&inst->Internal.datalen,&inst->Internal.datadim);
								if(inst->Internal.status == 0)
								{
									strcpy(&inst->data.Tasks[i-1].Variables[inst->data.Tasks[i-1].VariableCount].Name,&inst->Internal.var_typ.name);
									inst->data.Tasks[i-1].Variables[inst->data.Tasks[i-1].VariableCount].Type = inst->Internal.var_typ.data_typ;
									inst->data.Tasks[i-1].VariableCount++;
								}
							}
						}
					}
					
					if(!inst->Internal.found)
					{
						if(inst->data.GlobalVarCount > 0)
						{
							for(int i = 0; i < inst->data.GlobalVarCount; ++i)
							{
								if(strcmp(&inst->data.GlobalVars[i].Name,&inst->Internal.var_typ.name) == 0)
								{
									inst->Internal.found = 1;
									break;
								}
							}
							if(!inst->Internal.found)
							{
								strcpy(&inst->data.GlobalVars[inst->data.GlobalVarCount].Name,&inst->Internal.var_typ.name);
								inst->data.GlobalVars[inst->data.GlobalVarCount].Type = inst->Internal.var_typ.data_typ;
								inst->data.GlobalVarCount++;
							}
						}
						else
						{
							strcpy(&inst->data.GlobalVars[inst->data.GlobalVarCount].Name,&inst->Internal.var_typ.name);
							inst->data.GlobalVars[inst->data.GlobalVarCount].Type = inst->Internal.var_typ.data_typ;
							inst->data.GlobalVarCount++;
						}
					
					}
					inst->Internal.browse_module_state = 10;
					break;
				
				case 20:
					
					if(!inst->browse)
					{
						inst->Internal.browse = 0;
						inst->Internal.browse_module_state = 0;
					}
				
				default:

					break;
			}
     	
			
		}
		
		inst->done = inst->browse && (inst->Internal.browse_module_state == 20);
		
	}
	inst->active = inst->enable;
	
	
	
}

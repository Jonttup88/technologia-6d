
#include <bur/plctypes.h>
#ifdef __cplusplus
	extern "C"
	{
#endif
	#include "comUtil.h"
	#include "AsTCP.h"
	#include <stdio.h>
	#include "ws.h"
	#include "utf8.h"
	#include "parson.h"
	#include "standard.h"

#ifdef __cplusplus
	};
#endif

#define TRUE 1
#define FALSE 0


struct ws_frame_data 
{
		/**
		 * @brief Frame read.
		 */
	unsigned char frm[MESSAGE_LENGTH];
		/**
		 * @brief Processed message at the moment.
		 */
	unsigned char *msg;
		/**
		 * @brief Control frame payload
		 */
	unsigned char msg_ctrl[125];
		/**
		 * @brief Current byte position.
		 */
	size_t cur_pos;
		/**
		 * @brief Amount of read bytes.
		 */
	size_t amt_read;
		/**
		 * @brief Frame type, like text or binary.
		 */
	int frame_type;
		/**
		 * @brief Frame size.
		 */
	uint64_t frame_size;
		/**
		 * @brief Error flag, set when a read was not possible.
		 */
	int error;
		/**
		 * @brief client status.
		 */
	int client;
};

void setError(unsigned char *data);

int verifyParameters(void *context);

int storeMonitorVariables(unsigned char *input,void *context);

void createJSONfromMonitorVar(unsigned char *buffer, void *context,int index, unsigned char *buffer1,unsigned long len);
void createJSONfromMonitorVars(unsigned char *buffer, void *context,unsigned char *buffer1,unsigned long len);

static int do_handshake(unsigned char *data, struct ws_frame_data *wfd,UDINT *len);

static int do_close(struct ws_frame_data *wfd, int close_code, unsigned char *data);

static int next_frame(struct ws_frame_data *wfd);

int _json_get_member(unsigned char *data,unsigned char *memberstr,unsigned char *result);
int _json_get_array_memberString(unsigned char *data,unsigned char *arraystr,unsigned char *target,int index,UDINT result);
int _json_dotget_member(unsigned char *data,unsigned char *memberstr,unsigned char *result);
int _json_dotget_number(unsigned char *data,unsigned char *memberstr,REAL *result);
int _json_get_array_member(unsigned char *data,unsigned char *arraystr,unsigned char *target,int index,REAL *result);
int _json_get_array_memberStr(unsigned char *data,unsigned char *arraystr,unsigned char *target,int index,unsigned char *result);
int _json_get_array_array_member(unsigned char *data,unsigned char *arraystr,int mainIndex,unsigned char *target,int index,unsigned char *targetMember,REAL *result);
int _json_get_array_array_memberStr(unsigned char *data,unsigned char *arraystr,int mainIndex,unsigned char *target,int index,unsigned char *targetMember,unsigned char *result);


UDINT crc32b(UDINT start_addr, UDINT size);

/* TODO: Add your comment here */
void ws_server(struct ws_server* inst)
{
	struct ws_frame_data wfd;
	BOOL ioctlValue;

	/*TODO: Add your code here*/
	switch (inst->Internal.serverState)
	{
		case 0:
			inst->Internal.FB.TcpOpen_0.enable = TRUE;
			inst->Internal.FB.TcpOpen_0.options = tcpOPT_REUSEADDR;
			inst->Internal.FB.TcpOpen_0.port = inst->ServerPort;
			
			TcpOpen(&inst->Internal.FB.TcpOpen_0);
			
			if(inst->Internal.FB.TcpOpen_0.status == ERR_OK)
			{
				inst->Internal.FB.TcpServer_0.ident = inst->Internal.FB.TcpOpen_0.ident;
				inst->Internal.FB.TcpIoctl_0.ident = inst->Internal.FB.TcpOpen_0.ident;
				inst->Internal.FB.TcpIoctl_0.ioctl = tcpSO_NOWAITING_SET;
				ioctlValue = 1;
				inst->Internal.serverState = 1;
				inst->Internal.FB.TcpOpen_0.enable = FALSE;			
				TcpOpen(&inst->Internal.FB.TcpOpen_0);
			}
			break;

		case 1:
			inst->Internal.FB.TcpIoctl_0.enable = TRUE;
			inst->Internal.FB.TcpIoctl_0.pData = (UDINT)&ioctlValue;
			inst->Internal.FB.TcpIoctl_0.datalen = sizeof(ioctlValue);
			TcpIoctl(&inst->Internal.FB.TcpIoctl_0);
		
			if(inst->Internal.FB.TcpIoctl_0.status = ERR_FUB_BUSY)
			{
				inst->Internal.FB.TcpIoctl_0.enable = FALSE;
				TcpIoctl(&inst->Internal.FB.TcpIoctl_0);
				inst->Internal.serverState = 2;
			}
			break;
		case 2:
			
			if(inst->Internal.clients.count < MAX_CLIENT_COUNT)
			{
			
				inst->Internal.FB.TcpServer_0.enable = TRUE;
				inst->Internal.FB.TcpServer_0.backlog = 0;
				inst->Internal.FB.TcpServer_0.pIpAddr = &inst->Internal.data.ip_addr;
				//inst->Internal.FB.TcpServer_0.backlog = 1;
			
				TcpServer(&inst->Internal.FB.TcpServer_0);
			
				if(inst->Internal.FB.TcpServer_0.status == ERR_OK)
				{
					brsstrcpy(&inst->Internal.clients.client[inst->Internal.clients.count].ip_addr,&inst->Internal.data.ip_addr);
					//inst->Internal.clients.client[inst->Internal.clients.count].ident = inst->Internal.FB.TcpServer_0.identclnt;
					inst->Internal.clients.client[inst->Internal.clients.count].FB.TcpRecv_0.ident = inst->Internal.FB.TcpServer_0.identclnt;
					inst->Internal.clients.client[inst->Internal.clients.count].FB.TcpSend_0.ident = inst->Internal.FB.TcpServer_0.identclnt;
					inst->Internal.clients.client[inst->Internal.clients.count].ident = inst->Internal.FB.TcpServer_0.identclnt;
					inst->Internal.clients.count++;
				
				}
			}
				/*
			else
			{
				inst->Internal.FB.TcpServer_0.enable = TRUE;
				inst->Internal.FB.TcpServer_0.backlog = 0;
				inst->Internal.FB.TcpServer_0.pIpAddr = &inst->Internal.data.ip_addr;
				//inst->Internal.FB.TcpServer_0.backlog = 0;
			
				TcpServer(&inst->Internal.FB.TcpServer_0);
			
				if(inst->Internal.FB.TcpServer_0.status == ERR_OK)
				{
					
					inst->Internal.FB.TcpClose_0.ident = inst->Internal.FB.TcpServer_0.identclnt;
					inst->Internal.serverState++;
				}
			
			}
			*/
			break;
		
		case 3:
			
			inst->Internal.FB.TcpClose_0.enable = TRUE;
			inst->Internal.FB.TcpClose_0.how = tcpSHUT_RD | tcpSHUT_WR;
			TcpClose(&inst->Internal.FB.TcpClose_0);
		
			if(inst->Internal.FB.TcpClose_0.status = ERR_OK)
			{
				inst->Internal.FB.TcpClose_0.enable = FALSE;
				TcpClose(&inst->Internal.FB.TcpClose_0);
				inst->Internal.serverState = 2;
			}
		
		default:

			break;
	}
	
	


	
	BOOL changeOccured = FALSE;
	for(int i = 0; i < inst->Internal.clients.count; ++i)
	{
		BOOL sendDone = FALSE;
		unsigned char clse_code[2];
		int cc;
		switch (inst->Internal.clients.client[i].commState)
		{
			case 0:
				// receive
				inst->Internal.clients.client[i].FB.TcpRecv_0.enable = TRUE;
				inst->Internal.clients.client[i].FB.TcpRecv_0.pData = &inst->Internal.clients.client[i].data.recvbuf;
				//inst->Internal.clients.client[i].FB.TcpRecv_0.flags = tcpMSG_OOB;
				inst->Internal.clients.client[i].FB.TcpRecv_0.datamax = sizeof(inst->Internal.clients.client[i].data.recvbuf);
				TcpRecv(&inst->Internal.clients.client[i].FB.TcpRecv_0);
				
				if(inst->Internal.clients.client[i].FB.TcpRecv_0.status == ERR_OK)
				{
					inst->Internal.clients.client[i].data.recvlen = inst->Internal.clients.client[i].FB.TcpRecv_0.recvlen;
					inst->Internal.clients.client[i].FB.TcpRecv_0.enable = FALSE;
					TcpRecv(&inst->Internal.clients.client[i].FB.TcpRecv_0);
					if(	inst->Internal.clients.client[i].status == WS_STATE_OPEN)
					{
						inst->Internal.clients.client[i].commState = 11;
					}
					else
					{
						inst->Internal.clients.client[i].commState = 10;
					}
				}
				else if((inst->Internal.clients.client[i].FB.TcpRecv_0.status != ERR_FUB_BUSY) && (inst->Internal.clients.client[i].FB.TcpRecv_0.status != tcpERR_NO_DATA))
				{
					inst->Internal.data.prevError = inst->Internal.clients.client[i].FB.TcpRecv_0.status;
					if(inst->Internal.clients.client[i].FB.TcpRecv_0.status == tcpERR_NOT_CONNECTED)
					{
						inst->Internal.clients.client[i].commState = 99;
					}
					else
					{
						inst->Internal.clients.client[i].commState = 0;
					}
				}
				break;
			
			case 1:
				inst->Internal.clients.client[i].FB.TcpSend_0.enable = TRUE;
				inst->Internal.clients.client[i].FB.TcpSend_0.flags = tcpMSG_DONTROUTE;
				inst->Internal.clients.client[i].FB.TcpSend_0.pData = &inst->Internal.clients.client[i].data.sendbuf;
				TcpSend(&inst->Internal.clients.client[i].FB.TcpSend_0);
				
				
				if(inst->Internal.clients.client[i].FB.TcpSend_0.status == ERR_OK)
				{
					brsmemset(&inst->Internal.clients.client[i].data.sendbuf,0,sizeof(inst->Internal.clients.client[i].data.sendbuf));
					inst->Internal.clients.client[i].FB.TcpSend_0.enable = FALSE;
					TcpSend(&inst->Internal.clients.client[i].FB.TcpSend_0);
					inst->Internal.clients.client[i].commState = 0;
					sendDone = TRUE;
					if(inst->Internal.clients.client[i].status == WS_STATE_CONNECTING)
					{
						inst->Internal.clients.client[i].status = WS_STATE_OPEN;
					}
					else if(inst->Internal.clients.client[i].status == WS_STATE_CLOSING)
					{
						inst->Internal.clients.client[i].commState = 99;
					}
				}
				else if(inst->Internal.clients.client[i].FB.TcpSend_0.status != ERR_FUB_BUSY)
				{
					inst->Internal.data.prevError = inst->Internal.clients.client[i].FB.TcpSend_0.status;
					inst->Internal.clients.client[i].commState = 99;
				}
				
				break;
			
			case 10:
				// handshake 
				brsmemset(&wfd,0,sizeof(wfd));
				brsmemcpy(&wfd.frm,&inst->Internal.clients.client[i].data.recvbuf,inst->Internal.clients.client[i].data.recvlen);
				brsmemset(&inst->Internal.clients.client[i].data.recvbuf,0,sizeof(inst->Internal.clients.client[i].data.recvbuf));
				if(do_handshake(&inst->Internal.clients.client[i].data.sendbuf,&wfd,&inst->Internal.clients.client[i].FB.TcpSend_0.datalen) < 0)
				{
					//error
					inst->Internal.clients.client[i].commState = 100;
				}
				else
				{
					inst->Internal.clients.client[i].commState = 1;
					inst->Internal.clients.client[i].status = WS_STATE_CONNECTING;
				}
				break;
			
			case 11:
				// handle frame
				brsmemset(&wfd,0,sizeof(wfd));
				wfd.client = inst->Internal.clients.client[i].status;
				wfd.amt_read = inst->Internal.clients.client[i].data.recvlen;
				wfd.cur_pos = 0;
				brsmemcpy(&wfd.frm,&inst->Internal.clients.client[i].data.recvbuf,inst->Internal.clients.client[i].data.recvlen);
				brsmemset(&inst->Internal.clients.client[i].data.recvbuf,0,sizeof(inst->Internal.clients.client[i].data.recvbuf));
				
				if(next_frame(&wfd) >= 0)
				{
					/* Text/binary event. */
					if ((wfd.frame_type == WS_FR_OP_TXT || wfd.frame_type == WS_FR_OP_BIN) &&
						!wfd.error)
					{
						// handle message
						if(wfd.msg != NULL)
						{
							//brsstrcpy(&inst->Internal.data.latestData,wfd.msg);
							if(_json_get_member(wfd.msg,"cmd",&inst->Internal.data.latestData) < 0)
							{
								// error - listen more data
								inst->Internal.clients.client[i].commState = 0;
							}
							else
							{
								if(0 == strcmp(&inst->Internal.data.latestData,"monitor"))
								{
									if(_json_get_member(wfd.msg,"pvName",&inst->Internal.data.latestData) >= 0)
									{
										brsmemset((UDINT)&inst->Internal.clients.client[i].monitor,0,sizeof(inst->Internal.clients.client[0].monitor));
										storeMonitorVariables(&inst->Internal.data.latestData,&inst->Internal.clients.client[i].monitor);
										brsmemset(&inst->Internal.data.latestData,0,sizeof(inst->Internal.data.latestData));
										inst->Internal.clients.client[i].monitorActive = verifyParameters(&inst->Internal.clients.client[i].monitor) > 0;
										inst->Internal.clients.client[i].monitor.init = TRUE;
									}
									else
									{
										setError(&inst->Internal.data.latestData);
									}
								}
								else if(0 == strcmp(&inst->Internal.data.latestData,"read"))
								{
									if(_json_get_member(wfd.msg,"pvName",&inst->Internal.data.latestData) >= 0)
									{
										brsmemset((UDINT)&inst->Internal.read,0,sizeof(inst->Internal.read));
										storeMonitorVariables(&inst->Internal.data.latestData,&inst->Internal.read);
										brsmemset(&inst->Internal.data.latestData,0,sizeof(inst->Internal.data.latestData));
										if(verifyParameters(&inst->Internal.read) > 0)
										{
										
											brsmemset(&inst->Internal.data.monitorData,0,sizeof(inst->Internal.data.monitorData));
											brsstrcpy(&inst->Internal.data.monitorData,"{\"status\":\"readValuesOK\",\"data\":[");
											BOOL firstWritten = FALSE;
											for(int z = 0; z < inst->Internal.read.count; ++z)
											{
												brsmemset(&inst->Internal.data.latestData,0,sizeof(inst->Internal.data.latestData));
												createJSONfromMonitorVar(&inst->Internal.data.latestData,&inst->Internal.read,z,&inst->Internal.data.latestData1,sizeof(inst->Internal.data.latestData1));
												if(firstWritten)
												{
													brsstrcat(&inst->Internal.data.monitorData,",");
													brsstrcat(&inst->Internal.data.monitorData,&inst->Internal.data.latestData);
												}
												else
												{
													brsstrcat(&inst->Internal.data.monitorData,&inst->Internal.data.latestData);
													firstWritten = TRUE;
												}
											}
											if(firstWritten)
											{
												brsstrcat(&inst->Internal.data.monitorData,"]}");
												brsstrcpy(&inst->Internal.data.latestData,&inst->Internal.data.monitorData);
												inst->Internal.clients.client[i].commState = 1;	
												changeOccured = TRUE;
											}
										}
										else
										{
											setError(&inst->Internal.data.latestData);
										}
									}
								}
								else if(0 == strcmp(&inst->Internal.data.latestData,"write"))
								{
									DINT index = 0;
									UDINT data_type = 0;
									UDINT address = 0;
									UDINT data_len = 0;
									UINT status = 0;
									UINT dimension;
									BOOL tempBOOL;
										
									SINT tempSINT;
									DINT tempDINT;
									INT tempINT;
									USINT tempUSINT;
									UINT tempUINT;
									UDINT tempUDINT;
									int k = 0;
									int loopVar = 0;
									char member[32];
									size_t arrSize;
									BOOL arraySizeSet = FALSE;
									JSON_Value *jsonRoot = json_parse_string(wfd.msg);
									brsstrcpy((UDINT)&member,(UDINT)"parameter");
									if(jsonRoot != NULL)
									{
										JSON_Array *arr = json_object_dotget_array(json_object(jsonRoot), member);
										if(arr != NULL)
										{
											arrSize = json_array_get_count(arr);
											arraySizeSet = TRUE;
										}
									}
									json_value_free(jsonRoot);
									
									for(loopVar = 0; loopVar < (int)arrSize; ++loopVar)
									{
										char parValue[30];
										char parameter[40];
										char loopVarSTR[4];
										char arrayData[500];
										char targetPvName[80];
										DINT arrayIndex;
										DINT arrayMax;
										brsmemset((UDINT)&parValue,0,sizeof(parValue));
										brsmemset((UDINT)&loopVarSTR,0,sizeof(loopVarSTR));
										brsstrcpy((UDINT)&parValue,(UDINT)"parameter[");
										brsitoa((DINT)loopVar,(UDINT)&loopVarSTR);
										brsstrcat((UDINT)&parValue,(UDINT)&loopVarSTR);
										brsstrcat((UDINT)&parValue,(UDINT)"]");
										REAL tempREAL = 0;
										
										brsmemset((UDINT)&parameter,0,sizeof(parameter));
										brsstrcpy((UDINT)&parameter,(UDINT)&parValue);
										brsstrcat((UDINT)&parameter,(UDINT)".value");
										_json_get_array_member(wfd.msg,"parameter","value",loopVar,&tempREAL);
									
										brsmemset(&inst->Internal.data.latestData,0,sizeof(inst->Internal.data.latestData));
										if(_json_get_array_memberStr(wfd.msg,"parameter","variable",loopVar,&inst->Internal.data.latestData) >= 0)
										{
											if(PV_xgetadr((UDINT)&inst->Internal.data.latestData,(UDINT)&address,(UDINT)&data_len) == 0)
											{
												PV_ninfo((UDINT)&inst->Internal.data.latestData,(UDINT)&data_type,(UDINT)&data_len,(UDINT)&dimension);
												if(dimension > 1)
												{
													_json_get_array_memberStr(wfd.msg,"parameter","value",loopVar,&arrayData);
													JSON_Value *jsonRoot = json_parse_string(arrayData);
													int retVal = 0;
													if(jsonRoot != NULL)
													{
														JSON_Array *arr = json_array(jsonRoot);
														if(arr != NULL)
														{
															arrayMax = (DINT)json_array_get_count(arr);
															for(arrayIndex = 0; arrayIndex < arrayMax; ++arrayIndex)
															{
																double tempDouble;
																tempDouble = json_array_get_number(arr,(size_t)arrayIndex);
																brsmemset((UDINT)&targetPvName,0,sizeof(targetPvName));
																sprintf(targetPvName,"%s[%i]",&inst->Internal.data.latestData,arrayIndex);
																if(PV_xgetadr((UDINT)&targetPvName,(UDINT)&address,(UDINT)&data_len) == 0)
																{
																	PV_ninfo((UDINT)&inst->Internal.data.latestData,(UDINT)&data_type,(UDINT)&data_len,(UDINT)&dimension);
																	tempREAL = (REAL)tempDouble;
																	switch(data_type)
																	{
																		case 1:
											
																			tempBOOL = (BOOL)tempREAL;
																			brsmemcpy(address,(UDINT)&tempBOOL,sizeof(tempBOOL));
											
																			break;
																		case 2:
																			tempSINT = (SINT)tempREAL;
																			brsmemcpy(address,(UDINT)&tempSINT,sizeof(tempSINT));
											
																			break;
																		case 3:
																			tempINT = (INT)tempREAL;
																			brsmemcpy(address,(UDINT)&tempINT,sizeof(tempINT));
											
																			break;
																		case 4:
																			tempDINT = (DINT)tempREAL;
																			brsmemcpy(address,(UDINT)&tempDINT,sizeof(tempDINT));
											
																			break;
																		case 5:
																			tempUSINT = (USINT)tempREAL;
																			brsmemcpy(address,(UDINT)&tempUSINT,sizeof(tempUSINT));
											
																			break;
																		case 6:
																			tempUINT = (UINT)tempREAL;
																			brsmemcpy(address,(UDINT)&tempUINT,sizeof(tempUINT));
											
																			break;
																		case 7:
																			tempUDINT = (UDINT)tempREAL;
																			brsmemcpy(address,(UDINT)&tempUDINT,sizeof(tempUDINT));
											
																			break;
																		case 8:
																			brsmemcpy(address,(UDINT)&tempREAL,sizeof(tempREAL));
																			break;
																		default:

																			break;
																	}
																}
															}
														}
													}

													json_value_free(jsonRoot);
												}
												else
												{
													switch (data_type)
													{
														case 1:
												
															tempBOOL = (BOOL)tempREAL;
															brsmemcpy(address,(UDINT)&tempBOOL,sizeof(tempBOOL));
												
															break;
														case 2:
															tempSINT = (SINT)tempREAL;
															brsmemcpy(address,(UDINT)&tempSINT,sizeof(tempSINT));
												
															break;
														case 3:
															tempINT = (INT)tempREAL;
															brsmemcpy(address,(UDINT)&tempINT,sizeof(tempINT));
												
															break;
														case 4:
															tempDINT = (DINT)tempREAL;
															brsmemcpy(address,(UDINT)&tempDINT,sizeof(tempDINT));
												
															break;
														case 5:
															tempUSINT = (USINT)tempREAL;
															brsmemcpy(address,(UDINT)&tempUSINT,sizeof(tempUSINT));
												
															break;
														case 6:
															tempUINT = (UINT)tempREAL;
															brsmemcpy(address,(UDINT)&tempUINT,sizeof(tempUINT));
												
															break;
														case 7:
															tempUDINT = (UDINT)tempREAL;
															brsmemcpy(address,(UDINT)&tempUDINT,sizeof(tempUDINT));
												
															break;
														case 8:
															brsmemcpy(address,(UDINT)&tempREAL,sizeof(tempREAL));
															break;
														case 9:
															_json_get_array_memberString(wfd.msg,"parameter","value",loopVar,address);
														default:

															break;
													}
												}
											}
										}
									}
								}
								else if(0 == strcmp(&inst->Internal.data.latestData,"list"))
								{
									brsmemset(&inst->Internal.data.latestData,0,sizeof(inst->Internal.data.latestData));
									brsstrcpy(&inst->Internal.data.latestData,&"{\"status\":\"listResult\",\"data\":{\"variables\":[");
									for(int s = 0; s < inst->Internal.FB.PLC_var_info_0.data.GlobalVarCount; ++s)
									{
										if(s == 0)
										{
											sprintf(&inst->Internal.data.latestData,"%s{\"name\":\"%s\",\"type\":\"%u\"}",&inst->Internal.data.latestData,&inst->Internal.FB.PLC_var_info_0.data.GlobalVars[s].Name,inst->Internal.FB.PLC_var_info_0.data.GlobalVars[s].Type);
										}
										else
										{
											sprintf(&inst->Internal.data.latestData,"%s,{\"name\":\"%s\",\"type\":\"%u\"}",&inst->Internal.data.latestData,&inst->Internal.FB.PLC_var_info_0.data.GlobalVars[s].Name,inst->Internal.FB.PLC_var_info_0.data.GlobalVars[s].Type);
										}
									}
									brsstrcat(&inst->Internal.data.latestData,&"],\"tasks\":[");
										
									for(int s = 0; s < inst->Internal.FB.PLC_var_info_0.data.TaskCount; ++s)
									{
										if(s == 0)
										{
											sprintf(&inst->Internal.data.latestData,&"%s{\"name\":\"%s\",\"variables\":[",&inst->Internal.data.latestData,&inst->Internal.FB.PLC_var_info_0.data.Tasks[s].Name);
												
										}
										else
										{
											sprintf(&inst->Internal.data.latestData,&"%s,{\"name\":\"%s\",\"variables\":[",&inst->Internal.data.latestData,&inst->Internal.FB.PLC_var_info_0.data.Tasks[s].Name);
												
										}
										for(int j = 0; j < inst->Internal.FB.PLC_var_info_0.data.Tasks[s].VariableCount; ++j)
										{
											if(j == 0)
											{
												sprintf(&inst->Internal.data.latestData,"%s{\"name\":\"%s\",\"type\":\"%u\"}",&inst->Internal.data.latestData,&inst->Internal.FB.PLC_var_info_0.data.Tasks[s].Variables[j].Name,inst->Internal.FB.PLC_var_info_0.data.Tasks[s].Variables[j].Type);
											}
											else
											{
												sprintf(&inst->Internal.data.latestData,"%s,{\"name\":\"%s\",\"type\":\"%u\"}",&inst->Internal.data.latestData,&inst->Internal.FB.PLC_var_info_0.data.Tasks[s].Variables[j].Name,inst->Internal.FB.PLC_var_info_0.data.Tasks[s].Variables[j].Type);
											}
										}
										brsstrcat(&inst->Internal.data.latestData,&"]}");
									}
									brsstrcat(&inst->Internal.data.latestData,&"]}}");	
									inst->Internal.clients.client[i].commState = 1;	
									changeOccured = TRUE;
								}
								else
								{
									setError(&inst->Internal.data.latestData);
								}
								inst->Internal.clients.client[i].FB.TcpSend_0.datalen = ws_sendframe_txt(&inst->Internal.clients.client[i].data.sendbuf,&inst->Internal.data.latestData);
								if(!changeOccured)
								{
									inst->Internal.clients.client[i].commState = 0;
								}
							}
						}
						else
						{
							inst->Internal.clients.client[i].commState = 0;
						}
					}

						/* Close event. */
					else if (wfd.frame_type == WS_FR_OP_CLSE && !wfd.error)
					{
							/*
							 * We only send a CLOSE frame once, if we're already
							 * in CLOSING state, there is no need to send.
							 */
						if (inst->Internal.clients.client[i].status != WS_STATE_CLOSING)
						{
							inst->Internal.clients.client[i].status = WS_STATE_CLOSING;

							/* We only send a close frameSend close frame */
							inst->Internal.clients.client[i].FB.TcpSend_0.datalen = do_close(&wfd, -1,&inst->Internal.clients.client[i].data.sendbuf);
							inst->Internal.clients.client[i].commState = 1;
						}

						free(wfd.msg);
						break;
					}
					else
					{
						inst->Internal.clients.client[i].commState = 0;
					}

					free(wfd.msg);
				}
				else
				{
					inst->Internal.clients.client[i].commState = 0;
				}
				
				
				break;
			/*
			case 97:
				
				cc = WS_CLSE_NORMAL;
				clse_code[0] = (cc >> 8);
				clse_code[1] = (cc & 0xFF);
				brsmemset(&inst->Internal.clients.client[i].data.sendbuf,0,sizeof(inst->Internal.clients.client[i].data.sendbuf));
				inst->Internal.clients.client[i].FB.TcpSend_0.datalen = ws_sendframe(&inst->Internal.clients.client[i].data.sendbuf, (const char *)clse_code, sizeof(char) * 2, WS_FR_OP_CLSE);
				inst->Internal.clients.client[i].commState++;
				break;
			
			case 98:
				inst->Internal.clients.client[i].FB.TcpSend_0.enable = TRUE;
				inst->Internal.clients.client[i].FB.TcpSend_0.flags = tcpMSG_DONTROUTE;
				inst->Internal.clients.client[i].FB.TcpSend_0.pData = &inst->Internal.clients.client[i].data.sendbuf;
				TcpSend(&inst->Internal.clients.client[i].FB.TcpSend_0);
				
				
				if(inst->Internal.clients.client[i].FB.TcpSend_0.status == ERR_OK || inst->Internal.clients.client[i].FB.TcpSend_0.status == tcpERR_NOT_CONNECTED)
				{
					inst->Internal.clients.client[i].FB.TcpSend_0.enable = FALSE;
					TcpSend(&inst->Internal.clients.client[i].FB.TcpSend_0);
					inst->Internal.clients.client[i].commState++;
				}
					
				
				break;
			*/
			
			case 99:
				
				{
					inst->Internal.clients.client[i].FB.TcpClose_0.ident = inst->Internal.clients.client[i].ident;
					inst->Internal.clients.client[i].FB.TcpClose_0.enable = TRUE;
					TcpClose(&inst->Internal.clients.client[i].FB.TcpClose_0);
				
					if((inst->Internal.clients.client[i].FB.TcpClose_0.status == ERR_OK) || (inst->Internal.clients.client[i].FB.TcpClose_0.status == tcpERR_INVALID_IDENT))
					{
						brsmemset(&inst->Internal.clients.client[i],0,sizeof(inst->Internal.clients.client[i]));
						inst->Internal.clients.client[i].FB.TcpClose_0.enable = FALSE;
						TcpClose(&inst->Internal.clients.client[i].FB.TcpClose_0);
						inst->Internal.clients.client[i].commState = 0;
						for(int k = i; k < (inst->Internal.clients.count-1); ++k)
						{
							brsmemcpy(&inst->Internal.clients.client[k],&inst->Internal.clients.client[k+1],sizeof(inst->Internal.clients.client[0]));
							brsmemset(&inst->Internal.clients.client[k+1],0,sizeof(inst->Internal.clients.client[0]));
						}
						inst->Internal.clients.count--;
					}
				}
				break;
			
			default:
	
				break;
		}
		
		if((inst->Internal.clients.client[i].commState == 0) && !sendDone)
		{
			if(inst->Internal.clients.client[i].monitorActive)
			{
				brsmemset(&inst->Internal.data.monitorData,0,sizeof(inst->Internal.data.monitorData));
				brsstrcpy(&inst->Internal.data.monitorData,"{\"status\":\"valueChanged\",\"data\":[");
				BOOL firstWritten = FALSE;
				for(int z = 0; z < inst->Internal.clients.client[i].monitor.count; ++z)
				{
					UDINT test = 0;
					test = crc32b(inst->Internal.clients.client[i].monitor.variables[z].pv_addr,inst->Internal.clients.client[i].monitor.variables[z].size);
					if(test != inst->Internal.clients.client[i].monitor.variables[z].crc || changeOccured || inst->Internal.clients.client[i].monitor.init)
					{
						changeOccured = TRUE;
						inst->Internal.clients.client[i].monitor.variables[z].crc = test;
						brsmemset(&inst->Internal.data.latestData,0,sizeof(inst->Internal.data.latestData));
						createJSONfromMonitorVar(&inst->Internal.data.latestData,&inst->Internal.clients.client[i].monitor,z,&inst->Internal.data.latestData1,sizeof(inst->Internal.data.latestData1));
						if(firstWritten)
						{
							brsstrcat(&inst->Internal.data.monitorData,",");
							brsstrcat(&inst->Internal.data.monitorData,&inst->Internal.data.latestData);
						}
						else
						{
							brsstrcat(&inst->Internal.data.monitorData,&inst->Internal.data.latestData);
							firstWritten = TRUE;
						}
					}
				}
				if(firstWritten)
				{
					brsstrcat(&inst->Internal.data.monitorData,"]}");
					inst->Internal.clients.client[i].FB.TcpSend_0.datalen = ws_sendframe_txt(&inst->Internal.clients.client[i].data.sendbuf,&inst->Internal.data.monitorData);
					inst->Internal.clients.client[i].commState = 1;	
				}
			}
			inst->Internal.clients.client[i].monitor.init = FALSE;
		}
	}
	
	
	if(inst->Enable)
	{
		inst->Internal.FB.PLC_var_info_0.enable = 1;
		inst->Internal.FB.PLC_var_info_0.browse = 1;
		PLC_var_info(&inst->Internal.FB.PLC_var_info_0);
	}
	
}


/**
 * @brief Do the handshake process.
 *
 * @param wfd Websocket Frame Data.
 *
 * @return Returns 0 if success, a negative number otherwise.
 *
 * @attention This is part of the internal API and is documented just
 * for completeness.
 */
static int do_handshake(unsigned char *data, struct ws_frame_data *wfd,UDINT *len)
{
	char *p;        /* Last request line pointer.  */
	ssize_t n;      /* Read/Write bytes.           */

	/* Advance our pointers before the first next_byte(). */
	p = strstr((const char *)wfd->frm, "\r\n\r\n");
	if (p == NULL)
	{
		//DEBUG("An empty line with \\r\\n was expected!\n");
		return (-1);
	}
	wfd->amt_read = n;
	wfd->cur_pos = (size_t)((ptrdiff_t)(p - (char *)wfd->frm)) + 4;

	/* Get response. */
	if (get_handshake_response((char *)wfd->frm, data) < 0)
	{
		//DEBUG("Cannot get handshake response, request was: %s\n", wfd->frm);
		return (-1);
	}
	*len = strlen(data);
	/* Valid request. 
	DEBUG("Handshaked, response: \n"
		"------------------------------------\n"
		"%s"
		"------------------------------------\n",
		response);
	*/

	return (0);
}

/**
 * @brief Given a PONG message, decodes the content
 * as a int32_t number that corresponds to our
 * PONG id.
 *
 * @param msg Content to be decoded.
 *
 * @return Returns the PONG id.
 */
static inline int32_t pong_msg_to_int32(uint8_t *msg)
{
	int32_t pong_id;
	/* Decodes as big-endian. */
	pong_id = (msg[3] << 0) | (msg[2] << 8) | (msg[1] << 16) | (msg[0] << 24);
	return (pong_id);
}

/**
 * @brief Read a chunk of bytes and return the next byte
 * belonging to the frame.
 *
 * @param wfd Websocket Frame Data.
 *
 * @return Returns the byte read, or -1 if error.
 *
 * @attention This is part of the internal API and is documented just
 * for completeness.
 */
static inline int next_byte(struct ws_frame_data *wfd)
{
	ssize_t n;

	/* If empty or full. */
	/*
	if (wfd->cur_pos == 0 || wfd->cur_pos == wfd->amt_read)
	{
		if ((n = RECV(wfd->client, wfd->frm, sizeof(wfd->frm))) <= 0)
		{
			wfd->error = 1;
			//DEBUG("An error has occurred while trying to read next byte\n");
			return (-1);
		}
		wfd->amt_read = (size_t)n;
		wfd->cur_pos = 0;
	}
	*/
	if(wfd->cur_pos == wfd->amt_read)
	{
		return -1;	
	}
	return (wfd->frm[wfd->cur_pos++]);
}


/**
 * @brief Checks is a given opcode @p frame
 * belongs to a control frame or not.
 *
 * @param frame Frame opcode to be checked.
 *
 * @return Returns 1 if is a control frame, 0 otherwise.
 *
 * @attention This is part of the internal API and is documented just
 * for completeness.
 */
static inline int is_control_frame(int frame)
{
	return (
		frame == WS_FR_OP_CLSE || frame == WS_FR_OP_PING || frame == WS_FR_OP_PONG);
}

/**
 * @brief Reads the current frame isolating data from control frames.
 * The parameters are changed in order to reflect the current state.
 *
 * @param wfd Websocket Frame Data.
 * @param opcode Frame opcode.
 * @param buf Buffer to be written.
 * @param frame_length Length of the current frame.
 * @param frame_size Total size of the frame (considering CONT frames)
 *                   read until the moment.
 * @param msg_idx Message index, reflects the current buffer pointer state.
 * @param masks Masks vector.
 * @param is_fin Is FIN frame indicator.
 *
 * @return Returns 0 if success, a negative number otherwise.
 *
 * @attention This is part of the internal API and is documented just
 * for completeness.
 */
static int read_frame(struct ws_frame_data *wfd,
	int opcode,
	unsigned char **buf,
	uint64_t *frame_length,
	uint64_t *frame_size,
	uint64_t *msg_idx,
	uint8_t *masks,
	int is_fin)
{
	unsigned char *tmp; /* Tmp message.     */
	unsigned char *msg; /* Current message. */
	int cur_byte;       /* Curr byte read.  */
	uint64_t i;         /* Loop index.      */

	msg = *buf;

	/* Decode masks and length for 16-bit messages. */
	if (*frame_length == 126)
		*frame_length = (((uint64_t)next_byte(wfd)) << 8) | next_byte(wfd);

		/* 64-bit messages. */
	else if (*frame_length == 127)
	{
		*frame_length =
			(((uint64_t)next_byte(wfd)) << 56) | /* frame[2]. */
			(((uint64_t)next_byte(wfd)) << 48) | /* frame[3]. */
			(((uint64_t)next_byte(wfd)) << 40) | (((uint64_t)next_byte(wfd)) << 32) |
			(((uint64_t)next_byte(wfd)) << 24) | (((uint64_t)next_byte(wfd)) << 16) |
			(((uint64_t)next_byte(wfd)) << 8) |
			(((uint64_t)next_byte(wfd))); /* frame[9]. */
	}

	*frame_size += *frame_length;

	/*
	 * Check frame size
	 *
	 * We need to limit the amount supported here, since if
	 * we follow strictly to the RFC, we have to allow 2^64
	 * bytes. Also keep in mind that this is still true
	 * for continuation frames.
	 */
	if (*frame_size > MAX_FRAME_LENGTH)
	{
		/*
		DEBUG("Current frame from client %d, exceeds the maximum\n"
			"amount of bytes allowed (%" PRId64 "/%d)!",
		wfd->client->client_sock, *frame_size + *frame_length, MAX_FRAME_LENGTH);
		*/
			wfd->error = 1;
		return (-1);
	}

	/* Read masks. */
	masks[0] = next_byte(wfd);
	masks[1] = next_byte(wfd);
	masks[2] = next_byte(wfd);
	masks[3] = next_byte(wfd);

	/*
	 * Abort if error.
	 *
	 * This is tricky: we may have multiples error codes from the
	 * previous next_bytes() calls, but, since we're only setting
	 * variables and flags, there is no major issue in setting
	 * them wrong _if_ we do not use their values, thing that
	 * we do here.
	 */
	if (wfd->error)
		return (-1);

	/*
	 * Allocate memory.
	 *
	 * The statement below will allocate a new chunk of memory
	 * if msg is NULL with size total_length. Otherwise, it will
	 * resize the total memory accordingly with the message index
	 * and if the current frame is a FIN frame or not, if so,
	 * increment the size by 1 to accommodate the line ending \0.
	 */
	if (*frame_length > 0)
	{
		if (!is_control_frame(opcode))
		{
			tmp = realloc(
				msg, sizeof(unsigned char) * (*msg_idx + *frame_length + is_fin));
			if (!tmp)
			{
				/*
				DEBUG("Cannot allocate memory, requested: % " PRId64 "\n",
				(*msg_idx + *frame_length + is_fin));
				*/
					wfd->error = 1;
				return (-1);
			}
			msg = tmp;
			*buf = msg;
		}

		/* Copy to the proper location. */
		for (i = 0; i < *frame_length; i++, (*msg_idx)++)
		{
			/* We were able to read? .*/
			cur_byte = next_byte(wfd);
			if (cur_byte == -1)
				return (-1);

			msg[*msg_idx] = cur_byte ^ masks[i % 4];
		}
	}

	/* If we're inside a FIN frame, lets... */
	if (is_fin && *frame_size > 0)
	{
		/* Increase memory if our FIN frame is of length 0. */
		if (!*frame_length && !is_control_frame(opcode))
		{
			tmp = realloc(msg, sizeof(unsigned char) * (*msg_idx + 1));
			if (!tmp)
			{	
				/*
				DEBUG("Cannot allocate memory, requested: %" PRId64 "\n",
				(*msg_idx + 1));
				*/
					wfd->error = 1;
				return (-1);
			}
			msg = tmp;
			*buf = msg;
		}
		msg[*msg_idx] = '\0';
	}

	return (0);
}


/**
 * @brief Reads the next frame, whether if a TXT/BIN/CLOSE
 * of arbitrary size.
 *
 * @param wfd Websocket Frame Data.
 *
 * @return Returns 0 if success, a negative number otherwise.
 *
 * @attention This is part of the internal API and is documented just
 * for completeness.
 */
static int next_frame(struct ws_frame_data *wfd)
{
	unsigned char *msg_data; /* Data frame.                */
	unsigned char *msg_ctrl; /* Control frame.             */
	uint8_t masks_data[4];   /* Masks data frame array.    */
	uint8_t masks_ctrl[4];   /* Masks control frame array. */
	uint64_t msg_idx_data;   /* Current msg index.         */
	uint64_t msg_idx_ctrl;   /* Current msg index.         */
	uint64_t frame_length;   /* Frame length.              */
	uint64_t frame_size;     /* Current frame size.        */
	uint32_t utf8_state;     /* Current UTF-8 state.       */
	int32_t pong_id;         /* Current PONG id.           */
	uint8_t opcode;          /* Frame opcode.              */
	uint8_t is_fin;          /* Is FIN frame flag.         */
	uint8_t mask;            /* Mask.                      */
	int cur_byte;            /* Current frame byte.        */

	msg_data = NULL;
	msg_ctrl = wfd->msg_ctrl;
	is_fin = 0;
	frame_length = 0;
	frame_size = 0;
	msg_idx_data = 0;
	msg_idx_ctrl = 0;
	wfd->frame_size = 0;
	wfd->frame_type = -1;
	wfd->msg = NULL;
	mask = 0;
	utf8_state = UTF8_ACCEPT;

	/* Read until find a FIN or a unsupported frame. */
	do
	{
		/*
		 * Obs: next_byte() can return error if not possible to read the
		 * next frame byte, in this case, we return an error.
		 *
		 * However, please note that this check is only made here and in
		 * the subsequent next_bytes() calls this also may occur too.
		 * wsServer is assuming that the client only create right
		 * frames and we will do not have disconnections while reading
		 * the frame but just when waiting for a frame.
		 */
		cur_byte = next_byte(wfd);
		if (cur_byte == -1)
			return (-1);

		is_fin = (cur_byte & 0xFF) >> WS_FIN_SHIFT;
		opcode = (cur_byte & 0xF);

		/*
		 * Check for RSV field.
		 *
		 * Since wsServer do not negotiate extensions if we receive
		 * a RSV field, we must drop the connection.
		 */
		if (cur_byte & 0x70)
		{
			//DEBUG("RSV is set while wsServer do not negotiate extensions!\n");
			wfd->error = 1;
			break;
		}

		/*
		 * Check if the current opcode makes sense:
		 * a) If we're inside a cont frame but no previous data frame
		 *
		 * b) If we're handling a data-frame and receive another data
		 *    frame. (it's expected to receive only CONT or control
		 *    frames).
		 *
		 * It is worth to note that in a), we do not need to check
		 * if the previous frame was FIN or not: if was FIN, an
		 * on_message event was triggered and this function returned;
		 * so the only possibility here is a previous non-FIN data
		 * frame, ;-).
		 */
		if ((wfd->frame_type == -1 && opcode == WS_FR_OP_CONT) ||
			(wfd->frame_type != -1 && !is_control_frame(opcode) &&
			opcode != WS_FR_OP_CONT))
		{
			/*
			DEBUG("Unexpected frame was received!, opcode: %d, previous: %d\n",
				opcode, wfd->frame_type);
			*/
			wfd->error = 1;
			break;
		}

		/* Check if one of the valid opcodes. */
		if (opcode == WS_FR_OP_TXT || opcode == WS_FR_OP_BIN ||
			opcode == WS_FR_OP_CONT || opcode == WS_FR_OP_PING ||
			opcode == WS_FR_OP_PONG || opcode == WS_FR_OP_CLSE)
		{
			/*
			 * Check our current state: if CLOSING, we only accept close
			 * frames.
			 *
			 * Since the server may, at any time, asynchronously, asks
			 * to close the client connection, we should terminate
			 * immediately.
			 */
			if ((wfd->client == WS_STATE_CLOSING) &&
				opcode != WS_FR_OP_CLSE)
			{
				/*
				DEBUG("Unexpected frame received, expected CLOSE (%d), "
					"received: (%d)",
					WS_FR_OP_CLSE, opcode);
				*/
				wfd->error = 1;
				break;
			}

			/* Only change frame type if not a CONT frame. */
			if (opcode != WS_FR_OP_CONT && !is_control_frame(opcode))
				wfd->frame_type = opcode;

			mask = next_byte(wfd);
			frame_length = mask & 0x7F;
			frame_size = 0;
			msg_idx_ctrl = 0;

			/*
			 * We should deny non-FIN control frames or that have
			 * more than 125 octets.
			 */
			if (is_control_frame(opcode) && (!is_fin || frame_length > 125))
			{
				/*
				DEBUG("Control frame bigger than 125 octets or not a FIN "
					"frame!\n");
				*/
				wfd->error = 1;
				break;
			}

			/* Normal data frames. */
			if (opcode == WS_FR_OP_TXT || opcode == WS_FR_OP_BIN ||
				opcode == WS_FR_OP_CONT)
			{
				if (read_frame(wfd, opcode, &msg_data, &frame_length,
					&wfd->frame_size, &msg_idx_data, masks_data, is_fin) < 0)
					break;

#ifdef VALIDATE_UTF8
				/* UTF-8 Validate partial (or not) frame. */
				if (wfd->frame_type == WS_FR_OP_TXT)
				{
					if (is_fin)
					{
						if (is_utf8_len_state(
						msg_data + (msg_idx_data - frame_length),
						frame_length, utf8_state) != UTF8_ACCEPT)
						{
							//DEBUG("Dropping invalid complete message!\n");
						wfd->error = 1;
						}
					}
	
					/* Check current state for a CONT or initial TXT frame. */
					else
					{
						utf8_state = is_utf8_len_state(
						msg_data + (msg_idx_data - frame_length), frame_length,
						utf8_state);
		
						/* We can be in any state, except reject. */
						if (utf8_state == UTF8_REJECT)
						{
						//	DEBUG("Dropping invalid cont/initial frame!\n");
						wfd->error = 1;
						}
					}
				}
#endif
			}

			/*
			 * We _may_ send a PING frame if the ws_ping() routine was invoked.
			 *
			 * If the content is invalid and/or differs the size, ignore it.
			 * (maybe unsolicited PONG).
			 */
			else if (opcode == WS_FR_OP_PONG)
			{
				if (read_frame(wfd, opcode, &msg_ctrl, &frame_length, &frame_size,
					&msg_idx_ctrl, masks_ctrl, is_fin) < 0)
					break;

				is_fin = 0;

				/* If there is no content and/or differs the size, ignore it. */
				/*
				if (frame_size != sizeof(wfd->client->last_pong_id))
					continue;
				*/

				/*
				 * Our PONG id should be positive and smaller than our
				 * current PING id. If not, ignore.
				 */

				pong_id = pong_msg_to_int32(msg_ctrl);
				
				/*
				wfd->client->last_pong_id = pong_id;
				*/
				/* clang-format on */
				continue;
			}

				/* We should answer to a PING frame as soon as possible. */
			else if (opcode == WS_FR_OP_PING)
			{
				if (read_frame(wfd, opcode, &msg_ctrl, &frame_length, &frame_size,
					&msg_idx_ctrl, masks_ctrl, is_fin) < 0)
					break;
				/*
				if (do_pong(wfd, frame_size) < 0)
					break;
				*/
				/* Quick hack to keep our loop. */
				is_fin = 0;
			}

				/* We interrupt the loop as soon as we find a CLOSE frame. */
			else
			{
				if (read_frame(wfd, opcode, &msg_ctrl, &frame_length, &frame_size,
					&msg_idx_ctrl, masks_ctrl, is_fin) < 0)
					break;

#ifdef VALIDATE_UTF8
				/* If there is a close reason, check if it is UTF-8 valid. */
				if (frame_size > 2 && !is_utf8_len(msg_ctrl + 2, frame_size - 2))
				{
				//DEBUG("Invalid close frame payload reason! (not UTF-8)\n");
				wfd->error = 1;
				break;
				}
#endif

				/* Since we're aborting, we can scratch the 'data'-related
				 * vars here. */
				wfd->frame_size = frame_size;
				wfd->frame_type = WS_FR_OP_CLSE;
				free(msg_data);
				return (0);
			}
		}

			/* Anything else (unsupported frames). */
		else
		{
			DEBUG("Unsupported frame opcode: %d\n", opcode);
			/* We should consider as error receive an unknown frame. */
			wfd->frame_type = opcode;
			wfd->error = 1;
		}

	} while (!is_fin && !wfd->error);

	/* Check for error. */
	if (wfd->error)
	{
		free(msg_data);
		wfd->msg = NULL;
		return (-1);
	}

	wfd->msg = msg_data;
	return (0);
}


/**
 * @brief Sends a close frame, accordingly with the @p close_code
 * or the message inside @p wfd.
 *
 * @param wfd Websocket Frame Data.
 * @param close_code Websocket close code.
 *
 * @return Returns 0 if success, a negative number otherwise.
 *
 * @attention This is part of the internal API and is documented just
 * for completeness.
 */
static int do_close(struct ws_frame_data *wfd, int close_code, unsigned char *data)
{
	int cc; /* Close code.           */
	int len = 0;
	/* If custom close-code. */
	if (close_code != -1)
	{
		cc = close_code;
		goto custom_close;
	}

	/* If empty or have a close reason, just re-send. */
	if (wfd->frame_size == 0 || wfd->frame_size > 2)
		goto send;

	/* Parse close code and check if valid, if not, we issue an protocol error.
	 */
	if (wfd->frame_size == 1)
		cc = wfd->msg_ctrl[0];
	else
		cc = ((int)wfd->msg_ctrl[0]) << 8 | wfd->msg_ctrl[1];

	/* Check if it's not valid, if so, we send a protocol error (1002). */
	if ((cc < 1000 || cc > 1003) && (cc < 1007 || cc > 1011) &&
		(cc < 3000 || cc > 4999))
	{
		cc = WS_CLSE_PROTERR;

		custom_close:
			wfd->msg_ctrl[0] = (cc >> 8);
		wfd->msg_ctrl[1] = (cc & 0xFF);

		len = ws_sendframe(data, (const char *)wfd->msg_ctrl, sizeof(char) * 2,
			WS_FR_OP_CLSE);
		return (0);
	}

	/* Send the data inside wfd->msg_ctrl. */
	send:
		len = ws_sendframe(data, (const char *)wfd->msg_ctrl, wfd->frame_size,
			WS_FR_OP_CLSE);
		
	return len;
}

/**
 * @brief Creates and send an WebSocket frame with some payload data.
 *
 * This routine is intended to be used to create a websocket frame for
 * a given type e sending to the client. For higher level routines,
 * please check @ref ws_sendframe_txt and @ref ws_sendframe_bin.
 *
 * @param client Target to be send. If NULL, broadcast the message.
 * @param msg    Message to be send.
 * @param size   Binary message size.
 * @param type   Frame type.
 *
 * @return Returns the number of bytes written, -1 if error.
 *
 * @note If @p size is -1, it is assumed that a text frame is being sent,
 * otherwise, a binary frame. In the later case, the @p size is used.
 */
int ws_sendframe(unsigned char *data, const char *msg, uint64_t size, int type)
{
	unsigned char *response; /* Response data.     */
	unsigned char frame[10]; /* Frame.             */
	uint8_t idx_first_rData; /* Index data.        */
	uint64_t length;         /* Message length.    */
	int idx_response;        /* Index response.    */
	ssize_t output;          /* Bytes sent.        */
	ssize_t send_ret;        /* Ret send function  */
	uint64_t i;              /* Loop index.        */
	

	frame[0] = (WS_FIN | type);
	length = (uint64_t)size;

	/* Split the size between octets. */
	if (length <= 125)
	{
		frame[1] = length & 0x7F;
		idx_first_rData = 2;
	}

		/* Size between 126 and 65535 bytes. */
	else if (length >= 126 && length <= 65535)
	{
		frame[1] = 126;
		frame[2] = (length >> 8) & 255;
		frame[3] = length & 255;
		idx_first_rData = 4;
	}

		/* More than 65535 bytes. */
	else
	{
		frame[1] = 127;
		frame[2] = (unsigned char)((length >> 56) & 255);
		frame[3] = (unsigned char)((length >> 48) & 255);
		frame[4] = (unsigned char)((length >> 40) & 255);
		frame[5] = (unsigned char)((length >> 32) & 255);
		frame[6] = (unsigned char)((length >> 24) & 255);
		frame[7] = (unsigned char)((length >> 16) & 255);
		frame[8] = (unsigned char)((length >> 8) & 255);
		frame[9] = (unsigned char)(length & 255);
		idx_first_rData = 10;
	}

	/* Add frame bytes. */
	idx_response = 0;
	/*
	response = malloc(sizeof(unsigned char) * (idx_first_rData + length + 1));
	if (!response)
		return (-1);
	*/

	for (i = 0; i < idx_first_rData; i++)
	{
		data[i] = frame[i];
		idx_response++;
	}

	/* Add data bytes. */
	for (i = 0; i < length; i++)
	{
		data[idx_response] = msg[i];
		idx_response++;
	}

	data[idx_response] = '\0';

	return idx_response;
}


/**
 * @brief Sends a WebSocket text frame.
 *
 * @param data buffer to be send. If NULL, broadcast the message.
 * @param msg    Message to be send, null terminated.
 *
 * @return Returns the number of bytes written, -1 if error.
 */
int ws_sendframe_txt(unsigned char *data, const char *msg)
{
	return ws_sendframe(data, msg, (uint64_t)strlen(msg), WS_FR_OP_TXT);
}

/**
 * @brief Sends a WebSocket binary frame.
 *
 * @param client Target to be send. If NULL, broadcast the message.
 * @param msg    Message to be send.
 * @param size   Binary message size.
 *
 * @return Returns the number of bytes written, -1 if error.
 */
int ws_sendframe_bin(unsigned char *data, const char *msg, uint64_t size)
{
	return ws_sendframe(data, msg, size, WS_FR_OP_BIN);
}

/**
 * @brief Read JSON data
 *
 * @param data JSON data to be read
 * @param memberstr JSON member to be read
 * @param result JSON member to be read
 *
 * @return Returns member value, -1 if error.
 */
int _json_get_member(unsigned char *data,unsigned char *memberstr,unsigned char *result)
{
	/*TODO: Add your code here*/
	char buf[2000];
	char member[32];
	char memberValue[256];
	brsstrcpy((UDINT)&buf,data);
	
	JSON_Value *jsonRoot = json_parse_string(buf);
	brsstrcpy((UDINT)&member,memberstr);
	int retVal = -1;
	if(jsonRoot != NULL)
	{
		JSON_Value *data = json_object_get_value(json_object(jsonRoot), member);
		if(data != NULL)
		{
			/*
			if(json_value_get_type(data) == JSONArray)
			{
				JSON_Array *arr = json_value_get_array(data);
				if(arr != NULL)
				{
					size_t i;
					for (i = 0; i < json_array_get_count(arr); i++) {
						JSON_Object *arrValue = json_array_get_object(arr,i);
						if(arrValue != NULL)
						{
							const char *variable = NULL;
							const char *value = NULL;
							unsigned long pv_address = 0;
							unsigned long pv_len = 0;
							unsigned long pv_typ = 0;
							unsigned long pv_dim = 0;
							unsigned int status = 0;
							signed short tempSINT = 0;
							unsigned short tempUSINT = 0;
							int tempINT = 0;
							unsigned int tempUINT = 0;
							signed long tempDINT = 0;
							unsigned long tempUDINT = 0;
							double tempREAL = 0;
							variable = json_object_dotget_string(arrValue,"variable");
							value = json_object_dotget_string(arrValue,"value");
							
							status = PV_xgetadr((UDINT)variable,(UDINT)&pv_address,(UDINT)&pv_len);
							status = PV_ninfo((UDINT)variable,(UDINT)&pv_typ,(UDINT)&pv_len,(UDINT)&pv_dim);
							retVal = status;
							if(status == 0)
							{
								switch(pv_typ)
								{
									case 1:
										if((strcmp(value,"true") == 0) || (strcmp(value,"1") == 0))
										{
											tempUSINT = 1;
											brsmemcpy(pv_address,(UDINT)&tempUSINT,1);
										}
										else if((strcmp(value,"false") == 0) || (strcmp(value,"0") == 0))
										{
											tempUSINT = 0;
											brsmemcpy(pv_address,(UDINT)&tempUSINT,1);
										}
										break;
									
									case 2:
										
										tempSINT = (signed short) atoi(value);
										brsmemcpy(pv_address,(UDINT)&tempSINT,1);
										break;
									
									case 3:
										
										tempINT = (int) atoi(value);
										brsmemcpy(pv_address,(UDINT)&tempINT,2);
										break;
									
									
									case 4:
										
										tempDINT = atoi(value);
										brsmemcpy(pv_address,(UDINT)&tempDINT,4);
										break;
									
									case 5:
										
										tempUSINT = (unsigned short) atoi(value);
										brsmemcpy(pv_address,(UDINT)&tempUSINT,1);
										break;
									
									case 6:
										
										tempUINT = (unsigned int) atoi(value);
										brsmemcpy(pv_address,(UDINT)&tempUINT,2);
										break;
									
									case 7:
										
										tempUDINT = (unsigned long) atoi(value);
										brsmemcpy(pv_address,(UDINT)&tempUDINT,4);
										break;
									
									case 8:
										
										tempREAL = atof(value);
										brsmemcpy(pv_address,(UDINT)&tempREAL,4);
										break;
									
									case 9:
										
										brsstrcpy(pv_address,value);
										break;
										
								
									default:
										retVal = 0;
										break;
									
								}
							}
						}
					}
				}

			}
			*/
			const char *tempStr = NULL;
			tempStr = json_value_get_string(data);
			if(tempStr != NULL)
			{
				brsstrcpy(result,tempStr);	
				retVal = 0;
			}
			else
			{
				retVal = -1;	
			}
		}
		
	}
	
	json_value_free(jsonRoot);
	return retVal;
}

int _json_get_array_memberString(unsigned char *data,unsigned char *arraystr,unsigned char *target,int index,UDINT result)
{
	/*TODO: Add your code here*/
	char buf[8000];
	char member[32];
	char memberValue[2000];
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
				tempStr = json_object_dotget_string(arrValue,target);
				if(tempStr != NULL)
				{
					brsstrcpy(result,tempStr);	
					retVal = 0;
				}
			}
		}
	}

	json_value_free(jsonRoot);
	return retVal;
}


int _json_get_array_member(unsigned char *data,unsigned char *arraystr,unsigned char *target,int index,REAL *result)
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
				tempStr = json_object_dotget_string(arrValue,target);
				if(tempStr != NULL)
				{
					brsstrcpy(result,tempStr);	
					*result =brsatof((UDINT)tempStr);
					retVal = 0;
				}
			}
		}
	}

	json_value_free(jsonRoot);
	return retVal;
}





	
int _json_get_array_array_member(unsigned char *data,unsigned char *arraystr,int mainIndex,unsigned char *target,int index,unsigned char *targetMember,REAL *result)
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
			JSON_Object *arrValue = json_array_get_object(arr,(size_t)mainIndex);
			if(arrValue != NULL)
			{
				JSON_Array *arr1 = json_object_dotget_array(arrValue, target);
				if(arr1 != NULL)
				{
					JSON_Object *arrValue1 = json_array_get_object(arr1,(size_t)index);
					if(arrValue1 != NULL)
					{
						double temp = 0;
						temp = json_object_dotget_number(arrValue1, targetMember);
						*result = (REAL)temp;
					}
				}
			}
		}
	}

	json_value_free(jsonRoot);
	return retVal;
}

int _json_get_array_memberStr(unsigned char *data,unsigned char *arraystr,unsigned char *target,int index,unsigned char *result)
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
				tempStr = json_object_dotget_string(arrValue,target);
				if(tempStr != NULL)
				{
					brsstrcpy(result,tempStr);	
					retVal = 0;
				}
				else
				{
					retVal = -1;	
				}
			}
		}
	}

	json_value_free(jsonRoot);
	return retVal;
}



int _json_dotget_member(unsigned char *data,unsigned char *memberstr,unsigned char *result)
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
		const char *tempStr = NULL;
		tempStr = json_object_dotget_string(json_object(jsonRoot), member);
		if(tempStr != NULL)
		{
			brsstrcpy(result,tempStr);	
			retVal = 0;
		}
		else
		{
			retVal = -1;	
		}
		
	}
	
	json_value_free(jsonRoot);
	return retVal;
}

int _json_dotget_number(unsigned char *data,unsigned char *memberstr,REAL *result)
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
		*result = (REAL)temp;
		//brsmemcpy(result,(UDINT)&temp,4);	
		
	}
	
	json_value_free(jsonRoot);
	return retVal;
}

void setError(unsigned char *data)
{
	brsstrcpy(data,"{\"status\":\"error while with input data\"}");
}

int storeMonitorVariables(unsigned char *input,void *context)
{
	monitor_var_typ *monitor = (monitor_var_typ *) context;
	brsmemset(monitor,0,sizeof(*monitor));
	char *saveptr;         /* strtok_r() pointer. */
	char *s;               /* Current string.     */
	int ret;               /* Return value.       */

	saveptr = NULL;
	int count = 0;
	for (s = strtok_r(input, ",", &saveptr); s != NULL;
		s = strtok_r(NULL, ",", &saveptr))
	{
		if(s != NULL)
		{
			brsstrcpy(&monitor->variables[monitor->count].name,s);
			brsstrcpy(&monitor->variables[monitor->count].queryName,s);
			++monitor->count;
		}
	}
	return 0;
}


int verifyParameters(void *context)
{
	monitor_var_typ *monitor = (monitor_var_typ *) context;
	int i = 0;
	int returnValue = 0;
	for(i = 0; i < monitor->count; ++i)
	{
		if(PV_xgetadr(&monitor->variables[i].name,&monitor->variables[i].pv_addr,&monitor->variables[i].size) != 0)
		{
			if(i < (monitor->count -1))
			{
				//shift array 
				brsmemcpy(&monitor->variables[i],&monitor->variables[i+1],sizeof(monitor->variables[0])*((monitor->count-1)-i));
			}
			monitor->count--;
			i--;
		}
		else
		{
			returnValue++;	
		}
	}
	return returnValue;
}

int prepareMonitorMessage(unsigned char *msg, void *context)
{
	monitor_var_typ *monitor = (monitor_var_typ *) context;
	int i = 0;
	for(i = 0; i < monitor->count; ++i)
	{
		if(monitor->variables[i].pv_addr != 0)
		{
			
		}
	}
	return 0;
}

void createJSONfromMonitorVars(unsigned char *buffer, void *context,unsigned char *buffer1,unsigned long len)
{
	int i = 0;
	monitor_var_typ *monitor = (monitor_var_typ *) context;
	brsstrcpy(buffer,"{");
	
	for( i = 0; i < monitor->count; ++i)
	{
		brsmemset(buffer1,0,len);
		pvElements(&monitor->variables[i].name,buffer1,&monitor->variables[i].queryName,TRUE,TRUE);
		brsstrcat(buffer,buffer1);
		if(i < (monitor->count -1))
		{
			brsstrcat(buffer,",");
		}
		else
		{
			brsstrcat(buffer,"}");
		}
	}
}

void createJSONfromMonitorVar(unsigned char *buffer, void *context,int index, unsigned char *buffer1,unsigned long len)
{
	monitor_var_typ *monitor = (monitor_var_typ *) context;
	brsstrcpy(buffer,"{");
	
	brsmemset(buffer1,0,len);
	pvElements(&monitor->variables[index].name,buffer1,&monitor->variables[index].queryName,TRUE,TRUE);
	brsstrcat(buffer,buffer1);
	brsstrcat(buffer,"}");
}




UDINT crc32b(UDINT start_addr, UDINT size) {
	int i, j;
	unsigned int byte, crc;

	i = 0;
	crc = 0;
	byte = 0;
	while (i < size) {
		brsmemcpy((UDINT)&byte,start_addr+i,1);
		//byte = message[i];            // Get next byte.
		crc = crc + byte;
		i = i + 1;
	}
	return (UDINT)crc;
}



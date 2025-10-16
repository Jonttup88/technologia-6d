/* Automation Studio generated header file */
/* Do not edit ! */
/* BrAbbRws 2.0.0 */

#ifndef _BRABBRWS_
#define _BRABBRWS_
#ifdef __cplusplus
extern "C" 
{
#endif
#ifndef _BrAbbRws_VERSION
#define _BrAbbRws_VERSION 2.0.0
#endif

#include <bur/plctypes.h>

#ifndef _BUR_PUBLIC
#define _BUR_PUBLIC
#endif
#ifdef _SG3
		#include "operator.h"
		#include "astime.h"
		#include "Crypto.h"
		#include "AsHttp.h"
		#include "standard.h"
		#include "AsBrMath.h"
		#include "ArEventLog.h"
		#include "ArSsl.h"
#endif
#ifdef _SG4
		#include "operator.h"
		#include "astime.h"
		#include "Crypto.h"
		#include "AsHttp.h"
		#include "standard.h"
		#include "AsBrMath.h"
		#include "ArEventLog.h"
		#include "ArSsl.h"
#endif
#ifdef _SGC
		#include "operator.h"
		#include "astime.h"
		#include "Crypto.h"
		#include "AsHttp.h"
		#include "standard.h"
		#include "AsBrMath.h"
		#include "ArEventLog.h"
		#include "ArSsl.h"
#endif


/* Datatypes and datatypes of function blocks */
typedef enum BrAbbRwsStatusIDEnum
{	RWS_ERROR_NONE,
	RWS_CORE_INVALID_HOSTPORT,
	RWS_CORE_INVALID_SERVERIP,
	RWS_CORE_INVALID_USERNAME,
	RWS_CORE_INVALID_PASSWORD,
	RWS_CORE_INVALID_WS_VERSION,
	RWS_CORE_SSL_EMPTY,
	RWS_CORE_INVALID_SSL,
	RWS_BAD_HTTP_REQEST,
	RWS_FORBIDDEN_HTTP_REQEST,
	RWS_AUTHENTICATION_FAILURE,
	RWS_GENERIC_HTTP_REQEST_ERROR,
	RWS_HTTP_REQEST_TIMEOUT,
	RWS_ERROR_ON_CORE_FB,
	RWS_INVALID_IDENT,
	RWS_MULTIPLE_COMMANDS,
	RWS_INVALID_MECHUNIT,
	RWS_INVALID_SIGNAL,
	RWS_INVALID_DATA_ADR,
	RWS_INVALID_SIGNAL_MODE,
	RWS_LOG_CREATE_ERROR,
	RWS_LOG_GET_IDENT_ERROR,
	RWS_LOG_GET_LAST_RECORD_ERROR,
	RWS_LOG_READ_ERROR,
	RWS_LOG_WRITE_ERROR,
	RWS_INVALID_VARIABLE,
	RWS_INVALID_TASK,
	RWS_INVALID_MODULE,
	RWS_STRING_TOO_SHORT,
	RWS_INVALID_PARAMETER,
	RWS_INVALID_CMD_IN_CURRENT_STATE,
	RWS_TCP_CONNECTION_CLOSED
} BrAbbRwsStatusIDEnum;

typedef enum BrAbbRwsCommonRWVersionEnum
{	BR_ABB_RWS_VERSION_V1,
	BR_ABB_RWS_VERSION_V2
} BrAbbRwsCommonRWVersionEnum;

typedef enum BrAbbRwsCoreInternalStepEnum
{	STEP_CORE_WAIT_ENABLE,
	STEP_CORE_GET_SSL_IDENT,
	STEP_CORE_SCAN_REQUEST_BUFFER,
	STEP_CORE_PROCESS_REQUEST,
	STEP_CORE_PROCESS_RESPONSE,
	STEP_CORE_UPDATE_REQUEST_BUFFER,
	STEP_CORE_ERROR
} BrAbbRwsCoreInternalStepEnum;

typedef enum BrAbbRwsRapidCmdStopModeEnum
{	BR_ABB_RWS_CMD_STOPMODE_STOP,
	BR_ABB_RWS_CMD_STOPMODE_QSTOP,
	BR_ABB_RWS_CMD_STOPMODE_CYCLE,
	BR_ABB_RWS_CMD_STOPMODE_INSTR
} BrAbbRwsRapidCmdStopModeEnum;

typedef enum BrAbbRwsRapidCmdStopUsetEnum
{	BR_ABB_RWS_CMD_STOP_USET_NORMAL,
	BR_ABB_RWS_CMD_STOP_USET_ALL_TSK
} BrAbbRwsRapidCmdStopUsetEnum;

typedef enum BrAbbRwsRapidCmdRegainEnum
{	BR_ABB_RWS_CMD_REGAIN_CONTINUE,
	BR_ABB_RWS_CMD_REGAIN_REGAIN,
	BR_ABB_RWS_CMD_REGAIN_CLEAR,
	BR_ABB_RWS_CMD_REGAIN_ENTCONSUME
} BrAbbRwsRapidCmdRegainEnum;

typedef enum BrAbbRwsRapidCmdExecuteModeEnum
{	RWS_CMD_EXEMODE_CONTINUE,
	RWS_CMD_EXEMODE_STEP_IN,
	RWS_CMD_EXEMODE_STEP_OVER,
	RWS_CMD_EXEMODE_STEP_OUT,
	RWS_CMD_EXEMODE_STEP_BACK,
	RWS_CMD_EXEMODE_STEP_LAST,
	RWS_CMD_EXEMODE_STEP_MOTION
} BrAbbRwsRapidCmdExecuteModeEnum;

typedef enum BrAbbRwsRapidCmdCycleEnum
{	BR_ABB_RWS_CMD_CYCLE_FOREVER,
	BR_ABB_RWS_CMD_CYCLE_AS_IS,
	BR_ABB_RWS_CMD_CYCLE_ONCE
} BrAbbRwsRapidCmdCycleEnum;

typedef enum BrAbbRwsRapidCmdConditionEnum
{	BR_ABB_RWS_CMD_CONDITION_NONE,
	BR_ABB_RWS_CMD_CONDITION_CHAIN
} BrAbbRwsRapidCmdConditionEnum;

typedef enum BrAbbRwsRapidCmdStopBPEnum
{	BR_ABB_RWS_CMD_STOP_BP_DISABLED,
	BR_ABB_RWS_CMD_STOP_BP_ENABLED
} BrAbbRwsRapidCmdStopBPEnum;

typedef enum BrAbbRwsRapidCmdTskByTSPEnum
{	BR_ABB_RWS_CMD_ALL_TASK_FALSE,
	BR_ABB_RWS_CMD_ALL_TASK_TRUE
} BrAbbRwsRapidCmdTskByTSPEnum;

typedef enum BrAbbRwsRapidCmdRestartModeEnum
{	BR_ABB_RWS_CMD_MODE_RESTART,
	BR_ABB_RWS_CMD_MODE_ISTART,
	BR_ABB_RWS_CMD_MODE_PSTART,
	BR_ABB_RWS_CMD_MODE_BSTART
} BrAbbRwsRapidCmdRestartModeEnum;

typedef enum BrAbbRwsRapidCmdStepEnum
{	BR_ABB_RWS_CMD_WAIT_ENABLE,
	BR_ABB_RWS_CMD_WAIT_REQUEST,
	BR_ABB_RWS_CMD_WRITE_REQUEST,
	BR_ABB_RWS_CMD_PROCESS_RESPONSE,
	BR_ABB_RWS_CMD_COMMAND_RESET,
	BR_ABB_RWS_CMD_ERROR
} BrAbbRwsRapidCmdStepEnum;

typedef enum BrAbbRwsCoordSystemEnum
{	BR_ABB_RWS_STATE_CS_DEFAULT,
	BR_ABB_RWS_STATE_CS_BASE,
	BR_ABB_RWS_STATE_CS_WORLD,
	BR_ABB_RWS_STATE_CS_TOOL,
	BR_ABB_RWS_STATE_CS_WOBJ
} BrAbbRwsCoordSystemEnum;

typedef enum BrAbbRwsStateInternalStepEnum
{	STEP_STATE_WAIT_ENABLE,
	STEP_STATE_WAIT_REQUEST,
	STEP_STATE_WRITE_REQUEST,
	STEP_STATE_PROCESS_RESPONSE,
	STEP_STATE_WAIT_COMMANDS_RESET,
	STEP_STATE_ERROR
} BrAbbRwsStateInternalStepEnum;

typedef enum BrAbbRwsStateRapidStateEnum
{	RWS_STATE_RAPID_UNDEFINED,
	RWS_STATE_RAPID_RUNNING,
	RWS_STATE_RAPID_STOPPED
} BrAbbRwsStateRapidStateEnum;

typedef enum BrAbbRwsStateMotorStateEnum
{	RWS_STATE_MOTORS_UNDEFINED,
	RWS_STATE_MOTORS_INIT,
	RWS_STATE_MOTORS_OFF,
	RWS_STATE_MOTORS_ON,
	RWS_STATE_MOTORS_GUARDSTOP,
	RWS_STATE_MOTORS_ESTOP,
	RWS_STATE_MOTORS_ESTOP_RESET,
	RWS_STATE_MOTORS_SYSFAIL
} BrAbbRwsStateMotorStateEnum;

typedef enum BrAbbRwsStateActiveModeEnum
{	RWS_STATE_MODE_UNDEFINED,
	RWS_STATE_MODE_MANUAL_SLOW,
	RWS_STATE_MODE_MANUAL_FAST,
	RWS_STATE_MODE_MANUAL_FAST_REQ,
	RWS_STATE_MODE_AUTOMAT,
	RWS_STATE_MODE_AUTOMAT_REQ,
	RWS_STATE_MODE_INIT
} BrAbbRwsStateActiveModeEnum;

typedef enum BrAbbRwsSignalSignalsTypesEnum
{	BR_ABB_RWS_SIGNALTYPE_DI,
	BR_ABB_RWS_SIGNALTYPE_DO,
	BR_ABB_RWS_SIGNALTYPE_GI,
	BR_ABB_RWS_SIGNALTYPE_GO,
	BR_ABB_RWS_SIGNALTYPE_AI,
	BR_ABB_RWS_SIGNALTYPE_AO
} BrAbbRwsSignalSignalsTypesEnum;

typedef enum BrAbbRwsSignalInternalStepEnum
{	BR_ABB_RWS_STEP_WAIT_ENABLE,
	BR_ABB_RWS_STEP_WAIT_REQUEST,
	BR_ABB_RWS_STEP_WRITE_REQUEST,
	BR_ABB_RWS_STEP_PROCESS_RESPONSE,
	BR_ABB_RWS_STEP_COMMANDS_RESET,
	BR_ABB_RWS_STEP_ERROR
} BrAbbRwsSignalInternalStepEnum;

typedef enum BrAbbRwsSignalParSetModeEnum
{	BR_ABB_RWS_SIGNAL_MODE_VALUE,
	BR_ABB_RWS_SIGNAL_MODE_INVERT,
	BR_ABB_RWS_SIGNAL_MODE_PULSE
} BrAbbRwsSignalParSetModeEnum;

typedef enum BrAbbRwsVariableValueTypeEnum
{	BR_ABB_RWS_VAR_BOOL,
	BR_ABB_RWS_VAR_NUM,
	BR_ABB_RWS_VAR_STRING,
	BR_ABB_RWS_VAR_ROBTARGET,
	BR_ABB_RWS_VAR_JOINTTARGET,
	BR_ABB_RWS_VAR_TOOLDATA,
	BR_ABB_RWS_VAR_WOBJDATA,
	BR_ABB_RWS_VAR_POSE
} BrAbbRwsVariableValueTypeEnum;

typedef enum BrAbbRwsVariableInternalStepEnum
{	STEP_VAR_WAIT_ENABLE,
	STEP_VAR_WAIT_REQUEST,
	STEP_VAR_WRITE_REQUEST,
	STEP_VAR_PROCESS_RESPONSE,
	STEP_VAR_WAIT_COMMANDS_RES,
	STEP_VAR_ERROR
} BrAbbRwsVariableInternalStepEnum;

typedef enum BrAbbRwsGetElogParLogPersEnum
{	RWS_GETELOG_PERSISTENCE_VOLATILE,
	RWS_GETELOG_PERSISTENCE_REMANENT,
	RWS_GETELOG_PERSISTENCE_PERSIST
} BrAbbRwsGetElogParLogPersEnum;

typedef enum BrAbbRwsGetElogParDomainEnum
{	RWS_GETELOG_DOMAIN_COMMON = 0,
	RWS_GETELOG_DOMAIN_OPERATIONAL = 1,
	RWS_GETELOG_DOMAIN_SYSTEM = 2,
	RWS_GETELOG_DOMAIN_HARDWARE = 3,
	RWS_GETELOG_DOMAIN_PROGRAM = 4,
	RWS_GETELOG_DOMAIN_MOTION = 5,
	RWS_GETELOG_DOMAIN_IO_COMM = 7,
	RWS_GETELOG_DOMAIN_USER = 8,
	RWS_GETELOG_DOMAIN_SAFETY = 9,
	RWS_GETELOG_DOMAIN_INTERNAL = 10,
	RWS_GETELOG_DOMAIN_PROCESS = 11,
	RWS_GETELOG_DOMAIN_CONFIGURATION = 12,
	RWS_GETELOG_DOMAIN_RAPID = 15,
	RWS_GETELOG_DOMAIN_CONN_SERV = 17
} BrAbbRwsGetElogParDomainEnum;

typedef enum BrAbbRwsGetElogInternalStepType
{	STEP_GETELOG_WAIT_ENABLE,
	STEP_GETELOG_WAIT_REQUEST,
	STEP_GETELOG_WRITE_REQUEST,
	STEP_GETELOG_PROCESS_RESPONSE,
	STEP_GETELOG_LOG_CREATE,
	STEP_GETELOG_LOG_GET_IDENT,
	STEP_GETELOG_LOG_GET_LAST_REC,
	STEP_GETELOG_LOG_READ,
	STEP_GETELOG_LOG_WRITE,
	STEP_GETELOG_WAIT_COMMANDS_RESET,
	STEP_GETELOG_ERROR
} BrAbbRwsGetElogInternalStepType;

typedef enum BrAbbRwsGetElogElogTypeEnum
{	BR_ABB_RWS_ELOG_MSGTYPE_NONE = 0,
	BR_ABB_RWS_ELOG_MSGTYPE_INFO = 1,
	BR_ABB_RWS_ELOG_MSGTYPE_WARNING = 2,
	BR_ABB_RWS_ELOG_MSGTYPE_ERROR = 3
} BrAbbRwsGetElogElogTypeEnum;

typedef struct BrAbbRwsErrorInfoType
{	unsigned short Status;
	unsigned short HttpStatus;
	unsigned short TcpStatus;
} BrAbbRwsErrorInfoType;

typedef struct BrAbbRwsCommonResponseType
{	struct httpResponseHeader_t ResponseHeader;
	plcstring ResponseData[200001];
	plcstring ResponseRawHeaderData[1501];
	plcbit Error;
	struct BrAbbRwsErrorInfoType ErrorInfo;
	plcbit Done;
	enum BrAbbRwsStatusIDEnum StatusID;
} BrAbbRwsCommonResponseType;

typedef struct BrAbbRwsCommonReqestBufferType
{	unsigned long AddrServiceResponse;
	plcstring Uri[201];
	unsigned short Method;
	plcstring ReqData[501];
} BrAbbRwsCommonReqestBufferType;

typedef struct BrAbbRwsCommonCoreSrvLinkType
{	struct BrAbbRwsCommonReqestBufferType ReqBuffer[51];
	enum BrAbbRwsCommonRWVersionEnum WebServerVersion;
} BrAbbRwsCommonCoreSrvLinkType;

typedef struct BrAbbRwsCoreParametersType
{	unsigned short HostPort;
	plcstring ServerIP[16];
	plcstring UserName[51];
	plcstring Password[51];
	unsigned long Timeout;
	enum BrAbbRwsCommonRWVersionEnum WebServerVersion;
	plcstring SecureConfigName[256];
} BrAbbRwsCoreParametersType;

typedef struct BrAbbRwsCoreInternalNonceType
{	unsigned long StartIdx;
	unsigned long EndIdx;
	plcstring Nonce[101];
} BrAbbRwsCoreInternalNonceType;

typedef struct BrAbbRwsCoreInternalAutType
{	plcstring A1[256];
	unsigned char A1Usint[255];
	unsigned char HA1Usint[16];
	plcstring HA1[33];
	plcstring A2[256];
	unsigned char A2Usint[255];
	unsigned char HA2Usint[16];
	plcstring HA2[33];
	unsigned long NcUdint;
	unsigned char NcArrUsint[16];
	unsigned char NcArrUsintInv[16];
	plcstring NcTemp[81];
	plcstring Nc[11];
	plcstring cnonce[33];
	plcstring RES[256];
	unsigned char RESUsint[255];
	unsigned char HRESUsint[16];
	plcstring Response[33];
} BrAbbRwsCoreInternalAutType;

typedef struct BrAbbRwsCoreInternalCookieType
{	unsigned long StartSessionIdx;
	unsigned long EndSessionIdx;
	unsigned long StartABBCXIdx;
	unsigned long EndABBCXIdx;
	plcstring Session[151];
	plcstring ABBCX[151];
} BrAbbRwsCoreInternalCookieType;

typedef struct BrAbbRwsCoreInternalType
{	enum BrAbbRwsCoreInternalStepEnum Step;
	enum BrAbbRwsCoreInternalStepEnum OldStep;
	plcbit OldEnable;
	plcbit OldErrorReset;
	struct BrAbbRwsCoreParametersType Parameters;
	struct ArSslOpen FBSslOpen;
	struct httpsClient FBHttpsClient;
	struct httpClient FBHttpClient;
	struct BrAbbRwsCommonResponseType Response;
	struct httpRequestHeader_t ReqHeader;
	plcstring ReqRawHeaderData[1501];
	struct BrAbbRwsCommonCoreSrvLinkType CoreSrvLink;
	unsigned char BufferIdx;
	struct BrAbbRwsCoreInternalNonceType Nonce;
	struct BrAbbRwsCoreInternalAutType Authorization;
	unsigned char PendingRequests;
	struct TON FBTimerSending;
	struct BrAbbRwsCoreInternalCookieType Cookie;
	struct BrAbbRwsCoreInternalCookieType OldCookie;
	struct ExtrDelStr fbExtrDelStr;
	unsigned short FBStatus;
	unsigned short Phase;
	unsigned short tcpStatus;
	unsigned short httpStatus;
	struct httpEncodeBase64 FBEncode;
	plcstring EncodedPW[256];
	plcbit NewAuthAttemptRequired;
	unsigned char AuthorizationAttempts;
} BrAbbRwsCoreInternalType;

typedef struct BrAbbRwsRapidCmdContinueModeType
{	enum BrAbbRwsRapidCmdRegainEnum Regain;
	enum BrAbbRwsRapidCmdExecuteModeEnum Execmode;
	enum BrAbbRwsRapidCmdCycleEnum Cycle;
	enum BrAbbRwsRapidCmdConditionEnum Condition;
	enum BrAbbRwsRapidCmdStopBPEnum StopAtBp;
	enum BrAbbRwsRapidCmdTskByTSPEnum AllTaskByTsp;
} BrAbbRwsRapidCmdContinueModeType;

typedef struct BrAbbRwsRapidCmdStopModeType
{	enum BrAbbRwsRapidCmdStopModeEnum StopMode;
	enum BrAbbRwsRapidCmdStopUsetEnum USetSp;
} BrAbbRwsRapidCmdStopModeType;

typedef struct BrAbbRwsRapidCmdParameterType
{	struct BrAbbRwsRapidCmdContinueModeType Continue;
	struct BrAbbRwsRapidCmdStopModeType Stop;
	enum BrAbbRwsRapidCmdRestartModeEnum RestartMode;
	unsigned char SpeedRatio;
} BrAbbRwsRapidCmdParameterType;

typedef struct BrAbbRwsRapidCmdInternalType
{	enum BrAbbRwsRapidCmdStepEnum Step;
	plcbit OldEnable;
	plcbit OldErrorReset;
	plcbit OldPowerOn;
	plcbit OldPowerOff;
	plcbit OldStart;
	plcbit OldStop;
	plcbit OldContinue;
	plcbit OldResetPointer;
	plcbit OldChangeSpeedRatio;
	plcbit OldWarmstart;
	struct BrAbbRwsRapidCmdParameterType Parameters;
	unsigned char BufferIdx;
	struct BrAbbRwsCommonResponseType Response;
	plcstring SpeedRatioStr[81];
} BrAbbRwsRapidCmdInternalType;

typedef struct BrAbbRwsStateParEnableType
{	plcbit MotorState;
	plcbit RapidState;
	plcbit ActiveMode;
	plcbit ActPosCart;
	plcbit ActSpeedRatio;
} BrAbbRwsStateParEnableType;

typedef struct BrAbbRwsStateParOptType
{	plcstring Tool[81];
	plcstring WObj[81];
	enum BrAbbRwsCoordSystemEnum CoordSys;
} BrAbbRwsStateParOptType;

typedef struct BrAbbRwsStateParametersType
{	struct BrAbbRwsStateParEnableType Enable;
	plcstring MechUnit[51];
	struct BrAbbRwsStateParOptType Options;
} BrAbbRwsStateParametersType;

typedef struct BrAbbRwsStateStringStateType
{	unsigned long StartIdx;
	unsigned long EndIdx;
	plcstring State[51];
} BrAbbRwsStateStringStateType;

typedef struct BrAbbRwsStateInternalType
{	enum BrAbbRwsStateInternalStepEnum Step;
	struct BrAbbRwsStateParametersType Parameters;
	plcbit OldEnable;
	plcbit OldErrorReset;
	plcbit OldGetState;
	unsigned char BufferIdx;
	struct BrAbbRwsCommonResponseType Response[5];
	struct BrAbbRwsStateStringStateType State[5];
	unsigned char RequestNumber;
	unsigned char ReqIdx;
	unsigned char MotorStateIdx;
	unsigned char RapidStateIdx;
	unsigned char ActiveModeIdx;
	unsigned char ActPosCartIdx;
	unsigned char ActPosJointsIdx;
	unsigned char ActSpeedRatioIdx;
	struct ExtrDelStr fbExtrDelStr;
	plcbit AuxResponseError;
	struct BrAbbRwsErrorInfoType AuxErrorInfo;
	enum BrAbbRwsStatusIDEnum AuxStatusID;
	plcbit OptIn;
} BrAbbRwsStateInternalType;

typedef struct BrAbbRwsStatePosCartType
{	float X;
	float Y;
	float Z;
	float A;
	float B;
	float C;
	float Q1;
	float Q2;
	float Q3;
	float Q4;
} BrAbbRwsStatePosCartType;

typedef struct BrAbbRwsSignalParType
{	unsigned long SetPar;
	unsigned long GetPar;
	unsigned long SignalsNumber;
} BrAbbRwsSignalParType;

typedef struct BrAbbRwsSignalValuesType
{	plcbit DigitalValue;
	float AnalogValue;
	unsigned long GroupValue;
} BrAbbRwsSignalValuesType;

typedef struct BrAbbRwsSignalParSetType
{	plcstring Network[81];
	plcstring Device[81];
	plcstring SignalName[81];
	enum BrAbbRwsSignalParSetModeEnum SetMode;
	unsigned long Pulses;
	unsigned long PulseOn;
	unsigned long PulseOff;
	struct BrAbbRwsSignalValuesType Value;
	enum BrAbbRwsSignalSignalsTypesEnum SignalType;
} BrAbbRwsSignalParSetType;

typedef struct BrAbbRwsSignalParGetType
{	plcstring SignalName[81];
	enum BrAbbRwsSignalSignalsTypesEnum SignalType;
	plcstring Category[81];
	struct BrAbbRwsSignalValuesType Value;
} BrAbbRwsSignalParGetType;

typedef struct BrAbbRwsSignalInternalGetValType
{	unsigned long StartIdx;
	unsigned long EndIdx;
	plcstring Value[16];
} BrAbbRwsSignalInternalGetValType;

typedef struct BrAbbRwsSignalInternalType
{	enum BrAbbRwsSignalInternalStepEnum Step;
	struct BrAbbRwsSignalParType Parameters;
	struct BrAbbRwsSignalParSetType SetPar;
	struct BrAbbRwsSignalParGetType GetPar;
	plcbit OldEnable;
	plcbit OldErrorReset;
	plcbit OldSetValue;
	plcbit OldGetValue;
	plcbit AuxSetValue;
	plcbit AuxSetDigitalValue;
	unsigned long AuxSetGroupValue;
	float AuxSetAnalogValue;
	plcstring AuxPulsesString[16];
	plcstring AuxPulseOnString[16];
	plcstring AuxPulseOffString[16];
	plcbit AuxGetValue;
	struct BrAbbRwsSignalInternalGetValType GetValue;
	unsigned char BufferIdx;
	struct BrAbbRwsCommonResponseType Response;
	struct ExtrDelStr fbExtrDelStr;
	plcstring AuxStringLeft[201];
	plcstring SetValueString[16];
	unsigned long SignalIndex;
} BrAbbRwsSignalInternalType;

typedef struct BrAbbRwsVariableParameterType
{	plcstring Task[81];
	plcstring Module[81];
	plcstring Variable[201];
} BrAbbRwsVariableParameterType;

typedef struct BrAbbRwsVariableTranslationType
{	float X;
	float Y;
	float Z;
} BrAbbRwsVariableTranslationType;

typedef struct BrAbbRwsVariableRotationType
{	float Q1;
	float Q2;
	float Q3;
	float Q4;
} BrAbbRwsVariableRotationType;

typedef struct BrAbbRwsVariableRobotCfgType
{	float Cf1;
	float Cf4;
	float Cf6;
	float Cfx;
} BrAbbRwsVariableRobotCfgType;

typedef struct BrAbbRwsVariableExtaxType
{	float ExtAx1;
	float ExtAx2;
	float ExtAx3;
	float ExtAx4;
	float ExtAx5;
	float ExtAx6;
} BrAbbRwsVariableExtaxType;

typedef struct BrAbbRwsVariableRobTarget
{	struct BrAbbRwsVariableTranslationType Translation;
	struct BrAbbRwsVariableRotationType Rotation;
	struct BrAbbRwsVariableRobotCfgType RobotCfg;
	struct BrAbbRwsVariableExtaxType ExtAx;
} BrAbbRwsVariableRobTarget;

typedef struct BrAbbRwsVariableRobAxisType
{	float RobAxis1;
	float RobAxis2;
	float RobAxis3;
	float RobAxis4;
	float RobAxis5;
	float RobAxis6;
} BrAbbRwsVariableRobAxisType;

typedef struct BrAbbRwsVariableJointTargetType
{	struct BrAbbRwsVariableRobAxisType RobAxis;
	struct BrAbbRwsVariableExtaxType ExtAx;
} BrAbbRwsVariableJointTargetType;

typedef struct BrAbbRwsVariablePositionType
{	struct BrAbbRwsVariableTranslationType Translation;
	struct BrAbbRwsVariableRotationType Rotation;
} BrAbbRwsVariablePositionType;

typedef struct BrAbbRwsVariableTLoadType
{	float Mass;
	struct BrAbbRwsVariableTranslationType CenterOfGravity;
	struct BrAbbRwsVariableRotationType AxesOfMoment;
	float InertiaX;
	float InertiaY;
	float InertiaZ;
} BrAbbRwsVariableTLoadType;

typedef struct BrAbbRwsVariableToolDataType
{	plcbit RobHold;
	struct BrAbbRwsVariablePositionType Tframe;
	struct BrAbbRwsVariableTLoadType Tload;
} BrAbbRwsVariableToolDataType;

typedef struct BrAbbRwsVariableWObjectDataType
{	plcbit RobHold;
	plcbit UfProg;
	plcstring UfMec[81];
	struct BrAbbRwsVariablePositionType Uframe;
	struct BrAbbRwsVariablePositionType Oframe;
} BrAbbRwsVariableWObjectDataType;

typedef struct BrAbbRwsVariableGetValType
{	unsigned long StartIdx;
	unsigned long EndIdx;
	plcstring Value[301];
} BrAbbRwsVariableGetValType;

typedef struct BrAbbRwsVariableInternalType
{	enum BrAbbRwsVariableInternalStepEnum Step;
	plcbit OldEnable;
	plcbit OldErrorReset;
	plcbit OldSetValue;
	plcbit OldGetValue;
	plcbit AuxSetValue;
	plcbit AuxGetValue;
	struct BrAbbRwsVariableParameterType Parameters;
	unsigned char BufferIdx;
	struct BrAbbRwsCommonResponseType Response;
	plcbit AuxValueBool;
	float AuxValueNum;
	plcstring AuxValueString[301];
	struct BrAbbRwsVariableRobTarget AuxValueRobTarget;
	struct BrAbbRwsVariableJointTargetType AuxValueJointTarget;
	struct BrAbbRwsVariableToolDataType AuxValueToolData;
	struct BrAbbRwsVariableWObjectDataType AuxValueWObjData;
	struct BrAbbRwsVariablePositionType AuxValuePose;
	plcstring AuxString[301];
	struct BrAbbRwsVariableGetValType GetValue;
	struct ExtrDelStr fbExtrDelStr;
} BrAbbRwsVariableInternalType;

typedef struct BrAbbRwsVariableValueType
{	unsigned long DataAdress;
	enum BrAbbRwsVariableValueTypeEnum DataType;
	unsigned long StringSize;
} BrAbbRwsVariableValueType;

typedef struct BrAbbRwsGetElogParFilterType
{	plcbit Information;
	plcbit Warning;
	plcbit Error;
} BrAbbRwsGetElogParFilterType;

typedef struct BrAbbRwsGetElogParLoggerType
{	plcbit Enable;
	enum BrAbbRwsGetElogParLogPersEnum Persistence;
	plcstring RobotName[5];
} BrAbbRwsGetElogParLoggerType;

typedef struct BrAbbRwsGetElogParametersType
{	enum BrAbbRwsGetElogParDomainEnum Domain;
	struct BrAbbRwsGetElogParFilterType Filter;
	struct BrAbbRwsGetElogParLoggerType Logger;
} BrAbbRwsGetElogParametersType;

typedef struct BrAbbRwsGetElogElogType
{	enum BrAbbRwsGetElogElogTypeEnum Type;
	unsigned long Code;
	plcstring Title[201];
	plcdt DateTime;
} BrAbbRwsGetElogElogType;

typedef struct BrAbbRwsGetElogInternalElogType
{	unsigned long StartIdx;
	unsigned long EndIdx;
	plcstring Type[4];
	plcstring Code[16];
	plcstring Title[201];
	plcstring DateTime[51];
	plcstring TmpDateTime[6];
	struct DTStructure DateTimeDTstruct;
	unsigned char Idx;
	struct BrAbbRwsGetElogElogType Elog[50];
} BrAbbRwsGetElogInternalElogType;

typedef struct BrAbbRwsGetElogInternalType
{	enum BrAbbRwsGetElogInternalStepType Step;
	plcbit OldEnable;
	plcbit OldErrorReset;
	plcbit OldGetElog;
	struct BrAbbRwsGetElogParametersType Parameters;
	unsigned char BufferIdx;
	struct BrAbbRwsCommonResponseType Response;
	plcstring SeqNumString[16];
	signed long DomainDint;
	plcstring DomainString[4];
	struct BrAbbRwsGetElogInternalElogType Elog;
	unsigned char TmpElogIdx;
	struct ArEventLogCreate fbLogCreate;
	struct ArEventLogGetIdent fbLogGetIdent;
	struct ArEventLogGetLatestRecordID fbLogGetLastRecID;
	struct ArEventLogRead fbLogRead;
	struct ArEventLogWrite fbLogWrite;
	ArEventLogIdentType LogIdent;
	ArEventLogRecordIDType LastRecordID;
	plcdt LastRecordDateTime;
	signed short ElogIdx;
	signed long LogEventID;
	signed long TypeDint;
	struct ArEventLogTimeStampType LogTimeStamp;
	plcstring CodeString[16];
	plcstring LogDescription[201];
	signed long LastRecordEventID;
	signed short LastRecordIdx;
	plcbit NewLogger;
	struct ExtrDelStr fbExtrDelStr;
} BrAbbRwsGetElogInternalType;

typedef struct BrAbbRwsGetElogErrInfoLogType
{	signed long Status;
} BrAbbRwsGetElogErrInfoLogType;

typedef struct BrAbbRwsGetElogErrorInfoType
{	struct BrAbbRwsErrorInfoType Http;
	struct BrAbbRwsGetElogErrInfoLogType Logger;
} BrAbbRwsGetElogErrorInfoType;

typedef struct BrAbbRwsCore
{
	/* VAR_INPUT (analog) */
	struct BrAbbRwsCoreParametersType Parameters;
	/* VAR_OUTPUT (analog) */
	unsigned long Ident;
	enum BrAbbRwsStatusIDEnum StatusID;
	struct BrAbbRwsErrorInfoType ErrorInfo;
	/* VAR (analog) */
	struct BrAbbRwsCoreInternalType Internal;
	/* VAR_INPUT (digital) */
	plcbit Enable;
	plcbit ErrorReset;
	/* VAR_OUTPUT (digital) */
	plcbit Active;
	plcbit Busy;
	plcbit Error;
} BrAbbRwsCore_typ;

typedef struct BrAbbRwsGetElog
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	struct BrAbbRwsGetElogParametersType Parameters;
	/* VAR_OUTPUT (analog) */
	enum BrAbbRwsStatusIDEnum StatusID;
	struct BrAbbRwsGetElogErrorInfoType ErrorInfo;
	struct BrAbbRwsGetElogElogType Elog[50];
	/* VAR (analog) */
	struct BrAbbRwsGetElogInternalType Internal;
	struct BrAbbRwsCommonCoreSrvLinkType* CoreSrvLink;
	/* VAR_INPUT (digital) */
	plcbit Enable;
	plcbit ErrorReset;
	plcbit GetElog;
	/* VAR_OUTPUT (digital) */
	plcbit Active;
	plcbit Busy;
	plcbit Done;
	plcbit Error;
} BrAbbRwsGetElog_typ;

typedef struct BrAbbRwsVariable
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	struct BrAbbRwsVariableParameterType Parameters;
	struct BrAbbRwsVariableValueType Value;
	/* VAR_OUTPUT (analog) */
	enum BrAbbRwsStatusIDEnum StatusID;
	struct BrAbbRwsErrorInfoType ErrorInfo;
	/* VAR (analog) */
	struct BrAbbRwsVariableInternalType Internal;
	struct BrAbbRwsCommonCoreSrvLinkType* CoreSrvLink;
	/* VAR_INPUT (digital) */
	plcbit Enable;
	plcbit ErrorReset;
	plcbit SetValue;
	plcbit GetValue;
	/* VAR_OUTPUT (digital) */
	plcbit Active;
	plcbit Busy;
	plcbit Done;
	plcbit Error;
} BrAbbRwsVariable_typ;

typedef struct BrAbbRwsSignal
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	struct BrAbbRwsSignalParType Parameters;
	/* VAR_OUTPUT (analog) */
	enum BrAbbRwsStatusIDEnum StatusID;
	struct BrAbbRwsErrorInfoType ErrorInfo;
	/* VAR (analog) */
	struct BrAbbRwsSignalInternalType Internal;
	struct BrAbbRwsCommonCoreSrvLinkType* CoreSrvLink;
	/* VAR_INPUT (digital) */
	plcbit Enable;
	plcbit ErrorReset;
	plcbit SetValue;
	plcbit GetValue;
	/* VAR_OUTPUT (digital) */
	plcbit Active;
	plcbit Busy;
	plcbit Done;
	plcbit Error;
} BrAbbRwsSignal_typ;

typedef struct BrAbbRwsRapidCmd
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	struct BrAbbRwsRapidCmdParameterType Parameters;
	/* VAR_OUTPUT (analog) */
	enum BrAbbRwsStatusIDEnum StatusID;
	struct BrAbbRwsErrorInfoType ErrorInfo;
	/* VAR (analog) */
	struct BrAbbRwsRapidCmdInternalType Internal;
	struct BrAbbRwsCommonCoreSrvLinkType* CoreSrvLink;
	/* VAR_INPUT (digital) */
	plcbit Enable;
	plcbit ErrorReset;
	plcbit PowerOn;
	plcbit PowerOff;
	plcbit Start;
	plcbit Stop;
	plcbit Continue;
	plcbit ChangeSpeedRatio;
	plcbit ResetPointer;
	plcbit Warmstart;
	/* VAR_OUTPUT (digital) */
	plcbit Active;
	plcbit Busy;
	plcbit Done;
	plcbit Error;
} BrAbbRwsRapidCmd_typ;

typedef struct BrAbbRwsGetState
{
	/* VAR_INPUT (analog) */
	unsigned long Ident;
	struct BrAbbRwsStateParametersType Parameters;
	/* VAR_OUTPUT (analog) */
	enum BrAbbRwsStatusIDEnum StatusID;
	struct BrAbbRwsErrorInfoType ErrorInfo;
	enum BrAbbRwsStateRapidStateEnum RapidState;
	enum BrAbbRwsStateMotorStateEnum MotorState;
	enum BrAbbRwsStateActiveModeEnum ActiveMode;
	struct BrAbbRwsStatePosCartType ActPosition;
	unsigned char ActSpeedRatio;
	/* VAR (analog) */
	struct BrAbbRwsStateInternalType Internal;
	struct BrAbbRwsCommonCoreSrvLinkType* CoreSrvLink;
	/* VAR_INPUT (digital) */
	plcbit Enable;
	plcbit ErrorReset;
	plcbit GetState;
	/* VAR_OUTPUT (digital) */
	plcbit Active;
	plcbit Busy;
	plcbit Done;
	plcbit Error;
} BrAbbRwsGetState_typ;



/* Prototyping of functions and function blocks */
_BUR_PUBLIC void BrAbbRwsCore(struct BrAbbRwsCore* inst);
_BUR_PUBLIC void BrAbbRwsGetElog(struct BrAbbRwsGetElog* inst);
_BUR_PUBLIC void BrAbbRwsVariable(struct BrAbbRwsVariable* inst);
_BUR_PUBLIC void BrAbbRwsSignal(struct BrAbbRwsSignal* inst);
_BUR_PUBLIC void BrAbbRwsRapidCmd(struct BrAbbRwsRapidCmd* inst);
_BUR_PUBLIC void BrAbbRwsGetState(struct BrAbbRwsGetState* inst);


/* Constants */
#ifdef _REPLACE_CONST
 #define BR_ABB_RWS_SIGNAL_TYPE_GO "GO"
 #define BR_ABB_RWS_SIGNAL_TYPE_GI "GI"
 #define BR_ABB_RWS_SIGNAL_TYPE_DO "DO"
 #define BR_ABB_RWS_SIGNAL_TYPE_DI "DI"
 #define BR_ABB_RWS_SIGNAL_TYPE_AO "AO"
 #define BR_ABB_RWS_SIGNAL_TYPE_AI "AI"
 #define BR_ABB_RWS_MAX_BUFFER_LENGTH 50U
 #define BR_ABB_RWS_REALM "validusers@robapi.abb"
 #define BR_ABB_RWS_QOP "auth"
 #define BR_ABB_RWS_OPAQUE "799d5"
 #define BR_ABB_RWS_MAX_STATE_RESPONSE 4U
 #define BR_ABB_RWS_MAX_ELOG 49U
 #define BR_ABB_RWS_MAX_RESPONSE_LEN 200000U
 #define BR_ABB_RWS_MAX_HEADER_LEN 1500U
 #define BR_ABB_RWS_LOGGER_SIZE 50000U
 #define BR_ABB_RWS_EMPTY_STR ""
#else
 _GLOBAL_CONST plcstring BR_ABB_RWS_SIGNAL_TYPE_GO[81];
 _GLOBAL_CONST plcstring BR_ABB_RWS_SIGNAL_TYPE_GI[81];
 _GLOBAL_CONST plcstring BR_ABB_RWS_SIGNAL_TYPE_DO[81];
 _GLOBAL_CONST plcstring BR_ABB_RWS_SIGNAL_TYPE_DI[81];
 _GLOBAL_CONST plcstring BR_ABB_RWS_SIGNAL_TYPE_AO[81];
 _GLOBAL_CONST plcstring BR_ABB_RWS_SIGNAL_TYPE_AI[81];
 _GLOBAL_CONST unsigned char BR_ABB_RWS_MAX_BUFFER_LENGTH;
 _GLOBAL_CONST plcstring BR_ABB_RWS_REALM[31];
 _GLOBAL_CONST plcstring BR_ABB_RWS_QOP[11];
 _GLOBAL_CONST plcstring BR_ABB_RWS_OPAQUE[11];
 _GLOBAL_CONST unsigned char BR_ABB_RWS_MAX_STATE_RESPONSE;
 _GLOBAL_CONST unsigned char BR_ABB_RWS_MAX_ELOG;
 _GLOBAL_CONST unsigned long BR_ABB_RWS_MAX_RESPONSE_LEN;
 _GLOBAL_CONST unsigned short BR_ABB_RWS_MAX_HEADER_LEN;
 _GLOBAL_CONST unsigned long BR_ABB_RWS_LOGGER_SIZE;
 _GLOBAL_CONST plcstring BR_ABB_RWS_EMPTY_STR[81];
#endif




#ifdef __cplusplus
};
#endif
#endif /* _BRABBRWS_ */


/*
 * Configuration System (COSY) API
 *
 * This API provides functionality for creating and destroying COSY elements and its members.
 * Element members can be properties as well as a groups, whereof each group can aggregate
 * properties again as well as sub groups.
 *
 * For more information regarding the identification of a COSY element see cosyApi.h
 */

#ifndef _COSY_WRITE_API_H_
#define _COSY_WRITE_API_H_

#include <cosyApi.h>
#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/* timeout behaviour defines */
#define COSY_TIMEOUT_NO_WAIT 0
#define COSY_TIMEOUT_WAIT_FOREVER 0xFFFFFFFF

/*
 * Create a new COSY element with a unique 'location' and 'id'. Both values are
 * aggregated to a fqn (see cosyApi.h) identifying the element. For the purpose of
 * detailed element specification, 'type' and 'technologyPackage' are mandatory to be set.
 * Return the handle of the COSY element on success, else NULL on failure.
 *
 * Example: fqn:= "System/GMC/Axis", where location:= "System/GMC" and id:= "Axis"
 */
COSY_H cosyCreateElement(const char* location, const char* id, const char* type, const char* technologyPackage);

/*
 * Destroy a COSY element by its 'location' and 'id'.
 * Return true on success, else false on failure.
 *
 * Mind:
 * An element with all its members will be destroyed synchronously. Saved non-volatile data are removed asynchronously.
 */
bool cosyDestroyElement(const char* location, const char* id);

/*
 * Add a group by 'id' and 'value' to a COSY element by 'hCosy'.
 * Return true on success, else false on failure.
 *
 * In case of 'id' is representing a path to a subgroup, like id:= "g1/g2/g3", all parent groups
 * will be created.
 */
bool cosyAddGroup(COSY_H hCosy, const char* id, const char* value);

/*
 * Set a 'value' that must not be NULL for a group by 'id' of a COSY element by 'hCosy'.
 * Return the path name as UTF8 encoded string on success, else NULL on failure.
 */
const char* cosySetGroupValue(COSY_H hCosy, const char* id, const char* value);

/*
 * Set a property value by 'pValue' and 'valueSize', which 'iecType' is specified according
 * to the convention table below, for a group by 'id' of a COSY element by 'hCosy'.
 * Return true on success, else false on failure.
 *
 * In case of 'id' represents a path to a property, like id:= "g1/g2/g3/property", all
 * parent groups will be created on demand.
 *
 * Any property that does not exist will be created, else its value will updated only in case of
 * the 'iecType' matches the existing property's type.
 *
 * Convention:
 * According to the mapping table the 'pValue' is interpreted differently. For IEC data types
 * (see iecType.h) the input parameter 'valueSize' is optional. It is used for iecType="BLOB" only.
 * Note, that the mapping convention has an impact on 'cosyGetPropertyValue' too.
 *
 * pValue       |   valueSize   |   iecType
 * -------------|---------------|-----------
 * uint32_t     |      -        |   BOOL, SINT, INT, DINT, USINT, UINT, UDINT, BYTE, WORD, DWORD
 * const char*  |      -        |   REAL, LREAL, STRING, TIME, DATE, DATE_AND_TIME, TIME_OF_DAY
 * ----------------------------------------------------------------------------------------------
 * void*        |   N bytes     |   BLOB
 *
 * Unsupported IEC data types (see iecType.h):
 * ULINT, LWORD, WSTRING, OCTET, LINT
 */
bool cosySetProperty(COSY_H hCosy, const char* id, const char* iecType, const void* pValue, size_t valueSize);

/*
 * Delete a group or property by its 'id' of a COSY element by 'hCosy'. 'timeoutUsec' is used to specify the
 * timeout [Usec] that the cleanup process is allowed to be blocked by a competitive process operating on an
 * open element. Use COSY_TIMEOUT_NO_WAIT, COSY_TIMEOUT_WAIT_FOREVER or any numeric value to regulate the timeout.
 * Return true on success, else false on failure.
 */
bool cosyDeleteMember(COSY_H hCosy, const char* id, uint32_t timeoutUsec);

/*
 * Set the 'version' of a COSY element by 'hCosy'.
 * Return true on success, false on failure.
 */
bool cosySetElementVersion(COSY_H hCosy, const char* version);

#if AR_CORE
#include <private/cosyWriteApiP.h>
#endif

#ifdef __cplusplus
}
#endif

#endif

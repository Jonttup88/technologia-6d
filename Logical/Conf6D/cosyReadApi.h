/*
 * Configuration System (COSY) API
 *
 * This API provides functionality for accessing element member information. For reading purpose
 * element members, that can be properties as well as a groups, can be iterated too.
 *
 * For more information regarding the identification of a COSY element see cosyApi.h
 */

#ifndef _COSY_READ_API_H_
#define _COSY_READ_API_H_

#include <cosyApi.h>
#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/* COSY iterate flags */
enum COSY_ITERATE_FLAGS
{
	/* Iterate over element members of the given element non recursively */
	COSY_ITERATE_DEFAULT = 0,
	/* Iterate over element members of a given element recursively */
	COSY_ITERATE_SUB_MEMBER = 1
};

/*
 * Prototype for COSY iteration callback, that will be invoked for each existing element, whereof
 * 'context' is the user argument that will be hand over from cosyIterateElements and 'hCosy' is
 * the handle of the COSY element currently processed.
 * Return true to continue iteration, or false to stop iteration.
 *
 * Mind:
 * Within iteration context, elements must not be added or removed.
 */
typedef bool (*COSY_ITERATE_FP)(uintptr_t context, COSY_H hCosy);

/*
 * Prototype for COSY iteration callback, that will be invoked for each existing element member, whereof
 * 'context' is the user argument that will be hand over from cosyIterateMembers, 'hCosy' is the handle
 * of the COSY element currently processed, 'id' is the path information of the dedicated member
 * as UTF8 encoded string and 'memberType' is the member itself (group or property) as UTF8 encoded string.
 * Return true to continue iteration, or false to stop iteration.
 *
 * Mind:
 * Within iteration context, element members of the same iteration depth must not be added or removed.
 */
typedef bool (*COSY_ITERATE_MEMBERS_FP)(uintptr_t context, COSY_H hCosy, const char* id, const char* memberType);

/*
 * Get the location of the COSY element by 'hCosy'.
 * Return the address of the UTF8 encoded string on success, else NULL on failure.
 */
const char* cosyGetElementLocation(COSY_H hCosy);

/*
 * Get the id of the COSY element by 'hCosy'.
 * Return the address of the UTF8 encoded  string on success, else NULL on failure.
 */
const char* cosyGetElementId(COSY_H hCosy);

/*
 * Get the type of the COSY element by 'hCosy'.
 * Return the address of the UTF8 encoded string on success, else NULL on failure.
 */
const char* cosyGetElementType(COSY_H hCosy);

/* Get the technology package of the COSY element by 'hCosy'.
 * Return the address of the UTF8 encoded string on success, else NULL on failure.
 */
const char* cosyGetElementTechnologyPackage(COSY_H hCosy);

/*
 * Get the value of the group by 'id' of the COSY element by 'hCosy'.
 * Return the address of the UTF8 encoded string on success, else NULL on failure.
 */
const char* cosyGetGroupValue(COSY_H hCosy, const char* id);

/*
 * Get the type of the property by 'id' of the COSY element by 'hCosy'.
 * Return the address of the UTF8 encoded string on success, else NULL on failure.
 *
 * Mind:
 * The type information correlates with the 'iecType' described for cosyGetPropertyType.
 * It can be either the UTF8 encoded string of an IEC-Type (see iecType.h) or "BLOB" for any
 * raw data.
 */
const char* cosyGetPropertyType(COSY_H hCosy, const char* id);

/*
 * Get the value of the property by 'id' and 'iecType' of the COSY element by 'hCosy', whereof 'bytesToRead'
 * specify the size of 'pValue' in byte. 'pValueSize' is an output parameter being set on success to indicate the
 * minimum required size of byte for 'pValue'.
 * Return true on succeess, or false on failure.
 *
 * Mind:
 * In order to determine the proper size of byte by 'pValueSize' of the property value being requested,
 * 'pValue' can be set to NULL.
 *
 * Although the property is identified by its path information by 'id', the 'iecType' is mandatory
 * to interpret the 'pValue' according to the mapping table correctly.
 *
 * Convention:
 * According to the mapping table the 'pValue' is interpreted differently.
 *
 * pValue       |   bytesToRead         |   iecType
 * -------------|-----------------------|-----------
 * uint32_t     |   sizeof(uint32_t)    |   BOOL, SINT, INT, DINT, USINT, UINT, UDINT, BYTE, WORD, DWORD
 * char*        |   N bytes             |   REAL, LREAL, STRING, TIME, DATE, DATE_AND_TIME, TIME_OF_DAY
 * ----------------------------------------------------------------------------------------------
 * void*        |   N bytes             |   BLOB
 *
 * Unsupported IEC data types (see iecType.h):
 * ULINT, LWORD, WSTRING, OCTET, LINT
 */
bool cosyGetPropertyValue(COSY_H hCosy, const char* id, const char* iecType, size_t bytesToRead, void* pValue,
                          size_t* pValueSize);

/*
 * Get the size as output parameter 'pValueSize' of the property by 'id' of the COSY element
 * by 'hCosy'.
 * Return true on success, else false on failure.
 */
bool cosyGetPropertySize(COSY_H hCosy, const char* id, size_t* pValueSize);

/*
 * Iterate over COSY elements and invoke the user callback by 'fpIterate' with the user argument
 * 'context'. Set 'elementTypeFilter' to NULL to iterate over all elements, or set a value for
 * 'elementTypeFilter' to narrow the iteration down.
 * Return true on success, else false on failure.
 */
bool cosyIterateElements(COSY_ITERATE_FP fpIterate, uintptr_t context, const char* elementTypeFilter);

/*
 * Iterate over members of the COSY element by 'hCosy' and invoke the user callback by 'fpIterate' with
 * the user argument by 'context' for each member. Set 'startId' to NULL to start iteration from the first
 * member, else set a value for 'startId' to start iteration from a dedicated element member.
 * Further set 'flags' according to COSY_ITERATE_FLAGS to iterate recursively or not.
 * Return true on success, else false on failure.
 */
bool cosyIterateMembers(COSY_H hCosy, const char* startId, enum COSY_ITERATE_FLAGS flags,
                        COSY_ITERATE_MEMBERS_FP fpIterate, uintptr_t context);

/*
 * Gets the version of a COSY element by 'hCosy'.
 * Return the address of the UTF8 encoded string on success, else NULL on failure.
 */
const char* cosyGetElementVersion(COSY_H hCosy);

#if AR_CORE
#include <private/cosyReadApiP.h>
#endif

#ifdef __cplusplus
}
#endif

#endif

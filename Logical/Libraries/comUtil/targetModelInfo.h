/*
 * identify the hardware target
 */

#ifndef _TARGET_MODEL_INFO_H_
#define _TARGET_MODEL_INFO_H_

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/* returns true for ARSim (AR000) */
bool targetIsArSim();

#if AR_CORE
#include <private/targetModelInfoP.h>
#endif

#ifdef __cplusplus
}
#endif

#endif

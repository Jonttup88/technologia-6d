/* B&R-Modulename constants
 */

#ifndef _MODULE_NAME_H_
#define _MODULE_NAME_H_

/* identifier of default-scope */
#define DEFAULT_SCOPE_NAME ""

/* delimiter */
#define DELIMITER_SCOPE "::"
#define SCOPE_DELIMITER_LEN 2 /* scope-delimiter "::" */
#define DELIMITER_MODULE ":"
#define MODULE_DELIMITER_LEN 1 /* module-delimiter ":" */

/* name-length defines for B&R-modules */
#define MAX_SCOPE_NAME_LEN 20  /* scopename */
#define MAX_MODULE_NAME_LEN 10 /* B&R-modulename */
                               /* If max. B&R-module name-length is changed, following defines have to be changed too:
                                * - NVM_NAMELEN in NvMemory.h
                                * - ARPROF_MAX_NAME in ArProfilerP.h
                                */

#define MAX_FQ_MODULE_NAME_LEN (MAX_SCOPE_NAME_LEN + SCOPE_DELIMITER_LEN + MAX_MODULE_NAME_LEN)
/* fully qualified -> "<scopename>::<B&R-modulename>" */

/* used by different *GetName() functions (mo-API, cyp-API, ...), parameter 'ulOptions' */
#define NAME_FQ 0      /* get fully qualified modulename <Scopename::B&R-Modulename> */
#define NAME_SCOPE 1   /* get scopename only */
#define NAME_MODULE 2  /* get modulename only (scope is stripped) */
#define NAME_DEFAULT 3 /* call in default scope behaves like option MO_NAME_MODULE, otherwise like option MO_NAME_FQ*/

#endif

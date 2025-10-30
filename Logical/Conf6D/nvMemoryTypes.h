/* Non Volatile (NV) Memory Types */

#ifndef _NV_MEMORY_TYPES_H_
#define _NV_MEMORY_TYPES_H_

/* clang-format off */
#define	MEMTYP_SYSTEM_FLASH			0		/* System ROM */
#define	MEMTYP_SYSTEM_RAM			1		/* obsolet, only used by MEM_gettyp() */
#define	MEMTYP_USER_FLASH			2		/* User ROM */
#define	MEMTYP_USER_RAM				3		/* User RAM */
#define	MEMTYP_COPY_RAM				0x41	/* Heap/DRAM */
#define	MEMTYP_SYSTEM_FLASH_BURN	0xEE	/* System ROM, only used by online communication */
#define	MEMTYP_PERMANENT_MEM		0xF0	/* system internal permanent memory */
#define	MEMTYP_SYSTEM_INTERNAL		0xF1	/* system internal memory for simulated B&R-Modules */
#define	MEMTYP_REMANENT_MEM			0xF2	/* memory for VAR_RETAIN (remanent + permanent PVs) */
#define	MEMTYP_ARREGNV_MEM			0xF3	/* memory for non volatile system configuration */
#define	MEMTYP_TRSF					0xF4	/* memory for transfer module */

#define	MEMTYP_INVALID				0xFF	/* memory not supported */

#endif

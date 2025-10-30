/*  B&R-Moduletypes and groups */

#ifndef _MODULE_TYPES_H_
#define _MODULE_TYPES_H_

/* Modulegroups */
#define BRMGRP_MASK 0xF0
#define IS_BRMGRP(modType, group) ((modType & BRMGRP_MASK) == group)
#define GET_BRMGRP(type) ((type)&0xF0)

#define BRMTYP_INVALID 			255

/* Moduletypes */
/* clang-format off */
#define BRMGRP_VW			(0 << 4)	/* Gruppe Verwaltungsmodule */
/*#define BRMTYP_RPSSW_UPDATE	0*/		/* 0x00 RPSSW-Update */
#define BRMTYP_TRSFM			1		/* 0x01 Transfermodul, ehemals BRMTYP_INHVZ = Inhaltsverzeichnis */
/*#define BRMTYP_INHVF			2*/		/* 0x02 InhVZ Fortsetzung */
/*#define BRMTYP_MEMEX			3*/		/* 0x03 Speicherextension */
/*#define BRMTYP_HWD			4*/		/* 0x04 Hardwarebeschreibung (nur fuer SG4)*/
/*#define BRMTYP_START			7*/		/* 0x07 Bootmodul */

#define BRMGRP_TASK			(1 << 4)	/* Gruppe Taskmodule */
#define BRMTYP_SPSTASK			17		/* 0x11 SPSTask Modul */
#define BRMTYP_SYSTASK			18		/* 0x12 Systemtask Modul */
/*#define BRMTYP_USERTASK		19*/	/* 0x13 Usertask Modul */
/*#define BRMTYP_SSTASK			20*/	/* 0x14 SS Task Modul */
/*#define BRMTYP_IRQTASK		21*/	/* 0x15 Interrupttask Modul */
#define BRMTYP_EXCTASK			22		/* 0x16 Exceptiontask Modul */
/*#define BRMTYP_STARTUP		31*/	/* 0x1F Modultyp des Startup-Moduls */

/*#define BRMGRP_LIB		(2 << 4)*/	/* Gruppe Library-/Trap-Module */
/*#define BRMTYP_UPLIB			33*/	/* 0x21 FUB/UP AVT Lib */
/*#define BRMTYP_SYSLIB			34*/	/* 0x22 SystemSW Lib */
/*#define BRMTYP_HWLIB			35*/	/* 0x23 Hardwaretrap Lib */
/*#define BRMTYP_KOMLIB			36*/	/* 0x24 Kommuni(ALI) Lib */
/*#define BRMTYP_MATHLIB		37*/	/* 0x25 Mathematik Lib */
/*#define BRMTYP_LIB			38*/	/* 0x26 irgendeine Lib */
/*#define BRMTYP_INSTLIB		39*/	/* 0x27 Insttrap */
/*#define BRMTYP_ADDLIB			40*/	/* 0x28 Erweiterungstrap */

#define BRMGRP_IO			(3 << 4)	/* Gruppe IO-Module */
/*#define BRMTYP_IO				49*/	/* 0x31 IO-Modul SchTab */
#define BRMTYP_IOMAP			50		/* 0x32 IO-Map (nur fuer SG4) */

#define BRMGRP_TAB			(4 << 4)	/* Gruppe Tabellenmodule */
#define BRMTYP_BRDATA			65		/* 0x41 B&R Datenmodul */
/*#define BRMTYP_SDMDATA		66*/	/* 0x42 System Diagnostics Datenmodul */
#define BRMTYP_CONTAINER		67		/* 0x43 Containermodul */
#define BRMTYP_SAFETY_APP		68		/* 0x44 Safety Application (als Binaerstrom in der Datensection) */
#define BRMTYP_NC_TREIBER		69		/* 0x45 */
#define BRMTYP_NC_DATA			70		/* 0x46 entspricht BRMTYP_BRNCDATA von Motion */
#define	BRMTYP_SAFETY_CONFIG	71		/* 0x47 Safety Konfigurationsdaten */
/*#define BRMTYP_XTRACE_DEF		73*/	/* 0x49 Trace Definition fuer "Oszi-Module" */
/*#define BRMTYP_XTRACE_DATA	74*/	/* 0x4A Trace Daten fuer "Oszi-Module" */
#define BRMTYP_PROFILE_DEF		75		/* 0x4B Profile Definition */
#define BRMTYP_PROFILE_DATA		76		/* 0x4C Profile Daten */
#define BRMTYP_TRACER_DEF		77		/* 0x4D Tracer Definition */
#define BRMTYP_TRACER_DATA		78		/* 0x4E Tracer Daten */
#define BRMTYP_NC_UPDATE		79		/* 0x4F */

#define BRMGRP_RING			(5 << 4)	/* Gruppe Ringpuffermodule */
/*#define BRMTYP_HIST			81*/	/* 0x51 Historymodul */
#define BRMTYP_ERROR			82		/* 0x52 Errormodul */
#define BRMTYP_LOGGER			83		/* 0x53 Loggermodul */

/*#define BRMGRP_COPY		(6 << 4)*/	/* Gruppe Copy-Module */
/*#define BRMTYP_NOC			97*/	/* 0x61 NW Output Copymodul */

/*#define BRMGRP_PA			(7 << 4)*/	/* Gruppe Prozessabbildmodule */
/*#define BRMTYP_MERKER			113*/	/* 0x71 PA Merkerabbild */
/*#define BRMTYP_TKLOC			114*/	/* 0x72 PA tasklokaler Sp */

#define BRMGRP_CONF			(8 << 4)	/* Konfigurationsmodule */
#define BRMTYP_CFGSPS			129		/* 0x81 SPS Konfiguration */
/*#define BRMTYP_CFGKOM			130*/	/* 0x82 KOM Konfiguration */
/*#define BRMTYP_CFGPP			131*/	/* 0x83 PeriProz Konf */
#define BRMTYP_CFGIO			132		/* 0x84 IO Konfiguration (arconfig.br - nur fuer SG4) */
/*#define BRMTYP_CFGOPC			133*/	/* 0x85 OPC Konfiguration (asopc - nur fuer SG4) */ 
#define BRMTYP_CFGOPCUA			134		/* 0x86 OPC-UA Konfiguration */
#define BRMTYP_CFGRRAD			135		/* 0x87 Redundanz Relevante Anwenderdaten */
#define BRMTYP_CFGXML			136		/* 0x88 XML-basiertes Konfigurationsmodul (GSA) */
#define BRMTYP_CFGXMLS			137		/* 0x89 XML-basiertes Konfigurationsmodul (GSA) - Persistente Sicherung */
/*#define BRMTYP_CFGTRACE		138*/	/* 0x8A Zentraler Aufzeichnungsmechanismus Konfiguration (GSA) */
/*#define BRMTYP_CFG			143*/	/* 0x8F beliebiges Konfigurationsmodul */

/*#define BRMGRP_EXC_IRQ	(9 << 4)*/	/* Exception-/IRQ-Module */
/*#define BRMTYP_EXCEP			145*/	/* 0x91 Exceptionmodul */
/*#define BRMTYP_IRQ			146*/	/* 0x92 IRQ Modul */

/*#define BRMGRP_DEVICE		(0x0a << 4)*/	/* Gruppe Device-Driver-Modul */
/*#define BRMTYP_DEVICE			161*/	/* 0xA1 Devicedrivermodul */

/*#define BRMGRP_TAB_NG		(0x0b << 4)*/	/* Gruppe Tabellenmodule (Fortsetzung von BRMGRP_TAB) */
/*#define BRMTYP_CAPTRACE		177*/	/* 0xB1 Zentraler Aufzeichnungsmechanismus Capture (GSA) */

/*#define BRMGRP_UP			(0x0c << 4)*/	/* Gruppe UP-Module */
/*#define BRMTYP_UP				193*/	/* 0xC1 Unterprogrammmodul */

#define BRMGRP_DB			(0x0d << 4)	/* Gruppe Datenbankmodule */
/*define BRMTYP_SQLITE0			208*/	/* 0xD0*/
#define BRMTYP_SQLITE_TEXT		209 	/* 0xD1 Textsystem SQLite DBs	*/
/*define BRMTYP_SQLITE2			210*/	/* 0xD2 */
#define BRMTYP_SQLITE_TEXT_EXT	211		/* 0xD3 Nachladbare SQLite Textsystem DBs */

/*#define BRMGRP_EXE		(0x0e << 4)*/	/* Gruppe EXE-Module */
/*#define BRMTYP_EXE			224*/	/* 0xE0 beliebiges EXE Modul */
/*#define BRMTYP_PR				237*/	/* 0xED Modultyp des pROBE-Moduls*/
/*#define BRMTYP_PI				238*/	/* 0xEE Modultyp des pROBE-IO */
/*#define BRMTYP_OS				239*/	/* 0xEF Betriebssystem EXE */

/*#define BRMGRP_DATA		(0x0f << 4)*/	/* Gruppe Datenmodule */
/*#define BRMTYP_DATA			240*/	/* 0xF0 beliebiges Daten Modul */
/* clang-format on */

#endif

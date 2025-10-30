/* Funktionen zum Zugriff auf B&R-Module.
 *
 * Aufbau von B&R-Modulen siehe:
 * http://bratgrazpdc1/Technical%20Info/DescrBrModule/index.htm
 * bzw. ssmodul.doc
 */

#ifndef _MO_API_H_
#define _MO_API_H_

#include <rtkTypes.h>
#include <moduleTypes.h>
#include <moduleName.h>
#include <nvMemoryTypes.h>
#include <arexport.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct BRModul_TabFS* MOHANDLE;

/* Die Iterationsfunktion liefert das Handle des ersten B&R-Modul-Objekts in der Verwaltung der B&R-Module.
 * Returns: Handle des ersten B&R-Moduls, oder NULL falls es kein B&R-Modul gibt. */
MOHANDLE moGetFirst();

/* Die Iterationsfunktion liefert das Handle des nachfolgenden B&R-Modul des mit 'hMo' spezifizierten Vorgaengers in
 * der Verwaltung der B&R-Module.
 * Returns: Handle des naechsten B&R-Moduls, oder NULL falls es kein weiteres Modul gibt. */
MOHANDLE moGetNext(MOHANDLE hMo);

/* Die Funktion sucht ein B&R-Modul ueber den Namen 'moduleName' und ermittelt das Handle des B&R-Modul-Objekts.
 * Es kann der vollqualifizierte Modulname <Scopename::B&R-Modulname> zur Suche von B&R-Modulen im Scope von
 * "AppModulen", oder der einfache B&R-Modulname <B&R-Modulname> zur Suche im "Default-Scope" angegeben werden.
 * Returns: Handle des per Namen gesuchten B&R-Moduls, oder NULL falls das B&R-Modul nicht gefunden wurde. */
MOHANDLE moFindByName(const char* moduleName);

/* Die Funktion ermittelt den Identifier fuer die DataObj-Library fuer das mit 'hMo' spezifizierte B&R-Modul.
 * Returns: Identifier fuer DataObj-Library, oder 0 falls das Modul nicht gefunden wurde. */
AR_NOT_RECOMMENDED ULONG moHandleToDataObjId(MOHANDLE hMo);

/* Die Funktion ermmittelt das Handle des B&R-Modul-Objekts fuer das mit 'id' (DataObj-Library-Modul-Identifier)
 * spezifizierte B&R-Modul.
 * Returns: Handle des B&R-Moduls, oder NULL falls das B&R-Modul nicht gefunden wurde. */
AR_NOT_RECOMMENDED MOHANDLE moDataObjIdToHandle(ULONG id);

/* Die Funktion ermittelt den Namen des ueber 'hMo' spezifizierten B&R-Moduls.
 * Der Name wird in den uebergebenen Puffer 'nameBuffer' mit maximaler Laenge 'bufferSize' kopiert.
 * Ist der Puffer zu klein, wird der Name abgeschnitten und 0-terminiert (kein Fehler!).
 * Falls das Modul Teil eines "AppModuls" ist, wird der vollqualifizierte Modulname <Scopename::B&R-Modulname>
 * ermittelt, ansonsten der einfache B&R-Modulname <B&R-Modulname>.
 * Returns: Zeiger auf uebergebenen Puffer 'nameBuffer', oder NULL im Fehlerfall. */
const char* moGetName(MOHANDLE hMo, char* nameBuffer, int bufferSize);

/* Die Funktion ermittelt eine Referenz auf den Namen des ueber 'hMo' spezifizierten B&R-Moduls.
 * Die Referenz ist nur solange gueltig, solange das B&R-Modul existiert.
 * Falls das Modul Teil eines "AppModuls" ist, wird der vollqualifizierte Modulname <Scopename::B&R-Modulname>
 * ermittelt, ansonsten der einfache B&R-Modulname <B&R-Modulname>.
 * Returns: Referenz auf den B&R-Modulnamen, oder NULL im Fehlerfall. */
const char* moGetNameRef(MOHANDLE hMo);

/* Die Funktion ermittelt den Zeiger auf das Abbild des durch 'hMo' spezifizierten B&R-Moduls im DRAM.
 * Ein Return-Wert der Funktion ungleich NULL ist das Kennzeichen fuer ein geladenes B&R-Modul!
 * Returns: Zeiger auf das Abbild des B&R-Moduls im DRAM, oder NULL fuer ein nicht geladenes B&R-Modul. */
BYTE* moGetModulePtr(MOHANDLE hMo);

/* Die Funtion ermittelt die Laenge des durch 'hMo' spezifizierten B&R-Moduls in Bytes.
 * Returns: Laenge des B&R-Moduls in Bytes, oder 0 im Fehlerfall. */
ULONG moGetSize(MOHANDLE hMo);

/* Die Funktion ermittelt den Typ des durch 'hMo' spezifizierten B&R-Moduls.
 * Returns: Modultyp BRMTYP_* oder BRMTYP_INVALID im Fehlerfall (siehe modulTypes.h). */
BYTE moGetType(MOHANDLE hMo);

/* Die Funktion ermittelt den Typ des Speichers in dem das durch 'hMo' spezifizierte B&R-Modul gespeichert ist.
 * Returns: Speichertyp MEMTYP_* oder MEMTYP_INVALID im Fehlerfall (siehe nvMemoryTypes.h). */
BYTE moGetMemType(MOHANDLE hMo);

/* Die Funktion ermittelt die Version des mit 'hMo' spezifizierten B&R-Moduls.
 * Returns: B&R-Modul-Version, oder 0xff im Fehlerfall. */
BYTE moGetVersion(MOHANDLE hMo);

/* Die Funktion ermittelt die Revision des mit 'hMo' spezifizierten B&R-Moduls.
 * Returns: B&R-Modul-Revision, oder 0xff im Fehlerfall. */
BYTE moGetRevision(MOHANDLE hMo);

/* Mit Aufruf dieser Funktion wird das Abbild des durch 'hMo' spezifizierten B&R-Moduls im DRAM erzeugt.
 * Die Checksumme des B&R-Moduls wird dabei geprueft.
 * Returns: Zeiger auf das Abbild des B&R-Moduls im DRAM, oder NULL im Fehlerfall (Checksummen-Fehler oder
 * keine/zuwenig Ressourcen stehen zur Verfuegung). */
BYTE* moLoadImage(MOHANDLE hMo);

/* Mit Aufruf dieser Funktion wird explizit der Zugriff das mit 'hMo' spezifizierte B&R-Modul signalisiert.
 * Es wird sichergestellt, dass das Handle bis zum Aufruf von moDetach gueltig ist. Ein mehrfaches moAttach ist
 * moeglich. Fuer jeden Aufruf von moAttach muss ein Aufruf von moDetach folgen.
 * Returns: TRUE, wenn ein B&R-Modul-Objekt erfolgreich "attached" wurde, sonst FALSE */
BOOLEAN moAttach(MOHANDLE hMo);
AR_DEPRECATED BOOLEAN MO_Attach(MOHANDLE hMo); /* use moAttach instead*/

/* Mit Aufruf dieser Funktion wird die Beendigung des Zugriffs auf das mit 'hMo' spezifizierte B&R-Modul signalisiert.
 */
void moDetach(MOHANDLE hMo);
AR_DEPRECATED void MO_Detach(MOHANDLE hMo); /* use moDetach instead*/

/* Die Funktion ermittelt den Offset in Bytes zur Basisadresse des durch 'hMo' spezifizierten B&R-Modul.
 * Der Offset errechnet sich aus dem (Start-)Offset der mit 'sectionIndex' adressierten B&R-Modul-Section plus dem im
 * Parameter 'sectionOffset' uebergebenen Wert.
 * Ueber den Output-Paramert 'sectionSize' (Uebergabe von NULL erlaubt) wird die Laenge der mit 'sectionIndex'
 * spezifizierten Section zurueckgegeben.
 * Returns: Den berechneten Moduloffset, bestehend auf errechnetem Offset der Section und dem uebergebenen
 * Offset innerhalb der Section, oder 0xffffffff im Fehlerfall. */
ULONG moOffset(MOHANDLE hMo, BYTE sectionIndex, ULONG sectionOffset, ULONG* sectioncSize);

/* Die Funktion liest bis zu 'nBytes' Bytes in den Puffer 'buffer' aus dem durch 'hMo' spezifizierten B&R-Modul ab dem
 * angegebenen Offset 'offset' in Bytes.
 * Der Offset in das B&R-Modul kann ueber die Funktion moOffset() berechnet werden.
 * Returns: Anzahl der erfolgreich gelesenen Bytes, oder -1 im Fehlerfall. Die Anzahl der gelesenen Bytes kann kleiner
 * sein als 'nBytes', wenn das Ende des B&R-Moduls erreicht wird. */
int moReadS(MOHANDLE hMo, BYTE* buffer, ULONG offset, ULONG nBytes);

/* Werte fuer den Parameter 'options' der Funktion moReadSEx() */
#define MO_READ_DEFAULT 0
#define MO_READ_FROM_DRAM 1
#define MO_READ_FROM_NVMEM 2

/* Die Funktion liest bis zu 'nBytes' Bytes in den Puffer 'buffer' aus dem durch 'hMo' spezifizierten B&R-Modul ab dem
 * angegebenen Offset 'offset' in Bytes.
 * Der Offset in das B&R-Modul kann ueber die Funktion moOffset() berechnet werden.
 * Mit dem Parameter 'options' kann bestimmt werden, ob der Zugriff auf das Original-Modul im NV-Speicher, oder auf die
 * Kopie im DRAM (Abbild) erfolgt.
 * 		MO_READ_DEFAULT			Zugriff auf die Kopie des B&R-Moduls im DRAM, wenn das B&R-Modul geladen ist, ansonsten
 * 								Zugriff auf das B&R-Modul im NV-Speicher; Verhalten wie moReadS()
 * 		MO_READ_FROM_DRAM		Zugriff auf die Kopie des B&R-Moduls im DRAM; Fehler bei nicht geladenen B&R-Modulen
 * 		MO_READ_FROM_NVMEM		Zugriff auf das B&R-Modul im NV-Speicher; Fehler bei B&R-Modulen ohne NV-Ablage
 * Returns: Anzahl der erfolgreich gelesenen Bytes, oder -1 im Fehlerfall. Die Anzahl der gelesenen Bytes kann kleiner
 * sein als 'nBytes', wenn das Ende des B&R-Moduls erreicht wird. */
int moReadSEx(MOHANDLE hMo, BYTE* buffer, ULONG offset, ULONG nBytes, ULONG options);

/* Die Funktion schreibt 'nBytes' Bytes vom Puffer 'buffer' in das durch 'hMo' spezifizierte B&R-Modul ab dem
 * angegebenen Offset 'offset'. Der Offset in das B&R-Modul kann ueber die Funktion moOffset() berechnet werden.
 * Returns: Anzahl der erfolgreich geschriebenen Bytes, oder -1 im Fehlerfall. Da ein B&R-Modul nicht wachsen kann, wird
 * ein Fehler zurueckgegeben, wenn der die zu schreibenden Daten nicht im B&R-Modul Platz haben. */
int moWriteS(MOHANDLE hMo, BYTE* buffer, ULONG offset, ULONG nBytes);

/* Diese Funktion ermittelt assoziierte Objekte zu dem durch 'hMo' spezifizierten B&R-Modul.
 * Ist das B&R-Modul ein "Anwenderprogramm" (BRMTYP_SPSTASK/0x11) wird ein Handle vom Typ CYPHANDE zurueckgegeben.
 * Ist das B&R-Modul ein "Systemmodul" (BRMTYP_SYSTASK/0x12) wird ein Handle vom Typ NCYCHANDLE zurueckgegeben.
 * Fuer alle anderen B&R-Modultypen oder im Fehlerfall (MOHANDLE ist ungueltig) wird NULL zurueckgegeben. */
AR_NOT_RECOMMENDED LPVOID moGetObjectHandle(MOHANDLE hMo);

/* Diese Funktion ermittelt das Aenderungsdatum und -uhrzeit des durch 'hMo' spezifizierten B&R-Moduls.
 * Ueber den Output-Paramert 'time' wird das Aenderungsdatum und -uhrzeit zurueckgegeben.
 * Returns: TRUE, wenn Aenderungsdatum und -uhrzeit ermittelt werden konnten, sonst FALSE */
BOOLEAN moGetMTime(MOHANDLE hMo, RTK_RTC* time);

#if AR_CORE
#include <private/moApiP.h>
#endif

#ifdef __cplusplus
}
#endif

#endif

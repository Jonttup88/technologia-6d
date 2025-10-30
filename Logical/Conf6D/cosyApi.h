/*
 * Configuration System (COSY) API
 *
 * The configuration system provides a generic mechanism to configure object instances of any type. An object
 * itself is described by a set of attributes. Thus an object configuration, represented by a COSY-element, is an
 * assembly of properties, with each property being represented by a key-/value pair. For contextual separation
 * of information, properties may be grouped hierarchically. To be able to save the configuration data permanently,
 * COSY offers the possibility to save elements non-volatile.
 *
 * COSY, as an administration of configuration elements, provides read-/write-access to its COSY-elements. For further
 * documentation see 'cosyWriteApi.h' and 'cosyReadApi.h'.
 *
 * Mind that COSY is operating on UTF encoded strings. So any function granting write access to COSY will fail
 * in case of wrong input parameter string encoding.
 *
 * COSY-element:
 * An element is uniquely identified by its path-name representing a full qualified name (fqn).
 * The fqn is divided into a location- and id-part separated by the '/' delimiter character. Further, the location-part
 * may be subdivided using the '/' delimiter character for hierarchy purpose. An element consists of groups, and
 * properties. Each group again may be organised in sub-groups and properties.
 *
 * Notation:
 * fqn := <location>/<id> with location := <arg1>/<arg2>/<arg3>/... and id := <arg>
 *
 * Sample:
 * fqn := "GMC/Axis1" with location := "GMC" and id := "Axis1"
 *
 * In addition, each element is reporting a certain type and technologyPackage. Both attributes are specified as
 * mandatory, classifying a COSY element for custom purpose.
 *
 * COSY-element type:
 * The type classifies an element. Mind that an element (uniquely specified by its location and id) of different types
 * is prohibited.
 *
 * Sample:
 * fqn := "GMC/Axis1" of type := "singleAxis" (ok)
 * fqn := "GMC/Axis1" of type := "multiAxis"  (failure)
 * fqn := "GMC/Axis2" of type := "multiAxis"  (ok)
 *
 * COSY-element technologyPackage:
 * A technologyPackage is closely related to a namespace, aggregating elements for custom specific pupose.
 *
 * COSY-element property:
 * A property is defined as a key-/value pair describing a certain attribute. Mind that a property can not be deleted on
 * demand, although it can be created.
 *
 * COSY-element group:
 * A group may be used for contextual separation of information. Mind that a group can not be deleted on demand,
 * although it can be created.
 *
 * Non-volatile COSY Element:
 * Non-volatile COSY elements are preserved across reboots. A COSY element can be saved non-volatile per
 * cosySaveElement() - Note: COSY elements transferred with the project are already non-volatile. If a non-volatile
 * element is closed, an implicit save is performed.
 * Since saving is done asynchronously, the save status can be read with cosyGetElementSaveStatus().
 */

#ifndef _COSY_API_H_
#define _COSY_API_H_

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Handle for accessing a COSY element */
typedef struct COSY* COSY_H;

/*
 * Open an existing COSY element by its 'location' and 'id'.
 * Return the handle of the COSY element on success, else NULL on failure (e.g. non existing).
 *
 * Note:
 * A COSY element can be opened multiple times.
 */
COSY_H cosyOpenElement(const char* location, const char* id);

/*
 * Open an existing COSY element by its 'fqn'.
 * Return the handle of the COSY element on success, else NULL on failure (e.g. non existing).
 *
 * Note:
 * A COSY element can be opened multiple times.
 */
COSY_H cosyOpenElementByFqn(const char* fqn);

/*
 * Close a COSY element by its handle 'hCosy'.
 * Non-volatile Elements are automatically saved.
 * Return true on success, false on failure.
 */
bool cosyCloseElement(COSY_H hCosy);

/*
 * Save the COSY element specified by 'hCosy' non-volatile.
 * Return true on success, false on failure (e.g. diagnose mode).
 *
 * Note:
 * Saving a element is done asynchronously, therefore the current save status can be read out via
 * cosyGetElementSaveStatus(). Non-volatile elements are automatically saved on closing.
 */
bool cosySaveElement(COSY_H hCosy);

/*
 * Get the save status of a COSY element specified by 'hCosy'.
 * Returns the current save status:
 *   0 - the element is up to date.
 * > 0 - the non-volatile element has been changed since the last save, or there is currently a save job running.
 * < 0 - saving the element failed.
 * The error status (< 0) can be reset by modifying and saving again.
 */
int cosyGetElementSaveStatus(COSY_H hCosy);

/*
 * Evaluate if the COSY element specified by 'hCosy' is non-volatile.
 * Return true if non-volatile, false if not.
 */
bool cosyIsElementNonVolatile(COSY_H hCosy);

/*
 * Evaluate if the COSY element specified by 'hCosy' has been changed since the last save.
 * A element is dirty until it is saved again (cosySaveElement()).
 * Return true if element is dirty (only if the element is non-volatile), false if not.
 */
bool cosyIsElementDirty(COSY_H hCosy);

#ifdef __cplusplus
}
#endif

#endif

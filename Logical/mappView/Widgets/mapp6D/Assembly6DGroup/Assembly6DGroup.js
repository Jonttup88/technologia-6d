'use strict';
define([
    'brease',
    'widgets/mapp6D/Assembly6DGroup/libs/assembly6DGroup'
], function ({
    config,
    core: { ContainerWidget },
}, Assembly6DGroupDependencies) {

    /**
    * @class widgets.mapp6D.Assembly6DGroup
    * #Description
    * Grouping widgets for the widget Assembly6D
    * of an ACOPOS6D.
    *
    * @mixins widgets.brease.common.DragDropProperties.libs.DroppablePropertiesEvents
    *
    * @extends brease.core.ContainerWidget
    * @iatMeta studio:isContainer
    * true
    *
    * @iatMeta category:Category
    * Container,Assembly
    * @iatMeta description:de
    * Widget welches eine Gruppe für mapp6D Assembly Widgets zur Verfügung stellt
    * @iatMeta description:en
    * Widget that provides a group for mapp6D assembly widgets
    * 
    * @aside example assembly6DGroup
    */
    
    /**
     * @property {WidgetList} children=["widgets.mapp6D.Assembly6D"]
     * @inheritdoc
     */

    /**
     * @htmltag examples
     * ##Configuration examples:
     *
     *     <div id='Assembly6DGroup01' data-brease-widget='widgets/mapp6D/Assembly6DGroup'>
     *         <!-- insert Assembly6D widgets here -->
     *     </div>
     */

    var defaultSettings = {
        },
    
        WidgetClass = ContainerWidget.extend(function Assembly6DGroup() {
            ContainerWidget.apply(this, arguments);
        }, defaultSettings),

        p = WidgetClass.prototype;

    p.init = function () {

        if (this.settings.omitClass !== true) {
            this.addInitialClass('mapp6DAssembly6DGroup');
        }
        if (config.editMode === true) {
            this.addInitialClass('iatd-outline');
        }

        this.data = {
        };

        this._group = Assembly6DGroupDependencies.assembly6DGroup(this.elem);
        this._group.readChildElements();
        this._group.addAssembly6DClickEventListenerForChilds(this);

        ContainerWidget.prototype.init.call(this);
    };

    p.dispose = function () {
        this._group.removeAssembly6DClickEventListenerForChilds(this);
        ContainerWidget.prototype.dispose.apply(this, arguments);
    };

    return WidgetClass;
});

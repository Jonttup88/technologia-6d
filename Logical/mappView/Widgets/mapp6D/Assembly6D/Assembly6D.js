'use strict';
define([
    'brease',
    'widgets/mapp6D/Assembly6D/libs/assembly6D',
    'widgets/mapp6D/Assembly6D/libs/trafficManager',
    'widgets/mapp6D/Assembly6D/libs/FileLoader',
    'widgets/mapp6D/common/libs/mapp6DShared',
    'widgets/mapp6D/OpcUaNodeBindingEventManager/OpcUaNodeBindingEventManager',
    'widgets/mapp6D/OpcUaNodeBindingEventManager/libs/Constants',
], function ({
    config,
    core: { BaseWidget },
    controller: { widgetRegistry }
}, Assembly6DDependencies, TrafficManagerDependencies, FileLoader, mapp6DSharedDependencies, OpcUaNodeBindingEventManager, OpcUaConstants) {

    /**
    * @class widgets.mapp6D.Assembly6D
    * #Description
    * Assembly that represents the layout with the segments and shuttles
    * of an ACOPOS6D.
    * @extends brease.core.BaseWidget
    *
    * @iatMeta category:Category
    * Assembly
    * @iatMeta description:de
    * Widget für ein mapp6D Assembly
    * @iatMeta description:en
    * Widget for a mapp6D assembly
    */
       
    /**
    * @cfg {MpComIdentReference} mpLink={}
    * @iatStudioExposed
    * @iatCategory Data
    * @subtype Assembly6D
    * Link to the Assembly6D
    */

    /**
    * @cfg {MpComIdentReference} mpLinkTrafficManager={}
    * @iatStudioExposed
    * @iatCategory Data
    * @subtype TrafficManager
    * Link to the TrafficManager
    */

    /**
    * @cfg {Boolean} showAdditionalShuttleInfo=true
    * @iatStudioExposed
    * @iatCategory Data
    * Specifies whether the additional information of the shuttles should be displayed
    */

    /**
    * @cfg {Boolean} showXAxisShuttleInfo=true
    * @iatStudioExposed
    * @iatCategory Data
    * Specifies whether the x axis information of the shuttles should be displayed
    */

    /**
    * @cfg {Boolean} showYAxisShuttleInfo=true
    * @iatStudioExposed
    * @iatCategory Data
    * Specifies whether the y axis information of the shuttles should be displayed
    */

    /**
    * @cfg {Boolean} showZAxisShuttleInfo=true
    * @iatStudioExposed
    * @iatCategory Data
    * Specifies whether the z axis information of the shuttles should be displayed
    */

    /**
    * @cfg {Boolean} showRxAxisShuttleInfo=true
    * @iatStudioExposed
    * @iatCategory Data
    * Specifies whether the Rx axis information of the shuttles should be displayed
    */

    /**
    * @cfg {Boolean} showRyAxisShuttleInfo=true
    * @iatStudioExposed
    * @iatCategory Data
    * Specifies whether the Ry axis information of the shuttles should be displayed
    */

    /**
    * @cfg {Boolean} showRzAxisShuttleInfo=true
    * @iatStudioExposed
    * @iatCategory Data
    * Specifies whether the Rz axis information of the shuttles should be displayed
    */

    /**
    * @cfg {Boolean} showAdditionalTrafficManagerInfo=false
    * @iatStudioExposed
    * @iatCategory Data
    * Specifies whether the additional information of the traffic manager should be displayed
    */

    /**
    * @cfg {Boolean} showCoordinateSystem=true
    * @iatStudioExposed
    * @iatCategory Data
    * Specifies whether the coordinate system should be displayed
    */

    var defaultSettings = {
            mpLink: {},
            mpLinkTrafficManager: {},
            showAdditionalShuttleInfo: true,
            showXAxisShuttleInfo: true,
            showYAxisShuttleInfo: true,
            showZAxisShuttleInfo: true,
            showRxAxisShuttleInfo: true,
            showRyAxisShuttleInfo: true,
            showRzAxisShuttleInfo: true,
            showAdditionalTrafficManagerInfo: false,
            showCoordinateSystem: true
        },
    
        WidgetClass = BaseWidget.extend(function Assembly6D() {
            BaseWidget.apply(this, arguments);
        }, defaultSettings),

        p = WidgetClass.prototype;

    const FILE_DEVICE_NAME = '6DData';
    
    p.init = function () {

        if (this.settings.omitClass !== true) {
            this.addInitialClass('mapp6DAssembly6D');
        }

        this.fileLoader = new FileLoader(this, this.getSvgFileName(this.getMpLink()), FILE_DEVICE_NAME);
        if (typeof this.settings.mpLinkTrafficManager === 'string') {
            this.fileLoaderTrafficManager = new FileLoader(this, this.getSvgFileName(this.getMpLinkTrafficManager()), FILE_DEVICE_NAME);
        } else {
            this.fileLoaderTrafficManager = null;
        }
        this._assembly6DDataAccessFactory = null;
        this._assembly = null;
        this._trafficManagerDataAccessFactory = null;
        this._trafficManager = null;
        this._initContent = false;

        if (config.editMode) {
            _addPlaceholderImage(this);
        } else {
            if (!config.preLoadingState && this._assembly === null) {
                this._loadSvg();
            }
        }
        
        BaseWidget.prototype.init.call(this);
    };

    p.dispose = function () {
        if (this._assembly6DDataAccessFactory !== null) {
            this._assembly6DDataAccessFactory.getDataAccessContainer().removeSubscriptions();
            this._assembly6DDataAccessFactory = null;
        }

        if (this._trafficManagerDataAccessFactory !== null) {
            this._trafficManagerDataAccessFactory.getDataAccessContainer().removeSubscriptions();
            this._trafficManagerDataAccessFactory = null;
        }

        if (this._assembly !== null) {
            this._assembly.dispose();
            this._assembly = null;
        }

        if (this._trafficManager !== null) {
            this._trafficManager.dispose();
            this._trafficManager = null;
        }
        
        SuperClass.prototype.dispose.apply(this, arguments);
    };

    p.onBeforeSuspend = function () {
        if (this._assembly6DDataAccessFactory !== null) {
            this._assembly6DDataAccessFactory.getDataAccessContainer().removeSubscriptions();
        }
        BaseWidget.prototype.onBeforeSuspend.apply(this, arguments);
    };

    p.wake = function () {
        if (this.internalData.preLoaded && this._assembly === null && !this._initContent) {
            this._loadSvg();
        } else if (this._assembly6DDataAccessFactory !== null) {
            this._assembly6DDataAccessFactory.getDataAccessContainer().addSubscriptions();
        }
        BaseWidget.prototype.wake.apply(this, arguments);
    };
    
    /**
    * @method setMpLink
    * @param {MpComIdentReference} mpLink
    * Sets the name of the MpLink.
    */
    p.setMpLink = function (mpLink) {
        return this.settings.mpLink = mpLink;
    };

    /**
    * @method getMpLink
    * @return {MpComIdentReference}
    * Gets the name of the MpLink.
    */
    p.getMpLink = function () {
        return this.settings.mpLink.replace(/^mapp6D::/, '');
    };

    /**
    * @method setMpLinkTrafficManager
    * @param {MpComIdentReference} mpLinkTrafficManager
    * Sets the name of the MpLink.
    */
    p.setMpLinkTrafficManager = function (mpLink) {
        return this.settings.mpLinkTrafficManager = mpLink;
    };

    /**
    * @method getMpLinkTrafficManager
    * @return {MpComIdentReference}
    * Gets the name of the MpLink for a TrafficManager.
    */
    p.getMpLinkTrafficManager = function () {
        return this.settings.mpLinkTrafficManager.replace(/^mapp6D::/, '');
    };

    /**
    * @method setShowAdditionalShuttleInfo
    * @param {Boolean} showAdditionalShuttleInfo
    * Sets the flag to show the additional shuttle information.
    */
    p.setShowAdditionalShuttleInfo = function (showAdditionalShuttleInfo) {
        return this.settings.showAdditionalShuttleInfo = showAdditionalShuttleInfo;
    };

    /**
    * @method getShowAdditionalShuttleInfo
    * @return {Boolean}
    * Gets the flag to show the additional shuttle information.
    */
    p.getShowAdditionalShuttleInfo = function () {
        return this.settings.showAdditionalShuttleInfo;
    };

    /**
    * @method setShowXAxisShuttleInfo
    * @param {Boolean} showXAxisShuttleInfo
    * Sets the flag to show the additional shuttle information for the x axis.
    */
    p.setShowXAxisShuttleInfo = function (showXAxisShuttleInfo) {
        return this.settings.showXAxisShuttleInfo = showXAxisShuttleInfo;
    };

    /**
    * @method getShowXAxisShuttleInfo
    * @return {Boolean}
    * Gets the flag to show the additional shuttle information for the x axis.
    */
    p.getShowXAxisShuttleInfo = function () {
        return this.settings.showXAxisShuttleInfo;
    };

    /**
    * @method setShowYAxisShuttleInfo
    * @param {Boolean} showYAxisShuttleInfo
    * Sets the flag to show the additional shuttle information for the x axis.
    */
    p.setShowYAxisShuttleInfo = function (showYAxisShuttleInfo) {
        return this.settings.showYAxisShuttleInfo = showYAxisShuttleInfo;
    };

    /**
    * @method getShowYAxisShuttleInfo
    * @return {Boolean}
    * Gets the flag to show the additional shuttle information for the x axis.
    */
    p.getShowYAxisShuttleInfo = function () {
        return this.settings.showYAxisShuttleInfo;
    };

    /**
    * @method setShowZAxisShuttleInfo
    * @param {Boolean} showZAxisShuttleInfo
    * Sets the flag to show the additional shuttle information for the x axis.
    */
    p.setShowZAxisShuttleInfo = function (showZAxisShuttleInfo) {
        return this.settings.showZAxisShuttleInfo = showZAxisShuttleInfo;
    };

    /**
    * @method getShowZAxisShuttleInfo
    * @return {Boolean}
    * Gets the flag to show the additional shuttle information for the x axis.
    */
    p.getShowZAxisShuttleInfo = function () {
        return this.settings.showZAxisShuttleInfo;
    };

    /**
    * @method setShowRxAxisShuttleInfo
    * @param {Boolean} showRxAxisShuttleInfo
    * Sets the flag to show the additional shuttle information for the x axis.
    */
    p.setShowRxAxisShuttleInfo = function (showRxAxisShuttleInfo) {
        return this.settings.showRxAxisShuttleInfo = showRxAxisShuttleInfo;
    };

    /**
    * @method getShowRxAxisShuttleInfo
    * @return {Boolean}
    * Gets the flag to show the additional shuttle information for the x axis.
    */
    p.getShowRxAxisShuttleInfo = function () {
        return this.settings.showRxAxisShuttleInfo;
    };

    /**
    * @method setShowRyAxisShuttleInfo
    * @param {Boolean} showRyAxisShuttleInfo
    * Sets the flag to show the additional shuttle information for the x axis.
    */
    p.setShowRyAxisShuttleInfo = function (showRyAxisShuttleInfo) {
        return this.settings.showRyAxisShuttleInfo = showRyAxisShuttleInfo;
    };

    /**
    * @method getShowRyAxisShuttleInfo
    * @return {Boolean}
    * Gets the flag to show the additional shuttle information for the x axis.
    */
    p.getShowRyAxisShuttleInfo = function () {
        return this.settings.showRyAxisShuttleInfo;
    };

    /**
    * @method setShowRzAxisShuttleInfo
    * @param {Boolean} showRzAxisShuttleInfo
    * Sets the flag to show the additional shuttle information for the x axis.
    */
    p.setShowRzAxisShuttleInfo = function (showRzAxisShuttleInfo) {
        return this.settings.showRzAxisShuttleInfo = showRzAxisShuttleInfo;
    };

    /**
    * @method getShowRzAxisShuttleInfo
    * @return {Boolean}
    * Gets the flag to show the additional shuttle information for the x axis.
    */
    p.getShowRzAxisShuttleInfo = function () {
        return this.settings.showRzAxisShuttleInfo;
    };

    /**
    * @method setShowAdditionalTrafficManagerInfo
    * @param {Boolean} showAdditionalTrafficManagerInfo
    * Sets the flag to show the additional traffic manager information.
    */
    p.setShowAdditionalTrafficManagerInfo = function (showAdditionalTrafficManagerInfo) {
        return this.settings.showAdditionalTrafficManagerInfo = showAdditionalTrafficManagerInfo;
    };

    /**
    * @method getShowAdditionalTrafficManagerInfo
    * @return {Boolean}
    * Gets the flag to show the additional traffic manager information.
    */
    p.getShowAdditionalTrafficManagerInfo = function () {
        return this.settings.showAdditionalTrafficManagerInfo;
    };

    /**
    * @method setShowCoordinateSystem
    * @param {Boolean} showCoordinateSystem
    * Sets the flag to show the coordinate system.
    */
    p.setShowCoordinateSystem = function (showCoordinateSystem) {
        return this.settings.showCoordinateSystem = showCoordinateSystem;
    };

    /**
    * @method getShowCoordinateSystem
    * @return {Boolean}
    * Gets the flag to show the coordinate system.
    */
    p.getShowCoordinateSystem = function () {
        return this.settings.showCoordinateSystem;
    };

    /**
    * @method getFileName
    * @return {String}
    * Gets the file name that belongs to the MpLink.
    */
    p.getSvgFileName = function (fileName) {
        return fileName + '.svg';
    };

    p._loadSvg = function () {
        this._initContent = true;
        var self = this;
        var deferred = $.Deferred();
        var deferredAssembly6D, deferredTrafficManager;
        var trafficManagerSvg = null;

        deferredAssembly6D = this.fileLoader.getConfiguration().then(function (svgContent) {
            self._insertScaledSvg(svgContent);
        });

        if (this.fileLoaderTrafficManager) {
            deferredTrafficManager = this.fileLoaderTrafficManager.getConfiguration().then(function (svgContent) {
                const svgContainer = document.createElement('div');
                svgContainer.innerHTML = svgContent;
                trafficManagerSvg = svgContainer.querySelector('svg') || undefined;
            });
        }
        
        $.when(deferredAssembly6D, deferredTrafficManager).then(function () {
            var softwareComponentsNs = 'NS6';
            let OpcUaNodeBindingEventManagerClass = widgetRegistry.get('widgets.mapp6D.OpcUaNodeBindingEventManager');
            const opcUaNodeBindingEventManager = OpcUaNodeBindingEventManagerClass.createWidget(self.elem.id);
            opcUaNodeBindingEventManager.getNamespaceIdx(OpcUaConstants.SOFTWARE_COMPONENTS_URI).then(function (namespaceIdx) {
                softwareComponentsNs = 'NS' + namespaceIdx;
            }).then(function () {
                self._assembly6DDataAccessFactory = Assembly6DDependencies.dataAccessFactory(opcUaNodeBindingEventManager, self.getMpLink(), softwareComponentsNs);
                const assemblyComponentFactoryOptions = Assembly6DDependencies.componentFactoryOptions();
                assemblyComponentFactoryOptions.shuttle.showAdditionalInformation = self.getShowAdditionalShuttleInfo();
                assemblyComponentFactoryOptions.shuttle.showPosition.x = self.getShowXAxisShuttleInfo();
                assemblyComponentFactoryOptions.shuttle.showPosition.y = self.getShowYAxisShuttleInfo();
                assemblyComponentFactoryOptions.shuttle.showPosition.z = self.getShowZAxisShuttleInfo();
                assemblyComponentFactoryOptions.shuttle.showPosition.rX = self.getShowRxAxisShuttleInfo();
                assemblyComponentFactoryOptions.shuttle.showPosition.rY = self.getShowRyAxisShuttleInfo();
                assemblyComponentFactoryOptions.shuttle.showPosition.rZ = self.getShowRzAxisShuttleInfo();
                const assembly6DComponentFactory = Assembly6DDependencies.componentFactory(self._assembly6DDataAccessFactory, assemblyComponentFactoryOptions);
                const assembly6DConfigParser = Assembly6DDependencies.configParser(assembly6DComponentFactory, self._svg);
                const assemblyBuilder = Assembly6DDependencies.assemblyBuilder(assembly6DConfigParser, assembly6DComponentFactory, self._assembly6DDataAccessFactory);
                const onClickHandler = Assembly6DDependencies.eventOnClickHandler(self.elem, self.getMpLink());
                assemblyBuilder.useOnClickHandler(onClickHandler).addZones().addPowerSectors();
                const widgetBuilder = mapp6DSharedDependencies.widgetBuilder(assemblyBuilder);

                if (trafficManagerSvg) {
                    self._trafficManagerDataAccessFactory = TrafficManagerDependencies.dataAccessFactory(opcUaNodeBindingEventManager, self.getMpLinkTrafficManager(), softwareComponentsNs);
                    const trafficManagerComponentFactoryOptions = TrafficManagerDependencies.componentFactoryOptions();
                    trafficManagerComponentFactoryOptions.trafficManager.showAdditionalInformation = self.getShowAdditionalTrafficManagerInfo();
                    const trafficManagerComponentFactory = TrafficManagerDependencies.componentFactory(trafficManagerComponentFactoryOptions);
                    const trafficManagerConfigParser = TrafficManagerDependencies.configParser(trafficManagerComponentFactory, trafficManagerSvg);
                    const trafficManagerBuilder = TrafficManagerDependencies.trafficManagerBuilder(trafficManagerConfigParser);
                    widgetBuilder.useTrafficManagerBuilder(trafficManagerBuilder);
                    const trafficManagerConfigObserver = TrafficManagerDependencies.trafficManagerConfigObserver(
                        self._svg,
                        trafficManagerBuilder,
                        self._trafficManagerDataAccessFactory.createTrafficManagerDataAccess(self.getMpLinkTrafficManager())
                    );
                    trafficManagerConfigObserver.onConfigChange(function (component) {
                        if (self._trafficManager !== null) {
                            self._trafficManager.dispose();
                        }
                        self._trafficManager = component;
                    });
                }

                if (self.getShowCoordinateSystem()) {
                    widgetBuilder.addCoordinateSystem();
                }

                widgetBuilder.build();
                self._initContent = false;
                self._assembly = assemblyBuilder.getComponent();
                self._trafficManager = widgetBuilder.trafficManagerBuilder ? widgetBuilder.trafficManagerBuilder.getComponent() : null;

                deferred.resolve();
            })
        });
        return deferred;
    };

    p._insertScaledSvg = function (svgContent) {
        this._svg = mapp6DSharedDependencies.svgUtils().insertSvgIntoDom(
            this.elem,
            svgContent);
        mapp6DSharedDependencies.svgUtils().limitSvgDimension(
            this._svg,
            this.settings.width,
            this.settings.height);
    };

    function _addPlaceholderImage(widget) {
        widget.el.css({
            'background-image': 'url("widgets/mapp6D/Assembly6D/assets/Assembly6DPlaceholder.svg")',
            'background-repeat': 'no-repeat',
            'background-position': 'center center'
        });
    }

    return WidgetClass;
});

'use strict';
define([
    'brease'
], function ({
    appElem,
    config,
    core: { BaseWidget },
    services,
    controller: { bindingController, uiController, pageController },
    events: { BreaseEvent }, enum: { Enum }
}) {

    const CONTENT_ID_PREFIX = 'm6DVirt';
    const WIDGET_NAME_POSTFIX = 'OpcUaNodeBindingEventManager';

    function isString(value) {
        return (typeof value === 'string' || value instanceof String);
    }

    function isFunction(value) {
        return (typeof value === 'function' || value instanceof Function);
    }

    function normalizeString(value) {
        var normalized = '';
        var splitValue = value.split(' ');
        for (var i = 0; i < splitValue.length; ++i) {
            normalized += splitValue[i].substring(0, 1).toUpperCase() + splitValue[i].substring(1);
        }
        return value;
    }

    function getFullQualifiedOpcUaNodeName(namespace, idType, nodeId) {
        return namespace + '|' + idType + '|' + nodeId;
    }

    function getFullQualifiedOpcUaNodeNameForMethod(namespace, idType, nodeId) {
        return getFullQualifiedOpcUaNodeName(namespace, idType, nodeId) + '.MethodSet';
    }

    function getFullQualifiedParameterName(namespace, idType, nodeId, parameterId) {
        return getFullQualifiedOpcUaNodeName(namespace, idType, nodeId) + '.' + parameterId;
    }

    function getFullQualifiedMethodName(namespace, idType, nodeId, methodName) {
        return getFullQualifiedOpcUaNodeName(namespace, idType, nodeId) + '.' + methodName;
    }

    function getFullQualifiedContentId(prefix, contentId) {
        return prefix + '_' + contentId;
    }

    function getAttributeId(attributeId, nodeId) {
        return normalizeString(attributeId) + '_' + nodeId;
    }

    function getMethodName(prefix, attribute) {
        return prefix + attribute.substring(0, 1).toUpperCase() + attribute.substring(1);
    }

    function getSetterFunctionName(parameterId, nodeId) {
        return getMethodName('set', getAttributeId(parameterId, nodeId));
    }

    function createBindingConfiguration(widgetId, nodeId, parameterId, namespace, idType, bindingOptions) {
        // set default parameters
        if (bindingOptions === undefined || bindingOptions === null) {
            bindingOptions = { samplingRate: 'default' };
        }
        return {
            mode: 'twoWay',
            source: {
                type: 'opcUa',
                refId: getFullQualifiedParameterName(namespace, idType, nodeId, parameterId),
                attribute: 'value',
                samplingRate: bindingOptions.samplingRate
            },
            target: {
                type: 'brease',
                refId: widgetId,
                attribute: getAttributeId(parameterId, nodeId),
                samplingRate: bindingOptions.samplingRate
            }
        }
    }
    

    function getContentAttributes(widgetId) {
        var contentId = pageController.getCurrentPage(appElem.id);
        return {
            contentId: contentId,
            visuId: pageController.getVisu4Page(contentId),
            virtContentId: getFullQualifiedContentId(CONTENT_ID_PREFIX, widgetId),
        };
    }

    /**
     * @class widgets.mapp6D.OpcUaNodeBindingEventManager
     * #Description
     * Connect and collect data from OPCUA tags based on nodes
     * @extends brease.core.BaseWidget
     * @singleton
     *
     * @iatMeta studio:visible
     * false
     */

    var settings = {},
        maxAttempts = 3; // maximum number of attempts to browse for a certain node

    var instance,
        ModuleClass = BaseWidget.extend(function OpcUaNodeBindingEventManager(widgetId) {
                instance = this;
                instance.nodes = {};
                instance.contentAttributes = getContentAttributes(widgetId);

                var elem = document.createElement('div');

                elem.id = getFullQualifiedContentId(instance.contentAttributes.virtContentId, WIDGET_NAME_POSTFIX);
                elem.classList.add('mapp6DOpcUaNodeBindingEventManager');
                document.getElementsByTagName('body')[0].appendChild(elem);
                BaseWidget.apply(this, [elem]);
        }, settings),
        p = ModuleClass.prototype;

    ModuleClass.nameSpaceCache = new Map();

    ModuleClass.createWidget = function (widgetId) {
        var widget = uiController.callWidget(getFullQualifiedContentId(getFullQualifiedContentId(CONTENT_ID_PREFIX, widgetId), WIDGET_NAME_POSTFIX), 'widget');
        var instance = null;
        if (!widget) {
            instance = new ModuleClass(widgetId);
            uiController.addWidget(instance);
            instance._dispatchReady();
        } else {
            instance = widget.widget;
        }
        return instance;
    };

    /**
     * @method init
     * Initialize the widget
     */
    p.init = function () {
        BaseWidget.prototype.init.apply(this, arguments);
    };

    /**
     * @method getData
     * Returns the data for the specified OPC UA node
     * @param {String} nodeId ID of the OPC UA node
     * @return {Object} data
     */
    p.getData = function (nodeId) {
        if (this.nodes.hasOwnProperty(nodeId)) {
            return this.nodes[nodeId].data;
        }
    };

    /**
     * @method subscribe
     * Subscribes the callback function for the defined OPC UA node and parameter
     * @param {String} nodeId ID of the OPC UA node
     * @param {String} parameterId ID of the parameter for the defined nodeId
     * @param {String} namespace namespace of the OPC UA node
     * @param {String} idType Defines the type of the OPC UA node e.g. String
     * @param {Function} callback Callback function that should be called at a value change
     * @param {Object} bindingOptions Defines additional options for the binding e.g. the sampling rate group
     */
    p.subscribe = function (nodeId, parameterId, namespace, idType, callback, bindingOptions) {
        if (!isString(nodeId) || nodeId === ''
            || !isString(parameterId) || parameterId === ''
            || !isFunction(callback) || callback === undefined) {
            return;
        }
        var self = this;
        if (config.ContentCaching.cachingSlots > 0 && self.nodes.hasOwnProperty(nodeId) && self.nodes[nodeId].parameterIds.hasOwnProperty(parameterId)) {
            self.nodes[nodeId].parameterIds[parameterId].subscriptions.push(callback);
            if (!self.nodes[nodeId].parameterIds[parameterId].active) {
                self.nodes[nodeId].parameterIds[parameterId].active = true;
                self._createBinding(nodeId, parameterId, namespace, idType, bindingOptions);
            }
        } else {
            if (!self.nodes.hasOwnProperty(nodeId)) {
                self.nodes[nodeId] = {
                    id: nodeId,
                    parameterIds: {},
                    data: {}
                };
            }
            
            self.nodes[nodeId].parameterIds[parameterId] = {
                id: parameterId,
                opcUaId: parameterId,
                active: false,
                subscriptions: [callback],
                bindingCreated: false
            };

            self._checkNode(getFullQualifiedOpcUaNodeName(namespace, idType, nodeId)).then(function success() {
                self.nodes[nodeId].parameterIds[parameterId].active = true;
                self._createBinding(nodeId, parameterId, namespace, idType, bindingOptions);
            }, function fail() {
                self._errorHandlingFireLogEvent(nodeId, parameterId);
            });
        }
    };

    /**
     * @method unsubscribe
     * Stop notifying a widget about data modification
     * @param {String} nodeId ID of the OPC UA node
     * @param {String} parameterId ID of the parameter for the defined nodeId
     */
    p.unsubscribe = function (nodeId, parameterId, callback) {
        var self = this;
        if (self.nodes.hasOwnProperty(nodeId)
            && self.nodes[nodeId].parameterIds.hasOwnProperty(parameterId)
            && self.nodes[nodeId].parameterIds[parameterId].subscriptions.length > 0) {
            
            if (self.nodes[nodeId].parameterIds[parameterId].subscriptions.includes(callback)) {
                self.nodes[nodeId].parameterIds[parameterId].subscriptions.splice(self.nodes[nodeId].parameterIds[parameterId].subscriptions.indexOf(callback), 1);
            }
            if (self.nodes[nodeId].parameterIds[parameterId].subscriptions.length <= 0) {
                self.nodes[nodeId].parameterIds[parameterId].active = false;
                self._removeBindings(nodeId, parameterId);
            }
        }
    };

    /**
     * @method executeMethod
     * Executes a method on the OPCUA server
     * @param {String} nodeId ID of the OPC UA node
     * @param {String} parameterId ID of the parameter for the defined nodeId
     * @param {String} namespace namespace of the OPC UA node
     * @param {String} idType Defines the type of the OPC UA node e.g. String
     * @param {Array} args Array that contains the arguments for the called method
     * @return {Promise} The result is provided with the promise.
     */
    p.executeMethod = function (nodeId, methodName, namespace, idType, args) {
        return services.opcua.callMethod(getFullQualifiedOpcUaNodeNameForMethod(namespace, idType, nodeId),
            getFullQualifiedMethodName(namespace, idType, nodeId, methodName),
            args).then(function (result) {
            return result.arguments;
        });
    };

    //Pseudopivate functions

    /**
     * @method _createBinding
     * @private
     * @param {String} nodeId ID of the OPC UA node
     * @param {String} parameterId ID of the parameter for the defined nodeId
     * @param {String} namespace namespace of the OPC UA node
     * @param {String} idType Defines the type of the OPC UA node e.g. String
     * @param {Object} bindingOptions Defines additional options for the binding e.g. the sampling rate group
     * Creates the bindings to listen for modification on the data
     */
    p._createBinding = function (nodeId, parameterId, namespace, idType, bindingOptions) {
        var self = this;

        self.nodes[nodeId].parameterIds[parameterId].binding = createBindingConfiguration(self.elem.id, nodeId, parameterId, namespace, idType, bindingOptions);

        // ensure all required nodes are available on the server before creating bindings for it (A&P 679530)
        var deferred = self._checkNode(self.nodes[nodeId].parameterIds[parameterId].binding.source.refId);

        $.when.apply($, deferred).then(function success() {
            if (!self.activatePromise) {
                self.activatePromise = bindingController.activateVirtualContent(self.contentAttributes.virtContentId, self.contentAttributes.visuId);
            }
            self.activatePromise.then(function success() {
                // iterate over all nodes where a subscription was requested and check the binding state
                for (var refId in self.nodes) {
                    for (var parId in self.nodes[refId].parameterIds) {
                        if (self.nodes[refId].parameterIds[parId].bindingCreated !== true && self.nodes[refId].parameterIds[parId].active === true) {
                            bindingController.createBindings(self.contentAttributes.virtContentId, self.contentAttributes.visuId, [self.nodes[refId].parameterIds[parId].binding]).then(self._bindingsHandler(self, refId, parId),
                                function fail(responseStatus) {
                                    console.log('Not possible to create bindings: ' + responseStatus.message);
                                });
                        }
                    }
                }
            }, function fail(responseStatus) {
                console.log('OpcUaNodeBindingEventManager cannot create virtual binding: ' + responseStatus.message);
            }); 
        }, function fail() {
            self._errorHandlingFireLogEvent(nodeId, parameterId);
        });
    };

    p._bindingsHandler = function (widget, nodeId, parameterId) {
        var self = widget;
        self[getSetterFunctionName(parameterId, nodeId)] = (function () {
            return function (args) {
                // Trigger a data update notification to all subscribed callback functions
                if (self.nodes.hasOwnProperty(nodeId) && self.nodes[nodeId].parameterIds.hasOwnProperty(parameterId)) {
                    self.nodes[nodeId].data[parameterId] = args;
                    self.nodes[nodeId].parameterIds[parameterId].subscriptions.forEach(function (callback) {
                        callback(args);
                    });
                }
            };
        })();
        self.nodes[nodeId].parameterIds[parameterId].bindingCreated = true;
    };

    /**
    * @method _checkNode
    * @private
    * @param {String} nodeId ID of the OPC UA node
    * @return {Promise}
    * Check if a certain node exists on the server
    */
    p._checkNode = function (nodeId) {
        var deferred = $.Deferred();
        this._browseNode(nodeId, { resolve: deferred.resolve, reject: deferred.reject, attempts: 0 });
        return deferred.promise();
    };

    /**
    * @method _browseNode
    * @private
    * @param {String} nodeId ID of the OPC UA node
    * @param {Object} promiseData
    * @param {Function} promiseData.resolve
    * @param {Function} promiseData.reject
    * @param {Number} promiseData.attempts
    * browse for a certain node until the server responds with 
    * status success
    */
    p._browseNode = function (nodeId, promiseData) {
        var self = this;
        services.opcua.browse(nodeId).then(function (result) {
            if (result.status && result.status.code === services.libs.ServerCode.SUCCESS) {
                promiseData.resolve();
            } else if (promiseData.attempts < maxAttempts) {
                promiseData.attempts += 1;
                window.setTimeout(function () {
                    self._browseNode(nodeId, promiseData);
                }, 1000);
            } else {
                console.log('Node ' + nodeId + ' not found on OPCUA server. response:', result.status);
                promiseData.reject();
            }
        });
    };

    /**
     * @method _removeBindings
     * @private
     * @param {String} nodeId ID of the OPC UA node
     * @param {String} parameterId ID of the parameter for the defined nodeId
     * Removes the bindings to listen for modification on the data
     */
    p._removeBindings = function (nodeId, parameterId) {
        var self = this;

        var bindingTarget = {
            type: 'brease',
            refId: self.elem.id,
            attribute: getAttributeId(parameterId, nodeId)
        };
        
        bindingController.deleteBindings(self.contentAttributes.virtContentId, self.contentAttributes.visuId, [bindingTarget]).then(function () {
            self.nodes[nodeId].parameterIds[parameterId].bindingCreated = false;
        }, function (error) {
            console.log('Error when deleting the bindings.' + error);
        });
    };

    p._errorHandlingFireLogEvent = function (nodeId, parameterId) {
        if (this.nodes.hasOwnProperty(nodeId)
            && this.nodes[nodeId].parameterIds.hasOwnProperty(parameterId)) {
            this.nodes[nodeId].parameterIds[parameterId].active = false;
            this.nodes[nodeId].parameterIds[parameterId].bindingCreated = false;
        }

        var log = services.libs.LogCode.getConfig(services.libs.LogCode.CLIENT_WIDGET_INITIALIZATION_FAILED);
        document.body.dispatchEvent(new CustomEvent(BreaseEvent.LOG_MESSAGE, {
            detail: {
                customer: Enum.EventLoggerCustomer.BUR,
                verbose: log.verboseLevel,
                severity: log.severity,
                code: log.code,
                text: '',
                args: []
            },
            bubbles: true
        }));
        console.log('OpcUaNodeBindingEventManager missing members on OPCUA server for creating bindings to: ' + nodeId + '.' + parameterId);
    }

    p.getNamespaceIdx = function (nameSpaceUri) {
        return new Promise(async (resolve, reject) => {
            if (ModuleClass.nameSpaceCache.has(nameSpaceUri)) {
                resolve(ModuleClass.nameSpaceCache.get(nameSpaceUri));
            }
            try {
                let idx = await services.opcua.getNamespaceIdx(nameSpaceUri);
                ModuleClass.nameSpaceCache.set(nameSpaceUri, idx);
                resolve(idx);
            } catch {
                reject();
            }
        });
    }

    return ModuleClass;
});

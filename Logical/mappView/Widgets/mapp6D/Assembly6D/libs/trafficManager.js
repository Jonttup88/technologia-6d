'use strict';
define([
    'widgets/mapp6D/common/mapp6DWidgetCore/libs/amd/trafficmanager',
], function (TrafficManagerBundle) {

    var DependenciesClass = function () {
    };

    // static members

    DependenciesClass.dataAccessFactory = function (opcUaNodeBindingEventManager, mpLink, namespace) {
        return new TrafficManagerBundle['DataAccessFactoryOpcUa'](opcUaNodeBindingEventManager, mpLink, namespace);
    };
    
    DependenciesClass.componentFactoryOptions = function () {
        return new TrafficManagerBundle['ComponentFactoryOptions']();
    };

    DependenciesClass.componentFactory = function (options) {
        return new TrafficManagerBundle['ComponentFactory'](options);
    };
    
    DependenciesClass.configParser = function (componentFactory, svg) {
        return new TrafficManagerBundle['ConfigParser'](componentFactory, svg);
    };

    DependenciesClass.trafficManagerBuilder = function (configParser) {
        return new TrafficManagerBundle['TrafficManagerBuilder'](configParser);
    };

    DependenciesClass.trafficManagerConfigObserver = function(svg, trafficManagerBuilder, trafficManagerDataAccess) {
        return new TrafficManagerBundle['TrafficManagerConfigObserver'](svg, trafficManagerBuilder, trafficManagerDataAccess);
    }
    
    return DependenciesClass;
});

'use strict';
define([
    'widgets/mapp6D/common/mapp6DWidgetCore/libs/amd/mapp6DShared'
], function (mapp6DShared) {

    var DependenciesClass = function () {
    };

    // static members

    DependenciesClass.lock = function () {
        return new mapp6DShared['Lock']();
    };

    DependenciesClass.configProviderJQueryWrapper = function (configProvider) {
        return new mapp6DShared['ConfigProviderJQueryWrapper'](configProvider);
    };

    DependenciesClass.opcUaNodeBindingEventManagerMappViewWrapper = function (widgetId, opcUaNodeBindingEventManager) {
        return new mapp6DShared['OpcUaNodeBindingEventManagerMappViewWrapper'](widgetId, opcUaNodeBindingEventManager);
    };

    DependenciesClass.widgetBuilder = function (assemblyBuilder) {
        return new mapp6DShared['WidgetBuilder'](assemblyBuilder);
    };

    DependenciesClass.svgUtils = function () {
        return mapp6DShared['SvgUtils'];
    };

    return DependenciesClass;
});

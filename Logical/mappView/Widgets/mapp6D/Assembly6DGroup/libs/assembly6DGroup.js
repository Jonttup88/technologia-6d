'use strict';
define([
    'widgets/mapp6D/common/mapp6DWidgetCore/libs/amd/assembly6DGroup'
], function (Assembly6DGroupBundle) {

    var DependenciesClass = function () {
    };

    // static members

    DependenciesClass.assembly6DGroup = function (element) {
        return new Assembly6DGroupBundle['Assembly6DGroup'](element);
    };

    return DependenciesClass;
});

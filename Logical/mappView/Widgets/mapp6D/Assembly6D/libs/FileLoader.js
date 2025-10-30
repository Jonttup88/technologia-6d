'use strict';
define([
    'brease'
], function ({ core: { Class } }) {

    var FileLoader = Class.extend(function FileLoader(widget, fileName, fileDeviceName) {
            Class.call(this);
            this.init(widget, fileName, fileDeviceName);
        }, null),

        p = FileLoader.prototype;

    p.init = function (widget, fileName, fileDeviceName) {
        this.widget = widget;
        this.onLoadedCallback = null;
        this.fileName = fileName;
        this.fileDeviceName = fileDeviceName;
    };

    p.getConfiguration = function () {
        var filePath = _getFilePath(this.fileName, this.fileDeviceName);
        var deferred = $.Deferred();
        var self = this;
        if (filePath === '') {
            this.deferred.resolve('');
        } else {
            $.get(filePath, function (data) {
                // check if widget is not disposed in the mean time
                if (self.widget.elem) {
                    if (self.onLoadedCallback !== null) {
                        self.onLoadedCallback(data);
                    }
                    deferred.resolve(data);
                } else {
                    deferred.reject();
                }
            }, 'text').fail(function () {
                deferred.reject();
            });
        }
        return deferred;
    };

    p.onLoaded = function (callback) {
        this.onLoadedCallback = callback;
    };

    function _getFilePath(fileName, fildeDeviceName) {
        return '/FileDevice:' + fildeDeviceName + '/' + fileName;
    }

    return FileLoader;
});

define(["brease"], function({core:{designer:{ContainerWidget:{ClassInfo:s}}}}, e) {const classInfo={meta:{className:"widgets.mapp6D.Assembly6DGroup",parents:["*"],children:["widgets.mapp6D.Assembly6D"],inheritance:["widgets.mapp6D.Assembly6DGroup","brease.core.ContainerWidget","brease.core.BaseWidget"],creator:"ad5c1be6dc0ba9f4455d667550a204ea",eventBindingApi:function (w) {
function a(e, f) { w.addServerEventListener(e, f); }
function c(...args) { const [{ action: a }] = args.slice(-1); return w[a](...args); }
return {
click: f => a('Click', f),
disabledClick: f => a('DisabledClick', f),
enableChanged: f => a('EnableChanged', f),
focusIn: f => a('FocusIn', f),
focusOut: f => a('FocusOut', f),
onDragEnter: f => a('OnDragEnter', f),
onDragLeave: f => a('OnDragLeave', f),
onDrop: f => a('OnDrop', f),
visibleChanged: f => a('VisibleChanged', f),
focus: function () { c({ origin: 'action', action: 'focus' }); },
setEnable: function (a1) { c(a1,{ origin: 'action', action: 'setEnable' }); w.sendValueChange({enable: w.getEnable()}, false);},
setStyle: function (a1) { c(a1,{ origin: 'action', action: 'setStyle' }); w.sendValueChange({style: w.getStyle()}, false);},
setVisible: function (a1) { c(a1,{ origin: 'action', action: 'setVisible' }); w.sendValueChange({visible: w.getVisible()}, false);},
showTooltip: function () { c({ origin: 'action', action: 'showTooltip' }); }
};
},actions:{"Focus":{"method":"focus"},"setAdditionalStyle":{"method":"setAdditionalStyle","parameter":{"styleName":{"name":"styleName","index":0,"type":"StyleReference"}}},"setEditable":{"method":"setEditable","parameter":{"editable":{"name":"editable","index":0,"type":"Boolean"},"metaData":{"name":"metaData","index":1,"type":"Object"}}},"SetEnable":{"method":"setEnable","parameter":{"value":{"name":"value","index":0,"type":"Boolean"}}},"setParentCoWiId":{"method":"setParentCoWiId","parameter":{"value":{"name":"value","index":0,"type":"String"}}},"SetStyle":{"method":"setStyle","parameter":{"value":{"name":"value","index":0,"type":"StyleReference"}}},"setTabIndex":{"method":"setTabIndex","parameter":{"value":{"name":"value","index":0,"type":"Number"}}},"SetVisible":{"method":"setVisible","parameter":{"value":{"name":"value","index":0,"type":"Boolean"}}},"ShowTooltip":{"method":"showTooltip"}},properties:{}}};if(s.classExtension) {classInfo.classExtension = s.classExtension;}if(e) {classInfo.classExtension = e;}return classInfo;});

window.TAjax_class = function () { };
$.extend(TAjax_class.prototype, $.extend(new window.parent.AjaxPro.AjaxClass(), {
    invokeWithEncode: function (method, args, e) {
        var url = window.location.origin + window.parent.appName + "/ajaxpro/Ufida.T.PU.UIP.PurchaseOrderEditController,Ufida.T.PU.UIP.ashx"
        var s = "";
        for (var i in args)
            if (typeof args[i] !== "function" && args[i] != null) s += args[i];
        e.push(window.parent.TTop.$.md5(s));
        args["__sign"] = e[e.length - 1];
        if (e != null) {
            if (e.length != 6)
                for (; e.length < 6;) e.push(null);
            if (e[0] != null && typeof e[0] == "function") return window.parent.TTop.AjaxPro.queue.add(this.url, method, args, e)
        }
        var r = new window.parent.TTop.AjaxPro.Request;
        r.url = url;
        return r.invoke(method, args)
    },
    GetVchAttCount: function (templateName, associateID) {
        return this.invokeWithEncode("GetVchAttCount", {
            "templateName": templateName,
            "associateID": associateID
        }, [templateName, associateID]);
    },
}));
window.TAjax = new TAjax_class();
window.showModalDialog = window.parent.showModalDialog
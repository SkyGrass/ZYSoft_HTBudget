var utils = {
  obj2Url: function (obj) {
    var url = "";
    for (var key in obj) {
      var value = obj[key];
      url += `&${key}=${value}`;
    }
    return url.substring(1);
  },

  url2Obj: function (url) {
    var obj = {};
    if (url == "") return obj;
    if (url[0] == "?") url = url.substring(1);
    url.split("&").forEach(function (ele) {
      var tmp = ele.split("=");
      obj[tmp[0]] = tmp[1];
    });
    return obj;
  },
  format: function (num) { 
    var reg = /\d{1,3}(?=(\d{3})+$)/g;
    return (num + ' ').replace(reg, '$&,')
  }
};

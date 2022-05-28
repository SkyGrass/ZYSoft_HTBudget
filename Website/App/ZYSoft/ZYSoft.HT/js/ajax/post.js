if ($ == void 0) {
  var s = document.createElement("script");
  s.src = "../jquery.min.js";
  document.getElementsByTagName("HEAD")[0].appendChild(s);
}

if (layer == void 0) {
  var s = document.createElement("script");
  s.src = "../layui/layui.js";
  document.getElementsByTagName("HEAD")[0].appendChild(s);
}

function post(url, form, success, fail) {
  var index = layer.load(2, { time: 10 * 1000, shade: [0.3, "#393D49"] });
  $.ajax({
    type: "POST",
    url: url,
    async: true,
    data: form,
    dataType: "json",
    success: function (result) {
      success && success(result);
      layer.close(index);
    },
    error: function () {
      layer.close(index);
      layer.msg("调用网络接口出现错误!", { icon: 5 });
    },
  });
}

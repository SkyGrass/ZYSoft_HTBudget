var openDialog = function (options) {
  var options = Object.assign(
    {},
    {
      type: 2,
      area: ["800px", "500px"],
      btn: ["确定", "取消"],
    },
    options
  );
  layui.use("layer", function () {
    var layer = (window.layer = layui.layer);

    layer.open({
      type: options.type,
      title: options.title,
      closeBtn: options.closeBtn,
      maxmin: options.maxmin,
      area: options.area,
      offset: options.offset,
      content: options.url,
      success: function (layero, index) {
        layer.setTop(layero);
        options.onSuccess && options.onSuccess(layero, index, layer);
      },
      btn: options.btn,
      zIndex: layer.zIndex,
      yes: function (index, layero) {
        options.onBtnYesClick && options.onBtnYesClick(index, layero, layer);
      },
      cancel: function () {},
    });
  });
};

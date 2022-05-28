var vm = new Vue({
  el: "#app",
  data() {
    var curDate = new dayjs();
    return {
      form: {
        name: "",
        region: "",
        date: curDate,
        billNo: "SO-2022-05-07",
        delivery: false,
        type: [],
        resource: "",
        desc: "",
      },
    };
  },
  methods: {
    onOpenDialogSuccess(layero, index) {},
    openDialog() {
      layui.use("layer", function () {
        window.layer = layer = layui.layer;
        layer.open({
          type: 2,
          title: "选择客户",
          closeBtn: 0,
          area: ["600px", "400px"],
          content: "./modal/Dialog.aspx",
          success: function (layero, index) {
            var iframeWin = window[layero.find("iframe")[0]["name"]];
            iframeWin.init({ dialogType: "custom" });
          },
          btn: ["确定", "取消"],
          yes: function (index, layero) {
            var iframeWin = window[layero.find("iframe")[0]["name"]];
            var row = iframeWin.getSelect();
            if (row.length <= 0) {
              layer.msg("请先选择", { icon: 5 });
            } else {
              layer.close(index);
            }
          },
          cancel: function () {},
        });
      });
    },
  },
  mounted() {
    this.openDialog();
  },
});

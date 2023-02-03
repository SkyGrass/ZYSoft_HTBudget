var dialog = {};
function init(opt) {
  var self = (dialog = new Vue({
    el: "#app",
    data() {
      return {
        form: {
          startDate: "",
          endDate: "",
          custId: "",
          custName: "",
          billerName: "",
          billStatus: ""
        },
        billStatusList: [{ value: "0", label: "未审批" }, { value: "1", label: "已审批" }]
      };
    },
    computed: {
    },
    methods: {
      openCustom() {
        opt.parent.openBaseDataDialog(
          "custom",
          "选择客户",
          function (result) {
            result = result[0];
            var id = result.id,
              code = result.code,
              name = result.name;
            self.form.custName = name;
            self.form.custId = id;
          },
          this.form.custName || ""
        );
      },
      closeDialog(dialogType, row) {
        var result = row;
        var id = result.id,
          code = result.code,
          name = result.name;
        switch (dialogType) {
          case "custom":
            self.form.custName = name;
            self.form.custId = id;
            break;
          case "project":
            self.form.projectNo = name;
            self.form.projectId = id;
            break;
        }
        opt.parent.closeBaseDataDialog(dialogType, row);
      },
      onClearCust() {
        this.form.custId = "";
      },
    },
    watch: {},
    mounted() {
      this.form = opt.parent.form;
    },
  }));
}

function getSelect() {
  var result = [dialog.form].map(function (m) {
    m.startDate = Date.parse(m.startDate)
      ? dayjs(m.startDate).format("YYYY-MM-DD")
      : "";
    m.endDate = Date.parse(m.endDate)
      ? dayjs(m.endDate).format("YYYY-MM-DD")
      : "";
    return m;
  });
  return result;
}

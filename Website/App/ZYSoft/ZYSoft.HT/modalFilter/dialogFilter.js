var dialog = {};
function init(opt) {
  dialog = new Vue({
    el: "#app",
    data() {
      return {
        form: {
          startDate: "",
          endDate: "",
          custId: "",
          projectId: "",

          contractNo: "",
          manager: "",
          custManager: "",

          custName: "",
          projectNo: "",
        },
      };
    },
    methods: {
      openCustom() {
        var self = this;
        opt.parent.openBaseDataDialog(
          "custom",
          "选择客户",
          function ([{ id, code, name }]) {
            self.form.custName = name;
            self.form.custId = id;
            self.$refs.form.validateField("custName");
          }
        );
      },
      openProject() {
        var self = this;
        opt.parent.openBaseDataDialog(
          "project",
          "选择项目",
          function ([{ id, code, name }]) {
            self.form.projectNo = name;
            self.form.projectId = id;
            self.$refs.form.validateField("projectNo");
          }
        );
      },
      doFilter() {
        this.grid.setFilter([
          [
            { field: "code", type: "like", value: this.queryForm.keyword },
            { field: "name", type: "like", value: this.queryForm.keyword },
          ],
        ]);
      },
      onClearCust() {
        this.form.custId = "";
      },
      onClearProject() {
        this.form.projectId = "";
      },
    },
    watch: {},
    mounted() {
      var self = this;
      self.form = opt.parent.form;
    },
  });
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

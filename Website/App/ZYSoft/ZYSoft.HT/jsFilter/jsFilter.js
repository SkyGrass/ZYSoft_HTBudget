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
          projectId: "",

          contractNo: "",
          manager: "",
          custManager: "",

          custName: "",
          projectNo: "",

          projectType: "",
        },
      };
    },
    methods: {
      openCustom() {
        opt.parent.openBaseDataDialog("custom", "选择客户", function (result) {
          result = result[0];
          var id = result.id,
            code = result.code,
            name = result.name;
          self.form.custName = name;
          self.form.custId = id;
          self.$refs.form.validateField("custName");
        });
      },
      openProject() {
        opt.parent.openBaseDataDialog("project", "选择项目", function (result) {
          result = result[0];
          var id = result.id,
            code = result.code,
            name = result.name;
          self.form.projectNo = name;
          self.form.projectId = id;
          self.$refs.form.validateField("projectNo");
        });
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

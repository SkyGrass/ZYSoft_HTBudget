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
        },
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
            self.$refs.form.validateField("custName");
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

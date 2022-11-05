Vue.directive("number", {
  inserted(el, binding, vnode) {
    el.oninput = function (e) {
      var value = e.target.value;
      if (isNaN(value)) {
        vnode.context.num = e.target.value = "";
        return;
      }
    };
  },
});
//accountId = '250116'
Vue.mixin(printMixin);
var self = (vm = new Vue({
  el: "#app",
  data() {
    return {
      form: {
        accountId: accountId,
        custId: "",
        projectId: "",
        contractNo: "",
        sum: 0,
        sum1: 0,
        budgetSum: 0,
        addSum: 0,
        totalSum: 0,
        billerId: loginUserId,
        manager: "",
        custManager: "",
        endDate: "",
        projectType: "",
        year: "",

        custName: "",
        projectName: "",
        billerName: loginName,
        id: -1,
      },
      query: {},
      list: [],
      rules: {
        accountName: [
          { required: true, message: "帐套名称不可为空!", trigger: "blur" },
        ],
        billerName: [
          { required: true, message: "制单人不可为空!", trigger: "blur" },
        ],
        custName: [
          { required: true, message: "客户不可为空!", trigger: "blur" },
        ],
        projectName: [
          { required: true, message: "项目不可为空!", trigger: "blur" },
        ],
        contractNo: [
          { required: true, message: "合同号不可为空!", trigger: "blur" },
        ],
        manager: [
          { required: true, message: "项目经理不可为空!", trigger: "blur" },
        ],
        custManager: [
          { required: true, message: "客户项目经理不可为空!", trigger: "blur" },
        ],
        sum: [{ required: true, message: "金额不能为空", trigger: "blur" }],
        addSum: [
          { required: true, message: "增补金额不能为空", trigger: "blur" },
        ],
        // endDate: [
        //   { required: true, message: "竣工日期不能为空", trigger: "blur" },
        // ],
        projectType: [
          { required: true, message: "项目类型不能为空", trigger: "blur" },
        ],
      },
      grids: {},
      activeName: "",
    };
  },
  computed: {
    tabs() {
      var group = Array.from(
        new Set(
          this.list.map(function (f) {
            return f.FGroupCode;
          })
        )
      );
      this.activeName = group[0];
      return group.map(function (g) {
        var r = self.list.filter(function (f) {
          return f.FGroupCode == g;
        });
        return {
          FIsSp: r[0].FIsSp || 0,
          FTableId: "table_" + r[0].FGroupCode,
          FGroupCode: r[0].FGroupCode,
          FGroupName: `${r[0].FGroupCode} ${r[0].FGroupName}`,
          FChildren: r.map(function (m) {
            m.FChildren = [];
            return m;
          }),
        };
      });
    },
    summary() {
      var t1 = this.tabs.filter(function (f) {
        return f.FIsSp == 0;
      })
        .map(function (m) {
          return {
            FIsTotal: 0,
            FGroupCode: m.FGroupCode,
            FGroupName: m.FGroupName,
            FBudgetSum: m.FChildren.map(function (m) {
              return Number(m.FBudgetSum);
            }).reduce(function (total, num) {
              return Number(math.eval(total + "+" + num)).toFixed(2);
            }, 0),
            FCostSum: m.FChildren.map(function (m) {
              return Number(m.FCostSum);
            }).reduce(function (total, num) {
              return Number(math.eval(total + "+" + num)).toFixed(2);
            }, 0),
            FDiffSum: m.FChildren.map(function (m) {
              return Number(m.FDiffSum);
            }).reduce(function (total, num) {
              return Number(math.eval(total + "+" + num)).toFixed(2);
            }, 0),
          };
        })
        .map(function (m) {
          if (m.FBudgetSum == 0) {
            m.FDiffRate = "0";
            return m;
          } else {
            m.FDiffRate =
              Number(
                math.eval("(" + m.FDiffSum + "/" + m.FBudgetSum + ")*" + 100)
              ).toFixed(2) + "%";
            return m;
          }
        });
      var s1 = t1.map(function (f) { return f.FBudgetSum }).reduce(function (total, num) {
        return Number(math.eval(total + "+" + num)).toFixed(2);
      }, 0);
      var s2 = t1.map(function (f) { return f.FCostSum }).reduce(function (total, num) {
        return Number(math.eval(total + "+" + num)).toFixed(2);
      }, 0);
      var s3 = t1.map(function (f) { return f.FDiffSum }).reduce(function (total, num) {
        return Number(math.eval(total + "+" + num)).toFixed(2);
      }, 0);
      var t2 = [{
        FIsTotal: 1,
        FGroupCode: '合计',
        FGroupName: '合计',
        FBudgetSum: s1,
        FCostSum: s2,
        FDiffSum: s3,
        FDiffRate: s1 == 0 ? "0" : Number(
          math.eval("(" + s3 + "/" + s1 + ")*" + 100)
        ).toFixed(2) + "%"
      }]
      return t1.concat(t2)
    },
    printObj() {
      return {
        FBillType: 3,
        FAccountID: this.form.accountId,
        FItemID: this.form.id,
      };
    },
  },
  watch: {
    "form.sum"(newV, oldV) {
      this.form.totalSum = math.add(
        newV == void 0 ? "0" : newV,
        this.form.addSum == void 0 ? "0" : this.form.addSum
      );
    },
    "form.addSum"(newV, oldV) {
      this.form.totalSum = math.add(
        newV == void 0 ? "0" : newV,
        this.form.sum == void 0 ? "0" : this.form.sum
      );
    },
  },
  methods: {
    openBaseDialog(type, title, success, filter) {
      openDialog({
        title: title,
        url: "./modal/Dialog.aspx?filter=" + filter,
        onSuccess: function (layero, index) {
          var iframeWin = window[layero.find("iframe")[0]["name"]];
          iframeWin.init({
            layer,
            dialogType: type,
            accountId: self.form.accountId,
          });
        },
        onBtnYesClick: function (index, layero) {
          var iframeWin = window[layero.find("iframe")[0]["name"]];
          var row = iframeWin.getSelect();
          if (row.length > 0) {
            success && success(row);
            layer.close(index);
          }
        },
      });
    },
    openCustom() {
      this.openBaseDialog(
        "custom",
        "选择客户",
        function (result) {
          var result = result[0];
          var id = result.id,
            code = result.code,
            name = result.name;
          self.form.custName = name;
          self.form.custId = id;
          self.$refs.form.validateField("custName");
        },
        this.form.custName
      );
    },
    openProject() {
      this.openBaseDialog(
        "project",
        "选择项目",
        function (result) {
          var result = result[0];
          var id = result.id,
            code = result.code,
            name = result.name;
          self.form.projectName = name;
          self.form.projectId = id;
          self.$refs.form.validateField("projectName");
        },
        this.form.projectName
      );
    },
    onTabClick(tab, event) {
      //  console.log(tab);
    },
    showGroup(item) {
      var title = item.FItemName;
      openDialog({
        title: title,
        area: ["70%", "500px"],
        url:
          "./modalDiffTree/ModalDiffTree.aspx?" +
          utils.obj2Url({ v: new Date() * 1, state: self.query.state }),
        onSuccess: function (layero, index) {
          var iframeWin = window[layero.find("iframe")[0]["name"]];
          iframeWin.init({ layer, group: item });
        },
        btn: this.query.state == "read" ? [] : ["确定", "取消"],
        onBtnYesClick: function (index, layero) { },
      });
    },
    showGroupDetail(item) {
      this.activeName = item.FGroupCode;
    },
    doInitBill(query) {
      $.ajax({
        type: "POST",
        url: "./BudgetHandler.ashx",
        async: true,
        data: {
          SelectApi: "getdifflist",
          accountId: this.form.accountId,
          billId: query.id,
        },
        dataType: "json",
        success: function (result) {
          if (result.state == "success") {
            result = result.data[0];
            self.form.accountId = result.FAccountID;
            self.form.custId = result.FCustID;
            self.form.projectId = result.FProjectID;
            self.form.contractNo = result.FContractNo;
            // self.form.sum = result.FDiffSum;
            // self.form.addSum = result.FDiffAddSum;
            self.form.sum1 = result.FCostSum;// result.FSum;
            self.form.budgetSum = result.FBudgetSum;
            self.form.totalSum = result.FDiffSum;
            self.form.billerId = result.FBillerID;
            self.form.manager = result.FManager;
            self.form.custManager = result.FCustManager;
            self.form.endDate =
              result.FEndDate != null && result != void 0 && result != ""
                ? new dayjs(result.FEndDate).format("YYYY-MM-DD")
                : "";
            self.form.projectType = result.FProjectType;
            self.form.year = result.FYear;

            self.form.custName = result.FCustName;
            self.form.projectName = result.FProjectName;
            self.form.billerName = result.FBillerName;
            self.form.id = result.FID;
            self.doInitBillEntry();
          } else {
            layer.msg(result.msg, { icon: result.icon });
          }
        },
        error: function () {
          layer.msg("查询差异单发生错误!", { icon: 5 });
        },
      });
    },
    doInitBillEntry(index) {
      $.ajax({
        type: "POST",
        url: "./BudgetHandler.ashx",
        async: true,
        data: {
          SelectApi: "checkdiffdetail",
          accountId: this.form.accountId,
          projectId: this.form.projectId,
        },
        dataType: "json",
        success: function (result) {
          if (result.state == "success") {
            self.list = result.data;
          }
          layer.close(index);
        },
        error: function () {
          layer.close(index);
          layer.msg("查询差异明细发生错误!", { icon: 5 });
        },
      });
    },
  },
  mounted() {
    this.query = utils.url2Obj(window.location.search);
    if (this.query.state == void 0) {
      this.query.state = "add";
    }
    if (this.query.state == "read") {
      this.doInitBill(this.query);
    }

    var dom = document.querySelector('label[for="manager"] span');
    if (dom != void 0) {
      if (this.form.accountId == "230114") {
        dom.innerText = "苏腾项目经理";
      } else if (this.form.accountId == "250116") {
        dom.innerText = "华腾项目经理";
      }
    }
  },
}));

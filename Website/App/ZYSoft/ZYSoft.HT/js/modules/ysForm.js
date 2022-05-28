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

var self = (vm = new Vue({
  el: "#app",
  data() {
    return {
      form: {
        accountId: "250116",
        custId: "",
        projectId: "",
        contractNo: "",
        sum: 0,
        addSum: 0,
        totalSum: 0,
        billerId: "",
        manager: "",
        custManager: "",

        custName: "",
        projectName: "",
        billerName: "",
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
      return this.tabs.map(function (m) {
        return {
          FGroupCode: m.FGroupCode,
          FGroupName: m.FGroupName,
          FSum: m.FChildren.map(function (m) {
            return Number(m.FBudgetSum);
          }).reduce(function (total, num) {
            return total + num;
          }, 0),
        };
      });
    },
    summary1() {
      var temp = this.tabs.map(function (m) {
        return {
          FGroupCode: m.FGroupCode,
          FGroupName: m.FGroupName,
          FSum: m.FChildren.map(function (m) {
            return Number(m.FBudgetSum);
          }).reduce(function (total, num) {
            return total + num;
          }, 0),
        };
      });
      var r = {};
      temp.forEach(function (row) {
        r[row.FGroupName] = row["FSum"];
      });
      return r;
    },
  },
  watch: {
    "form.sum"(newV, oldV) {
      this.form.totalSum = math.add(newV, this.form.addSum);
    },
    "form.addSum"(newV, oldV) {
      this.form.totalSum = math.add(newV, this.form.sum);
    },
  },
  methods: {
    openBaseDialog(type, title, success) {
      openDialog({
        title: title,
        url: "./modal/Dialog.aspx",
        onSuccess: function (layero, index) {
          var iframeWin = window[layero.find("iframe")[0]["name"]];
          iframeWin.init({ layer, dialogType: type });
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
      this.openBaseDialog("custom", "选择客户", function (result) {
        var result = result[0];
        var id = result.id,
          code = result.code,
          name = result.name;
        self.form.custName = name;
        self.form.custId = id;
        self.$refs.form.validateField("custName");
      });
    },
    openProject() {
      this.openBaseDialog("project", "选择项目", function (result) {
        var result = result[0];
        var id = result.id,
          code = result.code,
          name = result.name;
        self.form.projectName = name;
        self.form.projectId = id;
        self.$refs.form.validateField("projectName");
      });
    },
    onTabClick(tab, event) {
      //  console.log(tab);
    },
    showGroup(item) {
      var title = item.FItemName;
      openDialog({
        title: title,
        url:
          "./modalTree/ModalTree.aspx?" +
          utils.obj2Url({ v: new Date() * 1, state: self.query.state }),
        onSuccess: function (layero, index) {
          var iframeWin = window[layero.find("iframe")[0]["name"]];
          iframeWin.init({ layer, group: item });
        },
        btn: this.query.state == "read" ? [] : ["确定", "取消"],
        onBtnYesClick: function (index, layero) {
          var iframeWin = window[layero.find("iframe")[0]["name"]];
          var row = iframeWin.getResult();

          if (row.length <= 0) {
            layer.msg("预算录入不完整!", { icon: 5 });
          } else {
            var total = row.filter(function (f) {
              return f.code == item.FItemCode;
            })[0];
            self.doSaveItem(
              {
                accountId: item.FAccountID,
                projectId: item.FProjectID,
                entryId: item.FEntryID,
                budgetPrice: total.budgetPrice,
                budgetQty: total.budgetQty,
                budgetSum: total.budgetSum,
                code: item.FItemCode,
              },
              row,
              function () {
                item.FBudgetPrice = total.budgetPrice;
                item.FBudgetQty = total.budgetQty;
                item.FBudgetSum = total.budgetSum;
                item.FChildren = row;
                layer.close(index);
              }
            );
          }
        },
      });
    },
    showGroupDetail(item) {
      this.activeName = item.FGroupCode;
    },
    doInitBill(id) {
      $.ajax({
        type: "POST",
        url: "./BudgetHandler.ashx",
        async: true,
        data: {
          SelectApi: "getBudgetlist",
          accountId: "250116",
          billId: id,
        },
        dataType: "json",
        success: function (result) {
          if (result.state == "success") {
            result = result.data[0];
            self.form.accountId = result.FAccountID;
            self.form.custId = result.FCustID;
            self.form.projectId = result.FProjectID;
            self.form.contractNo = result.FContractNo;
            self.form.sum = result.FSum;
            self.form.addSum = result.FAddSum;
            self.form.totalSum = result.FTotalSum;
            self.form.billerId = result.FBillerID;
            self.form.manager = result.FManager;
            self.form.custManager = result.FCustManager;

            self.form.custName = result.FCustName;
            self.form.projectName = result.FProjectName;
            // self.form.billerName = result.FAccountID;

            self.doInitBillEntry();
          } else {
            layer.msg(result.msg, { icon: result.icon });
          }
        },
        error: function () {
          layer.msg("生成预算明细发生错误!", { icon: 5 });
        },
      });
    },
    doInitBillEntry(index) {
      $.ajax({
        type: "POST",
        url: "./BudgetHandler.ashx",
        async: true,
        data: {
          SelectApi: "genBudgetDetail",
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
          layer.msg("生成预算明细发生错误!", { icon: 5 });
        },
      });
    },
    doGenBudget() {
      if (this.form.custId == "" || this.form.projectId == "") {
        return layer.msg("请先选择客户和项目!", { icon: 5 });
      } else {
        layer.confirm(
          "确定要生成预算单明细吗?",
          { icon: 3, title: "提示" },
          function (index) {
            self.doInitBillEntry(index);
          }
        );
      }
    },
    doCancelEdit() {
      this.query.state = "read";
    },
    doEdit() {
      this.query.state = "edit";
    },
    doSaveItem(main, forms, success) {
      $.ajax({
        type: "POST",
        url: "./BudgetHandler.ashx",
        async: true,
        data: {
          SelectApi: "savebudgetItem",
          mainStr: JSON.stringify(main),
          formStr: JSON.stringify(forms),
        },
        dataType: "json",
        success: function (result) {
          if (result.state == "success") {
            success && success();
          }
          layer.msg(result.msg, { icon: result.icon });
        },
        error: function () {
          layer.msg("生成预算明细发生错误!", { icon: 5 });
        },
      });
    },
    doSave() {
      this.$refs["form"].validate(function (valid) {
        if (valid) {
          if (math.add(this.form.sum, 0) == 0) {
            return layer.msg("预算金额应该大于0!", { icon: 5 });
          }
          layer.confirm(
            "确定要保存预算单吗?",
            { icon: 3, title: "提示" },
            function (index) {
              $.ajax({
                type: "POST",
                url: "./BudgetHandler.ashx",
                async: true,
                data: Object.assign(
                  {},
                  {
                    SelectApi: "savebudget",
                  },
                  self.form
                ),
                dataType: "json",
                success: function (result) {
                  if (result.state == "success") {
                    layer.close(index);
                  }
                  layer.msg(result.msg, { icon: result.icon });
                },
                error: function () {
                  layer.msg("生成预算明细发生错误!", { icon: 5 });
                },
              });
            }
          );
        } else {
          return false;
        }
      });
    },
  },
  mounted() {
    this.query = utils.url2Obj(window.location.search);
    if (this.query.state == void 0) {
      this.query.state = "add";
    }
    if (this.query.state == "read") {
      this.doInitBill(this.query.id);
    }
  },
}));

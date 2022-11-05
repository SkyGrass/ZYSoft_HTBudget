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
    var curDate = dayjs().format("YYYY-MM-DD");
    return {
      form: {
        accountId: accountId,
        custId: "",
        projectId: "",
        contractNo: "",
        sum: 0,
        addSum: 0,
        totalSum: 0,
        billerId: loginUserId,
        manager: "",
        custManager: "",
        year: "",
        custName: "",
        projectName: "",
        billerName: loginName,
        projectType: "",
        date: curDate,
        id: -1,
        index: -1,
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
        projectType: [
          { required: true, message: "项目类型不可为空!", trigger: "blur" },
        ],
        date: [
          { required: true, message: "制单日期不可为空!", trigger: "blur" },
        ],
        contractNo: [
          { required: true, message: "合同号不可为空!", trigger: "blur" },
        ],
        manager: [
          { required: true, message: "项目经理不可为空!", trigger: "blur" },
        ],
        //custManager: [
        //  { required: true, message: "客户项目经理不可为空!", trigger: "blur" },
        //],
        // sum: [{ required: true, message: "金额不能为空", trigger: "blur" }],
        // addSum: [
        //   { required: true, message: "增补金额不能为空", trigger: "blur" },
        // ],
        // year: [{ required: false, message: "年份不能为空", trigger: "blur" }],
      },
      activeName: "",
      yearSign: false,
      projectTypes: []
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
      var t = this.tabs
        .filter(function (f) {
          return f.FIsSp == 0;
        })
        .map(function (m) {
          return {
            FIsTotal: 0,
            FGroupCode: m.FGroupCode,
            FGroupName: m.FGroupName,
            FSum: m.FChildren.map(function (m) {
              return Number(m.FBudgetSum);
            }).reduce(function (total, num) {
              return Number(math.eval(total + "+" + num)).toFixed(2);
            }, 0),
          };
        });
      var total = t
        .map(function (f) {
          return f.FSum;
        })
        .reduce(function (total, num) {
          return Number(math.eval(total + "+" + num)).toFixed(2);
        }, 0);
      return t.concat([
        {
          FIsTotal: 1,
          FGroupCode: "合计",
          FGroupName: "",
          FSum: total,
        },
      ]);
    },
    printObj() {
      return {
        FBillType: 1,
        FAccountID: this.form.accountId,
        FItemID: this.form.id,
      };
    },
  },
  watch: {
    "form.sum"(newV, oldV) {
      this.form.totalSum = math.add(newV, this.form.addSum);
    },
    "form.addSum"(newV, oldV) {
      this.form.totalSum = math.add(newV, this.form.sum);
    },
    yearSign(newV, oldV) {
      if (newV) {
        this.rules.year[0].required = newV;
      }
    },
  },
  methods: {
    closeDialog(dialogType, row) {
      var result = row;
      switch (dialogType) {
        case "custom":
          self.openCustomDone([result]);
          break;
        case "project":
          self.openProjectDone([result]);
          break;
      }
      layer.close(self.index);
    },
    openBaseDialog(type, title, success, filter) {
      openDialog({
        title: title,
        url: "./modal/Dialog.aspx?filter=" + filter,
        onSuccess: function (layero, index) {
          self.index = index;
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
        self.openCustomDone,
        this.form.custName
      );
    },
    openCustomDone(result) {
      var result = result[0];
      var id = result.id,
        code = result.code,
        name = result.name;
      self.form.custName = name;
      self.form.custId = id;
      self.$refs.form.validateField("custName");
    },
    openProject() {
      this.openBaseDialog(
        "project",
        "选择项目",
        self.openProjectDone,
        this.form.projectName
      );
    },
    openProjectDone(result) {
      var result = result[0];
      var id = result.id,
        code = result.code,
        name = result.name,
        yearSign = result.YearSign == "是",
        year = result.Year;
      self.form.projectName = name;
      self.form.projectId = id;
      self.form.contractNo = code;
      self.yearSign = yearSign;
      self.form.year = year;
      if (yearSign && year == "") {
        layer.msg("没有取到利润年度信息!", { icon: 5 });
      }
      self.$refs.form.validateField("projectName");
    },
    onTabClick(tab, event) {
      document.getElementById(self.activeName).scrollIntoView({
        behavior: "smooth",
      });
    },
    showGroup(item) {
      var title = item.FItemName;
      openDialog({
        title: title,
        url:
          "./modalBudgetTree/ModalBudgetTree.aspx?" +
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
                item.FBudgetQty = total.budgetQty;
                item.FBudgetPrice = total.budgetPrice;
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
    doInitBill(query) {
      $.ajax({
        type: "POST",
        url: "./BudgetHandler.ashx",
        async: true,
        data: {
          SelectApi: "getBudgetlist",
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
            self.form.sum = result.FSum;
            self.form.addSum = result.FAddSum;
            self.form.totalSum = result.FTotalSum;
            self.form.billerId = result.FBillerID;
            self.form.manager = result.FManager;
            self.form.custManager = result.FCustManager;
            self.form.year = result.FYear;
            self.form.projectType = result.FProjectType;

            // self.form.budget = result.FSum;

            self.form.date = result.FCreateDate;
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
          layer.msg("查询预算单发生错误!", { icon: 5 });
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
          year: this.form.year,
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
          layer.msg("查询预算明细发生错误!", { icon: 5 });
        },
      });
    },
    beforeGen(success) {
      $.ajax({
        type: "POST",
        url: "./BudgetHandler.ashx",
        async: true,
        data: {
          SelectApi: "check",
          accountId: this.form.accountId,
          projectId: this.form.projectId,
          year: this.form.year,
        },
        dataType: "json",
        success: function (result) {
          if (result.state == "success") {
            if (result.data == 1) {
              layer.msg(result.msg, { icon: 5 });
            } else {
              success && success();
            }
          }
          layer.close(index);
        },
        error: function () {
          layer.close(index);
          layer.msg("检查数据合法性发生错误!", { icon: 5 });
        },
      });
    },
    doGenBudget() {
      if (this.form.custId == "" || this.form.projectId == "") {
        return layer.msg("请先选择客户、项目 !", { icon: 5 });
      } else {
        layer.confirm(
          "确定要生成预算单明细吗?",
          { icon: 3, title: "提示" },
          function (index) {
            self.beforeGen(function () {
              self.doInitBillEntry(index);
            });
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
          // if (math.add(self.form.sum, 0) == 0) {
          //   return layer.msg("预算金额应该大于0!", { icon: 5 });
          // }
          if (self.tabs.length <= 0) {
            return layer.msg("请先生成预算明细再保存!", { icon: 5 });
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
                  self.form,
                  {
                    sum: self.form.totalSum
                  }
                ),
                dataType: "json",
                success: function (result) {
                  if (result.state == "success") {
                    layer.close(index);
                    self.query.state = "read";
                    self.query.id = result.data;

                    if ($.isFunction(top.CreateTab)) {
                      top.CreateTab(
                        "App/ZYSoft/ZYSoft.HT/BudgetFormPage.aspx?" +
                        utils.obj2Url(self.query),
                        "预算表",
                        "YS1001"
                      );
                    }
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
    queryProjectTypes() {
      $.ajax({
        type: "POST",
        url: "./BudgetHandler.ashx",
        async: true,
        data: {
          SelectApi: "getprojecttypes",
          accountId: accountId
        },
        dataType: "json",
        success: function (result) {
          if (result.state == "success") {
            self.projectTypes = result.data
          }
          if (result.msg != ''){
            layer.msg(result.msg, { icon: result.icon });
          }
        },
        error: function () {
          layer.msg("未能查询到项目类型!", { icon: 5 });
        },
      });
    }
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

    this.queryProjectTypes();
  },
}));

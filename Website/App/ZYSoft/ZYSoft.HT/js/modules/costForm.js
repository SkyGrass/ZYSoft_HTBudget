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

Vue.mixin(printMixin);
var s = { cost: 0 };
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
        addSum: 0,
        totalSum: 0,
        billerId: loginUserId,
        manager: "",
        custManager: "",
        endDate: "",
        projectType: "",
        year: "",
        cost: 0,
        custName: "",
        projectName: "",
        billerName: loginName,
        id: -1,
      },
      query: {},
      list: [{ FGroupCode: "", FGroupName: "从属合同、增补合同", FIsSp: 1 }],
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
        endDate: [
          { required: true, message: "竣工日期不能为空", trigger: "blur" },
        ],
        projectType: [
          { required: true, message: "项目类型不能为空", trigger: "blur" },
        ],
      },
      contractList: [],
      activeName: "",
      offset: {
        top: 0,
        left: 0,
      },
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
      if (self.list == void 0) {
        return [];
      } else
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
      return this.tabs
        .filter(function (f) {
          return f.FIsSp == 0;
        })
        .map(function (m) {
          return {
            FIsTotal: 0,
            FGroupCode: m.FGroupCode,
            FGroupName: m.FGroupName,
            FSum: m.FChildren.map(function (m) {
              return Number(m.FCostSum);
            }).reduce(function (total, num) {
              return Number(math.eval(total + "+" + num)).toFixed(2);
            }, 0),
          };
        })
        .concat([
          {
            FIsTotal: 1,
            FGroupCode: "合计",
            FGroupName: "",
            FSum: (self.form || s).cost,
          },
        ]);
    },
    printObj() {
      return {
        FBillType: 2,
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
      document.getElementById(self.activeName).scrollIntoView({
        behavior: "smooth",
      });
    },
    showGroup(item) {
      var title = item.FItemName;
      openDialog({
        title: title,
        url:
          "./modalCostTree/modalCostTree.aspx?" +
          utils.obj2Url({ v: new Date() * 1, state: self.query.state }),
        onSuccess: function (layero, index) {
          layer.setTop(layero);
          self.offset.top = $(layero).offset().top - 80;
          self.offset.left = $(layero).offset().left + 40;
          var iframeWin = window[layero.find("iframe")[0]["name"]];
          iframeWin.init({ layer, group: item, parent: self });
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
                costPrice: total.costPrice,
                costQty: total.costQty,
                costSum: total.costSum,
                code: item.FItemCode,
              },
              row,
              function () {
                item.FCostPrice = total.costPrice;
                item.FCostQty = total.costQty;
                item.FCostSum = total.costSum;
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
    showNodeDetail(node) {
      var title = "材料明细";
      if (node.FItemType == "费用") {
        title = "费用明细";
      }
      openDialog({
        title: title,
        url: "./modalCostDetail/ModalCostDetail.aspx",
        offset: [self.offset.top, self.offset.left],
        btn: ["确定"],
        onSuccess: function (layero, index) {
          var iframeWin = window[layero.find("iframe")[0]["name"]];
          iframeWin.init({ node });
        },
        onBtnYesClick: function (index, layero) {
          layer.close(index);
        },
      });
    },
    doInitBill(query) {
      $.ajax({
        type: "POST",
        url: "./BudgetHandler.ashx",
        async: true,
        data: {
          SelectApi: "getCostlist",
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

            self.form.endDate =
              result.FEndDate != null && result != void 0
                ? new dayjs(result.FEndDate).format("YYYY-MM-DD")
                : "";
            self.form.projectType = result.FProjectType;

            self.form.cost = result.FCost;

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
          layer.msg("查询成本单发生错误!", { icon: 5 });
        },
      });
    },
    doInitBillEntry(index) {
      $.ajax({
        type: "POST",
        url: "./BudgetHandler.ashx",
        async: true,
        data: {
          SelectApi: "checkcostdetail",
          accountId: this.form.accountId,
          projectId: this.form.projectId,
        },
        dataType: "json",
        success: function (result) {
          if (result.state == "success") {
            self.list = self.list.concat(result.data);
          }
          layer.close(index);
        },
        error: function () {
          layer.close(index);
          layer.msg("查询成本明细发生错误!", { icon: 5 });
        },
      });
    },
    doInitContract(query) {
      $.ajax({
        type: "POST",
        url: "./BudgetHandler.ashx",
        async: true,
        data: {
          SelectApi: "getContractlist",
          accountId: this.form.accountId,
          id: query.id,
        },
        dataType: "json",
        success: function (result) {
          if (result.state == "success") {
            self.contractList = result.data.map(function (row, index) {
              row.FIndex = index + 1;
              row.FDate = dayjs(row.FDate).format("YYYY-MM-DD");
              return row;
            });
          }
        },
        error: function () {
          layer.msg("查询增补合同发生错误!", { icon: 5 });
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
      this.doInitContract(this.query);
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

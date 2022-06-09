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
var table = {};
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
        billerId: loginUserId,
        manager: "",
        custManager: "",
        date: curDate,
        projectType: "",
        custName: "",
        projectName: "",
        billerName: loginName,
        memo: "",
        billNo: "",
        id: "-1",
      },
      query: {},
      rules: {
        billNo: [{ required: true, message: "单号不可为空!", trigger: "blur" }],
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
        date: [{ required: true, message: "日期不能为空", trigger: "blur" }],
        projectType: [
          { required: true, message: "项目类型不能为空", trigger: "blur" },
        ],
      },
      canShow: false,
    };
  },
  computed: {},
  watch: {},
  methods: {
    doPick() {
      if (self.form.projectId == "") {
        return layer.msg("请先选择项目", { icon: 5 });
      }
      openDialog({
        title: "选择销货单",
        url: "./modalJsPick/ModalJsPick.aspx",
        area: ["90%", "500px"],
        onSuccess: function (layero, index) {
          var iframeWin = window[layero.find("iframe")[0]["name"]];
          iframeWin.init({
            layer,
            accountId: self.form.accountId,
            projectId: self.form.projectId,
          });
        },
        onBtnYesClick: function (index, layero) {
          var iframeWin = window[layero.find("iframe")[0]["name"]];
          var rows = iframeWin.getSelect();
          if (rows.length > 0) {
            var row = rows[0];
            self.form.custId = row.FCustID;
            self.form.custName = row.FCustName;
            self.form.manager = row.FManager;
            self.form.custManager = row.FCustManager;

            table
              .setData(rows)
              .then(function () {
                var total = rows
                  .map(function (row) {
                    return row.FSum;
                  })
                  .reduce(function (total, num) {
                    return total + num;
                  }, 0);
                self.form.sum = total;
              })
              .catch(function (error) {
                //handle error loading data
              });
            layer.close(index);
          }
        },
      });
    },
    openBaseDialog(type, title, success) {
      openDialog({
        title: title,
        url: "./modal/Dialog.aspx",
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
        self.form.contractNo = code;
        self.$refs.form.validateField("projectName");
      });
    },
    doSave() {
      this.$refs["form"].validate(function (valid) {
        if (valid) {
          if (table.getData().length <= 0) {
            return layer.msg("没有发现表体记录!", { icon: 5 });
          }
          layer.confirm(
            "确定要保存结算单吗?",
            { icon: 3, title: "提示" },
            function (index) {
              $.ajax({
                type: "POST",
                url: "./BudgetHandler.ashx",
                async: true,
                data: Object.assign(
                  {},
                  {
                    SelectApi: "savejs",
                  },
                  {
                    mainStr: JSON.stringify(
                      [self.form].map(function (row) {
                        return {
                          FItemID: row.id,
                          FAccountID: row.accountId,
                          FBillNo: row.billNo,
                          FDate: row.date,
                          FCustID: row.custId,
                          FProjectID: row.projectId,
                          FContractNo: row.contractNo,
                          FManager: row.manager,
                          FCustManager: row.custManager,
                          FMemo: row.memo,
                          FSum: row.sum,
                          FBillerID: row.billerId,
                          FProjectType: row.projectType,
                        };
                      })[0]
                    ),
                    formStr: JSON.stringify(
                      table.getData().map(function (row) {
                        row.FSourceBillNo = row.FBillNo;
                        row.FSourceBillID = row.FID;
                        row.FSourceBillEntryID = row.EntryID;
                        return row;
                      })
                    ),
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
                        "App/ZYSoft/ZYSoft.HT/JSFormPage.aspx?" +
                          utils.obj2Url(self.query),
                        "结算单",
                        "YS1004"
                      );
                    }
                  }
                  layer.msg(result.msg, { icon: result.icon });
                },
                error: function () {
                  layer.msg("保存结算单发生错误!", { icon: 5 });
                },
              });
            }
          );
        } else {
          return false;
        }
      });
    },
    doCancelEdit() {
      this.query.state = "read";
      table.updateColumnDefinition("FQty", { editor: false });
      table.updateColumnDefinition("FPrice", { editor: false });
      table.updateColumnDefinition("FSum", { editor: false });
    },
    doEdit() {
      if (self.canShow) {
        return layer.msg("当前单据已审批,禁止编辑!", { icon: 5 });
      }
      this.query.state = "edit";
      table.updateColumnDefinition("FQty", { editor: "number" });
      table.updateColumnDefinition("FPrice", { editor: "number" });
      table.updateColumnDefinition("FSum", { editor: "number" });
    },
    doInitBillNo() {
      $.ajax({
        type: "POST",
        url: "./BudgetHandler.ashx",
        async: true,
        data: {
          SelectApi: "genbillno",
        },
        dataType: "json",
        success: function (result) {
          if (result.state == "success") {
            result = result.data;
            self.form.billNo = result;
          }
        },
      });
    },
    doInitBill(query) {
      $.ajax({
        type: "POST",
        url: "./BudgetHandler.ashx",
        async: true,
        data: {
          SelectApi: "getjslist",
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

            self.form.billerId = result.FBillerID;
            self.form.manager = result.FManager;
            self.form.custManager = result.FCustManager;
            self.form.date = result.FDate;
            self.form.projectType = result.FProjectType;
            self.form.billNo = result.FBillNo;
            self.form.memo = result.FMemo;
            self.form.custName = result.FCustName;
            self.form.projectName = result.FProjectName;
            self.form.billerName = result.FBillerName;
            self.form.id = result.FItemID;
            self.canShow = result.FVeriferID != "" && result.FVeriferID != null;
            self.doInitBillEntry(result.FItemID);
          } else {
            layer.msg(result.msg, { icon: result.icon });
          }
        },
        error: function () {
          layer.msg("查询结算单发生错误!", { icon: 5 });
        },
      });
    },
    doInitBillEntry(billId) {
      $.ajax({
        type: "POST",
        url: "./BudgetHandler.ashx",
        async: true,
        data: {
          SelectApi: "getjsdetail",
          billId: billId,
        },
        dataType: "json",
        success: function (result) {
          if (result.state == "success") {
            table.setData(
              result.data.map(function (row) {
                row.FBillNo = row.FSourceBillNo;
                row.FID = row.FSourceBillID;
                row.EntryID = row.FSourceBillEntryID;
                return row;
              })
            );
          } else {
            layer.msg(result.msg, { icon: result.icon });
          }
        },
        error: function () {
          layer.msg("生成预算明细发生错误!", { icon: 5 });
        },
      });
    },
    initGrid(callback) {
      var maxHeight =
        $(window).height() -
        $("#header").height() -
        $("#toolbarContainer").height() -
        $(".form").height() -
        3;
      table = new Tabulator("#grid", {
        locale: true,
        langs: langs,
        height: maxHeight,
        index: "EntryID",
        columnHeaderVertAlign: "bottom",
        columns: tableConf(this).concat([
          {
            formatter: function (cell, formatterParams, onRendered) {
              return "<el-tooltip  effect='dark' content='点击移除行' placement='right-end'><i class='el-icon-delete'/></el-tooltip>";
            },
            title: "操作",
            width: 80,
            headerHozAlign: "center",
            hozAlign: "center",
            headerSort: false,
            download: false,
            cellClick: function (e, cell) {
              if (self.query.state != "read") {
                cell
                  .getRow()
                  .delete()
                  .then(function () {
                    var total = table
                      .getData()
                      .map(function (row) {
                        return row.FSum;
                      })
                      .reduce(function (total, num) {
                        return Number(total) + Number(num);
                      }, 0);
                    self.form.sum = total;
                  });
              } else {
                layer.msg("请先编辑单据!", { icon: 5 });
              }
            },
          },
        ]),
      });

      table.on("tableBuilt", function () {
        callback && callback(table);
      });
    },
    reCalc(cell) {
      var value = cell.getValue();
      var oldValue = cell.getOldValue();
      if (value == oldValue) return;
      var field = cell.getField();
      var taxRate = cell.getRow().getCell("FTaxRate").getValue();
      var sum = 0,
        taxSum = 0,
        price = 0,
        taxPrice = 0,
        qty = 0,
        tax = 0;
      if (field == "FQty") {
        qty = value;
        price = Number(cell.getRow().getCell("FPrice").getValue());
        taxPrice = Number(cell.getRow().getCell("FTaxPrice").getValue());
        sum = math.eval(price + "*" + value);
        tax = math.eval(sum + "*" + taxRate);
        taxSum = math.eval(taxPrice + "*" + value);
        cell.getRow().update({ FSum: sum.toFixed(2) });
        cell.getRow().update({ FTaxSum: taxSum.toFixed(2) });
        cell.getRow().update({ FTax: tax.toFixed(2) });
      } else if (field == "FPrice") {
        price = value;
        qty = Number(cell.getRow().getCell("FQty").getValue()).toFixed(2);
        taxPrice = math.eval(value + "*" + "(1+" + taxRate + ")");
        sum = math.eval(qty + "*" + value);
        taxSum = math.eval(qty + "*" + taxPrice);
        tax = math.eval(sum + "*" + taxRate);

        cell.getRow().update({ FTaxPrice: taxPrice.toFixed(2) });
        cell.getRow().update({ FSum: sum.toFixed(2) });
        cell.getRow().update({ FTaxSum: taxSum.toFixed(2) });
        cell.getRow().update({ FTax: tax.toFixed(2) });
      } else if (field == "FSum") {
        sum = value;
        qty = cell.getRow().getCell("FQty").getValue();
        price = math.eval(sum + "/" + qty);
        taxPrice = math.eval(price + "*" + "(1+" + taxRate + ")");
        taxSum = math.eval(taxPrice + "*" + qty);
        tax = math.eval(sum + "*" + taxRate);

        cell.getRow().update({ FSum: sum.toFixed(2) });
        cell.getRow().update({ FPrice: price.toFixed(2) });
        cell.getRow().update({ FTaxPrice: taxPrice.toFixed(2) });
        cell.getRow().update({ FTaxSum: taxSum.toFixed(2) });
        cell.getRow().update({ FTax: tax.toFixed(2) });
      }
      var total = table
        .getData()
        .map(function (row) {
          return row.FSum;
        })
        .reduce(function (total, num) {
          return Number(total) + Number(num);
        }, 0);
      self.form.sum = total;
    },
    doVerify() {
      if (loginUserId == "")
        return layer.msg("没有获取到当前账套登录信息!", { icon: 5 });
      layer.confirm(
        "确定要审批单据吗?",
        { icon: 3, title: "提示" },
        function (index) {
          $.ajax({
            type: "POST",
            url: "./BudgetHandler.ashx",
            async: true,
            data: {
              SelectApi: "verfiy",
              ids: self.form.id,
              billerId: loginUserId,
              flag: 0,
            },
            dataType: "json",
            success: function (result) {
              if (result.state == "success") {
                self.doInitBill({ id: self.form.id });
                layer.msg(result.msg, { icon: 1 });
                layer.close(index);
              } else {
                layer.msg(result.msg, { icon: 5 });
              }
            },
          });
        }
      );
    },
    doUnVerify() {
      if (loginUserId == "")
        return layer.msg("没有获取到当前账套登录信息!", { icon: 5 });
      layer.confirm(
        "确定要反审批单据吗?",
        { icon: 3, title: "提示" },
        function (index) {
          $.ajax({
            type: "POST",
            url: "./BudgetHandler.ashx",
            async: true,
            data: {
              SelectApi: "verfiy",
              ids: self.form.id,
              billerId: loginUserId,
              flag: 1,
            },
            dataType: "json",
            success: function (result) {
              if (result.state == "success") {
                self.doInitBill({ id: self.form.id });
                layer.msg(result.msg, { icon: 1 });
                layer.close(index);
              } else {
                layer.msg(result.msg, { icon: 5 });
              }
            },
          });
        }
      );
    },
  },
  mounted() {
    this.query = utils.url2Obj(window.location.search);
    if (this.query.state == void 0 || this.query.state == "add") {
      this.query.state = "add";
      this.doInitBillNo();
    }
    if (this.query.state == "read") {
      this.doInitBill(this.query);
    }
    this.initGrid(function () {
      window.onresize = function () {
        table.setHeight(
          $(window).height() -
            $("#header").height() -
            $("#toolbarContainer").height() -
            $(".form").height() -
            3
        );
      };
    });
  },
}));

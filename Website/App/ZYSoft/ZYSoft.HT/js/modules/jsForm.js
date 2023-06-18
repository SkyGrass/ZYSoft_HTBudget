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
//accountId = 250116
var self = (vm = new Vue({
  el: "#app",
  data() {
    var curDate = dayjs().format("YYYY-MM-DD");
    return {
      form: {
        accountId: accountId || localStorage.getItem('t_accountId'),
        custId: "",
        custName: "",
        sum: 0,
        taxsum: 0,
        memo: "",
        billNo: "",
        date: curDate,
        id: "-1",
        billerId: loginUserId,
        billerName: loginName,
        veriferId: '',
        veriferName: '',
        veriferDate: ""
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
        sum: [{ required: true, message: "结算金额不能为空", trigger: "blur" }],
        taxsum: [{ required: true, message: "含税金额不能为空", trigger: "blur" }],
        date: [{ required: true, message: "日期不能为空", trigger: "blur" }]
      },
      canShow: false,
      index: -1,
      index1: -1,
      forbidden: false
    };
  },
  computed: {},
  watch: {
    "form.custName": function (newV, oldV) {
      if (newV == "") {
        this.form.custId = ""
      }
    }
  },
  methods: {
    doAdd() {
      if ($.isFunction(top.CreateTab)) {
        if (this.query.state == "edit") {
          layer.confirm(
            "确定要放弃编辑新增单据吗?",
            { icon: 3, title: "提示" },
            function (index) {
              top.CreateTab(
                "App/ZYSoft/ZYSoft.HT/JSFormPage.aspx?" +
                utils.obj2Url({
                  state: "add",
                  v: new Date() * 1,
                }),
                "结算单",
                "JS" + new Date() * 1
              );
            });
        } else {
          top.CreateTab(
            "App/ZYSoft/ZYSoft.HT/JSFormPage.aspx?" +
            utils.obj2Url({
              state: "add",
              v: new Date() * 1,
            }),
            "结算单",
            "JS" + new Date() * 1
          );
        }

      }
    },
    doPick() {
      openDialog({
        title: "选择销货单",
        url: "./modalJsPick/ModalJsPick.aspx",
        area: ["90%", "570px"],
        onSuccess: function (layero, index) {
          self.index1 = index;
          var iframeWin = window[layero.find("iframe")[0]["name"]];
          iframeWin.init({
            layer,
            accountId: self.form.accountId,
            custId: self.form.custId,
            custName: self.form.custName,
            openDialog: openDialog
          });
        },
        onBtnYesClick: function (index, layero) {
          var iframeWin = window[layero.find("iframe")[0]["name"]];
          var rows = iframeWin.getSelect();
          self.pickDone(rows, index);
        },
      });
    },
    pickDone(rows, index) {
      if (rows.length > 0) {
        var oldRows = table.getData();
        var custId = rows[0].FCustID;
        var custName = rows[0].FCustName;
        self.form.custId = custId;
        self.form.custName = custName;
        rows.forEach(function (r) {
          var isExist = oldRows.filter(function (old) {
            return r.FBillNo == old.FBillNo
          });
          if (isExist.length <= 0) {
            oldRows.push(r)
          }
        });
        this.forbidden = true;
        table
          .setData(oldRows)
          .then(function () {
            var total = rows
              .map(function (row) {
                return row.FAccountSum;
              })
              .reduce(function (total, num) {
                return total + num;
              }, 0);
            self.form.sum = total;

            var total1 = rows
            .map(function (row) {
              return row.FAccountTaxSum;
            })
            .reduce(function (total, num) {
              return total + num;
            }, 0);
          self.form.taxsum = total1;
          })
          .catch(function (error) {
            //handle error loading data
          });
        layer.close(index);
      }
    },
    closePickerDialog(dialogType, row) {
      self.pickDone([row], self.index1);
    },
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
            layer: window.parent.layer,
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
        this.openCustomDone,
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
    doSave() {
      var _d = table.getData().map(function (r) { return r.FAccountSum });
      this.form.sum = _d.reduce(function (total, num) {
        return total + num;
      }, 0);

      var _d1 = table.getData().map(function (r) { return r.FAccountTaxSum });
      this.form.taxsum = _d1.reduce(function (total, num) {
        return total + num;
      }, 0);
      this.$refs["form"].validate(function (valid) {
        if (valid) {
          if (table.getData().length <= 0) {
            return layer.msg("没有发现表体记录!", { icon: 5 });
          }
          if (table.getData().filter(function (r) {
            return math.add(r.FAccountSum, 0) == 0;
          }).length > 0) {
            return layer.msg("发现金额为0的表体记录!", { icon: 5 });
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
                          FMemo: row.memo,
                          FAccountSum: 0,
                          FAccountTaxSum: 0,
                          FBillerID: row.billerId,
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
                        "JS" + result.data
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
      table.updateColumnDefinition("FAccountSum", { editor: false });
      table.updateColumnDefinition("FAccountTaxSum", { editor: false });
    },
    doEdit() {
      if (self.canShow) {
        return layer.msg("当前单据已审核,禁止编辑!", { icon: 5 });
      }
      this.query.state = "edit";
      table.updateColumnDefinition("FAccountSum", { editor: "number" });
      table.updateColumnDefinition("FAccountTaxSum", { editor: "number" });
      table.updateColumnDefinition("FEntryMemo", { editor: "input" });
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
            self.form.sum = numeral(result.FTotalAccountSum).format('0,0.00');
            self.form.taxsum = numeral(result.FTotalAccountTaxSum).format('0,0.00');;

            self.form.veriferId = result.FVeriferID;
            self.form.veriferName = result.FVeriferName;
            if (result.FVerifyDate != '' && result.FVerifyDate != null) {
              self.form.veriferDate = dayjs(result.FVerifyDate).format('YYYY-MM-DD HH:mm:ss');
            }

            self.form.billerId = result.FBillerID;
            self.form.date = result.FDate;
            self.form.billNo = result.FBillNo;
            self.form.memo = result.FMemo;
            self.form.custName = result.FCustName;
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
          accountId: this.form.accountId,
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
          layer.msg("生成结算明细发生错误!", { icon: 5 });
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
        index: "FID",
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

                    var total1 = table
                    .getData()
                    .map(function (row) {
                      return row.FTaxSum;
                    })
                    .reduce(function (total, num) {
                      return Number(total) + Number(num);
                    }, 0);
                    self.form.taxsum = total1;
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

      table.on("rowDeleted", function (row) {
        self.forbidden = table.getData().length > 0
      });
    },
    beforeVerify() {
      result = false;
      try {
        if (window.TAjax) {
          const check = window.TAjax.GetVchAttCount('ZYSoftProjectAccount', this.form.id + '')
          if (check.value <= 0) {
            layer.msg("请先上传附件!", { icon: 5 });
          }
          return check.value > 0
        } else {
          layer.msg("请在T+环境操作单据!", { icon: 5 });
        }
      } catch (error) {
        layer.msg("操作出现异常!", { icon: 5 });
      }
      return result
    },
    doVerify() {
      if (loginUserId == "")
        return layer.msg("没有获取到当前账套登录信息!", { icon: 5 });
      if (this.beforeVerify()) {
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
                accountId: self.form.accountId,
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
      }
    },
    doUnVerify() {
      if (loginUserId == "")
        return layer.msg("没有获取到当前账套登录信息!", { icon: 5 });
      layer.confirm(
        "确定要弃审单据吗?",
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
              accountId: self.form.accountId,
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
    doAttachments() {
      var url = window.parent.$T.Request.CombineUrl("/tplus/" + "CommonPage/VoucherExt/Attachments.aspx", {
        associateid: this.form.id,
        TemplateName: 'ZYSoftProjectAccount',
        mId: 'SA999',
        sysId: 'SA',
        AccessState: 'Edit'
      });
      window.parent.showModalDialog(url, self, "dialogWidth:600px;dialogHeight:300px;help:no;status:no", function (ret) { })
    },
    reCalc(cell) {
      var result = table.getCalcResults();
      if (result.bottom.FAccountSum == void 0) {
        var _d = table.getData().map(function (r) { return r.FAccountSum });
        this.form.sum = _d.reduce(function (total, num) {
          return total + num;
        }, 0);
      } else {
        this.form.sum = result.bottom.FAccountSum
      }

      if (result.bottom.FAccountTaxSum == void 0) {
        var _d1 = table.getData().map(function (r) { return r.FAccountTaxSum });
        this.form.taxsum = _d1.reduce(function (total, num) {
          return total + num;
        }, 0);
      } else {
        this.form.taxsum = result.bottom.FAccountTaxSum
      }

      try {
        var index = cell.getRow().getNextRow().getIndex();
        if (index) {
          cell.getRow().getNextRow().getCell('FAccountSum').edit(true)
        }
      } catch (e) {
        var cell = table.getRows()[0].getCell('FAccountSum');
        cell.edit(true)
      }

      try {
        var index = cell.getRow().getNextRow().getIndex();
        if (index) {
          cell.getRow().getNextRow().getCell('FAccountTaxSum').edit(true)
        }
      } catch (e) {
        var cell = table.getRows()[0].getCell('FAccountTaxSum');
        cell.edit(true)
      }
    }
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

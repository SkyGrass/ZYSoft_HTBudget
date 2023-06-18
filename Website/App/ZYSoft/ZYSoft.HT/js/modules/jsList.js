var table = {};
//accountId = "250116"
var self = (vm = new Vue({
  el: "#app",
  data() {
    var curDate = new dayjs();
    return {
      form: {
        startDate: curDate.startOf("year"),
        endDate: curDate.endOf("year"),
        accountId: accountId || localStorage.getItem('t_accountId'),
        custId: "",
        custName: "",
        billerName: "",
        billStatus: "",
        projectCode: "",
        projectName: ""
      },
      list: [],
      maxHeight: 0,
      offset: {
        top: 0,
        left: 0,
      },
      index: -1,
    };
  },
  computed: {},
  watch: {},
  methods: {
    closeBaseDataDialog(row) {
      layer.close(self.index);
    },
    openBaseDataDialog(type, title, success, filter) {
      openDialog({
        title: title,
        url: "./modal/Dialog.aspx?filter=" + filter,
        offset: [self.offset.top, self.offset.left],
        onSuccess: function (layero, index) {
          self.index = index;
          var iframeWin = window[layero.find("iframe")[0]["name"]];
          iframeWin.init({
            layer,
            dialogType: type,
            accountId: accountId || localStorage.getItem('t_accountId'),
          });
        },
        onBtnYesClick: function (index, layero) {
          var iframeWin = window[layero.find("iframe")[0]["name"]];
          var row = iframeWin.getSelect();
          if (row.length <= 0) {
            layer.msg("请先选择", { icon: 5 });
          } else if (!row) {
            layer.msg("最多只能选择一个", { icon: 5 });
          } else {
            success && success(row);
            layer.close(index);
          }
        },
      });
    },
    doAdd() {
      if ($.isFunction(top.CreateTab)) {
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
    },
    doQuery() {
      openDialog({
        url: "./modalJSFilter/ModalJSFilter.aspx",
        onSuccess: function (layero, index) {
          layer.setTop(layero);
          self.offset.top = $(layero).offset().top - 80;
          self.offset.left = $(layero).offset().left + 40;
          var iframeWin = window[layero.find("iframe")[0]["name"]];
          iframeWin.init({ layer, parent: self });
        },
        onBtnYesClick: function (index, layero) {
          var iframeWin = window[layero.find("iframe")[0]["name"]];
          var row = iframeWin.getSelect();
          if (row.length <= 0) {
            layer.msg("请先选择", { icon: 5 });
          } else if (!row) {
            layer.msg("最多只能选择一个", { icon: 5 });
          } else {
            var r = row[0];
            r = Object.assign(
              {},
              {
                SelectApi: "getjslist",
              },
              self.form,
              r
            );
            table.setData(
              "./BudgetHandler.ashx",
              Object.assign(
                {},
                {
                  SelectApi: "getjslist",
                },
                r
              ),
              "POST"
            );
            layer.close(index);
          }
        },
      });
    },
    doRefresh() {
      table.setData(
        "./BudgetHandler.ashx",
        Object.assign(
          {},
          {
            SelectApi: "getjslist",
          },
          self.form,
          {
            startDate: self.form.startDate == "" ? "" : dayjs(self.form.startDate).format("YYYY-MM-DD"),
            endDate: self.form.endDate == "" ? "" : dayjs(self.form.endDate).format("YYYY-MM-DD"),
          }
        ),
        "POST"
      );
    },
    doVerify() {
      if (table.getSelectedData().length <= 0)
        return layer.msg("请先选择要审核的记录行", { icon: 5 });
      var ids = table.getSelectedData().map(function (row) {
        return row.FItemID;
      });
      if (loginUserId == "")
        return layer.msg("没有获取到当前账套登录信息!", { icon: 5 });
      if (this.beforeVerify(table.getSelectedData())) {
        layer.confirm(
          "确定要批量审核选中记录吗?",
          { icon: 3, title: "提示" },
          function (index) {
            $.ajax({
              type: "POST",
              url: "./BudgetHandler.ashx",
              async: true,
              data: {
                SelectApi: "verfiy",
                ids: ids.join(","),
                billerId: loginUserId,
                accountId: accountId || localStorage.getItem('t_accountId'),
                flag: 0,
              },
              dataType: "json",
              success: function (result) {
                if (result.state == "success") {
                  self.doRefresh();
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
      if (table.getSelectedData().length <= 0)
        return layer.msg("请先选择要弃审的记录行", { icon: 5 });
      var ids = table.getSelectedData().map(function (row) {
        return row.FItemID;
      });
      layer.confirm(
        "确定要批量弃审选中记录吗?",
        { icon: 3, title: "提示" },
        function (index) {
          $.ajax({
            type: "POST",
            url: "./BudgetHandler.ashx",
            async: true,
            data: {
              SelectApi: "verfiy",
              ids: ids.join(","),
              billerId: loginUserId,
              accountId: accountId || localStorage.getItem('t_accountId'),
              flag: 1,
            },
            dataType: "json",
            success: function (result) {
              if (result.state == "success") {
                layer.msg(result.msg, { icon: 1 });
                self.doRefresh();
                layer.close(index);
              } else {
                layer.msg(result.msg, { icon: 5 });
              }
            },
          });
        }
      );
    },
    doDelete() {
      if (table.getSelectedData().length <= 0) {
        return layer.msg("尚未选择要删除的行", {
          zIndex: new Date() * 1,
          icon: 5,
        });
      }
      var ids = table
        .getSelectedData()
        .map(function (row) {
          return row.FItemID;
        })
        .join(",");
      layer.confirm(
        "确定要删除选中的行吗?",
        { icon: 3, title: "提示" },
        function (index) {
          $.ajax({
            type: "POST",
            url: "./BudgetHandler.ashx",
            async: true,
            data: {
              SelectApi: "deletejs",
              ids: ids,
            },
            dataType: "json",
            success: function (result) {
              if (result.state == "success") {
                self.doRefresh();
              }
              layer.msg(result.msg, {
                icon: result.state == "success" ? 1 : 5,
              });
              layer.close(index);
            },
            error: function () {
              layer.close(index);
              layer.msg("删除结算单发生错误!", { icon: 5 });
            },
          });
        }
      );
    },
    doExport() {
      if (table.getData().length <= 0) {
        return layer.msg("没有可以导出的数据", {
          zIndex: new Date() * 1,
          icon: 5,
        });
      }
      layer.confirm(
        "确定要导出列表吗?",
        { icon: 3, title: "提示" },
        function (index) {
          layer.close(index);
          table.download(
            "xlsx",
            "结算单统计表" + dayjs().format("YYYY-MM-DD") + ".xlsx",
            {
              sheetName: "结算单统计表",
            }
          );
        }
      );
    },
    initGrid(callback) {
      var maxHeight =
        $(window).height() -
        $("#header").height() -
        $("#toolbarContainer").height() -
        $("#title").height() +
        5;
      table = new Tabulator("#grid", {
        locale: true,
        langs: langs,
        index: "FItemID",
        height: maxHeight,
        columnHeaderVertAlign: "bottom",
        selectable: 999,
        columns: [
          {
            formatter: function (cell, formatterParams, onRendered) {
              return "<el-tooltip  effect='dark' content='点击查看详情' placement='right-end'><i class='el-icon-document'/></el-tooltip>";
            },
            title: "操作",
            width: 80,
            headerHozAlign: "center",
            hozAlign: "center",
            headerSort: false,
            download: false,
            cellClick: function (e, cell) {
              self.onClickDetail(cell.getRow().getData());
            },
          },
        ].concat(tableConf),
        ajaxResponse: function (url, params, response) {
          if (response.state == "success") {
            var t = response.data.map(function (m, i) {
              m.FDate = dayjs(m.FDate).format("YYYY-MM-DD");
              if (m.FVerifyDate != null)
                m.FVerifyDate = dayjs(m.FVerifyDate).format(
                  "YYYY-MM-DD HH:mm:ss"
                );
              return m;
            });

            return t;
          } else {
            layer.msg("没有查询到数据", { icon: 5 });
            return [];
          }
        },
      });

      table.on("tableBuilt", function () {
        callback && callback(table);
      });
    },
    beforeVerify(rows) {
      var result = false;
      try {
        if (window.TAjax) {
          var results = [];
          rows.forEach(function (row) {
            var billId = row.FItemID;
            var billNo = row.FBillNo;
            var check = TAjax.GetVchAttCount('ZYSoftProjectAccount', billId + '')
            if (check.value <= 0) {
              results.push("发现单号" + billNo + "尚未上传附件!")
            }
          })

          if (results.length > 0) {
            layer.msg(results.join("\r\n"), { icon: 5 });
          }
          return results.length <= 0
        } else {
          layer.msg("请在T+环境操作单据!", { icon: 5 });
        }
      } catch (error) {
        layer.msg("请在T+环境操作单据!", { icon: 5 });
      }
      return result
    },
    onClickDetail(item) {
      var FAccountID = item.FAccountID,
        FCustID = item.FCustID,
        FItemID = item.FItemID;
      if ($.isFunction(top.CreateTab)) {
        top.CreateTab(
          "App/ZYSoft/ZYSoft.HT/JSFormPage.aspx?" +
          utils.obj2Url({
            accountId: FAccountID,
            custId: FCustID,
            id: FItemID,
            state: "read",
            v: new Date() * 1,
          }),
          "结算单",
          "JS" + FItemID
        );
      }
    },
  },
  mounted() {
    this.initGrid(function () {
      window.onresize = function () {
        table.setHeight(
          $(window).height() -
          $("#header").height() -
          $("#toolbarContainer").height() -
          $("#title").height() +
          5
        );
      };

      table.setData(
        "./BudgetHandler.ashx",
        Object.assign(
          {},
          {
            SelectApi: "getjslist",
          },
          self.form,
          {
            startDate: dayjs(self.form.startDate).format("YYYY-MM-DD"),
            endDate: dayjs(self.form.endDate).format("YYYY-MM-DD"),
          }
        ),
        "POST"
      );
    });
  },
}));

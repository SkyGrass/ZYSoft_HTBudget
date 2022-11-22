var dialog = {},
  table = {},
  _opt = {};
function init(opt) {
  _opt = opt;
  var self = (dialog = new Vue({
    el: "#app",
    data() {
      return {
        queryForm: {
          accountId: opt.accountId,
          keyword: "", startDate: "", endDate: "", cust: "", project: "",
          custId: opt.custId, custName: opt.custName,
          sourceBillNo: ""
        },
        tableData: [],
        url: "",
      };
    },
    methods: {
      initGrid() {
        table = new Tabulator("#table", {
          locale: true,
          langs: {
            "zh-cn": {
              data: {
                loading: "加载中", //data loader text
                error: "错误", //data error text
              },
            },
          },
          index: "FID",
          columnHeaderVertAlign: "bottom",
          height: "345px",
          selectable: 999,
          columns: tableConf,
          ajaxURL: "../BudgetHandler.ashx",
          ajaxConfig: "POST",
          ajaxParams: {
            SelectApi: "getsalelist",
            accountId: opt.accountId,
          },
          ajaxResponse: function (url, params, response) {
            if (response.state == "success") {
              return response.data.map(function (m, i) {
                m.FDate = dayjs(m.FDate).format("YYYY-MM-DD");
                return m;
              });
            } else {
              layer.msg("没有查询到数据", { icon: 5 });
              return [];
            }
          },
        });

        table.on("renderComplete", function () {
          self.setRowSelect()
        });

        table.on("scrollVertical", function () {
          self.setRowSelect()
        });
      },
      clearFilter() {
        table.clearFilter();
      },
      doFilter() {
        this.doQuery();
      },
      openCustom() {
        this.openBaseDialog(
          "custom",
          "选择客户",
          this.openCustomDone,
          this.queryForm.custName || ""
        );
      },
      openCustomDone(result) {
        var result = result[0];
        var id = result.id,
          code = result.code,
          name = result.name;
        self.queryForm.custName = name;
        self.queryForm.custId = id;
        this.doQuery();
      },
      openBaseDialog(type, title, success, filter) {
        opt.openDialog({
          title: title,
          url: "./modal/Dialog.aspx?filter=" + filter,
          onSuccess: function (layero, index) {
            self.index = index;
            var iframeWin = window.parent[layero.find("iframe")[0]["name"]];
            iframeWin.init({
              layer: window.parent.layer,
              dialogType: type,
              accountId: self.queryForm.accountId,
            });
          },
          onBtnYesClick: function (index, layero) {
            var iframeWin = window.parent[layero.find("iframe")[0]["name"]];
            var row = iframeWin.getSelect();
            if (row.length > 0) {
              success && success(row);
              window.parent.layer.close(index);
            }
          },
        });
      },
      onClearCust() {
        this.queryForm.custId = "";
        this.doQuery();
      },
      doQuery() {
        table.setData(
          "../BudgetHandler.ashx",
          Object.assign(
            {},
            {
              SelectApi: "getsalelist",
            },
            {
              startDate: (this.queryForm.startDate != "" && this.queryForm.startDate != null) ? dayjs(this.queryForm.startDate).format("YYYY-MM-DD") : "",
              endDate: (this.queryForm.endDate != "" && this.queryForm.endDate != null) ? dayjs(this.queryForm.endDate).format("YYYY-MM-DD") : "",
              project: this.queryForm.project,
              billNo: this.queryForm.sourceBillNo,
              custId: this.queryForm.custId
            }
          ),
          "POST"
        );
      },
      setRowSelect() {
        $('.tabulator-cell input[type="checkbox"]').off('click').on('click', function (e, a) {
          var id = $(this).parent().next().next().html();
          if (id != void 0) {
            var keyField = 'FID';
            var rows = table.getData();
            var selRows = table.getSelectedData();
            if (rows.length > 0) {
              var ps = rows.filter(function (row) {
                return row[keyField] == id
              })
              if (ps.length > 0) {
                ps.forEach(function (p) {
                  var cs = selRows.filter(function (ff) { return ff[keyField] == p[keyField] })
                  if (cs.length > 0) {
                    var _p = rows.findIndex(function (ff) { return ff[keyField] == cs[0][keyField] })
                    table.deselectRow(_p + 1)
                  } else {
                    var _p = rows.findIndex(function (ff) { return ff[keyField] == p[keyField] })
                    table.selectRow(_p + 1)
                  }
                });
              }
            }
          }
        });
      },
    },
    watch: {},
    mounted() {
      this.initGrid();
      this.$nextTick(function () {
        setTimeout(function () {
          self.doQuery();
        }, 300);
      })
    },
  }));
}

function getSelect() {
  var rows = table.getSelectedData();
  if (rows != void 0 && rows.length <= 0) {
    layer.msg("尚未选择数据！", { zIndex: new Date() * 1, icon: 5 });
    return [];
  } else {
    var custId = rows.map(function (row) {
      return row.FCustID
    })
    var newCustId = custId.filter(function (r) {
      return r != custId[0];
    })
    if (newCustId.length > 0) {
      layer.msg("发现选择了多个客户,请检查！", { zIndex: new Date() * 1, icon: 5 });
      return [];
    }
    if (_opt.custId != "" && _opt.custId != custId[0]) {
      layer.msg("您选择的客户与单据上不一致,请检查！", { zIndex: new Date() * 1, icon: 5 });
      return [];
    }
    return rows.map(function (r) {
      r.FAccountSum = 0;
      r.FSourceSum = r.FTaxSum
      return r;
    });
  }
}

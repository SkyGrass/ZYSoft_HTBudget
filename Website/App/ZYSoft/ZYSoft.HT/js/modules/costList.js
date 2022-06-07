var self = (vm = new Vue({
  el: "#app",
  data() {
    var curDate = new dayjs();
    return {
      form: {
        startDate: curDate.add(-10, "day"),
        endDate: curDate,
        accountId: accountId || "250116",
        contractNo: "",
        manager: "",
        custManager: "",
        custName: "",
        projectNo: "",
        projectId: "",
        custId: "",
      },
      list: [],
      grid: {},
      maxHeight: 0,
      offset: {
        top: 0,
        left: 0,
      },
    };
  },
  computed: {},
  watch: {},
  methods: {
    openBaseDataDialog(type, title, success) {
      openDialog({
        title: title,
        url: "./modal/Dialog.aspx",
        offset: [self.offset.top, self.offset.left],
        onSuccess: function (layero, index) {
          var iframeWin = window[layero.find("iframe")[0]["name"]];
          iframeWin.init({ layer, dialogType: type });
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
    doQuery() {
      openDialog({
        url: "./modalFilter/ModalFilter.aspx",
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
                SelectApi: "getcostlist",
              },
              self.form,
              r
            );
            self.grid.setData(
              "./BudgetHandler.ashx",
              Object.assign(
                {},
                {
                  SelectApi: "getcostlist",
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
    doAdd() {
      if ($.isFunction(top.CreateTab)) {
        top.CreateTab(
          "App/ZYSoft/ZYSoft.HT/CostFormPage.aspx?" +
            utils.obj2Url({
              state: "add",
              v: new Date() * 1,
            }),
          "成本表",
          "YS100201"
        );
      }
    },
    doRefresh() {
      self.grid.setData(
        "./BudgetHandler.ashx",
        Object.assign(
          {},
          {
            SelectApi: "getcostlist",
          },
          self.form,
          {
            startDate: dayjs(self.form.startDate).format("YYYY-MM-DD"),
            endDate: dayjs(self.form.endDate).format("YYYY-MM-DD"),
          }
        ),
        "POST"
      );
    },
    doExport() {
      if (this.grid.getData().length <= 0) {
        return layer.msg("没有可以导出的数据", {
          zIndex: new Date() * 1,
          icon: 5,
        });
      }
      layer.confirm(
        "确定要导出列表吗?",
        { icon: 3, title: "提示" },
        function (index) {
          this.grid.download(
            "xlsx",
            "实际成本统计表" + dayjs().format("YYYY-MM-DD") + ".xlsx",
            {
              sheetName: "实际成本统计表",
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
      this.grid = new Tabulator("#grid", {
        locale: true,
        langs: langs,
        height: maxHeight,
        columnHeaderVertAlign: "bottom",
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
              m.FCreateDate = dayjs(m.FCreateDate).format("YYYY-MM-DD");
              return m;
            });

            return t;
          } else {
            layer.msg("没有查询到数据", { icon: 5 });
            return [];
          }
        },
      });

      this.grid.on("tableBuilt", function () {
        callback && callback(self.grid);
      });
    },
    onClickDetail(item) {
      var FAccountID = item.FAccountID,
        FProjectID = item.FProjectID,
        FID = item.FID;
      if ($.isFunction(top.CreateTab)) {
        top.CreateTab(
          "App/ZYSoft/ZYSoft.HT/CostFormPage.aspx?" +
            utils.obj2Url({
              accountId: FAccountID,
              projectId: FProjectID,
              id: FID,
              state: "read",
              v: new Date() * 1,
            }),
          "成本表",
          "YS100201"
        );
      }
    },
  },
  mounted() {
    this.initGrid(function () {
      window.onresize = function () {
        self.grid.setHeight(
          $(window).height() -
            $("#header").height() -
            $("#toolbarContainer").height() -
            $("#title").height() +
            5
        );
      };
      self.grid.setData(
        "./BudgetHandler.ashx",
        Object.assign(
          {},
          {
            SelectApi: "getcostlist",
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

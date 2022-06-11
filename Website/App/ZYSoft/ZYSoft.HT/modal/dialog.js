var dialog = {},
  table = {};
function init(opt) {
  var self = (dialog = new Vue({
    el: "#app",
    data() {
      return {
        queryForm: { keyword: "" },
        columns: opt.columns,
        tableData: opt.tableData,
        url: "",
        method2: "",
        clsData: [
          {
            id: "-1",
            code: "",
            name: "",
            children: [],
          },
        ],
        defaultProps: {
          children: "children",
          label: "name",
        },
        defaultExpandedKeys: ["-1"],
      };
    },
    methods: {
      initConfig() {
        $.ajax({
          type: "POST",
          url: "../BudgetHandler.ashx",
          async: true,
          data: {
            SelectApi: "getDialogConf",
            dialogType: opt.dialogType,
          },
          dataType: "json",
          success: function (result) {
            if (result.state == "success") {
              result = result.data;
              self.url = result.url;
              self.method2 = result.method2;
              self.$set(self.clsData, 0, {
                id: "-1",
                code: "",
                name: result.clsName,
                children: [],
              });
              self.initCls(result.method1);
              self.initGrid(result);
            } else {
              layer.msg(result.msg, { icon: 5 });
            }
          },
          error: function () {
            layer.msg("查询配置信息出错!", { icon: 5 });
          },
        });
      },

      initCls(method) {
        $.ajax({
          type: "POST",
          url: "../BudgetHandler.ashx",
          async: true,
          data: {
            SelectApi: method,
            accountId: opt.accountId,
          },
          dataType: "json",
          success: function (result) {
            if (result.state == "success") {
              result = result.data;
              self.formatData(self.clsData[0], result);
            } else {
              layer.msg(result.msg, { icon: 5 });
            }
          },
          error: function () {
            layer.msg("查询配置信息出错!", { icon: 5 });
          },
        });
      },

      initGrid(result) {
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
          index: result.key,
          columnHeaderVertAlign: "bottom",
          height: "345px",
          selectable: result.selectable || 1,
          columns: result.columns,
          data: [],
          ajaxURL: self.url,
          ajaxConfig: "POST",
          ajaxResponse: function (url, params, response) {
            if (response.state == "success") {
              return response.data.map(function (m, i) {
                return m;
              });
            } else {
              layer.msg("没有查询到数据", { icon: 5 });
              return [];
            }
          },
        });

        table.on("rowDblClick", function (e, row) {
          var p = parent[1] == void 0 ? parent.self : parent[0].dialog;
          p.closeDialog(opt.dialogType, row.getData());
        });
      },

      handleNodeClick(data) {
        var id = data.id;
        table.setData(
          self.url,
          Object.assign(
            {},
            {
              SelectApi: self.method2,
            },
            { accountId: opt.accountId, classId: id }
          ),
          "POST"
        );
      },

      formatData(root, data) {
        data.forEach(function (node) {
          if (node.idparent == root.id) {
            if (!Object.keys(root).includes("children")) {
              root.children = [];
            }
            root.children.push(node);
            self.formatData(node, data);
          }
        });
      },

      clearFilter() {
        table.clearFilter();
      },

      doFilter() {
        table.setFilter([
          [
            { field: "code", type: "like", value: this.queryForm.keyword },
            { field: "name", type: "like", value: this.queryForm.keyword },
          ],
        ]);
      },
    },
    watch: {},
    mounted() {
      this.initConfig();
    },
  }));
}

function getSelect() {
  var rows = table.getSelectedData();
  if (rows != void 0 && rows.length <= 0) {
    layer.msg("尚未选择数据！", { zIndex: new Date() * 1, icon: 5 });
    return [];
  } else {
    return rows;
  }
}

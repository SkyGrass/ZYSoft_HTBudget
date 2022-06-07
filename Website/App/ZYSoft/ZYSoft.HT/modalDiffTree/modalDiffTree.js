var dialog = {};
function init(opt) {
  var group = opt.group;
  var self = (dialog = new Vue({
    el: "#app",
    data() {
      return {
        clsData: [],
        defaultProps: {
          children: "children",
          label: "FItemName",
        },
        defaultExpandedKeys: [],
        query: {},
      };
    },
    methods: {
      init() {
        $.ajax({
          type: "POST",
          url: "../BudgetHandler.ashx",
          async: true,
          data: {
            SelectApi: "getItemDetail",
            accountId: group.FAccountID,
            projectId: group.FProjectID,
            clsCode: group.FItemCode,
            groupCode: group.FGroupCode,
            year: group.FYear,
          },
          dataType: "json",
          success: function (result) {
            if (result.state == "success") {
              result = result.data.map(function (m, i) {
                var p = group.FChildren.filter(function (f) {
                  return f.entryId == m.FEntryID;
                });
                if (p.length > 0) {
                  m.FBudgetQty = p[0].budgetQty;
                  m.FBudgetSum = p[0].budgetSum;

                  m.FCostQty = p[0].costQty;
                  m.FCostSum = p[0].costSum;

                  m.FDiffQty = p[0].diffQty;
                  m.FDiffSum = p[0].diffSum;
                }

                if (i == 0) {
                  self.defaultExpandedKeys.push(m.FItemID);
                }
                return m;
              });
              self.clsData.push(result[0]);
              var root = self.clsData[0];
              self.formatData(root, result);
            } else {
              layer.msg(result.msg, { icon: 5 });
            }
          },
          error: function () {
            layer.msg("查询配置信息出错!", { icon: 5 });
          },
        });
      },
      formatData(root, data) {
        data.forEach(function (node) {
          if (node.FParentItemID == root.FItemID) {
            if (node.FBudgetQty == 0) {
              node.FBudgetQty = "";
            }
            if (node.FBudgetSum == 0) {
              node.FBudgetSum = "";
            }
            if (node.FCostQty == 0) {
              node.FCostQty = "";
            }
            if (node.FCostSum == 0) {
              node.FCostSum = "";
            }
            if (node.FDiffQty == 0) {
              node.FDiffQty = "";
            }
            if (node.FDiffSum == 0) {
              node.FDiffSum = "";
            }
            if (!Object.keys(root).includes("children")) {
              root.children = [];
            }
            root.children.push(node);
            self.formatData(node, data);
          }
        });
      },
    },
    mounted() {
      this.init();
      this.query = utils.url2Obj(location.search);
    },
  }));
}

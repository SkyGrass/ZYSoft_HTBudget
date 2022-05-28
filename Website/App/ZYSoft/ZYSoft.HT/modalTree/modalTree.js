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
            typeId: 1,
          },
          dataType: "json",
          success: function (result) {
            if (result.state == "success") {
              result = result.data.map(function (m, i) {
                var p = group.FChildren.filter(function (f) {
                  return f.entryId == m.FEntryID;
                });
                if (p.length > 0) {
                  m.FBudgetPrice = p[0].budgetPrice;
                }
                var q = group.FChildren.filter(function (f) {
                  return f.entryId == m.FEntryID;
                });
                if (q.length > 0) {
                  m.FBudgetQty = q[0].budgetQty;
                }
                var s = group.FChildren.filter(function (f) {
                  return f.entryId == m.FEntryID;
                });
                if (s.length > 0) {
                  m.FBudgetSum = s[0].budgetSum;
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
            if (!Object.keys(root).includes("children")) {
              root.children = [];
            }
            root.children.push(node);
            self.formatData(node, data);
          }
        });
      },
      onInput(e, data, field) {
        var id = e.currentTarget.id;
        var value = e.currentTarget.value;
        // value = value.match(/^\d*(\.?\d{0,2})/g)[0];
        // data[field] = value;
      },
      onFocus(e) {
        e.currentTarget.select();
      },
      onBlur(e, data, field) {
        var id = e.currentTarget.id;
        var value = e.currentTarget.value;
        value = value.match(/^\d*(\.?\d{0,2})/g)[0];
        document.getElementById(id).value = value;
        if (this.checkNeedReCalc(id, value, field)) {
          this.calcSum(id, field);
          this.changeParentNode(data.FItemID, field);
          this.changeParentNode(data.FItemID, "FBudgetSum");
        }
        data[field] = value;
      },
      onChange(e, data, field) {
        var curNode = this.$refs.tree.getNode(data.FItemID);
        if (!curNode.isLeaf) {
          for (var index = 0; index < curNode.childNodes.length; index++) {
            var node = curNode.childNodes[index];
            node.data[field] = "0";
            this.onChange(e, node.data, field);
          }
        }
      },
      changeParentNode(nodeId, field) {
        var curNode = this.$refs.tree.getNode(nodeId);
        if (curNode) {
          var parent = curNode.parent;
          var total = 0;
          for (var index = 0; index < parent.childNodes.length; index++) {
            var node = parent.childNodes[index];
            var cId = "",
              val = "0";
            if (field == "FBudgetQty") {
              cId = "qty_" + node.key;
              val = document.getElementById(cId).value;
            } else {
              if (field == "FBudgetSum") {
                cId = "sum_" + node.key;
                val = document.getElementById(cId).value;
              }
            }
            total =
              field == "FBudgetPrice"
                ? "0"
                : math.format(
                    math.add(math.bignumber(total), math.bignumber(val)),
                    14
                  );
          }
          parent.data[field] = total;

          setTimeout(function () {
            self.changeParentNode(parent.key, field);
          }, 200);
        }
      },
      checkNeedReCalc(id, newV, field) {
        var _id = id.split("_")[1];
        var curNode = this.$refs.tree.getNode(_id);
        if (curNode) {
          return curNode.data[field] != newV;
        }
        return false;
      },
      calcSum(id, field) {
        var _id = id.split("_")[1];
        var p_id = "price_" + _id;
        var q_id = "qty_" + _id;
        var s_id = "sum_" + _id;

        var price = document.getElementById(p_id).value;
        var qty = document.getElementById(q_id).value;

        var sum = math.format(
          math.multiply(math.bignumber(qty), math.bignumber(price)),
          14
        );
        document.getElementById(s_id).value = sum;

        var curNode = this.$refs.tree.getNode(_id);
        if (curNode) {
          curNode.data["FBudgetSum"] = sum;
        }
        if (!curNode.isLeaf) {
          this.onChange({}, curNode.data, "FBudgetSum");
        }
      },
    },
    mounted() {
      this.init();
      this.query = utils.url2Obj(location.search);
    },
  }));
}

function formatForm(rows) {
  var result = [];
  rows.forEach(function (row) {
    var tmp = [row].map(function (m) {
      return {
        accountId: m.FAccountID,
        projectId: m.FProjectID,
        entryId: m.FEntryID,
        budgetPrice: m.FBudgetPrice,
        budgetQty: m.FBudgetQty,
        budgetSum: m.FBudgetSum,
        isLeaf: m.FIsEndNode,
        code: m.FItemCode,
      };
    });
    result = result.concat(tmp);

    if ($.isArray(row.children)) {
      result = result.concat(formatForm(row.children));
    }
  });
  return result;
}
function getResult() {
  var rows = dialog.clsData;
  var result = formatForm(rows);
  return result;
}

var dialog = {};
function init(opt) {
  var node = opt.node;
  var self = (dialog = new Vue({
    el: "#app",
    data() {
      return {
        query: {},
        list: [],
        columnsInv: [
          { label: "单据编码", field: "code" },
          { label: "单据日期", field: "voucherdate" },
          { label: "材料编码", field: "InvCode" },
          { label: "材料名称", field: "InvName" },
          { label: "规格型号", field: "invStd" },
          { label: "单价", field: "price" },
          { label: "数量", field: "quantity" },
          { label: "金额", field: "amount" },
        ],
        columnsFee: [
          { label: "单据编码", field: "code" },
          { label: "单据日期", field: "voucherdate" },
          // { label: "费用编码", field: "ItemCode" },
          { label: "费用名称", field: "ItemName" },
          { label: "费用明细", field: "ItemDetail" },
          { label: "金额", field: "amount" },
        ],
      };
    },
    methods: {
      init() {
        $.ajax({
          type: "POST",
          url: "../BudgetHandler.ashx",
          async: true,
          data: {
            SelectApi: "getCostDetailList",
            accountId: node.FAccountID,
            projectId: node.FProjectID,
            entryId: node.FEntryID,
          },
          dataType: "json",
          success: function (result) {
            if (result.state == "success") {
              self.list = result.data.map(function (m, i) {
                m.rid = i + 1;
                m.voucherdate = new dayjs(m.voucherdate).format(
                  "YYYY-MM-DD HH:mm:ss"
                );
                return m;
              });
            } else {
              layer.msg(result.msg, { icon: 5 });
            }
          },
          error: function () {
            layer.msg("查询配置信息出错!", { icon: 5 });
          },
        });
      },
    },
    computed: {
      isInv() {
        return node.FItemType == "存货";
      },
      isFee() {
        return node.FItemType == "费用";
      },
    },
    mounted() {
      this.init();
      this.query = utils.url2Obj(location.search);
    },
  }));
}

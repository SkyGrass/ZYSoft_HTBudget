var dialog = {};
function init(opt) {
  var options = Object.assign(
    {
      isCheck: true,
      isMulit: false,
    },
    opt
  );
  //开启勾选，默认添加勾选列
  if (options.isCheck) {
    options.columns = [
      {
        title: "勾选",
        formatter: "rowSelection",
        titleFormatter: "rowSelection",
        headerHozAlign: "center",
        hozAlign: "center",
        headerSort: false,
        frozen: true,
        cellClick: function (e, cell) {
          cell.getRow().toggleSelect();
        },
      },
    ].concat(options.columns);

    if (options.isMulit) {
      options.selectable = true;
    } else {
      options.selectable = 1;
    }
  }

  $.ajax({
    type: "POST",
    url: "../ctlhandler.ashx",
    async: true,
    data: {
      SelectApi: "getDialogConf",
      formData: JSON.stringify({
        dialogType: "custom",
      }),
    },
    dataType: "json",
    success: function (result) {
      console.log(result);
    },
    error: function () {
      window.layer.msg("未能读取到配置信息", { icon: 5 });
    },
  });

  dialog = new Vue({
    el: "#app",
    data() {
      return {
        queryForm: { keyword: "" },
        columns: options.columns,
        tableData: options.tableData,
        grid: {},
      };
    },
    mounted() {
      var that = this;
      that.grid = new Tabulator("#table", {
        columnHeaderVertAlign: "bottom",
        height: "100%",
        selectable: options.selectable, //make rows selectable
        data: that.tableData, //set initial table data
        columns: that.columns,
      });
    },
  });
}

function getSelect() {
  return dialog.grid.getSelectedData();
}

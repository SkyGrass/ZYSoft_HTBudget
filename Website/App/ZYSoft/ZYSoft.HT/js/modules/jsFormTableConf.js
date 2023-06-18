var tableConf = function (self) {
  return [
    {
      title: "序号",
      formatter: "rownum",
      headerHozAlign: "center",
      hozAlign: "center",
      width: 30,
      download: false,
      headerSort: false,
    },
    {
      title: "项目名称",
      field: "FProjectName",
      headerHozAlign: "center",
      hozAlign: "center",
      width: 180,
      headerSort: false,
    },
    {
      title: "项目编码",
      field: "FProjectCode",
      headerHozAlign: "center",
      hozAlign: "center",
      width: 180,
      headerSort: false,
    },
    {
      title: "销货单金额",
      field: "FSourceSum",
      headerHozAlign: "center",
      hozAlign: "right",
      width: 150,
      headerSort: false, bottomCalc: "sum",
      bottomCalc: function (values, data, calcParams) {
        var total = 0;
        values.forEach(function (value) {
          total = Number(math.eval(total + "+" + value))
        });
        return numeral(total).format('0,0.00');
      },
      formatter: "money",
      formatterParams: {
        decimal: ".",
        thousand: ",",
        precision: 2,
      },
    },
	{
      title: "销货单含税金额",
      field: "FSourceTaxSum",
      headerHozAlign: "center",
      hozAlign: "right",
      width: 150,
      headerSort: false, bottomCalc: "sum",
      bottomCalc: function (values, data, calcParams) {
        var total = 0;
        values.forEach(function (value) {
          total = Number(math.eval(total + "+" + value))
        });
        return numeral(total).format('0,0.00');
      },
      formatter: "money",
      formatterParams: {
        decimal: ".",
        thousand: ",",
        precision: 2,
      },
    },
    {
      title: "结算金额",
      field: "FAccountSum",
      headerHozAlign: "center",
      hozAlign: "right",
      width: 150,
      headerSort: false, bottomCalc: "sum",
      bottomCalc: function (values, data, calcParams) {
        var total = 0;
        data.forEach(function (row) {
          var value = row.FAccountSum
          total = Number(math.eval(total + "+" + value))
        });
        return numeral(total).format('0,0.00');
      },
      formatter: "money",
      editor: self.query.state == "read" ? false : "number",
      editorParams: {
        selectContents: true,
      },
      formatterParams: {
        decimal: ".",
        thousand: ",",
        precision: 2,
      },
      cellEdited: function (cell) {
        self.reCalc(cell);
      },
    },
	{
      title: "结算含税金额",
      field: "FAccountTaxSum",
      headerHozAlign: "center",
      hozAlign: "right",
      width: 150,
      headerSort: false, bottomCalc: "sum",
      bottomCalc: function (values, data, calcParams) {
        var total = 0;
        data.forEach(function (row) {
          var value = row.FAccountTaxSum
          total = Number(math.eval(total + "+" + value))
        });
        return numeral(total).format('0,0.00');
      },
      formatter: "money",
      editor: self.query.state == "read" ? false : "number",
      editorParams: {
        selectContents: true,
      },
      formatterParams: {
        decimal: ".",
        thousand: ",",
        precision: 2,
      },
      cellEdited: function (cell) {
        self.reCalc(cell);
      },
    },
    {
      title: "销货单号",
      field: "FBillNo",
      headerHozAlign: "center",
      hozAlign: "center",
      width: 150,
      headerSort: false,
    },
    {
      title: "销售订单号",
      field: "FSOBillNo",
      headerHozAlign: "center",
      hozAlign: "center",
      width: 150,
      headerSort: false,
    },
    {
      title: "备注",
      field: "FEntryMemo",
      headerHozAlign: "center",
      hozAlign: "center",
      width: 250,
      headerSort: false,
    },
  ];
};

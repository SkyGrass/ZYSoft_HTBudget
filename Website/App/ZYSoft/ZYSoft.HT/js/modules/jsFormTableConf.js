var tableConf = function (self) {
  return [
    {
      formatter: "rownum",
      headerHozAlign: "center",
      hozAlign: "center",
      width: 30,
      download: false,
      headerSort: false,
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
      title: "编码",
      field: "FInvCode",
      headerHozAlign: "center",
      hozAlign: "center",
      width: 80,
      headerSort: false,
    },
    {
      title: "名称",
      field: "FInvName",
      headerHozAlign: "center",
      hozAlign: "center",
      width: 120,
      headerSort: false,
    },
    {
      title: "单价",
      field: "FPrice",
      headerHozAlign: "center",
      hozAlign: "right",
      width: 150,
      headerSort: false,
      editor: self.query.state == "read" ? false : "number",
      editorParams: {
        selectContents: true,
      },
      cellEdited: function (cell) {
        self.reCalc(cell);
      },
    },
    {
      title: "含税单价",
      field: "FTaxPrice",
      headerHozAlign: "center",
      hozAlign: "right",
      width: 150,
      headerSort: false,
    },
    {
      title: "数量",
      field: "FQty",
      headerHozAlign: "center",
      hozAlign: "right",
      width: 60,
      headerSort: false,
      editor: self.query.state == "read" ? false : "number",
      editorParams: {
        selectContents: true,
      },
      cellEdited: function (cell) {
        self.reCalc(cell);
      },
    },
    {
      title: "单位",
      field: "FUnitName",
      headerHozAlign: "center",
      hozAlign: "center",
      width: 60,
      headerSort: false,
    },
    {
      title: "金额",
      field: "FSum",
      headerHozAlign: "center",
      hozAlign: "right",
      width: 150,
      headerSort: false,
      editor: self.query.state == "read" ? false : "number",
      editorParams: {
        selectContents: true,
      },
      cellEdited: function (cell) {
        self.reCalc(cell);
      },
    },
    {
      title: "含税金额",
      field: "FTaxSum",
      headerHozAlign: "center",
      hozAlign: "right",
      width: 150,
      headerSort: false,
    },
    {
      title: "税额",
      field: "FTax",
      headerHozAlign: "center",
      hozAlign: "right",
      width: 150,
      headerSort: false,
    },
    {
      title: "税率",
      field: "FTaxRate",
      headerHozAlign: "center",
      hozAlign: "right",
      width: 100,
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

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
      headerSort: false, bottomCalc: "sum", bottomCalcParams: { precision: 2 },
    },
    {
      title: "结算金额",
      field: "FAccountSum",
      headerHozAlign: "center",
      hozAlign: "right",
      width: 150,
      headerSort: false, bottomCalc: "sum", bottomCalcParams: { precision: 2 },
      editor: self.query.state == "read" ? false : "number",
      editorParams: {
        selectContents: true,
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

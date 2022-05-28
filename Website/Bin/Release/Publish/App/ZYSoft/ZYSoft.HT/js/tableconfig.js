var tableconf_in = [
    {
        title: "勾选",
        formatter: "rowSelection",
        titleFormatter: "rowSelection",
        hozAlign: "center",
        headerSort: false,
        frozen: true,
        cellClick: function (e, cell) {
            cell.getRow().toggleSelect();
        }
    },
    {
        title: "状态",
        field: "isMark",
        hozAlign: "center",
        width: 120,
        headerSort: false
    },
    {
        title: "单号",
        field: "code",
        hozAlign: "center",
        width: 180,
        headerSort: false
    },
    {
        title: "日期",
        field: "voucherdate",
        hozAlign: "center",
        width: 120,
        headerSort: false,
        formatter: "datetime",
        formatterParams: {
            inputFormat: "YYYY-MM-DD",
            outputFormat: "YYYY-MM-DD",
            invalidPlaceholder: "",
        }
    },
    {
        title: "供应商",
        field: "Vendor",
        hozAlign: "center",
        width: 120,
        headerSort: false
    },
    {
        title: "仓库",
        field: "cWhName",
        width: 120,
        hozAlign: "center",
        headerSort: false
    },
    {
        title: "存货编码",
        field: "cInvCode",
        hozAlign: "center",
        width: 150,
        headerSort: false
    },
    {
        title: "存货名称",
        field: "cInvName",
        hozAlign: "center",
        headerSort: false,
        width: 150,
    },
    {
        title: "规格型号",
        field: "specification",
        hozAlign: "center",
        headerSort: false,
        width: 150,
    },
    {
        title: "单位",
        field: "cUnitName",
        hozAlign: "center",
        headerSort: false,
        width: 60
    },
    {
        title: "批号",
        field: "batch",
        hozAlign: "center",

        width: 80,
        headerSort: false
    },
    {
        title: "生产日期",
        field: "ProductionDate",
        hozAlign: "center",
        width: 120,
        headerSort: false,
        formatter: "datetime",
        formatterParams: {
            inputFormat: "YYYY-MM-DD",
            outputFormat: "YYYY-MM-DD",
            invalidPlaceholder: "",
        }
    },
    {
        title: "失效日期",
        field: "expiryDate",
        hozAlign: "center",
        width: 120,
        headerSort: false,
        formatter: "datetime",
        formatterParams: {
            inputFormat: "YYYY-MM-DD",
            outputFormat: "YYYY-MM-DD",
            invalidPlaceholder: "",
        }
    },
    {
        title: "数量",
        field: "quantity",
        hozAlign: "center",
        width: 120,
        headerSort: false,
        editor: false,
    },
    {
        title: "单价",
        field: "TaxPrice",
        hozAlign: "right",
        width: 120,
        headerSort: false
    },
    {
        title: "金额",
        field: "TaxAmount",
        hozAlign: "right",
        width: 120,
        headerSort: false
    }
]

var tableconf_trans = [{
    title: "勾选",
    formatter: "rowSelection",
    titleFormatter: "rowSelection",
    hozAlign: "center",
    headerSort: false,
    frozen: true,
    cellClick: function (e, cell) {
        cell.getRow().toggleSelect();
    }
}, {
    title: "状态",
    field: "isMark",
    hozAlign: "center",
    width: 120,
    headerSort: false
},
{
    title: "单号",
    field: "code",
    hozAlign: "center",
    width: 180,
    headerSort: false
},
{
    title: "日期",
    field: "voucherdate",
    hozAlign: "center",
    width: 120,
    headerSort: false,
    formatter: "datetime",
    formatterParams: {
        inputFormat: "YYYY-MM-DD",
        outputFormat: "YYYY-MM-DD",
        invalidPlaceholder: "",
    }
},
{
    title: "调入仓库",
    field: "cInWhName",
    hozAlign: "center",
    width: 120,
    headerSort: false
},
{
    title: "调出仓库",
    field: "cOutWhName",
    width: 120,
    hozAlign: "center",
    headerSort: false
},
{
    title: "存货编码",
    field: "cInvCode",
    hozAlign: "center",
    width: 150,
    headerSort: false
},
{
    title: "存货名称",
    field: "cInvName",
    hozAlign: "center",
    headerSort: false,
    width: 150,
},
{
    title: "规格型号",
    field: "specification",
    hozAlign: "center",
    width: 150,
    headerSort: false
},
{
    title: "单位",
    field: "cUnitName",
    hozAlign: "center",
    headerSort: false,
    width: 60
},
{
    title: "批号",
    field: "batch",
    hozAlign: "center",
    width: 80,
    headerSort: false
},
{
    title: "生产日期",
    field: "ProductionDate",
    hozAlign: "center",
    width: 120,
    headerSort: false,
    formatter: "datetime",
    formatterParams: {
        inputFormat: "YYYY-MM-DD",
        outputFormat: "YYYY-MM-DD",
        invalidPlaceholder: "",
    }
},
{
    title: "失效日期",
    field: "expiryDate",
    hozAlign: "center",
    width: 120,
    headerSort: false,
    formatter: "datetime",
    formatterParams: {
        inputFormat: "YYYY-MM-DD",
        outputFormat: "YYYY-MM-DD",
        invalidPlaceholder: "",
    }
},
{
    title: "数量",
    field: "quantity",
    hozAlign: "center",
    width: 120,
    headerSort: false,
    editor: false,
},
{
    title: "单价",
    field: "outPrice",
    hozAlign: "right",
    width: 120,
    headerSort: false
},
{
    title: "金额",
    field: "outAmount",
    hozAlign: "right",
    width: 120,
    headerSort: false
}
]

var tableconf_out = [
    {
        title: "勾选",
        formatter: "rowSelection",
        titleFormatter: "rowSelection",
        hozAlign: "center",
        headerSort: false,
        frozen: true,
        cellClick: function (e, cell) {
            cell.getRow().toggleSelect();
        }
    },
    { field: "ID", visible: false },
    {
        title: "状态",
        field: "isMark",
        hozAlign: "center",
        width: 120,
        headerSort: false
    },
    {
        title: "单号",
        field: "code",
        hozAlign: "center",
        width: 180,
        headerSort: false
    },
    {
        title: "日期",
        field: "voucherdate",
        hozAlign: "center",
        width: 120,
        headerSort: false,
        formatter: "datetime",
        formatterParams: {
            inputFormat: "YYYY-MM-DD",
            outputFormat: "YYYY-MM-DD",
            invalidPlaceholder: "",
        }
    },
    {
        title: "仓库",
        field: "cWhName",
        width: 120,
        hozAlign: "center",
        headerSort: false
    },
    {
        title: "存货编码",
        field: "cInvCode",
        hozAlign: "center",
        width: 120,
        headerSort: false
    },
    {
        title: "存货名称",
        field: "cInvName",
        hozAlign: "center",
        headerSort: false,
        width: 150,
    },
    {
        title: "规格型号",
        field: "specification",
        hozAlign: "center",
        width: 150,
        headerSort: false
    },
    {
        title: "单位",
        field: "cUnitName",
        hozAlign: "center",
        headerSort: false,
        width: 60
    },
    {
        title: "批号",
        field: "batch",
        hozAlign: "center",

        width: 80,
        headerSort: false
    },
    {
        title: "生产日期",
        field: "ProductionDate",
        hozAlign: "center",
        width: 120,
        headerSort: false,
        formatter: "datetime",
        formatterParams: {
            inputFormat: "YYYY-MM-DD",
            outputFormat: "YYYY-MM-DD",
            invalidPlaceholder: "",
        }
    },
    {
        title: "失效日期",
        field: "expiryDate",
        hozAlign: "center",
        width: 120,
        headerSort: false,
        formatter: "datetime",
        formatterParams: {
            inputFormat: "YYYY-MM-DD",
            outputFormat: "YYYY-MM-DD",
            invalidPlaceholder: "",
        }
    },
    {
        title: "数量",
        field: "quantity",
        hozAlign: "center",
        width: 120,
        headerSort: false,
        editor: false,
    },
    {
        title: "单价",
        field: "Price",
        hozAlign: "right",
        width: 120,
        headerSort: false
    },
    {
        title: "金额",
        field: "Amount",
        hozAlign: "right",
        width: 120,
        headerSort: false
    }
]


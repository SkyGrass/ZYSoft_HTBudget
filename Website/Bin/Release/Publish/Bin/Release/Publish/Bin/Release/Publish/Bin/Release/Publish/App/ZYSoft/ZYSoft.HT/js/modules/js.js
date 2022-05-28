var vm = new Vue({
  el: "#app",
  data() {
    var curDate = new dayjs();
    return {
      form: {
        name: "",
        region: "",
        date: curDate,
        billNo: "SO-2022-05-07",
        delivery: false,
        type: [],
        resource: "",
        desc: "",
      },
      grid: {},
      tableData: [{ isMark: 1, voucherdate: "" }],
      columns: tableconf,
    };
  },
  methods: {
    onSubmit() {},
  },
  mounted() {
    var that = this;
    that.grid = new Tabulator("#table", {
      height: 150,
      columnHeaderVertAlign: "bottom",
      selectable: true, //make rows selectable
      data: that.tableData, //set initial table data
      columns: that.columns,
    });
  },
});

var vm = new Vue({
    el: "#app",
    data: function () {
        return {
            materialVisible: false,
            markerVisible: false,
            loading: false,
            fullscreenLoading: false,
            keyword: "",
            keyword_marker: "",
            queryForm: {
                cid: "",
                code: "",
                batch: ""
            },
            form: {
                FMaker: loginName,
                FMakerId: loginUserId,
                isMark: true,
                isCancelMark: false,
                FormId: {
                    Form_in: [],
                    Form_out: [],
                    Form_trans: []
                },
                date: [new moment().startOf('month').format('YYYY-MM-DD'), new moment().endOf('month').format('YYYY-MM-DD')]
            },
            materialList: [],
            materialList_bark: [],
            markersList: [],
            markersList_bark: [],
            maxHeight: 0,
            grid_out: {},
            grid_in: {},
            grid_trans: {},
            tableData_out: [],
            tableData_in: [],
            tableData_trans: [],
            currentMaterial: {}
        };
    },
    methods: {
        doMark1(value) {
            this.form.isCancelMark = !value;
        },
        doMark2(value) {
            this.form.isMark = !value;
        },
        duplicate(arr) {
            var tmp = [];
            arr.concat().sort().sort(function (a, b) {
                if (a == b && tmp.indexOf(a) === -1) tmp.push(a);
            });
            return tmp;
        },
        handleMaterialSelectionChange(value) {
            this.currentMaterial = value
            this.queryForm.code = this.currentMaterial.code;
            this.queryForm.cid = this.currentMaterial.id;
            this.materialVisible = false;
        },
        handleMarkerSelectionChange(value) {
            this.form.FMaker = value.name;
            this.form.FMakerId = value.id;
            this.markerVisible = false;
        },
        remoteQueryMaterial(query) {
            if (query !== '') {
                this.loading = true;
                setTimeout(function () {
                    vm.loading = false;
                    vm.materialList = $.extend(true, [], vm.materialList_bark).filter(function (item) {
                        return (item.name.toLowerCase()
                            .indexOf(query.toLowerCase()) > -1 ||
                            item.code.toLowerCase()
                                .indexOf(query.toLowerCase()) > -1
                        );
                    });
                }, 150);
            } else {
                this.materialList = this.materialList_bark;
            }
        },
        remoteQueryMarker(query) {
            if (query !== '') {
                this.loading = true;
                setTimeout(function () {
                    vm.loading = false;
                    vm.markersList = $.extend(true, [], vm.markersList_bark).filter(function (item) {
                        return (item.name.toLowerCase()
                            .indexOf(query.toLowerCase()) > -1 ||
                            item.code.toLowerCase()
                                .indexOf(query.toLowerCase()) > -1
                        );
                    });
                }, 150);
            } else {
                this.markersList = this.markersList_bark;
            }
        },
        chooseMaterial() {
            var that = this;
            $.ajax({
                type: "POST",
                url: "ctlhandler.ashx",
                async: true,
                data: { SelectApi: "GetAllMaterialInfo", code: this.queryForm.code },
                dataType: "json",
                success: function (result) {
                    that.materialList = [];
                    that.materialList_bark = [];
                    if (result.state == "success") {
                        that.keyword = that.queryForm.code;
                        that.materialList = result.data;
                        that.materialList_bark = result.data;
                        if (result.data.length > 1) {
                            that.materialVisible = true;
                        } else {
                            that.currentMaterial = result.data[0];
                            that.queryForm.code = that.currentMaterial.code;
                            that.queryForm.cid = that.currentMaterial.id;
                        }
                    } else {
                        return that.$message({
                            message: '未能查询到物料信息!',
                            type: 'warning'
                        });
                    }
                },
                error: function () {
                    that.$message({
                        message: '查询物料信息未能成功发出请求!!',
                        type: 'error'
                    });
                }
            });
        },
        queryMaterial() {
            if (this.queryForm.code == "") return;
            var that = this;
            $.ajax({
                type: "POST",
                url: "ctlhandler.ashx",
                async: true,
                data: { SelectApi: "GetMaterialInfo", code: this.queryForm.code },
                dataType: "json",
                success: function (result) {
                    that.materialList = [];
                    that.materialList_bark = [];
                    if (result.state == "success") {
                        that.materialList = result.data;
                        that.materialList_bark = result.data;
                        if (result.data.length > 1) {
                            that.materialVisible = true;
                        } else {
                            that.currentMaterial = result.data[0];
                            that.queryForm.code = that.currentMaterial.code;
                            that.queryForm.cid = that.currentMaterial.id;
                        }
                    } else {
                        return that.$message({
                            message: '未能查询到物料信息!',
                            type: 'warning'
                        });
                    }
                },
                error: function () {
                    that.$message({
                        message: '查询物料信息未能成功发出请求!!',
                        type: 'error'
                    });
                }
            });
        },
        chooseMarker(flag) {
            var that = this;
            $.ajax({
                type: "POST",
                url: "ctlhandler.ashx",
                async: true,
                data: { SelectApi: "GetMarker" },
                dataType: "json",
                success: function (result) {
                    that.markersList = [];
                    that.markersList_bark = [];
                    if (result.state == "success") {
                        var temp = result.data;
                        that.markersList = result.data;
                        that.markersList_bark = result.data;
                        that.markerVisible = !!flag;
                    } else {
                        return that.$message({
                            message: '未能查询到制单人信息!',
                            type: 'warning'
                        });
                    }
                },
                error: function () {
                    that.$message({
                        message: '查询制单人信息未能成功发出请求!!',
                        type: 'error'
                    });
                }
            });
        },
        queryRecord() {
            if (this.queryForm.code == "") {
                return this.$message({
                    message: '查询需要物料编码!',
                    type: 'warning'
                });
            } else {
                this.queryRecord_in();
                this.queryRecord_trans();
                this.queryRecord_out();
            }
        },
        queryRecord_in() { this.queryRecordBase("GetRecordIn", "tableData_in", 0) },
        queryRecord_trans() { this.queryRecordBase("GetRecordTrans", "tableData_trans", 1) },
        queryRecord_out() { this.queryRecordBase("GetRecordOut", "tableData_out", 2) },
        queryRecordBase(queryType, tableType, index) {
            var that = this;
            var typeName = index == 0 ? "进货单" : (index == 1 ? "调拨单" : "材料出库");
            $.ajax({
                type: "POST",
                url: "ctlhandler.ashx",
                async: true,
                data: { SelectApi: queryType, cid: that.queryForm.cid, batch: that.queryForm.batch, isMark: that.form.isMark, startdate: that.form.date[0], enddate: that.form.date[1] },
                dataType: "json",
                success: function (result) {
                    that[tableType] = [];
                    if (result.state == "success") {
                        that[tableType] = result.data;
                    } else {

                        that.$message({
                            message: typeName + '没有查询到单据记录!',
                            type: 'warning'
                        });
                    }
                },
                error: function () {
                    that.$message({
                        message: typeName + '未能成功发出请求!!',
                        type: 'error'
                    });
                }
            });
        },
        initBill() {
            this.tableData_out = [];
            this.tableData_in = [];
            this.tableData_trans = [];
        },
        deSelectRow() {
            if (this.tableData.length > 0 &&
                this.grid.getSelectedData().length > 0) {
                vm.grid.getSelectedRows().forEach(function (row) {
                    row.deselect();
                })
            }
        },
        beforeSave() {
            var that = this;
            return true;
            var selectTableIn_All = this.grid_in.getSelectedData()
            var selectTableIn = this.grid_in.getSelectedData().map(function (f) { return f.ID });
            var setTableIn = this.unique((selectTableIn));

            var selectTableTrans_All = this.grid_trans.getSelectedData()
            var selectTableTrans = this.grid_trans.getSelectedData().map(function (f) { return f.ID });
            var setTableTrans = this.unique((selectTableTrans));

            var selectTableOut_All = this.grid_out.getSelectedData()
            var selectTableOut = this.grid_out.getSelectedData().map(function (f) { return f.ID });
            var setTableOut = this.unique((selectTableOut));



            var result = false;
            result = (selectTableIn.length == setTableIn.length &&
                selectTableOut.length == setTableOut.length &&
                selectTableTrans.length == setTableTrans.length);
            if (!result) {
                if (selectTableIn.length != setTableIn.length) {

                    var diffIn = this.duplicate(selectTableIn);
                    var recordIn = selectTableIn_All.filter(function (f) { return f.ID == diffIn[0] });
                    this.$message({
                        message: '发现进货单[' + recordIn[0]['code'] + ']中有多条记录被选中,请核实!',
                        type: 'warning'
                    });
                    return false;
                }

                if (selectTableTrans.length != setTableTrans.length) {

                    var diffTrans = this.duplicate(selectTableTrans);
                    var recordTrans = selectTableTrans_All.filter(function (f) { return f.ID == diffTrans[0] });
                    this.$message({
                        message: '发现调拨单[' + recordTrans[0]['code'] + ']中有多条记录被选中,请核实!',
                        type: 'warning'
                    });
                    return false;
                }

                if (selectTableOut.length != setTableOut.length) {

                    var diffOut = this.duplicate(selectTableOut);
                    var recordOut = selectTableOut_All.filter(function (f) { return f.ID == diffOut[0] });
                    this.$message({
                        message: '发现材料出库单[' + recordOut[0]['code'] + ']中有多条记录被选中,请核实!',
                        type: 'warning'
                    });
                    return false;
                }
            }

            return result;
        },
        saveBill() {
            var that = this;

            var selectTableIn = this.grid_in.getSelectedData().map(function (f) { return { Id: f.ID, EntryId: f.entryId } });
            var selectTableTrans = this.grid_trans.getSelectedData().map(function (f) { return { Id: f.ID, EntryId: f.entryId } });
            var selectTableOut = this.grid_out.getSelectedData().map(function (f) { return { Id: f.ID, EntryId: f.entryId } });

            if (selectTableIn.length <= 0 && selectTableOut.length <= 0 && selectTableTrans.length <= 0) {
                return that.$message({
                    message: '您尚未勾选单据,请先选中单据!!',
                    type: 'error'
                });
            }

            if (that.form.FMakerId == "") {
                return that.$message({
                    message: '请先选中制单人!!',
                    type: 'error'
                });
            }

            if (this.beforeSave()) {

                this.$confirm('您一共选中了'
                    + selectTableIn.length + '张进货单'
                    + selectTableTrans.length + '张调拨单'
                    + selectTableOut.length + '张材料出库单, 是否继续?', '提示', {
                    confirmButtonText: '确定',
                    cancelButtonText: '取消',
                    type: 'warning'
                }).then(function () {
                    that.fullscreenLoading = true;
                    $.ajax({
                        type: "POST",
                        url: "ctlhandler.ashx",
                        async: true,
                        data: {
                            SelectApi: "SaveBill",
                            formData: JSON.stringify(
                                Object.assign(that.form, {
                                    FormId:
                                    {
                                        Form_in: selectTableIn,
                                        Form_out: selectTableOut,
                                        Form_trans: selectTableTrans
                                    }
                                })
                            )
                        },
                        dataType: "json",
                        success: function (result) {
                            if (result.state == "success") {
                                that.$message({
                                    type: 'success',
                                    message: result.msg,
                                    onClose: function () {
                                        that.initBill();
                                    }
                                });
                            } else {
                                that.$message({
                                    message: result.msg,
                                    type: 'error'
                                });
                            }
                            that.fullscreenLoading = false;
                        },
                        error: function () {
                            that.fullscreenLoading = false;
                            that.$message({
                                message: '发生异常,请刷新重试!!',
                                type: 'error'
                            });
                        }
                    });
                }).catch(function (e) {
                    console.log(e)
                    that.$message({
                        type: 'info',
                        message: '已取消',
                        onClose: function () { }
                    });
                });
            }
        },
        unique(arr) {
            var newArr = [];
            for (var i = 0; i < arr.length; i++) {
                if (newArr.indexOf(arr[i]) == -1) {
                    newArr.push(arr[i])
                }
            }
            return newArr;
        },
        clearGrid() {
            this.grid_in.clearData();
            this.grid_out.clearData();
            this.grid_trans.clearData();
        },
        chooseMaker(val) {
            this.form.FMaker = this.markersList.filter(function (f) { return f.id == val })[0].name;
        }
    },
    watch: {
        tableData_out: {
            handler: function (newData) {
                this.grid_out.replaceData(newData);
            },
            deep: true
        },
        tableData_in: {
            handler: function (newData) {
                this.grid_in.replaceData(newData);
            },
            deep: true
        },
        tableData_trans: {
            handler: function (newData) {
                this.grid_trans.replaceData(newData);
            },
            deep: true
        },
    },
    mounted() {
        var that = this;
        this.chooseMarker(false);
        this.maxHeight = ($(window).height() - $("#header").height())
        window.onresize = function () {
            that.maxHeight = ($(window).height() - $("#header").height())
        }
        this.grid_out = new Tabulator("#grid_out", {
            height: 150,
            columnHeaderVertAlign: "bottom",
            selectable: true, //make rows selectable
            data: this.tableData_out, //set initial table data
            columns: tableconf_out,
            rowSelected1: function (row) {
                var _id = row.getData()["ID"];
                var code = row.getData()["code"];
                if (that.form.FormId.Form_out.indexOf(_id) < 0) {
                    if (row.isSelected()) {
                        row.select();
                        that.form.FormId.Form_out.push(_id)
                    } else {
                        var index = that.form.FormId.Form_out.findIndex(function (f) { return f == _id });
                        that.form.FormId.Form_out.splice(index, 1);
                        row.deselect();
                    }
                } else {
                    var index = that.form.FormId.Form_out.findIndex(function (f) { return f == _id });
                    that.form.FormId.Form_out.splice(index, 1);
                    row.deselect();
                    return that.$message({
                        message: '发现材料出库单据[' + code + ']已经有行被选中,请核实!',
                        type: 'warning'
                    });
                }
            }
        });
        this.grid_in = new Tabulator("#grid_in", {
            height: 150,
            columnHeaderVertAlign: "bottom",
            data: this.tableData_in, //set initial table data
            columns: tableconf_in,
            rowSelected1: function (row) {
                var _id = row.getData()["ID"];
                var code = row.getData()["code"];
                if (that.form.FormId.Form_in.indexOf(_id) < 0) {
                    if (row.isSelected()) {
                        row.select();
                        that.form.FormId.Form_in.push(_id)
                    } else {
                        var index = that.form.FormId.Form_in.findIndex(function (f) { return f == _id });
                        that.form.FormId.Form_in.splice(index, 1);
                        row.deselect();
                    }
                } else {
                    var index = that.form.FormId.Form_in.findIndex(function (f) { return f == _id });
                    that.form.FormId.Form_in.splice(index, 1);
                    row.deselect();
                    return that.$message({
                        message: '发现进货单据[' + code + ']已经有行被选中,请核实!',
                        type: 'warning'
                    });
                }
            }
        });
        this.grid_trans = new Tabulator("#grid_trans", {
            height: 150,
            columnHeaderVertAlign: "bottom",
            selectable: true, //make rows selectable
            data: this.tableData_trans, //set initial table data
            columns: tableconf_trans,
            rowSelected1: function (row) {
                var _id = row.getData()["ID"];
                var code = row.getData()["code"];
                if (that.form.FormId.Form_trans.indexOf(_id) < 0) {
                    if (row.isSelected()) {
                        row.select();
                        that.form.FormId.Form_trans.push(_id)
                    } else {
                        var index = that.form.FormId.Form_trans.findIndex(function (f) { return f == _id });
                        that.form.FormId.Form_trans.splice(index, 1);
                        row.deselect();
                    }
                } else {
                    var index = that.form.FormId.Form_trans.findIndex(function (f) { return f == _id });
                    that.form.FormId.Form_trans.splice(index, 1);
                    row.deselect();
                    return that.$message({
                        message: '发现调拨单单据[' + code + ']已经有行被选中,请核实!',
                        type: 'warning'
                    });
                }
            }
        });
        this.form.FMakerId = loginUserId
    }
});
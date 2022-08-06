var table = {};
var self = (vm = new Vue({
    el: "#app",
    data() {
        return {
            form: {
                startDate: "",
                endDate: "",
                accountId: "",
                contractNo: "",
                year: "",
                custName: "",
                projectNo: "",
                projectId: "",
                projectClsId: "",
                custId: "",
            },
            maxHeight: 0,
            offset: {
                top: 0,
                left: 0,
            },
            index: -1,
        };
    },
    computed: {},
    watch: {},
    methods: {
        closeBaseDataDialog(row) {
            layer.close(self.index);
        },
        openBaseDataDialog(type, title, success, filter) {
            openDialog({
                title: title,
                url: "./modal/Dialog.aspx?filter=" + filter,
                offset: [self.offset.top, self.offset.left],
                onSuccess: function(layero, index) {
                    self.index = index;
                    var iframeWin = window[layero.find("iframe")[0]["name"]];
                    iframeWin.init({
                        layer,
                        dialogType: type,
                        accountId: self.form.accountId,
                    });
                },
                onBtnYesClick: function(index, layero) {
                    var iframeWin = window[layero.find("iframe")[0]["name"]];
                    var row = iframeWin.getSelect();
                    if (row.length <= 0) {
                        layer.msg("请先选择", { icon: 5 });
                    } else if (!row) {
                        layer.msg("最多只能选择一个", { icon: 5 });
                    } else {
                        success && success(row);
                        layer.close(index);
                    }
                },
            });
        },
        doQuery() {
            openDialog({
                url: "./rptFilter/RptFilter.aspx",
                onSuccess: function(layero, index) {
                    layer.setTop(layero);
                    self.offset.top = $(layero).offset().top - 80;
                    self.offset.left = $(layero).offset().left + 40;
                    var iframeWin = window[layero.find("iframe")[0]["name"]];
                    iframeWin.init({ layer, parent: self });
                },
                onBtnYesClick: function(index, layero) {
                    var iframeWin = window[layero.find("iframe")[0]["name"]];
                    var row = iframeWin.getSelect();
                    if (row.length <= 0) {
                        layer.msg("请先选择", { icon: 5 });
                    } else if (!row) {
                        layer.msg("最多只能选择一个", { icon: 5 });
                    } else {
                        var r = row[0];
                        r = Object.assign({}, {
                                SelectApi: "getprojectprofit",
                            },
                            self.form,
                            r
                        );
                        table.setData(
                            "./BudgetHandler.ashx",
                            Object.assign({}, {
                                    SelectApi: "getprojectprofit",
                                },
                                r
                            ),
                            "POST"
                        );
                        layer.close(index);
                    }
                },
            });
        },
        doRefresh() {
            table.setData(
                "./BudgetHandler.ashx",
                Object.assign({}, {
                        SelectApi: "getprojectprofit",
                    },
                    self.form, {
                        startDate: self.form.startDate == "" ?
                            "" : dayjs(self.form.startDate).format("YYYY-MM-DD"),
                        endDate: self.form.endDate == "" ?
                            "" : dayjs(self.form.endDate).format("YYYY-MM-DD"),
                    }
                ),
                "POST"
            );
        },
        doExport() {
            if (table.getData().length <= 0) {
                return layer.msg("没有可以导出的数据", {
                    zIndex: new Date() * 1,
                    icon: 5,
                });
            }
            layer.confirm(
                "确定要导出列表吗?", { icon: 3, title: "提示" },
                function(index) {
					setTimeout(function () {
						layer.close(index);
					}, 2000);
                    table.download(
                        "xlsx",
                        "利润统计表" + dayjs().format("YYYY-MM-DD") + ".xlsx", {
                            sheetName: "利润统计表",
                        }
                    );
                }
            );
        },
        initGrid(callback) {
            var maxHeight =
                $(window).height() -
                $("#header").height() -
                $("#toolbarContainer").height() -
                $("#title").height() +
                5;
            table = new Tabulator("#grid", {
				rowHeight:40,
                locale: true,
                langs: langs,
                height: maxHeight,
                columnHeaderVertAlign: "bottom",
                columns: tableConf[this.form.accountId](this),
                ajaxResponse: function(url, params, response) {
                    if (response.state == "success") {
                        var t = response.data.map(function(m, i) {
                            if (m.FIsTotal == 0) {
                                m.FEndDate =
                                    m.FEndDate == "" || m.FEndDate == null ?
                                    "" :
                                    dayjs(m.FEndDate).format("YYYY-MM-DD");
                            } else {
                                m.FSortIndex = "";
                            }
                            return m;
                        });
                        return t;
                    } else {
                        layer.msg("没有查询到数据", { icon: 5 });
                        return [];
                    }
                },
            });

            table.on("renderComplete", function() {
                self.renderRow();
            });

            table.on("scrollVertical", function() {
                self.renderRow();
            });

            table.on("tableBuilt", function() {
                callback && callback(table);
            });
        },
        onClickDetail(item) {
            var FAccountID = item.FAccountID,
                FProjectID = item.FProjectID,
                FID = item.FID,
                FIsTotal = item.FIsTotal;
            if (FIsTotal == 0) {
                if ($.isFunction(top.CreateTab)) {
                    top.CreateTab(
                        "App/ZYSoft/ZYSoft.HT/CostFormPage.aspx?" +
                        utils.obj2Url({
                            accountId: FAccountID,
                            projectId: FProjectID,
                            id: FID,
                            state: "read",
                            v: new Date() * 1,
                        }),
                        "成本表",
                        "YS100201"
                    );
                }
            }
        },
        renderRow() {
            var ps1 = $("#grid .tabulator-cell:contains('小计')").parent();
            for (let i = 0; i < ps1.length; i++) {
                $(ps1[i]).css("backgroundColor", "cornflowerblue");
                $(ps1[i]).css("color", "#fff");
                $(ps1[i]).css("fontWeight", "bold");
            }
            var ps2 = $("#grid .tabulator-cell:contains('合计')").parent();
            for (let j = 0; j < ps2.length; j++) {
                $(ps2[j]).css("backgroundColor", "cornflowerblue");
                $(ps2[j]).css("color", "#fff");
                $(ps2[j]).css("fontWeight", "bold");
            }
        },
    },
    mounted() {
        this.initGrid(function() {
            window.onresize = function() {
                table.setHeight(
                    $(window).height() -
                    $("#header").height() -
                    $("#toolbarContainer").height() -
                    $("#title").height() +
                    5
                );
            };

            table.setData(
                "./BudgetHandler.ashx",
                Object.assign({}, {
                        SelectApi: "getprojectprofit",
                    },
                    self.form, {
                        startDate: self.form.startDate == "" ?
                            "" : dayjs(self.form.startDate).format("YYYY-MM-DD"),
                        endDate: self.form.endDate == "" ?
                            "" : dayjs(self.form.endDate).format("YYYY-MM-DD"),
                    }
                ),
                "POST"
            );
        });
    },
}));
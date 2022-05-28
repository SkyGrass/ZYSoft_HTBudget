<%@ Page Language="C#" AutoEventWireup="true" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="ie=edge" />
    <title>销货单1</title>
    <!-- 引入样式 -->
    <link rel="stylesheet" href="./css/element-ui-index.css" />
    <link rel="stylesheet" href="./css/theme-chalk-index.css" />
    <link href="./css/tabulator.min.css" rel="stylesheet" />
    <link href="./css/js.css" rel="stylesheet" />
    <link href="./css/noborder.css" rel="stylesheet" />
</head>

<body>
    <asp:Label ID="lblUserName" runat="server" Visible="false"></asp:Label>
    <asp:Label ID="lbUserId" runat="server" Visible="false"></asp:Label>
    <asp:Label ID="lbAccount" runat="server" Visible="false"></asp:Label>
    <div id="app">
        <el-container class="contain">
            <el-header id="header" style="height: inherit !important">
            </el-header>
            <el-main>
                <el-form ref="form" :model="form" label-width="80px" size="mini" inline>
                    <el-row :gutter="4">
                        <el-col :span="4">
                            <el-form-item label="单据日期" class="form-item-max">
                                <el-date-picker type="date" class="noBorder" placeholder="请选择单据日期" v-model="form.date" style="width: 92%"></el-date-picker>
                            </el-form-item>
                        </el-col>
                        <el-col :span="4">
                            <el-form-item label="单据编号" class="form-item-max">
                                <el-input v-model="form.billNo" class="noBorder" readonly></el-input>
                            </el-form-item>
                        </el-col>
                    </el-row>
                    <el-row>
                        <el-col :span="4">
                            <el-form-item label="施工区域" class="form-item-max">
                                <el-select style="width:100%" v-model="form.region" placeholder="请选择施工区域" class="noBorder">
                                    <el-option label="区域一" value="shanghai"></el-option>
                                    <el-option label="区域二" value="beijing"></el-option>
                                </el-select>
                            </el-form-item>
                        </el-col>
                    </el-row>
                    <el-row>
                        <el-col :span="20">
                            <el-form-item label="施工地址" style="width:100%" class="form-item-full">
                                <el-input class="noBorder" v-model="form.addr"></el-input>
                            </el-form-item>
                        </el-col>
                    </el-row>
                </el-form>
            </el-main>
            <el-row>
                <el-col :span="24" style="padding: 5px;">
                    <div id="table">
                    </div>
                </el-col>
            </el-row>
        </el-container>
    </div>
    <!-- import Vue before Element -->
    <script src="./js/jquery.min.js"></script>
    <script src="./js/luxon.min.js"></script>
    <script src="./js/dayjs.min.js"></script>
    <script src="./js/tableconfig.js"></script>
    <script src="./js/vue.js"></script>
    <script src="./js/element-ui-index.js"></script>
    <script src="./js/tabulator.js"></script>
    <script>
        var loginName = "<%=lblUserName.Text%>";
        var loginUserId = "<%=lbUserId.Text%>";
		var accountId = "<%=lbAccount.Text%>";
    </script>

    <script src="./js/columns/jsTableConf.js"></script>
    <script src="./js/modules/js.js"></script>
</body>

</html>
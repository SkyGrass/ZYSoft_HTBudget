<%@ Page Language="C#" AutoEventWireup="true" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="ie=edge" />
    <title>结算单列表</title>
    <!-- 引入样式 -->
    <link rel="stylesheet" href="./css/element-ui-index.css" />
    <link rel="stylesheet" href="./css/theme-chalk-index.css" />
    <link href="./css/tabulator.min.css" rel="stylesheet" />
    <link href="./js/layui/css/layui.css" rel="stylesheet" />
    <link href="./css/ys.css" rel="stylesheet" />
    <link href="./css/noborder.css" rel="stylesheet" />
    <link href="./css/tool.css" rel="stylesheet" />
    <style>
        [v-cloak] {
            display: none;
        }
    </style>
</head>

<body>
    <asp:Label ID="lblUserName" runat="server" Visible="false"></asp:Label>
    <asp:Label ID="lbUserId" runat="server" Visible="false"></asp:Label>
    <asp:Label ID="lbAccount" runat="server" Visible="false"></asp:Label>
    <div id="app" v-cloak>
        <el-container class="contain">
            <el-header id="header" style="height: inherit !important;padding:0 !important">
                <div id="toolbarContainer" class="t-page-tb" style="position: relative; z-index: 999;">
                    <div id="toolbarContainer-ct" class="tb-bg">
                        <ul id="toolbarContainer-gp" class="tb-group tb-first-class">
                            <li tabindex="0">
                                <a href="javascript:void(0)" @click='doAdd'>
                                    <span class="tb-item"><span class="tb-text" title="新增">新增</span></span>
                                </a>
                            </li>
                            <li tabindex="0">
                                <a href="javascript:void(0)" @click='doQuery'>
                                    <span class="tb-item"><span class="tb-text" title="查询">查询</span></span>
                                </a>
                            </li>
                            <li tabindex="1">
                                <a href="javascript:void(0)" @click='doRefresh'>
                                    <span class="tb-item"><span class="tb-text" title="刷新">刷新</span></span>
                                </a>
                            </li>
                            <li tabindex="2">
                                <a href="javascript:void(0)" @click='doVerify'>
                                    <span class="tb-item"><span class="tb-text" title="审批">审批</span></span>
                                </a>
                            </li>
                            <li tabindex="2">
                                <a href="javascript:void(0)" @click='doUnVerify'>
                                    <span class="tb-item"><span class="tb-text" title="反审批">反审批</span></span>
                                </a>
                            </li>
                            <li tabindex="3">
                                <a href="javascript:void(0)" @click='doDelete'>
                                    <span class="tb-item"><span class="tb-text" title="删除">删除</span></span>
                                </a>
                            </li>
                            <li tabindex="4">
                                <a href="javascript:void(0)" @click='doExport'>
                                    <span class="tb-item"><span class="tb-text" title="导出">导出</span></span>
                                </a>
                            </li>
                        </ul>
                    </div>
                </div>
            </el-header>
            <el-main>
                <el-row :gutter="5">
                    <el-col :span=14 :push=5 :pull=5 style='text-align:center'>
                        <h1 id='title'>结算单列表</h1>
                    </el-col>
                </el-row>
            </el-main>
            <div id='grid'></div>
        </el-container>
    </div>
    <!-- import Vue before Element -->
    <script>
        var loginName = "<%=lblUserName.Text%>";
        var loginUserId = "<%=lbUserId.Text%>";
        var accountId = '<%=lbAccount.Text%>'
    </script>

    <!-- import poly -->
    <script src="./js/poly/js.polyfills.js"></script>
    <script src="./js/poly/es5.polyfills.js"></script>
    <script src="./js/poly/proxy.min.js"></script>

    <!-- import base javascript-->
    <script src="./js/lang.js"></script>
    <script src="./js/jquery.min.js"></script>
    <script src="./js/luxon.min.js"></script>
    <script src="./js/dayjs.min.js"></script>
    <script src="./js/vue.js"></script>
    <script src="./js/element-ui-index.js"></script>
    <script src="./js/tabulator.js"></script>
    <script src="./js/math/math.min.js"></script>
    <script src="./js/layui/layui.js"></script>
    <script src="./js/dialog/dialog.js"></script>
    <script src="./js/utils.js"></script>
    <script src="./js/xlsx/xlsx.js"></script>

    <!-- import bus javascript -->
    <script src="./js/modules/jsListTableConf.js"></script>
    <script src="./js/modules/jsList.js"></script>
</body>

</html>
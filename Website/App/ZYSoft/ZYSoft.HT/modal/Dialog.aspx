<%@ Page Language="C#" AutoEventWireup="true" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="ie=edge" />
    <link rel="stylesheet" href="../css/element-ui-index.css" />
    <link rel="stylesheet" href="../css/theme-chalk-index.css" />
    <link href="../css/tabulator.min.css" rel="stylesheet" />
    <link href="../js/layui/css/layui.css" rel="stylesheet" />
    <link href="./dialog.css" rel="stylesheet" />
    <link href="../css/noborder.css" rel="stylesheet" />
    <style>
        [v-cloak] {
            display: none;
        }
    </style>
</head>

<body>
    <div id="app" v-cloak>
        <el-row>
            <el-col :span="8" style="height: 390px;overflow-y:scroll">
                <el-tree ref='tree' :data="clsData" :default-expanded-keys="defaultExpandedKeys" :expand-on-click-node=false :props="defaultProps" node-key="id" @node-click="handleNodeClick">
                    <span class="custom-tree-node" slot-scope="node">
                        <span>{{node.data.code}}{{ node.data.name }}</span>
                    </span>
                </el-tree>
            </el-col>
            <el-col :span='16'>
                <el-form ref="form" :model="queryForm" label-width="60px" size='mini' style="padding-right:10px" @submit.native.prevent>
                    <el-form-item label="检索" style="margin-bottom: 5px;">
                        <el-input class="noBorder" clearable placeholder="请在此输入关键字进行搜索" v-model="queryForm.keyword" @clear='clearFilter' @keyup.enter.native='doFilter'></el-input>
                    </el-form-item>
                </el-form>

                <div style="padding:5px">
                    <div id="table"></div>
                </div>
            </el-col>
        </el-row>
    </div>
    <!-- import poly -->
    <script src="../js/poly/js.polyfills.js"></script>
    <script src="../js/poly/es5.polyfills.js"></script>
    <script src="../js/poly/proxy.min.js"></script>

    <!-- import base javascript-->
    <script src="../js/jquery.min.js"></script>
    <script src="../js/vue.js"></script>
    <script src="../js/element-ui-index.js"></script>
    <script src="../js/layui/layui.js"></script>
    <script src="../js/tabulator.js"></script>

    <!-- import bus javascript -->
    <script src="./dialog.js"></script>
</body>

</html>
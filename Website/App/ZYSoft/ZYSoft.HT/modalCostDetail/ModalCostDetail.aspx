<%@ Page Language="C#" AutoEventWireup="true" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="ie=edge" />
    <link rel="stylesheet" href="../css/element-ui-index.css" />
    <link rel="stylesheet" href="../css/theme-chalk-index.css" />
    <link href="../js/layui/css/layui.css" rel="stylesheet" />
    <link href="../css/tabulator.min.css" rel="stylesheet" />
    <link href="./modalCostDetail.css" rel="stylesheet" />
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
            <el-col :span="24">
                <table border='1' style="text-align: center">
                    <thead>
                        <tr v-if="isInv">
                            <th style="width:250px;padding:8px" v-for='column in columnsInv' :key='column.field'>{{column.label}}</th>
                        </tr>
                        <tr v-if="isFee">
                            <th style="width:250px;padding:8px" v-for='column in columnsFee' :key='column.field'>{{column.label}}</th>
                        </tr>
                    </thead>

                    <tr class="tr" v-for='(row,index) in list' :key='index'>
                        <td v-if="isInv" v-for='column in columnsInv' :key='column.field'>{{row[column.field]}}</td>
                        <td v-if="isFee" v-for='column in columnsFee' :key='column.field'>{{row[column.field]}}</td>
                    </tr>
                </table>



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
    <script src="../js/dayjs.min.js"></script>
    <script src="../js/element-ui-index.js"></script>
    <script src="../js/tabulator.js"></script>
    <script src="../js/utils.js"></script>
    <script src="../js/math/math.min.js"></script>
    <script src="../js/layui/layui.js"></script>

    <!-- import bus javascript -->
    <script src="./modalCostDetail.js"></script>
</body>

</html>
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
    <link href="./dialogFilter.css" rel="stylesheet" />
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
            <el-col :push="1" :span="20" :pull="1">
                <el-form ref="form" :model="form" label-width="100px" size="mini" inline>
                    <table>
                        <tr>
                            <td>
                                <el-form-item label="开始日期" class="form-item-max" prop='startDate'>
                                    <el-date-picker type="date" clearable style="width:100%" v-model="form.startDate" placeholder="请选择开始日期" class="noBorder"></el-date-picker>
                                </el-form-item>
                            </td>
                            <td>
                                <el-form-item label="结束日期" class="form-item-max" prop='endDate'>
                                    <el-date-picker type="date" clearable style="width:100%" v-model="form.endDate" placeholder="请选择结束日期" class="noBorder"></el-date-picker>
                                </el-form-item>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <el-form-item label="客户" class="form-item-max" prop='custName'>
                                    <el-input clearable @clear='onClearCust' style="width:100%" v-model="form.custName" placeholder="请选择客户" class="noBorder">
                                        <i class="el-icon-search" slot='suffix' @click='openCustom'></i>
                                    </el-input>
                                </el-form-item>
                            </td>
                            <td>
                                <el-form-item label="项目" class="form-item-max" prop='projectNo'>
                                    <el-input clearable @clear='onClearProject' style="width:100%" v-model="form.projectNo" placeholder="请选择项目" class="noBorder">
                                        <i class="el-icon-search" slot='suffix' @click='openProject'></i>
                                    </el-input>
                                </el-form-item>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <el-form-item label="项目经理" class="form-item-max" prop='manager'>
                                    <el-input clearable style="width:100%" v-model="form.manager" placeholder="请填写项目经理" class="noBorder"></el-input>
                                </el-form-item>
                            </td>
                            <td>
                                <el-form-item label="客户项目经理" class="form-item-max" prop='custManager'>
                                    <el-input clearable style="width:100%" v-model="form.custManager" placeholder="请填写客户项目经理" class="noBorder"></el-input>
                                </el-form-item>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <el-form-item label="合同号" class="form-item-max" prop='contractNo'>
                                    <el-input clearable style="width:100%" v-model="form.contractNo" placeholder="请填写合同号" class="noBorder"></el-input>
                                </el-form-item>
                            </td>
                            <td>
                                <el-form-item label="项目类型" class="form-item-max" prop='projectType'>
                                    <el-input clearable style="width:100%" v-model="form.projectType" placeholder="请填写项目类型" class="noBorder"></el-input>
                                </el-form-item>
                            </td>
                        </tr>
                    </table>
                </el-form>
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
    <script src="../js/tabulator.js"></script>
    <script src="../js/layui/layui.js"></script>
    <script src="../js/dayjs.min.js"></script>
    <script src="../js/math/math.min.js"></script>

    <!-- import bus javascript -->
    <script src="./jsFilter.js"></script>
</body>

</html>
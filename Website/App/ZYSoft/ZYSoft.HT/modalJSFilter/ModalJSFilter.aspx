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
        <link href="./dialogJSFilter.css" rel="stylesheet" />
        <link href="../css/noborder.css" rel="stylesheet" />
        <link href="../css/labelalign.css" rel="stylesheet" />
        <style>
            [v-cloak] {
                display: none;
            }
        </style>
    </head>

    <body>
        <div id="app" v-cloak>
            <el-row>
                <el-col :push="1" :span="22" :pull="1">
                    <el-form ref="form" :model="form" label-width="100px" size="mini" inline>
                        <table style="width: 100%;">
                            <tr>
                                <td>
                                    <el-form-item label="开始日期" class="form-item-max" prop='startDate' label-width="70px"
                                        style="margin-bottom: 0px !important;">
                                        <el-date-picker type="date" clearable style="width:100%"
                                            v-model="form.startDate" placeholder="请选择开始日期" class="noBorder">
                                        </el-date-picker>
                                    </el-form-item>
                                </td>
                                <td>
                                    <el-form-item label="结束日期" class="form-item-max" prop='endDate' label-width="70px"
                                        style="margin-bottom: 0px !important;">
                                        <el-date-picker type="date" clearable style="width:100%" v-model="form.endDate"
                                            placeholder="请选择结束日期" class="noBorder"></el-date-picker>
                                    </el-form-item>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <el-form-item label="客户" class="form-item-max" prop='custName' label-width="70px"
                                        style="margin-bottom: 0px !important;">
                                        <el-input clearable @clear='onClearCust' style="width:100%"
                                            v-model="form.custName" placeholder="请选择客户" class="noBorder">
                                            <i class="el-icon-search" slot='suffix' @click='openCustom'></i>
                                        </el-input>
                                    </el-form-item>
                                </td>
                                <td>
                                    <el-form-item label="制单人" class="form-item-max" prop='billerName' label-width="70px"
                                        style="margin-bottom: 0px !important;">
                                        <el-input clearable style="width:100%" v-model="form.billerName"
                                            placeholder="请输入制单人" class="noBorder">
                                        </el-input>
                                    </el-form-item>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <el-form-item label="单据状态" class="form-item-max" prop='billStatus'
                                        label-width="70px" style="margin-bottom: 0px !important;">
                                        <el-select v-model="form.billStatus" placeholder="请选择" class="noBorder" clearable>
                                            <el-option v-for="item in billStatusList" :key="item.value"
                                                :label="item.label" :value="item.value">
                                            </el-option>
                                        </el-select>
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
        <script src="./dialogJSFilter.js"></script>
    </body>

    </html>
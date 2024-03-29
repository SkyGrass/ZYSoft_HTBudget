﻿<%@ Page Language="C#" AutoEventWireup="true" %>
    <!DOCTYPE html>

    <html xmlns="http://www.w3.org/1999/xhtml">

    <head runat="server">
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="ie=edge" />
        <title>预算表</title>
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
                                <li tabindex="0" v-if="query.state =='add'">
                                    <a href="javascript:void(0)" @click='doGenBudget'>
                                        <span class="tb-item"><span class="tb-text" title="生成预算明细">生成预算明细</span></span>
                                    </a>
                                </li>
                                <li tabindex="1" v-if="query.state =='edit'">
                                    <a href="javascript:void(0)" @click='doCancelEdit'>
                                        <span class="tb-item"><span class="tb-text" title="取消编辑">取消编辑</span></span>
                                    </a>
                                </li>
                                <li tabindex="1" v-if="query.state =='read'">
                                    <a href="javascript:void(0)" @click='doEdit'>
                                        <span class="tb-item"><span class="tb-text" title="编辑">编辑</span></span>
                                    </a>
                                </li>
                                <li tabindex="2" v-if="query.state =='edit'|| query.state =='add'">
                                    <a href="javascript:void(0)" @click='doSave'>
                                        <span class="tb-item"><span class="tb-text" title="保存">保存</span></span>
                                    </a>
                                </li>

                                <li tabindex="3" v-if="query.state =='read'">
                                    <a href="javascript:void(0)" @click='doSign'>
                                        <span class="tb-item"><span class="tb-text" title="设计">设计</span></span>
                                    </a>
                                </li>
                                <li tabindex="4" v-if="query.state =='read'">
                                    <a href="javascript:void(0)" @click='doPreView'>
                                        <span class="tb-item"><span class="tb-text" title="预览">预览</span></span>
                                    </a>
                                </li>
                                <li tabindex="5" v-if="query.state =='read'">
                                    <a href="javascript:void(0)" @click='doPrint'>
                                        <span class="tb-item"><span class="tb-text" title="打印">打印</span></span>
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </div>
                </el-header>
                <el-main>
                    <el-row :gutter="10">
                        <el-col :span=16 style="overflow-x:auto">
                            <el-form ref="form" :rules="rules" :model="form" label-width="100px" size="mini" inline>
                                <table>
                                    <tr>
                                        <td>
                                            <el-form-item label="客户" class="form-item-max1" prop='custName'>
                                                <span slot='label'>客&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;户</span>
                                                <el-input :readonly="query.state =='read' || query.state =='edit'"
                                                    clearable style="width:100%" v-model="form.custName"
                                                    placeholder="请选择客户" class="noBorder">
                                                    <i class="el-icon-search" slot='suffix' @click='openCustom'
                                                        v-if="query.state =='edit' || query.state =='add'"></i>
                                                </el-input>
                                            </el-form-item>
                                        </td>
                                        <!-- <td>
										<el-form-item label="利润年度" class="form-item-max" prop='year'>
											<span slot='label'>利&nbsp;&nbsp;润&nbsp;&nbsp;年&nbsp;&nbsp;度</span>
											<el-input readonly clearable style="width:100%" v-model="form.year" placeholder="请填写利润年度" class="noBorder"></el-input>
										</el-form-item>
									</td> -->
                                        <td>
                                            <el-form-item label="项目经理" class="form-item-max" prop='manager'>
                                                <span slot='label'>项&nbsp;&nbsp;目&nbsp;&nbsp;经&nbsp;&nbsp;理</span>
                                                <el-input :readonly="query.state =='read'" clearable style="width:100%"
                                                    v-model="form.manager" placeholder="请填写项目经理" class="noBorder">
                                                </el-input>
                                            </el-form-item>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <el-form-item label="项目" class="form-item-max1" prop='projectName'>
                                                <span slot='label'>项&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;目</span>
                                                <el-input :readonly="query.state =='read' || query.state =='edit' "
                                                    clearable style="width:100%" v-model="form.projectName"
                                                    placeholder="请选择项目" class="noBorder">
                                                    <i class="el-icon-search" slot='suffix' @click='openProject'
                                                        v-if="query.state =='add'"></i>
                                                </el-input>
                                            </el-form-item>
                                        </td>
                                        <!-- <td>
                                        <el-form-item label="预算金额" class="form-item-max moneyright" prop='sum'>
                                            <span slot='label'>预算金额</span>
                                            <el-input-number :disabled="query.state =='read'" style="width:100%" :controls=false v-model="form.sum" :min=0 :precision="2" placeholder="请填写预算金额" class="noBorder"></el-input-number>
                                        </el-form-item>
                                    </td>-->
                                        <td>
                                            <el-form-item label="客户项目经理" class="form-item-max" prop='custManager'>
                                                <el-input :readonly="query.state =='read'" clearable style="width:100%"
                                                    v-model="form.custManager" placeholder="请填写客户项目经理" class="noBorder">
                                                </el-input>
                                            </el-form-item>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <el-form-item label="合同号" class="form-item-max1" prop='contractNo'>
                                                <span slot='label'>合&nbsp;&nbsp;同&nbsp;&nbsp;号</span>
                                                <el-input :readonly="query.state =='read'" clearable style="width:100%"
                                                    v-model="form.contractNo" placeholder="请填写合同号" class="noBorder">
                                                </el-input>
                                            </el-form-item>
                                        </td>
                                        <td>
                                            <el-form-item label="预算金额" class="form-item-max moneyright" prop='totalSum'>
                                                <el-input-number :disabled="query.state =='read'" style="width:100%"
                                                    :controls=false v-model="form.totalSum" :min=0 :precision="2"
                                                    placeholder="请填写预算金额" class="noBorder"></el-input-number>
                                            </el-form-item>
                                        </td>

                                    </tr>
                                    <tr>
                                        <td>
                                            <el-form-item label="项目类型" class="form-item-max1" prop='projectType'>
                                                <span slot='label'>项目类型</span>
                                                <el-select class="noBorder" style="width:100%"
                                                    :disabled="query.state =='read'" v-model="form.projectType"
                                                    placeholder="请选择" clearable>
                                                    <el-option v-for="item in projectTypes" :key="item.id"
                                                        :label="item.name" :value="item.name">
                                                    </el-option>
                                                </el-select>
                                                <!-- <el-input :readonly="query.state =='read'" clearable style="width:100%" v-model="form.projectType" placeholder="请填写项目类型" class="noBorder"></el-input> -->
                                            </el-form-item>
                                        </td>

                                        <!--      <td>
                                        <el-form-item label="合同净收入" class="form-item-max moneyright">
                                            <span slot='label'>合同净收入</span>
                                            <el-input-number style="width:100%" disabled :controls=false v-model="form.totalSum" :min=0 :precision="2" placeholder="请填写增补金额" class="noBorder"></el-input-number>
                                        </el-form-item>
                                    </td>-->
                                        <td>
                                            <el-form-item label="制单日期" class="form-item-max" prop='date'>
                                                <span slot='label'>制&nbsp;&nbsp;单&nbsp;&nbsp;日&nbsp;&nbsp;期</span>
                                                <el-date-picker value-format='yyyy-MM-dd'
                                                    :readonly="query.state =='read' " type="date" clearable
                                                    style="width:100%" v-model="form.date" placeholder="请选择日期"
                                                    class="noBorder"></el-date-picker>
                                            </el-form-item>
                                        </td>
                                        <td>
                                            <el-form-item label="制单人" class="form-item-max" prop='billerName'>
                                                <span
                                                    slot='label'>制&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;单&nbsp;&nbsp;&nbsp;&nbsp;人</span>
                                                <el-input :readonly="query.state =='read'" style="width:100%"
                                                    v-model="form.billerName" readonly placeholder="请填写制单人"
                                                    class="noBorder"></el-input>
                                            </el-form-item>
                                        </td>
                                    </tr>
                                </table>
                            </el-form>
                        </el-col>
                        <el-col :span=7 v-if="summary.length>0" style="height:150px;overflow-y:scroll">
                            <table border='1' style="text-align: center">
                                <thead>
                                    <tr style="background-color: #e6e6e6;">
                                        <th style="padding:8px">编码</th>
                                        <th style="padding:8px">名称</th>
                                        <th style="padding:8px">金额</th>
                                    </tr>
                                </thead>
                                <tr :class="t.FGroupCode == activeName ? 'hightRow' : '' " v-for='t in summary'
                                    :key='t.FGroupCode' :id='t.FGroupCode'>
                                    <td style="width:150px;padding:10px">
                                        <el-tooltip class="item" effect="dark" content="点击查看详情" placement="right">
                                            <a :class="t.FGroupCode == activeName ? 'hightRow' : '' "
                                                @click='showGroupDetail(t)'
                                                style="cursor: pointer;text-decoration: underline;">
                                                {{t.FGroupCode}}</a>
                                        </el-tooltip>
                                    </td>

                                    <td style="width:150px;padding:10px">{{t.FGroupName}}</td>
                                    <td style="width:150px;padding:10px">{{t.FSum}}</td>
                                </tr>
                            </table>
                        </el-col>
                    </el-row>
                </el-main>
                <el-row v-if="tabs.length>0">
                    <el-col :span="24" style="padding: 5px;">
                        <el-tabs type="border-card" v-model="activeName" @tab-click="onTabClick">
                            <el-tab-pane v-for='tab in tabs' :key='tab.FGroupCode' :name="tab.FGroupCode"
                                :label="tab.FGroupName">
                                <table border='1' style="text-align: center">
                                    <thead>
                                        <tr style="background-color: #e6e6e6;">
                                            <th style="padding:8px">编码</th>
                                            <th style="padding:8px">名称</th>
                                            <th style="padding:8px">数量</th>
                                            <th style="padding:8px">单价</th>
                                            <th style="padding:8px">金额</th>
                                        </tr>
                                    </thead>
                                    <tr class="tr" v-for='t in tab.FChildren' :key='t.FItemCode'>
                                        <td style="width:100px;padding:10px">{{t.FItemCode}}</td>

                                        <td style="width:150px;padding:10px">
                                            <el-tooltip class="item" effect="dark" content="点击查看详情" placement="right">
                                                <a @click='showGroup(t)'
                                                    style="cursor: pointer;text-decoration: underline;">
                                                    {{t.FItemName}}</a>
                                            </el-tooltip>
                                        </td>

                                        <td style="width:150px;padding:10px">{{t.FBudgetQty}}</td>
                                        <td style="width:150px;padding:10px">{{t.FBudgetPrice}}</td>
                                        <td style="width:150px;padding:10px">{{t.FBudgetSum}}</td>

                                    </tr>
                                </table>
                            </el-tab-pane>
                        </el-tabs>
                    </el-col>
                </el-row>
            </el-container>
        </div>
        <!-- import poly -->
        <script src="./js/poly/js.polyfills.js"></script>
        <script src="./js/poly/es5.polyfills.js"></script>
        <script src="./js/poly/proxy.min.js"></script>

        <!-- import base javascript-->
        <script src="./js/jquery.min.js"></script>
        <script src="./js/luxon.min.js"></script>
        <script src="./js/dayjs.min.js"></script>
        <script src="./js/vue.js"></script>
        <script src="./js/element-ui-index.js"></script>
        <script src="./js/tabulator.js"></script>
        <script src="./js/math/math.min.js"></script>
        <script src="./js/dialog/dialog.js"></script>
        <script src="./js/layui/layui.js"></script>
        <script src="./js/utils.js"></script>

        <script>
            var loginName = "<%=lblUserName.Text%>";
            var loginUserId = "<%=lbUserId.Text%>";
            var accountId = '<%=lbAccount.Text%>'
        </script>

        <!-- import bus javascript -->

        <script src="./js/printMixin.js"></script>
        <script src="./js/modules/budgetForm.js"></script>
    </body>

    </html>
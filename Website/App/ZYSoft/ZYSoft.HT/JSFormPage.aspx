<%@ Page Language="C#" AutoEventWireup="true" %>
	<!DOCTYPE html>

	<html xmlns="http://www.w3.org/1999/xhtml">

	<head runat="server">
		<meta charset="UTF-8" />
		<meta name="viewport" content="width=device-width, initial-scale=1.0" />
		<meta http-equiv="X-UA-Compatible" content="ie=edge" />
		<title>结算单</title>
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
								<li tabindex="1" v-if="query.state =='add'">
									<a href="javascript:void(0)" @click='doPick'>
										<span class="tb-item"><span class="tb-text" title="选择销货单">选择销货单</span></span>
									</a>
								</li>
								<li tabindex="1=2" v-if="query.state =='edit'">
									<a href="javascript:void(0)" @click='doCancelEdit'>
										<span class="tb-item"><span class="tb-text" title="取消编辑">取消编辑</span></span>
									</a>
								</li>
								<li tabindex="2" v-if="query.state =='read'">
									<a href="javascript:void(0)" @click='doEdit'>
										<span class="tb-item"><span class="tb-text" title="编辑">编辑</span></span>
									</a>
								</li>
								<li tabindex="3" v-if="query.state =='edit'|| query.state =='add'">
									<a href="javascript:void(0)" @click='doSave'>
										<span class="tb-item"><span class="tb-text" title="保存">保存</span></span>
									</a>
								</li>

								<li tabindex="4" v-if="(query.state =='read' || query.state =='edit') && !canShow">
									<a href="javascript:void(0)" @click='doVerify'>
										<span class="tb-item"><span class="tb-text" title="审批">审批</span></span>
									</a>
								</li>
								<li tabindex="5" v-if='canShow'>
									<a href="javascript:void(0)" @click='doUnVerify'>
										<span class="tb-item"><span class="tb-text" title="反审批">反审批</span></span>
									</a>
								</li>
								<li tabindex="6" v-if="query.state !='add'">
									<a href="javascript:void(0)" @click='doAttachments'>
										<span class="tb-item"><span class="tb-text" title="附件">附件</span></span>
									</a>
								</li>
							</ul>
						</div>
					</div>
				</el-header>
				<el-main class="form">
					<el-form ref="form" :rules="rules" :model="form" label-width="100px" size="mini" inline>
						<el-row :gutter="10">
							<el-col :span="6">
								<el-form-item label="单据日期" class="form-item-max" prop='date'>
									<span slot='label'>单据日期</span>
									<el-date-picker value-format='yyyy-MM-dd' :readonly="query.state =='read' "
										type="date" clearable style="width:100%" v-model="form.date" placeholder="请选择日期"
										class="noBorder"></el-date-picker>
								</el-form-item>
							</el-col>
							<el-col :span="6">
								<el-form-item label="单据编号" prop='billNo' class="form-item-full">
									<el-input readonly clearable style="width:100%" v-model="form.billNo"
										placeholder="请填写单据编号" class="noBorder" />
								</el-form-item>
							</el-col>
							<el-col :span="7">
								<el-form-item label="客户" prop='custName' class="form-item-full">
									<el-input :readonly="query.state =='read' || query.state =='edit'" clearable
										:disabled="forbidden" style="width:100%" v-model="form.custName"
										placeholder="请选择客户" class="noBorder">
										<i class="el-icon-search" slot='suffix' @click='openCustom' v-if="!forbidden"
											v-if="query.state =='edit' || query.state =='add'"></i>
									</el-input>
								</el-form-item>
							</el-col>
							<el-col :span="5">
								<el-form-item label="结算金额" class="form-item-max moneyright">
									<span slot='label'>结算金额</span>
									<el-input style="width:100%;" disabled v-model="form.sum"
										:precision="2" placeholder="请填写结算金额" class="noBorder"></el-input>
								</el-form-item>
							</el-col>
						</el-row>
						<el-row>
							<el-col :span="24" style="padding: 5px;">
								<div id='grid'></div>
							</el-col>
						</el-row>
						<el-row>
							<el-col>
								<el-form-item label="备注" class="form-item-all" prop='memo'>
									<span slot='label'>备注</span>
									<el-input :readonly="query.state =='read'" clearable style="width:100%"
										v-model="form.memo" placeholder="请填写备注" class="noBorder"></el-input>
								</el-form-item>
							</el-col>
						</el-row>

						<el-row>
							<el-col :span="6">
								<el-form-item label="制单人" class="form-item-max" prop='billerName'>
									<el-input :readonly="query.state =='read'" style="width:100%"
										v-model="form.billerName" readonly placeholder="请填写制单人" class="noBorder">
									</el-input>
								</el-form-item>
							</el-col>
							<el-col :span="6">
								<el-form-item label="审核人" class="form-item-max" prop='veriferName'>
									<el-input :readonly="query.state =='read'" style="width:100%"
										v-model="form.veriferName" readonly placeholder="请填写审核人" class="noBorder">
									</el-input>
								</el-form-item>
							</el-col>
							<el-col :span="6">
								<el-form-item label="审核日期" class="form-item-max" prop='veriferDate'>
									<el-input :readonly="query.state =='read'" style="width:100%"
										v-model="form.veriferDate" readonly placeholder="请填写审核日期" class="noBorder">
									</el-input>
								</el-form-item>
							</el-col>
						</el-row>
					</el-form>
				</el-main>
			</el-container>
		</div>
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
		<script src="./js/numeral/numeral.min.js"></script>
		<script src="./js/dialog/dialog.js"></script>
		<script src="./js/layui/layui.js"></script>
		<script src="./js/utils.js"></script>

		<script>
			var loginName = "<%=lblUserName.Text%>";
			var loginUserId = "<%=lbUserId.Text%>";
			var accountId = '<%=lbAccount.Text%>'
		</script>

		<!-- import bus javascript -->


		<script src="./js/env.js"></script>
		<script src="./js/modules/jsFormTableConf.js"></script>
		<script src="./js/printMixin.js"></script>
		<script src="./js/modules/jsForm.js"></script>
	</body>

	</html>
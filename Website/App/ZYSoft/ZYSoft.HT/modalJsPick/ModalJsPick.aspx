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
		<link href="./modalJsPick.css" rel="stylesheet" />
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
				<el-col :span='24'>
					<el-form ref="form" :model="queryForm" label-width="60px" size='mini' style="padding-right:10px"
						@submit.native.prevent>
						<el-row>
							<el-col :span="8">
								<el-form-item label-width="100px" label="单据开始日期" prop='startDate' label-width="70px"
									style="margin-bottom: 0px !important;">
									<span slot='label'>单据开始日期</span>
									<el-date-picker type="date" clearable style="width:100%"
										v-model="queryForm.startDate" @change="doFilter" placeholder="请选择单据开始日期"
										class="noBorder">
									</el-date-picker>
								</el-form-item>
							</el-col>
							<el-col :span="8">
								<el-form-item label-width="100px" label="单据结束日期" prop='endDate'
									style="margin-bottom: 0px !important;">
									<span slot='label'>单据结束日期</span>
									<el-date-picker type="date" clearable style="width:100%" v-model="queryForm.endDate"
										@change="doFilter" placeholder="请选择单据结束日期" class="noBorder">
									</el-date-picker>
								</el-form-item>
							</el-col>
						</el-row>
						<el-row>
							<el-col :span="8">
								<el-form-item label-width="100px" label="项目" prop='project'
									style="margin-bottom: 0px !important;">
									<span slot='label'>项&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;目</span>
									<el-input clearable @clear='doFilter' style="width:100%" v-model="queryForm.project"
										placeholder="请输入项目编码或名称" @keyup.enter.native='doFilter' class="noBorder">
									</el-input>
								</el-form-item>
							</el-col>
							<el-col :span="8">
								<el-form-item label="客户" prop='custName' label-width="100px"
									style="margin-bottom: 0px !important;">
									<span slot='label'>客&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;户</span>
									<el-input clearable @clear='onClearCust' style="width:100%"
										v-model="queryForm.custName" placeholder="请选择客户" class="noBorder">
										<i class="el-icon-search" slot='suffix' @click='openCustom'></i>
									</el-input>
							</el-col>
							<el-col>
								<el-col :span="16">
									<el-form-item label-width="100px" label="销货单号" prop='sourceBillNo'
										style="margin-bottom: 0px !important;">
										<span slot='label'>单&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;号</span>
										<el-input clearable @clear='doFilter' style="width:100%"
											v-model="queryForm.sourceBillNo" placeholder="请输入销货单号"
											@keyup.enter.native='doFilter' class="noBorder">
										</el-input>
									</el-form-item>
								</el-col>
						</el-row>
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
		<script src="../js/lang.js"></script>
		<script src="../js/jquery.min.js"></script>
		<script src="../js/dayjs.min.js"></script>
		<script src="../js/vue.js"></script>
		<script src="../js/element-ui-index.js"></script>
		<script src="../js/layui/layui.js"></script>
		<script src="../js/tabulator.js"></script>
		<!-- import bus javascript -->
		<script src="./tableConf.js"></script>
		<script src="./modalJsPick.js"></script>
	</body>

	</html>
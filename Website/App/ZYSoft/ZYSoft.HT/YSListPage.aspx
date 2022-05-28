<%@ Page Language="C#" AutoEventWireup="true" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
	<meta charset="UTF-8" />
	<meta name="viewport" content="width=device-width, initial-scale=1.0" />
	<meta http-equiv="X-UA-Compatible" content="ie=edge" />
	<title>预算表统计表</title>
	<!-- 引入样式 -->
	<link rel="stylesheet" href="./css/element-ui-index.css" />
	<link rel="stylesheet" href="./css/theme-chalk-index.css" />
	<link href="./css/tabulator.min.css" rel="stylesheet" />
	<link href="./js/layui/css/layui.css" rel="stylesheet" />
	<link href="./css/ys.css" rel="stylesheet" />
	<link href="./css/noborder.css" rel="stylesheet" />
	<link href="./css/tool.css" rel="stylesheet" />
</head>

<body>
	<asp:Label ID="lblUserName" runat="server" Visible="false"></asp:Label>
	<asp:Label ID="lbUserId" runat="server" Visible="false"></asp:Label>
	<asp:Label ID="lbAccount" runat="server" Visible="false"></asp:Label>
	<div id="app">
		<el-container class="contain">
			<el-header id="header" style="height: inherit !important;padding:0 !important">
				<div id="toolbarContainer" class="t-page-tb" style="position: relative; z-index: 999;">
					<div id="toolbarContainer-ct" class="tb-bg">
						<ul id="toolbarContainer-gp" class="tb-group tb-first-class">
							<li tabindex="0">
								<a href="javascript:void(0)" @click='doQuery'>
									<span class="tb-item"><span class="tb-text" title="查询">查询</span></span>
								</a>
							</li>
							<li tabindex="1">
								<a href="javascript:void(0)" @click='doAdd'>
									<span class="tb-item"><span class="tb-text" title="新增">新增</span></span>
								</a>
							</li>
						</ul>
					</div>
				</div>
			</el-header>
			<el-main>
				<el-row :gutter="5">
					<el-col :span=14 :push=5 :pull=5 style='text-align:center'>
						<h1 id='title'>预算表统计表</h1>
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
		var accounId = '<%=lbAccount.Text%>'
		window.accounId = accounId || "250116";
	</script>

	<script src="./js/lang.js"></script>
	<script src="./js/jquery.min.js"></script>
	<script src="./js/luxon.min.js"></script>
	<script src="./js/dayjs.min.js"></script>
	<script src="./js/tableconfig.js"></script>
	<script src="./js/vue.js"></script>
	<script src="./js/element-ui-index.js"></script>
	<script src="./js/tabulator.js"></script>
	<script src="./js/calc/calc.js"></script>

	<script src="./js/layui/layui.js"></script>
	<script src="./js/dialog/dialog.js"></script>
	<script src="./js/modules/ysListTableConf.js"></script>
	<script src="./js/modules/ysList.js"></script>
	<script src="./js/utils.js"></script>
</body>

</html>
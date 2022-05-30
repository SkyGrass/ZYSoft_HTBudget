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
	<link href="./modalDiffTree.css" rel="stylesheet" />
	<link href="../css/noborder.css" rel="stylesheet" />
</head>

<body>
	<div id="app">
		<el-row>
			<el-col :push="1" :span="22" :pull="1">
				<el-tree ref='tree' :data="clsData" :default-expanded-keys="defaultExpandedKeys" :expand-on-click-node=false :props="defaultProps" node-key="FItemID">
					<span class="custom-tree-node" slot-scope="node">
						<span>{{node.data.FItemCode}}-{{ node.data.FItemName }}</span>
						<el-row style="margin-left: 20px;" :gutter=5>

							<el-col :span=4 class="col">
								<div class='contr'><label>预算数量:</label>
									<input disabled class="txt number_noboard" :value="node.data.FBudgetQty" />
								</div>
							</el-col>
							<el-col :span=4 class="col">
								<div class='contr'><label>成本数量:</label>
									<input disabled class="txt number_noboard" :value="node.data.FCostQty" />
								</div>
							</el-col>
							<el-col :span=4 class="col">
								<div class='contr'><label>差异数量:</label>
									<input disabled class="txt number_noboard" :value="node.data.FDiffQty" />
								</div>
							</el-col>
							<el-col :span=4 class="col">
								<div class='contr'><label>预算金额:</label>
									<input disabled class="txt number_noboard" :value="node.data.FBudgetSum" />
								</div>
							</el-col>
							<el-col :span=4 class="col">
								<div class='contr'><label>成本金额:</label>
									<input disabled class="txt number_noboard" :value="node.data.FCostSum" />
								</div>
							</el-col>
							<el-col :span=4 class="col">
								<div class='contr'><label>差异金额:</label>
									<input disabled class="txt number_noboard" :value="node.data.FDiffSum" />
								</div>
							</el-col>
						</el-row>
					</span>
				</el-tree>
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
	<script src="../js/utils.js"></script>
	<script src="../js/math/math.min.js"></script>

	<!-- import bus javascript -->
	<script src="./modalDiffTree.js"></script>
</body>

</html>
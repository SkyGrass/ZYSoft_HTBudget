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
	<link href="./modalCostTree.css" rel="stylesheet" />
	<link href="../css/noborder.css" rel="stylesheet" />
</head>

<body>
	<div id="app">
		<el-row>
			<el-col :push="2" :span="20" :pull="2">
				<el-tree ref='tree' :data="clsData" :default-expanded-keys="defaultExpandedKeys" :expand-on-click-node=false :props="defaultProps" node-key="FItemID">
					<span class="custom-tree-node" slot-scope="node">
						<span>{{node.data.FItemCode}}-{{ node.data.FItemName }}</span>
						<el-row style="margin-left: 20px;" :gutter=5>

							<el-col :span=8>
								<div class='contr'><label>数量:</label>
									<input :disabled="query.state == 'read'" type='number' @focus='onFocus' @input="onInput($event,node.data,'FCostQty')" @change="onChange($event,
							node.data,'FCostQty')" @blur="onBlur($event,node.data,'FCostQty')" :precision="2" :id="'qty_'+node.data.FItemID" class="txt number_noboard" :value="node.data.FCostQty" placeholder="数量" :min="0" />
								</div>
							</el-col>
							<el-col :span=8>
								<div class='contr'><label>单价:</label>
									<input :disabled="query.state == 'read'" type='number' @focus='onFocus' @input="onInput($event,node.data,'FCostPrice')" @change="onChange($event,
							node.data,'FCostPrice')" @blur="onBlur($event,node.data,'FCostPrice')" :precision="2" :id="'price_'+node.data.FItemID" class="txt number_noboard" :value="node.data.FCostPrice" placeholder="单价" :min="0" />
								</div>
							</el-col>
							<el-col :span=8>
								<div class='contr'><label>金额:</label>
									<input :disabled="query.state == 'read'" type='number' @focus='onFocus' @change="onChange($event,
							node.data,'FCostSum')" readonly @blur="onBlur($event,node.data,'FCostSum')" :precision="2" :id="'sum_'+node.data.FItemID" class="txt number_noboard" :value="node.data.FCostSum" placeholder=" 总价" :min="0" />
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
	<script src="./modalCostTree.js"></script>
</body>

</html>
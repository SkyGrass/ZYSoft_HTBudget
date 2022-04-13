<%@ Page Language="C#" AutoEventWireup="true" %>

<%-- CodeFile="CTLMainPage.aspx.cs" Inherits="App_ZYSoft_ZYSoft_CTL_CTLMainPage" --%>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta http-equiv="X-UA-Compatible" content="ie=edge" />
    <title>销货单</title>
    <!-- 引入样式 -->
    <link rel="stylesheet" href="./css/element-ui-index.css" />
    <link rel="stylesheet" href="./css/theme-chalk-index.css" />
    <link href="./css/tabulator.min.css" rel="stylesheet" />
    <style>
        .el-dialog__body {
            padding: 10px 10px;
        }

        .el-dialog {
            margin-top: 1vh !important;
        }

        .tabulator .tabulator-header .tabulator-col {
            text-align: center;
        }

        .tabulator-tableHolder {
            background-color: #fff;
        }

        .border {
            border: 1px solid #808080;
            padding: 10px;
        }

        .el-input__inner {
            background-color: transparent;
        }

        .tabulator .tabulator-header {
            font-weight: inherit;
        }

        html {
            font-family: "Microsoft Yahei";
            font-size: 11px !important;
        }

        .el-form--inline .el-form-item__label {
            text-align: center !important;
        }

        .el-form--label-left .el-form-item__label {
            text-align: center !important;
        }
    </style>
</head>

<body>
    <asp:Label ID="lblUserName" runat="server" Visible="false"></asp:Label>
    <asp:Label ID="lbUserId" runat="server" Visible="false"></asp:Label>
     <asp:Label ID="lbAccount" runat="server" Visible="false"></asp:Label>
    <div id="app">
        <el-container> 
            <el-main class="manin">
                <el-container class="contain">
                    <el-header id="header" style="height:inherit !important">
                        <el-form :model="form" label-position="left" label-width="80px">
                            <el-row>
                                <el-col :span="8">
                                    <el-form-item label="物料编码">
                                      <el-input class="underline" v-model="queryForm.code"  placeholder="物料编码" @keyup.enter.native ="queryMaterial">
                                           <el-button slot="append" @click.native="chooseMaterial" size="small">选取</el-button>
                                      </el-input>
                                    </el-form-item> 
                                </el-col>
                                 <el-col :span="2">
                                    <el-form-item>
                                      <el-checkbox v-model="form.isMark" @change="doMark1">打标</el-checkbox>
                                    </el-form-item> 
                                </el-col>
                                <el-col :span="12">
                                    <el-form-item>
                                      <el-button size="medium" @click="queryRecord">查询记录</el-button>
                                    </el-form-item> 
                                </el-col>
                            </el-row>
                            <el-row>
                                <el-col :span="8">
                                    <el-form-item label="批号" >
                                        <el-input class="underline" v-model="queryForm.batch" placeholder="批号">
                                        </el-input>
                                    </el-form-item> 
                                </el-col>
                                <el-col :span="2">
                                    <el-form-item>
                                      <el-checkbox v-model="form.isCancelMark" @change="doMark2">取消标志</el-checkbox>
                                    </el-form-item> 
                                </el-col>
                                <el-col :span="12">
                                    <el-form-item>
                                      <el-button size="medium" type="warning" :disabled="!form.isMark" @click="saveBill">确认打标</el-button>
                                    </el-form-item> 
                                </el-col>
                            </el-row>
                            <el-row>
                                <el-col :span="8">
                                    <el-form-item label="标志">
                                      <el-input class="underline" v-model="form.FMaker"  placeholder="标志" @keyup.enter.native ="chooseMaker" readonly>
                                           <el-button slot="append" @click.native="chooseMarker" size="small">选取</el-button>
                                      </el-input>
                                    </el-form-item> 
                                </el-col>
                                  <el-col :span="12" :offset="2">
                                    <el-form-item>
                                     <el-button size="medium" type="danger" :disabled="!form.isCancelMark" @click="saveBill">取消打标</el-button>
                                    </el-form-item> 
                                </el-col>
                            </el-row> 
                             <el-row>
                                <el-col :span="8">
                                    <el-form-item label="日期">
                                     <el-date-picker
                                          style="width:100%"
                                          v-model="form.date"
                                          type="daterange"
                                          range-separator="至"
                                          start-placeholder="开始日期"
                                          end-placeholder="结束日期">
                                    </el-date-picker>
                                    </el-form-item> 
                                </el-col>
                            </el-row> 
                       </el-form>
                    </el-header>
                    <el-main :style="{height:maxHeight+'px',padding:0}">
                        <div style="width:100%">进货单 <div id="grid_in"></div></div>  
                        <div style="width:100%">调拨单 <div id="grid_trans"></div></div>  
                        <div style="width:100%">材料出库 <div id="grid_out"></div></div>  
                    </el-main>
                </el-container>
            </el-main> 
           </el-container>
         <el-dialog title="标志人查询：" :visible.sync="markerVisible">
              <el-input placeholder="请输入标志人编码或者姓名" focus  v-model="keyword_marker" @change="remoteQueryMarker">
              </el-input>  
           <el-table 
                :data="markersList"
                tooltip-effect="dark"
                :height="maxHeight"
                style="width: 100%"
                highlight-current-row
                @row-click="handleMarkerSelectionChange"> 
                <el-table-column
                  prop="code"
                  label="编码">
                </el-table-column>
                <el-table-column
                  prop="name"
                  label="名称"
                  show-overflow-tooltip>
                </el-table-column> 
              </el-table>
            <div slot="footer" class="dialog-footer">
                <el-button @click="markerVisible = false">取 消</el-button> 
            </div>
        </el-dialog>
        <el-dialog title="物料查询：" :visible.sync="materialVisible">
              <el-input placeholder="请输入物料编码" focus  v-model="keyword" @change="remoteQueryMaterial">
              </el-input>  
           <el-table 
                :data="materialList"
                tooltip-effect="dark"
                :height="maxHeight"
                style="width: 100%"
                highlight-current-row
                @row-click="handleMaterialSelectionChange"> 
                <el-table-column
                  prop="code"
                  label="物料编码">
                </el-table-column>
                <el-table-column
                  prop="name"
                  label="物料名称"
                  show-overflow-tooltip>
                </el-table-column>
                <el-table-column
                  prop="specification"
                  label="规格型号"
                  show-overflow-tooltip>
                </el-table-column>
                <el-table-column
                  prop="unitname"
                  label="单位"
                  show-overflow-tooltip>
                </el-table-column>
              </el-table>
            <div slot="footer" class="dialog-footer">
                <el-button @click="materialVisible = false">取 消</el-button> 
            </div>
        </el-dialog>
    </div>
    <!-- import Vue before Element -->
     <script src="./js/moment.js"></script>
    <script src="./js/tableconfig.js"></script>
    <script src="./js/vue.js"></script> 
    <script src="js/element-ui-index.js"></script>--%>
    <script src="./js/tabulator.js"></script>
    <script src="./js/jquery.min.js"></script> 
    <script>
        var loginName = "<%=lblUserName.Text%>"
        var loginUserId = "<%=lbUserId.Text%>"
    </script>

    <script src="js/ctl.js"></script>
</body>

</html>

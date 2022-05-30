<%@ WebHandler Language="C#" Class="BudgetHandler" %>

using System;
using System.Web;
using System.Data;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Collections.Generic;
using System.Xml;
using System.IO;
public class BudgetHandler : IHttpHandler
{
    public class Result
    {
        public string state { get; set; }
        public object data { get; set; }
        public string msg { get; set; }
    }

    public class TreeNode
    {
        public string id { get; set; }
        public string code { get; set; }
        public string name { get; set; }
        public int idparent { get; set; }
    }

    public class DBMethod
    {
        public static string LoadJSON(string key)
        {
            string filename = HttpContext.Current.Request.PhysicalApplicationPath + @"BudgetDialogConf.json";
            if (File.Exists(filename))
            {
                using (StreamReader sr = new StreamReader(filename, encoding: System.Text.Encoding.UTF8))
                {
                    JsonTextReader reader = new JsonTextReader(sr);
                    JObject jo = (JObject)JToken.ReadFrom(reader);
                    return JsonConvert.SerializeObject(new
                    {
                        state = jo[key] == null ? "error" : "success",
                        msg = jo[key] == null ? "未能查询到配置" : "成功",
                        data = jo[key]
                    });
                }
            }
            else
            {
                return "";
            }
        }

        public static string LoadXML(string key)
        {
            string filename = HttpContext.Current.Request.PhysicalApplicationPath + @"BudgetZYSoftWeb.config";
            XmlDocument xmldoc = new XmlDocument();
            xmldoc.Load(filename);
            XmlNode node = xmldoc.SelectSingleNode("/configuration/appSettings");

            string return_value = string.Empty;
            foreach (XmlElement el in node)//读元素值 
            {
                if (el.Attributes["key"].Value.ToLower().Equals(key.ToLower()))
                {
                    return_value = el.Attributes["value"].Value;
                    break;
                }
            }
            return return_value;
        }

        public static string GetProjectCls(string accountId)
        {
            var list = new List<TreeNode>();
            try
            {
                string sql = string.Format(@"EXEC dbo.P_Get_ProjectClass @FAccountID = '{0}'", accountId);
                DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(sql);
                return JsonConvert.SerializeObject(new
                {
                    state = dt.Rows.Count > 0 ? "success" : "error",
                    data = dt,
                    msg = ""
                });
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new
                {
                    state = "error",
                    data = new List<string>(),
                    msg = ex.Message
                });
            }
        }

        public static string GetProject(string accountId, string classId)
        {
            var list = new List<dynamic>();
            try
            {
                string sql = string.Format(@"EXEC dbo.P_Get_Project @FAccountID = '{0}' , @IdClass ='{1}'", accountId, classId);
                DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(sql);
                return JsonConvert.SerializeObject(new
                {
                    state = dt.Rows.Count > 0 ? "success" : "error",
                    data = dt,
                    msg = ""
                });
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new
                {
                    state = "error",
                    data = new List<string>(),
                    msg = ex.Message
                });
            }
        }

        public static string GetCustomCls(string accountId)
        {
            var list = new List<TreeNode>();
            try
            {
                string sql = string.Format(@"EXEC dbo.P_Get_CustClass @FAccountID = '{0}'", accountId);
                DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(sql);
                return JsonConvert.SerializeObject(new
                {
                    state = dt.Rows.Count > 0 ? "success" : "error",
                    data = dt,
                    msg = ""
                });
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new
                {
                    state = "error",
                    data = new List<string>(),
                    msg = ex.Message
                });
            }
        }

        public static string GetCustom(string accountId, string classId)
        {
            var list = new List<dynamic>();
            try
            {
                string sql = string.Format(@"EXEC dbo.P_Get_Cust @FAccountID = '{0}' , @IdClass ='{1}'", accountId, classId);
                DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(sql);
                return JsonConvert.SerializeObject(new
                {
                    state = dt.Rows.Count > 0 ? "success" : "error",
                    data = dt,
                    msg = ""
                });
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new
                {
                    state = "error",
                    data = new List<string>(),
                    msg = ex.Message
                });
            }
        }

        public static string GetBudgetList(string accountId, HttpRequest request)
        {
            try
            {
                string sqlWhere = " 1=1 ";
                var form = request.Form;

                int pageIndex = CommMethod.SafeInt(request.Form["pageIndex"], 1);
                int pageSize = CommMethod.SafeInt(request.Form["pageSize"], 20);
                string startDate = CommMethod.SafeString(request.Form["startDate"], "");
                string endDate = CommMethod.SafeString(request.Form["endDate"], "");
                string contractNo = CommMethod.SafeString(request.Form["contractNo"], "");
                string manager = CommMethod.SafeString(request.Form["manager"], "");
                string custManager = CommMethod.SafeString(request.Form["custManager"], "");
                string projectId = CommMethod.SafeString(request.Form["projectId"], "");
                string custId = CommMethod.SafeString(request.Form["custId"], "");
                string billId = CommMethod.SafeString(request.Form["billId"], "");
                if (!string.IsNullOrEmpty(startDate))
                {
                    sqlWhere += string.Format(@" AND t.FCreateDate >= ''{0} 00:00:00''", startDate);
                }
                if (!string.IsNullOrEmpty(endDate))
                {
                    sqlWhere += string.Format(@" AND t.FCreateDate <= ''{0} 23:59:59''", endDate);
                }
                if (!string.IsNullOrEmpty(contractNo))
                {
                    sqlWhere += string.Format(@" AND t.FContractNo like ''%{0}%''", contractNo);
                }
                if (!string.IsNullOrEmpty(manager))
                {
                    sqlWhere += string.Format(@" AND t.FManager like ''%{0}%''", manager);
                }
                if (!string.IsNullOrEmpty(custManager))
                {
                    sqlWhere += string.Format(@" AND t.FCustManager like  ''%{0}%''", custManager);
                }
                if (!string.IsNullOrEmpty(projectId))
                {
                    sqlWhere += string.Format(@" AND t.FProjectId =''{0}''", projectId);
                }
                if (!string.IsNullOrEmpty(custId))
                {
                    sqlWhere += string.Format(@" AND t.FCustId = ''{0}''", custId);
                }
                if (!string.IsNullOrEmpty(billId))
                {
                    sqlWhere += string.Format(@" AND t.FID = ''{0}''", billId);
                }

                string sql = string.Format(@" EXEC dbo.P_GetBudgetRecord @FAccountID = '{0}', -- varchar(20)
                                                @PageIndex = {1},   -- int
                                                @PageSize = {2},    -- int
                                                @Where = N'{3}'      -- nvarchar(max)", accountId, pageIndex, pageSize, sqlWhere);
                DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(sql);
                if (dt != null && dt.Rows.Count > 0)
                {
                    return JsonConvert.SerializeObject(new
                    {
                        state = dt.Rows.Count > 0 ? "success" : "error",
                        data = dt,
                        icon = 1,
                        msg = "查询成功!"
                    });
                }
                else
                {
                    return JsonConvert.SerializeObject(new
                    {
                        state = "error",
                        data = DBNull.Value,
                        msg = "没有查询到记录!"
                    });
                }
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new
                {
                    state = "error",
                    data = DBNull.Value,
                    msg = ex.Message
                });
            }
        }

        public static string GetCostList(string accountId, HttpRequest request)
        {
            try
            {
                string sqlWhere = " 1=1 ";
                var form = request.Form;

                int pageIndex = CommMethod.SafeInt(request.Form["pageIndex"], 1);
                int pageSize = CommMethod.SafeInt(request.Form["pageSize"], 20);
                string startDate = CommMethod.SafeString(request.Form["startDate"], "");
                string endDate = CommMethod.SafeString(request.Form["endDate"], "");
                string contractNo = CommMethod.SafeString(request.Form["contractNo"], "");
                string manager = CommMethod.SafeString(request.Form["manager"], "");
                string custManager = CommMethod.SafeString(request.Form["custManager"], "");
                string projectId = CommMethod.SafeString(request.Form["projectId"], "");
                string custId = CommMethod.SafeString(request.Form["custId"], "");
                string billId = CommMethod.SafeString(request.Form["billId"], "");
                if (!string.IsNullOrEmpty(startDate))
                {
                    sqlWhere += string.Format(@" AND t.FCreateDate >= ''{0} 00:00:00''", startDate);
                }
                if (!string.IsNullOrEmpty(endDate))
                {
                    sqlWhere += string.Format(@" AND t.FCreateDate <= ''{0} 23:59:59''", endDate);
                }
                if (!string.IsNullOrEmpty(contractNo))
                {
                    sqlWhere += string.Format(@" AND t.FContractNo like ''%{0}%''", contractNo);
                }
                if (!string.IsNullOrEmpty(manager))
                {
                    sqlWhere += string.Format(@" AND t.FManager like ''%{0}%''", manager);
                }
                if (!string.IsNullOrEmpty(custManager))
                {
                    sqlWhere += string.Format(@" AND t.FCustManager like  ''%{0}%''", custManager);
                }
                if (!string.IsNullOrEmpty(projectId))
                {
                    sqlWhere += string.Format(@" AND t.FProjectId =''{0}''", projectId);
                }
                if (!string.IsNullOrEmpty(custId))
                {
                    sqlWhere += string.Format(@" AND t.FCustId = ''{0}''", custId);
                }
                if (!string.IsNullOrEmpty(billId))
                {
                    sqlWhere += string.Format(@" AND t.FID = ''{0}''", billId);
                }

                string sql = string.Format(@" EXEC dbo.P_GetCostRecord @FAccountID = '{0}', -- varchar(20)
                                                @PageIndex = {1},   -- int
                                                @PageSize = {2},    -- int
                                                @Where = N'{3}'      -- nvarchar(max)", accountId, pageIndex, pageSize, sqlWhere);
                DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(sql);
                if (dt != null && dt.Rows.Count > 0)
                {
                    return JsonConvert.SerializeObject(new
                    {
                        state = dt.Rows.Count > 0 ? "success" : "error",
                        data = dt,
                        icon = 1,
                        msg = "查询成功!"
                    });
                }
                else
                {
                    return JsonConvert.SerializeObject(new
                    {
                        state = "error",
                        data = DBNull.Value,
                        msg = "没有查询到记录!"
                    });
                }
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new
                {
                    state = "error",
                    data = DBNull.Value,
                    msg = ex.Message
                });
            }
        }

        public static string GetDiffList(string accountId, HttpRequest request)
        {
            try
            {
                string sqlWhere = " 1=1 ";
                var form = request.Form;

                int pageIndex = CommMethod.SafeInt(request.Form["pageIndex"], 1);
                int pageSize = CommMethod.SafeInt(request.Form["pageSize"], 20);
                string startDate = CommMethod.SafeString(request.Form["startDate"], "");
                string endDate = CommMethod.SafeString(request.Form["endDate"], "");
                string contractNo = CommMethod.SafeString(request.Form["contractNo"], "");
                string manager = CommMethod.SafeString(request.Form["manager"], "");
                string custManager = CommMethod.SafeString(request.Form["custManager"], "");
                string projectId = CommMethod.SafeString(request.Form["projectId"], "");
                string custId = CommMethod.SafeString(request.Form["custId"], "");
                string billId = CommMethod.SafeString(request.Form["billId"], "");
                if (!string.IsNullOrEmpty(startDate))
                {
                    sqlWhere += string.Format(@" AND t.FCreateDate >= ''{0} 00:00:00''", startDate);
                }
                if (!string.IsNullOrEmpty(endDate))
                {
                    sqlWhere += string.Format(@" AND t.FCreateDate <= ''{0} 23:59:59''", endDate);
                }
                if (!string.IsNullOrEmpty(contractNo))
                {
                    sqlWhere += string.Format(@" AND t.FContractNo like ''%{0}%''", contractNo);
                }
                if (!string.IsNullOrEmpty(manager))
                {
                    sqlWhere += string.Format(@" AND t.FManager like ''%{0}%''", manager);
                }
                if (!string.IsNullOrEmpty(custManager))
                {
                    sqlWhere += string.Format(@" AND t.FCustManager like  ''%{0}%''", custManager);
                }
                if (!string.IsNullOrEmpty(projectId))
                {
                    sqlWhere += string.Format(@" AND t.FProjectId =''{0}''", projectId);
                }
                if (!string.IsNullOrEmpty(custId))
                {
                    sqlWhere += string.Format(@" AND t.FCustId = ''{0}''", custId);
                }
                if (!string.IsNullOrEmpty(billId))
                {
                    sqlWhere += string.Format(@" AND t.FID = ''{0}''", billId);
                }

                string sql = string.Format(@" EXEC dbo.P_GetDiffRecord @FAccountID = '{0}', -- varchar(20)
                                                @PageIndex = {1},   -- int
                                                @PageSize = {2},    -- int
                                                @Where = N'{3}'      -- nvarchar(max)", accountId, pageIndex, pageSize, sqlWhere);
                DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(sql);
                if (dt != null && dt.Rows.Count > 0)
                {
                    return JsonConvert.SerializeObject(new
                    {
                        state = dt.Rows.Count > 0 ? "success" : "error",
                        data = dt,
                        icon = 1,
                        msg = "查询成功!"
                    });
                }
                else
                {
                    return JsonConvert.SerializeObject(new
                    {
                        state = "error",
                        data = DBNull.Value,
                        msg = "没有查询到记录!"
                    });
                }
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new
                {
                    state = "error",
                    data = DBNull.Value,
                    msg = ex.Message
                });
            }
        }

        public static string GetBudget(string id)
        {
            try
            {
                string sql = string.Format(@"SELECT * FROM dbo.t_ProjectBudget WHERE FID = '{0}'", id);
                DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(sql);
                if (dt != null && dt.Rows.Count > 0)
                {
                    return JsonConvert.SerializeObject(new
                    {
                        state = dt.Rows.Count > 0 ? "success" : "error",
                        data = dt,
                        icon = 1,
                        msg = "查询成功!"
                    });
                }
                else
                {
                    return JsonConvert.SerializeObject(new
                    {
                        state = "error",
                        data = DBNull.Value,
                        msg = "没有查询到记录!"
                    });
                }
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new
                {
                    state = "error",
                    data = DBNull.Value,
                    msg = ex.Message
                });
            }
        }

        public static string GetCost(string id)
        {
            try
            {
                string sql = string.Format(@"SELECT * FROM dbo.t_ProjectCost WHERE FID = '{0}'", id);
                DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(sql);
                if (dt != null && dt.Rows.Count > 0)
                {
                    return JsonConvert.SerializeObject(new
                    {
                        state = dt.Rows.Count > 0 ? "success" : "error",
                        data = dt,
                        icon = 1,
                        msg = "查询成功!"
                    });
                }
                else
                {
                    return JsonConvert.SerializeObject(new
                    {
                        state = "error",
                        data = DBNull.Value,
                        msg = "没有查询到记录!"
                    });
                }
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new
                {
                    state = "error",
                    data = DBNull.Value,
                    msg = ex.Message
                });
            }
        }

        /// <summary>
        /// 生成 预算 / 成本 / 差异 结构
        /// </summary>
        /// <param name="accountId"></param>
        /// <param name="projectId"></param>
        /// <param name="type">1 预算、2 成本、 3 差异</param>
        /// <returns></returns>
        public static string GenBudgetInfo(string accountId, string projectId, int type = 1)
        {
            var list = new List<TreeNode>();
            try
            {
                string sql = string.Format(@"EXEC dbo.P_Get_ProjectItem @FType = {0},
                                        @FAccountID = '{1}',
                                        @FProjectID = '{2}'", type, accountId, projectId);
                DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(sql);
                if (dt != null && dt.Rows.Count > 0)
                {
                    return JsonConvert.SerializeObject(new
                    {
                        state = dt.Rows.Count > 0 ? "success" : "error",
                        data = dt,
                        icon = 1,
                        msg = "生成预算明细成功!"
                    });
                }
                else
                {
                    return JsonConvert.SerializeObject(new
                    {
                        state = "error",
                        data = DBNull.Value,
                        msg = "未能生成预算明细!"
                    });
                }
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new
                {
                    state = "error",
                    data = DBNull.Value,
                    msg = ex.Message
                });
            }
        }

        public static string GetBudgetDetailInfo(string accountId, string projectId, string clsCode, int type = 1)
        {
            var list = new List<TreeNode>();
            try
            {
                string sql = string.Format(@"EXEC dbo.P_Get_ProjectItemEntry @FType = {0},
                                        @FAccountID = '{1}',
                                        @FProjectID = '{2}',
                                        @FItemCode = '{3}'", type, accountId, projectId, clsCode);
                DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(sql);
                if (dt != null && dt.Rows.Count > 0)
                {
                    return JsonConvert.SerializeObject(new
                    {
                        state = dt.Rows.Count > 0 ? "success" : "error",
                        data = dt,
                        msg = "查询明细成功!"
                    });
                }
                else
                {
                    return JsonConvert.SerializeObject(new
                    {
                        state = "error",
                        data = DBNull.Value,
                        msg = "未能查询到明细记录!"
                    });
                }
            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new
                {
                    state = "error",
                    data = DBNull.Value,
                    msg = ex.Message
                });
            }
        }

        /// <summary>
        /// 保存预算
        /// </summary>
        /// <returns></returns>
        public static string SaveBudget(HttpRequest request)
        {
            try
            {
                var form = request.Form;
                int billId = CommMethod.SafeInt(form["id"], -1);
                bool isAdd = false;
                if (billId == -1)
                {
                    isAdd = true;
                    //do insert
                    if (!GenBillId("t_ProjectBudget", ref billId))
                    {
                        return JsonConvert.SerializeObject(new
                        {
                            state = "error",
                            data = "",
                            msg = "生成单据ID发生错误,请先检查!"
                        });
                    }
                }

                string accountId = form["accountId"] ?? "";
                string custId = form["custId"] ?? "";
                string projectId = form["projectId"] ?? "";
                string contractNo = form["contractNo"] ?? "";
                decimal sum = CommMethod.SafeDecimal(form["sum"], 0);
                decimal addSum = CommMethod.SafeDecimal(form["addSum"], 0);
                decimal totalSum = sum + addSum;
                string billerId = form["billerId"] ?? "";
                string manager = form["manager"] ?? "";
                string custManager = form["custManager"] ?? "";

                string sql = isAdd ? string.Format(@"INSERT INTO dbo.t_ProjectBudget ( FID, FAccountID, FCustID, FProjectID, FContractNo,
                                FSum, FAddSum, FTotalSum, FBillerID, FCreateDate, FManager, FCustManager ) VALUES 
                                ( {0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}',GETDATE(),'{9}','{10}')",
                                    billId, accountId, custId, projectId, contractNo, sum, addSum, totalSum, billerId, manager, custManager)
                        : string.Format(@"UPDATE dbo.t_ProjectBudget SET  FContractNo = '{1}',FSum = '{2}',FAddSum ='{3}' ,FTotalSum = '{4}',
                        FManager = '{5}',FCustManager = '{6}' WHERE FID = '{0}'", billId, contractNo, sum, addSum, totalSum, manager, custManager);


                int effectRow = ZYSoft.DB.BLL.Common.ExecuteNonQuery(sql);
                return JsonConvert.SerializeObject(new
                {
                    state = effectRow > -1 ? "success" : "error",
                    data = "",
                    msg = effectRow > -1 ? "保存成功" : "保存失败"
                });

            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new
                {
                    state = "error",
                    data = DBNull.Value,
                    msg = ex.Message
                });
            }
        }

        public static string SaveBudgetItem(HttpRequest request)
        {
            try
            {
                var form = request.Form;
                var mainStr = form["mainStr"] ?? "[]";
                var formStr = form["formStr"] ?? "[]";
                BudgetItemCls main = JsonConvert.DeserializeObject<BudgetItemCls>(mainStr);
                List<BudgetItemCls> list = JsonConvert.DeserializeObject<List<BudgetItemCls>>(formStr);
                List<string> sqls = new List<string>();
                if (main != null)
                {
                    sqls.Add(string.Format(@"UPDATE dbo.t_ProjectItem SET FBudgetQty = '{0}',FBudgetPrice = '{1}',FBudgetSum = '{2}' 
                                    WHERE FEntryID = '{3}' AND  FAccountID = '{4}' AND  FProjectID = '{5}' AND FItemCode ='{6}'",
                                    main.BudgetQty, main.BudgetPrice, main.BudgetSum, main.EntryId, main.AccountId, main.ProjectId, main.Code
                                            ));
                }
                if (list.Count > 0)
                {
                    list.ForEach(ele =>
                    {
                        sqls.Add(string.Format(@"UPDATE dbo.t_ProjectItemEntry SET FBudgetQty = '{0}',FBudgetPrice = '{1}',FBudgetSum = '{2}' 
                                    WHERE FEntryID = '{3}' AND  FAccountID = '{4}' AND  FProjectID = '{5}' AND FItemCode ='{6}'",
                                    ele.BudgetQty, ele.BudgetPrice, ele.BudgetSum, ele.EntryId, ele.AccountId, ele.ProjectId, ele.Code
                                            ));
                    });

                    int effectRow = ZYSoft.DB.BLL.Common.ExecuteSQLTran(sqls);
                    return JsonConvert.SerializeObject(new
                    {
                        state = effectRow > -1 ? "success" : "error",
                        data = "",
                        msg = effectRow > -1 ? "保存成功" : "保存失败"
                    });
                }
                else
                {
                    return JsonConvert.SerializeObject(new
                    {
                        state = "error",
                        data = "",
                        msg = "未能获取到提交数据,请先检查!"
                    });
                }
            }
            catch (Exception e)
            {
                return JsonConvert.SerializeObject(new
                {
                    state = "error",
                    data = "",
                    msg = "保存时发生异常,原因:" + e.Message
                });
            }
        }

        /// <summary>
        /// 保存实际成本
        /// </summary>
        /// <returns></returns>
        public static string SaveCost(HttpRequest request)
        {
            try
            {
                var form = request.Form;
                int billId = CommMethod.SafeInt(form["id"], -1);
                bool isAdd = false;
                if (billId == -1)
                {
                    isAdd = true;
                    //do insert
                    if (!GenBillId("t_ProjectCost", ref billId))
                    {
                        return JsonConvert.SerializeObject(new
                        {
                            state = "error",
                            data = "",
                            msg = "生成单据ID发生错误,请先检查!"
                        });
                    }
                }

                string accountId = form["accountId"] ?? "";
                string custId = form["custId"] ?? "";
                string projectId = form["projectId"] ?? "";
                string contractNo = form["contractNo"] ?? "";
                decimal sum = CommMethod.SafeDecimal(form["sum"], 0);
                decimal addSum = CommMethod.SafeDecimal(form["addSum"], 0);
                decimal totalSum = sum + addSum;
                string billerId = form["billerId"] ?? "";
                string manager = form["manager"] ?? "";
                string custManager = form["custManager"] ?? "";

                string sql = isAdd ? string.Format(@"INSERT INTO dbo.t_ProjectCost ( FID, FAccountID, FCustID, FProjectID, FContractNo,
                                FSum, FAddSum, FTotalSum, FBillerID, FCreateDate, FManager, FCustManager ) VALUES 
                                ( {0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}',GETDATE(),'{9}','{10}')",
                                    billId, accountId, custId, projectId, contractNo, sum, addSum, totalSum, billerId, manager, custManager)
                        : string.Format(@"UPDATE dbo.t_ProjectCost SET  FContractNo = '{1}',FSum = '{2}',FAddSum ='{3}' ,FTotalSum = '{4}',
                        FManager = '{5}',FCustManager = '{6}' WHERE FID = '{0}'", billId, contractNo, sum, addSum, totalSum, manager, custManager);


                int effectRow = ZYSoft.DB.BLL.Common.ExecuteNonQuery(sql);
                return JsonConvert.SerializeObject(new
                {
                    state = effectRow > -1 ? "success" : "error",
                    data = "",
                    msg = effectRow > -1 ? "保存成功" : "保存失败"
                });

            }
            catch (Exception ex)
            {
                return JsonConvert.SerializeObject(new
                {
                    state = "error",
                    data = DBNull.Value,
                    msg = ex.Message
                });
            }
        }

        public static string SaveCostItem(HttpRequest request)
        {
            try
            {
                var form = request.Form;
                var mainStr = form["mainStr"] ?? "[]";
                var formStr = form["formStr"] ?? "[]";
                BudgetItemCls main = JsonConvert.DeserializeObject<BudgetItemCls>(mainStr);
                List<BudgetItemCls> list = JsonConvert.DeserializeObject<List<BudgetItemCls>>(formStr);
                List<string> sqls = new List<string>();
                if (main != null)
                {
                    sqls.Add(string.Format(@"UPDATE dbo.t_ProjectItem SET FCostQty = '{0}',FCostPrice = '{1}',FCostSum = '{2}' 
                                    WHERE FEntryID = '{3}' AND  FAccountID = '{4}' AND  FProjectID = '{5}' AND FItemCode ='{6}'",
                                    main.CostQty, main.CostPrice, main.CostSum, main.EntryId, main.AccountId, main.ProjectId, main.Code
                                            ));
                }
                if (list.Count > 0)
                {
                    list.ForEach(ele =>
                    {
                        sqls.Add(string.Format(@"UPDATE dbo.t_ProjectItemEntry SET FCostQty = '{0}',FCostPrice = '{1}',FCostSum = '{2}' 
                                    WHERE FEntryID = '{3}' AND  FAccountID = '{4}' AND  FProjectID = '{5}' AND FItemCode ='{6}'",
                                    ele.CostQty, ele.CostPrice, ele.CostSum, ele.EntryId, ele.AccountId, ele.ProjectId, ele.Code
                                            ));
                    });

                    int effectRow = ZYSoft.DB.BLL.Common.ExecuteSQLTran(sqls);
                    return JsonConvert.SerializeObject(new
                    {
                        state = effectRow > -1 ? "success" : "error",
                        data = "",
                        msg = effectRow > -1 ? "保存成功" : "保存失败"
                    });
                }
                else
                {
                    return JsonConvert.SerializeObject(new
                    {
                        state = "error",
                        data = "",
                        msg = "未能获取到提交数据,请先检查!"
                    });
                }
            }
            catch (Exception e)
            {
                return JsonConvert.SerializeObject(new
                {
                    state = "error",
                    data = "",
                    msg = "保存时发生异常,原因:" + e.Message
                });
            }
        }

        public static bool GenBillId(string tableName, ref int billId)
        {
            billId = -1;
            try
            {
                DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(string.Format(@"
                    DECLARE @FInterID BIGINT;
                    EXEC dbo.L_P_GetICMaxNum @TableName = '{0}',
                    @FInterID = @FInterID OUTPUT,
                    @Increment = 1
                    SELECT
                      @FInterID ID", tableName));
                if (dt != null && dt.Rows.Count > 0)
                {
                    billId = CommMethod.SafeInt(dt.Rows[0]["ID"].ToString(), -1);
                }
                return billId > -1;
            }
            catch
            {
                return false;
            }
        }
    }

    public class BudgetItemCls
    {
        public string AccountId { get; set; }
        public string ProjectId { get; set; }
        public string EntryId { get; set; }
        public string Code { get; set; }
        public decimal BudgetQty { get; set; }
        public decimal BudgetPrice { get; set; }
        public decimal BudgetSum { get; set; }

        public decimal CostQty { get; set; }
        public decimal CostPrice { get; set; }
        public decimal CostSum { get; set; }

        public decimal DiffQty { get; set; }
        public decimal DiffPrice { get; set; }
        public decimal DiffSum { get; set; }
    }

    public enum GenBudgetType
    {
        Budget = 1,
        Cost = 2,
        Diff = 3
    }

    public class CommMethod
    {
        #region SafeParse
        public static bool SafeBool(object target, bool defaultValue)
        {
            if (target == null) return defaultValue;
            string tmp = target.ToString(); if (string.IsNullOrWhiteSpace(tmp)) return defaultValue;
            return SafeBool(tmp, defaultValue);
        }
        public static bool SafeBool(string text, bool defaultValue)
        {
            bool flag;
            if (bool.TryParse(text, out flag))
            {
                defaultValue = flag;
            }
            return defaultValue;
        }

        public static DateTime SafeDateTime(object target, DateTime defaultValue)
        {
            if (target == null) return defaultValue;
            string tmp = target.ToString(); if (string.IsNullOrWhiteSpace(tmp)) return defaultValue;
            return SafeDateTime(tmp, defaultValue);
        }
        public static DateTime SafeDateTime(string text, DateTime defaultValue)
        {
            DateTime time;
            if (DateTime.TryParse(text, out time))
            {
                defaultValue = time;
            }
            return defaultValue;
        }

        public static decimal SafeDecimal(object target, decimal defaultValue)
        {
            if (target == null) return defaultValue;
            string tmp = target.ToString(); if (string.IsNullOrWhiteSpace(tmp)) return defaultValue;
            return SafeDecimal(tmp, defaultValue);
        }
        public static decimal SafeDecimal(string text, decimal defaultValue)
        {
            decimal num;
            if (decimal.TryParse(text, out num))
            {
                defaultValue = num;
            }
            return defaultValue;
        }
        public static short SafeShort(object target, short defaultValue)
        {
            if (target == null) return defaultValue;
            string tmp = target.ToString(); if (string.IsNullOrWhiteSpace(tmp)) return defaultValue;
            return SafeShort(tmp, defaultValue);
        }
        public static short SafeShort(string text, short defaultValue)
        {
            short num;
            if (short.TryParse(text, out num))
            {
                defaultValue = num;
            }
            return defaultValue;
        }

        public static int SafeInt(object target, int defaultValue)
        {
            if (target == null) return defaultValue;
            string tmp = target.ToString(); if (string.IsNullOrWhiteSpace(tmp)) return defaultValue;
            return SafeInt(tmp, defaultValue);
        }
        public static int SafeInt(string text, int defaultValue)
        {
            int num;
            if (int.TryParse(text, out num))
            {
                defaultValue = num;
            }
            return defaultValue;
        }


        public static long SafeLong(object target, long defaultValue)
        {
            if (target == null) return defaultValue;
            string tmp = target.ToString(); if (string.IsNullOrWhiteSpace(tmp)) return defaultValue;
            if (string.IsNullOrWhiteSpace(tmp)) return defaultValue;
            return SafeLong(tmp, defaultValue);
        }
        public static long SafeLong(string text, long defaultValue)
        {
            long num;
            if (long.TryParse(text, out num))
            {
                defaultValue = num;
            }
            return defaultValue;
        }

        public static string SafeString(object target, string defaultValue)
        {
            if (null != target && "" != target.ToString())
            {
                return target.ToString();
            }
            return defaultValue;
        }

        #region SafeNullParse
        public static bool? SafeBool(object target, bool? defaultValue)
        {
            if (target == null) return defaultValue;
            string tmp = target.ToString();
            if (string.IsNullOrWhiteSpace(tmp)) return defaultValue;
            return SafeBool(tmp, defaultValue);
        }
        public static bool? SafeBool(string text, bool? defaultValue)
        {
            bool flag;
            if (bool.TryParse(text, out flag))
            {
                defaultValue = flag;
            }
            return defaultValue;
        }

        public static DateTime? SafeDateTime(object target, DateTime? defaultValue)
        {
            if (target == null) return defaultValue;
            string tmp = target.ToString();
            if (string.IsNullOrWhiteSpace(tmp)) return defaultValue;
            return SafeDateTime(tmp, defaultValue);
        }
        public static DateTime? SafeDateTime(string text, DateTime? defaultValue)
        {
            DateTime time;
            if (DateTime.TryParse(text, out time))
            {
                defaultValue = time;
            }
            return defaultValue;
        }

        public static decimal? SafeDecimal(object target, decimal? defaultValue)
        {
            if (target == null) return defaultValue;
            string tmp = target.ToString();
            if (string.IsNullOrWhiteSpace(tmp)) return defaultValue;
            return SafeDecimal(tmp, defaultValue);
        }
        public static decimal? SafeDecimal(string text, decimal? defaultValue)
        {
            decimal num;
            if (decimal.TryParse(text, out num))
            {
                defaultValue = num;
            }
            return defaultValue;
        }

        public static short? SafeShort(object target, short? defaultValue)
        {
            if (target == null) return defaultValue;
            string tmp = target.ToString();
            if (string.IsNullOrWhiteSpace(tmp)) return defaultValue;
            return SafeShort(tmp, defaultValue);
        }
        public static short? SafeShort(string text, short? defaultValue)
        {
            short num;
            if (short.TryParse(text, out num))
            {
                defaultValue = num;
            }
            return defaultValue;
        }

        public static int? SafeInt(object target, int? defaultValue)
        {
            if (target == null) return defaultValue;
            string tmp = target.ToString();
            if (string.IsNullOrWhiteSpace(tmp)) return defaultValue;
            return SafeInt(tmp, defaultValue);
        }
        public static int? SafeInt(string text, int? defaultValue)
        {
            int num;
            if (int.TryParse(text, out num))
            {
                defaultValue = num;
            }
            return defaultValue;
        }

        public static long? SafeLong(object target, long? defaultValue)
        {
            if (target == null) return defaultValue;
            string tmp = target.ToString();
            if (string.IsNullOrWhiteSpace(tmp)) return defaultValue;
            return SafeLong(tmp, defaultValue);
        }
        public static long? SafeLong(string text, long? defaultValue)
        {
            long num;
            if (long.TryParse(text, out num))
            {
                defaultValue = num;
            }
            return defaultValue;
        }
        #endregion

        #region SafeEnum
        /// <summary>
        /// 将枚举数值or枚举名称 安全转换为枚举对象
        /// </summary>
        /// <typeparam name="T">枚举类型</typeparam>
        /// <param name="value">数值or名称</param>
        /// <param name="defaultValue">默认值</param>
        /// <remarks>转换区分大小写</remarks>
        /// <returns></returns>
        public static T SafeEnum<T>(string value, T defaultValue) where T : struct
        {
            return SafeEnum<T>(value, defaultValue, false);
        }

        /// <summary>
        /// 将枚举数值or枚举名称 安全转换为枚举对象
        /// </summary>
        /// <typeparam name="T">枚举类型</typeparam>
        /// <param name="value">数值or名称</param>
        /// <param name="defaultValue">默认值</param>
        /// <param name="ignoreCase">是否忽略大小写 true 不区分大小写 | false 区分大小写</param>
        /// <returns></returns>
        public static T SafeEnum<T>(string value, T defaultValue, bool ignoreCase) where T : struct
        {
            T result;
            if (Enum.TryParse<T>(value, ignoreCase, out result))
            {
                if (Enum.IsDefined(typeof(T), result))
                {
                    defaultValue = result;
                }
            }
            return defaultValue;
        }
        #endregion
        #endregion
    }


    public void ProcessRequest(HttpContext context)
    {
        ZYSoft.DB.Common.Configuration.ConnectionString = DBMethod.LoadXML("ConnectionString");
        context.Response.ContentType = "text/plain";
        if (context.Request.Form["SelectApi"] != null)
        {
            string accountId = context.Request.Form["accountId"] ?? "";
            string result = "";
            switch (context.Request.Form["SelectApi"].ToLower())
            {
                case "getconnect":
                    result = ZYSoft.DB.Common.Configuration.ConnectionString;
                    break;
                case "getdialogconf":
                    string dialogType = context.Request.Form["dialogType"] ?? "custom";
                    result = DBMethod.LoadJSON(dialogType);
                    break;
                case "getprojectcls":
                    result = DBMethod.GetProjectCls(accountId);
                    break;
                case "getproject":
                    string classId = context.Request.Form["classId"] ?? "";
                    result = DBMethod.GetProject(accountId, classId);
                    break;
                case "getcustcls":
                    result = DBMethod.GetCustomCls(accountId);
                    break;
                case "getcustom":
                    classId = context.Request.Form["classId"] ?? "";
                    result = DBMethod.GetCustom(accountId, classId);
                    break;
                case "genbudgetdetail":
                    string projectId = context.Request.Form["projectId"] ?? "";
                    result = DBMethod.GenBudgetInfo(accountId, projectId, GenBudgetType.Budget.GetHashCode());
                    break;
                case "checkcostdetail":
                    projectId = context.Request.Form["projectId"] ?? "";
                    result = DBMethod.GenBudgetInfo(accountId, projectId, GenBudgetType.Cost.GetHashCode());
                    break;
                case "checkdiffdetail":
                    projectId = context.Request.Form["projectId"] ?? "";
                    result = DBMethod.GenBudgetInfo(accountId, projectId, GenBudgetType.Diff.GetHashCode());
                    break;
                case "getitemdetail":
                    projectId = context.Request.Form["projectId"] ?? "";
                    string clsCode = context.Request.Form["clsCode"] ?? "";
                    string type = context.Request.Form["type"] ?? GenBudgetType.Budget.GetHashCode().ToString();
                    result = DBMethod.GetBudgetDetailInfo(accountId, projectId, clsCode, GenBudgetType.Budget.GetHashCode());
                    break;
                case "getbudget":
                    string billId = context.Request.Form["id"] ?? "";
                    result = DBMethod.GetBudget(billId);
                    break;
                case "getbudgetlist":
                    result = DBMethod.GetBudgetList(accountId, context.Request);
                    break;
                case "getcost":
                    billId = context.Request.Form["id"] ?? "";
                    result = DBMethod.GetCost(billId);
                    break;
                case "getcostlist":
                    result = DBMethod.GetCostList(accountId, context.Request);
                    break;
                case "getdifflist":
                    result = DBMethod.GetDiffList(accountId, context.Request);
                    break;
                case "savebudget":
                    result = DBMethod.SaveBudget(context.Request);
                    break;
                case "savecost":
                    result = DBMethod.SaveCost(context.Request);
                    break;
                case "savebudgetitem":
                    result = DBMethod.SaveBudgetItem(context.Request);
                    break;
                case "savecostitem":
                    result = DBMethod.SaveCostItem(context.Request);
                    break;
                default: break;
            }
            context.Response.Write(result);
        }
        else
        {
            context.Response.Write("服务正在运行!");
        }
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}
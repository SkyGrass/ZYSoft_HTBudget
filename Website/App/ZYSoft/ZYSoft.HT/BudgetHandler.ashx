<%@ WebHandler Language="C#" Class="BudgetHandler" %>

using System;
using System.Web;
using System.Data;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Collections.Generic;
using System.Xml;
using System.IO;
using System.Reflection;
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

    public class BudgetEntry
    {
        /// <summary>
        /// 
        /// </summary>
        public long FEntryID { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string FAccountID { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int FProjectID { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string FGroupCode { get; set; }
        /// <summary>
        /// 存货
        /// </summary>
        public string FItemType { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int FItemID { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string FItemCode { get; set; }
        /// <summary>
        /// 碳钢
        /// </summary>
        public string FItemName { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int FDepth { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int FParentItemID { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public int FIsEndNode { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public decimal FBudgetQty { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public decimal FBudgetPrice { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public decimal FBudgetSum { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public decimal FCostQty { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public decimal FCostPrice { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public decimal FCostSum { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public decimal FDiffQty { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public decimal FDiffPrice { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public decimal FDiffSum { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public string FDiffRate { get; set; }
    }

    public class DBMethod
    {
        public static IList<T> ToList<T>(DataTable dt)
        {
            var lst = new List<T>();
            var plist = new List<PropertyInfo>(typeof(T).GetProperties());
            foreach (DataRow item in dt.Rows)
            {
                T t = System.Activator.CreateInstance<T>();
                for (int i = 0; i < dt.Columns.Count; i++)
                {
                    PropertyInfo info = plist.Find(p => p.Name == dt.Columns[i].ColumnName);
                    if (info != null)
                    {
                        if (!Convert.IsDBNull(item[i]))
                        {
                            info.SetValue(t, item[i], null);
                        }
                    }
                }
                lst.Add(t);
            }
            return lst;

        }

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
                string year = CommMethod.SafeString(request.Form["year"], "");
                string contractDate = CommMethod.SafeString(request.Form["contractDate"], "");
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
                if (!string.IsNullOrEmpty(year))
                {
                    string sw = "";
                    string[] ys = (year.Split(','));
                    foreach (string y in ys)
                    {
                        sw += string.Format(@" t.FYear = ''{0}'' OR", y); ;
                    }
                    sw = sw.TrimEnd('O', 'R');
                    sqlWhere += string.Format(@" AND ({0})", sw);
                }
                if (!string.IsNullOrEmpty(contractDate))
                {
                    sqlWhere += string.Format(@" AND t.FContractDate = ''{0}''", contractDate);
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

        public static string GetProjectProfitList(string accountId, HttpRequest request)
        {
            try
            {
                string sqlWhere = " 1=1 ";
                var form = request.Form;

                int pageIndex = CommMethod.SafeInt(request.Form["pageIndex"], 1);
                int pageSize = CommMethod.SafeInt(request.Form["pageSize"], 20);
                string startDate = CommMethod.SafeString(request.Form["startDate"], "");
                string endDate = CommMethod.SafeString(request.Form["endDate"], "");
                string year = CommMethod.SafeString(request.Form["year"], "");
                string contractNo = CommMethod.SafeString(request.Form["contractNo"], "");
                string projectClsId = CommMethod.SafeString(request.Form["projectClsId"], "");
                string projectId = CommMethod.SafeString(request.Form["projectId"], "");
                string custId = CommMethod.SafeString(request.Form["custId"], "");
                if (!string.IsNullOrEmpty(startDate))
                {
                    sqlWhere += string.Format(@" AND t1.FEndDate >= ''{0} 00:00:00''", startDate);
                }

                if (!string.IsNullOrEmpty(endDate))
                {
                    sqlWhere += string.Format(@" AND t1.FEndDate <= ''{0} 23:59:59''", endDate);
                }
                if (!string.IsNullOrEmpty(contractNo))
                {
                    sqlWhere += string.Format(@" AND t1.FContractNo like ''%{0}%''", contractNo);
                }
                if (!string.IsNullOrEmpty(projectClsId))
                {
                    sqlWhere += string.Format(@" AND t4.ID =''{0}''", projectClsId);
                }
                if (!string.IsNullOrEmpty(projectId))
                {
                    sqlWhere += string.Format(@" AND t1.FProjectId =''{0}''", projectId);
                }
                if (!string.IsNullOrEmpty(custId))
                {
                    sqlWhere += string.Format(@" AND t1.FCustId = ''{0}''", custId);
                }
                if (!string.IsNullOrEmpty(year))
                {
                    sqlWhere += string.Format(@" AND t3.priuserdefnvc1 = ''{0}''", year);
                }

                string sql = string.Format(@" EXEC dbo.P_Total_ProjectProfit 
                                            @FAccountID = '{0}', -- varchar(20)
                                            @FilterSql = '{1}'   -- varchar(max)", accountId, sqlWhere);
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

        public static string GetBudgetDetailInfo(string accountId, string projectId, string clsCode, string groupCode, string year)
        {
            try
            {
                List<BudgetEntry> list = new List<BudgetEntry>();
                string sql = string.Format(@" SELECT FEntryID,FAccountID,FProjectID,FGroupCode,FItemType,FItemID,FItemCode,
                    FItemName,FDepth,ISNULL(FParentItemID,0)FParentItemID,FIsEndNode,ISNULL(FBudgetQty,0)FBudgetQty,ISNULL(FBudgetPrice,0)FBudgetPrice,
		         ISNULL(FBudgetSum,0)FBudgetSum,ISNULL(FCostQty,0)FCostQty,ISNULL(FCostPrice,0)FCostPrice,
		         ISNULL(FCostSum,0)FCostSum,ISNULL(FDiffQty,0)FDiffQty,ISNULL(FDiffPrice,0)FDiffPrice,ISNULL(FDiffSum,0)FDiffSum,
                ISNULL(FDiffRate,'')FDiffRate FROM dbo.t_ProjectItemEntry WHERE
                FAccountID = '{0}' AND FProjectID = '{1}' AND FItemCode = '{2}' AND FGroupCode = '{3}' AND FYear='{4}' ",
                  accountId, projectId, clsCode, groupCode, year);
                DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(sql);
                if (dt != null && dt.Rows.Count > 0)
                {
                    string itemId = CommMethod.SafeString(dt.Rows[0]["FItemID"], "");
                    list.AddRange(new List<BudgetEntry>(ToList<BudgetEntry>(dt)));
                    QueryA(accountId, projectId, itemId, year, ref list);
                    return JsonConvert.SerializeObject(new
                    {
                        state = list.Count > 0 ? "success" : "error",
                        data = list,
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

        public static void QueryA(string accountId, string projectId, string itemId, string year,
            ref List<BudgetEntry> list)
        {
            string sql = string.Format(@" SELECT  FEntryID,FAccountID,FProjectID,FGroupCode,FItemType,FItemID,FItemCode,
                    FItemName,FDepth,ISNULL(FParentItemID,0)FParentItemID,FIsEndNode,ISNULL(FBudgetQty,0)FBudgetQty,ISNULL(FBudgetPrice,0)FBudgetPrice,
		         ISNULL(FBudgetSum,0)FBudgetSum,ISNULL(FCostQty,0)FCostQty,ISNULL(FCostPrice,0)FCostPrice,
		         ISNULL(FCostSum,0)FCostSum,ISNULL(FDiffQty,0)FDiffQty,ISNULL(FDiffPrice,0)FDiffPrice,ISNULL(FDiffSum,0)FDiffSum,
                ISNULL(FDiffRate,'')FDiffRate,ISNULL(FYear,'')FYear FROM dbo.t_ProjectItemEntry WHERE
                FAccountID = '{0}' AND FProjectID = '{1}' AND FParentItemID = '{2}'  AND FYear = '{3}' ",
                  accountId, projectId, itemId, year);
            DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(sql);
            list.AddRange(new List<BudgetEntry>(ToList<BudgetEntry>(dt)));
            if (dt != null && dt.Rows.Count > 0)
            {
                foreach (DataRow dr in dt.Rows)
                {
                    if (CommMethod.SafeInt(dr["FIsEndNode"], 1) == 0)
                    {
                        QueryA(CommMethod.SafeString(dr["FAccountID"], ""),
                            CommMethod.SafeString(dr["FProjectID"], ""),
                            CommMethod.SafeString(dr["FItemID"], ""),
                            CommMethod.SafeString(dr["FYear"], ""), ref list);
                    }
                }
            }
        }

        public static bool BeforeSaveBudget(string accountId, string projectId, string year, ref string errMsg)
        {
            try
            {
                string sql = string.Format(@"SELECT 1 FROM dbo.t_ProjectBudget  WHERE FAccountID ='{0}' AND FProjectID = '{1}' AND FYear ='{2}'",
                    accountId, projectId, year);
                bool result = ZYSoft.DB.BLL.Common.Exist(sql);
                if (result)
                {
                    errMsg = "当前账套下已经存在年度项目的预算单!";
                }
                return result;
            }
            catch (Exception e)
            {
                errMsg = e.Message;
                return true;
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

                string accountId = form["accountId"] ?? "";
                string custId = form["custId"] ?? "";
                string projectId = form["projectId"] ?? "";
                string contractNo = form["contractNo"] ?? "";
                string year = form["year"] ?? "";
                string projectType = form["projectType"] ?? "";
                string createDate = form["date"] ?? "";
                decimal sum = CommMethod.SafeDecimal(form["sum"], 0);
                decimal addSum = CommMethod.SafeDecimal(form["addSum"], 0);
                decimal totalSum = sum + addSum;
                string billerId = form["billerId"] ?? "";
                string manager = form["manager"] ?? "";
                string custManager = form["custManager"] ?? "";

                if (billId == -1)
                {
                    string errMsg = "";
                    if (BeforeSaveBudget(accountId, projectId, year, ref errMsg))
                    {
                        return JsonConvert.SerializeObject(new
                        {
                            state = "error",
                            data = "",
                            msg = errMsg
                        });

                    }

                    isAdd = true;
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

                string sql = isAdd ? string.Format(@"INSERT INTO dbo.t_ProjectBudget ( FID, FAccountID, FCustID, FProjectID, FContractNo,
                                FSum, FAddSum, FTotalSum, FBillerID, FCreateDate, FManager, FCustManager ,FYear,FProjectType) VALUES 
                                ( {0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','{10}','{11}','{12}','{13}')",
                                    billId, accountId, custId, projectId, contractNo, sum, addSum, totalSum, billerId, createDate, manager, custManager, year, projectType)
                        : string.Format(@"UPDATE dbo.t_ProjectBudget SET  FContractNo = '{1}',FSum = '{2}',FAddSum ='{3}' ,FTotalSum = '{4}',
                        FManager = '{5}',FCustManager = '{6}',FYear = '{7}',FProjectType = '{8}',FCreateDate='{9}' WHERE FID = '{0}'", billId, contractNo, sum, addSum, totalSum,
                        manager, custManager, year, projectType, createDate);


                int effectRow = ZYSoft.DB.BLL.Common.ExecuteNonQuery(sql);
                return JsonConvert.SerializeObject(new
                {
                    state = effectRow > -1 ? "success" : "error",
                    data = effectRow > -1 ? billId.ToString() : "",
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

        /// <summary>
        /// 保存预算明细
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
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
        /// 查询增补合同
        /// </summary>
        /// <param name="accountId"></param>
        /// <param name="billId"></param>
        /// <returns></returns>
        public static string GetContractList(string accountId, string billId)
        {
            var list = new List<TreeNode>();
            try
            {
                string sql = string.Format(@"EXEC dbo.P_Get_ProjectContract @FAccountID = '{0}',
                                        @FID = '{1}'", accountId, billId);
                DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(sql);
                if (dt != null && dt.Rows.Count > 0)
                {
                    return JsonConvert.SerializeObject(new
                    {
                        state = dt.Rows.Count > 0 ? "success" : "error",
                        data = dt,
                        msg = "查询增补合同成功!"
                    });
                }
                else
                {
                    return JsonConvert.SerializeObject(new
                    {
                        state = "error",
                        data = DBNull.Value,
                        msg = "未能查询到增补合同!"
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
        /// 查询成本明细
        /// </summary>
        /// <param name="accountId"></param>  
        /// <param name="projectId"></param> 
        /// <param name="entryId"></param>    
        /// <returns></returns>
        public static string GetCostDetailList(string accountId, string projectId, string entryId)
        {
            var list = new List<TreeNode>();
            try
            {
                string sql = string.Format(@"EXEC dbo.P_Get_ProjectCostDetail @FAccountID = '{0}', -- varchar(20)
                                  @FProjectID = '{1}',  -- int
                                  @FEntryID = '{2}'     -- int	", accountId, projectId, entryId);
                DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(sql);
                if (dt != null && dt.Rows.Count > 0)
                {
                    return JsonConvert.SerializeObject(new
                    {
                        state = dt.Rows.Count > 0 ? "success" : "error",
                        data = dt,
                        msg = "查询成本明细成功!"
                    });
                }
                else
                {
                    return JsonConvert.SerializeObject(new
                    {
                        state = "error",
                        data = DBNull.Value,
                        msg = "未能查询到成本明细!"
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

        public static string GetJSList(string accountId, HttpRequest request)
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
                    sqlWhere += string.Format(@" AND t.FDate >= ''{0} 00:00:00''", startDate);
                }
                if (!string.IsNullOrEmpty(endDate))
                {
                    sqlWhere += string.Format(@" AND t.FDate <= ''{0} 23:59:59''", endDate);
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
                    sqlWhere += string.Format(@" AND t.FItemID = ''{0}''", billId);
                }

                string sql = string.Format(@" EXEC dbo.P_GetJSRecord @FAccountID = '{0}', -- varchar(20)
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

        public static string GetJSDetail(string billId)
        {
            try
            {

                string sql = string.Format(@"SELECT * FROM dbo.t_ProjectAccountEntry WHERE FItemID = '{0}'", billId);
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

        public static string GetSaleList(string accountId, string projectId)
        {
            var list = new List<TreeNode>();
            try
            {
                string sql = string.Format(@"EXEC dbo.P_Get_SaleDelivery @FAccountID = '{0}', -- varchar(20)
                            @FilterSql = 't2.idproject = ''{1}'''   -- varchar(max)", accountId, projectId);
                DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(sql);
                if (dt != null && dt.Rows.Count > 0)
                {
                    return JsonConvert.SerializeObject(new
                    {
                        state = dt.Rows.Count > 0 ? "success" : "error",
                        data = dt,
                        msg = "查询销货单成功!"
                    });
                }
                else
                {
                    return JsonConvert.SerializeObject(new
                    {
                        state = "error",
                        data = DBNull.Value,
                        msg = "未能查询到销货单!"
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

        public static string SaveJs(HttpRequest request)
        {
            try
            {
                var form = request.Form;
                var mainStr = form["mainStr"] ?? "[]";
                var formStr = form["formStr"] ?? "[]";
                ProjectAccount main = JsonConvert.DeserializeObject<ProjectAccount>(mainStr);
                List<ProjectAccountEntry> list = JsonConvert.DeserializeObject<List<ProjectAccountEntry>>(formStr);
                List<string> sqls = new List<string>();
                if (main != null)
                {
                    if (main.FItemID <= 0)
                    {
                        int billId = 0;
                        if (GenBillId("t_ProjectAccount", ref billId))
                        {
                            main.FItemID = billId;
                        }

                        sqls.Add(string.Format(@"INSERT INTO dbo.t_ProjectAccount(
								    FItemID, FAccountID,FBillNo,FDate,FCustID,FProjectID,FContractNo,FManager,FCustManager,FMemo,FSum,FBillerID,FProjectType)VALUES
								( '{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','{10}' ,'{11}','{12}' )",
                                    main.FItemID, main.FAccountID, main.FBillNo, main.FDate, main.FCustID,
                                    main.FProjectID, main.FContractNo, main.FManager, main.FCustManager,
                                    main.FMemo, main.FSum, main.FBillerID, main.FProjectType));
                    }
                    else
                    {
                        sqls.Add(string.Format(@"Update dbo.t_ProjectAccount Set FCustID ='{1}',FContractNo ='{2}',FManager='{3}',
                        FCustManager='{4}',FMemo='{5}',FSum='{6}',FProjectType='{7}' Where FItemID = '{0}'",
                            main.FItemID, main.FCustID, main.FContractNo, main.FManager, main.FCustManager, main.FMemo, main.FSum, main.FProjectType));

                        sqls.Add(string.Format(@"DELETE FROM t_ProjectAccountEntry Where FItemID ='{0}'", main.FItemID));
                    }

                    if (list != null && list.Count > 0)
                    {
                        list.ForEach(row =>
                        {
                            sqls.Add(string.Format(@"INSERT INTO dbo.t_ProjectAccountEntry ( FItemID, FInventroyID, FUnitID, FQty, FPrice, FSum, FTaxRate, FTax, FTaxPrice, FTaxSum, FEntryMemo, FSourceBillNo, FSourceBillID, FSourceBillEntryID,FUnitName,FInvCode,FInvName ) VALUES
                                      (  '{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','{10}','{11}','{12}','{13}','{14}','{15}','{16}')",
                                                           main.FItemID, row.FInventoryID, row.FUnitID, row.FQty, row.FPrice,
                                                           row.FSum, row.FTaxRate, row.FTax, row.FTaxPrice, row.FTaxSum, row.FEntryMemo, row.FSourceBillNo, row.FSourceBillID,
                                                           row.FSourceBillEntryID, row.FUnitName, row.FInvCode, row.FInvName));
                        });

                        int effectRow = ZYSoft.DB.BLL.Common.ExecuteSQLTran(sqls);
                        return JsonConvert.SerializeObject(new
                        {
                            state = effectRow > 0 ? "success" : "error",
                            data = main.FItemID,
                            msg = effectRow > 0 ? "保存成功!" : "保存失败!"
                        });
                    }
                    else
                    {
                        return JsonConvert.SerializeObject(new
                        {
                            state = "error",
                            data = "",
                            msg = "保存时发生异常,原因:没有获取到提交数据"
                        });
                    }
                }
                else
                {
                    return JsonConvert.SerializeObject(new
                    {
                        state = "error",
                        data = "",
                        msg = "保存时发生异常,原因:没有获取到提交数据"
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

        public static string VerifyJs(string ids, string billerId, int flag = 0)
        {
            try
            {
                string checkSql = flag == 0 ? "SELECT 1 FROM dbo.t_ProjectAccount WHERE FItemID IN ({0}) AND ISNULL(FVeriferID,'-1') <> -1"
                        : "SELECT 1 FROM dbo.t_ProjectAccount WHERE FItemID IN ({0}) AND ISNULL(FVeriferID,'-1') = -1";
                if (ZYSoft.DB.BLL.Common.Exist(string.Format(checkSql, ids)))
                {
                    return JsonConvert.SerializeObject(new
                    {
                        state = "error",
                        data = "",
                        msg = (flag == 0 ? "审批" : "反审批") + "失败,原因:" + "存在" + (flag == 0 ? "已审批" : "未审批") + "的单据"
                    });
                }
                else
                {
                    string updateSql = flag == 0 ? "update dbo.t_ProjectAccount SET FVeriferID = '{1}',FVerifyDate =GETDATE() WHERE FItemID IN ({0})"
                   : "update dbo.t_ProjectAccount SET FVeriferID = NULL,FVerifyDate = NULL WHERE FItemID IN ({0})";
                    int effectRow = ZYSoft.DB.BLL.Common.ExecuteNonQuery(string.Format(updateSql, ids, billerId));
                    return JsonConvert.SerializeObject(new
                    {
                        state = effectRow > 0 ? "success" : "error",
                        data = "",
                        msg = (flag == 0 ? "审批" : "反审批") + (effectRow > 0 ? "成功" : "失败")
                    });
                }
            }
            catch (Exception e)
            {
                return JsonConvert.SerializeObject(new
                {
                    state = "error",
                    data = "",
                    msg = (flag == 0 ? "审批" : "反审批") + "时发生异常,原因:" + e.Message
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


        public static string DeleteBudget(string ids)
        {
            try
            {
                List<string> sqls = new List<string>();
                DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(string.Format(@"SELECT FAccountID,FProjectID,FYear FROM dbo.t_ProjectBudget WHERE FID IN ({0})", ids));
                if (dt != null && dt.Rows.Count > 0)
                {
                    sqls.Add(string.Format(@"DELETE FROM dbo.t_ProjectBudget WHERE FID IN ({0})", ids));
                    foreach (DataRow dr in dt.Rows)
                    {
                        sqls.Add(string.Format(@"UPDATE dbo.t_ProjectItem SET FBudgetQty = 0,FBudgetPrice = 0,FBudgetSum = 0 
                                WHERE FAccountID ='{0}' AND FProjectID = '{1}' AND FYear ='{2}'", CommMethod.SafeString(dr["FAccountID"], ""),
                                CommMethod.SafeString(dr["FProjectID"], ""), CommMethod.SafeString(dr["FYear"], "")));

                        sqls.Add(string.Format(@"UPDATE dbo.t_ProjectItemEntry SET FBudgetQty = 0,FBudgetPrice = 0,FBudgetSum = 0 
                                WHERE FAccountID ='{0}' AND FProjectID = '{1}' AND FYear ='{2}'", CommMethod.SafeString(dr["FAccountID"], ""),
                            CommMethod.SafeString(dr["FProjectID"], ""), CommMethod.SafeString(dr["FYear"], "")));
                    }
                }
                int effectRow = ZYSoft.DB.BLL.Common.ExecuteSQLTran(sqls);
                return JsonConvert.SerializeObject(new
                {
                    state = effectRow > 0 ? "success" : "error",
                    data = "",
                    msg = effectRow > 0 ? "删除成功!" : "删除失败!",
                });
            }
            catch (Exception e)
            {
                return JsonConvert.SerializeObject(new
                {
                    state = "error",
                    data = "",
                    msg = "删除预算单时发生异常,原因:" + e.Message
                });
            }
        }

        public static string DeleteCost(string ids)
        {
            try
            {
                List<string> sqls = new List<string>();
                DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(string.Format(@"SELECT FAccountID,FProjectID,FYear FROM dbo.t_ProjectCost WHERE FID IN ({0})", ids));
                if (dt != null && dt.Rows.Count > 0)
                {
                    sqls.Add(string.Format(@"DELETE FROM dbo.t_ProjectCost WHERE FID IN ({0})", ids));
                    foreach (DataRow dr in dt.Rows)
                    {
                        sqls.Add(string.Format(@"UPDATE dbo.t_ProjectItem SET FCostQty = 0,FCostPrice = 0,FCostSum = 0 
                                WHERE FAccountID ='{0}' AND FProjectID = '{1}' AND FYear ='{2}'", CommMethod.SafeString(dr["FAccountID"], ""),
                                CommMethod.SafeString(dr["FProjectID"], ""), CommMethod.SafeString(dr["FYear"], "")));

                        sqls.Add(string.Format(@"UPDATE dbo.t_ProjectItemEntry SET FCostQty = 0,FCostPrice = 0,FCostSum = 0 
                                WHERE FAccountID ='{0}' AND FProjectID = '{1}' AND FYear ='{2}'", CommMethod.SafeString(dr["FAccountID"], ""),
                            CommMethod.SafeString(dr["FProjectID"], ""), CommMethod.SafeString(dr["FYear"], "")));
                    }
                }
                int effectRow = ZYSoft.DB.BLL.Common.ExecuteSQLTran(sqls);
                return JsonConvert.SerializeObject(new
                {
                    state = effectRow > 0 ? "success" : "error",
                    data = "",
                    msg = effectRow > 0 ? "删除成功!" : "删除失败!",
                });
            }
            catch (Exception e)
            {
                return JsonConvert.SerializeObject(new
                {
                    state = "error",
                    data = "",
                    msg = "删除实际成本单时发生异常,原因:" + e.Message
                });
            }
        }

        public static string DeleteDiff(string ids)
        {
            try
            {
                List<string> sqls = new List<string>();
                DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(string.Format(@"SELECT FAccountID,FProjectID,FYear FROM dbo.t_ProjectDiff WHERE FID IN ({0})", ids));
                if (dt != null && dt.Rows.Count > 0)
                {
                    sqls.Add(string.Format(@"DELETE FROM dbo.t_ProjectDiff WHERE FID IN ({0})", ids));
                    foreach (DataRow dr in dt.Rows)
                    {
                        sqls.Add(string.Format(@"UPDATE dbo.t_ProjectItem SET FDiffQty = 0,FDiffPrice = 0,FDiffSum = 0 
                                WHERE FAccountID ='{0}' AND FProjectID = '{1}' AND FYear ='{2}'", CommMethod.SafeString(dr["FAccountID"], ""),
                                CommMethod.SafeString(dr["FProjectID"], ""), CommMethod.SafeString(dr["FYear"], "")));

                        sqls.Add(string.Format(@"UPDATE dbo.t_ProjectItemEntry SET FDiffQty = 0,FDiffPrice = 0,FDiffSum = 0 
                                WHERE FAccountID ='{0}' AND FProjectID = '{1}' AND FYear ='{2}'", CommMethod.SafeString(dr["FAccountID"], ""),
                            CommMethod.SafeString(dr["FProjectID"], ""), CommMethod.SafeString(dr["FYear"], "")));
                    }
                }
                int effectRow = ZYSoft.DB.BLL.Common.ExecuteSQLTran(sqls);
                return JsonConvert.SerializeObject(new
                {
                    state = effectRow > 0 ? "success" : "error",
                    data = "",
                    msg = effectRow > 0 ? "删除成功!" : "删除失败!",
                });
            }
            catch (Exception e)
            {
                return JsonConvert.SerializeObject(new
                {
                    state = "error",
                    data = "",
                    msg = "删除实际成本与预算差异单时发生异常,原因:" + e.Message
                });
            }
        }

        public static string DeleteJs(string ids)
        {
            try
            {
                string checkSql = "SELECT 1 FROM dbo.t_ProjectAccount WHERE FItemID IN ({0}) AND ISNULL(FVeriferID,'-1') <> -1";
                if (ZYSoft.DB.BLL.Common.Exist(string.Format(checkSql, ids)))
                {
                    return JsonConvert.SerializeObject(new
                    {
                        state = "error",
                        data = "",
                        msg = "删除结算单时发生错误,原因:存在已经审核过的单据!"
                    });
                }
                List<string> sqls = new List<string>();
                sqls.Add(string.Format(@"DELETE FROM dbo.t_ProjectAccount WHERE FItemID IN ({0})", ids));
                sqls.Add(string.Format(@"DELETE FROM dbo.t_ProjectAccountEntry WHERE FItemID IN ({0})", ids));
                int effectRow = ZYSoft.DB.BLL.Common.ExecuteSQLTran(sqls);
                return JsonConvert.SerializeObject(new
                {
                    state = effectRow > 0 ? "success" : "error",
                    data = "",
                    msg = effectRow > 0 ? "删除成功!" : "删除失败!",
                });
            }
            catch (Exception e)
            {
                return JsonConvert.SerializeObject(new
                {
                    state = "error",
                    data = "",
                    msg = "删除结算单时发生异常,原因:" + e.Message
                });
            }
        }

        public static string GenBillNo(string prefix)
        {
            string billNo = "";
            try
            {
                DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable(string.Format(@"
                    DECLARE @FInterID BIGINT;
                    EXEC dbo.L_P_GetICMaxNum @TableName = '{0}',
                    @FInterID = @FInterID OUTPUT,
                    @Increment = 1
                    SELECT
                      @FInterID ID", prefix));
                if (dt != null && dt.Rows.Count > 0)
                {
                    int billId = CommMethod.SafeInt(dt.Rows[0]["ID"].ToString(), -1);
                    billNo = string.Format(@"{0}{1}{2}", prefix, DateTime.Now.ToString("yyyyMMddhhmmss"), billId);
                }
                return JsonConvert.SerializeObject(new
                {
                    state = !string.IsNullOrEmpty(billNo) ? "success" : "error",
                    data = billNo,
                    msg = "生成成功!"
                }); ;
            }
            catch (Exception e)
            {
                return JsonConvert.SerializeObject(new
                {
                    state = "error",
                    data = "",
                    msg = e.Message
                }); ;
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

    public class ProjectAccount
    {
        public int FItemID { get; set; }
        public int FAccountID { get; set; }
        public string FBillNo { get; set; }
        public string FDate { get; set; }
        public int FCustID { get; set; }
        public int FProjectID { get; set; }
        public string FContractNo { get; set; }
        public string FManager { get; set; }
        public string FCustManager { get; set; }
        public string FMemo { get; set; }
        public decimal FSum { get; set; }
        public int FBillerID { get; set; }
        public int FVeriferID { get; set; }
        public string FVeriferDate { get; set; }
        public string FProjectType { get; set; }
    }

    public class ProjectAccountEntry
    {
        public int FEntryID { get; set; }
        public int FItemID { get; set; }
        public int FInventoryID { get; set; }
        public int FUnitID { get; set; }

        public decimal FQty { get; set; }
        public decimal FPrice { get; set; }
        public decimal FSum { get; set; }

        public decimal FTaxRate { get; set; }
        public decimal FTax { get; set; }
        public decimal FTaxPrice { get; set; }
        public decimal FTaxSum { get; set; }

        public int FSourceBillID { get; set; }
        public int FSourceBillEntryID { get; set; }
        public string FSourceBillNo { get; set; }
        public string FEntryMemo { get; set; }

        public string FUnitName { get; set; }
        public string FInvCode { get; set; }
        public string FInvName { get; set; }
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
                    string groupCode = context.Request.Form["groupCode"] ?? "";
                    string year = context.Request.Form["year"] ?? "";
                    result = DBMethod.GetBudgetDetailInfo(accountId, projectId, clsCode, groupCode, year);
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
                case "getsalelist":
                    projectId = context.Request.Form["projectId"] ?? "";
                    result = DBMethod.GetSaleList(accountId, projectId);
                    break;
                case "getjslist":
                    result = DBMethod.GetJSList(accountId, context.Request);
                    break;
                case "getjsdetail":
                    billId = context.Request.Form["billId"] ?? "";
                    result = DBMethod.GetJSDetail(billId);
                    break;
                case "savebudget":
                    result = DBMethod.SaveBudget(context.Request);
                    break;
                case "savebudgetitem":
                    result = DBMethod.SaveBudgetItem(context.Request);
                    break;
                case "savejs":
                    result = DBMethod.SaveJs(context.Request);
                    break;
                case "verfiy":
                    string ids = context.Request.Form["ids"] ?? "";
                    string billerId = context.Request.Form["billerId"] ?? "";
                    int flag = CommMethod.SafeInt(context.Request.Form["flag"] ?? "0", 0);
                    result = DBMethod.VerifyJs(ids, billerId, flag);
                    break;
                case "getcontractlist":
                    billId = context.Request.Form["id"] ?? "";
                    result = DBMethod.GetContractList(accountId, billId);
                    break;
                case "getcostdetaillist":
                    projectId = context.Request.Form["projectId"] ?? "";
                    string entryId = context.Request.Form["entryId"] ?? "";
                    result = DBMethod.GetCostDetailList(accountId, projectId, entryId);
                    break;
                case "getprojectprofit":
                    result = DBMethod.GetProjectProfitList(accountId, context.Request);
                    break;
                case "genbillno":
                    result = DBMethod.GenBillNo("JS");
                    break;
                case "deletebudget":
                    ids = context.Request.Form["ids"] ?? "";
                    result = DBMethod.DeleteBudget(ids);
                    break;
                case "deletecost":
                    ids = context.Request.Form["ids"] ?? "";
                    result = DBMethod.DeleteCost(ids);
                    break;
                case "deletediff":
                    ids = context.Request.Form["ids"] ?? "";
                    result = DBMethod.DeleteDiff(ids);
                    break;
                case "deletejs":
                    ids = context.Request.Form["ids"] ?? "";
                    result = DBMethod.DeleteJs(ids);
                    break;
                case "check":
                    projectId = context.Request.Form["projectId"] ?? "";
                    year = context.Request.Form["year"] ?? "";
                    string errMsg = "";
                    bool r = DBMethod.BeforeSaveBudget(accountId, projectId, year, ref errMsg);
                    result = JsonConvert.SerializeObject(new
                    {
                        state = "success",
                        data = r ? 1 : 0,
                        msg = errMsg
                    });
                    break;
                default:
                    result = JsonConvert.SerializeObject(new
                    {
                        state = "error",
                        data = "",
                        msg = "没有这个接口方法!"
                    });
                    break;
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
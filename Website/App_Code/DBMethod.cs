using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Web;

/// <summary>
/// DBMethod 的摘要说明
/// </summary>
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
            int billId = -1;
            if (GenBillId("t_ProjectBudget", ref billId))
            {
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

                string sql = string.Format(@"INSERT INTO dbo.t_ProjectBudget ( FID, FAccountID, FCustID, FProjectID, FContractNo,
                                FSum, FAddSum, FTotalSum, FBillerID, FCreateDate, FManager, FCustManager ) VALUES 
                                ( {0},'{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}',GETDATE(),'{9}','{10}')",
                                    billId, accountId, custId, projectId, contractNo, sum, addSum, totalSum, billerId, manager, custManager);

                int effectRow = ZYSoft.DB.BLL.Common.ExecuteNonQuery(sql);
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
                    msg = "生成单据ID发生错误,请先检查!"
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
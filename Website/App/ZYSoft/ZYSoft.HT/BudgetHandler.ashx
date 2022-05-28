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

    public class QueryForm
    {
        public string cid { get; set; }
        public string batch { get; set; }
    }

    public class PostForm
    {
        public string FMakerId { get; set; }
        public string FMaker { get; set; }
        public bool isMark { get; set; }
        public Body FormId { get; set; }
    }

    public class Body
    {
        public List<BillForm> Form_in { get; set; }
        public List<BillForm> Form_out { get; set; }
        public List<BillForm> Form_trans { get; set; }
    }

    public class BillForm
    {
        public string Id { get; set; }
        public string EntryId { get; set; }
    }

    public class TResult
    {
        public string Result { get; set; }
        public string Message { get; set; }
        public object Data { get; set; }
    }


    public void ProcessRequest(HttpContext context)
    {
        ZYSoft.DB.Common.Configuration.ConnectionString = LoadXML("ConnectionString");
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
                case "getitems":
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
                case "savebudget":
                    result = DBMethod.SaveBudget(context.Request);
                    break;
                case "savebudgetitem":
                    result = DBMethod.SaveBudgetItem(context.Request);
                    break;

















                case "getallmaterialinfo":
                    string code = context.Request.Form["code"] ?? "";
                    result = GetMaterialInfo(code);
                    break;
                case "getmaterialinfo":
                    code = context.Request.Form["code"] ?? "";
                    result = GetMaterialInfo(code);
                    break;
                case "getrecordin":
                    string cid = context.Request.Form["cid"] ?? "";
                    string batch = context.Request.Form["batch"] ?? "";
                    bool ismark = (context.Request.Form["isMark"] ?? "true").Equals("true") ? true : false;
                    string startdate = context.Request.Form["startdate"] ?? "";
                    string enddate = context.Request.Form["enddate"] ?? "";
                    result = GetRecordIn(cid, batch, ismark, startdate, enddate);
                    break;
                case "getrecordtrans":
                    cid = context.Request.Form["cid"] ?? "";
                    batch = context.Request.Form["batch"] ?? "";
                    ismark = (context.Request.Form["isMark"] ?? "true").Equals("true") ? true : false;
                    startdate = context.Request.Form["startdate"] ?? "";
                    enddate = context.Request.Form["enddate"] ?? "";
                    result = GetRecordTrans(cid, batch, ismark, startdate, enddate);
                    break;
                case "getrecordout":
                    cid = context.Request.Form["cid"] ?? "";
                    batch = context.Request.Form["batch"] ?? "";
                    ismark = (context.Request.Form["isMark"] ?? "true").Equals("true") ? true : false;
                    startdate = context.Request.Form["startdate"] ?? "";
                    enddate = context.Request.Form["enddate"] ?? "";
                    result = GetRecordOut(cid, batch, ismark, startdate, enddate);
                    break;
                case "savebill":
                    string formData = context.Request.Form["formData"] ?? "";
                    result = SaveBill(JsonConvert.DeserializeObject<PostForm>(formData));
                    break;
                case "getmarker":
                    result = GetMaker();
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

    public string GetMaker()
    {
        var list = new List<Result>();
        try
        {
            string sql = string.Format(@"select id,code,name from EAP_User where ActorType=0 and issystem= 0");
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

    /*查询进货单数据*/
    public string GetMaterialInfo(string code = "")
    {
        var list = new List<Result>();
        try
        {
            string sql = string.Format(@"SELECT  t1.id,t1.code,t1.name,specification,isBatch,isQualityPeriod,Expired,ExpiredUnit,
                        t3.Name ExpiredUnitName ,idunit,T2.name unitname
                        FROM dbo.AA_Inventory  T1 JOIN dbo.AA_Unit T2 ON T1.idunit=T2.ID
                        LEFT OUTER JOIN Eap_EnumItem t3 ON t1.ExpiredUnit= t3.id AND t3.idEnum=491") + (string.IsNullOrEmpty(code) ? "" :
            string.Format(@" where t1.code like '%{0}%' or t1.name like '%{0}%'", code));
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


    /*查询进货单数据*/
    public string GetRecordIn(string cid, string batch, bool ismark, string startdate, string enddate)
    {
        var list = new List<Result>();
        try
        {
            DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable
            (string.Format(@"SELECT " + (ismark ? "'未打标'" : "'已打标'") + @"as isMark,T1.ID,T2.id as entryId,T1.code,T1.voucherdate,t3.name Vendor,makerid,maker, t21.name cWhName,
                        t2.idinventory,t4.code cInvCode,t4.name cInvName,t4.specification ,t5.name cUnitName,
                        t2.quantity,t2.batch,t2.ProductionDate,t2.expiryDate,
                        t2.TaxPrice,t2.TaxAmount
                        FROM PU_PurchaseArrival  T1 JOIN PU_PurchaseArrival_b T2 ON T1.ID=T2.idPurchaseArrivalDTO
                        LEFT JOIN dbo.AA_Warehouse t21 ON t2.idwarehouse=t21.id
                        LEFT JOIN dbo.AA_Partner t3 ON t1.idpartner=t3.id
                        LEFT JOIN dbo.AA_Inventory t4 ON t2.idinventory=t4.id
                        LEFT JOIN dbo.AA_Unit T5 ON T4.idunit=T5.ID
                        WHERE ISNULL(t2.pubuserdefnvc1,'') {2} AND t2.idinventory='{0}' {1} {3} {4}", cid,
                        (!string.IsNullOrEmpty(batch) ? " AND t2.batch='" + batch + "'" : ""),
                        ismark ? "<>'是'" : "='是'",
                        !string.IsNullOrEmpty(startdate) ? " AND t1.voucherdate >='" + startdate + " 00:00:00'" : "",
                        !string.IsNullOrEmpty(enddate) ? " AND t1.voucherdate <='" + enddate + " 23:59:59'" : ""));
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

    public string GetRecordTrans(string cid, string batch, bool ismark, string startdate, string enddate)
    {
        var list = new List<Result>();
        try
        {
            DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable
            (string.Format(@"SELECT " + (ismark ? "'未打标'" : "'已打标'") + @"as isMark, T1.ID,T2.id as entryId,T1.code,T1.voucherdate,makerid,maker, 
                            t21.name cOutWhName,t22.name cInWhName,
                            t2.idinventory,t4.code cInvCode,t4.name cInvName,t4.specification ,t5.name cUnitName,
                            t2.quantity,t2.batch,t2.ProductionDate,t2.expiryDate,
                            t2.outPrice,t2.outAmount
                            FROM ST_TransVoucher  T1 JOIN ST_TransVoucher_b T2 ON T1.ID=T2.idTransVoucherDTO
                            LEFT JOIN dbo.AA_Warehouse t21 ON t1.idoutwarehouse=t21.id
                            LEFT JOIN dbo.AA_Warehouse t22 ON t1.idinwarehouse=t22.id
                            LEFT JOIN dbo.AA_Inventory t4 ON t2.idinventory=t4.id
                            LEFT JOIN dbo.AA_Unit T5 ON T4.idunit=T5.ID
                            WHERE ISNULL(t2.pubuserdefnvc1,'') {2} AND t2.idinventory='{0}' {1} {3} {4}", cid,
                            (!string.IsNullOrEmpty(batch) ? " AND t2.batch='" + batch + "'" : ""),
                            ismark ? "<>'是'" : "='是'",
                            !string.IsNullOrEmpty(startdate) ? " AND t1.voucherdate >='" + startdate + " 00:00:00'" : "",
                            !string.IsNullOrEmpty(enddate) ? " AND t1.voucherdate <='" + enddate + " 23:59:59'" : ""));
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

    public string GetRecordOut(string cid, string batch, bool ismark, string startdate, string enddate)
    {
        var list = new List<Result>();
        try
        {
            DataTable dt = ZYSoft.DB.BLL.Common.ExecuteDataTable
            (string.Format(@"SELECT " + (ismark ? "'未打标'" : "'已打标'") + @"as isMark,T1.ID,T2.id as entryId,T1.code,T1.voucherdate,makerid,maker, t21.name cWhName,
                    t2.idinventory,t4.code cInvCode,t4.name cInvName,t4.specification ,t5.name cUnitName,
                    t2.quantity,t2.batch,t2.ProductionDate,t2.expiryDate,
                    t2.Price,t2.Amount
                    FROM ST_RDRecord  T1 JOIN ST_RDRecord_B T2 ON T1.ID=T2.idRDRecordDTO
                    LEFT JOIN dbo.AA_Warehouse t21 ON t2.idwarehouse=t21.id
                    LEFT JOIN dbo.AA_Inventory t4 ON t2.idinventory=t4.id
                    LEFT JOIN dbo.AA_Unit T5 ON T4.idunit=T5.ID
                    WHERE T1.idvouchertype=21 AND ISNULL(t2.pubuserdefnvc1,'') {2} AND t2.idinventory='{0}' {1} {3} {4}", cid,
                    (!string.IsNullOrEmpty(batch) ? " AND t2.batch='" + batch + "'" : ""),
                    ismark ? "<>'是'" : "='是'",
                    !string.IsNullOrEmpty(startdate) ? " AND t1.voucherdate >='" + startdate + " 00:00:00'" : "",
                    !string.IsNullOrEmpty(enddate) ? " AND t1.voucherdate <='" + enddate + " 23:59:59'" : ""));
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

    public bool BeforeSave(PostForm formData, ref string msg)
    {
        /*2021-01-13客户放弃检查*/
        return true;
        /*
         --进货单
SELECT COUNT(1) FRecordNum FROM PU_PurchaseArrival_b WHERE idPurchaseArrivalDTO=1
--调拨单
SELECT COUNT(1) FRecordNum FROM ST_TransVoucher_b  WHERE idTransVoucherDTO=1
--材料出库
SELECT COUNT(1) FRecordNum FROM ST_RDRecord_B T2  WHERE idRDRecordDTO=1
         */

        try
        {
            foreach (BillForm bill in formData.FormId.Form_in)
            {
                string f = bill.Id;
                DataTable _ret = ZYSoft.DB.BLL.Common.ExecuteDataTable(string.Format(@"SELECT t1.code FROM PU_PurchaseArrival t1 left join  PU_PurchaseArrival_b t2 
on t1.ID = t2.idPurchaseArrivalDTO WHERE t2.idPurchaseArrivalDTO='{0}'", f));
                if (_ret != null && !_ret.Rows.Count.Equals(1))
                {
                    msg = string.Format(@"进货单{0}有多行记录,无法打标,请拆单后再打标!", _ret.Rows[0]["code"]);
                    return false;
                }
            };

            foreach (BillForm bill in formData.FormId.Form_out)
            {
                string f = bill.Id;
                DataTable _ret = ZYSoft.DB.BLL.Common.ExecuteDataTable(string.Format(@"SELECT t1.code FROM ST_RDRecord t1 left join  ST_RDRecord_b t2 
on t1.ID = t2.idRDRecordDTO WHERE t2.idRDRecordDTO='{0}'", f));
                if (_ret != null && !_ret.Rows.Count.Equals(1))
                {
                    msg = string.Format(@"材料出库单{0}有多行记录,无法打标,请拆单后再打标!", _ret.Rows[0]["code"]);
                    return false;
                }

            };

            foreach (BillForm bill in formData.FormId.Form_trans)
            {
                string f = bill.Id;
                DataTable _ret = ZYSoft.DB.BLL.Common.ExecuteDataTable(string.Format(@"SELECT t1.code FROM ST_TransVoucher t1 left join  ST_TransVoucher_B t2 
on t1.ID = t2.idTransVoucherDTO WHERE t2.idTransVoucherDTO='{0}'", f));
                if (_ret != null && !_ret.Rows.Count.Equals(1))
                {
                    msg = string.Format(@"调拨单{0}有多行记录,无法打标,请拆单后再打标!", _ret.Rows[0]["code"]);
                    return false;
                }

            };
            return true;

        }
        catch (Exception e)
        {
            msg = "检查单据行数出现异常!异常原因：" + e.Message;
            return false;
        }
    }


    /*保存单据*/
    public string SaveBill(PostForm formData)
    {
        bool isMark = formData.isMark;
        try
        {
            string errMsg = "";
            if (BeforeSave(formData, ref errMsg))
            {
                List<string> ls_sql = new List<string>();

                formData.FormId.Form_in.ForEach(f =>
                {
                    ls_sql.Add(string.Format(@"UPDATE PU_PurchaseArrival  SET makerid= '{0}',maker='{1}' WHERE ID={2}", formData.FMakerId, formData.FMaker, f.Id));
                    ls_sql.Add(string.Format(@"UPDATE PU_PurchaseArrival_B SET pubuserdefnvc1='{1}' WHERE idPurchaseArrivalDTO='{0}' and id='{2}'", f.Id, isMark ? "是" : "否", f.EntryId));
                    ls_sql.Add(string.Format(@"UPDATE ST_RDRecord set makerid='{0}',maker='{1}' where idsourcevouchertype=50 and sourceVoucherId ={2}",
                        formData.FMakerId, formData.FMakerId, f.Id));
                    ls_sql.Add(string.Format(@"UPDATE ST_RDRecord_b SET pubuserdefnvc1='{1}' WHERE idsourcevouchertype=50 and sourceVoucherId={0} and sourceVoucherDetailId ={2}",
                        f.Id, isMark ? "是" : "否", f.EntryId));
                });

                formData.FormId.Form_out.ForEach(f =>
                {
                    ls_sql.Add(string.Format(@"UPDATE ST_RDRecord  SET makerid= '{0}',maker='{1}' WHERE ID={2}", formData.FMakerId, formData.FMaker, f.Id));
                    ls_sql.Add(string.Format(@"UPDATE ST_RDRecord_B SET pubuserdefnvc1='{1}' WHERE idRDRecordDTO='{0}'  and ID ={2}", f.Id, isMark ? "是" : "否", f.EntryId));
                });

                formData.FormId.Form_trans.ForEach(f =>
                {
                    ls_sql.Add(string.Format(@"UPDATE ST_TransVoucher  SET makerid= '{0}',maker='{1}' WHERE ID={2}", formData.FMakerId, formData.FMaker, f.Id));
                    ls_sql.Add(string.Format(@"UPDATE ST_TransVoucher_B SET pubuserdefnvc1='{1}' WHERE idTransVoucherDTO='{0}'  and id='{2}'", f.Id, isMark ? "是" : "否", f.EntryId));
                    ls_sql.Add(string.Format(@"update ST_RDRecord set makerid='{0}',maker='{1}' where idsourcevouchertype=33 and sourceVoucherId ={2}", formData.FMakerId, formData.FMaker, f.Id));
                    ls_sql.Add(string.Format(@"UPDATE ST_RDRecord_b SET pubuserdefnvc1='{1}' WHERE idsourcevouchertype=33 and sourceVoucherId={0} and sourceVoucherDetailId ={2}", f.Id, isMark ? "是" : "否", f.EntryId));
                });




                if (ls_sql.Count > 0)
                {
                    int effectRow = ZYSoft.DB.BLL.Common.ExecuteSQLTran(ls_sql);
                    return JsonConvert.SerializeObject(new
                    {
                        state = effectRow > -1 ? "success" : "error",
                        data = "",
                        msg = effectRow > -1 ? (isMark ? "打标成功" : "解标成功") : (isMark ? "打标失败" : "解标失败")
                    });
                }
                else
                {
                    return JsonConvert.SerializeObject(new
                    {
                        state = "error",
                        data = "",
                        msg = isMark ? "打标失败" : "解标失败"
                    });
                }
            }
            else
            {
                return JsonConvert.SerializeObject(new
                {
                    state = "error",
                    data = "",
                    msg = errMsg
                });
            }
        }
        catch (Exception)
        {
            return JsonConvert.SerializeObject(new
            {
                state = "error",
                data = "",
                msg = (isMark ? "打标" : "解标") + "发生异常!"
            });
        }
    }

    public string LoadXML(string key)
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

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}
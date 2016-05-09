using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using DotNetNuke.Entities.Users;
using DotNetNuke.Entities.Portals;
using DotNetNuke.Security.Membership;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Entities.Modules.Actions;
using DotNetNuke.Entities.Profile;
using DotNetNuke.Security.Profile;
using DotNetNuke.Services.Localization;
using DotNetNuke.Services.Mail;
using DotNetNuke.Security.Membership;
using DotNetNuke.UI.Utilities;
using DotNetNuke.UI.WebControls;
using System.Data.SqlClient;
using System.Data;
using DotNetNuke.Common.Utilities;
using System.Threading;
using System.IO;
using System.Xml;
using rets_dataaccess_lib;
using ba360lib;
using Newtonsoft.Json;
using DotNetNuke.Entities.Tabs;
using DotNetNuke.Security.Permissions;

using DotNetNuke.Entities.Modules.Definitions;
using DotNetNuke.Security.Roles;
using System.Net.NetworkInformation;
using DotNetNuke.Security;
using DotNetNuke.Services.Authentication;
/// <summary>
/// Summary description for test_ws
/// </summary>
//[WebService(Namespace = "http://209.208.66.196")]
[WebService(Namespace = "http://tempuri.org/")]
//[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
[System.Web.Script.Services.ScriptService]
public class test_ws : System.Web.Services.WebService
{
    rets_data_access rda = new rets_data_access();
    string OfficeID = System.Web.Configuration.WebConfigurationManager.AppSettings["OfficeID"];
    string SiteUrl = System.Web.Configuration.WebConfigurationManager.AppSettings["SiteUrl"];
    String MLSTable = System.Web.Configuration.WebConfigurationManager.AppSettings["MLSTable"];
    String PHOTOURL = System.Web.Configuration.WebConfigurationManager.AppSettings["imageurl"];
    String portalname = System.Web.Configuration.WebConfigurationManager.AppSettings["portalname"];

    public test_ws()
    {

        //Uncomment the following line if using designed components 
        //InitializeComponent(); 
    }

    [WebMethod]
    public string HelloWorld(string name)
    {
        return "HelloWorld " + name;
    }


    //update user from backend
    [WebMethod]
    public string updateUser(int portalId, int user_id, string fname, string lname, string phone, string newUserName, string CompanyID)
    {
        string returnString = "";
        string isoptout = string.Empty;
        BA360_lib objba360 = new BA360_lib();
        try
        {
            if (user_id != 0 && user_id != -1)
            {
                UserInfo ObjUser = new UserInfo();

                ObjUser = DotNetNuke.Entities.Users.UserController.GetUserById(portalId, user_id);
                if (ObjUser != null)
                {


                    if (fname != string.Empty)
                    {
                        ObjUser.FirstName = fname;
                    }

                    if (lname != string.Empty)
                    {
                        ObjUser.LastName = lname;
                    }

                    if (phone != string.Empty)
                    {
                        ObjUser.Profile.Cell = phone;
                    }
                    DotNetNuke.Entities.Users.UserController.UpdateUser(portalId, ObjUser);
                    DotNetNuke.Common.Utilities.DataCache.ClearHostCache(true);
                    if (newUserName != string.Empty)
                    {

                        if (UpdateUserName(ObjUser.Username, newUserName) == "Uname Updated")
                        {
                            ObjUser = DotNetNuke.Entities.Users.UserController.GetUserById(portalId, user_id);
                            ObjUser.Email = newUserName;
                            DotNetNuke.Entities.Users.UserController.UpdateUser(portalId, ObjUser);
                            isoptout = objba360.set_OptOut(user_id, 0, portalname, false);
                            returnString = SendMail(ObjUser, CompanyID);
                        }
                        else
                        {
                            ObjUser = DotNetNuke.Entities.Users.UserController.GetUserById(portalId, user_id);
                            DotNetNuke.Entities.Users.UserController.UpdateUser(portalId, ObjUser);
                            returnString = "user updated";
                        }
                    }

                    DotNetNuke.Common.Utilities.DataCache.ClearHostCache(true);
                    if (returnString == "Email Sent" && isoptout == "true")
                        returnString = Convert.ToString(user_id);

                }
                else
                {
                    DotNetNuke.Common.Utilities.DataCache.ClearHostCache(true);
                    returnString = "user not found.";
                }
            }
            else
            {
                returnString = "userID Parameter is null or empty.";
            }

        }
        catch (Exception ex)
        {
            returnString = ex.ToString();
        }
        return returnString;

    }

    public string UpdateUserName(string oldUserName, string newUserName)
    {
        string result = string.Empty;
        UserInfo userInfo = new UserInfo();
        try
        {
            if (oldUserName != string.Empty && newUserName != string.Empty && oldUserName != newUserName)
            {
                //UpdateUserName

                IDataReader dr = DotNetNuke.Data.DataProvider.Instance().ExecuteReader("prc_UpdateUserName", oldUserName, newUserName);
                while (dr.Read())
                {
                    if (Convert.ToInt16(dr["result"]) == 1)
                    {
                        result = "Uname Updated";
                    }
                }

            }
        }
        catch (Exception ex)
        {
            return ex.ToString();
        }

        return result;
    }

    public string SendMail(UserInfo userInfo, string CompanyID)
    {

        BA360_lib objba360 = new BA360_lib();
        LeadInfo lead_info = new LeadInfo();
        string resultSentmail = string.Empty;
        try
        {
            if (userInfo != null)
            {
                lead_info.DnnLeadID = userInfo.UserID.ToString();
                lead_info.CompanyID = CompanyID;
                lead_info.FirstName = userInfo.FirstName;
                lead_info.LastName = userInfo.LastName;
                lead_info.EmailID = userInfo.Email;

                System.Web.Security.MembershipUser objUser = System.Web.Security.Membership.GetUser(userInfo.Username);

                lead_info.DnnPassword = objUser.GetPassword();

                objba360.SendEmail(lead_info, userInfo);
                resultSentmail = "Email Sent";
            }
        }
        catch (Exception ex)
        {
            resultSentmail = ex.ToString();
        }
        return resultSentmail;

    }


    #region Old_3_8_14_updateUser
    //[WebMethod]
    //public string updateUser(int portalId, int user_id, string fname, string lname, string phone)
    //{
    //    string returnString = "";
    //    try
    //    {
    //        if (user_id != null && user_id != -1)
    //        {
    //            UserInfo ObjUser = new UserInfo();

    //            ObjUser = DotNetNuke.Entities.Users.UserController.GetUserById(portalId, user_id);
    //            ObjUser.FirstName = fname;
    //            ObjUser.LastName = lname;
    //            ObjUser.Profile.Cell = phone;
    //            DotNetNuke.Entities.Users.UserController.UpdateUser(portalId, ObjUser);

    //            returnString = "user updated";
    //        }
    //        else
    //        {
    //            returnString = "user updation error";
    //        }

    //    }
    //    catch (Exception ex)
    //    {

    //    }
    //    return returnString;

    //}
    #endregion


    [WebMethod]
    public string CreateUser(string user_id, string user_name, string fname, string lname, string email_id, string password, string role, string portal_ID, string MyAlias)//,string lname,string email_id,string password,string role
    {
        string returnString = "";
        try
        {
            int current_portal_id = Convert.ToInt32(portal_ID);

            UserInfo oUser = new UserInfo();

            oUser.PortalID = current_portal_id;//DotNetNuke.Entities.Portals.PortalController.GetCurrentPortalSettings().PortalId;

            oUser.IsSuperUser = false;

            oUser.FirstName = fname;

            oUser.LastName = lname;

            oUser.Email = email_id;

            oUser.Username = user_name;

            oUser.DisplayName = user_name;



            //Fill MINIMUM Profile Items (KEY PIECE)

            // oUser.Profile.PreferredLocale = PortalSettings.DefaultLanguage;

            //oUser.Profile.TimeZone = PortalSettings.TimeZoneOffset;

            oUser.Profile.FirstName = oUser.FirstName;

            oUser.Profile.LastName = oUser.LastName;



            //Set Membership

            UserMembership oNewMembership = new UserMembership();

            oNewMembership.Approved = true;

            oNewMembership.CreatedDate = System.DateTime.Now;

            oNewMembership.Email = oUser.Email;

            // oNewMembership.IsOnLine = false;

            oNewMembership.Username = oUser.Username;

            if (role.Equals("Agent"))
                oNewMembership.Password = password;
            if (role.Equals("Lead"))
                //oNewMembership.Password = GenerateCoupon(7);
                oNewMembership.Password = password;


            //Bind membership to user

            oUser.Membership = oNewMembership;



            //Add the user, ensure it was successful

            DotNetNuke.Security.Membership.UserCreateStatus resultVal = UserController.CreateUser(ref oUser);

            if (UserCreateStatus.Success == resultVal)
            {

                //returnString = "user created";
                if (role.Equals("Agent"))
                {
                    DataSet Ds = DotNetNuke.Data.DataProvider.Instance().ExecuteDataSet("prc_mappUserId", oUser.UserID.ToString(), user_id, oUser.Username.ToString());
                }
                DotNetNuke.Security.Roles.RoleController rc = new DotNetNuke.Security.Roles.RoleController();
                //retrieve role
                string groupName = role;
                DotNetNuke.Security.Roles.RoleInfo ri = rc.GetRoleByName(current_portal_id, groupName);
                //suppose your userinfo object is ui
                DotNetNuke.Entities.Users.UserInfo ui = DotNetNuke.Entities.Users.UserController.GetCurrentUserInfo();
                DateTime d = Null.NullDate;
                rc.AddUserRole(current_portal_id, Convert.ToInt32(oUser.UserID.ToString()), ri.RoleID, d);
                if (role.Equals("Agent"))
                {
                    DataSet Ds1 = DotNetNuke.Data.DataProvider.Instance().ExecuteDataSet("AddCustomAlias", oUser.PortalID, MyAlias, oUser.UserID.ToString());
                }
                if (role.Equals("Lead"))
                {
                    createleadXML(current_portal_id, portalname, oUser.UserID.ToString());
                }
                returnString = oUser.UserID.ToString();
                DotNetNuke.Common.Utilities.DataCache.ClearHostCache(true);
                if (role.Equals("Agent"))
                {
                    createAgentPage(user_id, oUser.Username.ToString(), current_portal_id);
                }
            }
            else
            {
                returnString = "Error" + resultVal;
            }
        }
        catch (Exception ex)
        {
        }
        return returnString;
    }

    #region Create Backend Agent Pages

    string F_Name = string.Empty, L_name = string.Empty, A_Email = string.Empty, A_City = string.Empty, A_Description = string.Empty, A_State = string.Empty, A_Title = string.Empty, A_UserName = string.Empty;
    string logfilepath = Path.Combine(HttpRuntime.AppDomainAppPath, "Portals/ExitRL/MLS_Medias/lead_activity_xml/Shedulers_log_Files/AgentBlog.txt");

    public void createAgentPage(string user_id, string Username, int portalId)
    {
        try
        {

            //string F_Name = string.Empty, L_name = string.Empty, A_Email = string.Empty, A_City = string.Empty, A_Description = string.Empty, A_State = string.Empty, A_Title = string.Empty, A_UserName = string.Empty;
            string CompanyID = System.Web.Configuration.WebConfigurationManager.AppSettings["companyID"];
            BA360_lib BA_obj = new BA360_lib();
            AgentInfo agentInfo = new AgentInfo();
            DataTable agent_dt = new DataTable();

            //agentInfo.ShowOnSite = "Active";
            agentInfo.CompanyID = CompanyID;
            agentInfo.RoleType = "2";

            agentInfo.AgentID = user_id;
            System.IO.File.AppendAllText(logfilepath, Environment.NewLine + "Agent UUser ID :" + user_id + " Agent UUser ID :" + CompanyID);
            agent_dt = BA_obj.get_agent_info(agentInfo);
            System.IO.File.AppendAllText(logfilepath, Environment.NewLine + "Agent dt Called :" + agent_dt.Rows.Count);
            if (agent_dt.Rows.Count > 0)
            {
                A_Description = string.Empty;
                F_Name = string.Empty; L_name = string.Empty; A_Email = string.Empty; A_City = string.Empty; A_State = string.Empty; A_Title = string.Empty; A_UserName = string.Empty;
                F_Name = agent_dt.Rows[0]["first_name"].ToString();
                L_name = agent_dt.Rows[0]["last_name"].ToString();
                A_Email = agent_dt.Rows[0]["email1"].ToString();
                A_City = agent_dt.Rows[0]["address_city"].ToString();
                A_State = agent_dt.Rows[0]["address_state"].ToString();
                A_Title = agent_dt.Rows[0]["title"].ToString();
                A_UserName = agent_dt.Rows[0]["user_name"].ToString();
                A_Description = agent_dt.Rows[0]["description"].ToString();




                string Page_Name = F_Name + L_name;
                TabController tabController = new TabController();

                TabInfo parent = tabController.GetTabByName("Agents", portalId);


                if (!CheckPageExists(Page_Name, parent, tabController, portalId))
                {
                    try
                    {
                        bool result = createAgentPage(Page_Name, parent, tabController, portalId);
                        if (result)
                        {
                            System.IO.File.AppendAllText(logfilepath, Environment.NewLine + "Backend Page Created :" + Page_Name);

                        }
                    }
                    catch (Exception ex)
                    {
                        System.IO.File.AppendAllText(logfilepath, Environment.NewLine + "Backend Page Not Created :" + Page_Name);
                    }
                }
            }

        }
        catch (Exception ee)
        {
            System.IO.File.AppendAllText(logfilepath, Environment.NewLine + "Exception occured :" + ee.ToString());
        }

    }



    private bool createAgentPage(string Page_Name, TabInfo parent, TabController tabController, int portalID)
    {
        string CompanyName = System.Web.Configuration.WebConfigurationManager.AppSettings["companyname"];


        DotNetNuke.Security.Roles.RoleController rc = new DotNetNuke.Security.Roles.RoleController();

        DotNetNuke.Security.Roles.RoleInfo roleLead = rc.GetRoleByName(portalID, "Lead");
        int LeadRoleID = roleLead.RoleID;
        DotNetNuke.Security.Roles.RoleInfo role = rc.GetRoleByName(portalID, "Unverified Users");
        int UnverifiedRoleID = role.RoleID;
        DotNetNuke.Security.Roles.RoleInfo Administratorrole = rc.GetRoleByName(portalID, "Administrators");
        int AdminRoleID = role.RoleID;

        PermissionController pc = new PermissionController();
        PermissionInfo objViewPermission = (PermissionInfo)pc.GetPermissionByCodeAndKey("SYSTEM_MODULE_DEFINITION", "VIEW")[0];
        PermissionInfo objEditPermission = (PermissionInfo)pc.GetPermissionByCodeAndKey("SYSTEM_MODULE_DEFINITION", "EDIT")[0];

        //System.IO.File.AppendAllText(logfilepath, Environment.NewLine + "RoleLead:" + LeadRoleID);
        //System.IO.File.AppendAllText(logfilepath, Environment.NewLine + "UnverifiedRoleID:" + UnverifiedRoleID);
        //System.IO.File.AppendAllText(logfilepath, Environment.NewLine + "View Permission:" + objViewPermission.PermissionID);
        //System.IO.File.AppendAllText(logfilepath, Environment.NewLine + "Edit Permission:" + objEditPermission.PermissionID);



        DataSet dset = new DataSet();
        int PageID = 0;
        string defaultPortalSkin = PortalSettings.Current.DefaultPortalSkin;
        string defaultPortalContainer = PortalSettings.Current.DefaultPortalContainer;

        UserInfo UserInfoAgent = UserController.GetUserByName(PortalController.GetCurrentPortalSettings().PortalId, A_UserName);



        TabInfo tab = new TabInfo();
        //tab.CultureCode = PageID.ToString();
        tab.PortalID = portalID;
        tab.TabName = Page_Name;
        tab.Title = F_Name + " " + L_name + " - " + CompanyName + " | Real Estate " + A_Title + " in " + A_City + "," + A_State;
        //tab.DefaultLanguageGuid = page_Category;
        tab.Description = Page_Name;
        tab.KeyWords = Page_Name;
        tab.IsVisible = true;
        tab.DisableLink = false;
        tab.ParentId = parent.TabID;
        tab.IsDeleted = false;
        tab.SkinSrc = "[G]Skins/BANewTemplate/MapFull.ascx";
        tab.ContainerSrc = "/Portals/_default/Containers/BATemplateContainers/NoTitle.ascx";
        tab.IsSuperTab = false;
        //tab.CreatedByUserID = UserInfoAgent.UserID;

        //Add permission to the page so that all users can view it
        foreach (PermissionInfo p in PermissionController.GetPermissionsByTab())
        {
            if (p.PermissionKey == "VIEW")
            {
                TabPermissionInfo tpi = new TabPermissionInfo();
                tpi.PermissionID = p.PermissionID;
                tpi.PermissionKey = p.PermissionKey;
                tpi.PermissionName = p.PermissionName;
                tpi.AllowAccess = true;
                tpi.RoleID = -1; //ID of all users
                tab.TabPermissions.Add(tpi);
            }
            if (p.PermissionKey == "EDIT")
            {
                TabPermissionInfo tpi = new TabPermissionInfo();
                tpi.PermissionID = p.PermissionID;
                tpi.PermissionKey = p.PermissionKey;
                tpi.PermissionName = p.PermissionName;
                tpi.AllowAccess = true;
                tpi.RoleID = AdminRoleID; //ID of Administrator
                tab.TabPermissions.Add(tpi);
            }
        }


        int tabId = tabController.AddTab(tab, true);
        DotNetNuke.Common.Utilities.DataCache.ClearModuleCache(tab.TabID);




        #region _Agent_Info
        DesktopModuleController objDMC = new DesktopModuleController();
        DesktopModuleInfo desktopModuleInfo = null;
        try
        {
            foreach (KeyValuePair<int, DesktopModuleInfo> kvp in DesktopModuleController.GetDesktopModules(portalID))
            {
                DesktopModuleInfo mod = kvp.Value;
                if (mod != null)
                    if (mod.FriendlyName.IndexOf("_Agent_Info") > -1 || mod.ModuleName.IndexOf("_Agent_Info") > -1)
                    {
                        desktopModuleInfo = mod;
                        break;
                    }
            }

            //_Quick_Search

            foreach (ModuleDefinitionInfo moduleDefinitionInfo in ModuleDefinitionController.GetModuleDefinitionsByDesktopModuleID(desktopModuleInfo.DesktopModuleID).Values)
            {


                RoleInfo ri = new RoleInfo();
                // PortalSettings.RegisteredRoleId

                ModuleInfo moduleInfo = new ModuleInfo();
                moduleInfo.PortalID = portalID;
                moduleInfo.TabID = tabId;
                moduleInfo.ModuleOrder = 1;
                moduleInfo.ModuleTitle = "";
                moduleInfo.PaneName = "ContentLeftPane";
                moduleInfo.ContainerSrc = "/Portals/_default/Containers/BATemplateContainers/NoTitle.ascx";


                moduleInfo.ModuleDefID = moduleDefinitionInfo.ModuleDefID;
                moduleInfo.CacheTime = moduleDefinitionInfo.DefaultCacheTime;//Default Cache Time is 0
                moduleInfo.InheritViewPermissions = true;//Inherit View Permissions from Tab
                moduleInfo.AllTabs = false;
                moduleInfo.Alignment = "Top";


                ModuleController moduleController = new ModuleController();
                int moduleId = moduleController.AddModule(moduleInfo);

                //Set Module Permission
                ModulePermissionController objMPC = new ModulePermissionController();
                ModulePermissionInfo mpi3 = new ModulePermissionInfo();
                mpi3.ModuleID = moduleId;
                mpi3.PermissionID = 1;//View Permission
                mpi3.AllowAccess = true;
                mpi3.RoleID = -1;//Role ID of Specified User
                objMPC.AddModulePermission(mpi3);
            }
        }
        catch (Exception ee)
        {
            System.IO.File.AppendAllText(logfilepath, Environment.NewLine + "_Agent_Info Module :" + ee.ToString());
            //Pageresult += "_Agent_Info Module" + ee.ToString();
            //txt_log.InnerText = Pageresult;
        }
        #endregion

        #region _Ask_An_Expert
        DesktopModuleInfo desktopModuleInfo_AAE = null;
        try
        {
            foreach (KeyValuePair<int, DesktopModuleInfo> kvp in DesktopModuleController.GetDesktopModules(portalID))
            {
                DesktopModuleInfo mod = kvp.Value;
                if (mod != null)
                    if (mod.FriendlyName.IndexOf("_Ask_An_Expert") > -1 || mod.ModuleName.IndexOf("_Ask_An_Expert") > -1)
                    {
                        desktopModuleInfo_AAE = mod;
                        break;
                    }
            }


            foreach (ModuleDefinitionInfo moduleDefinitionInfo in ModuleDefinitionController.GetModuleDefinitionsByDesktopModuleID(desktopModuleInfo_AAE.DesktopModuleID).Values)
            {
                ModuleInfo moduleInfo = new ModuleInfo();
                moduleInfo.PortalID = portalID;
                moduleInfo.TabID = tabId;
                moduleInfo.ModuleOrder = 1;
                moduleInfo.ModuleTitle = "";
                moduleInfo.PaneName = "ContentLeftPane";
                moduleInfo.ContainerSrc = "/Portals/_default/Containers/BATemplateContainers/NoTitle.ascx";


                moduleInfo.ModuleDefID = moduleDefinitionInfo.ModuleDefID;
                moduleInfo.CacheTime = moduleDefinitionInfo.DefaultCacheTime;//Default Cache Time is 0
                moduleInfo.InheritViewPermissions = false;//Inherit View Permissions from Tab
                moduleInfo.AllTabs = false;
                moduleInfo.Alignment = "Bottom";

                ModuleController moduleController = new ModuleController();
                int moduleId = moduleController.AddModule(moduleInfo);

                //Set Module Permission

                ModulePermissionController objMPC = new ModulePermissionController();


                ModulePermissionInfo mpiAAE = new ModulePermissionInfo();
                mpiAAE.ModuleID = moduleId;
                mpiAAE.PermissionID = objViewPermission.PermissionID;//View Permission
                mpiAAE.AllowAccess = true;
                mpiAAE.RoleID = LeadRoleID;//Role ID of Specified User (Change to Lead ID)
                objMPC.AddModulePermission(mpiAAE);

                ModulePermissionInfo mpiAAEView = new ModulePermissionInfo();
                mpiAAEView.ModuleID = moduleId;
                mpiAAEView.PermissionID = objEditPermission.PermissionID;//View Permission
                mpiAAEView.AllowAccess = true;
                mpiAAEView.RoleID = AdminRoleID;//Role ID of Specified User (Change to Lead ID)
                objMPC.AddModulePermission(mpiAAEView);

            }
        }
        catch (Exception ee)
        {
            System.IO.File.AppendAllText(logfilepath, Environment.NewLine + "_Ask_An_Expert Module :" + ee.ToString());
            //Pageresult += "_Ask_An_Expert Module" + ee.ToString();
            //txt_log.InnerText = Pageresult;
        }
        #endregion

        #region _LeadCreation
        DesktopModuleInfo desktopModuleInfo_LC = null;
        try
        {
            foreach (KeyValuePair<int, DesktopModuleInfo> kvp in DesktopModuleController.GetDesktopModules(portalID))
            {
                DesktopModuleInfo mod = kvp.Value;
                if (mod != null)
                    if (mod.FriendlyName.IndexOf("_LeadCreation") > -1 || mod.ModuleName.IndexOf("_LeadCreation") > -1)
                    {
                        desktopModuleInfo_LC = mod;
                        break;
                    }
            }


            foreach (ModuleDefinitionInfo moduleDefinitionInfo in ModuleDefinitionController.GetModuleDefinitionsByDesktopModuleID(desktopModuleInfo_LC.DesktopModuleID).Values)
            {
                ModuleInfo moduleInfo = new ModuleInfo();
                moduleInfo.PortalID = portalID;
                moduleInfo.TabID = tabId;
                moduleInfo.ModuleOrder = 1;
                moduleInfo.ModuleTitle = "";
                moduleInfo.PaneName = "RightPane";
                moduleInfo.ContainerSrc = "/Portals/_default/Containers/BATemplateContainers/NoTitle.ascx";


                moduleInfo.ModuleDefID = moduleDefinitionInfo.ModuleDefID;
                moduleInfo.CacheTime = moduleDefinitionInfo.DefaultCacheTime;//Default Cache Time is 0
                moduleInfo.InheritViewPermissions = true;//Inherit View Permissions from Tab
                moduleInfo.AllTabs = false;
                moduleInfo.Alignment = "Top";

                ModuleController moduleController = new ModuleController();
                int moduleId = moduleController.AddModule(moduleInfo);

                //Set Module Permission
                ModulePermissionController objMPC = new ModulePermissionController();
                ModulePermissionInfo mpiLC = new ModulePermissionInfo();

                mpiLC.ModuleID = moduleId;
                mpiLC.PermissionID = objViewPermission.PermissionID;//View Permission
                mpiLC.AllowAccess = true;
                mpiLC.RoleID = UnverifiedRoleID;//Role ID of Specified User (Change to ID UnAuthenticated User)
                objMPC.AddModulePermission(mpiLC);

                ModulePermissionInfo mpiAAEView = new ModulePermissionInfo();
                mpiAAEView.ModuleID = moduleId;
                mpiAAEView.PermissionID = objEditPermission.PermissionID;//View Permission
                mpiAAEView.AllowAccess = true;
                mpiAAEView.RoleID = AdminRoleID;//Role ID of Specified User (Change to Lead ID)
                objMPC.AddModulePermission(mpiAAEView);
            }
        }
        catch (Exception ee)
        {
            System.IO.File.AppendAllText(logfilepath, Environment.NewLine + "_LeadCreation Module :" + ee.ToString());
            //Pageresult += "_LeadCreation Module" + ee.ToString();
            //txt_log.InnerText = Pageresult;
        }
        #endregion

        #region _Facebook_Comment_Detail
        DesktopModuleInfo desktopModuleInfo_FCD = null;
        try
        {

            foreach (KeyValuePair<int, DesktopModuleInfo> kvp in DesktopModuleController.GetDesktopModules(portalID))
            {
                DesktopModuleInfo mod = kvp.Value;
                if (mod != null)
                    if (mod.FriendlyName.IndexOf("_Facebook_Comment_Detail") > -1 || mod.ModuleName.IndexOf("_Facebook_Comment_Detail") > -1)
                    {
                        desktopModuleInfo_FCD = mod;
                        break;
                    }
            }


            foreach (ModuleDefinitionInfo moduleDefinitionInfo in ModuleDefinitionController.GetModuleDefinitionsByDesktopModuleID(desktopModuleInfo_FCD.DesktopModuleID).Values)
            {
                ModuleInfo moduleInfo = new ModuleInfo();
                moduleInfo.PortalID = portalID;
                moduleInfo.TabID = tabId;
                moduleInfo.ModuleOrder = 1;
                moduleInfo.ModuleTitle = "";
                moduleInfo.PaneName = "RightPane";
                moduleInfo.ContainerSrc = "/Portals/_default/Containers/BATemplateContainers/NoTitle.ascx";


                moduleInfo.ModuleDefID = moduleDefinitionInfo.ModuleDefID;
                moduleInfo.CacheTime = moduleDefinitionInfo.DefaultCacheTime;//Default Cache Time is 0
                moduleInfo.InheritViewPermissions = true;//Inherit View Permissions from Tab
                moduleInfo.AllTabs = false;
                moduleInfo.Alignment = "Bottom";

                ModuleController moduleController = new ModuleController();
                int moduleId = moduleController.AddModule(moduleInfo);

                //Set Module Permission
                ModulePermissionController objMPC = new ModulePermissionController();
                ModulePermissionInfo mpiFCD = new ModulePermissionInfo();
                mpiFCD.ModuleID = moduleId;
                mpiFCD.PermissionID = 1;//View Permission
                mpiFCD.AllowAccess = true;
                mpiFCD.RoleID = -1;//Role ID of Specified User (Keep Same)
                objMPC.AddModulePermission(mpiFCD);

                ModulePermissionInfo mpiAAEView = new ModulePermissionInfo();
                mpiAAEView.ModuleID = moduleId;
                mpiAAEView.PermissionID = objEditPermission.PermissionID;//View Permission
                mpiAAEView.AllowAccess = true;
                mpiAAEView.RoleID = AdminRoleID;//Role ID of Specified User (Change to Lead ID)
                objMPC.AddModulePermission(mpiAAEView);
            }
        }
        catch (Exception ee)
        {
            System.IO.File.AppendAllText(logfilepath, Environment.NewLine + "_Facebook_Comment_Detail Module :" + ee.ToString());
            //Pageresult += "_Facebook_Comment_Detail Module" + ee.ToString();
            //txt_log.InnerText = Pageresult;
        }
        #endregion

        #region _AgentProfileContent
        DesktopModuleInfo desktopModuleInfo_APC = null;
        try
        {

            foreach (KeyValuePair<int, DesktopModuleInfo> kvp in DesktopModuleController.GetDesktopModules(portalID))
            {
                DesktopModuleInfo mod = kvp.Value;
                if (mod != null)
                    if (mod.FriendlyName.IndexOf("_AgentProfileContent") > -1 || mod.ModuleName.IndexOf("_AgentProfileContent") > -1)
                    {
                        desktopModuleInfo_APC = mod;
                        break;
                    }
            }


            foreach (ModuleDefinitionInfo moduleDefinitionInfo in ModuleDefinitionController.GetModuleDefinitionsByDesktopModuleID(desktopModuleInfo_APC.DesktopModuleID).Values)
            {
                ModuleInfo moduleInfo = new ModuleInfo();
                moduleInfo.PortalID = portalID;
                moduleInfo.TabID = tabId;
                moduleInfo.ModuleOrder = 1;
                moduleInfo.ModuleTitle = "";
                moduleInfo.PaneName = "ContentPane";
                moduleInfo.ContainerSrc = "/Portals/_default/Containers/BATemplateContainers/NoTitle.ascx";


                moduleInfo.ModuleDefID = moduleDefinitionInfo.ModuleDefID;
                moduleInfo.CacheTime = moduleDefinitionInfo.DefaultCacheTime;//Default Cache Time is 0
                moduleInfo.InheritViewPermissions = true;//Inherit View Permissions from Tab
                moduleInfo.AllTabs = false;
                moduleInfo.Alignment = "Bottom";

                ModuleController moduleController = new ModuleController();
                int moduleId = moduleController.AddModule(moduleInfo);

                //Set Module Permission
                ModulePermissionController objMPC = new ModulePermissionController();
                ModulePermissionInfo mpiAPC = new ModulePermissionInfo();
                mpiAPC.ModuleID = moduleId;
                mpiAPC.PermissionID = 1;//View Permission
                mpiAPC.AllowAccess = true;
                mpiAPC.RoleID = -1;//Role ID of Specified User (Keep Same)
                objMPC.AddModulePermission(mpiAPC);

                ModulePermissionInfo mpiAAEView = new ModulePermissionInfo();
                mpiAAEView.ModuleID = moduleId;
                mpiAAEView.PermissionID = objEditPermission.PermissionID;//View Permission
                mpiAAEView.AllowAccess = true;
                mpiAAEView.RoleID = AdminRoleID;//Role ID of Specified User (Change to Lead ID)
                objMPC.AddModulePermission(mpiAAEView);
            }
        }
        catch (Exception ee)
        {
            System.IO.File.AppendAllText(logfilepath, Environment.NewLine + "_AgentProfileContent Module :" + ee.ToString());
            //Pageresult += "_AgentProfileContent Module" + ee.ToString();
            //txt_log.InnerText = Pageresult;
        }
        #endregion


        string query = "update [dbo].[Tabs] set [CreatedByUserID]=" + UserInfoAgent.UserID + " where TabID=" + tabId;
        //                            + PageID + "," + tabId + ",'" + A_UserName + "','" + Page_Name + "')";
        DotNetNuke.Data.DataProvider.Instance().ExecuteNonQuery("prc_property_search", query);
        DotNetNuke.Common.Utilities.DataCache.ClearCache();
        return true;
    }


    private bool CheckPageExists(string Page_Name, TabInfo parent, TabController tabController, int portalId)
    {


        TabInfo parentTab = tabController.GetTabByName(Page_Name, portalId);

        if (parentTab != null)
        {
            int parenttabID = parent.TabID;
            if (parenttabID == parentTab.ParentId)
            {
                return true;
            }
            else
                return false;

        }
        else
        {
            return false;
        }
    }
    #endregion Create Backend Agent Pages
    
    //Not Used 
    [WebMethod]
    public DataTable get_agent_properties(string agent_short_id, string office_short)
    {

        string query = "SELECT * FROM All_Properties where list_5=(select MEMBER_0  FROM Rets_Agents where OFFICESHORT='" + office_short + "' and MEMBER_17='" + agent_short_id + "')";
        //string query="select * from All_Properties where LIST_5="+agent_id;

        DataSet Ds1 = DotNetNuke.Data.DataProvider.Instance().ExecuteDataSet("prc_property_search", query);
        if (Ds1.Tables[0].Rows.Count > 0)
        {

            for (int i = 0; i < Ds1.Tables[0].Rows.Count; i++)
            {
                Ds1.Tables[0].Rows[i]["LIST_78"] = Ds1.Tables[0].Rows[i]["LIST_78"].ToString().Replace("'", "&#39;");
                Ds1.Tables[0].Rows[i]["LIST_82"] = Ds1.Tables[0].Rows[i]["LIST_82"].ToString().Replace("'", "&#39;");

            }


            return Ds1.Tables[0];
        }
        return null;

    }
    [WebMethod]
    public DataTable get_agent_properties_new(string agent_short_id, string office_short_id, string exclude_agent_short_id, string exclude_office_short_id)
    {
        string[] str_agent;
        string[] str_office;
        string[] str_ex_agent;
        string[] str_ex_office;
        string agent_mls_list = "''", office_mls_list = "''", ex_agent_mls_list = "''", ex_office_mls_list = "''";

        if (!agent_short_id.Equals(""))
        {
            str_agent = agent_short_id.Split(',');

            for (int i = 0; i < str_agent.Length; i++)
            {
                if (i == 0)
                    agent_mls_list += "'" + str_agent[i] + "'";
                else
                    agent_mls_list += ",'" + str_agent[i] + "'";
            }
        }

        if (!office_short_id.Equals(""))
        {
            str_office = office_short_id.Split(',');
            for (int i = 0; i < str_office.Length; i++)
            {
                if (i == 0)
                    office_mls_list += "'" + str_office[i] + "'";
                else
                    office_mls_list += ",'" + str_office[i] + "'";
            }
        }



        if (!exclude_agent_short_id.Equals(""))
        {
            str_ex_agent = exclude_agent_short_id.Split(',');
            for (int i = 0; i < str_ex_agent.Length; i++)
            {
                if (i == 0)
                    ex_agent_mls_list += "'" + str_ex_agent[i] + "'";
                else
                    ex_agent_mls_list += ",'" + str_ex_agent[i] + "'";
            }
        }

        if (!exclude_office_short_id.Equals(""))
        {
            str_ex_office = exclude_office_short_id.Split(',');
            for (int i = 0; i < str_ex_office.Length; i++)
            {
                if (i == 0)
                    ex_office_mls_list += "'" + str_ex_office[i] + "'";
                else
                    ex_office_mls_list += ",'" + str_ex_office[i] + "'";
            }
        }




        /* string query = "SELECT TOP 100 [AgentListFullName] as c_member_name ,[17] as c_member_short_id , [17] as c_agent_id,";
         query += "[138] as c_office_id,";
         query += "CASE WHEN [1] = 'Residential' and [PropertyStyle] like '%single family%' THEN 'Single Family Home'";
         query += " WHEN [1] = 'Residential' and [PropertyStyle] like '%Condo%' THEN 'Condo'";
         query += " WHEN [1] = 'Residential' and [PropertyStyle] like '%villa%' THEN 'TownHouse/Villa'";
         query += " WHEN [1] = 'Residential' and [PropertyStyle] like '%Townhouse%' THEN 'TownHouse/Villa'";

         query += " WHEN [1] = 'Income' THEN [1]";
         query += "WHEN [1] = 'Rental' THEN [1]";
         query += "WHEN [1] = 'Vacant-Land' THEN [1]";
         query += "WHEN  [1] = 'Commercial' THEN [1]";
         //query += "  ELSE [1] ";
         query += " end as c_p_type";
         query += ",CASE WHEN [1] = 'Residential' then [CurrentPrice] ";
         query += " WHEN [1] = 'Income' then [CurrentPrice] ";
         query += " WHEN [1] = 'Rental' then [CurrentPrice] ";
         query += " WHEN [1] = 'Vacant-Land' then [CurrentPrice] ";
         query += " WHEN [1] = 'Commercial' then [CurrentPrice] ";
         query += " end as c_listing_price,[SqFtTotal] as c_listing_area, ";
         query += "[City] as c_city,MlsNum as c_listing_id,[TotalBedrooms] as c_bedroom,[2622] as c_living_room_size , ";
         query += "[Remarks] as c_public_remark,[StreetName] as c_street_name,[State] as c_state,[StreetDirection] as c_direction,[StreetNumber] as c_street_number, ";
         query += "[ZipCode] as c_zipcode,'bestorlandohousesearch.com' as domain_name,[MlsNum] as PostalCode FROM All_Properties_orlando where ([17] in (" + agent_mls_list + ") or ";
         query += "[ListOfficeMLSID] in (" + office_mls_list + ",'56533')) and ";
         query += "([17] not in (" + ex_agent_mls_list + ") and [ListOfficeMLSID] not in (" + ex_office_mls_list + ")) and [PropertyStyle] not like '%1/2%' and [City] not like '%tampa%'";*/

        string query = "SELECT top 100 [AgentListFullName] as c_member_name ,[AgentID] as c_member_short_id , [AgentID] as c_agent_id,";
        query += "[OfficeCoListCode] as c_office_id,";
        query += "CASE WHEN [PropertyType] like '%single family%' or [LandPropertyType] like '%single family%' THEN 'Single Family Home'";
        query += " WHEN [PropertyType] like '%condo%' THEN 'Condos'";
        query += " WHEN [PropertyType] like '%Townhouse%' THEN 'Townhouses'";
        query += " WHEN [PropertyType] like '%Multi-Family%' or [LandPropertyType] like '%Multi Family%'";
        query += " WHEN [LandPropertyType] like '%Commercial%' THEN 'Commercial'";
        query += " WHEN [PropertyType] like '%Vacant Land%' THEN 'Land'";
        query += " WHEN [PropertyType] like '%Rental%' THEN 'Rental'";
        query += " WHEN [PropertyType] like '%Commercial for Lease%' THEN 'Commercial for Lease'";

       // query += " WHEN [PropertyType] = 'INC' THEN 'Income'";
       // query += " WHEN [PropertyType] = 'REN' THEN 'Rental'";
      //  query += " WHEN [PropertyType] = 'VAC' THEN 'Vacant-Land and Lots'";
      //  query += " WHEN  [PropertyType] = 'COM' THEN 'Commercial'";
        //query += "  ELSE [PropertyType] ";
        query += " end as c_p_type, ";
        query += "CASE WHEN [PropertyType] = 'RES' then [CurrentPrice] ";  
        query += " WHEN [PropertyType] = 'INC' then [CurrentPrice] ";
        query += " WHEN [PropertyType] = 'REN' then [CurrentPrice] ";
        query += " WHEN [PropertyType] = 'VAC' then [CurrentPrice] ";
        query += " WHEN [PropertyType] = 'COM' then [CurrentPrice] ";
        query += " end as c_listing_price,[ApxTotalSQFT] as c_listing_area, ";
        query += "[City] as c_city,ListingID as c_listing_id,[Bedrooms] as c_bedroom,[TotalBaths] as c_bath,[ApxTotalSQFT] as c_living_room_size , ";
        query += "[RESRemark] as c_public_remark,[StreetName] as c_street_name,[StateOrProvince] as c_state,[AddrStreetDirection] as c_direction,[StreetNumber] as c_street_number, ";
        query += "[PostalCode] as c_zipcode,'BenchmarkRealty.net' as domain_name,[PostalCode] as PostalCode FROM [WARDEX_VIEW] where ([AgentID] in (" + agent_mls_list + ") or ";
        query += "[OfficeCoListCode] in (" + office_mls_list + ",'BNCH01')) and ";
        query += "([AgentID] not in (" + ex_agent_mls_list + ") and [OfficeCoListCode] not in (" + ex_office_mls_list + ")) ";
        //string query = "SELECT * FROM All_Daytona_Properties where (ListingAgentID in (" + agent_mls_list + ") or ListingBoard in (" + office_mls_list + ")) and (ListingAgentID not in (" + ex_agent_mls_list + ") or ListingBoard not in (" + ex_office_mls_list + "))";


        //string query = "SELECT * FROM All_Properties where list_5=(select MEMBER_0  FROM Rets_Agents where OFFICESHORT='" + office_short + "' and MEMBER_17='" + agent_short_id + "')";
        //string query="select * from All_Properties where LIST_5="+agent_id;

        //DataSet Ds1 = DotNetNuke.Data.DataProvider.Instance().ExecuteDataSet("prc_property_search", query);
        DataSet Ds1 = rda.query_exec_With_Dataset(query);

        if (Ds1.Tables[0].Rows.Count > 0)
        {

            for (int i = 0; i < Ds1.Tables[0].Rows.Count; i++)
            {
                Ds1.Tables[0].Rows[i]["c_public_remark"] = Ds1.Tables[0].Rows[i]["c_public_remark"].ToString().Replace("'", "&#39;");
                Ds1.Tables[0].Rows[i]["c_public_remark"] = Ds1.Tables[0].Rows[i]["c_public_remark"].ToString().Replace("/", "&#47;");
                Ds1.Tables[0].Rows[i]["c_direction"] = Ds1.Tables[0].Rows[i]["c_direction"].ToString().Replace("'", "&#39;");
                Ds1.Tables[0].Rows[i]["c_direction"] = Ds1.Tables[0].Rows[i]["c_direction"].ToString().Replace("/", "&#47;");


            }


            return Ds1.Tables[0];
        }
        return null;


    }

    [WebMethod]
    public DataTable get_agent_properties_new_Testing(string agent_short_id, string office_short_id, string exclude_agent_short_id, string exclude_office_short_id, string listingId, string propertyType)
    {
        string[] str_agent;
        string[] str_office;
        string[] str_ex_agent;
        string[] str_ex_office;
        string agent_mls_list = "''", office_mls_list = "''", ex_agent_mls_list = "''", ex_office_mls_list = "''";

        if (!agent_short_id.Equals(""))
        {
            str_agent = agent_short_id.Split(',');

            for (int i = 0; i < str_agent.Length; i++)
            {
                if (i == 0)
                    agent_mls_list += "'" + str_agent[i] + "'";
                else
                    agent_mls_list += ",'" + str_agent[i] + "'";
            }
        }

        if (!office_short_id.Equals(""))
        {
            str_office = office_short_id.Split(',');
            for (int i = 0; i < str_office.Length; i++)
            {
                if (i == 0)
                    office_mls_list += "'" + str_office[i] + "'";
                else
                    office_mls_list += ",'" + str_office[i] + "'";
            }
        }



        if (!exclude_agent_short_id.Equals(""))
        {
            str_ex_agent = exclude_agent_short_id.Split(',');
            for (int i = 0; i < str_ex_agent.Length; i++)
            {
                if (i == 0)
                    ex_agent_mls_list += "'" + str_ex_agent[i] + "'";
                else
                    ex_agent_mls_list += ",'" + str_ex_agent[i] + "'";
            }
        }

        if (!exclude_office_short_id.Equals(""))
        {
            str_ex_office = exclude_office_short_id.Split(',');
            for (int i = 0; i < str_ex_office.Length; i++)
            {
                if (i == 0)
                    ex_office_mls_list += "'" + str_ex_office[i] + "'";
                else
                    ex_office_mls_list += ",'" + str_ex_office[i] + "'";
            }
        }

        string listId = string.Empty;
        if (listingId.ToString() != string.Empty)
        {
            //int id = Convert.ToInt32(listingId.ToString());
            listId = " and [ListingID] ='" + listingId.ToString() + "'";
        }

        string propType = "";
        switch (propertyType)
        {
            case "SingleFamily": propType = " and ([PropertyType] like '%single family%' or [LandPropertyType] like '%single family%')"; break;
            case "Condo": propType = " and ([PropertyType] like '%condo%')"; break;
            case "Townhomes": propType = " and ([PropertyType] like '%Townhouse%')"; break;
            case "multyfamily": propType = " and ([PropertyType] like '%Multi-Family%' or [LandPropertyType] like '%Multi Family%')"; break;
            case "Commercial": propType = " and ([LandPropertyType] like '%Commercial%' )"; break;
            case "Land": propType = " and ([PropertyType] like '%Vacant Land%')"; break;
            case "Rental": propType = " and ( [PropertyType] like '%Rental%')"; break;
            case "CommercialLease": propType = " and ([PropertyType] like '%Commercial for Lease%')"; break;
            default: propType = ""; break;
          //  default: propType = " and ([PropertyStyle] like '%Single Family Home%' or [PropertyStyle] like '%Single Family Home%' or [PropertyStyleLand] like '%Single Family Home%' or [PropertyStyle] like '%Single Family Home%' or [PropertyStyleCOM] like '%Single Family Home%')"; break;
        }

        string query = "SELECT top 100 [AgentListFullName] as c_member_name ,[AgentID] as c_member_short_id , [AgentID] as c_agent_id,";
        query += "[OfficeCoListCode] as c_office_id,";
        //query += "CASE WHEN [PropertyClassID] like '%Residential%' and (PropertySubType like '%Site Built%' Or PropertySubType like '%Horiz. Property Regime-Detached%' OR PropertySubType like '%Manufactured-Foundation% THEN 'Single Family Home'";
        query += "CASE WHEN  [PropertyType] like '%single family%' THEN 'Single Family Home' or [LandPropertyType] like '%single family%' THEN 'Single Family Home'";
        query += " WHEN  [PropertyType] like '%condo%' THEN 'Condos'";
        query += " WHEN  [PropertyType] like '%Multi-Family%' THEN 'Multi Family' Or [LandPropertyType] like '%Multi Family%' THEN 'Multi-Family'";
        query += " WHEN  [PropertyType] like '%Townhouse%' THEN 'TownHouses'";
        query += " WHEN  [LandPropertyType] like '%Commercial%'";
        query += " WHEN  [PropertyType] like '%Land%' THEN 'Land'";
        query += " WHEN  [PropertyType] like '%Rental%' THEN 'Rental'";
        query += " WHEN  [PropertyType] like '%Commercial for Lease%' THEN 'Commercial for Lease'";


      //  query += " WHEN [PropertyType] = 'INC' THEN 'Income'";
       // query += " WHEN [PropertyType] = 'REN' THEN 'Rental'";
        //query += " WHEN [PropertyType] = 'VAC' THEN 'Vacant-Land and Lots'";
        //query += " WHEN  [PropertyType] = 'COM' THEN 'Commercial'";
        //query += "  ELSE [PropertyType] ";
        query += " end as c_p_type, ";
        query += "CASE WHEN [PropertyType] = 'RES' then [CurrentPrice] ";
        query += " WHEN [PropertyType] = 'INC' then [CurrentPrice] ";
        query += " WHEN [PropertyType] = 'REN' then [CurrentPrice] ";
        query += " WHEN [PropertyType] = 'VAC' then [CurrentPrice] ";
        query += " WHEN [PropertyType] = 'COM' then [CurrentPrice] ";
        query += " end as c_listing_price,[ApxTotalSQFT] as c_listing_area, ";
        query += "[City] as c_city,ListingID as c_listing_id,[Bedrooms] as c_bedroom,[TotalBaths] as c_bath,[ApxTotalSQFT] as c_living_room_size , ";
        query += "[RESRemark] as c_public_remark,[StreetName] as c_street_name,[StateOrProvince] as c_state,[AddrStreetDirection] as c_direction,[StreetNumber] as c_street_number, ";
        query += "[PostalCode] as c_zipcode,'BenchmarkRealty.net' as domain_name,[PostalCode] as PostalCode FROM WARDEX_VIEW where ([AgentID] in (" + agent_mls_list + ") or ";
        query += "[OfficeCoListCode] in (" + office_mls_list + ",'BNCH01')) and ";
        query += "([AgentID] not in (" + ex_agent_mls_list + ") and [OfficeCoListCode] not in (" + ex_office_mls_list + "))" + listId + propType;


        //DataSet Ds1 = DotNetNuke.Data.DataProvider.Instance().ExecuteDataSet("prc_property_search", query);
        DataSet Ds1 = rda.query_exec_With_Dataset(query);
        if (Ds1.Tables[0].Rows.Count > 0)
        {

            DataRow dtrow;
            DataTable dt = Ds1.Tables[0];
            int count = Ds1.Tables[0].Rows.Count;
            dtrow = dt.NewRow();
            dt.Columns.Add("propCount");
            dtrow["propCount"] = count;
            dt.Rows.Add(dtrow);

            for (int i = 0; i < Ds1.Tables[0].Rows.Count; i++)
            {
                Ds1.Tables[0].Rows[i]["c_public_remark"] = Ds1.Tables[0].Rows[i]["c_public_remark"].ToString().Replace("'", "&#39;");
                Ds1.Tables[0].Rows[i]["c_public_remark"] = Ds1.Tables[0].Rows[i]["c_public_remark"].ToString().Replace("/", "&#47;");
                Ds1.Tables[0].Rows[i]["c_direction"] = Ds1.Tables[0].Rows[i]["c_direction"].ToString().Replace("'", "&#39;");
                Ds1.Tables[0].Rows[i]["c_direction"] = Ds1.Tables[0].Rows[i]["c_direction"].ToString().Replace("/", "&#47;");


            }


            return Ds1.Tables[0];
        }
        return null;


    }


    [WebMethod]
    public DataTable get_agent_properties_new_Testing_pagging(string agent_short_id, string office_short_id, string listing_short_id, string exclude_agent_short_id, string exclude_office_short_id, string exclude_listing_short_id, string listingId, string propertyType, string page)
    {
     
            string[] str_agent;
            string[] str_office;
            string[] str_ListingID;
            string[] str_ex_agent;
            string[] str_ex_office;
            string[] str_ex_ListingID;

            string agent_mls_list = "''", office_mls_list = "''", listingShortID = "''", ex_agent_mls_list = "''", ex_office_mls_list = "''", ex_listingShortID = "''";
            
           if (agent_short_id !=string.Empty)
            {
                str_agent = agent_short_id.Split(',');

                for (int i = 0; i < str_agent.Length; i++)
                {
                    if (i == 0)
                        agent_mls_list = "'" + str_agent[i] + "'";
                    else
                        agent_mls_list += ",'" + str_agent[i] + "'";
                }
            }

       
            if (office_short_id != string.Empty)
            {
                str_office = office_short_id.Split(',');
                for (int i = 0; i < str_office.Length; i++)
                {
                    if (i == 0)
                        office_mls_list = "'" + str_office[i] + "'";
                    else
                        office_mls_list += ",'" + str_office[i] + "'";
                }
            }

            if (listing_short_id != null && listing_short_id != string.Empty)
            {
                str_ListingID = listing_short_id.Split(',');
                for (int i = 0; i < str_ListingID.Length; i++)
                {
                    if (i == 0)
                        listingShortID = "'" + str_ListingID[i] + "'";
                    else
                        listingShortID += ",'" + str_ListingID[i] + "'";
                }
            }

            if (exclude_agent_short_id != null && exclude_agent_short_id != string.Empty)
            {
                str_ex_agent = exclude_agent_short_id.Split(',');
                for (int i = 0; i < str_ex_agent.Length; i++)
                {
                    if (i == 0)
                        ex_agent_mls_list = "'" + str_ex_agent[i] + "'";
                    else
                        ex_agent_mls_list += ",'" + str_ex_agent[i] + "'";
                }
            }

            if (exclude_office_short_id != null && exclude_office_short_id != string.Empty)
            {
                str_ex_office = exclude_office_short_id.Split(',');
                for (int i = 0; i < str_ex_office.Length; i++)
                {
                    if (i == 0)
                        ex_office_mls_list = "'" + str_ex_office[i] + "'";
                    else
                        ex_office_mls_list += ",'" + str_ex_office[i] + "'";
                }
            }

            if (exclude_listing_short_id != null && exclude_listing_short_id != string.Empty)
            {
                str_ex_ListingID = exclude_listing_short_id.Split(',');
                for (int i = 0; i < str_ex_ListingID.Length; i++)
                {
                    if (i == 0)
                        ex_listingShortID = "'" + str_ex_ListingID[i] + "'";
                    else
                        ex_listingShortID += ",'" + str_ex_ListingID[i] + "'";
                }
            }

            string listId = string.Empty;
            if (listingId != string.Empty)
            {
                //int id = Convert.ToInt32(listingId.ToString());
                listId = " and [ListId] ='" + listingId.ToString() + "'";
            }

            string propType = "";
            switch (propertyType)
            {

                case "Condo": propType = " and L_type_ like '%Condo%' and Prop_Class like '%Residential'"; break;
                case "ManufHomeMobile": propType = " and Prop_Class like '%Residential' and L_type_ like '%Manuf. Home/Mobile Home%'"; break;
                case "SiteBuiltHome": propType = " and Prop_Class like '%Residential' and L_type_ like '%Site-Built Home%'"; break;
                case "VillaDetachedWalls": propType = " and Prop_Class like '%Residential' and L_type_ like '%Villa/Detached Walls%'"; break;
                case "Commercial": propType = " and L_class like '%Commercial'"; break;
                case "LotsAndLand": propType = " and Prop_Class like '%LotsAndLand' and L_type_ like '%Land%'"; break;
                case "MultiFamily": propType = " and Prop_Class like '%MultiFamily'"; break;
                case "FarmRanch": propType = " and (L_class like '%Farm/Ranch')"; break;
                case "AUCTION": propType = " and  L_class like '%AUCTION'"; break;
                case "Rental": propType = " and  (L_class like '%RESIDENTIAL FOR LEASE%' or L_class like '%COMMERCIAL FOR LEASE%')"; break;             
                default: propType = ""; break;
                //default: propType = "and ([PropertyType] like '%single family%' or [LandPropertyType] like '%single family%' or [PropertyType] like '%condo%' or [PropertyType] like '%Townhouse%' or [PropertyType] like '%Multi-Family%' or [LandPropertyType] like '%Multi Family%' or [LandPropertyType] like '%Commercial%' or [PropertyType] like '%Vacant Land%' or [PropertyType] like '%Rental%' or [PropertyType] like '%Commercial for Lease%')"; break;

            }

            string query_count = "SELECT count([ListId]) as TotalCount FROM [MLS_VIEW] where ([AgentID] in (" + agent_mls_list + ") or ";
            query_count += "[OfficeID] in (" + office_mls_list + ",'" + OfficeID.Replace(",", "','") + "') OR [ListId] in (" + listingShortID + ")) and ";
            query_count += "([AgentID] not in (" + ex_agent_mls_list + ") and [OfficeID] not in (" + ex_office_mls_list + ") and [ListId] not in (" + ex_listingShortID + "))  ";//and [Status] in ('Active') 
            query_count += "and [Status] in ('Active') ";
            query_count += listId + propType;
            //DataSet Ds_count = DotNetNuke.Data.DataProvider.Instance().ExecuteDataSet("prc_property_search", query_count);

            DataSet Ds_count = rda.query_exec_With_Dataset(query_count);

            int pageLimit = 200;
            string totalCount = Ds_count.Tables[0].Rows[0]["TotalCount"].ToString();
     
            if (page == string.Empty)
            {
                page = "1";
            }
            int start = ((Convert.ToInt32(page) - 1) * pageLimit) + 1;
            int limit = (Convert.ToInt32(page) * pageLimit);


            string query = "WITH tempTable AS (SELECT [OfficeName] as c_member_name ,[AgentID] as c_member_short_id , [AgentID] as c_agent_id,";
            query += "[OfficeID] as c_office_id,";
            query += "CASE WHEN (L_type_ like '%Condo%' and Prop_Class like '%Residential') THEN 'Condo'";
            query += " WHEN (Prop_Class like '%Residential' and L_type_ like '%Manuf. Home/Mobile Home%') THEN 'ManufHome Mobile'";
            query += " WHEN (Prop_Class like '%Residential' and L_type_ like '%Site-Built Home%') THEN 'Site Built Home'";
            query += " WHEN (Prop_Class like '%Residential' and L_type_ like '%Villa/Detached Walls%') THEN 'Villa Detached Walls'";
            query += " WHEN (L_class like '%Commercial') THEN 'Commercial'";
            query += " WHEN (Prop_Class like '%LotsAndLand' and L_type_ like '%Land%') THEN 'Lots And Land'";
            query += " WHEN (Prop_Class like '%MultiFamily') THEN 'Multi Family'";
            query += " WHEN ((L_class like '%Farm/Ranch')) THEN 'Farm Ranch'";
            query += " WHEN (L_class like '%AUCTION') THEN 'AUCTION'";
            query += " WHEN (L_class like '%RESIDENTIAL FOR LEASE%' or L_class like '%COMMERCIAL FOR LEASE%') THEN 'Rental'";
         
            query += " end as c_p_type, ";
            query += "parsename(convert(varchar,convert(money,[TotalPrice]), 1),2) as c_listing_price,";
            query += " [Sqft] as c_listing_area, ";
            query += "[City] as c_city,[ListId] as c_listing_id,[TotalBeds] as c_bedroom,[TotalBaths] as c_bath,[Sqft] as c_living_room_size , ";
            query += "[PublicRemark] as c_public_remark,[StreetName] as c_street_name,[StreetNumber] as c_street_number,[State] as c_state, ";
            query += "[ZipCode] as c_zipcode,'" + SiteUrl.Replace(".com/", ".com").Replace("http://", "") + "' as domain_name,[ListId] as c_mlsno , ROW_NUMBER() OVER(ORDER BY [ListId] asc) AS RowNum, ";
            query += "[OfficeName] as off_name,'' as off_address,'' as off_phone ";
            //  query += ",'' as PhotoUrls FROM All_Properties_orlando where ([AgentListID] in (" + agent_mls_list + ") or ";
            query += ",Primaryphotourl as PhotoUrls FROM " + MLSTable + " where ([AgentID] in (" + agent_mls_list + ") or ";
            query += " [OfficeID] in (" + office_mls_list + ",'" + OfficeID.Replace(",", "','") + "') or [ListId] in (" + listingShortID + ")) and ";
            query += "([AgentID] not in (" + ex_agent_mls_list + ") and [OfficeID] not in (" + ex_office_mls_list + ") and [ListId] not in (" + ex_listingShortID + ")) and [Status] in ('Active')";//and [Status] in ('Active')
            query += listId + propType + ")";

            query += " SELECT * FROM tempTable WHERE RowNum BETWEEN  " + start + " AND " + limit;

                        
            //DataSet Ds1 = DotNetNuke.Data.DataProvider.Instance().ExecuteDataSet("prc_property_search", query);
            DataSet Ds1 = rda.query_exec_With_Dataset(query);
            if (Ds1.Tables[0].Rows.Count > 0)
            {

                DataRow dtrow;
                DataTable dt = Ds1.Tables[0];
                int count = Ds1.Tables[0].Rows.Count;
                dtrow = dt.NewRow();
                dt.Columns.Add("propCount");
                dtrow["propCount"] = count;

                dt.Columns.Add("start");
                dtrow["start"] = start;
                dt.Columns.Add("limit");
                dtrow["limit"] = limit;
                dt.Columns.Add("page");
                dtrow["page"] = Convert.ToInt32(page);

                dt.Columns.Add("next");
                dtrow["next"] = Convert.ToInt32(page) + 1;
                dt.Columns.Add("previous");
                dtrow["previous"] = Convert.ToInt32(page) - 1;

                dt.Columns.Add("pageLimit");
                dtrow["pageLimit"] = pageLimit;
                dt.Rows.Add(dtrow);

                for (int i = 0; i < Ds1.Tables[0].Rows.Count; i++)
                {
                    Ds1.Tables[0].Rows[i]["c_public_remark"] = Ds1.Tables[0].Rows[i]["c_public_remark"].ToString().Replace("'", "&#39;");
                    Ds1.Tables[0].Rows[i]["c_public_remark"] = Ds1.Tables[0].Rows[i]["c_public_remark"].ToString().Replace("/", "&#47;");
                    //Ds1.Tables[0].Rows[i]["c_direction"] = Ds1.Tables[0].Rows[i]["c_direction"].ToString().Replace("'", "&#39;");
                    //Ds1.Tables[0].Rows[i]["c_direction"] = Ds1.Tables[0].Rows[i]["c_direction"].ToString().Replace("/", "&#47;");

                }


                return Ds1.Tables[0];
            }
      

        return null;


    }

    public static string GenerateCoupon(int length)
    {
        string result = string.Empty;
        Random random = new Random((int)DateTime.Now.Ticks);
        List<string> characters = new List<string>() { };
        for (int i = 48; i < 58; i++)
        {
            characters.Add(((char)i).ToString());
        }
        for (int i = 65; i < 91; i++)
        {
            characters.Add(((char)i).ToString());
        }
        for (int i = 97; i < 123; i++)
        {
            characters.Add(((char)i).ToString());
        }
        for (int i = 0; i < length; i++)
        {
            result += characters[random.Next(0, characters.Count)];
            Thread.Sleep(1);
        }
        return result;
    }

    public void createleadXML(int DnnPortalID, string DnnPortalName, string DnnLeadID)
    {
        string filepath = Path.Combine(HttpRuntime.AppDomainAppPath, "Portals/" + DnnPortalName + "/MLS_Medias/lead_activity_xml/" + DnnLeadID + ".xml");

        if (!Directory.Exists(Path.Combine(HttpRuntime.AppDomainAppPath, "Portals/" + DnnPortalName + "/MLS_Medias")))// + "/MLS_Medias/Property/" + PropertyID + "/"+ObjectType)))
        {
            // Specify a "currently active folder" 
            string activeDir = Path.Combine(HttpRuntime.AppDomainAppPath, "Portals/" + DnnPortalName + "/");

            //Create a new subfolder under the current active folder 
            string newPath = System.IO.Path.Combine(activeDir, "MLS_Medias");

            // Create the subfolder
            if (!Directory.Exists(newPath))
                System.IO.Directory.CreateDirectory(newPath);
        }

        if (!Directory.Exists(Path.Combine(HttpRuntime.AppDomainAppPath, "Portals/" + DnnPortalName + "/MLS_Medias/lead_activity_xml")))// + "/MLS_Medias/Property/" + PropertyID + "/"+ObjectType)))
        {
            // Specify a "currently active folder" 
            string activeDir = Path.Combine(HttpRuntime.AppDomainAppPath, "Portals/" + DnnPortalName + "/MLS_Medias/");

            //Create a new subfolder under the current active folder 
            string newPath = System.IO.Path.Combine(activeDir, "lead_activity_xml");

            // Create the subfolder
            if (!Directory.Exists(newPath))
                System.IO.Directory.CreateDirectory(newPath);
        }

        XmlTextWriter xtw = new XmlTextWriter((filepath), System.Text.Encoding.UTF8);
        xtw.Formatting = System.Xml.Formatting.Indented;
        xtw.Indentation = 3;
        xtw.IndentChar = ' ';
        xtw.WriteStartDocument(true);
        xtw.WriteStartElement("Activities");
        xtw.WriteEndElement();
        xtw.WriteEndDocument();
        xtw.Close();

    }

    [WebMethod]
    public bool changeAgentPassword(string portal_ID, string user_name, string oldPassword, string newPassword)
    {
        int current_portal_id = Convert.ToInt32(portal_ID);
        DotNetNuke.Entities.Users.UserInfo userInfo = DotNetNuke.Entities.Users.UserController.GetUserByName(current_portal_id, user_name);

        DotNetNuke.Security.Membership.MembershipProvider membershipProvider = DotNetNuke.Security.Membership.MembershipProvider.Instance();

        oldPassword = DotNetNuke.Entities.Users.UserController.GetPassword(ref userInfo, userInfo.Membership.PasswordAnswer);

        DotNetNuke.Entities.Users.UserController.ChangePassword(userInfo, oldPassword, newPassword);
        return true;
    }
    // Function for delete user from backend 
    [WebMethod]
    public string deleteUser(string portal_ID, string BakckendId)
    {
        try
        {

            DataSet ds = DotNetNuke.Data.DataProvider.Instance().ExecuteDataSet("prc_MappTable_Mgmt", BakckendId, "get");
            int current_portal_id = Convert.ToInt32(portal_ID);
            int DNNId = Convert.ToInt32(ds.Tables[0].Rows[0]["dnn_user_id"].ToString());
            UserController userController = new UserController();
            UserInfo user = userController.GetUser(current_portal_id, DNNId);
            DotNetNuke.Data.DataProvider.Instance().ExecuteNonQuery("prc_MappTable_Mgmt", DNNId.ToString(), "delete_potal_alias");
            //UserController.DeleteUser(ref user, true, false); // soft delete of user
            UserController.RemoveUser(user); // remove user to complete hard delete
            DotNetNuke.Data.DataProvider.Instance().ExecuteNonQuery("prc_MappTable_Mgmt", BakckendId, "delete");
            return "User Deleted";
        }
        catch (Exception ex)
        {
            return "Getting error during agent deletion";
        }
    }

    [WebMethod]
    public String UpdateAgent(int portalId, string agentobj_str)
    {
        try
        {
            AgentObject agentobj = JsonConvert.DeserializeObject<AgentObject>(agentobj_str);

            if (agentobj != null)
            {
                UserInfo UserInfoEdit = UserController.GetUserByName(portalId, agentobj.user_name);

                if (UserInfoEdit != null)
                {
                    int CreatedByUserID = DotNetNuke.Data.DataProvider.Instance().ExecuteScalar<int>("Prc_UpdatePortalAlias", UserInfoEdit.PortalID, agentobj.url_c, UserInfoEdit.UserID.ToString());

                    if (CreatedByUserID <= 0)
                    {
                        DataSet Ds = DotNetNuke.Data.DataProvider.Instance().ExecuteDataSet("AddCustomAlias", UserInfoEdit.PortalID, agentobj.url_c, UserInfoEdit.UserID.ToString());
                    }


                    UserInfoEdit.FirstName = agentobj.first_name;
                    UserInfoEdit.LastName = agentobj.last_name;
                    UserInfoEdit.Email = agentobj.email1;
                    UserInfoEdit.Profile.FirstName = agentobj.first_name;
                    UserInfoEdit.Profile.LastName = agentobj.last_name;
                    UserInfoEdit.IsSuperUser = false;
                    UserInfoEdit.DisplayName = agentobj.first_name + " " + agentobj.last_name;
                    UserInfoEdit.RefreshRoles = true;
                    UserInfoEdit.IsDeleted = false;

                    //Set Membership
                    UserMembership ums = new UserMembership();
                    ums.Approved = true;

                    ums.UpdatePassword = false;
                    ums.CreatedDate = System.DateTime.Now;
                    ums.Email = agentobj.email1;


                    ums.IsOnLine = false;
                    ums.Username = UserInfoEdit.Username;

                    //Bind membership to user
                    UserInfoEdit.Membership = ums;

                    UserInfo ui = new UserInfo();
                    ui = UserInfoEdit;

                    ProfileController.UpdateUserProfile(UserInfoEdit);
                    UserController.UpdateUser(UserInfoEdit.PortalID, UserInfoEdit);
                    createAgentPage(agentobj.id, UserInfoEdit.Username.ToString(), UserInfoEdit.PortalID);
                    DotNetNuke.Common.Utilities.DataCache.ClearHostCache(true);

                    return "1";
                }
                return "0";
            }
            return "0";
        }
        catch (Exception ex)
        {
            return JsonConvert.SerializeObject(ex);
        }
        return "0";
    }


    class AgentObject
    {
        public string id { get; set; }
        public string user_name { get; set; }
        public string user_hash { get; set; }
        public string system_generated_password { get; set; }
        public string pwd_last_changed { get; set; }
        public string authenticate_id { get; set; }
        public string sugar_login { get; set; }
        public string first_name { get; set; }
        public string last_name { get; set; }
        public string is_admin { get; set; }
        public string external_auth_only { get; set; }
        public string receive_notifications { get; set; }
        public string date_entered { get; set; }
        public string date_modified { get; set; }
        public string modified_user_id { get; set; }
        public string created_by { get; set; }
        public string title { get; set; }
        public string department { get; set; }
        public string phone_home { get; set; }
        public string phone_mobile { get; set; }
        public string phone_work { get; set; }
        public string phone_other { get; set; }
        public string phone_fax { get; set; }
        public string status { get; set; }
        public string address_street { get; set; }
        public string address_city { get; set; }
        public string address_state { get; set; }
        public string address_country { get; set; }
        public string address_postalcode { get; set; }
        public string deleted { get; set; }
        public string portal_only { get; set; }
        public string show_on_employees { get; set; }
        public string employee_status { get; set; }
        public string messenger_id { get; set; }
        public string messenger_type { get; set; }
        public string reports_to_id { get; set; }
        public string is_group { get; set; }
        public string id_c { get; set; }
        public string active_rotate_flag_c { get; set; }
        public string agentmls2_c { get; set; }
        public string agentmls_c { get; set; }
        public string awards_c { get; set; }
        public string bio_c { get; set; }
        public string company_name_c { get; set; }
        public string current_rotate_cnt_c { get; set; }
        public string last_lead_c { get; set; }
        public string last_login_date_c { get; set; }
        public string leadsperround_c { get; set; }
        public string lead_assign_flag_c { get; set; }
        public string lead_flow_c { get; set; }
        public string lender_company_c { get; set; }
        public string lender_company_logo_c { get; set; }
        public string lender_to_agent_c { get; set; }
        public string login_count_c { get; set; }
        public string notify_c { get; set; }
        public string officemls1_c { get; set; }
        public string officemls2_c { get; set; }
        public string office_ph_c { get; set; }
        public string post_to_craiglist_c { get; set; }
        public string roletype_c { get; set; }
        public string send_leads_c { get; set; }
        public string show_on_site_c { get; set; }
        public string tagline_c { get; set; }
        public string upload_logo_c { get; set; }
        public string url_c { get; set; }
        public string company_id_c { get; set; }
        public string allow_recruitment_zone_c { get; set; }
        public string users_photo_c { get; set; }
        public string users_pic_c { get; set; }
        public string email1 { get; set; }

    }
}

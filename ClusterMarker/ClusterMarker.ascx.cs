using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Web.Client.ClientResourceManagement;
using DotNetNuke.Framework;
using System.Xml.Linq;
using rets_dataaccess_lib;
using rets_dataaccess_lib.Components;
using CustomSqlHelper;
using System.Data;


public partial class DesktopModules_ClusterMarker_ClusterMarker : PortalModuleBase
{
    override protected void OnInit(EventArgs e)
    {
        ServicesFramework.Instance.RequestAjaxScriptSupport();
        ServicesFramework.Instance.RequestAjaxAntiForgerySupport();
    }
    protected void Page_Load(object sender, EventArgs e)
    {

    }
}








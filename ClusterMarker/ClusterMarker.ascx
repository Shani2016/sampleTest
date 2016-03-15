<%@ Control Language="C#" AutoEventWireup="true" CodeFile="ClusterMarker.ascx.cs" Inherits="DesktopModules_ClusterMarker_ClusterMarker" ClientIDMode="Static" %>
<%@ Register Src="~/DesktopModules/_Lead_Activity/_Lead_Activity.ascx" TagName="LeadActivity"
    TagPrefix="BA" %>
<%@ Register TagPrefix="dnn" Namespace="DotNetNuke.Web.Client.ClientResourceManagement"
    Assembly="DotNetNuke.Web.Client" %>

<script src="http://maps.googleapis.com/maps/api/js?key= AIzaSyD4sfI7fT0N6Ltrt-6LB8JOZOQ-7THkibc&sensor=false"></script>
<script type="text/javascript" src="http://google-maps-utility-library-v3.googlecode.com/svn/tags/markerclustererplus/2.0.12/src/markerclusterer_packed.js"></script>
<script src="http://www.bdcc.co.uk/Gmaps/GDouglasPeuker.js"></script> <%--//For Polygondrawing--%>
<%--<script type="text/javascript" src="//apicdn.walkscore.com/api/v1/traveltime/js?wsid=5dd48f75c5ed4763a4100fe25e0e5cb4"></script>--%>


<%--<script src="http://google-maps-utility-library-v3.googlecode.com/svn/trunk/markerclustererplus/src/data.json"></script>--%>
<script type="text/javascript" src="/js/_Advance_Search.js"></script>

<script type="text/javascript" src="/DesktopModules/ClusterMarker/js/ClusterMarker.js"></script>
<script src="/DesktopModules/_LeadCapture/js/_LeadCapture.js"></script>
<script src="/js/_Advance_Search.js"></script>
<link href="/DesktopModules/_GMap/module.css" rel="stylesheet" type="text/css" />
<link href="/DesktopModules/ClusterMarker/module.css" rel="stylesheet" type="text/css" />
<dnn:DnnJsInclude runat="server" FilePath="/Resources/rateit/src/jquery.rateit.js" />
<dnn:DnnCssInclude runat="server" FilePath="/Resources/rateit/src/rateit.css" />
<dnn:DnnCssInclude runat="server" FilePath="/DesktopModules/_PropertyDetails/module.css" />
<dnn:DnnCssInclude runat="server" FilePath="/DesktopModules/_HomeProperty/HP_Lead_Activity.css" />

<script type="text/javascript" src="/DesktopModules/ClusterMarker/js/fotorama.js"></script>
<link href="/DesktopModules/ClusterMarker/fotorama.css" rel="stylesheet" type="text/css" />

<%--<link rel="stylesheet" type="text/css" href="/DesktopModules/ClusterMarker/css/style.css">
<link rel="stylesheet" type="text/css" href="/DesktopModules/ClusterMarker/css/bootstrap.css">--%>
<link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
<script src="/DesktopModules/ClusterMarker/js/bootstrap.min.js"></script>
<script src="/DesktopModules/ClusterMarker/js/bootstrap.js"></script>


<script type="text/javascript">
    //var reload=false;
    //var mouse_is_inside=false;
    //window.onpopstate = function(event) {    
    //    if(reload) {
    //        $("#div_LeadCapture").bPopup().close();
    //        $('#rightsidebar').bPopup().close();
    //    }
    //}
    //$('div.b-modal').click(function(e) {
    //    debugger;
    //    $("#div_LeadCapture").bPopup().close();
    //    $('#rightsidebar').bPopup().close();
    //});

    function IsUrlValid(url) {
        var validUrlRegexExprn=/^(?:(?:https?):\/\/)(?:\S+(?::\S*)?@)?(?:(?!10(?:\.\d{1,3}){3})(?!127(?:\.\d{1,3}){3})(?!169\.254(?:\.\d{1,3}){2})(?!192\.168(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\u00a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)(?:\.(?:[a-z\u00a1-\uffff0-9]+-?)*[a-z\u00a1-\uffff0-9]+)*(?:\.(?:[a-z\u00a1-\uffff]{2,})))(?::\d{2,5})?(?:\/[^\s]*)?$/i;
        if (!validUrlRegexExprn.test(url)){
        
            return "none";
        }
        else{
            return "normal";
        }
    }


    function imgError_agent_info(image) {
        image.onerror = "";
        image.src = "/images/default_users.jpg";
        return true;
    }

    function imgError_lender_info(image) {
        image.onerror = "";
        image.src = "/images/default_users.jpg";
        return true;
    }
    // Returns a Pow 
    function getPow(x,y) {
        return Math.pow(x,y);
    }

    //Returns a Round
    function getRound(MonthlyPay) {
        return Math.round(MonthlyPay);
    }

    $(document).keydown(function(e) {
        // ESCAPE key pressed
        if (e.keyCode == 27) { //|| e.keyCode==8) {
         
            $("#div_LeadCapture").bPopup().close();
            $('#PropertyDetails').bPopup().close();


        }
    });
    $('#PropertyRating').rateit('step', 1);
    $("#PropertyRating").bind('rated', function (event, value) {
        $.PropertyDetails.SetPropertyRating(opts, value);
    });
    var query;
    opts = $.extend({}, defaultOptions, options);

    var PropertyViewedCount = $.cookie('PropertyViewedCount');

    if (PropertyViewedCount == undefined) {
        $.cookie("PropertyViewedCount", "1", {
            path: '/'
        });
    } else {
        PropertyViewedCount = TryParseInt($.cookie('PropertyViewedCount'), 0);
        PropertyViewedCount = PropertyViewedCount + 1;
        $.cookie("PropertyViewedCount", PropertyViewedCount, {
            path: '/'
        });
    }
    if (opts.LeadId == "-1" && opts.UserRole != "Agent" && $.cookie("SourceCampaign") == "Cookie Available") {
        $.LeadCapture.showLeadCapture();
    }

    else
        if (opts.LeadId == "-1" && opts.UserRole != "Agent" && PropertyViewedCount > 1) {
            $.LeadCapture.showLeadCapture();
        }
    function IsFav(favflag) {
        if (favflag == true)
            return "redheart";
        return "Blackheart";
    }

    function IsViewed(viewedflag) {
        if (viewedflag == true)
            return "redviewed";
    }
    function search_listings_showMainLeadPopup(pid) {
        
        //debugger;
        //$(pid).removeClass('Blackheart');
        var classn = $(pid).attr('class');

        if (classn.indexOf("Blackheart") >= 0) {
            search_listings_AddtoFav_or_remove(pid.id);
            $(pid).removeClass('Blackheart');
            $(pid).addClass('redheart');
        }
        else {
            search_listings_AddtoFav_or_remove(pid.id);
            $(pid).removeClass('redheart');
            $(pid).addClass('Blackheart');
        }

        return false;
    }

    var search_listings_AddtoFav_or_remove = function (pid) {

        $.post("/testHandler.ashx?ListingID=" + pid + "&lid=" + <%= UserId %>, function (data) {
            if (data != null) {
                //alert(data);
            }

        });
        //alert(lbl_id.id); 
    };

    $(document).ready(function () {
        $(document).ready(function () {
            setTimeout(function () {
                reload = true;
            }, 2000);

        });
      

        $(window).load(function () {
            var optionsAS = {
                servicesFramework: $.ServicesFramework(<%=ModuleId%>),
                <% if (UserInfo.IsInRole("Lead") && !UserInfo.IsSuperUser)
               {%>
                LeadId: '<%= UserId %>'
            <%} %>
            <% else
               {%>
                LeadId: '-1'
            <%} %>

        <% if (UserInfo.IsInRole("Agent"))
           {%>
            ,UserRole: 'Agent'
            <%} %>
         <% else if (UserInfo.IsInRole("Lead"))
           {%>
        ,UserRole: 'Lead'
        <%} %>
            };
            
            $.MapCluster.Init(optionsAS);
            $.MapCluster.initialize();
            
    });


    });
    //$(document).keydown(function(e) {
    //    // ESCAPE key pressed
    //    if (e.keyCode == 27) { //|| e.keyCode==8) {
    //        debugger;
    //        $("#div_LeadCapture").bPopup().close();
    //        $('#rightsidebar').bPopup().close();


    //    }
    //});

</script>


<asp:HiddenField ID="query_str_place_HF" runat="server" />
<asp:HiddenField ID="postalcodeCityHiddnFld" runat="server" />
<asp:HiddenField ID="query_str_HF" runat="server" />
<asp:HiddenField ID="hdf_maintainUrl" runat="server" />
<asp:HiddenField ID="prop_count" runat="server" />
<asp:HiddenField ID="hdfRole" runat="server" />
<asp:HiddenField ID="cityname_HF" runat="server" />

<asp:HiddenField ID="hdfCitychanged" runat="server" />
<asp:HiddenField ID="southW_hdf" runat="server" />
<asp:HiddenField ID="NorthE_hdf" runat="server" />
<asp:HiddenField ID="hdfLatitude" runat="server" />
<asp:HiddenField ID="hdfLongitude" runat="server" />
<%--<asp:HiddenField ID="" runat="server" />
<asp:HiddenField ID="" runat="server" />--%>
<input type="hidden" id="hdfNorthEast" />
<input type="hidden" id="hdfSouthWest" />
<%--<input type="hidden" id="list_hover" />--%>
<asp:HiddenField ID="hdfOtherSearchFlag" runat="server" />

<asp:HiddenField ID="hdf_lat" runat="server" />
<asp:HiddenField ID="hdf_lng" runat="server" />
<asp:HiddenField ID="Ne_Sw_flag" runat="server" />
<asp:HiddenField ID="idle_flag" runat="server" />
<%--<asp:HiddenField ID="getNearByprop_flag" runat="server" />--%>
<asp:HiddenField ID="hdf_relateprop_flag" runat="server" />
<input type="hidden" id="getNearByprop_flag" />
<input type="hidden" id="walkscore_Address" />
<script type="text/javascript">
    $("#carousel").carousel();
    //function showMarkerPopup(Latitude, Longitude, MLSId)
    //{
    //    $.MapCluster.prop_list_hover(Latitude, Longitude,MLSId);
    //}
    function ShowMarkeronMap(MLSId, Latitude, Longitude) {
    
        $("#SelectedListId").val(MLSId);
       // $("#SelectedListId").attr('Rank',Rank);
        //$('#FEL_listView').hide();
        //$('#rightsidebar').show();
        //$('.map-data').attr('style', 'width: 50% !important');
       // $('.gm-style').attr('style', 'width: 50% !important');
        //$('.col-map-2').css('display', 'block');
        $('#PropertyDetails').bPopup({
            modalClose: true,
            escClose: true,
            transition: 'slideBack',
            opacity: 0.0,
            speed:300,
            
            //transitionClose: 'slideBack',
            zIndex: 2,
            positionStyle: 'fixed'
            
        });
      
       $.MapCluster.MapPropertyDetails(MLSId);

       walkscore_data(Latitude, Longitude);

    }
    var hide = 0;
    function ShowhideProperties() {
        if (hide == 0) {
            $("#btnShowHideList").html('Show');
           // $('.map-data').css('width', '100%', '!important');
            $('.Mapwrap').css('width', '100%');
            //$('#FEL_listView').show();
            hide = 1;
        }
        else {
            $("#btnShowHideList").html('Hide');
            //$('.map-data').css('width', '75%');
            $('.Mapwrap').css('width', '78%');
            hide = 0;
        }
        $("#FEL_listView").animate({ width: 'toggle' }, 500);

        //$("#FEL_listView").css({transition : 'width 2s'})
        // $("#FEL_listView").slideToggle("slow");
    }
    function imgError(image) {
        image.onerror = "";
        image.src = "/images/NoPreview.jpg";
        return true;
    }
</script>
 
            <div class="hide_show">
                <a id='btnShowHideList' onclick="ShowhideProperties();" href="javascript:void(0);">Hide</a>
             </div>

<div class="map"> </div>
       

<div class="mapdisplaywrap mapWrapper">
    <div id="property_type_legend">Property Type Legend : </div>
    <div id="prop_guide" class="prop_guide_cls"></div>
    <div id="property_count"class="property_count_cls" ></div>
    <%--<div id="first" style="padding:3px;">
        <span class="test"></span>
        </div>--%>
        <div class="propertydisplayWrap"></div>
    <div id="leftmap" class="col-map-1">
        <%-- FreehandPolygon--%>
       <%--<div id="draw"><a href="#">drawme</a></div><div id="clearPoly" style="float:left"><a href="#">Clear</a></div>--%>
         <%-- FreehandPolygon--%>
        <div class="drawClear" id="drawClear">
            <div id="draw"><a href="#"><img src="/Portals/0/drawShape.png" title="Draw a Custom Region" class="drawR" id="drawR" style="border-radius:20px; height:40px; width:40px;" /></a></div>
            <div id="clearPoly" style="float:left"><a href="#"><img src="/Portals/0/clearShape.png" title="Clear Custom Region" class="clearR" id="clearR" style="border-radius:20px; height:40px; width:40px;margin-top: -10px;" /></a></div>
        </div>
        <%------------------------------------------------------------  Start --- New Code of Draw and Clear Button --%>
        
                <%--<div class="drawClearR" id="drawClearR">
                    <div id="draw" style="position: absolute;margin-left: 20px;">
                        <a href="#">--%>
                    
                            <%--<img src="/Portals/0/drawShape.png" title="Draw a Custom Region" class="drawR" id="drawR" style="border-radius:20px; height:30px; width:30px;" />--%>
                            <%--<input type="button" value="Draw Region" class="drawR" id="drawR" style="height: 30px;font-weight: bold;border: 2px solid #000;font-size:13px;"/>
                        </a>
                    </div>
                    <div id="clearPoly" style="float:left;position: absolute;margin-left: 20px;">
                        <a href="#">--%>
                            <%--<img src="/Portals/0/clearShape.png" title="Clear Custom Region" class="clearR" id="clearR" style="border-radius:20px; height:30px; width:30px;" />--%>
                            <%--<input type="button" value="Clear Region" class="clearR" id="clearR" style="height: 30px;font-weight: bold;border: 2px solid #000;font-size:13px;"/>
                        </a>
                    </div>
                </div>--%>
        <%--------------------------------------------------------------  End --- New Code of Draw and Clear Button --%>


        
        <div id="GoogleMap1" class="Mapwrap map-data"></div>
      
        
        
        <%--//------propertylist//--%>
        <div id="FEL_listView" class="Gmap-property-list" style="background: #fff!important; height: 500px; margin: 0px auto; overflow-x: scroll; float: right; overflow-y: no-display; margin-top: -501px; margin-right: 10px;">
        </div>
        
       <div id="PropertyDetails" style="width: 75%; margin: 0px auto;background-color:#fff;">
        
        <div class="closebtn">
        <a href="javascript:void(0);" id="click" style="color: #fff;">X</a>
       </div>
        <h1 class="listing-style">
        <div class="prop-heading-box">
            
            <img class="Property-img-thumb" />
            <div id="div_propertyHeader">
            </div>
            <BA:LeadActivity ID="_Favourite" runat="server" />
        </div>
    </h1>

         
           <input type="hidden" id="SelectedListId" />
           <input type="hidden" id="SelectedFullAddress" />
           <div class="Main-Prop-Div">
               <div class="Main-prop">
            <div class="col-md-12">
                <div class="col-md-6" style="text-align: center;">
                    <div id="div_propertyBasic">
                    </div>
                    <div id="PropertyRating" class="rateit bigstars" data-rateit-starwidth="32" data-rateit-starheight="32">
                    </div>
                </div>
                <!--------------------------------- slider ---------------------------------------------->
                <div class="col-md-6" style="text-align: center; margin: 0px auto;">
                    <div  id="divgalleryPage" class="fotorama" data-max-width="100%" data-auto="false" data-ratio="800/600" data-maxheight="50%" data-stopautoplayontouch="false" data-autoplay="true" data-loop="true" data-allowfullscreen="true" data-nav="thumbs" data-thumbheight="50px" style="margin: 0px auto;text-align: center;" >
                    </div>
                </div>
            </div>
         
            <%--//************************Public Remarkes AND  AGENT DETAILS**************************//--%>
            <div class="row border_demo">
                <div class="col-md-12">
                    <%--<button type="button" class="btn btn-info" data-toggle="collapse" data-target="#div_PublicRemark">Public Remarks</button>--%>
                    <h2 class="hp_PublicRemarkBG">Public Remarks</h2>
                    <div id="div_PublicRemark">
                    </div>
                </div>                               
            </div>

<!--------------------------------- Map ---------------------------------------------->
                <div id="map-sp" class="col-md-12" style="margin: 0px auto; text-align: center;">
                    <div class="map_space" style="margin: 0px auto; /*text-align: center;*/text-align:left; margin-left:0px; width: 50%;">
                        <div class="mapfull">
                            <div>
                                <div class="tablerow">
                                    <div class="mapbuttonall tablecell">
                                        <a href="javascript:void(0);" id="btn_RoadMap">
                                            <div class="dnnPrimaryAction">
                                                Road View
                                            </div>
                                        </a>
                                    </div>
                                    <div class="mapbuttonall tablecell">
                                        <a href="javascript:void(0);" id="btn_aerialview">
                                            <div class="dnnPrimaryAction">
                                                Aerial View
                                            </div>
                                        </a>
                                    </div>
                                    <div class="mapbuttonall tablecell">
                                        <a href="javascript:void(0);" id="btn_streetview">
                                            <div class="dnnPrimaryAction">
                                                Street View
                                            </div>
                                        </a>
                                    </div>
                                </div>
                            </div>
                            <div id="toggle">
                            </div>
                            <div id="map-prop_details" class="map-canvas" style="">
                            </div>
                        </div>
                        <div class="places-nearby-div">
                            <ul id="places">
                               
                                <li>
                                    <input type="checkbox" value="props" name="props" id="nearbyProps" class="likeRadio">
                                    <span>For Sale Nearby</span> </li>
                                <!--
                <li>
                    <input type="checkbox" value="photos" name="photos" id="nearbyPhotos" class="likeRadio">
                    <span>Neighborhood Photos</span>
                </li>
                   -->
                               <%-- <li>
                                    <input type="checkbox" value="Traffic" name="Traffic" id="chkTraffic" class="likeRadio">
                                    <span>Show Live Traffic</span> </li>--%>
                            </ul>
                        </div>
                    </div>

  <script type="text/javascript">
      //var abc="";
      function walkscore_data(Latitude,Longitude) {
        
          //var geocoder = new google.maps.Geocoder();
          //var latn, lng;
          //geocoder.geocode({ 'address': CombineAddress }, function (results, status) {
          //    debugger;
          //    if (status == google.maps.GeocoderStatus.OK) {
          //         latn = results[0].geometry.location.lat();
          //         lng = results[0].geometry.location.lng();
                  
          //    }
          //});
          var ws_lat = Latitude;
          var ws_lon = Longitude;
         
        var ws_wsid = '5dd48f75c5ed4763a4100fe25e0e5cb4';
        //var ws_address =abc;
        var ws_width = '500';
        var ws_height = '800';
        var ws_layout = 'horizontal';
        var ws_hide_footer = 'true';
        var ws_commute = 'true';
        var ws_show_reviews = 'true';
        var ws_map_modules = 'default';
        var ws_no_link_info_bubbles = 'true';
        var ws_no_link_score_description = 'true';
        var ws_iframe_css_final = "border: 0";     
        var ws_params = "ws_wsid = '5dd48f75c5ed4763a4100fe25e0e5cb4'";
        ws_params +="&lat=" + ws_lat + "&lng=" + ws_lon;

        $("#ws-walkscore-tile").html('<iframe src="http://www.walkscore.com/serve-tile.php?' + ws_params + '" marginwidth="0" marginheight="0" vspace="0" hspace="0" allowtransparency="true" frameborder="0" scrolling="no" width="' + ws_width + 'px" height="' + ws_height + 'px" style="' + ws_iframe_css_final + '"></iframe>');
        
      }
  
</script>                
                   <%-- <style type='text/css'>#ws-walkscore-tile{position:relative;text-align:left}#ws-walkscore-tile *{float:none;}#ws-foottext, #ws-footer a,#ws-footer a:link{font:11px/14px Verdana,Arial,Helvetica,sans-serif;margin-right:6px;white-space:nowrap;padding:0;color:#000;font-weight:bold;text-decoration:none}#ws-footer a:hover{color:#000;text-decoration:none}#ws-footer a:active{color:#b14900}</style>--%>
                <div id='ws-walkscore-tile'></div>
                    <%--<script type='text/javascript' src='http://www.walkscore.com/tile/show-walkscore-tile.php'></script>--%>                   
                   <%-- <div id="myDiv">
                    </div>--%> 
                </div>
                   <div style="clear: both; border-bottom: 1px #ccc; height: 18px;">
                </div>

                   <!--------------------------------- feature Block ---------------------------------------------->
                <div class="col-md-12">
                    <div class="col-md-4">
                        <ul class="tree-col">
                            <li class="tree-colRow">
                                <h3 class="hp_featured_title">Exterior Features</h3>
                                <div id="div_ExteriorFeatures">
                                </div>
                            </li>
                        </ul>
                    </div>
                    <div class="col-md-4">
                        <ul class="tree-col">
                            <li class="tree-colRow">
                                <h3 class="hp_featured_title">Interior Features</h3>
                                <div id="div_InteriorFeatures">
                                </div>
                            </li>
                        </ul>
                    </div>
                    <div class="col-md-4">
                        <ul class="tree-col">
                            <li class="tree-colRow">
                                <h3 class="hp_featured_title">Property Features</h3>
                                <div id="div_PropertyFeatures">
                                </div>
                            </li>
                        </ul>
                    </div>
                </div>
                <div style="clear: both; border-bottom: 1px dotted #ccc; height: 18px;">
                </div>

        
                  <div class="Box">
                      <div class="col-md-12">
                    <div class="col-md-4">
                        <!--------------------------------- Agent Block ---------------------------------------------->
                        <div id="div_Agent">
                        </div>
                    </div>
                    <div class="col-md-4">
                        <!--------------------------------- Mogtage Block ---------------------------------------------->
                        <div style="clear: both;">
                            <div class="hp_agentname">
                                Mortgage Calculator
                            </div>
                            <div style="margin-top: 35px;">
                            <%-- <div class="Mortgage-title">Mortgage</div>--%>
                            <div id="div_PD_Mortgage" class="pd_div_Mortgage">
                                <div id="div_PD_MortgageForm">
                                    <ul>
                                        <li>
                                            <label for="PD_MGPrice">
                                                Price $
                                            </label>
                                            <input type="text" id="PD_Price" name="PD_Price" class="k-textbox" required />
                                        </li>
                                        <li>
                                            <label for="MTG_MGInterest" class="required">
                                                % Interest</label>
                                            <input type="text" id="PD_Interest" name="PD_Interest " class="k-textbox" required
                                                data-required-msg="*" />
                                        </li>
                                        <li>
                                            <label for="MTG_MGYear" class="required">
                                                Years</label>
                                            <input type="text" id="PD_Year" name="PD_Year" class="k-textbox" required data-required-msg="Year Required" />
                                        </li>
                                        <li>
                                            <label for="PD_MGDownPay" class="required">
                                                Down Payment</label>
                                            <input type="text" id="PD_DownPay" name="PD_DownPay" class="k-textbox" required data-required-msg="Down Pay Required" />
                                        </li>
                                        <li>
                                            <label for="PD_MGMsg" class="required">
                                                Est. Monthly Payment
                                            </label>
                                            <input type="text" id="PD_EMPayment" name="PD_EMPayment" class="k-textbox" placeholder="0"
                                                readonly="true" />
                                        </li>
                                        <li>
                                            <div style="text-align: center;">
                                                <button id="PD_MGCalculate" name="PD_MGCalculate" type="button" class="dnnPrimaryAction">
                                                    Calculate</button>
                                                <div id="PD_Progress">
                                                </div>
                                            </div>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                        
                        </div>
                    </div>
                    <div class="col-md-4">
                        <!--------------------------------- Lender Block ---------------------------------------------->
                        <div id="div_Lender">
                        </div>
                    </div>
                </div>
          
     </div>
    
            
            <div class="col-md-12">
                <h4 class="category">Related Properties</h4>
                <div style="width: 100%; overflow-x: scroll; overflow-y: hidden;">
                <table id="Related_property" style="width:auto; background: none !important; height: 200px;
                 margin: 0px auto; overflow-x: scroll; float: left; overflow-y: no-display;">
                <tr>
                </tr>
                </table>
              </div>
               <%-- <div id="Related_property" class="Gmap-property-list" style="background: #fff!important; height: 167px; width: 100%; overflow-x: scroll; overflow-y: no-display; margin-right: 10px;">
                </div>--%>
            </div>
               <div style="clear: both; border-bottom: 1px #ccc; height: 18px;">
                </div>
        </div>
    </div>
   </div>
     </div>
    <div id="first" style="padding:3px;">
        <span class="test"></span>
        </div>     
    </div>

<%--<div style="background-color: rgb(255, 255, 255); border: 1px solid rgb(216, 216, 216); width: 500px; height: 318px;" id="Div1">    <iframe width="500" height="318" frameborder="0" scrolling="no" allowtransparency="false" hspace="0" vspace="0" marginheight="0" marginwidth="0" id="tile-frame"></iframe>  </div>--%>
<%--/TO ADD PROPERTY LISTING TEMPLATE--%>
<script type="text/x-kendo-tmpl" id="ListTemplate">
 
    <div class="detail_list" id="#= MLSId#">
     <a href="javascript:void(0);" style="text-decoration:none;" onclick="ShowMarkeronMap('#= MLSId#','#= Latitude#','#= Longitude#');">
     <div class="add-price-div">
        <span class="search-text">#:CombineAddress#</span>
    </div>
        <div class="search-result" style="margin:0px auto;margin-bottom:10px;float: left;">
     
            <div class="search-img" style="margin-right:10px;">
            
                    <img src="#= PrimaryPhotoURL#" class="img-List" style="height:100px; width:100px;"onerror="imgError(this);" /> <!---- width="175" height="145" ----->
            </div>
                        
        </div>
   
    <div class="tableDiv search-details-info search_detail_box" >
        <table style="margin:0px auto;margin-top: 5px; margin-left:0px;class="border-grid">
            <tbody>

                <tr>
                    <td colspan="2" class="BG-Prop price-clr" style="font-weight:bold;width: 100px;margin-left: 0px;">$#:TotalPrice#</td>
                </tr>
                <tr>
                    
                    <td class="BG-Prop" style="width:60px;">Beds</td>
                    <td><div class="bed_val" style="font-weight:bold;width: 100px;margin-left: 0px;"><span class="alignStyle">#:TotalBaths#</span></td>
                </tr>
                <tr>
                    <td class="BG-Prop" style="width:60px;">Baths</td>
                    <td><div class="bath_val"style="font-weight:bold;width: 100px;margin-left: 0px;"><span class="alignStyle">#:TotalBeds#</span></td>   
                </tr>
                <tr>
                   
                    <td class="BG-Prop" style="width:60px;">MLS</td>
                    <td><div class="mls_val"style="font-weight:bold;width: 100px;margin-left: 0px;"><span class="alignStyle">#= MLSId#</span></td>
                </tr>
                <tr>
                   
                    <td class="BG-Prop" style="width:60px;">Area</td>
                    <td><div class="mls_val"style="font-weight:bold;width: 100px;margin-left: 0px;"><span class="alignStyle">#= Sqft#</span></td>
                </tr>
                <tr>
                   
                    <td class="BG-Prop" style="width:60px;">Style</td>
                    <td><div class="mls_val"style="font-weight:bold;width: 100px;margin-left: 0px;"><span class="alignStyle">#= Style#</span></td>
                </tr>
               
            </tbody>
        </table>
    </div>
     </a>    
</div>
   
</script>

<script type="text/x-kendo-tmpl" id="tmp_relatedListing">
  <%--  #var propertydeatails=IsBlankSpace(StreetNumber,StreetName,City,State,ZipCode);#--%>
    
    <td class="prop_att">
      <%--<div class="Main_prop_att">--%>
    <div class="relate_list" id="#= MLSId#">
      
     <div class="Typs">
    <b class="Lbl"><span class="Price-clr Add-clr"> #:Address#,#:City# </span>  </b>
             </div>     
     <a href="#=link#" target="_blank">     
       <img src="#= PrimaryPhotoURL#" onerror="imgError(this);"/>  </a> 
                <%-- <div id="dv_feature" runat="server" class="#= IsFeatureType(FeatureType)#">
                             #= FeatureText#
                             </div>   --%>         
        <%--</a> --%>      
                                   
               
                               
             <%--<div style="text-align:center;">--%>
    <div class="rel_p">
                    <b class="Lbl prc-clr">$<span class="Price-clr"> #:TotalPrice#</span>  </b>
             </div>
     <%--<div style="text-align:center;">--%>
    <div class="rel_p">
                    <b class="Lbl bed-clr">Beds:<span class="Price-clr tol-val"> #:TotalBaths# </span>  </b>&nbsp&nbsp
    <b class="Lbl bath-clr">Baths:<span class="Price-clr tol-val"> #:TotalBeds# </span>  </b></div>
    <div class="rel_p"> <b class="Lbl typ-clr">Type:</b>
            <span class="tol-val">#= Style#</span>
            </div> 
             <%--</div>--%>
    <%-- <div style="text-align:center;">
                    <b class="Lbl">Price:<span class="Price-clr"> #:TotalBeds# </span>  </b>
             </div>--%>
     
   
   <%--</div>--%>
       </td>
  
   
</script>




<%--<script type="text/x-kendo-tmpl" id="Related_properties_temp">
 
    <div class="relate_list" id="#= MLSId#">
    
     <div class="add-price-div">
        <span class="search-text">#:Address#</span>
    </div>
        <div class="search-result" style="margin:0px auto;margin-bottom:10px;float: left;">
     
            <div class="search-img" style="margin-right:10px;">
            
                    <img src="#= PrimaryPhotoURL#" class="img-List" style="height:100px; width:100px;" /> <!---- width="175" height="145" ----->
            </div>
                        
        </div>
   
    <div class="tableDiv search-details-info search_detail_box" >
        <table style="margin:0px auto;margin-top: 5px; margin-left:0px;class="border-grid">
            <tbody>

                <tr>
                    <td colspan="2" class="BG-Prop price-clr" style="font-weight:bold;width: 100px;margin-left: 0px;">#:Price#</td>
                </tr>
                <tr>
                    
                    <td class="BG-Prop" style="width:60px;">Beds</td>
                    <td><div class="bed_val" style="font-weight:bold;width: 100px;margin-left: 0px;"><span class="alignStyle">#:TotalBaths#</span></td>
                </tr>
                <tr>
                    <td class="BG-Prop" style="width:60px;">Baths</td>
                    <td><div class="bath_val"style="font-weight:bold;width: 100px;margin-left: 0px;"><span class="alignStyle">#:TotalBeds#</span></td>   
                </tr>
                <tr>
                   
                    <td class="BG-Prop" style="width:60px;">MLS</td>
                    <td><div class="mls_val"style="font-weight:bold;width: 100px;margin-left: 0px;"><span class="alignStyle">#= MLSId#</span></td>
                </tr>
                <tr>
                   
                    <td class="BG-Prop" style="width:60px;">Area</td>
                    <td><div class="mls_val"style="font-weight:bold;width: 100px;margin-left: 0px;"><span class="alignStyle">#= Sqft#</span></td>
                </tr>
                <tr>
                   
                    <td class="BG-Prop" style="width:60px;">Style</td>
                    <td><div class="mls_val"style="font-weight:bold;width: 100px;margin-left: 0px;"><span class="alignStyle">#= PropertyType#</span></td>
                </tr>
               
            </tbody>
        </table>
    </div>
     </a>    
</div>
    
   
   
</script>--%> 


<%--/TO ADD PROPERTY DETAILS TEMPLATE--%>
<script type="text/x-kendo-tmpl" id="propertyHeaderTemplate">
 <div class="propHeader" style="margin-top: 4px;">
                 
                 <h1><div class="add"> #:StreetNumber# #:StreetName# #:City#, #:State# #:ZipCode#</div></h1>
                 <ul>
                       <li class="listing-header-stat"> <span class="txt-style_H">Price </span><span class="txt-style_1">#:kendo.toString(TotalPrice, "c0")#</span></li>
                       <li class="listing-header-stat"><span class="txt-style_H">  Status </span><span class="txt-style">#:Status#</span></li>
                       <li class="listing-header-stat"><span class="txt-style_H">  Style </span><span class="txt-style_PT">#:Style#</span></li>
                 </ul>
    </div>
    <div class="clear"></div>
</script>
<script type="text/x-kendo-tmpl" id="propertyBasicTemplate">
      <div class="Box-prop" style="width:100%;padding:10px; margin-top: 10px;">
                    <table class="t-border" cellspacing="0" cellpadding="0" width="100%">
                        <tbody>
                            <tr>
                                <td class="BG-Prop" align="center" style="width: 16%; text-align:center;">Beds</td>
                                <td class="BG-Prop" align="center" style="width: 21%; text-align:center;">Baths</td>
                             <%--   <td class="BG-Prop" align="center" style="width: 16%;">Half</td>--%>
                                <td class="BG-Prop" align="center" style="width: 21%; text-align:center;">Built</td>                                
                                <td class="BG-Prop" align="center" style="width: 33%; text-align:center;">Sq Ft</td>
                            </tr>
                            <tr>
                                <td class="boldStyle top-border" align="center" style="text-align:center;"><span class="alignStyle">#:TotalBeds#</span></td>
                                <td class="boldStyle top-border" align="center" style="text-align:center;"><span class="alignStyle">#:FullBaths#</span></td>
                              <%--  <td class="boldStyle top-border" align="center"><span class="alignStyle">#:HalfBaths#</span></td>--%>
                                <td class="boldStyle top-border" align="center" style="text-align:center;"><span class="alignStyle">#:YearBuilt#</span></td>                                
                                <td class="boldStyle top-border" align="center" style="text-align:center;"><span class="alignStyle">#:Sqft#</span></td>
                            </tr>
                            <tr>
                                <td align="center"  class="BG-Prop" style="text-align:center;">MLS \#</td>
                                <td align="center" colspan="2" class="BG-Prop" style="text-align:center;">Lot</td>
                                <td align="center" class="BG-Prop" style="text-align:center;">$/Sq Ft</td>
                            </tr>
                            <tr>
                                <td class="boldStyle top-border" align="center" style="text-align:center;"><span class="alignStyle">#= ListId#</span></td>
                                <td class="boldStyle top-border" align="center" colspan="2" style="text-align:center;"><span class="alignStyle">#= Acre# Acres</span></td>
                                <td class="boldStyle top-border" align="center" style="text-align:center;"><span class="alignStyle">#:kendo.toString(Pricepersqft, "c")#</span></td>
                            </tr>
                           
                        </tbody>
                    </table>
                </div>
</script>

<script type="text/x-kendo-tmpl" id="PublicRemarkTemplate">
  <div class="Box-prop" style="width:100%;padding:10px; margin-top: 10px;">
                    <table cellspacing="0" cellpadding="0" width="100%">
                        <tbody>
                         
                            <tr>
                                <td align="center"><span style="color:\#777;">#:PublicRemark#</span></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
</script>
<script type="text/x-kendo-tmpl" id="FeaturesTemplate">
    <ul><h4>#= LongName #</h4>
                        <li>#= Value #</li>
                        </ul>
</script>
<script type="text/x-kendo-tmpl" id="LenderTemplate">
   <div class="hp_agentname">Lender Info</div>
<ul class="div_LenderBlockForm">

    <li>
        <div class="hp_li_div_lender">
            <div class="hp_name">
                           <span style="color: \#78736f;">#= first_name # #= last_name #</span>
                    </div>
            <span class="hp_Lender-hw_prof_pic">
                <img src="#= users_pic_c #" style="border: 0px solid rgb(255, 255, 255); box-shadow: 1px 1px 7px \#777;"></span><br />
            <div class="hp_phone_email">
                    
                    <span style="color: \#78736f;">#= address_street # #= address_city #</span>
                    <br />

               <div class="hp_phone-st">
                        <img width="18px;" height="18px;" src="/images/tel.png">
                      <a href="tel:#= phone_work #">#= phone_work #</a>
                    &nbsp;&nbsp;&nbsp;
                        <img width="18px;" height="18px;" src="/images/mob.png">
                       <a href="tel:#= phone_mobile #">#= phone_mobile #</a>
                        <br />
                    </div>

              
            <span class="Lender-party_icon Lender-cong"></span>
          

         
                    <span style="color: \#777;"><a href="mailto:#= email1 #">#= email1 #</a></span>
                    <br>
                    <div class="Lender-upper">
                        <a href="#= facebook_url_c#" target="_blank" style="display:#= IsUrlValid(facebook_url_c)#">
                            <img src="/images/Fb_co.png" height="25px" width="25px" /></a>
                        <a href="#= linked_in_c#" target="_blank" style="display:#= IsUrlValid(linked_in_c)#">
                            <img src="/images/li.png" height="25px" width="25px" /></a>
                        <a href="#= twitter_url_c#" target="_blank" style="display:#= IsUrlValid(twitter_url_c)#">
                            <img src="/images/twt.png" height="25px" width="25px" /></a>
                    </div>
                </div>
            </div>
       
    </li>

</ul>
</script>
<script type="text/x-kendo-tmpl" id="AgentTemplate">
    <div class="hp_agentname">Agent Info</div>
<ul class="div_AgentBlockForm">

    <li>
        <div class="hp_li_div_agent">
              <div class="hp_name">
                        <a href="http://#= url_c #"><span style="color: \#78736f;">#= first_name # #= last_name #</span> </a>
              </div>
            <span class="hw_prof_pic_hp">
                <img src="#= users_pic_c #" style="border: 0px solid rgb(255, 255, 255); box-shadow: 1px 1px 7px \#777;"></span><br />

            
                  <div class="hp_phone_email">
                        <a href="http://#= url_c #/Blog" class="hp_link-prof-hover">My Blog</a><br />

                       
                 <span style="color: \#78736f;">#= address_street # #= address_city #</span>
                    <br />

                    <div class="hp_phone-st">
                        <img width="18px;" height="18px;" src="/images/tel.png">
                       <a href="tel:#= phone_work #">#= phone_work #</a>
                     &nbsp;&nbsp;&nbsp;
                        <img width="18px;" height="18px;" src="/images/mob.png">
                       <a href="tel:#= phone_mobile #">#= phone_mobile #</a>
                        <br />
                    </div>

          
            <span class="party_icon cong"></span>
        

            
                    <span style="color: \#777;"><a href="mailto:#= email1 #">#= email1 #</a></span>

                    <br>
                    <div class="upper">
                        <a href="#= facebook_url_c#" target="_blank" style="display:#= IsUrlValid(facebook_url_c)#">
                            <img src="/images/Fb_co.png" height="25px" width="25px" /></a>
                        <a href="#= linked_in_c#" target="_blank" style="display:#= IsUrlValid(linked_in_c)#">
                            <img src="/images/li.png" height="25px" width="25px" /></a>
                        <a href="#= twitter_url_c#" target="_blank" style="display:#= IsUrlValid(twitter_url_c)#">
                            <img src="/images/twt.png" height="25px" width="25px" /></a>
                        <a href="#= youtube_url_c#" id="youtube" target="_blank" style="display:#= IsUrlValid(youtube_url_c)#"><img src="/images/utub.png" height="25px" width="25px" /></a>
                    
        </div>
        </div>
               
            
        </div>
    </li>
</ul>
</script>
<script type="text/x-kendo-tmpl" id="div_relatedproperties">
  
</script>

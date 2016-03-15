(function (name, definition) {
    var theModule = definition(),
    // this is considered "safe":
      hasDefine = typeof define === 'function' && define.amd,
    // hasDefine = typeof define === 'function',
      hasExports = typeof module !== 'undefined' && module.exports;

    if (hasDefine) { // AMD Module
        define(theModule);
    } else if (hasExports) { // Node.js Module
        module.exports = theModule;
    } else { // Assign to common namespaces or simply the global object (window)
        (this.jQuery || this.ender || this.$ || this)[name] = theModule;
    }
})('MapCluster', function () {

    var module = this;
    module.plugins = [];
    module.options = {};
    module.dataModels = [];

    var plugin = this;
    plugin.defaultOptions = {};
    plugin.optsAS = {};
    plugin.tabs = {};

    plugin.SearchInputs = {
        QueryString: '',
        XmlPath: '',
        SearchTable: '',
        SearchColumns: '',
        PropertyID: '',
        Favorite: '',
        PropertyType: '',
        PropertyImage: '',
        LoginSessionID: '',
        OnlyCount: 0,
        FirstRowsNo: "0",
        LastRowsNo: "0",
        searchID: '',
        SearchModifiedByRole: '',
        SearchModifiedByName: '',
        RatingCount: 0,
        //added by shani for related properties_ cluster map 23-2-16
        MLSId: '',
        ListId:'',
     
       TotalBaths:'',
       TotalBeds:'',
       Address:'',
       City:'',
       TotalPrice: '',
       PrimaryPhotoURL:''

    };
    
    var lt = 0.0, ln = 0.0;
    var Lat = [], Lng = [];
    var map;
    var map_reload;
    var panorama;
    var addr = [];
    var hide = 0;
    var slidePanelOpen = false;;//flag
    var propertyListData = "";
    var listjsondata = "";
    var div_pager_top_Kpager, div_pager_bottom_Kpager;
    var page = 0;
    var hide = 0;
    var maptypes_arr = [];
    var markers = [];
    var poly_flag = 0;
   // var poly_flag_2call = 0;
   // var poly_flag_call = 0;
    var circleplacechanged = 0;
    var FinalQueryString = "";
    var marker;
    var property = [];
    var data1 = [];
    var Mylatlan = [];
    var bounds_changed = 0;
    var idle_f = 0;
    var latitude;
    var longitude;
    var SearchCount;
    var address = '';
    var getNearByprop_flag = 0;
    var relateprop_flag = 0;
    var trafficLayer = new google.maps.TrafficLayer();
    var propertymarker = [];
    var propertymarker1 = [];
    var city_new;
    var NE='';
    var SW = '';
    var xhr = null;
    var poly;
    var polyOptions;
    var latitudeA;
    var longitudeA;
    var toggle_clear_flag = 0;
    var MapSaveSearchFlag = 1;
    var editsearch_mapFlag = 0;
    //-------Tooltip
    //var tooltips = document.querySelectorAll('.tooltip span');
    //debugger;
    //window.onmousemove = function (e) {
    //    var x = (e.clientX + 20) + 'px',
    //        y = (e.clientY + 20) + 'px';
    //    for (var i = 0; i < tooltips.length; i++) {
    //        tooltips[i].style.top = y;
    //        tooltips[i].style.left = x;
    //    }
    //};
    //-------Tooltip End

    return {
        Init: function (optionsAS) {
          
            plugin.optsAS = $.extend({}, plugin.SearchInputs, optionsAS);
            $(document).attr('title', $.MapCluster.GetParameterValues("page_title"));
            $.MapCluster.MapData();
            
            $("#places input[type=checkbox]").on('change', function (e) {
               
                $.MapCluster.ClearMap();
                $.MapCluster.getNearByPlaces();
            });

            PropertyResultURL = $(location).attr('href');
            var validatorASP_MTC = $("#ASP_MGCalculate").kendoValidator().data("kendoValidator");

            $('#ASP_MGCalculate').click(function (e) {
                if (validatorASP_MTC.validate()) {
                    $.MapCluster.MortgageCalculateClick();
                }
            });
            $('#PropertyRating ').rateit('step', 1);

            $("#PropertyRating").bind('rated', function (event, value) { $.MapCluster.SetPropertyRating(value); });

            $('#btn_RoadMap').click(function (e) {
                $("#places").show();

                $.MapCluster.SetROADMAP();
            });

            $('#btn_aerialview').click(function (e) {
                $("#places").show();
                $.MapCluster.SetSATELLITE();
            });

            $('#btn_streetview').click(function (e) {
                $("#places").hide();
                $.MapCluster.SetStreetView();
            });

            $('#PD_popup_close').click(function (e) {
                window.history.pushState(null, null, PropertyResultURL);
                $('#PropertyDetails').bPopup().close();
                fotorama.destroy();
            });
            var validatorPD_MTC = $("#div_PD_MortgageForm").kendoValidator().data("kendoValidator");

            $('#PD_MGCalculate').click(function (e) {
                if (validatorPD_MTC.validate()) {
                    $.MapCluster.MortgageCalculateClick();
                }
            });

            return this; 
        },

        MapData: function () {
           
            //changed city call
           
            var cityname = document.getElementById('cityname_HF').value;//for city name           
            city_new = document.getElementById('city_dlt_flag').value; //when city change           
            var city_default = document.getElementById('city_default').value;  //when city unselect from search

            if (bounds_changed == 0 || city_new == 1 || city_default==1) {
                var geocoder = new google.maps.Geocoder();
                geocoder.geocode({ 'address': cityname + ', USA' }, function (results, status) {
                
                    if (status == google.maps.GeocoderStatus.OK) {
                        var url_edit = $(location).attr('href');
                      
                        // TO get current Url//editsearch to map 29-2-16
                        function getUrlVars() {
                            var vars = [], hash;
                            var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
                            for (var i = 0; i < hashes.length; i++) {
                                hash = hashes[i].split('=');
                                vars.push(hash[0]);
                                vars[hash[0]] = hash[1];
                            }
                            return vars;
                        }
                        
                        
                        if (window.location.href.indexOf("searchId") > -1 || window.location.href.indexOf("Latitude") > -1 && window.location.href.indexOf("Longitude") > -1 && city_new != 1)//|| window.location.href.indexOf("city") > -1
                        {
                         
                            latitude = getUrlVars()["Latitude"];
                            longitude = getUrlVars()["Longitude"];
                            editsearch_mapFlag = 1;
                          //  alert(url_edit.toLowerCase().indexOf("latitude"));
                        }
                        else                            
                            if (city_new == 1) {
                              
                                latitude = results[0].geometry.location.lat();
                                longitude = results[0].geometry.location.lng();
                                
                            }
                        else
                        if (document.getElementById("hdf_lat").value == "" && document.getElementById("hdf_lng").value == "") {
                          
                            latitude = results[0].geometry.location.lat();
                            longitude = results[0].geometry.location.lng();
                        }
                       
                            else
                                if (city_default == 1)
                                {
                                   
                                    latitude = results[0].geometry.location.lat();
                                    longitude = results[0].geometry.location.lng();
                                }
                                else {
                                   
                                    latitude = document.getElementById("hdf_lat").value;
                                    longitude = document.getElementById("hdf_lng").value;
                                }
                      
                        $.MapCluster.map_creation(latitude, longitude);
                       
                    }
                });
            }
        },
       
        map_creation:function(latitude,longitude)
        {
          
            var toggle_poly_flag = 0;
         
            var new_search = document.getElementById("query_str_HF").value;
            var new_search_place = document.getElementById("query_str_place_HF").value;
            var map = new google.maps.Map(
                                      document.getElementById("GoogleMap1"), {
                                          // center: new google.maps.LatLng(Lat, Lng),
                                          center: new google.maps.LatLng(latitude, longitude),
                                          zoom: 12,
                                          mapTypeId: google.maps.MapTypeId.ROADMAP,
                                          mapTypeControl: true,
                                          mapTypeControlOptions: {
                                              style: google.maps.MapTypeControlStyle.HORIZONTAL_BAR,
                                              position: google.maps.ControlPosition.RIGHT_TOP
                                          },
                                      });
         
            //var map = new google.maps.Map(
            //      document.getElementById("GoogleMap1"), {
            //          // center: new google.maps.LatLng(Lat, Lng),
            //          center: new google.maps.LatLng(36.168578, -86.782542),
            //          zoom: 14,
            //          mapTypeId: google.maps.MapTypeId.ROADMAP,
            //      });
            //FreehandPolygon
           
            //var ii = 0;
            /*------------------------------------------------------
                Hide Clear Region Button when page reload
            ------------------------------------------------------*/
            if (toggle_clear_flag != 1) {
                $("#clearR").hide();
            }
                //$("#clearR").show();
            if (toggle_poly_flag == 1) {
              
                $("#drawR").show();
            }            
            function clearpoly() {                
                $("#clearPoly a").click(function (e) {//clearPoly
                    //To add border circle color after draw button disable
                    //$("#clearR").click(function () {
                    //$("#clearR").addClass("addBorder");
                    //    $("#drawR").removeClass("addBorder");
                    //});
                    toggle_poly_flag = 1;
                    // ------ Hide the Clear Poly Button and Show Draw Region Button
                        $("#clearR").hide();
                        $("#drawR").show();

                    poly_flag = 0;                   
                    create_poly();             
                        latitude = document.getElementById("hdf_lat").value;
                        longitude = document.getElementById("hdf_lng").value;               
                       $.MapCluster.map_creation(latitude, longitude);                   
                        poly.setMap(null);                   
                });                
            }
          
            function drawFreeHand() {
               
                //the polygon
                poly = new google.maps.Polyline({ map: map, clickable: false });
                //move-listener
                var move = google.maps.event.addListener(map, 'mousemove', function (e) {
                    poly.getPath().push(e.latLng);
                });
                //mouseup-listener
                google.maps.event.addListenerOnce(map, 'mouseup', function (e) {
                    google.maps.event.removeListener(move);
                    var path = poly.getPath();
                    poly.setMap(null);                    
                    var theArrayofLatLng = path.j;
                    var ArrayforPolygontoUse = GDouglasPeucker(theArrayofLatLng, 100);
                    console.log("ArrayforPolygontoUse", ArrayforPolygontoUse);
                    
                   polyOptions = {
                        map: map,
                        fillColor: '#0099FF',
                        fillOpacity: 0.7,
                        strokeColor: '#AA2143',
                        strokeWeight: 2,
                        clickable: false,
                        zIndex: 1,
                        path: ArrayforPolygontoUse,
                        editable: false
                    }

                    poly = new google.maps.Polygon(polyOptions);
                     map.fitBounds(poly.getBounds());                   
                   
                     google.maps.event.clearListeners(map.getDiv(), 'mousedown');              
                    
                        clearpoly();
                        enable();                    
                    var bounds = poly.getBounds();
                    var Y = map.getCenter();
                    latitudeA = Y.lat();
                    longitudeA = Y.lng();
                    NE = bounds.getNorthEast();
                    SW = bounds.getSouthWest();
                    var NW = new google.maps.LatLng(NE.lat(), SW.lng());
                    var SE = new google.maps.LatLng(SW.lat(), NE.lng());                  
                   
                    create_poly();
                    //To load a map while polygon drwn
                    $.MapCluster.map_creation(latitude, longitude);                    
                });
                //$("#clearR").show();
                
               
            }
            google.maps.Polygon.prototype.getBounds = function () {
                var bounds = new google.maps.LatLngBounds();
                var paths = this.getPaths();
                var path;
                for (var i = 0; i < paths.getLength() ; i++) {
                    path = paths.getAt(i);
                    for (var ii = 0; ii < path.getLength() ; ii++) {
                        bounds.extend(path.getAt(ii));
                    }
                }
                return bounds;
            }
          
            function disable() {
                map.setOptions({
                    draggable: false,
                    zoomControl: false,
                    scrollwheel: false,
                    disableDoubleClickZoom: false
                });
            }

            function enable() {
                map.setOptions({
                    draggable: true,
                    zoomControl: true,
                    scrollwheel: true,
                    disableDoubleClickZoom: true
                });
            }
            
            
            //FreehandPolygon  29-1-16
            $("#draw a").click(function (e) {
              
                //To add border circle color after draw button enable
                //$("#drawR").click(function () {
                // commented code
                    //$("#drawR").addClass("addBorder");
                    //$("#clearR").removeClass("addBorder");
                // commented code
                    //$("#drawR").toggleClass("btndraw");
                //});
                //$("#drawR").toggleClass("btndraw");
                $("#drawR").hide();
                $("#clearR").show();
                toggle_clear_flag = 1;

                disable();
                //e.preventDefault();
                google.maps.event.addDomListener(map.getDiv(), 'mousedown', function (e) {
                    
                    poly_flag = 1;
                    drawFreeHand();                 
                 
                });
              
            });
            
            var search_inputs = $.extend({}, plugin.SearchInputs, null);
            var create_poly = function () {
               
                MapSaveSearchFlag = 1;
                var SearchCount_forsearch = document.getElementById('searchcount_flag').value;
                if (SearchCount_forsearch < 20 && city_new!=1) {
                  
                        var querystr_new = null;
                        querystr_new = new_search_place;
                        FinalQueryString = new_search_place + '&Latitude=' + latitude + '&Longitude=' + longitude;
                        window.history.pushState(null, null, 'http://' + document.domain + '/map' + FinalQueryString);

                        search_inputs.SearchColumns = "*";
                        search_inputs.QueryString = querystr_new;
                        $("#prop_guide").empty();
                        $("#property_count").empty();

                        if (xhr != null) {
                            xhr.abort();
                            xhr = null;
                        }
                        xhr = $.ajax({
                            type: "POST",
                            url: plugin.optsAS.servicesFramework.getServiceRoot(plugin.optsAdvncSearch.Routmapper) + 'RetsServices/Get_Map_Properties',
                            dataType: 'json',
                            async: true,
                            data: search_inputs,
                            beforeSend: function () {
                            },
                            complete: function () {
                            },
                            success: function (data1) {
                                var contentString1 = '<div id="content">' +
                                                     '</div>';
                                var infowindow11 = new google.maps.InfoWindow({
                                    maxwidth: 30,
                                    content: contentString1,
                                });

                                var mapdata_new = {};
                                mapdata_new = data1.server_result;

                                propertymarker = [];
                                propertymarker1 = [];
                                var mcOptions1;
                                var latlng11 = [];
                                var flag_prop_guide11 = 0, flag_prop_guide22 = 0, flag_prop_guide33 = 0, flag_prop_guide44 = 0, flag_prop_guide55 = 0, flag_prop_guide66 = 0, flag_prop_guide77 = 0, flag_prop_guide88 = 0, flag_prop_guide99 = 0, flag_prop_guide1010 = 0;

                                if (mapdata_new.length > 0) {

                                    var prop_list_count1 = '<div>' + '<b class="txt-style_PT list_count_cls">' + mapdata_new.length + '</b>' + '&nbsp&nbsp<div class="txt-style_PT list_count_cls1"><b>Properties Found in Area</b></div></div>' + '</div>';
                                    $("#property_count").append(prop_list_count1);
                                    for (var i = 0; i < mapdata_new.length; i++) {
                                        Lat[i] = mapdata_new[i].Latitude;
                                        Lng[i] = mapdata_new[i].Longitude;
                                        var data_new1 = mapdata_new[i];

                                        ($("#hdf_lat").val(Lat[0]));
                                        ($("#hdf_lng").val(Lng[0]));
                                        var prop_guide_all = "";
                                        latlng11 = new google.maps.LatLng(Lat[i], Lng[i]);
                                        var prop_guide11 = "", prop_guide22 = "", prop_guide33 = "", prop_guide44 = "", prop_guide55 = "", prop_guide66 = "", prop_guide66 = "", prop_guide77 = "", prop_guide88 = "", prop_guide99 = "", prop_guide1010 = "";
                                        mapdata_new[i].TotalPrice = mapdata_new[i].TotalPrice.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");//toString().replace(/(\d+)(\d{3})/, '$1' + ',' + '$2');//adding comma in TotalPrice
                                        //add markers and images for markers as per propertytype
                                        switch (mapdata_new[i].Prop_num) {

                                            case "1":
                                                marker = new google.maps.Marker({ position: latlng11, icon: 'images/house-01.png', map: map, });
                                                flag_prop_guide11 = flag_prop_guide11 + 1;
                                                prop_guide11 = '<div style="float:left;left:50%;"><div style="float:left;"><img src="images/house-01.png" class="gm-style img"height="15";width="15";/></div>&nbsp' + '<div style="float:left;"><b>' + mapdata_new[i].Prop_label + '</b></div></div>';
                                                if (flag_prop_guide11 == 1) {
                                                    prop_guide_all += prop_guide11;
                                                }
                                                break;
                                            case "2":
                                                marker = new google.maps.Marker({ position: latlng11, icon: 'images/house-02.png', map: map, });
                                                flag_prop_guide22 = flag_prop_guide22 + 1;
                                                prop_guide22 = '<div style="float:left;left:50%;"><div style="float:left;"><img src="images/house-02.png" class="gm-style img"height="15";width="15";/></div>&nbsp' + '<div style="float:left;"><b>' + mapdata_new[i].Prop_label + '</b></div></div>';
                                                if (flag_prop_guide22 == 1) {
                                                    prop_guide_all += prop_guide22;
                                                }
                                                break;
                                            case "3":
                                                marker = new google.maps.Marker({ position: latlng11, icon: 'images/house-03.png', map: map, });
                                                flag_prop_guide33 = flag_prop_guide33 + 1;
                                                prop_guide33 = '<div style="float:left;left:50%;"><div style="float:left;"><img src="images/house-03.png" class="gm-style img"height="15";width="15";/></div>&nbsp' + '<div style="float:left;"><b>' + mapdata_new[i].Prop_label + '</b></div></div>';
                                                if (flag_prop_guide33 == 1) {
                                                    prop_guide_all += prop_guide33;
                                                }
                                                break;
                                            case "4":
                                                marker = new google.maps.Marker({ position: latlng11, icon: 'images/house-04.png', map: map, });
                                                flag_prop_guide44 = flag_prop_guide44 + 1;
                                                prop_guide44 = '<div style="float:left;"><div style="float:left;"><img src="images/house-04.png" class="gm-style img"height="15";width="15";/></div>&nbsp' + '<div style="float:left;"><b>' + mapdata_new[i].Prop_label + '</b></div></div>';
                                                if (flag_prop_guide44 == 1) {
                                                    prop_guide_all += prop_guide44;
                                                }
                                                break;
                                            case "5":
                                                marker = new google.maps.Marker({ position: latlng11, icon: 'images/house-05.png', map: map, });
                                                flag_prop_guide55 = flag_prop_guide55 + 1;
                                                prop_guide55 = '<div style="float:left;left:50%;"><div style="float:left;"><img src="images/house-05.png" class="gm-style img"height="15";width="15";/></div>&nbsp' + '<div style="float:left;"><b>' + mapdata_new[i].Prop_label + '</b></div></div>';
                                                if (flag_prop_guide55 == 1) {
                                                    prop_guide_all += prop_guide55;
                                                }
                                                break;
                                            case "6":
                                                marker = new google.maps.Marker({ position: latlng11, icon: 'images/house-06.png', map: map, });
                                                flag_prop_guide66 = flag_prop_guide66 + 1;
                                                prop_guide66 = '<div style="float:left;left:50%;"><div style="float:left;"><img src="images/house-06.png" class="gm-style img"height="15";width="15";/></div>&nbsp' + '<div style="float:left;"><b>' + mapdata_new[i].Prop_label + '</b></div></div>';
                                                if (flag_prop_guide66 == 1) {
                                                    prop_guide_all += prop_guide66;
                                                }
                                                break;
                                            case "7":
                                                marker = new google.maps.Marker({ position: latlng11, icon: 'images/house-07.png', map: map, });
                                                flag_prop_guide77 = flag_prop_guide77 + 1;
                                                prop_guide77 = '<div style="float:left;left:50%;"><div style="float:left;"><img src="images/house-07.png" class="gm-style img"height="15";width="15";/></div>&nbsp' + '<div style="float:left;"><b>' + mapdata_new[i].Prop_label + '</b></div></div>';
                                                if (flag_prop_guide77 == 1) {
                                                    prop_guide_all += prop_guide77;
                                                }
                                                break;
                                            case "8":
                                                marker = new google.maps.Marker({ position: latlng11, icon: 'images/house-08.png', map: map, });
                                                flag_prop_guide88 = flag_prop_guide88 + 1;
                                                prop_guide88 = '<div style="float:left;left:50%;"><div style="float:left;"><img src="images/house-08.png" class="gm-style img"height="15";width="15";/></div>&nbsp' + '<div style="float:left;"><b>' + mapdata_new[i].Prop_label + '</b></div></div>';
                                                if (flag_prop_guide88 == 1) {
                                                    prop_guide_all += prop_guide88;
                                                }
                                                break;
                                            case "9":
                                                marker = new google.maps.Marker({ position: latlng11, icon: 'images/house-09.png', map: map, });
                                                flag_prop_guide99 = flag_prop_guide99 + 1;
                                                prop_guide99 = '<div style="float:left;left:50%;"><div style="float:left;"><img src="images/house-09.png" class="gm-style img"height="15";width="15";/></div>&nbsp' + '<div style="float:left;"><b>Townhouse</b></div></div>';
                                                if (flag_prop_guide99 == 1) {
                                                    prop_guide_all += prop_guide99;
                                                }
                                                break;
                                            case "10":
                                                marker = new google.maps.Marker({ position: latlng11, icon: 'images/house-10.png', map: map, });
                                                flag_prop_guide1010 = flag_prop_guide1010 + 1;
                                                prop_guide1010 = '<div style="float:left;left:50%;"><div style="float:left;"><img src="images/house-10.png" class="gm-style img"height="15";width="15";/></div>&nbsp' + '<div style="float:left;"><b>Townhouse</b></div></div>';
                                                if (flag_prop_guide1010 == 1) {
                                                    prop_guide_all += prop_guide1010;
                                                }
                                                break;
                                        }
                                      
                                        if (mapdata_new.length < 5) {
                                            map.setCenter(marker.position);
                                            //map.setCenter(bounds.getCenter());
                                        }
                                        if (prop_guide11.length > 0 && flag_prop_guide11 == 1 || prop_guide22.length > 0 && flag_prop_guide22 == 1 || prop_guide33.length > 0 && flag_prop_guide33 == 1 || prop_guide44.length > 0 && flag_prop_guide44 == 1 || prop_guide55.length > 0 && flag_prop_guide55 == 1 || prop_guide66.length > 0 && flag_prop_guide66 == 1 || prop_guide77.length > 0 && flag_prop_guide77 == 1 || prop_guide88.length > 0 && flag_prop_guide88 == 1 || prop_guide99.length > 0 && flag_prop_guide99 == 1 || prop_guide1010.length > 0 && flag_prop_guide1010 == 1) {
                                            // $("#prop_guide").append(prop_guide11 + prop_guide22 + prop_guide33 + prop_guide44 + prop_guide55);
                                            $("#prop_guide").append(prop_guide_all);
                                            prop_guide_all = "";
                                            // flag_prop_guide = 0;
                                        }
                                       
                                        if (idle_f == 1 && bounds_changed == 1) {
                                           
                                           // map.setCenter(bounds.getCenter());
                                            map.setCenter(marker.position);
                                        }

                                        propertymarker.push(marker);
                                        (function (marker, data1) {

                                            //google.maps.event.addListener(marker, 'click', loadURL(data));                                   
                                            google.maps.event.addListener(marker, "click", function (e) {

                                                $('#PropertyDetails').bPopup({

                                                    modalClose: true,
                                                    escClose: true,
                                                    transition: 'slideBack',
                                                    transitionClose: 'slideBack',
                                                    opacity: 0.0,
                                                    speed: 300,

                                                    zIndex: 2,
                                                    positionStyle: 'fixed'

                                                });
                                                //debugger;//normalmapdata_new[i]
                                                // 
                                                if (mapdata_new.length == 1) {
                                                   
                                                    $("#SelectedListId").val(mapdata_new[0].MLSId);
                                                    
                                                    $.MapCluster.MapPropertyDetails(mapdata_new[0].MLSId);

                                                    walkscore_data(mapdata_new[0].Latitude, mapdata_new[0].Longitude);
                                                }
                                                else {
                                                  
                                                    $("#SelectedListId").val(data1.MLSId);
                                                    $.MapCluster.MapPropertyDetails(data1.MLSId);
                                                    walkscore_data(data1.Latitude, data1.Longitude);
                                                   
                                                }
                                                //to take your marker at center when click event happen
                                                //map.setCenter(marker.position);
                                                marker.setMap(map);

                                            });
                                            google.maps.event.addListener(marker, "mouseover", function (e) {
                                               
                                                if (data1.PrimaryPhotoURL == null || data1.PrimaryPhotoURL == '') {
                                                    data1.PrimaryPhotoURL = 'images/NoPreview.jpg';
                                                }

                                                data1.TotalPrice = data1.TotalPrice.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");//toString().replace(/(\d+)(\d{3})/, '$1' + ',' + '$2');
                                                var iwContent1 = '<div id="iw_container">' +
                                                                    '<div class="iw_title mp-data-add">' + data1.CombineAddress +
                                                                    '</div>' +
                                                                    '<table>' +
                                                                      '<tr>' +
                                                                       '<td><img src=' + data1.PrimaryPhotoURL + ' class="gm-style img" height="50" width="50"/>' + '</td>' +

                                                                        '<td><table><tr><td class="data-price-st"><b>&nbsp$</b>' + data1.TotalPrice + '</td></tr>' +
                                                '<tr><td>' + '&nbsp&nbsp' + 'Bath:' + '&nbsp' + data1.TotalBaths + '&nbsp&nbsp' + 'BEd:' + '&nbsp' + data1.TotalBeds + '</td></tr>'
                                                                         + '</table>' +
                                                                      '</tr>' +
                                                                      '</table>' +
                                                                      '<div id="iw_container">' +
                                                                      '<div width="100">' + data1.OfficeName + '</div>';

                                                infowindow11.setContent(iwContent1);

                                                findlistdiv(data1.MLSId);
                                                infowindow11.open(map, marker);
                                            });

                                            google.maps.event.addListener(marker, "mouseout", function (e) {
                                                infowindow11.close();
                                            });


                                        })(marker, data1);
                                    }
                                  
                                    if (editsearch_mapFlag != 1) {
                                        map.setCenter(marker.position);
                                    }
                                    var clusterStyles = [
                                                                    {
                                                                        textColor: 'black',
                                                                        url: location.href.substring(0, location.href.lastIndexOf("/") + 1) + 'images/mapimg1.png',
                                                                        height: 25,
                                                                        width: 25
                                                                    },
                                                                    {
                                                                        textColor: 'white',
                                                                        url: location.href.substring(0, location.href.lastIndexOf("/") + 1) + 'images/radiobutton-checked-md.png',
                                                                        height: 25,
                                                                        width: 25
                                                                    },
                                                                    {
                                                                        textColor: 'white',
                                                                        url: location.href.substring(0, location.href.lastIndexOf("/") + 1) + 'images/mapimg2.png',
                                                                        height: 26,
                                                                        width: 26
                                                                    }];
                                    //create marker cluster
                                    var markerCluster = new MarkerClusterer(map, propertymarker, {
                                        //gridSize: 40,
                                        minimumClusterSize: 8,
                                        styles: clusterStyles,

                                        calculator: function (markers, numStyles) {
                                            if (markers.length >= 50) return { text: markers.length, index: 3 };
                                            if (markers.length >= 5) return { text: markers.length, index: 2 };
                                            return { text: markers.length, index: 0 };
                                        }
                                    });
                                }

                                var divlist1 = $("#FEL_listView").kendoListView({
                                    dataSource: mapdata_new,
                                    template: kendo.template($('#ListTemplate').html()),
                                    dataBound: function () {
                                    }

                                });
                            }
                        });

                        // var Property_ClickMarkers = [];
                        var OldDiv1;
                        var listdata1 = null;
                        function findlistdiv(ListId) {

                            listdata1 = $('#FEL_listView').find('#' + ListId);
                            try {
                                OldDiv1.removeClass('list_propert');
                                OldDiv1.addClass('detail_list');
                            }
                            catch (E) {
                            }

                            listdata1.removeClass('detail_list');
                            listdata1.addClass('list_propert');
                            OldDiv1 = listdata1;

                            $("html, body").animate({ scrollTop: 0 }, "slow");
                            $('#FEL_listView').scrollTop($('#FEL_listView').scrollTop() + listdata1.position().top);//offset()
                            
                        }                   
                }
                else {

                    google.maps.event.addListener(map, 'bounds_changed', function () {
                       
                        //for dragg and search map event..
                        //var ne;
                        //var sw;
                        var timeout;
                        window.clearTimeout(timeout);
                        timeout = window.setTimeout(function () {
                            //do stuff on event                    
                        
                            this.idleSkipped = false;
                            if (poly_flag == 0) {//not having polygon
                               
                                var bounds = map.getBounds();
                                var x = map.getCenter();
                                latitudeA = x.lat();
                                longitudeA = x.lng();
                                ne = bounds.getNorthEast();
                                sw = bounds.getSouthWest();
                            }
                            else
                                if (poly_flag == 1 ) {
                                    ne = NE;
                                    sw = SW;                                   
                                }
                            //to allow map to move on another place search after poly draw
                           // if (poly_flag_call == 1) { poly_flag_2call = 1; }
                            $("#hdfLatitude").val(latitudeA);
                            $("#hdfLongitude").val(longitudeA);
                            $("#hdfNorthEast").val(ne.lat() + ',' + ne.lng());
                            $("#hdfSouthWest").val(sw.lat() + ',' + sw.lng());
                           
                            var querystr = null;
                            var getCoordinatesfromQueryString_new = function () {
                               
                                var NS_data = document.getElementById("Ne_Sw_flag").value;
                                bounds_changed = document.getElementById("bound_changeflag").value;
                                if (city_new == 1) {
                                    querystr = new_search + "&NorthEast=" + ne.lat() + ',' + ne.lng() + "&SouthWest=" + sw.lat() + ',' + sw.lng();
                                    FinalQueryString = new_search + '&Latitude=' + latitudeA + '&Longitude=' + longitudeA + "&NorthEast=" + ne.lat() + ',' + ne.lng() + "&SouthWest=" + sw.lat() + ',' + sw.lng();
                                    window.history.pushState(null, null, 'http://' + document.domain + '/map' + FinalQueryString);
                                }
                                else
                                    if (bounds_changed != "") {
                                        querystr = new_search_place + NS_data;
                                        FinalQueryString = new_search_place + '&Latitude=' + latitudeA + '&Longitude=' + longitudeA + NS_data;
                                        window.history.pushState(null, null, 'http://' + document.domain + '/map' + FinalQueryString);

                                        //querystr = new_search_place + "&NorthEast=" + ne.lat() + ',' + ne.lng() + "&SouthWest=" + sw.lat() + ',' + sw.lng();
                                        //FinalQueryString = new_search_place + '&Latitude=' + latitude + '&Longitude=' + longitude + "&NorthEast=" + ne.lat() + ',' + ne.lng() + "&SouthWest=" + sw.lat() + ',' + sw.lng();
                                        //window.history.pushState(null, null, 'http://' + document.domain + '/clustermap' + FinalQueryString);
                                    }
                                    else {
                                        querystr = new_search + "&NorthEast=" + ne.lat() + ',' + ne.lng() + "&SouthWest=" + sw.lat() + ',' + sw.lng();
                                        FinalQueryString = new_search + '&Latitude=' + latitudeA + '&Longitude=' + longitudeA + "&NorthEast=" + ne.lat() + ',' + ne.lng() + "&SouthWest=" + sw.lat() + ',' + sw.lng();
                                        window.history.pushState(null, null, 'http://' + document.domain + '/map' + FinalQueryString);

                                    }
                               
                                ($("#Ne_Sw_flag").val("&NorthEast=" + ne.lat() + ',' + ne.lng() + "&SouthWest=" + sw.lat() + ',' + sw.lng()));

                                ($("#idle_flag").val(1));

                            };

                            getCoordinatesfromQueryString_new();

                            //alert(querystr);
                            //var searchUrl = '?Property_type=SingleFamily%2CCondo%2CTownhomes%2Cmultyfamily%2CCommercial%2CLand%2CAuction&city=Nashville' + '&NorthEast=' + ne.lat() + ',' + ne.lng() + '&SouthWest=' + sw.lat() + ',' + sw.lng();

                            search_inputs.SearchColumns = "*";
                            search_inputs.QueryString = querystr;

                            //var PropertyHTMLTemplate = "";
                            //var Templatecontent;

                            //$.ajax({
                            //    url: '/DesktopModules/ClusterMarker/map.html',
                            //    type: 'get',
                            //    async: false,
                            //    success: function (html) {
                            //        PropertyHTMLTemplate = html;
                            //    }
                            //});
                           
                            $("#prop_guide").empty();
                            $("#property_count").empty();
                            if (xhr != null) {
                                xhr.abort();
                                xhr = null;
                            }
                            xhr = $.ajax({
                                type: "POST",
                                url: plugin.optsAS.servicesFramework.getServiceRoot(plugin.optsAdvncSearch.Routmapper) + 'RetsServices/Get_Map_Properties',
                                dataType: 'json',
                                async: true,
                                data: search_inputs,
                                beforeSend: function () {
                                },
                                complete: function () {
                                },
                                success: function (data) {
                                    var contentString = '<div id="content">' +
                                                         '</div>';
                                    var infowindow = new google.maps.InfoWindow({
                                        maxwidth: 30,
                                        content: contentString,
                                    });

                                    //For showing search count msg if properties more than 500
                                    SearchCount = document.getElementById('searchcount_flag').value;
                                    if (SearchCount > 500) {
                                        $("#first").show();
                                        $("#first span.test").text("Showing only 500 Properties. Zoom in to precise search.");
                                    }
                                    else {
                                        $("#first").hide();
                                    }

                                    var mapdata = {};
                                    mapdata = data.server_result;
                                    var prop_list_count
                                  
                                    if (mapdata.length <= 500) {
                                        prop_list_count = '<div>' + '<b class="txt-style_PT list_count_cls">' + mapdata.length + '</b>' + '&nbsp&nbsp<div class="txt-style_PT list_count_cls1"><b>Properties Found in Area</b></div></div>' + '</div>';
                                    }
                                    //if (mapdata.length = 500) {
                                    //    prop_list_count = '<div>' + '<b class="txt-style_PT" style="float: left;padding-right: 10px; font-size: 18px;">' + mapdata.length +'+'+ '</b>' + '&nbsp&nbsp<div class="txt-style_PT" style="float: left;"><b>Properties Found in Area</b></div></div>' + '</div>';
                                    //}
                                    $("#property_count").append(prop_list_count);
                                    //  var json = JSON.stringify(mapdata);                      
                                    propertymarker = [];
                                    propertymarker1 = [];
                                    
                                    var mcOptions;
                                    var latlng = [];
                                    var prop_guide_all_1 = "";
                                    var flag_prop_guide1 = 0, flag_prop_guide2 = 0, flag_prop_guide3 = 0, flag_prop_guide4 = 0, flag_prop_guide5 = 0, flag_prop_guide6 = 0, flag_prop_guide7 = 0, flag_prop_guide8 = 0, flag_prop_guide9 = 0, flag_prop_guide10 = 0;
                                    var prop_list_count_flag = 0;
                                    if (mapdata.length > 0) {
                                        
                                        for (var i = 0; i < mapdata.length; i++) {
                                            Lat[i] = mapdata[i].Latitude;
                                            Lng[i] = mapdata[i].Longitude;
                                            var data = mapdata[i];

                                            ($("#hdf_lat").val(Lat[0]));
                                            ($("#hdf_lng").val(Lng[0]));

                                            latlng = new google.maps.LatLng(Lat[i], Lng[i]);
                                            var prop_guide1 = "", prop_guide2 = "", prop_guide3 = "", prop_guide4 = "", prop_guide5 = "", prop_guide6 = "", prop_guide7 = "", prop_guide8 = "", prop_guide9 = "", prop_guide10 = "";
                                            mapdata[i].TotalPrice = mapdata[i].TotalPrice.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");//toString().replace(/(\d+)(\d{3})/, '$1' + ',' + '$2');
                                            //add markers and images for markers as per propertytype
                                            switch (mapdata[i].Prop_num) {
                                                case "1":
                                                    marker = new google.maps.Marker({ position: latlng,icon: 'images/house-01.png', map: map,});
                                                    flag_prop_guide1 = flag_prop_guide1 + 1;
                                                    prop_guide1 = '<div style="float:left;left:50%;"><div style="float:left;"><img src="images/house-01.png" class="gm-style img"height="15";width="15";/></div>&nbsp' + '<div style=float:left;"><b>' + mapdata[i].Prop_label + '</b></div></div>';
                                                    if (flag_prop_guide1 == 1) {
                                                        prop_guide_all_1 += prop_guide1;
                                                    }
                                                    break;
                                                case "2":
                                                    marker = new google.maps.Marker({ position: latlng, icon: 'images/house-02.png', map: map, });
                                                    flag_prop_guide2 = flag_prop_guide2 + 1;
                                                    prop_guide2 = '<div style="float:left;left:50%;"><div style="float:left;"><img src="images/house-02.png" class="gm-style img"height="15";width="15";/></div>&nbsp' + '<div style=float:left;"><b>' + mapdata[i].Prop_label + '</b></div></div>';
                                                    if (flag_prop_guide2 == 1) {
                                                        prop_guide_all_1 += prop_guide2;
                                                    }
                                                    break;
                                               
                                                case "3":
                                                    marker = new google.maps.Marker({ position: latlng, icon: 'images/house-03.png', map: map,});
                                                    flag_prop_guide3 = flag_prop_guide3 + 1;
                                                    prop_guide3 = '<div style="float:left;"><div style="float:left;"><img src="images/house-03.png" class="gm-style img"height="15";width="15";/></div>&nbsp' + '<div style=float:left;"><b>' + mapdata[i].Prop_label + '</b></div></div>';
                                                    if (flag_prop_guide3 == 1) {
                                                        prop_guide_all_1 += prop_guide3;
                                                    }
                                                    break;
                                                case "4":
                                                    marker = new google.maps.Marker({ position: latlng, icon: 'images/house-04.png',map: map,});
                                                    flag_prop_guide4 = flag_prop_guide4 + 1;
                                                    prop_guide4 = '<div style="float:left;left:50%;"><div style="float:left;"><img src="images/house-04.png" class="gm-style img"height="15";width="15";/></div>&nbsp' + '<div style=float:left;"><b>' + mapdata[i].Prop_label + '</b></div></div>';
                                                    if (flag_prop_guide4 == 1) {
                                                        prop_guide_all_1 += prop_guide4;
                                                    }
                                                    break;
                                                case "5":
                                                    marker = new google.maps.Marker({position: latlng,icon: 'images/house-05.png', map: map,});
                                                    flag_prop_guide5 = flag_prop_guide5 + 1;
                                                    prop_guide5 = '<div style="float:left;left:50%;"><div style="float:left;"><img src="images/house-05.png" class="gm-style img"height="15";width="15";/></div>&nbsp' + '<div style=float:left;"><b>' + mapdata[i].Prop_label + '</b></div></div>';
                                                    if (flag_prop_guide5==1) {
                                                        prop_guide_all_1 += prop_guide5;
                                                    }
                                                    break;
                                                case "6": marker = new google.maps.Marker({position: latlng,icon: 'images/house-06.png',map: map,});
                                                    flag_prop_guide6 = flag_prop_guide6 + 1;
                                                    prop_guide6 = '<div style="float:left;left:50%;"><div style="float:left;"><img src="images/house-06.png" class="gm-style img"height="15";width="15";/></div>&nbsp' + '<div style=float:left;"><b>' + mapdata[i].Prop_label + '</b></div></div>';
                                                    if (flag_prop_guide6==1) {
                                                        prop_guide_all_1 += prop_guide6;
                                                    }
                                                    break;
                                                case "7": marker = new google.maps.Marker({ position: latlng, icon: 'images/house-07.png', map: map, });
                                                    flag_prop_guide7 = flag_prop_guide7 + 1;
                                                    prop_guide7 = '<div style="float:left;left:50%;"><div style="float:left;"><img src="images/house-07.png" class="gm-style img"height="15";width="15";/></div>&nbsp' + '<div style=float:left;"><b>' + mapdata[i].Prop_label + '</b></div></div>';
                                                    if (flag_prop_guide7 == 1) {
                                                        prop_guide_all_1 += prop_guide7;
                                                    }
                                                    break;
                                                case "8": marker = new google.maps.Marker({ position: latlng, icon: 'images/house-08.png', map: map, });
                                                    flag_prop_guide8 = flag_prop_guide8 + 1;
                                                    prop_guide8 = '<div style="float:left;left:50%;"><div style="float:left;"><img src="images/house-08.png" class="gm-style img"height="15";width="15";/></div>&nbsp' + '<div style=float:left;"><b>' + mapdata[i].Prop_label + '</b></div></div>';
                                                    if (flag_prop_guide8 == 1) {
                                                        prop_guide_all_1 += prop_guide8;
                                                    }
                                                    break;
                                                case "9": marker = new google.maps.Marker({ position: latlng, icon: 'images/house-09.png', map: map, });
                                                    flag_prop_guide9 = flag_prop_guide9 + 1;
                                                    prop_guide9 = '<div style="float:left;left:50%;"><div style="float:left;"><img src="images/house-09.png" class="gm-style img"height="15";width="15";/></div>&nbsp' + '<div style=float:left;"><b>' + mapdata[i].Prop_label + '</b></div></div>';
                                                    if (flag_prop_guide9==1) {
                                                        prop_guide_all_1 += prop_guide9;
                                                    }
                                                    break;
                                                case "10": marker = new google.maps.Marker({ position: latlng, icon: 'images/house-10.png', map: map, });
                                                    flag_prop_guide10 = flag_prop_guide10 + 1;
                                                    prop_guide10 = '<div style="float:left;left:50%;"><div style="float:left;"><img src="images/house-10.png" class="gm-style img"height="15";width="15";/></div>&nbsp' + '<div style=float:left;"><b>' + mapdata[i].Prop_label + '</b></div></div>';
                                                    if (flag_prop_guide10 == 1) {
                                                        prop_guide_all_1 += prop_guide10;
                                                    }
                                                    break;
                                                    
                                            }
                                           
                                            //if (mapdata.length < 5) {
                                            //    debugger;
                                            //    map.fitBounds(bounds);
                                            //    map.setCenter(bounds.getCenter());
                                            //   // map.setCenter(marker.position);
                                            //}

                                            //$("body").append($newdiv1);
                                            //if (prop_guide1.length > 0 && flag_prop_guide1 == 1 || prop_guide2.length > 0 && flag_prop_guide2 == 1 || prop_guide3.length > 0 && flag_prop_guide3 == 1 || prop_guide4.length > 0 && flag_prop_guide4 == 1 || prop_guide5.length > 0 && flag_prop_guide5 == 1 || prop_guide6.length > 0 && flag_prop_guide6 == 1 || prop_guide7.length > 0 && flag_prop_guide7 == 1 ) {
                                            //    $("#prop_guide").append(prop_guide1 + prop_guide2 + prop_guide3 + prop_guide4 + prop_guide5 + prop_guide6 + prop_guide7);
                                            if (prop_guide1.length > 0 && flag_prop_guide1 == 1 || prop_guide2.length > 0 && flag_prop_guide2 == 1 || prop_guide3.length > 0 && flag_prop_guide3 == 1 || prop_guide4.length > 0 && flag_prop_guide4 == 1 || prop_guide5.length > 0 && flag_prop_guide5 == 1 || prop_guide6.length > 0 && flag_prop_guide6 == 1 || prop_guide7.length > 0 && flag_prop_guide7 == 1 || prop_guide8.length > 0 && flag_prop_guide8 == 1 || prop_guide9.length > 0 && flag_prop_guide9 == 1 || prop_guide10.length > 0 && flag_prop_guide10 == 1) {
                                                $("#prop_guide").append(prop_guide_all_1);
                                                prop_guide_all_1 = "";
                                            }
                                          
                                            if (idle_f == 1 && bounds_changed == 1) {
                                               
                                                map.fitBounds(bounds);
                                                map.setCenter(bounds.getCenter());
                                                //map.setCenter(marker.position);
                                            }
                                          
                                            propertymarker.push(marker);
                                            (function (marker, data) {
                                               

                                                //google.maps.event.addListener(marker, 'click', loadURL(data));                                   
                                                google.maps.event.addListener(marker, "click", function (e) {
                                                    //$('#FEL_listView').hide();
                                                    //$('#rightsidebar').show();
                                                    // $('.map-data').attr('style', 'width: 50% !important');
                                                    // $('.gm-style').attr('style', 'width: 50% !important');
                                                    // $('.col-map-2').css('display', 'block');
                                                  
                                                    $('#PropertyDetails').bPopup({
                                                        
                                                        modalClose: true,
                                                        escClose: true,
                                                        transition: 'slideBack',
                                                        transitionClose: 'slideBack',
                                                        opacity: 0.0,
                                                        speed: 300,

                                                        zIndex: 2,
                                                        positionStyle: 'fixed'

                                                    });
                                                    //debugger;//bounds
                                                    $("#SelectedListId").val(data.MLSId);
                                                   
                                                    $.MapCluster.MapPropertyDetails(data.MLSId);

                                                    walkscore_data(data.Latitude, data.Longitude);
                                                   
                                                    
                                                    //to take your marker at center when click event happen
                                                    //map.setCenter(marker.position);
                                                    marker.setMap(map);
                                                  
                                                });
                                                google.maps.event.addListener(marker, "mouseover", function (e) {
                                                   
                                                    if (data.PrimaryPhotoURL == null || data.PrimaryPhotoURL == '') {
                                                        data.PrimaryPhotoURL = 'images/NoPreview.jpg';
                                                    }
                                                    data.TotalPrice = data.TotalPrice.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");//toString().replace(/(\d+)(\d{3})/, '$1' + ',' + '$2');
                                                    var iwContent = '<div id="iw_container">' +
                                                                        '<div class="iw_title mp-data-add">' + data.CombineAddress +
                                                                        '</div>' +
                                                                        '<table>' +
                                                                          '<tr>' +
                                                                           '<td><img src=' + data.PrimaryPhotoURL + ' class="gm-style img" height="50" width="50" onerror="imgError(this);"/>' + '</td>' +

                                                                            '<td><table><tr><td class="data-price-st"><b>&nbsp$</b>' + data.TotalPrice + '</td></tr>' +
                                                    '<tr><td>' + '&nbsp&nbsp' + 'Bath:' + '&nbsp' + data.TotalBaths + '&nbsp&nbsp' + 'Bed:' + '&nbsp' + data.TotalBeds + '</td></tr>'
                                                                             + '</table>' +
                                                                          '</tr>' +
                                                                          '</table>' +
                                                                          '<div id="iw_container">' +
                                                                          '<div width="100">' + data.OfficeName + '</div>';

                                                    infowindow.setContent(iwContent);

                                                    findlistdiv(data.MLSId);
                                                    infowindow.open(map, marker);
                                                });

                                                google.maps.event.addListener(marker, "mouseout", function (e) {
                                                    infowindow.close();
                                                });

                                            })(marker, data);
                                        }
                                        if (poly_flag == 1 || mapdata.length < 50) {
                                           
                                            map.setCenter(marker.position);
                                            //poly_flag_call = 1;
                                        }
                                        var clusterStyles = [
                                                                  {
                                                                      textColor: 'black',
                                                                      url: location.href.substring(0, location.href.lastIndexOf("/") + 1) + 'images/mapimg1.png',
                                                                      height: 25,
                                                                      width: 25
                                                                  },
                                                                  {
                                                                      textColor: 'white',
                                                                      url: location.href.substring(0, location.href.lastIndexOf("/") + 1) + 'images/radiobutton-checked-md.png',
                                                                      height: 25,
                                                                      width: 25
                                                                  },
                                                                  {
                                                                      textColor: 'white',
                                                                      url: location.href.substring(0, location.href.lastIndexOf("/") + 1) + 'images/mapimg2.png',
                                                                      height: 26,
                                                                      width: 26
                                                                  }];
                                        //create marker cluster
                                        var markerCluster = new MarkerClusterer(map, propertymarker, {
                                            //gridSize: 40,
                                            minimumClusterSize: 8,
                                            styles: clusterStyles,

                                            calculator: function (markers, numStyles) {
                                                if (markers.length >= 50) return { text: markers.length, index: 3 };
                                                if (markers.length >= 5) return { text: markers.length, index: 2 };
                                                return { text: markers.length, index: 0 };
                                            }
                                        });
                                    }
                                  
                                    var divlist = $("#FEL_listView").kendoListView({
                                        dataSource: mapdata,
                                        template: kendo.template($('#ListTemplate').html()),
                                        dataBound: function () {
                                        }
                                    });
                                }
                            });

                            var Property_ClickMarkers = [];
                            var OldDiv;
                            var listdata = null;
                            function findlistdiv(ListId) {

                                listdata = $('#FEL_listView').find('#' + ListId);
                                try {
                                    OldDiv.removeClass('list_propert');
                                    OldDiv.addClass('detail_list');
                                }
                                catch (E) {
                                }

                                listdata.removeClass('detail_list');
                                listdata.addClass('list_propert');
                                OldDiv = listdata;

                                $("html, body").animate({ scrollTop: 0 }, "slow");
                                $('#FEL_listView').scrollTop($('#FEL_listView').scrollTop() + listdata.position().top);//offset()
                            }
                            //poly_flag = 0;
                        }, 500);

                    });
                }
            };
            
            create_poly();
           // poly = new google.maps.Polygon(polyOptions);
            map_reload=($("#hdfReload_flag").val(1));  
        },

        //Call For Data on propertyDetails template of Map
       MapPropertyDetails: function (MLSId) {
           var search_inputs = $.extend({}, plugin.SearchInputs, null);
          // debugger;
           search_inputs.PropertyID = MLSId;     
           search_inputs.XmlPath = plugin.optsAS.LeadId;

           if (MapSaveSearchFlag == 1) {
               $._Advance_Search.SaveSearchHistory("MapSearchHistory", "Map", FinalQueryString);

               MapSaveSearchFlag = 0;
           }
           var propertyHeaderTemplate = kendo.template($("#propertyHeaderTemplate").html());
           var propertyBasicTemplate = kendo.template($("#propertyBasicTemplate").html());
           var FeaturesTemplate = kendo.template($("#FeaturesTemplate").html());
           var LenderTemplate = kendo.template($("#LenderTemplate").html());
           var AgentTemplate = kendo.template($("#AgentTemplate").html());
           var publicRemark = kendo.template($("#PublicRemarkTemplate").html());
            
           $.ajax({
               type: "POST",
               url: plugin.optsAS.servicesFramework.getServiceRoot(plugin.optsAdvncSearch.Routmapper) + 'RetsServices/GetProperty',
               dataType: 'json',
               async: true,
               data: search_inputs,
               beforeSend: function () {
               },
               complete: function () {
               },
               success: function (data) {
                 
                   if (data.basicPropertyInfo.length == 0) {
                       debugger;
                      $(location).attr('href', "/outofmarket.aspx");
                   }
                   else {
                       $("#PD_Price").val(data.basicPropertyInfo[0].TotalPrice);
                       $("#PD_Interest").val(3.5);
                       $("#PD_Year").val(15);
                       if (data.basicPropertyInfo[0].Favourite) {
                           $("#favImage").attr('src', '/DesktopModules/_Lead_Activity/images/Add_fav.png');
                           $("#favImage").attr('title', 'Remove Favorite');
                       }
                       else if (!data.basicPropertyInfo[0].Favourite) {
                           $("#favImage").attr('src', '/DesktopModules/_Lead_Activity/images/black_heart.png');
                           $("#favImage").attr('title', 'Add To Favorite');
                       }

                       //for setting Viewed on home - chandan                       
                       $("#v" + data.basicPropertyInfo[0].ListId).addClass('redviewed view');
                       $.MapCluster.MortgageCalculate();

                       $.MapCluster.RelatedProperties(data.basicPropertyInfo[0]);

                       lt = data.basicPropertyInfo[0].Latitude;
                       ln = data.basicPropertyInfo[0].Longitude;
                       address = data.basicPropertyInfo[0].CombineAddress;
                       //$.MapCluster.walkscore_data(address);
                       $.MapCluster.InitGoogleMap();

                       $("#div_PublicRemark").html(kendo.render(publicRemark, data.basicPropertyInfo));
                       $("#div_propertyHeader").html(kendo.render(propertyHeaderTemplate, data.basicPropertyInfo));
                       $("#div_propertyBasic").html(kendo.render(propertyBasicTemplate, data.basicPropertyInfo));
                       $("#div_ExteriorFeatures").html(kendo.render(FeaturesTemplate, data.ExteriorFeatures));
                       $("#div_InteriorFeatures").html(kendo.render(FeaturesTemplate, data.InteriorFeatures));
                       $("#div_PropertyFeatures").html(kendo.render(FeaturesTemplate, data.PropertyFeatures));
                       //$("#div_OtherFeatures").html(kendo.render(FeaturesTemplate, data.basicPropertyInfo));
                       //$("#div_ExtraFeatures").html(kendo.render(FeaturesTemplate, data.basicPropertyInfo));


                       $('#PropertyRating').rateit('value', data.basicPropertyInfo[0].Rating);
                       //TO add slider images
                  }
             }
           });


          // $.MapCluster.InitGoogleMap();

                   $.ajax({
                       type: "POST",
                       url: plugin.optsAS.servicesFramework.getServiceRoot(plugin.optsAdvncSearch.Routmapper) + 'RetsServices/getPhotos_single',
                       dataType: 'json',
                       async: true,
                       data: search_inputs,
                       //beforeSend: opts.servicesFramework.setModuleHeaders,
                       beforeSend: function () {
                           //functions to be executed before sending AJAX request
                           // kendo.ui.progress($("#div_agent"), true);
                           //kendo.ui.progress($("#div_lender"), true);
                       },
                       complete: function () {
                           //functions to be executed after completing AJAX requests
                           // kendo.ui.progress($("#div_agent"), false);
                           // kendo.ui.progress($("#div_lender"), false);
                       },
                       success: function (PropertyPhotoLinks) {
                           var sliderHtml = "";
                           var MyImages = PropertyPhotoLinks;
                          
                           if (MyImages != null) {
                               sliderHtml = "<ul id='myGalleryPage'>";
                               imagesPreloaded = new Array();

                                $('.Property-img-thumb').attr("src", MyImages[0]);

                               // 1. Initialize fotorama manually.
                               var $fotoramaDiv = $('#divgalleryPage').fotorama();

                               // 2. Get the API object.
                               var fotorama = $fotoramaDiv.data('fotorama');

                               var propertyListData = "";
                               propertyListData = "[";

                               for (var i = 0; i < MyImages.length; i++) {
                                   propertyListData += '{ "img":"' + MyImages[i] + '", "thumb":"' + MyImages[i] + '", "fit": "scaledown"},';
                               }

                               var listjsondata = "";
                               listjsondata = propertyListData.replace(/,\s*$/, "") + "]";
                               listjsondata = (listjsondata.replace(/\s+/g, ""));
                               var obj = [];

                               obj = JSON.parse(listjsondata);

                               fotorama.load(obj);

                           }
                       }
                   });
                   //for lender
                   var search_inputs = $.extend({}, plugin.SearchInputs, null);
                   search_inputs.XmlPath = "-1";

                   $.ajax({
                       type: "POST",
                       url: plugin.optsAS.servicesFramework.getServiceRoot(plugin.optsAdvncSearch.Routmapper) + 'RetsServices/GetLender',
                       dataType: 'json',
                       async: true,
                       data: search_inputs,
                       //beforeSend: plugin.optsHome.servicesFramework.setModuleHeaders,
                       beforeSend: function () {
                           //functions to be executed before sending AJAX request
                           // kendo.ui.progress($("#div_agent"), true);
                           //kendo.ui.progress($("#div_lender"), true);
                       },
                       complete: function () {
                           //functions to be executed after completing AJAX requests
                           // kendo.ui.progress($("#div_agent"), false);
                           // kendo.ui.progress($("#div_lender"), false);
                       },
                       success: function (AgentAndLender) {
                           //alert(AgentAndLender.agent_dt);
                           //alert(AgentAndLender.lender_dt);
                           //$("#div_Agent").html(kendo.render(AgentTemplate, AgentAndLender.agent_dt));
                           $("#div_Lender").html(kendo.render(LenderTemplate, AgentAndLender.lender_dt));
                       }
                   });
           //map nearby
                   //kendo.ui.progress($("#map-sp"), true);
                   //$("#chkSchools").prop("checked", false);
                   //$("#chkEssentials").prop("checked", false);
                   //$("#chkActivities").prop("checked", false);
                   //$("#chkRestaurants").prop("checked", false);
                   //$("#chkEntertainment").prop("checked", false);
                   //$("#chkShopping").prop("checked", false);
                   $("#nearbyProps").prop("checked", false);
                   //$("#chkTraffic").prop("checked", false);
           //To add data in kendo template/
           // FOr lead popup 15-2-16
                 
                   var PropertyViewedCount = $.cookie('PropertyViewedCount');

                   if (PropertyViewedCount == undefined) {
                       $.cookie("PropertyViewedCount", "1", { path: '/' });
                   }
                   else {
                       PropertyViewedCount = TryParseInt($.cookie('PropertyViewedCount'), 0);
                       PropertyViewedCount = PropertyViewedCount + 1;
                       $.cookie("PropertyViewedCount", PropertyViewedCount, { path: '/' });
                   }
                   $('#PropertyDetails').bPopup({
                       modalClose: false,
                       escClose: false,
                       opacity: 0.0,
                       zIndex: 2,
                       positionStyle: 'fixed'

                   });

                   if (plugin.optsAS.LeadId == "-1" && plugin.optsAS.UserRole != "Agent" && $.cookie("SourceCampaign") == "Cookie Available") {
                       setTimeout(" $.LeadCapture.showLeadCapture();", 1000);
                   }

                   else if (plugin.optsAS.LeadId == "-1" && plugin.optsAS.UserRole != "Agent" && PropertyViewedCount > 1) {
                       setTimeout(" $.LeadCapture.showLeadCapture();", 1000);
                   }
       },      
        //To add realted properties
       RelatedProperties:function(prop_dt) {
                var search_inputs = $.extend({}, plugin.SearchInputs, null);
              
                search_inputs.SearchColumns = "MLSId,ListId,City,PrimaryPhotoURL,TotalPrice,TotalBaths,TotalBeds,PropertyType,Address,StreetName,Prop_Class";
                search_inputs.PropertyType = prop_dt.PropertyType;
                search_inputs.Prop_Class = prop_dt.Prop_Class;
                search_inputs.StreetName = prop_dt.StreetName;
                search_inputs.MLSId = prop_dt.MLSId;
                search_inputs.TotalBaths = prop_dt.TotalBaths;
                search_inputs.TotalBeds = prop_dt.TotalBeds;
               
            
                //switch (prop_dt.PropertyType)
                //{
                //    case "Res":
                //        prop_dt.PropertyType = "SingleFamily";
                //        break;
                //    case "Con":
                //        prop_dt.PropertyType = "Condo";
                //        break;
                //    case "Com":
                //        prop_dt.PropertyType = "Business";
                //        break;
                //    case "Lan":
                //        prop_dt.PropertyType = "Land";
                //        break;
                //    case "Ren":
                //        prop_dt.PropertyType = "Rental";
                //        break;
                //}
              
               // search_inputs.QueryString = '?StreetName=' + prop_dt.StreetName;
          
                $.ajax({
                type: "POST",
                url: plugin.optsAS.servicesFramework.getServiceRoot(plugin.optsAdvncSearch.Routmapper) + 'RetsServices/Get_Related_Properties',
                dataType: 'json',
                async: true,
                data: search_inputs,
                beforeSend: function () {
                },
                complete: function () {
                },
                success: function (json_data) {
                    
                    var related_prop = {};   
                    related_prop = json_data;

                    for (i = 0; i < related_prop.length; i++) {
                        related_prop[i].TotalPrice = related_prop[i].TotalPrice.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");//toString().replace(/(\d+)(\d{3})/, '$1' + ',' + '$2');
                    }
                    debugger;
                    if (related_prop.length == 0) {
                       
                        relateprop_flag = 1;
                    }
                        //= related_prop.Price.toString().replace(/(\d+)(\d{3})/, '$1' + ',' + '$2');
                    else {
                        var relatedProp = $("#Related_property").kendoListView({
                            dataSource: related_prop,
                            template: kendo.template($('#tmp_relatedListing').html()),
                            dataBound: function () {
                            }
                        });
                    }
                }
                });
              
                if (relateprop_flag == 1)
                {
                 
                    //search_inputs.QueryString = '?Property_type=' + prop_dt.PropertyType +
                    //'&bathmin=' + prop_dt.TotalBaths + '&bathmax=' + prop_dt.TotalBaths +
                    //'&bedmin=' + prop_dt.TotalBeds + '&bedmax=' + prop_dt.TotalBeds;

                    $.ajax({
                        type: "POST",
                        url: plugin.optsAS.servicesFramework.getServiceRoot(plugin.optsAdvncSearch.Routmapper) + 'RetsServices/Get_Related_Properties_1',
                        dataType: 'json',
                        async: true,
                        data: search_inputs,
                        beforeSend: function () {
                        },
                        complete: function () {
                        },
                        success: function (json_data) {
                            var related_prop = {};
                            related_prop = json_data;
                            for (i = 0; i < related_prop.length; i++)
                            {
                                related_prop[i].TotalPrice = related_prop[i].TotalPrice.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");//toString().replace(/(\d+)(\d{3})/, '$1' + ',' + '$2');
                            }
                            debugger;
                            relateprop_flag = 0;
                            var relatedProp = $("#Related_property").kendoListView({
                                dataSource: related_prop,
                                template: kendo.template($('#tmp_relatedListing').html()),
                                dataBound: function () {
                                }
                            });
                        }
                    });
                }
            },        
       
        initialize: function () {            
          
            $('#click').click(function () {
                $('#PropertyDetails').bPopup().close();
                   // $('#rightsidebar').hide();                    
                   // $('#FEL_listView').show();
                });
                //$('.map-data').css('width', '100%');
              //  $('.col-map-2').css('display', 'none');
            $('#PropertyDetails').css('display', 'none');
        },

        MortgageCalculate: function () {
            var TotalPrice = 0.0,
				interestRate = 0.0,
				MonthlyPay = 0.0,
				cinterestRate = 0.0,
				downpayment = 0.0;
            var year = 0;
         
            TotalPrice = $("#PD_Price").val();
            interestRate = $("#PD_Interest").val();
            year = $("#PD_Year").val();
            if (downpayment == 0.0) downpayment = TotalPrice * 20 / 100;
            else downpayment = $("#PD_DownPay").val();
            cinterestRate = (interestRate / 100) * (1.0 / 12.0);
            MonthlyPay = ((TotalPrice - downpayment) * cinterestRate) / (1 - (1 / getPow((1 + cinterestRate), (year * 12))));
            $("#PD_DownPay").val(downpayment);
            $("#PD_EMPayment").val(getRound(MonthlyPay));


        },

        MortgageCalculateClick: function () {
            var TotalPrice = 0.0,
				interestRate = 0.0,
				MonthlyPay = 0.0,
				cinterestRate = 0.0,
				downpayment = 0.0;
            var year = 0;
           
            TotalPrice = $("#PD_Price").val();
            interestRate = $("#PD_Interest").val();
            year = $("#PD_Year").val();

            downpayment = $("#PD_DownPay").val();

            cinterestRate = (interestRate / 100) * (1.0 / 12.0);
            MonthlyPay = ((TotalPrice - downpayment) * cinterestRate) / (1 - (1 / getPow((1 + cinterestRate), (year * 12))));

            //////  System.Math.Round(n, 2, MidpointRounding.ToEven);
            $("#PD_DownPay").val(downpayment);
            $("#PD_EMPayment").val(getRound(MonthlyPay));


        },

        //property details page map
        InitGoogleMap: function () {
            
           // var map_detl=data.CombineAddress
            //lt = map_data.Latitude;
            //ln = map_data.Longitude;
          //  walkscore_data(address);
            if (lt == 0 && ln == 0) {
                var geocoder = new google.maps.Geocoder();
                geocoder.geocode({ 'address': address }, function (results, status) {
                    if (status == google.maps.GeocoderStatus.OK) {

                        // var temp_lat = results[0].geometry.location;
                        //alert(results[0].geometry.location);
                        lt = results[0].geometry.location.lat();
                        ln = results[0].geometry.location.lng();
                        //alert(address+" ,"+Lat + ", " + Lng);

                        var  map = new google.maps.Map(
                document.getElementById('map-prop_details'), {
                    center: new google.maps.LatLng(lt, ln),
                    zoom: 17,
                    mapTypeId: google.maps.MapTypeId.ROADMAP,
                    scrollwheel: false
                });

                        var marker = new google.maps.Marker({
                            position: new google.maps.LatLng(lt, ln),
                            map: map
                        });

                        //alert(Lat + " " + Lng);
                    }
                });
                //alert(Lat + " " + Lng);
            }
            else {
                var map = new google.maps.Map(
                 document.getElementById('map-prop_details'), {
                     center: new google.maps.LatLng(lt, ln),
                     zoom: 17,
                     mapTypeId: google.maps.MapTypeId.ROADMAP,
                     scrollwheel: false
                 });

                var marker = new google.maps.Marker({
                    position: new google.maps.LatLng(lt, ln),
                    map: map
                });
            }
           //To get map this flag is added for getnearbyprop method
          $("#getNearByprop_flag").val(map);
            //var getNearByprop_flag = document.getElementById('getNearByprop_flag').value;
            //if (getNearByprop_flag == 1) {
            //    $.MapCluster.getNearByPlaces();
            //}
        },

        SetStreetView: function () {
            if (lt == 0 && ln == 0) {
                var geocoder = new google.maps.Geocoder();
                geocoder.geocode({ 'address': address }, function (results, status) {
                    if (status == google.maps.GeocoderStatus.OK) {
                        //alert(results[0].geometry.location);
                        lt = results[0].geometry.location.lat();
                        ln = results[0].geometry.location.lng();

                        var fenway = new google.maps.LatLng(lt, ln);
                        var panoramaOptions = {
                            position: fenway,
                            pov: {
                                heading: 35,
                                pitch: 5,
                                zoom: 1
                            }
                        };

                        var panorama = new google.maps.StreetViewPanorama(
                            document.getElementById('map-prop_details'),
                            panoramaOptions);

                    }
                });

                // alert(Lat+" "+ Lng);
            }
            else {
                var fenway = new google.maps.LatLng(lt, ln);
                var panoramaOptions = {
                    position: fenway,
                    pov: {
                        heading: 35,
                        pitch: 5,
                        zoom: 1
                    }
                };

                var panorama = new google.maps.StreetViewPanorama(
                    document.getElementById('map-prop_details'),
                    panoramaOptions);
            }
        },
        SetROADMAP: function () {
            $.MapCluster.InitGoogleMap();
           // var map = new google.maps.LatLng(lt, ln);
            map.setMapTypeId(google.maps.MapTypeId.ROADMAP);

            $.MapCluster.ClearMap();
            $.MapCluster.getNearByPlaces();
        },
        SetHYBRID: function () {
            $.MapCluster.InitGoogleMap();
            map.setMapTypeId(google.maps.MapTypeId.HYBRID);
        },
        SetTERRAIN: function () {
            $.MapCluster.InitGoogleMap();
            map.setMapTypeId(google.maps.MapTypeId.TERRAIN);
        },
        SetSATELLITE: function () {
            $.MapCluster.InitGoogleMap();
            var myLatlng = new google.maps.LatLng(lt, ln);
            var mapOptions = {
                position:new google.maps.LatLng(lt, ln),
                zoom: 14,
                center: myLatlng,
                mapTypeId: google.maps.MapTypeId.SATELLITE
            };

            var map = new google.maps.Map(document.getElementById("map-prop_details"),
                mapOptions);
            var marker = new google.maps.Marker({
                position: new google.maps.LatLng(lt, ln),
                map: map
            });
            ($("#hdf_satelite_flag").val(1));
            //map.setMapTypeId(google.maps.MapTypeId.SATELLITE);
            map.setTilt(45);
            
            $.MapCluster.ClearMap();
            $.MapCluster.getNearByPlaces();
        },
        GetParameterValues: function (param) {
            //debugger;
            var searchUrl = $(location).attr('href');
            var queryString = searchUrl.split('?')[1];

            if (queryString == undefined) {
                searchUrl = $("#hdf_originalUrl").val();
                queryString = searchUrl.split('?')[1];
            }

            if (queryString == undefined) {
                return undefined;
            }
            else {
                var urlParameters = queryString.split('&');
                if (queryString == undefined) {
                    return undefined;
                }
                else {
                    for (var i = 0; i < urlParameters.length; i++) {
                        var urlparam = urlParameters[i].split('=');
                        if (urlparam[0] == param) {
                            return decodeURIComponent(urlparam[1].replace(/\+/g, ' '));
                        }
                    }
                }
            }
            return undefined;
        },
      
        getNearByProperties: function () {
            
            var map = new google.maps.Map(
               document.getElementById('map-prop_details'), {
                   center: new google.maps.LatLng(lt, ln),
                   zoom: 17,
                   mapTypeId: google.maps.MapTypeId.ROADMAP,
                   scrollwheel: false
               });
           
            if (document.getElementById('hdf_satelite_flag').value != "") {
                map.setMapTypeId(google.maps.MapTypeId.SATELLITE);
            }
            ($("#hdf_satelite_flag").val(null));

            var marker_main = new google.maps.Marker({
                position: new google.maps.LatLng(lt, ln),
                
                map: map,
            });
            //  marker_main.setMap(map);

            var bounds = map.getBounds();

            var ne = bounds.getNorthEast();
            var sw = bounds.getSouthWest();
            var new_search = document.getElementById("query_str_HF").value;
            var querystr = querystr = new_search + "&NorthEast=" + ne.lat() + ',' + ne.lng() + "&SouthWest=" + sw.lat() + ',' + sw.lng();
            var search_inputs = $.extend({}, plugin.SearchInputs, null);
            search_inputs.SearchColumns = "*";
            search_inputs.QueryString = querystr;
          
         

            $.ajax({
                type: "POST",
                url: plugin.optsAS.servicesFramework.getServiceRoot(plugin.optsAdvncSearch.Routmapper) + 'RetsServices/Get_Map_Properties',
                dataType: 'json',
                async: true,
                data: search_inputs,
                beforeSend: function () {
                },
                complete: function () {
                },
                success: function (data) {
                    var contentString = '<div id="content">' +
                                         '</div>';
                    var infowindow = new google.maps.InfoWindow({
                        maxwidth: 30,
                        content: contentString,
                    });

                    var mapdata_prop = {};
                    mapdata_prop = data.server_result;
                    //  var json = JSON.stringify(mapdata);                      
                    
                    propertymarker1 = [];
                    var mcOptions;
                    var latlng = [];
                   
                    if (mapdata_prop.length > 0) {
                        for (var i = 0; i < mapdata_prop.length; i++) {
                            Lat[i] = mapdata_prop[i].Latitude;
                            Lng[i] = mapdata_prop[i].Longitude;
                            var data = mapdata_prop[i];

                            latlng = new google.maps.LatLng(Lat[i], Lng[i]);
                            //add markers and images for markers as per propertytype
                            switch (mapdata_prop[i].Prop_num) {
                                case "1": marker = new google.maps.Marker({ position: latlng, icon: 'images/house-01.png', map: map, });
                                    break;
                                case "2":
                                    marker = new google.maps.Marker({ position: latlng,icon: 'images/house-02.png',map: map,});
                                    break;
                                case "3": marker = new google.maps.Marker({ position: latlng, icon: 'images/house-03.png', map: map,});
                                    break;
                                case "4":
                                    marker = new google.maps.Marker({ position: latlng, icon: 'images/house-04.png', map: map,});
                                    break;
                                case "5": marker = new google.maps.Marker({ position: latlng,icon: 'images/house-05.png', map: map,});
                                    break;
                                case "6":
                                    marker = new google.maps.Marker({  position: latlng, icon: 'images/house-06.png', map: map, });
                                    break;
                                case "7":
                                    marker = new google.maps.Marker({ position: latlng, icon: 'images/house-07.png', map: map, });
                                    break;
                                case "8":
                                    marker = new google.maps.Marker({ position: latlng, icon: 'images/house-08.png', map: map, });
                                    break;
                                case "9":
                                    marker = new google.maps.Marker({ position: latlng, icon: 'images/house-09.png', map: map, });
                                    break;
                                case "10":
                                    marker = new google.maps.Marker({ position: latlng, icon: 'images/house-10.png', map: map, });
                                    break;

                            }

                            propertymarker1.push(marker);
                            (function (marker, data) {

                                google.maps.event.addListener(marker, "click", function (e) {                              
                                   
                                    window.open(data.link);
                                   // marker.setMap(map);
                                });
                                google.maps.event.addListener(marker, "mouseover", function (e) {

                                    if (data.PrimaryPhotoURL == null || data.PrimaryPhotoURL == '') {
                                        data.PrimaryPhotoURL = "/images/NoPreview.jpg";
                                    }
                                    data.TotalPrice = data.TotalPrice.toString().replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1,");//toString().replace(/(\d+)(\d{3})/, '$1' + ',' + '$2');
                                    var iwContent = '<div id="iw_container">' +
                                                        '<div class="iw_title mp-data-add">' + data.CombineAddress +
                                                        '</div>' +
                                                        '<table>' +
                                                          '<tr>' +
                                                           '<td><img src=' + data.PrimaryPhotoURL + ' class="gm-style img" height="50" width="50" onerror="imgError(this);"/>' + '</td>' +

                                                            '<td><table><tr><td>' + '&nbsp&nbsp' + data.TotalBaths + '&nbsp' + 'Bath,' + '&nbsp&nbsp' + data.TotalBeds + '&nbsp' + 'Bed</td></tr>' +
                                                                       '<tr><td class="data-price-st"><b>$</b>' + data.TotalPrice + '</td></tr>'
                                                             + '</table>' +
                                                          '</tr>' +
                                                          '</table>' +
                                                          '<div id="iw_container">' +
                                                          '<div width="100">' + data.OfficeName + '</div>';

                                    infowindow.setContent(iwContent);
                                    infowindow.open(map, marker);
                                });

                                google.maps.event.addListener(marker, "mouseout", function (e) {
                                    infowindow.close();
                                });

                            })(marker, data);
                        }                                              
                    }

                }
            });
        },
        getNearByPlaces: function () {
          
            var getNearByprop_flag = $("#getNearByprop_flag").val();
            maptypes_arr = [];
            $("#places input[type=checkbox]:checked").each(function () {

           
                //if (this.value.indexOf("Traffic") == 0) {
                //    trafficLayer.setMap(getNearByprop_flag);
                //}
                if (this.value.indexOf("props") == 0) {

                    $.MapCluster.getNearByProperties();

                }
                //if (this.value.indexOf("photos") == 0) {
                //    maptypes_arr.push("school");
                //}

            });

            if (maptypes_arr.length > 0) {

                var request = {
                    location: new google.maps.LatLng(lt, ln),
                    radius: 5000,
                    types: maptypes_arr
                };

              
                
                infowindow = new google.maps.InfoWindow();
                var service = new google.maps.places.PlacesService(getNearByprop_flag);
                service.nearbySearch(request, $.MapCluster.createMarker);
            }
        },
        ClearMap: function () {
           
            for (var i = 0; i < propertymarker1.length; i++) {
                propertymarker1[i].setMap(null);
            }
            trafficLayer.setMap(null);
        },
        createMarker: function (results, status) {
            if (status == google.maps.places.PlacesServiceStatus.OK) {
                $("#places_list").html("");


                // Sets the map on all markers in the array.
                for (var i = 0; i < results.length; i++) {



                    //$("#places_list").append("<li>" + JSON.stringify(results[i]) + "</li>");

                    var request = {
                        placeId: results[i].place_id
                    };

                    var service = new google.maps.places.PlacesService(map);

                    service.getDetails(request, function (place, status) {
                        if (status == google.maps.places.PlacesServiceStatus.OK) {

                            var image = {
                                url: place.icon,
                                size: new google.maps.Size(71, 71),
                                origin: new google.maps.Point(0, 0),
                                anchor: new google.maps.Point(17, 34),
                                scaledSize: new google.maps.Size(25, 25)
                            };

                            var marker = new google.maps.Marker({
                                map: map,
                                icon: image,
                                position: place.geometry.location
                            });

                            google.maps.event.addListener(marker, 'click', function () {

                                var photos = place.photos;
                                if (!photos) {
                                    placePhoto = "";
                                }
                                else {
                                    placePhoto = "<img src='" + photos[0].getUrl({ 'maxWidth': 150, 'maxHeight': 150 }) + "' style='width:100px;height:100px;' /><br/>";
                                }

                                var placeWebsite = place.website;
                                if (!placeWebsite) {
                                    placeWebsite = place.name;
                                }
                                else {
                                    placeWebsite = "<a target='_blank' href='" + place.website + "' >" + place.name + "</a>";
                                }

                                //alert(JSON.stringify(place));


                                infowindow.setContent(placePhoto + placeWebsite + "<br/>" + place.formatted_address + "<br/>" + place.formatted_phone_number);
                                infowindow.open(map, this);
                            });

                            markers.push(marker);
                        }
                    });

                }
            }
        },
        //leadactivity for fvrt, viewd
        setFavorite: function (pid) {
           
            var searchInputsInfo = $.extend({}, plugin.SearchInputs, null);
          
            searchInputsInfo.XmlPath = plugin.optsAS.LeadId;
            searchInputsInfo.PropertyID = pid.id;

            var favTitle = $(pid).attr('class');

            if (favTitle.indexOf("Blackheart") >= 0) {
                searchInputsInfo.Favorite = true;
                $.ajax({
                    type: "POST",
                    url: plugin.optsAS.servicesFramework.getServiceRoot(plugin.optsAdvncSearch.Routmapper) + "RetsServices/setPropertyFavourite",
                    dataType: 'json',
                    async: true,
                    beforeSend: opts.servicesFramework.setModuleHeaders,
                    data: searchInputsInfo,
                    success: function (setFavoriteData) {
                       
                        if (setFavoriteData != "") {
                            $(pid).removeClass('Blackheart');
                            $(pid).addClass('redheart');
                        }
                    },
                    error: function (xhr, status, error) {
                    }
                }).complete(function () {
                });

            }
            else {
                searchInputsInfo.Favorite = false;
             
                $.ajax({
                    type: "POST",
                    url: plugin.optsAS.servicesFramework.getServiceRoot(plugin.optsAdvncSearch.Routmapper) + "RetsServices/setPropertyFavourite",
                    dataType: 'json',
                    async: true,
                    beforeSend: opts.servicesFramework.setModuleHeaders,
                    data: searchInputsInfo,
                    success: function (setFavoriteData) {
                        if (setFavoriteData != "") {
                            $(pid).removeClass('redheart');
                            $(pid).addClass('Blackheart');
                        }
                    },
                    error: function (xhr, status, error) {
                    }
                }).complete(function () {
                });

            }
        },
        SetPropertyRating: function (RatingCount) {
          
            var search_inputs = $.extend({}, plugin.SearchInputs, null);
         
            search_inputs.PropertyID = $("#SelectedListId").val();
            if (plugin.optsAS.LeadId != "") {
                search_inputs.Favorite = true;
            }
            search_inputs.XmlPath = plugin.optsAS.LeadId;
            search_inputs.RatingCount = RatingCount;
            $.ajax({
                type: "POST",
                url: plugin.optsAS.servicesFramework.getServiceRoot(plugin.optsAdvncSearch.Routmapper) + 'RetsServices/SetPropertyRating',
                dataType: 'json',
                async: true,
                data: search_inputs,
                beforeSend: function () {
                },
                complete: function () {
                },
                success: function (IsDone) {
                    //alert(IsDone);
                }
            });
        },
      
    }  
});
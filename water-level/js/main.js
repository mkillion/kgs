var map;

require(["esri/map", "esri/dijit/Scalebar", "application/bootstrapmap", "esri/dijit/LocateButton", "dojo/dom-construct", "esri/layers/FeatureLayer",
         "esri/dijit/PopupMobile", "esri/dijit/PopupTemplate", "esri/InfoTemplate", "esri/renderers/UniqueValueRenderer", "esri/symbols/PictureMarkerSymbol", "dojo/domReady!"],
function(Map, Scalebar, BootstrapMap, LocateButton, domConstruct, FeatureLayer, PopupMobile, PopupTemplate, InfoTemplate, UniqueValueRenderer, PictureMarkerSymbol) {

    var popup = new PopupMobile(null, domConstruct.create("div"));
    var popupTemplate = new InfoTemplate("${LOCAL_WELL_NUMBER}",
        "<b>USGS ID:</b> ${USGS_ID}<br><b>ACCESS:</b> ${WELL_ACCESS}");

    map = BootstrapMap.create("map-div", {
        basemap: "topo",
        center: [-101, 38.5],
        zoom: 8,
        logo: false,
        infoWindow: popup
    });

    var scalebar = new Scalebar({
        map: map,
        scalebarUnit: "dual"
    });

    var geoLocate = new LocateButton({
        map: map
    }, "geolocator-btn");
    geoLocate.startup();

    plssLayer = new esri.layers.ArcGISDynamicMapServiceLayer("http://services.kgs.ku.edu/arcgis8/rest/services/PLSS/plss");
    routesLayer = new esri.layers.ArcGISDynamicMapServiceLayer("http://services.kgs.ku.edu/arcgis8/rest/services/water_level/ww_sampling/MapServer");
    routesLayer.setVisibleLayers([1]);

    wellsLayer = new FeatureLayer("http://services.kgs.ku.edu/arcgis8/rest/services/water_level/ww_sampling/MapServer/0", {
        mode: FeatureLayer.MODE_ONDEMAND,
        infoTemplate: popupTemplate,
        outFields: ["*"]
    });

    map.addLayers([routesLayer, wellsLayer]);

    // Define renderer for wells layer:
    var defaultSymbol = new PictureMarkerSymbol("http://static.arcgis.com/images/Symbols/NPS/npsPictograph_0077b.png", 20, 25);
    var renderer = new UniqueValueRenderer(defaultSymbol, "MEASUREMENT_STATUS");
    /*renderer.addValue("-9999", new PictureMarkerSymbol("http://static.arcgis.com/images/Symbols/AtoZ/blueN.png", 20, 25));*/
    renderer.addValue("-9999", new PictureMarkerSymbol("http://static.arcgis.com/images/Symbols/Shapes/BlueSquareLargeB.png", 35, 35));
    /*renderer.addValue("1", new PictureMarkerSymbol("http://static.arcgis.com/images/Symbols/AtoZ/greenM.png", 20, 25));*/
    renderer.addValue("1", new PictureMarkerSymbol("http://static.arcgis.com/images/Symbols/Shapes/GreenCircleLargeB.png", 35, 35));
    /*renderer.addValue("0", new PictureMarkerSymbol("http://static.arcgis.com/images/Symbols/AtoZ/redU.png", 20, 25));*/
    renderer.addValue("0", new PictureMarkerSymbol("http://static.arcgis.com/images/Symbols/Shapes/RedDiamondLargeB.png", 35, 35));

    wellsLayer.setRenderer(renderer);
}); // end dj require.



$(document).ready(function(){
    updateTable();

    // Basemap options kept for future reference - not all are used here:
    $("#basemapList li").click(function(e) {
        switch (e.target.text) {
            case "Streets":
                map.setBasemap("streets");
                break;
            case "Imagery":
                map.setBasemap("hybrid");
                break;
            case "National Geographic":
                map.setBasemap("national-geographic");
                break;
            case "Topographic":
                map.setBasemap("topo");
                break;
            case "Gray":
                map.setBasemap("gray");
                break;
            case "Open Street Map":
                map.setBasemap("osm");
                break;
        }
    });

    $("#routes-chkbox").change(function() {
        routesLayer.visible ? routesLayer.hide() : routesLayer.show();
    });

    $(":radio").change(function(e) {
        switch (e.target.value) {
            case "notvisited":
                filterWells("-9999");
                break;
            case "measured":
                filterWells("1");
                break;
            case "utm":
                filterWells("0");
                break;
            case "all":
                filterWells("all");
                break;
        }
    });
}); // end jq ready.


function updateTable() {
    $.ajax({
        url: "track-table.cfm",
        success: function(data) {
            $("#table-div").html(data);
        },
        error: function() {
            $("#table-div").text("Currently unable to retreive tabular data.");
        }
    });
}


function filterWells(status) {
    var defExp = "";
    if (status !== "all") {
        defExp = "MEASUREMENT_STATUS = " + status;
    }
    wellsLayer.setDefinitionExpression(defExp);
}


function toggleTable() {
    if ($("#map-pane").hasClass("col-md-9")) {
        $("#table-pane").hide();
        $("#map-pane").removeClass("col-md-9");
        $("#map-pane").addClass("col-md-12");
    } else {
        $("#table-pane").show();
        $("#map-pane").removeClass("col-md-12");
        $("#map-pane").addClass("col-md-9");
    }
    map.resize();
    map.reposition();
}

<cfquery name="GetMinMax" datasource="gis_webinfo">
	select 	to_char(min(timestamp_1), 'MM/DD/YYYY') min_date, 
			to_char(max(timestamp_1), 'MM/DD/YYYY') max_date 
	from wizard.water_droid
</cfquery>

<cfif IsDefined("form.end") and IsDate(#form.end#)>
		<cfset the_max_date = DateFormat(#form.end#, 'yyyy-mm-dd')>
<cfelse>
	<cfset the_max_date = DateFormat(#GetMinMax.max_date#, 'yyyy-mm-dd')>
</cfif>

<cfif IsDefined("form.start") and IsDate(#form.start#)>
	<cfset the_min_date = DateFormat(#form.start#, 'yyyy-mm-dd')>
<cfelse>
	<cfset the_min_date = DateFormat(#GetMinMax.min_date#, 'yyyy-mm-dd')>
</cfif>


<cfif the_min_date eq the_max_date>
	<cfset theDateWhere = "trunc(timestamp_1) = to_date('#the_min_date#', 'yyyy-mm-dd')">
<cfelse>
	<cfset theDateWhere = "trunc(timestamp_1) >= to_date('#the_min_date#', 'yyyy-mm-dd') and trunc(timestamp_1) <= to_date('#the_max_date#', 'yyyy-mm-dd')">
</cfif>


<cfquery name="WellsLeftToMeasure" datasource="gis_webinfo">
	select count(usgs_id) theCount from geohydro.wizard_sites_network_wells where measurement_status = -9999 and responsible_agency = 'KGS'
</cfquery>


<!--- this query gets the well counts by date--->
<!---cfquery name="DayResults" datasource="gis_webinfo">
    select 	well.Mdate, well.well_count, utm.utm_count
    from 	(select 	trunc(timestamp_1) Mdate, count(distinct USGS_ID) well_count
        from 		wizard.water_droid 
        where 		depth_1 >= 0 
        group by 	trunc(timestamp_1)) WELL,
        (select 	trunc(timestamp_1) Mdate, count(distinct USGS_ID) utm_count
        from 		wizard.water_droid 
        where 		depth_1 < 0 
        group by 	trunc(timestamp_1)) UTM
    where 	well.mdate >= to_date('#the_min_date#', 'yyyy-mm-dd') and well.mdate <= to_date('#the_max_date#', 'yyyy-mm-dd') and
        well.mdate = utm.mdate (+)
        order by well.mdate
</cfquery--->
    
<cfquery name="DayResults" datasource="gis_webinfo">
select 	bigcount.Mdate, well.well_count, utm.utm_count, bigcount.the_count
    from 	(select 	trunc(timestamp_1) Mdate, count(distinct USGS_ID) well_count
        from 		wizard.water_droid
        where 		depth_1 >= 0 
        group by 	trunc(timestamp_1)) WELL,
        (select 	trunc(timestamp_1) Mdate, count(distinct USGS_ID) utm_count
        from 		wizard.water_droid 
        where 		depth_1 < 0 
        group by 	trunc(timestamp_1)) UTM,
        (select		trunc(timestamp_1) Mdate, count(distinct USGS_ID) the_count
        from 		wizard.water_droid
        group by 	trunc(timestamp_1)) BIGCOUNT
    where bigcount.mdate = well.mdate (+) and bigcount.mdate = utm.mdate (+)
    order by bigcount.mdate
</cfquery>
   
<p>There are currently <cfoutput><b>#WellsLeftToMeasure.theCount#</b></cfoutput> wells left to measure.</p>
    
<table id="wells-table" class="table table-striped" align="center" border="1">
    <tr><th>Day</th><th>Measured Wells</th><th>UTM'ed Wells</th><th>Total Well Counts</th></tr>
    <cfoutput query="DayResults">
        <tr>
            <td>
             <a href="http://hercules.kgs.ku.edu/geohydro/water_levels/daylist.cfm?mdate=#Dateformat(mdate, 'yyyy-mm-dd')#&theOrderBy=local_well_number, timestamp_1&theOrderByDir=Asc" target="_blank">#Dateformat(mdate, 'yyyy-mm-dd')# </a>
             </td>
            <cfif not isnumeric(#well_count#)>
                <td align="right">0</td>
            <cfelse> 
                <td align="right">#well_count#</td>
            </cfif>

            <cfif not isnumeric(#utm_count#)>
                <td align="right">0</td> 
            <cfelse> 
                <td align="right">#utm_count#</td>
            </cfif>

            <cfif not isnumeric(#the_count#)>
                <td align="right">0</td> 
            <cfelse> 
                <td align="right">#the_count#</td>
            </cfif>
        </tr>
    </cfoutput>
    <tr><td colspan="4" align="center">
         <a href="http://hercules.kgs.ku.edu/geohydro/water_levels/daylist.cfm?mdate=all&theOrderBy=local_well_number, timestamp_1&theOrderByDir=Asc" target="_blank">List all measured wells</a>
    </td></tr>
    <tr><td colspan="4" align="center"><button id="btnUpdate" onclick="updateTable();">Update Table</button></td></tr>
</table>
 
<!--<img src="img/water_level_legend.png" alt="legend">-->
<table>
    <tr><td><img src="http://static.arcgis.com/images/Symbols/Shapes/BlueSquareLargeB.png" width="35px" height="35px"></td><td style="text-align:left">Not Visited</td></tr>
    <tr><td><img src="http://static.arcgis.com/images/Symbols/Shapes/GreenCircleLargeB.png" width="35px" height="35px"></td><td style="text-align:left">Measured</td></tr>
    <tr><td><img src="http://static.arcgis.com/images/Symbols/Shapes/RedDiamondLargeB.png" width="35px" height="35px"></td><td style="text-align:left">Unable to Measure</td></tr>
    </tr>
</table>   
    
    
            
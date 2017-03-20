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
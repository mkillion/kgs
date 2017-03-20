<cfquery name="DayResults" datasource="gis_webinfo">
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
</cfquery>
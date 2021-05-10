-- Inspired by: https://www.kdnuggets.com/2017/02/data-science-nyc-taxi-trips.html
SELECT
    CASE
        WHEN TipPercentage < 0 THEN 'No Tip'
        WHEN TipPercentage BETWEEN 0
        AND 5 THEN 'Less but still a Tip'
        WHEN TipPercentage BETWEEN 5
        AND 10 THEN 'Decent Tip'
        WHEN TipPercentage > 10 THEN 'Good Tip'
        ELSE 'Something different'
    END AS TipRange,
    Hr,
    Wk,
    TripMonth,
    Trips,
    Tips,
    AverageSpeed,
    AverageDistance,
    TipPercentage,
    Tipbin
FROM
    (
        SELECT
            EXTRACT(
                HOUR
                from
                    pickup_datetime
            ) As Hr,
            EXTRACT(
                DOW
                from
                    pickup_datetime
            ) As Wk,
            Extract (
                MONTH
                from
                    pickup_datetime
            ) As TripMonth,
            case
                when tip_amount = 0 then 'No Tip'
                when (
                    tip_amount > 0
                    and tip_amount <= 5
                ) then '0-5'
                when (
                    tip_amount > 5
                    and tip_amount <= 10
                ) then '5-10'
                when (
                    tip_amount > 10
                    and tip_amount <= 20
                ) then '10-20'
                when tip_amount > 20 then '> 20'
                else 'other'
            end as Tipbin,
            COUNT(*) Trips,
            SUM(tip_amount) as Tips,
            ROUND(
                AVG(
                    trip_distance / EXTRACT(EPOCH FROM (dropoff_datetime - pickup_datetime))
                ) * 3600,
                1
            ) as AverageSpeed,
            ROUND(AVG(trip_distance), 1) as AverageDistance,
            ROUND(
                avg((tip_amount) / NULLIF(total_amount - tip_amount, 0)) * 100,
                3
            ) as TipPercentage
        FROM
            nyc_taxi.trips
        WHERE
            trip_distance > 0
            AND fare_amount / NULLIF(trip_distance, 0) BETWEEN 2
            AND 10
            AND dropoff_datetime > pickup_datetime
            AND EXTRACT(YEAR FROM pickup_datetime) = 2020
        group by
            1,
            2,
            3,
            tip_amount,
            total_amount,
            tipbin
    ) t

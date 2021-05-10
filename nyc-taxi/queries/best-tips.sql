/**
 * Inspired by: https://www.kdnuggets.com/2017/02/data-science-nyc-taxi-trips.html
 *
 * Changes:
 *   - remove "Wk" and "Hr" in favor of "Day"/"Month"/"Year" analysis
 *   - query the "nyc_taxi.trips" view, which merges yellow and green cabs
 *   - rework query to show tip range for each time bucket
 */
SELECT TripMonth || '/' || TripDay || '/' || TripYear, TipRange, COUNT(TipRange) FROM (
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
    TripDay,
    TripMonth,
    TripYear,
    Trips,
    TipPercentage
FROM
    (
        SELECT
            EXTRACT(
                Day
                from
                    pickup_datetime
            ) As TripDay,
            Extract (
                MONTH
                from
                    pickup_datetime
            ) As TripMonth,
            Extract (
                YEAR
                from
                    pickup_datetime
            ) As TripYear,
            COUNT(*) Trips,
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
        group by
            1,
            2,
            3,
            tip_amount,
            total_amount
    ) t
) tt
GROUP BY 1, 2
;

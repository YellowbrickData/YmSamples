
# Lookup tables.
curl https://www.gdeltproject.org/data/lookups/CAMEO.country.txt >./lookup-tables/countries.txt
curl https://www.gdeltproject.org/data/lookups/CAMEO.type.txt >./lookup-tables/types.txt
curl https://www.gdeltproject.org/data/lookups/CAMEO.knowngroup.txt >./lookup-tables/groups.txt
curl https://www.gdeltproject.org/data/lookups/CAMEO.ethnic.txt >./lookup-tables/ethnic.txt
curl https://www.gdeltproject.org/data/lookups/CAMEO.religion.txt >./lookup-tables/religion.txt
curl https://www.gdeltproject.org/data/lookups/CAMEO.eventcodes.txt >./lookup-tables/eventcodes.txt
curl https://www.gdeltproject.org/data/lookups/CAMEO.goldsteinscale.txt >./lookup-tables/goldsteinscale.txt

# Listings
curl https://gdelt-open-data.s3.amazonaws.com/ |xmllint --pretty 1 - >./listings/bucket.xml
aws s3 ls 's3://gdelt-open-data/v2/events/' --no-sign-request >./listings/v2-events.listing
aws s3 ls 's3://gdelt-open-data/v2/mentions/' --no-sign-request >./listings/v2-mentions.listing
aws s3 ls 's3://gdelt-open-data/events/' --no-sign-request >./listings/events.listing

# Samples
curl https://gdelt-open-data.s3.amazonaws.com/events/1979.csv >./samples/1979.csv
curl https://gdelt-open-data.s3.amazonaws.com/events/20150906.export.csv >./samples/20150906.export.csv
curl https://gdelt-open-data.s3.amazonaws.com/v2/events/20150218230000.export.csv >./samples/v2-20150218230000.export.csv
curl https://gdelt-open-data.s3.amazonaws.com/v2/mentions/20150218230000.mentions.csv >./samples/v2-20150218230000.mentions.csv

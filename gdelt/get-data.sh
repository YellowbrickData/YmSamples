# Listings

curl https://gdelt-open-data.s3.amazonaws.com/ |xmllint --pretty 1 - >bucket.xml
aws s3 ls 's3://gdelt-open-data/v2/events/' --no-sign-request >v2-events.listing
aws s3 ls 's3://gdelt-open-data/events/' --no-sign-request >events.listing

# Samples
curl https://gdelt-open-data.s3.amazonaws.com/events/1979.csv >1979.csv
curl https://gdelt-open-data.s3.amazonaws.com/events/20150906.export.csv >./20150906.export.csv
curl https://gdelt-open-data.s3.amazonaws.com/v2/events/20150218230000.export.csv >./v2-20150218230000.export.csv

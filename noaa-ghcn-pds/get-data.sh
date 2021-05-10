aws s3 ls 's3://noaa-ghcn-pds/csv.gz/' --no-sign-request >etc/csv.gz.list
aws s3 cp 's3://noaa-ghcn-pds/csv/2021.csv' etc --no-sign-request
aws s3 ls 's3://noaa-ghcn-pds/' --no-sign-request  >etc/root.list
aws s3 cp 's3://noaa-ghcn-pds/ghcnd-stations.txt' etc --no-sign-request

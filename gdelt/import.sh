# Setup date cli (gnu date on mac == gdate; TODO: detect this)
if [ ! -z "$(command -v gdate)" ]; then
  dt="gdate"
else
  dt="date"
fi

# Setup connection
YBHOST=$1
if [ -z "${YBHOST}" ]; then
  echo
  echo "    Usage: $0 hostname [database] [user] [password] [startdate]"
  echo "    Defaults: database=yellowbrick_trial user=yellowbrick password=yellowbrick startdate=2019-01-01"
  echo
  exit 1
fi
YBDATABASE="${2:-yellowbrick_trial}"
YBUSER="${3:-yellowbrick}"
YBPASSWORD="${4:-yellowbrick}"
startdate="${5:-2019-01-01}"

echo "YBHOST: ${YBHOST}"
echo "YBDATABASE: ${YBDATABASE}"
echo "YBUSER: ${YBUSER}"
echo "YBPASSWORD: ${YBPASSWORD}"

# From 2015 to now
d="${startdate}"
end=$(${dt} -I -d "$(${dt} +%Y-%m-01) + 1 month")
echo "Importing ${d} to ${end}"
while [ "$d" != "${end}" ]; do
  echo "Starting month: $d"

  # Calculate prefix by date
  prefix=$($dt --d=${d} +%Y%m)

  # Run 3 imports for the month.
  for suffix in {0..3}; do
    echo "Loading /v2/events/${prefix}${suffix}"
    YBHOST="${YBHOST}"\
    YBDATABASE="${YBDATABASE}"\
    YBUSER="${YBUSER}"\
    YBPASSWORD="${YBPASSWORD}"\
      ybsql -c "LOAD TABLE gdelt.events FROM ('/v2/events/${prefix}${suffix}') EXTERNAL LOCATION gdelt.gdelt_location"
  done

  # Advance date and normalize.
  d=$($dt -I -d "$d + 1 month")
  d=$($dt -d "$d" +%Y-%m-01)

done

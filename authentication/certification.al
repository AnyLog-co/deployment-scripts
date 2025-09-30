on error ignore
:set-params:
if not !loc then loc_info = rest get where url = https://ipinfo.io/json
if !loc_info and not !loc then loc = from !loc_info bring [loc]
if not !loc_info and not !loc then loc = 0.0, 0.0
if !loc_info and not !country then country = from !loc_info bring [country]
if not !loc_info and not !country then country = Unknown
if !loc_info and not !state then state = from !loc_info bring [region]
if not !loc_info and not !state then state = Unknown
if !loc_info and not !city then city = from !loc_info bring [city]
if not !loc_info and not !city then city = Unknown

if not !hostname then hostname = get hostname
if not !company_name then company_name = New Company

# Setup the CA
:setup-ca:
<id generate certificate authority where
    country = !country and
    state = !state and
    locality = !city and
    org = !company_name and
    hostname = !hostname>

# Generating a certificate request
:generate-cert:
    <id generate certificate request where
        country = !country and
        state = !state and
        locality = !city and
        org = !company_name and
        hostname =  !hostname
        and ip = !ip>

exit rest

<run rest server where
    external_ip=!external_ip and external_port=!anylog_rest_port and
    internal_ip=!ip and internal_port=!anylog_rest_port and
    bind=!rest_bind and threads=!rest_threads and timeout=!rest_timeout and
    ssl = true and ca_org = !company_name and server_org = !company_name>

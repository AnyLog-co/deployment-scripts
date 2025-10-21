bucket provider connect where group = chi-branch and provider = akave and id = 123 and access_key = $AKAVE_ACCESS_KEY and secret_key = $AKAVE_SECRET_KEY and region = akave-network and endpoint_url = $AKAVE_ENDPOINT

bucket drop where group = chi-branch and name = people and delete_all  = true
bucket create where group = chi-branch and name = people

connect dbms customers where type = bucket and connection = chi-branch
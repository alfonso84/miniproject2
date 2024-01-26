#!/bin/bash
# install Elastic 


# add helm repo for elastic
helm repo add elastic https://Helm.elastic.co 

# an example values.yaml for use with minikube, but it didn't work exactly as written for me.
# curl -O https://raw.githubusercontent.com/elastic/Helm-charts/master/elasticsearch/examples/minikube/values.yaml 

# This is how I created the elasticvalues.yaml file:
# helm show values elastic/elasticsearch | tee -a elasticvalues.yaml
#
# I then edited to increase the Java opts to 512m). The important setting here seems to be "storageClassName: "standard". 
# Yep. That's the trick. I saved the YAML file as elasticvalues.yaml. 
# I also set the password to "passw0rd" to make life easier. Setting the password requires getting the "full" list of values
# with 'helm show...'

# enable these addons for minikube. 
minikube addons enable default-storageclass
minikube addons enable storage-provisioner

helm install elasticsearch elastic/elasticsearch -f elasticvalues.yaml

# keep checking the status of the elasticsearch pods. They take several minutes to become Ready.

echo Sleeping 5 minutes to wait for the install to complete

sleep 300 # wait 5 minutes

# Once they're Ready, run the following command. This is just needed to test
# the status of elasticsearch. It's not required for normal operations.
kubectl port-forward svc/elasticsearch-master 9200 &

# now install Kibana
helm install kibana elastic/kibana

echo Sleeping 5 minutes to wait for the install to complete
sleep 300 # wait 5 minutes for the install to complete.

# provide access to the Kibana UI
kubectl port-forward deployment/kibana-kibana 5601 &

# Kibana URL: http://localhost:5601
# user: elastica
# get pass with: 
# kubectl get secrets --namespace=default elasticsearch-master-credentials -ojsonpath='{.data.password}' | base64 -d
# It's actually hard-coded to "passw0rd" in elasticvalues.yaml. Download the file and change it if needed.


# install metricbeat.
helm install metricbeat elastic/metricbeat

# You can verify metricbeat is working by going to https://localhost:9200/_cat/indices?v&pretty
# and you should see at least one index whose name begins with  ".ds-metricbeat"

echo Sleeping 2 minutes to wait for the install to complete
sleep 120 # wait 2 minutes for the install to complete.

# install logstash

# Specifying this values.yaml file to use the OSS image:
# https://github.com/elastic/helm-charts/blob/main/logstash/examples/oss/values.yaml

# The default install looks for a license and other things and causes problems. This one does not.

helm install logstash elastic/logstash -f https://raw.githubusercontent.com/elastic/helm-charts/main/logstash/examples/oss/values.yaml

echo Sleeping 5 minutes to wait for the install to complete
sleep 300 # sleep 5 minutes waiting for the install to really complete. May not take this long.

# We need filebeat installed and feeding logstash. The OSS example is already configured, so use it.

helm install filebeat elastic/filebeat -f https://raw.githubusercontent.com/elastic/helm-charts/main/filebeat/examples/oss/values.yaml

echo Sleeping 30 seconds to wait for the install to complete
sleep 30  # sleep 30 seconds to wait for the install to really finish

# To verify that it worked, run:

# curl --insecure "https://localhost:9200/_cat/_indices?v&pretty"

# make sure there's at least one index shown whose name begins with ".ds-filebeat-oss"

# Now that we have the OSS version of Elasticsearch installed, let's install Fluent-Bit

# Install fluent bit
helm repo add fluent https://fluent.github.io/helm-charts

# the fluentbitvalues.yaml file used here was first downloaded with
# curl https://raw.githubusercontent.com/fluent/helm-charts/main/charts/fluent-bit/values.yaml | tee -a fluentbitvalues.yaml
# and then modified. The modifications were just to the two "es" [OUTPUT] stanzas
helm install fluent-bit fluent/fluent-bit -f https://gist.github.com/franktate/0873e0a38234ca8ca57350b6c08a2ef8/raw

# To verify that it worked, run:

# curl --insecure "https://localhost:9200/_cat/_indices?v&pretty"

# You should see a new index whose name begins with "logstash" (really. Seems odd, and is configurable, but that's the default).

# That's it! You should be good to go.


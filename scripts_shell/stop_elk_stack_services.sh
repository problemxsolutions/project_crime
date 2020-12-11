# Stop Elasticsearch, Logstash and Kibana service
sudo systemctl stop elasticsearch.service
sudo systemctl stop logstash.service
sudo systemctl stop kibana.service

# Run the following on the CLI
# bash ./scripts_shell/stop_elk_stack_services.sh
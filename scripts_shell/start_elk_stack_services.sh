# Start Elasticsearch, Logstash and Kibana service
sudo systemctl start elasticsearch.service
sudo systemctl start logstash.service
sudo systemctl start kibana.service

# Modify as desired
# firefox http://localhost:5601/

# Run the following on the CLI
# bash ./scripts_shell/start_elk_stack_services.sh
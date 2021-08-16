############################################################################################
### Ref: https://docs.microsoft.com/en-us/azure/hdinsight/kafka/apache-kafka-get-started ###
############################################################################################
#Connection to Kafka cluster
ssh sshuser@kafka-test-neochen-ssh.azurehdinsight.net
#Install jq utility for Json Parsing
sudo apt -y install jq
#set environment variable password
export password="PASSWORD" 
#extract the cluster name
export clusterName=$(curl -u admin:$password -sS -G "http://headnodehost:8080/api/v1/clusters" | jq -r '.items[].Clusters.cluster_name')
#To set an environment variable with Zookeeper host information
export KAFKAZKHOSTS=$(curl -sS -u admin:$password -G https://$clusterName.azurehdinsight.net/api/v1/clusters/$clusterName/services/ZOOKEEPER/components/ZOOKEEPER_SERVER | jq -r '["\(.host_components[].HostRoles.host_name):2181"] | join(",")' | cut -d',' -f1,2);
#To set an environment variable with Apache Kafka broker host information
export KAFKABROKERS=$(curl -sS -u admin:$password -G https://$clusterName.azurehdinsight.net/api/v1/clusters/$clusterName/services/KAFKA/components/KAFKA_BROKER | jq -r '["\(.host_components[].HostRoles.host_name):9092"] | join(",")' | cut -d',' -f1,2);

###Manage Apache Kafka topics using kafka-topics.sh ###
#To create a topic
/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --create --replication-factor 3 --partitions 8 --topic test --zookeeper $KAFKAZKHOSTS

#To list topics
/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --list --zookeeper $KAFKAZKHOSTS
#To delete a topic
/usr/hdp/current/kafka-broker/bin/kafka-topics.sh --delete --topic topicname --zookeeper $KAFKAZKHOSTS
#For more information about kafka-topics.sh
/usr/hdp/current/kafka-broker/bin/kafka-topics.sh

###Produce and consume records
#To write records to the topic, use the kafka-console-producer.sh utility
/usr/hdp/current/kafka-broker/bin/kafka-console-producer.sh --broker-list $KAFKABROKERS --topic test

#To read records from the topic, use the kafka-console-consumer.sh utility 
/usr/hdp/current/kafka-broker/bin/kafka-console-consumer.sh --bootstrap-server $KAFKABROKERS --topic test --from-beginning

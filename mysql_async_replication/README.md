# MySQL simple asynchronous replication example for Kubernetes


Kubernetes launches pods which the containers in those pods have environment variables set, the service files for the mysql master in particular $MYSQL_MASTER_SERVICE_HOST, provides a way for the the slave pod's containers to connect to the master and start replicating. This is done using the entrypoint script to run the necessary "CHANGE MASTER..." SQL statements.

Contained in this repository are Kubernetes pod and service files for both master and slave as well as the files a master and slave images. These images each have a Dockerfile, an entrypoint script performing the necessary Kube-fu to set up replication. 

## Image file building - if you don't want to use the ones specified 

cd images/master
docker build -t yourname/mysql_master_kubernetes .
docker push yourname/mysql_master_kubernetes
cd images/slave
docker build -t yourname/mysql_slave_kubernetes .
docker push yourname/mysql_slave_kubernetes


## Kubernetes USAGE

kubectl -f mysql-master.json
kubectl -f mysql-master-service.json
kubectl -f mysql-slave.json 
kubectl -f mysql-slave-service.json 

Any questions? Look at the code and contact the author!

# MySQL simple replication example for Kubernetes

This repository is very simple and designed to primarily be a proof-of-concept.

The POC is essentially show how to launch a MySQL master and then slave(s) on Kubernetes.

Kubernetes launches pods which the containers in those pods have environment variables set, the service files for the mysql master in particular $MYSQL_MASTER_SERVICE_HOST, provides a way for the the slave pod's containers to connect to the master and start replicating. This is done using the entrypoint script to run the necessary "CHANGE MASTER..." SQL statements.

Contained in this repository are Kubernetes pod and service files for both master and slave as well as the files a master and slave images. These images each have a Dockerfile, an entrypoint script performing the necessary Kube-fu to set up replication. 

Any questions? Look at the code and contact the author!

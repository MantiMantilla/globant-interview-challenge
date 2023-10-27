---
jupytext:
  formats: md:myst
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
    jupytext_version: 1.15.2
kernelspec:
  display_name: Python 3 (ipykernel)
  language: python
  name: python3
---

# Architecture

+++

Our intended architecture for this implementation relies on a Kubernetes cluster that manages a collection of microservices, some for the explicit requirements of the application and others to glue these together or make the whole of it more scalable. The result is a design with which one could easily mitigate the most obvious bottlenecks, both in terms of processing time, and availability and platform reliability.

+++

Our technology stack includes Kubernetes and Docker for deploying microservices written for the most part in Python with Flask, RabbitMQ (also deployed inside de Kubernetes cluster) for loosely coupling services, a MySQL DB for keeping track of users and their permissions, a separate MySQL DB for tracking records from the uploaded CSV files, and a MongDB cluster with GridFS for storing the uploaded CSV files.

+++

Let us look at an overview of the architecture.

```{code-cell} ipython3
from diagrams import Cluster, Diagram
from diagrams.aws.network import Route53
from diagrams.k8s.network import Ingress
from diagrams.k8s.network import Service
from diagrams.k8s.compute import Pod, StatefulSet
from diagrams.aws.database import RDSMysqlInstance
from diagrams.k8s.storage import PV, PVC, StorageClass
from diagrams.custom import Custom
from diagrams.aws.engagement import SimpleEmailServiceSesEmail
```

```{code-cell} ipython3
with Diagram("Microservice Queue Architecture", show=False) as arch:
    #dns = Route53("DNS")
    with Cluster("K8s Cluster"):
        ing = Ingress("Ingress")
        with Cluster("Gateway") as gateway:
            gtwy_svc = Service("Gateway Service")
            gtwy_workers = [Pod("Worker") for _ in range(0, 1)]
            ing - gtwy_svc - gtwy_workers

        with Cluster("Auth") as auth:
            auth_svc = Service("Auth Service")
            auth_workers = [Pod("Worker") for _ in range(0, 1)]
            gtwy_workers - auth_svc - auth_workers

        with Cluster("DBUploader") as dbupldr:
            upld_svc = Service("DBUpld Service")
            upld_workers = [Pod("Worker") for _ in range(0, 1)]
            upld_svc - upld_workers

        with Cluster("Notification") as notif:
            noti_svc = Service("Notif Service")
            noti_workers = [Pod("Worker") for _ in range(0, 1)]
            noti_svc - noti_workers

        with Cluster("Queries") as queries:
            query_svc = Service("Query Service")
            query_workers = [Pod("Worker") for _ in range(0, 1)]
            gtwy_workers - query_svc - query_workers

        queue_svc = Service("Queue Service")
        queue = Custom("Messae queue", "./assets/rabbitmq.png")
        gtwy_workers - queue_svc - queue
        queue - noti_workers

        sts = StatefulSet("Stateful Set")
        pvc = PVC("PV Claim")

    queue - sts - pvc - PV("Persistent Vol") - StorageClass("Storage Class")

    mongo_blob = Custom("MongoDB FS", "./assets/mongodb.png")
    gtwy_workers - mongo_blob

    emply_DB = RDSMysqlInstance("Employment")
    RDSMysqlInstance("Users") - auth_workers

    SimpleEmailServiceSesEmail("Email Server") - noti_workers

    queue - upld_workers - mongo_blob
    upld_workers - emply_DB
    query_workers - emply_DB
    #dns - ing

arch
```

```{code-cell} ipython3

```

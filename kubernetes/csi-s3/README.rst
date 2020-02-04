.. title:: README

Kubernetes Persistent Storage with CSI-S3 and OpenIO
====================================================

Pitch
-----

In a world of containerized applications, the intrinsec ephemeral nature of containers 
makes data persistence a non trivial challenge.

When using Kubernetes, you benefits from complete primitives to ensure data persistence
with the right properties at the right time.

In particular, Kubernetes exposes the objects "Volumes" and "Persistent Volumes" to express the lifecycle
of data to outlives any container that run within a Pod.
Each of these volumes have a "storage class" which express the data policies (backups, snapshot, expansion, etc.)
and also the quality of service (performances, concurent accesses, etc.).
You can learn more at https://kubernetes.io/docs/concepts/storage/volumes,
https://kubernetes.io/docs/concepts/storage/persistent-volumes and 
https://kubernetes.io/docs/concepts/storage/storage-classes/.

In this context, the "Container Storage Interface" (CSI) was developed as a standard for exposing 
arbitrary block and file storage storage systems to containerized workloads on Container Orchestration Systems (COs) 
like Kubernetes.

OpenIO exposes data stores through different primitives, from OpenIO client API to the S3/Swift gateway.

By using a CSI driver compliant with any of these primitives, OpenIO is also able to exposes data stores
in Kubernetes as persistent volumes, with its own storage class.

As for today, the project `<CSI-S3> https://github.com/ctrox/csi-s3#status`_ can be used with OpenIO's S3 gateway
to provide a new storage class to your Kubernetes cluster, with a concurent writing capability (aka. `ReadWriteMany`).
Stay tuned for more data storage topologies for Kubernete with OpenIO.

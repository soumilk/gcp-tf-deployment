# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

## @section Global parameters
## Global Docker image parameters
## Please, note that this will override the image parameters, including dependencies, configured to use the global value
## Current available global Docker image parameters: imageRegistry, imagePullSecrets and storageClass

nameOverride: "mediawiki-db"

fullnameOverride: "mediawiki-db"

serviceBindings:
  enabled: false

image:
  registry: docker.io
  repository: bitnami/mariadb
  tag: 11.3.2-debian-12-r5
  digest: ""
  pullPolicy: IfNotPresent
architecture: standalone
## MariaDB Authentication parameters
auth:
  rootPassword: "${MARIADB_PASS}"
  database: "${MARIADB_DB}"
  username: "${MARIADB_USER}"
  password: ""

  replicationUser: replicator

  updateStrategy:
    type: RollingUpdate
  resources:
    requests:
      cpu: 2
      memory: 512Mi
    limits:
      cpu: 3
      memory: 1024Mi

  persistence:
    enabled: true
    accessModes:
      - ReadWriteOnce
    size: 8Gi
    selector: {}
  service:
    type: ClusterIP
    ports:
      mysql: 3306
      metrics: 9104

serviceAccount:
  create: true
  automountServiceAccountToken: false

metrics:
  enabled: true

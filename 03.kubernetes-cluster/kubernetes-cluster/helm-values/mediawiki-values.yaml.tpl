# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

## @section Global parameters
## Global Docker image parameters
## Please, note that this will override the image parameters, including dependencies, configured to use the global value
## Current available global Docker image parameters: imageRegistry, imagePullSecrets and storageClass

nameOverride: "mediawiki-tw"
fullnameOverride: "mediawiki-tw"

commonLabels:
  assignment: "mediawiki-tw"

automountServiceAccountToken: true

mediawikiUser: "${MEDIAWIKI_USER}"
mediawikiPassword: "${MEDIAWIKI_PASS}"
mediawikiEmail: ${MEDIAWIKI_EMAIL}

mediawikiName: Wiki Demo
replicaCount: 1

updateStrategy:
  type: RollingUpdate

containerPorts:
  http: 8080
  https: 8443

persistence:
  enabled: true
  accessModes:
    - ReadWriteOnce
  size: 8Gi
serviceAccount:
  create: true

service:
  ## @param service.type Kubernetes Service type
  ## For minikube, set this to NodePort, elsewhere use LoadBalancer
  ##
  type: LoadBalancer

  ports:
    http: 80
    https: 443

  loadBalancerIP: "${LOAD_BALANCER_IP}"

mariadb:
   enabled: false
   
externalDatabase:
  ## @param externalDatabase.existingSecret Use existing secret (ignores previous password)
  ## Must contain key `mariadb-password`
  ## NOTE: When it's set, the `externalDatabase.password` parameter is ignored
  ##
  existingSecret: ""
  host: "{MARIADB_HOST}"
  port: 3306
  user: "${MARIADB_USER}"
  mariadb-password: "${MARIADB_PASS}"
  database: "${MARIADB_DB}"

metrics:
  enabled: false

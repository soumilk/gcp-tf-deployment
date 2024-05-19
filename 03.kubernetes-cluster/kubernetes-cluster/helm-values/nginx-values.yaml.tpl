controller:
  service:
    type: LoadBalancer
    loadBalancerIP: ${NGINX_IP}
    externalTrafficPolicy: "Local"
    annotations:
      networking.gke.io/load-balancer-type: ${INGRESS_TYPE}
  admissionWebhooks:
    enabled: false
  autoscaling:
    enabled: true
    minReplicas: ${MIN_REPLICAS}
    maxReplicas: 10
    targetCPUUtilizationPercentage: 70
    targetMemoryUtilizationPercentage: 70
  resources:
    requests:
      cpu: 500m
      memory: 512Mi
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: hyenodepool
            operator: In
            values:
            - application
  config:
    allow-snippet-annotations: "true"
    keep-alive-requests: 1000
    proxy-body-size: 25m
    proxy-connect-timeout: 30
    proxy-read-timeout: 3600
    proxy-send-timeout: 3600
    use-gzip: true
  logLevel: 5
  replicaCount: 2
  tolerations:
  - effect: NoSchedule
    key: application-pool
    operator: Equal
    value: "true"
nodeSelector:
  kubernetes.io/os: linux
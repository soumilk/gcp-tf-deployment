crds:
  install: true
  keep: false # this will remove all crds when helm is uninstalled

redis:
  enabled: true
  name: redis

redis-ha:
  enabled: false
  exporter:
    enabled: false

  tolerations:
    - key: workload
      operator: Equal
      value: utility
      effect: NoSchedule

  nodeSelector:
    workload: utility

  haproxy:
    enabled: false
    metrics:
      enabled: false

controller:
  replicas: 1

  tolerations:
    - key: workload
      operator: Equal
      value: utility
      effect: NoSchedule
  nodeSelector:
    workload: utility

  resources:
    limits:
      cpu: 500m
      memory: 2Gi
    requests:
      cpu: 250m
      memory: 1Gi

  serviceAccount:
    create: true
    automountServiceAccountToken: true

  metrics:
    enabled: false

server:
  extraArgs:
  - --insecure
  additionalApplications:
  - name: tw
    namespace: argocd
    project: default
    source:
      repoURL: ${REPO_URL}
      targetRevision: HEAD
      path: ${REPO_PATH}
      directory:
        recurse: true
      plugin:
        name: kustom-plugin
        env:
        - name: API_HOST_NAME
          value: ${INGRESS_HOST}
        - name: TENANT_ID
          value: ${PROJECT_ID}
        - name: VAULT_NAME
          value: vault
        - name: LTMS_API_HOST_NAME
          value: apiHost
        - name: DASHBOARD_API_HOST_NAME
          value: apiHost
        - name: AUTOMATION_API_HOST_NAME
          value: apiHost
        - name: AUTH_API_HOST_NAME
          value: apiHost
        - name: ACCOUNTS_API_HOST_NAME
          value: apiHost
        - name: CLIENT_ID
          value: clientId
    destination:
      server: https://kubernetes.default.svc
      namespace: tw
    syncPolicy:
      syncOptions:
        - CreateNamespace=true
      automated:
        prune: false
        selfHeal: false

  autoscaling:
    enabled: false
    minReplicas: 1
    maxReplicas: 2
    targetCPUUtilizationPercentage: 70
    targetMemoryUtilizationPercentage: 70

    behavior: {}
      # scaleDown:
      # stabilizationWindowSeconds: 300
      # policies:
      #   - type: Pods
      #     value: 1
      #     periodSeconds: 180
      # scaleUp:
      #   stabilizationWindowSeconds: 300
      #   policies:
      #   - type: Pods
      #     value: 2
      #     periodSeconds: 60

  tolerations:
    - key: workload
      operator: Equal
      value: utility
      effect: NoSchedule
  nodeSelector:
    workload: utility

  resources:
    limits:
      cpu: 500m
      memory: 256Mi
    requests:
      cpu: 125m
      memory: 128Mi

  metrics:
    enabled: false

  ingress:
    enabled: true
    annotations:
#      cert-manager.io/cluster-issuer: letsencrypt-prod
      ingress.kubernetes.io/ssl-redirect: "false"
      ingress.kubernetes.io/force-ssl-redirect: "false"
      nginx.ingress.kubernetes.io/ssl-passthrough: "true"
      nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
      kubernetes.io/tls-acme: "true"
    ingressClassName: "nginx"
    hosts:
      - ${INGRESS_HOST}
    tls:
      - secretName: ${INGRESS_TLS_SECRET}
        hosts:
          - ${INGRESS_HOST}
    https: true
    ## to add grpc you have to add a new ingress


repoServer:
  extraArgs:
    - --repo-cache-expiration
    - 3m
  autoscaling:
    enabled: false
    minReplicas: 1
    maxReplicas: 2
    targetCPUUtilizationPercentage: 70
    targetMemoryUtilizationPercentage: 70
  resources:
    limits:
      cpu: '1'
      memory: 512Mi
    requests:
      cpu: 250m
      memory: 256Mi
  tolerations:
    - key: workload
      operator: Equal
      value: utility
      effect: NoSchedule
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: workload
            operator: In
            values:
            - utility
  nodeSelector:
    workload: utility
  clusterAdminAccess:
    enabled: true

applicationSet:
  replicas: 1
  resources:
    limits:
      cpu: '2'
      memory: 1Gi
    requests:
      cpu: 250m
      memory: 512Mi
  tolerations:
    - key: workload
      operator: Equal
      value: utility
      effect: NoSchedule
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: workload
            operator: In
            values:
            - utility
  nodeSelector:
    workload: utility

dex:
  enabled: true
  metrics:
    enabled: false
  serviceAccount:
    create: true

  tolerations:
    - key: workload
      operator: Equal
      value: utility
      effect: NoSchedule
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: workload
            operator: In
            values:
            - utility
  nodeSelector:
    workload: utility

  resources:
    limits:
      cpu: 500m
      memory: 256Mi
    requests:
      cpu: 250m
      memory: 128Mi

configs:
  cmp:
    create: true
    plugins:
      kustom-plugin:
        init:
          command: [sh, -c, 'echo "Initializing plugin"']
        generate:
          command: ["/bin/sh", "-c"]
          args: ["API_HOST_NAME=${INGRESS_HOST} DASHBOARD_API_HOST_NAME=apiHost AUTOMATION_API_HOST_NAME=apiHost AUTH_API_HOST_NAME=apiHost ACCOUNTS_API_HOST_NAME=apiHost LTMS_API_HOST_NAME=apiHost TENANT_ID=${PROJECT_ID} CLIENT_ID=${PROJECT_ID} VAULT_NAME=vault kustomize build"]
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

  prometheus:
    config:
      scrape_configs:
        - job_name: 'otel-collector'
          scrape_interval: 10s
          static_configs:
            - targets: ['0.0.0.0:8889']

processors:
  batch:
    send_batch_size: 10000
    timeout: 10s

  memory_limiter:
    check_interval: 1s
    limit_percentage: 80
    spike_limit_percentage: 25

  resource:
    attributes:
      - key: service.namespace
        value: ${service_namespace}
        action: upsert
      - key: deployment.environment
        value: ${environment}
        action: upsert

exporters:
  prometheus:
    endpoint: "0.0.0.0:8889"

  prometheusremotewrite:
    endpoint: "${prometheus_endpoint}"
    tls:
      insecure: true

  logging:
    verbosity: detailed

extensions:
  health_check:
    endpoint: 0.0.0.0:13133
  pprof:
    endpoint: 0.0.0.0:1777
  zpages:
    endpoint: 0.0.0.0:55679

service:
  extensions: [health_check, pprof, zpages]
  pipelines:
    metrics:
      receivers: [otlp, prometheus]
      processors: [memory_limiter, batch, resource]
      exporters: [prometheusremotewrite, logging]
    traces:
      receivers: [otlp]
      processors: [memory_limiter, batch, resource]
      exporters: [logging]
    logs:
      receivers: [otlp]
      processors: [memory_limiter, batch, resource]
      exporters: [logging]
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  scrape_timeout: 10s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'ecs_services'
    ec2_sd_configs:
      - region: ${aws_region}
        port: 9100
    relabel_configs:
      - source_labels: [__meta_ec2_tag_Name]
        regex: '.*'
        action: keep
      - source_labels: [__meta_ec2_tag_Environment]
        target_label: environment
      - source_labels: [__meta_ec2_instance_id] 
        target_label: instance_id
      - source_labels: [__meta_ec2_private_ip]
        target_label: private_ip

storage:
  tsdb:
    path: /prometheus
    retention: ${retention_period}
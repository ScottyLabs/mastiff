[server]
root_url = ${root_url}
domain = ${domain}

[auth]
disable_login_form = false

[auth.anonymous]
enabled = ${anonymous_enabled}

[analytics]
check_for_updates = true

[security]
admin_user = ${admin_user}
admin_password = ${admin_password}

[users]
allow_sign_up = false
auto_assign_org = true
auto_assign_org_role = Viewer

[dashboards]
versions_to_keep = 20

[dataproxy]
timeout = 300
logging = false

[paths]
data = /var/lib/grafana
logs = /var/log/grafana
plugins = /var/lib/grafana/plugins
provisioning = /etc/grafana/provisioning

[log]
mode = console
level = info
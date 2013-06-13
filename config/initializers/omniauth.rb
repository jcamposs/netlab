# This initializer solves the conflict with omniauth callbacks when this application is served through NGINX

OmniAuth.config.full_host = "#{Netlab::Application.config.app_protocol}://#{Netlab::Application.config.app_host_and_port}"


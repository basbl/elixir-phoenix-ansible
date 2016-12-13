map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      close;
}

upstream phoenix_app {
    server 127.0.0.1:4000;
}

server{
    {% if nginx.ssl | default(false) %}
    listen 443 ssl http2;
    {% else %}
    listen 80;
    {% endif %}

    sendfile off;
    server_tokens off;

    if ($host !~* ^www\.){
        rewrite ^(.*)$ $scheme://www.$host$1;
    }

    charset utf-8;

    server_name {{ nginx.servername }};

    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options SAMEORIGIN;
    add_header X-Xss-Protection "1; mode=block" always;

    {% if nginx.basicauth.enabled | default(false) %}
    auth_basic 'Authentication required';
    auth_basic_user_file /etc/nginx/htpasswd;
    {% endif %}

    {% if nginx.ssl | default(false) %}
    include ssl.conf;
    include ssl-stapling.conf;

    ssl_certificate         /etc/nginx/ssl/{{ nginx.hostname }}_self_signed.pem;
    ssl_trusted_certificate /etc/nginx/ssl/{{ nginx.hostname }}_self_signed.pem;
    ssl_certificate_key     /etc/nginx/ssl/{{ nginx.hostname }}_self_signed.key;
    {% endif %}

    location / {
        try_files $uri @proxy;
    }

    location @proxy {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
        proxy_pass http://phoenix_app;

        # WebSocket proxying - from http://nginx.org/en/docs/http/websocket.html
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
    }
}


{% if nginx.ssl | default(false) %}
server {
    listen 80;
    server_name {{ nginx.servername }};
    return 301 https://www.{{ nginx.hostname }}$request_uri;
}
{% endif %}

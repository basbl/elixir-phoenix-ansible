upstream my_app {
    server 127.0.0.1:4000;
}

server{
    listen 80;
    server_name www.dev.elixir-phoenix.com dev.elixir-phoenix.com;

    location / {
        try_files $uri @proxy;
    }

    location @proxy {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
        proxy_pass http://my_app;
    }
}

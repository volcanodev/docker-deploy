# docker-deploy

Simple script, which deploys a service onto a Docker machine.

#### Required Perl modules:

- Getopt::Long
- Eixo::Docker::Api
- JSON

#### Usage:

```sh
$ perl deploy.pl --image <image> --endpoint <endpoint> [--publish <publish>] [--name <name>] [--cmd <cmd> [--cmd <cmd>] ...]
```

#### Example:

```sh
perl deploy.pl  --image tutum/hello-world \
                --endpoint http://127.0.0.1:7000 \
                --name hello \
                --publish 80:49160 \
                --cmd "/bin/sh" \
                --cmd "-c" \
                --cmd "php-fpm -d variables_order=\"EGPCS\" && (tail -F /var/log/nginx/access.log &) && exec nginx -g \"daemon off;\""
```

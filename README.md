# docker-sensu-server

CentOS and sensu.
It runs redis, rabbitmq-server, uchiwa, sensu-api, sensu-server and ssh processes.

## Installation

Install from docker index

```
docker pull amontaigu/sensu-server
```

## Run

```
docker run -d -p 3000:3000 -p 4567:4567 -p 5671:5671 -p 15672:15672 amontaigu/sensu-server
```

## How to access via browser and sensu-client

### rabbitmq console

* http://your-server:15672/
* id/pwd : sensu/password

### uchiwa

* http://your-server:3000/

### sensu-client

To run sensu-client, create client.json (see example below), then just run sensu-client process.

These are examples of sensu-client configuration.

* /etc/sensu/config.json

```
{
  "rabbitmq": {
    "host": "sensu-server-ipaddr",
    "port": 5671,
    "vhost": "/sensu",
    "user": "sensu",
    "password": "password",
    "ssl": {
      "cert_chain_file": "/etc/sensu/ssl/cert.pem",
      "private_key_file": "/etc/sensu/ssl/key.pem"
    }
  }
}
```

* /etc/sensu/conf.d/client.json

```
{
  "client": {
    "name": "sensu-client-node-hostname",
    "address": "sensu-client-node-ipaddr",
    "subscriptions": [
      "common",
      "web"
    ]
  },
  "keepalive": {
    "thresholds": {
      "critical": 60
    },
    "refresh": 300
  }
}
```

## Documentation and references

* [Sensu – Adding Check’s and Handler’s](https://beingasysadmin.wordpress.com/2013/04/26/378/)
* [GitHub sensu-plugins-mailer](https://github.com/sensu-plugins/sensu-plugins-mailer)
* [Adding a Sensu handler](https://sensuapp.org/docs/0.16/adding_a_handler)
* [Comparing Seven Monitoring Options for Docker](http://rancher.com/comparing-monitoring-options-for-docker-deployments/)

## License

MIT

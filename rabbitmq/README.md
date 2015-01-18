# RabbitMQ

Project website: https://www.rabbitmq.com

Version: 3.4.3

To build: 

	spoon build -n=rabbitmq /path/to/spoon.me

It installs to `C:\rabbitmq-3.4.3`

The container has the default RabbitMQ configuration but includes the rabbitmq_management plugin.

Assuming no firewall issues you should be able to access the management site at: http://localhost:15672
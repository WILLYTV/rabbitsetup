# Proposta de Infraestrutura para Cluster RabbitMQ (Bare Metal)

## Visão Geral da Arquitetura

O cluster RabbitMQ será composto por 5 VMs Linux, formando um cluster de alta disponibilidade e tolerância a falhas. Todos os nós participarão do cluster, permitindo replicação de filas e distribuição de carga.

```
+---------+    +---------+    +---------+    +---------+    +---------+
|  node1  |    |  node2  |    |  node3  |    |  node4  |    |  node5  |
+---------+    +---------+    +---------+    +---------+    +---------+
```


## Função de Cada VM e Aplicação dos Setups

Todos os nós (node1 a node5) devem receber todas as etapas do guia de instalação, na seguinte ordem:

- 2.1_instalacao_erlang.md
- 2.2_instalacao_rabbitmq.md
- 2.3_configuracao_inicial.md
- 2.4_configuracao_rede_seguranca.md
- 2.5_configuracao_cluster.md
- 2.6_ativacao_plugins.md
- 2.7_monitoramento.md
- 2.8_testes_funcionamento.md

**Observação:**
- O comando de cluster (`join_cluster`) do passo 2.5 só deve ser executado nos nós que vão se juntar ao cluster (node2, node3, node4, node5). O node1 é o nó inicial do cluster e não executa o join_cluster.

Todos os nós terão as mesmas funções e permissões, garantindo balanceamento e resiliência. Não há distinção obrigatória entre "ram" e "disc nodes" a partir das versões recentes do RabbitMQ, mas todos podem ser configurados como disc nodes para maior segurança.

## Endereços IP/Hostnames Sugeridos

- node1: 10.0.0.1
- node2: 10.0.0.2
- node3: 10.0.0.3
- node4: 10.0.0.4
- node5: 10.0.0.5

(ajustar conforme ambiente do cliente)

## Papéis Especiais

- Todos os nós: Participam do cluster, recebem filas e conexões.
- Recomenda-se ativar mirrored queues para garantir alta disponibilidade das filas críticas.
- Plugins de monitoramento (Prometheus, Management) podem ser ativados em todos os nós.

## Requisitos Mínimos de Hardware/OS

- CPU: 2 vCPU por VM (mínimo)
- RAM: 4 GB por VM (mínimo)
- Disco: 40 GB SSD por VM
- SO: Ubuntu Server 20.04+ ou CentOS 8+
- Rede: Latência < 2ms entre as VMs

## Considerações de Rede e Segurança

- Liberar portas 4369 (EPMD), 25672 (inter-node), 5672 (AMQP), 15672 (management), 15692 (Prometheus)
- Recomenda-se uso de TLS para conexões externas
- Restringir acesso às portas apenas para IPs autorizados
- Sincronizar horário das VMs (NTP)

---

Este documento serve como referência para implantação e troubleshooting do cluster RabbitMQ.

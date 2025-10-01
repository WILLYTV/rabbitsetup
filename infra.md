# Proposta de Infraestrutura para Cluster RabbitMQ (Bare Metal)

## Visão Geral da Arquitetura

O ambiente será composto por **5 VMs Linux**, sendo **3 nodes para RabbitMQ** (alta disponibilidade e quorum) e **2 nodes dedicados para HAProxy** (alta disponibilidade de balanceamento).

```
+---------+    +---------+    +---------+      +---------+    +---------+
|  00c    |    |  01c    |    |  02c    |      |  03c    |    |  04c    |
| Rabbit  |    | Rabbit  |    | Rabbit  |      | HAProxy |    | HAProxy |
+---------+    +---------+    +---------+      +---------+    +---------+
```

- **00c, 01c, 02c:** Nodes do cluster RabbitMQ (participam do cluster, armazenam filas, quorum, replicação).
- **03c, 04c:** Nodes dedicados ao HAProxy (não executam RabbitMQ, apenas balanceamento de conexões).

---

## Função de Cada VM e Aplicação dos Setups

- **Nodes 00c, 01c, 02c (RabbitMQ):**
  - Executar todos os passos do guia de instalação:
    - 2.1_instalacao_erlang.md
    - 2.2_instalacao_rabbitmq.md
    - 2.3_configuracao_inicial.md
    - 2.4_configuracao_rede_seguranca.md
    - 2.5_configuracao_cluster.md
    - 2.6_ativacao_plugins.md
    - 2.7_monitoramento.md
    - 2.8_testes_funcionamento.md

  - **Observação:**  
    O comando de cluster (`join_cluster`) do passo 2.5 só deve ser executado nos nodes que vão se juntar ao cluster (01c, 02c). O 00c é o nó inicial do cluster e não executa o join_cluster.

- **Nodes 03c, 04c (HAProxy):**
  - Executar apenas o passo 2.9 (setup do HAProxy).
  - Não instale RabbitMQ ou Erlang nesses nodes.
  - Siga as instruções para desabilitar/remover RabbitMQ caso já tenha sido instalado.

---

## Endereços IP/Hostnames Sugeridos

- 00c: 10.0.0.1 (RabbitMQ)
- 01c: 10.0.0.2 (RabbitMQ)
- 02c: 10.0.0.3 (RabbitMQ)
- 03c: 10.0.0.4 (HAProxy)
- 04c: 10.0.0.5 (HAProxy)

(Ajuste conforme ambiente do cliente)

---

## Papéis Especiais

- **RabbitMQ (00c, 01c, 02c):**  
  Participam do cluster, armazenam filas, processam mensagens, quorum, replicação.
- **HAProxy (03c, 04c):**  
  Balanceamento de carga e alta disponibilidade para conexões de clientes ao cluster RabbitMQ.
- Recomenda-se ativar mirrored queues/quorum queues para garantir alta disponibilidade das filas críticas.
- Plugins de monitoramento (Prometheus, Management) podem ser ativados em todos os nodes RabbitMQ.

---

## Requisitos Mínimos de Hardware/OS

- CPU: 2 vCPU por VM (mínimo)
- RAM: 4 GB por VM (mínimo)
- Disco: 40 GB SSD por VM
- SO: RHEL 9, CentOS 9, ou Ubuntu Server 20.04+
- Rede: Latência < 2ms entre as VMs

---

## Considerações de Rede e Segurança

- Liberar portas:
  - **RabbitMQ:** 4369 (EPMD), 25672 (inter-node), 5672 (AMQP), 15672 (management), 15692 (Prometheus)
  - **HAProxy:** portas públicas de entrada (5672, 5671, 15672, 15671)
- Recomenda-se uso de TLS para conexões externas
- Restringir acesso às portas apenas para IPs autorizados
- Sincronizar horário das VMs (NTP)

---

Este documento serve como referência para implantação, arquitetura e troubleshooting do cluster RabbitMQ com HAProxy dedicado.

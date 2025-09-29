# Como usar o coletor de métricas RabbitMQ

Este guia mostra como preparar, executar e automatizar a coleta de métricas do RabbitMQ usando o script `rmq_log.sh`.

---

## Preparar o script
1. Salve o conteúdo do script em um arquivo chamado `rmq_log.sh`.  
2. Dê permissão de execução:  
   ```
   chmod +x rmq_log.sh
   ```

---

## Executar snapshots manuais
Para gerar um snapshot único e registrar no CSV:

- Execução padrão (todos os vhosts e todas as filas, arquivo `rmq_log.csv` no diretório atual):  
  ```
  ./rmq_log.sh
  ```

- Escolher outro arquivo de saída:  
  ```
  ./rmq_log.sh --outfile teste.csv
  ```

- Filtrar filas por regex (exemplo: apenas filas que começam com `quorum-`):  
  ```
  ./rmq_log.sh --queue-regex '^quorum-'
  ```

- Combinar opções (exemplo: salvar em `quorum.csv` apenas as filas `quorum-*`):  
  ```
  ./rmq_log.sh --outfile quorum.csv --queue-regex '^quorum-'
  ```

---

## Executar periodicamente
O script pode ser rodado de tempos em tempos para acompanhar o comportamento do cluster.

- Usando `watch` (executa a cada 30 segundos e continua acrescentando ao arquivo):  
  ```
  watch -n 30 ./rmq_log.sh
  ```

- Usando loop em Bash (executa a cada 60 segundos até ser interrompido):  
  ```
  while true; do
    ./rmq_log.sh
    sleep 60
  done
  ```

- Usando `cron` (exemplo: rodar a cada 5 minutos e salvar em `/var/log/rabbitmq/rmq_log.csv`):  
  ```
  */5 * * * * /caminho/para/rmq_log.sh --outfile /var/log/rabbitmq/rmq_log.csv
  ```

---

## Localização do arquivo
- Por padrão, o arquivo de saída (`rmq_log.csv`) é criado no diretório em que o script foi executado.  
- Para gravar em um local fixo, use um caminho completo:  
  ```
  ./rmq_log.sh --outfile /var/log/rabbitmq/rmq_log.csv
  ```

---

## Formato da saída
Cada execução acrescenta uma ou mais linhas (uma por vhost) no arquivo CSV. O formato é:

```
ts,node,vhost,alarms,total_queues,total_msgs,total_ready,total_unacked,total_consumers,load1,load5,load15
```

Exemplo de linhas registradas:

```
2025-09-29T16:12:43-03:00,rabbit@node01,"/","",12,10345,10200,145,28,0.12,0.08,0.05
2025-09-29T16:12:43-03:00,rabbit@node01,"vhost_cliente","disk;mem",5,2450,2400,50,10,0.12,0.08,0.05
```

---

## Boas práticas
- Execute o script em todos os nodes do cluster para comparar resultados.  
- Durante testes de carga longos, prefira salvar em `/var/log/rabbitmq/` ou outro diretório de logs persistente.  
- Analise o arquivo CSV em ferramentas como Excel, Grafana ou Elastic para visualizar backlog de mensagens, consumo de CPU e alarmes ao longo do tempo.  

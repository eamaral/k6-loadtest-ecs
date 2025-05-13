FROM grafana/k6:latest

# Muda para root para instalar pacotes
USER root

# Instala curl, bash e ferramentas necessárias
RUN apk add --no-cache curl bash

# Copia os arquivos
COPY load-test.js /scripts/load-test.js
COPY entrypoint.sh /entrypoint.sh

# Permissão
RUN chmod +x /entrypoint.sh

# Volta para o usuário padrão do k6
USER 1000

ENTRYPOINT ["/entrypoint.sh"]

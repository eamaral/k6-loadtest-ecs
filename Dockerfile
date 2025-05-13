FROM grafana/k6:latest

# Instala curl, bash e ferramentas necessárias
RUN apk add --no-cache curl bash

# Copia os arquivos
COPY test/load-test.js /scripts/load-test.js
COPY entrypoint.sh /entrypoint.sh

# Permissão e entrypoint
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

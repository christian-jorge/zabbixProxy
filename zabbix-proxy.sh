#!/usr/bin/env bash
set -euo pipefail

# --- 0. Variáveis interativas ---
read -s -p "Senha root do MySQL: " MYSQL_ROOT_PASSWORD
echo

read -p "Nome do banco MySQL: " MYSQL_DATABASE
MYSQL_DATABASE=${MYSQL_DATABASE:-proxy_db}

read -p "Usuário MySQL: " MYSQL_USER
MYSQL_USER=${MYSQL_USER:-zabbix}

read -s -p "Senha do usuário MySQL: " MYSQL_PASSWORD
echo

read -p "Host e porta do Zabbix Server (ex: 111.111.111.111:10051): " ZBX_SERVER_HOST

read -p "Hostname do proxy (deve bater no cadastro do Zabbix): " ZBX_HOSTNAME
ZBX_HOSTNAME=${ZBX_HOSTNAME:-cliente}

echo
echo "→ Variáveis definidas:"
echo "   MYSQL_ROOT_PASSWORD=******"
echo "   MYSQL_DATABASE= $MYSQL_DATABASE"
echo "   MYSQL_USER=     $MYSQL_USER"
echo "   MYSQL_PASSWORD= ******"
echo "   ZBX_SERVER_HOST=$ZBX_SERVER_HOST"
echo "   ZBX_HOSTNAME=   $ZBX_HOSTNAME"
echo

# --- 1. Atualiza e instala Docker e Docker Compose ---
echo "1/9 Instalando Docker e Docker Compose..."
apt update
apt install -y docker.io docker-compose
systemctl enable --now docker

# --- 2. Preparando diretório do projeto ---
PROJECT_DIR="/opt/zabbix-proxy"
echo "2/9 Preparando diretório ${PROJECT_DIR}..."
mkdir -p "${PROJECT_DIR}"
cd "${PROJECT_DIR}"

# --- 3. Cria .gitignore se não existir e garante que .env está ignorado ---
echo "3/9 Ajustando .gitignore..."
touch .gitignore
grep -qxF ".env" .gitignore || echo ".env" >> .gitignore

# --- 4. Escreve o arquivo .env ---
echo "4/9 Gerando .env..."
cat > .env <<EOF
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
MYSQL_DATABASE=${MYSQL_DATABASE}
MYSQL_USER=${MYSQL_USER}
MYSQL_PASSWORD=${MYSQL_PASSWORD}
ZBX_SERVER_HOST=${ZBX_SERVER_HOST}
ZBX_HOSTNAME=${ZBX_HOSTNAME}
EOF
chmod 600 .env

# --- 5. Cria diretórios de volumes e ajusta permissões ---
echo "5/9 Criando volumes e ajustando permissões..."
DIRS=(
  mysql_data
  zbx_proxy_modules
  zbx_proxy_ssh_keys
  zbx_proxy_ssl_certs
  zbx_proxy_ssl_keys
  zbx_proxy_ssl_ca
)
for d in "${DIRS[@]}"; do
  mkdir -p "${d}"
done
chown -R 100:100 mysql_data zbx_proxy_*

# --- 6. Gera docker-compose.yml usando variáveis ${} ---
echo "6/9 Gerando docker-compose.yml..."
cat > docker-compose.yml <<'EOF'
version: '3.8'

services:
  mariadb:
    image: mariadb:10.5
    container_name: zabbix-proxy-db
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: "${MYSQL_ROOT_PASSWORD}"
      MYSQL_DATABASE:      "${MYSQL_DATABASE}"
      MYSQL_USER:          "${MYSQL_USER}"
      MYSQL_PASSWORD:      "${MYSQL_PASSWORD}"
    volumes:
      - ./mysql_data:/var/lib/mysql
    networks:
      - zbxnet

  zabbix-proxy:
    image: zabbix/zabbix-proxy-mysql:alpine-6.2.9
    container_name: zabbix-proxy
    depends_on:
      - mariadb
    restart: unless-stopped
    environment:
      DB_SERVER_HOST: "mariadb"
      MYSQL_USER:     "${MYSQL_USER}"
      MYSQL_PASSWORD: "${MYSQL_PASSWORD}"
      MYSQL_DATABASE: "${MYSQL_DATABASE}"
      ZBX_SERVER_HOST: "${ZBX_SERVER_HOST}"
      ZBX_HOSTNAME:    "${ZBX_HOSTNAME}"
      ZBX_PROXYMODE:   0
    ports:
      - "10051:10051"
    volumes:
      - ./zbx_proxy_modules:/var/lib/zabbix/modules
      - ./zbx_proxy_ssh_keys:/var/lib/zabbix/ssh_keys
      - ./zbx_proxy_ssl_certs:/var/lib/zabbix/ssl/certs
      - ./zbx_proxy_ssl_keys:/var/lib/zabbix/ssl/keys
      - ./zbx_proxy_ssl_ca:/var/lib/zabbix/ssl/ssl_ca
    networks:
      - zbxnet

networks:
  zbxnet:
    driver: bridge
EOF

# --- 7. Sobe containers ---
echo "7/9 Subindo containers..."
docker-compose up -d

# --- 8. Cria serviço systemd ---
echo "8/9 Criando serviço systemd..."
SERVICE_FILE="/etc/systemd/system/zabbix-proxy.service"
cat > "${SERVICE_FILE}" <<EOF
[Unit]
Description=Zabbix Proxy via Docker Compose
Requires=docker.service
After=docker.service

[Service]
WorkingDirectory=${PROJECT_DIR}
ExecStart=/usr/bin/docker-compose up -d
ExecStop=/usr/bin/docker-compose down
RemainAfterExit=yes
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable zabbix-proxy.service

# --- 9. Inicia o serviço ---
echo "9/9 Iniciando serviço zabbix-proxy.service..."
systemctl start zabbix-proxy.service

echo
echo "✅ Concluído! Use 'journalctl -u zabbix-proxy.service -f' para acompanhar os logs."

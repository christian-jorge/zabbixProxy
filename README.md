# ZabbixProxy

Repositório com scripts e recursos para implantação rápida do **Zabbix Proxy** utilizando Docker Compose, facilitando o monitoramento distribuído em ambientes com múltiplas redes e localidades.

## Visão Geral

Este projeto automatiza a instalação, configuração e atualização do Zabbix Proxy, permitindo a integração com ambientes Zabbix Server para monitoramento remoto de hosts de forma segura e eficiente.

## Principais Recursos

- Deploy rápido via Docker Compose
- Scripts para setup, atualização e gerenciamento
- Compatível com bancos MySQL/MariaDB
- Estrutura personalizável por variáveis de ambiente
- Exemplo de service para uso em sistemas Linux com systemd

## Pré-requisitos

- Docker instalado
- Docker Compose instalado
- Acesso ao repositório do Zabbix Proxy Docker

## Instalação

Clone o repositório:

```bash
git clone https://github.com/christian-jorge/zabbixProxy.git
cd zabbixProxy
Copie o arquivo de exemplo de variáveis e edite conforme seu ambiente:

bash
Copiar
Editar
cp .env.example .env
nano .env
Edite as variáveis de conexão com banco, endereço do Zabbix Server e nome do proxy.

Uso
Para subir o proxy:

bash
Copiar
Editar
docker-compose up -d
Para parar:

bash
Copiar
Editar
docker-compose down
Verifique os logs com:

bash
Copiar
Editar
docker-compose logs -f
Scripts Úteis
zabbix-proxy.sh: Automação do deploy, atualização e verificação do ambiente

.gitignore: Padrão para evitar commits de arquivos sensíveis

Exemplo de service: zabbix-proxy.service para uso com systemd (Linux)

Customização
Altere as configurações do arquivo .env para adaptar o proxy ao seu cenário, incluindo:

Endereço do servidor Zabbix (ZBX_SERVER_HOST)

Porta do servidor Zabbix (ZBX_SERVER_PORT)

Nome do Proxy (ZBX_PROXY_HOSTNAME)

Credenciais do banco de dados

Exemplo de .env
env
Copiar
Editar
ZBX_SERVER_HOST=zabbix.meu.dominio.com
ZBX_SERVER_PORT=10051
ZBX_PROXY_HOSTNAME=proxy-local
MYSQL_ROOT_PASSWORD=suasenha
MYSQL_USER=zabbix
MYSQL_PASSWORD=zabbix
MYSQL_DATABASE=zabbix_proxy
Atualização
Para atualizar a imagem ou os scripts:

bash
Copiar
Editar
git pull
docker-compose pull
docker-compose up -d
Créditos
Desenvolvido por Christian Andrei Nascimento Jorge.

Licença
Este projeto está licenciado sob a MIT License.

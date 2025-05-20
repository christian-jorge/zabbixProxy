# Zabbix Proxy com Docker Compose

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Repositório para implantação rápida e eficiente do Zabbix Proxy utilizando Docker Compose, facilitando o monitoramento distribuído em ambientes com múltiplas redes e localidades.

---

## 🚀 Visão Geral

Este projeto automatiza a instalação, configuração e atualização do Zabbix Proxy em containers Docker, proporcionando integração fácil com o Zabbix Server para monitoramento remoto de hosts de forma segura e eficiente.

**Principais Recursos:**
- Deploy automatizado via script (instala Docker e Docker Compose se necessário)
- Preenchimento interativo das variáveis de ambiente durante a instalação
- Suporte a bancos de dados MySQL/MariaDB
- Scripts de setup, atualização e gerenciamento
- Estrutura personalizável por variáveis de ambiente
- Exemplo de configuração como serviço (systemd)

---

## 🛠️ Pré-requisitos

- Permissão de root ou sudo no servidor Linux
- Conexão à internet para baixar pacotes

> O script de instalação cuida de tudo, incluindo a instalação do Docker, Docker Compose e preenchimento das variáveis de ambiente de forma **interativa**!

---

## ⚙️ Instalação

### 1. Clone este repositório

```bash
git clone https://github.com/christian-jorge/zabbixProxy.git
cd zabbixProxy
```

### 2. Execute o script de instalação

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

**Durante a execução do script, você será guiado por um assistente interativo que irá solicitar os principais dados de configuração, como:**

- Senha root do MySQL

- Nome do banco de dados

- Usuário e senha do banco

- Endereço do Zabbix Server

- Nome do Proxy

**Essas informações serão usadas para preencher automaticamente o arquivo .env necessário para o funcionamento do Docker Compose.**

> Dica: Se não tiver todas as informações em mãos, basta pressionar **Ctrl+C** para sair e reiniciar quando desejar

---

### 3. Inicie o Zabbix Proxy

```bash
docker-compose up -d
```

## 📝 Configuração

### Banco de Dados:
- **O proxy utiliza MySQL/MariaDB para armazenar dados temporários de monitoramento.**

### Variáveis de Ambiente:
- **Todas as variáveis essenciais são preenchidas durante a execução do script de setup.**

## 💡 Exemplo de Uso
**Para iniciar:**

```bash
docker-compose up -d
```

**Para atualizar ou reiniciar o proxy:**

```bash
docker-compose pull
docker-compose down
docker-compose up -d
```

## 📸 Exemplo do Processo Interativo
**Exemplo do que será exibido ao rodar o script de instalação:**

```bash
Senha root do MySQL:
Nome do banco MySQL:
Usuário do banco MySQL:
Senha do banco MySQL:
Endereço do Zabbix Server:
Nome do Proxy:
...
Configuração concluída!
```

> Tudo pronto! Seu ambiente estará configurado automaticamente após responder as perguntas do script.

---

## ❓ FAQ (Perguntas Frequentes)
**Posso rodar o script mais de uma vez?**

- Sim! O script pode ser executado novamente a qualquer momento para reconfigurar variáveis ou reinstalar componentes.

**Preciso ter Docker já instalado?**

- Não! O script verifica e instala Docker e Docker Compose automaticamente se necessário.

**Como monitoro se o proxy está rodando?**

- Execute docker ps para ver os containers ativos ou acompanhe os logs com:

```bash
docker-compose logs -f
```

## 📄 Licença
Este projeto está licenciado sob a licença MIT. Consulte o arquivo LICENSE para mais informações.

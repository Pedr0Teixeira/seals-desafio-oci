# Desafio SEALS OCI - Arquitetura de Produção com OKE e FSDR

Este repositório contém todos os artefatos e a documentação para a construção, configuração e operação de um ambiente de produção completo na **Oracle Cloud Infrastructure (OCI)**, com foco em **Kubernetes (OKE)**, banco de dados **MySQL**, segurança com **WAF**, alta disponibilidade e **Disaster Recovery com Full Stack DR (FSDR)**.

---

## Arquitetura Proposta

A solução foi implementada em um modelo **multi-região** para garantir resiliência e continuidade do negócio:

- **Região Primária:** `sa-saopaulo-1` (São Paulo)  
- **Região Secundária (DR):** `sa-vinhedo-1` (Vinhedo)  
- **Compartimento:** `ccmlab (root)/CCM-SEALS/PTEIXEIRA`

---

## 1. Provisionamento da Infraestrutura com Terraform (IaC)

Toda a infraestrutura, tanto na região primária quanto na de DR, foi provisionada utilizando **Terraform** para garantir consistência e automação.

- **`terraform/`:** Código para provisionar recursos na região primária (São Paulo).  
- **`terraform-dr/`:** Cópia adaptada para a região de DR (Vinhedo), com ajustes de CIDR e nomes.

### Recursos Provisionados

- **Networking:** VCN, Subnets (públicas/privadas), Internet Gateway, NAT Gateway, Service Gateway, DRGs, Route Tables, Security Lists.  
- **Kubernetes (OKE):** Cluster OKE com **node pool de 3 workers** distribuídos em diferentes Fault Domains.  
- **Banco de Dados:** Instância **OCI MySQL Database Service** em subnet privada.  
- **Acesso Seguro:** **OCI Bastion** para acesso administrativo seguro.  

### Como Executar

```bash
cd terraform      # ou terraform-dr
# Preencha o arquivo terraform.tfvars com as credenciais
terraform init
terraform plan
terraform apply
```

---

## 2. Aplicação Web no OKE com GitOps

A aplicação web (**NGINX**) é implantada e gerenciada no cluster Kubernetes através do **ArgoCD** (**GitOps**).

### Componentes no Cluster

- **ArgoCD:** Sincroniza os manifestos Kubernetes versionados neste repositório.  
- **NGINX Ingress Controller:** Instalado via Helm, provê OCI Load Balancer e gerencia tráfego externo.  
- **Aplicação Web:**
  - Namespace: `app-producao`  
  - Deployment: 2 réplicas da aplicação  
  - Service: `ClusterIP` para exposição interna  
  - Ingress: Regras de tráfego → Service  
  - ConfigMap & Secret: Armazenam credenciais do MySQL  

> Manifestos no diretório: `k8s-manifests/`

---

## 3. Configurações Manuais na Console OCI

Alguns ajustes complementares foram realizados manualmente:

- **Remote Peering Connection:** Peering entre os DRGs (SP ↔ VH).  
- **Replicação MySQL:** Configurado canal de replicação Vinhedo ← São Paulo.  
- **OCI Vault:** Cofre + chave para armazenar senhas usadas pelo FSDR.  
- **WAF:** Política associada ao Load Balancer com proteção contra SQL Injection e controle de IP.  

---

## 4. Disaster Recovery com FSDR

O **OCI Full Stack DR (FSDR)** foi configurado para orquestrar failover entre regiões.

- **Protection Groups:**
  - `PG_SEALS_SAOPAULO` (Primary)  
  - `PG_SEALS_VINHEDO` (Standby)  
  - Incluem: OKE, Worker Nodes, Load Balancer, MySQL  

- **DR Plan:** Plano de **Failover** com passos automatizados e manuais.  

---

## ✅ Guia de Entregas do Desafio

### Item 1: Cluster Kubernetes (OKE) com Aplicação Web
- **Arquivos YAML:** `k8s-manifests/`  
- **Obter IP público do Load Balancer:**
  ```bash
  kubectl get svc -n ingress-nginx
  ```
- **Listar recursos no namespace da aplicação:**
  ```bash
  kubectl get all -n app-producao
  ```

---

### Item 2: Instance MySQL em PaaS
- **Scripts Terraform:** `terraform/` e `terraform-dr/`  
- **Dump da base:**
  ```bash
  mysqldump -h 127.0.0.1 -u admin -p webappdb > dump.sql
  ```
- **Conexão no Deployment:** `secret.yaml`, `configmap.yaml`, `deployment.yaml`  
- **Validação:** Print da aplicação exibindo variáveis de conexão.  

---

### Item 3: Load Balancer com WAF
- **IP público:** mesmo do Item 1.  
- **Política WAF:** Navegar em *Identity & Security > WAF > WAF_Policy_Seals*.  

---

### Item 4: Disaster Recovery com FSDR
- **Protection Groups:** Print dos grupos (SP e VH).  
- **DR Plan:** Print mostrando passos.  
- **Replicação MySQL:** Canal ativo em Vinhedo.  
- **Aplicação no DR:** Mesmos `k8s-manifests/`.  

---

### Item 5: Segurança, Monitoramento e Acesso
- **NSGs:** Definições em `terraform/security.tf` e `terraform-dr/security.tf`.  
- **Alarme de CPU:** Print de alarme criado.  
- **Logs:** Print de eventos em *Observability & Management > Logging*.  
- **Política IAM:** Print da política criada para o FSDR.  

---

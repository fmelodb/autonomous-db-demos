
DROP TABLE candidates PURGE;

CREATE TABLE candidates (
  id          NUMBER         PRIMARY KEY,
  name        VARCHAR2(100)  NOT NULL,
  area_label  VARCHAR2(30)   NOT NULL,  -- ground truth p/ avaliar resultados
  variation   VARCHAR2(15)   NOT NULL,  -- canonical | ambiguous | trap
  profile     CLOB           NOT NULL   -- coluna única indexada pelo HVI
);

-- =====================================================================
-- DEVELOPER (8)
-- =====================================================================
INSERT INTO candidates VALUES (1, 'Lucas Almeida', 'developer', 'canonical',
'Desenvolvedor backend sênior em Java e Spring Boot. Construo microserviços REST, integro com Kafka e PostgreSQL via JPA/Hibernate. Forte em design patterns, TDD com JUnit e Mockito, code review e arquitetura hexagonal.');

INSERT INTO candidates VALUES (2, 'Marina Costa', 'developer', 'canonical',
'Full-stack developer com 5 anos em React, TypeScript e Node.js. Desenvolvo SPAs, APIs GraphQL e integro com Stripe e Auth0. Experiência com Next.js, Tailwind e testes E2E com Playwright.');

INSERT INTO candidates VALUES (3, 'Pedro Henrique', 'developer', 'canonical',
'Backend engineer em Python e Django. Construo APIs REST com DRF, integro Celery para tarefas assíncronas e Redis para cache. Forte em ORM, migrations e pytest.');

INSERT INTO candidates VALUES (4, 'Camila Rocha', 'developer', 'ambiguous',
'Desenvolvedora backend que trabalha diariamente em ambiente Linux, usa Docker para subir dependências locais, escreve scripts Python de apoio e queries SQL para integrar com PostgreSQL. Foco em APIs em Go.');

INSERT INTO candidates VALUES (5, 'Rafael Tanaka', 'developer', 'ambiguous',
'Software engineer building cloud-native apps on AWS and Kubernetes. Writes Java services, configures Helm charts and CI/CD pipelines on GitLab. Daily use of Linux, Git and Docker for local development.');

INSERT INTO candidates VALUES (6, 'Beatriz Mendes', 'developer', 'ambiguous',
'Engenheira de software focada em backend Node.js. Lida com SQL complexo, otimiza queries no PostgreSQL e deploya containers Docker. Conhece Terraform para provisionar a infra dos próprios serviços.');

INSERT INTO candidates VALUES (7, 'Diego Ferreira', 'developer', 'trap',
'Desenvolvedor que automatiza tarefas com bash e Python, mantém scripts de deploy, configura nginx e gerencia servidores Linux do time. Construo APIs em Flask e integro com Prometheus para métricas.');

INSERT INTO candidates VALUES (8, 'Isabela Souza', 'developer', 'trap',
'Backend developer que trabalha com tuning de queries SQL, índices em PostgreSQL, particionamento de tabelas grandes e replicação read-replica. Construo APIs REST em Ruby on Rails consumindo esses dados.');

-- =====================================================================
-- DEVOPS / SRE / INFRA (8)
-- =====================================================================
INSERT INTO candidates VALUES (9, 'Thiago Barbosa', 'devops', 'canonical',
'SRE sênior com foco em confiabilidade e observabilidade. Opero clusters Kubernetes em produção, configuro Prometheus, Grafana e Loki, implemento SLOs e error budgets. Forte em Terraform, Ansible e GitOps com ArgoCD.');

INSERT INTO candidates VALUES (10, 'Juliana Pires', 'devops', 'canonical',
'DevOps engineer especialista em pipelines CI/CD com Jenkins e GitHub Actions. Automatizo deploys blue-green, gerencio Helm charts e configuro service mesh Istio. Experiência com chaos engineering usando LitmusChaos.');

INSERT INTO candidates VALUES (11, 'Bruno Carvalho', 'devops', 'canonical',
'Platform engineer construindo internal developer platforms. Mantenho Backstage, automatizo provisioning multi-cloud com Crossplane e Pulumi, opero fleets de Kubernetes em AWS EKS e GCP GKE.');

INSERT INTO candidates VALUES (12, 'Fernanda Lopes', 'devops', 'ambiguous',
'Engenheira de infra que escreve muito Python para automação, mantém scripts SQL de manutenção de bancos e administra servidores Linux RHEL e Ubuntu. Opero Docker Swarm e Kubernetes em produção.');

INSERT INTO candidates VALUES (13, 'André Vasconcelos', 'devops', 'ambiguous',
'Cloud infrastructure engineer working with AWS, Linux servers, Docker containers and SQL databases. Builds automation in Python and Go, manages networking with VPC peering and Transit Gateway, runs Kubernetes workloads.');

INSERT INTO candidates VALUES (14, 'Patrícia Nogueira', 'devops', 'ambiguous',
'SRE que opera bancos PostgreSQL e MySQL em alta disponibilidade, configura replicação, monitora performance de queries SQL e mantém o tuning do kernel Linux dos hosts. Forte em Terraform e Ansible.');

INSERT INTO candidates VALUES (15, 'Marcelo Dias', 'devops', 'trap',
'Engenheiro que mantém firewalls iptables, configura roteamento entre VPCs, gerencia VPNs site-to-site e túneis IPsec. Automatiza tudo via Python e Ansible, opera Linux e containers Docker.');

INSERT INTO candidates VALUES (16, 'Larissa Moura', 'devops', 'trap',
'Engenheira que faz hardening de Linux servers, configura SELinux, audita logs com Falco, escaneia imagens Docker com Trivy e implementa políticas de admission no Kubernetes via OPA Gatekeeper.');

-- =====================================================================
-- DBA (7)
-- =====================================================================
INSERT INTO candidates VALUES (17, 'Roberto Siqueira', 'dba', 'canonical',
'DBA Oracle sênior com 12 anos de experiência. Especialista em RAC, Data Guard, ASM, AWR, tuning de SQL plans, gerenciamento de tablespaces, RMAN backups e upgrades de versão. Administro Linux RHEL nos servidores de banco.');

INSERT INTO candidates VALUES (18, 'Vanessa Pereira', 'dba', 'canonical',
'PostgreSQL DBA focada em performance e replicação. Configuro streaming replication, logical replication, particionamento de tabelas grandes, tuning de autovacuum e análise de query plans com EXPLAIN ANALYZE.');

INSERT INTO candidates VALUES (19, 'Eduardo Ramos', 'dba', 'canonical',
'MySQL and MariaDB DBA. Experienced in InnoDB tuning, GTID replication, ProxySQL, Percona toolkit, backup strategies with XtraBackup and schema migrations on large production databases.');

INSERT INTO candidates VALUES (20, 'Cláudia Martins', 'dba', 'ambiguous',
'DBA que escreve muito Python para automatizar manutenção, opera bancos em containers Docker no Kubernetes, mantém os servidores Linux dos bancos e integra com pipelines CI/CD para schema migrations.');

INSERT INTO candidates VALUES (21, 'Felipe Andrade', 'dba', 'ambiguous',
'Database engineer working on AWS RDS and Aurora. Manages Linux-based instances, writes Python automation scripts, integrates with Terraform for IaC and tunes SQL workloads for OLTP and analytics.');

INSERT INTO candidates VALUES (22, 'Renata Cardoso', 'dba', 'trap',
'Engenheira de dados que modela schemas dimensionais, escreve SQL complexo, faz tuning de queries em Snowflake e Redshift, mantém pipelines de ingestão em Airflow e transformações em dbt.');

INSERT INTO candidates VALUES (23, 'Gustavo Lima', 'dba', 'trap',
'Especialista em segurança de bancos de dados. Faço hardening de PostgreSQL e Oracle, configuro TDE, auditoria com Oracle Audit Vault, controle de acesso fine-grained e detecção de SQL injection.');

-- =====================================================================
-- NETWORK ENGINEER (7)
-- =====================================================================
INSERT INTO candidates VALUES (24, 'Sérgio Pinheiro', 'network', 'canonical',
'Engenheiro de redes sênior CCNP/CCIE. Projeto e opero redes corporativas com switches Cisco Nexus, roteadores ISR, BGP, OSPF, MPLS e VPNs IPsec. Forte em troubleshooting com Wireshark e tcpdump.');

INSERT INTO candidates VALUES (25, 'Adriana Teixeira', 'network', 'canonical',
'Network engineer specialized in cloud networking. Designs AWS VPC architectures, Direct Connect, Transit Gateway, VPN tunnels and hybrid connectivity. Strong in SD-WAN, BGP peering and route policies.');

INSERT INTO candidates VALUES (26, 'Ricardo Cavalcanti', 'network', 'canonical',
'Especialista em redes data center. Configuro fabrics VXLAN/EVPN, spine-leaf topology, QoS, multicast e protocolos de roteamento dinâmico. Experiência com Arista, Juniper e Cisco ACI.');

INSERT INTO candidates VALUES (27, 'Mônica Alvarenga', 'network', 'ambiguous',
'Engenheira de redes que automatiza configuração de switches via Python e Ansible, opera em ambiente Linux, usa Docker para labs e mantém scripts de monitoramento. Forte em BGP e MPLS.');

INSERT INTO candidates VALUES (28, 'Henrique Batista', 'network', 'ambiguous',
'Network engineer working on cloud-native networking. Manages Kubernetes CNI plugins like Calico and Cilium, configures service mesh networking, Linux iptables and nftables, automates with Python.');

INSERT INTO candidates VALUES (29, 'Tatiana Reis', 'network', 'trap',
'Engenheira que faz análise de tráfego para detectar intrusões, opera IDS Snort e Suricata, configura firewalls Palo Alto e captura pacotes para forensics. Forte em TLS inspection e DNS filtering.');

INSERT INTO candidates VALUES (30, 'Vinícius Aragão', 'network', 'trap',
'Engenheiro que opera load balancers F5 e HAProxy, configura ingress controllers no Kubernetes, mantém certificados TLS e otimiza latência de aplicações web. Conhece HTTP/2, gRPC e CDN tuning.');

-- =====================================================================
-- SECURITY ENGINEER (7)
-- =====================================================================
INSERT INTO candidates VALUES (31, 'Daniela Freitas', 'security', 'canonical',
'Security engineer com foco em AppSec. Faço threat modeling, code review de segurança, SAST/DAST com SonarQube e Burp Suite, gerencio o programa de bug bounty e respondo a incidentes.');

INSERT INTO candidates VALUES (32, 'Leonardo Sampaio', 'security', 'canonical',
'Offensive security specialist. Conduct red team engagements, penetration testing on web apps and infrastructure, exploit development, Active Directory attacks and post-exploitation with Cobalt Strike.');

INSERT INTO candidates VALUES (33, 'Carla Bittencourt', 'security', 'canonical',
'GRC and compliance lead. Implemento ISO 27001, SOC 2 e LGPD, conduzo risk assessments, gerencio políticas de segurança e programa de awareness. Forte em frameworks NIST e CIS Controls.');

INSERT INTO candidates VALUES (34, 'Otávio Machado', 'security', 'ambiguous',
'Security engineer que faz hardening de servidores Linux, audita configurações Docker e Kubernetes, escreve automação em Python para varreduras e analisa logs de rede para detecção de ameaças.');

INSERT INTO candidates VALUES (35, 'Sabrina Castro', 'security', 'ambiguous',
'Cloud security engineer working on AWS. Configures IAM policies, GuardDuty, Security Hub, scans Terraform code with Checkov, hardens Kubernetes clusters and monitors SQL injection attempts on databases.');

INSERT INTO candidates VALUES (36, 'Paulo Henrique Vieira', 'security', 'trap',
'Engenheiro que monitora performance de aplicações, mantém SIEM Splunk, escreve queries complexas para correlação de eventos, opera EDR CrowdStrike e automatiza response em Python.');

INSERT INTO candidates VALUES (37, 'Amanda Resende', 'security', 'trap',
'Especialista em DevSecOps. Integro security scanning em pipelines CI/CD, gerencio secrets com Vault, configuro policies como código com OPA e faço shift-left security em pull requests.');

-- =====================================================================
-- DATA ENGINEER (8)
-- =====================================================================
INSERT INTO candidates VALUES (38, 'Rodrigo Bastos', 'data_eng', 'canonical',
'Engenheiro de dados sênior, 7 anos construindo pipelines em Airflow e Spark com Python. Atuo com ingestão batch e streaming via Kafka, modelagem em data lake S3, formato Parquet e Delta Lake.');

INSERT INTO candidates VALUES (39, 'Letícia Gonçalves', 'data_eng', 'canonical',
'Data engineer especializada em lakehouse Databricks. Desenvolvo jobs PySpark, transformações em dbt, orquestração com Airflow e modelagem dimensional para BI. Forte em otimização de jobs e custos cloud.');

INSERT INTO candidates VALUES (40, 'Fábio Monteiro', 'data_eng', 'canonical',
'Senior data engineer building streaming systems with Apache Flink and Kafka. Designs schemas with Avro and Protobuf, manages schema registry and builds real-time analytics platforms on Kubernetes.');

INSERT INTO candidates VALUES (41, 'Priscila Coutinho', 'data_eng', 'ambiguous',
'Engenheira que constrói pipelines de ingestão, opera bancos PostgreSQL e Redshift, escreve muito SQL complexo, mantém Docker images dos jobs e administra Linux nos workers do cluster Spark.');

INSERT INTO candidates VALUES (42, 'Maurício Teixeira', 'data_eng', 'ambiguous',
'Data platform engineer working on AWS. Builds Python pipelines, manages Kubernetes-based Spark on EKS, tunes SQL on Redshift, configures networking between VPCs for cross-account data sharing.');

INSERT INTO candidates VALUES (43, 'Aline Figueiredo', 'data_eng', 'ambiguous',
'Engenheira de dados que automatiza infra com Terraform, opera clusters Kubernetes para rodar Airflow, mantém Docker images customizadas e escreve Python para transformação de dados em larga escala.');

INSERT INTO candidates VALUES (44, 'Caio Branco', 'data_eng', 'trap',
'Engenheiro de machine learning que constrói feature stores, mantém pipelines de treino em Kubeflow, versiona datasets com DVC e deploya modelos em produção via Seldon. Trabalho diário com Python e Spark.');

INSERT INTO candidates VALUES (45, 'Joana Pacheco', 'data_eng', 'trap',
'Analytics engineer focada em dbt e modelagem analítica. Construo data marts, escrevo testes de qualidade de dados, documento lineage no dbt docs e atendo demandas de BI no Looker e Tableau.');

-- =====================================================================
-- CLOUD ARCHITECT (5)
-- =====================================================================
INSERT INTO candidates VALUES (46, 'Eduardo Salgado', 'cloud_arch', 'canonical',
'Cloud architect AWS Solutions Architect Professional. Desenho arquiteturas multi-region, well-architected reviews, estratégias de DR, landing zones com Control Tower e governança via SCPs e Config rules.');

INSERT INTO candidates VALUES (47, 'Bianca Oliveira', 'cloud_arch', 'canonical',
'Principal cloud architect specialized in Azure and GCP. Designs enterprise landing zones, hub-and-spoke networks, identity federation with Entra ID and cost optimization strategies at scale.');

INSERT INTO candidates VALUES (48, 'Murilo Cavalcante', 'cloud_arch', 'ambiguous',
'Arquiteto de soluções cloud que combina Kubernetes, Terraform, networking de VPC, segurança IAM e bancos gerenciados RDS. Escreve Python para automação e mantém padrões em Linux nos workloads.');

INSERT INTO candidates VALUES (49, 'Helena Drummond', 'cloud_arch', 'ambiguous',
'Cloud solutions architect designing hybrid environments. Works with AWS Direct Connect, on-prem Linux servers, Kubernetes clusters, Docker registries, SQL databases migrations and Python automation.');

INSERT INTO candidates VALUES (50, 'Tiago Esteves', 'cloud_arch', 'trap',
'Arquiteto focado em arquiteturas event-driven e microserviços. Desenho com EventBridge, SNS/SQS, Kafka, Lambda, Step Functions e padrões saga, CQRS e event sourcing em DynamoDB.');

-- =====================================================================
-- ML ENGINEER (5)
-- =====================================================================
INSERT INTO candidates VALUES (51, 'Natália Boaventura', 'ml_eng', 'canonical',
'Machine learning engineer com foco em LLMs e RAG. Fine-tuning com PEFT/LoRA, serving com vLLM e TGI, embeddings em vector databases e avaliação com RAGAS. Forte em PyTorch e Hugging Face.');

INSERT INTO candidates VALUES (52, 'Gabriel Antunes', 'ml_eng', 'canonical',
'ML platform engineer building MLOps infrastructure. Implements model registry with MLflow, feature stores with Feast, online inference with KServe and continuous training pipelines on Kubernetes.');

INSERT INTO candidates VALUES (53, 'Cristina Vargas', 'ml_eng', 'ambiguous',
'Engenheira de ML que constrói pipelines de dados em Python e Spark, opera clusters Kubernetes para treino distribuído, mantém Docker images com CUDA e otimiza queries SQL para feature engineering.');

INSERT INTO candidates VALUES (54, 'Renan Pessoa', 'ml_eng', 'ambiguous',
'ML engineer working with computer vision models on AWS SageMaker. Manages Linux GPU instances, writes Python training code, builds Docker images and integrates with data pipelines on S3 and Athena SQL.');

INSERT INTO candidates VALUES (55, 'Mariana Vilanova', 'ml_eng', 'trap',
'Cientista de dados que faz análise estatística, A/B testing, modelagem preditiva em Python com scikit-learn e XGBoost. Escrevo SQL no warehouse para extrair features e apresento insights ao negócio.');

COMMIT;


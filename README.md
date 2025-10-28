# 📚 Portal PoliEduca

## 🧩 Descrição do Projeto
O **Portal PoliEduca** é uma plataforma **web e mobile** desenvolvida para facilitar a comunicação e a gestão acadêmica entre **professores e alunos**.  
A solução centraliza informações como **disciplinas, notas, atividades e avisos**, tornando o acompanhamento mais transparente e eficiente.

---

## 🎯 Objetivos
- Oferecer aos professores um **painel administrativo** para gerenciar alunos, turmas, notas e atividades.  
- Permitir que alunos visualizem **notas, posts e mensagens** de forma clara e organizada.  
- Melhorar a **transparência e comunicação** entre docentes e discentes.  

---

## 👥 Público-Alvo
- Professores e administradores das escolas **Poliedro**.  
- Alunos do ensino **médio e superior**.  
- Instituições parceiras: **Instituto Mauá de Tecnologia** e **Poliedro**.

---

## ⚙️ Funcionalidades Principais

### 👨‍🏫 Professores
- ✅ Criar, editar e excluir disciplinas com cores personalizadas
- ✅ Cadastrar e gerenciar alunos
- ✅ Criar, editar e deletar atividades com datas de entrega
- ✅ Registrar notas e comentários para os alunos
- ✅ Matricular e desmatricular alunos em disciplinas
- ✅ Visualizar estatísticas em tempo real (dashboard)
- ✅ Buscar alunos por nome, RA ou email
- 🚧 Enviar e receber mensagens (em desenvolvimento)
- 🚧 Gerenciar materiais (aguardando MongoDB)

### 👨‍🎓 Alunos
- ✅ Visualizar todas as disciplinas matriculadas
- ✅ Ver notas e médias calculadas automaticamente
- ✅ Acompanhar atividades por disciplina
- ✅ Dashboard com estatísticas pessoais
- ✅ Visualizar detalhes de cada disciplina
- 🚧 Ler posts e avisos das disciplinas (em desenvolvimento)
- 🚧 Mensagens com professores (em desenvolvimento)
- 🚧 Download de materiais (aguardando MongoDB)  

---

## 💻 Tecnologias Utilizadas

| Categoria | Ferramenta / Linguagem |
|------------|------------------------|
| **Frontend / Mobile** | [Flutter](https://flutter.dev) 3.35.6 |
| **Backend** | [Dart Shelf](https://pub.dev/packages/shelf) 1.4.2 |
| **Database (Relacional)** | [PostgreSQL](https://www.postgresql.org) 18.0 |
| **Database (Documentos)** | [MongoDB](https://www.mongodb.com) (em planejamento) |
| **Controle de versão** | [GitHub](https://github.com) |
| **Design e prototipagem** | [Figma](https://www.figma.com) |
| **Gerenciamento ágil** | [Trello](https://trello.com) |

### 🏗 Arquitetura Atual
- **Backend RESTful** com Dart Shelf
- **Banco de dados híbrido:**
  - PostgreSQL para dados estruturados (usuários, disciplinas, notas)
  - MongoDB (planejado) para materiais didáticos e arquivos
- **Autenticação** em desenvolvimento (dev mode implementado)
- **API endpoints** completos para CRUD de todas as entidades
- **Design responsivo** com suporte a múltiplos tamanhos de tela  

---

## 🧠 Metodologia

O projeto segue o framework **SCRUM**, com sprints quinzenais e entregas incrementais.

### 🧩 Papéis no Time
| Função | Integrante |
|--------|-------------|
| **Product Owner (PO)** | Mariana Boschetti Castellani |
| **Scrum Master** | Murilo Rodrigues dos Santos |
| **Desenvolvedores** | Henrique Impastaro, Matheus Garcia Mattoso |

---

## 📝 Backlog do Produto (Principais Histórias de Usuário)

| Categoria | História de Usuário |
|------------|--------------------|
| **Autenticação** | Como professor/aluno, quero fazer login e recuperar minha senha para acessar o sistema. |
| **Gestão de Alunos** | Como professor, quero cadastrar alunos com nome, RA e turma. |
| **Gestão de Disciplinas** | Como professor, quero criar e organizar disciplinas para associar notas e materiais. |
| **Visualização de Notas** | Como aluno, quero ver minhas notas e médias automaticamente calculadas. |
| **Comunicação** | Como aluno/professor, quero enviar e receber mensagens privadas. |

### 🔢 Priorização (MoSCoW)
- **Must Have:** Login, cadastro de alunos, gestão de disciplinas, visualização de notas, cálculo de médias
- **Should Have:** Dashboard com estatísticas, busca de alunos, personalização de cores
- **Could Have:** Sistema de mensagens, upload de materiais (MongoDB), posts/avisos
- **Won't Have:** Integração com sistemas externos (financeiro, biblioteca), sistema de presença avançado

---

## 📆 Planejamento das Sprints

| Sprint | Período | Entregas Principais | Status |
|---------|---------|---------------------|--------|
| **1** | 09-22/10/2025 | Login, navegação e estrutura inicial | ✅ Concluída |
| **2** | 23/10-05/11/2025 | Backend PostgreSQL, API REST, gestão de disciplinas | ✅ Concluída |
| **3** | 06-19/11/2025 | Gestão de atividades e notas, cálculo de médias | 🚧 Em andamento |
| **4** | 20/11-03/12/2025 | Interface completa do aluno, dashboards avançados | 📋 Planejada |
| **5** | 04-17/12/2025 | Integração MongoDB, upload/download de materiais | 📋 Planejada |
| **6** | 18-31/12/2025 | Sistema de mensagens, testes finais e documentação | 📋 Planejada |

---

## 🚀 Como Executar o Projeto

### Pré-requisitos
- Flutter SDK 3.35.6 ou superior
- Dart SDK 3.6.0 ou superior
- PostgreSQL 18.0
- Git

### Configuração do Backend

1. **Clone o repositório:**
```bash
git clone https://github.com/PII-4Semestre/SistemaParaProfessores.git
cd SistemaParaProfessores
```

2. **Configure o PostgreSQL:**
```bash
# Crie o banco de dados
psql -U postgres
CREATE DATABASE sistema_professores;
```

3. **Configure as variáveis de ambiente:**
```bash
cd server
# Crie o arquivo .env
cp .env.example .env
# Edite com suas credenciais do PostgreSQL
```

4. **Execute o schema e seed:**
```bash
psql -U postgres -d sistema_professores -f database/schema.sql
psql -U postgres -d sistema_professores -f database/seed.sql
```

5. **Inicie o servidor:**
```bash
dart run bin/server.dart
```
O servidor estará rodando em `http://localhost:8080`

### Configuração do Frontend

1. **Instale as dependências:**
```bash
flutter pub get
```

2. **Execute o app:**
```bash
flutter run -d chrome  # Para web
# ou
flutter run -d windows  # Para Windows
```

### Login de Desenvolvimento
- Digite "professor" ou "aluno" no campo de login
- Sem senha necessária (modo dev)

---

## 📦 Estrutura do Projeto

```
SistemaParaProfessores/
├── lib/
│   ├── main.dart
│   ├── models/
│   ├── screens/
│   │   ├── aluno/
│   │   ├── professor/
│   │   └── autenticacao/
│   ├── services/
│   │   └── api_service.dart
│   └── widgets/
├── server/
│   ├── bin/
│   │   └── server.dart
│   ├── lib/
│   │   ├── database/
│   │   └── routes/
│   └── database/
│       ├── schema.sql
│       └── seed.sql
└── README.md
```

---

## 🧰 Ferramentas de Suporte
- **Trello:** controle de tarefas e backlog (Kanban).  
- **GitHub:** versionamento e integração com commits.  
- **Figma:** prototipagem visual e design responsivo.

---

## 👨‍💻 Equipe de Desenvolvimento

| Nome | RA | Função |
|------|----|--------|
| Henrique Impastaro | 24.01777-9 | Dev |
| Mariana Boschetti Castellani | 24.01664-0 | PO |
| Matheus Garcia Mattoso | 24.00304-2 | Dev |
| Murilo Rodrigues dos Santos | 24.01780-9 | Scrum Master |

---

## 📎 Referências
- Documentação oficial do [PostgreSQL](https://www.postgresql.org/docs/)
- Documentação oficial do [MongoDB](https://www.mongodb.com/docs/) (planejado)
- Guia do [Flutter](https://docs.flutter.dev)
- Documentação do [Dart Shelf](https://pub.dev/packages/shelf)
- Recursos educacionais das instituições **Poliedro** e **Instituto Mauá de Tecnologia**

---

## 📚 Documentação Completa

Para documentação detalhada do projeto, incluindo:
- Modelo de banco de dados completo
- Especificação de requisitos
- Documentação das Sprints 1 e 2
- Testes e validações
- Apresentações e retrospectivas

Consulte: **[DOCUMENTACAO_PROJETO.md](./DOCUMENTACAO_PROJETO.md)**

---

## 📄 Licença
Este projeto foi desenvolvido com fins **acadêmicos** como parte da disciplina **TTI206 - Desenvolvimento Multiplataformas**.  
O uso e modificação do código são livres para fins educacionais.

---

> Projeto desenvolvido por alunos do Instituto Mauá de Tecnologia.

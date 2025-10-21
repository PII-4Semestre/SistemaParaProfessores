# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

## [Unreleased] - 2025-10-21

### Added
- ✨ **Seletor de Cores Avançado**: Implementado `flex_color_picker` para seleção profissional de cores
  - Paleta completa do Material Design (300+ cores)
  - Roda de cores para seleção precisa
  - Exibição de nomes e códigos de cores (HEX, RGB, HSL)
  - Histórico de cores recentes
  - Copiar e colar códigos de cor
  - Preview grande da cor selecionada
- 🎨 Telas de detalhes modernizadas (Professor e Aluno)
  - Headers com gradiente customizado
  - Cards modernos com elevação e espaçamento adequado
  - Badges coloridos para status e informações
  - Tabs integradas no gradiente
  - Estatísticas visíveis no header
- 📊 Telas de Visão Geral implementadas com dados reais
  - Professor: Estatísticas, disciplinas, atividades recentes
  - Aluno: Média geral calculada, disciplinas matriculadas, notas recentes
  - Navegação entre abas funcional
  - Cards clicáveis com navegação para detalhes
- 🔄 Sistema CRUD completo de Atividades
  - Criar, editar e excluir atividades
  - Validação de dados
  - Feedback visual de ações
- 👥 Gerenciamento de Alunos em Disciplinas
  - Listar alunos matriculados
  - Adicionar novos alunos
  - Remover alunos da disciplina
  - Busca de alunos disponíveis
- 🔐 Login simplificado com modo DEV
  - Shortcuts: "aluno" e "professor"
  - Sem necessidade de senha em desenvolvimento

### Changed
- 🎨 Design system padronizado com cores do banco de dados
- 📱 Layout responsivo com breakpoints (1400/1100/800/600px)
- 🔧 Migração de Firebase para Dart Shelf + PostgreSQL

### Technical Details
- **Backend**: Dart Shelf 1.4.2 rodando em http://0.0.0.0:8080
- **Database**: PostgreSQL 18.0
- **Frontend**: Flutter 3.35.6
- **Color Picker**: flex_color_picker 3.6.0
- **API Endpoints**: 
  - GET/POST /disciplinas
  - PUT/DELETE /disciplinas/:id
  - GET/POST /atividades
  - PUT/DELETE /atividades/:id
  - GET/POST/DELETE /notas
  - GET/POST/DELETE /alunos (matricular/desmatricular)
  - POST /auth/login

### Fixed
- 🐛 Overflow em cards de disciplinas em diferentes resoluções
- 🔤 Encoding de caracteres portugueses (Média vs M�dia)
- 🗂️ Corrupção de arquivos durante edições múltiplas
- 📐 Responsividade de GridView com LayoutBuilder

### In Progress
- 🚧 Funcionalidade de Materiais (aguardando MongoDB)
- 🚧 Sistema de Mensagens
- 🚧 Autenticação JWT real

### Documentation
- 📖 README.md atualizado com instruções completas
- 📚 SELETOR_DE_CORES.md criado com guia detalhado
- ✅ Todo list mantida e atualizada

---

## Próximas Features Planejadas

### Alta Prioridade
- [ ] Upload e gerenciamento de materiais didáticos (MongoDB)
- [ ] Sistema de mensagens entre professores e alunos
- [ ] Autenticação JWT com refresh tokens
- [ ] Recuperação de senha

### Média Prioridade
- [ ] Notificações push
- [ ] Exportar relatórios em PDF
- [ ] Dashboard analytics para professores
- [ ] Calendário de atividades

### Baixa Prioridade
- [ ] Modo escuro
- [ ] Múltiplos idiomas (i18n)
- [ ] Integração com Google Classroom
- [ ] App mobile nativo

---

**Versão Atual**: 1.0.0+1  
**Última Atualização**: 21 de Outubro de 2025  
**Desenvolvido por**: Equipe Polieduca

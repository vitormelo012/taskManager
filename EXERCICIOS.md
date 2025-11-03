# Exercícios Implementados - Task Manager Pro

## ✅ Exercício 1: Data de Vencimento

### Implementações Realizadas:

#### 1. **Modelo Task Atualizado** (`lib/models/task.dart`)
- ✅ Adicionado campo `DateTime? dueDate` ao modelo Task
- ✅ Criados métodos auxiliares:
  - `isOverdue`: Verifica se a tarefa está vencida
  - `daysUntilDue`: Calcula dias restantes até o vencimento
- ✅ Atualizado `toMap()` e `fromMap()` para persistir dueDate
- ✅ Atualizado `copyWith()` para incluir dueDate

#### 2. **Formulário de Tarefa** (`lib/screens/task_form_screen.dart`)
- ✅ Implementado DatePicker com seleção de data e hora
- ✅ Interface intuitiva com InputDecorator
- ✅ Botão para limpar data de vencimento
- ✅ Formato de data brasileiro (dd/MM/yyyy HH:mm)
- ✅ Validação de data (apenas datas futuras)

#### 3. **Card de Tarefa** (`lib/widgets/task_card.dart`)
- ✅ Exibição da data de vencimento (quando existir)
- ✅ Ícone de alerta (⚠️) para tarefas vencidas
- ✅ Cor vermelha para tarefas vencidas
- ✅ Cor azul para tarefas com vencimento futuro
- ✅ Texto "Vencida em" ou "Vence em" conforme status

#### 4. **Tela Principal** (`lib/screens/task_list_screen.dart`)
- ✅ **Alerta de tarefas vencidas**: Banner vermelho no topo mostrando quantidade
- ✅ **Ordenação por data de vencimento**: Menu "Ordenar por" na AppBar
  - Data de Criação (padrão)
  - Data de Vencimento (tarefas sem data aparecem no final)

#### 5. **Banco de Dados** (`lib/services/database_service.dart`)
- ✅ Atualizado schema para versão 2
- ✅ Migration automática adicionando coluna `dueDate`
- ✅ Método `readAllSortedByDueDate()` com ordenação SQL

---

## ✅ Exercício 2: Categorias

### Implementações Realizadas:

#### 1. **Modelo Category** (`lib/models/category.dart`)
- ✅ Criada classe `Category` com:
  - `id`: Identificador único
  - `name`: Nome da categoria
  - `color`: Cor associada
  - `icon`: Ícone MaterialIcons
- ✅ Classe utilitária `Categories` com 8 categorias predefinidas:
  - 🔵 **Trabalho** (Azul)
  - 🟢 **Pessoal** (Verde)
  - 🟠 **Compras** (Laranja)
  - 🔴 **Saúde** (Vermelho)
  - 🟣 **Estudos** (Roxo)
  - 🟤 **Casa** (Marrom)
  - 🔵 **Finanças** (Teal)
  - ⚪ **Outros** (Cinza - padrão)
- ✅ Método `getById()` para recuperar categoria por ID

#### 2. **Modelo Task Atualizado** (`lib/models/task.dart`)
- ✅ Adicionado campo `String categoryId` (padrão: 'other')
- ✅ Integração com persistência no banco de dados

#### 3. **Formulário de Tarefa** (`lib/screens/task_form_screen.dart`)
- ✅ Dropdown de categorias com:
  - Ícone colorido de cada categoria
  - Nome da categoria
  - Valor padrão: "Outros"

#### 4. **Card de Tarefa** (`lib/widgets/task_card.dart`)
- ✅ Badge de categoria com:
  - Ícone da categoria
  - Nome da categoria
  - Borda e fundo coloridos conforme categoria
  - Posicionado antes do badge de prioridade

#### 5. **Tela Principal** (`lib/screens/task_list_screen.dart`)
- ✅ **Filtro por categoria**: Menu na AppBar (ícone 📁)
  - Opção "Todas as Categorias"
  - Lista de todas as categorias com ícones coloridos
  - Indicador visual da categoria selecionada
- ✅ Cores diferentes por categoria em todo o card

#### 6. **Banco de Dados** (`lib/services/database_service.dart`)
- ✅ Coluna `categoryId` adicionada na migration
- ✅ Método `readByCategory(categoryId)` para filtrar por categoria

---

## 🎨 Recursos Visuais Implementados

### Interface Aprimorada:
1. **AppBar com 3 menus**:
   - 📊 Ordenar por (Data de Criação / Vencimento)
   - 🔍 Filtrar por Status (Todas / Pendentes / Concluídas)
   - 📁 Filtrar por Categoria (8 categorias + Todas)

2. **Banner de Alerta**:
   - Exibido quando há tarefas vencidas
   - Fundo vermelho claro com borda vermelha
   - Ícone de aviso e contador

3. **Cards de Tarefa**:
   - Badge de categoria colorido
   - Badge de prioridade
   - Data de vencimento com status visual
   - Cores dinâmicas baseadas em categoria e prioridade

4. **Formulário Completo**:
   - Campo de título e descrição
   - Dropdown de prioridade
   - **Novo**: Dropdown de categoria
   - **Novo**: Date & Time Picker para vencimento
   - Switch de tarefa completa

---

## 📋 Como Usar

### Criar Tarefa com Data de Vencimento:
1. Clique no botão "Nova Tarefa"
2. Preencha título e descrição
3. Selecione a prioridade
4. **Selecione a categoria**
5. **Toque no campo "Data de Vencimento"**
6. Escolha data e horário
7. Salve a tarefa

### Filtrar e Ordenar:
- **Ordenar**: Toque no ícone 📊 e escolha critério
- **Filtrar por status**: Toque em 🔍 (Todas/Pendentes/Concluídas)
- **Filtrar por categoria**: Toque em 📁 e escolha categoria

### Visualizar Tarefas Vencidas:
- Banner vermelho aparece automaticamente
- Tarefas vencidas têm texto vermelho e ícone ⚠️
- Ordene por "Data de Vencimento" para ver vencidas primeiro

---

## 🗄️ Estrutura do Banco de Dados

### Schema Atualizado (Versão 2):
```sql
CREATE TABLE tasks (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  completed INTEGER NOT NULL,
  priority TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  dueDate TEXT,                      -- ✅ NOVO
  categoryId TEXT NOT NULL DEFAULT 'other'  -- ✅ NOVO
)
```

### Migration Automática:
- Se já existia banco v1, colunas são adicionadas automaticamente
- Sem perda de dados existentes
- Valor padrão: `categoryId = 'other'`, `dueDate = null`

---

## 🎯 Checklist de Implementação

### Exercício 1 - Data de Vencimento:
- [x] Campo `DateTime? dueDate` no modelo
- [x] DatePicker no formulário
- [x] TimePicker para horário
- [x] Alerta visual para tarefas vencidas
- [x] Ordenação por data de vencimento
- [x] Migration do banco de dados
- [x] Exibição no card com cores

### Exercício 2 - Categorias:
- [x] Modelo `Category` criado
- [x] 8 categorias predefinidas
- [x] Campo `categoryId` no modelo Task
- [x] Dropdown de categorias no formulário
- [x] Filtro por categoria na tela principal
- [x] Cores diferentes por categoria
- [x] Badges visuais no card
- [x] Ícones personalizados

---

## 🚀 Melhorias Futuras Sugeridas

1. **Notificações**:
   - Push notifications para tarefas próximas do vencimento
   - Lembrete 1 dia antes / 1 hora antes

2. **Categorias Customizáveis**:
   - Permitir criar/editar/deletar categorias
   - Escolher cor e ícone personalizado

3. **Estatísticas Avançadas**:
   - Gráfico de tarefas por categoria
   - Taxa de conclusão por categoria
   - Tarefas vencidas vs concluídas no prazo

4. **Recorrência**:
   - Tarefas que se repetem (diária, semanal, mensal)
   - Auto-criação de nova tarefa ao completar

5. **Subtarefas**:
   - Dividir tarefas grandes em etapas
   - Barra de progresso

---

## 📝 Notas Técnicas

### Formatação de Datas:
- Usado pacote `intl` para formato brasileiro
- Padrão: `dd/MM/yyyy HH:mm`

### Persistência:
- SQLite com pacote `sqflite`
- Migrations automáticas preservam dados

### UI/UX:
- Material 3 Design
- Cores consistentes com Material Design
- Feedback visual em todas as ações

---

**Desenvolvido com ❤️ usando Flutter**

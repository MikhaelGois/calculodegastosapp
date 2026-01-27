# 📱 App "Cálculo de Gastos" - v3.1.0 Changelog

**Data de Lançamento**: 27 de Janeiro, 2026  
**Versão anterior**: 3.0.0  
**Status**: ✅ Implementado - Pronto para Testes

---

## 🎯 Nova Funcionalidade: Sistema de Controle Financeiro

### 📝 Resumo Executivo

Implementação completa de um sistema abrangente que:
- 💰 **Registra todas as receitas** (corridas, gorjetas, bônus, reembolsos)
- 💸 **Controla todas as despesas** (combustível, manutenção, seguro, etc.)
- 📊 **Calcula lucro real** após todos os custos
- 📈 **Fornece análises financeiras** (média diária, top despesas, previsões)
- 🔄 **Gerencia despesas recorrentes** (seguro, celular, etc.)
- 📸 **Suporta anexos** para comprovantes
- 🚗 **Vincula com veículos** e corridas

---

## 🆕 Arquivos Adicionados

### 1. **lib/models/financial_transaction.dart** (~400 linhas)
Modelo completo de transação financeira com:

#### Enums
- `TransactionType`: INCOME 💰, EXPENSE 💸

- `IncomeCategory` (5 categorias):
  - 🚗 RIDE - Corrida
  - 💵 TIP - Gorjeta
  - 🎁 BONUS - Bônus
  - ↩️ REIMBURSEMENT - Reembolso
  - 📝 OTHER - Outro

- `ExpenseCategory` (10 categorias):
  - ⛽ FUEL - Combustível
  - 🔧 MAINTENANCE - Manutenção
  - 🛡️ INSURANCE - Seguro
  - 🚿 CAR_WASH - Lavagem
  - 🅿️ PARKING - Estacionamento
  - 🛣️ TOLL - Pedágio
  - 🍔 FOOD - Alimentação
  - 📱 PHONE - Celular
  - 📊 APP_FEE - Taxa de app
  - 📝 OTHER - Outro

- `PaymentMethod` (6 métodos):
  - 💵 CASH - Dinheiro
  - 💳 DEBIT_CARD - Cartão de débito
  - 💳 CREDIT_CARD - Cartão de crédito
  - 📲 PIX - PIX
  - 👛 APP_WALLET - Carteira do app
  - 💰 OTHER - Outro

#### Classe FinancialTransaction
**Campos principais**:
- `id`, `type`, `amount`, `date`, `description`
- `paymentMethod` - Como foi pago
- `incomeCategory` / `expenseCategory` - Categoria específica
- `notes` - Notas adicionais
- `attachments` - Lista de fotos de recibos
- `isRecurring` - Se é despesa recorrente
- `nextRecurrence` - Próxima data de recorrência
- `rideId` - Link para corrida específica
- `vehicleId` - Link para veículo
- `odometer` - Quilometragem no momento

**Métodos**:
- `create()` - Factory constructor
- `toMap()` / `fromMap()` - Serialização
- `copyWith()` - Cópia com modificações
- `categoryIcon` / `categoryName` - Getters de categoria

**Exemplo de uso**:
```dart
// Receita de corrida
final rideIncome = FinancialTransaction.create(
  type: TransactionType.INCOME,
  amount: 45.80,
  date: DateTime.now(),
  description: 'Corrida Centro - Aeroporto',
  paymentMethod: PaymentMethod.APP_WALLET,
  incomeCategory: IncomeCategory.RIDE,
  rideId: 'ride-123',
);

// Despesa de combustível
final fuelExpense = FinancialTransaction.create(
  type: TransactionType.EXPENSE,
  amount: 250.00,
  date: DateTime.now(),
  description: 'Abastecimento posto Shell',
  paymentMethod: PaymentMethod.DEBIT_CARD,
  expenseCategory: ExpenseCategory.FUEL,
  vehicleId: 'vehicle-abc',
  odometer: 45230.5,
);

// Despesa recorrente
final insurance = FinancialTransaction.create(
  type: TransactionType.EXPENSE,
  amount: 180.00,
  date: DateTime.now(),
  description: 'Seguro mensal',
  paymentMethod: PaymentMethod.DEBIT_CARD,
  expenseCategory: ExpenseCategory.INSURANCE,
  isRecurring: true,
);
```

---

### 2. **lib/services/financial_service.dart** (~200 linhas)
Serviço estático de análise financeira com:

#### Classe FinancialSummary
**Resultados de análise**:
- `totalIncome` - Total de receitas
- `totalExpense` - Total de despesas
- `netProfit` - Lucro líquido (receitas - despesas)
- `profitMargin` - Margem de lucro (%)
- `incomeByCategory` - Map de receitas por categoria
- `expenseByCategory` - Map de despesas por categoria
- `byPaymentMethod` - Map por método de pagamento
- `isProfitable` - Boolean se está lucrando
- `profitStatus` - Texto do status
- `profitStatusIcon` - Emoji do status (😊/😐/😢)

#### Métodos de Análise

**Filtros de Período**:
- `getTodayTransactions()` - Transações de hoje
- `getWeekTransactions()` - Transações desta semana
- `getMonthTransactions()` - Transações deste mês

**Cálculos Principais**:
- `calculateSummary()` - Resumo financeiro completo de um período
- `calculateDailyAverageProfit()` - Média de lucro diário
- `getTopExpenses()` - Top N categorias de maior despesa
- `calculateBreakEven()` - Ponto de equilíbrio (quanto precisa ganhar/dia)

**Análises Avançadas**:
- `predictNextMonthExpenses()` - Previsão baseada em recorrentes
- `comparePerformance()` - Compara dois períodos diferentes
- `calculateROI()` - Retorno sobre investimento
- `getUpcomingRecurring()` - Próximas despesas recorrentes

**Utilitários**:
- `formatCurrency()` - Formatação em R$ brasileiro

**Exemplo de uso**:
```dart
final summary = FinancialService.calculateSummary(
  transactions: allTransactions,
  startDate: DateTime(2026, 1, 1),
  endDate: DateTime(2026, 1, 31),
);

print('Receitas: ${FinancialService.formatCurrency(summary.totalIncome)}');
// Receitas: R$ 3.250,00

print('Despesas: ${FinancialService.formatCurrency(summary.totalExpense)}');
// Despesas: R$ 1.850,00

print('Lucro: ${FinancialService.formatCurrency(summary.netProfit)}');
// Lucro: R$ 1.400,00

print('Margem: ${summary.profitMargin.toStringAsFixed(1)}%');
// Margem: 43.1%

print('${summary.profitStatusIcon} ${summary.profitStatus}');
// 😊 Ótimo! Você está tendo lucro.

// Top despesas
final topExpenses = FinancialService.getTopExpenses(allTransactions, limit: 3);
for (final entry in topExpenses) {
  print('${entry.key.icon} ${entry.key.displayName}: ${FinancialService.formatCurrency(entry.value)}');
}
// ⛽ Combustível: R$ 800,00
// 🔧 Manutenção: R$ 350,00
// 🛡️ Seguro: R$ 180,00
```

---

### 3. **lib/providers/financial_provider.dart** (~200 linhas)
Provider para gerenciamento de estado:

**Gerenciamento de Transações**:
- `addTransaction()` - Adiciona nova transação
- `removeTransaction()` - Remove transação por ID
- `updateTransaction()` - Atualiza transação existente
- `clearAllTransactions()` - Limpa todas
- `clearTransactionsInPeriod()` - Limpa período específico

**Resumos por Período**:
- `get todaySummary` - Resumo de hoje
- `get weekSummary` - Resumo da semana
- `get monthSummary` - Resumo do mês
- `get totalSummary` - Resumo total

**Listas Filtradas**:
- `get todayTransactions` - Transações de hoje
- `get weekTransactions` - Transações da semana
- `get monthTransactions` - Transações do mês
- `getTransactionsByType()` - Por tipo (INCOME/EXPENSE)
- `getTransactionsByIncomeCategory()` - Por categoria de receita
- `getTransactionsByExpenseCategory()` - Por categoria de despesa

**Estatísticas**:
- `get topExpenses` - Top categorias de despesa
- `get upcomingRecurring` - Recorrentes próximas
- `get dailyAverageProfit` - Média diária de lucro (últimos 30 dias)
- `get nextMonthExpensesPrediction` - Previsão próximo mês
- `compareLastTwoMonths()` - Comparação mês atual vs anterior

**Persistência**:
- `exportTransactions()` - Exporta para List<Map>
- `importTransactions()` - Importa de List<Map>

**Exemplo de uso**:
```dart
final provider = Provider.of<FinancialProvider>(context);

// Adicionar transação
provider.addTransaction(transaction);

// Ver resumo do mês
final summary = provider.monthSummary;
print('Lucro mensal: ${FinancialService.formatCurrency(summary.netProfit)}');

// Ver média diária
print('Média diária: ${FinancialService.formatCurrency(provider.dailyAverageProfit)}');

// Ver top despesas
for (final entry in provider.topExpenses.take(3)) {
  print('${entry.key.displayName}: ${FinancialService.formatCurrency(entry.value)}');
}

// Comparar últimos 2 meses
final comparison = provider.compareLastTwoMonths();
print('Variação: ${comparison['profitChange']}%');
```

---

### 4. **lib/widgets/transaction_card.dart** (~220 linhas)
Widget para exibir transação individual:

**Características**:
- Ícone da categoria com cor de fundo
- Descrição da transação
- Categoria e método de pagamento
- Data formatada (Hoje, Ontem, ou data completa)
- Notas (se houver)
- Badge "🔄 Recorrente" se aplicável
- Valor com cor (verde para receita, vermelho para despesa)
- Botão de editar
- Swipe para excluir com confirmação
- Cor de fundo sutil baseada no tipo

**Exemplo visual**:
```
┌─────────────────────────────────────────┐
│ [⛽]  Abastecimento posto Shell     ✏️   │
│       Combustível • Cartão débito        │
│       Hoje às 14:30                      │
│       Gasolina Aditivada                 │
│                           - R$ 250,00    │
└─────────────────────────────────────────┘
```

---

### 5. **lib/widgets/financial_summary_card.dart** (~200 linhas)
Widget de resumo financeiro:

**Exibe**:
- Cabeçalho "Resumo Financeiro" + badge de período
- 💰 Total de receitas (verde)
- 💸 Total de despesas (vermelho)
- Divisória
- **Lucro líquido** em destaque com:
  - Emoji de status
  - Valor grande
  - Cor baseada em lucratividade
  - Margem de lucro (%)
- Status textual

**Cores dinâmicas**:
- Verde se `isProfitable = true`
- Vermelho se `isProfitable = false`

**Exemplo visual**:
```
┌──────────────────────────────────────┐
│ Resumo Financeiro         [Mês]      │
│                                       │
│ 💰 Receitas        R$ 3.250,00       │
│ 💸 Despesas        R$ 1.850,00       │
│ ───────────────────────────────────   │
│ ┌──────────────────────────────────┐ │
│ │ 😊  Lucro Líquido    Margem      │ │
│ │     R$ 1.400,00      43.1%       │ │
│ └──────────────────────────────────┘ │
│                                       │
│ Ótimo! Você está tendo lucro.        │
└──────────────────────────────────────┘
```

---

### 6. **lib/screens/financial_dashboard_screen.dart** (~400 linhas)
Tela principal do controle financeiro:

**Layout**:
1. **AppBar** com título e botão de filtros
2. **Seletor de período** (Hoje/Semana/Mês/Total)
3. **Card de resumo financeiro**
4. **Estatísticas rápidas** (3 cards):
   - 📊 Média Diária de lucro
   - 🔄 Número de recorrentes próximas
   - 💸 Maior categoria de despesa
5. **Cabeçalho da lista** com contador
6. **Lista de transações** ordenadas por data
7. **FAB** "Nova Transação"

**Estado Vazio**:
- Ícone de carteira
- Texto explicativo
- Botão para adicionar primeira transação

**Interações**:
- Clicar em transação: Ver detalhes (TODO)
- Clicar no ícone de editar: Editar transação
- Swipe para esquerda: Excluir com confirmação
- Trocar período: Atualiza resumo e lista
- FAB: Adicionar nova transação

---

### 7. **lib/screens/transaction_form_screen.dart** (~400 linhas)
Formulário para adicionar/editar transação:

**Campos**:
1. **Tipo** (botões):
   - 💰 Receita (verde)
   - 💸 Despesa (vermelho)
2. **Descrição** (TextField obrigatório)
3. **Valor** (R$, numérico, obrigatório)
4. **Categoria** (Dropdown dinâmico baseado no tipo)
5. **Método de Pagamento** (Dropdown)
6. **Data** (DatePicker + TimePicker)
7. **Recorrente** (Switch)
8. **Notas** (TextField opcional, multilinhas)

**Validações**:
- Descrição não pode ser vazia
- Valor deve ser > 0
- Categoria deve ser selecionada

**Comportamento**:
- Ao trocar tipo (Receita/Despesa), reseta categoria
- Ao editar, preenche campos com dados existentes
- Salva no provider e volta para dashboard
- Mostra SnackBar de sucesso

---

## 📊 Documentação

### **FINANCIAL_SYSTEM_v3.1.md**
Documentação completa do sistema incluindo:
- Visão geral da arquitetura
- Detalhes de todos os componentes
- Descrição de categorias e enums
- Fluxos de uso
- Exemplos de código
- Cálculos financeiros
- Integração futura planejada
- Roadmap (v3.2, v3.3, v3.4)
- Benefícios para o motorista

---

## 🔄 Integrações Planejadas

### Com Sistema de Ofertas (v3.0)
Quando o motorista aceita uma oferta de corrida:
1. Sistema cria automaticamente uma `FinancialTransaction`
2. Tipo: `INCOME`
3. Categoria: `IncomeCategory.RIDE`
4. Valor: Valor da oferta aceita
5. Link via `rideId`
6. Motorista pode editar valor real após completar

### Com Perfil de Veículo
- Vincular despesas a veículos específicos
- Registrar odômetro em cada abastecimento
- Calcular custo por quilômetro
- Relatórios individualizados por veículo

### Com Hive Storage
- Persistir transações localmente
- Box: `'financialTransactions'`
- Auto-save em cada operação
- Backup e restore

---

## 🧮 Cálculos Implementados

### Lucro Líquido
```
Lucro Líquido = Σ Receitas - Σ Despesas
```

### Margem de Lucro
```
Margem (%) = (Lucro Líquido / Σ Receitas) × 100
```

### Média Diária de Lucro
```
Média Diária = Lucro do Período / Número de Dias
```

### Ponto de Equilíbrio
```
Break-Even = Σ Despesas / Número de Dias
Quanto precisa ganhar por dia para cobrir despesas
```

### Previsão de Despesas
```
Previsão = Σ Despesas Recorrentes do Próximo Mês
```

### ROI (Retorno sobre Investimento)
```
ROI (%) = ((Receita - Despesa) / Despesa) × 100
```

---

## 💡 Casos de Uso

### Caso 1: Motorista Registra Dia de Trabalho
1. Manhã: Registra abastecimento (R$ 250,00)
2. Durante o dia: Sistema auto-registra 8 corridas (R$ 320,00 total)
3. Tarde: Registra almoço (R$ 25,00)
4. Noite: Registra lavagem de carro (R$ 30,00)
5. Fim do dia: Vê resumo:
   - Receitas: R$ 320,00
   - Despesas: R$ 305,00
   - Lucro: R$ 15,00 (4,7%)
6. Percebe que o lucro foi baixo e decide trabalhar mais horas

### Caso 2: Análise Mensal
1. Fim do mês: Troca para período "Mês"
2. Vê resumo:
   - Receitas: R$ 4.500,00 (22 dias trabalhados)
   - Despesas: R$ 2.200,00
   - Lucro: R$ 2.300,00 (51,1%)
3. Vê top despesas:
   - Combustível: R$ 1.200,00
   - Seguro: R$ 180,00
   - Manutenção: R$ 350,00
4. Decide procurar posto mais barato

### Caso 3: Despesa Recorrente
1. Dia 5: Registra seguro mensal (R$ 180,00)
2. Marca como "Recorrente"
3. Sistema exibe nas "Recorrentes próximas"
4. Dia 28: Notificação lembrando pagamento próximo
5. Dia 5 (próximo mês): Auto-cria nova transação

---

## 🎯 Benefícios para o Motorista

1. **Visibilidade Total**: Vê exatamente quanto ganha e gasta
2. **Decisões Informadas**: Sabe se está realmente lucrando
3. **Controle de Gastos**: Identifica onde pode economizar
4. **Planejamento**: Prevê despesas recorrentes
5. **Imposto de Renda**: Tem todos os dados organizados
6. **Otimização**: Compara períodos e melhora resultados
7. **Profissionalização**: Gerencia atividade como negócio

---

## 🚀 Próximos Passos

### Versão 3.2 (Próxima)
- [ ] Integração com Hive para persistência
- [ ] Gráficos com fl_chart (linha, barra, pizza)
- [ ] Exportação para PDF/Excel
- [ ] Captura de foto de recibos
- [ ] Auto-criar receita ao aceitar corrida v3.0

### Versão 3.3
- [ ] Orçamentos por categoria
- [ ] Metas financeiras mensais
- [ ] Alertas de gastos excessivos
- [ ] Relatórios fiscais automatizados
- [ ] Calculadora de impostos

### Versão 3.4
- [ ] Suporte a múltiplos veículos
- [ ] Relatórios por veículo
- [ ] Custo por quilômetro
- [ ] Análise de rentabilidade por app
- [ ] Previsões com Machine Learning
- [ ] Sincronização na nuvem

---

## 📌 Notas Técnicas

### Persistência
- Atualmente em memória (provider)
- v3.2 adicionará Hive
- Exportação/importação já implementada

### Performance
- Cálculos otimizados
- Filtros eficientes por data
- Lista virtualizada (ListView)

### UX/UI
- Material Design 3
- Cores contextuais (verde/vermelho)
- Emojis para categorias
- Confirmação em ações destrutivas
- Feedback visual (SnackBars)

---

## ✅ Checklist de Implementação

- [x] Modelo de dados completo
- [x] Serviço de cálculos financeiros
- [x] Provider para gerenciamento de estado
- [x] Widget de card de transação
- [x] Widget de card de resumo
- [x] Tela de dashboard
- [x] Tela de formulário de transação
- [x] Validações de formulário
- [x] Formatação de moeda
- [x] Formatação de data
- [x] Categorização de receitas (5 categorias)
- [x] Categorização de despesas (10 categorias)
- [x] Métodos de pagamento (6 métodos)
- [x] Suporte a transações recorrentes
- [x] Suporte a notas
- [x] Suporte a anexos (estrutura)
- [x] Vinculação com corridas (estrutura)
- [x] Vinculação com veículos (estrutura)
- [x] Cálculos de resumo
- [x] Cálculos de média diária
- [x] Top despesas
- [x] Previsão de despesas
- [x] Comparação de períodos
- [x] ROI
- [x] Ponto de equilíbrio
- [x] Exportação/importação
- [x] Documentação completa

---

## 🎉 Conclusão

A versão 3.1.0 adiciona um sistema completo e profissional de controle financeiro que:
- Complementa perfeitamente o sistema de semáforo de corridas (v3.0)
- Fornece visão real da lucratividade
- Ajuda motoristas a tomarem decisões financeiras melhores
- Profissionaliza a gestão da atividade

O motorista agora tem duas ferramentas poderosas:
1. **v3.0**: Decidir quais corridas aceitar
2. **v3.1**: Saber se está realmente lucrando

**Status**: ✅ Pronto para testes e feedback dos usuários!

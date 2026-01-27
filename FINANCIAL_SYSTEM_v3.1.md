# Sistema de Controle Financeiro v3.1

## Visão Geral

O sistema de controle financeiro foi desenvolvido para motoristas de aplicativos acompanharem suas receitas e despesas, calculando o lucro real após todos os custos.

## Arquitetura

### Modelo de Dados

**FinancialTransaction** (`lib/models/financial_transaction.dart`)
- `id`: Identificador único
- `type`: TransactionType (INCOME, EXPENSE)
- `amount`: Valor da transação
- `date`: Data e hora
- `description`: Descrição
- `paymentMethod`: Método de pagamento
- `incomeCategory`: Categoria de receita (se type=INCOME)
- `expenseCategory`: Categoria de despesa (se type=EXPENSE)
- `notes`: Notas adicionais
- `attachments`: Lista de anexos (fotos de recibos)
- `isRecurring`: Se é recorrente
- `nextRecurrence`: Próxima data de recorrência
- `rideId`: Link para corrida (se aplicável)
- `vehicleId`: Link para veículo (se aplicável)
- `odometer`: Km do veículo (se aplicável)

### Categorias

#### Receitas
- 🚗 RIDE - Corrida
- 💵 TIP - Gorjeta
- 🎁 BONUS - Bônus
- ↩️ REIMBURSEMENT - Reembolso
- 📝 OTHER - Outro

#### Despesas
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

#### Métodos de Pagamento
- 💵 CASH - Dinheiro
- 💳 DEBIT_CARD - Cartão de débito
- 💳 CREDIT_CARD - Cartão de crédito
- 📲 PIX - PIX
- 👛 APP_WALLET - Carteira do app
- 💰 OTHER - Outro

### Camada de Serviço

**FinancialService** (`lib/services/financial_service.dart`)

Métodos disponíveis:
- `calculateSummary()` - Calcula resumo financeiro do período
- `getTodayTransactions()` - Transações de hoje
- `getWeekTransactions()` - Transações da semana
- `getMonthTransactions()` - Transações do mês
- `calculateDailyAverageProfit()` - Média diária de lucro
- `getTopExpenses()` - Maiores categorias de despesa
- `getUpcomingRecurring()` - Despesas recorrentes próximas
- `calculateBreakEven()` - Ponto de equilíbrio
- `predictNextMonthExpenses()` - Previsão de despesas
- `comparePerformance()` - Comparação entre períodos
- `calculateROI()` - Retorno sobre investimento
- `formatCurrency()` - Formatação de moeda

**FinancialSummary**
- `totalIncome`: Total de receitas
- `totalExpense`: Total de despesas
- `netProfit`: Lucro líquido
- `profitMargin`: Margem de lucro (%)
- `incomeByCategory`: Receitas por categoria
- `expenseByCategory`: Despesas por categoria
- `byPaymentMethod`: Transações por método de pagamento
- `isProfitable`: Se está lucrando
- `profitStatus`: Status do lucro em texto
- `profitStatusIcon`: Ícone do status (😊/😐/😢)

### Camada de Estado

**FinancialProvider** (`lib/providers/financial_provider.dart`)

Gerenciamento de estado usando Provider:
- Armazena lista de transações
- Notifica mudanças para UI
- Fornece filtros e estatísticas
- Suporta importação/exportação

Principais métodos:
- `addTransaction()` - Adiciona transação
- `removeTransaction()` - Remove transação
- `updateTransaction()` - Atualiza transação
- `get todaySummary` - Resumo de hoje
- `get weekSummary` - Resumo da semana
- `get monthSummary` - Resumo do mês
- `get totalSummary` - Resumo total
- `get topExpenses` - Top despesas
- `get upcomingRecurring` - Recorrentes próximas
- `get dailyAverageProfit` - Média diária
- `compareLastTwoMonths()` - Compara últimos 2 meses
- `exportTransactions()` - Exporta para Map
- `importTransactions()` - Importa de Map

### Camada de UI

#### Widgets

**TransactionCard** (`lib/widgets/transaction_card.dart`)
- Exibe uma transação
- Ícone da categoria
- Valor com cor (verde/vermelho)
- Data formatada
- Notas
- Badge de recorrente
- Swipe para excluir
- Botão de editar

**FinancialSummaryCard** (`lib/widgets/financial_summary_card.dart`)
- Exibe resumo do período
- Total de receitas
- Total de despesas
- Lucro líquido (destaque)
- Margem de lucro
- Status com emoji

#### Telas

**FinancialDashboardScreen** (`lib/screens/financial_dashboard_screen.dart`)
- Dashboard principal
- Seletor de período (Hoje/Semana/Mês/Total)
- Card de resumo financeiro
- Estatísticas rápidas (média diária, recorrentes, maior despesa)
- Lista de transações
- FAB para adicionar transação

**TransactionFormScreen** (`lib/screens/transaction_form_screen.dart`)
- Formulário de transação
- Seleção de tipo (Receita/Despesa)
- Campo de descrição
- Campo de valor
- Dropdown de categoria
- Dropdown de método de pagamento
- Seletor de data e hora
- Switch de recorrente
- Campo de notas
- Validação de formulário
- Suporta edição

## Fluxo de Uso

### Adicionar Receita
1. Abrir dashboard
2. Clicar em "Nova Transação"
3. Selecionar tipo "Receita"
4. Escolher categoria (Corrida, Gorjeta, etc.)
5. Inserir valor e descrição
6. Selecionar método de pagamento
7. Salvar

### Adicionar Despesa
1. Abrir dashboard
2. Clicar em "Nova Transação"
3. Selecionar tipo "Despesa"
4. Escolher categoria (Combustível, Manutenção, etc.)
5. Inserir valor e descrição
6. Marcar como recorrente se aplicável
7. Salvar

### Visualizar Resumo
1. Abrir dashboard
2. Selecionar período (Hoje/Semana/Mês/Total)
3. Ver resumo no card principal:
   - Total de receitas
   - Total de despesas
   - Lucro líquido
   - Margem de lucro
4. Ver estatísticas:
   - Média diária de lucro
   - Número de recorrentes
   - Maior categoria de despesa

### Gerenciar Transações
1. Ver lista de transações no dashboard
2. Clicar para ver detalhes
3. Clicar no ícone de edição para editar
4. Deslizar para a esquerda para excluir
5. Confirmar exclusão

## Integração Futura

### Com Sistema de Ofertas de Corrida
- Quando aceitar uma oferta de corrida, criar automaticamente:
  - Transação de receita com valor da corrida
  - Categoria: RIDE
  - Link para o `rideId`
  - Permite editar valor real após completar

### Com Perfil do Veículo
- Vincular despesas a veículos específicos
- Registrar odômetro para despesas de combustível
- Calcular custo por quilômetro
- Relatórios por veículo

### Com Storage
- Salvar transações no Hive
- Backup automático
- Sincronização

## Cálculos Importantes

### Lucro Líquido
```
Lucro Líquido = Total de Receitas - Total de Despesas
```

### Margem de Lucro
```
Margem = (Lucro Líquido / Total de Receitas) × 100
```

### Média Diária de Lucro
```
Média Diária = Lucro do Período / Número de Dias
```

### Ponto de Equilíbrio
```
Break-Even = Total de Despesas / Número de Dias
```
*Quanto precisa ganhar por dia para cobrir despesas*

### Previsão de Despesas
```
Previsão = Soma das Despesas Recorrentes do Próximo Mês
```

### ROI (Retorno sobre Investimento)
```
ROI = ((Receita Total - Despesa Total) / Despesa Total) × 100
```

## Exemplo de Uso

```dart
// Adicionar receita de corrida
final rideIncome = FinancialTransaction.create(
  type: TransactionType.INCOME,
  amount: 45.80,
  date: DateTime.now(),
  description: 'Corrida Centro - Aeroporto',
  paymentMethod: PaymentMethod.APP_WALLET,
  incomeCategory: IncomeCategory.RIDE,
  rideId: 'ride-123',
);
provider.addTransaction(rideIncome);

// Adicionar despesa de combustível
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
provider.addTransaction(fuelExpense);

// Adicionar despesa recorrente (seguro)
final insurance = FinancialTransaction.create(
  type: TransactionType.EXPENSE,
  amount: 180.00,
  date: DateTime.now(),
  description: 'Seguro mensal',
  paymentMethod: PaymentMethod.DEBIT_CARD,
  expenseCategory: ExpenseCategory.INSURANCE,
  isRecurring: true,
);
provider.addTransaction(insurance);

// Ver resumo do mês
final summary = provider.monthSummary;
print('Receitas: ${FinancialService.formatCurrency(summary.totalIncome)}');
print('Despesas: ${FinancialService.formatCurrency(summary.totalExpense)}');
print('Lucro: ${FinancialService.formatCurrency(summary.netProfit)}');
print('Margem: ${summary.profitMargin.toStringAsFixed(1)}%');
print('Status: ${summary.profitStatus} ${summary.profitStatusIcon}');
```

## Próximos Passos

### Versão 3.2
- [ ] Integração com Hive para persistência
- [ ] Gráficos com fl_chart
- [ ] Exportação para PDF/Excel
- [ ] Foto de recibos
- [ ] Auto-criar receita ao aceitar corrida

### Versão 3.3
- [ ] Orçamentos por categoria
- [ ] Metas financeiras
- [ ] Alertas de gastos
- [ ] Relatórios fiscais
- [ ] Comparações mensais com gráficos
- [ ] Calculadora de impostos

### Versão 3.4
- [ ] Múltiplos veículos
- [ ] Relatórios por veículo
- [ ] Custo por km
- [ ] Análise de rentabilidade por app
- [ ] Previsões com ML
- [ ] Sincronização na nuvem

## Benefícios para o Motorista

1. **Visibilidade Total**: Veja exatamente quanto ganha e gasta
2. **Decisões Informadas**: Saiba se está realmente lucrando
3. **Controle de Gastos**: Identifique onde pode economizar
4. **Planejamento**: Preveja despesas recorrentes
5. **Imposto de Renda**: Tenha todos os dados organizados
6. **Otimização**: Compare períodos e melhore resultados
7. **Profissionalização**: Gerencie sua atividade como um negócio

## Conclusão

O sistema de controle financeiro v3.1 complementa perfeitamente o sistema de análise de ofertas de corrida (v3.0), fornecendo uma visão completa da rentabilidade do motorista. Não basta saber quais corridas aceitar - é preciso saber se, no final do mês, o trabalho está gerando lucro real após todas as despesas.

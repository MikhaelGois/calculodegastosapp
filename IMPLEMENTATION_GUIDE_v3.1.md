# 🚀 Guia Rápido de Implementação - Sistema Financeiro v3.1

## 📋 Pré-requisitos

✅ Sistema de notificações v3.0 implementado  
✅ Flutter 3.10.7+ instalado  
✅ Provider configurado em `pubspec.yaml`  
✅ Hive configurado (opcional para v3.1, obrigatório para v3.2)

## 🎯 Integração com o App Principal

### Passo 1: Registrar o Provider

Adicione o `FinancialProvider` no `main.dart`:

```dart
import 'package:provider/provider.dart';
import 'providers/financial_provider.dart';
import 'providers/ride_offer_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RideOfferProvider()),
        ChangeNotifierProvider(create: (_) => FinancialProvider()), // NOVO
      ],
      child: const MyApp(),
    ),
  );
}
```

### Passo 2: Adicionar Rota

Em `routes.dart` ou `main.dart`, adicione a rota:

```dart
import 'screens/financial_dashboard_screen.dart';

// ...

routes: {
  '/': (context) => const HomeScreen(),
  '/ride-offers': (context) => const RideOffersScreen(),
  '/financial': (context) => const FinancialDashboardScreen(), // NOVO
},
```

### Passo 3: Adicionar Item no Menu

Na `HomeScreen` ou drawer de navegação:

```dart
ListTile(
  leading: const Icon(Icons.account_balance_wallet),
  title: const Text('Controle Financeiro'),
  subtitle: const Text('Receitas e despesas'),
  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
  onTap: () {
    Navigator.pushNamed(context, '/financial');
  },
),
```

### Passo 4: Integração com Ride Offers (Opcional)

Para auto-criar receita ao aceitar corrida, modifique `RideOfferProvider`:

```dart
import '../providers/financial_provider.dart';
import '../models/financial_transaction.dart';

class RideOfferProvider extends ChangeNotifier {
  // ... código existente ...

  void acceptOffer(String offerId) {
    final offer = _offers.firstWhere((o) => o.id == offerId);
    
    // Atualizar status
    offer.wasAccepted = true;
    offer.responseTime = DateTime.now();
    notifyListeners();

    // NOVO: Criar transação financeira
    _createIncomeTransaction(offer);
  }

  void _createIncomeTransaction(RideOffer offer) {
    try {
      final financialProvider = Provider.of<FinancialProvider>(
        context, 
        listen: false,
      );

      final transaction = FinancialTransaction.create(
        type: TransactionType.INCOME,
        amount: offer.offeredValue,
        date: DateTime.now(),
        description: 'Corrida ${offer.appName} - ${offer.distanceKm}km',
        paymentMethod: PaymentMethod.APP_WALLET,
        incomeCategory: IncomeCategory.RIDE,
        rideId: offer.id,
        notes: '${offer.trafficLightEmoji} Score: ${offer.profitabilityScore.toStringAsFixed(1)}',
      );

      financialProvider.addTransaction(transaction);
    } catch (e) {
      print('Erro ao criar transação: $e');
    }
  }
}
```

**⚠️ IMPORTANTE**: Para usar Provider.of dentro do RideOfferProvider, você precisa do BuildContext. Alternativa melhor é usar callbacks:

```dart
// Na HomeScreen ou RideOffersScreen:
void _acceptOffer(RideOffer offer) {
  // Atualizar provider de ofertas
  rideOfferProvider.acceptOffer(offer.id);

  // Criar transação financeira
  final transaction = FinancialTransaction.create(
    type: TransactionType.INCOME,
    amount: offer.offeredValue,
    date: DateTime.now(),
    description: 'Corrida ${offer.appName} - ${offer.distanceKm}km',
    paymentMethod: PaymentMethod.APP_WALLET,
    incomeCategory: IncomeCategory.RIDE,
    rideId: offer.id,
  );
  
  financialProvider.addTransaction(transaction);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Receita registrada automaticamente!'),
      backgroundColor: Colors.green,
    ),
  );
}
```

## 🧪 Teste Manual

### Teste 1: Adicionar Receita
1. Abrir dashboard financeiro
2. Clicar em "Nova Transação"
3. Selecionar tipo "Receita"
4. Preencher:
   - Descrição: "Corrida Teste"
   - Valor: 45.80
   - Categoria: Corrida
   - Método: Carteira do app
5. Salvar
6. Verificar que aparece na lista com **+ R$ 45,80** em verde
7. Verificar resumo: Receitas = R$ 45,80, Lucro = R$ 45,80

### Teste 2: Adicionar Despesa
1. Clicar em "Nova Transação"
2. Selecionar tipo "Despesa"
3. Preencher:
   - Descrição: "Abastecimento"
   - Valor: 250.00
   - Categoria: Combustível
   - Método: Cartão de débito
4. Salvar
5. Verificar que aparece com **- R$ 250,00** em vermelho
6. Verificar resumo atualizado: Despesas = R$ 250,00, Lucro = -R$ 204,20

### Teste 3: Filtros de Período
1. Adicionar transações em dias diferentes
2. Trocar período para "Hoje"
3. Verificar que mostra só de hoje
4. Trocar para "Semana"
5. Verificar que mostra da semana
6. Trocar para "Mês"
7. Verificar que mostra do mês

### Teste 4: Editar Transação
1. Clicar no ícone de edição
2. Alterar valor ou descrição
3. Salvar
4. Verificar que a transação foi atualizada

### Teste 5: Excluir Transação
1. Deslizar transação para a esquerda
2. Confirmar exclusão
3. Verificar que foi removida
4. Verificar que resumo foi atualizado

### Teste 6: Recorrente
1. Adicionar despesa recorrente (ex: seguro)
2. Marcar switch "Recorrente"
3. Salvar
4. Verificar badge "🔄 Recorrente" no card
5. Verificar que aparece em "Estatísticas rápidas"

## 📊 Dados de Teste Sugeridos

Para testar completamente, adicione:

**Receitas**:
- Corrida 1: R$ 35,00 (Hoje, manhã)
- Corrida 2: R$ 42,50 (Hoje, tarde)
- Corrida 3: R$ 28,00 (Hoje, noite)
- Gorjeta: R$ 10,00 (Hoje)
- Bônus: R$ 50,00 (Ontem)

**Despesas**:
- Combustível: R$ 250,00 (Hoje)
- Almoço: R$ 25,00 (Hoje)
- Lavagem: R$ 30,00 (Ontem)
- Seguro: R$ 180,00 (Dia 5, recorrente)
- Telefone: R$ 50,00 (Dia 10, recorrente)

**Resultados Esperados (Hoje)**:
- Receitas: R$ 115,50
- Despesas: R$ 275,00
- Lucro: -R$ 159,50
- Status: 😢 Prejuízo no período

**Resultados Esperados (Mês)**:
- Receitas: R$ 165,50
- Despesas: R$ 535,00
- Lucro: -R$ 369,50
- Status: 😢 Prejuízo no período

Isso mostra ao motorista que precisa trabalhar mais ou reduzir gastos!

## 🔍 Verificação de Erros Comuns

### Erro 1: Provider not found
**Sintoma**: `Error: Could not find the correct Provider<FinancialProvider>`  
**Solução**: Certifique-se de que `FinancialProvider` está registrado em `MultiProvider` no `main.dart`

### Erro 2: Type mismatch
**Sintoma**: Erro ao criar transação  
**Solução**: Verifique que está usando os enums corretos (`TransactionType`, `IncomeCategory`, etc.)

### Erro 3: Valor não atualiza
**Sintoma**: Resumo não atualiza após adicionar transação  
**Solução**: Verifique que está chamando `notifyListeners()` no provider

### Erro 4: Data errada
**Sintoma**: Transação não aparece em "Hoje"  
**Solução**: Verifique o fuso horário e use `DateTime.now()` corretamente

## 🎨 Customização (Opcional)

### Alterar Cores
Em `financial_summary_card.dart`, altere as cores:

```dart
// Lucro verde mais escuro
color: Colors.green[900]

// Prejuízo laranja em vez de vermelho
color: Colors.orange[700]
```

### Adicionar Mais Categorias
Em `financial_transaction.dart`:

```dart
enum ExpenseCategory {
  // ... existentes ...
  FINE,        // 🚨 Multa
  DOCUMENT,    // 📄 Documento
  ACCESSORIES, // 🔌 Acessórios
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get icon {
    switch (this) {
      // ... existentes ...
      case ExpenseCategory.FINE:
        return '🚨';
      case ExpenseCategory.DOCUMENT:
        return '📄';
      case ExpenseCategory.ACCESSORIES:
        return '🔌';
    }
  }
  
  String get displayName {
    switch (this) {
      // ... existentes ...
      case ExpenseCategory.FINE:
        return 'Multa';
      case ExpenseCategory.DOCUMENT:
        return 'Documento';
      case ExpenseCategory.ACCESSORIES:
        return 'Acessórios';
    }
  }
}
```

### Alterar Formato de Moeda
Em `financial_service.dart`:

```dart
static String formatCurrency(double amount) {
  // Formato padrão: R$ 1.234,56
  final formatted = amount.toStringAsFixed(2).replaceAll('.', ',');
  return 'R\$ $formatted';
  
  // Alternativa com milhares:
  // final parts = formatted.split(',');
  // final intPart = parts[0].replaceAllMapped(
  //   RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
  //   (Match m) => '${m[1]}.',
  // );
  // return 'R\$ $intPart,${parts[1]}';
}
```

## 🐛 Debug

Para debugar problemas:

```dart
// No dashboard
print('Total de transações: ${provider.transactions.length}');
print('Resumo: ${provider.monthSummary.toMap()}');

// No provider
void addTransaction(FinancialTransaction transaction) {
  print('Adicionando: ${transaction.description} - ${transaction.amount}');
  _transactions.add(transaction);
  print('Total agora: ${_transactions.length}');
  notifyListeners();
}
```

## ✅ Checklist de Go-Live

Antes de disponibilizar para usuários:

- [ ] Todos os testes manuais passaram
- [ ] Provider registrado corretamente
- [ ] Rota configurada
- [ ] Menu de navegação atualizado
- [ ] Integração com ride offers testada (se aplicável)
- [ ] Cores e textos revisados
- [ ] Validações de formulário testadas
- [ ] Exclusão com confirmação funcionando
- [ ] Swipe gesture funcionando
- [ ] Formatação de moeda correta
- [ ] Formatação de data correta
- [ ] Cálculos de resumo corretos
- [ ] Filtros de período funcionando
- [ ] Performance aceitável (lista de 100+ itens)

## 🚀 Próximos Passos (v3.2)

Após estabilizar v3.1:

1. **Persistência com Hive**:
   - Criar `FinancialTransactionAdapter`
   - Registrar em `HiveService`
   - Auto-save em cada operação

2. **Gráficos**:
   - Adicionar `fl_chart` no `pubspec.yaml`
   - Criar `FinancialChartsWidget`
   - Gráfico de linha: Lucro por dia
   - Gráfico de pizza: Despesas por categoria

3. **Exportação**:
   - Botão "Exportar" no dashboard
   - Gerar CSV para Excel
   - Gerar PDF com relatório

4. **Fotos de Recibos**:
   - Usar `image_picker`
   - Salvar em storage local
   - Exibir thumbnail no card

---

**Dúvidas?** Consulte:
- `FINANCIAL_SYSTEM_v3.1.md` - Documentação completa
- `CHANGELOG_v3.1.0.md` - Detalhes técnicos
- Código-fonte com comentários

**Pronto para começar!** 🎉

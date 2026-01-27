# 📋 Checklist de Testes - Cálculo de Gastos v2.0

## ✅ Testes Básicos de Interface

- [ ] **Tela Inicial**
  - [ ] Veículos carregam corretamente
  - [ ] Botões aparecem quando veículo selecionado
  - [ ] Ícones estão visíveis e alinhados

- [ ] **Navegação**
  - [ ] Botão "Calcular" abre CalculationScreen
  - [ ] Botão "Tempo Real" abre RealTimeTripScreen
  - [ ] Botão "Editar" abre VehicleFormScreen
  - [ ] Botão "Histórico" abre HistoryScreen

- [ ] **Cadastro de Veículos**
  - [ ] Formulário valida campos obrigatórios
  - [ ] Salva novo veículo corretamente
  - [ ] Edita veículo existente
  - [ ] Deleta veículo com confirmação

## ✅ Testes - Histórico de Corridas

- [ ] **HistoryScreen Carrega**
  - [ ] Exibe mensagem vazia quando sem corridas
  - [ ] Mostra estatísticas corretamente
  - [ ] Lista corridas em ordem cronológica

- [ ] **Detalhes de Corrida**
  - [ ] Expande e mostra todas as informações
  - [ ] Valores calculados corretamente
  - [ ] Avaliação de passageiro exibe corretamente

- [ ] **Integração Google Maps**
  - [ ] Botão "Saída" abre Google Maps com endereço
  - [ ] Botão "Destino" abre Google Maps com endereço
  - [ ] URL gerada está correta

## ✅ Testes - Rastreamento em Tempo Real

- [ ] **RealTimeTripScreen Carrega**
  - [ ] Formulário aparece quando não está rastreando
  - [ ] Campos de texto aceitam entrada

- [ ] **Iniciar Corrida**
  - [ ] Valida campos obrigatórios
  - [ ] Timer inicia e conta em tempo real
  - [ ] Formato de tempo é correto (HH:MM:SS)
  - [ ] Botões Pausar/Finalizar aparecem

- [ ] **Finalizar Corrida**
  - [ ] Valida distância antes de salvar
  - [ ] Calcula custos corretamente
  - [ ] Salva na HistoryProvider
  - [ ] Cria notificação
  - [ ] Exibe mensagem de sucesso
  - [ ] Retorna para tela anterior

- [ ] **Pausar Corrida**
  - [ ] Timer para de contar
  - [ ] Retorna ao formulário
  - [ ] Dados não são perdidos

## ✅ Testes - Persistência de Dados

- [ ] **Hive Storage**
  - [ ] Veículos persistem após fechar app
  - [ ] Corridas persistem após fechar app
  - [ ] Notificações persistem após fechar app

- [ ] **HistoryProvider**
  - [ ] loadTrips() carrega dados do Hive
  - [ ] addTrip() salva nova corrida
  - [ ] getTripsByVehicle() filtra corretamente
  - [ ] getStatistics() calcula valores corretos

## ✅ Testes - Cálculos

- [ ] **Valor por KM e Hora**
  - [ ] Valor/km calculado: (costByKm * avgKm + costByHour * avgHours) / 2
  - [ ] Valor/hora calculado corretamente
  - [ ] Ganho calculado com markup correto (70%)

- [ ] **Estatísticas**
  - [ ] Total de corridas soma corretamente
  - [ ] Total de distância é preciso
  - [ ] Total de ganhos é preciso
  - [ ] Avaliação média calcula corretamente

## ✅ Testes - Permissões (Android)

- [ ] **Network**
  - [ ] App conecta à internet para Google Maps

- [ ] **Geolocation** (Quando implementado)
  - [ ] Solicita permissão ao usuário
  - [ ] Localização atualiza em tempo real

## ✅ Testes de Usabilidade

- [ ] **Fluxo Completo**
  1. [ ] Abrir app
  2. [ ] Selecionar/criar veículo
  3. [ ] Iniciar corrida em tempo real
  4. [ ] Finalizar corrida
  5. [ ] Ver no histórico
  6. [ ] Abrir no Google Maps
  7. [ ] Adicionar avaliação

- [ ] **Responsividade**
  - [ ] Interface funciona em tela pequena (4.5")
  - [ ] Interface funciona em tela grande (6.5")
  - [ ] Textos legíveis em todos os tamanhos
  - [ ] Botões acessíveis

- [ ] **Performance**
  - [ ] App carrega em menos de 2 segundos
  - [ ] Listagem suave com 100+ corridas
  - [ ] Sem travamentos ao finalizar corrida

## ✅ Testes de Validação

- [ ] **Entrada de Dados**
  - [ ] Rejeita distância negativa
  - [ ] Rejeita distância muito grande (> 1000km)
  - [ ] Aceita valores decimais
  - [ ] Valida endereços vazios

- [ ] **Erro Handling**
  - [ ] Mensagem clara quando falha ao salvar
  - [ ] Recupera graciosamente de erros
  - [ ] Não perde dados em caso de erro

## ✅ Testes - Notificações Overlay

- [ ] **OverlayNotificationWidget**
  - [ ] Desliza da direita corretamente
  - [ ] Auto-fecha após 5 segundos
  - [ ] Fecha ao clicar X
  - [ ] Fecha ao clicar na notificação

## 📱 Testes em Dispositivos Reais

### Tester Checklist
- [ ] Testado em Android 8 (API 26)
- [ ] Testado em Android 10 (API 29)
- [ ] Testado em Android 12 (API 31)
- [ ] Testado em Android 14 (API 34)

## 🐛 Bugs Conhecidos / Melhorias Futuras

- [ ] Implementar AccessibilityService para leitura de tela
- [ ] Adicionar sincronização em nuvem
- [ ] Detecção automática de corridas
- [ ] Exportar relatórios em PDF
- [ ] Modo offline aprimorado
- [ ] Ícone de app customizado

## 📊 Métricas de Qualidade

| Métrica | Meta | Atual |
|---------|------|-------|
| Code Coverage | > 80% | - |
| Lint Errors | 0 | - |
| Build Size | < 50MB | - |
| Startup Time | < 2s | - |
| Memory Usage | < 150MB | - |

---

**Data de Criação**: Dezembro 2024
**Versão**: 2.0.0
**Status**: Em Testes

# 🎯 Guia de Recursos de Tempo Real

## Visão Geral

O aplicativo Cálculo de Gastos agora inclui funcionalidades avançadas de rastreamento de corridas em tempo real, registro de histórico detalhado, e integração com Google Maps.

---

## 📱 Recursos Principais

### 1. **Histórico de Corridas**
- **Localização**: Menu principal → "Histórico"
- **Funcionalidades**:
  - Visualizar todas as corridas registradas do veículo selecionado
  - Estatísticas consolidadas (total de corridas, distância, ganhos, avaliação média)
  - Detalhes de cada corrida (tempo, velocidade média, valor/km, valor/hora)
  - Avaliações de passageiros (estrelas e comentários)
  - Abrir endereços no Google Maps

### 2. **Rastreamento em Tempo Real**
- **Localização**: Menu principal → "Tempo Real"
- **Como Usar**:
  1. Preencha o endereço de saída
  2. Preencha o endereço de destino
  3. Informe a distância em km
  4. Clique em "Iniciar Corrida"
  5. O aplicativo mostrará o tempo decorrido
  6. Clique em "Finalizar" para salvar a corrida
  
- **Funcionalidades**:
  - Contador de tempo em tempo real
  - Possibilidade de pausar a corrida
  - Cálculo automático de custos e ganhos
  - Notificação de conclusão
  - Salvamento automático no histórico

### 3. **Integração com Google Maps**
- Abrir endereços de saída e destino no Google Maps
- Visualizar rotas entre dois pontos
- Salvar endereços com coordenadas GPS (quando disponível)
- Compartilhar endereços facilmente

### 4. **Sistema de Notificações**
- Notificações overlay flutuantes
- Exibição de detalhes da corrida (distância, tempo, ganhos)
- Salvamento de notificações no histórico
- Marcar notificações como lidas

---

## 🔄 Fluxo de Trabalho Recomendado

### Iniciar uma Corrida
```
Menu Principal
    ↓
Clique em "Tempo Real"
    ↓
Preencha endereço de saída
    ↓
Preencha endereço de destino
    ↓
Informe distância
    ↓
Clique "Iniciar Corrida"
    ↓
[Timer executa em tempo real]
    ↓
Clique "Finalizar"
    ↓
Corrida salva automaticamente
    ↓
Notificação exibida
```

### Revisar Histórico
```
Menu Principal
    ↓
Clique em "Histórico"
    ↓
Visualize estatísticas consolidadas
    ↓
Expanda uma corrida para detalhes
    ↓
Clique em endereço para ver no Maps
    ↓
Adicione avaliação do passageiro
```

---

## 💾 Armazenamento de Dados

### Estrutura Hive
Dados são persistidos em 3 caixas separadas:

```
Hive Database
├── vehicles (Configurações de veículos)
├── trips (Histórico de corridas)
│   └── [Trip_ID]
│       ├── Distance
│       ├── Duration
│       ├── Cost
│       ├── Earnings
│       ├── PassengerRating
│       └── Addresses
└── notifications (Histórico de notificações)
    └── [Notification_ID]
        ├── Title
        ├── Message
        └── Timestamp
```

### Backup de Dados
- Todos os dados são salvos localmente no dispositivo
- Recomenda-se fazer backup periódico do banco de dados Hive
- Localização no Android: `/data/data/com.seu.app/files/`

---

## 📊 Estatísticas Disponíveis

### Por Veículo
- **Total de Corridas**: Quantidade de corridas registradas
- **Distância Total**: Soma de km percorridos
- **Ganhos Totais**: Ganho bruto acumulado
- **Avaliação Média**: Média das avaliações de passageiros

### Por Corrida
- **Distância**: Km percorridos
- **Duração**: Tempo total
- **Velocidade Média**: km/h
- **Valor/km**: Tarifa por quilômetro
- **Valor/hora**: Tarifa por hora
- **Ganho**: Lucro líquido

---

## 🗺️ Google Maps Integration

### Abrindo Endereços
1. No histórico, clique na corrida desejada
2. Na seção de detalhes, clique em "Saída" ou "Destino"
3. Google Maps abrirá automaticamente

### Funcionalidades disponíveis
- Visualizar localização no mapa
- Obter direções
- Ver tempo estimado de viagem
- Compartilhar localização

---

## ⭐ Sistema de Avaliação

### Adicionar Avaliação de Passageiro
1. Abra o histórico
2. Clique na corrida desejada
3. Expanda os detalhes
4. Avalie com 1-5 estrelas
5. Adicione comentário (opcional)
6. Salve

### Visualizar Avaliações
- Veja estrelas ao lado de cada corrida
- Clique para expandir e ver comentário completo
- Verifique a avaliação média no topo do histórico

---

## 🔧 Permissões Necessárias (Android)

Para total funcionalidade, o aplicativo requer:

### Obrigatórias
- ✅ Acesso à rede (para Google Maps)

### Recomendadas
- 📍 Localização (para rastreamento GPS)
- 🔔 Notificações (para alertas)
- 💾 Armazenamento (para backup)

---

## ⚠️ Dicas e Boas Práticas

1. **Antes de Iniciar**
   - Certifique-se de ter o veículo correto selecionado
   - Verifique se os endereços estão preenchidos corretamente
   - Confirme a distância

2. **Durante a Corrida**
   - Não feche o aplicativo (se pausado)
   - O timer continua mesmo com tela desligada
   - Você pode pausar e retomar

3. **Após a Corrida**
   - Adicione avaliação do passageiro
   - Revise os detalhes antes de finalizar
   - Use Google Maps para verificar rotas

4. **Manutenção de Dados**
   - Limpe histórico antigo periodicamente
   - Faça backup das corridas importantes
   - Mantenha veículos atualizados

---

## 🆘 Solução de Problemas

### Timer não inicia
- Verifique se o veículo está selecionado
- Confirme que todos os campos estão preenchidos
- Reinicie o aplicativo

### Distância não calculada
- Verifique a formatação (use ponto para decimais)
- Exemplo correto: 12.5 km
- Exemplo incorreto: 12,5 km

### Google Maps não abre
- Verifique conexão de internet
- Confirme que Google Maps está instalado
- Teste com outro aplicativo

### Notificação não aparece
- Verifique permissões de notificação
- Confirme que overlay está ativado
- Ajuste configurações de volume

---

## 📝 Atualização de Versão

### v2.0.0 (Atual)
- ✅ Histórico de corridas
- ✅ Rastreamento em tempo real
- ✅ Integração Google Maps
- ✅ Sistema de avaliações
- ✅ Notificações overlay
- ✅ Estatísticas consolidadas

### Planejado para Futuro
- 🔜 Sincronização em nuvem
- 🔜 Detecção automática de corridas
- 🔜 Análise avançada de ganhos
- 🔜 Exportação de relatórios
- 🔜 Modo offline aprimorado

---

## 📞 Suporte

Para questões ou problemas:
1. Revise este guia
2. Verifique seção de Solução de Problemas
3. Reinicie o aplicativo
4. Limpe cache do aplicativo

---

**Última Atualização**: Dezembro 2024
**Versão**: 2.0.0

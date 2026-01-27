# Cálculo de Gastos - App Flutter

Um aplicativo moderno e intuitivo para motoristas de aplicativos gerenciarem custos, analisarem ofertas de corridas e controlarem finanças, com gravação secreta de vídeo e marca d'água automática. Desenvolvido em Flutter (Material Design 3).

## ✨ Características Principais

- ✅ **Cálculo Automatizado**: Custos fixos, variáveis, valor/hora e valor/km
- ✅ **Histórico de Corridas**: Registre e acompanhe todas as corridas
- ✅ **Rastreamento em Tempo Real**: Inicie corridas com contador automático
- ✅ **🆕 Sistema de Semáforo (v3.0)**: Análise inteligente de ofertas com recomendações 🟢🟡🔴
- ✅ **🆕 Controle Financeiro (v3.1)**: Gerencie receitas e despesas para calcular lucro real
- ✅ **🆕 Remoção de anúncios (v3.2.1)**: Qualquer assinatura paga remove anúncios; apenas vídeo ads no free
- ✅ **🆕 Tema dinâmico (v3.2.2)**: Dark/Light/System + 8 cores
- ✅ **🆕 Gravação secreta + marca d'água (v3.2.3)**: Vídeos com data, hora, endereço e coordenadas, seleção de câmera e player dedicado
- ✅ **Integração Google Maps**: Abra endereços e rotas diretamente
- ✅ **Avaliações de Passageiros**: Adicione estrelas e comentários
- ✅ **Interface Moderna**: Design Material 3 com tema responsivo
- ✅ **Gerenciamento de Veículos**: Adicionar, editar e deletar múltiplos veículos
- ✅ **Análise Detalhada**: Visualize breakdown completo de custos e ganhos
- ✅ **Persistência Local**: Dados salvos localmente com Hive
- ✅ **Notificações Overlay**: Receba alertas de corridas finalizadas
- ✅ **Multi-plataforma**: Android e iOS suportados
- ✅ **Português Brasileiro**: Totalmente localizado

## 🎯 Funcionalidades

### 🆕 v3.3 (próximo) - Sincronização em nuvem (planejado)
**Planejado**:
- Sincronizar vídeos e dados financeiros na nuvem
- Backup automático e restauração
- Compartilhamento seguro de gravações

---

### 🆕 v3.2.3 - Gravação Secreta + Marca d'Água
**O que faz**:
- Gravar vídeos secretamente com seleção de câmera (frontal/traseira)
- Inserir marca d'água automática: data, hora, endereço e coordenadas
- Galeria interna com metadados, player dedicado e salvar na galeria
- Permissões guiadas (câmera, microfone, localização)

**Como usar (rápido)**:
1) Home → "Gravar" → iniciar/parar
2) Marca d'água aparece no preview
3) Vá em "Vídeos" para listar, reproduzir ou salvar

**Docs**:
- MARCA_DAGUA.md (técnico)
- MARCA_DAGUA_SETUP.md (setup iOS/Android)
- EXEMPLOS_MARCA_DAGUA.md (15 exemplos)
- MARCA_DAGUA_RAPIDO.md (3 min)

---

### 🆕 v3.2.2 - Sistema de Tema Completo
**O que faz**:
- Dark/Light/System + 8 cores temáticas
- Aplica em todas as telas (gravação, galeria, player, finanças)
- Persistência de escolha do usuário

**Como usar**:
- Tela de Configurações de Tema → escolha modo e cor

---

### 🆕 v3.2.1 - Monetização (Anúncios)
**Mudanças**:
- Qualquer assinatura paga remove anúncios
- Free: apenas um anúncio de vídeo quando aplicável
- AdBanner descontinuado; interstitial/ vídeo mantido

---

### 🆕 v3.1 - Sistema de Controle Financeiro
**Gerencie todas as suas receitas e despesas:**
- 💰 **Receitas**: Corridas, gorjetas, bônus, reembolsos
- 💸 **Despesas**: Combustível, manutenção, seguro, alimentação, telefone, etc.
- 📊 **Análises Completas**: 
  - Lucro líquido real após todos os custos
  - Margem de lucro percentual
  - Média diária de ganhos
  - Top categorias de despesas
  - Previsão de gastos recorrentes
- 🔄 **Despesas Recorrentes**: Registre gastos mensais (seguro, telefone)
- 📸 **Anexos**: Adicione fotos de recibos
- 🗓️ **Filtros**: Visualize por dia, semana, mês ou total
- 🚗 **Integração com Corridas**: Receitas vinculadas automaticamente às corridas aceitas

**[📖 Documentação Completa v3.1](FINANCIAL_SYSTEM_v3.1.md)**  
**[📋 Guia de Implementação v3.1](IMPLEMENTATION_GUIDE_v3.1.md)**

---

### 🆕 v3.0 - Sistema de Semáforo para Ofertas
**Decida quais corridas aceitar com confiança:**
- 📱 **Detecção Automática**: Reconhece notificações de Uber, 99 e iDriver
- 🧮 **Análise de Rentabilidade**: Score baseado em 7 fatores
- 🚦 **Sistema de Semáforo**: 
  - 🟢 Verde (≥70): Excelente, aceite!
  - 🟡 Amarelo (50-69): Avalie com cuidado
  - 🔴 Vermelho (<50): Evite, baixa rentabilidade
- 📊 **Estatísticas**: Acompanhe taxas de aceitação/rejeição
- ⏱️ **Histórico**: Veja todas as ofertas recebidas

**Fatores analisados:**
- Valor oferecido vs distância
- Tempo estimado
- Custo de combustível
- Desgaste do veículo
- Relação valor/hora
- Eficiência da rota

**[📖 Documentação Completa v3.0](RIDE_OFFERS_FEATURE_v3.md)**

---

### Gerenciamento de Veículos
- Criar múltiplos perfis de veículos
- Configurar custos fixos e variáveis
- Definir tarifa por hora e por km
- Gerenciar dados operacionais

### Custos Fixos
- Parcela mensal (financiamento)
- IPVA anual
- Seguro anual
- Troca de óleo
- Pneus
- Manutenção e revisão

### Combustível
- Preço do combustível
- Tamanho do tanque
- Consumo na cidade (km/l)
- Consumo na rodovia (km/l)

### Configurações Operacionais
- Limite de KM semanal
- Dias de trabalho por semana
- Horas de trabalho por dia
- Lucro desejado (semanal)

### Histórico de Corridas
- Registre corridas com tempo e distância
- Salve endereços de saída e destino
- Visualize estatísticas por veículo
- Abra endereços no Google Maps
- Adicione avaliações de passageiros

### Rastreamento em Tempo Real
- Contador de tempo automático
- Cálculo de custos em tempo real
- Possibilidade de pausar corrida
- Salvamento automático

### Sistema de Notificações
- Overlay flutuante com detalhes da corrida
- Histórico de notificações
- Marcar como lidas

## 📱 Plataformas Suportadas
- Android (API 21+)
- iOS (12.0+)

## 🔧 Requisitos
- Flutter 3.10.7 ou superior
- Dart 3.10 ou superior

## 🚀 Instalação

### 1. Clone o repositório
```bash
git clone https://github.com/MikhaelGois/calculodegastosapp.git
cd calculodegastosapp
```

### 2. Instale dependências
```bash
flutter pub get
```

### 3. Execute o aplicativo
```bash
flutter run
```

### 4. Build para produção

**Android:**
```bash
flutter build apk
# ou para AAB (Google Play)
flutter build appbundle
```

**iOS:**
```bash
flutter build ios
```

## 📦 Dependências Principais

- **provider**: Gerenciamento de estado
- **hive**: Banco de dados local
- **intl**: Localização e formatação
- **fl_chart**: Gráficos (preparado para futuro)
- **uuid**: Geração de IDs únicos
- **animations**: Animações Material

## 🏗️ Arquitetura

```
lib/
├── main.dart                 # Entrada da aplicação
├── models/                   # Modelos de dados
│   ├── vehicle.dart
│   └── calculation_result.dart
├── providers/                # State management
│   └── vehicle_provider.dart
├── screens/                  # Telas da aplicação
│   ├── home_screen.dart
│   ├── vehicle_form_screen.dart
│   ├── calculation_screen.dart
│   └── results_screen.dart
├── services/                 # Serviços
│   ├── storage_service.dart  # Persistência de dados
│   └── calculation_service.dart
├── widgets/                  # Widgets reutilizáveis
│   └── custom_widgets.dart
└── utils/                    # Utilitários
    └── format_utils.dart
```

## 🎨 Design

- **Material Design 3**: Tema moderno e responsivo
- **Cor primária**: #1F77D2 (Azul)
- **Tipografia**: Família Roboto (padrão Material)
- **Ícones**: Material Icons

## 🔄 Fluxo de Uso

1. **Adicionar Veículo**: Insira informações do veículo
2. **Preencher Dados**: Configure custos e operacional
3. **Calcular**: Calcule os resultados
4. **Visualizar**: Veja ganhos, custos e detalhes
5. **Gerenciar**: Edite ou delete veículos conforme necessário

## 💾 Persistência de Dados

Os dados são armazenados localmente usando Hive (banco de dados NoSQL para Flutter):
- Veículos são salvos automaticamente
- Cada veículo mantém histórico de configurações
- Sem sincronização em nuvem (pode ser implementado)

## 🚀 Melhorias Futuras

- [ ] Gráficos de análise de gastos
- [ ] Sincronização em nuvem (Firebase)
- [ ] Exportação de relatórios (PDF)
- [ ] Modo escuro
- [ ] Multi-idiomas
- [ ] Backup e restore
- [ ] Histórico de cálculos
- [ ] Compartilhamento de dados

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a Licença MIT - veja o arquivo LICENSE para detalhes.

## 👨‍💻 Autor

**Mikhael Gois**

## 📞 Suporte

Para questões e sugestões, abra uma issue no repositório.

---

Desenvolvido com ❤️ usando Flutter

### Requisitos

1. Abra o projeto no Android Studio
2. Sincronize o Gradle
3. Conecte um emulador ou dispositivo Android
4. Clique em "Run" (Shift + F10)

## Estrutura do Projeto

```
app/
├── src/
│   ├── main/
│   │   ├── java/com/example/calculogastos/
│   │   │   └── MainActivity.kt
│   │   ├── res/
│   │   │   ├── layout/
│   │   │   │   └── activity_main.xml
│   │   │   ├── values/
│   │   │   │   ├── strings.xml
│   │   │   │   ├── colors.xml
│   │   │   │   └── themes.xml
│   │   └── AndroidManifest.xml
│   └── build.gradle
└── proguard-rules.pro
```

## Dependências

- AndroidX Core KTX 1.12.0
- AndroidX AppCompat 1.6.1
- Material Components 1.11.0
- ConstraintLayout 2.1.4

## Licença

MIT

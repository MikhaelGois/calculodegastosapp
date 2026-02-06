# RotaLucro

Um aplicativo Flutter para análise de rentabilidade de corridas sugeridas por apps como Uber, 99 e Indriver, com base em dados históricos e configurações de custos.

## Descrição

O RotaLucro é um aplicativo móvel desenvolvido para ajudar motoristas parceiros a tomar decisões inteligentes sobre quais corridas aceitar. Com base nas configurações de custos definidas pelo usuário e em dados históricos de corridas, o aplicativo analisa automaticamente a rentabilidade das corridas sugeridas pelos apps de transporte.

## Recursos

- Análise automática de rentabilidade de corridas sugeridas por apps de transporte
- Configuração personalizada de custos operacionais (fixos e variáveis)
- Controle financeiro com histórico de corridas e despesas
- Cálculo manual de rentabilidade para corridas específicas
- Integração com notificações do sistema para apps de corrida
- Overlay automático para exibição instantânea de cálculos
- Armazenamento local de dados (SharedPreferences)
- Interface intuitiva e responsiva

## Tecnologias Utilizadas

- Flutter (Dart)
- SharedPreferences para armazenamento local
- Permission Handler para gerenciamento de permissões
- UUID para geração de identificadores únicos
- Intl para internacionalização
- Flutter Local Notifications

## Desenvolvedor

Mikhael Gois

## Licença

Este projeto está licenciado sob os termos da licença MIT.

## Arquitetura

O projeto segue uma arquitetura modular com as seguintes camadas:

- `lib/`: Código-fonte principal
  - `core/`: Temas e configurações centrais
  - `data/`: Modelos, serviços e armazenamento
    - `models/`: Classes de modelo de dados
    - `services/`: Serviços de lógica de negócio
    - `storage/`: Serviços de armazenamento local
  - `presentation/`: Telas e widgets da interface
    - `screens/`: Telas do aplicativo
    - `widgets/`: Componentes reutilizáveis
  - `utils/`: Funções utilitárias

## Instalação

1. Clone este repositório
2. Execute `flutter pub get` para instalar as dependências
3. Execute o aplicativo com `flutter run`

## Permissões Requeridas

- Acesso às notificações: Para ler notificações dos apps de corrida (Uber, 99, Indriver)
- Sobreposição de apps: Para exibir cálculos instantaneamente sobre outros apps
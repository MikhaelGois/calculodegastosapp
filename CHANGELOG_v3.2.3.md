# Changelog v3.2.3 — Gravação Secreta + Marca d'Água
**Data:** 27/01/2026  \
**Tipo:** Nova funcionalidade

## 🎯 Destaques
- Gravação secreta de vídeo com seleção de câmera (frontal/traseira).
- Marca d'água automática em todos os vídeos gravados: data, hora, endereço e coordenadas.
- Player dedicado para reprodução com salvamento/compartilhamento e metadados.
- Galeria interna para listar, reproduzir e deletar vídeos.
- Permissões guiadas para câmera, microfone e localização.

## 🆕 Funcionalidades
- **Tela de gravação secreta:** alterna câmera, inicia/paralisa gravação, exibe tempo e status.
- **Marca d'água automática:** captura horário, localização (endereço + GPS) e tipo de câmera e grava junto ao vídeo.
- **Galeria de vídeos:** lista cronológica com duração, câmera usada e data; opções de reproduzir, compartilhar e deletar.
- **Player completo:** controles de play/pause, seek ±10s, salvar na galeria, mostrar metadados.
- **Widgets auxiliares:** badge de gravação, preview mini, overlay de marca d'água.

## 📂 Principais Arquivos
- `lib/screens/secret_recording_screen.dart` — UI de gravação e controles.
- `lib/screens/recorded_videos_screen.dart` — Galeria de vídeos gravados.
- `lib/screens/video_playback_screen.dart` — Player e metadados.
- `lib/providers/camera_provider.dart` — Estado de câmera e gravação.
- `lib/services/camera_service.dart` — Lógica de captura e armazenamento.
- `lib/services/location_service.dart` — GPS + geocoding.
- `lib/services/watermark_service.dart` — Marca d'água (formatação e serialização).
- `lib/widgets/watermark_widgets.dart` — Overlays e cards.

## ✅ Checklist
- [x] Gravação secreta com alternância de câmera
- [x] Marca d'água com data/hora/localização/câmera
- [x] Permissões (câmera, microfone, localização)
- [x] Galeria e player dedicados
- [x] Documentação completa (guias, exemplos, índices)

## 🔗 Documentação Relacionada
- `MARCA_DAGUA.md` — Referência técnica completa
- `MARCA_DAGUA_SETUP.md` — Passo a passo de configuração
- `EXEMPLOS_MARCA_DAGUA.md` — 15 exemplos práticos
- `MARCA_DAGUA_RESUMO_VISUAL.md` — Diagramas e visão rápida
- `MARCA_DAGUA_RAPIDO.md` — Guia ultra-rápido

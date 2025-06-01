# CRUD Flutter com Persistência JSON

Exercício da disciplina de PROGRAMAÇÃO_PARA_DISPOSITIVOS_MÓVEIS_II, ministrada pelo professor Carlos Feichas.

Aplicativo Flutter que implementa operações CRUD (Create, Read, Update, Delete) com armazenamento persistente em arquivo JSON local.

## Funcionalidades

- **Criar (C)**: Adicionar novos usuários com nome e email
- **Ler (R)**: Visualizar lista de usuários cadastrados
- **Atualizar (U)**: Editar informações de usuários existentes
- **Excluir (D)**: Remover usuários da lista
- **Persistência**: Armazenamento em arquivo JSON local

## Tecnologias Utilizadas

- Flutter
- Dart
- JSON para persistência de dados
- Uso de path_provider para acesso ao sistema de arquivos

## Como Executar

1. Certifique-se de ter o Flutter instalado e configurado
2. Clone este repositório:
git clone https://github.com/seu-usuario/crud-flutter-json.git

3. Navegue até a pasta do projeto:
cd crud-flutter-json

4. Obtenha as dependências:
flutter pub get

5. Execute o aplicativo:
flutter run


## Estrutura do Projeto

O projeto utiliza uma estrutura simples com todo o código principal no arquivo `lib/main.dart`:

- Implementação do CRUD completo
- Persistência em arquivo JSON
- Interface de usuário com Material Design
- Tratamento de plataformas (Android, iOS, Linux, etc.)

## Requisitos

- Flutter 3.0+
- Dart 2.17+
- Dispositivo ou emulador Android/iOS

## Observações

O aplicativo salva os dados em:
- Android/iOS: Diretório de documentos do aplicativo
- Linux/Desktop: Pasta "Documentos" ou "Documents" no diretório home do usuário
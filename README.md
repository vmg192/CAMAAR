# CAMAAR - Sistema de Avaliação Acadêmica

Sistema web para avaliação de disciplinas e docentes na Universidade de Brasília.

## Instalação

### Pré-requisitos
- Ruby 3.4.5
- Bundler
- Node.js

### Passos

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/CAMAAR.git
cd CAMAAR

# Instale as dependências
bundle install

# Configure o banco de dados
./reset_db.sh

# Inicie o servidor
bin/dev
```

Acesse: http://localhost:3000

## Credenciais

| Usuário | Login | Senha |
|---------|-------|-------|
| Admin | admin | password |
| Aluno | aluno123 | senha123 |
| Professor | prof | senha123 |

## Testes

```bash
# Rodar testes BDD
bundle exec cucumber features/sistema_login.feature
```

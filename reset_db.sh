#!/bin/bash
# Script para resetar o banco de dados do CAMAAR

echo " Removendo bancos antigos..."
rm -f db/*.sqlite3

echo " Criando banco com schema correto..."
rails db:schema:load

echo " Populando dados..."
rails db:seed

echo ""
echo " BANCO PRONTO!"
echo ""
echo "=== CREDENCIAIS ==="
echo "Admin: login=admin, senha=password"
echo "Aluno: login=aluno123, senha=senha123"
echo "Professor: login=prof, senha=senha123"
echo ""
echo "Agora execute: bin/dev"

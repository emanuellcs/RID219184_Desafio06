#!/bin/bash

# Script de teste da API DNCommerce para Bash (Linux/macOS)

# --- Configuração ---
BASE_URL="http://localhost:3000"
HEADERS=(-H "Content-Type: application/json")

# --- Função Auxiliar de Teste ---
# Parâmetros: 1:Nome do Teste, 2:Método HTTP, 3:Rota, 4:Corpo da Requisição (JSON string)
test_endpoint() {
    local test_name="$1"
    local method="$2"
    local route="$3"
    local body="$4"
    local url="$BASE_URL$route"

    echo "---[ TESTE: $test_name ]---"

    # Constrói o comando curl
    local curl_cmd=(curl -s -X "$method" "${HEADERS[@]}" "$url")
    if [[ -n "$body" ]]; then
        curl_cmd+=(-d "$body")
    fi

    # Executa o comando e captura a resposta e o status HTTP
    http_response=$("${curl_cmd[@]}" -w "\n%{http_code}")
    http_body=$(echo "$http_response" | sed '$d')
    http_status=$(echo "$http_response" | tail -n 1)

    # Verifica o status da resposta
    if [[ "$http_status" -ge 200 && "$http_status" -lt 300 ]]; then
        echo "SUCESSO (Status: $http_status)"
        echo "Resposta:"
        echo "$http_body" | jq . # Usa jq para formatar a saída
        # Retorna o corpo da resposta para extração de IDs
        echo "$http_body"
    else
        echo "FALHA (Status: $http_status)"
        echo "Corpo do Erro:"
        echo "$http_body" | jq .
        # Retorna uma string vazia em caso de falha
        echo ""
    fi
    echo "---[ FIM DO TESTE ]---"
    echo ""
}

# --- Início dos Testes ---

# === SEÇÃO DE PRODUTOS ===

# 1. Criar um novo produto
echo "1. Criando um novo produto..."
product_body='{
    "nome": "Sérum Vitamina C",
    "descricao": "Sérum antioxidante para a pele",
    "preco": 89.99,
    "categoria": "Skincare"
}'
response=$(test_endpoint "POST /produtos" "POST" "/produtos" "$product_body")
product_id=$(echo "$response" | jq -r '._id')
if [[ -z "$product_id" || "$product_id" == "null" ]]; then echo "Falha ao criar produto. Abortando."; exit 1; fi
sleep 1

# 2. Listar todos os produtos
echo "2. Listando todos os produtos..."
test_endpoint "GET /produtos" "GET" "/produtos"
sleep 1

# 3. Obter o produto criado por ID
echo "3. Obtendo produto por ID..."
test_endpoint "GET /produtos/{id}" "GET" "/produtos/$product_id"
sleep 1

# 4. Atualizar o produto
echo "4. Atualizando o produto..."
updated_product_body='{
    "preco": 95.50
}'
test_endpoint "PUT /produtos/{id}" "PUT" "/produtos/$product_id" "$updated_product_body"
sleep 1

# === SEÇÃO DE ESTOQUE ===

# 5. Atualizar o estoque do novo produto
echo "5. Atualizando o estoque..."
stock_body='{
    "quantidade": 150
}'
test_endpoint "PUT /estoque/{produto_id}" "PUT" "/estoque/$product_id" "$stock_body"
sleep 1

# 6. Obter a quantidade em estoque do produto
echo "6. Obtendo a quantidade em estoque..."
test_endpoint "GET /estoque/{produto_id}" "GET" "/estoque/$product_id"
sleep 1

# === SEÇÃO DE CLIENTES ===

# 7. Criar um novo cliente
echo "7. Criando um novo cliente..."
# Gera um email único usando o timestamp
unique_email="joana.doe+$(date +%s)@example.com"
client_body=$(cat <<EOF
{
    "nome": "Joana Doe",
    "email": "$unique_email",
    "telefone": "11987654321",
    "enderecos": [
        {
            "rua": "Rua das Flores",
            "numero": "123",
            "cidade": "São Paulo",
            "estado": "SP",
            "cep": "01000-000"
        }
    ]
}
EOF
)
response=$(test_endpoint "POST /clientes" "POST" "/clientes" "$client_body")
client_id=$(echo "$response" | jq -r '._id')
if [[ -z "$client_id" || "$client_id" == "null" ]]; then echo "Falha ao criar cliente. Abortando."; exit 1; fi
sleep 1

# 8. Listar todos os clientes
echo "8. Listando todos os clientes..."
test_endpoint "GET /clientes" "GET" "/clientes"
sleep 1

# 9. Obter cliente por ID
echo "9. Obtendo cliente por ID..."
test_endpoint "GET /clientes/{id}" "GET" "/clientes/$client_id"
sleep 1

# 10. Atualizar cliente por ID
echo "10. Atualizando o cliente..."
updated_client_body='{
    "telefone": "11999998888"
}'
test_endpoint "PUT /clientes/{id}" "PUT" "/clientes/$client_id" "$updated_client_body"
sleep 1

# === SEÇÃO DE VENDAS ===

# 11. Registrar uma nova venda
echo "11. Registrando uma nova venda..."
sale_body=$(cat <<EOF
{
    "cliente_id": "$client_id",
    "itens": [
        {
            "produto_id": "$product_id",
            "quantidade": 2,
            "preco_unitario": 95.50
        }
    ]
}
EOF
)
response=$(test_endpoint "POST /vendas" "POST" "/vendas" "$sale_body")
sale_id=$(echo "$response" | jq -r '._id')
if [[ -z "$sale_id" || "$sale_id" == "null" ]]; then echo "Falha ao criar venda. Abortando."; exit 1; fi
sleep 1

# 12. Listar todas as vendas
echo "12. Listando todas as vendas..."
test_endpoint "GET /vendas" "GET" "/vendas"
sleep 1

# 13. Obter venda por ID
echo "13. Obtendo venda por ID..."
test_endpoint "GET /vendas/{id}" "GET" "/vendas/$sale_id"
sleep 1

# 14. Atualizar o status da venda
echo "14. Atualizando o status da venda..."
update_sale_status_body='{
    "status": "enviado"
}'
test_endpoint "PUT /vendas/{id}" "PUT" "/vendas/$sale_id" "$update_sale_status_body"
sleep 1

# === SEÇÃO DE LIMPEZA ===

# 15. Excluir o produto
echo "15. Excluindo o produto..."
test_endpoint "DELETE /produtos/{id}" "DELETE" "/produtos/$product_id"
sleep 1

# 16. Excluir o cliente
echo "16. Excluindo o cliente..."
test_endpoint "DELETE /clientes/{id}" "DELETE" "/clientes/$client_id"
sleep 1

echo "Todos os testes foram executados."
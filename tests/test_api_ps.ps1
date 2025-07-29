# Script de teste da API DNCommerce para PowerShell

$baseUrl = "http://localhost:3000"
$headers = @{"Content-Type"="application/json"}

# Função auxiliar para executar e reportar os testes
function Test-Endpoint {
    param(
        [string]$Name,
        [string]$Method,
        [string]$Uri,
        [object]$Body
    )

    Write-Host "---[ TESTE: $Name ]---"
    try {
        $params = @{
            Method = $Method
            Uri = $Uri
            Headers = $headers
            ErrorAction = 'Stop'
        }
        if ($Body) {
            $params.Body = ($Body | ConvertTo-Json -Depth 10)
        }
        
        $response = Invoke-RestMethod @params
        Write-Host "SUCESSO" -ForegroundColor Green
        Write-Host "Resposta:"
        $response | Format-List | Out-String | Write-Host
        return $response
    } catch {
        Write-Host "FALHA" -ForegroundColor Red
        Write-Host "Erro: $($_.Exception.Message)"
        # Tenta ler o corpo da resposta de erro
        try {
            $errorResponse = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorResponse)
            $reader.BaseStream.Position = 0
            $errorBody = $reader.ReadToEnd();
            Write-Host "Corpo do Erro: $errorBody"
        } catch {
            Write-Host "Não foi possível ler o corpo da resposta de erro."
        }
        return $null
    } finally {
        Write-Host "---[ FIM DO TESTE ]---`n"
    }
}

# --- Início dos Testes ---

# === SEÇÃO DE PRODUTOS ===

# 1. Criar um novo produto
$productBody = @{
    nome = "Sérum Vitamina C"
    descricao = "Sérum antioxidante para a pele"
    preco = 89.99
    categoria = "Skincare"
}
$newProduct = Test-Endpoint -Name "POST /produtos" -Method Post -Uri "$baseUrl/produtos" -Body $productBody
if (-not $newProduct) { throw "Falha ao criar produto. Abortando testes." }
$productId = $newProduct._id
Start-Sleep -Seconds 1

# 2. Listar todos os produtos
Test-Endpoint -Name "GET /produtos" -Method Get -Uri "$baseUrl/produtos"
Start-Sleep -Seconds 1

# 3. Obter o produto criado por ID
Test-Endpoint -Name "GET /produtos/{id}" -Method Get -Uri "$baseUrl/produtos/$productId"
Start-Sleep -Seconds 1

# 4. Atualizar o produto
$updatedProductBody = @{
    preco = 95.50
}
Test-Endpoint -Name "PUT /produtos/{id}" -Method Put -Uri "$baseUrl/produtos/$productId" -Body $updatedProductBody
Start-Sleep -Seconds 1

# === SEÇÃO DE ESTOQUE ===

# 5. Atualizar o estoque do novo produto
$stockBody = @{
    quantidade = 150
}
Test-Endpoint -Name "PUT /estoque/{produto_id}" -Method Put -Uri "$baseUrl/estoque/$productId" -Body $stockBody
Start-Sleep -Seconds 1

# 6. Obter a quantidade em estoque do produto
Test-Endpoint -Name "GET /estoque/{produto_id}" -Method Get -Uri "$baseUrl/estoque/$productId"
Start-Sleep -Seconds 1

# === SEÇÃO DE CLIENTES ===

# 7. Criar um novo cliente
$clientBody = @{
    nome = "Joana Doe"
    email = "joana.doe+$(Get-Date -Format "yyyyMMddHHmmssfff")@example.com"
    telefone = "11987654321"
    enderecos = @(
        @{
            rua = "Rua das Flores"
            numero = "123"
            cidade = "São Paulo"
            estado = "SP"
            cep = "01000-000"
        }
    )
}
$newClient = Test-Endpoint -Name "POST /clientes" -Method Post -Uri "$baseUrl/clientes" -Body $clientBody
if (-not $newClient) { throw "Falha ao criar cliente. Abortando testes." }
$clientId = $newClient._id
Start-Sleep -Seconds 1

# 8. Listar todos os clientes
Test-Endpoint -Name "GET /clientes" -Method Get -Uri "$baseUrl/clientes"
Start-Sleep -Seconds 1

# 9. Obter cliente por ID
Test-Endpoint -Name "GET /clientes/{id}" -Method Get -Uri "$baseUrl/clientes/$clientId"
Start-Sleep -Seconds 1

# 10. Atualizar cliente por ID
$updatedClientBody = @{
    telefone = "11999998888"
}
Test-Endpoint -Name "PUT /clientes/{id}" -Method Put -Uri "$baseUrl/clientes/$clientId" -Body $updatedClientBody
Start-Sleep -Seconds 1

# === SEÇÃO DE VENDAS ===

# 11. Registrar uma nova venda
$saleBody = @{
    cliente_id = $clientId
    itens = @(
        @{
            produto_id = $productId
            quantidade = 2
            preco_unitario = 95.50
        }
    )
}
$newSale = Test-Endpoint -Name "POST /vendas" -Method Post -Uri "$baseUrl/vendas" -Body $saleBody
if (-not $newSale) { throw "Falha ao criar venda. Abortando testes." }
$saleId = $newSale._id
Start-Sleep -Seconds 1

# 12. Listar todas as vendas
Test-Endpoint -Name "GET /vendas" -Method Get -Uri "$baseUrl/vendas"
Start-Sleep -Seconds 1

# 13. Obter venda por ID
Test-Endpoint -Name "GET /vendas/{id}" -Method Get -Uri "$baseUrl/vendas/$saleId"
Start-Sleep -Seconds 1

# 14. Atualizar o status da venda
$updateSaleStatusBody = @{
    status = "enviado"
}
Test-Endpoint -Name "PUT /vendas/{id}" -Method Put -Uri "$baseUrl/vendas/$saleId" -Body $updateSaleStatusBody
Start-Sleep -Seconds 1

# === SEÇÃO DE LIMPEZA ===

# 15. Excluir o produto
Test-Endpoint -Name "DELETE /produtos/{id}" -Method Delete -Uri "$baseUrl/produtos/$productId"
Start-Sleep -Seconds 1

# 16. Excluir o cliente
Test-Endpoint -Name "DELETE /clientes/{id}" -Method Delete -Uri "$baseUrl/clientes/$clientId"
Start-Sleep -Seconds 1

Write-Host "Todos os testes foram executados."
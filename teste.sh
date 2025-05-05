#!/bin/bash

# Solicita o nome do pacote ao usuário
read -p "Digite o nome do pacote: " query

# Faz a busca na AUR com o termo digitado
response=$(curl -s "https://aur.archlinux.org/rpc?v=5&type=search&arg=${query}")

# Cabeçalho da tabela
printf "%-30s %-8s %-10s %s\n" "NAME" "UPVOTES" "PROXIMITY" "DESCRIPTION"
printf "%-30s %-8s %-10s %s\n" "------------------------------" "--------" "----------" "----------------------------------------"

# Processa e exibe resultados formatados
echo "$response" | jq -r '
  .results
  | map([
      .Name, 
      .NumVotes, 
      (if .Description | test("'"${query}"'"; "i") then 0 else 1 end), 
      .Description
    ])
  | sort_by(.[2], ( -.[1] ))
  | .[:10]
  | .[]
  | @tsv' | while IFS=$'\t' read -r name upvotes is_close description; do
    proximity=$([ "$is_close" -eq 0 ] && echo "Close" || echo "Far")
    printf "%-30s %-8s %-10s %s\n" "$name" "$upvotes" "$proximity" "$description"
done

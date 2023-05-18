#!/bin/bash

calculate_days_until_expiry() {
    # Przyjmuje datę w formacie "Friday, September 2, 2022 4:51:37 PM CEST" i zwraca liczbę dni do tej daty od dzisiaj

    expiry_date="$1"
    expiry_timestamp=$(date -d "$expiry_date" +%s)
    current_timestamp=$(date +%s)

    diff_seconds=$((expiry_timestamp - current_timestamp))
    diff_days=$((diff_seconds / 86400))

    echo "$diff_days"
}


extract_qmanager_name() {
    label="$1"
    qmanager_name="${label#ibmwebspheremq}"

    echo "$qmanager_name"
}

# Wykonaj polecenie i zapisz wynik do zmiennej
#output=$(runmqckm -cert -list -db key.kdb -expiry -stashed)
output=$(./debug.sh)

filtered_output=$(echo "$output" | awk 'BEGIN { RS = ""; FS = "\n" } /^ibmweb/ { print $2 }')
filter_label=$(echo "$output" | awk '/^ibmweb/')

# Wyciągnij daty z wyniku
from_date=$(echo "$filtered_output" | awk -F': ' '/To:/ {print $2}' | sed 's/ To//')
to_date=$(echo "$filtered_output" | awk -F': ' '/To:/ {print $3}')

# Oblicz liczbę dni do wygaśnięcia
days_until_expiry=$(calculate_days_until_expiry "$to_date")

label="$filter_label"
# Wyodrębnij nazwę Q Managera
qmanager_name=$(extract_qmanager_name "$label")

echo "{\"days_until_expiry\": $days_until_expiry, \"qmanager_name\": \"$qmanager_name\"}"
echo "Liczba dni do wygaśnięcia certyfikatu: $days_until_expiry MQanagerName: $qmanager_name"

#!/bin/bash

header='
{
  "kid": "66824c5d7aec4a23986bbbf828d8d05c",
  "alg": "RS256"
}'

payload='
{
  "iss": "https://example.com",
  "sub": "sho2010@gmail.com",
  "aud": "awesome-app-id-123",
  "exp": 1735689600,
  "iat": 1563980400
}'

function pack() {
  # Remove return and space
  echo $1 | sed -e "s/[\r\n]\+//g" | sed -e "s/ //g"
}

if ! pem-jwk kubectl > /dev/null 2>&1; then
  echo 'pem-jwk command not found. Please install it.'
  echo 'npm install pem-jwk'
  exit 1
fi

if [ ! -f private-key.pem ]; then
  # Private and Public keys
  openssl genrsa 2048 > private-key.pem
  openssl rsa -in private-key.pem -pubout -out public-key.pem
fi

# Base64 Encoding
b64_header=$(pack "$header" | openssl enc -e -A -base64)
b64_payload=$(pack "$payload" | openssl enc -e -A -base64)
signature=$(echo -n $b64_header.$b64_payload | openssl dgst -sha256 -sign private-key.pem | openssl enc -e -A -base64)
# Export JWT
echo $b64_header.$b64_payload.$signature > jwt.txt

jwk=$(pem-jwk public-key.pem)
# Add additional fields
jwk=$(echo '{"use":"sig"}' $jwk $header | jq -cs add)
# Export JWK
echo '{"keys":['$jwk']}'| jq . > jwks.json

echo "--- JWT ---"
cat jwt.txt
echo -e "\n--- JWK ---"
jq . jwks.json

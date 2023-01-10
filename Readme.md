# Creating certificates

## CA Certificate

- Generate a private Key
```bash
openssl req -x509 -sha256 -days 3650 -newkey rsa:4096 -keyout root-ca.key -out root-ca.crt
```

```bash
openssl rsa -in root-ca.key -out key.pem
```

```bash
openssl x509 -in root-ca.crt -out RootCA-cert.pem -outform PEM
```

## Server Certificates

```bash
openssl req \
	-x509 \
	-newkey rsa:4096 \
	-keyout server-key.pem \
	-out server-cert.pem \
	-nodes \
	-days 365 \
	-subj "/CN=localhost/O=Client\ Certificate\ Demo"
```

This command shortens following _three_ commands:

- `openssl genrsa` 
- `openssl req`
- `openssl x509`

which generates _two_ files:

- `server_cert.pem`
- `server_key.pem`

## Create Client Certificates

For demo, two users are created:

- Alice, who has a valid certificate, signed by the server
- Bob, who creates own certificate, self-signed


### Create Alice's Certificate (server-signed and valid)

We create a certificate for Alice.

- sign alice's Certificate Signing Request (CSR)...
- with our server key via `-CA server_cert.pem` and
	`-CAkey server_key.pem` flags
- and save results as certificate

```bash
# generate server-signed (valid) certifcate
openssl req \
	-newkey rsa:4096 \
	-keyout alice_key.pem \
	-out alice_csr.pem \
	-nodes \
	-days 365 \
	-subj "/CN=Alice"

# sign with server_cert.pem
openssl x509 \
	-req \
	-in alice_csr.pem \
	-CA server_cert.pem \
	-CAkey server_key.pem \
	-out alice_cert.pem \
	-set_serial 01 \
	-days 365
```

### Create Bob's Certificate (self-signed and invalid)

Bob creates own without our server key.

```bash
# generate self-signed (invalid) certifcate
openssl req \
	-newkey rsa:4096 \
	-keyout bob_key.pem \
	-out bob_csr.pem \
	-nodes \
	-days 365 \
	-subj "/CN=Bob"

# sign with bob_csr.pem
openssl x509 \
	-req \
	-in bob_csr.pem \
	-signkey bob_key.pem \
	-out bob_cert.pem \
	-days 365
```

## Setting up the kubernetes cluster

### Creating the namespace

```bash
kubectl create namespace mtls
```

### Pushing your certificates up

```bash
kubectl create secret generic server-key --from-file=server-key.pem --namespace=mtls
kubectl create secret generic server-cert --from-file=server-cert.pem --namespace=mtls
kubectl create secret generic root-ca --from-file=RootCA-cert.pem --namespace=mtls
```

### Deploying the application

```bash
helm upgrade mtls-app k8s --install --debug --namespace=mtls
```

__OR__

```bash
tilt up
```
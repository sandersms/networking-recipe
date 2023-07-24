# Security Guide for P4 Control Plane

- [1. Overview](#1-overview)
- [2. Certificate management](#2-certificate-management)
   - [2.1 Running in secure mode](#21-running-in-secure-mode)
      - [2.1.1 Requirements for gRPC server](#211-requirements-for-grpc-server)
      - [2.1.2 Requirements for gRPC clients](#212-requirements-for-grpc-clients)
      - [2.1.3 Generate and install TLS certificates](#213-generate-and-install-tls-certificates)
   - [2.2 Running in insecure mode](#22-running-in-insecure-mode)

## 1. Overview

This document provides information about secure and insecure
modes for networking recipe and certificate management.

## 2. Certificate Management

The gRPC ports are secured using TLS certificates. A script and reference
configuration files are available to assist in generating certificates and
keys using OpenSSL. You may use other tools if you wish.

The [reference files](https://github.com/ipdk-io/stratum-dev/tree/split-arch/tools/tls)
uses a simple PKI where a self-signed key and certificate.
The root level Certificate Authority (CA) is used to generate server-side
key and cert files, and client-side key and cert files. This results in a
1-depth level certificate chain, which will suffice for validation and
confirmation but may not provide sufficient security for production systems.
It is highly recommended to use well-known CAs, and generate certificates at
multiple depth levels in order to conform to higher security standards.

### 2.1 Running in secure mode

#### 2.1.1 Requirements for gRPC server

The IPDK Networking Recipe uses a secure-by-default model. If you wish to
open insecure ports, you must do so explicitly. It is strongly recommended
that you use secure ports in production systems.

infrap4d is launched with following gRPC ports secured via TLS certificates.
The port numbers are:

- 9339 - an IANA-registered port for gNMI
- 9559 - an IANA-registered port for P4RT

#### 2.1.2 Requirements for gRPC clients

Under default conditions, the gRPC clients will require the TLS certificates
to establish communication with infrap4d. The clients will need to use the
generated client.key and client.crt files signed by the same CA (can copy
the generated files from the server if client is not on the same system as
server).

- P4RT client

    The P4Runtime Control client will default to communicating in secure mode
using port 9559. If certificates are not available, the P4RT client will attempt
a connection using insecure client credentials as a fallback mechanism.
Note that the communication will fail if infrap4d runs in secure mode. Server
must specify insecure mode for this to work.

- gNMI client

    gnmi-ctl (the gNMI client for DPDK) and sgnmi_cli (the secure gNMI client)
issue requests to port 9339.

#### 2.1.3 Generate and install TLS certificates

See [Install TLS Certificates](https://github.com/ipdk-io/networking-recipe/blob/main/docs/guides/install-tls-certificates.md)
for step by step guide to generate and install TLS certificates

### 2.2 Running in insecure mode

To launch infrap4d in insecure mode:

```bash
$IPDK_RECIPE/install/sbin/infrap4d -grpc_open_insecure_mode=true
```

To launch clients in insecure mode:

For DPDK target:

```bash
$IPDK_RECIPE/install/bin/gnmi-ctl set <COMMAND> \
-grpc_use_insecure_mode=true
```

For Intel IPU E2100 target:

```bash
$IPDK_RECIPE/install/bin/sgnmi_cli set <COMMAND> \
-grpc_use_insecure_mode=true
```
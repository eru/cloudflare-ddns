# Cloudflare DDNS

dynamic-ip-update.sh is works for [Cloudflare] DNS Record Global IP Address update.

- Support cloudflare API v4
- Update A record and AAAA record

## Requirements

- [curl](https://curl.haxx.se/)
- [jq](https://stedolan.github.io/jq/)

## Usage

- `X_AUTH_EMAIL`: Email.
- `X_AUTH_KEY`: API Key.
- `ZONE`: Zone name.
- `DOMAIN`: Domain name.
- `DEVICE`: Ethernet device.

### dynamic-ip-update.sh

```sh
$ X_AUTH_EMAIL="johnappleseed@example.com" \
    X_AUTH_KEY="123abc456def789ghi" \
    ZONE="example.com" \
    DOMAIN="www.example.com" \
    DEVICE="eth0" \
    dynamic-ip-update.sh
```

[Cloudflare]: https://www.cloudflare.com/

#!/usr/bin/env bash
set -euo pipefail

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERT_SOURCE="${SCRIPT_DIR}/config/network/eduroam.pem"
CERT_TARGET="/var/lib/iwd/certs/eduroam-ca.pem"
IWD_DIR="/var/lib/iwd"
PROFILE="${IWD_DIR}/eduroam.8021x"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Bitte als root ausführen (sudo ./connect-eduroam.sh)." >&2
  exit 1
fi

if [[ -f $PROFILE ]]; then
  echo "Die Konfiguration $PROFILE existiert bereits."
  exit 1
fi

if [[ ! -f "${CERT_SOURCE}" && ! -f "${CERT_TARGET}" ]]; then
  echo "Zertifikat fehlt: ${CERT_SOURCE} existiert nicht und ${CERT_TARGET} ebenfalls nicht." >&2
  exit 1
fi

read -rp "Eduroam-Benutzername (z.B. user@uni.de): " EDU_USER
read -rsp "Eduroam-Passwort: " EDU_PASS
echo

mkdir -p "$(dirname "${CERT_TARGET}")" "${IWD_DIR}"

if [[ -f "${CERT_SOURCE}" ]]; then
  mv "${CERT_SOURCE}" "${CERT_TARGET}"
  echo "Zertifikat nach ${CERT_TARGET} verschoben."
else
  echo "Zertifikat bereits unter ${CERT_TARGET} vorhanden, überspringe Verschieben."
fi
chmod 644 "${CERT_TARGET}"

cat >"${PROFILE}" <<EOF
[Security]
EAP-Method=PEAP
EAP-Identity=${EDU_USER}
EAP-PEAP-Phase2-Method=MSCHAPV2
EAP-PEAP-Phase2-Identity=${EDU_USER}
EAP-PEAP-Phase2-Password=${EDU_PASS}
EAP-PEAP-Anon-Identity=eduroam@tu-darmstadt.de
EAP-PEAP-CACert=${CERT_TARGET}
EAP-ServerDomainMask=radius.hrz.tu-darmstadt.de
EOF
chmod 600 "${PROFILE}"

echo "iwd-Konfiguration erstellt: ${PROFILE}"
echo "Starte iwd neu, falls notwendig: systemctl restart iwd"

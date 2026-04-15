# Intermediate Lab 02 - Hybrid Connectivity Troubleshooting

## Time Estimate
- 75 to 105 minutes

## Scenario
Users in a branch network cannot consistently reach workloads in a spoke subnet. Some connections succeed, but packet loss and timeout events occur during peak periods.

Investigate potential causes across:
- VPN gateway/BGP route propagation,
- route table and next-hop design,
- NSG rules on spoke subnet,
- DNS resolution path for target services.

## Variables

```bash
SUB_ID="<subscription-id>"
RG_NAME="rg-az104-network-dev-eastus2-01"
CONNECTION_NAME="conn-branch-to-hub"
GW_NAME="vpngw-az104-hub-dev-01"
```

## Step 1 - Gather current-state evidence

```bash
az account set --subscription "$SUB_ID"
az network vpn-connection show -g "$RG_NAME" -n "$CONNECTION_NAME" -o json > evidence-vpn-connection.json
az network vnet-gateway show -g "$RG_NAME" -n "$GW_NAME" -o json > evidence-vpngw.json
az network route-table list -g "$RG_NAME" -o json > evidence-route-tables.json
az network nsg list -g "$RG_NAME" -o json > evidence-nsgs.json
```

## Step 2 - Validate data path

1. Run connection troubleshooting from source to spoke endpoint.
2. Record latency and failure points.

```bash
az network watcher test-connectivity \
  --source-resource "<source-resource-id>" \
  --dest-address "<spoke-workload-ip-or-fqdn>" \
  --dest-port 443 \
  --output json > evidence-connectivity-before.json
```

## Step 3 - Implement minimum fix

Apply the least invasive correction, such as:
- add missing return route,
- adjust NSG allow rule for approved branch CIDR,
- repair BGP propagation setting on route table.

Example route-table update:

```bash
az network route-table route create \
  --resource-group "$RG_NAME" \
  --route-table-name "rt-spoke-app" \
  --name "branch-return" \
  --address-prefix "10.50.0.0/16" \
  --next-hop-type VirtualNetworkGateway
```

## Step 4 - Re-test and document

Produce:
- `evidence-connectivity-after.json`
- `root-cause-summary.md`
- `rollback-plan.md`
- `network-change-log.md`

## Acceptance Criteria
- Evidence proves cause and fix.
- Fix preserves least privilege and controlled routing.
- Rollback is complete and executable.
- Reviewer can reproduce the troubleshooting sequence.


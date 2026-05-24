# Ecommerce Profile

Use this profile for sellers, operators, marketplace teams, and ecommerce growth work.

Default capture types:

- `signal`: customer objections, buying friction, demand hints
- `research`: competitor, market, or product research
- `learning`: ad, listing, pricing, and merchandising lessons
- `decision`: product, channel, pricing, and launch decisions
- `workflow`: repeatable operating processes

Suggested tags:

- `ecommerce`
- `amazon`
- `customer-signal`
- `ads`
- `listing`
- `pricing`
- `product-research`
- `competitor`

Workshop test capture:

```bash
~/.everlearn/bin/everlearn capture \
  --type signal \
  --title "Customer asked for a cheaper bundle" \
  "A shopper wanted a lower-priced starter bundle before buying the full kit."
```

Nested SignalSweep research:

```bash
~/.everlearn/bin/everlearn signalsweep \
  --topic "Amazon review complaints for starter bundles" \
  -- --quick
```

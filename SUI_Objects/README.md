Publishing on chain

```bash
sui client publish --path SUI_Objects/sui_objects --gas-budget 10000
```

Create Object

```bash
sui client call --gas-budget 1000 --package $PACKAGE --module "object_2" --function "create" --args 0 255 0
```

Calling Transfer

```bash
sui client call --gas-budget 1000 --package $PACKAGE --module "object_2" --function "transfer" --args \"$OBJECT\" \"$RECIPIENT\
```

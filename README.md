## bootstrap-pkgsrc

This is a GitHub action to generate a pkgsrc bootstrap kit.

### Usage

```yaml
jobs:
  bootstrap:
    runs-on: ubuntu-latest
    inputs:
      platform: ubuntu-x86_64
    steps:
      - uses: actions/checkout@v4
      - name: Bootstrap
        uses: pkgsrc-ci/bootstrap-pkgsrc@v1
```

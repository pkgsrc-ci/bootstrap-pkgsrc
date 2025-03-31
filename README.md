## bootstrap-pkgsrc

This is a GitHub action to generate a pkgsrc bootstrap kit.

### Usage

Perform a bootstrap using all defaults, with
[https://github.com/marketplace/actions/cache](cache actions) handling
restore-or-save for the generated bootstrap.tar.

```yaml
jobs:
  bootstrap:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/cache@v4
        id: check-cache
        with:
          key: bootstrap-kit
          path: bootstrap.tar
      - uses: actions/checkout@v4
        if: steps.check-cache.outputs.cache-hit != 'true'
      - name: Bootstrap
        if: steps.check-cache.outputs.cache-hit != 'true'
        uses: pkgsrc-ci/bootstrap-pkgsrc@v1
```

Perform an unprivileged build.  This will use the bootstrap default prefix of
`${HOME}/pkg`:

```yaml
      - name: Bootstrap
        if: steps.check-cache.outputs.cache-hit != 'true'
        uses: pkgsrc-ci/bootstrap-pkgsrc@v1
        with:
          unprivileged: true
```

Apply some customisation.

```yaml
      - name: Add some extra variables
        shell: bash
        run: |
          cat >${GITHUB_WORKSPACE}/add-extra.mk <<-EOF
            PKG_DEFAULT_OPTIONS=-doc
          EOF
      - name: Bootstrap
        if: steps.check-cache.outputs.cache-hit != 'true'
        uses: pkgsrc-ci/bootstrap-pkgsrc@v1
        with:
          bootstrap_args: "--prefer-pkgsrc=yes --prefix=/opt/pkg"
          bootstrap_env: "CFLAGS=-O3"
```

### Input Variables

* `bootstrap_args`: Additional arguments for the `bootstrap` script.

* `bootstrap_env`: Additional environment variables to set.

* `make_jobs`: How many parallel threads to use.

* `path`: `$PATH` to set for bootstrap.

* `unprivileged`: Boolean to indicate whether unprivileged mode should be enabled.

If `unprivileged` is `false` (the default), then bootstrap is executed using
`sudo` so that the default prefix of `/usr/pkg` can be written to.

In addition, if there is an `add-extra.mk` file found in `${GITHUB_WORKSPACE}`
(i.e. the default working directory), then its contents are appended to the
default `mk.conf` created in the bootstrap kit.

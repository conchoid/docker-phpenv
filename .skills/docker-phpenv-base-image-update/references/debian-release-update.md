# Dockerfile base image update reference

Repository: `docker-phpenv`

## Standard pattern

- Copy the previous Debian variant into a new target directory if needed.
- Change the base image from `php:<patch>-cli-bookworm` to an available `php:<version>-cli-trixie` tag.
- Build from the repository root with the target Dockerfile.

## Example from the original procedure

- Source Dockerfile: `8.3-bookworm/Dockerfile`
- Target Dockerfile: `8.3-trixie/Dockerfile`
- Example image tag: `conchoid/docker-phpenv:v1.0.0-1-8.3.29-trixie`

```bash
cd docker-phpenv
docker build -t conchoid/docker-phpenv:v1.0.0-1-8.3.29-trixie -f 8.3-trixie/Dockerfile .
```

## Checklist

- Confirm the target PHP Docker tag exists for the new Debian suite.
- Preserve required `apt-get` libraries unless incompatibility is confirmed.
- Add missing build dependencies required by newer PHP build lines when necessary.
- Verify `phpenv` and `php-build` still function.
- Verify the intended PHP versions install correctly.
- Verify `Composer` works.
- Verify `docker-php-ext-install` steps such as `bz2` and `xml` still work.
- Verify the OpenSSL build still works when legacy OpenSSL is part of the image.
- Verify locale-related behavior.
- Verify a real PHP project can install dependencies, build, and run.

## Cautions

- Debian release changes can affect package names and versions.
- Official PHP image tags do not always expose the same patch-level naming across suites.
- Legacy OpenSSL builds can break on newer Debian releases and may require targeted build-option changes.

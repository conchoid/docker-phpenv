---
name: docker-phpenv-base-image-update
description: Updates Dockerfiles in the docker-phpenv repository for a new Debian base image release by switching the php:<version>-cli-<suite> base image, preserving required apt packages, accounting for floating PHP image tags when exact patch tags are unavailable, and validating phpenv/php-build/Composer/OpenSSL behavior. Use when asked to move docker-phpenv to a new Debian release such as trixie.
---

# docker-phpenv-base-image-update

Use this skill when updating `docker-phpenv` to a new Debian release.

## Workflow

1. Identify the source Dockerfile and target directory.
   Example: `8.3-bookworm/Dockerfile` -> `8.3-trixie/Dockerfile`.
2. If the target directory does not exist, create it and copy the previous Dockerfile into it.
3. Update the first `FROM` image from `php:<patch>-cli-<old-suite>` to an available `php:<version>-cli-<new-suite>` tag.
4. If the exact patch tag for the new Debian suite does not exist, use the maintained minor-line tag for that suite instead.
   Example: `php:8.3-cli-trixie`.
5. Keep the installed `apt-get` packages unless a compatibility issue is confirmed. Do not silently remove required libraries.
6. Add or adjust build dependencies only when the new Debian release requires them.
   Example: `libicu-dev` may be required for PHP 8.1+ builds.
7. Build the image locally.
   ```bash
   cd docker-phpenv
   docker build -t conchoid/docker-phpenv:<target-tag> -f <target-dir>/Dockerfile .
   ```
8. Validate compatibility:
   - confirm all `apt-get` packages still resolve
   - confirm `phpenv` works
   - confirm `php-build` works
   - confirm each intended PHP version installs correctly
   - confirm `Composer` works
   - confirm `docker-php-ext-install` steps still succeed
   - confirm the OpenSSL build still works if the Dockerfile builds a legacy OpenSSL
   - confirm locale settings still work
9. If the repository has project-level or sample builds, run them with the new image and verify dependency installation, build success, runtime behavior, and `phpenv` version switching.

## Notes

- Official PHP Docker tags vary by suite. Always confirm the target tag exists before pinning it.
- If a preinstalled PHP line is EOL or intentionally removed, document that explicitly in the final response instead of silently dropping it.
- Read [references/debian-release-update.md](references/debian-release-update.md) for the repo-specific checklist and example constraints.

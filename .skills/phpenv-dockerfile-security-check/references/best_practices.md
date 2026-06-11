# Dockerfile Security Best Practices

## 1. Run as a Non-Root User
By default, Docker containers run as root. This is a security risk. Always create a user and switch to it.

```dockerfile
RUN groupadd -r phpenv && useradd -r -g phpenv phpenv
USER phpenv
```

## 2. Use Specific Base Image Tags
Avoid `latest`. Use specific version tags to ensure reproducible and secure builds.

```dockerfile
# Good
FROM debian:trixie-20240513-slim
# Avoid
FROM debian:trixie-slim
```

## 3. Minimize Image Size and Attack Surface
Use `--no-install-recommends` with `apt-get install` and clean up caches in the same `RUN` layer.

```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
    package-name \
    && rm -rf /var/lib/apt/lists/*
```

## 4. Avoid Hardcoding Secrets
Never use `ENV` or `ARG` for secrets. Use Docker secrets or environment variables at runtime.

## 5. Use Multi-Stage Builds
Separate build dependencies from the final runtime image.

```dockerfile
FROM debian:trixie-slim AS build
# install build tools...

FROM debian:trixie-slim
COPY --from=build /app/bin /app/bin
```

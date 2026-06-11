---
name: phpenv-dockerfile-security-check
description: Analyzes Dockerfiles in the docker-phpenv repository for security vulnerabilities and provides improvement recommendations. Use when creating or modifying Dockerfiles to ensure they follow best practices like running as non-root, using specific tags, and optimizing package management.
options:
  --push: Push the built image to ECR and fetch official scan findings after local Trivy and Docker Scout review.
---

# phpenv-dockerfile-security-check

This skill helps ensure that Dockerfiles in the docker-phpenv repository are secure and optimized.

## Triggers
- When the user asks to "check security" of a Dockerfile.
- When a new Dockerfile is created or an existing one is modified.
- When specifically asked to improve Dockerfile security.

## Workflow

0.  **Announce Push Destination and Cancel Point**: At the very start of the skill, tell the user the exact ECR repository that will be used for `--push` and pause for confirmation so the user can cancel if the destination is wrong.
    ```text
    ECR push target: 520300048555.dkr.ecr.us-west-2.amazonaws.com/codelift-plugins/tools/docker-phpenv
    ```

1.  **Prepare Branch**: Create a new branch with the `-sec1` suffix to isolate security changes.
    ```bash
    git checkout -b $(git rev-parse --abbrev-ref HEAD)-sec1
    ```

### 1. Local Security Validation (Default)

2.  **Analyze**: Run the `check_security.cjs` script against the target Dockerfile to identify immediate issues.
    ```bash
    node scripts/check_security.cjs <path-to-dockerfile>
    ```
3.  **Consult Best Practices**: Refer to `references/best_practices.md` for the rationale and recommended code patterns for each finding.
4.  **Propose Changes**: Present the findings to the user and propose specific code changes to the Dockerfile.
5.  **Implement**: Once approved, apply the changes to the Dockerfile.
6.  **Build and Verify**: Build the Docker image locally. (Note: Use the 'Suggested Tag' provided by the Analyze step if available)
    ```bash
    docker build --provenance=false -t <tag-name>-sec1 <context-dir>
    ```
7.  **Create Findings Directory**: Store all scan outputs under `./.sec/` and keep tool-specific findings separate.
    ```bash
    mkdir -p ./.sec
    ```
8.  **Local Scan (Trivy)**: Run Trivy after each build and save the findings with the tool name in the file.
    ```bash
    trivy image --severity HIGH,CRITICAL --format json -o ./.sec/findings.trivy.json <tag-name>-sec1
    ```
9.  **Local Scan (Docker Scout)**: Run Docker Scout against the same image and save the findings with the tool name in the file.
    ```bash
    docker scout cves --only-severity critical,high --format sarif --output ./.sec/findings.docker-scout.sarif <tag-name>-sec1
    ```
10. **Summarize Findings by Tool**: Report findings grouped under the tool names `Trivy` and `Docker Scout`. Each summary must include HIGH and CRITICAL counts and the packages or layers that still require changes.
11. **Patch and Repeat**: Apply a patch to the Dockerfile and rebuild whenever either tool reports HIGH or CRITICAL findings that can be reduced. Repeat the cycle:
    `Build -> Trivy -> Docker Scout -> Summarize -> Patch`
12. **Exit Condition for Local Fix Loop**: Continue until both tools report `CRITICAL=0` and `HIGH=0`. If that is not possible, stop the loop, report what remains, why it remains, and what was already tried.

### 2. Remote Validation and Delivery (with --push)

If the `--push` option is provided, proceed with the following steps after local validation. Push is allowed in either of these cases:
- both local tools reached `CRITICAL=0` and `HIGH=0`
- the counts could not be reduced to zero and the remaining findings were reported to the user first

1.  **Tag for ECR**: Add a specific tag for the project's ECR repository.
    ```bash
    docker tag <local-tag>-sec1 520300048555.dkr.ecr.us-west-2.amazonaws.com/codelift-plugins/tools/docker-phpenv:<suggested-tag>-sec1
    ```
2.  **Push to ECR**: Push the secured image to the remote repository.
    ```bash
    docker push 520300048555.dkr.ecr.us-west-2.amazonaws.com/codelift-plugins/tools/docker-phpenv:<suggested-tag>-sec1
    ```
3.  **Fetch Scan Findings**: Retrieve vulnerability scan results from ECR. Wait for the scan to complete before fetching and save them as a separate findings file.
    ```bash
    aws ecr wait image-scan-complete --profile Masato.Oikawa --region us-west-2 --repository-name codelift-plugins/tools/docker-phpenv --image-id imageTag=<suggested-tag>-sec1 && \
    aws ecr describe-image-scan-findings --profile Masato.Oikawa --region us-west-2 --repository-name codelift-plugins/tools/docker-phpenv --image-id imageTag=<suggested-tag>-sec1 > ./.sec/findings.ecr.json
    ```
4.  **Final Report**: Present local findings from `Trivy` and `Docker Scout`, then ECR findings separately. If local scans could not reach zero, explicitly state that the push occurred with known remaining findings.

## Key Security Areas
- **Non-Root Execution**: Ensure the `USER` instruction is used.
- **Image Pinning**: Use specific tags instead of `latest`.
- **Package Optimization**: Use `--no-install-recommends` and clean up `/var/lib/apt/lists/*`.
- **Layer Optimization**: Combine `RUN` commands where appropriate to reduce image size.

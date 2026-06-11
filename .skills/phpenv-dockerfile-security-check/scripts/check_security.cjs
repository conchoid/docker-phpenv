const fs = require('fs');
const path = require('path');

function checkSecurity(dockerfilePath) {
    const content = fs.readFileSync(dockerfilePath, 'utf8');
    const lines = content.split('\n');
    const findings = [];

    // 1. Check for USER instruction
    if (!content.includes('USER ')) {
        findings.push('- Missing USER instruction: Container runs as root by default.');
    }

    // 2. Check for apt-get install without --no-install-recommends
    const aptInstallLines = lines.filter(line => line.includes('apt-get install'));
    aptInstallLines.forEach(line => {
        if (!line.includes('--no-install-recommends')) {
            findings.push(`- apt-get install usage: Missing --no-install-recommends flag in: ${line.trim()}`);
        }
    });

    // 3. Check for cleanup after apt-get
    // Check if each RUN command that uses apt-get install also does cleanup
    let currentRunCommand = '';
    let inRun = false;
    for (let i = 0; i < lines.length; i++) {
        let line = lines[i].trim();
        if (line.startsWith('RUN ')) {
            currentRunCommand = line;
            inRun = true;
        } else if (inRun && line.endsWith('\\')) {
            currentRunCommand += ' ' + line;
        } else if (inRun) {
            currentRunCommand += ' ' + line;
            if (currentRunCommand.includes('apt-get install')) {
                if (!currentRunCommand.includes('rm -rf /var/lib/apt/lists/*') && !currentRunCommand.includes('apt-get clean')) {
                    findings.push(`- apt-get install usage: Missing cleanup (rm -rf /var/lib/apt/lists/* or apt-get clean) in RUN command: ${currentRunCommand.substring(0, 100)}...`);
                }
            }
            inRun = false;
            currentRunCommand = '';
        }
    }

    // 4. Check for latest tag in all FROM lines
    const fromLines = lines.filter(line => line.startsWith('FROM '));
    fromLines.forEach(line => {
        const parts = line.split(/\s+/);
        const image = parts[1];
        if (image && (image.endsWith(':latest') || (!image.includes(':') && !image.includes('@')))) {
            findings.push(`- Base image tag: Using 'latest' or untagged image (${line}).`);
        }
    });

    // 5. Check for insecure apt flags
    if (content.includes('--allow-unauthenticated')) {
        findings.push('- Security Risk: Use of --allow-unauthenticated flag detected.');
    }
    if (content.includes('[trusted=yes]')) {
        findings.push('- Security Risk: Use of [trusted=yes] in apt sources detected.');
    }
    if (content.includes('Acquire::AllowInsecureRepositories=true')) {
        findings.push('- Security Risk: AllowInsecureRepositories=true detected.');
    }

    // 6. Extract tag from comment
    const tagComment = lines.find(line => line.startsWith('# Docker Hub:'));
    let suggestedTag = '';
    if (tagComment) {
        const match = tagComment.match(/# Docker Hub:\s+\S+:(.+)/);
        if (match) {
            suggestedTag = match[1];
        }
    }

    return { findings, suggestedTag };
}

const target = process.argv[2];
if (!target) {
    console.error('Usage: node check_security.cjs <path-to-dockerfile>');
    process.exit(1);
}

try {
    const { findings, suggestedTag } = checkSecurity(target);
    if (findings.length === 0) {
        console.log('✅ No obvious security issues found.');
    } else {
        console.log('❌ Found potential security issues:');
        findings.forEach(f => console.log(f));
    }
    if (suggestedTag) {
        console.log(`\n💡 Suggested Tag (from comment): ${suggestedTag}`);
    }
} catch (err) {
    console.error(`Error reading file: ${err.message}`);
    process.exit(1);
}

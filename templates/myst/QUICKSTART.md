# Quick Start Guide

Get started with myst.sh in 5 minutes!

## Installation

```bash
# Using hammer.sh
./hammer.sh myst my-templates
cd my-templates
./setup.sh

# Manual installation
git clone https://github.com/yourorg/myst.sh.git
cd myst.sh
chmod +x myst.sh
```

## Your First Template

Create `hello.myst`:

```mustache
Hello, {{name}}!
Welcome to {{app}}.
```

Render it:

```bash
./myst.sh render hello.myst -v name=Alice -v app="myst.sh"
```

Output:
```
Hello, Alice!
Welcome to myst.sh.
```

## Common Patterns

### 1. Configuration File Generator

Template `nginx.conf.myst`:

```mustache
server {
    listen {{port}};
    server_name {{domain}};
    
    location / {
        proxy_pass {{backend_url}};
    }
}
```

Data `config.json`:

```json
{
  "port": "80",
  "domain": "example.com",
  "backend_url": "http://localhost:3000"
}
```

Generate:

```bash
./myst.sh render nginx.conf.myst -j config.json -o /etc/nginx/sites-available/mysite
```

### 2. Email Template

Template `welcome-email.myst`:

```mustache
Subject: Welcome to {{company}}, {{user_name}}!

Hi {{user_name}},

{{#if trial_user}}
Welcome to your 14-day free trial!
{{/if}}

{{#unless trial_user}}
Thank you for your purchase!
{{/unless}}

Get started: {{app_url}}

Best regards,
The {{company}} Team
```

Render:

```bash
./myst.sh render welcome-email.myst \
  -v user_name="Alice" \
  -v company="Acme Corp" \
  -v trial_user=true \
  -v app_url="https://app.example.com"
```

### 3. Static Site Generation

Directory structure:

```
site/
  ├── layouts/
  │   └── base.myst
  ├── partials/
  │   ├── _nav.myst
  │   └── _footer.myst
  ├── pages/
  │   ├── index.myst
  │   └── about.myst
  └── data.json
```

Build script:

```bash
#!/usr/bin/env bash

for page in pages/*.myst; do
  name=$(basename "$page" .myst)
  ./myst.sh render "$page" \
    -l layouts/base.myst \
    -p partials \
    -j data.json \
    -o "dist/${name}.html"
  echo "Generated: dist/${name}.html"
done
```

### 4. Docker Compose Generator

Template `docker-compose.yml.myst`:

```mustache
version: '3.8'

services:
{{#each services}}
  {{this}}:
    image: {{this}}:latest
    ports:
      - "{{port}}:{{port}}"
{{/each}}
```

Generate:

```bash
./myst.sh render docker-compose.yml.myst \
  -v services="web,api,db" \
  -v port="8080" \
  -o docker-compose.yml
```

### 5. CI/CD Pipeline

Template `.gitlab-ci.yml.myst`:

```mustache
stages:
  - build
  - test
  - deploy

variables:
  APP_NAME: {{app_name}}
  VERSION: {{version}}

build:
  stage: build
  script:
    - docker build -t $APP_NAME:$VERSION .

{{#if run_tests}}
test:
  stage: test
  script:
    - npm test
{{/if}}

deploy:
  stage: deploy
  script:
    - kubectl set image deployment/$APP_NAME $APP_NAME=$APP_NAME:$VERSION
  only:
    - main
```

## Data Sources

### JSON

```bash
./myst.sh render template.myst -j data.json
```

### YAML

```bash
./myst.sh render template.myst -y config.yml
```

### Environment

```bash
export MYST_DATABASE_URL=postgres://localhost/db
export MYST_API_KEY=secret123
./myst.sh render template.myst -e
```

### Multiple Sources

```bash
./myst.sh render template.myst \
  -j defaults.json \
  -y overrides.yml \
  -e \
  -v final_override=value
```

## Embedding in Scripts

```bash
#!/usr/bin/env bash

source ./myst.sh

# Programmatic usage
myst_set_var "deploy_env" "production"
myst_load_json "config.json"

template=$(cat deployment.myst)
rendered=$(myst_render "$template")

echo "$rendered" | kubectl apply -f -
```

## Tips & Tricks

### Pipe to Tools

```bash
# Generate and apply Kubernetes manifest
./myst.sh render k8s-deployment.myst -j vars.json | kubectl apply -f -

# Generate and send email
./myst.sh render email.myst -j user.json | sendmail user@example.com

# Generate and upload
./myst.sh render config.myst -e | aws s3 cp - s3://bucket/config.json
```

### Use with Make

```makefile
.PHONY: build

build: dist/index.html dist/about.html

dist/%.html: pages/%.myst data.json
	./myst.sh render $< -j data.json -o $@
```

### Template Directory

```bash
# Organize templates
templates/
  ├── emails/
  ├── configs/
  └── docs/

# Render from directory
./myst.sh render -d templates/emails welcome.myst -j user.json
```

## Next Steps

- Read the full [README.md](README.md)
- Check [DSL_DOCUMENTATION.md](DSL_DOCUMENTATION.md) for syntax
- Browse [examples/](examples/) directory
- See [API_REFERENCE.md](API_REFERENCE.md) for embedding

## Common Issues

### `jq: command not found`

```bash
# Install jq
sudo apt-get install jq  # Debian/Ubuntu
brew install jq          # macOS
```

### `yq: command not found`

```bash
# Install yq (for YAML support)
brew install yq
# or
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
  -O /usr/bin/yq && sudo chmod +x /usr/bin/yq
```

### Variables not rendering

Check that:
1. Variable names match exactly (case-sensitive)
2. Variables are set before rendering
3. Template syntax is correct: `{{variable}}` not `{{ variable }}`

### Debug mode

```bash
MYST_DEBUG=1 ./myst.sh render template.myst -v var=value
```

## Get Help

```bash
./myst.sh --help
./myst.sh render --help
```

Happy templating! 🎨

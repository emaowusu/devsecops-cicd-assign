Your prompt cuts off at “and…”, but I’ll assume the full task is:

> Build a basic CI/CD pipeline (GitHub Actions or similar) that runs tests, builds a Docker image, deploys to a staging environment, and documents one intentionally introduced security vulnerability.

I’ll give you a complete step-by-step project you can actually implement.

---

# 1. Project Overview (What you are building)

You will create:

* A simple app (example: Node.js or Python API)

* Automated tests

* A Docker image for the app

* A GitHub Actions CI/CD pipeline that:

  1. Runs tests
  2. Builds Docker image
  3. Pushes image to registry (Docker Hub or GHCR)
  4. Deploys to a staging server (VM or cloud instance)

* One intentional security vulnerability (for learning/documentation)

---

# 2. Prerequisites

Install / create:

* GitHub account
* Git
* Docker Desktop
* Node.js or Python (I’ll use Node.js example below)
* A staging server (options):

  * AWS EC2
  * DigitalOcean droplet
  * Any Linux VPS
* Docker installed on staging server

---

# 3. Step 1 — Create Simple App

## 3.1 Initialize project

```bash
mkdir ci-cd-demo
cd ci-cd-demo
npm init -y
```

## 3.2 Install dependencies

```bash
npm install express
npm install --save-dev jest supertest
```

---

## 3.3 Create app (`app.js`)

```javascript
const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.send("Hello CI/CD Pipeline!");
});

// INTENTIONALLY VULNERABLE ENDPOINT (we will document later)
app.get("/debug", (req, res) => {
  res.json({
    env: process.env,
    message: "Debug mode enabled"
  });
});

module.exports = app;
```

---

## 3.4 Server file (`server.js`)

```javascript
const app = require("./app");

app.listen(3000, () => {
  console.log("Server running on port 3000");
});
```

---

# 4. Step 2 — Add Tests

Create folder:

```bash
mkdir tests
```

## 4.1 Test file (`tests/app.test.js`)

```javascript
const request = require("supertest");
const app = require("../app");

describe("GET /", () => {
  it("should return hello message", async () => {
    const res = await request(app).get("/");
    expect(res.statusCode).toBe(200);
    expect(res.text).toContain("Hello CI/CD");
  });
});
```

---

## 4.2 Add test script in `package.json`

```json
"scripts": {
  "start": "node server.js",
  "test": "jest"
}
```

---

# 5. Step 3 — Create Dockerfile

Create `Dockerfile`:

```dockerfile
FROM node:18

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

---

## 5.1 Test Docker locally

```bash
docker build -t ci-cd-demo .
docker run -p 3000:3000 ci-cd-demo
```

---

# 6. Step 4 — Create GitHub Repository

```bash
git init
git add .
git commit -m "initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/ci-cd-demo.git
git push -u origin main
```

---

# 7. Step 5 — Create GitHub Actions Pipeline

Create folder:

```bash
mkdir -p .github/workflows
```

---

## 7.1 CI/CD workflow file

Create:

`.github/workflows/deploy.yml`

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ "main" ]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: 18

      - name: Install dependencies
        run: npm install

      - name: Run tests
        run: npm test

  build-and-push:
    needs: test
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Log in to Docker Hub
        run: echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin

      - name: Build Docker image
        run: docker build -t YOUR_DOCKERHUB_USERNAME/ci-cd-demo:latest .

      - name: Push Docker image
        run: docker push YOUR_DOCKERHUB_USERNAME/ci-cd-demo:latest

  deploy:
    needs: build-and-push
    runs-on: ubuntu-latest

    steps:
      - name: Deploy to staging server via SSH
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.STAGING_HOST }}
          username: ${{ secrets.STAGING_USER }}
          key: ${{ secrets.STAGING_SSH_KEY }}
          script: |
            docker pull YOUR_DOCKERHUB_USERNAME/ci-cd-demo:latest
            docker stop ci-cd-demo || true
            docker rm ci-cd-demo || true
            docker run -d -p 80:3000 --name ci-cd-demo YOUR_DOCKERHUB_USERNAME/ci-cd-demo:latest
```

---

# 8. Step 6 — Add GitHub Secrets

Go to:

**GitHub Repo → Settings → Secrets and variables → Actions**

Add:

* `DOCKER_USERNAME`
* `DOCKER_PASSWORD`
* `STAGING_HOST` (your server IP)
* `STAGING_USER` (e.g. ubuntu)
* `STAGING_SSH_KEY` (private key)

---

# 9. Step 7 — Setup Staging Server

On your Linux server:

```bash
sudo apt update
sudo apt install docker.io -y
sudo systemctl enable docker
```

Allow port 80:

```bash
sudo ufw allow 80
```

---

# 10. Step 8 — Run Pipeline

Now:

```bash
git add .
git commit -m "add ci cd pipeline"
git push
```

GitHub Actions will:

1. Run tests
2. Build Docker image
3. Push image
4. Deploy to staging server

---

# 11. Step 9 — Security Vulnerability (Required Documentation)

## Vulnerability introduced: Exposed environment variables endpoint

### Location:

```javascript
app.get("/debug", (req, res) => {
  res.json({
    env: process.env
  });
});
```

---

## Why this is a vulnerability

This endpoint:

* Exposes sensitive environment variables
* May leak:

  * API keys
  * Database passwords
  * Secret tokens
* Can be accessed publicly without authentication

---

## Impact

An attacker could:

* Steal credentials
* Access production systems
* Compromise deployment pipelines

---

## Severity

High (Information Disclosure vulnerability)

---

## Fix

Remove endpoint OR protect it:

```javascript
const auth = (req, res, next) => {
  if (req.headers["x-api-key"] !== process.env.ADMIN_KEY) {
    return res.status(403).send("Forbidden");
  }
  next();
};

app.get("/debug", auth, (req, res) => {
  res.json({ env: process.env });
});
```

---

# 12. Final Deliverables Checklist

You now have:

✔ App with tests
✔ Docker container
✔ GitHub Actions CI/CD pipeline
✔ Automated deployment to staging
✔ Documented security vulnerability
✔ Fix recommendation


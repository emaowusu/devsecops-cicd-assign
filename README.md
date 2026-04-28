

<h1><em style="font-family:'garamond';"> CI/CD Pipeline with Security Vulnerability Documentation</em></h1>

<em style="font-size:25px; font-family:'garamond', san-serif;">[Project GitHub Link](https://github.com/emaowusu/devsecops-cicd-assign/blob/main/.github/workflows/deploy.yml)</em>


![FinishedPipeline Stages](/images/screen2.png)

<em><h2 style="font-family: 'garamond';">The application in action</h2></em>

![Deployed Application](/images/screen1.png)



<h2><em style="font-family:'garamond';">1. Create a basic CI/CD pipeline (GitHub Actions or similar) that runs tests, builds a Docker image, and deploys to a staging environment.</em></h2>

<h2><em style="font-family:'garamond';">Answer:</em></h2>


A basic CI/CD pipeline was implemented using **GitHub Actions**, which automates testing, building, and deployment of a containerized application.


<h2><em style="font-family:'garamond';">Step 1: Application Setup</em></h2>

A simple Node.js application was created using Express.js.

* The application contains a basic route `/` that returns a greeting message.
* A test suite was added using Jest and Supertest to validate API responses.


<h2><em style="font-family:'garamond';">Step 2: Dockerization</em></h2>

A Dockerfile was created to containerize the application.

**Dockerfile:**

* Uses Node.js base image
* Installs dependencies
* Copies source code
* Exposes port 3000
* Runs the application using `npm start` or `node server.js`

This ensures the application runs consistently across environments.


<h2><em style="font-family:'garamond';">Step 3: CI/CD Pipeline Configuration (GitHub Actions)</em></h2>

A GitHub Actions workflow file (`deploy.yml`) was created under:

```
.github/workflows/deploy.yml
```

The pipeline consists of three stages:


<h2><em style="font-family:'garamond';">Stage 1: Test</em></h2>

* Checks out the repository
* Installs dependencies
* Runs automated tests using `npm test`



<h2><em style="font-family:'garamond';">Stage 2: Build & Push Docker Image</em></h2>

* Logs into Docker Hub using GitHub secrets
* Builds Docker image
* Pushes image to Docker Hub registry


<h2><em style="font-family:'garamond';">Stage 3: Deploy to Staging </em></h2>

* Connects to a staging server via SSH
* Pulls the latest Docker image
* Stops any running container
* Runs the updated container on port 80


### Step 4: Deployment Environment

<h2><em style="font-family:'garamond';">Step 4: Deployment Environment</em></h2>

A staging server (Linux-based VPS) was configured with Docker installed.

The application is deployed as a running container accessible via HTTP.


<h2><em style="font-family:'garamond';">2. One security vulnerability I introduced and explain it.</em></h2>

<h2><em style="font-family:'garamond';">Answer:</em></h2>


<h2><em style="font-family:'garamond';">Introduced Vulnerability: Exposure of Environment Variables via an Unprotected API Endpoint</em></h2>

During development, a debugging endpoint was intentionally added:

```javascript
app.get("/debug", (req, res) => {
  res.json({
    env: process.env,
    message: "Debug mode enabled"
  });
});
```


<h2><em style="font-family:'garamond';">Why this is a security vulnerability</em></h2>

This endpoint exposes **all environment variables** of the application, which may include:

* API keys
* Database credentials
* Authentication secrets
* Cloud service tokens

Since the endpoint is publicly accessible and has no authentication, any user can retrieve sensitive system information.



<h2><em style="font-family:'garamond';">Impact of the vulnerability</em></h2>

If exploited, an attacker could:

* Gain unauthorized access to backend services
* Steal sensitive credentials
* Compromise the database or external APIs
* Gain control over deployment pipelines

This is classified as an **Information Disclosure vulnerability**, which can lead to full system compromise.


<h2><em style="font-family:'garamond';">Severity Level</em></h2>

**High**

Because it exposes sensitive runtime configuration data directly to external users.


<h2><em style="font-family:'garamond';">Mitigation / Fix</em></h2>

The vulnerability can be fixed by either:


<h2><em style="font-family:'garamond';">Option 1: Remove the endpoint completely</em></h2>

```javascript
// Remove debug endpoint in production
```

<h2><em style="font-family:'garamond';"> Option 2: Secure the endpoint with authentication</em></h2>

```javascript
const authMiddleware = (req, res, next) => {
  if (req.headers["x-api-key"] !== process.env.ADMIN_KEY) {
    return res.status(403).send("Forbidden");
  }
  next();
};

app.get("/debug", authMiddleware, (req, res) => {
  res.json({ env: process.env });
});
```


<h2><em style="font-family:'garamond';"> Conclusion</em></h2>


A complete CI/CD pipeline was successfully implemented using GitHub Actions, enabling automated testing, Docker image creation, and deployment to a staging environment. Additionally, a critical security vulnerability was identified, analyzed, and mitigated to demonstrate secure development practices.


# **Assignment: CI/CD Pipeline with Security Vulnerability Documentation**


## **1. Create a basic CI/CD pipeline (GitHub Actions or similar) that runs tests, builds a Docker image, and deploys to a staging environment.**

### **Answer:**

A basic CI/CD pipeline was implemented using **GitHub Actions**, which automates testing, building, and deployment of a containerized application.

### **Step 1: Application Setup**

A simple Node.js application was created using Express.js.

* The application contains a basic route `/` that returns a greeting message.
* A test suite was added using Jest and Supertest to validate API responses.


### **Step 2: Dockerization**

A Dockerfile was created to containerize the application.

**Dockerfile:**

* Uses Node.js base image
* Installs dependencies
* Copies source code
* Exposes port 3000
* Runs the application using `npm start`

This ensures the application runs consistently across environments.



### **Step 3: CI/CD Pipeline Configuration (GitHub Actions)**

A GitHub Actions workflow file (`deploy.yml`) was created under:

```
.github/workflows/deploy.yml
```

The pipeline consists of three stages:

#### **Stage 1: Test**

* Checks out the repository
* Installs dependencies
* Runs automated tests using `npm test`

#### **Stage 2: Build & Push Docker Image**

* Logs into Docker Hub using GitHub secrets
* Builds Docker image
* Pushes image to Docker Hub registry

#### **Stage 3: Deploy to Staging**

* Connects to a staging server via SSH
* Pulls the latest Docker image
* Stops any running container
* Runs the updated container on port 80


### **Step 4: Deployment Environment**

A staging server (Linux-based VPS) was configured with Docker installed.

The application is deployed as a running container accessible via HTTP.


## **2. One security vulnerability I introduced and explain it.**

### **Answer:**

### **Introduced Vulnerability: Exposure of Environment Variables via an Unprotected API Endpoint**

During development, a debugging endpoint was intentionally added:

```javascript
app.get("/debug", (req, res) => {
  res.json({
    env: process.env,
    message: "Debug mode enabled"
  });
});
```


### **Why this is a security vulnerability**

This endpoint exposes **all environment variables** of the application, which may include:

* API keys
* Database credentials
* Authentication secrets
* Cloud service tokens

Since the endpoint is publicly accessible and has no authentication, any user can retrieve sensitive system information.



### **Impact of the vulnerability**

If exploited, an attacker could:

* Gain unauthorized access to backend services
* Steal sensitive credentials
* Compromise the database or external APIs
* Gain control over deployment pipelines

This is classified as an **Information Disclosure vulnerability**, which can lead to full system compromise.



### **Severity Level**

**High**

Because it exposes sensitive runtime configuration data directly to external users.


### **Mitigation / Fix**

The vulnerability can be fixed by either:

#### Option 1: Remove the endpoint completely

```javascript
// Remove debug endpoint in production
```

#### Option 2: Secure the endpoint with authentication

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


## **Conclusion**

A complete CI/CD pipeline was successfully implemented using GitHub Actions, enabling automated testing, Docker image creation, and deployment to a staging environment. Additionally, a critical security vulnerability was identified, analyzed, and mitigated to demonstrate secure development practices.



